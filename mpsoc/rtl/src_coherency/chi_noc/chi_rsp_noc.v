/**************************************
* Module: chi_rsp_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_rsp_noc #(
    
   // parameter MAP_CHI_chanel_ON= "VC", 
    /*
    "VC"= map each CHI chanel on one Virtual chanel. Only one chanel can send a flit at each clock cycle
    "PHY" map each CHI chanel in a seperate physical NoC
    */
    parameter B = 4,     // buffer space :flit per VC 
    parameter TOPOLOGY= "MESH",     
    parameter T1= 2,
    parameter T2= 2,
    parameter T3= 1,
    parameter T4= 8,  
    parameter ROUTE_NAME = "XY",
    parameter DEBUG_EN=1,      
    parameter RSP_FLIT_SIZE=10
    )(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
      
    // TXRSP
    chi_noc_txrspflitpend_all,
    chi_noc_txrspflitv_all,
    chi_noc_txrspflit_all,
    noc_chi_txrsplcrdv_all,
            
    // CRSP/RXRSP
    noc_chi_rxrspflitpend_all,
    noc_chi_rxrspflitv_all,
    noc_chi_rxrspflit_all,
    chi_noc_rxrsplcrdv_all
    
   );
            
    
    
     
`define INCLUDE_TOPOLOGY_LOCALPARAM
`ifdef VERILATOR
     `include "topology_localparam.v"    
`else
   `include "../../src_noc/topology_localparam.v"    
`endif
    
    localparam 
        EAw_NE = EAw * NE,
        RSP_FLIT_SIZE_NE= NE * RSP_FLIT_SIZE;
    
    
    // Clock and Reset
    input clk,reset;
        

    
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXRSP
    input   [NE-1 : 0] chi_noc_txrspflitpend_all ;
    input  [NE-1 : 0] chi_noc_txrspflitv_all ;
    input  [RSP_FLIT_SIZE_NE-1:0]    chi_noc_txrspflit_all  ;
    output   [NE-1 : 0] noc_chi_txrsplcrdv_all ;
    // CRSP/RXRSP
    output   [NE-1 : 0] noc_chi_rxrspflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxrspflitv_all ;
    output   [RSP_FLIT_SIZE_NE-1:0]    noc_chi_rxrspflit_all ;
    input  [NE-1 : 0] chi_noc_rxrsplcrdv_all ;
  
    
    
   
    
   
    
    wire  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit [NE-1 : 0];
    wire  [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit [NE-1 : 0];
   
   
/*----------------------------------------------------------------------------*/
/*ProNoC interface */
/*----------------------------------------------------------------------------*/
 
 localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
        PRONOC_RSP_Fw = PRONOC_OFFSEET + RSP_FLIT_SIZE + 3;      
        
        
    

    //Response chanel IO
    wire [PRONOC_RSP_Fw * NE-1 : 0] rsp_flit_out_all;
    wire [PRONOC_RSP_Fw-1 : 0] rsp_flit_out [NE-1 : 0];
    wire [NE-1 : 0] rsp_flit_out_wr_all;
    wire [NE-1 : 0] rsp_credit_in_all;
    wire [PRONOC_RSP_Fw * NE-1 : 0] rsp_flit_in_all;
    wire [PRONOC_RSP_Fw-1 : 0] rsp_flit_in [NE-1 : 0];
    wire [NE-1 : 0] rsp_flit_in_wr_all;  
    wire [NE-1 : 0] rsp_credit_out_all;

   
    
    
    genvar i;
    generate 
    for(i=0;i<NE;i=i+1)begin :ne
     //connected router encoded address
        localparam CURRENTR=  i/T3;
        localparam CURRENTX=  CURRENTR%T1;
        localparam CURRENTY=  CURRENTR/T1;
        localparam [RAw-1 : 0] CURRENT_ADDR =  (CURRENTY<<NXw) + CURRENTX; 
      
      
        assign chi_noc_txrspflit[i] = chi_noc_txrspflit_all[(i+1)*RSP_FLIT_SIZE-1 : i*RSP_FLIT_SIZE];
        assign noc_chi_rxrspflit_all [(i+1)*RSP_FLIT_SIZE-1 : i*RSP_FLIT_SIZE] = noc_chi_rxrspflit[i];
        assign rsp_flit_out[i] = rsp_flit_out_all [(i+1)*PRONOC_RSP_Fw-1 : i*PRONOC_RSP_Fw];
        assign rsp_flit_in_all [(i+1)*PRONOC_RSP_Fw-1 : i*PRONOC_RSP_Fw] = rsp_flit_in[i];
       
                      
        
        chi_to_pronoc_wrapper #(
            .CHI_FLIT_SIZE(RSP_FLIT_SIZE),
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
        rsp_wrapper
        (
            .chi_flitpend_i(chi_noc_txrspflitpend_all[i]),
            .chi_flitv_i(chi_noc_txrspflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxrsplcrdv_all[i]),        
            .chi_flit_i(chi_noc_txrspflit[i]),            
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(rsp_flit_in[i]),
            .pronoc_flit_wr_o(rsp_flit_in_wr_all[i]),
            .pronoc_credit_o(rsp_credit_in_all[i]),
            .clk(clk)
        );
      
       // pronoc to chi    
        
            
        
         pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(RSP_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_rsp
        (
            
            .pronoc_flit_i(rsp_flit_out[i]),
            .pronoc_flit_wr_i(rsp_flit_out_wr_all[i]),
            .pronoc_credit_i(rsp_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxrspflit[i]),
            .chi_flitpend_o(noc_chi_rxrspflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxrspflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txrsplcrdv_all[i])
        );
        
        
     
    
   end
   endgenerate    
      
    
    
     noc #(
        .V(1),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .C(1),
        .Fpay(PRONOC_RSP_Fw-3),
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
    noc_rsp //response
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(rsp_flit_out_all),
        .flit_out_wr_all(rsp_flit_out_wr_all),
        .credit_in_all(rsp_credit_in_all),
        .flit_in_all(rsp_flit_in_all),
        .flit_in_wr_all(rsp_flit_in_wr_all),
        .credit_out_all(rsp_credit_out_all)
    );
    
    
    

endmodule


