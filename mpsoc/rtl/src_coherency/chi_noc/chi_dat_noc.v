/**************************************
* Module: chi_dat_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_dat_noc #(
    
   // parameter MAP_CHI_CHANNEL_ON= "VC", 
    /*
    "VC"= map each CHI channel on one Virtual channel. Only one channel can send a flit at each clock cycle
    "PHY" map each CHI channel in a seperate physical NoC
    */
    parameter B = 4,     // buffer space :flit per VC 
    parameter TOPOLOGY= "MESH",     
    parameter T1= 2,
    parameter T2= 2,
    parameter T3= 1,
    parameter T4= 8,  
    parameter ROUTE_NAME = "XY",
    parameter DEBUG_EN=1,      
    parameter DAT_FLIT_SIZE=10  
)(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
      
    // TXDAT
    chi_noc_txdatflitpend_all, 
    chi_noc_txdatflitv_all,
    chi_noc_txdatflit_all,
    noc_chi_txdatlcrdv_all,    
        
    // RDAT
    noc_chi_rxdatflitpend_all, 
    noc_chi_rxdatflitv_all,
    noc_chi_rxdatflit_all,
    chi_noc_rxdatlcrdv_all       
    
    );
       
    
    
`define INCLUDE_TOPOLOGY_LOCALPARAM
`ifdef VERILATOR
     `include "topology_localparam.v"    
`else
   `include "../../src_noc/topology_localparam.v"    
`endif
 
    localparam 
        EAw_NE = EAw * NE,
        DAT_FLIT_SIZE_NE= NE * DAT_FLIT_SIZE;
      
    
    
    // Clock and Reset
    input clk,reset;
        
   
    
    
    /*--------- Interface with NoC ---------------------------------*/
   
    // TXDAT
    input  [NE-1 : 0] chi_noc_txdatflitpend_all ;
    input  [NE-1 : 0] chi_noc_txdatflitv_all ;
    input  [DAT_FLIT_SIZE_NE-1:0]    chi_noc_txdatflit_all  ;
    output   [NE-1 : 0] noc_chi_txdatlcrdv_all ;
    
    // RDAT
    output   [NE-1 : 0] noc_chi_rxdatflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxdatflitv_all ;
    output   [DAT_FLIT_SIZE_NE-1:0]    noc_chi_rxdatflit_all ;
    input  [NE-1 : 0] chi_noc_rxdatlcrdv_all ; 
   
    wire  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit [NE-1 : 0];
    wire  [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit [NE-1 : 0];
 
   
/*----------------------------------------------------------------------------*/
/*ProNoC interface */
/*----------------------------------------------------------------------------*/
 
 localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
        PRONOC_DAT_Fw = PRONOC_OFFSEET + DAT_FLIT_SIZE + 3;
        
        
       
    //data channel IO
    wire [PRONOC_DAT_Fw * NE -1 : 0] dat_flit_out_all;
    wire [PRONOC_DAT_Fw-1 : 0] dat_flit_out [NE-1 : 0];
    wire [NE-1 : 0] dat_flit_out_wr_all;
    wire [NE-1 : 0] dat_credit_in_all;
    wire [PRONOC_DAT_Fw * NE-1 : 0] dat_flit_in_all;
    wire [PRONOC_DAT_Fw-1 : 0] dat_flit_in [NE-1 : 0];
    wire [NE-1 : 0] dat_flit_in_wr_all;  
    wire [NE-1 : 0] dat_credit_out_all;

  
    
    genvar i;
    generate 
    for(i=0;i<NE;i=i+1)begin :ne
     //connected router encoded address
        localparam CURRENTR=  i/T3;
        localparam CURRENTX=  CURRENTR%T1;
        localparam CURRENTY=  CURRENTR/T1;
        localparam [RAw-1 : 0] CURRENT_ADDR =  (CURRENTY<<NXw) + CURRENTX; 
        
       
        
       
        assign chi_noc_txdatflit[i] = chi_noc_txdatflit_all[(i+1)*DAT_FLIT_SIZE-1 : i*DAT_FLIT_SIZE];
        assign noc_chi_rxdatflit_all [(i+1)*DAT_FLIT_SIZE-1 : i*DAT_FLIT_SIZE] = noc_chi_rxdatflit[i];
        assign dat_flit_out[i] = dat_flit_out_all [(i+1)*PRONOC_DAT_Fw-1 : i*PRONOC_DAT_Fw];
        assign dat_flit_in_all [(i+1)*PRONOC_DAT_Fw-1 : i*PRONOC_DAT_Fw] = dat_flit_in[i];
            
        
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
            .chi_flitpend_i(chi_noc_txdatflitpend_all[i]),
            .chi_flitv_i(chi_noc_txdatflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxdatlcrdv_all[i]),        
            .chi_flit_i(chi_noc_txdatflit[i]),            
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(dat_flit_in[i]),
            .pronoc_flit_wr_o(dat_flit_in_wr_all[i]),
            .pronoc_credit_o(dat_credit_in_all[i]),
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
            
            .pronoc_flit_i(dat_flit_out[i]),
            .pronoc_flit_wr_i(dat_flit_out_wr_all[i]),
            .pronoc_credit_i(dat_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxdatflit[i]),
            .chi_flitpend_o(noc_chi_rxdatflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxdatflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txdatlcrdv_all[i])
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
        .Fpay(PRONOC_DAT_Fw-3),
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
    noc_dat //data
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(dat_flit_out_all),
        .flit_out_wr_all(dat_flit_out_wr_all),
        .credit_in_all(dat_credit_in_all),
        .flit_in_all(dat_flit_in_all),
        .flit_in_wr_all(dat_flit_in_wr_all),
        .credit_out_all(dat_credit_out_all)
    );
    
    
    
    
    
     
endmodule


