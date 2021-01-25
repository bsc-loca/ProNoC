module router_mesh_wrapper #(
	parameter V=1,
	parameter CHI_FLIT_SIZE=100,
	parameter SNP_ROUTER=0
)
(
    clk,
    reset,
	/*--------- Interface with NoC ---------------------------------*/
    CURRENT_ADDR,
   
    // tx
    chi_noc_txflitpend,
    chi_noc_txflitv,
    chi_noc_txflit,
    noc_chi_txlcrdv,
    
    // rx
    noc_chi_rxflitpend,
    noc_chi_rxflitv,
    noc_chi_rxflit,
    chi_noc_rxlcrdv,

    //oR2Ey valid if snp router
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
		R2E = R2E_CHANNELS_MESH_TORI,
		P= MAX_P;//These three params are valid only for mesh tori line and ring topology  


	localparam 
		CONGw= 3,
		CONG_ALw=P*CONGw;
	
	localparam
	   PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,	  
	   PRONOC_Fw = PRONOC_OFFSEET + CHI_FLIT_SIZE + 3;
	   

	input clk,reset;
	/*--------- Interface with NoC ---------------------------------*/
	input  [RAw-1 : 0] CURRENT_ADDR;
   
	// tx
	input  [0 : 0] chi_noc_txflitpend [R2E-1 : 0];
	input  [0 : 0] chi_noc_txflitv [R2E-1 : 0];
	input  [CHI_FLIT_SIZE-1:0]    chi_noc_txflit [R2E-1 : 0];
	output [0 : 0] noc_chi_txlcrdv [R2E-1 : 0];
    
	// rx
	output   [0 : 0] noc_chi_rxflitpend [R2E-1 : 0];
    	output   [0 : 0] noc_chi_rxflitv [R2E-1 : 0];
	output   [CHI_FLIT_SIZE-1:0]    noc_chi_rxflit [R2E-1 : 0];
	input    [0 : 0] chi_noc_rxlcrdv [R2E-1 : 0]; 
   
	input [EAw-1 : 0]  snp_target_id [R2E-1 : 0];

	
	//R2R
	input  [PRONOC_Fw-1 : 0] router_flit_in[R2R-1:0];
	output [PRONOC_Fw-1 : 0] router_flit_out[R2R-1:0];
	input  [0:0] router_flit_in_wr [R2R-1:0];
	output [0:0] router_flit_out_wr [R2R-1:0] ;
	input  [0:0] router_credit_in [R2R-1:0]; 
	output [0:0] router_credit_out [R2R-1:0];  
	input  [CONGw-1 : 0]  router_congestion_in [R2R-1:0];
	output [CONGw-1 : 0]  router_congestion_out [R2R-1:0];


   
	  
	//E2R
	wire [PRONOC_Fw-1 : 0] endp_flit_out [R2E-1 : 0];
	wire [PRONOC_Fw-1 : 0] endp_flit_in [R2E-1 : 0];
	wire [R2E-1 : 0] endp_flit_out_wr;
	wire [R2E-1 : 0] endp_credit_in;
	wire [R2E-1 : 0] endp_flit_in_wr;  
	wire [R2E-1 : 0] endp_credit_out;
 


	//Internal
	wire [P*PRONOC_Fw-1 :  0]  flit_in_all;
	wire [P-1 :  0]  flit_in_wr_all;
	wire [P*V-1 :  0]  credit_out_all;
	wire [CONG_ALw-1 :  0]  congestion_in_all;
    
	wire [P*PRONOC_Fw-1 :  0]  flit_out_all;
	wire [P-1 :  0]  flit_out_wr_all;
	wire [P*V-1 :  0]  credit_in_all;
	wire [CONG_ALw-1 :  0]  congestion_out_all;


	//wire [PRONOC_Fw-1 :  0]  flit_in [P-1 : 0];
	wire [V-1 :  0]  credit_out [P-1 : 0];
	wire [CONGw-1 :  0]  congestion_in [P-1 : 0];
    
	//wire [PRONOC_Fw-1 :  0]  flit_out [P-1 : 0];
	wire [V-1 :  0]  credit_in [P-1 : 0];
	wire [CONGw-1 :  0]  congestion_out[P-1 : 0];





	//endp 0 
	assign flit_in_all[PRONOC_Fw-1 : 0] = endp_flit_in[0];
	assign flit_in_wr_all[0]=endp_flit_in_wr[0];
	assign endp_credit_out[0] = credit_out [0];
   
	assign endp_flit_out[0] =flit_out_all [PRONOC_Fw-1 : 0];
	assign endp_flit_out_wr[0] =flit_out_wr_all [0];
	assign credit_in[0]  =endp_credit_in[0]; 
    
    
	genvar i; 
	//connect r2r
	generate
	for(i=0; i<R2R; i=i+1) begin :r2r	
		assign flit_in_all[(i+2)*PRONOC_Fw-1 : (i+1)*PRONOC_Fw] = router_flit_in[i];
		assign flit_in_wr_all[i+1]	= router_flit_in_wr[i];
		assign router_credit_out[i]    = credit_out [i+1];
		assign congestion_in [i+1]  =router_congestion_in[i];

		assign router_flit_out[i] =    flit_out_all [(i+2)*PRONOC_Fw-1 : (i+1)*PRONOC_Fw];
		assign router_flit_out_wr[i] =   flit_out_wr_all [i+1];
		assign credit_in [i+1] =router_credit_in[i];
		assign router_congestion_out [i]=  congestion_out[i+1];
	end

	
	//other endps connection to port P-R2E+endp_num port	
	for(i=1; i<R2E; i=i+1) begin :other_enp
		assign flit_in_all[(R2R+i+1)*PRONOC_Fw-1 : (R2R+i)*PRONOC_Fw]  = endp_flit_in[i];
		assign flit_in_wr_all[R2R+i]=endp_flit_in_wr[i];
		assign endp_credit_out[i] = credit_out [R2R+i];
   	
		assign endp_flit_out[i] =flit_out_all [(R2R+i+1)*PRONOC_Fw-1 : (R2R+i)*PRONOC_Fw] ;
		assign endp_flit_out_wr[i] =flit_out_wr_all [R2R+i];
		assign credit_in[R2R+i]  =endp_credit_in[i]; 
	end	


	






//connect r2r
	
	for(i=0; i<P; i=i+1) begin :all	
		//assign flit_in_all[(i+1)*PRONOC_Fw-1 : i*PRONOC_Fw] = flit_in[i];
		assign credit_out[i]    = credit_out_all [(i+1)*V-1 :  i*V];
		assign congestion_in_all [(i+1)*CONGw-1 :  i*CONGw]  =congestion_in[i];

		//assign flit_out[i] =    flit_out_all [(i+1)*PRONOC_Fw-1 :  i*PRONOC_Fw];
		assign credit_in_all[(i+1)*V-1 :  i*V] =credit_in[i];
		assign congestion_out [i]=  congestion_out_all[(i+1)*CONGw-1 :  i*CONGw];
	end





	for(i=0; i<R2E; i=i+1) begin :local_p	  
		if(SNP_ROUTER)begin :snp
			chi_to_pronoc_snoop_wrapper #(
			    .CHI_FLIT_SIZE(CHI_FLIT_SIZE),
			    .P(MAX_P),
			    .T1(T1),
			    .T2(T2),
			    .T3(T3),
			    .RAw(RAw),
			    .EAw(EAw),
			    .NE(NE),
			    .DSTPw(DSTPw),
			    .TOPOLOGY(TOPOLOGY),
			    .ROUTE_NAME(ROUTE_NAME),
			    .ROUTE_TYPE(ROUTE_TYPE)
			)
			snp_wrapper
			(
			    .chi_flitpend_i(chi_noc_txflitpend[i]),
			    .chi_flitv_i(chi_noc_txflitv[i]),
			    .chi_lcrdv_i(chi_noc_rxlcrdv[i]),        
			    .chi_flit_i(chi_noc_txflit[i]), 
			    .snp_target_id(snp_target_id[i]),//comes from home nodes           
			    .current_r_addr_i(CURRENT_ADDR),            
			    .pronoc_flit_o(endp_flit_in[i]),
			    .pronoc_flit_wr_o(endp_flit_in_wr[i]),
			    .pronoc_credit_o(endp_credit_in[i]),
			    .clk(clk)
			);

		end else begin: other
		    chi_to_pronoc_wrapper #(
			    .CHI_FLIT_SIZE(CHI_FLIT_SIZE),
			    .P(MAX_P),
			    .T1(T1),
			    .T2(T2),
			    .T3(T3),
			    .RAw(RAw),
			    .EAw(EAw),
			    .NE(NE),
			    .DSTPw(DSTPw),
			    .TOPOLOGY(TOPOLOGY),
			    .ROUTE_NAME(ROUTE_NAME),
			    .ROUTE_TYPE(ROUTE_TYPE)
			)
			the_chi_to_pronoc_wrapper
			(
			    .chi_flitpend_i(chi_noc_txflitpend[i]),
			    .chi_flitv_i(chi_noc_txflitv[i]),
			    .chi_lcrdv_i(chi_noc_rxlcrdv[i]),	   
			    .chi_flit_i(chi_noc_txflit[i]),		  
			    .current_r_addr_i(CURRENT_ADDR),		  
			    .pronoc_flit_o(endp_flit_in[i]),
			    .pronoc_flit_wr_o(endp_flit_in_wr[i]),
			    .pronoc_credit_o(endp_credit_in[i]),
			    .clk(clk)
			);
		end	
		  
		 
		
		  // pronoc to chi    
		
		    
		 
		pronoc_to_chi_wrapper #(
		    .CHI_FLIT_SIZE(CHI_FLIT_SIZE),
		    .P(MAX_P),
		    .EAw(EAw),
		    .DSTPw(DSTPw)
		)
		the_pronoc_to_chi_wrapper
		(
		    
		    .pronoc_flit_i(endp_flit_out[i]),
		    .pronoc_flit_wr_i(endp_flit_out_wr[i]),
		    .pronoc_credit_i(endp_credit_out[i]),		  
		    .chi_flit_o(noc_chi_rxflit[i]),
		    .chi_flitpend_o(noc_chi_rxflitpend[i]),
		    .chi_flitv_o(noc_chi_rxflitv[i]),
		    .chi_lcrdv_o(noc_chi_txlcrdv[i])
		);
	end
	endgenerate	   



    router # (
	   .V(V),
	   .B(B),
	   .TOPOLOGY(TOPOLOGY),
	   .T1(T1),
	   .T2(T2),
	   .T3(T3),
	   .T4(T4),
	   .ROUTE_NAME(ROUTE_NAME),
	   .P(P),
	   .C(1),
	   .Fpay(PRONOC_Fw-3),
	   .MUX_TYPE("ONE_HOT"),
	   .VC_REALLOCATION_TYPE("NONATOMIC"),
	   .COMBINATION_TYPE("COMB_NONSPEC"),
	   .FIRST_ARBITER_EXT_P_EN(1),
	   .CONGESTION_INDEX(1),
	   .DEBUG_EN(DEBUG_EN),
	   .AVC_ATOMIC_EN(0),
	   .ADD_PIPREG_AFTER_CROSSBAR(0),
	   .SSA_EN("NO"),
	   .SWA_ARBITER_TYPE("RRA"),
	   .MIN_PCK_SIZE(1)
    )
   the_router
    (
	   .current_r_addr(CURRENT_ADDR),
	   .neighbors_r_addr(0),
	   .flit_in_all(flit_in_all),
	   .flit_in_wr_all(flit_in_wr_all),
	   .credit_out_all(credit_out_all),
	   .congestion_in_all(congestion_in_all),
	   .flit_out_all(flit_out_all),
	   .flit_out_wr_all(flit_out_wr_all),
	   .credit_in_all(credit_in_all),
	   .congestion_out_all(congestion_out_all),
	   .clk(clk),
	   .reset(reset)

    );

	//always @(posedge clk)begin 
	//	if(flit_in_wr_all!=0) $display("addr= %h, inwr=%b\n",CURRENT_ADDR,flit_in_wr_all);
	//	if(flit_out_wr_all!=0) $display("addr= %h, outwr=%b\n",CURRENT_ADDR,flit_out_wr_all);
	//end

endmodule
