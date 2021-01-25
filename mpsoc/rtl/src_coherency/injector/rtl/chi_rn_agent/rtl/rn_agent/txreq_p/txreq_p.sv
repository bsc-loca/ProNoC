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
*   Date:           11/01/2019
*-------------------------------------------------------------------------------
*   Title:          txreq.sv  - top file of TXREQ Pipeline
*
*   Description:    This block arbitrates from the two input L2 Req and Evict queue
*                   and output to CHI TXREQ channel to the NoC.
*                   It also filters out snoop requests from the L2 Req and sends 
*                   them to the Snoop pipeline, and accepts retry requests from 
*                   the Retry Logic. 
*
*                   Add size information for Atomic operations. It is required in the 
*                   reqflit, therefore from the evict queue to TXREQ channel, from the 
*                   retry logic, and this size information should also be saved in the 
*                   txnid table.
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module txreq_p 
     import chi_rn_params_pkg::*;
#(
    parameter LOG_LCREDITS_NUM = 4,
    parameter NOC_INITS_CRED = 0,
    parameter ARB_WITH_QUEUE = 0,
    parameter CHI_REQ_HAS_ENDIAN = 0,
    parameter CHI_REQ_HAS_NS = 0,
    parameter CHI_REQ_HAS_LIKELYSHARED = 0,
    parameter CHI_REQ_HAS_TRACETAG = 0,
    parameter CHI_EVICT_HAS_RSP_CH = 0,
    // parameter for flit structs and configurable field sizes
    parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
    parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t,
    parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
    parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
    parameter type l2_evict_pkt_t    = l2_evict_pkt_default_t,
    parameter type l2_data_pkt_t     = l2_data_pkt_default_t,
    parameter type l2_req_pkt_t      = l2_req_pkt_default_t,
    parameter REQ_FLIT_SIZE,
    parameter DAT_FLIT_SIZE,
    parameter RSP_FLIT_SIZE,
    parameter SNP_FLIT_SIZE,
    parameter L2_REQ_SIZE,
    parameter L2_EVICT_SIZE,
    parameter L2_DATA_SIZE,
    parameter SRCID_REQ,
    parameter TGTID_REQ,
    parameter ADDR_REQ,
    parameter QOS_REQ,
    parameter RETURNNID_REQ,
    parameter LPID_REQ,
    parameter TXNID_TABLE_DAT2,
    parameter WDAT_TABLE_DAT,
    parameter type txnid_table_pkt2_t = txnid_table_pkt2_default_t,
    parameter SAM_TGT_ADDR_W
)(
     // Clock and Reset
     input  logic                            clk                         ,
     input  logic                            rst_n                       ,
     // Interface with L2 
     // NoC Response Queue
     output logic                            l2_chi_q_pop_o              ,
     input  logic                            l2_chi_q_empty_i            ,
     input  logic [L2_REQ_SIZE-1:0]          l2_chi_q_data_i             ,
     // Evict Queue
     output logic                            l2_chi_evt_q_pop_o          ,
     input  logic                            l2_chi_evt_q_highoccupancy_i,
     input  logic                            l2_chi_evt_q_empty_i        ,
     input  logic [L2_EVICT_SIZE-1:0]        l2_chi_evt_q_data_i         ,
     // Arbitration queue
     output  logic                           l2_chi_arb_q_pop_o           ,
     input   logic                           l2_chi_arb_q_empty_i         ,
     input   logic [ARB_QUEUE_W-1:0]         l2_chi_arb_q_data_i          ,
     // Interface with NoC
     // TXREQ
     output logic                            chi_noc_txreqflitpend       ,
     output logic                            chi_noc_txreqflitv          ,
     output logic [REQ_FLIT_SIZE-1:0]        chi_noc_txreqflit           ,
     input  logic                            noc_chi_txreqlcrdv          ,
     // Interface with Snoop pipeline
     output logic                            l2_snp_data_valid_o         ,
     output logic [L2_REQ_SIZE-1:0]          l2_snp_req_o                ,
     output l2_data_pkt_t                    l2_snp_data_o               ,
     input  logic                            l2_snp_data_stall_i         ,
     // Interface with TXREQ pipeline to resend the Request with credit
     input  logic [TGTID_REQ-1:0]            retry_tgtid_i               ,
     input  logic [SRCID_REQ-1:0]            retry_srcid_i               ,
     input  logic [TXNID_REQ-1:0]            retry_txnid_i               ,
     input  logic [OPCODE_REQ-1:0]           retry_opcode_i              ,
     input  logic [ADDR_REQ-1:0]             retry_addr_i                ,
     input  logic [1:0]                      retry_amo_size_i            ,
     input  logic [PCRDTYPE_REQ-1:0]         retry_pcrdtype_i            ,
     input  logic                            retry_excl_snoopme_i        ,
     input  logic                            retry_req_metadata_valid_i  ,
     output logic                            retry_stall_o               ,
     // Interface with txnID table
     input  logic                            txnid_table_full_i          ,
     input  logic [TXNID_TABLE_ADDR-1:0]     txnid_table_index_i         ,
     output logic                            txnid_table_wr_en_1_or_o    ,
     output logic                            txnid_table_wr_en_2_o       ,
     output logic [TXNID_TABLE_ADDR-1:0]     txnid_table_wr_addr_2_o     , 
     output logic [2**TXNID_TABLE_ADDR-1:0]  txnid_table_wr_data_1_or_o  ,
     output logic [TXNID_TABLE_DAT2-1:0]     txnid_table_wr_data_2_o     ,
     // Interface with wdat table
     input  logic                            wdat_table_full_i           ,
     input  logic [WDAT_TABLE_ADDR-1:0]      wdat_table_index_i          ,
     output logic                            wdat_table_wr_en_1_or_o     ,
     output logic [2**WDAT_TABLE_ADDR-1:0]   wdat_table_wr_data_1_or_o   ,
     output logic                            wdat_table_wr_en_2_o        ,
     output logic [WDAT_TABLE_ADDR-1:0]      wdat_table_wr_addr_2_o      , 
     output logic [WDAT_TABLE_DAT-1:0]       wdat_table_wr_data_2_o      ,
     // SAM Interface
     output logic [SAM_TGT_ADDR_W-1:0]       sam_target_address_o        ,
     input  logic [TGTID_REQ-1:0]            sam_target_id_i             ,
     input logic  [SRCID_REQ-1:0]            src_id
     //input  logic [SRCID_REQ-1:0]            source_id_i
);

