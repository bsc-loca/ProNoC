// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module star_noc_connection 
	import pronoc_pkg::*; 
(   
   
 clk,
 reset,
 start_i,
 start_o,
 router_flit_out_all, 
 router_flit_out_wr_all,    
 router_credit_in_all,
 router_credit_out_all,
 router_flit_in_all,     
 router_flit_in_wr_all,
 router_congestion_in_all,
 router_congestion_out_all,

 ni_flit_in,    
 ni_flit_in_wr, 
 ni_credit_out,                 
 ni_flit_out, 
 ni_flit_out_wr,  
 ni_credit_in,
 er_addr,
 current_r_addr 
);    

    
    
        
 
    
    
    localparam
        PV = V * MAX_P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = MAX_P * Fw,
        NEFw = NE * Fw,
        NEV = NE * V,
        CONG_ALw = CONGw * MAX_P,
        PLKw = MAX_P * LKw,
        PLw = MAX_P * Lw,       
        PRAw = MAX_P * RAw; 
                
                    
   
    input reset,clk;      
    
    
                    
     
    output [PFw-1 : 0] router_flit_out_all [NR-1 :0];
    output [MAX_P-1 : 0] router_flit_out_wr_all [NR-1 :0];    
    input  [PV-1 : 0] router_credit_in_all [NR-1 :0];    
    input  [PFw-1 : 0] router_flit_in_all [NR-1 :0];
    input  [MAX_P-1 : 0] router_flit_in_wr_all [NR-1 :0];
    output [PV-1 : 0] router_credit_out_all[NR-1 :0]; 
    input  [CONG_ALw-1: 0] router_congestion_in_all[NR-1 :0];  
    output [CONG_ALw-1: 0] router_congestion_out_all [NR-1 :0];   
  
    input  [Fw-1 : 0] ni_flit_in [NE-1 :0];   
    input  [NE-1 : 0] ni_flit_in_wr; 
    output [V-1 : 0] ni_credit_out [NE-1 :0];
    output [Fw-1 : 0] ni_flit_out [NE-1 :0];   
    output [NE-1 : 0] ni_flit_out_wr;  
    input  [V-1 : 0] ni_credit_in [NE-1 :0];

   
   
    
    output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint
    
   
    output [RAw-1 : 0] current_r_addr [NR-1 : 0];
    
     
    input  start_i;
    output [NE-1 : 0] start_o;
 
    
   genvar pos;
    generate
	for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints
    
  
    
    
 
            assign router_flit_out_all [0][(pos+1)*Fw-1 : pos*Fw] =    ni_flit_in [pos];
            assign router_credit_out_all [0][(pos+1)*V-1 : pos*V] =    ni_credit_in [pos];
            assign router_flit_out_wr_all [0][pos] =    ni_flit_in_wr [pos];
            assign router_congestion_out_all[0][(pos+1)*CONGw-1 : pos*CONGw] =   {CONGw{1'b0}}; 
                     
                        
            assign ni_flit_out [pos] = router_flit_in_all [0][(pos+1)*Fw-1 : pos*Fw]; 
            assign ni_flit_out_wr [pos] = router_flit_in_wr_all[0][pos];
            assign ni_credit_out [pos] = router_credit_in_all [0][(pos+1)*V-1 : pos*V];             
            assign er_addr [pos] = 1'b0;
         
 
	end//pos 
 	endgenerate    
    
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

