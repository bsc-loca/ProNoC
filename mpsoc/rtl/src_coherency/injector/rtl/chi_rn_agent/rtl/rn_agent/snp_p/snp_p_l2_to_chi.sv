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
*   Date:           04/03/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI Requestor agent SNP logic from L2 Req queue to CHI TXRSP 
*                   and TXDAT chanels
*
*   Description:    This module implements:
*                   1) receives l2_req packet
*                      if both rsp_ch1 and rsp_ch2 are valid, add an extra invalid bit "set with 0" with the rsp_ch1 message,
                       and add an extra invalid bit "set with 1" with the rsp_ch2 message. 
*                   2) decodes, reads snoop_table and sends the messages to either TXRSP or TXDAT pipeline.
*                   3) for messages that has the extra invalid bit set with 0, write a NULL invalidation to the snoop_table entry
*                      for messages that has the extra invalid bit set with 1, write a invalidation to the snoop table entry
*                    
*                   The L2_Req packet that received in this module can have four different types:
*                   case1: rsp_ch1 == SRSP, rsp_ch2 == NOP
*                   case2: rsp_ch1 == WDAT, rsp_ch2 == NOP
*                   case3: rsp_ch1 == SRSP, rsp_ch2 == WDAT
*                   case4: rsp_ch1 == WDAT, rsp_ch2 == WDAT
*                   
*                   In all the cases, there is only one field also in the same field rsp_ch1 goes to SRSP chanel. 
*                   In case4, there are two fields that go to WDAT chanel, for this reason, a 1-entry buffer is used
*                   when we cannot send all the packets to WDAT chanel. 
*                   Whenever the buffer is used, we cannot accept any new L2_req packet. 
*                   When this buffer is empty, we send directly the L2_req rsp_ch1; whenever the buffer is occupied, we 
*                   send the one in the buffer (always will be a rsp_ch2 message)
*
*                   For tgtid, always targets at HN; and rsp_ch2 always targets for RN.
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module snp_p_l2_to_chi
    import chi_rn_params_pkg::*;
    #(
        parameter CHI_EVICT_HAS_RSP_CH = 0, // add rsp_chi field inside the l2_evict packet
        parameter CHI_RSP_HAS_TRACETAG = 0,
        parameter CHI_DAT_HAS_CCID = 0,
        parameter CHI_DAT_HAS_DATAID = 0,
        parameter CHI_DAT_HAS_TRACETAG = 0,
        parameter CHI_DAT_HAS_DATACHECK = 0,
        parameter CHI_DAT_HAS_POISON = 0,
        // parameter for flit structs and configurable field sizes
        parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
        parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t,
        parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
        parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
        parameter type l2_req_pkt_t      = l2_req_pkt_default_t,
        parameter type l2_data_pkt_t     = l2_data_pkt_default_t,
        parameter REQ_FLIT_SIZE,
        parameter DAT_FLIT_SIZE,
        parameter RSP_FLIT_SIZE,
        parameter SNP_FLIT_SIZE,
        parameter L2_REQ_SIZE,
        parameter L2_TBL_ID,
        parameter QOS_RSP,
        parameter SRCID_RSP,
        parameter OPCODE_DAT,
        parameter DATA_DAT,
        parameter BE_DAT,
        parameter DATACHECK_DAT,
        parameter POISON_DAT
    )
