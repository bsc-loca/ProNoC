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
*   Title:          rxdat_p.sv CHI Requestor Agent - RXDAT to TXRSP Pipeline
*
*   Description:    This block receives NoC responses in the RXDAT channel, and 
*                   decode, then encode, and send CHI Compliant request to the NoC
*                   on the TXRSP Channel.
*
*                   The requests receive in the RXDAT channel are COMPDATA_I,
*                   COMPDATA_UC, COMPDATA_SC, COMPDATA_UD_PD
*
*                   The requests send in the TXRSP channel is COMPACK
*
*                   This block also sends data fill to the L2 Cache
*
*                   This block also receives COMPACK infos from the TXRSP pipeline 
*                   and organize them into the local pipeline, in addition, it receives
*                   snoop dataless responses from the Snoop pipeline.
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module rxdat_p
    import chi_rn_params_pkg::*;
    #(
        parameter LOG_LCREDITS_NUM = 4,
        parameter NOC_INITS_CRED = 0,
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
        parameter TXNID_TABLE_DAT,
        parameter type txnid_table_pkt_t = txnid_table_pkt_default_t
    )
(
    // Clock and Reset
    input   logic                           clk                             ,
    input   logic                           rst_n                           ,
    // Interface with NoC
    // RXDAT
    input  logic                            noc_chi_rxdatflitpend           ,
    input  logic                            noc_chi_rxdatflitv              ,
    input  logic [DAT_FLIT_SIZE-1:0]        noc_chi_rxdatflit               ,
    output logic                            chi_noc_rxdatlcrdv              ,
    // TXRSP
    output logic                            chi_noc_txrspflitpend           ,
    output logic                            chi_noc_txrspflitv              ,
    output logic [RSP_FLIT_SIZE-1:0]        chi_noc_txrspflit               ,
    input  logic                            noc_chi_txrsplcrdv              ,
    // Interface with TxnID table 
    output logic                            txnid_table_rd_en_o             ,
    output logic [TXNID_TABLE_ADDR-1:0]     txnid_table_rd_addr_o           ,
    input  logic [TXNID_TABLE_DAT-1:0]      txnid_table_rd_data_i           ,
    input  logic                            txnid_table_rd_data_valid_i     ,
    output logic                            txnid_table_wr_en_1_and_o       ,
    output logic [2**TXNID_TABLE_ADDR-1:0]  txnid_table_wr_data_1_and_o     ,
    // Input CmpAck signal from RXRSP to RXDAT pipeline
    input  logic [RSP_FLIT_SIZE-1:0]        rxrspp_rxdatp_rspflit_i         ,        
    input  logic                            rxrspp_rxdatp_rspflitv_i        ,  
    output logic                            rxrspp_rxdatp_cmpack_stall_o    ,  
    // Snoop dataless response 
    input  logic [RSP_FLIT_SIZE-1:0]        snpp_rxdatp_rspflit_i           ,        
    input  logic                            snpp_rxdatp_rspflitv_i          ,
    output logic                            rxdatp_snpp_stall_o             ,
    // Interface with FILL Queue Arbiter
    output logic                            rxdatp_fill_data_valid_o        ,
    output l2_fill_pkt_t                    rxdatp_fill_data_o              ,
    input  logic                            rxdatp_fill_q_full_i             
);

//logic definition
logic                            dec_rx_stop_w;
logic                            rx_dec_datflit_valid_w;
logic                            rx_dec_datflit_valid_r;
logic [DAT_FLIT_SIZE-1:0]        rx_dec_datflit_w;
logic [DAT_FLIT_SIZE-1:0]        rx_dec_datflit_r;

logic                            arb_dec_stop_w;
logic [RSP_FLIT_SIZE-1:0]        dec_arb_rspflit_r;
logic                            dec_arb_rspflitv_r;
logic [RSP_FLIT_SIZE-1:0]        dec_arb_rspflit_w;
logic                            dec_arb_rspflitv_w;


logic [RSP_FLIT_SIZE-1:0]        rxrspp_rxdatp_rspflit_r;
logic                            rxrspp_rxdatp_rspflitv_r;
logic                            rxdatp_rxrspp_cmpack_stall_w;