// logic definition 
logic                     alloc_arb_stop_w;
logic                     arb_alloc_req_valid_w;
logic [L2_REQ_SIZE-1:0]   arb_alloc_req_dat_w;
logic                     arb_alloc_req_valid_r;
logic [L2_REQ_SIZE-1:0]   arb_alloc_req_dat_r;
l2_data_pkt_t             arb_alloc_evict_data_w;
l2_data_pkt_t             arb_alloc_evict_data_r;
logic [1:0]               arb_alloc_evict_amo_size_w;
logic [1:0]               arb_alloc_evict_amo_size_r;

logic [TGTID_REQ-1:0]     alloc_enc_tgtid_w;
logic [SRCID_REQ-1:0]     alloc_enc_srcid_w;
logic [TXNID_REQ-1:0]     alloc_enc_txnid_w;
logic [OPCODE_REQ-1:0]    alloc_enc_opcode_w;
logic [ADDR_REQ-1:0]      alloc_enc_addr_w;
logic [1:0]               alloc_enc_amo_size_w;
logic                     alloc_enc_excl_snoopme_w;
logic                     alloc_enc_req_metadata_valid_w;

logic [TGTID_REQ-1:0]     alloc_enc_tgtid_r; 
logic [SRCID_REQ-1:0]     alloc_enc_srcid_r; 
logic [TXNID_REQ-1:0]     alloc_enc_txnid_r; 
logic [OPCODE_REQ-1:0]    alloc_enc_opcode_r; 
logic [ADDR_REQ-1:0]      alloc_enc_addr_r; 
logic [1:0]               alloc_enc_amo_size_r;
logic                     alloc_enc_excl_snoopme_r; 
logic                     alloc_enc_req_metadata_valid_r;
logic                     enc_alloc_stop_w;

logic [TGTID_REQ-1:0]     retry_tgtid_r; 
logic [SRCID_REQ-1:0]     retry_srcid_r; 
logic [TXNID_REQ-1:0]     retry_txnid_r; 
logic [OPCODE_REQ-1:0]    retry_opcode_r; 
logic [ADDR_REQ-1:0]      retry_addr_r; 
logic [1:0] retry_amo_size_r;
logic [PCRDTYPE_REQ-1:0]  retry_pcrdtype_r; 
logic                     retry_excl_snoopme_r; 
logic                     retry_req_metadata_valid_r;

