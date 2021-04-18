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
*   Date:           10/09/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI Requestor agent SNP logic from SNP chanel to L2 Snoop queue
*
*   Description:    This module implements the rx stage of the CHI Requestor agent's
*                   incoming pipeline. 
*                   1) It receives the requests from the CHI SNP 
*                   chanel from the NOC. 
*                   2) For all the new requests, allocates a free entry in 
*                   the snoop table
*                   3) Send the necessary info to the L2_SNOOP Queue
*                   add a queue for the snoop for l2 and expose a pop interface
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module snp_p_chi_to_l2
    import chi_rn_params_pkg::*;
    #(
        parameter LOG_LCREDITS_NUM = 4,
        parameter NOC_INITS_CRED = 0,
        // parameter for flit structs and configurable field sizes
        parameter type chi_reqflit_pkt_t  = chi_reqflit_pkt_default_t, 
        parameter type chi_rspflit_pkt_t  = chi_rspflit_pkt_default_t,
        parameter type chi_datflit_pkt_t  = chi_datflit_pkt_default_t,
        parameter type chi_snpflit_pkt_t  = chi_snpflit_pkt_default_t,
        parameter type l2_snoop_req_pkt_t = l2_snoop_req_pkt_default_t,
        parameter REQ_FLIT_SIZE,
        parameter DAT_FLIT_SIZE,
        parameter RSP_FLIT_SIZE,
        parameter SNP_FLIT_SIZE,
        parameter L2_SNOOP_REQ_SIZE
    )
