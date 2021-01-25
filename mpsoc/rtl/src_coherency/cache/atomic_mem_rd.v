/**************************************
* Module: atomic_mem_rd
* Date:2019-07-08  
* Author: alireza     
*
* Description: 
***************************************/
module  atomic_mem_rd#(
    parameter PIPE_NUM=2,
    parameter Dw=32,
    parameter Aw=10
)
(
    rd_addr,
    rd_en,
    mem_rd_dat, 
    rd_dat,
    
      
    wr_addr_pipe,
    wr_en_pipe,
    wr_dat_pipe,  // the latest wr should be assigned to MS loc  
    
    clk,
    reset
    
);

    localparam 
        P   = PIPE_NUM, 
        PDw = P  * Dw, 
        PAw =  P  * Aw; 
       

    input [Aw-1 : 0]  rd_addr;
    input rd_en;
    input [Dw-1 : 0] mem_rd_dat;
    output [Dw-1 : 0] rd_dat;
    
    input [PAw-1 : 0] wr_addr_pipe;  
    input [P-1: 0]  wr_en_pipe; 
    input [PDw-1 : 0] wr_dat_pipe;      

    input clk,reset; 

    wire [P-1 : 0] wr_rd_from_same_addr, grant;
    wire any_grant;
    
    genvar i;
    generate
        for (i = 0; i < P; i = i + 1) begin : block
            assign wr_rd_from_same_addr[i]= (wr_addr_pipe[(i+1)*Aw-1 : i*Aw] == rd_addr) & rd_en & wr_en_pipe[i];
        end
    endgenerate
           
            
    
    
    fixed_priority_arbiter #(
    	.ARBITER_WIDTH(P),
    	.HIGH_PRORITY_BIT("HSB")//The last written data has the highest prority to be bypassed
    )
    arbiter
    (
    	.request(wr_rd_from_same_addr),
    	.grant(grant),
    	.any_grant(any_grant)
    );
    
  
    wire [Dw-1 : 0] mux_out;
    
    one_hot_mux #(
    	.IN_WIDTH(PDw),
    	.SEL_WIDTH(P),
    	.OUT_WIDTH(Dw)
    )
    mux
    (
    	.mux_in(wr_dat_pipe),
    	.mux_out(mux_out),
    	.sel(grant)
    );
    
    
    
    reg bypass_en;
    reg [Dw-1:0] bypass_data;
    always @(posedge clk or posedge reset) begin
        if(reset)bypass_en<=1'b0;
        if (rd_en) begin 
            bypass_en<=any_grant;
            bypass_data <= mux_out;
        end
    end
          
    assign rd_dat = (bypass_en)? bypass_data : mem_rd_dat;

endmodule


// This module perevents two unfinished consequative read requests to the same snpf cache line 
module snpf_rxreq_hazard_detect  #(
    parameter Aw=32,
    parameter PIPE_SIZE=2
   // parameter src_id=0

)(
    src_id,
    req_ram_addr_i_rd,
    rd_en,
    req_ram_addr_i_wr,
    wr_en,
    clk,
    reset,
    hazard

);

    input [31 : 0] src_id;
    
    input [Aw-1 : 0] req_ram_addr_i_rd;
    input rd_en;
    input [Aw-1 : 0] req_ram_addr_i_wr;
    input wr_en;
    input clk;
    input reset;
    output reg hazard;

    reg [Aw-1 : 0] registers [PIPE_SIZE-1 : 0];
    reg [PIPE_SIZE-1 : 0] valid;
    wire [PIPE_SIZE-1 : 0] grant,match_wr,match_rd;
    wire any_grant;
    
    
   
    fixed_priority_arbiter #(
    	.ARBITER_WIDTH(PIPE_SIZE)
    )
    empty_select
    (
    	.request(~valid),
    	.grant(grant),
    	.any_grant(any_grant)
    );
    
    genvar i;
    generate
    for (i = 0; i < PIPE_SIZE; i = i + 1) begin : block
    
        assign match_wr[i] = (req_ram_addr_i_wr == registers [i])&valid[i];
        assign match_rd[i] = (req_ram_addr_i_rd == registers [i])&valid[i];
    
        always @(posedge clk or posedge reset) begin
            if(reset)begin 
                registers [i]<= {Aw{1'b0}};
                valid [i]<=1'b0;   
            end else begin 
                if(rd_en & grant[i] & ~(| match_rd))begin 
                    registers [i]<= req_ram_addr_i_rd;
                    valid [i] <= 1'b1 ;
                end
                else if(wr_en & match_wr[i])begin 
                    valid [i] <= 1'b0;
                end
               
            end        
        end//always
    end//for
    endgenerate
    
   
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
               hazard<=1'b0 ; 
            end else begin 
                if(rd_en) hazard <=| match_rd;              
            end        
    end//always
    

//synthesis translate_off 
//synopsys  translate_off

    always @(posedge clk or posedge reset) begin
            if(rd_en & ~any_grant) begin 
                $display("%t: SNP (%d) hazard detect buffer overflow on ram_addr :%h",$time,src_id,req_ram_addr_i_rd);
                $stop;            
            end        
    end//always

//synthesis translate_on 
//synopsys  translate_on

     
     

endmodule


















































