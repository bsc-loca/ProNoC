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
*   Date:           1/03/2019
*-------------------------------------------------------------------------------
*   Title:          snoop_mem.sv
*
*   Description:    This block is implemented to maintain the Wdat table which allows 
*                   two pipelines to read and write it without arbiter.
*
*                   To meet the requirement, the Wdat mem includes one special write 
*                   and one normal read port.
*                   
*                   The special write port includes different write enable signals to 
*                   different fields, which allows to write fields separately using 
*                   the same entry address 5bits for 32 entries.
*
*                   The snoop mem has two fields 
*                   Field 1: Valid 
*                   Field 2: the second field consists of srcid, txnid, fwdnid, fwdtxnid
*                   To write to Field 1, the address is not valid
*
*                   The read port accepts 5bits address and read all the fields out once.
*                   Each write takes one cycle, each read takes 0 cycle. 
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module snoop_mem 
     import chi_rn_params_pkg::*;
#(
    )
(
    // generic
    input  logic                                clk,
    input  logic                                rst_n,

    // read port  
    input  logic                                rd_en_i,
    input  logic [SNOOP_TABLE_ADDR-1:0]         rd_addr_i,
    output logic [SNOOP_TABLE_DAT-1:0]          data_output_o,
    output logic                                data_output_valid_o,

    // write port
    input  logic                                wr_en_1_or_i,
    input  logic                                wr_en_1_and_i,
    input  logic [2**SNOOP_TABLE_ADDR-1:0]      wr_data_1_or_i,
    input  logic [2**SNOOP_TABLE_ADDR-1:0]      wr_data_1_and_i,
    input  logic                                wr_en_2_i,
    input  logic [SNOOP_TABLE_ADDR-1:0]         wr_addr_2_i, 
    input  logic [SNOOP_TABLE_DAT-1:0]          wr_data_2_i,
    
    // free entry
    output logic [SNOOP_TABLE_ADDR-1:0]         free_entry_o,
    // snoop mem is full
    output logic                                full_o 
);


    // logic definition
    // the memory block
    // valid bitmap 
    logic [2**SNOOP_TABLE_ADDR-1:0]              mem1_valid_bitmap;
    // mem2 includes srcid, txnid, fwdnid, fwdtxnid
    logic [SNOOP_TABLE_DAT-1 : 0]                mem2 [2**SNOOP_TABLE_ADDR-1:0];
    
    // start coding body
    // write to mem1 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem1_valid_bitmap <= {2**SNOOP_TABLE_ADDR{1'b0}};
        end else begin
            if (!wr_en_1_and_i && wr_en_1_or_i) begin
                mem1_valid_bitmap <= mem1_valid_bitmap | wr_data_1_or_i;
            end else if (wr_en_1_and_i && !wr_en_1_or_i) begin
                mem1_valid_bitmap <= mem1_valid_bitmap & wr_data_1_and_i ;
            end else if (wr_en_1_and_i && wr_en_1_or_i) begin
                mem1_valid_bitmap <= (mem1_valid_bitmap | wr_data_1_or_i) & wr_data_1_and_i ;
            end else begin
                mem1_valid_bitmap <= mem1_valid_bitmap ;
            end
        end
    end

    // write to mem2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<2**SNOOP_TABLE_ADDR; i++) begin
                mem2[i] <= {SNOOP_TABLE_DAT{1'b0}};
            end
        end else if (wr_en_2_i) begin
            mem2[wr_addr_2_i] <= wr_data_2_i;
        end
    end
    
    
    // read data  
    assign data_output_o = mem2[rd_addr_i]; 
    assign data_output_valid_o = rd_en_i && mem1_valid_bitmap[rd_addr_i];


    // find first empty block
    always_comb begin
        free_entry_o = {SNOOP_TABLE_ADDR{1'b0}};
        for (int i=0; i<2**SNOOP_TABLE_ADDR; i++) begin
            if (!mem1_valid_bitmap[i]) begin
                free_entry_o = $unsigned(i);
                break;
            end
        end
    end
   
    // assign output 
    assign full_o = &mem1_valid_bitmap;
    
    endmodule 
