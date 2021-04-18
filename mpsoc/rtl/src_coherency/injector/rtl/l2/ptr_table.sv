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
*   Date:           17/01/2019
*-------------------------------------------------------------------------------
*   Title:          Pointer Table V2
*   Description:    
*   Release Notes:  Implemented a two stages (Access/Update) type Ptr Table
*-----------------------------------------------------------------------------*/
module ptr_table
#(
    parameter   TAG_W               = 39                ,
                DEPTH               = 8                 ,
                TIM_PTR_W           = 6                 ,
                LINE_ST_W           = 2                 ,
                L2_INDEX_W          = 13                ,
                LOCAL_PTR_W         = $clog2(DEPTH)
)(
    input   logic                   clk                 ,
    input   logic                   rst_n               ,

    // Table Access Stage related signals
    input   logic [LOCAL_PTR_W-1:0] s1_tbl_id_i         ,
    input   logic                   s1_tag_val_i        ,
    input   logic [TAG_W-1:0]       s1_tag_i            ,

    output  logic [TIM_PTR_W-1:0]   s1_tim_ptr_o        ,
    output  logic                   s1_use_fst_4_dtx_o  , // Use Final State bus to set end state of non dataless TX.
    output  logic [LINE_ST_W-1:0]   s1_fst_o            , // Final state output for dataless requests
    output  logic                   s1_dless_rsp_to_l1_o, // Send response back to L1 after dataless completion.
    output  logic                   s1_lp_stx_o         , // Line requested by STX.

    output  logic [L2_INDEX_W-1:0]  s1_l2_index_o       ,
    output  logic [LOCAL_PTR_W-1:0] s1_tbl_id_o         ,
    output  logic [TAG_W-1:0]       s1_tag_o            ,
    output  logic                   s1_l1_hit_o         ,

    // Table Update Stage related signals               
    input   logic                   s2_l1_req_i         , // Is it an L1 Request?
    input   logic                   s2_l1_val_i         , // Assert only if line is not present in the L2.
    input   logic                   s2_fl_val_i         ,
    input   logic [LOCAL_PTR_W-1:0] s2_tbl_id_i         ,
    input   logic [TAG_W-1:0]       s2_tag_i            ,
    input   logic [L2_INDEX_W-1:0]  s2_l2_index_i       ,
    input   logic [TIM_PTR_W-1:0]   s2_tim_ptr_i        ,
    input   logic                   s2_use_fst_4_dtx_i  , // Use Final State bus to set end state of non dataless TX.
                                                          // This is a specific functionality required by the injector. 
                                                          // To be removed in case of a real cache.

    input   logic [LINE_ST_W-1:0]   s2_fst_i            , // Final Line state for dataless transactions
    input   logic                   s2_dless_rsp_to_l1_i, // Store if a rsp back to L1 is required after a dataless completion (use for evicts).
    input   logic                   s2_is_stx_i         , // Assert if current Line was requested by an STX.

    output  logic                   s1_full_o
);


    // Logic Declaration 
    /////////////////////////////////////

    // Declare Tables
    logic [TAG_W-1:0]       tag_table_r         [DEPTH-1:0] ; 
    logic [TIM_PTR_W-1:0]   tim_ptr_table_r     [DEPTH-1:0] ; 
    logic [L2_INDEX_W-1:0]  l2_index_table_r    [DEPTH-1:0] ; 
    logic [LINE_ST_W-1:0]   l2_fst_r            [DEPTH-1:0] ; 
    logic [DEPTH-1:0]       l2_use_fst_4_dtx_r              ;
    logic [DEPTH-1:0]       l2_dless_rsp_to_l1_r            ;
    logic [DEPTH-1:0]       is_stx_r                        ;
    logic [DEPTH-1:0]       valid_vect_r                    ,
                            valid_vect_rr                   ;

    // Other logic
    logic [LOCAL_PTR_W-1:0] s1_wr_ptr                       ;
    logic                   s1_table_hit                    ;
    logic [DEPTH-1:0]       s1_table_hit_v                  ;
    logic                   s1_int_full                     ,
                            s2_int_full_r                   ;



    // Implementation
    /////////////////////////////////////

    // Access Stage S1

    // Find out if the address is present in the table
    always_comb begin
        s1_table_hit_v = {DEPTH{1'b0}};
        for (int i=0; i<DEPTH; i++) begin
            if ({1'b1,s1_tag_i} == {valid_vect_rr[i],tag_table_r[i]}) begin
                s1_table_hit_v[i] = 1'b1;
            end
        end
    end

    assign s1_table_hit = |s1_table_hit_v;


    // Find table entry candiate
    always_comb begin
        s1_wr_ptr = {LOCAL_PTR_W{1'b0}};
        for (int i=0; i<DEPTH; i++) begin
            if (!valid_vect_r[i]) begin
                s1_wr_ptr = i;
                break;
            end
        end
    end

    // Assign Stage 1 Ouptuts
    assign s1_tim_ptr_o         = tim_ptr_table_r       [s1_tbl_id_i]; 
    assign s1_fst_o             = l2_fst_r              [s1_tbl_id_i];
    assign s1_dless_rsp_to_l1_o = l2_dless_rsp_to_l1_r  [s1_tbl_id_i];
    assign s1_use_fst_4_dtx_o   = l2_use_fst_4_dtx_r    [s1_tbl_id_i];
    assign s1_lp_stx_o          = is_stx_r              [s1_tbl_id_i];
    assign s1_l2_index_o        = l2_index_table_r      [s1_tbl_id_i];
    assign s1_tag_o             = tag_table_r           [s1_tbl_id_i];

    assign s1_tbl_id_o          = s1_wr_ptr;
    assign s1_l1_hit_o          = s1_table_hit;


    // Update Stage S2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) begin
                tag_table_r[i]      <= {TAG_W{1'b0}};
                tim_ptr_table_r[i]  <= {TIM_PTR_W{1'b0}};
                l2_index_table_r[i] <= {L2_INDEX_W{1'b0}};
                l2_fst_r[i]         <= {LINE_ST_W{1'b0}};
            end
            valid_vect_r            <= {DEPTH{1'b0}};
            l2_dless_rsp_to_l1_r    <= {DEPTH{1'b0}};
            l2_use_fst_4_dtx_r      <= {DEPTH{1'b0}};
            is_stx_r                <= {DEPTH{1'b0}};
        end else begin
            // Pre-allocate During S1
            if (s1_tag_val_i && !s1_l1_hit_o && !s1_int_full) begin
                valid_vect_r[s1_wr_ptr] <= 1'b1;
            end

            // S2 Unset valid bit if line present in L2
            // or if it's an evict and line is not in shared.
            if (s2_l1_req_i && !s2_l1_val_i) begin
                valid_vect_r[s2_tbl_id_i] <= 1'b0;
            end
                
            // S2 If line is not present in the L2, add outstanding miss
            if (s2_l1_req_i && s2_l1_val_i && !s2_int_full_r) begin
                tag_table_r             [s2_tbl_id_i]   <= s2_tag_i             ;
                tim_ptr_table_r         [s2_tbl_id_i]   <= s2_tim_ptr_i         ;
                l2_index_table_r        [s2_tbl_id_i]   <= s2_l2_index_i        ;
                l2_fst_r                [s2_tbl_id_i]   <= s2_fst_i             ;
                l2_dless_rsp_to_l1_r    [s2_tbl_id_i]   <= s2_dless_rsp_to_l1_i ;
                l2_use_fst_4_dtx_r      [s2_tbl_id_i]   <= s2_use_fst_4_dtx_i   ;
                is_stx_r                [s2_tbl_id_i]   <= s2_is_stx_i          ;
            end

            // S2 If fill -> Free up miss entry
            if (s2_fl_val_i) begin 
                valid_vect_r[s2_tbl_id_i] <= 1'b0;
                tag_table_r [s2_tbl_id_i] <= '0;
                is_stx_r    [s2_tbl_id_i] <= 1'b0;
            end
        end
    end

    assign s1_int_full = &valid_vect_r;

    // Flop full signal for internal usage during S2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_int_full_r <= 1'b0;
            valid_vect_rr <= {DEPTH{1'b0}};
        end else begin
            s2_int_full_r <= s1_int_full;
            valid_vect_rr <= valid_vect_r;
        end
    end

    assign s1_full_o = s1_int_full;


endmodule : ptr_table
