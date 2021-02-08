module custom_noc_connection 
	  import pronoc_pkg::*; 
(
  	reset,
	clk,
	start_i,
	start_o,
	er_addr, 
	current_r_addr,
	chan_in_all,
	chan_out_all, 
	router_chan_in,
	router_chan_out  
);
    


	input reset;
	input clk;
	input start_i;
	output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint 
	output [RAw-1 : 0] current_r_addr [NR-1 : 0]; // provide each router current address  ;
	output [NE-1 : 0] start_o;
	output router_chanel_t chan_in_all [NE-1 : 0];
	input  router_chanel_t chan_out_all [NE-1 : 0]; 
	input  router_chanel_t    router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	output router_chanel_t    router_chan_out  [NR-1 :0][MAX_P-1 : 0];
    


    generate

    
     
	
    
     
	
    
     
	
    
     
	//do not modify this line ===custom1===
    if(TOPOLOGY == "custom1" ) begin : Tcustom1
    
        custom1_connection  connection
        (
		.reset(reset),
		.clk(clk),
		.start_i(start_i),
		.start_o(start_o),
		.er_addr(er_addr), 
		.current_r_addr(current_r_addr),
		.chan_in_all(chan_in_all),
		.chan_out_all(chan_out_all), 
		.router_chan_in(router_chan_in),
		.router_chan_out(router_chan_out)  


     
        );    
    
    end	
    
    endgenerate
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
    	
endmodule
 
