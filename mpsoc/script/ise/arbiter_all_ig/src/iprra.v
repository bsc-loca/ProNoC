module iprra #(
		parameter	ARBITER_WIDTH	=32
		
)
(	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	function integer log2;
      input integer number;	begin	
         log2=0;	
         while(2**log2<number) begin	
            log2=log2+1;	
         end	
      end	
   endfunction // log2 
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
	generate 
	if(ARBITER_WIDTH<=2) begin :arb_gen
		iprra2 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=4) begin :arb_gen
		iprra4 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=8) begin :arb_gen
		iprra8 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=16) begin :arb_gen
		iprra16 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=32) begin :arb_gen
		iprra32 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=64) begin :arb_gen
		iprra64 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=128) begin :arb_gen
		iprra128 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end

endgenerate	
	
	
	
endmodule	








/**************
	ileaf_node

**************/


module ileaf_node (
	r_in,
	g_out,	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out,
	reset,
	clk
);

	
	input r_in,	g_in,	set_in,	reset, clk;
	output g_out, 	h_out, 	r_out, set_out;	
	reg h;
	
	assign r_out = r_in;
	assign g_out = r_in & g_in;
	assign set_out = g_out;
	assign h_out = h;
	
	always @(posedge clk or posedge reset)begin 
		if(reset) begin 
			h<=1'b0;		
		end else begin 
			h<=set_in;
		end	
	end


endmodule


/*************
	iinode

************/

module ii_node(
	//top
	h_out,
	r_out,
	
	
	//down
	h_left_in,
	g_left_out,
	r_left_in,
	
	h_right_in,
	g_right_out,
	r_right_in

);


	output h_out, r_out, g_left_out, 	g_right_out;
	input  h_left_in, 	r_left_in, h_right_in, r_right_in;
	
	assign h_out= h_left_in | h_right_in;
	assign r_out= r_right_in | (r_left_in & (~h_right_in));

	assign g_left_out= (
									(r_left_in & (~ r_right_in))| 
									(r_left_in & (~ h_right_in))| 
									(h_left_in & (~ r_right_in)));
									
	assign g_right_out= (
									((~h_left_in) & (~ r_left_in))| 		
									((~r_left_in) & r_right_in)| 									
									(h_right_in &  r_right_in));
																	
							


endmodule





/*************
	irnode

************/

module ir_node(
	
	
	//down
	h_left_in,
	g_left_out,
	r_left_in,
	
	h_right_in,
	g_right_out,
	r_right_in

);


	output g_left_out, 	g_right_out;
	input  h_left_in, 	r_left_in, h_right_in, r_right_in;

	
	assign g_left_out= (
									(r_left_in & (~ r_right_in))| 
									(r_left_in & (~ h_right_in))| 
									(h_left_in & (~ r_right_in)));
									
	assign g_right_out= (
									((~h_left_in) & (~ r_left_in))| 		
									((~r_left_in) & r_right_in)| 									
									(h_right_in &  r_right_in));
																	
							


endmodule






/****************
	iprra2
*****************/

module iprra2_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=2;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	
	
	
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);

wire set;
wire new_g_left = g_in & g_left;
wire new_g_right = g_in & g_right;

 ileaf_node leaf1(
	.r_in(request[0]),
	.g_out(grant[0]),	
	.h_out(h_left),
	.r_out(r_left),
	.g_in(new_g_left),
	.set_in(set_in),
	.set_out(set),
	.reset(reset),
	.clk(clk)
);


 ileaf_node leaf2(
	.r_in(request[1]),
	.g_out(grant[1]),	
	.h_out(h_right),
	.r_out(r_right),
	.g_in(new_g_right),
	.set_in(set),
	.set_out(set_out),
	.reset(reset),
	.clk(clk)
);



endmodule




	/****************
	top
	*****************/

module iprra2 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	 
);

	localparam 	ARBITER_WIDTH	=2;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign any_grant = | request;
	
	
	

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	
	
	ir_node root(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);

