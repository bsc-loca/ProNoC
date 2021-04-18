
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
*   Title:          The CHI Requestor agent RXRSP to TXDAT arbiter stage
*
*   Description:    This stage is used to merge the data from decode stage in the  
*                   local pipeline, and similar data from the decode stage in the
*                   SNP pipeline to encode stage in the local pipeline
*
*                   It includes two 4-entry FIFO buffers for both incoming data, 
*                   and uses a round-robin policy to pick one from these two entries.
*                   The full signals of these two buffers will stall the corresponding
*                   Pipeline stages.
*                   
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rxrsp_p_arb 
    import chi_rn_params_pkg::*;
    #(
        parameter REQ_FLIT_SIZE,
        parameter DAT_FLIT_SIZE,
        parameter RSP_FLIT_SIZE,
        parameter SNP_FLIT_SIZE
    )
(
    // Clock and Reset_n
    input logic                              clk                    ,
    input logic                              rst_n                  ,
    // Stall signal from the next stage
    input logic                              tx_arb_stop_i          ,
    // Input Snoop data response
    input  logic                             snpp_rxrspp_datflitv_i ,
    input  logic [DAT_FLIT_SIZE-1:0]         snpp_rxrspp_datflit_i  ,
    output logic                             rxrspp_snpp_stall_o    ,  
    // Interface with previous pipeline stage 
    input  logic                             dec_arb_datflitv_i     ,
    input  logic [DAT_FLIT_SIZE-1:0]         dec_arb_datflit_i      ,
    // Output to next stage 
    output logic                             arb_tx_datflitv_o      ,
    output logic [DAT_FLIT_SIZE-1:0]         arb_tx_datflit_o       ,
    // Stop
    output arb_dec_stop_o 
);
    


    // logic definition 
    logic [DAT_FLIT_SIZE-1:0] tmp_local_p_datflit_o;
    logic                     fifo_dec_stop_o;
    logic                     tmp_local_p_pop;
    logic                     tmp_alien_p_pop;
    logic                     tmp_fifo_local_p_empty;
    logic                     tmp_fifo_alien_p_empty;
    logic                     tmp_fifo_local_p_af;
    logic [DAT_FLIT_SIZE-1:0] tmp_alien_p_datflit_o;

    // Start coding body*/
    // puch datflit from previous stage to local queue
    sync_ff_fifo 
    #(
        .DATA_W                ( DAT_FLIT_SIZE),
        .FIFO_DEPTH            ( 4            ),
        .AF_FLAG_LIM           ( 3            ),
        .AE_FLAG_LIM           ( 1            )
    ) fifo_localdat
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (dec_arb_datflitv_i          ),
        .pop_i                           (tmp_local_p_pop             ),
        .data_i                          (dec_arb_datflit_i           ),
        .data_o                          (tmp_local_p_datflit_o       ),
        .full_o                          (fifo_dec_stop_o             ),
        .empty_o                         (tmp_fifo_local_p_empty      ),
        .af_o                            (tmp_fifo_local_p_af         ),
        .ae_o                            (                            )
    );

    // push snoop data responses into the alien queue
    sync_ff_fifo 
    #(
        .DATA_W                ( DAT_FLIT_SIZE),
        .FIFO_DEPTH            ( 4            ),
        .AF_FLAG_LIM           ( 3            ),
        .AE_FLAG_LIM           ( 1            )
    ) fifo_aliensnoopdat
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (snpp_rxrspp_datflitv_i      ),
        .pop_i                           (tmp_alien_p_pop             ),
        .data_i                          (snpp_rxrspp_datflit_i       ),
        .data_o                          (tmp_alien_p_datflit_o       ),
        .full_o                          (rxrspp_snpp_stall_o         ),
        .empty_o                         (tmp_fifo_alien_p_empty      ),
        .af_o                            (                            ),
        .ae_o                            (                            )
    );
  
    // Snoop data response should take priority than local data response 
    localparam IDLE = 2'b00,
               S0   = 2'b01,
               S1   = 2'b10;
    logic [1:0] state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state) 
                IDLE: if((!tmp_fifo_local_p_empty || !tmp_fifo_alien_p_empty || tmp_fifo_local_p_af) && !tx_arb_stop_i) begin
                          state <= S0;
                      end else begin
                          state <= IDLE;
                      end
               // S0 reads alien queue
               S0:    if ((tmp_fifo_local_p_af || (!tmp_fifo_local_p_empty && tmp_fifo_alien_p_empty)) && !tx_arb_stop_i) begin state <= S1; end
               // S1 reads local queue
               S1:    if (!tmp_fifo_alien_p_empty && !tmp_fifo_local_p_af && !tx_arb_stop_i) begin state <= S0; end
            endcase
        end
    end

    assign tmp_local_p_pop = state == S1 && !tmp_fifo_local_p_empty && !tx_arb_stop_i;
    assign tmp_alien_p_pop = state == S0 && !tmp_fifo_alien_p_empty && !tx_arb_stop_i;
    assign arb_tx_datflitv_o = tmp_local_p_pop || tmp_alien_p_pop; 
    assign arb_tx_datflit_o  = tmp_alien_p_pop? tmp_alien_p_datflit_o : tmp_local_p_datflit_o;
    assign arb_dec_stop_o  = fifo_dec_stop_o ; 
 
endmodule