(
     //generic
     clk                              ,
     rst_n                            ,
    /*--------- Stop signal -----------------------------------------*/
     stop_i                           ,
    /*--------- Interface with TXREQ logic --------------------------*/
     l2_snp_data_valid_i              ,
     l2_snp_req_i                     ,
     l2_snp_data_i                    , 
    /*--------- Interface with Snoop table --------------------------*/
    // read port  
     snoop_table_rd_en_o              ,
     snoop_table_rd_addr_o            ,
      snoop_table_data_output_i        ,
     snoop_table_data_output_valid_i  ,  
    // write port 
     snoop_table_wr_en_1_and_o        ,
      snoop_table_wr_data_1_and_o      ,
    /*--------- Common interface with other pipelines ----------------*/
           snpp_txrsp_rspflit_o             ,
        snpp_txrsp_rspflitv_o            ,
 txrsp_snpp_stall_i               ,
    /*--------- Interface with RXRSP to TXDAT pipeline encode stage --*/
    snpp_txdat_datflit_o             ,
    snpp_txdat_datflitv_o            ,
    txdat_snpp_stall_i               , 
    /*--------- Stop signal -----------------------------------------*/
     stop_o                           ,
     src_id
);


 //generic
    input  logic                            clk                              ;
    input  logic                            rst_n                            ;
    /*--------- Stop signal -----------------------------------------*/
    input  logic                            stop_i                           ;
    /*--------- Interface with TXREQ logic --------------------------*/
    input  logic                            l2_snp_data_valid_i              ;
    input  l2_req_pkt_t                     l2_snp_req_i                     ;
    input  l2_data_pkt_t                    l2_snp_data_i                    ; 
    /*--------- Interface with Snoop table --------------------------*/
    // read port  
    output logic                            snoop_table_rd_en_o              ;
    output logic [SNOOP_TABLE_ADDR-1:0]     snoop_table_rd_addr_o            ;
    input  logic [SNOOP_TABLE_DAT-1:0]      snoop_table_data_output_i        ;
    input  logic                            snoop_table_data_output_valid_i  ;  
    // write port 
    output logic                            snoop_table_wr_en_1_and_o        ;
    output logic [2**SNOOP_TABLE_ADDR-1:0]  snoop_table_wr_data_1_and_o      ;
    /*--------- Common interface with other pipelines ----------------*/
    output logic [RSP_FLIT_SIZE-1:0]        snpp_txrsp_rspflit_o             ;
    output logic                            snpp_txrsp_rspflitv_o            ;
    input  logic                            txrsp_snpp_stall_i               ;
    /*--------- Interface with RXRSP to TXDAT pipeline encode stage --*/
    output logic [DAT_FLIT_SIZE-1:0]        snpp_txdat_datflit_o             ;
    output logic                            snpp_txdat_datflitv_o            ;
    input  logic                            txdat_snpp_stall_i               ; 
    /*--------- Stop signal -----------------------------------------*/
    output logic                            stop_o                           ;
    input logic [SRCID_RSP-1 : 0]           src_id			     ;




    // logic definition
    l2_req_pkt_t                           tmp_l2_req_data;
    snoop_table_pkt2_t                     tmp_snoop_table_pkt2_data;  
    chi_datflit_pkt_t                      tmp_chi_datflit_pkt1;
    chi_datflit_pkt_t                      tmp_chi_datflit_pkt2;
    chi_rspflit_pkt_t                      tmp_chi_rspflit_pkt;
    // fifo signals
    logic tmp_fifo_push_i;
    logic tmp_fifo_pop_i;
    logic [OPCODE_DAT+RESPERR_DAT+RESP_DAT+L2_TBL_ID-1:0] tmp_fifo_push_data_i;
    logic [OPCODE_DAT+RESPERR_DAT+RESP_DAT+L2_TBL_ID-1:0] tmp_fifo_pop_data_o;
    logic fifo_full;
    
    // all the stop signals that will cause this stage to stall    
    logic tmp_stop_2nd;

    // L2_Req rsp_ch1 valid and is for SRSP chanel
    logic tmp_ch1_srsp_valid;
    // L2_Req rsp_ch2 is not valid
    logic tmp_ch2_not_valid ;
    // L2_Req rsp_ch1 is valid  and is for WDAT chanel
    logic tmp_ch1_wdat_valid;
    // L2_Req rsp_ch2 is valid  and is for WDAT chanel
    logic tmp_ch2_wdat_valid;
    // all the four types of L2_Req snoop responses
    logic case1_valid ; 
    logic case2_valid ;
    logic case3_valid ; 
    logic case4_valid ; 

    // directly send SRSP message invalidation data for snoop table entry
    // it includes tbl_id, and the extra invalidation bit
    // if the extra invalidation bit is set to 0, it will induce a NULL invalidation
    // otherwise, it will induce a normal invalidation
    logic [L2_TBL_ID:0] snpp_srsp_invalid_snoop_table_data;
    logic               snpp_srsp_invalid_snoop_table_datav;
    // the extra invalidation bit in the previous vector
    logic               snpp_srsp_invalid_data;
    // write invalidation data with or mask - 32bits
    logic [2**SNOOP_TABLE_ADDR-1:0] snpp_srsp_snoop_table_wr_data_1_and_o; 
    // directly send WDAT message invalidation data for snoop table entry
    logic [L2_TBL_ID:0] snpp_wdat_invalid_snoop_table_data_1;
    logic               snpp_wdat_invalid_snoop_table_datav_1;
    // the extra invalidation bit in the previous vector
    logic               snpp_wdat_invalid_data1;
    // write invalidation data with or mask - 32bits
    logic [2**SNOOP_TABLE_ADDR-1:0] snpp_wdat_snoop_table_wr_data_1_and_o_1; 
    // fifo output WDAT message invalidation data for snoop table entry
    logic [L2_TBL_ID:0] snpp_wdat_invalid_snoop_table_data_2; 
    logic               snpp_wdat_invalid_snoop_table_datav_2;
    // the extra invalidation bit in the previous vector
    logic               snpp_wdat_invalid_data2;
    // write invalidation data with AND mask - 32bits
    logic [2**SNOOP_TABLE_ADDR-1:0] snpp_wdat_snoop_table_wr_data_1_and_o_2;

    // for snoop table read port
    logic tmp_rd_en;
    logic [SNOOP_TABLE_ADDR-1:0] tmp_rd_addr;

    // directly send datflit
    logic [DAT_FLIT_SIZE-1:0]        snpp_datflit_o_1 ;
    logic                            snpp_datflitv_o_1;

    // pipeline stage 2
    // delayed fifo send datflit
    logic [DAT_FLIT_SIZE-1:0]        snpp_datflit_o_2 ;
    logic                            snpp_datflitv_o_2;

    logic                            l2_snp_req_valid_i_2nd       ;
    logic [L2_REQ_SIZE-1:0]          l2_snp_req_i_2nd             ;
    logic [OPCODE2-1:0]              tmp_l2_req_data_opcode2_2nd  ; 
    logic [RESPERR_DAT-1:0]          tmp_l2_req_data_resperr2_2nd ; 
    logic [RESP_DAT-1:0]             tmp_l2_req_data_resp2_2nd    ; 
    logic [L2_TBL_ID-1:0]            tmp_l2_req_data_tbl_id_2nd   ; 

    logic        tmp_fifo_push_i_delay;
    /*-------------------------------------------------------------------------------------------*/
    /* Start coding body*/ 
    /*-------------------------------------------------------------------------------------------*/
    assign tmp_stop_2nd = stop_i || txrsp_snpp_stall_i || txdat_snpp_stall_i;
    assign tmp_l2_req_data = l2_snp_req_i;
  

    /*------------------------------------------------------------------------------------------*/ 
    /* Pipeline stage 1: send direct and push data */ 
    /*------------------------------------------------------------------------------------------*/ 
    // decode
    // check both rsp_ch1 and rsp_ch2 in the l2 req packet
    // case1: tmp_ch1_srsp_valid && tmp_ch2_not_valid 
    // case2: tmp_ch1_wdat_valid && tmp_ch2_not_valid 
    // case3: tmp_ch1_srsp_valid && tmp_ch2_wdat_valid 
    // case4: tmp_ch1_wdat_valid && tmp_ch2_wdat_valid 
    assign tmp_ch1_srsp_valid = l2_snp_data_valid_i && tmp_l2_req_data.rsp_ch1 == SRSP && !fifo_full;
    assign tmp_ch2_not_valid  = l2_snp_data_valid_i && tmp_l2_req_data.rsp_ch2 == NORP && !fifo_full;
    assign tmp_ch1_wdat_valid = l2_snp_data_valid_i && tmp_l2_req_data.rsp_ch1 == WDAT && !fifo_full;
    assign tmp_ch2_wdat_valid = l2_snp_data_valid_i && tmp_l2_req_data.rsp_ch2 == WDAT && !fifo_full;

    assign case1_valid = tmp_ch1_srsp_valid && tmp_ch2_not_valid ; 
    assign case2_valid = tmp_ch1_wdat_valid && tmp_ch2_not_valid ;
    assign case3_valid = tmp_ch1_srsp_valid && tmp_ch2_wdat_valid; 
    assign case4_valid = tmp_ch1_wdat_valid && tmp_ch2_wdat_valid; 


    // in case1 and case3, we package and send the RSPFLIT, we also read the snoop table
    // here we only show the package and send RSPFLIT logic 
    assign tmp_chi_rspflit_pkt.qos           = {QOS_RSP{1'b0}};
    assign tmp_chi_rspflit_pkt.srcid         = src_id;
    generate
        if (CHI_RSP_HAS_TRACETAG) assign tmp_chi_rspflit_pkt.tracetag = 1'b0;
    endgenerate
    // pcrdtype is not applicable in Snoop responses
    assign tmp_chi_rspflit_pkt.pcrdtype      = {PCRDTYPE_RSP{1'b0}};
    assign tmp_chi_rspflit_pkt.opcode        = tmp_l2_req_data.opcode1[3:0];
    assign tmp_chi_rspflit_pkt.resp          = tmp_l2_req_data.resp1;
    assign tmp_chi_rspflit_pkt.resperr       = tmp_l2_req_data.resperr1;
    // fwdstate[2:0] is applicable in SnpRespFwded and SnpRespDataFwded
    // inapplicable in all other Snoop responses
    // in our case the fwdstate is always equals to either resp1 or resp2 depending on which chanel this message is from 
    assign tmp_chi_rspflit_pkt.fwd_datapull  = tmp_l2_req_data.resp1;
    // rsp_ch1 is always targeted to HomeNID, rsp_ch2 is always targeted to RN
    assign tmp_chi_rspflit_pkt.tgtid         = tmp_snoop_table_pkt2_data.srcid;  //: tmp_snoop_table_pkt2_data.fwdnid;
    assign tmp_chi_rspflit_pkt.txnid         = tmp_snoop_table_pkt2_data.txnid;
    // DBID is not applicable for rxrsp snoop response 
    assign tmp_chi_rspflit_pkt.dbid          = tmp_snoop_table_pkt2_data.txnid;
    // source id is determined by us
    // assign the rspflit
    assign snpp_txrsp_rspflitv_o             = (case1_valid || case3_valid) && snoop_table_data_output_valid_i && !tmp_stop_2nd;
    assign snpp_txrsp_rspflit_o              = tmp_chi_rspflit_pkt;

    // invalidation packet for each message
    // for case1: the extra invalidation bit is set to 1; for case3: the extra invalidata bit is set to 0
    assign snpp_srsp_invalid_snoop_table_data[L2_TBL_ID]     =  case1_valid? 1'b1: 1'b0; 
    // save the tbl_id for setting the AND mask
    assign snpp_srsp_invalid_snoop_table_data[L2_TBL_ID-1:0]   = tmp_l2_req_data.tbl_id;
    // invalidation packet valid 
    assign snpp_srsp_invalid_snoop_table_datav    = (case1_valid || case3_valid) && snoop_table_data_output_valid_i && !tmp_stop_2nd;

    // pack and send WDAT
    // truth table of how to deal with wdat messages
    // case2, case3, case4, b_empty, fifo_full
    //  1       0      0      1        0   ->  send datflit,  read snoop table once, set the extra invalid bit to 1 
    //  1       0      0      0        0   ->  fifo, set the extra invalid bit to 1
    //  1       0      0      0        1   ->  stall, don't do anything
    //  0       1      0      1        0   ->  send rspflit and datflit, read snoop table once, set the extra invalid bit of dataflit to 1
    //  0       1      0      0        0   ->  send rspflit, write datflit to fifo, read snoop table twice, set extra invalid dataflit to 1    //  0       1      0      0        1   ->  stall, don't do anything
    //  0       0      1      1        0   ->  1st datflit send and 2nd datflit to fifo, read snoop table twice, set 1st invalid to 0, 2nd invalid to 1
    //  0       0      1      0        0   ->  both datflits to fifo, if during the process, fifo is full, stall; read snoop table twice, set 1st invalid 0, 2nd invalid 1. 
    // for send directly datflit logic, the following cases are true
    // case2, case3, case4, b_empty, fifo_full
    //  1       0      0      1        0   ->  send datflit,  read snoop table once, set the extra invalid bit to 1 
    //  0       1      0      1        0   ->  send rspflit and datflit, read snoop table once, set the extra invalid bit of dataflit to 1
    //  0       0      1      1        0   ->  1st datflit send and 2nd datflit to fifo, read snoop table twice, set 1st invalid to 0, 2nd invalid to 1
    // pcrdtype is not applicable in Snoop responses
    assign tmp_chi_datflit_pkt1.qos              = {QOS_RSP{1'b0}}                     ;
    assign tmp_chi_datflit_pkt1.srcid            = src_id;
    generate
        if (CHI_DAT_HAS_CCID) assign tmp_chi_datflit_pkt1.ccid = 2'b00;
    endgenerate
    generate
        if (CHI_DAT_HAS_DATAID) assign tmp_chi_datflit_pkt1.dataid = 2'b00;
    endgenerate
    generate
        if (CHI_DAT_HAS_TRACETAG) assign tmp_chi_datflit_pkt1.tracetag = 1'b0;
    endgenerate
    generate
        if (CHI_DAT_HAS_DATACHECK) assign tmp_chi_datflit_pkt1.datacheck = {DATACHECK_DAT{1'b0}};
    endgenerate
    generate
        if (CHI_DAT_HAS_POISON) assign tmp_chi_datflit_pkt1.poison = {POISON_DAT{1'b0}};
    endgenerate
    
    // rsp_ch1 is always targeted to HomeNID, rsp_ch2 is always targeted to RN
    // for datflit, if to HN, the tgtid = snoop_table_srcID,  the srcID is new, the TxnID = snoop_table_txnid, the Dbid is not valid
    // for datflit, if to RN, the tgtid = snoop_table_fwdID,  the srcID is new, the TxnID = snoop_table_fwdtxnid, the Dbid = snoop_table_txnid, the HomeNid = snoop_table_srcid
    assign tmp_chi_datflit_pkt1.tgtid            = (case2_valid || case4_valid)? tmp_snoop_table_pkt2_data.srcid : tmp_snoop_table_pkt2_data.fwdnid;            
    assign tmp_chi_datflit_pkt1.txnid            = (case2_valid || case4_valid)? tmp_snoop_table_pkt2_data.txnid :tmp_snoop_table_pkt2_data.fwdtxnid  ;
    assign tmp_chi_datflit_pkt1.homenid          = tmp_snoop_table_pkt2_data.srcid     ;            
    assign tmp_chi_datflit_pkt1.opcode           = (case2_valid || case4_valid)? tmp_l2_req_data.opcode1[OPCODE_DAT-1:0] : tmp_l2_req_data.opcode2[OPCODE_DAT-1:0];
    assign tmp_chi_datflit_pkt1.resperr          = (case2_valid || case4_valid)? tmp_l2_req_data.resperr1:tmp_l2_req_data.resperr2 ;
    assign tmp_chi_datflit_pkt1.resp             = (case2_valid || case4_valid)? tmp_l2_req_data.resp1   :tmp_l2_req_data.resp2    ; 
    assign tmp_chi_datflit_pkt1.fwd_datapull     = (case2_valid || case4_valid)? tmp_l2_req_data.resp1   :tmp_l2_req_data.resp2    ; 
    assign tmp_chi_datflit_pkt1.dbid             = tmp_snoop_table_pkt2_data.txnid; 

    if (CHI_EVICT_HAS_RSP_CH) begin
        assign tmp_chi_datflit_pkt1.data         = l2_snp_data_i.data;
        assign tmp_chi_datflit_pkt1.be           = l2_snp_data_i.dmask;
    end else begin
        assign tmp_chi_datflit_pkt1.data         = {{(DATA_DAT-TXNID_DAT){1'b0}}, tmp_snoop_table_pkt2_data.fwdtxnid};
        assign tmp_chi_datflit_pkt1.be           = {BE_DAT{1'b1}};
    end
        
    assign snpp_datflit_o_1                      = tmp_chi_datflit_pkt1;
    //assign snpp_datflitv_o_1                    = (case2_valid || case3_valid || case4_valid) && snoop_table_data_output_valid_i && !tmp_stop_2nd && !fifo_full;  // we will not receive any L2_req when fifo_full is valid
    assign snpp_datflitv_o_1                     = (case2_valid || case3_valid || case4_valid) && snoop_table_data_output_valid_i && !tmp_stop_2nd;  // we will not receive any L2_req when fifo_full is valid

    // invalidation packet for direct send datflit
    // for case2_valid and case3_valid, the extra invalidation bit is set to 1
    // for case4_valid with directly send, it means it is 1st of the double wdat L2_Req requeust, therefore its extra
    // invalidation bit should be set to 0.
    assign snpp_wdat_invalid_snoop_table_data_1[L2_TBL_ID]     =  (case2_valid || case3_valid)? 1'b1: 1'b0;
    // save the tbl_id 
    assign snpp_wdat_invalid_snoop_table_data_1[L2_TBL_ID-1:0]   = tmp_l2_req_data.tbl_id;
    // invalidation packet valid 
    assign snpp_wdat_invalid_snoop_table_datav_1   = (case2_valid || case3_valid || case4_valid) && snoop_table_data_output_valid_i && !tmp_stop_2nd;  // we will not receive any L2_req when fifo_full is valid, fifo_full signal also indicates the arbitration between sending direct or sending pop

     
    // in the remaining cases, we write the wdat into a fifo
    // case2, case3, case4, b_empty, fifo_full
    //  1       0      0      0        0   ->  fifo, set the extra invalid bit to 1
    //  0       1      0      0        0   ->  send rspflit, write datflit to fifo, read snoop table twice, set extra invalid dataflit to 1    
    //  0       0      1      1        0   ->  1st datflit send and 2nd datflit to fifo, read snoop table twice, set 1st invalid to 0, 2nd invalid to 1
    //  0       0      1      0        0   ->  both datflits to fifo, if during the process, fifo is full, stall; read snoop table twice, set 1st invalid 0, 2nd invalid 1.
    //  in the last case4 and !b_empty, we should also generate a one-cycle stop signal to stop the L2_Req 
    // when both datflits are writting to fifo, we need to delay the second datflit and the valid signal 



    // rsp_ch2 wdat always push to fifo, for pop data, therefore we always do a valid invalidation
    //assign tmp_fifo_push_i    =  case4_valid && !tmp_stop_2nd && !fifo_full; // we will only receive any L2_req when fifo_full is not valid, therefore we will push the rsp_ch2 into the fifo.
    assign tmp_fifo_push_i    =  case4_valid && !tmp_stop_2nd; // we will only receive any L2_req when fifo_full is not valid, therefore we will push the rsp_ch2 into the fifo.
    assign tmp_fifo_push_data_i = {tmp_l2_req_data.opcode2[OPCODE_DAT-1:0], tmp_l2_req_data.resperr2, tmp_l2_req_data.resp2, tmp_l2_req_data.tbl_id};
     
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tmp_fifo_pop_data_o <= {(OPCODE_DAT+RESPERR_DAT+RESP_DAT+L2_TBL_ID){1'b0}};
        end else if (tmp_fifo_push_i) begin
            tmp_fifo_pop_data_o <= tmp_fifo_push_data_i;
        end
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_full <= 1'b0;
        end else if (tmp_fifo_push_i) begin
            fifo_full <= 1'b1;
        end else if (tmp_fifo_pop_i) begin
            fifo_full <= 1'b0;
        end
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tmp_fifo_push_i_delay <= 1'b0;
        end else if (!tmp_stop_2nd) begin
            tmp_fifo_push_i_delay <= tmp_fifo_push_i;
        end
    end

    /*------------------------------------------------------------------------------------------*/ 
    /* Pipeline stage 2: pop and send */ 
    /*------------------------------------------------------------------------------------------*/
    assign tmp_fifo_pop_i = tmp_fifo_push_i_delay && !tmp_stop_2nd;
    assign tmp_chi_datflit_pkt2.qos              = {QOS_RSP{1'b0}};
    assign tmp_chi_datflit_pkt2.srcid            = src_id;
    generate
        if (CHI_DAT_HAS_CCID) assign tmp_chi_datflit_pkt2.ccid = 2'b00;
    endgenerate
    generate
        if (CHI_DAT_HAS_DATAID) assign tmp_chi_datflit_pkt2.dataid = 2'b00;
    endgenerate
    generate
        if (CHI_DAT_HAS_TRACETAG) assign tmp_chi_datflit_pkt2.tracetag = 1'b0;
    endgenerate
    assign tmp_chi_datflit_pkt2.be               = {BE_DAT{1'b1}}                  ;
    generate
        if (CHI_DAT_HAS_DATACHECK) assign tmp_chi_datflit_pkt2.datacheck = {DATACHECK_DAT{1'b0}};
    endgenerate
    generate
        if (CHI_DAT_HAS_POISON) assign tmp_chi_datflit_pkt2.poison = {POISON_DAT{1'b0}};
    endgenerate
    // on the second, stage, we always send rsp_ch2 chanel data, therefore, we always send to RN
    // for datflit, if to RN, the tgtid = snoop_table_fwdID,  the srcID is new, the TxnID = snoop_table_fwdtxnid, the Dbid = snoop_table_txnid, the HomeNid = snoop_table_srcid
    assign tmp_chi_datflit_pkt2.tgtid            = tmp_snoop_table_pkt2_data.fwdnid;
    assign tmp_chi_datflit_pkt2.txnid            = tmp_snoop_table_pkt2_data.fwdtxnid;
    assign tmp_chi_datflit_pkt2.homenid          = tmp_snoop_table_pkt2_data.srcid;            
    assign tmp_chi_datflit_pkt2.opcode           = tmp_fifo_pop_data_o[(OPCODE_DAT+RESPERR_DAT+RESP_DAT+L2_TBL_ID-1):(RESPERR_DAT+RESP_DAT+L2_TBL_ID)] ;
    assign tmp_chi_datflit_pkt2.resperr          = tmp_fifo_pop_data_o[           (RESPERR_DAT+RESP_DAT+L2_TBL_ID-1):(RESP_DAT+L2_TBL_ID)] ;
    assign tmp_chi_datflit_pkt2.resp             = tmp_fifo_pop_data_o[                       (RESP_DAT+L2_TBL_ID-1):(L2_TBL_ID)] ; 
    assign tmp_chi_datflit_pkt2.fwd_datapull     = tmp_fifo_pop_data_o[                       (RESP_DAT+L2_TBL_ID-1):(L2_TBL_ID)] ; 
    assign tmp_chi_datflit_pkt2.dbid             = tmp_snoop_table_pkt2_data.txnid; 
    assign tmp_chi_datflit_pkt2.data             = {{(DATA_DAT-TXNID_DAT){1'b0}}, tmp_snoop_table_pkt2_data.fwdtxnid};
    assign snpp_datflit_o_2                     = tmp_chi_datflit_pkt2;
    assign snpp_datflitv_o_2                    = tmp_fifo_pop_i && snoop_table_data_output_valid_i;

    // invalidation packet for fifo pop datflit
    assign snpp_wdat_invalid_snoop_table_data_2[L2_TBL_ID]     = 1'b1; 
    assign snpp_wdat_invalid_snoop_table_data_2[L2_TBL_ID-1:0] = tmp_fifo_pop_data_o[L2_TBL_ID-1:0]; 
    assign snpp_wdat_invalid_snoop_table_datav_2               = tmp_fifo_pop_i; 


    /*--------------------- Interact with Snoop table in both stages ------------------------------------------------*/
    // read snoop table to get the tgtid, srcid, txnid and dbid
    // when there is direct send or fifo send, we read snoop table
    assign tmp_rd_en = (l2_snp_data_valid_i && !tmp_stop_2nd) || tmp_fifo_pop_i;
    assign tmp_rd_addr = tmp_fifo_pop_i? tmp_fifo_pop_data_o[L2_TBL_ID-1:0] : tmp_l2_req_data.tbl_id;
    assign snoop_table_rd_en_o = tmp_rd_en;
    assign snoop_table_rd_addr_o = tmp_rd_addr;
    // read snoop table costs 0 cycle, therefore we are assign the output data in the same cycle
    assign tmp_snoop_table_pkt2_data =  snoop_table_data_output_i;  
    
    // the invalidation of the snoop table entry
    // we send a invalidation packet for each message we send
    // that means both directly send or fifo send
    // depending on the extra invalid bit whether it is set to zero or one,
    // we send a NULL OR mask or a OR mask.
    assign snoop_table_wr_en_1_and_o   = tmp_rd_en;
    assign snpp_srsp_invalid_data      = snpp_srsp_invalid_snoop_table_data[L2_TBL_ID];
    assign snpp_wdat_invalid_data1     = snpp_wdat_invalid_snoop_table_data_1[L2_TBL_ID];
    assign snpp_wdat_invalid_data2     = snpp_wdat_invalid_snoop_table_data_2[L2_TBL_ID]; 
    assign snpp_srsp_snoop_table_wr_data_1_and_o = (case1_valid)?  ~({{(2**SNOOP_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_l2_req_data.tbl_id) : {(2**SNOOP_TABLE_ADDR){1'b1}};
    //assign snpp_wdat_snoop_table_wr_data_1_and_o_1 = (snpp_wdat_invalid_data1 && (case2_valid || case3_valid) && !fifo_full)? ~({{(2**SNOOP_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_l2_req_data.tbl_id): {(2**SNOOP_TABLE_ADDR){1'b1}};
    assign snpp_wdat_snoop_table_wr_data_1_and_o_1 = (snpp_wdat_invalid_data1 && (case2_valid || case3_valid))? ~({{(2**SNOOP_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_l2_req_data.tbl_id): {(2**SNOOP_TABLE_ADDR){1'b1}};
    assign snpp_wdat_snoop_table_wr_data_1_and_o_2 = (snpp_wdat_invalid_data2 && tmp_fifo_pop_i) ? ~({{(2**SNOOP_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_fifo_pop_data_o[L2_TBL_ID-1:0]) :{(2**SNOOP_TABLE_ADDR){1'b1}};
    assign snoop_table_wr_data_1_and_o   = snpp_srsp_snoop_table_wr_data_1_and_o & snpp_wdat_snoop_table_wr_data_1_and_o_1 & snpp_wdat_snoop_table_wr_data_1_and_o_2 ;

    /*--------------------- End of interactacion with Snoop table ------------------------------------------------*/

    // merge output datflit
    assign snpp_txdat_datflitv_o                      = snpp_datflitv_o_1 || snpp_datflitv_o_2;
    assign snpp_txdat_datflit_o                       = snpp_datflitv_o_1 ? snpp_datflit_o_1 : snpp_datflit_o_2;

    assign stop_o = tmp_stop_2nd || fifo_full;
 


endmodule : snp_p_l2_to_chi
