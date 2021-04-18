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
*   Date:           19/02/2019
*-------------------------------------------------------------------------------
*   Title:          rxrsp_p.sv CHI Requestor Agent - RXRSP to TXDAT Pipeline
*
*   Description:    This block receives NoC responses in the RXRSP chanel, and 
*                   decode, then encode, and send CHI Compliant request to the NoC
*                   on the WDAT/TXDAT chanel.
*
*                   The requests receive in the RXRSP chanel are COMPDBIDRESP, 
*                   DBIDRESP, COMP, RETRYACK, PCRDGRANT.
*                   The requests send in the TXDAT chanel are COPYBACKDATA,
*                   NCBDATA.
*         
*                   For COMP request that corresponds to CLEANUNIQUE, this pipeline
*                   also output CMPACK information to RXDAT pipeline
*
*                   This pipeline separates RETRYACK and PCRDGRANT and outputs
*                   them to the retry logic. It also accepts snoop data responses
*                   from the Snoop pipeline and send them to the WDAT chanel.
*
*                   This pipeline also sends dataless fill to the L2 FILL queue.
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module rxrsp_p
    import chi_rn_params_pkg::*;
#(
    parameter LOG_LCREDITS_NUM = 4,
    parameter NOC_INITS_CRED = 0,
    parameter CHI_DAT_HAS_CCID = 0,
    parameter CHI_DAT_HAS_DATAID = 0,
    parameter CHI_DAT_HAS_TRACETAG = 0,
    parameter CHI_DAT_HAS_DATACHECK = 0,
    parameter CHI_DAT_HAS_POISON = 0,
    parameter CHI_RSP_HAS_TRACETAG = 0,
    // parameter for flit structs and configurable field sizes
    parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
    parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t,
    parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
    parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
    parameter type l2_fill_pkt_t     = l2_fill_pkt_default_t,
    parameter REQ_FLIT_SIZE,
    parameter DAT_FLIT_SIZE,
    parameter RSP_FLIT_SIZE,
    parameter SNP_FLIT_SIZE,
    parameter HOMENID_DAT,
    parameter DATACHECK_DAT,
    parameter POISON_DAT,
    parameter TXNID_TABLE_DAT,
    parameter WDAT_TABLE_DAT,
    parameter DATA_DAT,
    parameter type txnid_table_pkt_t = txnid_table_pkt_default_t,
    parameter type wdat_table_pkt_t  = wdat_table_pkt_default_t
)(
    // Clock and Reset
    input   logic                           clk                             ,
    input   logic                           rst_n                           ,
    // Interface with NoC
    // CRSP/RXRSP
    input  logic                            noc_chi_rxrspflitpend           ,
    input  logic                            noc_chi_rxrspflitv              ,
    input  logic [RSP_FLIT_SIZE-1:0]        noc_chi_rxrspflit               ,
    output logic                            chi_noc_rxrsplcrdv              ,
    // WDAT/TXDAT
    output logic                            chi_noc_txdatflitpend           ,
    output logic                            chi_noc_txdatflitv              ,
    output logic [DAT_FLIT_SIZE-1:0]        chi_noc_txdatflit               ,
    input  logic                            noc_chi_txdatlcrdv              ,
    // Interface with txnID table 
    output logic                            txnid_table_rd_en_o             ,
    output logic [TXNID_TABLE_ADDR-1:0]     txnid_table_rd_addr_o           ,
    input  logic [TXNID_TABLE_DAT-1:0]      txnid_table_rd_data_i           ,
    input  logic                            txnid_table_rd_data_valid_i     ,
    output logic                            txnid_table_wr_en_1_and_o       ,
    output logic [2**TXNID_TABLE_ADDR-1:0]  txnid_table_wr_data_1_and_o     ,
    // Interface with wdat table 
    output logic                            wdat_table_rd_en_o              ,
    output logic [WDAT_TABLE_ADDR-1:0]      wdat_table_rd_addr_o            ,
    input  logic [WDAT_TABLE_DAT-1:0]       wdat_table_rd_data_i            ,
    input  logic                            wdat_table_rd_data_valid_i      ,
    output logic                            wdat_table_wr_en_1_and_o        ,
    output logic [2**WDAT_TABLE_ADDR-1:0]   wdat_table_wr_data_1_and_o      ,
    // Snoop data response
    input  logic                            snpp_rxrspp_datflitv_i          ,
    input  logic [DAT_FLIT_SIZE-1:0]        snpp_rxrspp_datflit_i           ,
    output logic                            rxrspp_snpp_stall_o             ,  
    // Output to retry logic 
    output logic                            retry_rspflit_valid_o           ,                           
    output logic [RSP_FLIT_SIZE-1:0]        retry_rspflit_o                 ,  
    input  logic                            retry_stall_i                   ,
    // Output CmpAck signal to RXDAT pipeline
    output logic                            rxrspp_rxdatp_rspflitv_o        ,
    output logic [RSP_FLIT_SIZE-1:0]        rxrspp_rxdatp_rspflit_o         ,
    input  logic                            rxdatp_rxrspp_cmpack_stall_i    ,  
    // Interface with FILL Queue Arbiter
    output logic                            rxrspp_fill_data_valid_o        ,
    output l2_fill_pkt_t                    rxrspp_fill_data_o              ,
    input  logic                            rxrspp_fill_q_full_i             
);

