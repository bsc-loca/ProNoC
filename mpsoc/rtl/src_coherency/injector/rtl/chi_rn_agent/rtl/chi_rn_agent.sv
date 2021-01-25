/*------------------------------------------------------------------------------
* Copyright (C) 2018, 2019, SemiDynamics Technology Services, S.L.U.  
* The copyright to the computer program(s) herein is the property of
* SemiDynamics Technology Services, S.L.U. All Rights Reserved.  NOTICE: the
* intellectual and technical concepts contained herein are proprietary to
* SemiDynamics Technology Services, S.L.U. and are protected by trade secret or
* copyright law.  Dissemination of this information and use or reproduction of
* this material is strictly forbidden unless prior written permission is
* obtained from SemiDynamics Technology Services, S.L.U. The program(s) may be
* used and/or reproduced only with the written permission of SemiDynamics
* Technology Services, S.L.U. and in accordance with the regulations under the
* Horizon 2020 Grant Agreement and the terms and conditions of MontBlanc 2020
* Consortium Agreement under which the program(s) have been distributed. Unless
* required by applicable law or agreed in writing, the program(s) is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied.
*-------------------------------------------------------------------------------
*   Author:         Xubin Tan
*   Email:          xubin.tan@semidynamics.com
*   Date:           13/03/2019
*-------------------------------------------------------------------------------
*   Title:          CHI Requestor Agent Top Module
*
*   Description:    This block is used to translate the L2 Cache requests to 
*                   the NoC in a CHI compliant format, and the vice versa.
*
*                   From the L2 Cache side, there are four queues (two inputs 
*                   and two outputs): L2 request, L2 evict, Fill and Snoop.
*                   From the NoC side, there are six standard CHI channels. 
*                   
*                   This CHI RN Agent has all the required features specified 
*                   as a Requestor Agent in the spec.
*        
*                   Add size for 1 to 8 bytes for Atomic operations, which 
*                   requires changes in the TXREQ pipeline to send reqflit with 
*                   the correct size field for atomics, in the txnid table to store 
*                   the size and the retry logic when the retry operation is Atomics.
*            
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module chi_rn_agent
    import chi_rn_params_pkg::*;
#(
    // initial number of credits is 2**LOG_LCREDITS_NUM - 1
    parameter LOG_LCREDITS_NUM = 4,
    // set to 1 if initial credit handshaking is required
    parameter NOC_INITS_CRED = 0,
    // set to 1 to arbitrate based on l2_chi_arb queue
    parameter ARB_WITH_QUEUE = 0,
    // optional flit fields
    parameter CHI_DAT_HAS_CCID = 1,
    parameter CHI_DAT_HAS_DATAID = 1,
    parameter CHI_DAT_HAS_TRACETAG = 1,
    parameter CHI_DAT_HAS_DATACHECK = 1,
    parameter CHI_DAT_HAS_POISON = 1,
    parameter CHI_RSP_HAS_TRACETAG = 1,
    parameter CHI_REQ_HAS_ENDIAN = 1,
    parameter CHI_REQ_HAS_NS = 1,
    parameter CHI_REQ_HAS_LIKELYSHARED = 1,
    parameter CHI_REQ_HAS_TRACETAG = 1,
    // add rsp_chi field inside the l2_evict packet
    parameter CHI_EVICT_HAS_RSP_CH = 0,
    // parameter for flit structs and configurable field sizes
    parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
    parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t,
    parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
    parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
    parameter type l2_req_pkt_t      = l2_req_pkt_default_t,
    parameter type l2_evict_pkt_t    = l2_evict_pkt_default_t,
    parameter type l2_data_pkt_t     = l2_data_pkt_default_t,
    parameter type l2_fill_pkt_t     = l2_fill_pkt_default_t,
    parameter type l2_snoop_req_pkt_t = l2_snoop_req_pkt_default_t,
    parameter REQ_FLIT_SIZE          = $bits(chi_reqflit_pkt_default_t),
    parameter DAT_FLIT_SIZE          = $bits(chi_datflit_pkt_default_t),
    parameter RSP_FLIT_SIZE          = $bits(chi_rspflit_pkt_default_t),
    parameter SNP_FLIT_SIZE          = $bits(chi_snpflit_pkt_default_t),
    parameter L2_REQ_SIZE            = $bits(l2_req_pkt_default_t),
    parameter L2_EVICT_SIZE          = $bits(l2_evict_pkt_default_t),
    parameter L2_DATA_SIZE           = $bits(l2_data_pkt_default_t),
    parameter L2_FILL_SIZE           = $bits(l2_fill_pkt_default_t),
    parameter L2_SNOOP_REQ_SIZE      = $bits(l2_snoop_req_pkt_default_t),
    parameter L2_TBL_ID              = L2_TBL_ID_DEFAULT,
    parameter QOS_REQ                = QOS_REQ_DEFAULT,
    parameter TGTID_REQ              = TGTID_REQ_DEFAULT,
    parameter SRCID_REQ              = SRCID_REQ_DEFAULT,
    parameter RETURNNID_REQ          = RETURNNID_REQ_DEFAULT,
    parameter ADDR_REQ               = ADDR_REQ_DEFAULT,
    parameter LPID_REQ               = LPID_REQ_DEFAULT,
    parameter QOS_DAT                = QOS_DAT_DEFAULT,
    parameter TGTID_DAT              = TGTID_DAT_DEFAULT,
    parameter SRCID_DAT              = SRCID_DAT_DEFAULT,
    parameter HOMENID_DAT            = HOMENID_DAT_DEFAULT,
    parameter OPCODE_DAT             = OPCODE_DAT_DEFAULT,
    parameter DATA_DAT               = DATA_DAT_DEFAULT,
    parameter BE_DAT                 = BE_DAT_DEFAULT,
    parameter DATACHECK_DAT          = DATACHECK_DAT_DEFAULT,
    parameter POISON_DAT             = POISON_DAT_DEFAULT,
    parameter QOS_RSP                = QOS_RSP_DEFAULT,
    parameter TGTID_RSP              = TGTID_RSP_DEFAULT,
    parameter SRCID_RSP              = SRCID_RSP_DEFAULT,
    parameter ADDR_SNP               = ADDR_SNP_DEFAULT
)(
    // Clock and Reset
    input   logic                       clk_i                       ,
    input   logic                       rst_ni                      ,
    // Interface with L2 
    // NoC Response Queue
    output  logic                       l2_chi_q_pop_o              ,
    input   logic                       l2_chi_q_empty_i            ,
    input   l2_req_pkt_t                l2_chi_q_data_i             ,
    // Evict Queue
    output  logic                       l2_chi_evt_q_pop_o          ,
    input   logic                       l2_chi_evt_q_highoccupancy_i,
    input   logic                       l2_chi_evt_q_empty_i        ,
    input   l2_evict_pkt_t              l2_chi_evt_q_data_i         ,
    // Arbitration queue
    output  logic                       l2_chi_arb_q_pop_o           ,
    input   logic                       l2_chi_arb_q_empty_i         ,
    input   logic [ARB_QUEUE_W-1:0]     l2_chi_arb_q_data_i          ,
    // To Fill Queue From CHI
    output  logic                       chi_l2_fill_q_push_o        ,
    output  l2_fill_pkt_t               chi_l2_fill_q_data_o        ,
    input   logic                       chi_l2_fill_q_full_i        ,
    // To Snoop Queue From CHI
    output  logic                       chi_l2_snp_q_push_o         ,
    output  l2_snoop_req_pkt_t          chi_l2_snp_q_data_o         ,
    input   logic                       chi_l2_snp_q_full_i         ,
    // Interface with NoC 
    // TXREQ
    output logic                        chi_noc_txreqflitpend       ,
    output logic                        chi_noc_txreqflitv          ,
    output chi_reqflit_pkt_t            chi_noc_txreqflit           ,
    input  logic                        noc_chi_txreqlcrdv          ,
    // TXDAT
    output logic                        chi_noc_txdatflitpend       ,
    output logic                        chi_noc_txdatflitv          ,
    output chi_datflit_pkt_t            chi_noc_txdatflit           ,
    input  logic                        noc_chi_txdatlcrdv          ,
    // TXRSP
    output logic                        chi_noc_txrspflitpend       ,
    output logic                        chi_noc_txrspflitv          ,
    output chi_rspflit_pkt_t            chi_noc_txrspflit           ,
    input  logic                        noc_chi_txrsplcrdv          ,
    // CRSP/RXRSP
    input  logic                        noc_chi_rxrspflitpend       ,
    input  logic                        noc_chi_rxrspflitv          ,
    input  chi_rspflit_pkt_t            noc_chi_rxrspflit           ,
    output logic                        chi_noc_rxrsplcrdv          ,
    // RDAT
    input  logic                        noc_chi_rxdatflitpend       ,
    input  logic                        noc_chi_rxdatflitv          ,
    input  chi_datflit_pkt_t            noc_chi_rxdatflit           ,
    output logic                        chi_noc_rxdatlcrdv          , 
    // SNP/RXSNP
    input  logic                        noc_chi_rxsnpflitpend       ,
    input  logic                        noc_chi_rxsnpflitv          ,
    input  chi_snpflit_pkt_t            noc_chi_rxsnpflit           ,
    output logic                        chi_noc_rxsnplcrdv          ,
    // SAM Interface
    output logic [ADDR_REQ-1:0]         sam_target_address_o        ,
    input  logic [TGTID_REQ-1:0]        sam_target_id_i             ,
    input  logic [SRCID_REQ-1:0]        src_id
    //input  logic [SRCID_REQ-1:0]        source_id_i
);    


// struct definition
// placed here as they depend on parameters
// which have a variable size
typedef struct packed{
    logic                            valid ;
    logic [PCRDTYPE_RSP-1:0]         pcrdtype;
    logic [SRCID_RSP-1:0]            srcid;
    logic [TXNID_RSP-1:0]            first_txnid;
    logic [PCRDGRANT_TABLE_ADDR-1:0] cnt_retryack;
    logic [PCRDGRANT_TABLE_ADDR-1:0] cnt_pcrdgrant;
} pcrdgrant_table_pkt_t;
localparam PCRDGRANT_TABLE_DAT2 = PCRDTYPE_RSP+SRCID_RSP;
localparam PCRDGRANT_TABLE_DAT = $bits(pcrdgrant_table_pkt_t);

typedef struct packed{
    logic   [OPCODE_REQ-1:0]      opcode_req;
    logic   [L2_TBL_ID-1:0]       tbl_id;
    logic   [L2_BANK_ID-1:0]      bank_addr;
    logic   [WDAT_TABLE_ADDR-1:0] wdat_table_addr; // = {WDAT_TABLE_ADDR{1'b0}};
    logic   [RETRY_ADDR-1:0]      addr; // = {RETRY_ADDR{1'b0}};
    logic                         compack;
    logic                         excl_snoopme;
    logic   [1:0]                 amo_size;
} txnid_table_pkt2_t;

typedef struct packed {
    // write field 2
    txnid_table_pkt2_t            mem2;
    // write field 3
    logic   [TXNID_REQ-1:0]       next_txnid; 
} txnid_table_pkt_t;

localparam TXNID_TABLE_DAT = $bits(txnid_table_pkt_t);
localparam TXNID_TABLE_DAT2 = $bits(txnid_table_pkt2_t);
localparam TXNID_TABLE_DAT3 = TXNID_REQ;
localparam TXNID_TABLE_DAT1_OFFSET = TXNID_TABLE_DAT;
localparam TBL_BANK_ID_OFFSET = TXNID_TABLE_DAT-OPCODE_REQ; 
localparam TXNID_TABLE_WDAT_OFFSET = TBL_BANK_ID_OFFSET - L2_TBL_ID - L2_BANK_ID; 
localparam TXNID_TABLE_ADDR_OFFSET = TXNID_TABLE_WDAT_OFFSET - WDAT_TABLE_ADDR; 

//package to define the necessary fields for the wdat_table entry
typedef struct packed {
    logic   [DATA_DAT-1:0]   data; 
    logic   [BE_DAT-1:0]     dmask; 
} wdat_table_pkt_t;

localparam WDAT_TABLE_DAT = $bits(wdat_table_pkt_t);

// logic definition

// interface with TxnID table
logic                                     tmp_txnid_table_full_o;
logic [TXNID_TABLE_ADDR-1:0]              tmp_txnid_table_index_o;

logic                                     rxrspp_txnid_table_rd_en_1_i;
logic [TXNID_TABLE_ADDR-1:0]              rxrspp_txnid_table_rd_addr_1_i;
logic [TXNID_TABLE_DAT-1:0]               rxrspp_txnid_table_rd_data_1_o;
logic                                     rxrspp_txnid_table_rd_data_valid_1_o;

logic                                     retry_txnid_table_rd_en_1_i;
logic [TXNID_TABLE_ADDR-1:0]              retry_txnid_table_rd_addr_1_i;
logic [TXNID_TABLE_DAT-1:0]               retry_txnid_table_rd_data_1_o;
logic                                     retry_txnid_table_rd_data_valid_1_o;

logic                                     tmp_txnid_table_rd_en_1_i  ;
logic [TXNID_TABLE_ADDR-1:0]              tmp_txnid_table_rd_addr_1_i;
logic [TXNID_TABLE_DAT-1:0]               tmp_txnid_table_rd_data_1_o;
logic                                     tmp_txnid_table_rd_data_valid_1_o;


logic                                     tmp_txnid_table_rd_en_2_i;
logic [TXNID_TABLE_ADDR-1:0]              tmp_txnid_table_rd_addr_2_i;
logic [TXNID_TABLE_DAT-1:0]               tmp_txnid_table_rd_data_2_o;
logic                                     tmp_txnid_table_rd_data_valid_2_o;
logic                                     tmp_txnid_table_wr_en_1_or_i;
logic                                     tmp_txnid_table_wr_en_1_and_i;
logic                                     tmp_txnid_table_wr_en_2_i;
logic                                     tmp_txnid_table_wr_en_3_i;
logic [TXNID_TABLE_ADDR-1:0]              tmp_txnid_table_wr_addr_2_i; 
logic [TXNID_TABLE_ADDR-1:0]              tmp_txnid_table_wr_addr_3_i; 
logic [2**TXNID_TABLE_ADDR-1:0]           tmp_txnid_table_wr_data_1_or_i;
logic [2**TXNID_TABLE_ADDR-1:0]           tmp_txnid_table_wr_data_1_and_i;
logic [TXNID_TABLE_DAT2-1:0]              tmp_txnid_table_wr_data_2_i;
logic [TXNID_TABLE_DAT3-1:0]              tmp_txnid_table_wr_data_3_i;
logic [2**TXNID_TABLE_ADDR-1:0]           tmp_rxdatp_txnid_table_wr_data_1_and_o;
logic [2**TXNID_TABLE_ADDR-1:0]           tmp_rxrspp_txnid_table_wr_data_1_and_o;
logic [2**TXNID_TABLE_ADDR-1:0]           tmp_retry_txnid_table_wr_data_1_and_o;

/*----------- interface with Wdat table ---------------------------*/
logic                                     tmp_wdat_table_full_o;
logic [WDAT_TABLE_ADDR-1:0]               tmp_wdat_table_index_o;
logic                                     tmp_wdat_table_rd_en_i;
logic [WDAT_TABLE_ADDR-1:0]               tmp_wdat_table_rd_addr_i;
logic [WDAT_TABLE_DAT-1:0]                tmp_wdat_table_rd_data_o;
logic                                     tmp_wdat_table_rd_data_valid_o;

