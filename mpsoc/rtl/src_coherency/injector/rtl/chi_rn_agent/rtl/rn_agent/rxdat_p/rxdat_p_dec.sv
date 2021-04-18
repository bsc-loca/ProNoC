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
*   Title:          The CHI Requestor agent RXDAT to TXRSP decode stage
*
*   Description:    This code implements the CHI Requestor agent RXDAT to TXRSP pipeline, 
*                   decode stage. This module has the following actions: first, decode the
*                   request. Depending on which request it is, it acts differently.
*
*                   Add L2_RESPERR field to the L2_FILL Queue
*                  
*                   for COMPDATA received, if it is corresponding to READNOSNP, READONCE, or
*                   ATOMICS, we don't send COMPACK to the next stage.
* 
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rxdat_p_dec 
    import chi_rn_params_pkg::*;
    #(
        parameter type l2_fill_pkt_t = l2_fill_pkt_default_t,
        parameter int FWD_READONCE_READNOSNP = 0,
        parameter CHI_RSP_HAS_TRACETAG = 0,
        // parameter for flit structs and configurable field sizes
        parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
        parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t,
        parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
        parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
        parameter REQ_FLIT_SIZE,
        parameter DAT_FLIT_SIZE,
        parameter RSP_FLIT_SIZE,
        parameter SNP_FLIT_SIZE,
        parameter TXNID_TABLE_DAT,
        parameter type txnid_table_pkt_t  = txnid_table_pkt_default_t
    )
