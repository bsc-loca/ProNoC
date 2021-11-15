`ifndef PRONOC_DEF
`define PRONOC_DEF

	//`define SYNC_RESET_MODE    	/* Reset is asynchronous by default. Uncomment this line for having synchronous reset*/
	//`define ACTIVE_LOW_RESET_MODE /* Reset is active high by deafult. Uncomment this line for having active low reset*/



	`ifdef SYNC_RESET_MODE 
			`define pronoc_clk_reset_edge  posedge clk
	`else 
		`ifdef ACTIVE_LOW_RESET_MODE 
	   	 	`define pronoc_clk_reset_edge  posedge clk or negedge reset
		`else 
			`define pronoc_clk_reset_edge  posedge clk or posedge reset		
		`endif  
	`endif   
	   



	`ifdef ACTIVE_LOW_RESET_MODE 
	   	 	`define pronoc_reset !reset
		`else 
			`define pronoc_reset  reset
	`endif  






`endif

