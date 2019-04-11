module prra #(
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
		prra2 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=4) begin :arb_gen
		prra4 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=8) begin :arb_gen
		prra8 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=16) begin :arb_gen
		prra16 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=32) begin :arb_gen
		prra32 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=64) begin :arb_gen
		prra64 arb(
			.request(request), 
			.grant(grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=128) begin :arb_gen
	prra128 arb(
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
	leaf_node

**************/


module leaf_node (
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
	inode

************/

module i_node(
	//top
	h_out,
	r_out,
	g_in,
	
	//down
	h_left_in,
	g_left_out,
	r_left_in,
	
	h_right_in,
	g_right_out,
	r_right_in

);


	output h_out, r_out, g_left_out, 	g_right_out;
	input  g_in,  h_left_in, 	r_left_in, h_right_in, r_right_in;
	
	assign h_out= h_left_in | h_right_in;
	assign r_out= r_right_in | (r_left_in & (~h_right_in));

	assign g_left_out= g_in &(
									(r_left_in & (~ r_right_in))| 
									(r_left_in & (~ h_right_in))| 
									(h_left_in & (~ r_right_in)));
									
	assign g_right_out= g_in &(
									((~h_left_in) & (~ r_left_in))| 		
									((~r_left_in) & r_right_in)| 									
									(h_right_in &  r_right_in));
																	
							


endmodule





/*************
	rnode

************/

module r_node(
		
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
	prra2
*****************/

module prra2_middle (
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
	
	
	
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);

wire set;

 leaf_node leaf1(
	.r_in(request[0]),
	.g_out(grant[0]),	
	.h_out(h_left),
	.r_out(r_left),
	.g_in(g_left),
	.set_in(set_in),
	.set_out(set),
	.reset(reset),
	.clk(clk)
);


 leaf_node leaf2(
	.r_in(request[1]),
	.g_out(grant[1]),	
	.h_out(h_right),
	.r_out(r_right),
	.g_in(g_right),
	.set_in(set),
	.set_out(set_out),
	.reset(reset),
	.clk(clk)
);



endmodule




	/****************
	top
	*****************/

module prra2 (
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
	
	
	
	
	

	wire h_left, g_left, r_left, h_right, g_right, r_right;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);

wire set_right,set_left;

 leaf_node left_leaf(
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


 leaf_node right_leaf(
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
		prra4
*****************/

module prra4_middle (
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
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
		
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	
	
	prra2_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	prra2_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module prra4 (
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
	
	
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	prra2_middle left_arb(
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


	
	prra2_middle right_arb(
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
		prra8
*****************/

module prra8_middle (
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
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	
	
	prra4_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	prra4_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module prra8 (
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
	
	
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	prra4_middle left_arb(
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


	
	prra4_middle right_arb(
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
		prra16
*****************/

module prra16_middle (
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
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	
	
	prra8_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	prra8_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module prra16 (
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
	
	
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	prra8_middle left_arb(
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


	
	prra8_middle right_arb(
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
		prra32
*****************/

module prra32_middle (
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
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	
	
	prra16_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	prra16_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module prra32 (
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
	
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	prra16_middle left_arb(
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


	
	prra16_middle right_arb(
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
		prra64
*****************/

module prra64_middle (
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
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	
	
	prra32_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	prra32_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module prra64 (
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
	
	
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	prra32_middle left_arb(
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


	
	prra32_middle right_arb(
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
		prra128
*****************/

module prra128_middle (
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
	i_node the_inode(
	//top
		.h_out(h_out),
		.r_out(r_out),
		.g_in(g_in),
	
	//down
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
);
	
	
	prra64_middle left_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[LEFT_HS:LEFT_LS]), 
		.grant(grant[LEFT_HS:LEFT_LS]),
	
		.h_out(h_left),
		.r_out(r_left),
		.g_in(g_left),
		.set_in(set_in),
		.set_out(set)
  
	);


	
	prra64_middle right_arb(
		.clk(clk), 
		.reset(reset), 
		.request(request[RIGHT_HS:RIGTH_LS]), 
		.grant(grant[RIGHT_HS:RIGTH_LS]),
	
		.h_out(h_right),
		.r_out(r_right),
		.g_in(g_right),
		.set_in(set),
		.set_out(set_out)
  
	);

	
endmodule





	/****************
		top
	*****************/

module prra128 (
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
	
	
	
	wire h_left, g_left, r_left, h_right, g_right, r_right;
	wire set_right,set_left;
	
	assign any_grant=|request;
	r_node root( 
		.h_left_in(h_left),
		.g_left_out(g_left),
		.r_left_in(r_left),	
		.h_right_in(h_right),
		.g_right_out(g_right),
		.r_right_in(r_right)
	);
	
	
	prra64_middle left_arb(
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


	
	prra64_middle right_arb(
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
		

	

	
	

	

