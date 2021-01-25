/**************************************
* Module: transaction_lookup_table
* Date:2019-05-13  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns




module  transaction_lookup_table#(
    parameter TXN_DATAw=37,
    parameter TXN_IDw = 8,
    parameter RD_DURING_WR= "OLD_DAT"  // "NEW_DAT", "OLD_DAT"     
)(
    //wr
    txn_wr_dat,
    txn_wr_addr,
    txn_wr_en,
    
    //rd
    txn_rd_dat,
    txn_rd_addr,  
    txn_rd_en,
    clk   
);

    input [TXN_IDw-1 :  0] txn_wr_addr,txn_rd_addr;
    input [TXN_DATAw-1 :  0] txn_wr_dat;
    input txn_wr_en;
    output [TXN_DATAw-1 :  0] txn_rd_dat;
    input txn_rd_en;
    input clk; 
   
    // memory
    reg [TXN_DATAw-1:0] queue [2**TXN_IDw-1:0] /* synthesis ramstyle = "no_rw_check , M9K" */;
    reg [TXN_DATAw-1:0] mem_rd_data;
      
     //memory def
           always @(posedge clk ) begin
                if (txn_wr_en)
                     queue[txn_wr_addr] <= txn_wr_dat;
                if (txn_rd_en)
                     mem_rd_data <=
    //synthesis translate_off
    //synopsys  translate_off
                          #1
    //synopsys  translate_on
    //synthesis translate_on   
                          queue[txn_rd_addr];
        end 
      
   generate 
   if(RD_DURING_WR == "OLD_DAT") begin : old_dat       
          
           assign txn_rd_dat =   mem_rd_data;
    
    end
    else begin : new_dat
    
        wire wr_rd_to_same_addr = (txn_wr_addr == txn_rd_addr) & txn_rd_en & txn_wr_en;
         
                  
          //
          reg bypass_en;
          reg [TXN_DATAw-1:0] bypass_data;
          always @(posedge clk ) begin
               if (txn_rd_en) begin 
                        bypass_en<=wr_rd_to_same_addr;
                        bypass_data <= txn_wr_dat;
                    end
        end
          
          assign txn_rd_dat = (bypass_en)? bypass_data : mem_rd_data;
          
          
   end     
    endgenerate
   
   
   /*
   //synthesis translate_off 
   //synopsys  translate_off
   always @(posedge clk) begin
      if (txn_wr_en) $display ("txntable addr (%d) is updated with (%d)",txn_wr_addr, txn_wr_dat);
   end
   
   
   //synthesis translate_on 
   //synopsys  translate_on
   
*/
endmodule









module  transaction_lookup_table_old#(
    parameter TXN_DATAw=37,
    parameter TXNID_REQ = 8,
    parameter RD_DURING_WR="OLD_DAT" // "NEW_DAT", "OLD_DAT"     
)(
    //wr
    txn_wr_dat,
    txn_wr_addr,
    txn_wr_en,
    
    txn_rd_dat,
    txn_rd_addr,  
    txn_rd_en,
    clk   
);

    input [TXNID_REQ-1 :  0] txn_wr_addr,txn_rd_addr;
    input [TXN_DATAw-1 :  0] txn_wr_dat;
    input txn_wr_en;
    output reg [TXN_DATAw-1 :  0] txn_rd_dat;
    input txn_rd_en;
    input clk; 
   
    // memory
    reg [TXN_DATAw-1:0] queue [2**TXNID_REQ-1:0] /* synthesis ramstyle = "no_rw_check , M9K" */;
   
   generate 
   if(RD_DURING_WR == "OLD_DAT") begin : old_dat
      
      
        always @(posedge clk ) begin
                if (txn_wr_en)
                     queue[txn_wr_addr] <= txn_wr_dat;
                if (txn_rd_en)
                     txn_rd_dat <=
    //synthesis translate_off
    //synopsys  translate_off
                          #1
    //synopsys  translate_on
    //synthesis translate_on   
                          queue[txn_rd_addr];
        end
    
    end
    else begin : new_dat
    
        wire wr_rd_to_same_addr = (txn_wr_addr == txn_rd_addr) & txn_rd_en & txn_wr_en;
        always @(posedge clk ) begin
                if (txn_wr_en)
                     queue[txn_wr_addr] <= txn_wr_dat;
                
                                
                if (txn_rd_en)
                     txn_rd_dat <=
    //synthesis translate_off
    //synopsys  translate_off
                          #1
    //synopsys  translate_on
    //synthesis translate_on   
                        (wr_rd_to_same_addr)?  txn_wr_dat : queue[txn_rd_addr];
        end
    
    end
    endgenerate
   
   

endmodule




module  pronoc_active_transaction_lookup#(
    parameter TXN_DATAw=37,
    parameter TXNID_REQ = 8
     
)(
    txndata_in,
    txnid_wr_in,
    new_txn,
    txnid_rd_in,  
    txndata_out,
    clk   
);

    input [TXNID_REQ-1 :  0] txnid_wr_in,txnid_rd_in;
    input [TXN_DATAw-1 :  0] txndata_in;
    input new_txn;
    output  [TXN_DATAw-1 :  0] txndata_out;
    input clk; 
   
    generic_dual_port_ram #(
        .Dw(TXN_DATAw),
        .Aw(TXNID_REQ),
        .BYTE_WR_EN("NO"),
        .INITIAL_EN("NO")       
    )
    ram
    (
        .data_a(txndata_in),
        .addr_a(txnid_wr_in),
        .we_a(new_txn),
        .byteena_a(1'b0),
        .q_a( ),
        
        
        .data_b(),
        .addr_b(txnid_rd_in ),  
        .q_b(txndata_out),
        .byteena_b(1'b0),       
        .we_b(1'b0),
        .clk(clk)   
        
    ); 

endmodule
