
    
    
/****************************************************************************
 * router_top.v
 ****************************************************************************/
  
/**
 * Module: router_top
 * 
 *  add optional bypass links to two stage router.
 */
module router_top 
		import pronoc_pkg::*;
        
	# (
		parameter P = 6     // router port num         
		)(
			current_r_addr,// connected to constant parameter  
        
			chan_in,
			chan_out,
        
			clk,
			reset

		);
  

   

	input [RAw-1 :  0]  current_r_addr;
    
	input   router_chanel_t chan_in [P-1 : 0];
	output  router_chanel_t chan_out [P-1 : 0];
	input   clk,reset;
	
	genvar i;
	
	flit_chanel_t r2_chan_in  [P-1 : 0];
	flit_chanel_t r2_chan_out [P-1 : 0];
	
	ivc_info_t 	 ivc_info    [P-1 : 0][V-1 : 0];
	iport_info_t iport_info  [P-1 : 0];
	oport_info_t oport_info  [P-1 : 0]; 
	sbp_chanel_t sbp_chanel  [P-1 : 0];

	router_two_stage  #(//r2
		.P (P)
	)router_ref (
			.ivc_info(ivc_info),
			.iport_info(iport_info),
			.oport_info(oport_info),
			.current_r_addr  (current_r_addr ), 
			.chan_in         (r2_chan_in     ), 
			.chan_out        (r2_chan_out    ), 
			.clk             (clk            ), 
			.reset           (reset          )			
	);                

	generate 
	if(SBP_EN) begin :sbp
		
		
		sbp_forward_ivc_info			
		#(
			.P(P)
		 )forward_sbp(			
				.ivc_info(ivc_info),
				.iport_info(iport_info),
				.oport_info(oport_info),
				.sbp_chanel(sbp_chanel),
				.ovc_alloc_is_not_allowed(),
				.reset(reset),
				.clk(clk)
		);
		
		for (i=0;i<P;i=i+1)begin : p_
			assign chan_out[i].sbp_chanel = sbp_chanel[i];		
		end
		
		
		
		
	end else begin :nosbp
		for (i=0;i<P;i=i+1)begin : p_
			assign r2_chan_in[i]   =  chan_in[i].flit_chanel;
			assign chan_out[i].flit_chanel     =  r2_chan_out[i];
		end//for
	end
	endgenerate	
endmodule 







/**********************************
The router top module that can be called in Verilog module. 
***********************************/

module router_top_v
	import pronoc_pkg::*;        
	# (
		parameter P = 5     // router port num         
	)(
	
		current_r_addr,
		neighbors_r_addr_in,
		neighbors_r_addr_out,
   
	    flit_in_all,
	    flit_in_wr_all,
	    credit_out_all,
	    congestion_in_all,
    
	    flit_out_all,
	    flit_out_wr_all,
	    credit_in_all,
	    congestion_out_all,
    
	    clk,reset

	);

	localparam 
		PRAw	=P * RAw,
    	PFw		=P * Fw,
    	PV		=P * V,
		PCONGw	=P * CONGw;


	input  [RAw-1 :  0]  current_r_addr;
    input  [PRAw-1:  0]  neighbors_r_addr_in;
    output [PRAw-1:  0]  neighbors_r_addr_out;

    input  [PFw-1 :  0]  flit_in_all;
    input  [P-1 :  0]  flit_in_wr_all;
    output [PV-1 :  0]  credit_out_all;
    input  [PCONGw-1 :  0]  congestion_in_all;
    
    output [PFw-1 :  0]  flit_out_all;
    output [P-1 :  0]  flit_out_wr_all;
    input  [PV-1 :  0]  credit_in_all;
    output [PCONGw-1 :  0]  congestion_out_all;
    
    input clk,reset;

//internal var
	router_chanel_t chan_in  [P-1 : 0];
	router_chanel_t chan_out [P-1 : 0];


	router_top # (
		.P(P)           
	)
	router
	(
		.current_r_addr(current_r_addr),          
		.chan_in (chan_in),
		.chan_out(chan_out),       
		.clk(clk),
		.reset(reset)
	);

	genvar i;
	generate
	for(i=0;i<P;i=i+1) begin: p
		assign chan_in[i].flit_chanel.flit 		= flit_in_all   [(i+1)*Fw-1 : i*Fw];
		assign chan_in[i].flit_chanel.flit_wr 	= flit_in_wr_all[i];
		assign chan_in[i].flit_chanel.credit 	= credit_in_all [(i+1)*V-1 : i*V];
		assign chan_in[i].flit_chanel.congestion 	= congestion_in_all [(i+1)*CONGw-1 : i*CONGw];
		assign chan_in[i].flit_chanel.neighbors_r_addr =neighbors_r_addr_in [(i+1)*RAw-1 : i*RAw];

		assign flit_out_all   [(i+1)*Fw-1 : i*Fw] = chan_out[i].flit_chanel.flit;
		assign flit_out_wr_all[i] = chan_out[i].flit_chanel.flit_wr;
		assign credit_out_all [(i+1)*V-1 : i*V] = chan_out[i].flit_chanel.credit;
		assign congestion_out_all [(i+1)*CONGw-1 : i*CONGw] = chan_out[i].flit_chanel.congestion;
		assign neighbors_r_addr_out [(i+1)*RAw-1 : i*RAw] = chan_out[i].flit_chanel.neighbors_r_addr;

	end
	endgenerate 


endmodule 


