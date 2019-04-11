module arbiter_top
(	
   clk, 
   reset, 
   request, 
   grant,
   any_grant
	
);
	
	`define  INCLUDE_PARAM
	`include "param.v"

		

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output reg	[ARBITER_WIDTH-1			:	0]	grant;
	output reg								any_grant;
	input									clk;
	input									reset;
	
	
	reg		[ARBITER_WIDTH-1 			:	0]	request_reg;
	wire	[ARBITER_WIDTH-1			:	0]	grant_o;
	wire											any_grant_o;

	
	always @(posedge clk or posedge reset) begin 
		if(reset)begin 
			request_reg<= 0;
			grant<= 0;
			any_grant<=0;
		end else begin 
			request_reg<= request;
			grant<= grant_o;
			any_grant<=any_grant_o;
				
		end
	
	end


	arbiter #(
		.ARBITER_WIDTH(ARBITER_WIDTH),
		.ARBITER_NAME(ARBITER_NAME)
	)arb_comb
	(	
   		.clk(clk), 
   		.reset(reset), 
   		.request(request_reg), 
   		.grant(grant_o),
   		.any_grant(any_grant_o)
	);




endmodule











module arbiter #(
	parameter ARBITER_WIDTH=32,
	parameter ARBITER_NAME="ppe"
)
(	
   clk, 
   reset, 
   request, 
   grant,
   any_grant
	
);

		

	
	input		[ARBITER_WIDTH-1 			:	0]	request;
	output 		[ARBITER_WIDTH-1			:	0]	grant;
	output 									any_grant;
	input									clk;
	input									reset;
	
	
	



	generate 
	if	   (ARBITER_NAME=="ppe") begin :ppe

		ppe #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
			.clk	(clk), 
		   	.reset(reset), 
		   	.request(request), 
		   	.grant(grant),
		   	.any_grant(any_grant)	
	
		);

	end else if(ARBITER_NAME=="ping_pong") begin :ping_pong

		ping_arbiter #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		   .clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);


	end else if(ARBITER_NAME=="ping_lock") begin :ping_lock
		ping_lock #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);

		
	end else if(ARBITER_NAME=="tca") begin :tca

		tca #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);

	end else if(ARBITER_NAME=="fra") begin :fra
		fra #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);

	end else if(ARBITER_NAME=="hdra") begin :hdra
		hdra #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);

	end else if(ARBITER_NAME=="prra") begin :prra
		prra #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);

	end else if(ARBITER_NAME=="iprra") begin :iprra
		iprra #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);

	end else if(ARBITER_NAME=="ping_org") begin  :ping_org
	
		ping_org #(
			.ARBITER_WIDTH(ARBITER_WIDTH)
		
		)
		uut
		(	
		.clk	(clk), 
		   .reset(reset), 
		   .request(request), 
		   .grant(grant),
		   .any_grant(any_grant)
	
	
		);
	
	
	
	end


	endgenerate

		
	
endmodule	
	