(
     //generic
    input logic                            clk                        ,
    input logic                            rst_n                      ,
    // chanel signals
    input logic                            noc_rx_snpflitpend         ,
    input logic [SNP_FLIT_SIZE-1:0]        noc_rx_snpflit             ,
    input logic                            noc_rx_snpflitv            ,
    output logic                           chi_noc_snplcrdv           ,
    // To Snoop Queue From CHI
    output  logic                          chi_l2_snp_q_push_o        ,
    output  logic [L2_SNOOP_REQ_SIZE -1:0] chi_l2_snp_q_data_o        ,
    input   logic                          chi_l2_snp_q_full_i        ,
    // input  logic                           chi_l2_snp_q_pop_i         ,
    // output logic [L2_SNOOP_REQ_SIZE -1:0]       chi_l2_snp_q_data_o        ,
    // output logic                           chi_l2_snp_q_empty_o       ,
    // Interface with Snoop table 
    input  logic                           snoop_table_full_i         ,
    input  logic [SNOOP_TABLE_ADDR-1:0]    snoop_table_index_i        ,
    output logic                           snoop_table_wr_en_1_or_o   ,
    output logic [2**SNOOP_TABLE_ADDR-1:0] snoop_table_wr_data_1_or_o ,
    output logic                           snoop_table_wr_en_2_o      ,
    output logic [SNOOP_TABLE_ADDR-1:0]    snoop_table_wr_addr_2_o    , 
    output logic [SNOOP_TABLE_DAT-1:0]     snoop_table_wr_data_2_o      
);


    // logic definition
    l2_snoop_req_pkt_t        tmp_snoop_req_pkt;
    chi_snpflit_pkt_t         tmp_chi_snpflit_pkt;
    snoop_table_pkt2_t        tmp_snoop_table_entry_pkt2;
    logic                     snpflitpend;
    logic                     noc_rx_snpflitv_valid ;
    logic [SNP_FLIT_SIZE-1:0] rx_dec_snpflit ;
    logic                     rx_dec_snpflit_valid;
    logic                     queue_stop;
    // NoC credits initialization
    enum logic [1:0] {RST, INIT, INIT_DONE} state_q, state_n;
    logic [LOG_LCREDITS_NUM-1:0] init_cnt_n, init_cnt_q;
    logic chi_noc_snplcrdv_rxqueue, chi_noc_snplcrdv_fsm;

    // start coding body
    // receive SNPFLIT    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            snpflitpend <= 1'b0;
            state_q     <= RST;
            init_cnt_q  <= {LOG_LCREDITS_NUM{1'b0}};
        end else begin
            snpflitpend <= noc_rx_snpflitpend;
            state_q     <= state_n;
            init_cnt_q  <= init_cnt_n;
        end
    end

    always_comb begin
      init_cnt_n       = init_cnt_q;
      state_n          = state_q;
      chi_noc_snplcrdv = 1'b0;
      chi_noc_snplcrdv_fsm = 1'b0;


      if (state_q == RST ) begin
        chi_noc_snplcrdv_fsm = 1'b0;
        state_n = INIT;
      end

      // send N credits after reset
      if (state_q == INIT && init_cnt_q < (2**LOG_LCREDITS_NUM)-1) begin
        chi_noc_snplcrdv_fsm = 1'b1;
        init_cnt_n           = init_cnt_q + 1;
        if (init_cnt_n == (2**LOG_LCREDITS_NUM)-1) begin
            state_n = INIT_DONE;
        end
      end

      // the muxing of snplcrdv only happens if the NOC_INITS_CRED is set
      // otherwise, statically assign from the rx_queue

      if (NOC_INITS_CRED) begin
        // mux credits from FSM init or from rx_queue
        if (state_q == INIT) begin
          chi_noc_snplcrdv = chi_noc_snplcrdv_fsm;
        end else begin
          chi_noc_snplcrdv = chi_noc_snplcrdv_rxqueue;
        end
      end else begin
        chi_noc_snplcrdv = chi_noc_snplcrdv_rxqueue;
      end

    end

    assign noc_rx_snpflitv_valid = snpflitpend && noc_rx_snpflitv;
    
    // integrate the request queue to the logic
    rx_queue_nobypass #(
        .FIFO_WIDTH  (SNP_FLIT_SIZE),
        .FIFO_DEPTH  (LOG_LCREDITS_NUM) 
        ) snp_rx_queue (
        .clk            (clk),
        .rst_n          (rst_n),
        .queue_stop     (queue_stop),
        .data_in        (noc_rx_snpflit),
        .din_valid      (noc_rx_snpflitv_valid),
        .data_out       (rx_dec_snpflit),
        .data_out_valid (rx_dec_snpflit_valid),
        .lcrdv          (chi_noc_snplcrdv_rxqueue)
    );

    //logic chi_l2_snp_q_full;
    assign queue_stop                          = snoop_table_full_i || chi_l2_snp_q_full_i;

    // Prepare data for snoop table and for snoop req to L2 Cache
    assign tmp_chi_snpflit_pkt                 = rx_dec_snpflit;
    assign tmp_snoop_req_pkt.rettosrc          = tmp_chi_snpflit_pkt.rettosrc;
    assign tmp_snoop_req_pkt.addr              = tmp_chi_snpflit_pkt.addr;
    assign tmp_snoop_req_pkt.opcode            = tmp_chi_snpflit_pkt.opcode;
    assign tmp_snoop_req_pkt.snoop_table_index = snoop_table_index_i;
   
    assign tmp_snoop_table_entry_pkt2.srcid    = tmp_chi_snpflit_pkt.srcid;
    assign tmp_snoop_table_entry_pkt2.txnid    = tmp_chi_snpflit_pkt.txnid;
    assign tmp_snoop_table_entry_pkt2.fwdnid   = tmp_chi_snpflit_pkt.fwdnid;
    assign tmp_snoop_table_entry_pkt2.fwdtxnid = tmp_chi_snpflit_pkt.fwdtxnid;  

    // SEND to L2_SNOOP queue
    assign chi_l2_snp_q_push_o                 = rx_dec_snpflit_valid;
    assign chi_l2_snp_q_data_o                 = tmp_snoop_req_pkt;

    // // start coding body
    // // push local rspflit to the local queue
    // sync_ff_fifo 
    // #(
    //     .DATA_W                ( L2_SNOOP_REQ_SIZE)    ,
    //     .FIFO_DEPTH            ( 4)     ,
    //     .AF_FLAG_LIM           ( 3)     ,
    //     .AE_FLAG_LIM           ( 1)
    // ) fifo_snp_2_l2
    // (
    //     .clk                             (clk                         ),
    //     .rst_n                           (rst_n                       ),
    //     .push_i                          (rx_dec_snpflit_valid        ),
    //     .pop_i                           (chi_l2_snp_q_pop_i          ),
    //     .data_i                          (tmp_snoop_req_pkt           ),
    //     .data_o                          (chi_l2_snp_q_data_o         ),
    //     .full_o                          (chi_l2_snp_q_full           ),
    //     .empty_o                         (chi_l2_snp_q_empty_o        ),
    //     .af_o                            () ,
    //     .ae_o                            ()
    // );

    // Write to SNOOP TABLE
    assign snoop_table_wr_en_1_or_o            = rx_dec_snpflit_valid;
    assign snoop_table_wr_data_1_or_o          = {{(2**SNOOP_TABLE_ADDR-1){1'b0}}, 1'b1} << snoop_table_index_i;
    assign snoop_table_wr_en_2_o               = rx_dec_snpflit_valid;
    assign snoop_table_wr_addr_2_o             = snoop_table_index_i;
    assign snoop_table_wr_data_2_o             = tmp_snoop_table_entry_pkt2;

endmodule