logic                     enc_tx_reqflitv_w; 
logic [REQ_FLIT_SIZE-1:0] enc_tx_reqflit_w; 
logic                     enc_tx_reqflitv_r; 
logic [REQ_FLIT_SIZE-1:0] enc_tx_reqflit_r; 
logic                     tx_enc_stop_w; 


// start coding body
// stage 0
txreq_p_arb #(
    .l2_evict_pkt_t       (l2_evict_pkt_t),
    .l2_data_pkt_t        (l2_data_pkt_t),
    .l2_req_pkt_t         (l2_req_pkt_t),
    .ARB_WITH_QUEUE       (ARB_WITH_QUEUE),
    .L2_REQ_SIZE          (L2_REQ_SIZE),
    .SAM_TGT_ADDR_W       (SAM_TGT_ADDR_W),
    .CHI_EVICT_HAS_RSP_CH (CHI_EVICT_HAS_RSP_CH)
) txreq_p_arb_inst (
     .clk                          (clk                           ),
     .rst_n                        (rst_n                         ),
     .alloc_stop                   (alloc_arb_stop_w              ),
     // Interface with L2
     .l2_chi_q_pop_o               (l2_chi_q_pop_o                ),
     .l2_chi_q_empty_i             (l2_chi_q_empty_i              ),
     .l2_chi_q_data_i              (l2_chi_q_data_i               ),
     .l2_chi_evt_q_pop_o           (l2_chi_evt_q_pop_o            ),
     .l2_chi_evt_q_data_i          (l2_chi_evt_q_data_i           ),
     .l2_chi_evt_q_highoccupancy_i (l2_chi_evt_q_highoccupancy_i  ),
     .l2_chi_evt_q_empty_i         (l2_chi_evt_q_empty_i          ),
     .l2_chi_arb_q_pop_o           (l2_chi_arb_q_pop_o            ),
     .l2_chi_arb_q_empty_i         (l2_chi_arb_q_empty_i          ),
     .l2_chi_arb_q_data_i          (l2_chi_arb_q_data_i           ),
     .arb_alloc_req_valid_o        (arb_alloc_req_valid_w         ),    
     .arb_alloc_req_data_o         (arb_alloc_req_dat_w           ),
     .arb_alloc_evict_data_o       (arb_alloc_evict_data_w        ),
     .arb_alloc_evict_amo_size_o   (arb_alloc_evict_amo_size_w    ),
     // Interface with Snoop logic 
     .l2_snp_data_valid_o          (l2_snp_data_valid_o           ),
     .l2_snp_data_stall_i          (l2_snp_data_stall_i           ),
     .sam_target_address_o         (sam_target_address_o          ) 
);    
     

assign l2_snp_req_o = arb_alloc_req_dat_w; 
assign l2_snp_data_o = arb_alloc_evict_data_w;

