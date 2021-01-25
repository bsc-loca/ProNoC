module router_mesh_snp (
    clk,
    reset,
     /*--------- Interface with NoC ---------------------------------*/
    CURRENT_ADDR,
   
    // TXSNP
    chi_noc_txsnpflitpend,
    chi_noc_txsnpflitv,
    chi_noc_txsnpflit,
    noc_chi_txsnplcrdv,
    
    // RXSNP
    noc_chi_rxsnpflitpend,
    noc_chi_rxsnpflitv,
    noc_chi_rxsnpflit,
    chi_noc_rxsnplcrdv,

    snp_target_id,

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
		R2R = R2R_CHANNELS_MESH_TORI,
		R2E = R2E_CHANNELS_MESH_TORI;
		//These two param are valid only for mesh tori line and ring topology  


	localparam CONGw= 3;

	localparam
		PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
		PRONOC_SNP_Fw = PRONOC_OFFSEET + SNP_FLIT_SIZE + 3;


	input clk,reset;
	/*--------- Interface with NoC ---------------------------------*/
	input  [RAw-1 : 0] CURRENT_ADDR;
   
	// TXsnp
	input  [0:0] chi_noc_txsnpflitpend [R2E-1 : 0];
	input  [0:0] chi_noc_txsnpflitv [R2E-1 : 0];
	input  [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit [R2E-1 : 0];
	output [0:0] noc_chi_txsnplcrdv [R2E-1 : 0];
    
	// Rsnp
	output   [0 : 0] noc_chi_rxsnpflitpend [R2E-1 : 0];
	output   [0 : 0] noc_chi_rxsnpflitv [R2E-1 : 0];
	output   [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit [R2E-1 : 0];
	input    [0 : 0] chi_noc_rxsnplcrdv [R2E-1 : 0]; 
   
	input [EAw-1 : 0]  snp_target_id [R2E-1 : 0];

    

	//R2R ports
	input  [PRONOC_SNP_Fw-1 : 0] router_flit_in[R2R-1:0];
	output [PRONOC_SNP_Fw-1 : 0] router_flit_out[R2R-1:0];
	input  [0:0] router_flit_in_wr [R2R-1:0];
	output [0:0] router_flit_out_wr [R2R-1:0] ;
	input  [0:0] router_credit_in [R2R-1:0]; 
	output [0:0] router_credit_out [R2R-1:0];  
	input  [CONGw-1 : 0]  router_congestion_in [R2R-1:0];
	output [CONGw-1 : 0]  router_congestion_out [R2R-1:0];
   
       
           
        
	router_mesh_wrapper #(
		
		.CHI_FLIT_SIZE( SNP_FLIT_SIZE),
		.SNP_ROUTER(1)
	)
	rsp_router
	(
		.clk                        ( clk                 ),
		.reset                      ( reset               ),
	
		.CURRENT_ADDR	             ( CURRENT_ADDR    	   ),
     
		.chi_noc_txflitpend         ( chi_noc_txsnpflitpend  ),
		.chi_noc_txflitv            ( chi_noc_txsnpflitv     ),
		.chi_noc_txflit             ( chi_noc_txsnpflit      ),
		.noc_chi_txlcrdv            ( noc_chi_txsnplcrdv     ),
	                                             
	                                             
		.noc_chi_rxflitpend         ( noc_chi_rxsnpflitpend  ),
		.noc_chi_rxflitv            ( noc_chi_rxsnpflitv     ),
		.noc_chi_rxflit             ( noc_chi_rxsnpflit      ),
		.chi_noc_rxlcrdv            ( chi_noc_rxsnplcrdv     ),
   
   
		.router_flit_in             ( router_flit_in      ),
		.router_flit_out            ( router_flit_out     ),
		.router_flit_in_wr          ( router_flit_in_wr   ),
		.router_flit_out_wr         ( router_flit_out_wr  ),
		.router_credit_in           ( router_credit_in    ),
		.router_credit_out          ( router_credit_out   ),
		.router_congestion_in       ( router_congestion_in),
		.router_congestion_out       ( router_congestion_out),
		.snp_target_id		     ( snp_target_id)
	);    
   
endmodule