//logic definition
logic                            dec_rx_stop_w;
logic                            rx_dec_rspflit_valid_w;
logic                            rx_dec_rspflit_valid_r;
logic [RSP_FLIT_SIZE-1:0]        rx_dec_rspflit_w;
logic [RSP_FLIT_SIZE-1:0]        rx_dec_rspflit_r;

logic                            rxdatp_rxrspp_cmpack_stall_w;
logic                            arb_dec_stop_w;
logic                            dec_arb_datflitv_r;                  
logic [DAT_FLIT_SIZE-1:0]        dec_arb_datflit_r; 
logic                            dec_arb_datflitv_w;                  
logic [DAT_FLIT_SIZE-1:0]        dec_arb_datflit_w; 
logic                            tx_arb_stop_w;
logic                            arb_tx_datflitv_r;
logic [DAT_FLIT_SIZE-1:0]        arb_tx_datflit_r;
logic                            arb_tx_datflitv_w;
logic [DAT_FLIT_SIZE-1:0]        arb_tx_datflit_w;

// start coding body
// stage 0
rxrsp_p_rx #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED  (NOC_INITS_CRED),
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) rxrsp_p_rx_inst
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    .dec_rx_stop                     (dec_rx_stop_w               ),
    .retry_stall_i                   (retry_stall_i               ),
    .noc_rx_rspflitpend              (noc_chi_rxrspflitpend       ), 
    .noc_rx_rspflit                  (noc_chi_rxrspflit           ),
    .noc_rx_rspflitv                 (noc_chi_rxrspflitv          ),
    .chi_noc_rsplcrdv                (chi_noc_rxrsplcrdv          ),
    .rx_dec_rspflit                  (rx_dec_rspflit_w            ), 
    .rx_dec_rspflit_valid            (rx_dec_rspflit_valid_w      ), 
    .retry_rspflit_valid             (retry_rspflit_valid_o       )
);

