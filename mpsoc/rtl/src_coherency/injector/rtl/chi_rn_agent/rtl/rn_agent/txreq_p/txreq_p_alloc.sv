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
*   Date:           11/02/2019
*-------------------------------------------------------------------------------
*   Title:          TXREQ Pipeline - alloc stage
*   Description:    The alloc stage has the following functionalities:
*                   1) For all the new requests, allocates a free entry in 
*                   the TxnID table and intialize the table entry.
*                   2) For requests with opcode == WriteBackFull or Atomics, 
*                   also allocate a free entry in the Wdat table and initialize
*                   the allocated entry.
*
*                   The information needed to pass to the next stage include:
*                   TgtID, SrcID, TxnID, ReturnTxnID, Opcode, Addr, all the other 
*                   fields will be fixed and thus are not mentioned here.
*                   
*                   We generate TgtID, SrCID in this module.                  
*                   Add amo_size to support the atomic operations in the evict queue, 
*                   also in the txnid table and the retry logic
* 
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module txreq_p_alloc 
    import chi_rn_params_pkg::*;
#(  
    parameter type l2_req_pkt_t  = l2_req_pkt_default_t,
    parameter type l2_data_pkt_t = l2_data_pkt_default_t,
    parameter L2_REQ_SIZE,
    parameter SRCID_REQ,
    parameter TGTID_REQ,
    parameter ADDR_REQ,
    parameter TXNID_TABLE_DAT2,
    parameter WDAT_TABLE_DAT,
    parameter type txnid_table_pkt2_t = txnid_table_pkt2_default_t
)(
    // Stop signal from the next stage
    input  logic                            enc_stop_i                 ,
    // Data from the arb stage 
    input  logic                            arb_alloc_req_valid_i      ,
    input  logic [L2_REQ_SIZE-1:0]          arb_alloc_req_dat_i        ,
    input  l2_data_pkt_t                    arb_alloc_evict_data_i     ,
    input  logic [1:0]                      arb_alloc_evict_amo_size_i ,
    // Interface with txnID table 
    input  logic                            txnid_table_full_i         ,
    input  logic [TXNID_TABLE_ADDR-1:0]     txnid_table_index_i        ,
    output logic                            txnid_table_wr_en_1_or_o   ,
    output logic                            txnid_table_wr_en_2_o      ,
    output logic [TXNID_TABLE_ADDR-1:0]     txnid_table_wr_addr_2_o    , 
    output logic [2**TXNID_TABLE_ADDR-1:0]  txnid_table_wr_data_1_or_o ,
    output logic [TXNID_TABLE_DAT2-1:0]     txnid_table_wr_data_2_o    ,
    // Interface with Wdat table
    input  logic                            wdat_table_full_i          ,
    input  logic [WDAT_TABLE_ADDR-1:0]      wdat_table_index_i         ,
    output logic                            wdat_table_wr_en_1_or_o    ,
    output logic [2**WDAT_TABLE_ADDR-1:0]   wdat_table_wr_data_1_or_o  ,
    output logic                            wdat_table_wr_en_2_o       ,
    output logic [WDAT_TABLE_ADDR-1:0]      wdat_table_wr_addr_2_o     , 
    output logic [WDAT_TABLE_DAT-1:0]       wdat_table_wr_data_2_o     ,
    // Interface to the next stage
    output logic [TGTID_REQ-1:0]            tgtid_o                    ,
    output logic [SRCID_REQ-1:0]            srcid_o                    ,
    output logic [TXNID_REQ-1:0]            txnid_o                    ,
    output logic [OPCODE_REQ-1:0]           opcode_o                   ,
    output logic [ADDR_REQ-1:0]             addr_o                     ,
    output logic [1:0]                      amo_size_o                 ,
    output logic                            excl_snoopme_o             ,
    output logic                            req_metadata_valid_o       ,
    // alloc stage stop signal
    output logic                            alloc_stop_o               ,
    // SAM
    input  logic [TGTID_REQ-1:0]            sam_target_id_i            ,
    input logic  [SRCID_REQ-1:0]            src_id
    //input  logic [SRCID_REQ-1:0]            source_id_i
); 


    // logic definition
    l2_req_pkt_t tmp_arb_alloc_req_data_i;
    txnid_table_pkt2_t tmp_txnid_table_wr_data2;
    logic tmp_wdat_table_req_valid;
    //// fake data
    //logic [L2_DATA-1:0] tmp_fake_data;
    logic [2**TXNID_TABLE_ADDR-1:0]   tmp_txnid_table_wr_data_valid;

    // start coding body
    // alloc stage stop signal
    assign alloc_stop_o =  enc_stop_i || txnid_table_full_i || wdat_table_full_i;
    
    // decode the L2 Req message for allocating a TxnID table entry
    assign tmp_arb_alloc_req_data_i = arb_alloc_req_dat_i;
    assign tmp_txnid_table_wr_data_valid = ({{(2**TXNID_TABLE_ADDR-1){1'b0}}, 1'b1} << txnid_table_index_i); // create an or mask for write valid to txnid table entry
    assign tmp_txnid_table_wr_data2.opcode_req = tmp_arb_alloc_req_data_i.opcode1; 
    assign tmp_txnid_table_wr_data2.tbl_id  = tmp_arb_alloc_req_data_i.tbl_id;
    assign tmp_txnid_table_wr_data2.bank_addr = tmp_arb_alloc_req_data_i.bank_addr;
    assign tmp_txnid_table_wr_data2.wdat_table_addr  = tmp_wdat_table_req_valid? wdat_table_index_i : {WDAT_TABLE_ADDR{1'b0}};
    assign tmp_txnid_table_wr_data2.addr = tmp_arb_alloc_req_data_i.addr; 
    assign tmp_txnid_table_wr_data2.compack = (tmp_arb_alloc_req_data_i.opcode1 == READSHARED || 
                                              tmp_arb_alloc_req_data_i.opcode1 == READUNIQUE ||
                                              tmp_arb_alloc_req_data_i.opcode1 == CLEANUNIQUE)? 1'b1:1'b0;
    assign tmp_txnid_table_wr_data2.excl_snoopme = tmp_arb_alloc_req_data_i.excl_snoopme;
    assign tmp_txnid_table_wr_data2.amo_size = arb_alloc_evict_amo_size_i;
    // ATOMICS_START to ATOMICS_END defines the range of ATOMIC opcode value
    assign tmp_wdat_table_req_valid =  tmp_arb_alloc_req_data_i.opcode1 == WRITEBACKFULL || 
                                       tmp_arb_alloc_req_data_i.opcode1 == WRITEUNIQUEPTL || 
                                       tmp_arb_alloc_req_data_i.opcode1 == WRITEUNIQUEFULL || 
                                       tmp_arb_alloc_req_data_i.opcode1 == WRITENOSNPPTL || 
                                       tmp_arb_alloc_req_data_i.opcode1 == WRITENOSNPFULL || 
                                       (tmp_arb_alloc_req_data_i.opcode1 >= ATOMICS_START && tmp_arb_alloc_req_data_i.opcode1 <= ATOMICS_END);
    //// to generate fake data for ATOMICS
    //logic tmp_wdat_at_req_valid; 
    //assign tmp_wdat_at_req_valid =  (tmp_arb_alloc_req_data_i.opcode1 >= ATOMICS_START && tmp_arb_alloc_req_data_i.opcode1 <= ATOMICS_END);
    //// Gen fakedata
    //always_ff@(posedge clk or negedge rst_n) begin
    //    if(!rst_n) begin
    //        tmp_fake_data <= {L2_DATA{1'b0}};
    //    end else begin
    //        if(arb_alloc_req_valid_i && tmp_wdat_at_req_valid && !enc_stop_i) begin
    //            tmp_fake_data <= tmp_fake_data + 1'b1;
    //        end else begin
    //            tmp_fake_data <= tmp_fake_data;
    //        end 
    //    end
    // end   

    // write to TxnID table
    assign txnid_table_wr_en_1_or_o = (arb_alloc_req_valid_i && !alloc_stop_o); // !enc_stop_i);
    assign txnid_table_wr_data_1_or_o = tmp_txnid_table_wr_data_valid;
    assign txnid_table_wr_en_2_o = (arb_alloc_req_valid_i && !alloc_stop_o); // !enc_stop_i);
    assign txnid_table_wr_data_2_o =  tmp_txnid_table_wr_data2;
    assign txnid_table_wr_addr_2_o = txnid_table_index_i                  ; 

    assign wdat_table_wr_en_1_or_o = (arb_alloc_req_valid_i && tmp_wdat_table_req_valid && !alloc_stop_o); // !enc_stop_i);
    assign wdat_table_wr_data_1_or_o = ({{(2**WDAT_TABLE_ADDR-1){1'b0}},1'b1} << wdat_table_index_i);
 
    assign wdat_table_wr_en_2_o   = (arb_alloc_req_valid_i && tmp_wdat_table_req_valid && !alloc_stop_o); // !enc_stop_i); 
    assign wdat_table_wr_addr_2_o = wdat_table_index_i;                                                 
    //assign wdat_table_wr_data_2_o = (arb_alloc_req_valid_i && tmp_wdat_at_req_valid)? tmp_fake_data : arb_alloc_evict_data_i; // tmp_fake_data for ATOMICS and real data for WRITEBACKFULL; 
    assign wdat_table_wr_data_2_o = arb_alloc_evict_data_i; // tmp_fake_data for ATOMICS and real data for WRITEBACKFULL; 

    // output to next stage
    //assign tgtid_o               = {TGTID_REQ{1'b1}};
    //assign srcid_o               = {SRCID_REQ{1'b0}};
    assign tgtid_o               = sam_target_id_i;
    assign srcid_o               = src_id;
    assign txnid_o               = {2'b0, txnid_table_index_i};                    
    assign opcode_o              = tmp_arb_alloc_req_data_i.opcode1;       
    assign addr_o                = tmp_arb_alloc_req_data_i.addr;          
    assign amo_size_o            = arb_alloc_evict_amo_size_i;              
    assign excl_snoopme_o        = tmp_arb_alloc_req_data_i.excl_snoopme;          
    assign req_metadata_valid_o  = arb_alloc_req_valid_i && !alloc_stop_o; 

     
endmodule
