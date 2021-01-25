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
*   Date:           11/03/2019
*-------------------------------------------------------------------------------
*   Title:          pcrdgrant_mem.sv
*
*   Description:    This block is implemented to maintain the pcrdgrant table.
*                   
*                   The pcrdgrant table supports three kinds of operations:
*                   mem read: which accepts a 5-bits address and reads out the 
*                   entry in 0 cycles.
*                   mem compare: which accepts a pair of pcrdtype and srcid, 
*                   and compares with all the 32 entries, then outputs either 
*                   miss with a new entry, or a hit with the hit entry address.
*                   mem write, the special write port includes different write 
*                   enable signals to different fields, which allows to write to 
*                   fields separately using the same entry address.

*                   The pcrdgrant table includes 32 entries, with each entry 
*                   consists of the following 5 fields:
*                   Field 1: Valid bit
*                   Field 2: Tag including pcrdtype and srcid
*                   Field 2: first_txnid
*                   Field 3: cnt_retryack 
*                   Field 4: cnt_pcrdgrant
*                   The valid field cannot be directly read or write.
*                    
*                   Each write takes one cycle, each read takes 0 cycle.
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module pcrdgrant_mem 
     import chi_rn_params_pkg::*;
#(
    parameter PCRDGRANT_TABLE_DAT2
    )
(
    // generic
    input  logic                                clk,
    input  logic                                rst_n,

    // write port
    input  logic                                wr_en_2_i,
    input  logic [PCRDGRANT_TABLE_ADDR-1:0]     wr_addr_2_i, 
    input  logic [PCRDGRANT_TABLE_DAT2-1:0]     wr_data_2_i,
    input  logic                                wr_en_3_i,
    input  logic [PCRDGRANT_TABLE_ADDR-1:0]     wr_addr_3_i, 
    input  logic [PCRDGRANT_TABLE_DAT3-1:0]     wr_data_3_i,
    input  logic                                wr_en_4_i,
    input  logic [PCRDGRANT_TABLE_ADDR-1:0]     wr_addr_4_i, 
    input  logic [PCRDGRANT_TABLE_DAT4-1:0]     wr_data_4_i,
    input  logic                                wr_en_5_i,
    input  logic [PCRDGRANT_TABLE_ADDR-1:0]     wr_addr_5_i, 
    input  logic [PCRDGRANT_TABLE_DAT5-1:0]     wr_data_5_i,

    // compare port
    input  logic [PCRDGRANT_TABLE_DAT2-1:0]     comp_data_i,
    input  logic                                comp_data_valid_i,
    output logic [HIT_DAT-1:0]                  comp_hit_data_o,
    output logic [PCRDGRANT_TABLE_ADDR-1:0]     comp_hit_addr_o,
    output logic                                comp_hit_o,
    output logic                                comp_valid_o,

    //free entry 
    output logic [PCRDGRANT_TABLE_ADDR-1:0]     free_entry_o,
    // table is full
    output logic                                full_o 
);


    // logic definition
    // the memory block
    // mem1-valid, mem2-pcrdtype+srcid, mem3-first_txnid, mem4-cnt_retryack, mem5-cnt_pcrdgrant
    logic [2**PCRDGRANT_TABLE_ADDR-1:0]         mem1_valid_bitmap;
    logic [PCRDGRANT_TABLE_DAT2-1 : 0]          mem2 [2**PCRDGRANT_TABLE_ADDR-1:0];
    logic [PCRDGRANT_TABLE_DAT3-1 : 0]          mem3 [2**PCRDGRANT_TABLE_ADDR-1:0];
    logic [PCRDGRANT_TABLE_DAT4-1 : 0]          mem4 [2**PCRDGRANT_TABLE_ADDR-1:0];
    logic [PCRDGRANT_TABLE_DAT5-1 : 0]          mem5 [2**PCRDGRANT_TABLE_ADDR-1:0];
    // (srcid, pcrdtype) hit in the table 
    logic                                       tmp_comp_hit_o;
    logic [PCRDGRANT_TABLE_ADDR-1:0]            tmp_comp_hit_addr_o;
    logic [HIT_DAT-1:0]                         tmp_comp_hit_data_o;
                                                                       
    // start coding body
    // write to mem1
    genvar i;
    for(i='d0; i< 2**PCRDGRANT_TABLE_ADDR; i++) begin: gen_valid 
        assign mem1_valid_bitmap[i] = (mem4[i] != 0) || (mem5[i] != 0);
    end

    // write to mem2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<2**PCRDGRANT_TABLE_ADDR; i++) begin
                mem2[i] <= {PCRDGRANT_TABLE_DAT2{1'b0}};
            end
        end else if (wr_en_2_i) begin
            mem2[wr_addr_2_i] <= wr_data_2_i;
        end
    end
    
    // write to mem3
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<2**PCRDGRANT_TABLE_ADDR; i++) begin
                mem3[i] <= {PCRDGRANT_TABLE_DAT3{1'b0}};
            end
        end else if (wr_en_3_i) begin
            mem3[wr_addr_3_i] <= wr_data_3_i;
        end
    end

    // write to mem4
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<2**PCRDGRANT_TABLE_ADDR; i++) begin
                mem4[i] <= {PCRDGRANT_TABLE_DAT4{1'b0}};
            end
        end else if (wr_en_4_i) begin
            mem4[wr_addr_4_i] <= wr_data_4_i;
        end
    end
    // write to mem5
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<2**PCRDGRANT_TABLE_ADDR; i++) begin
                mem5[i] <= {PCRDGRANT_TABLE_DAT5{1'b0}};
            end
        end else if (wr_en_5_i) begin
            mem5[wr_addr_5_i] <= wr_data_5_i;
        end
    end
    
    // compare
    always_comb begin
        tmp_comp_hit_o  = 1'b0;
        tmp_comp_hit_addr_o  = {PCRDGRANT_TABLE_ADDR{1'b0}};
        tmp_comp_hit_data_o = {(HIT_DAT){1'b0}};
        for(int j= 0; j< 2**PCRDGRANT_TABLE_ADDR; j++) begin           
            if(comp_data_valid_i && (comp_data_i == mem2[j])) begin
                tmp_comp_hit_o  = 1'b1;
                tmp_comp_hit_addr_o = $unsigned(j);
                tmp_comp_hit_data_o = {mem3[j], mem4[j], mem5[j]};
                break; 
            end 
        end
     end
    // flop the data
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            comp_valid_o <= 1'b0;
            comp_hit_o  <= 1'b0;
            comp_hit_addr_o <= {PCRDGRANT_TABLE_ADDR{1'b0}};
            comp_hit_data_o <= {(HIT_DAT){1'b0}};
        end else begin
            comp_valid_o    <= comp_data_valid_i;
            comp_hit_o      <= tmp_comp_hit_o     ; 
            comp_hit_addr_o <= tmp_comp_hit_addr_o;
            comp_hit_data_o <= tmp_comp_hit_data_o;
        end
    end

    // find the first empty block
    always_comb begin
        free_entry_o = {PCRDGRANT_TABLE_ADDR{1'b0}};
        for (int i=0; i<2**PCRDGRANT_TABLE_ADDR; i++) begin
            if (!mem1_valid_bitmap[i]) begin
                free_entry_o = $unsigned(i);
                break;
            end
        end
    end
   
    // assign output 
    assign full_o = &mem1_valid_bitmap;
    
    endmodule 
