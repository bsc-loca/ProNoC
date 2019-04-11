module arbiter_mux (
	clk,
	reset,
	request,
	mux_in,
	//any_grant,
	out

);

	`define  INCLUDE_PARAM
	`include "param.v"

	input clk, reset;
	input		[ARBITER_WIDTH-1 			:	0] mux_in,request;
	output	reg out;
	//output  reg any_grant;
	
	wire		[ARBITER_WIDTH-1 			:	0] grant;
	//wire any_grant_next;
	wire out_next;
	reg [ARBITER_WIDTH-1 			:	0] mux_in_reg,request_reg;


	arbiter  #(
		.ARBITER_WIDTH(ARBITER_WIDTH),
		.ARBITER_NAME(ARBITER_NAME)
	)arb_comb
	(	
		.clk(clk), 
		.reset(reset), 
		.request(request_reg), 
		.grant(grant),
		//.any_grant(any_grant_next)
		.any_grant()
	);


	one_hot_mux #(
        	.IN_WIDTH(ARBITER_WIDTH),
        	.SEL_WIDTH(ARBITER_WIDTH)

	)mux(
        	.mux_in(mux_in_reg),
        	.mux_out(out_next),
        	.sel(grant)

    	);


	always @(posedge clk or posedge reset)begin 
		if(reset)begin 
			request_reg	<={ARBITER_WIDTH{1'b0}};
			mux_in_reg	<={ARBITER_WIDTH{1'b0}};
			out		<=1'b0;
			//any_grant	<=1'b0;
		end else begin 
			request_reg	<=request;
			mux_in_reg	<=mux_in;
			out		<=out_next;
			//any_grant	<=any_grant_next;

		end
	end



endmodule










/*********************************

    multiplexer
    
********************************/

module one_hot_mux #(
        parameter   IN_WIDTH      = 20,
        parameter   SEL_WIDTH =   5, 
        parameter   OUT_WIDTH = IN_WIDTH/SEL_WIDTH

    )
    (
        input [IN_WIDTH-1       :0] mux_in,
        output[OUT_WIDTH-1  :0] mux_out,
        input[SEL_WIDTH-1   :0] sel

    );

    wire [IN_WIDTH-1    :0] mask;
    wire [IN_WIDTH-1    :0] masked_mux_in;
    wire [SEL_WIDTH-1:0]    mux_out_gen [OUT_WIDTH-1:0]; 
    
    genvar i,j;
    
    //first selector masking
    generate    // first_mask = {sel[0],sel[0],sel[0],....,sel[n],sel[n],sel[n]}
        for(i=0; i<SEL_WIDTH; i=i+1) begin : mask_loop
            assign mask[(i+1)*OUT_WIDTH-1 : (i)*OUT_WIDTH]  =   {OUT_WIDTH{sel[i]} };
        end
        
        assign masked_mux_in    = mux_in & mask;
        
        for(i=0; i<OUT_WIDTH; i=i+1) begin : lp1
            for(j=0; j<SEL_WIDTH; j=j+1) begin : lp2
                assign mux_out_gen [i][j]   =   masked_mux_in[i+OUT_WIDTH*j];
            end
            assign mux_out[i] = | mux_out_gen [i];
        end
    endgenerate
    
endmodule



