module   custom_noc #(  
    	parameter TOPOLOGY = "CUSTOM_NAME",
	parameter ROUTE_NAME = "CUSTOM_NAME",
	parameter T1= 8,
    	parameter T2= 8,
    	parameter T3= 8,
	parameter B  = 4,
	parameter V  = 2,
	parameter C  = 2,
	parameter Fpay  = 32,
	parameter MUX_TYPE = "ONE_HOT",
	parameter VC_REALLOCATION_TYPE  = "NONATOMIC",
	parameter COMBINATION_TYPE = "COMB_NONSPEC",
	parameter FIRST_ARBITER_EXT_P_EN  = 1,
	parameter CONGESTION_INDEX  = 7,
	parameter DEBUG_EN = 0,
	parameter AVC_ATOMIC_EN = 0,
	parameter ADD_PIPREG_AFTER_CROSSBAR = 0,
	parameter CVw = (C==0)? V : C * V,
	parameter CLASS_SETTING  = {CVw{1'b1}},
	parameter SSA_EN = "NO",
	parameter SWA_ARBITER_TYPE  = "RRA",
	parameter WEIGHTw  = 7,
	parameter MIN_PCK_SIZE = 2
)(
    	reset,
	clk,
	flit_in_all,
	flit_out_all,
	flit_in_wr_all,
	flit_out_wr_all,
	credit_out_all,
	credit_in_all
);


    
    
     `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"
   
    
    localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;


   
    localparam
        PV = V * MAX_P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = MAX_P * Fw,
        CONG_ALw = CONGw * MAX_P, // congestion width per router            
        W= WEIGHTw,
        WP = W * MAX_P,
        PRAw= RAw * MAX_P;                   
     
    

	input reset;
	input clk;
	input [(NE*Fw)-1 : 0] flit_in_all;
	output [(NE*Fw)-1 : 0] flit_out_all;
	input [NE-1 : 0] flit_in_wr_all;
	output [NE-1 : 0] flit_out_wr_all;
	output [(NE*V)-1 : 0] credit_out_all;
	input [(NE*V)-1 : 0] credit_in_all;


	   

    generate 

	
	
    
     
	    
     
    
     
	
    
     
	//do not modify this line ===custom1===
    if(TOPOLOGY == "custom1" ) begin : Tcustom1
    
        custom1_noc_genvar #(
		.TOPOLOGY(TOPOLOGY),
		.ROUTE_NAME(ROUTE_NAME),
		.V (V ),
		.B (B ),
		.C (C ),
		.Fpay (Fpay ),
		.MUX_TYPE(MUX_TYPE),
		.VC_REALLOCATION_TYPE (VC_REALLOCATION_TYPE ),
		.COMBINATION_TYPE(COMBINATION_TYPE),
		.FIRST_ARBITER_EXT_P_EN (FIRST_ARBITER_EXT_P_EN ),
		.CONGESTION_INDEX (CONGESTION_INDEX ),
		.DEBUG_EN(DEBUG_EN),
		.AVC_ATOMIC_EN(AVC_ATOMIC_EN),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE),
		.BYTE_EN(BYTE_EN)
        )
        the_noc
        (
		.reset(reset),
		.clk(clk),
		.flit_in_all(flit_in_all),
		.flit_out_all(flit_out_all),
		.flit_in_wr_all(flit_in_wr_all),
		.flit_out_wr_all(flit_out_wr_all),
		.credit_out_all(credit_out_all),
		.credit_in_all(credit_in_all)     
        );    
    
    end	
    
    endgenerate
	
	 
	
	 
	
	 
	
	 
	
	 
	
	 
	
	 
	
	 
	
             
endmodule
