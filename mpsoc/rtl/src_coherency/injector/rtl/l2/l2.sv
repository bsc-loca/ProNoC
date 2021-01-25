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
*   Date:           28/11/2018
*-------------------------------------------------------------------------------
*   Title:          L2 Block
*   Description:    L2 block with the tags, replacement bits and the State bits. 
*   Release Notes:  On the second version, adapt L2 structure to the different 
*                   stages conflicts.
*-----------------------------------------------------------------------------*/
module l2 #(
    parameter WAYS    = 4,
    parameter SIZE    = 8192,
    parameter LOGWAYS = 2,
    parameter LOGSIZE = $clog2(SIZE)
    )
    (
    //Generic
    input                clk,
    input                rst_n,
    // From L2-FSM
    // Stage 2 ... Tag access
    input [38:0]         s2_l2_address,
    input                s2_l2_valid,
    input                s2_l2_miss,
    input                s2_l2_evict,
    input                s2_l2_fill,
    
    // Stage 3
    input [1:0]          s3_l2_new_state,
    input                s3_l2_valid,
    input [LOGSIZE-1:0]  s3_l2_index,
    input                s3_l2_snoop,

    
    // To L2-FSM
    output [1:0]         s2_l2_state,
    output [LOGSIZE-1:0] s2_l2_index,
    output [38:0]        s2_l2_evict_addr,
    output               s2_l2_evict_valid,
    output               s2_l2_wrong_evict,
    output               s2_l2_blocked
);
localparam LINE_W = 6;
localparam BANK_W = 2;
localparam TAG_W  = 38-LOGSIZE-LINE_W-BANK_W+LOGWAYS;
localparam FULL_INDEX_W = LOGSIZE-LOGWAYS;

reg [TAG_W:0]              l2_tags  [SIZE-1:0];
reg [1:0]                  l2_state [SIZE-1:0];
reg [SIZE-1:0]             l2_pending;
reg [WAYS-1:0]             l2_repl  [(SIZE >> LOGWAYS)-1:0];
logic                      s3_l2_fill;

// Pedro ---> Map
// 3       32        21        1
// 876543210987654321098765432109876543210
// (          Tags            )(  Index  )

// Pedro ---> New Map
// 3       32        21        1
// 876543210987654321098765432109876543210
// (          Tags      )(  Index  )(line)



wire [38-LOGSIZE-LINE_W+LOGWAYS:0] s2_address_tag;
wire [LOGSIZE-LOGWAYS-1:0]  s2_index;
wire [WAYS-1:0]     s2_hit_vector;
wire [WAYS-1:0]     s2_any_invalid;
wire [WAYS-1:0]     s2_not_pending;
wire [WAYS-1:0]     s2_new_pending;
wire [1:0]         s2_state;
wire [1:0]         s2_pending;
wire [LOGSIZE-1:0] s2_hit_index; 
wire [LOGWAYS-1:0] s2_invalid_index; 
wire [LOGWAYS-1:0] s2_notpend_index; 
wire [LOGSIZE-1:0] s2_victim_index; 

assign s2_index       = s2_l2_address[LOGSIZE+LINE_W-LOGWAYS-1:LINE_W];
assign s2_address_tag = s2_l2_address[38:LOGSIZE-LOGWAYS+LINE_W];

