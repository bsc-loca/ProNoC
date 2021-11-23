`timescale     1ns/1ps

module fixed_priority_arbiter_testbench;
// parameters
	 parameter HIGH_PRORITY_BIT =  "LSB" ;
	 parameter ARBITER_WIDTH = 8;

// Ports
	 wire  any_grant;
	 wire [ARBITER_WIDTH-1:0] grant;
	 reg [ARBITER_WIDTH-1:0] request;

// top module instance
 	 fixed_priority_arbiter #(
		.HIGH_PRORITY_BIT(HIGH_PRORITY_BIT),
		.ARBITER_WIDTH(ARBITER_WIDTH)
	)
	uut
	(
		.any_grant(any_grant),
		.grant(grant),
		.request(request)
	);

initial begin
	 request=0;

 //write your testbench code here
 


end //initial 
endmodule
