
    
    
/****************************************************************************
 * router_top.v
 ****************************************************************************/
  
/**
 * Module: router_top
 * 
 *  add optinal bypass links to two stage router.
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
    
	input   router_channel_t chan_in [P-1 : 0];
	output  router_channel_t chan_out [P-1 : 0];
	input   clk,reset;




	router_two_stage  #(
			.P               (P              )
		) router_ref (
			.current_r_addr  (current_r_addr ), 
			.chan_in         (chan_in        ), 
			.chan_out        (chan_out       ), 
			.clk             (clk            ), 
			.reset           (reset          ));                


endmodule 


/**********************************
The router top module that can be called in Verilog module. 
***********************************/

module router_top_v
	import pronoc_pkg::*;        
	# (
		parameter P = 6     // router port num         
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
	router_channel_t chan_in  [P-1 : 0];
	router_channel_t chan_out [P-1 : 0];


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
		assign chan_in[i].flit 		= flit_in_all   [(i+1)*Fw-1 : i*Fw];
		assign chan_in[i].flit_wr 	= flit_in_wr_all[i];
		assign chan_in[i].credit 	= credit_in_all [(i+1)*V-1 : i*V];
		assign chan_in[i].congestion 	= congestion_in_all [(i+1)*CONGw-1 : i*CONGw];
		assign chan_in[i].neighbors_r_addr =neighbors_r_addr_in [(i+1)*RAw-1 : i*RAw];

		assign flit_out_all   [(i+1)*Fw-1 : i*Fw] = chan_out[i].flit;
		assign flit_out_wr_all[i] = chan_out[i].flit_wr;
		assign credit_out_all [(i+1)*V-1 : i*V] = chan_out[i].credit;
		assign congestion_out_all [(i+1)*CONGw-1 : i*CONGw] = chan_out[i].congestion;
		assign neighbors_r_addr_out [(i+1)*RAw-1 : i*RAw] = chan_out[i].neighbors_r_addr;

	end
	endgenerate 


endmodule 


