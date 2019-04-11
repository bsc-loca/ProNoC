


module ping_arbiter #(
		parameter	ARBITER_WIDTH	=16
		
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
		ping_arbiter_2 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk),
			.mask()
		);
	end else if(ARBITER_WIDTH<=4) begin :arb_gen
		ping_arbiter_4 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=8) begin :arb_gen
		ping_arbiter_8 arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=16) begin :arb_gen
		ping_arbiter_16 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=32) begin :arb_gen
		ping_arbiter_32 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=64) begin :arb_gen
		ping_arbiter_64 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=128) begin :arb_gen
		ping_arbiter_128 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end else if(ARBITER_WIDTH<=256) begin :arb_gen
		ping_arbiter_256 #(
			.ARBITER_W(ARBITER_WIDTH)		
		)arb(
			.request(request), 
			.grant(grant),
			.priority_en(any_grant),
			.any_grant(any_grant),
			.reset(reset),
			.clk(clk)
		);
	end

endgenerate	
	
	
	
endmodule	




module ping_arbiter_2 #(
	parameter ARBITER_W=2//1~2

)(
   request, 
   grant,
	mask,
   priority_en,
   any_grant,
   reset,
   clk	
);


	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
	output		[ARBITER_W-1	:0]	mask;
 	input 					priority_en;
	output 					any_grant;
	input 					reset,clk;
	reg						priority_reg; 
	//wire						g0,g1;
	
generate 
if(ARBITER_W==2)begin 	
	always @(posedge clk or posedge reset)begin 
		if(reset) begin 
			priority_reg<=1'b0;
		end else  begin 
			if(priority_en) priority_reg<= grant[0];		
		end	
	end
	
	assign 				any_grant=|request;
	nand nand0 (mask[0], request[1] ,  priority_reg);
	nand nand1 (mask[1], request[0] ,  ~priority_reg); 
	assign 				grant[0]= request[0] & mask[0];
	assign 				grant[1]= request[1] & mask[1];
	
end else begin //width ==1	
		assign 	any_grant= request[0];
		assign  grant[0]=  request[0];
		assign  mask[0]=   request[0];
end
endgenerate

endmodule



module ping_arbiter_4 #(
	parameter ARBITER_W=4 // 3~4

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	localparam MAX_ARB_WIDTH=4;

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 


	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk),
		.mask()
	);
	
	 
	 
	  ping_arbiter_2  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk),
		.mask()
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	





module ping_arbiter_8 #(
	parameter ARBITER_W=8 // 5~8

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	localparam MAX_ARB_WIDTH=8;

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 

	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_4  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk)
	);
	
	 
	 
	  ping_arbiter_4  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk)
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(  
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	





module ping_arbiter_16 #(
	parameter ARBITER_W=16 // 9~16

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 


	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_8  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk)
	);
	
	 
	 
	  ping_arbiter_8  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk)
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(  
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	







module ping_arbiter_32 #(
	parameter ARBITER_W=32 // 17~32

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	localparam MAX_ARB_WIDTH=32;

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 


	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_16  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk)
	);
	
	 
	 
	  ping_arbiter_16  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk)
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(  
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	




module ping_arbiter_64 #(
	parameter ARBITER_W=64 // 33~64

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	localparam MAX_ARB_WIDTH=64;

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 


	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_32  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk)
	);
	
	 
	 
	  ping_arbiter_32  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk)
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(  
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	



module ping_arbiter_128 #(
	parameter ARBITER_W=128 // 65~128

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	localparam MAX_ARB_WIDTH=128;

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 


	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_64  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk)
	);
	
	 
	 
	  ping_arbiter_64  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk)
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(  
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	





module ping_arbiter_256 #(
	parameter ARBITER_W=256 // 129~256

)(
	request, 
   grant,
   priority_en,
	any_grant,
	reset,
	clk
);

	localparam MAX_ARB_WIDTH=256;

	
	input 		[ARBITER_W-1	:0] 	request;
	output 		[ARBITER_W-1	:0] 	grant;
 	input 									priority_en;
	output 									any_grant;
	input										reset,clk;

	
	localparam FIRST_ARB_W= (ARBITER_W/2); 
	localparam SECOND_ARB_W= ARBITER_W-FIRST_ARB_W; 


	
	
	wire [1: 0] any_grant_first,grant_second,mask;
	wire [ARBITER_W-1	:0] grant_first;
	wire  priority_en1,priority_en2;
	assign priority_en1= priority_en & mask[0];
	assign priority_en2= priority_en & mask[1];
	
	
	 ping_arbiter_128  #(
		.ARBITER_W(FIRST_ARB_W)
	 )arb1(
		.request(request[FIRST_ARB_W-1	:0] ), 
		.grant(grant_first [FIRST_ARB_W-1	:0]),
		.priority_en(priority_en1),
		.any_grant(any_grant_first[0]),
		.reset(reset),
		.clk(clk)
	);
	
	 
	 
	  ping_arbiter_128  #(
		.ARBITER_W(SECOND_ARB_W)
	  )arb2(
		.request(request[ARBITER_W-1	:FIRST_ARB_W] ), 
		.grant(grant_first [ARBITER_W-1	:FIRST_ARB_W]),
		.priority_en(priority_en2),
		.any_grant(any_grant_first[1]),
		.reset(reset),
		.clk(clk)
	);
	
	
	
	 ping_arbiter_2  #(
		.ARBITER_W(2)
	  )arb3(  
		.mask(mask),
		.request(any_grant_first ), 
		.grant(grant_second),
		.priority_en(priority_en),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)
	);
	
	assign grant[FIRST_ARB_W-1:0]= grant_first[FIRST_ARB_W-1:0] & {FIRST_ARB_W{mask[0]}};
	assign grant[ARBITER_W-1:FIRST_ARB_W]= grant_first[ARBITER_W-1:FIRST_ARB_W] & {SECOND_ARB_W{mask[1]}};
	
endmodule	







