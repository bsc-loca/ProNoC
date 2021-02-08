module router_mesh_req (
    clk,
    reset,
     /*--------- Interface with NoC ---------------------------------*/
    CURRENT_ADDR,
   
    // TXREQ
    chi_noc_txreqflitpend,
    chi_noc_txreqflitv,
    chi_noc_txreqflit,
    noc_chi_txreqlcrdv,
    
    // RREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,
    chi_noc_rxreqlcrdv,

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
		R2E = R2E_chanelS_MESH_TORI; //These two param are valid only for mesh tori line and ring topology  


	localparam CONGw= 3;


    input clk,reset;
     /*--------- Interface with NoC ---------------------------------*/
    input  [RAw-1 : 0] CURRENT_ADDR;
   
    // TXREQ
    input [0 : 0] chi_noc_txreqflitpend [R2E-1 : 0];
    input [0 : 0] chi_noc_txreqflitv [R2E-1 : 0];
    input  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit [R2E-1 : 0];
    output [0 : 0] noc_chi_txreqlcrdv [R2E-1 : 0];
    
    // RXREQ
    output   [0 : 0] noc_chi_rxreqflitpend [R2E-1 : 0];
    output   [0 : 0] noc_chi_rxreqflitv [R2E-1 : 0];
    output   [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit [R2E-1 : 0];
    input    [0 : 0] chi_noc_rxreqlcrdv [R2E-1 : 0]; 
   


     localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
        PRONOC_REQ_Fw = PRONOC_OFFSEET + REQ_FLIT_SIZE + 3;
        
   

     //other ports
     input  [PRONOC_REQ_Fw-1 : 0] router_flit_in[R2R-1:0];
     output [PRONOC_REQ_Fw-1 : 0] router_flit_out[R2R-1:0];
     input  [0:0] router_flit_in_wr [R2R-1:0];
     output [0:0] router_flit_out_wr [R2R-1:0] ;
     input  [0:0] router_credit_in [R2R-1:0]; 
     output [0:0] router_credit_out [R2R-1:0];  
     input  [CONGw-1 : 0]  router_congestion_in [R2R-1:0];
     output [CONGw-1 : 0]  router_congestion_out [R2R-1:0];
   
	router_mesh_wrapper #(
		.CHI_FLIT_SIZE(REQ_FLIT_SIZE),
		.SNP_ROUTER(0)
	)
	rsp_router
	(
		.clk                        ( clk                 ),
		.reset                      ( reset               ),
	
		.CURRENT_ADDR	             ( CURRENT_ADDR    	   ),
     
		.chi_noc_txflitpend         ( chi_noc_txreqflitpend  ),
		.chi_noc_txflitv            ( chi_noc_txreqflitv     ),
		.chi_noc_txflit             ( chi_noc_txreqflit      ),
		.noc_chi_txlcrdv            ( noc_chi_txreqlcrdv     ),
	                                             
	                                             
		.noc_chi_rxflitpend         ( noc_chi_rxreqflitpend  ),
		.noc_chi_rxflitv            ( noc_chi_rxreqflitv     ),
		.noc_chi_rxflit             ( noc_chi_rxreqflit      ),
		.chi_noc_rxlcrdv            ( chi_noc_rxreqlcrdv     ),
   
   
		.router_flit_in             ( router_flit_in      ),
		.router_flit_out            ( router_flit_out     ),
		.router_flit_in_wr          ( router_flit_in_wr   ),
		.router_flit_out_wr         ( router_flit_out_wr  ),
		.router_credit_in           ( router_credit_in    ),
		.router_credit_out          ( router_credit_out   ),
		.router_congestion_in       ( router_congestion_in),
		.router_congestion_out       ( router_congestion_out),
		.snp_target_id		     ( )
);    
            
        
   
endmodule
