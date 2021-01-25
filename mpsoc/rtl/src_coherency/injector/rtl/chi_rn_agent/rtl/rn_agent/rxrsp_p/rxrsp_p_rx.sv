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
*   Author:         Vasilis Dimitsas
*   Email:          vasilis.dimitsas@semidynamics.com
*   Date:           01/02/2019
*   Author:         Xubin Tan
*   Email:          xubin.tan@semidynamics.com
*   Date:           14/02/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI Requestor agent RXRSP to TXDAT Pipeline stage rx
*
*   Description:    This module implements the rx stage of the CHI Requestor agent's
*                   incoming pipeline. It receives the requests from the CHI RXRSP 
*                   channel from the NOC, places them
*                   in the corresponding queues and forwards them to the next 
*                   stage (DECODE)
*   Attention:      Check if I have used 16 or 15 for LCredits
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rxrsp_p_rx
    import chi_rn_params_pkg::*;
    #(
    parameter LOG_LCREDITS_NUM = 4,
    parameter NOC_INITS_CRED = 0,
    // parameter for flit structs and configurable field sizes
    parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
    parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t, 
    parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
    parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
    parameter REQ_FLIT_SIZE,
    parameter DAT_FLIT_SIZE,
    parameter RSP_FLIT_SIZE,
    parameter SNP_FLIT_SIZE
    )
(
    //generic
   input logic                          clk                  ,
   input logic                          rst_n                ,
   //stop signals that stall the incoming pipeline
   input logic                          dec_rx_stop          ,
   input logic                          retry_stall_i        ,
   // channel signals
   input logic                          noc_rx_rspflitpend   ,
   input logic [RSP_FLIT_SIZE-1:0]      noc_rx_rspflit       ,
   input logic                          noc_rx_rspflitv      ,
   output logic                         chi_noc_rsplcrdv     ,
   // output to next stage
   output logic [RSP_FLIT_SIZE-1:0]     rx_dec_rspflit       ,
   output logic                         rx_dec_rspflit_valid ,
   // output to retry logic
   output logic                         retry_rspflit_valid 
);

// logic definition
chi_rspflit_pkt_t         tmp_rspflit;
logic                     rspflitpend;
logic                     noc_rx_rspflitv_valid ; 
logic [RSP_FLIT_SIZE-1:0] tmp_rx_dec_rspflit;
logic                     tmp_rx_dec_rspflit_valid;
// NoC credits initialization
enum logic [1:0] {RST, INIT, INIT_DONE} state_q, state_n;
logic [LOG_LCREDITS_NUM-1:0] init_cnt_n, init_cnt_q;
logic chi_noc_rsplcrdv_rxqueue, chi_noc_rsplcrdv_fsm;

// start coding body
assign tmp_rspflit = tmp_rx_dec_rspflit;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rspflitpend <= 0;
      state_q     <= RST;
      init_cnt_q  <= {LOG_LCREDITS_NUM{1'b0}};
    end else begin
      rspflitpend <= noc_rx_rspflitpend; 
      state_q     <= state_n;
      init_cnt_q  <= init_cnt_n;
    end
end

always_comb begin
  init_cnt_n       = init_cnt_q;
  state_n          = state_q;
  chi_noc_rsplcrdv = 1'b0;
  chi_noc_rsplcrdv_fsm = 1'b0;


  if (state_q == RST ) begin
    chi_noc_rsplcrdv_fsm = 1'b0;
    state_n = INIT;
  end

  // send N credits after reset
  if (state_q == INIT && init_cnt_q < (2**LOG_LCREDITS_NUM)-1) begin
    chi_noc_rsplcrdv_fsm = 1'b1;
    init_cnt_n           = init_cnt_q + 1;
    if (init_cnt_n == (2**LOG_LCREDITS_NUM)-1) begin
        state_n = INIT_DONE;
    end
  end

  // the muxing of rsplcrdv only happens if the NOC_INITS_CRED is set
  // otherwise, statically assign from the rx_queue

  if (NOC_INITS_CRED) begin
    // mux credits from FSM init or from rx_queue
    if (state_q == INIT) begin
      chi_noc_rsplcrdv = chi_noc_rsplcrdv_fsm;
    end else begin
      chi_noc_rsplcrdv = chi_noc_rsplcrdv_rxqueue;
    end
  end else begin
    chi_noc_rsplcrdv = chi_noc_rsplcrdv_rxqueue;
  end

end

assign noc_rx_rspflitv_valid = rspflitpend && noc_rx_rspflitv;

// integrate the request queue to the logic
rx_queue_nobypass #(
    .FIFO_WIDTH  (RSP_FLIT_SIZE),
    .FIFO_DEPTH  (LOG_LCREDITS_NUM) 
    ) rsp_rx_queue (
    .clk            (clk),
    .rst_n          (rst_n),
    .queue_stop     (dec_rx_stop || retry_stall_i),
    .data_in        (noc_rx_rspflit),
    .din_valid      (noc_rx_rspflitv_valid),
    .data_out       (tmp_rx_dec_rspflit),
    .data_out_valid (tmp_rx_dec_rspflit_valid),
    .lcrdv          (chi_noc_rsplcrdv_rxqueue)
);

// assign output
assign rx_dec_rspflit = tmp_rx_dec_rspflit;

// split the rsp responses into two different modules
// RETRYACK and PCRDGRAT rspflit will go to the retry logic
assign retry_rspflit_valid = (tmp_rspflit.opcode == RETRYACK || tmp_rspflit.opcode == PCRDGRANT) && tmp_rx_dec_rspflit_valid;
// Other responses will go to the next stage in this pipeline
assign rx_dec_rspflit_valid = (tmp_rspflit.opcode != RETRYACK && tmp_rspflit.opcode != PCRDGRANT) && tmp_rx_dec_rspflit_valid; 

endmodule