genvar i;
generate
for (i = 0; i < WAYS; i++) begin : gen_hitvector
    assign s2_hit_vector[i]  = s2_l2_valid & (l2_tags [(s2_index << LOGWAYS) + i] == s2_address_tag) & 
                                           ~((l2_state[(s2_index << LOGWAYS) + i] == 2'b00) & ~l2_pending[(s2_index << LOGWAYS) + i]);
    assign s2_any_invalid[i] = s2_l2_valid & (l2_state[(s2_index << LOGWAYS) + i] == 2'b00) & ~l2_pending[(s2_index << LOGWAYS) + i];
    assign s2_not_pending[i] = s2_l2_valid & ~l2_pending[(s2_index << LOGWAYS) + i];
end : gen_hitvector
endgenerate

assign s2_hit_index     = {s2_index, |s2_hit_vector [3:2], s2_hit_vector [3] | (s2_hit_vector [1] & ~s2_hit_vector[2])};
assign s2_invalid_index = {|s2_any_invalid[3:2], s2_any_invalid[3] | (s2_any_invalid[1] & ~s2_any_invalid[2])};  
assign s2_notpend_index = {|s2_not_pending[3:2], s2_not_pending[3] | (s2_not_pending[1] & ~s2_not_pending[2])};
assign s2_new_pending   = ~s2_not_pending | (1'b1 << s2_notpend_index);  

assign s2_state = l2_state[{s2_index,2'b00}] & {2{s2_hit_vector[0]}} | l2_state[{s2_index,2'b01}] & {2{s2_hit_vector[1]}} 
                | l2_state[{s2_index,2'b10}] & {2{s2_hit_vector[2]}} | l2_state[{s2_index,2'b11}] & {2{s2_hit_vector[3]}};

/*
assign s2_hit_index     = {s2_index, |s2_hit_vector [7:4], |s2_hit_vector [7:6] | |s2_hit_vector [3:2], s2_hit_vector [7] | s2_hit_vector [5] | s2_hit_vector [3] | s2_hit_vector [1]};
assign s2_invalid_index = {s2_index, |s2_any_invalid[7:4], |s2_any_invalid[7:6] | |s2_any_invalid[3:2], s2_any_invalid[7] | s2_any_invalid[5] | s2_any_invalid[3] | s2_any_invalid[1]};  

assign StateValue = l2_state[{s2_index,3'b000} & {3{s2_hit_vector[0]}} | l2_state[{s2_index,3'b001} & {3{s2_hit_vector[1]}} 
                  | l2_state[{s2_index,3'b010} & {3{s2_hit_vector[2]}} | l2_state[{s2_index,3'b011} & {3{s2_hit_vector[3]}}
                  | l2_state[{s2_index,3'b100} & {3{s2_hit_vector[4]}} | l2_state[{s2_index,3'b101} & {3{s2_hit_vector[5]}} 
                  | l2_state[{s2_index,3'b110} & {3{s2_hit_vector[6]}} | l2_state[{s2_index,3'b111} & {3{s2_hit_vector[7]}};

*/
wire [LOGWAYS-1:0] s2_victim;
wire [WAYS-2:0]    s2_plru_hit;
wire [WAYS-2:0]    s2_plru_vct;
wire [LOGWAYS-1:0] s2_plru_idx;

assign s2_plru_idx = {l2_repl[s2_index][2], l2_repl[s2_index][2] ?  l2_repl[s2_index][1] : l2_repl[s2_index][0]};

assign s2_victim   = |s2_any_invalid ? s2_invalid_index : l2_pending[(s2_index << LOGWAYS) + s2_plru_idx] ? s2_notpend_index : s2_plru_idx;  
assign s2_plru_hit = {~|s2_hit_vector[3:2], |s2_hit_vector[3:2] ? ~(s2_hit_vector[3] | (s2_hit_vector[1] & ~s2_hit_vector[2])) : l2_repl[s2_index][1], 
                                            |s2_hit_vector[3:2] ? l2_repl[s2_index][0] : ~(s2_hit_vector[3] | (s2_hit_vector[1] & ~s2_hit_vector[2]))};
assign s2_plru_vct = |s2_any_invalid ? {~|s2_any_invalid[3:2],
                                         |s2_any_invalid[3:2] ? ~(s2_any_invalid[3] | (s2_any_invalid[1] & ~s2_any_invalid[2])) : l2_repl[s2_index][1], 
                                         |s2_any_invalid[3:2] ? l2_repl[s2_index][0] : ~(s2_any_invalid[3] | (s2_any_invalid[1] & ~s2_any_invalid[2]))}
                    : {~l2_repl[s2_index][2], l2_repl[s2_index][2] ^ l2_repl[s2_index][1], ~l2_repl[s2_index][2] ^ l2_repl[s2_index][0]}; // Check
assign s2_victim_index = {s2_index, s2_victim};

// Pedro --> Missing plru assignments for 8-way set associative


wire s2_hit = |s2_hit_vector & ~(s3_l2_snoop & ~|s3_l2_new_state & (s2_hit_index == s3_l2_index));
logic full_pending;
logic [LOGSIZE-LOGWAYS-1:0]  full_index;
logic s3_l2_evict;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        l2_state     <= '{SIZE{2'b0}};                    // All lines are invalid
        l2_pending   <=  {SIZE{1'b0}};                    // All lines are invalid
        l2_repl      <= '{(SIZE>>LOGWAYS){{WAYS{1'b0}}}}; // And are the least recently used
        full_pending <= 1'b0;
        l2_tags      <= '{SIZE{{TAG_W-1{1'b0}}}};
        full_index   <= {FULL_INDEX_W{1'b0}};
        s3_l2_fill   <= 1'b0;
	s3_l2_evict  <= 1'b0;
    end    
    else begin
        s3_l2_fill   <= s2_l2_fill;
	s3_l2_evict  <= s2_l2_evict & s2_state[1] & s2_hit & s2_l2_valid;
        if ((s2_l2_valid) && (s2_l2_miss ^ s2_l2_evict))begin // Modify replacement bits and tags
            if (s2_hit) begin
                l2_repl[s2_index] <= s2_plru_hit;
             end
            else begin
                if (~s2_l2_evict) begin
                    l2_tags[s2_victim_index]    <= s2_address_tag;
                    l2_repl[s2_index]           <= s2_plru_vct;
                end
            end
        end
        if ((s2_l2_valid) && (s2_l2_miss ^ s2_l2_fill)) begin // Modify pending bits
            if (~s2_hit) begin
                l2_pending[s2_victim_index] <= s2_l2_miss;
                if (s3_l2_valid & s3_l2_fill & (s2_index[LOGSIZE-LOGWAYS-1:2] != s3_l2_index[LOGSIZE-1:2])) begin
                    full_pending            <= &s2_new_pending;
                    full_index              <= s2_index;
                end
            end
        end
        if (s3_l2_valid) begin
            l2_state[s3_l2_index]           <= s3_l2_new_state;
            l2_pending[s3_l2_index]         <= ~(s3_l2_fill | s3_l2_evict | s3_l2_snoop);
            if (full_pending & (full_index[LOGSIZE-LOGWAYS-1:0] == s3_l2_index[LOGSIZE-1:2]) & s3_l2_fill) begin
                full_pending                <= 1'b0;
            end
        end
    end
end

assign s2_l2_state       = (s3_l2_valid & (s3_l2_index == s2_hit_index) & s2_hit) ?  s3_l2_new_state : (s2_hit ? s2_state : (l2_state[s2_victim_index] & {2{s2_l2_miss}}));              
assign s2_l2_index       = s2_hit ? s2_hit_index : s2_victim_index;
assign s2_l2_evict_addr  = {l2_tags[s2_victim_index], s2_index, 2'b0,{LINE_W{1'b0}}};
assign s2_l2_evict_valid = ~s2_hit & s2_l2_valid & ~|s2_any_invalid & s2_l2_miss;
assign s2_l2_wrong_evict = s2_l2_valid & s2_l2_evict & ~s2_hit;
assign s2_l2_blocked     = full_pending | (&s2_new_pending & s2_l2_valid & s2_l2_miss & ~s2_hit);
endmodule
