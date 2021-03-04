`timescale     1ns/1ps


module noc_connection_sv 
	import pronoc_pkg::*; 
( 
	clk,
	reset,
	start_i,
	start_o,
	er_addr,// endpoints connected to each router   
	current_r_addr,
	chan_in_all,
	chan_out_all,
	router_chan_in, 
	router_chan_out 
);
       

	input reset,clk,start_i;

    //local ports 
	input   router_chanel_t chan_in_all  [NE-1 : 0];
	output  router_chanel_t chan_out_all [NE-1 : 0];
	
	
	//all routers port 
	input  router_chanel_t    router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	output router_chanel_t    router_chan_out  [NR-1 :0][MAX_P-1 : 0];

	output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint  
    output [RAw-1 : 0] current_r_addr [NR-1 : 0];
	output [NE-1  : 0] start_o;  



generate 
    /* verilator lint_off WIDTH */ 
    if( TOPOLOGY == "FATTREE") begin : fat
    /* verilator lint_on WIDTH */  
       
        fattree_noc_connection connections
        (   
         .chan_in_all(chan_in_all),
		 .chan_out_all (chan_out_all),
		 .router_chan_in (router_chan_in),
		 .router_chan_out (router_chan_out),
         .er_addr(er_addr),
         .current_r_addr(current_r_addr)         
        );

     /* verilator lint_off WIDTH */    
    end else if( TOPOLOGY == "TREE") begin : fat
    /* verilator lint_on WIDTH */  
       
        tree_noc_connection  connections
        (             
         .chan_in_all(chan_in_all),
		 .chan_out_all (chan_out_all),
		 .router_chan_in (router_chan_in),
		 .router_chan_out (router_chan_out),
         .er_addr(er_addr),
         .current_r_addr(current_r_addr)                
        );       
    /* verilator lint_off WIDTH */      
    end else if (TOPOLOGY == "MESH" || TOPOLOGY == "TORUS" || TOPOLOGY == "RING" || TOPOLOGY == "LINE") begin :mesh_torus
    /* verilator lint_on WIDTH */      

    mesh_torus_noc_connection connections
      (   
         .chan_in_all(chan_in_all),
		 .chan_out_all (chan_out_all),
		 .router_chan_in (router_chan_in),
		 .router_chan_out (router_chan_out),
         .er_addr(er_addr),
         .current_r_addr(current_r_addr)         
        );

	end else if (TOPOLOGY == "STAR") begin  

		star_noc_connection  connections
        (   
         .chan_in_all(chan_in_all),
		 .chan_out_all (chan_out_all),
		 .router_chan_in (router_chan_in),
		 .router_chan_out (router_chan_out),
         .er_addr(er_addr),
         .current_r_addr(current_r_addr)         
        );


    end else begin :custom

	custom_noc_connection connections
        (   
         .chan_in_all(chan_out_all),
		 .chan_out_all (chan_in_all),
		 .router_chan_in (router_chan_in),
		 .router_chan_out (router_chan_out),
         .er_addr(er_addr),
         .current_r_addr(current_r_addr)         
        );


    end
  endgenerate

	//assert start signal for different endpoints at different time 
	//It used for simulation only
	 start_delay_gen #(
        .NC(NE)
    )
    delay_gen
    (
        .clk(clk),
        .reset(reset),
        .start_i(start_i),
        .start_o(start_o)
    );

endmodule






module noc_connection
	import pronoc_pkg::*; 
(
    
    /*
    reset,
    clk,    
    flit_out_all,
    flit_out_wr_all, 
    credit_in_all,
    flit_in_all,  
    flit_in_wr_all,  
    credit_out_all
    */
 clk,
 reset,
 start_i,
 start_o,
 router_chan_in, 
 router_chan_out, 

// router_iport_weight_in_all,
// router_iport_weight_out_all, 
 ni_flit_in,    
 ni_flit_in_wr, 
 ni_credit_out,                 
 ni_flit_out, 
 ni_flit_out_wr,  
 ni_credit_in,
 er_addr,// endpoints connected to each router   
 current_r_addr
 
);
    


   
    localparam
        PV = V * MAX_P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = MAX_P * Fw,
        CONG_ALw = CONGw * MAX_P, // congestion width per router            
        W= WEIGHTw,
        WP = W * MAX_P,
        PRAw= RAw * MAX_P;                
                    
                    
    //all routers port 
	input  router_chanel_t    router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	output router_chanel_t    router_chan_out  [NR-1 :0][MAX_P-1 : 0];
 


    input  [Fw-1 : 0] ni_flit_in [NE-1 : 0];   
    input  [NE-1 : 0] ni_flit_in_wr; 
    output [V-1 : 0] ni_credit_out [NE-1 : 0];
    output [Fw-1 : 0] ni_flit_out [NE-1 : 0];   
    output [NE-1 : 0] ni_flit_out_wr;  
    input  [V-1 : 0]  ni_credit_in [NE-1 : 0]; 

    output [RAw-1 :	0] current_r_addr [NR-1 : 0];
    output [RAw-1 : 0] er_addr [NE-1 : 0];
   
 
   
    
    input clk,reset, start_i;
    
    
    output [NE-1 : 0] start_o;

	//local ports 
	router_chanel_t chan_in_all  [NE-1 : 0];
	router_chanel_t chan_out_all [NE-1 : 0];
	
	

	noc_connection_sv connection	
	( 
		.chan_in_all(chan_in_all),
		.chan_out_all (chan_out_all),
		.router_chan_in (router_chan_in),
		.router_chan_out (router_chan_out),
		.er_addr(er_addr),
		.current_r_addr(current_r_addr),
		.reset(reset),
		.clk(clk),
		.start_i(start_i),
		.start_o(start_o)         
	);

	
	genvar i,j;
	generate 
	for (i=0; i<NE; i=i+1) begin : E_
		assign chan_in_all[i].flit_chanel.flit    = ni_flit_in [i];		
		assign chan_in_all[i].flit_chanel.credit  = ni_credit_in [i]; 
		assign chan_in_all[i].flit_chanel.flit_wr = ni_flit_in_wr[i]; 

		assign ni_flit_out [i] = chan_out_all[i].flit_chanel.flit;		
		assign ni_credit_out [i] = chan_out_all[i].flit_chanel.credit;
		assign ni_flit_out_wr[i] = chan_out_all[i].flit_chanel.flit_wr; 

	end
	
	




	endgenerate



   
endmodule

