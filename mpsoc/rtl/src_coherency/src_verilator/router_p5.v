module router_verilator_p5
(
    clk,
    reset,
     /*--------- Interface with NoC ---------------------------------*/
    ENDP,
   
    // TXDAT
    chi_noc_txdatflitpend,
    chi_noc_txdatflitv,
    chi_noc_txdatflit,
    noc_chi_txdatlcrdv,
    
    // RDAT
    noc_chi_rxdatflitpend,
    noc_chi_rxdatflitv,
    noc_chi_rxdatflit,
    chi_noc_rxdatlcrdv 
);

    localparam P=5;   

    `define   INCLUDE_PARAM
    `include "parameter.v"

    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"
 

    input clk,reset;
     /*--------- Interface with NoC ---------------------------------*/
    input [31 : 0] ENDP;
   
    // TXDAT
    input  chi_noc_txdatflitpend;
    input  chi_noc_txdatflitv;
    input  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit;
    output noc_chi_txdatlcrdv;
    
    // RDAT
    output   noc_chi_rxdatflitpend;
    output   noc_chi_rxdatflitv;
    output   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit;
    input    chi_noc_rxdatlcrdv; 
   


    localparam CURRENTR=  ENDP/T3;
    localparam CURRENTX=  CURRENTR%T1;
    localparam CURRENTY=  CURRENTR/T1;
    localparam [RAw-1 : 0] CURRENT_ADDR =  (CURRENTY<<NXw) + CURRENTX; 
        
       
    wire  [RAw-1 : 0] current_r_addr;    
    

    wire  [RAw-1 :  0] neighbors_r_addr [P-1 : 0];    
    wire  [Fw-1 : 0]  flit_in [P-1 : 0];
    wire  [P-1 : 0]  flit_in_wr;
    wire  [V-1 : 0]  credit_out [P-1 : 0];
    wire  [CONG_ALw-1 : 0]  congestion_in;  
     
    wire  [Fw-1 : 0]  flit_out [P-1 : 0];
    wire  [P-1 : 0]  flit_out_wr;
    wire  [V-1 : 0]  credit_in [P-1 : 0];
    wire  [CONG_ALw-1 : 0]  congestion_out;   
       
       
            
        
    chi_to_pronoc_wrapper #(
            .CHI_FLIT_SIZE(DAT_FLIT_SIZE),
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
        dat_wrapper
        (
            .chi_flitpend_i(chi_noc_txdatflitpend),
            .chi_flitv_i(chi_noc_txdatflitv),
            .chi_lcrdv_i(chi_noc_rxdatlcrdv),        
            .chi_flit_i(chi_noc_txdatflit),            
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(dat_flit_in),
            .pronoc_flit_wr_o(dat_flit_in_wr),
            .pronoc_credit_o(dat_credit_in),
            .clk(clk)
        );
        
       
      
        
       // pronoc to chi    
        
            
      
         pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(DAT_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_dat
        (
            
            .pronoc_flit_i(dat_flit_out),
            .pronoc_flit_wr_i(dat_flit_out_wr),
            .pronoc_credit_i(dat_credit_out),            
            .chi_flit_o(noc_chi_rxdatflit),
            .chi_flitpend_o(noc_chi_rxdatflitpend),
            .chi_flitv_o(noc_chi_rxdatflitv),
            .chi_lcrdv_o(noc_chi_txdatlcrdv)
        );
        









localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;


   
    localparam         
        PV = V * P,
        P_1 = P-1,
        Fw = 2+V+Fpay,  //flit width;
        PFw = P * Fw,
        CONG_ALw = CONGw * P,    //  congestion width per router      
        W = WEIGHTw,
        WP = W * P,
        PRAw = P * RAw;    


    



    router # (
        .V(V),
        .P(P),
        .B(B), 
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .C(C),  
        .Fpay(Fpay),    
        .MUX_TYPE(MUX_TYPE),
        .VC_REALLOCATION_TYPE(VC_REALLOCATION_TYPE),
        .COMBINATION_TYPE(COMBINATION_TYPE),
        .FIRST_ARBITER_EXT_P_EN(FIRST_ARBITER_EXT_P_EN),
        .TOPOLOGY(TOPOLOGY),
        .ROUTE_NAME(ROUTE_NAME),  
        .AVC_ATOMIC_EN(AVC_ATOMIC_EN),
        .CONGESTION_INDEX(CONGESTION_INDEX),
        .CONGw(CONGw),
        .DEBUG_EN(DEBUG_EN),
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
        .current_r_addr(current_r_addr),
        .neighbors_r_addr({neighbors_r_addr[4],neighbors_r_addr[3],neighbors_r_addr[2],neighbors_r_addr[1],neighbors_r_addr[0]}),
        .flit_in_all({flit_in[4],flit_in[3],flit_in[2],flit_in[1],flit_in[0]}),
        .flit_in_wr_all(flit_in_wr),
        .credit_out_all({credit_out[4],credit_out[3],credit_out[2],credit_out[1],credit_out[0]}),
        .congestion_in_all({congestion_in[4],congestion_in[3],congestion_in[2],congestion_in[1],congestion_in[0]}),
        .flit_out_all({flit_out[4],flit_out[3],flit_out[2],flit_out[1],flit_out[0]}),
        .flit_out_wr_all(flit_out_wr),
        .credit_in_all({credit_in[4],credit_in[3],credit_in[2],credit_in[1],credit_in[0]}),
        .congestion_out_all({congestion_out[4],congestion_out[3],congestion_out[2],congestion_out[1],congestion_out[0]}),
        .clk(clk),
        .reset(reset)

    );
endmodule