// flop between arb_to_alloc results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arb_alloc_req_valid_r <= 1'b0;
        arb_alloc_req_dat_r <= {L2_REQ_SIZE{1'b0}};
        arb_alloc_evict_data_r <= {L2_DATA_SIZE{1'b0}};
        arb_alloc_evict_amo_size_r <= 2'b00;
    end else begin
        if (!alloc_arb_stop_w) begin
            arb_alloc_req_valid_r <= arb_alloc_req_valid_w;
            arb_alloc_req_dat_r <= arb_alloc_req_dat_w;
            arb_alloc_evict_data_r <= arb_alloc_evict_data_w;
            arb_alloc_evict_amo_size_r <= arb_alloc_evict_amo_size_w;
        end
    end
end

// stage 1
txreq_p_alloc #(
    .l2_req_pkt_t(l2_req_pkt_t),
    .l2_data_pkt_t(l2_data_pkt_t),
    .L2_REQ_SIZE(L2_REQ_SIZE),
    .SRCID_REQ(SRCID_REQ),
    .TGTID_REQ(TGTID_REQ),
    .ADDR_REQ(ADDR_REQ),
    .TXNID_TABLE_DAT2(TXNID_TABLE_DAT2),
    .WDAT_TABLE_DAT(WDAT_TABLE_DAT),
    .txnid_table_pkt2_t(txnid_table_pkt2_t)
    ) txreq_p_alloc_inst
(
     .enc_stop_i                   (enc_alloc_stop_w              ),
     // interface with previous stage arb
     .arb_alloc_req_valid_i        (arb_alloc_req_valid_r         ),
     .arb_alloc_req_dat_i          (arb_alloc_req_dat_r           ),
     .arb_alloc_evict_data_i       (arb_alloc_evict_data_r        ),
     .arb_alloc_evict_amo_size_i   (arb_alloc_evict_amo_size_r    ),
     // interface with TxnID table
     .txnid_table_full_i           (txnid_table_full_i            ),
     .txnid_table_index_i          (txnid_table_index_i           ),
     .txnid_table_wr_en_1_or_o     (txnid_table_wr_en_1_or_o      ),
     .txnid_table_wr_en_2_o        (txnid_table_wr_en_2_o         ),
     .txnid_table_wr_addr_2_o      (txnid_table_wr_addr_2_o       ), 
     .txnid_table_wr_data_1_or_o   (txnid_table_wr_data_1_or_o    ),
     .txnid_table_wr_data_2_o      (txnid_table_wr_data_2_o       ),
     // interface with Wdat table
     .wdat_table_full_i            (wdat_table_full_i             ),
     .wdat_table_index_i           (wdat_table_index_i            ),
     .wdat_table_wr_en_1_or_o      (wdat_table_wr_en_1_or_o       ),
     .wdat_table_wr_data_1_or_o    (wdat_table_wr_data_1_or_o     ),
     .wdat_table_wr_en_2_o         (wdat_table_wr_en_2_o          ),
     .wdat_table_wr_addr_2_o       (wdat_table_wr_addr_2_o        ), 
     .wdat_table_wr_data_2_o       (wdat_table_wr_data_2_o        ),
     // interface to the next stage
     .tgtid_o                      (alloc_enc_tgtid_w             ),
     .srcid_o                      (alloc_enc_srcid_w             ),
     .txnid_o                      (alloc_enc_txnid_w             ),
     .opcode_o                     (alloc_enc_opcode_w            ),
     .addr_o                       (alloc_enc_addr_w              ),
     .amo_size_o                   (alloc_enc_amo_size_w          ),
     .excl_snoopme_o               (alloc_enc_excl_snoopme_w      ),
     .req_metadata_valid_o         (alloc_enc_req_metadata_valid_w),
     // stop
     .alloc_stop_o                 (alloc_arb_stop_w              ),
     // SAM
     .sam_target_id_i              (sam_target_id_i               ),
     .src_id                       (src_id                        )
     //.source_id_i                  (source_id_i                   )
); 

// flop between alloc_to_enc results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        alloc_enc_tgtid_r              <= {TGTID_REQ{1'b0}}; 
        alloc_enc_srcid_r              <= {SRCID_REQ{1'b0}}; 
        alloc_enc_txnid_r              <= {TXNID_REQ{1'b0}}; 
        alloc_enc_opcode_r             <= {OPCODE_REQ{1'b0}};
        alloc_enc_addr_r               <= {ADDR_REQ{1'b0}};
        alloc_enc_amo_size_r           <= 2'b00;   
        alloc_enc_excl_snoopme_r       <= 1'b0;
        alloc_enc_req_metadata_valid_r <= 1'b0; 
    end else begin
        if (!enc_alloc_stop_w) begin
             alloc_enc_tgtid_r              <= alloc_enc_tgtid_w;    
             alloc_enc_srcid_r              <= alloc_enc_srcid_w;   
             alloc_enc_txnid_r              <= alloc_enc_txnid_w;   
             alloc_enc_opcode_r             <= alloc_enc_opcode_w;   
             alloc_enc_addr_r               <= alloc_enc_addr_w;   
             alloc_enc_amo_size_r           <= alloc_enc_amo_size_w;   
             alloc_enc_excl_snoopme_r       <= alloc_enc_excl_snoopme_w;   
             alloc_enc_req_metadata_valid_r <= alloc_enc_req_metadata_valid_w;
        end
    end
end

// flop between retry_to_enc results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        retry_tgtid_r              <= {TGTID_REQ{1'b0}}; 
        retry_srcid_r              <= {SRCID_REQ{1'b0}}; 
        retry_txnid_r              <= {TXNID_REQ{1'b0}}; 
        retry_opcode_r             <= {OPCODE_REQ{1'b0}};
        retry_addr_r               <= {ADDR_REQ{1'b0}};
        retry_amo_size_r           <= 2'b00;
        retry_pcrdtype_r           <= {PCRDTYPE_REQ{1'b0}};
        retry_excl_snoopme_r       <= 1'b0;
        retry_req_metadata_valid_r <= 1'b0; 
    end else begin
        if (!enc_alloc_stop_w) begin
             retry_tgtid_r              <= retry_tgtid_i;    
             retry_srcid_r              <= retry_srcid_i;   
             retry_txnid_r              <= retry_txnid_i;   
             retry_opcode_r             <= retry_opcode_i;   
             retry_addr_r               <= retry_addr_i;   
             retry_amo_size_r           <= retry_amo_size_i;   
             retry_pcrdtype_r           <= retry_pcrdtype_i;   
             retry_excl_snoopme_r       <= retry_excl_snoopme_i;   
             retry_req_metadata_valid_r <= retry_req_metadata_valid_i;
        end
    end
end

// stage 2
txreq_p_enc #(
    .CHI_REQ_HAS_ENDIAN      (CHI_REQ_HAS_ENDIAN),
    .CHI_REQ_HAS_NS          (CHI_REQ_HAS_NS),
    .CHI_REQ_HAS_LIKELYSHARED(CHI_REQ_HAS_LIKELYSHARED),
    .CHI_REQ_HAS_TRACETAG    (CHI_REQ_HAS_TRACETAG),
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    ),
    .SRCID_REQ           (SRCID_REQ        ),
    .TGTID_REQ           (TGTID_REQ        ),
    .ADDR_REQ            (ADDR_REQ         ),
    .QOS_REQ             (QOS_REQ          ),
    .RETURNNID_REQ       (RETURNNID_REQ    ),
    .LPID_REQ            (LPID_REQ         )
    ) txreq_p_enc_inst 
(
    .clk                          (clk                           ),  
    .rst_n                        (rst_n                         ),
    .tx_enc_stop_i                (tx_enc_stop_w                 ),
    // from retry logic, this has higher priority over the local queue
    .retry_tgtid_i                (retry_tgtid_r                 ), 
    .retry_srcid_i                (retry_srcid_r                 ), 
    .retry_txnid_i                (retry_txnid_r                 ), 
    .retry_opcode_i               (retry_opcode_r                ), 
    .retry_addr_i                 (retry_addr_r                  ), 
    .retry_amo_size_i             (retry_amo_size_r              ), 
    .retry_pcrdtype_i             (retry_pcrdtype_r              ), 
    .retry_excl_snoopme_i         (retry_excl_snoopme_r          ), 
    .retry_req_metadata_valid_i   (retry_req_metadata_valid_r    ),
    .retry_stall_o                (retry_stall_o                 ), 
    // from previous stage - decode 
    .tgtid_i                      (alloc_enc_tgtid_r             ), 
    .srcid_i                      (alloc_enc_srcid_r             ), 
    .txnid_i                      (alloc_enc_txnid_r             ), 
    .opcode_i                     (alloc_enc_opcode_r            ), 
    .addr_i                       (alloc_enc_addr_r              ), 
    .amo_size_i                   (alloc_enc_amo_size_r          ), 
    .excl_snoopme_i               (alloc_enc_excl_snoopme_r      ), 
    .req_metadata_valid_i         (alloc_enc_req_metadata_valid_r), 
    // output to the next stage
    .enc_tx_reqflitv_o            (enc_tx_reqflitv_w             ),
    .enc_tx_reqflit_o             (enc_tx_reqflit_w              ),
    // output stop signal
    .enc_alloc_stop_o             (enc_alloc_stop_w) 
);

// flop between enc to tx
always_ff @(posedge clk) begin
    if (!rst_n) begin
        enc_tx_reqflitv_r <= 1'b0;
        enc_tx_reqflit_r  <= {REQ_FLIT_SIZE{1'b0}};
    end else if (!tx_enc_stop_w) begin
        enc_tx_reqflitv_r <=  enc_tx_reqflitv_w;
        enc_tx_reqflit_r  <=  enc_tx_reqflit_w ;
    end
end

// stage 3 - last stage
txreq_p_tx #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED  (NOC_INITS_CRED),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) txreq_p_tx_inst
(
    .clk                    (clk),  
    .rst_n                  (rst_n),
    .enc_tx_reqflitv_i      (enc_tx_reqflitv_r            ),
    .enc_tx_reqflit_i       (enc_tx_reqflit_r             ),
    .noc_rx_reqlcrd         (noc_chi_txreqlcrdv           ),
    .tx_reqflitpend         (chi_noc_txreqflitpend        ),
    .tx_reqflitv            (chi_noc_txreqflitv           ),
    .tx_reqflit             (chi_noc_txreqflit            ),
    .tx_enc_stop_o          (tx_enc_stop_w                ) 
);
        
endmodule
