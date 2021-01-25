
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
*   Date:           25/02/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI Requestor agent 
*
*   Description:    This stage is used to merge the FILL data from two different pipelines
*                   the RXDAT and the RXRSP pipeline to the L2 FILL Queue.
*
*                   It includes two 4-entry FIFO buffers for both incoming data, 
*                   and uses a round-robin policy to pick one from these two entries.
*                   The full signals of these two buffers will stall the corresponding
*                   Pipeline stages.
*                   
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module fill_arb 
    import chi_rn_params_pkg::*;
    #(
        parameter L2_FILL_SIZE
    )
(
    //generic
    input  logic                        clk                             ,
    input  logic                        rst_n                           ,
    // Interface with FILL from RXRSP pipeline 
    input  logic                        rxrspp_fill_data_valid_i        ,
    input  logic [L2_FILL_SIZE-1:0]     rxrspp_fill_data_i              ,
    output logic                        rxrspp_fill_q_full_o            ,
    // Interface with FILL from RXDAT pipeline 
    input  logic                        rxdatp_fill_data_valid_i        ,
    input  logic [L2_FILL_SIZE-1:0]     rxdatp_fill_data_i              ,
    output logic                        rxdatp_fill_q_full_o            ,
    // Interface with FILL from Retry Logic 
    input  logic [L2_FILL_SIZE-1:0]     retry_fill_data_i               ,
    input  logic                        retry_fill_data_valid_i         ,
    output logic                        retry_fill_q_full_o             ,
    // Output data to next stage 
    // To Fill Queue From CHI
    output logic                        chi_l2_fill_q_push_o            ,
    output logic [L2_FILL_SIZE-1:0]     chi_l2_fill_q_data_o            ,
    input  logic                        chi_l2_fill_q_full_i             
);
    


    // logic definition 
    logic [L2_FILL_SIZE-1:0]         tmp_rxrspp_data_o;
    logic [L2_FILL_SIZE-1:0]         tmp_rxdatp_data_o;
    logic [L2_FILL_SIZE-1:0]         tmp_retry_data_o;
    logic                            tmp_rxrspp_pop ;
    logic                            tmp_rxdatp_pop ;
    logic                            tmp_retry_pop ;
    logic                            tmp_fifo_rxrspp_empty ;
    logic                            tmp_fifo_rxdatp_empty ;
    logic                            tmp_fifo_retry_empty ;
/*---------------------------------------------------------------------*/
/* Start coding body*/
/*---------------------------------------------------------------------*/

    sync_ff_fifo 
    #(
        .DATA_W                ( L2_FILL_SIZE),
        .FIFO_DEPTH            ( 4      ),
        .AF_FLAG_LIM           ( 3      ),
        .AE_FLAG_LIM           ( 1      )
    ) fifo_rxrspp_fill
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (rxrspp_fill_data_valid_i    ),
        .pop_i                           (tmp_rxrspp_pop              ),
        .data_i                          (rxrspp_fill_data_i          ),
        .data_o                          (tmp_rxrspp_data_o           ),
        .full_o                          (rxrspp_fill_q_full_o        ),
        .empty_o                         (tmp_fifo_rxrspp_empty       ),
        .af_o                            () ,
        .ae_o                            ()
    );


    sync_ff_fifo 
    #(
        .DATA_W                (L2_FILL_SIZE),
        .FIFO_DEPTH            ( 4     ),
        .AF_FLAG_LIM           ( 3     ),
        .AE_FLAG_LIM           ( 1     )
    ) fifo_rxdatp_fill
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (rxdatp_fill_data_valid_i    ),
        .pop_i                           (tmp_rxdatp_pop              ),
        .data_i                          (rxdatp_fill_data_i          ),
        .data_o                          (tmp_rxdatp_data_o           ),
        .full_o                          (rxdatp_fill_q_full_o        ),
        .empty_o                         (tmp_fifo_rxdatp_empty       ),
        .af_o                            () ,
        .ae_o                            ()
    );

    sync_ff_fifo 
    #(
        .DATA_W                (L2_FILL_SIZE),
        .FIFO_DEPTH            ( 4     ),
        .AF_FLAG_LIM           ( 3     ),
        .AE_FLAG_LIM           ( 1     )
    ) fifo_retry_fill
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (retry_fill_data_valid_i     ),
        .pop_i                           (tmp_retry_pop               ),
        .data_i                          (retry_fill_data_i           ),
        .data_o                          (tmp_retry_data_o            ),
        .full_o                          (retry_fill_q_full_o         ),
        .empty_o                         (tmp_fifo_retry_empty        ),
        .af_o                            () ,
        .ae_o                            ()
    );
  
    // Round-Robin FSM 
    localparam IDLE = 2'b00,
               S0   = 2'b01, // SO reads rxrspp fill queue
               S1   = 2'b10, // S1 reads rxdatp fill queue
               S2   = 2'b11; // S2 reads retry fill queue
    logic [1:0] state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state) 
                IDLE: if(!tmp_fifo_rxrspp_empty || !tmp_fifo_rxdatp_empty || !tmp_fifo_retry_empty) begin
                          state <= S0;
                      end else begin
                          state <= IDLE;
                      end
                S0:   if (!tmp_fifo_rxdatp_empty) begin state <= S1; 
                      end else if (!tmp_fifo_retry_empty) begin state <= S2; end
                S1:   if (!tmp_fifo_retry_empty) begin state <= S2; 
                      end else if (!tmp_fifo_rxrspp_empty) begin state <= S0; end
                S2:   if (!tmp_fifo_rxrspp_empty) begin state <= S0; 
                      end else if (!tmp_fifo_rxdatp_empty) begin state <= S1; end
            endcase
        end
    end

    assign tmp_rxrspp_pop = state == S0 && !tmp_fifo_rxrspp_empty && !chi_l2_fill_q_full_i;
    assign tmp_rxdatp_pop = state == S1 && !tmp_fifo_rxdatp_empty && !chi_l2_fill_q_full_i;
    assign tmp_retry_pop  = state == S2 && !tmp_fifo_retry_empty && !chi_l2_fill_q_full_i;

    // assign output
    assign chi_l2_fill_q_push_o = tmp_rxrspp_pop || tmp_rxdatp_pop || tmp_retry_pop; 
    assign chi_l2_fill_q_data_o = tmp_retry_pop? tmp_retry_data_o: tmp_rxdatp_pop? tmp_rxdatp_data_o : tmp_rxrspp_data_o;
 
endmodule
