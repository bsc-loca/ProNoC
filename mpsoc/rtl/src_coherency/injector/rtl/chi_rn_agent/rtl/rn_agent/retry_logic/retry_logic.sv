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
*   Date:           12/03/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI Requestor agent Retry and PcrdGrant logic 
*
*   Description:    A new PcrdGrant table is introduced, it has 32 entries. 
*                   Since we only has 64 txnid, therefore we consider with 32 
*                   outstanding Retry table, it should never become full.
*                   Each entry includes: PcrdType, SrcID, First_txnid, 
*                   Cnt_Retryack, Cnt_PcrdGrant.
*
*                   Whenever a Retryack is received, we compare with PcrdGrant 
*                   table by using (PcrdType, SrcID).
*                   If miss: allocate a new entry in the PcrdGrant table and 
*                   saves the pair; Cnt_RetryAck = 1; PcrdGrant_table.First_txnid = txnid;
*                   else if hit && !cnt_PcrdGrant: Cnt_RetryAck++; 
*                   Txnid_table[PcrdGrant_table.First_txnid].Next_txnid = txnid;
*                   else if hit && cnt_PcrdGrant: Cnt_PcrdGrant--; read Txnid table 
*                   and resend the request with Allowretry set with 0.
*
*                   Whenever a PcrdGrant is received, we compare with PcrdGrant 
*                   table by using (PcrdType, SrcID). 
*                   If miss: allocate a new entry in the PcrdGrant table and saves 
*                   the pair; Cnt_PcrdGrant = 1; else if hit && !cnt_Retryack: cnt_PcrdGrant++;
*                   else if hit && cnt_Retryack  -> Read Txnid_table[PcrdGrant_table.First_txnid], 
*                   and resend request with Allowretry set to 0; 
*                   update PcrdGrant_table.First_txnid = Txnid_table[PcrdGrant.First_txnid].Next_txnid; 
*                   cnt_Retryack--.
*
*                   For the PcrdGrant table, its valid_bitmap = Cnt_RetryAck || Cnt_PcrdGrant.
*                   
*                   Add PcrdReturn to deal with the CLEANUNIQUE and SNPINVALID hazard situation. 
*                   When the pair of retryack and pcrdgrant corresponds to CLEANUNIQUE, 
*                   instead of resend the request, we send PcrdReturn and also notifies L2 Cache about it.
*                   To add PcrdReturn, we will add three main modifications:
*                   1) when case_pcrdgrant_3 is valid, read txnid table and check the opcode_req;
*                      if it is a CLEANUNIQUE, send PcrdReturn, otherwise resend request to
*                      the TXREQ pipeline.
*                   2) when case_pcrdgrant_3 is valid, do the same thing
*                   3) in both cases when it is a CLEANUNIQUE, send a invalidation to txnid table entry
*                   4) in both cases when it is a CLEANUNIQUE, notify L2 of this PcrdReturn request by using 
*                      L2 FILL queue with dataless fill
*
*                   Add size information for Atomic operations in the txnid, therefore when a retry operation is 
*                   an atomic, we need to send the size information from retry to txreq pipeline
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module retry_logic
    import chi_rn_params_pkg::*;
    #(
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
    parameter L2_DATA_SIZE,
    parameter SRCID_REQ,
    parameter TGTID_REQ,
    parameter ADDR_REQ,
    parameter TXNID_TABLE_DAT,
    parameter TXNID_TABLE_DAT3,
    parameter PCRDGRANT_TABLE_DAT2,
    parameter type txnid_table_pkt_t = txnid_table_pkt_default_t
    )