logic                                     tmp_wdat_table_wr_en_1_or_i; 
logic                                     tmp_wdat_table_wr_en_1_and_i; 
logic [2**WDAT_TABLE_ADDR-1:0]            tmp_wdat_table_wr_data_1_or_i; 
logic [2**WDAT_TABLE_ADDR-1:0]            tmp_wdat_table_wr_data_1_and_i; 
logic                                     tmp_wdat_table_wr_en_2_i; 
logic [WDAT_TABLE_ADDR-1:0]               tmp_wdat_table_wr_addr_2_i; 
logic [WDAT_TABLE_DAT-1:0]                tmp_wdat_table_wr_data_2_i; 

/*----------- interface with SNOOP table ---------------------------*/
logic                                     tmp_snoop_table_full_o;
logic [SNOOP_TABLE_ADDR-1:0]              tmp_snoop_table_index_o;
logic                                     tmp_snoop_table_rd_en_i;
logic [SNOOP_TABLE_ADDR-1:0]              tmp_snoop_table_rd_addr_i;
logic [SNOOP_TABLE_DAT-1:0]               tmp_snoop_table_rd_data_o;
logic                                     tmp_snoop_table_rd_data_valid_o;

logic                                     tmp_snoop_table_wr_en_1_or_i; 
logic                                     tmp_snoop_table_wr_en_1_and_i; 
logic [2**SNOOP_TABLE_ADDR-1:0]           tmp_snoop_table_wr_data_1_or_i; 
logic [2**SNOOP_TABLE_ADDR-1:0]           tmp_snoop_table_wr_data_1_and_i; 
logic                                     tmp_snoop_table_wr_en_2_i; 
logic [SNOOP_TABLE_ADDR-1:0]              tmp_snoop_table_wr_addr_2_i; 
logic [SNOOP_TABLE_DAT-1:0]               tmp_snoop_table_wr_data_2_i; 

