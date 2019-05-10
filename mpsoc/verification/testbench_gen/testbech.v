`timescale     1ns/1ps

module start_delay_gen_testbench;
// parameters
	 parameter NC = 	64 ;

// Ports
	 reg  clk;
	 reg  reset;
	 reg  start_i;
	 wire [NC-1:0] start_o;

// top module instance
 	 start_delay_gen #(
		.NC(NC)
	)
	uut
	(
		.clk(clk),
		.reset(reset),
		.start_i(start_i),
		.start_o(start_o)
	);

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 

initial begin
	 reset=0;
	 start_i=0;

 //write your testbench code here
 


end //initial 
endmodule