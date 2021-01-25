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
*   Date:           12/03/2019
*-------------------------------------------------------------------------------
*   Title:          txnid_mem.sv
*
*   Description:    This block is implemented to maintain the TxnID table which allows 
*                   three pipelines to read and write it at the same time.
*
*                   To meet the requirement, the TxnID mem includes one special write 
*                   and two normal read port.
*                   The special write port includes different write enable signals to 
*                   different fields, thus allows to write to fields separately.
*                   
*                   This memory has 64 entries, each entry consists of three fields:
*                   Field 1: Valid bit
*                   Field 2: opcode_req, tbl_id, bank_addr, wdat_addr, addr, cmpack, excl_snoopme
*                   Field 3: NextTxnid
*                   To write to Field 1, the address is not valid
*
*                   The read port accepts 6bits address and read all the fields out once.
*                   Each write takes one cycle, each read takes 0 cycle. 
*
*                   Add size for atomic operations in Field 2
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module txnid_mem 
     import chi_rn_params_pkg::*;
#(
    parameter TXNID_TABLE_DAT,
    parameter TXNID_TABLE_DAT2,
    parameter TXNID_TABLE_DAT3
)
(
    // generic
    input  logic                                clk,
    input  logic                                rst_n,

    // read port 1
    input  logic                                rd_en_1_i,
    input  logic [TXNID_TABLE_ADDR-1:0]         rd_addr_1_i,
    output logic [TXNID_TABLE_DAT-1:0]          data_output_1_o,
    output logic                                data_output_valid_1_o,
 
    // read port 2
    input  logic                                rd_en_2_i,
    input  logic [TXNID_TABLE_ADDR-1:0]         rd_addr_2_i,
    output logic [TXNID_TABLE_DAT-1:0]          data_output_2_o,
    output logic                                data_output_valid_2_o,

    // write port
    input  logic                                wr_en_1_or_i,
    input  logic                                wr_en_1_and_i,
    input  logic [TXNID_TABLE_ADDR-1:0]         wr_addr_2_i, 
    input  logic                                wr_en_2_i,
    input  logic [TXNID_TABLE_ADDR-1:0]         wr_addr_3_i, 
    input  logic                                wr_en_3_i,
    input  logic [2**TXNID_TABLE_ADDR-1:0]      wr_data_1_or_i,
    input  logic [2**TXNID_TABLE_ADDR-1:0]      wr_data_1_and_i,
    input  logic [TXNID_TABLE_DAT2-1:0]         wr_data_2_i,
    input  logic [TXNID_TABLE_DAT3-1:0]         wr_data_3_i,

    output logic [TXNID_TABLE_ADDR-1:0]         free_entry_o,
    output logic                                full_o 
);


    // logic definition
    // the memory block
    // valid bitmap 
    logic [2**TXNID_TABLE_ADDR-1:0]              mem1_valid_bitmap;
    // mem field 2 includes valid, opcode_req, tbl_id, bank_addr, wdat_table_addr, addr
    logic [TXNID_TABLE_DAT2-1 : 0]               mem2 [2**TXNID_TABLE_ADDR-1:0];
    // mem field 3 includes next_txnid, it is used to assist the retry logic
    logic [TXNID_TABLE_DAT3-1 : 0]               mem3 [2**TXNID_TABLE_ADDR-1:0];

    /*---------------------------------------------------------------*/
    /*Start coding body*/
    /*---------------------------------------------------------------*/
    
    // write to mem1
    // this allow multiple writes to the valid field at the same time 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem1_valid_bitmap <= {2**TXNID_TABLE_ADDR{1'b0}};
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
            for (int i=0; i<2**TXNID_TABLE_ADDR; i++) begin
                mem2[i] <= {TXNID_TABLE_DAT2{1'b0}};
            end
        end else if (wr_en_2_i) begin
            mem2[wr_addr_2_i] <= wr_data_2_i;
        end
    end

    // write to mem3
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<2**TXNID_TABLE_ADDR; i++) begin
                mem3[i] <= {TXNID_TABLE_DAT3{1'b0}};
            end
        end else if (wr_en_3_i) begin
            mem3[wr_addr_3_i] <= wr_data_3_i;
        end
    end
    
    
    //read data port 1
    assign data_output_1_o = {mem2[rd_addr_1_i], mem3[rd_addr_1_i]}; 
    assign data_output_valid_1_o = rd_en_1_i && mem1_valid_bitmap[rd_addr_1_i];

    //read data port 2
    assign data_output_2_o = {mem2[rd_addr_2_i], mem3[rd_addr_2_i]}; 
    assign data_output_valid_2_o = rd_en_2_i && mem1_valid_bitmap[rd_addr_2_i];
    

    // Find first empty block
    always_comb begin
        free_entry_o = {TXNID_TABLE_ADDR{1'b0}};
        for (int i=0; i<2**TXNID_TABLE_ADDR; i++) begin
            if (!mem1_valid_bitmap[i]) begin
                free_entry_o = $unsigned(i);
                break;
            end
        end
    end
   
    // assign output 
    assign full_o = &mem1_valid_bitmap;
    
    endmodule 
