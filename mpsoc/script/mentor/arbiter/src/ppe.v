`timescale 1ns/1ns

module ppe #(
		parameter	ARBITER_WIDTH	=32
		
)
(	
	clk, 
   reset, 
   request, 
   grant,
   any_grant
	
);


	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output	[ARBITER_WIDTH-1			:	0]	grant;
	output											any_grant;
	input												clk;
	input												reset;
	
	
	wire		[ARBITER_WIDTH-1 			:	0]	request1,request2,grant1,grant2,grant1_masked;
	wire												any_grant1,any_grant2;
	reg 		[ARBITER_WIDTH-1 			:	0] mask;
	wire 		[ARBITER_WIDTH-1 			:	0] next_priority,mask_next;
	
	fixed_priority_arbiter #(
		.ARBITER_WIDTH(ARBITER_WIDTH)
	)
	arb1
	(	
		.request(request1), 
		.grant(grant1),
		.any_grant(any_grant1)	
	);
	
	
	fixed_priority_arbiter #(
		.ARBITER_WIDTH(ARBITER_WIDTH)
	)
	arb2
	(	

		.request(request2), 
		.grant(grant2),
		.any_grant(any_grant2)
	
	);
	
	assign next_priority= {grant[ARBITER_WIDTH-2:0],grant[ARBITER_WIDTH-1]};
		
		 
	//thermo meter coder
	han_carison_pe#(
		.WIDTH(ARBITER_WIDTH)
	)
	thermo_coder
	(
		.in(next_priority),
		.out(mask_next)
	);
	 
	
	
	always @(posedge clk or posedge reset) begin 
		if(reset) begin 
			mask<= {ARBITER_WIDTH{1'b1}};
		end else begin 
			if(any_grant) mask<= mask_next;	
		end
	end
	 
	
	assign request1=request;
	assign any_grant=any_grant1;
	assign request2=request & mask;
	
	//	assign grant= (any_grant2)? grant2:   grant1;
	
	assign grant1_masked= grant1 &{ARBITER_WIDTH{~any_grant2}};	
	assign grant= grant1_masked |  grant2;
	

	
endmodule


/*******************************

	fixed_priority_arbiter 

*****************************/



module fixed_priority_arbiter #(
	parameter	ARBITER_WIDTH	=16
)
(	

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

		
	wire [ARBITER_WIDTH-1 			:	0] invalid_requests,termo_code;
	
	assign invalid_requests[0] =	0;
	
	han_carison_pe#(
		.WIDTH(ARBITER_WIDTH)
	)
	thermo_coder
	(
		.in(request),
		.out(termo_code)
	);
	
	
	assign {any_grant,invalid_requests} = {termo_code,1'b0};
	assign grant= request & ~invalid_requests;
	
endmodule	
