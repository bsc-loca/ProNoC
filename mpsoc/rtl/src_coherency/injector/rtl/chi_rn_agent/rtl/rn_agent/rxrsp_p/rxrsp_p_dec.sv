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
*   Title:          The CHI Requestor agent RXRSP to TXDAT decode stage
*
*   Description:    This code implements the CHI Requestor agent RXRSP to TXDAT pipeline, 
*                   decode stage. This module has the following actions: first, decode the
*                   request. Depending on which request it is, it acts differently.
*
*                   For Comp, COMPDBIDRESP, DBIDRESP request, read the TxnID table. 
*                   Between them: if it is Comp and the CmpAck bit is set, send to the 
*                   RXDAT to TXRSP Pipeline; in addition, send to FILL queue to the L2 Cache.
*                   If it is COMPDBIDRESP and DBIDRESP, read the Wdat table and go to encode stage.
*
*                   For both Comp and CompDBIDResp requests, check the opcode of this corresponding request, 
*                   if it is non atomic, invalid the corresponding TxnID and 
*                   Wdat entries. Otherwise if it is atomic, only invalid the Wdat entries.
*
*                   For COMPDBIDRESP and DBIDRESP, their resp field is invalid. Therefore this 
*                   module generates resp_o depending on different TXREQ requests. For COPYBACKDATA
*                   corresponds to WRITEBACKFULL, it is always RESP_COMPDATA_UD_PD; for ATOMICS, this 
*                   field is zero.
*                   
*                   The retry logic is removed from this pipeline, and will be handled separated by 
*                   the retry logic module
*
*                   Add support for WRITENOSNPFULL/PTL, WRITEQNIQUEFULL/PTL. 
*                   For COMPDBIDRESP and DBIDRESP responses, if they are corresponding to WRITEBACKFULL, 
*                   then COPYBAKWRDATA is provided to send data back to the HN; otherwise for WRITENOSNP*,
*                   WRITEUNIQUE*, all the ATOMICS, NOCOPYBACKWRDATA is provided as data packet.
*                   Currently we do not have byte enable signals comming in, therefore we treat PTL request
*                   as FULL write request.
* 
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rxrsp_p_dec 
    import chi_rn_params_pkg::*;
    #(
        parameter int SUPPORT_WRITENOSNP_WRITEUNIQUE = 1,
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
        parameter DATA_DAT,
        parameter type txnid_table_pkt_t = txnid_table_pkt_default_t,
        parameter type wdat_table_pkt_t  = wdat_table_pkt_default_t
    )
