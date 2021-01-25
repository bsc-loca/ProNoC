// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

/**************************************
* Module: fattree
* Date:2019-01-01  
* Author: alireza     
*
* 
Description: 

    FatTree

      Each level of the hierarchical indirect Network has
      k^(l-1) Routers. The Routers are organized such that 
      each node has k descendents, and each parent is
      replicated k  times.
      most routers has 2K ports, excep the top level has only K

***************************************/


module  fattree_noc #(
    parameter V = 2, // Number of Virtual channel per port 
    parameter B = 4, // buffer space :flit per VC 
    parameter T1   = 2, // number of last level individual router`s endpoints.
    parameter T2   = 2, // Fattree layer number (The height of FT)
    parameter T3   = 1, // Its not used
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
    parameter MIN_PCK_SIZE=2, //minimum packet size in flits. The minimum value is 1.
    parameter BYTE_EN=0 //0:disable, 1: enable.   Add byte enable (BE) filed to header flit which shows the location of last valid byte in tail flit. It is needed once the send data unit is smaller than Fpay.   
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
  
   `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"
     
    
    localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;
 
        
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
        Fw = 2+V+Fpay, //flit width;    
        PFw = MAX_P * Fw,       
        NRL= NE/K, //number of router in  each layer       
        NEFw = NE * Fw,
        NEV = NE * V,
        CONG_ALw = CONGw * MAX_P,
        PLKw = MAX_P * LKw,
        PLw = MAX_P * Lw,       
        PRAw = MAX_P * RAw; // {layer , Pos} width     
  
    
    input reset,clk;    
    
    output [NEFw-1 : 0] flit_out_all;
    output [NE-1 : 0] flit_out_wr_all;
    input  [NEV-1 : 0] credit_in_all;
    input  [NEFw-1 : 0] flit_in_all;
    input  [NE-1 : 0] flit_in_wr_all;  
    output [NEV-1 : 0] credit_out_all;                
                        
                
    wire [PFw-1 : 0] router_flit_in_all [NR-1 :0];
    wire [MAX_P-1 : 0] router_flit_in_wr_all [NR-1 :0];    
    wire [PV-1 : 0] router_credit_out_all [NR-1 :0];
    
    wire [PFw-1 : 0] router_flit_out_all [NR-1 :0];
    wire [MAX_P-1 : 0] router_flit_out_wr_all [NR-1 :0];
    wire [PV-1 : 0] router_credit_in_all [NR-1 :0];                    
    wire [CONG_ALw-1: 0] router_congestion_out_all[NR-1 :0];    
    wire [CONG_ALw-1: 0] router_congestion_in_all [NR-1 :0];   
    
    
    wire [Fw-1 : 0] ni_flit_out [NE-1 :0];   
    wire [NE-1 : 0] ni_flit_out_wr; 
    wire [V-1 : 0] ni_credit_in [NE-1 :0];
    wire [Fw-1 : 0] ni_flit_in [NE-1 :0];   
    wire [NE-1 : 0] ni_flit_in_wr;  
    wire [V-1 : 0] ni_credit_out [NE-1 :0];  
    
    wire [PLKw-1 : 0]  neighbors_pos_all [NR-1 :0];//get a fixed value for each individual router
    wire [PLw-1  : 0]  neighbors_layer_all [NR-1 :0];   
    wire [PRAw-1 : 0]  neighbors_r_all [NR-1 :0]; 
    
    wire [LKw-1 : 0] current_pos_addr [NR-1 :0];
    wire [Lw-1  : 0] current_layer_addr [NR-1 :0];   
    wire [RAw-1 : 0] current_r_addr [NR-1 : 0];
    
//add roots

genvar pos,level,port;



generate 
for( pos=0; pos<NRL; pos=pos+1) begin : root 
      router # (
                .V(V),
                .P(K),
                .B(B), 
                .T1(K),
                .T2(L),               
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
                .MIN_PCK_SIZE(MIN_PCK_SIZE),
                .BYTE_EN(BYTE_EN) 
                
            )
            the_router
            (
                
                .current_r_addr(current_r_addr[pos]),
                .neighbors_r_addr(neighbors_r_all[pos][K*RAw-1    :   0]),                
                
                .flit_in_all(router_flit_in_all[pos][(K*Fw)-1 : 0]),
                .flit_in_wr_all(router_flit_in_wr_all[pos][K-1 : 0]),
                .credit_out_all(router_credit_out_all[pos][(K*V)-1 : 0]),
                .congestion_in_all(router_congestion_in_all[pos][(K*CONGw)-1 : 0]),            
            
                .flit_out_all(router_flit_out_all[pos][(K*Fw)-1 : 0]),
                .flit_out_wr_all(router_flit_out_wr_all[pos][K-1 : 0]),
                .credit_in_all(router_credit_in_all[pos][(K*V)-1 : 0]),
                .congestion_out_all(router_congestion_out_all[pos][(K*CONGw)-1 : 0]),
            
                .clk(clk),
                .reset(reset)
        
            );  
   
   
   
end   

//add leaves

for( level=1; level<L; level=level+1) begin :level_lp
   for( pos=0; pos<NRL; pos=pos+1) begin : pos_lp 
      
            router # (
                .V(V),
                .P(2*K),
                .B(B), 
                .T1(K),
                .T2(L),               
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
                .MIN_PCK_SIZE(MIN_PCK_SIZE),
                .BYTE_EN(BYTE_EN) 
                
            )
            the_router
            (
                              
                .current_r_addr(current_r_addr[NRL*level+pos]),
                .neighbors_r_addr(neighbors_r_all[NRL*level+pos]),                  
                
                .flit_in_all(router_flit_in_all[NRL*level+pos]),
                .flit_in_wr_all(router_flit_in_wr_all[NRL*level+pos]),
                .credit_out_all(router_credit_out_all[NRL*level+pos]),
                .congestion_in_all(router_congestion_in_all[NRL*level+pos]),            
            
                .flit_out_all(router_flit_out_all[NRL*level+pos]),
                .flit_out_wr_all(router_flit_out_wr_all[NRL*level+pos]),
                .credit_in_all(router_credit_in_all[NRL*level+pos]),
                .congestion_out_all(router_congestion_out_all[NRL*level+pos]),
            
                .clk(clk),
                .reset(reset)
        
            );  
   
    end
end
      
   
//connect all down input channels
localparam NPOS = powi( K, L-1);
localparam CHAN_PER_DIRECTION = (K * powi( L , L-1 )); //up or down
localparam CHAN_PER_LEVEL = 2*(K * powi( K , L-1 )); //up+down

for (level = 0; level<L-1; level=level+1) begin : level_c
/* verilator lint_off WIDTH */
    localparam [Lw-1 : 0] LEAVE_L = L-1-level;
/* verilator lint_on WIDTH */    
    //input channel are numbered interleavely, the interleaev depends on level
    localparam ROUTERS_PER_NEIGHBORHOOD = powi(K,L-1-(level)); 
    localparam ROUTERS_PER_BRANCH = powi(K,L-1-(level+1)); 
    localparam LEVEL_OFFSET = ROUTERS_PER_NEIGHBORHOOD*K;
    for ( pos = 0; pos < NPOS; pos=pos+1 ) begin : pos_c
        localparam ADRRENCODED=addrencode(pos,K,L,Kw);
        localparam NEIGHBORHOOD = (pos/ROUTERS_PER_NEIGHBORHOOD);
        localparam NEIGHBORHOOD_POS = pos % ROUTERS_PER_NEIGHBORHOOD;
        for ( port = 0; port < K; port=port+1 ) begin : port_c
            localparam LINK = 
                ((level+1)*CHAN_PER_LEVEL - CHAN_PER_DIRECTION)  //which levellevel
                +NEIGHBORHOOD* LEVEL_OFFSET   //region in level
                +port*ROUTERS_PER_BRANCH*K //sub region in region
                +(NEIGHBORHOOD_POS)%ROUTERS_PER_BRANCH*K //router in subregion
                +(NEIGHBORHOOD_POS)/ROUTERS_PER_BRANCH; //port on router


            localparam L2= (LINK+CHAN_PER_DIRECTION)/CHAN_PER_LEVEL;
            localparam POS2 = ((LINK+CHAN_PER_DIRECTION) % CHAN_PER_LEVEL)/K;
            localparam PORT2= (((LINK+CHAN_PER_DIRECTION) % CHAN_PER_LEVEL)  %K)+K;
            localparam ID1 =NRL*level+pos;
            localparam ID2 =NRL*L2 + POS2;
            localparam POS_ADR_CODE2= addrencode(POS2,K,L,Kw);
            localparam POS_ADR_CODE1= addrencode(pos,K,L,Kw);
           
            
           // $dotfile=$dotfile.node_connection('R',$id1,undef,$port,'R',$connect_id,undef,$connect_port);    
       
            assign  router_flit_in_all   [ID1][(port+1)*Fw-1 : port*Fw] = router_flit_out_all [ID2][(PORT2+1)*Fw-1 : PORT2*Fw];
            assign  router_flit_in_all   [ID2][(PORT2+1)*Fw-1 : PORT2*Fw] = router_flit_out_all [ID1][(port+1)*Fw-1 : port*Fw];  

            assign  router_credit_in_all [ID1][(port+1)*V-1 : port*V]= router_credit_out_all  [ID2][(PORT2+1)*V-1 : PORT2*V];
            assign  router_credit_in_all [ID2][(PORT2+1)*V-1 : PORT2*V]= router_credit_out_all [ID1][(port+1)*V-1 : port*V];

            assign  router_flit_in_wr_all[ID1][port] = router_flit_out_wr_all [ID2][PORT2];
            assign  router_flit_in_wr_all[ID2][PORT2] = router_flit_out_wr_all [ID1][port];

            assign  router_congestion_in_all  [ID1][(port+1)*CONGw-1 : port*CONGw]  = router_congestion_out_all  [ID2][(PORT2+1)*CONGw-1 : PORT2*CONGw];
            assign  router_congestion_in_all [ID2][(PORT2+1)*CONGw-1 : PORT2*CONGw] = router_congestion_out_all [ID1][(port+1)*CONGw-1 : port*CONGw];
            
            assign  neighbors_pos_all[ID1][(port+1)*LKw-1 : port*LKw] = POS_ADR_CODE2[LKw-1 :0];
            assign  neighbors_pos_all[ID2][(PORT2+1)*LKw-1 : PORT2*LKw] = POS_ADR_CODE1[LKw-1 :0]; 
            
            /* verilator lint_off WIDTH */
            assign  neighbors_layer_all[ID1][(port+1)*Lw-1 : port*Lw] =  L-L2-1;
            assign  neighbors_layer_all[ID2][(PORT2+1)*Lw-1 : PORT2*Lw] = LEAVE_L;        
            /* verilator lint_on WIDTH */
                     
            assign  neighbors_r_all[ID1][(port+1)*RAw-1 : port*RAw]   = {neighbors_layer_all[ID1][(port+1)*Lw-1 : port*Lw],neighbors_pos_all[ID1][(port+1)*LKw-1 : port*LKw]};
            assign  neighbors_r_all[ID2][(PORT2+1)*RAw-1 : PORT2*RAw] = {neighbors_layer_all[ID2][(PORT2+1)*Lw-1 : PORT2*Lw],neighbors_pos_all[ID2][(PORT2+1)*LKw-1 : PORT2*LKw]};
         
            assign current_layer_addr [ID1] = LEAVE_L;
            assign current_pos_addr [ID1] = ADRRENCODED[LKw-1 :0];         
            assign current_r_addr [ID1] = {current_layer_addr [ID1],current_pos_addr[ID1]};
         
         end
    end
end 
   
   
   
 for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints
    localparam RID= NRL*(L-1)+(pos/K);
    localparam RPORT = pos%K;
    
     //$dotfile=$dotfile.node_connection('T',$i,undef,undef,'R',$r,undef,$i%($k));    
 
            assign router_flit_in_all [RID][(RPORT+1)*Fw-1 : RPORT*Fw] =    ni_flit_out [pos];
            assign router_credit_in_all [RID][(RPORT+1)*V-1 : RPORT*V] =    ni_credit_out [pos];
            assign router_flit_in_wr_all [RID][RPORT] =    ni_flit_out_wr [pos];
            assign router_congestion_in_all[RID][(RPORT+1)*CONGw-1 : RPORT*CONGw] =   {CONGw{1'b0}};  
            
          //  assign  neighbors_layer_all[RID][(RPORT+1)*Lw-1 : RPORT*Lw] = {Lw{1'b0}};  
            assign  neighbors_r_all[RID][(RPORT+1)*RAw-1 : RPORT*RAw]   = {RAw{1'b0}};
            
            assign ni_flit_in [pos] = router_flit_out_all [RID][(RPORT+1)*Fw-1 : RPORT*Fw]; 
            assign ni_flit_in_wr [pos] = router_flit_out_wr_all[RID][RPORT];
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


