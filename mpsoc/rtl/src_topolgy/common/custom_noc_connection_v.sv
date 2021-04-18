module   custom_noc_connection_v 
    	import pronoc_pkg::*; 
	(

   
    reset,
    clk, 
    router_flit_out_all,
    router_flit_out_wr_all,    
    router_credit_in_all,
    
    router_flit_in_all,
    router_flit_in_wr_all,
    router_credit_out_all,                    
    router_congestion_in_all,    
    router_congestion_out_all,   
    
    ni_flit_in,   
    ni_flit_in_wr, 
    ni_credit_out,
    ni_flit_out,   
    ni_flit_out_wr,  
    ni_credit_in,
    start_i,      
    er_addr, 
    current_r_addr,
    start_o
   
);

  

                    
    
                      
       
    localparam
        PV = V * MAX_P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = MAX_P * Fw,
        NEFw = NE * Fw,
        NEV = NE * V,
        CONG_ALw = CONGw * MAX_P; // congestion width per router         
        
      
    
    input reset,clk;    
    
                  
                    
                    
                   
    output [PFw-1 : 0] router_flit_out_all [NR-1 :0];
    output [MAX_P-1 : 0] router_flit_out_wr_all [NR-1 :0];    
    input [PV-1 : 0] router_credit_in_all [NR-1 :0];
    
    input [PFw-1 : 0] router_flit_in_all [NR-1 :0];
    input [MAX_P-1 : 0] router_flit_in_wr_all [NR-1 :0];
    output [PV-1 : 0] router_credit_out_all [NR-1 :0];                    
    input [CONG_ALw-1: 0] router_congestion_in_all[NR-1 :0];    
    output [CONG_ALw-1: 0] router_congestion_out_all [NR-1 :0];   
    
    
    input [Fw-1 : 0] ni_flit_in [NE-1 :0];   
    input [NE-1 : 0] ni_flit_in_wr; 
    output [V-1 : 0] ni_credit_out [NE-1 :0];
    output [Fw-1 : 0] ni_flit_out [NE-1 :0];   
    output [NE-1 : 0] ni_flit_out_wr;  
    input [V-1 : 0] ni_credit_in [NE-1 :0];   


    input start_i;      
    output [RAw-1 : 0] er_addr [NE-1 : 0]; 
    output [RAw-1 : 0] current_r_addr [NR-1 : 0];  
    output [NE-1 : 0] start_o;
	
	router_chanel_t chan_in_all [NE-1 : 0];
	router_chanel_t chan_out_all [NE-1 : 0]; 
	router_chanel_t    router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	router_chanel_t    router_chan_out  [NR-1 :0][MAX_P-1 : 0];



	genvar i,j;
	generate  
		for(i=0; i<NR; i=i+1) begin : rlp
			for(j=0; j<MAX_P; j=j+1) begin : plp
				assign router_flit_out_all [i][(j+1)*Fw-1 : j*Fw] = router_chan_out[i][j].flit_chanel.flit;
				assign router_flit_out_wr_all[i][j] = router_chan_out[i][j].flit_chanel.flit_wr;
				assign router_congestion_out_all[i][(j+1)*CONGw-1 : j*CONGw] = router_chan_out[i][j].flit_chanel.congestion;
				assign router_credit_out_all[i][(j+1)*V-1 : j*V] =router_chan_out[i][j].flit_chanel.credit;

				assign router_chan_in[i][j].flit_chanel.flit = router_flit_in_all [i][(j+1)*Fw-1 : j*Fw];
				assign router_chan_in[i][j].flit_chanel.flit_wr =  router_flit_in_wr_all[i][j];
				assign router_chan_in[i][j].flit_chanel.congestion = router_congestion_in_all[i][(j+1)*CONGw-1 : j*CONGw];
				assign router_chan_in[i][j].flit_chanel.credit = router_credit_in_all[i][(j+1)*V-1 : j*V];
			end
		end
		for(i=0; i<NE; i=i+1) begin : elp
			assign ni_flit_out [i] = chan_in_all[i].flit_chanel.flit;
			assign ni_flit_out_wr [i] = chan_in_all[i].flit_chanel.flit_wr;
			assign ni_credit_out [i] = chan_in_all[i].flit_chanel.credit;


			assign chan_out_all[i].flit_chanel.flit 	= ni_flit_in [i] ;
			assign chan_out_all[i].flit_chanel.flit_wr	= ni_flit_in_wr [i];
			assign chan_out_all[i].flit_chanel.credit 	= ni_credit_in [i] ;


		end
	endgenerate


	custom_noc_connection top_connect (
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

endmodule

