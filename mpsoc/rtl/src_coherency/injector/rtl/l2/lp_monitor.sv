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
*   Date:           11/01/2019
*-------------------------------------------------------------------------------
*   Title:          LP Monitor
*   Description:    Tracks LDX/STX Operations avoiding synchronisation
*                   conflicts.
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module lp_monitor #(
    parameter                       ADDR_W      = 39,
                                    L1_REQ_W    = 48

)(
    input   logic                   clk             ,       
    input   logic                   rst_n           ,

    input   logic [ADDR_W-1:0]      s2_addr_i       ,
    input   logic                   s2_ldx_i        ,
    input   logic                   s2_stx_i        ,
    input   logic                   s2_fill_i       ,
    input   logic                   s2_snp_i        ,

    input   logic                   stx_req_ack_i   ,   // Dedicated interface to
    output  logic                   stx_req_val_o   ,   // issue a Read Unique after
    output  logic [L1_REQ_W-1:0]    stx_req_data_o  ,   // a SNP has invalidated the
                                                        // line.                    
    input   logic [1:0]             s2_l2_st_i      ,
    input   logic                   fill_stx_i      ,
    
    output  logic                   s3_stx_ok_o

);

    // Parameters
    /////////////////////////////////////

    localparam MON_W = ADDR_W + 2;   // Two extra bits to track validity and line filled

    // Monitor register field indexes
    // [VALID BIT][FILLED BIT][ADDR]
    localparam F = MON_W-2;
    localparam V = MON_W-1;

    // FSM
    localparam IDLE     = 0,
               STX      = 1,
               FILL     = 2,
               SND_STX  = 3,
               STOK     = 4;

    localparam FSM_W = 5;


    // Logic Declaration 
    /////////////////////////////////////

    logic [MON_W-1:0]   monitor_r   ;

    logic               valid       ;

    logic [FSM_W-1:0]   fsm_ps      ,
                        fsm_ns      ; 

    logic [1:0]         vf          ;
    



    // Implementation
    /////////////////////////////////////

    assign valid = ((s2_addr_i == monitor_r[ADDR_W-1:0]) & monitor_r[V]);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            monitor_r <= {MON_W{1'b0}};
        end else begin
            unique case (1'b1)
                // s2_ldx_i                :   begin
                //                                 if (s2_l2_st_i[1]) begin    // If line is E or M
                //                                     monitor_r[V]            <= 1'b1;
                //                                     monitor_r[F]            <= 1'b1;
                //                                 end else begin              // Line is either I or S
                //                                     monitor_r[V]            <= 1'b1;
                //                                     monitor_r[F]            <= 1'b0;
                //                                 end
                //                                 monitor_r[ADDR_W-1:0]   <= s2_addr_i;
                //                             end

                // Two LDX in a row bug fix @jcortina:
                s2_ldx_i                :   begin
                                                if (~|s2_l2_st_i) begin     // Line is I
                                                    monitor_r[V]            <= 1'b1;
                                                    monitor_r[F]            <= 1'b0;
                                                end else begin              // If line is in E, M or S State
                                                    monitor_r[V]            <= 1'b1;
                                                    monitor_r[F]            <= 1'b1;
                                                end
                                                monitor_r[ADDR_W-1:0]   <= s2_addr_i;
                                            end

                // &{s2_stx_i, ~|vf}       :   begin
                //                                 monitor_r[V]    <= 1'b1;
                //                                 monitor_r[F]    <= 1'b0;
                //                             end

                &{s2_fill_i, valid}     :   begin
                                                monitor_r[V]    <= 1'b1;
                                                monitor_r[F]    <= 1'b1;
                                            end

                &{s2_snp_i, valid}      :   begin
                                                monitor_r[V]    <= 1'b0;
                                                monitor_r[F]    <= 1'b0;
                                            end

                &{s2_fill_i, fill_stx_i, ~valid}   :   begin
                                                 monitor_r[V]    <= 1'b1;
                                                 monitor_r[F]    <= 1'b1;
                                            end

                fsm_ps[SND_STX]         :   begin
                                                monitor_r[V]    <= 1'b1;
                                                monitor_r[F]    <= 1'b0;
                                            end
                        
                fsm_ps[STOK]            :   begin
                                                monitor_r[V]    <= 1'b1;
                                                monitor_r[F]    <= 1'b1;
                                            end

                default                 :                              ;
            endcase
        end
    end



    // Monitor FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fsm_ps          <= {FSM_W{1'b0}};
            fsm_ps[IDLE]    <= 1'b1;
        end else begin
            fsm_ps          <= fsm_ns;
        end
    end

    // FSM Comb logic
    always_comb begin
        fsm_ns = {FSM_W{1'b0}};
        unique case (1'b1)
            fsm_ps[IDLE]    :   begin
                                    // Only if in Exlusive or Modified, we return an stx_ok
                                    // otherwise, we need to wait for the line to come back in exclusive
                                    if ((s2_stx_i && s2_l2_st_i[1]) || (fill_stx_i && s2_fill_i))  
                                    //if ((s2_stx_i && |s2_l2_st_i) || (fill_stx_i && s2_fill_i))  
                                                                fsm_ns[STX]     = 1'b1;
                                    else                        fsm_ns[IDLE]    = 1'b1;
                                end

            fsm_ps[STX]     :   begin
                                            if (vf == 2'b11)    fsm_ns[STOK]    = 1'b1;
                                    else                        fsm_ns[SND_STX] = 1'b1;
                                end

            fsm_ps[FILL]    :   begin
                                            if ((s2_fill_i && fill_stx_i) || valid) begin
                                                if (valid && !s2_snp_i)      fsm_ns[STOK]    = 1'b1;
                                                else            fsm_ns[SND_STX] = 1'b1;
                                            end else begin
                                                                fsm_ns[FILL]    = 1'b1;
                                            end
                                end

            fsm_ps[SND_STX] :   begin
                                            if (stx_req_ack_i)  fsm_ns[FILL]    = 1'b1;
                                            else                fsm_ns[SND_STX] = 1'b1;
                                end

            fsm_ps[STOK]    :                                   fsm_ns[IDLE]    = 1'b1;

        endcase                                                                 
    end

    assign vf           = {monitor_r[V], monitor_r[F]};
    assign s3_stx_ok_o  = fsm_ps[STOK];

    // SoreX Request Bus
    assign stx_req_val_o    = fsm_ps[SND_STX];
    assign stx_req_data_o   = {6'b0,monitor_r[ADDR_W-1:0],l2_pkg::L1_SX};


endmodule
