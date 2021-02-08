module router_mesh_rsp (
    clk,
    reset,
     /*--------- Interface with NoC ---------------------------------*/
    CURRENT_ADDR,
   
    // TXRSP
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,
    
    // RXRSP
    noc_chi_rxrspflitpend,
    noc_chi_rxrspflitv,
    noc_chi_rxrspflit,
    chi_noc_rxrsplcrdv,

   // router 2 router connection ports
    router_flit_in,
    router_flit_out,
    router_flit_in_wr,
    router_flit_out_wr,
    router_credit_in, 
    router_credit_out,  
    router_congestion_in,
    router_congestion_out
 
);

 

    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  

	localparam
		R2R = R2R_chanelS_MESH_TORI,
		R2E = R2E_chanelS_MESH_TORI; 
		


	localparam CONGw= 3;


	input clk,reset;
	/*--------- Interface with NoC ---------------------------------*/
	input  [RAw-1 : 0] CURRENT_ADDR;
   
	// TXRSP
	input [0 : 0] chi_noc_txrspflitpend [R2E-1 : 0];
	input [0 : 0] chi_noc_txrspflitv [R2E-1 : 0];
	input  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit [R2E-1 : 0];
	output [0 : 0] noc_chi_txrsplcrdv [R2E-1 : 0];
    
	// RXRSP
	output  [0 : 0]  noc_chi_rxrspflitpend [R2E-1 : 0];
	output  [0 : 0] noc_chi_rxrspflitv [R2E-1 : 0];
	output  [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit [R2E-1 : 0];
	input   [0 : 0] chi_noc_rxrsplcrdv [R2E-1 : 0]; 
   

       
       
	localparam
		PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
		PRONOC_RSP_Fw = PRONOC_OFFSEET + RSP_FLIT_SIZE + 3;
           
       
   
 

     //other ports
     input  [PRONOC_RSP_Fw-1 : 0] router_flit_in[R2R-1:0];
     output [PRONOC_RSP_Fw-1 : 0] router_flit_out[R2R-1:0];
     input  [0:0] router_flit_in_wr [R2R-1:0];
     output [0:0] router_flit_out_wr [R2R-1:0] ;
     input  [0:0] router_credit_in [R2R-1:0]; 
     output [0:0] router_credit_out [R2R-1:0];  
     input  [CONGw-1 : 0]  router_congestion_in [R2R-1:0];
     output [CONGw-1 : 0]  router_congestion_out [R2R-1:0];
   
       
	router_mesh_wrapper #(
		.CHI_FLIT_SIZE(RSP_FLIT_SIZE),
		.SNP_ROUTER(0)
	)
	rsp_router
	(
		.clk                        ( clk                 ),
		.reset                      ( reset               ),
	
		.CURRENT_ADDR	             ( CURRENT_ADDR    	   ),
     
	    .chi_noc_txflitpend         ( chi_noc_txrspflitpend  ),
	    .chi_noc_txflitv           ( chi_noc_txrspflitv     ),
	    .chi_noc_txflit             ( chi_noc_txrspflit      ),
	    .noc_chi_txlcrdv            ( noc_chi_txrsplcrdv     ),
	                                             
	                                             
	    .noc_chi_rxflitpend         ( noc_chi_rxrspflitpend  ),
	    .noc_chi_rxflitv            ( noc_chi_rxrspflitv     ),
	    .noc_chi_rxflit             ( noc_chi_rxrspflit      ),
	    .chi_noc_rxlcrdv            ( chi_noc_rxrsplcrdv     ),
   
   
	    .router_flit_in             ( router_flit_in      ),
	    .router_flit_out            ( router_flit_out     ),
	    .router_flit_in_wr          ( router_flit_in_wr   ),
	    .router_flit_out_wr         ( router_flit_out_wr  ),
	    .router_credit_in           ( router_credit_in    ),
	    .router_credit_out          ( router_credit_out   ),
	    .router_congestion_in       ( router_congestion_in),
	    .router_congestion_out       ( router_congestion_out),
        .snp_target_id()
);  
endmodule