(
    // Clock and reset
    input  logic                                 clk                                 ,
    input  logic                                 rst_n                               ,
    // input stall
    input  logic                                 retry_stall_i                       ,
    // Interface with RXRSP pipeline to receive the RetryAck and PcrdGrant
    input  logic [RSP_FLIT_SIZE-1:0]             rxrspp_retry_rspflit_i              , 
    input  logic                                 rxrspp_retry_rspflitv_i             ,
    output logic                                 retry_rxrspp_stall_o                ,
    // Interface with TxnID table
    // read port               
    output logic                                 txnid_table_rd_en_o                 ,
    output logic [TXNID_TABLE_ADDR-1:0]          txnid_table_rd_addr_o               ,
    input  logic [TXNID_TABLE_DAT-1:0]           txnid_table_rd_data_i               ,
    input  logic                                 txnid_table_rd_data_valid_i         ,
    // write port              
    // add invalidation for PCRDRETURN 
    output logic                                 txnid_table_wr_en_1_and_o           ,
    output logic [2**TXNID_TABLE_ADDR-1:0]       txnid_table_wr_data_1_and_o         ,  
    output logic                                 txnid_table_wr_en_3_o               ,
    output logic [TXNID_TABLE_ADDR-1:0]          txnid_table_wr_addr_3_o             , 
    output logic [TXNID_TABLE_DAT3-1:0]          txnid_table_wr_data_3_o             ,
    // Interface with TXREQ pipeline to resend the Request with credit
    output logic [TGTID_REQ-1:0]                 retry_tgtid_o                       ,
    output logic [SRCID_REQ-1:0]                 retry_srcid_o                       ,
    output logic [TXNID_REQ-1:0]                 retry_txnid_o                       ,
    output logic [OPCODE_REQ-1:0]                retry_opcode_o                      ,
    output logic [ADDR_REQ-1:0]                  retry_addr_o                        ,
    output logic [1:0]                           retry_amo_size_o                    ,
    // Addr pcrdtype for PCRDRETURN
    output logic [PCRDTYPE_REQ-1:0]              retry_pcrdtype_o                    ,
    output logic                                 retry_excl_snoopme_o                ,
    output logic                                 retry_req_metadata_valid_o          ,
    // Output to FILL 
    output l2_fill_pkt_t                         retry_fill_data_o                   ,
    output logic                                 retry_fill_data_valid_o             ,
    input  logic                                 retry_fill_q_full_i                 ,
    input logic [SRCID_REQ-1:0]                  src_id
);


    // logic definition
    chi_rspflit_pkt_t tmp_rspflit,
                      tmp_rspflit_1st; 
    pcrdgrant_table_hit_pkt_t tmp_hit_data_i;
    txnid_table_pkt_t     tmp_txnid_table_rd_data_i;

    logic case_retryack_1;
    logic case_retryack_2;
    logic case_retryack_3;
    logic case_pcrdgrant_1;
    logic case_pcrdgrant_2;
    logic case_pcrdgrant_3;

    // Interface with PcrdGrant table
    logic [PCRDGRANT_TABLE_ADDR-1:0]     tmp_pcrdgrant_table_free_entry_i;
    logic                                tmp_pcrdgrant_table_full_i; 
    // write port: field2-pcrdtype+srcid, field3-firsttxnid, field4-cnt_retryack, field5-cnt_pcrdgrant
    logic                                tmp_pcrdgrant_table_wr_en_2_o;
    logic [PCRDGRANT_TABLE_ADDR-1:0]     tmp_pcrdgrant_table_wr_addr_2_o; 
    logic [PCRDGRANT_TABLE_DAT2-1:0]     tmp_pcrdgrant_table_wr_data_2_o;
    logic                                tmp_pcrdgrant_table_wr_en_3_o;
    logic [PCRDGRANT_TABLE_ADDR-1:0]     tmp_pcrdgrant_table_wr_addr_3_o; 
    logic [PCRDGRANT_TABLE_DAT3-1:0]     tmp_pcrdgrant_table_wr_data_3_o;
    logic                                tmp_pcrdgrant_table_wr_en_4_o;
    logic [PCRDGRANT_TABLE_ADDR-1:0]     tmp_pcrdgrant_table_wr_addr_4_o; 
    logic [PCRDGRANT_TABLE_DAT4-1:0]     tmp_pcrdgrant_table_wr_data_4_o;
    logic                                tmp_pcrdgrant_table_wr_en_5_o;
    logic [PCRDGRANT_TABLE_ADDR-1:0]     tmp_pcrdgrant_table_wr_addr_5_o; 
    logic [PCRDGRANT_TABLE_DAT5-1:0]     tmp_pcrdgrant_table_wr_data_5_o;
    // compare port
    logic [PCRDGRANT_TABLE_DAT2-1:0]     tmp_pcrdgrant_table_comp_data_o;
    logic                                tmp_pcrdgrant_table_comp_data_valid_o;
    logic [HIT_DAT-1:0]                  tmp_pcrdgrant_table_comp_hit_data_i;
    logic [PCRDGRANT_TABLE_ADDR-1:0]     tmp_pcrdgrant_table_comp_hit_addr_i;
    logic                                tmp_pcrdgrant_table_comp_hit_i;
    logic                                tmp_pcrdgrant_table_comp_valid_i;
   
    logic [TXNID_RSP-1:0]                tmp_txnid;
    logic                                tmp_is_cleanunique;
    logic                                retry_stop_2nd; 

    // start coding body
  
    /*---------------------------------------------------------------------------------*/
    // stage one: assign the packet and compare 
    /*---------------------------------------------------------------------------------*/ 
    // compare, compare operation takes one cycle
    assign tmp_rspflit_1st = rxrspp_retry_rspflit_i;
    assign tmp_pcrdgrant_table_comp_data_o       = {tmp_rspflit_1st.pcrdtype, tmp_rspflit_1st.srcid};
    assign tmp_pcrdgrant_table_comp_data_valid_o = rxrspp_retry_rspflitv_i && !retry_stop_2nd;

    //flop between stage one and stage two
    always_ff @(posedge clk) begin
        if(!rst_n) begin
            tmp_rspflit <= {RSP_FLIT_SIZE{1'b0}};
        end else if (!retry_stop_2nd) begin
            tmp_rspflit <= rxrspp_retry_rspflit_i;
        end
    end
    assign retry_rxrspp_stall_o  = retry_stop_2nd; 
    /*---------------------------------------------------------------------------------*/
    // stage two: compare result is ready
    // depending on comparison results, we have six cases, they are exclusive with each other
    // case_retryack_1:  retryack and miss
    // case_retryack_2:  retryack, hit, and cnt_pcrdgrant is zero
    // case_retryack_3:  retryack, hit, and cnt_pcrdgrant is not zero
    // case_pcrdgrant_1: pcrdgrant and miss
    // case_pcrdgrant_2: pcrdgrant, hit, and cnt_retryack is zero
    // case_pcrdgrant_3: pcrdgrant, hit, and cnt_retryack is not zero
    /*---------------------------------------------------------------------------------*/ 
    assign tmp_hit_data_i = tmp_pcrdgrant_table_comp_hit_data_i;
    assign tmp_txnid_table_rd_data_i = txnid_table_rd_data_i;

    assign case_retryack_1 = tmp_pcrdgrant_table_comp_valid_i && !tmp_pcrdgrant_table_comp_hit_i && tmp_rspflit.opcode == RETRYACK && !retry_stop_2nd;
    assign case_retryack_2 = tmp_pcrdgrant_table_comp_valid_i && tmp_pcrdgrant_table_comp_hit_i && tmp_rspflit.opcode == RETRYACK && tmp_hit_data_i.cnt_pcrdgrant == 0 && !retry_stop_2nd;
    assign case_retryack_3 = tmp_pcrdgrant_table_comp_valid_i && tmp_pcrdgrant_table_comp_hit_i && tmp_rspflit.opcode == RETRYACK && tmp_hit_data_i.cnt_pcrdgrant != 0 && !retry_stop_2nd;
    assign case_pcrdgrant_1 = tmp_pcrdgrant_table_comp_valid_i && !tmp_pcrdgrant_table_comp_hit_i && tmp_rspflit.opcode == PCRDGRANT && !retry_stop_2nd;
    assign case_pcrdgrant_2 = tmp_pcrdgrant_table_comp_valid_i && tmp_pcrdgrant_table_comp_hit_i && tmp_rspflit.opcode == PCRDGRANT && tmp_hit_data_i.cnt_retryack == 0 && !retry_stop_2nd;
    assign case_pcrdgrant_3 = tmp_pcrdgrant_table_comp_valid_i && tmp_pcrdgrant_table_comp_hit_i && tmp_rspflit.opcode == PCRDGRANT && tmp_hit_data_i.cnt_retryack != 0 && !retry_stop_2nd;


    // if miss, allocate a new entry and save the pair of PcrdType and SrcID as tag in the new entry
    // write port field 2
    assign tmp_pcrdgrant_table_wr_en_2_o         = case_retryack_1 || case_pcrdgrant_1;
    assign tmp_pcrdgrant_table_wr_addr_2_o       = tmp_pcrdgrant_table_free_entry_i; 
    assign tmp_pcrdgrant_table_wr_data_2_o       = {tmp_rspflit.pcrdtype, tmp_rspflit.srcid};

    // write port field 3
    // if case_retryack_1 or case_pcrdgrant_3 are valid, update first_txnid field in the pcrdgrant table
    // if case_retryack_1: save the first_txnid in the pcrdgrant table
    // if case_pcrdgrant_3: update pcrdgrant table first_txnid field with the next_txnid saved in the txnid table entry 
    assign tmp_pcrdgrant_table_wr_en_3_o         = case_retryack_1 || (case_pcrdgrant_3 && txnid_table_rd_data_valid_i); 
    assign tmp_pcrdgrant_table_wr_addr_3_o       = case_retryack_1? tmp_pcrdgrant_table_free_entry_i : tmp_pcrdgrant_table_comp_hit_addr_i; 
    assign tmp_pcrdgrant_table_wr_data_3_o       = case_retryack_1? tmp_rspflit.txnid: tmp_txnid_table_rd_data_i.next_txnid;

    // write port field 4
    // if case_retryack_1 or case_retryack_2 or case_pcrdgrant_3 are valid, update cnt_retryack in the pcrdgrant table
    // if case_retryack_1: intialize cnt_retryack = 1
    // if case_retryack_2: cnt_retryack++
    // if case_pcrdgrant_3: cnt_retryack-- 
    assign tmp_pcrdgrant_table_wr_en_4_o        = case_retryack_1 || case_retryack_2 || case_pcrdgrant_3; 
    assign tmp_pcrdgrant_table_wr_addr_4_o      = case_retryack_1? tmp_pcrdgrant_table_free_entry_i: tmp_pcrdgrant_table_comp_hit_addr_i; 
    assign tmp_pcrdgrant_table_wr_data_4_o      = case_retryack_1? 5'h1: (case_retryack_2? (tmp_hit_data_i.cnt_retryack + 5'h1) : (tmp_hit_data_i.cnt_retryack - 5'h1));

    // write port field 5
    // if case_pcrdgrant_1 or case_pcrdgrant_2 or case_retryack_3 are valid, update cnt_pcrdgrant in the pcrdgrant table
    // if case_pcrdgrant_1: intialize cnt_pcrdgrant = 1
    assign tmp_pcrdgrant_table_wr_en_5_o        = case_pcrdgrant_1 || case_pcrdgrant_2 || case_retryack_3; 
    assign tmp_pcrdgrant_table_wr_addr_5_o      = case_pcrdgrant_1? tmp_pcrdgrant_table_free_entry_i: tmp_pcrdgrant_table_comp_hit_addr_i; 
    assign tmp_pcrdgrant_table_wr_data_5_o      = case_pcrdgrant_1? 5'h1 :(case_pcrdgrant_2? (tmp_hit_data_i.cnt_pcrdgrant + 5'h1): (tmp_hit_data_i.cnt_pcrdgrant - 5'h1));
               
    // interact with txnid table
    // read txnid table
    // if case_retryack_3 or case_pcrdgrant_3 are valid, read 
    assign txnid_table_rd_en_o              = case_retryack_3 || case_pcrdgrant_3; 
    assign tmp_txnid                        = case_retryack_3? tmp_rspflit.txnid: tmp_hit_data_i.first_txnid;
    assign txnid_table_rd_addr_o            = tmp_txnid[TXNID_TABLE_ADDR-1:0]; 
    // check the opcode_req
    assign tmp_is_cleanunique               = (tmp_txnid_table_rd_data_i.mem2.opcode_req == CLEANUNIQUE) && txnid_table_rd_data_valid_i; 

    // write txnid table 
    // Txnid_table[PcrdGrant_table.First_txnid].next_txnid = txnid;
    assign txnid_table_wr_en_3_o            = case_retryack_2; 
    assign txnid_table_wr_addr_3_o          = tmp_hit_data_i.first_txnid[TXNID_TABLE_ADDR-1:0]; 
    assign txnid_table_wr_data_3_o          = tmp_rspflit.txnid;

    // if send PcrdReturn, invalid the txnid table entry
    assign txnid_table_wr_en_1_and_o        = tmp_is_cleanunique && (case_retryack_3 || case_pcrdgrant_3);
    assign txnid_table_wr_data_1_and_o      = ~({{(2**TXNID_TABLE_ADDR-1){1'b0}}, 1'b1} << tmp_txnid);  
                     
    // when case_retryack_3 or case_pcrdgrant_3 are valid, resend request
    // if tmp_txnid_table_rd_data_i.opcode_req == CLEANUNIQUE, send PcrdReturn
    // else resend the request
    assign retry_tgtid_o                    = tmp_rspflit.srcid;
    assign retry_srcid_o                    = src_id;// Added by Alireza {SRCID_REQ{1'b0}};
    assign retry_txnid_o                    = tmp_is_cleanunique? {TXNID_REQ{1'b0}} : (case_retryack_3? tmp_rspflit.txnid : tmp_hit_data_i.first_txnid);
    assign retry_opcode_o                   = tmp_is_cleanunique? PCRDRETURN: tmp_txnid_table_rd_data_i.mem2.opcode_req;
    assign retry_addr_o                     = tmp_is_cleanunique? {ADDR_REQ{1'b0}} :  tmp_txnid_table_rd_data_i.mem2.addr;
    assign retry_amo_size_o                 = tmp_txnid_table_rd_data_i.mem2.amo_size;
    assign retry_pcrdtype_o                 = tmp_rspflit.pcrdtype; 
    assign retry_excl_snoopme_o             = 1'b0;
    assign retry_req_metadata_valid_o       = (case_retryack_3 || case_pcrdgrant_3) && txnid_table_rd_data_valid_i;

    // if send PcrdReturn, also send to L2 FILL
    //assign retry_fill_data_o              = {1'b1, 2'b00, tmp_txnid_table_rd_data_i[TBL_BANK_ID_OFFSET-1:TXNID_TABLE_WDAT_OFFSET], 2'b11, {L2_DATA{1'b0}}};
    assign retry_fill_data_o              = {1'b1, 2'b00, tmp_txnid_table_rd_data_i.mem2.tbl_id, tmp_txnid_table_rd_data_i.mem2.bank_addr, 2'b11, {L2_DATA_SIZE{1'b0}}};
    assign retry_fill_data_valid_o        = tmp_is_cleanunique && (case_retryack_3 || case_pcrdgrant_3);

    // second stage stop 
    assign retry_stop_2nd                   = retry_stall_i || tmp_pcrdgrant_table_full_i || retry_fill_q_full_i ; 

    // initialize pcrdgrant mem
    pcrdgrant_mem #(
        .PCRDGRANT_TABLE_DAT2(PCRDGRANT_TABLE_DAT2)
        ) pcrdgrant_table_inst 
    (
        .clk                               (clk                                   ),
        .rst_n                             (rst_n                                 ),
        // write port
        .wr_en_2_i                         (tmp_pcrdgrant_table_wr_en_2_o         ),  
        .wr_addr_2_i                       (tmp_pcrdgrant_table_wr_addr_2_o       ),  
        .wr_data_2_i                       (tmp_pcrdgrant_table_wr_data_2_o       ),
        .wr_en_3_i                         (tmp_pcrdgrant_table_wr_en_3_o         ),
        .wr_addr_3_i                       (tmp_pcrdgrant_table_wr_addr_3_o       ),  
        .wr_data_3_i                       (tmp_pcrdgrant_table_wr_data_3_o       ),
        .wr_en_4_i                         (tmp_pcrdgrant_table_wr_en_4_o         ),
        .wr_addr_4_i                       (tmp_pcrdgrant_table_wr_addr_4_o       ),  
        .wr_data_4_i                       (tmp_pcrdgrant_table_wr_data_4_o       ),
        .wr_en_5_i                         (tmp_pcrdgrant_table_wr_en_5_o         ),
        .wr_addr_5_i                       (tmp_pcrdgrant_table_wr_addr_5_o       ),  
        .wr_data_5_i                       (tmp_pcrdgrant_table_wr_data_5_o       ),
        // compare port
        .comp_data_i                       (tmp_pcrdgrant_table_comp_data_o       ), 
        .comp_data_valid_i                 (tmp_pcrdgrant_table_comp_data_valid_o ),
        .comp_hit_data_o                   (tmp_pcrdgrant_table_comp_hit_data_i   ),
        .comp_hit_addr_o                   (tmp_pcrdgrant_table_comp_hit_addr_i   ),
        .comp_hit_o                        (tmp_pcrdgrant_table_comp_hit_i        ),
        .comp_valid_o                      (tmp_pcrdgrant_table_comp_valid_i      ),
        .free_entry_o                      (tmp_pcrdgrant_table_free_entry_i      ),
        .full_o                            (tmp_pcrdgrant_table_full_i            )  
    );


endmodule : retry_logic
