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
*   Title:          The queue logic CHI agent RX stage
*
*   Description:    This module implements the queue logic of the CHI incoming 
*                   pipeline stage RX. This queue is used as a temporary memory
*                   for holding the incoming  requests from the NOC and forwarding
*                   them in FIFO order to the DECODE stage
*
*   Modification:   Adapt for own use
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rx_queue_nobypass #(
    parameter FIFO_WIDTH  = 32,
    parameter FIFO_DEPTH = 3
    )
(
   //generic
   input  logic                    clk,
   input  logic                    rst_n,
   //pipeline stop signal from the next stage
   input  logic                    queue_stop,
   //the input data
   input  logic [FIFO_WIDTH-1:0]   data_in,
   input  logic                    din_valid,
   //the output data
   output logic [FIFO_WIDTH-1:0]   data_out,
   //the lcrdv value needed for the data and request logic
   //that handle the data and request flits
   output logic                    lcrdv,
   output logic                    data_out_valid
);

//added by Alireza
wire fifo_rx_queue_pop_w,fifo_rx_queue_full_w,fifo_rx_queue_empty_w;


// push local rspflit to the local queue
sync_ff_fifo 
#(
    .DATA_W                ( FIFO_WIDTH)    ,
    .FIFO_DEPTH            ( 15)     ,
    .AF_FLAG_LIM           ( 14)     ,
    .AE_FLAG_LIM           ( 1)
) fifo_rx_queue
(
    .clk                             (clk                    ),
    .rst_n                           (rst_n                  ),
    .push_i                          (din_valid              ),
    .pop_i                           (fifo_rx_queue_pop_w    ),
    .data_i                          (data_in                ),
    .data_o                          (data_out               ),
    .full_o                          (fifo_rx_queue_full_w   ),
    .empty_o                         (fifo_rx_queue_empty_w  ),
    .af_o                            () ,
    .ae_o                            ()
);

assign fifo_rx_queue_pop_w = !fifo_rx_queue_empty_w && !queue_stop;

assign lcrdv = fifo_rx_queue_pop_w;

assign data_out_valid = fifo_rx_queue_pop_w;

endmodule
