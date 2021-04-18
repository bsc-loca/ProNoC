`timescale   1ns/1ns

//TODO use dual port RAM to make 2-cycl write in pipeline manner


module pronoc_cache_testbench;
// parameters
	 parameter RESET_DELAY = "MULTI_CLKS" ;
	 parameter INDEXw = 10;
	 parameter BYTE_WR_EN = "NO";
	 parameter TAGw =  20;
	 parameter DATAw =  32;
	 parameter WAY_NUM =  8;
	 parameter ADDRw = 32;
	 
	  localparam 
        BYTE_ENw= ( BYTE_WR_EN == "YES")? DATAw/8 : 1;

// Ports
	 reg [ADDRw-1:0] addr;
	 wire  busy;
	 reg [BYTE_ENw-1:0] byteen_in;
	 reg  clk;
	 reg [DATAw-1:0] data_in;
	 wire [DATAw-1:0] data_out;
	 wire re_fill;
	 reg  evict;
	 wire  hit;
	 reg  reset;
	 reg  we;

// top module instance
 	 pronoc_cache #(
		.RESET_DELAY(RESET_DELAY),
		.INDEXw(INDEXw),
		.BYTE_WR_EN(BYTE_WR_EN),
		.TAGw(TAGw),
		.DATAw(DATAw),
		.WAY_NUM(WAY_NUM),
		.ADDRw(ADDRw)
	)
	uut
	(
		.addr(addr),
		.busy(busy),
		.byteen_in(byteen_in),
		.clk(clk),
		.data_in(data_in),
		.data_out(data_out),
		.re_fill(re_fill),
		.evict(evict),
		.hit(hit),
		.reset(reset),
		.we(we)
	);

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 

 integer i;

initial begin
	 addr=0;
	 byteen_in=0;
	 data_in=0;
	 evict=0;
	 reset=1;
	 we=0;
	 i=0;

 //write your testbench code here
 #100
 @(posedge clk)#1 reset=1'b0;

//wait util cache is reset
 @(negedge busy)#1 
 
 
 repeat (100)begin 
     addr = i;
     data_in=i*10;
     we=1; 
     @(posedge clk)#1
     if(hit)begin 
        $display ("Error : wrong hit is asserted");
        $stop;
     end
     @(negedge busy)#1 
     i=i+4;  
 end
 $display ("info: write 100 data in address range 0 : 400");
 
 i=0;
  repeat (100)begin 
     addr = i;
     data_in=i*10;
     we=0; 
     @(posedge clk)#1
     if(!hit) $display ("Error : hit has not asserted");
     if(data_out!=i*10) begin 
        $display ("Error: Wrong data has been read from the chache in addr=%d. Expected %d but read %d",addr, i*10,data_out);
        $stop;
     end
    // $display ("addr=%d : data=%d",addr,data_out);
     i=i+4;  
 end
 $display ("info: Read the 100 data in address range 0 : 400 successfuly");
 
 
 
 i=0;
  repeat (100)begin 
     addr = i;
     evict=1; 
     @(posedge clk)#1
     if(!hit)begin 
        $display ("Error :  hit is not asserted");
        $stop;
     end
     @(negedge busy)#1 
     i=i+4;  
 end
  evict=0; 
 
 $display ("info: Evict the 100 data in address range 0 : 400");
 
 
  repeat (100)begin 
     addr = i;
     data_in=i*10;
     we=0; 
     @(posedge clk)#1
     if(hit) begin 
        $display ("Error: unsuccessful evict in addr=%d. read %d",addr, data_out);
        $stop;
     end
     i=i+4;  
 end
 $display ("Evict was successful");
 
 
 //check refill
 repeat (18)begin 
     addr = i;
     data_in=i*10;
     we=1; 
     @(posedge clk)#1
     if(hit)begin 
        $display ("Error : wrong hit is asserted");
        $stop;
     end
     @(negedge busy)#1 
      i=(2**(INDEXw+2))+i;   
 end
 
 #100 $stop;
 
 
 
 
 

end //initial 
endmodule