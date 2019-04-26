`timescale     1ns/1ps

module pronoc_cache_testbench;
// parameters
	 parameter RESET_DELAY =  ;
	 parameter INDEXw = 10;
	 parameter BYTE_WR_EN = ;
	 parameter TAGw =  20;
	 parameter DATAw =  32;
	 parameter WAY_NUM =  8;
	 parameter ADDRw = 32;

// Ports
	 reg [ADDRw-1:0] addr;
	 wire  busy;
	 reg [BYTE_ENw-1:0] byteen_in;
	 reg  clk;
	 reg [DATAw-1:0] data_in;
	 wire [DATAw-1:0] data_out;
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
		.evict(evict),
		.hit(hit),
		.reset(reset),
		.we(we)
	);

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 

initial begin
	 addr=0;
	 byteen_in=0;
	 data_in=0;
	 evict=0;
	 reset=0;
	 we=0;

 //write your testbench code here
 


end //initial 
endmodule