/*----------- interface with TXREQ Pipeline ---------------------------*/
/*----------- interface with SNOOP Logic ------------------------------*/
logic                                     snpp_rxrspp_datflitv_w;
logic [DAT_FLIT_SIZE-1:0]                 snpp_rxrspp_datflit_w;
logic                                     rxrspp_snpp_stall_w; 
logic                                     l2_snp_data_valid_w;
l2_req_pkt_t                              l2_snp_req_w;
l2_data_pkt_t                             l2_snp_data_w;
logic                                     snpp_txreq_arb_stop_w;
                                                                      
/*----------- interface with RXRSP Pipeline --------------------------------*/
logic                                     rxrspp_txnid_table_wr_en_1_and_o;
logic [2**TXNID_TABLE_ADDR-1:0]           rxrspp_txnid_table_wr_data_1_and_o;
logic                                     rxrspp_txreqp_retry_valid_o;
logic                                     rxrspp_fill_data_valid_o;
l2_fill_pkt_t                             rxrspp_fill_data_o;
logic                                     rxrspp_fill_q_full_i;

/*----------- interface with RXDAT Pipeline -------------------------------*/
logic                                     rxdatp_txnid_table_wr_en_1_and_o;
logic [2**TXNID_TABLE_ADDR-1:0]           rxdatp_txnid_table_wr_data_1_and_o;
logic [RSP_FLIT_SIZE-1:0]                 snpp_rxdatp_rspflit_w; 
logic                                     snpp_rxdatp_rspflitv_w; 
logic                                     rxdatp_snpp_stall_w; 
                                                                        
logic                                     rxrspp_rxdatp_rspflitv_w; 
logic [RSP_FLIT_SIZE-1:0]                 rxrspp_rxdatp_rspflit_w;
logic                                     rxrspp_rxdatp_cmpack_stall_w;

                                                                       
logic                                     rxdatp_fill_data_valid_o;
l2_fill_pkt_t                             rxdatp_fill_data_o;
logic                                     rxdatp_fill_q_full_i;

