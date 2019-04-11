// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

/**************************************
* Module: tree
* Date:2019-01-01  
* Author: alireza     
*
* 
Description: 

    Tree

      

***************************************/



module  tree_noc #(
    parameter V = 2, // Number of Virtual channel per port 
    parameter B = 4, // buffer space :flit per VC 
    parameter K   = 2, // number of last level individual router`s endpoints.
    parameter L   = 2, // Fattree layer number (The height of FT)
    parameter C = 4, // number of message class 
    parameter Fpay = 32, // packet payload width
    parameter MUX_TYPE =    "BINARY",    //"ONE_HOT" or "BINARY"
    parameter VC_REALLOCATION_TYPE =    "NONATOMIC",// "ATOMIC" , "NONATOMIC"
    parameter COMBINATION_TYPE= "COMB_NONSPEC",// "BASELINE", "COMB_SPEC1", "COMB_SPEC2", "COMB_NONSPEC"
    parameter FIRST_ARBITER_EXT_P_EN   =   1,// 1,0    
    parameter TOPOLOGY = "MESH",//"MESH","TORUS","RING" , "LINE"
    parameter ROUTE_NAME =   "XY",//
    parameter CONGESTION_INDEX =   2,
    parameter DEBUG_EN =   0,
    parameter AVC_ATOMIC_EN=1,
    parameter ADD_PIPREG_AFTER_CROSSBAR=0,
    parameter CVw=(C==0)? V : C * V,
    parameter [CVw-1: 0] CLASS_SETTING = {CVw{1'b1}}, // shows how each class can use VCs   
    parameter [V-1 : 0] ESCAP_VC_MASK = 4'b1000,  // mask scape vc, valid only for full adaptive
    parameter SSA_EN="NO", // "YES" , "NO" 
    parameter SWA_ARBITER_TYPE = "RRA",//"RRA","WRRA". SWA: Switch Allocator.  RRA: Round Robin Arbiter. WRRA Weighted Round Robin Arbiter          
    parameter WEIGHTw=4, // WRRA weights' max width
    parameter MIN_PCK_SIZE=2 //minimum packet size in flits. The minimum value is 1. 
)(
    reset,
    clk,    
    flit_out_all,
    flit_out_wr_all, 
    credit_in_all,
    flit_in_all,  
    flit_in_wr_all,  
    credit_out_all    
);


  localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;
                      
   
                                              

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 
    
    function integer powi; // x^y
        input integer x,y;
        integer i;begin //compute x to the y
        powi=1;
        for (i = 0; i <y; i=i+1 ) begin 
            powi=powi * x;
        end
        end   
    endfunction // powi
    
    
    function integer  sum_powi;//x^(y-1) + x^(y-2) + ...+ 1;
        input integer x,y;
        integer i;begin 
        sum_powi = 0;
        for (i = 0; i < y; i=i+1)begin
            sum_powi = sum_powi + powi( x, i );
       end 
	end  
    endfunction // sum_powi
    
    
        
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
    endfunction // log2 
        
    localparam P=  K+1;   //max p in the NoC
    
    localparam
        PV = V * P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = P * Fw,
        NE = powi( K,L ),  //total number of endpoints
        NR = sum_powi ( K,L ),  // total number of routers  
        Lw=log2(L),
        Kw=log2(K),
        LKw=L*Kw,
        NEFw = NE * Fw,
        NEV = NE * V,
        CONG_ALw = CONGw * P,
        PLKw = P * LKw,
        PLw = P * Lw , 
        RAw = Lw + LKw,
        PRAw = P * RAw; // {layer , Pos} width
       

    
    input reset,clk;    
    
    output [NEFw-1 : 0] flit_out_all;
    output [NE-1 : 0] flit_out_wr_all;
    input  [NEV-1 : 0] credit_in_all;
    input  [NEFw-1 : 0] flit_in_all;
    input  [NE-1 : 0] flit_in_wr_all;  
    output [NEV-1 : 0] credit_out_all;
                
                    
           
    wire [PLKw-1 : 0]   neighbors_pos_all [NR-1 :0];//get a fixed value for each individual router
    wire [PLw-1  : 0]  neighbors_layer_all [NR-1 :0];  
    wire [PRAw-1 : 0]  neighbors_r_all [NR-1 :0]; 
                
    wire [PFw-1 : 0] router_flit_in_all [NR-1 :0];
    wire [P-1 : 0] router_flit_in_we_all [NR-1 :0];    
    wire [PV-1 : 0] router_credit_out_all [NR-1 :0];
    
    wire [PFw-1 : 0] router_flit_out_all [NR-1 :0];
    wire [P-1 : 0] router_flit_out_we_all [NR-1 :0];
    wire [PV-1 : 0] router_credit_in_all [NR-1 :0];                    
    wire [CONG_ALw-1: 0] router_congestion_out_all[NR-1 :0];    
    wire [CONG_ALw-1: 0] router_congestion_in_all [NR-1 :0];   
    
    
    wire [Fw-1 : 0] ni_flit_out [NE-1 :0];   
    wire [NE-1 : 0] ni_flit_out_wr; 
    wire [V-1 : 0] ni_credit_in [NE-1 :0];
    wire [Fw-1 : 0] ni_flit_in [NE-1 :0];   
    wire [NE-1 : 0] ni_flit_in_wr;  
    wire [V-1 : 0] ni_credit_out [NE-1 :0];  
    
    
//add root 

 localparam [Lw-1 : 0] ROOT_L = L-1; 
 localparam ROOT_ADDR = (ROOT_L << LKw);
 
    router # (
        .V(V),
        .P(K),// root has k port number
        .B(B), 
        .T1(K),
        .T2(L),               
        .RXw(LKw),  
        .RYw(Lw),   
        .EXw(LKw), 
        .EYw(Lw),  
        .C(C),  
        .Fpay(Fpay),    
        .TOPOLOGY(TOPOLOGY),
        .MUX_TYPE(MUX_TYPE),
        .VC_REALLOCATION_TYPE(VC_REALLOCATION_TYPE),
        .COMBINATION_TYPE(COMBINATION_TYPE),
        .FIRST_ARBITER_EXT_P_EN(FIRST_ARBITER_EXT_P_EN),
        .ROUTE_NAME(ROUTE_NAME),  
        .CONGESTION_INDEX(CONGESTION_INDEX),
        .DEBUG_EN(DEBUG_EN),
        .AVC_ATOMIC_EN(AVC_ATOMIC_EN),
        .CONGw(CONGw),
        .ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
        .CVw(CVw),
        .CLASS_SETTING(CLASS_SETTING),   
        .ESCAP_VC_MASK(ESCAP_VC_MASK),
        .SSA_EN(SSA_EN),
        .SWA_ARBITER_TYPE(SWA_ARBITER_TYPE),
        .WEIGHTw(WEIGHTw),
        .MIN_PCK_SIZE(MIN_PCK_SIZE) 
    )
    the_router
    (
        .current_r_addr(ROOT_ADDR),
        .neighbors_r_addr(neighbors_r_all[0]),   
                
        .flit_in_all(router_flit_in_all[ROOT_ID][(K*Fw)-1 : 0]),
        .flit_in_we_all(router_flit_in_we_all[ROOT_ID][K-1 : 0]),
        .credit_out_all(router_credit_out_all[ROOT_ID][(K*V)-1 : 0]),
        .congestion_in_all(router_congestion_in_all[ROOT_ID][(K*CONGw)-1 : 0]),            
            
        .flit_out_all(router_flit_out_all[ROOT_ID][(K*Fw)-1 : 0]),
        .flit_out_we_all(router_flit_out_we_all[ROOT_ID][K-1 : 0]),
        .credit_in_all(router_credit_in_all[ROOT_ID][(K*V)-1 : 0]),
        .congestion_out_all(router_congestion_out_all[ROOT_ID][(K*CONGw)-1 : 0]),
            
        .clk(clk),
        .reset(reset)
        
    );  


