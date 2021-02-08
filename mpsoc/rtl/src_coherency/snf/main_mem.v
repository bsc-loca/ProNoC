/**************************************
* Module: main_mem
* Date:2019-05-27  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  main_mem_emulator #(
    parameter VERBOSITY=0,
    //parameter src_id=0,
    parameter B=4,
    parameter RD_LATENCY=50,
    parameter WR_LATENCY=50,
    parameter Dw=32,
    parameter Aw=32
 
)(

    src_id,
   
   //rxreq
   mem_to_rxreq_rd_data,
   rxreq_to_mem_rd_addr,
  // rd_byteen, //Should be added later
   rxreq_to_mem_rd_en,
   mem_to_rxreq_rd_ready,
   mem_to_rxreq_rd_done,
   mem_to_rxreq_wr_credit_incr,
   
   //rxdat
   rxdat_to_mem_wr_data,
   rxdat_to_mem_wr_addr,
   //wr_byteen,
   rxdat_to_mem_wr_en,  
   mem_to_rxdat_wr_ready,
   mem_to_rxdat_wr_done,
   
   clk,
   reset
  
);

     `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
   
    input [31 : 0] src_id;
    
    output [Dw-1 : 0] mem_to_rxreq_rd_data;
    input [ADDR_REQ-1 : 0] rxreq_to_mem_rd_addr;
   
    input rxreq_to_mem_rd_en;
    output mem_to_rxreq_rd_ready;
    output reg mem_to_rxreq_rd_done;   
     
    output mem_to_rxreq_wr_credit_incr;
   
    input [Dw-1 : 0] rxdat_to_mem_wr_data;
    input [ADDR_REQ-1 : 0] rxdat_to_mem_wr_addr;
    
    input rxdat_to_mem_wr_en;
    output mem_to_rxdat_wr_ready;
    output reg mem_to_rxdat_wr_done;
    
    input clk;
    input reset;

    wire [ADDR_REQ-1 : 0] current_rd_addr;
    wire mem_not_ready;


generate 
if(RD_LATENCY>1) begin :rd_pipe
    
    //rd addr fifo
    wire rd_addr_fifo_empty;
    wire [ADDR_REQ-1 : 0] rd_addr_fifo_din = rxreq_to_mem_rd_addr;
    wire rd_addr_fifo_wr_en =rxreq_to_mem_rd_en;
    wire rd_addr_fifo_rd_en = ~rd_addr_fifo_empty;
    wire rd_addr_fifo_full;   
    
    pipeline_addr_fifo #(
    	.Dw(ADDR_REQ),
    	.B(100),
    	.PIPE_LATANCY(RD_LATENCY)
    )
    rd_addr_fifo
    (
    	.din(rd_addr_fifo_din),
    	.wr_en(rd_addr_fifo_wr_en),
    	.rd_en(rd_addr_fifo_rd_en),
    	.dout(current_rd_addr),
    	.full(rd_addr_fifo_full),
    	.nearly_full(),
    	.empty(rd_addr_fifo_empty),
    	.reset(reset),
    	.clk(clk)
    );  


    reg delay;
    always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            delay <= 1'b0;
            mem_to_rxreq_rd_done<=1'b0;
        end else begin
            delay <= rd_addr_fifo_rd_en;
            mem_to_rxreq_rd_done<=delay;
       end   
    end

    assign mem_to_rxreq_rd_ready = (~mem_not_ready) & (~rd_addr_fifo_full);
    
end else begin : rd_no_latency
    
     assign current_rd_addr =  rxreq_to_mem_rd_addr;
     assign mem_to_rxreq_rd_ready = (~mem_not_ready);
     always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            mem_to_rxreq_rd_done<=1'b0;
        end else begin
            mem_to_rxreq_rd_done<=rxreq_to_mem_rd_en;
       end   
    end
end
    
    
 if(WR_LATENCY>1) begin :wr_pipe   
        
    // do the write first but send its ack by delay. Simulate read during write with new dat 
    //wr ack delay  
    wire wr_delay_empty;
    wire wr_delay_wr_en =rxdat_to_mem_wr_en;
    wire wr_delay_rd_en = ~wr_delay_empty;
    assign mem_to_rxreq_wr_credit_incr = wr_delay_rd_en;
    wire wr_delay_full;
    
    pipeline_addr_fifo #(
        .Dw(1),
        .B(100),
        .PIPE_LATANCY(WR_LATENCY)
    )
    wr_delay
    (
        .din( ),
        .wr_en(wr_delay_wr_en),
        .rd_en(wr_delay_rd_en),
        .dout( ),
        .full(wr_delay_full),
        .nearly_full(),
        .empty(wr_delay_empty),
        .reset(reset),
        .clk(clk)
    ); 
        
    assign mem_to_rxdat_wr_ready = (~mem_not_ready) & (~wr_delay_full); 
    
    always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            mem_to_rxdat_wr_done<=1'b0;
        end else begin
            mem_to_rxdat_wr_done<= wr_delay_rd_en;           
       end   
    end
    

end else begin : wr_no_pipe
     assign mem_to_rxdat_wr_ready = ~mem_not_ready;
    always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            mem_to_rxdat_wr_done<=1'b0;
        end else begin
            mem_to_rxdat_wr_done<= rxdat_to_mem_wr_en;           
       end   
    end
end
endgenerate
  
  function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

   localparam  LOW_OFFSETw = log2(CACHE_BLK_SIZ);        // The address range in cache block
    wire [Aw-1 : 0] mem_rd_addr = current_rd_addr [Aw+LOW_OFFSETw-1  : LOW_OFFSETw];
    wire [Aw-1 : 0] mem_wr_addr = rxdat_to_mem_wr_addr [Aw+LOW_OFFSETw-1 : LOW_OFFSETw];
    
    main_mem #(
    	.Dw(Dw),
    	.Aw(Aw),
    	.BYTE_WR_EN("NO")
    )
    main_mem
    (
    	
    	//rd chanel
    	.data_a({Dw{1'b0}}),
    	.addr_a(mem_rd_addr),
    	.byteen_a(1'b0),
    	.q_a(mem_to_rxreq_rd_data),
    	.we_a(1'b0),    	
    	
    	.data_b(rxdat_to_mem_wr_data),    	
    	.addr_b(mem_wr_addr),
    	.byteen_b(1'b0),
    	
    	.we_b(rxdat_to_mem_wr_en),
    	.clk(clk),
   
    	.q_b(),
    	.reset(reset),
    	.not_ready(mem_not_ready)
    );

    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk) begin
        if((VERBOSITY & MONITORE_MAIN_MEM)>0) begin 
            if(rxdat_to_mem_wr_en) $display ("%t: snf ( %d ) Write ( %h ) on addr ( %d ) on main_mem",$time,src_id,rxdat_to_mem_wr_data,rxdat_to_mem_wr_addr ); 
        end
    end   
    //synthesis translate_on 
    //synopsys  translate_on



endmodule





module  main_mem #(
    parameter Dw=8, 
    parameter Aw=6,
    parameter BYTE_WR_EN= "NO"//"YES","NO"
   )
   (
   
   data_a,
   addr_a,
   byteen_a,
   we_a,
   
   data_b,
   addr_b,
   byteen_b,
   we_b,    
   
   clk,
   reset,
   not_ready,
   q_a,
   q_b
   
);   
    /* verilator lint_off WIDTH */
    localparam BYTE_ENw= ( BYTE_WR_EN == "YES")? Dw/8 : 1;
    /* verilator lint_on WIDTH */
    
    input [(Dw-1):0] data_a,data_b;
    input [(Aw-1):0] addr_a,addr_b;
    input [BYTE_ENw-1   :   0]  byteen_a, byteen_b;
    input we_a, we_b, clk;
    output  [(Dw-1):0] q_a, q_b;
    input reset;
    output not_ready;    
    
    reg [Aw-1: 0] counter,counter_next;
    reg busy,busy_next;
    wire [Dw-1 : 0] ram_data_a;
    wire [Aw-1:0] ram_addr_a;
    wire ram_we_a;    
    
    assign not_ready = busy;
    
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            counter <= {Aw{1'b0}};
            busy<= 1'b1;
        end else begin 
            counter <= counter_next;
            busy<= busy_next;
        end        
    end
        
    always @(*) begin
        counter_next = counter;
        busy_next = busy;
        if(busy) counter_next = counter +1'b1;
        if(counter>=1000) busy_next = 1'b0;
    end




   assign ram_data_a = (busy)? (counter+1'b1): data_a;
   assign ram_addr_a= (busy)? counter : addr_a;
   assign ram_we_a= (busy)? 1'b1 : we_a;


    generic_dual_port_ram #(
        .Dw(Dw),
        .Aw(Aw),
        .BYTE_WR_EN(BYTE_WR_EN),
        .INITIAL_EN("NO"),
        .INIT_FILE("no")
    )
    generic_dual_port_ram(
        .data_a(ram_data_a),
        .data_b(data_b),
        .addr_a(ram_addr_a),
        .addr_b(addr_b),
        .byteena_a(byteen_a),
        .byteena_b(byteen_b),
        .we_a(ram_we_a),
        .we_b(we_b),
        .clk(clk),
        .q_a(q_a),
        .q_b(q_b)
    );

    

endmodule









module pipeline_addr_fifo  #(
    parameter Dw = 72,//data_width
    parameter B  = 10,// buffer num
    parameter PIPE_LATANCY=50
)(
    din,   
    wr_en, 
    rd_en, 
    dout,  
    full,
    nearly_full,
    empty,
    reset,
    clk
);

 
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
    
    
    

    localparam  B_1 = B-1,
                Bw = log2(B),
                DEPTHw=log2(B+1),
                CNTw=log2(PIPE_LATANCY);
                
                
                
    localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];

    input [Dw-1:0] din;     // Data in
    input          wr_en;   // Write enable
    input          rd_en;   // Read the next word

    output reg [Dw-1:0]  dout;    // Data out
    output         full;
    output         nearly_full;
    output         empty;

    input          reset;
    input          clk;