/*----------- interface with the retry logic ---------------------------*/
logic [TGTID_REQ-1:0]                     tmp_retry_tgtid_o; 
logic [SRCID_REQ-1:0]                     tmp_retry_srcid_o; 
logic [TXNID_REQ-1:0]                     tmp_retry_txnid_o; 
logic [OPCODE_REQ-1:0]                    tmp_retry_opcode_o; 
logic [ADDR_REQ-1:0]                      tmp_retry_addr_o; 
logic [1:0]                               tmp_retry_amo_size_o; 
logic [PCRDTYPE_REQ-1:0]                  tmp_retry_pcrdtype_o; 
logic                                     tmp_retry_excl_snoopme_o; 
logic                                     tmp_retry_req_metadata_valid_o; 
logic                                     txreqp_retry_stall_w; 
logic                                     retry_rxrspp_stall_w; 
logic                                     rxrspp_retry_rspflit_valid_w;
logic [RSP_FLIT_SIZE-1:0]                 rxrspp_retry_rspflit_w; 
logic                                     retry_txnid_table_wr_en_1_and_o;
logic [2**TXNID_TABLE_ADDR-1:0]           retry_txnid_table_wr_data_1_and_o;

logic                                     retry_fill_data_valid_o;
l2_fill_pkt_t                             retry_fill_data_o;
logic                                     retry_fill_q_full_i;