genvar pos,level;


//add leaves
generate
for( level=1; level<L; level=level+1) begin :level_lp
    localparam [Lw-1 : 0] LEAVE_L = L-1-level;
    localparam NPOS1 = powi(K,level); // number of routers in this level
    localparam NRATTOP1 = sum_powi ( K,level); // number of routers at top levels : from root until last level
    for( pos=0; pos<NPOS1; pos=pos+1) begin : pos_lp 
        localparam FATTREE_EQ_POS_LEAVE = pos*(K**LEAVE_L);
        localparam [LKw-1 :0] ADRRENCODED1=addrencode(FATTREE_EQ_POS_LEAVE,K,L,Kw);
        localparam [RAw-1 :0] LEAVE_ADDR = (LEAVE_L << LKw) + ADRRENCODED1;
            
            
            router # (
                .V(V),
                .P(K+1),// leaves have K+1 port number
                .B(B), 
                .T1(K),
                .T2(L),               
                .RXw(LKw),  
                .RYw(Lw),   
                .EXw(LKw), 
                .EYw(Lw),  
                .C(C),  
                .Fpay(Fpay),    
                .TOPOLOGY(TOPOLOGY),
                .MUX_TYPE(MUX_TYPE),
                .VC_REALLOCATION_TYPE(VC_REALLOCATION_TYPE),
                .COMBINATION_TYPE(COMBINATION_TYPE),
                .FIRST_ARBITER_EXT_P_EN(FIRST_ARBITER_EXT_P_EN),
                .ROUTE_NAME(ROUTE_NAME),  
                .CONGESTION_INDEX(CONGESTION_INDEX),
                .DEBUG_EN(DEBUG_EN),
                .AVC_ATOMIC_EN(AVC_ATOMIC_EN),
                .CONGw(CONGw),
                .ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
                .CVw(CVw),
                .CLASS_SETTING(CLASS_SETTING),   
                .ESCAP_VC_MASK(ESCAP_VC_MASK),
                .SSA_EN(SSA_EN),
                .SWA_ARBITER_TYPE(SWA_ARBITER_TYPE),
                .WEIGHTw(WEIGHTw),
                .MIN_PCK_SIZE(MIN_PCK_SIZE) 
                
            )
            the_router
            (
                              
                .current_r_addr(LEAVE_ADDR),
                .neighbors_r_addr(neighbors_r_all[NRATTOP1+pos]),  
                 
                .flit_in_all(router_flit_in_all[NRATTOP1+pos]),
                .flit_in_we_all(router_flit_in_we_all[NRATTOP1+pos]),
                .credit_out_all(router_credit_out_all[NRATTOP1+pos]),
                .congestion_in_all(router_congestion_in_all[NRATTOP1+pos]),            
            
                .flit_out_all(router_flit_out_all[NRATTOP1+pos]),
                .flit_out_we_all(router_flit_out_we_all[NRATTOP1+pos]),
                .credit_in_all(router_credit_in_all[NRATTOP1+pos]),
                .congestion_out_all(router_congestion_out_all[NRATTOP1+pos]),
            
                .clk(clk),
                .reset(reset)
        
            );  
   
    end//pos
