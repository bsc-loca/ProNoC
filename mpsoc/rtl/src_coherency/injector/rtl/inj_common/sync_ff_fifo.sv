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
*   Author:         Jordi Cortina
*   Email:          jordi.cortina@semidynamics.com
*   Date:           15/11/2018
*-------------------------------------------------------------------------------
*   Title:          Sync FIFO
*   Description:    Synchronous DFF based FIFO
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module sync_ff_fifo
#(
    parameter DATA_W                = 32    ,
    parameter FIFO_DEPTH            = 8     ,
    parameter AF_FLAG_LIM           = 0     ,
    parameter AE_FLAG_LIM           = 0
)(
    input   logic                   clk     ,
    input   logic                   rst_n   ,
    input   logic                   push_i  ,
    input   logic                   pop_i   ,
    input   logic   [DATA_W-1:0]    data_i  ,
    output  logic   [DATA_W-1:0]    data_o  ,
    output  logic                   full_o  ,
    output  logic                   empty_o ,
    output  logic                   af_o    ,
    output  logic                   ae_o
);

    // Parameters
    /////////////////////////////////////
    localparam PTR_W        = $clog2(FIFO_DEPTH);
    localparam CTR_W        = $clog2(FIFO_DEPTH+1);


    // Logic Declaration 
    /////////////////////////////////////
    logic [DATA_W-1:0]      mem             [FIFO_DEPTH-1:0];
    logic [PTR_W-1:0]       rd_ptr, wr_ptr                  ;
    logic [CTR_W-1:0]       fifo_ctr                        ;

    logic                   push_data                       ;
    logic                   pop_data                        ;


    // Implementation
    /////////////////////////////////////

    assign push_data    = push_i & !full_o;
    assign pop_data     = pop_i  & !empty_o;
    
    // Memory write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<FIFO_DEPTH; i++) begin
                mem[i] <= {DATA_W{1'b0}};
            end
        end else begin
            if (push_data) begin
                mem[wr_ptr] <= data_i;
            end 
        end
    end

    // Update pointers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= {PTR_W{1'b0}};
            rd_ptr <= {PTR_W{1'b0}};
        end else begin
            // Write Pointer Update
            if (push_data) begin
                if (wr_ptr == FIFO_DEPTH-1) 
                    wr_ptr <= {PTR_W{1'b0}};
                else
                    wr_ptr <= wr_ptr + 1;
            end
            // Read Pointer Update
            if (pop_data) begin
                if (rd_ptr == FIFO_DEPTH-1)
                    rd_ptr <= {PTR_W{1'b0}};
                else
                    rd_ptr <= rd_ptr + 1;
            end
        end
    end

    // FIFO Counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_ctr <= {PTR_W{1'b0}};
        end else begin
            if (push_data & !pop_data) begin
                fifo_ctr <= fifo_ctr + 1;
            end else if (!push_data & pop_data) begin
                fifo_ctr <= fifo_ctr - 1;
            end
        end
    end
            
    // Output Data Mux
    assign data_o   = mem[rd_ptr];

    // Set Flags
    assign empty_o  = (fifo_ctr == '0           );
    assign full_o   = (fifo_ctr == FIFO_DEPTH   );

    assign af_o     = (AF_FLAG_LIM != 0) ? (fifo_ctr >= AF_FLAG_LIM) : 1'b0;
    assign ae_o     = (AE_FLAG_LIM != 0) ? (fifo_ctr <= AE_FLAG_LIM) : 1'b0;


endmodule : sync_ff_fifo
