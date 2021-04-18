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
*   Date:           05/03/2019
*-------------------------------------------------------------------------------
*   Title:          TXREQ Pipeline - stage arb
*   Description:    This block picks up one request from the two input queues from L2
*                   There are two main cases
*                   If the Evict queue has a high occupancy or if Evit is not empty 
*                   and REQ queue is empty, arb reads one from the Evict queue;
*                   Otherwise it reads from the Req queue.
*                   It also adapts the format of Evict queue to the format of the L2 Req Queue. 
*                   
*                   There are three types of requests that share the usage of L2_REQ_SIZE queue:
*                   Normal requests such as READSHARED, READUNIQUE, WRITEBACKFULL, ATOMICS;
*                   SNOOP dataless and data responses.
*                   Normal requests are send out through TXREQ chanel to NoC; while the 
*                   SNOOP responses are send out through TXRSP and TXDAT/WDAT chanels.
*                   Therefore we separate snoop requests and send them to Snoop pipeline. 
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module txreq_p_arb 
    import chi_rn_params_pkg::*;
#(
    parameter type l2_evict_pkt_t = l2_evict_pkt_default_t,
    parameter type l2_data_pkt_t  = l2_data_pkt_default_t,
    parameter type l2_req_pkt_t   = l2_req_pkt_default_t,
    parameter ARB_WITH_QUEUE,
    parameter L2_REQ_SIZE,
    parameter SAM_TGT_ADDR_W,
    parameter CHI_EVICT_HAS_RSP_CH
)(
   
clk                         ,
   rst_n                       ,
   
   alloc_stop                  ,
   
   
   l2_chi_q_pop_o              ,
   l2_chi_q_empty_i            ,
   l2_chi_q_data_i             ,
   
   l2_chi_evt_q_pop_o          ,
   l2_chi_evt_q_data_i         ,
   l2_chi_evt_q_highoccupancy_i,
   l2_chi_evt_q_empty_i        ,
   
   l2_chi_arb_q_pop_o           ,
   l2_chi_arb_q_empty_i         ,
   l2_chi_arb_q_data_i          ,
   
   arb_alloc_req_valid_o       ,
   arb_alloc_req_data_o        ,
   arb_alloc_evict_data_o      ,
   arb_alloc_evict_amo_size_o  ,
   
   l2_snp_data_valid_o         ,
   l2_snp_data_stall_i         ,
   
   sam_target_address_o

 
);    