end // level
       
   
//connect all up connections
for (level = 1; level<L-1; level=level+1) begin : level_c
    localparam  NPOS = powi(K,level); // number of routers in this level
          
    for ( pos = 0; pos < NPOS; pos=pos+1 ) begin : pos_c
        localparam [Lw-1 : 0] L1 = L-1-level;
        localparam ID1 = sum_powi ( K,level) + pos;        
        localparam FATTREE_EQ_POS1 = pos*(K**L1);
        localparam [LKw-1 :0] ADR_CODE1=addrencode(FATTREE_EQ_POS1,K,L,Kw);
        
        localparam level2= level - 1;
        localparam [Lw-1 : 0] L2 = L-1-level2;
        localparam POS2 = pos /K ;
        localparam ID2 = sum_powi ( K,level-1) + (pos/K);
        localparam PORT2= pos % K;  
        localparam FATTREE_EQ_POS2 = POS2*(K**L2);
        localparam [LKw-1 :0] ADR_CODE2=addrencode(FATTREE_EQ_POS2,K,L,Kw);
        
        // node_connection('Router[id1][k] to router[id2][pos%k];  
                  
            assign  router_flit_in_all   [ID1][(K+1)*Fw-1 : K*Fw] = router_flit_out_all [ID2][(PORT2+1)*Fw-1 : PORT2*Fw];
            assign  router_flit_in_all   [ID2][(PORT2+1)*Fw-1 : PORT2*Fw] = router_flit_out_all [ID1][(K+1)*Fw-1 : K*Fw];  

            assign  router_credit_in_all [ID1][(K+1)*V-1 : K*V]= router_credit_out_all  [ID2][(PORT2+1)*V-1 : PORT2*V];
            assign  router_credit_in_all [ID2][(PORT2+1)*V-1 : PORT2*V]= router_credit_out_all [ID1][(K+1)*V-1 : K*V];


            assign  router_flit_in_we_all[ID1][K] = router_flit_out_we_all [ID2][PORT2];
            assign  router_flit_in_we_all[ID2][PORT2] = router_flit_out_we_all [ID1][K];

            assign  router_congestion_in_all  [ID1][(K+1)*CONGw-1 : K*CONGw]  = router_congestion_out_all  [ID2][(PORT2+1)*CONGw-1 : PORT2*CONGw];
            assign  router_congestion_in_all [ID2][(PORT2+1)*CONGw-1 : PORT2*CONGw] = router_congestion_out_all [ID1][(K+1)*CONGw-1 : K*CONGw];
            
            assign  neighbors_pos_all[ID1][(K+1)*LKw-1 : K*LKw] = ADR_CODE2;
            assign  neighbors_pos_all[ID2][(PORT2+1)*LKw-1 : PORT2*LKw] = ADR_CODE1;
            
            assign  neighbors_layer_all[ID1][(K+1)*Lw-1 : K*Lw] =  L2;
            assign  neighbors_layer_all[ID2][(PORT2+1)*Lw-1 : PORT2*Lw] =L1;   
            
            assign  neighbors_r_all[ID1][(K+1)*RAw-1 : K*RAw]   = {neighbors_layer_all[ID1][(K+1)*Lw-1 : K*Lw],neighbors_pos_all[ID1][(K+1)*LKw-1 : K*LKw]};
            assign  neighbors_r_all[ID2][(PORT2+1)*RAw-1 : PORT2*RAw] = {neighbors_layer_all[ID2][(PORT2+1)*Lw-1 : PORT2*Lw],neighbors_pos_all[ID2][(PORT2+1)*LKw-1 : PORT2*LKw]};
         
            
       
        end// pos
    
