
    
    
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


