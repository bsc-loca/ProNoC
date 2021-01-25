/**************************************
* Module: fifo_depth_incr
* Date:2019-07-30  
* Author: alireza     
*
* Description: 
***************************************/
module  fifo_depth_extended #(
    parameter B=4,
    parameter EXTND_B=8,
    parameter Dw=32

)(
    din,   
    wr_en, 
    rd_en, 
    dout,  
    full,
    nearly_full,
    empty,
    reset,
    clk,
    credit_out
    


);

    input [Dw-1:0] din;     // Data in
    input          wr_en;   // Write enable
    input          rd_en;   // Read the next word

    output [Dw-1:0]  dout;    // Data out
    output         full;
    output         nearly_full;
    output         empty;

    input          reset;
    input          clk;

    output reg credit_out;
    
   
    fifo #(
        .Dw(Dw),
        .B(EXTND_B)
    )        
    extnd_fifo
    (
    	.din(din),
    	.wr_en(wr_en),
    	.rd_en(rd_en),
    	.dout(dout),
    	.full(full),
    	.nearly_full(nearly_full),
    	.empty(empty),
    	.reset(reset),
    	.clk(clk)
    );

   
   //When getting a new flit we will send credit signal next clock cycle aswhile the fifo available size is larger than B 
 
     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
        
    localparam  EBw = log2(EXTND_B+1);
    
    reg [EBw-1 : 0] credit_counter;
        
        
    
    always@(posedge clk or posedge reset)begin
        if(reset)begin
            credit_counter <={EBw{1'b0}};           
        end else begin
            if(  wr_en   & ~ rd_en)   credit_counter <= credit_counter+1'b1;
            if( ~wr_en   &   rd_en)   credit_counter <= credit_counter-1'b1;           
        end //reset
     end//always


    always @(posedge clk or posedge reset) begin
        if (reset) credit_out<=1'b0;
        else begin 
            if(credit_counter < (EXTND_B-B))begin 
                credit_out<=wr_en;              
            
            end else if (credit_counter == (EXTND_B-B) ) begin 
                 credit_out<=wr_en &rd_en ;  
            
            end else begin    
                 credit_out<=rd_en; 
                                        
            end
        end
    end
    
    
    


endmodule