assign retry_rspflit_o = rx_dec_rspflit_w ;
// flop between rx_to_dec results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_dec_rspflit_valid_r <= 1'b0;
        rx_dec_rspflit_r       <= {RSP_FLIT_SIZE{1'b0}};
    end else begin
        if (!dec_rx_stop_w) begin
             rx_dec_rspflit_valid_r <= rx_dec_rspflit_valid_w; 
             rx_dec_rspflit_r       <= rx_dec_rspflit_w;
        end
    end
end

// stage 1
rxrsp_p_dec #(
    .CHI_DAT_HAS_CCID              (CHI_DAT_HAS_CCID),
    .CHI_DAT_HAS_DATAID            (CHI_DAT_HAS_DATAID),
    .CHI_DAT_HAS_TRACETAG          (CHI_DAT_HAS_TRACETAG),
    .CHI_DAT_HAS_DATACHECK         (CHI_DAT_HAS_DATACHECK),
    .CHI_DAT_HAS_POISON            (CHI_DAT_HAS_POISON),
    .CHI_RSP_HAS_TRACETAG          (CHI_RSP_HAS_TRACETAG),
    .chi_reqflit_pkt_t             (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t             (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t             (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t             (chi_snpflit_pkt_t),
    .l2_fill_pkt_t                 (l2_fill_pkt_t    ),
    .REQ_FLIT_SIZE                 (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE                 (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE                 (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE                 (SNP_FLIT_SIZE    ),
    .HOMENID_DAT                   (HOMENID_DAT      ),
    .DATACHECK_DAT                 (DATACHECK_DAT    ),
    .POISON_DAT                    (POISON_DAT       ),
    .TXNID_TABLE_DAT               (TXNID_TABLE_DAT  ),
    .DATA_DAT                      (DATA_DAT         ),
    .txnid_table_pkt_t             (txnid_table_pkt_t),
    .wdat_table_pkt_t              (wdat_table_pkt_t )
    ) rxrsp_p_dec_inst 
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    // stall signal from the next stage
    .arb_dec_stop_i                  (arb_dec_stop_w              ),
    // stall signal from RXDAT pipeline
    .rxdatp_rxrspp_cmpack_stall_i    (rxdatp_rxrspp_cmpack_stall_i),  
    // request flit is valid
    .rx_dec_rspvalid_i               (rx_dec_rspflit_valid_r      ),
    .rx_dec_rsp_i                    (rx_dec_rspflit_r            ),
    // interface with TxnID table 
    // read port of TxnID table
    .txnid_table_rd_en_o             (txnid_table_rd_en_o         ),
    .txnid_table_rd_addr_o           (txnid_table_rd_addr_o       ),
    .txnid_table_rd_data_i           (txnid_table_rd_data_i       ),
    .txnid_table_rd_data_valid_i     (txnid_table_rd_data_valid_i ),
    // write port of TxnID table
    .txnid_table_wr_en_1_and_o       (txnid_table_wr_en_1_and_o   ),
    .txnid_table_wr_data_1_and_o     (txnid_table_wr_data_1_and_o ),
    // interface with Wdat table 
    // read port of Wdat table
    .wdat_table_rd_en_o              (wdat_table_rd_en_o          ),
    .wdat_table_rd_addr_o            (wdat_table_rd_addr_o        ),
    .wdat_table_rd_data_i            (wdat_table_rd_data_i        ),
    .wdat_table_rd_data_valid_i      (wdat_table_rd_data_valid_i  ),
    // write port of TxnID table
    .wdat_table_wr_en_1_and_o        (wdat_table_wr_en_1_and_o    ),
    .wdat_table_wr_data_1_and_o      (wdat_table_wr_data_1_and_o  ),
    // output CmpAck signal to RXDAT pipeline
    .rxrspp_rxdatp_rspflitv_o        (rxrspp_rxdatp_rspflitv_o    ),
    .rxrspp_rxdatp_rspflit_o         (rxrspp_rxdatp_rspflit_o     ),
    // output to FILL arbiter  
    .rxrspp_fill_data_o              (rxrspp_fill_data_o          ),                           
    .rxrspp_fill_data_valid_o        (rxrspp_fill_data_valid_o    ),                           
    .rxrspp_fill_q_full_i            (rxrspp_fill_q_full_i        ),
    // output data to next stage
    .dec_arb_datflitv_o              (dec_arb_datflitv_w          ),
    .dec_arb_datflit_o               (dec_arb_datflit_w           ),
    // output decode stop
    .decode_stop_o                   (dec_rx_stop_w               ) 
);

// flop between dec_to_enc results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dec_arb_datflitv_r     <= 1'b0; 
        dec_arb_datflit_r      <= {DAT_FLIT_SIZE{1'b0}};
    end else begin
        if (!arb_dec_stop_w && !rxdatp_rxrspp_cmpack_stall_i && !rxrspp_fill_q_full_i) begin
             dec_arb_datflitv_r     <= dec_arb_datflitv_w;
             dec_arb_datflit_r      <= dec_arb_datflit_w;
        end
    end
end

// stage 2
rxrsp_p_arb #(
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) rxrsp_p_arb_inst
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    .tx_arb_stop_i                   (tx_arb_stop_w               ),
    // input Snoop data response to TXDAT pipeline
    .snpp_rxrspp_datflitv_i          (snpp_rxrspp_datflitv_i      ),
    .snpp_rxrspp_datflit_i           (snpp_rxrspp_datflit_i       ),
    .rxrspp_snpp_stall_o             (rxrspp_snpp_stall_o         ),  
    // interface with previous pipeline stage
    .dec_arb_datflitv_i              (dec_arb_datflitv_r          ),
    .dec_arb_datflit_i               (dec_arb_datflit_r           ),
    // output to next stage
    .arb_tx_datflitv_o               (arb_tx_datflitv_w           ),
    .arb_tx_datflit_o                (arb_tx_datflit_w            ),
    // stop 
    .arb_dec_stop_o                  (arb_dec_stop_w              ) 
);

// flop between dec_to_enc results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arb_tx_datflitv_r      <= 1'b0; 
        arb_tx_datflit_r       <= {DAT_FLIT_SIZE{1'b0}};
    end else begin
        if (!tx_arb_stop_w) begin
            arb_tx_datflitv_r     <= arb_tx_datflitv_w;
            arb_tx_datflit_r      <= arb_tx_datflit_w;
        end
    end
end

// stage 3
rxrsp_p_tx #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED  (NOC_INITS_CRED),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) rxrsp_p_tx_inst
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    .arb_tx_datflitv                 (arb_tx_datflitv_r      ),
    .arb_tx_datflit                  (arb_tx_datflit_r            ),
    .noc_rx_datlcrdv                 (noc_chi_txdatlcrdv          ),
    .tx_datflitpend                  (chi_noc_txdatflitpend       ),
    .tx_datflitv                     (chi_noc_txdatflitv          ),
    .tx_datflit                      (chi_noc_txdatflit           ),
    .tx_arb_stop                     (tx_arb_stop_w           )
);

endmodule
