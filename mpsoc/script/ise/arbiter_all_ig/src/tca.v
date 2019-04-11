module tca #(
 parameter	ARBITER_WIDTH	=4
		
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
	input												reset,clk;
	
	
	wire		[ARBITER_WIDTH-1 			:	0]	termo1,termo2,mux_out,masked_request,edge_mask;
	reg		[ARBITER_WIDTH-1 			:	0]	pr;

	assign masked_request= request & pr;

	thermo_gen #(
		.WIDTH(ARBITER_WIDTH)
	) tm1
	(
		.in(request),
		.out(termo1)
	);




	thermo_gen #(
		.WIDTH(ARBITER_WIDTH)
	) tm2
	(
		.in(masked_request),
		.out(termo2)
	);

wire termo2_any_grant;
assign termo2_any_grant=termo2[ARBITER_WIDTH-1];
	
//assign mux_out= (termo1 & {ARBITER_WIDTH{~termo2_any_grant}}) | termo2;
assign mux_out= (termo2_any_grant)? termo2 : termo1;





assign any_grant=termo1[ARBITER_WIDTH-1];

always @(posedge clk or posedge reset)begin 
	if(reset) pr<= {ARBITER_WIDTH{1'b1}};
	else begin 
		if(any_grant) pr<= edge_mask;
	end

end

assign edge_mask= {mux_out[ARBITER_WIDTH-2:0],1'b0};
assign grant= mux_out ^ edge_mask;



endmodule
	
	
	
/*******************

	thermo_gen

*******************/

module thermo_gen #(
	parameter WIDTH=16


)(
	input  [WIDTH-1	:	0]in,
	output [WIDTH-1	:	0]out
);
	
	han_carison_pe#(
		.WIDTH(WIDTH)
	)pe
	(
		.in(in),
		.out(out)
	);

endmodule



	
	
/*******************

	thermo_gen



module thermo_gen #(
	parameter WIDTH=16


)(
	input  [WIDTH-1	:	0]in,
	output [WIDTH-1	:	0]out
);
	genvar i;
	generate
	for(i=0;i<WIDTH;i=i+1'b1)begin :lp
		assign out[i]= | in[i	:0];	
	end
	endgenerate

endmodule

********************/