(
    // Generic
    //input  logic                            clk                             ,
    //input  logic                            rst_n                           ,
    // Stall signal from the next stage
    input  logic                            arb_dec_stop_i                  ,
    // Input data from previous stage
    input  logic                            rx_dec_datvalid_i               ,
    input  logic [DAT_FLIT_SIZE-1:0]        rx_dec_dat_i                    ,
    // Interface with TxnID table 
    output logic                            txnid_table_rd_en_o             ,
    output logic [TXNID_TABLE_ADDR-1:0]     txnid_table_rd_addr_o           ,
    input  logic [TXNID_TABLE_DAT-1:0]      txnid_table_rd_data_i           ,
    input  logic                            txnid_table_rd_data_valid_i     ,
    output logic                            txnid_table_wr_en_1_and_o       ,
    output logic [2**TXNID_TABLE_ADDR-1:0]  txnid_table_wr_data_1_and_o     ,
    // output to FILL
    // L2_FILL = COMP_BIT+L2_ST_W+L2_TBL_ID+L2_BANK_ID+L2_RESPERR+l2_DATA
    output l2_fill_pkt_t                    rxdatp_fill_data_o              ,
    output logic                            rxdatp_fill_data_valid_o        ,                           
    input  logic                            rxdatp_fill_q_full_i            ,                           
    // output data to next stage 
    output logic [RSP_FLIT_SIZE-1:0]        rspflit_o                       ,
    output logic                            rspflitv_o                      ,
    // output decode stop
    output dec_rx_stop_o 
);

    // logic definition
    chi_datflit_pkt_t                        tmp_rx_dec_dat;
    chi_rspflit_pkt_t                        tmp_chi_rspflit_pkt;
    txnid_table_pkt_t                        tmp_txnid_table_rd_data_i;
    logic [L2_ST_W-1:0]                      tmp_resp;
    logic [TXNID_DAT-1:0]                    tmp_txnid;
 
    //
    // a. read TxnID table - for tblid+bankaddr 
    // b. pass tbl_id+bankaddr and data to FILL 
    // c. invalid TxnID table entry
    // d. if the corresponding opcode_req is READNOSNP and READONCE and ATOMICS, do not pass info to next stage; otherwise pass info to the 
    //    next stage (or always pass if config. parameter is set to 1)
    //
    // a
    assign tmp_rx_dec_dat = rx_dec_dat_i;
    assign tmp_txnid      = tmp_rx_dec_dat.txnid;

    always_comb begin
        tmp_resp = {L2_ST_W{1'b0}}; 
        case (tmp_rx_dec_dat.resp)
            RESP_COMPDATA_I:     tmp_resp = L2_ST_I;
            RESP_COMPDATA_SC:    tmp_resp = L2_ST_S;
            RESP_COMPDATA_UC:    tmp_resp = L2_ST_E;
            RESP_COMPDATA_UD_PD: tmp_resp = L2_ST_M;
        endcase
    end

    // a  read Txnid table
    assign txnid_table_rd_en_o                              = rx_dec_datvalid_i && !arb_dec_stop_i && !rxdatp_fill_q_full_i ;
    assign txnid_table_rd_addr_o                            = tmp_txnid[TXNID_TABLE_ADDR-1:0];
    // b  
    assign rxdatp_fill_data_valid_o                         = txnid_table_rd_data_valid_i; 
    // c  write to Txnid table invalid (add mask write field 1)
    assign txnid_table_wr_en_1_and_o                        = rx_dec_datvalid_i && !arb_dec_stop_i && !rxdatp_fill_q_full_i ;
    assign txnid_table_wr_data_1_and_o                      = ~({{(2**TXNID_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_txnid);  //create a add mask for the write valid data
    // d. if the corresponding opcode_req is READNOSNP and READONCE, do not pass info to next stage; otherwise pass info to the 
    //    next stage 
    assign tmp_chi_rspflit_pkt.qos                          = tmp_rx_dec_dat.qos              ;
    // the homenid from the rxdat packet should be now the tgtid of the txrsp packet
    assign tmp_chi_rspflit_pkt.tgtid                        = tmp_rx_dec_dat.homenid          ;
    // the tgtid from the rxdat packet should be now the srcid of the txrsp packet
    assign tmp_chi_rspflit_pkt.srcid                        = tmp_rx_dec_dat.tgtid            ;
    // the dbidid from the rxdat packet should be now the txnid of the txrsp packet
    assign tmp_chi_rspflit_pkt.txnid                        = tmp_rx_dec_dat.dbid             ; 
    assign tmp_chi_rspflit_pkt.opcode                       = COMPACK ;
    // For COMPACK response, resp, resperr, fwd_datapull, pcrdtype must be zero 
    assign tmp_chi_rspflit_pkt.resperr                      = {RESPERR_RSP{1'b0}}; // tmp_rx_dec_dat.resperr          ;     
    assign tmp_chi_rspflit_pkt.resp                         = {RESP_RSP{1'b0}};  //tmp_rx_dec_dat.resp             ;
    assign tmp_chi_rspflit_pkt.fwd_datapull                 = {FWD_DATAPULL_RSP{1'b0}}; //tmp_rx_dec_dat.fwd_datapull     ;
    // the dbidid in the txdata packet is not valid
    assign tmp_chi_rspflit_pkt.dbid                         = tmp_rx_dec_dat.dbid             ;
    generate
        if (CHI_RSP_HAS_TRACETAG) assign tmp_chi_rspflit_pkt.tracetag = tmp_rx_dec_dat.tracetag;
    endgenerate
    assign tmp_chi_rspflit_pkt.pcrdtype                     = {PCRDTYPE_RSP{1'b0}}; 
    assign rspflit_o                                        = tmp_chi_rspflit_pkt     ;


    assign tmp_txnid_table_rd_data_i = txnid_table_rd_data_i;
    // comp bit in l2_fill is set to zero for data packet
    assign rxdatp_fill_data_o        = {1'b0, tmp_resp, tmp_txnid_table_rd_data_i.mem2.tbl_id, tmp_txnid_table_rd_data_i.mem2.bank_addr, tmp_rx_dec_dat.resperr, tmp_rx_dec_dat.data};
    assign rspflitv_o                = txnid_table_rd_data_valid_i && (tmp_txnid_table_rd_data_i.mem2.opcode_req != READNOSNP || tmp_txnid_table_rd_data_i.mem2.opcode_req != READONCE || ~(tmp_txnid_table_rd_data_i.mem2.opcode_req >= ATOMICS_START && tmp_txnid_table_rd_data_i.mem2.opcode_req <= ATOMICS_END));


    assign dec_rx_stop_o = arb_dec_stop_i || rxdatp_fill_q_full_i ;

endmodule 