(
    // Generic
     clk                             ,
     rst_n                           ,
    // Stall signal from the next stage
     arb_dec_stop_i                  ,
    // Stall signal from RXDAT pipeline
     rxdatp_rxrspp_cmpack_stall_i    ,  
    // Request flit from the previous stage
     rx_dec_rspvalid_i               ,
      rx_dec_rsp_i                    ,
    // Interface with TxnID table 
     txnid_table_rd_en_o             ,
     txnid_table_rd_addr_o           ,
     txnid_table_rd_data_i           ,
     txnid_table_rd_data_valid_i     ,
     txnid_table_wr_en_1_and_o       ,
     txnid_table_wr_data_1_and_o     ,
    // Interface with Wdat table 
      wdat_table_rd_en_o              ,
      wdat_table_rd_addr_o            ,
      wdat_table_rd_data_i            ,
      wdat_table_rd_data_valid_i      ,
      wdat_table_wr_en_1_and_o        ,
      wdat_table_wr_data_1_and_o      ,
    // Output CmpAck signal to RXDAT pipeline
     rxrspp_rxdatp_rspflitv_o        ,
     rxrspp_rxdatp_rspflit_o         ,
    // Output to FILL 
    rxrspp_fill_data_o              ,
    rxrspp_fill_data_valid_o        ,                           
    rxrspp_fill_q_full_i            ,                           
    // Interface with next pipeline stage 
    dec_arb_datflitv_o              ,
    dec_arb_datflit_o               ,
    // output decode stop
    decode_stop_o 
);


 // Generic
    input  logic                              clk                             ;
    input  logic                              rst_n                           ;
    // Stall signal from the next stage
    input  logic                              arb_dec_stop_i                  ;
    // Stall signal from RXDAT pipeline
    input  logic                              rxdatp_rxrspp_cmpack_stall_i    ;  
    // Request flit from the previous stage
    input  logic                              rx_dec_rspvalid_i               ;
    input  logic [RSP_FLIT_SIZE-1:0]          rx_dec_rsp_i                    ;
    // Interface with TxnID table 
    output logic                              txnid_table_rd_en_o             ;
    output logic [TXNID_TABLE_ADDR-1:0]       txnid_table_rd_addr_o           ;
    input  txnid_table_pkt_t                  txnid_table_rd_data_i           ;
    input  logic                              txnid_table_rd_data_valid_i     ;
    output logic                              txnid_table_wr_en_1_and_o       ;
    output logic [2**TXNID_TABLE_ADDR-1:0]    txnid_table_wr_data_1_and_o     ;
    // Interface with Wdat table 
    output logic                              wdat_table_rd_en_o              ;
    output logic [WDAT_TABLE_ADDR-1:0]        wdat_table_rd_addr_o            ;
    input  wdat_table_pkt_t                   wdat_table_rd_data_i            ;
    input  logic                              wdat_table_rd_data_valid_i      ;
    output logic                              wdat_table_wr_en_1_and_o        ;
    output logic [2**WDAT_TABLE_ADDR-1:0]     wdat_table_wr_data_1_and_o      ;
    // Output CmpAck signal to RXDAT pipeline
    output logic                              rxrspp_rxdatp_rspflitv_o        ;
    output logic [RSP_FLIT_SIZE-1:0]          rxrspp_rxdatp_rspflit_o         ;
    // Output to FILL 
    output l2_fill_pkt_t                      rxrspp_fill_data_o              ;
    output logic                              rxrspp_fill_data_valid_o        ;                           
    input  logic                              rxrspp_fill_q_full_i            ;                           
    // Interface with next pipeline stage 
    output logic                              dec_arb_datflitv_o              ;
    output logic [DAT_FLIT_SIZE-1:0]          dec_arb_datflit_o               ;
    // output decode stop
    output decode_stop_o ;





















    // logic definition
    chi_rspflit_pkt_t                        tmp_rx_dec_rsp_1ststage,
                                             tmp_rx_dec_rsp_2ndstage,
                                             tmp_rspflit_pkt_t;
    chi_datflit_pkt_t                        tmp_datflit_pkt_t;
    logic [TXNID_DAT-1:0]                    tmp_txnid;
    logic [OPCODE_RSP-1:0]                   tmp_opcode_rsp;
    logic [OPCODE_REQ-1:0]                   tmp_opcode_req;
    logic                                    tmp_dat_metadata_valid;
    txnid_table_pkt_t                        tmp_txnid_table_rd_data;
    logic                                    tmp_txnid_table_rd_data_valid ;
    logic [2**TXNID_TABLE_ADDR-1:0]          txnid_table_gen_add_mask_valid;
    logic                                    tmp_rxrspp_rxdatp_cmpack_valid; 
    logic [1:0]                              tmp_resp;
    logic is_atomic;

    // start coding body
    // first substage: 
    // a. decode to understand the request
    // b. read TxnID table - for tblid+bankaddr, wdat addr, addr, cmpack
    // c. related actions 
    //    For Comp, COMPDBIDRESP, DBIDRESP request, read the TxnID table. 
    //    Between them: if it is Comp and the CmpAck bit is set, send to the 
    //    RXDAT to TXRSP Pipeline; in addition, send to FILL queue to the L2 Cache.
    //    If it is COMPDBIDRESP and DBIDRESP, read the Wdat table and go to encode stage.
    // d. for RetryAck or PcrdGrant, 
    //    writing to TxnID table RetryAck and PcrdGrant.
    //    signal TXREQ pipeline
    //    for COMP, COMPDBIDRESP, invalid TxnID table
    //
    // a
    assign tmp_rx_dec_rsp_1ststage         = rx_dec_rsp_i;
    assign tmp_dat_metadata_valid          = rx_dec_rspvalid_i;
    assign tmp_txnid                       = tmp_rx_dec_rsp_1ststage.txnid; 
    assign tmp_opcode_rsp                  = tmp_rx_dec_rsp_1ststage.opcode;
    // b  read Txnid table, if arb_dec_stop_i is set, stop reading
    assign txnid_table_rd_en_o             = rx_dec_rspvalid_i && (tmp_opcode_rsp == COMP || tmp_opcode_rsp == COMPDBIDRESP || tmp_opcode_rsp == DBIDRESP) && !arb_dec_stop_i && !rxdatp_rxrspp_cmpack_stall_i && !rxrspp_fill_q_full_i;
    assign txnid_table_rd_addr_o           = tmp_txnid[TXNID_TABLE_ADDR-1:0];
    // c 
    //assign tmp_rxrspp_rxdatp_cmpack_valid  = txnid_table_rd_data_valid_i && txnid_table_rd_data_i[CMPACK_OFFSET-1] && tmp_opcode_rsp == COMP;
    //assign rxrspp_fill_data_valid_o        = txnid_table_rd_data_valid_i && txnid_table_rd_data_i[CMPACK_OFFSET-1] && tmp_opcode_rsp == COMP; 
    assign tmp_rxrspp_rxdatp_cmpack_valid  = txnid_table_rd_data_valid_i && txnid_table_rd_data_i.mem2.compack && tmp_opcode_rsp == COMP;
    assign rxrspp_fill_data_valid_o        = txnid_table_rd_data_valid_i && txnid_table_rd_data_i.mem2.compack && tmp_opcode_rsp == COMP; 
   

 
    // FOR DBIDRESP and COMPDBIDRESP, resp field is not valid 
    always_comb begin
        //if(!rst_n) begin
            tmp_resp = 2'b00;
        //end else begin
            case (tmp_rx_dec_rsp_1ststage.resp)
                RESP_COMPDATA_I:     tmp_resp = L2_ST_I;
                RESP_COMPDATA_SC:    tmp_resp = L2_ST_S;
                RESP_COMPDATA_UC:    tmp_resp = L2_ST_E;
                RESP_COMPDATA_UD_PD: tmp_resp = L2_ST_M;
            endcase
        //end
    end
    // in this case, for dataless completion fill, there is only one possible tmp_resp = L2_ST_E
    // but still the CHI Requestor Agent should translate it from the resp field
    // comp bit in l2_fill is set to 1 for dataless packet
    assign rxrspp_fill_data_o = {1'b1, tmp_resp, txnid_table_rd_data_i.mem2.tbl_id, txnid_table_rd_data_i.mem2.bank_addr, tmp_rx_dec_rsp_1ststage.resperr, {DATA_DAT{1'b0}}};

    // d  invalid (add mask write field 1) to txnid table
    // if arb_dec_stop_i is set, stop writing to Txnid table
    assign is_atomic                      = txnid_table_rd_data_valid_i && (txnid_table_rd_data_i.mem2.opcode_req >= ATOMICS_START && txnid_table_rd_data_i.mem2.opcode_req  <= ATOMICS_END); 
    assign txnid_table_wr_en_1_and_o       = ~is_atomic && rx_dec_rspvalid_i && (tmp_opcode_rsp == COMP || tmp_opcode_rsp == COMPDBIDRESP) && !arb_dec_stop_i && !rxdatp_rxrspp_cmpack_stall_i && !rxrspp_fill_q_full_i ;
    assign txnid_table_wr_data_1_and_o     = ~({{(2**TXNID_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_txnid);  //create a add mask for the write valid data

    //
    // flop the data between the first and second substage
    //
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tmp_txnid_table_rd_data             <= {TXNID_TABLE_DAT{1'b0}}; 
            tmp_txnid_table_rd_data_valid       <= 1'b0;
            tmp_rx_dec_rsp_2ndstage             <= {RSP_FLIT_SIZE{1'b0}}; 
            rxrspp_rxdatp_rspflitv_o            <= 1'b0;
        end else begin
            if (!arb_dec_stop_i && !rxdatp_rxrspp_cmpack_stall_i && !rxrspp_fill_q_full_i) begin
               tmp_txnid_table_rd_data          <= txnid_table_rd_data_i ; 
               tmp_txnid_table_rd_data_valid    <= txnid_table_rd_data_valid_i;
               tmp_rx_dec_rsp_2ndstage          <= tmp_rx_dec_rsp_1ststage;
               rxrspp_rxdatp_rspflitv_o         <= tmp_rxrspp_rxdatp_cmpack_valid ;
            end
        end
    end

    //
    // second substage:
    // a. for COMPDBIDRESP and DBIDRESP, read wdat table
    // b. write valid == 0 to the wdat table
    // c. get the data from the corresponding wdat table entry and send it together with other information to the next stage
    // attention: COMP, RETRYACK, PCRDGRANT should not get any activities on the second substage.
    // but because COMP might generate COMPACK, and this needs all the qos, tgtid, srcid, therefore for this exception, 
    // COMPACK outputs are valid on the second substage 
    //
    assign tmp_opcode_req                 = tmp_txnid_table_rd_data.mem2.opcode_req;
    // a
    assign wdat_table_rd_en_o             = tmp_txnid_table_rd_data_valid && (tmp_rx_dec_rsp_2ndstage.opcode == COMPDBIDRESP || tmp_rx_dec_rsp_2ndstage.opcode  == DBIDRESP) && (!arb_dec_stop_i && !rxdatp_rxrspp_cmpack_stall_i && !rxrspp_fill_q_full_i) ;
    assign wdat_table_rd_addr_o           = tmp_txnid_table_rd_data.mem2.wdat_table_addr;
    // b
    assign wdat_table_wr_en_1_and_o       = wdat_table_rd_data_valid_i;
    assign wdat_table_wr_data_1_and_o     = ~({{(2**WDAT_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_txnid_table_rd_data.mem2.wdat_table_addr);


    // c
    // assign datflit
    assign tmp_datflit_pkt_t.data = wdat_table_rd_data_i.data;
    assign tmp_datflit_pkt_t.be = wdat_table_rd_data_i.dmask;
    // here we should flop one cycle in order to synchronize the data from wdat table and the tmp_rx_dec_rsp_1ststage signals for output
    assign tmp_datflit_pkt_t.qos = tmp_rx_dec_rsp_2ndstage.qos              ;
    // the srcid from the rxrsp packet should be now the tgtid of the txdat packet
    assign tmp_datflit_pkt_t.tgtid = tmp_rx_dec_rsp_2ndstage.srcid            ;
    // the tgtid from the rxrsp packet should be now the srcid of the txdat packet
    assign tmp_datflit_pkt_t.srcid = tmp_rx_dec_rsp_2ndstage.tgtid            ;
    // the dbidid from the rxrsp packet should be now the txnid of the txdat packet
    assign tmp_datflit_pkt_t.txnid = tmp_rx_dec_rsp_2ndstage.dbid             ;
    // the HomeNID has sources: from the RXDAT packet (HomeNID) or from the Comp_UC
    // (SrcID) corresponding to CLEANUNIQUE transaction; since both situations require
    // the RN to send back a CompAck to HN.
    // Therefore this field has values valid for these two situations.
    // for all the other situation, it must be all zeros
    // for the all zeros situation
    assign tmp_datflit_pkt_t.homenid = {HOMENID_DAT{1'b0}}             ;
    // for WRITEBACKFULL, we use CBWrData as opcode for the data flit
    // for ATOMICS, we use NCBWrData as opcode for the data flit
    generate
        if (SUPPORT_WRITENOSNP_WRITEUNIQUE == 1) begin
            always_comb begin
                tmp_datflit_pkt_t.opcode  = 3'h0;
                tmp_datflit_pkt_t.resp = RESP_COMPDATA_I;
                tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                if(tmp_opcode_req == WRITEBACKFULL) begin
                    tmp_datflit_pkt_t.opcode  = COPYBACKWRDATA ;
                    tmp_datflit_pkt_t.resp = RESP_COMPDATA_UD_PD;
                    // for COPYBACKWRDATA and NOCOPYBACKWRDATA, fwd_datapull must set to zero
                    tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                    // for WRITENOSNP* and WRITEUNIQUE*, use NOCOPYBACKWRDATA as data response opcode
                    // for NOCOPYBACKWRDATA, the only resp value allowed is RESP_COMPDATA_I
                end else if(tmp_opcode_req == WRITENOSNPPTL || tmp_opcode_req == WRITENOSNPFULL || tmp_opcode_req == WRITEUNIQUEPTL || tmp_opcode_req == WRITEUNIQUEFULL) begin
                    tmp_datflit_pkt_t.opcode  = NOCOPYBACKWRDATA ;
                    tmp_datflit_pkt_t.resp = RESP_COMPDATA_I;
                    tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                    // end else if tmp_opcode_req is ATOMICs, ATOMICs starts at 0x28 to 0x39
                end else if(tmp_opcode_req >= ATOMICS_START && tmp_opcode_req <= ATOMICS_END) begin
                    tmp_datflit_pkt_t.opcode  = NOCOPYBACKWRDATA ;
                    tmp_datflit_pkt_t.resp = RESP_COMPDATA_I;
                    tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                end else begin
                    tmp_datflit_pkt_t.fwd_datapull  = tmp_rx_dec_rsp_2ndstage.fwd_datapull;
                end
            end
        end else begin
            always_comb begin
                tmp_datflit_pkt_t.opcode  = 3'h0;
                tmp_datflit_pkt_t.resp = RESP_COMPDATA_I;
                tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                if(tmp_opcode_req == WRITEBACKFULL) begin
                    tmp_datflit_pkt_t.opcode  = COPYBACKWRDATA ;
                    tmp_datflit_pkt_t.resp = RESP_COMPDATA_UD_PD;
                    // for COPYBACKWRDATA and NOCOPYBACKWRDATA, fwd_datapull must set to zero
                    tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                    // end else if tmp_opcode_req is ATOMICs, ATOMICs starts at 0x28 to 0x39
                end else if(tmp_opcode_req >= ATOMICS_START && tmp_opcode_req <= ATOMICS_END) begin
                    tmp_datflit_pkt_t.opcode  = NOCOPYBACKWRDATA ;
                    tmp_datflit_pkt_t.resp = RESP_COMPDATA_I;
                    tmp_datflit_pkt_t.fwd_datapull  = {FWD_DATAPULL_DAT{1'b0}};
                end else begin
                    tmp_datflit_pkt_t.fwd_datapull  = tmp_rx_dec_rsp_2ndstage.fwd_datapull;
                end
            end
        end
    endgenerate

    assign tmp_datflit_pkt_t.resperr                       = tmp_rx_dec_rsp_2ndstage.resperr;     
    // the dbidid in the txdata packet is not valid
    assign tmp_datflit_pkt_t.dbid                          = tmp_rx_dec_rsp_2ndstage.dbid;
    generate
        if (CHI_DAT_HAS_CCID) assign tmp_datflit_pkt_t.ccid = {CCID_DAT{1'b0}};
    endgenerate
    generate
        if (CHI_DAT_HAS_DATAID) assign tmp_datflit_pkt_t.dataid = {DATAID_DAT{1'b0}};
    endgenerate
    generate
        if (CHI_DAT_HAS_TRACETAG) assign tmp_datflit_pkt_t.tracetag = tmp_rx_dec_rsp_2ndstage.tracetag;
    endgenerate
    generate
        if (CHI_DAT_HAS_DATACHECK) assign tmp_datflit_pkt_t.datacheck = {DATACHECK_DAT{1'b0}};
    endgenerate
    generate
        if (CHI_DAT_HAS_POISON) assign tmp_datflit_pkt_t.poison = {POISON_DAT{1'b0}};
    endgenerate

    // for the CLEANUNIQUE situation
    // assign rspflit
    assign tmp_rspflit_pkt_t.qos                           = tmp_rx_dec_rsp_2ndstage.qos;
    assign tmp_rspflit_pkt_t.tgtid                         = tmp_rx_dec_rsp_2ndstage.srcid;  
    assign tmp_rspflit_pkt_t.srcid                         = tmp_rx_dec_rsp_2ndstage.tgtid;
    assign tmp_rspflit_pkt_t.txnid                         = tmp_rx_dec_rsp_2ndstage.dbid; 
    assign tmp_rspflit_pkt_t.opcode                        = COMPACK; 
    // for COMPACK response, must set to zero
    assign tmp_rspflit_pkt_t.resperr                       = {RESPERR_RSP{1'b0}};     
    // for COMPACK response, must set to zero
    assign tmp_rspflit_pkt_t.resp                          = {RESP_RSP{1'b0}};     
    assign tmp_rspflit_pkt_t.fwd_datapull                  = 1'b0;
    generate
        if (CHI_RSP_HAS_TRACETAG) assign tmp_rspflit_pkt_t.tracetag = tmp_rx_dec_rsp_2ndstage.tracetag;
    endgenerate
    assign tmp_rspflit_pkt_t.dbid                          = tmp_rx_dec_rsp_2ndstage.dbid;
    // for COMPACK response, must set to zero
    assign tmp_rspflit_pkt_t.pcrdtype                      = {PCRDTYPE_RSP{1'b0}};
 
    // assign output
    assign rxrspp_rxdatp_rspflit_o                         = tmp_rspflit_pkt_t;
    assign dec_arb_datflit_o                               = tmp_datflit_pkt_t;
    assign dec_arb_datflitv_o                              = wdat_table_rd_data_valid_i; 
    assign decode_stop_o = arb_dec_stop_i || rxdatp_rxrspp_cmpack_stall_i || rxrspp_fill_q_full_i;

endmodule 
