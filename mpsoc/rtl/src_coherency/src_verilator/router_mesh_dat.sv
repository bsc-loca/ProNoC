module router_mesh_dat (
	    clk,
	    reset,
	     /*--------- Interface with NoC ---------------------------------*/
	    CURRENT_ADDR,
   
	    // TXDAT
	    chi_noc_txdatflitpend,
	    chi_noc_txdatflitv,
	    chi_noc_txdatflit,
	    noc_chi_txdatlcrdv,
	    
	    // RDAT
	    noc_chi_rxdatflitpend,
	    noc_chi_rxdatflitv,
	    noc_chi_rxdatflit,
	    chi_noc_rxdatlcrdv,

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
		R2E = R2E_CHANNELS_MESH_TORI; //These two param are valid only for mesh tori line and ring topology  



	     localparam CONGw= 3;


	    input clk,reset;
	     /*--------- Interface with NoC ---------------------------------*/
	    input  [RAw-1 : 0] CURRENT_ADDR;
   
	    // TXDAT
	    input  [0 : 0] chi_noc_txdatflitpend [R2E-1 : 0];
	    input  [0 : 0] chi_noc_txdatflitv [R2E-1 : 0];
	    input  [DAT_FLIT_SIZE-1:0]	    chi_noc_txdatflit [R2E-1 : 0];
	    output [0 : 0] noc_chi_txdatlcrdv [R2E-1 : 0];
	    
	    // RDAT
	    output   [0 : 0] noc_chi_rxdatflitpend [R2E-1 : 0];
	    output   [0 : 0] noc_chi_rxdatflitv [R2E-1 : 0];
	    output   [DAT_FLIT_SIZE-1:0]	    noc_chi_rxdatflit [R2E-1 : 0];
	    input    [0 : 0] chi_noc_rxdatlcrdv [R2E-1 : 0]; 
   

    	    
	       
	     localparam
	    	    PRONOC_OFFSEET =	    (2*EAw)+DSTPw+1,	       
	    	    PRONOC_DAT_Fw = PRONOC_OFFSEET + DAT_FLIT_SIZE + 3;
		  
	    	    
	    	    
	       
	    

	     //other ports
	     input  [PRONOC_DAT_Fw-1 : 0] router_flit_in[R2R-1:0];
	     output [PRONOC_DAT_Fw-1 : 0] router_flit_out[R2R-1:0];
	     input  [0:0] router_flit_in_wr [R2R-1:0];
	     output [0:0] router_flit_out_wr [R2R-1:0] ;
	     input  [0:0] router_credit_in [R2R-1:0]; 
	     output [0:0] router_credit_out [R2R-1:0];  
	     input  [CONGw-1 : 0]  router_congestion_in [R2R-1:0];
	     output [CONGw-1 : 0]  router_congestion_out [R2R-1:0];
  

	localparam 
		HASH_DAT =32,
		HASH_DAT_FLIT_SIZE = DAT_FLIT_SIZE-DATA_DAT+HASH_DAT,
		HASH_PRONOC_DAT_Fw = PRONOC_DAT_Fw-DATA_DAT+HASH_DAT;


	wire [HASH_DAT_FLIT_SIZE-1 : 0] chi_noc_txdatflit_hash  [R2E-1 : 0]; 
	wire [HASH_DAT_FLIT_SIZE-1 : 0] noc_chi_rxdatflit_hash  [R2E-1 : 0];
	wire [HASH_PRONOC_DAT_Fw-1 : 0] router_flit_in_hash[R2R-1:0];
	wire [HASH_PRONOC_DAT_Fw-1 : 0] router_flit_out_hash[R2R-1:0];




	

	genvar i;
	generate 

	for(i=0; i<R2E; i=i+1) begin :other_enp


		dat_reducer #(
			.FLIT_SIZE(DAT_FLIT_SIZE),
			.HASH_DAT(HASH_DAT)
		) reduce (
		    .dat_in (chi_noc_txdatflit[i]),
		    .dat_out(chi_noc_txdatflit_hash[i]) 
		);


		 dat_incr #(
			.FLIT_SIZE(DAT_FLIT_SIZE),		
			.HASH_DAT(HASH_DAT)
		) incr (
			.dat_in(noc_chi_rxdatflit_hash[i]),
			.dat_out(noc_chi_rxdatflit[i]) 
		);

	end

	for(i=0; i<R2R; i=i+1) begin :other_enp
		dat_reducer #(
			.FLIT_SIZE(PRONOC_DAT_Fw),			
			.HASH_DAT(HASH_DAT)
		) reduce_r (
		    .dat_in (router_flit_in[i]),
		    .dat_out(router_flit_in_hash[i]) 
		);


		 dat_incr #(
			.FLIT_SIZE(PRONOC_DAT_Fw),
			.HASH_DAT(HASH_DAT)
		) incr_r (
			.dat_in(router_flit_out_hash[i]),
			.dat_out(router_flit_out[i]) 
		);


	end
	endgenerate




 
    	router_mesh_wrapper #(
    	
    		.CHI_FLIT_SIZE(HASH_DAT_FLIT_SIZE),
    		.SNP_ROUTER(0)
    	)
    	dat_router
    	(
            .clk                        ( clk                 ),
            .reset                      ( reset               ),
    	
            .CURRENT_ADDR	        ( CURRENT_ADDR    	   ),
         
    	    .chi_noc_txflitpend         ( chi_noc_txdatflitpend  ),
    	    .chi_noc_txflitv            ( chi_noc_txdatflitv     ),
    	    .chi_noc_txflit             ( chi_noc_txdatflit_hash      ),
    	    .noc_chi_txlcrdv            ( noc_chi_txdatlcrdv     ),
    	                                             
    	                                             
    	    .noc_chi_rxflitpend         ( noc_chi_rxdatflitpend  ),
    	    .noc_chi_rxflitv            ( noc_chi_rxdatflitv     ),
    	    .noc_chi_rxflit             ( noc_chi_rxdatflit_hash ),
    	    .chi_noc_rxlcrdv            ( chi_noc_rxdatlcrdv     ),
       
       
    	    .router_flit_in             ( router_flit_in_hash      ),
    	    .router_flit_out            ( router_flit_out_hash     ),
    	    .router_flit_in_wr          ( router_flit_in_wr   ),
    	    .router_flit_out_wr         ( router_flit_out_wr  ),
    	    .router_credit_in           ( router_credit_in    ),
    	    .router_credit_out          ( router_credit_out   ),
    	    .router_congestion_in       ( router_congestion_in),
    	    .router_congestion_out       ( router_congestion_out),
            .snp_target_id ()
        );  
	    	    	    
	    	    
   
endmodule
