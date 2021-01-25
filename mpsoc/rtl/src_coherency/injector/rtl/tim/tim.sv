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
*   Title:          Trace Injector Manager (TIM)
*   Description:    FSM to feed the injector L2 with the requests
*                   from a trace converted by the wrapper. It emulates the
*                   behavior of a 1st level cache and create the events for
*                   the L2.
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module tim (
    // Generic
    input        clk,
    input        rst_n,
    // from wrapper
    input[63:0]  wrap_req,
    input        wrap_reqvalid,
    // from l2
    input[5:0]   l2_fillptr,
    input        l2_fillvalid,
    input        l2_stxdone,
    input        l2_reqqnocredits,
    
    // to wrapper
    output       tim_strobereq,
    // to l2
    output       tim_reqvalid,
    output[47:0] tim_req //must change for atomics
);

import tim_pkg::*;


wire[2:0]  timw_reqop;
wire       timw_reqldst;
wire       timw_reqx;
wire[38:0] timw_addr;

//decoder signals

wire tim_iswaitfor;
wire tim_iswait;
wire tim_isstx;
wire tim_ismiss;
wire tim_isevict;
wire tim_isldx;

assign timw_reqop   = wrap_req[2:0];
assign timw_reqldst = wrap_req[3];
assign timw_reqx    = wrap_req[4] & ~wrap_req[2] & ~wrap_req[1];
assign timw_addr    = {7'b0,wrap_req[39:8]};       //wrap_req[46:8];

//decoder
assign tim_iswaitfor = (timw_reqop == 3'b100) & wrap_reqvalid;
assign tim_iswait    = (timw_reqop == 3'b101) & wrap_reqvalid;
assign tim_isstx     = ({timw_reqop, timw_reqldst, timw_reqx} == 5'b00011) & wrap_reqvalid;
assign tim_isldx     = ({timw_reqop, timw_reqldst, timw_reqx} == 5'b00001) & wrap_reqvalid;
assign tim_ismiss    = (timw_reqop[2:1] == 2'b00) & wrap_reqvalid;
assign tim_isevict   = (timw_reqop == 3'b010) & wrap_reqvalid;

//miss table
wire mt_datafull, mt_instfull;
wire mt_ptrvaliddata, mt_ptrvalidinst,mt_ptrsecmissdata,mt_secm_byp_ldx;
wire[4:0] mt_ptrdata, mt_ptrinst;

reg [1:0]   tim_fsmstate; 
reg tim_special_ldx;
reg [5:0] tim_ptr;

miss_table #(
    .WIDTH(WIDTHDATAMISSES), 
    .SIZE(DATAMISSES)
    ) misstabledata (
    .clk            (clk),
    .rst_n          (rst_n),
    .tim_missaddr   (timw_addr),
    .tim_missvalid  (tim_ismiss & ~timw_reqop[0] & ~|tim_fsmstate),
    .tim_waitvalid  (tim_iswaitfor & ~|tim_fsmstate),
    .l2_fillptr     (l2_fillptr[4:0]),
    .l2_fillvalid   (~l2_fillptr[5] & l2_fillvalid & ~(tim_special_ldx & (l2_fillptr == tim_ptr))),
    .tim_x_access   (tim_ismiss & wrap_req[4] & ~tim_isstx),
    
    .mt_ptr         (mt_ptrdata),
    .mt_ptrvalid    (mt_ptrvaliddata),
    .mt_secmiss     (mt_ptrsecmissdata),
    .mt_secm_byp    (mt_secm_byp_ldx),
    .mt_full        (mt_datafull)
);

miss_table #(
    .WIDTH(WIDTHINSTMISSES), 
    .SIZE(INSTMISSES)
    ) misstableinstr (
    .clk            (clk),
    .rst_n          (rst_n),
    .tim_missaddr   (timw_addr),
    .tim_missvalid  (tim_ismiss & timw_reqop[0] & ~|tim_fsmstate),
    .tim_waitvalid  (tim_iswaitfor & ~|tim_fsmstate),
    .l2_fillptr     (l2_fillptr[4:0]),
    .l2_fillvalid   (l2_fillptr[5] & l2_fillvalid),
    .tim_x_access   (1'b0),
    
    .mt_ptr         (mt_ptrinst),
    .mt_ptrvalid    (mt_ptrvalidinst),
    .mt_secmiss     (),
    .mt_secm_byp    (),
    .mt_full        (mt_instfull)
);


//seguential part
reg [15:0] tim_counter;
reg tim_stx;
reg tim_ctr0;
reg tim_started;
reg [38:0] timw_addr_old;
wire [5:0] tim_finalptr;
wire tim_ptrvalid;

assign tim_finalptr = {1'b1,mt_ptrinst} & {6{(~timw_reqop[1] & ~timw_reqop[2] &  timw_reqop[0]) | (tim_iswaitfor & mt_ptrvalidinst)}} 
                    | {1'b0,mt_ptrdata} & {6{(~timw_reqop[1] & ~timw_reqop[2] & ~timw_reqop[0]) | (tim_iswaitfor & mt_ptrvaliddata)}};
assign tim_ptrvalid = mt_ptrvalidinst | mt_ptrvaliddata;

localparam idlestate = 2'b00,
           waitstate = 2'b01,
           wforstate = 2'b10,
           stexstate = 2'b11;

always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        tim_counter <= 16'b0;
        tim_stx <= 1'b0;
        tim_ptr <= 6'b0;  
        tim_fsmstate <= idlestate; 
        tim_ctr0 <= 1'b0;
        tim_special_ldx <= 1'b0;
    end
    else begin
        casex (tim_fsmstate) 
            idlestate: begin
                tim_ctr0 <= 1'b0;
                if (tim_iswait) begin
		    tim_counter <= {12'b0, |timw_addr[3:0] ? timw_addr[3:0] : 4'b0001};
                  //  tim_counter <= {8'b0,|timw_addr[7:0] ? timw_addr[7:0] : 8'b0001}; //timw_addr[15:0] ... temporary removed to still play with the old traces!! 
		  //  tim_counter <= timw_addr[15:0];
                    tim_fsmstate <= waitstate;
                end
                if (tim_isstx) begin
                    tim_stx <= 1'b1;
                    tim_fsmstate <= stexstate;
                end
                if ((tim_iswaitfor && tim_ptrvalid && (~l2_fillvalid || (l2_fillptr != tim_finalptr))) || (tim_isldx)) begin
                    tim_ptr <= tim_finalptr;
                    tim_fsmstate <= wforstate;
                    tim_special_ldx <= (mt_ptrsecmissdata & ~mt_secm_byp_ldx);
                    timw_addr_old <= timw_addr;
                end
                end
            waitstate: begin
                if ((tim_counter == 16'b1) || (tim_counter == 16'b0)) begin
                    if (~mt_datafull & ~mt_instfull & ~l2_reqqnocredits) begin
                        tim_fsmstate <= idlestate;
                        tim_ctr0     <= 1'b1;
                        tim_counter  <= 16'b0;
                    end
                end
                else    
                    if (~mt_datafull & ~mt_instfull & ~l2_reqqnocredits)
                        tim_counter <= tim_counter - 1;
                end
            wforstate: begin
                if (l2_fillvalid && (l2_fillptr == tim_ptr)) 
                    if (tim_special_ldx) begin
                        tim_special_ldx <= 1'b0;
                    end
                    else begin
                        tim_fsmstate <= idlestate;
                    end
                end
            stexstate: begin
                if (l2_stxdone) begin
                    tim_stx <= 1'b0;
                    tim_fsmstate <= idlestate;
                end
                end
            default: begin
                tim_fsmstate <= idlestate;
                tim_counter <= 16'b0;
                tim_stx <= 1'b0;
                tim_ptr <= 6'b0;  // pedro --> sure it is incorrect
                end
        endcase
    end
end 

assign tim_strobereq  = ~tim_fsmstate[0] & ~tim_fsmstate[1] & ~((mt_datafull | mt_instfull) & tim_ismiss) & ~l2_reqqnocredits;//& tim_ismiss & ~timw_reqop[0]) 
                      //& ~(mt_instfull & tim_ismiss & timw_reqop[0]) & ~l2_reqqnocredits;// & ~tim_ctr0;
assign tim_req[47:42] = tim_special_ldx ? tim_ptr : tim_finalptr;
assign tim_req[41:3]  = tim_special_ldx ? timw_addr_old : timw_addr;
assign tim_req[2:0]   = tim_special_ldx ? 3'b001 :{timw_reqop[1] & ~timw_reqop[2], timw_reqldst & ~(timw_reqop[1] & ~timw_reqop[2]), timw_reqx};
assign tim_reqvalid   = (~tim_fsmstate[0] & ~tim_fsmstate[1] & ~l2_reqqnocredits & //~mt_datafull & ~mt_instfull 
                        (tim_ptrvalid & ((tim_ismiss & ~tim_isldx) | (tim_isldx & ~mt_ptrsecmissdata)) | tim_isevict | tim_isstx)) |
                        (tim_fsmstate == wforstate & tim_special_ldx & l2_fillvalid &(l2_fillptr == tim_ptr)) |
                        (tim_fsmstate == idlestate & tim_isldx & l2_fillvalid & ((l2_fillptr == tim_ptr) | (mt_datafull)));
endmodule
