/**************************************
 * Module: tree
 * Date:2019-01-01  
 * Author: alireza     
 *
 * 
Description: 

    Tree      

 ***************************************/

 
module  tree_noc_connection
	import pronoc_pkg::*; 
	(
	er_addr,
 	current_r_addr,    
	chan_in_all,
	chan_out_all,
	router_chan_in, 
	router_chan_out
);
  
  
	
	//local ports 
	input   router_chanel_t chan_in_all  [NE-1 : 0];
	output  router_chanel_t chan_out_all [NE-1 : 0];
	
	//all routers port 
	input   router_chanel_t router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	output  router_chanel_t router_chan_out  [NR-1 :0][MAX_P-1 : 0];

	output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint  
    output [RAw-1 : 0] current_r_addr [NR-1 : 0];
                         
   
        
	function integer addrencode;
		input integer pos,k,n,kw;
		integer pow,i,tmp;begin
			addrencode=0;
			pow=1;
			for (i = 0; i <n; i=i+1 ) begin 
				tmp=(pos/pow);
				tmp=tmp%k;
				tmp=tmp<<i*kw;
				addrencode=addrencode | tmp;
				pow=pow * k;
			end
		end   
	endfunction 
    
	  
    localparam
        PV = V * MAX_P,
        PFw = MAX_P * Fw,
        NEFw = NE * Fw,
        NEV = NE * V,
        CONG_ALw = CONGw * MAX_P,
        PLKw = MAX_P * LKw,
        PLw = MAX_P * Lw,       
        PRAw = MAX_P * RAw; // {layer , Pos} width
                
    
	wire [LKw-1 : 0] current_pos_addr [NR-1 :0];
	wire [Lw-1  : 0] current_layer_addr [NR-1 :0];   
	
      
     
    
	//add root 

	localparam [Lw-1 : 0] ROOT_L = L-1; 
	localparam ROOT_ID = 0;
 
	assign current_layer_addr [ROOT_ID] = ROOT_L;
	assign current_pos_addr [ROOT_ID] = {LKw{1'b0}};       
	assign current_r_addr[ROOT_ID] = {current_layer_addr [ROOT_ID],current_pos_addr[ROOT_ID]};

 
	
	genvar pos,level;


	generate
  
		//connect all up connections
		for (level = 1; level<L; level=level+1) begin : level_c
			localparam  NPOS = powi(K,level); // number of routers in this level
			localparam L1 = L-1-level;
			localparam level2= level - 1;
			localparam L2 = L-1-level2;
			for ( pos = 0; pos < NPOS; pos=pos+1 ) begin : pos_c
          
				localparam ID1 = sum_powi ( K,level) + pos;        
				localparam FATTREE_EQ_POS1 = pos*(K**L1);
				localparam ADR_CODE1=addrencode(FATTREE_EQ_POS1,K,L,Kw);       
				localparam POS2 = pos /K ;
				localparam ID2 = sum_powi ( K,level-1) + (pos/K);
				localparam PORT2= pos % K;  
				localparam FATTREE_EQ_POS2 = POS2*(K**L2);
				localparam ADR_CODE2=addrencode(FATTREE_EQ_POS2,K,L,Kw);
        
				// node_connection('Router[id1][k] to router[id2][pos%k];  
				assign  router_chan_out [ID1][K] = router_chan_in [ID2][PORT2];
				assign  router_chan_out [ID2][PORT2]= router_chan_in[ID1][K];  
							
				assign current_layer_addr [ID1] = L1[Lw-1 : 0];
				assign current_pos_addr [ID1] = ADR_CODE1 [LKw-1 : 0];         
				assign current_r_addr [ID1] = {current_layer_addr [ID1],current_pos_addr[ID1]};
       
        
			end// pos
    
		end //level


		// connect endpoints 
   
		for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints
			//  node_connection T[pos] R[rid][pos %k];
			localparam RID= sum_powi(K,L-1)+(pos/K);
			localparam RPORT = pos%K;
    		localparam CURRENTPOS=   addrencode(pos/K,K,L,Kw);
			  
			assign router_chan_out [RID][RPORT] =    chan_in_all [pos];                     
			assign chan_out_all [pos] = router_chan_in [RID][RPORT];
			assign er_addr [pos] = CURRENTPOS [RAw-1 : 0];
 
		end
	endgenerate    


endmodule