end //level


// connect endpoints 
   
 for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints
   //  node_connection T[pos] R[rid][pos %k];
    localparam RID= sum_powi(K,L-1)+(pos/K);
    localparam RPORT = pos%K;
    
     //$dotfile=$dotfile.node_connection('T',$i,undef,undef,'R',$r,undef,$i%($k));    
 
            assign router_flit_in_all [RID][(RPORT+1)*Fw-1 : RPORT*Fw] =    ni_flit_out [pos];
            assign router_credit_in_all [RID][(RPORT+1)*V-1 : RPORT*V] =    ni_credit_out [pos];
            assign router_flit_in_we_all [RID][RPORT] =    ni_flit_out_wr [pos];
            assign router_congestion_in_all[RID][(RPORT+1)*CONGw-1 : RPORT*CONGw] =   {CONGw{1'b0}};  
            
            //assign  neighbors_layer_all[RID][(RPORT+1)*Lw-1 : RPORT*Lw] = {Lw{1'b0}};            
            assign  neighbors_r_all[RID][(RPORT+1)*RAw-1 : RPORT*RAw]   = {RAw{1'b0}};
             
            assign ni_flit_in [pos] = router_flit_out_all [RID][(RPORT+1)*Fw-1 : RPORT*Fw]; 
            assign ni_flit_in_wr [pos] = router_flit_out_we_all[RID][RPORT];
            assign ni_credit_in [pos] = router_credit_out_all [RID][(RPORT+1)*V-1 : RPORT*V]; 
            
                                     
            assign  flit_out_all [(pos+1)*Fw-1 : pos*Fw] =   ni_flit_in [pos];   
            assign  flit_out_wr_all [pos] =   ni_flit_in_wr [pos]; 
            assign  ni_credit_out [pos] =   credit_in_all [(pos+1)*V-1 : pos*V];  
            assign  ni_flit_out [pos] =   flit_in_all [(pos+1)*Fw-1 : pos*Fw];
            assign  ni_flit_out_wr [pos] =   flit_in_wr_all [pos];
            assign  credit_out_all [(pos+1)*V-1 : pos*V] =   ni_credit_in [pos];
 
 
 end
 endgenerate    


endmodule


/**************************************
*
*   tree route function
*
***************************************/

// ============================================================
//  TREE: Nearest Common Ancestor w
// ============================================================

module tree_nca_routing  #(
   parameter K   = 2, // number of last level individual router`s endpoints.
   parameter L   = 2 // Fattree layer number (The height of FT)
  
)
(
   
    current_addr_encoded,    // connected to current router x address
    current_level,    //connected to current router y address
    dest_addr_encoded,        // destination address
    destport_encoded    // router output port
        
);
    

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 

        
    localparam
        Kw = log2(K),
        LKw= L*Kw,
        Lw = log2(L),
        DSPw= log2(K+1);       
  
    input  [LKw-1 :0]    current_addr_encoded;
    input  [Lw-1  :0]    current_level;    
    input  [LKw-1 :0]    dest_addr_encoded;
    output [DSPw-1:0]    destport_encoded;
    
    /******************
        There is always one destination path that can be selected for each destination endpoint
        Hence we can use the binary address of destination port      
    *******************/   
    
    wire  [Kw-1 :0]  current_addr [L-1 : 0];
    wire  [Kw-1 :0]  parrent_dest_addr [L-1 : 0];
    wire  [Kw-1 :0]  dest_addr [L-1 : 0];
    wire  [DSPw-1 :0]  current_node_dest_port;
    
    wire [L-1 : 0] parrents_node_missmatch;   
    
    assign current_addr [0]={Kw{1'b0}}; 
    assign parrent_dest_addr [0]={Kw{1'b0}}; 
       
    genvar i;
    generate 
    for(i=1; i<L; i=i+1)begin : caddr
        /* verilator lint_off WIDTH */ 
        assign current_addr [i] = (current_level <i)? current_addr_encoded[i*Kw-1 : (i-1)*Kw] : {Kw{1'b0}};
        assign parrent_dest_addr [i] = (current_level<i)? dest_addr_encoded[(i+1)*Kw-1 : i*Kw] : {Kw{1'b0}};
        /* verilator lint_on WIDTH */ 
    end
    
    
    for(i=0; i<L; i=i+1) begin : daddr
       // assign current_addr [i] = (current_level >=i)? current_addr_encoded[(i+1)*Kw-1 : i*Kw] : {Kw{1'b0}};
       
        assign dest_addr [i] =  dest_addr_encoded[(i+1)*Kw-1 : i*Kw];
        assign parrents_node_missmatch[i]=  current_addr [i] !=  parrent_dest_addr [i]; 
    end//for
    
    if(DSPw==Kw) begin :eq
        assign current_node_dest_port = dest_addr[current_level];
    end else begin :neq
        assign current_node_dest_port = {1'b0,dest_addr[current_level]};
    end    
    endgenerate
   
    assign destport_encoded = (parrents_node_missmatch != {L{1'b0}}) ? /*go up*/ K[DSPw-1: 0] :  /*go down*/current_node_dest_port;
      
endmodule


/*************************
 *  tree_conventional_routing 
 * **********************/


module tree_conventional_routing #(
    parameter ROUTE_NAME = "NCA",
    parameter K   = 2, // number of last level individual router`s endpoints.
    parameter L   = 2 // Fattree layer number (The height of FT)
 )
(
  
    current_addr_encoded,    // connected to current router x address
    current_level,    //connected to current router y address
    dest_addr_encoded,        // destination address
    destport_encoded    // router output port
        
);
    

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 
        
    localparam
        Kw = log2(K),
        LKw= L*Kw,
        Lw = log2(L),
        DSPw= log2(K+1);
   
    input  [LKw-1 :0]    current_addr_encoded;
    input  [Lw-1  :0]    current_level;    
    input  [LKw-1 :0]    dest_addr_encoded;
    output [DSPw-1  :0]    destport_encoded;
  
        tree_nca_routing #(
            .K(K),
            .L(L)
        )
        nca_random_up
        (
            .current_addr_encoded(current_addr_encoded),
            .current_level(current_level),
            .dest_addr_encoded(dest_addr_encoded),
            .destport_encoded(destport_encoded)
        );
  

endmodule



/************************************************
        deterministic_look_ahead_routing
**********************************************/

module  tree_deterministic_look_ahead_routing #(
    parameter P=4,
    parameter ROUTE_NAME = "NCA_RND_UP",
    parameter K   = 2, // number of last level individual router`s endpoints.
    parameter L   = 2 // Fattree layer number (The height of FT)
    
  )
  (
    destport_encoded,// current router destination port 
    dest_addr_encoded,
    neighbors_rx,
    neighbors_ry,
    lkdestport_encoded // look ahead destination port     
 );
    
   
   function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 

        
    localparam
        Kw = log2(K),
        LKw= L*Kw,
        Lw = log2(L),
        PLw = P * Lw,
        PLKw = P * LKw,
        DSPw= log2(K+1);
                    
   
    input  [DSPw-1 :0]    destport_encoded;
    input  [LKw-1 :0]    dest_addr_encoded;
    input  [PLKw-1 : 0]  neighbors_rx;
    input  [PLw-1 : 0]  neighbors_ry;
    output [DSPw-1: 0]    lkdestport_encoded;
      
      
    wire  [LKw-1 :0]    next_addr_encoded;
    wire  [Lw-1  :0]    next_level;  
    wire  [DSPw-1:0] lkdestport_encoded;  
             
    next_router_addr_selector_bin #(
         .P(P),
         .RXw(LKw), 
         .RYw(Lw)
    )
    addr_predictor
    (
        .destport_bin(destport_encoded[P-1 : 0]),
        .neighbors_rx(neighbors_rx),
        .neighbors_ry(neighbors_ry),
        .next_rx(next_addr_encoded),
        .next_ry(next_level)
    );
  
     
    tree_conventional_routing #(        
        .ROUTE_NAME(ROUTE_NAME),
        .K(K),
        .L(L)        
    )
    conv_routing
    (
      
        .current_addr_encoded(next_addr_encoded),
        .current_level(next_level),
        .dest_addr_encoded(dest_addr_encoded),
        .destport_encoded(lkdestport_encoded)
    );
     
 endmodule



/************************************

     tree_look_ahead_routing

*************************************/

module tree_look_ahead_routing #(
    parameter ROUTE_NAME = "NCA",
    parameter P = 4,
    parameter L = 2,
    parameter K = 2
   
)
(
    reset,
    clk,
    destport_encoded,// current router destination port 
    dest_addr_encoded,
    neighbors_rx,
    neighbors_ry,
    lkdestport_encoded // look ahead destination port     
);
    
   function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 

        
    localparam
        Kw = log2(K),
        LKw= L*Kw,
        Lw = log2(L),
        PLw = P * Lw,
        PLKw = P * LKw,
        DSPw= log2(K+1);
   
    input  [DSPw-1 :0]    destport_encoded;
    input  [LKw-1 :0]    dest_addr_encoded;
    input  [PLKw-1 : 0]  neighbors_rx;
    input  [PLw-1 : 0]  neighbors_ry;
    output [DSPw-1: 0]    lkdestport_encoded;
    input                   reset,clk;
    
    reg  [DSPw-1 :0]    destport_encoded_delayed;
    reg  [LKw-1 :0]    dest_addr_encoded_delayed;
    
     tree_deterministic_look_ahead_routing #(
        .P(P),
        .ROUTE_NAME(ROUTE_NAME),
        .K(K),
        .L(L)
     )
     look_ahead_routing
     (
        .destport_encoded(destport_encoded_delayed),
        .dest_addr_encoded(dest_addr_encoded_delayed),
        .neighbors_rx(neighbors_rx),
        .neighbors_ry(neighbors_ry),
        .lkdestport_encoded(lkdestport_encoded)
     );
     
        
      always @(posedge clk or posedge reset)begin
        if(reset)begin
            destport_encoded_delayed <= {DSPw{1'b0}};
            dest_addr_encoded_delayed<= {LKw{1'b0}};
        end else begin
            destport_encoded_delayed<=destport_encoded;
            dest_addr_encoded_delayed<=dest_addr_encoded;
        end//else reset
    end//always
    
endmodule







/******************
    tree_vc_alloc_request_gen
******************/

module  fattree_vc_alloc_request_gen #(
    parameter P = 5,
    parameter DSTPw=3,  //K+1,
    parameter V = 4
)(
    ovc_avalable_all,
    dest_port_in_encoded_all,
    candidate_ovc_all,
    ivc_request_all,
    ovc_is_assigned_all,
    dest_port_out_all,
    masked_ovc_request_all
);

    localparam  P_1     =   P-1,
                PV      =   V       *   P,
                PVV     =   PV      *  V,
                PVP_1   =   PV      *   P_1,
                VP_1    =   V       *   P_1,
                PVDSTPw= PV * DSTPw;

    input   [PV-1       :   0]  ovc_avalable_all;
    input   [PVDSTPw-1  :   0]  dest_port_in_encoded_all;
    input   [PV-1       :   0]  ivc_request_all;
    input   [PV-1       :   0]  ovc_is_assigned_all;
    output  [PVP_1-1    :   0]  dest_port_out_all;
    output  [PVV-1      :   0]  masked_ovc_request_all;
    input   [PVV-1      :   0]  candidate_ovc_all;
    
    wire    [PV-1       :   0]  non_assigned_ovc_request_all; 
    wire    [VP_1-1     :   0]  ovc_avalable_perport        [P-1    :   0];
    wire    [VP_1-1     :   0]  ovc_avalable_ivc            [PV-1   :   0];
    wire    [P_1-1      :   0]  dest_port_ivc               [PV-1   :   0];
    wire    [V-1        :   0]  ovc_avb_muxed               [PV-1   :   0];  
    wire    [V-1        :   0]  ovc_request_ivc             [PV-1   :   0];
  
    assign non_assigned_ovc_request_all =   ivc_request_all & ~ovc_is_assigned_all;
  
    
    genvar i;

    generate
    //remove avalable ovc of reciver port 
    for(i=0;i< P;i=i+1) begin :port_loop
        if(i==0) begin : first assign ovc_avalable_perport[i]=ovc_avalable_all [PV-1              :   V]; end
        else if(i==(P-1)) begin : last assign ovc_avalable_perport[i]=ovc_avalable_all [PV-V-1               :   0]; end
        else  begin : midle  assign ovc_avalable_perport[i]={ovc_avalable_all [PV-1  :   (i+1)*V],ovc_avalable_all [(i*V)-1  :   0]}; end
   
       
   
   
    end
    
    localparam K= DSTPw-1;
    
    wire [2*K-1 : 0] destport_decoded [PV-1 : 0];
    wire [2*K-1 : 0] destport_masked [PV-1 : 0];
        
    // IVC loop
    for(i=0;i< PV;i=i+1) begin :total_vc_loop
        //seprate input/output
        assign ovc_avalable_ivc[i]  =   ovc_avalable_perport[(i/V)];
        assign dest_port_ivc   [i]  =   dest_port_out_all [(i+1)*P_1-1  :   i*P_1   ];
        assign ovc_request_ivc [i]  = (non_assigned_ovc_request_all[i])? candidate_ovc_all  [(i+1)*V-1  :   i*V ]: {V{1'b0}};
          
        fattree_destport_encoder #(           
            .K(K)
        )
        fattree_destport_encoder
        (
            .destport_encoded_i(dest_port_in_encoded_all[(i+1)*DSTPw-1  :   i*DSTPw   ]),
            .destport_decoded_o(destport_decoded[i])
        );
       
        fattree_mask_non_assignable_destport #(
            .K(K),
            .P(P),
            .SW_LOC(i/V)        
        )
        mask
        (
            .destport_in(destport_decoded[i]),
            .destport_out(destport_masked[i])        
        );
       
       
        remove_sw_loc_one_hot #(
            .P(P),
            .SW_LOC(i/V)
        )
        conv
        (
            .destport_in(destport_masked[i][P-1 : 0]),
            .destport_out(dest_port_out_all[(i+1)*P_1-1  :   i*P_1   ])
        );  
       
            
       
        //available ovc multiplexer
        one_hot_mux #(
            .IN_WIDTH       (VP_1),
            .SEL_WIDTH      (P_1)
        )
        multiplexer
        (
            .mux_in     (ovc_avalable_ivc   [i]),
            .mux_out    (ovc_avb_muxed      [i]),
            .sel        (dest_port_ivc      [i])

        );
        
        // mask unavailable ovc from requests
        assign masked_ovc_request_all  [(i+1)*V-1   :   i*V ]     =   ovc_avb_muxed[i] & ovc_request_ivc [i];
        
    end
   endgenerate


endmodule

/**********
 *  fattree_mask_non_assignable_destport
 * ********/

module fattree_mask_non_assignable_destport #(
    parameter K=4,
    parameter P=2*K,
    parameter SW_LOC = 0        
)
(
    destport_in,
    destport_out        
);

    input [2*K-1 : 0] destport_in;
    output [2*K-1 : 0] destport_out;
    
    generate 
    if(P<=K)begin :root //This is a root node there is conectivety between all ports
        assign destport_out = destport_in;    
    end else begin: leaf
        if(SW_LOC < K) begin: down // This port located in lower side of the router. It can send packet to any destport 
            assign destport_out = destport_in;   
        end else begin : up // // This port located in upper side of the router. It cannot send packet to upper port anymore
            assign destport_out[2*K-1 : K] = {K{1'b0}};   
            assign destport_out[K-1 : 0] = destport_in [K-1 : 0];           
        end
    end
    endgenerate
endmodule

/********************

    distance_gen 
     
********************/

module fattree_distance_gen #(
    parameter K= 4,    
    parameter L= 4
)(
    src_addr_encoded,    
    dest_addr_encoded,       
    distance

);

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

     localparam
        Kw = log2(K),
        LKw= L*Kw,
        DISTw= log2(2*L+1);

     input  [LKw-1 :0]    src_addr_encoded;
     input  [LKw-1 :0]    dest_addr_encoded;
     output reg [DISTw-1 : 0] distance;
     
    
     
     wire  [Kw-1 :0]  dest_addr [L-1 : 0];
     wire  [Kw-1 :0]  src_addr [L-1 : 0];
     wire  [L-1 : 0] diffrent;
     
    
    genvar i;
    generate 
    for(i=0; i<L; i=i+1)begin : daddr      
        assign dest_addr [i] =  dest_addr_encoded[(i+1)*Kw-1 : i*Kw];
        assign src_addr [i] =  src_addr_encoded[(i+1)*Kw-1 : i*Kw];
        assign diffrent[i] = dest_addr [i] != src_addr [i];
    end//for
    endgenerate
     
    wire [11:0] tmp;
    assign tmp= {{(12-L){1'b0}},diffrent};
    /* verilator lint_off WIDTH */
    always @(*)begin
        if (tmp[10]) distance =21;
        else if (tmp[9]) distance =19;
        else if (tmp[8]) distance =17;
        else if (tmp[7]) distance =15;
        else if (tmp[6]) distance =13;
        else if (tmp[5]) distance =11;
        else if (tmp[4]) distance =9;
        else if (tmp[3]) distance =7;
        else if (tmp[2]) distance =5;
        else if (tmp[1]) distance =3;
        else distance =1;    
    end
    /* verilator lint_on WIDTH */


  

endmodule

/**************
    fattree_addr_encoder
    most probbely it is only needed for simulation purposes
***************/  

module  fattree_addr_encoder #(
    parameter   K=2,
    parameter   L=2

)(
    id,
    code
);
    
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 
    
    function integer powi;
        input integer x,y;
        integer i;begin //compute x to the y
        powi=1;
        for (i = 0; i <y; i=i+1 ) begin 
            powi=powi * x;
        end
        end   
    endfunction // log2 
        
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
    endfunction // log2 
        
      
    localparam       
        NE = powi( K,L ),  //total number of endpoints
        NEw = log2(NE),
        Kw=log2(K),
        LKw=L*Kw;


     input [NEw-1 :0] id;
     output [LKw-1 : 0] code;

    wire [LKw-1 : 0 ] codes [NE-1 : 0];
    genvar i;
    generate 
    for(i=0; i< NE; i=i+1) begin : endpoints
        //Endpoint decoded address
        localparam [LKw-1 : 0] ENDPX= addrencode(i,K,L,Kw);
        assign codes[i] = ENDPX;            
    end
    endgenerate

    assign code = codes[id];
endmodule



/**************
    fattree_addr_decoder
    most probbely it is only needed for simulation purposes
***************/  

module  fattree_addr_decoder #(
    parameter   K=2,
    parameter   L=2

)(
    id,
    code
);
    
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 
    
    function integer powi;
        input integer x,y;
        integer i;begin //compute x to the y
        powi=1;
        for (i = 0; i <y; i=i+1 ) begin 
            powi=powi * x;
        end
        end   
    endfunction // log2 
        
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
    endfunction // log2 
        
      
    localparam       
        NE = powi( K,L ),  //total number of endpoints
        NEw = log2(NE),
        Kw=log2(K),
        LKw=L*Kw;


     output [NEw-1 :0] id;
     input  [LKw-1 : 0] code;

    wire  [NE-1 : 0] codes  [LKw-1 : 0 ];
    genvar i;
    generate 
    for(i=0; i< NE; i=i+1) begin : endpoints
        //Endpoint decoded address
        localparam [LKw-1 : 0] ENDPX= addrencode(i,K,L,Kw);
        assign codes[ENDPX] = i;            
    end
    endgenerate

    assign id = codes[code];
endmodule

/**************
 * mesh_torus_ssa_check_destport_conflict
 * check if the incomming flit goes to SS port
 * ************/

module fattree_ssa_check_destport #(
    parameter DSTPw = 5,
    parameter SS_PORT=0
)
(
    destport_encoded, //exsited packet dest port
    destport_in_encoded, // incomming packet dest port
    ss_port_hdr_flit, // asserted if the header incomming flit goes to ss port
    ss_port_nonhdr_flit // asserted if the body or tail incomming flit goes to ss port
 );

    localparam K= DSTPw-1;
    localparam SS_LOC = (SS_PORT < K)? SS_PORT : SS_PORT-K;
    
    input [DSTPw-1 : 0] destport_encoded, destport_in_encoded; 
    output ss_port_hdr_flit, ss_port_nonhdr_flit;


/******************
        destport_encoded format in fat tree. K+1 bit
        destport[K] 
            1'b0  : go down 
            1'b1  : go up
        destport[K-1: 0]: 
            onehot coded. asserted bit show the output port locatation     
*******************/
    
    wire up_flg = destport_encoded[DSTPw-1];
    wire up_flg_in = destport_in_encoded[DSTPw-1];
    wire down_flg = ~destport_encoded[DSTPw-1];
    wire down_flg_in = ~destport_in_encoded[DSTPw-1];   
    
    
    generate 
    if(SS_PORT < K) begin :SS_DOWN // the ssa port is located in down router side
        assign ss_port_hdr_flit = destport_in_encoded [SS_LOC] & down_flg_in;   
        assign ss_port_nonhdr_flit =  destport_encoded[SS_LOC] & down_flg;   
    end else begin : SS_UP
        assign ss_port_hdr_flit = destport_in_encoded [SS_LOC] & up_flg_in;   
        assign ss_port_nonhdr_flit =  destport_encoded[SS_LOC] & up_flg;       
    end
    endgenerate    
    
endmodule


module fattree_add_ss_port #(   
    parameter SW_LOC=1,
    parameter P=5
)(
    destport_in,
    destport_out 
);
    localparam
        P_1     =   P-1,
        DISABLED   =    P;
    
    localparam  SS_PORT_FATTREE_EVEN =  (SW_LOC < (P/2) )? (P/2)+ SW_LOC-1 : SW_LOC - (P/2);
    localparam  SS_PORT_FATTREE_ODD  =  (SW_LOC == (P-1)/2)?   DISABLED:
                                        (SW_LOC < ((P+1)/2) )? ((P+1)/2)+ SW_LOC-1 : SW_LOC - ((P+1)/2);
        
    localparam  SS_PORT_FATTREE = (P[0]==1'b0) ? SS_PORT_FATTREE_EVEN : SS_PORT_FATTREE_ODD;

    localparam  SS_PORT      =   SS_PORT_FATTREE;
     
          
    
     
    input       [P_1-1  :   0] destport_in;
    output reg  [P_1-1  :   0] destport_out; 
     
     
     
    always @(*)begin 
        destport_out=destport_in;
        if( SS_PORT != DISABLED ) begin 
            if(destport_in=={P_1{1'b0}}) destport_out[SS_PORT]= 1'b1;
        end    
    end 
     

endmodule
 

  /*************
 * tree_destport_encoder
 * ***********/

 module tree_destport_encoder #(
     parameter K=2 
 )(
    destport_decoded_o,
    destport_encoded_i  
 );
     function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end        
      end   
    endfunction // log2 
 
    localparam DSPw= log2(K+1);     
 
    input  [DSPw-1 : 0] destport_encoded_i;
    output [K : 0] destport_decoded_o; 
    
    
    bin_to_one_hot #(
        .BIN_WIDTH(DSPw),
        .ONE_HOT_WIDTH(K+1)
    )
    cnvt
    (
        .bin_code(destport_encoded_i),
        .one_hot_code(destport_decoded_o)
    );
    
    
    // dest port is not coded in tree
    assign destport_decoded_o =  destport_encoded_i;
   
endmodule

 