// start coding body
txreq_p #(
    .LOG_LCREDITS_NUM        (LOG_LCREDITS_NUM        ),
    .NOC_INITS_CRED          (NOC_INITS_CRED          ),
    .ARB_WITH_QUEUE          (ARB_WITH_QUEUE          ),
    .CHI_REQ_HAS_ENDIAN      (CHI_REQ_HAS_ENDIAN      ),
    .CHI_REQ_HAS_NS          (CHI_REQ_HAS_NS          ),
    .CHI_REQ_HAS_LIKELYSHARED(CHI_REQ_HAS_LIKELYSHARED),
    .CHI_REQ_HAS_TRACETAG    (CHI_REQ_HAS_TRACETAG    ),
    .CHI_EVICT_HAS_RSP_CH    (CHI_EVICT_HAS_RSP_CH    ),
    .chi_reqflit_pkt_t       (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t       (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t       (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t       (chi_snpflit_pkt_t),
    .l2_evict_pkt_t          (l2_evict_pkt_t),
    .l2_data_pkt_t           (l2_data_pkt_t ),
    .l2_req_pkt_t            (l2_req_pkt_t  ),
    .REQ_FLIT_SIZE           (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE           (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE           (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE           (SNP_FLIT_SIZE    ),
    .L2_REQ_SIZE             (L2_REQ_SIZE      ),
    .L2_EVICT_SIZE           (L2_EVICT_SIZE    ),
    .L2_DATA_SIZE            (L2_DATA_SIZE     ),
    .SRCID_REQ               (SRCID_REQ        ),
    .TGTID_REQ               (TGTID_REQ        ),
    .ADDR_REQ                (ADDR_REQ         ),
    .QOS_REQ                 (QOS_REQ          ),
    .RETURNNID_REQ           (RETURNNID_REQ    ),
    .LPID_REQ                (LPID_REQ         ),
    .TXNID_TABLE_DAT2        (TXNID_TABLE_DAT2 ),
    .WDAT_TABLE_DAT          (WDAT_TABLE_DAT   ),
    .txnid_table_pkt2_t      (txnid_table_pkt2_t),
    .SAM_TGT_ADDR_W          (ADDR_REQ         )
) txreq_p_inst (
    // Clock and Reset
    .clk                         (clk_i                         ),
    .rst_n                       (rst_ni                        ),
    /*--------- Interface with L2 -----------------------------------*/
    // NoC Response Queue
    .l2_chi_q_pop_o              (l2_chi_q_pop_o                ),
    .l2_chi_q_empty_i            (l2_chi_q_empty_i              ),
    .l2_chi_q_data_i             (l2_chi_q_data_i               ),
    // Evict Queue
    .l2_chi_evt_q_pop_o          (l2_chi_evt_q_pop_o            ),
    .l2_chi_evt_q_data_i         (l2_chi_evt_q_data_i           ),
    .l2_chi_evt_q_highoccupancy_i(l2_chi_evt_q_highoccupancy_i  ),
    .l2_chi_evt_q_empty_i        (l2_chi_evt_q_empty_i          ),
    // Arbitration queue
    .l2_chi_arb_q_pop_o          (l2_chi_arb_q_pop_o            ),
    .l2_chi_arb_q_empty_i        (l2_chi_arb_q_empty_i          ),
    .l2_chi_arb_q_data_i         (l2_chi_arb_q_data_i           ),
    /*--------- Interface with NoC ----------------------------------*/
    // TXREQ
    .chi_noc_txreqflitpend       (chi_noc_txreqflitpend         ),
    .chi_noc_txreqflitv          (chi_noc_txreqflitv            ),
    .chi_noc_txreqflit           (chi_noc_txreqflit             ),
    .noc_chi_txreqlcrdv          (noc_chi_txreqlcrdv            ),
    /*---------- Interface with Snoop logic -------------------------*/
    .l2_snp_data_valid_o         (l2_snp_data_valid_w           ),
    .l2_snp_req_o                (l2_snp_req_w                  ),
    .l2_snp_data_o               (l2_snp_data_w                 ),
    .l2_snp_data_stall_i         (snpp_txreq_arb_stop_w         ),
    /*--------- Retry signals ---------------------------------------*/
    .retry_tgtid_i               (tmp_retry_tgtid_o             ),
    .retry_srcid_i               (tmp_retry_srcid_o             ),
    .retry_txnid_i               (tmp_retry_txnid_o             ),
    .retry_opcode_i              (tmp_retry_opcode_o            ),
    .retry_addr_i                (tmp_retry_addr_o              ),
    .retry_amo_size_i            (tmp_retry_amo_size_o          ),
    .retry_pcrdtype_i            (tmp_retry_pcrdtype_o          ),
    .retry_excl_snoopme_i        (tmp_retry_excl_snoopme_o      ),
    .retry_req_metadata_valid_i  (tmp_retry_req_metadata_valid_o),
    .retry_stall_o               (txreqp_retry_stall_w          ),
    /*----------- interface with TxnID table ------------------------*/
    .txnid_table_full_i          (tmp_txnid_table_full_o        ),
    .txnid_table_index_i         (tmp_txnid_table_index_o       ),
    .txnid_table_wr_en_1_or_o    (tmp_txnid_table_wr_en_1_or_i  ),
    .txnid_table_wr_en_2_o       (tmp_txnid_table_wr_en_2_i     ),
    .txnid_table_wr_addr_2_o     (tmp_txnid_table_wr_addr_2_i   ),
    .txnid_table_wr_data_1_or_o  (tmp_txnid_table_wr_data_1_or_i),
    .txnid_table_wr_data_2_o     (tmp_txnid_table_wr_data_2_i   ),
    /*---------------------------------------------------------------*/
    /*----------- interface with Wdat table -------------------------*/
    .wdat_table_full_i           (tmp_wdat_table_full_o         ),
    .wdat_table_index_i          (tmp_wdat_table_index_o        ),
    .wdat_table_wr_en_1_or_o     (tmp_wdat_table_wr_en_1_or_i   ),
    .wdat_table_wr_data_1_or_o   (tmp_wdat_table_wr_data_1_or_i ),
    .wdat_table_wr_en_2_o        (tmp_wdat_table_wr_en_2_i      ),
    .wdat_table_wr_addr_2_o      (tmp_wdat_table_wr_addr_2_i    ),
    .wdat_table_wr_data_2_o      (tmp_wdat_table_wr_data_2_i    ),
    /*----------------------------------------------------------------*/
    /*----------- SAM Interface --------------------------------------*/
    .sam_target_address_o        (sam_target_address_o          ),
    .sam_target_id_i             (sam_target_id_i               ),
    .src_id                      (src_id                        ) 
    //.source_id_i                 (source_id_i                   )
);

snp_p_l2_to_chi #(
    .CHI_EVICT_HAS_RSP_CH (CHI_EVICT_HAS_RSP_CH),
    .CHI_RSP_HAS_TRACETAG (CHI_RSP_HAS_TRACETAG),
    .CHI_DAT_HAS_CCID     (CHI_DAT_HAS_CCID),
    .CHI_DAT_HAS_DATAID   (CHI_DAT_HAS_DATAID),
    .CHI_DAT_HAS_TRACETAG (CHI_DAT_HAS_TRACETAG),
    .CHI_DAT_HAS_DATACHECK(CHI_DAT_HAS_DATACHECK),
    .CHI_DAT_HAS_POISON   (CHI_DAT_HAS_POISON),
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .l2_req_pkt_t        (l2_req_pkt_t     ),
    .l2_data_pkt_t       (l2_data_pkt_t    ),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    ),
    .L2_REQ_SIZE         (L2_REQ_SIZE      ),
    .L2_TBL_ID           (L2_TBL_ID        ),
    .QOS_RSP             (QOS_RSP          ),
    .SRCID_RSP           (SRCID_RSP        ),
    .OPCODE_DAT          (OPCODE_DAT       ),
    .DATA_DAT            (DATA_DAT         ),
    .BE_DAT              (BE_DAT           ),
    .DATACHECK_DAT       (DATACHECK_DAT    ),
    .POISON_DAT          (POISON_DAT       )
    ) snp_p_l2_to_chi_inst
(
     //generic
    .clk                               (clk_i                              ),
    .rst_n                             (rst_ni                             ),
    /*--------- Stop signal ----------------------------------------------*/
    .stop_i                            (1'b0                               ),
    /*--------- Interface with TXREQ logic -------------------------------*/
    .l2_snp_data_valid_i               (l2_snp_data_valid_w                ),
    .l2_snp_req_i                      (l2_snp_req_w                       ),
    .l2_snp_data_i                     (l2_snp_data_w                      ),
    /*--------- Interface with Snoop table -------------------------------*/
    // read port  
    .snoop_table_rd_en_o               (tmp_snoop_table_rd_en_i            ),
    .snoop_table_rd_addr_o             (tmp_snoop_table_rd_addr_i          ),
    .snoop_table_data_output_i         (tmp_snoop_table_rd_data_o          ),
    .snoop_table_data_output_valid_i   (tmp_snoop_table_rd_data_valid_o    ),
    // write port 
    .snoop_table_wr_en_1_and_o         (tmp_snoop_table_wr_en_1_and_i      ),
    .snoop_table_wr_data_1_and_o       (tmp_snoop_table_wr_data_1_and_i    ),
    /*--------- Common interface with other pipelines --------------------*/
    .snpp_txrsp_rspflit_o              (snpp_rxdatp_rspflit_w              ), 
    .snpp_txrsp_rspflitv_o             (snpp_rxdatp_rspflitv_w             ), 
    .txrsp_snpp_stall_i                (rxdatp_snpp_stall_w                ), 
    /*--------- Interface with RXRSP to TXDAT pipeline encode stage ------*/
    .snpp_txdat_datflit_o              (snpp_rxrspp_datflit_w              ),
    .snpp_txdat_datflitv_o             (snpp_rxrspp_datflitv_w             ),
    .txdat_snpp_stall_i                (rxrspp_snpp_stall_w                ),
    /*--------- Stop signal ----------------------------------------------*/
    .stop_o                            (snpp_txreq_arb_stop_w              ),
    .src_id                            (src_id                             ) 
);


rxrsp_p #(
    .LOG_LCREDITS_NUM     (LOG_LCREDITS_NUM),
    .NOC_INITS_CRED       (NOC_INITS_CRED),
    .CHI_DAT_HAS_CCID     (CHI_DAT_HAS_CCID),
    .CHI_DAT_HAS_DATAID   (CHI_DAT_HAS_DATAID),
    .CHI_DAT_HAS_TRACETAG (CHI_DAT_HAS_TRACETAG),
    .CHI_DAT_HAS_DATACHECK(CHI_DAT_HAS_DATACHECK),
    .CHI_DAT_HAS_POISON   (CHI_DAT_HAS_POISON),
    .CHI_RSP_HAS_TRACETAG (CHI_RSP_HAS_TRACETAG),
    .chi_reqflit_pkt_t    (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t    (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t    (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t    (chi_snpflit_pkt_t),
    .l2_fill_pkt_t        (l2_fill_pkt_t    ),
    .REQ_FLIT_SIZE        (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE        (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE        (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE        (SNP_FLIT_SIZE    ),
    .HOMENID_DAT          (HOMENID_DAT      ),
    .DATACHECK_DAT        (DATACHECK_DAT    ),
    .POISON_DAT           (POISON_DAT       ),
    .TXNID_TABLE_DAT      (TXNID_TABLE_DAT  ),
    .WDAT_TABLE_DAT       (WDAT_TABLE_DAT   ),
    .DATA_DAT             (DATA_DAT         ),
    .txnid_table_pkt_t    (txnid_table_pkt_t),
    .wdat_table_pkt_t     (wdat_table_pkt_t )
    ) rxrsp_p_inst
(
    // Clock and Reset
    .clk                           (clk_i                                ),
    .rst_n                         (rst_ni                               ),
    /*--------- Interface with NoC -------------------------------------*/
    // CRSP/RXRSP
    .noc_chi_rxrspflitpend         (noc_chi_rxrspflitpend                ),
    .noc_chi_rxrspflitv            (noc_chi_rxrspflitv                   ),
    .noc_chi_rxrspflit             (noc_chi_rxrspflit                    ),
    .chi_noc_rxrsplcrdv            (chi_noc_rxrsplcrdv                   ),
    // TXDAT
    .chi_noc_txdatflitpend         (chi_noc_txdatflitpend                ),
    .chi_noc_txdatflitv            (chi_noc_txdatflitv                   ),
    .chi_noc_txdatflit             (chi_noc_txdatflit                    ),
    .noc_chi_txdatlcrdv            (noc_chi_txdatlcrdv                   ),
    /*----------- interface with TxnID table ---------------------------*/
    .txnid_table_rd_en_o           (rxrspp_txnid_table_rd_en_1_i         ),
    .txnid_table_rd_addr_o         (rxrspp_txnid_table_rd_addr_1_i       ),
    .txnid_table_rd_data_i         (rxrspp_txnid_table_rd_data_1_o       ),
    .txnid_table_rd_data_valid_i   (rxrspp_txnid_table_rd_data_valid_1_o ), 
    .txnid_table_wr_en_1_and_o     (rxrspp_txnid_table_wr_en_1_and_o     ),
    .txnid_table_wr_data_1_and_o   (rxrspp_txnid_table_wr_data_1_and_o   ),
    /*----------- interface with Wdat table ----------------------------*/
    .wdat_table_rd_en_o            (tmp_wdat_table_rd_en_i               ),
    .wdat_table_rd_addr_o          (tmp_wdat_table_rd_addr_i             ),
    .wdat_table_rd_data_i          (tmp_wdat_table_rd_data_o             ),
    .wdat_table_rd_data_valid_i    (tmp_wdat_table_rd_data_valid_o       ),
    .wdat_table_wr_en_1_and_o      (tmp_wdat_table_wr_en_1_and_i         ),
    .wdat_table_wr_data_1_and_o    (tmp_wdat_table_wr_data_1_and_i       ),
    /*----------- Snoop data response ----------------------------------*/
    .snpp_rxrspp_datflitv_i        (snpp_rxrspp_datflitv_w               ),
    .snpp_rxrspp_datflit_i         (snpp_rxrspp_datflit_w                ),
    .rxrspp_snpp_stall_o           (rxrspp_snpp_stall_w                  ),
    /*--------- Output Retry signal to TXREQ pipeline-------------------*/
    .retry_rspflit_valid_o         (rxrspp_retry_rspflit_valid_w         ),
    .retry_rspflit_o               (rxrspp_retry_rspflit_w               ),
    .retry_stall_i                 (retry_rxrspp_stall_w                 ),
    /*--------- Output COMPACK to RXDAT pipeline------------------------*/
    .rxrspp_rxdatp_rspflitv_o      (rxrspp_rxdatp_rspflitv_w             ),
    .rxrspp_rxdatp_rspflit_o       (rxrspp_rxdatp_rspflit_w              ),
    .rxdatp_rxrspp_cmpack_stall_i  (rxrspp_rxdatp_cmpack_stall_w         ),
    /*--------- Interface with FILL Queue Arbiter-----------------------*/
    .rxrspp_fill_data_valid_o      (rxrspp_fill_data_valid_o             ),
    .rxrspp_fill_data_o            (rxrspp_fill_data_o                   ),
    .rxrspp_fill_q_full_i          (rxrspp_fill_q_full_i                 ) 
);

retry_logic #(
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .l2_fill_pkt_t       (l2_fill_pkt_t    ),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    ),
    .L2_DATA_SIZE        (L2_DATA_SIZE     ),
    .SRCID_REQ           (SRCID_REQ        ),
    .TGTID_REQ           (TGTID_REQ        ),
    .ADDR_REQ            (ADDR_REQ         ),
    .TXNID_TABLE_DAT     (TXNID_TABLE_DAT  ),
    .TXNID_TABLE_DAT3    (TXNID_TABLE_DAT3 ),
    .PCRDGRANT_TABLE_DAT2(PCRDGRANT_TABLE_DAT2),
    .txnid_table_pkt_t   (txnid_table_pkt_t)
    ) retry_logic_inst
(
    // Clock and reset
    .clk                               (clk_i                              ),
    .rst_n                             (rst_ni                             ),
    // input stall
    .retry_stall_i                     (txreqp_retry_stall_w               ),
    // Interface with RXRSP pipeline to receive the RetryAck and PcrdGrant
    .rxrspp_retry_rspflit_i            (rxrspp_retry_rspflit_w             ),
    .rxrspp_retry_rspflitv_i           (rxrspp_retry_rspflit_valid_w       ), 
    .retry_rxrspp_stall_o              (retry_rxrspp_stall_w               ), 
    // Interface with TxnID table
    // read port               
    .txnid_table_rd_en_o               (retry_txnid_table_rd_en_1_i        ),
    .txnid_table_rd_addr_o             (retry_txnid_table_rd_addr_1_i      ),
    .txnid_table_rd_data_i             (retry_txnid_table_rd_data_1_o      ),
    .txnid_table_rd_data_valid_i       (retry_txnid_table_rd_data_valid_1_o), 
    // write port               
    .txnid_table_wr_en_1_and_o         (retry_txnid_table_wr_en_1_and_o    ),
    .txnid_table_wr_data_1_and_o       (retry_txnid_table_wr_data_1_and_o  ),
    .txnid_table_wr_en_3_o             (tmp_txnid_table_wr_en_3_i          ),
    .txnid_table_wr_addr_3_o           (tmp_txnid_table_wr_addr_3_i        ),
    .txnid_table_wr_data_3_o           (tmp_txnid_table_wr_data_3_i        ),
    // Interface with TXREQ pipeline to resend the Request with credit
    .retry_tgtid_o                     (tmp_retry_tgtid_o                  ), 
    .retry_srcid_o                     (tmp_retry_srcid_o                  ), 
    .retry_txnid_o                     (tmp_retry_txnid_o                  ), 
    .retry_opcode_o                    (tmp_retry_opcode_o                 ), 
    .retry_addr_o                      (tmp_retry_addr_o                   ), 
    .retry_amo_size_o                  (tmp_retry_amo_size_o               ), 
    .retry_pcrdtype_o                  (tmp_retry_pcrdtype_o               ), 
    .retry_excl_snoopme_o              (tmp_retry_excl_snoopme_o           ), 
    .retry_req_metadata_valid_o        (tmp_retry_req_metadata_valid_o     ), 
    // Output to FILL 
    .retry_fill_data_o                 (retry_fill_data_o                  ),
    .retry_fill_data_valid_o           (retry_fill_data_valid_o            ),
    .retry_fill_q_full_i               (retry_fill_q_full_i                ),
    .src_id                            (src_id                             ) 
);
 

rxdat_p #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED  (NOC_INITS_CRED),
    .CHI_RSP_HAS_TRACETAG(CHI_RSP_HAS_TRACETAG),
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .l2_fill_pkt_t       (l2_fill_pkt_t    ),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    ),
    .TXNID_TABLE_DAT     (TXNID_TABLE_DAT  ),
    .txnid_table_pkt_t   (txnid_table_pkt_t)
    ) rxdat_p_inst
(
    // Clock and Reset
    .clk                           (clk_i                              ),
    .rst_n                         (rst_ni                             ),
    /*--------- Interface with NoC -----------------------------------*/
    // RXDAT
    .noc_chi_rxdatflitpend         (noc_chi_rxdatflitpend              ),
    .noc_chi_rxdatflitv            (noc_chi_rxdatflitv                 ),
    .noc_chi_rxdatflit             (noc_chi_rxdatflit                  ),
    .chi_noc_rxdatlcrdv            (chi_noc_rxdatlcrdv                 ),
    // TXRSP
    .chi_noc_txrspflitpend         (chi_noc_txrspflitpend              ),
    .chi_noc_txrspflitv            (chi_noc_txrspflitv                 ),
    .chi_noc_txrspflit             (chi_noc_txrspflit                  ),
    .noc_chi_txrsplcrdv            (noc_chi_txrsplcrdv                 ),
    /*----------- interface with TxnID table --------------------------*/
    .txnid_table_rd_en_o           (tmp_txnid_table_rd_en_2_i          ),
    .txnid_table_rd_addr_o         (tmp_txnid_table_rd_addr_2_i        ),
    .txnid_table_rd_data_i         (tmp_txnid_table_rd_data_2_o        ),
    .txnid_table_rd_data_valid_i   (tmp_txnid_table_rd_data_valid_2_o  ),
    .txnid_table_wr_en_1_and_o     (rxdatp_txnid_table_wr_en_1_and_o   ),
    .txnid_table_wr_data_1_and_o   (rxdatp_txnid_table_wr_data_1_and_o ),
    /*--------- Snoop response to TXRSP channel   --------------------*/
    .snpp_rxdatp_rspflit_i         (snpp_rxdatp_rspflit_w              ),
    .snpp_rxdatp_rspflitv_i        (snpp_rxdatp_rspflitv_w             ),
    .rxdatp_snpp_stall_o           (rxdatp_snpp_stall_w                ),
    /*--------- Input CmpAck signal from RXRSP to RXDAT pipeline-------*/
    .rxrspp_rxdatp_rspflit_i       (rxrspp_rxdatp_rspflit_w            ),
    .rxrspp_rxdatp_rspflitv_i      (rxrspp_rxdatp_rspflitv_w           ),
    .rxrspp_rxdatp_cmpack_stall_o  (rxrspp_rxdatp_cmpack_stall_w       ),
    /*--------- Interface with FILL Queue Arbiter----------------------*/
    .rxdatp_fill_data_valid_o      (rxdatp_fill_data_valid_o           ),
    .rxdatp_fill_data_o            (rxdatp_fill_data_o                 ),
    .rxdatp_fill_q_full_i          (rxdatp_fill_q_full_i               ) 
);

snp_p_chi_to_l2 #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED  (NOC_INITS_CRED),
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .l2_snoop_req_pkt_t  (l2_snoop_req_pkt_t),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    ),
    .L2_SNOOP_REQ_SIZE   (L2_SNOOP_REQ_SIZE)
    ) snp_p_chi_to_l2_inst
(
     //generic
    .clk                           (clk_i                             ),
    .rst_n                         (rst_ni                            ),
    // channel signals
    .noc_rx_snpflitpend            (noc_chi_rxsnpflitpend             ),
    .noc_rx_snpflit                (noc_chi_rxsnpflit                 ),
    .noc_rx_snpflitv               (noc_chi_rxsnpflitv                ),
    .chi_noc_snplcrdv              (chi_noc_rxsnplcrdv                ),
    // To Snoop Queue From CHI
    .chi_l2_snp_q_push_o           (chi_l2_snp_q_push_o               ),
    .chi_l2_snp_q_data_o           (chi_l2_snp_q_data_o               ),
    .chi_l2_snp_q_full_i           (chi_l2_snp_q_full_i               ),
    /*----------- interface with Snoop table ------------------------*/
    .snoop_table_full_i            (tmp_snoop_table_full_o            ),
    .snoop_table_index_i           (tmp_snoop_table_index_o           ),
    .snoop_table_wr_en_1_or_o      (tmp_snoop_table_wr_en_1_or_i      ),
    .snoop_table_wr_data_1_or_o    (tmp_snoop_table_wr_data_1_or_i    ),
    .snoop_table_wr_en_2_o         (tmp_snoop_table_wr_en_2_i         ),
    .snoop_table_wr_addr_2_o       (tmp_snoop_table_wr_addr_2_i       ),  
    .snoop_table_wr_data_2_o       (tmp_snoop_table_wr_data_2_i       )   
);

fill_arb #(
    .L2_FILL_SIZE(L2_FILL_SIZE)
    ) fill_arb_inst 
(
    //generic
    .clk                           (clk_i                             ),
    .rst_n                         (rst_ni                            ),
    // Interface with FILL from RXRSP pipeline
    .rxrspp_fill_data_valid_i      (rxrspp_fill_data_valid_o          ),
    .rxrspp_fill_data_i            (rxrspp_fill_data_o                ),
    .rxrspp_fill_q_full_o          (rxrspp_fill_q_full_i              ),
    // Interface with FILL from RXDAT pipeline
    .rxdatp_fill_data_valid_i      (rxdatp_fill_data_valid_o          ),
    .rxdatp_fill_data_i            (rxdatp_fill_data_o                ),
    .rxdatp_fill_q_full_o          (rxdatp_fill_q_full_i              ),
    // Interface with FILL from RXDAT pipeline
    .retry_fill_data_valid_i       (retry_fill_data_valid_o           ),
    .retry_fill_data_i             (retry_fill_data_o                 ),
    .retry_fill_q_full_o           (retry_fill_q_full_i               ),
    // Output data to next stage 
    // To Fill Queue From CHI
    .chi_l2_fill_q_push_o          (chi_l2_fill_q_push_o              ),
    .chi_l2_fill_q_data_o          (chi_l2_fill_q_data_o              ),
    .chi_l2_fill_q_full_i          (chi_l2_fill_q_full_i              ) 
);

txnid_mem #(
    .TXNID_TABLE_DAT(TXNID_TABLE_DAT),
    .TXNID_TABLE_DAT2(TXNID_TABLE_DAT2),
    .TXNID_TABLE_DAT3(TXNID_TABLE_DAT3)
) txnid_table_inst
(
    .clk                    (clk_i                                    ),
    .rst_n                  (rst_ni                                   ),
    // read port 1
    .rd_en_1_i              (tmp_txnid_table_rd_en_1_i                ),
    .rd_addr_1_i            (tmp_txnid_table_rd_addr_1_i              ),
    .data_output_1_o        (tmp_txnid_table_rd_data_1_o              ),
    .data_output_valid_1_o  (tmp_txnid_table_rd_data_valid_1_o        ), 
    // read port 2
    .rd_en_2_i              (tmp_txnid_table_rd_en_2_i                ),
    .rd_addr_2_i            (tmp_txnid_table_rd_addr_2_i              ),
    .data_output_2_o        (tmp_txnid_table_rd_data_2_o              ),
    .data_output_valid_2_o  (tmp_txnid_table_rd_data_valid_2_o        ),
    // write port 
    .wr_en_1_or_i           (tmp_txnid_table_wr_en_1_or_i             ),
    .wr_data_1_or_i         (tmp_txnid_table_wr_data_1_or_i           ),
    .wr_en_1_and_i          (tmp_txnid_table_wr_en_1_and_i            ),
    .wr_data_1_and_i        (tmp_txnid_table_wr_data_1_and_i          ),
    .wr_en_2_i              (tmp_txnid_table_wr_en_2_i                ),
    .wr_addr_2_i            (tmp_txnid_table_wr_addr_2_i              ),
    .wr_data_2_i            (tmp_txnid_table_wr_data_2_i              ),
    .wr_en_3_i              (tmp_txnid_table_wr_en_3_i                ),
    .wr_addr_3_i            (tmp_txnid_table_wr_addr_3_i              ),
    .wr_data_3_i            (tmp_txnid_table_wr_data_3_i              ),
    .free_entry_o           (tmp_txnid_table_index_o                  ),
    .full_o                 (tmp_txnid_table_full_o                   ) 
);

assign tmp_txnid_table_wr_en_1_and_i = rxdatp_txnid_table_wr_en_1_and_o || rxrspp_txnid_table_wr_en_1_and_o || retry_txnid_table_wr_en_1_and_o ;
assign tmp_rxdatp_txnid_table_wr_data_1_and_o = rxdatp_txnid_table_wr_en_1_and_o? rxdatp_txnid_table_wr_data_1_and_o:{(2**TXNID_TABLE_ADDR){1'b1}};
assign tmp_rxrspp_txnid_table_wr_data_1_and_o = rxrspp_txnid_table_wr_en_1_and_o? rxrspp_txnid_table_wr_data_1_and_o:{(2**TXNID_TABLE_ADDR){1'b1}};
assign tmp_retry_txnid_table_wr_data_1_and_o = retry_txnid_table_wr_en_1_and_o? retry_txnid_table_wr_data_1_and_o:{(2**TXNID_TABLE_ADDR){1'b1}};
assign tmp_txnid_table_wr_data_1_and_i = tmp_rxdatp_txnid_table_wr_data_1_and_o & tmp_rxrspp_txnid_table_wr_data_1_and_o & tmp_retry_txnid_table_wr_data_1_and_o; 


// rxrspp read txnid and retry logic read txnid never happens at the same time, therefore could share read port 1
assign tmp_txnid_table_rd_en_1_i        = rxrspp_txnid_table_rd_en_1_i || retry_txnid_table_rd_en_1_i;
assign tmp_txnid_table_rd_addr_1_i      = rxrspp_txnid_table_rd_en_1_i? rxrspp_txnid_table_rd_addr_1_i : retry_txnid_table_rd_addr_1_i  ;
assign rxrspp_txnid_table_rd_data_1_o   = tmp_txnid_table_rd_data_1_o      ;
assign retry_txnid_table_rd_data_1_o    = tmp_txnid_table_rd_data_1_o      ;
assign rxrspp_txnid_table_rd_data_valid_1_o   = tmp_txnid_table_rd_data_valid_1_o && rxrspp_txnid_table_rd_en_1_i ;
assign retry_txnid_table_rd_data_valid_1_o    = tmp_txnid_table_rd_data_1_o &&  retry_txnid_table_rd_en_1_i  ;


wdat_mem #(
    .WDAT_TABLE_DAT(WDAT_TABLE_DAT)
    ) wdat_table_inst
(
    .clk                  (clk_i                               ),
    .rst_n                (rst_ni                              ),
    .rd_en_i              (tmp_wdat_table_rd_en_i              ),
    .rd_addr_i            (tmp_wdat_table_rd_addr_i            ),
    .data_output_o        (tmp_wdat_table_rd_data_o            ),
    .data_output_valid_o  (tmp_wdat_table_rd_data_valid_o      ), 
    .wr_en_1_or_i         (tmp_wdat_table_wr_en_1_or_i         ),
    .wr_en_1_and_i        (tmp_wdat_table_wr_en_1_and_i        ),
    .wr_data_1_or_i       (tmp_wdat_table_wr_data_1_or_i       ),
    .wr_data_1_and_i      (tmp_wdat_table_wr_data_1_and_i      ),
    .wr_en_2_i            (tmp_wdat_table_wr_en_2_i            ),
    .wr_addr_2_i          (tmp_wdat_table_wr_addr_2_i          ),
    .wr_data_2_i          (tmp_wdat_table_wr_data_2_i          ), 
    .free_entry_o         (tmp_wdat_table_index_o              ),
    .full_o               (tmp_wdat_table_full_o               )
);

snoop_mem snoop_table_inst
(
    .clk                  (clk_i                               ),
    .rst_n                (rst_ni                              ),
    .rd_en_i              (tmp_snoop_table_rd_en_i             ),
    .rd_addr_i            (tmp_snoop_table_rd_addr_i           ),
    .data_output_o        (tmp_snoop_table_rd_data_o           ),
    .data_output_valid_o  (tmp_snoop_table_rd_data_valid_o     ), 
    .wr_en_1_or_i         (tmp_snoop_table_wr_en_1_or_i        ),
    .wr_en_1_and_i        (tmp_snoop_table_wr_en_1_and_i       ),
    .wr_data_1_or_i       (tmp_snoop_table_wr_data_1_or_i      ),
    .wr_data_1_and_i      (tmp_snoop_table_wr_data_1_and_i     ),
    .wr_en_2_i            (tmp_snoop_table_wr_en_2_i           ),
    .wr_addr_2_i          (tmp_snoop_table_wr_addr_2_i         ),
    .wr_data_2_i          (tmp_snoop_table_wr_data_2_i         ), 
    .free_entry_o         (tmp_snoop_table_index_o             ),
    .full_o               (tmp_snoop_table_full_o              )
);

endmodule
