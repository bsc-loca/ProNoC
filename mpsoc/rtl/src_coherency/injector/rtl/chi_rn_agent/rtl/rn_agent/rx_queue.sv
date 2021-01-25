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

module rx_queue #(
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

//the FIFO queue to buffer the incoming requests from NoC in order
logic [FIFO_WIDTH-1:0]     fifo_q   [2**FIFO_DEPTH-1:0];
logic unsigned [FIFO_DEPTH-1:0]     head;
logic unsigned [FIFO_DEPTH-1:0]     tail;
//this register counts how many places are occupied      
logic unsigned [FIFO_DEPTH-1:0]        fifo_global_ctr;
//fifo empty or full
logic empty, full;
// fifo push, allowing write into fifo
logic insert;
// fifo pop, allowing read from fifo
logic extract;
//reg for keeping the lcrdv signal for correct timing
logic lcrdv_reg;

logic [FIFO_WIDTH-1:0]   data_out_r;
logic                    valid_2nd;
logic [FIFO_WIDTH-1:0]   data_2nd;

/*--------------------------------------------------------*/
/*Start codind body*/
/*--------------------------------------------------------*/

//the following registers are used for
//controlling the insertion and the extraction
//from the queue
assign insert = din_valid & !full;
assign extract = !queue_stop & !empty; // & (head != tail);


//insert into FIFO
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<2**FIFO_DEPTH; i++) begin
            fifo_q[i] <= {FIFO_WIDTH{1'b0}};
        end
    end else begin
        if (insert) begin
            fifo_q[tail] <= data_in;
        end 
    end
end

//update head, tail
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        head <= {FIFO_DEPTH{1'b0}};
        tail <= {FIFO_DEPTH{1'b0}};
    end else begin
        if (insert & queue_stop) begin
            tail <= tail + 1'b1;
        end
        if (extract) begin
            head <= head + 1'b1;
        end
    end
end

//update the FIFO global counter
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_global_ctr <= {FIFO_DEPTH{1'b0}};
    end else begin
        if (insert && queue_stop && !extract) begin
            fifo_global_ctr <= fifo_global_ctr + 1'b1;
        end else if (!insert && extract) begin
            fifo_global_ctr <= fifo_global_ctr - 1'b1;
        end
    end
end 

// we assume that the transmitter hold 15 L-credits at the very beginning 
// meanwhile the receiver here does not have any L-credit, therefore 
// only when the receiver received a request (indicated by the insert and !queue_stop)
// or the next stage of the receiver consumes one request, the receiver gets 
// hold of one L-credit, and it immediately gives this credit to NoC transmitter.
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lcrdv_reg <= 1'b0;
    end else if(extract || (!extract && !queue_stop && insert)) begin
        lcrdv_reg <= 1'b1;
    end else begin 
        lcrdv_reg <= 1'b0;
    end
end

//assign the full, empty output signals
assign full = (fifo_global_ctr == ($unsigned(2**FIFO_DEPTH)-1'b1));
assign empty = (fifo_global_ctr == 1'b0);

//drive the register contents of lcrdv to the exit
assign lcrdv = lcrdv_reg;

//FIFO data output
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out_r <= {FIFO_WIDTH{1'b0}};
    // when there queue stop, the data is buffered inside fifo_q, therefore when we read/extract from fifo_q
   // in this case the time between data_in and out depends on how long is the queue stop signal valid
    end else if(extract) begin
        data_out_r <= fifo_q[head];
    // when there is no queue stop, the data should flow to the next stage in one cycle
    end else if(!extract && !queue_stop && insert) begin  
        data_out_r <= data_in;
    end else begin
        data_out_r <= data_out_r ;
    end 
end

// preserve the one valid data when receiving queue_stop 
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_2nd <= 1'b0;
        data_2nd <= {FIFO_WIDTH{1'b0}};
    end else begin
        if (queue_stop && lcrdv_reg) begin
             valid_2nd <= 1'b1  ;
             data_2nd  <=  data_out_r;
        end else if(!queue_stop) begin
             valid_2nd <= 1'b0 ;
             data_2nd  <= {FIFO_WIDTH{1'b0}};
        end else begin
             valid_2nd <= valid_2nd;
             data_2nd  <= data_2nd ;
        end
    end
end

assign data_out_valid = lcrdv_reg || valid_2nd;
assign data_out = lcrdv_reg ? data_out_r : data_2nd;

endmodule
