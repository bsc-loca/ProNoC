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
*   Author:         Pedro Marcuello
*   Email:          pedro.marcuello@semidynamics.com
*   Date:           22/05/2018
*-------------------------------------------------------------------------------
*   Title:          Miss Table
*   Description:    Implements a fully associative table
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module miss_table #(
    parameter WIDTH = 3,
    parameter SIZE  = 8
    )
    (
    // generic
    input       clk,
    input       rst_n,
    
    // miss and wait signals
    input[38:0] tim_missaddr,
    input       tim_missvalid,
    input       tim_waitvalid,
    
    // fill-in signals
    input[4:0]  l2_fillptr,
    input       l2_fillvalid,

    input       tim_x_access,
    
    // outputs
    output[4:0] mt_ptr,
    output      mt_ptrvalid,
    output      mt_secmiss,
    output      mt_secm_byp,
    output      mt_full
);

logic [38:0] misstable [31:0];
logic [31:0] misstablevalid;

logic             mt_misswaitptrvalid;
logic [4:0]       mt_misswaitptr;

// first, detect whether the address is already in the table 

always_comb begin
    mt_misswaitptr      = 5'b0;
    mt_misswaitptrvalid = 1'b0;
    for (int i = 0; i < SIZE; i++) begin : gen_chk
        if ((tim_missvalid || tim_waitvalid) && (tim_missaddr == misstable[i]) && (misstablevalid[i])) begin
            mt_misswaitptr = i;
            mt_misswaitptrvalid = 1'b1;
            break;          
        end
    end
end

// and detect any possible bypass
wire mt_bypassdetected;

assign mt_bypassdetected = (tim_missvalid | tim_waitvalid) & l2_fillvalid & 
                           (tim_missaddr == misstable[l2_fillptr]) & misstablevalid[l2_fillptr];

// find the first entry empty
wire [4:0] mt_firstptr;
wire [7:0] mt_aux0, mt_aux1, mt_aux2, mt_aux3;

assign mt_aux3 = misstablevalid[31:24];
assign mt_aux2 = misstablevalid[23:16];
assign mt_aux1 = misstablevalid[15: 8];
assign mt_aux0 = misstablevalid[ 7: 0];

assign mt_firstptr[4] = ~&mt_aux3[7:0] | ~&mt_aux2[7:0];
assign mt_firstptr[3] = ~&mt_aux3[7:0] | (&mt_aux2[7:0] & ~&mt_aux1[7:0]);
wire [7:0] mt_validblock;

assign mt_validblock =  mt_aux3 & {8{~&mt_aux3[7:0]}} | (mt_aux2 & {8{&mt_aux3[7:0] & ~&mt_aux2[7:0]}})
                     | (mt_aux1 & {8{ &mt_aux3[7:0] & (&mt_aux2[7:0]) & (~&mt_aux1[7:0])}})
                     | (mt_aux0 & {8{ &mt_aux3[7:0] & (&mt_aux2[7:0]) & (&mt_aux1[7:0])}});

assign mt_firstptr[2] = ~&mt_validblock[7:4];
assign mt_firstptr[1] = ~&mt_validblock[7:6] | (&mt_validblock[5:4] & (~&mt_validblock[3:2]));
assign mt_firstptr[0] =  ~mt_validblock[7] | (~mt_validblock[5] & mt_validblock[6]) 
                      | (~mt_validblock[3] &   mt_validblock[6] & mt_validblock[4])
                      | (~mt_validblock[1] &   mt_validblock[6] & mt_validblock[4] & mt_validblock[2]);


// update the table accordingly
wire [1:0]       misstableaccess;
assign misstableaccess = {l2_fillvalid, tim_missvalid & ~mt_misswaitptrvalid & ~(&misstablevalid[SIZE-1:0])};
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        misstablevalid <= {{(32-SIZE){1'b1}},{SIZE{1'b0}}};
    end
    else begin
        case (misstableaccess)
            2'b11: begin
                if (mt_bypassdetected) begin
                    misstablevalid[l2_fillptr] <= 1'b0;
                end
                else begin
                    misstable[l2_fillptr]      <= tim_missaddr;
                end
                end
            2'b10: begin
                if (!(tim_x_access & mt_misswaitptrvalid & mt_bypassdetected))
                    misstablevalid[l2_fillptr] <= 1'b0;
                
                end
            2'b01: begin
                misstablevalid[mt_firstptr] <= 1'b1;
                misstable[mt_firstptr]      <= tim_missaddr;
                end
            2'b00:begin
                end
        endcase
    end
end

assign mt_ptrvalid = ( mt_misswaitptrvalid & ~mt_bypassdetected & tim_waitvalid) | 
                     (~mt_misswaitptrvalid & ~mt_bypassdetected & ~l2_fillvalid & ~&misstablevalid[SIZE-1:0] & tim_missvalid) |
                     (~mt_misswaitptrvalid & ~mt_bypassdetected &  l2_fillvalid & ~&misstablevalid[SIZE-1:0] & tim_missvalid) |
                     (tim_x_access & mt_misswaitptrvalid &  mt_bypassdetected); 
assign mt_ptr      = mt_misswaitptr & {5{ mt_misswaitptrvalid & ~mt_bypassdetected}} |
                     mt_firstptr    & {5{~mt_misswaitptrvalid & ~mt_bypassdetected & ~l2_fillvalid}} |
                     l2_fillptr     & {5{(~mt_misswaitptrvalid & ~mt_bypassdetected &  l2_fillvalid) |
                                         (tim_x_access & mt_misswaitptrvalid &  mt_bypassdetected)}};
assign mt_full     = &misstablevalid[SIZE-1:0];
assign mt_secmiss  = tim_x_access & mt_misswaitptrvalid & ~mt_bypassdetected;
assign mt_secm_byp = tim_x_access & mt_misswaitptrvalid &  mt_bypassdetected;
 
endmodule
