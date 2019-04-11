module hdra #(
	parameter ARBITER_WIDTH=32
	)(
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
	if(ARBITER_WIDTH==2)begin :arb_gen			
		hdra2 arb(clk,reset, request, grant, any_grant);
   end else if(ARBITER_WIDTH==4)begin :arb_gen			
		hdra4 arb(clk,reset, request, grant, any_grant);
	end else if(ARBITER_WIDTH==8)begin :arb_gen			
		hdra8 arb(clk,reset, request, grant, any_grant);
	end else if(ARBITER_WIDTH==16)begin :arb_gen			
		hdra16 arb(clk,reset, request, grant, any_grant);
	end else if(ARBITER_WIDTH==32)begin :arb_gen			
		hdra32 arb(clk,reset, request, grant, any_grant);
	end else if(ARBITER_WIDTH==64)begin :arb_gen			
		hdra64 arb(clk,reset, request, grant, any_grant);
	end else if(ARBITER_WIDTH==128)begin :arb_gen			
		hdra128 arb(clk,reset, request, grant, any_grant);
	end else if(ARBITER_WIDTH==256)begin :arb_gen			
		hdra256 arb(clk,reset, request, grant, any_grant);
	end
	
	
	endgenerate





endmodule



/*************
	hdra2
*************/

module hdra2 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=2;
	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;



		reg [3:0] r;
		wire [3:0]g;
		assign 	grant = g[1			:	0];
		always @(*)begin
			 r=4'd0;
			 r[1			:	0]=request;
		end
		
	
		leaf_ckt arb4 (
			.r(r),
			.g(g),
			.ack(any_grant),
			.self_reset(any_grant),
			.r_next(any_grant),
			.clk(clk),
			.reset(~reset)
		);
endmodule

/********
	hdra4
*********/

module hdra4 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=4;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
		leaf_ckt arb4 (
			.r(request),
			.g(grant),
			.ack(any_grant),
			.self_reset(any_grant),
			.r_next(any_grant),
			.clk(clk),
			.reset(~reset)
		);
endmodule



/********
	hdra8
*********/

module hdra8 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=8;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
		

	hdra_leaf #(
		.LEAF_NUM(2)//2,4
	)leaf
	(
		//top
		.ack_in(any_grant),
		.r_next(any_grant),
		.self_reset(any_grant),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request), 
		.grant(grant)
		
);


endmodule





/********
	hdra16
*********/

module hdra16 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=16;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
		

	hdra_leaf #(
		.LEAF_NUM(4)//2,4
	)leaf
	(
		//top
		.ack_in(any_grant),
		.r_next(any_grant),
		.self_reset(any_grant),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request), 
		.grant(grant)
		
);


endmodule



/********
	hdra32
*********/

module hdra32 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=32;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
		

	hdra_leaf_two #(
		.LEAF_NUM(2)
	)leaf
	(
		//top
		.ack_in(any_grant),
		.r_next(any_grant),
		.self_reset(any_grant),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request), 
		.grant(grant)
		
);

endmodule




/********
	hdra64
*********/

module hdra64 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=64;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
		

	hdra_leaf_two #(
		.LEAF_NUM(4)//2,4
	)leaf
	(
		//top
		.ack_in(any_grant),
		.r_next(any_grant),
		.self_reset(any_grant),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request), 
		.grant(grant)
		
);

endmodule




/********
	hdra128
*********/

module hdra128 (
	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=128;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

	
		

	hdra_leaf_three #(
		.LEAF_NUM(2)//2,4
	)leaf
	(
		//top
		.ack_in(any_grant),
		.r_next(any_grant),
		.self_reset(any_grant),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request), 
		.grant(grant)
		
);

endmodule




/********
	hdra256
*********/

module hdra256 (	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	localparam  ARBITER_WIDTH=256;

	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												reset,clk;

		

	hdra_leaf_three #(
		.LEAF_NUM(4)//2,4
	)
	leaf
	(
		//top
		.ack_in(any_grant),
		.r_next(any_grant),
		.self_reset(any_grant),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request), 
		.grant(grant)
		
);

endmodule








/*************
	hdra_leaf 
*************/


module hdra_leaf #(
	parameter LEAF_NUM=2 //2,4
)(
	//top
	ack_in,
	r_next,
	self_reset,
	
	//down
	clk, 
   reset, 
   request, 
   grant
	
	
);

	localparam  ARBITER_WIDTH=4*LEAF_NUM;
	//top
	input 	ack_in;
	output 	r_next;
	input    self_reset;


	//down
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;

	wire [LEAF_NUM-1	:	0] leaf_r_next, leaf_sr,leaf_ack;
	
	
	//
	inter_ckt # (
		.WIDTH(LEAF_NUM)
	)
	inode
	(
		.request(leaf_r_next),
		.ack_in(ack_in),
		.ack_out(leaf_ack),
		.request_next(r_next)
	);
	
	
	
	//leafs
	genvar i;
	generate
	for(i=0;i<LEAF_NUM;i=i+1)begin :leaf_lp
		leaf_ckt leaf (
			.r(request[(i+1)*4-1	: i*4]),
			.g(grant[(i+1)*4-1	: i*4]),
			.ack(leaf_ack[i]),
			.self_reset(self_reset),
			.r_next(leaf_r_next[i]),
			.clk(clk),
			.reset(~reset)
		);
	end
	endgenerate
	
	
	
endmodule


/**************
	
	hdra_leaf_two

**************/