reg [Dw-1       :   0] queue [B-1 : 0] /* synthesis ramstyle = "no_rw_check" */;
reg [Bw- 1      :   0] rd_ptr;
reg [Bw- 1      :   0] wr_ptr;
reg [DEPTHw-1   :   0] depth;


reg [CNTw-1 : 0] counters [B-1 : 0];

genvar i;
generate 
for(i=0; i<B; i=i+1)begin 
    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            counters[i]<=0;
        end else if(wr_ptr==i && wr_en ) begin
            counters[i]<= PIPE_LATANCY;
        end else if (counters[i]>0)begin 
            counters[i]<=counters[i]-1'b1;        
        end
    end
end
endgenerate



// Sample the data
always @(posedge clk)
begin
   if (wr_en)
      queue[wr_ptr] <= din;
   if (rd_en)
      dout <=
//synthesis translate_off
//synopsys  translate_off
          #1
//synopsys  translate_on
//synthesis translate_on  
          queue[rd_ptr];
end

always @(posedge clk)
begin
   if (reset) begin
      rd_ptr <= {Bw{1'b0}};
      wr_ptr <= {Bw{1'b0}};
      depth  <= {DEPTHw{1'b0}};
   end
   else begin
      if (wr_en) wr_ptr <= (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1;
      if (rd_en) rd_ptr <= (rd_ptr==Bint)? {Bw{1'b0}} : rd_ptr + 1'b1;
      if (wr_en & ~rd_en) depth <= depth + 1'b1;
      else if (~wr_en & rd_en) depth <= depth - 1'b1;
   end
end

//assign dout = queue[rd_ptr];
assign full = depth == B;
assign nearly_full = depth >= B-1;
assign empty = depth == {DEPTHw{1'b0}} | counters[rd_ptr]!=0 ;

//synthesis translate_off
//synopsys  translate_off
always @(posedge clk)
begin
    if(~reset)begin
       if (wr_en && depth == B && !rd_en) begin 
            $display(" %t: ERROR: Attempt to write to full FIFO: %m",$time);
            $stop;
       end   
       if (rd_en && depth == {DEPTHw{1'b0}}) begin 
             $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
            $stop;
       end
    end//~reset
end
//synopsys  translate_on
//synthesis translate_on

endmodule // fifo

