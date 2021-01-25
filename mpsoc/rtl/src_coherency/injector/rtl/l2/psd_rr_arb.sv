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
*   Date:           25/01/2019
*-------------------------------------------------------------------------------
*   Title:          Pseudo Round Robin Arbiter
*   Description:
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module psd_rr_arb #(
    parameter DEPTH = 4
)(
    input   logic                   clk     ,
    input   logic                   rst_n   ,

    input   logic                   enable_i,
    input   logic   [DEPTH-1:0]     valid_i ,
    output  logic   [DEPTH-1:0]     sel_o
);


    // Parameters
    /////////////////////////////////////
    localparam DEPTH_LOG = $clog2(DEPTH);


    // Logic Declaration 
    /////////////////////////////////////
    logic [DEPTH-1:0]       sel;
    logic [DEPTH-1:0]       mask;
    logic                   clr;
    logic [DEPTH_LOG-1:0]   last;
    logic [DEPTH-1:0]       last_match;


    // Implementation
    /////////////////////////////////////

    // Priority Logic
    always_comb begin
        sel = {DEPTH{1'b0}};
        for (int i=0; i<DEPTH; i++) begin
            if (valid_i[i] && !mask[i]) begin
                sel[i] = 1'b1;
                break;
            end
        end
    end

    // Generate mask flops
    genvar j;
    generate

        for (j=0; j<DEPTH; j++) begin
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    mask[j] <= 1'b0;
                end else begin
                    if (clr) begin
                        mask[j] <= 1'b0;
                    end else if (enable_i && sel[j]) begin    
                        mask[j] <= 1'b1;
                    end
                end
            end

        assign last_match[j] = ((j == last) && sel[j]);

        end
    endgenerate

    assign clr = |last_match;

    // Last active valid lane
    always_comb begin
        last = {DEPTH_LOG{1'b0}};
        for (int i=DEPTH-1; i>=0; i--) begin
            if (valid_i[i]) begin
                last = i;
                break;
            end
        end
    end

    // Output assign
    assign sel_o = sel & {DEPTH{enable_i}};


endmodule : psd_rr_arb