wire set_right,set_left;

 ileaf_node left_leaf(
	.r_in(request[1]),
	.g_out(grant[1]),	
	.h_out(h_left),
	.r_out(r_left),
	.g_in(g_left),
	.set_in(set_right),
	.set_out(set_left),
	.reset(reset),
	.clk(clk)
);


 ileaf_node right_leaf(
	.r_in(request[0]),
	.g_out(grant[0]),	
	.h_out(h_right),
	.r_out(r_right),
	.g_in(g_right),
	.set_in(set_left),
	.set_out(set_right),
	.reset(reset),
	.clk(clk)
);




endmodule






/****************
		iprra4
*****************/

module iprra4_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=4;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set;
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	wire new_g_left = g_in & g_left;
	wire new_g_right = g_in & g_right;
	
	iprra2_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(new_g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	iprra2_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(new_g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module iprra4 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	
  
);

	localparam 	ARBITER_WIDTH	=4;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign 											any_grant=|request;
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	ir_node the_inode(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	iprra2_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_right),
		.set_out(set_left)
  
	);


	
	iprra2_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set_left),
		.set_out(set_right)
  
	);


endmodule	




/****************
		iprra8
*****************/

module iprra8_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=8;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set;
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	wire new_g_left = g_in & g_left;
	wire new_g_right = g_in & g_right;
	
	iprra4_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(new_g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	iprra4_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(new_g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module iprra8 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	
  
);

	localparam 	ARBITER_WIDTH	=8;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign 											any_grant=|request;
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	ir_node the_inode(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	iprra4_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_right),
		.set_out(set_left)
  
	);


	
	iprra4_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set_left),
		.set_out(set_right)
  
	);


endmodule	




/****************
		iprra16
*****************/

module iprra16_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=16;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set;
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	wire new_g_left = g_in & g_left;
	wire new_g_right = g_in & g_right;
	
	iprra8_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(new_g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	iprra8_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(new_g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module iprra16 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	
  
);

	localparam 	ARBITER_WIDTH	=16;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign 											any_grant=|request;
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	ir_node the_inode(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	iprra8_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_right),
		.set_out(set_left)
  
	);


	
	iprra8_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set_left),
		.set_out(set_right)
  
	);


endmodule	





/****************
		iprra32
*****************/

module iprra32_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=32;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set;
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	wire new_g_left = g_in & g_left;
	wire new_g_right = g_in & g_right;
	
	iprra16_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(new_g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	iprra16_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(new_g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module iprra32 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	
  
);

	localparam 	ARBITER_WIDTH	=32;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign 											any_grant=|request;
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	ir_node the_inode(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	iprra16_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_right),
		.set_out(set_left)
  
	);


	
	iprra16_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set_left),
		.set_out(set_right)
  
	);


endmodule	





/****************
		iprra64
*****************/

module iprra64_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=64;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set;
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	wire new_g_left = g_in & g_left;
	wire new_g_right = g_in & g_right;
	
	iprra32_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(new_g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	iprra32_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(new_g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module iprra64 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	
  
);

	localparam 	ARBITER_WIDTH	=64;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign 											any_grant=|request;
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	ir_node the_inode(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	iprra32_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_right),
		.set_out(set_left)
  
	);


	
	iprra32_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set_left),
		.set_out(set_right)
  
	);


endmodule	






/****************
		iprra128
*****************/

module iprra128_middle (
	clk, 
   reset, 
   request, 
   grant,
	
	h_out,
	r_out,
	g_in,
	set_in,
	set_out
  
);

	localparam 	ARBITER_WIDTH	=128;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	
	output h_out, r_out,set_out;
	input  g_in,set_in;

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set;
	ii_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	wire new_g_left = g_in & g_left;
	wire new_g_right = g_in & g_right;
	
	iprra64_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(new_g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	iprra64_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(new_g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module iprra128 (
	clk, 
   reset, 
   request, 
   grant,
	any_grant
	
  
);

	localparam 	ARBITER_WIDTH	=128;
	
	localparam LEFT_HS  	= ARBITER_WIDTH-1,
				  LEFT_LS 	= ARBITER_WIDTH/2,
				  RIGHT_HS  = (ARBITER_WIDTH/2)-1,
				  RIGTH_LS 	= 0;
	

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;
	output 											any_grant;
	
	assign 											any_grant=|request;
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	ir_node the_inode(
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	iprra64_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_right),
		.set_out(set_left)
  
	);


	
	iprra64_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set_left),
		.set_out(set_right)
  
	);


endmodule	















