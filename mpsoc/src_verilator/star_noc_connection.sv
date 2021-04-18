/**************************************
 * Module: tree
 * Date:2019-01-01  
 * Author: alireza     
 *
 * 
Description: 

    Star      

 ***************************************/
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
 
module  star_noc_connection  
	import pronoc_pkg::*; 
	(
	er_addr,
 	current_r_addr,    
	chan_in_all,
	chan_out_all,
	router_chan_in, 
	router_chan_out
);
  
  
	
	//local ports 
	input   router_chanel_t chan_in_all  [NE-1 : 0];
	output  router_chanel_t chan_out_all [NE-1 : 0];
	
	//all routers port 
	input   router_chanel_t router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	output  router_chanel_t router_chan_out  [NR-1 :0][MAX_P-1 : 0];

	output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint  
    output [RAw-1 : 0] current_r_addr [NR-1 : 0];
    
	assign current_r_addr[0] = 1'b0;

	genvar pos;
    generate
	for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints   

		assign router_chan_out [0][pos] =   chan_in_all [pos];
		assign chan_out_all [pos] 		=   router_chan_in [0][pos];
	    assign er_addr [pos] = 1'b0;        
 
	end//pos 
 	endgenerate    
                     

endmodule