// Clock and Reset
    input  logic                            clk                         ;
    input  logic                            rst_n                       ;
    // stop signal from the next stage
    input  logic                            alloc_stop                  ;
    // Interface with L2
    // NoC Response Queue
    output logic                            l2_chi_q_pop_o              ;
    input  logic                            l2_chi_q_empty_i            ;
    input  logic [L2_REQ_SIZE-1:0]          l2_chi_q_data_i             ;
    // Evict Queue
    output logic                            l2_chi_evt_q_pop_o          ;
    input  l2_evict_pkt_t                   l2_chi_evt_q_data_i         ;
    input  logic                            l2_chi_evt_q_highoccupancy_i;
    input  logic                            l2_chi_evt_q_empty_i        ;
    // Arbitration queue
    output  logic                           l2_chi_arb_q_pop_o           ;
    input   logic                           l2_chi_arb_q_empty_i         ;
    input   logic [ARB_QUEUE_W-1:0]         l2_chi_arb_q_data_i          ;
    // Interface with alloc stage
    output logic                            arb_alloc_req_valid_o       ;
    output l2_req_pkt_t                     arb_alloc_req_data_o        ;
    output l2_data_pkt_t                    arb_alloc_evict_data_o      ;
    output logic [1:0]                      arb_alloc_evict_amo_size_o  ;
    // Interface with SNP logic
    output logic                            l2_snp_data_valid_o         ;
    input  logic                            l2_snp_data_stall_i         ;
    // SAM Interface
    output logic [SAM_TGT_ADDR_W-1:0]       sam_target_address_o;






 

    // logic definition
    logic                              l2_chi_q_pop_o_r;
    logic                              l2_chi_evt_q_pop_o_r;

    logic                              arb_alloc_req_valid_1st;
    logic                              arb_alloc_req_valid_2nd;
    l2_req_pkt_t                       tmp_arb_alloc_req_data;

    logic                              l2_chi_q_pop_tmp_r;
    logic                              l2_chi_evt_q_pop_tmp_r;

    logic                              l2_chi_q_pop_o_r_delay;
    logic                              l2_chi_evt_q_pop_o_r_delay;
    logic [L2_REQ_SIZE-1:0]            arb_alloc_req_data_1st ;

    logic                              l2_chi_evt_q_pop_o_valid_r;
    logic                              arb_is_evandrq_r, arb_is_evandrq_n;

    l2_req_pkt_t                       l2_chi_q_data;

    // FSM to read from L2_REQ_SIZE and L2_Evict queue
    localparam IDLE = 2'b00,
               S0   = 2'b01,
               S1   = 2'b10;
    logic [1:0] state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            arb_is_evandrq_r <= 1'b0;
        end else begin
            case (state) 
                IDLE: if((l2_chi_evt_q_highoccupancy_i || !l2_chi_q_empty_i || !l2_chi_evt_q_empty_i) && !alloc_stop && !l2_snp_data_stall_i ) begin
                          state <= S0;
                      end else begin
                          state <= IDLE;
                      end
               // S0 state: read L2_REQUEST Queue
               S0:    if ((l2_chi_evt_q_highoccupancy_i || (l2_chi_q_empty_i && !l2_chi_evt_q_empty_i)) && !alloc_stop && !l2_snp_data_stall_i) begin state <= S1; end
               // S1 state: read L2_EVICT Queue
               S1:    if ((!l2_chi_q_empty_i && !l2_chi_evt_q_highoccupancy_i) && !alloc_stop && !l2_snp_data_stall_i) begin state <= S0; end
            endcase
            arb_is_evandrq_r <= arb_is_evandrq_n;
        end
    end

    always_comb begin : proc_arb_is_evandrq
        arb_is_evandrq_n = arb_is_evandrq_r;
        if (!l2_chi_arb_q_empty_i) begin
            // flag to 1 when we have an eviction combined with request and eviction is going out
            if (l2_chi_arb_q_data_i == ARB_QUEUE_IS_EVANDRQ && l2_chi_evt_q_pop_o_r) begin
                arb_is_evandrq_n = 1'b1;
            end
            // overwrite with 0 on the chi request pop
            if (l2_chi_q_pop_o_r) begin
                arb_is_evandrq_n = 1'b0;
            end
        end
    end

    generate
        if (ARB_WITH_QUEUE) begin : arb_with_queue
            // arbitration queue has to be popped on both req/evict unless it's a EVANDRQ
            assign l2_chi_arb_q_pop_o = l2_chi_q_pop_o_r || (l2_chi_evt_q_pop_o_r && l2_chi_arb_q_data_i == ARB_QUEUE_IS_EVC);
            // pop either req or evict queue depending on the value in the arbitration queue
            assign l2_chi_q_pop_o_r     = ((~l2_chi_arb_q_empty_i && l2_chi_arb_q_data_i == ARB_QUEUE_IS_REQ) || arb_is_evandrq_r) && (!l2_chi_q_empty_i && !l2_chi_evt_q_highoccupancy_i) && !alloc_stop && !l2_snp_data_stall_i;
            assign l2_chi_evt_q_pop_o_r = (l2_chi_arb_q_data_i == ARB_QUEUE_IS_EVC || ((~l2_chi_arb_q_empty_i && l2_chi_arb_q_data_i == ARB_QUEUE_IS_EVANDRQ) && ~arb_is_evandrq_r)) && (l2_chi_evt_q_highoccupancy_i || (!l2_chi_evt_q_empty_i)) && !alloc_stop && !l2_snp_data_stall_i;
        end else begin : arb_with_pingpong
            assign l2_chi_q_pop_o_r = state == S0 && (!l2_chi_q_empty_i && !l2_chi_evt_q_highoccupancy_i) && !alloc_stop && !l2_snp_data_stall_i;
            assign l2_chi_evt_q_pop_o_r = state == S1 && (l2_chi_evt_q_highoccupancy_i || (l2_chi_q_empty_i && !l2_chi_evt_q_empty_i)) && !alloc_stop && !l2_snp_data_stall_i;
        end
    endgenerate

    assign l2_chi_evt_q_pop_o_valid_r = l2_chi_evt_q_pop_o_r & (l2_chi_evt_q_data_i.opcode!=NOP);
    assign arb_alloc_req_valid_1st  = (l2_chi_q_pop_o_r || l2_chi_evt_q_pop_o_valid_r);

    assign l2_chi_q_data = l2_chi_q_data_i;

    // resp1 indicates the state of the current cache line
    // for COPYBACKDATA, it is always with RESP_COMPDATA_UD_PD to pass dirty
    // for NOCOPYBACKDATA, it is always with RESP_COMPDATA_I 
    rsp_ch_t evc_rsp_ch; 
    noc_resp_t evc_resp; 
    generate
        if (CHI_EVICT_HAS_RSP_CH) begin
            assign evc_rsp_ch = l2_chi_evt_q_data_i.rsp_ch; 
            assign evc_resp   = l2_chi_evt_q_data_i.resp  ; 
        end else begin
            assign evc_rsp_ch = REQT; 
            assign evc_resp = (l2_chi_evt_q_data_i.opcode==WRITEBACKFULL)? ST_UCD_PD:ST_I; 
        end
    endgenerate
    always_comb begin 
        unique if (l2_chi_q_pop_o_r) begin
            tmp_arb_alloc_req_data = l2_chi_q_data;
            sam_target_address_o   = l2_chi_q_data.addr;
        end else if (l2_chi_evt_q_pop_o_valid_r) begin
            tmp_arb_alloc_req_data.rsp_ch1 = evc_rsp_ch; 
            tmp_arb_alloc_req_data.resp1 = evc_resp;
            tmp_arb_alloc_req_data.opcode1 = l2_chi_evt_q_data_i.opcode; 
            tmp_arb_alloc_req_data.resperr1 = 2'b00 ; 
            tmp_arb_alloc_req_data.rsp_ch2 = NORP; 
            tmp_arb_alloc_req_data.opcode2 = l2_chi_evt_q_data_i.opcode; 
            tmp_arb_alloc_req_data.resp2 = ST_I ; 
            tmp_arb_alloc_req_data.resperr2 = 2'b00 ; 
            tmp_arb_alloc_req_data.tbl_id = l2_chi_evt_q_data_i.tbl_id; 
            tmp_arb_alloc_req_data.bank_addr = l2_chi_evt_q_data_i.bank_addr;
            tmp_arb_alloc_req_data.addr = l2_chi_evt_q_data_i.addr;
            tmp_arb_alloc_req_data.excl_snoopme = l2_chi_evt_q_data_i.excl_snoopme;
            sam_target_address_o = l2_chi_evt_q_data_i.addr;
        end else begin 
            tmp_arb_alloc_req_data = {L2_REQ_SIZE{1'b0}};
            sam_target_address_o   = {SAM_TGT_ADDR_W{1'b0}};
        end
     end 
     assign arb_alloc_req_data_1st = tmp_arb_alloc_req_data;


    // SNP responses
    // when the l2 pkt rsp1 does not equal to REQT, means that it is a snp response, therefore we send the 
    // pkt to SNP response logic
    assign l2_snp_data_valid_o = arb_alloc_req_valid_1st && tmp_arb_alloc_req_data.rsp_ch1 != REQT;
 
    // assign the output 
    assign l2_chi_q_pop_o = l2_chi_q_pop_o_r; 
    assign l2_chi_evt_q_pop_o = l2_chi_evt_q_pop_o_r;
    assign arb_alloc_req_valid_o = arb_alloc_req_valid_1st && tmp_arb_alloc_req_data.rsp_ch1 == REQT;
    assign arb_alloc_req_data_o =   arb_alloc_req_data_1st;  
    assign arb_alloc_evict_data_o = {l2_chi_evt_q_data_i.data, l2_chi_evt_q_data_i.dmask};  
    assign arb_alloc_evict_amo_size_o = l2_chi_evt_q_data_i.atomic_size;  
    
endmodule