logic [RSP_FLIT_SIZE-1:0]        snpp_rxdatp_rspflit_r;
logic                            snpp_rxdatp_rspflitv_r;
logic                            rxdatp_snpp_stall_w;

logic                            tx_arb_stop_w;
logic                            arb_tx_rspflit_valid_w;
logic [RSP_FLIT_SIZE-1:0]        arb_tx_rspflit_w;
logic                            arb_tx_rspflit_valid_r;
logic [RSP_FLIT_SIZE-1:0]        arb_tx_rspflit_r;


// Start coding body
// stage 0
rxdat_p_rx #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED(NOC_INITS_CRED),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) rxdat_p_rx_inst
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    .dec_rx_stop                     (dec_rx_stop_w               ),
    .noc_rx_datflitpend              (noc_chi_rxdatflitpend       ), 
    .noc_rx_datflit                  (noc_chi_rxdatflit           ),
    .noc_rx_datflitv                 (noc_chi_rxdatflitv          ),
    .chi_noc_datlcrdv                (chi_noc_rxdatlcrdv          ),
    .rx_dec_datflit                  (rx_dec_datflit_w            ),  
    .rx_dec_datflit_valid            (rx_dec_datflit_valid_w      )  
);

// flop between rx_to_dec results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_dec_datflit_valid_r <= 1'b0;
        rx_dec_datflit_r <= {DAT_FLIT_SIZE{1'b0}};
    end else begin
        if (!dec_rx_stop_w) begin
             rx_dec_datflit_valid_r <= rx_dec_datflit_valid_w;
             rx_dec_datflit_r <= rx_dec_datflit_w;
        end
    end
end

// stage 1
rxdat_p_dec #(
    .CHI_RSP_HAS_TRACETAG  (CHI_RSP_HAS_TRACETAG),
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
    ) rxdat_p_dec_inst 
(
    //.clk                             (clk                         ),
    //.rst_n                           (rst_n                       ),
    // stall signal from the next stage
    .arb_dec_stop_i                  (arb_dec_stop_w              ),
    // request flit from previous stage
    .rx_dec_datvalid_i               (rx_dec_datflit_valid_r      ),
    .rx_dec_dat_i                    (rx_dec_datflit_r            ),
    // interface with TxnID table
    .txnid_table_rd_en_o             (txnid_table_rd_en_o         ),
    .txnid_table_rd_addr_o           (txnid_table_rd_addr_o       ),
    .txnid_table_rd_data_i           (txnid_table_rd_data_i       ),
    .txnid_table_rd_data_valid_i     (txnid_table_rd_data_valid_i ),
    .txnid_table_wr_en_1_and_o       (txnid_table_wr_en_1_and_o   ),
    .txnid_table_wr_data_1_and_o     (txnid_table_wr_data_1_and_o ),
    // output to FILL
    .rxdatp_fill_data_o              (rxdatp_fill_data_o          ),                           
    .rxdatp_fill_data_valid_o        (rxdatp_fill_data_valid_o    ),                           
    .rxdatp_fill_q_full_i            (rxdatp_fill_q_full_i        ),
    // output data to next stage
    .rspflit_o                       (dec_arb_rspflit_w           ),
    .rspflitv_o                      (dec_arb_rspflitv_w          ),
    // output decode stop
    .dec_rx_stop_o                   (dec_rx_stop_w) 
);

// flop between dec_to_arb results
// from previous stage
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dec_arb_rspflit_r              <= {RSP_FLIT_SIZE{1'b0}};
        dec_arb_rspflitv_r             <= 1'b0;
    end else begin
        if (!arb_dec_stop_w) begin
             dec_arb_rspflit_r         <= dec_arb_rspflit_w;
             dec_arb_rspflitv_r        <= dec_arb_rspflitv_w;
        end
    end
end

// flop between alien dec_to_arb results
// input from RXRSP pipeline
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rxrspp_rxdatp_rspflit_r         <= {RSP_FLIT_SIZE{1'b0}};
        rxrspp_rxdatp_rspflitv_r        <= 1'b0;
    end else begin
        if (!rxdatp_rxrspp_cmpack_stall_w) begin
            rxrspp_rxdatp_rspflit_r     <= rxrspp_rxdatp_rspflit_i;
            rxrspp_rxdatp_rspflitv_r    <= rxrspp_rxdatp_rspflitv_i;
        end
    end
end
assign rxrspp_rxdatp_cmpack_stall_o =  rxdatp_rxrspp_cmpack_stall_w;

// flop between alien2 to_arb results
// snoop dataless response from Snoop pipeline
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        snpp_rxdatp_rspflit_r           <= {RSP_FLIT_SIZE{1'b0}};        
        snpp_rxdatp_rspflitv_r          <= 1'b0;
    end else begin
        if (!rxdatp_snpp_stall_w) begin
             snpp_rxdatp_rspflit_r      <= snpp_rxdatp_rspflit_i;        
             snpp_rxdatp_rspflitv_r     <= snpp_rxdatp_rspflitv_i;
        end
    end
end
assign rxdatp_snpp_stall_o = rxdatp_snpp_stall_w;

// stage 2
rxdat_p_arb #(
    .chi_reqflit_pkt_t   (chi_reqflit_pkt_t),
    .chi_rspflit_pkt_t   (chi_rspflit_pkt_t),
    .chi_datflit_pkt_t   (chi_datflit_pkt_t),
    .chi_snpflit_pkt_t   (chi_snpflit_pkt_t),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) rxdat_p_arb_inst 
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    .tx_arb_stop_i                   (tx_arb_stop_w               ),
    .rxrspp_rxdatp_rspflit_i         (rxrspp_rxdatp_rspflit_r     ),        
    .rxrspp_rxdatp_rspflitv_i        (rxrspp_rxdatp_rspflitv_r    ),
    .rxdatp_rxrspp_cmpack_stall_o    (rxdatp_rxrspp_cmpack_stall_w),  
    .snpp_rxdatp_rspflit_i           (snpp_rxdatp_rspflit_r       ),        
    .snpp_rxdatp_rspflitv_i          (snpp_rxdatp_rspflitv_r      ),
    .rxdatp_snpp_stall_o             (rxdatp_snpp_stall_w         ),
    .rspflit_i                       (dec_arb_rspflit_r           ),
    .rspflitv_i                      (dec_arb_rspflitv_r          ),
    .rspflit_valid_o                 (arb_tx_rspflit_valid_w      ),
    .rspflit_o                       (arb_tx_rspflit_w            ),
    .arb_dec_stop_o                  (arb_dec_stop_w              )
);

// flop between arb_to_tx results
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arb_tx_rspflit_valid_r <= 1'b0;
        arb_tx_rspflit_r       <= {RSP_FLIT_SIZE{1'b0}};
    end else begin
        if (!tx_arb_stop_w) begin
             arb_tx_rspflit_valid_r <= arb_tx_rspflit_valid_w     ;
             arb_tx_rspflit_r       <= arb_tx_rspflit_w           ;
        end
    end
end

// stage 3 - last stage
rxdat_p_tx #(
    .LOG_LCREDITS_NUM(LOG_LCREDITS_NUM),
    .NOC_INITS_CRED(NOC_INITS_CRED),
    .REQ_FLIT_SIZE       (REQ_FLIT_SIZE    ),
    .DAT_FLIT_SIZE       (DAT_FLIT_SIZE    ),
    .RSP_FLIT_SIZE       (RSP_FLIT_SIZE    ),
    .SNP_FLIT_SIZE       (SNP_FLIT_SIZE    )
    ) rxdat_p_tx_inst
(
    .clk                             (clk                         ),
    .rst_n                           (rst_n                       ),
    .arb_tx_rspflit                  (arb_tx_rspflit_r            ),
    .arb_tx_rspflit_valid            (arb_tx_rspflit_valid_r      ),
    .noc_rx_rsplcrdv                 (noc_chi_txrsplcrdv          ),
    .tx_rspflitpend                  (chi_noc_txrspflitpend       ),
    .tx_rspflitv                     (chi_noc_txrspflitv          ),
    .tx_rspflit                      (chi_noc_txrspflit           ),
    .tx_arb_stop                     (tx_arb_stop_w               )
);


endmodule
