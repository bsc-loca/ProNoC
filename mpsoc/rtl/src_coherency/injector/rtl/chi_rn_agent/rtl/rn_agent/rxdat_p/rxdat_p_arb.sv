
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
*   Title:          The CHI Requestor agent RXDAT to TXRSP arbiter stage
*
*   Description:    This stage is used to merge the data from decode stage in the  
*                   local pipeline, and similar data from the decode stage in the
*                   RXRSP pipeline to encode stage in the local pipeline
*
*                   It includes two 4-entry FIFO buffers for both incoming data, 
*                   and uses a round-robin policy to pick one from these two entries.
*                   The full signals of these two buffers will stall the corresponding
*                   Pipeline stages.
*                   
*                   Add Snoop response messages to the arbiter
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rxdat_p_arb 
    import chi_rn_params_pkg::*;
    #(
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
    // Generic
    input logic                              clk                             ,
    input logic                              rst_n                           ,
    // Stall signal from the next stage
    input logic                              tx_arb_stop_i                   ,
    // Input CmpAck signal from RXRSP pipeline
    input  logic [RSP_FLIT_SIZE-1:0]         rxrspp_rxdatp_rspflit_i         ,        
    input  logic                             rxrspp_rxdatp_rspflitv_i        ,  
    output logic                             rxdatp_rxrspp_cmpack_stall_o    ,  
    // Snoop dataless responses from Snoop pipeline 
    input  logic [RSP_FLIT_SIZE-1:0]         snpp_rxdatp_rspflit_i           ,        
    input  logic                             snpp_rxdatp_rspflitv_i          ,
    output logic                             rxdatp_snpp_stall_o             ,
    // Local input data from previous stage 
    input  logic [RSP_FLIT_SIZE-1:0]         rspflit_i                       ,            
    input  logic                             rspflitv_i                      ,
    // Output data to next stage 
    output logic [RSP_FLIT_SIZE-1:0]         rspflit_o                       ,
    output logic                             rspflit_valid_o                 ,
    // Stop
    output arb_dec_stop_o 
);
    
    // logic definition 
    chi_rspflit_pkt_t         tmp_local_p_rspflit;
    logic [RSP_FLIT_SIZE-1:0] tmp_local_p_rspflit_w;
    logic [RSP_FLIT_SIZE-1:0] tmp_local_p_rspflit_o;
    logic                     fifo_dec_stop_o;
    logic                     tmp_local_p_pop;
    logic                     tmp_alien_p_pop;
    logic                     tmp_alien2_p_pop;
    logic                     tmp_fifo_local_p_empty;
    logic                     tmp_fifo_alien_p_empty;
    logic                     tmp_fifo_alien2_p_empty;
    logic [RSP_FLIT_SIZE-1:0] tmp_alien_p_rspflit_o;
    logic [RSP_FLIT_SIZE-1:0] tmp_alien2_p_rspflit_o;

    // start coding body
    // push local rspflit to the local queue
    sync_ff_fifo 
    #(
        .DATA_W                ( RSP_FLIT_SIZE)    ,
        .FIFO_DEPTH            ( 4)     ,
        .AF_FLAG_LIM           ( 3)     ,
        .AE_FLAG_LIM           ( 1)
    ) fifo_localcmpack
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (rspflitv_i                  ),
        .pop_i                           (tmp_local_p_pop             ),
        .data_i                          (rspflit_i                   ),
        .data_o                          (tmp_local_p_rspflit_o       ),
        .full_o                          (fifo_dec_stop_o             ),
        .empty_o                         (tmp_fifo_local_p_empty      ),
        .af_o                            () ,
        .ae_o                            ()
    );

    // push rspflit from RXRSP pipeline to the alien queue
    sync_ff_fifo 
    #(
        .DATA_W                ( RSP_FLIT_SIZE)    ,
        .FIFO_DEPTH            ( 4)     ,
        .AF_FLAG_LIM           ( 3)     ,
        .AE_FLAG_LIM           ( 1)
    ) fifo_aliencmpack
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (rxrspp_rxdatp_rspflitv_i    ),
        .pop_i                           (tmp_alien_p_pop             ),
        .data_i                          (rxrspp_rxdatp_rspflit_i     ),
        .data_o                          (tmp_alien_p_rspflit_o       ),
        .full_o                          (rxdatp_rxrspp_cmpack_stall_o),
        .empty_o                         (tmp_fifo_alien_p_empty      ),
        .af_o                            () ,
        .ae_o                            ()
    );

    // push rspflit from Snoop pipeline to the alien2 queue
    sync_ff_fifo 
    #(
        .DATA_W                ( RSP_FLIT_SIZE)    ,
        .FIFO_DEPTH            ( 4)     ,
        .AF_FLAG_LIM           ( 3)     ,
        .AE_FLAG_LIM           ( 1)
    ) fifo_alien2snoop
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (snpp_rxdatp_rspflitv_i      ),
        .pop_i                           (tmp_alien2_p_pop            ),
        .data_i                          (snpp_rxdatp_rspflit_i       ),
        .data_o                          (tmp_alien2_p_rspflit_o      ),
        .full_o                          (rxdatp_snpp_stall_o         ),
        .empty_o                         (tmp_fifo_alien2_p_empty     ),
        .af_o                            () ,
        .ae_o                            ()
    );
  
    // Round-Robin FSM 
    localparam IDLE = 2'b00,
               S0   = 2'b01,  // S0 reads local fifo
               S1   = 2'b10,  // S1 reads alien fifo
               S2   = 2'b11;  // S2 read alien2 fifo
    logic [1:0] state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state) 
                IDLE: if((!tmp_fifo_local_p_empty || !tmp_fifo_alien_p_empty || !tmp_fifo_alien2_p_empty) && !tx_arb_stop_i) begin
                          state <= S0;
                      end else begin
                          state <= IDLE;
                      end
                // SO read local queue
                S0: if (!tmp_fifo_alien_p_empty && !tx_arb_stop_i) begin state <= S1;
                    end else if (!tmp_fifo_alien2_p_empty && !tx_arb_stop_i) begin state <= S2; end  
                // S1 read alien1 queue
                S1: if (!tmp_fifo_alien2_p_empty && !tx_arb_stop_i) begin state <= S2; 
                    end else if (!tmp_fifo_local_p_empty && !tx_arb_stop_i) begin state <= S0; end 
                // S2 read alien2 queue
                S2: if (!tmp_fifo_local_p_empty && !tx_arb_stop_i) begin state <= S0; 
                    end else if (!tmp_fifo_alien_p_empty && !tx_arb_stop_i) begin state <= S1; end
            endcase 
        end
    end

    assign tmp_local_p_pop  = state == S0 &&!tmp_fifo_local_p_empty && !tx_arb_stop_i;
    assign tmp_alien_p_pop  = state == S1 &&!tmp_fifo_alien_p_empty && !tx_arb_stop_i;
    assign tmp_alien2_p_pop = state == S2 &&!tmp_fifo_alien2_p_empty && !tx_arb_stop_i;

    // assign output
    assign rspflit_valid_o = tmp_local_p_pop || tmp_alien_p_pop || tmp_alien2_p_pop; 
    assign rspflit_o       = tmp_alien2_p_pop? tmp_alien2_p_rspflit_o : tmp_alien_p_pop? tmp_alien_p_rspflit_o : tmp_local_p_rspflit_o;
    assign arb_dec_stop_o  = fifo_dec_stop_o ; 
 
endmodule