module hdra_leaf_two #(
	parameter LEAF_NUM=2 //2,4
)(
	//top
	ack_in,
	r_next,
	self_reset,
	
	//down
	clk, 
   reset, 
   request, 
   grant
	
	
);

	localparam  ARBITER_WIDTH=4*4*LEAF_NUM;
	//top
	input 	ack_in;
	output 	r_next;
	input    self_reset;


	//down
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;

	wire [LEAF_NUM-1	:	0] leaf_r_next, leaf_sr,leaf_ack;
	
	
	//
	inter_ckt # (
		.WIDTH(LEAF_NUM)
	)
	inode
	(
		.request(leaf_r_next),
		.ack_in(ack_in),
		.ack_out(leaf_ack),
		.request_next(r_next)
	);
	
	
	
	
	//leafs
	genvar i;
	generate
	for(i=0;i<LEAF_NUM;i=i+1)begin :leaf_lp
	
	hdra_leaf #(
		.LEAF_NUM(4)
	)leaf_one(
		//top
		.ack_in(leaf_ack[i]),
		.r_next(leaf_r_next[i]),
		.self_reset(self_reset),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request[(i+1)*16-1	: i*16]), 
		.grant(grant[(i+1)*16-1	: i*16])
	);
	
	end
	endgenerate
	
	
endmodule 



/**************
	
	hdra_leaf_two

**************/


module hdra_leaf_three #(
	parameter LEAF_NUM=2 //2,4
)(
	//top
	ack_in,
	r_next,
	self_reset,
	
	//down
	clk, 
   reset, 
   request, 
   grant
	
	
);

	localparam  ARBITER_WIDTH=4*4*4*LEAF_NUM;
	//top
	input 	ack_in;
	output 	r_next;
	input    self_reset;


	//down
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	input												reset,clk;

	wire [LEAF_NUM-1	:	0] leaf_r_next, leaf_sr,leaf_ack;
	
	
	//
	inter_ckt # (
		.WIDTH(LEAF_NUM)
	)
	inode
	(
		.request(leaf_r_next),
		.ack_in(ack_in),
		.ack_out(leaf_ack),
		.request_next(r_next)
	);
	
	
	
	
	//leafs
	genvar i;
	generate
	for(i=0;i<LEAF_NUM;i=i+1)begin :leaf_lp
	
	hdra_leaf_two #(
		.LEAF_NUM(4)
	)leaf_two(
		//top
		.ack_in(leaf_ack[i]),
		.r_next(leaf_r_next[i]),
		.self_reset(self_reset),
	
		//down
		.clk(clk), 
		.reset(reset), 
		.request(request[(i+1)*64-1	: i*64]), 
		.grant(grant[(i+1)*64-1	: i*64])
	);
	
	end
	endgenerate
	
	
endmodule 








module reg_block(
	clk,
	reset,
	r,
	ack,
	q_in,
	out

);


	input clk, reset, r, ack,q_in; 
	output out;

	reg q;
		
	always @ (posedge clk or posedge reset)begin 
		if(reset) q<= 1'b0;
		else begin 
			if(ack)q<= q_in;
		end	
	end
	
	nor nor1 (out, ~r ,q);

endmodule


module leaf_ckt (
	r,
	g,
	ack,
	self_reset,
	r_next,
	clk,
	reset
);

	input [3:0]	r;
	output[3:0] g;
	input 		ack,self_reset,clk,reset;
	output 		r_next;
	
	wire reset_comb;
	wire [3:0]	reg_out,reg_in;
	nand	nand_rst(reset_comb,self_reset,reset);
	
	genvar i;
	generate
	for (i=0;i<4;i=i+1)begin : gen_reg
		reg_block reg_blk(
			.clk(clk),
			.reset(reset_comb),
			.r(r[i]),
			.ack(ack),
			.q_in(reg_in[i]),
			.out(reg_out[i])
		);
	end
	endgenerate

	// g0
	assign g[0]= ack & reg_out[0];
	assign reg_in[0]= 1'b1;
	
	wire [3:1] nand_gates, or_gates,nor_gates;
	
	//g1
	nand nand1 (nand_gates[1], reg_out[1],reg_out[0]);
	or	  or1	  (or_gates[1], reg_out[1],reg_out[0]);
	nor  nor1  (nor_gates[1], ~reg_out[1],reg_out[0]);
	assign g[1]= ack & nor_gates[1];
	
	//g2
	nand nand2 (nand_gates[2], reg_out[2],or_gates[1]);
	or	  or2	  (or_gates[2], reg_out[2],or_gates[1]);
	nor  nor2  (nor_gates[2], ~reg_out[2],or_gates[1]);
	assign g[2]= ack & nor_gates[2];
	
	//g3
	nand nand3 (nand_gates[3], reg_out[3],or_gates[2]);
	or	  or3	  (or_gates[3], reg_out[3],reg_out[2]);
	nor  nor3  (nor_gates[3], ~reg_out[3],or_gates[2]);
	assign g[3]= ack & nor_gates[3];
	
	assign reg_in[3:1]=nand_gates;
	
	//r_next
	assign r_next = or_gates[3] | or_gates[1];
	
	
endmodule




module inter_ckt # (
	parameter WIDTH=4
)(
	request,
	ack_in,
	ack_out,
	request_next
);

	input [WIDTH-1	:	0] request;
	input 					ack_in;
	output [WIDTH-1:	0]	ack_out;
	output 					request_next;
	
	wire [WIDTH-1	:	0] or_gates,nor_gates;
	assign or_gates[0]=request[0];
	assign nor_gates[0]=request[0];
	
	
	genvar i;
	generate
	for (i=1;i<WIDTH;i=i+1)begin : gen_reg
		or or1	(or_gates[i],request[i],or_gates[i-1]);
		nor nor1	(nor_gates[i],~request[i],or_gates[i-1]);
		and (ack_out[i],ack_in, nor_gates[i]); 
	end
	endgenerate
	and (ack_out[0],ack_in, nor_gates[0]); 
	
	assign request_next =  or_gates [WIDTH-1];
	
endmodule








