/**************************************
* Module: chi_snp_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_snp_noc #(
    
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
    parameter SNP_FLIT_SIZE=10
    )(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop chanel so need target ID
    chi_noc_txsnpflitpend_all, 
    chi_noc_txsnpflitv_all,
    chi_noc_txsnpflit_all,
    noc_chi_txsnplcrdv_all,         
         
    // SNP/RXSNP
    noc_chi_rxsnpflitpend_all,
    noc_chi_rxsnpflitv_all,
    noc_chi_rxsnpflit_all,
    chi_noc_rxsnplcrdv_all,
    
    snp_target_id_all    
    );
            
    
    
      
`define INCLUDE_TOPOLOGY_LOCALPARAM
`ifdef VERILATOR
     `include "topology_localparam.v"    
`else
   `include "../../src_noc/topology_localparam.v"    
`endif
    
    localparam 
        EAw_NE = EAw * NE,
        SNP_FLIT_SIZE_NE= NE * SNP_FLIT_SIZE;
    
    
    // Clock and Reset
    input clk,reset;
        
    input [EAw_NE-1 : 0]  snp_target_id_all;
    
    
    /*--------- Interface with NoC ---------------------------------*/
   
    // SNP/RXSNP
    output   [NE-1 : 0] noc_chi_rxsnpflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxsnpflitv_all ;
    output   [SNP_FLIT_SIZE_NE-1:0]    noc_chi_rxsnpflit_all ;
    input  [NE-1 : 0] chi_noc_rxsnplcrdv_all ;         
    
    
      //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop chanel so need target ID
    input   [NE-1 : 0] chi_noc_txsnpflitpend_all ;
    input   [NE-1 : 0] chi_noc_txsnpflitv_all ;
    input   [SNP_FLIT_SIZE_NE-1:0]    chi_noc_txsnpflit_all ;
    output  [NE-1 : 0] noc_chi_txsnplcrdv_all ;         
    
      
  
    wire  [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit [NE-1 : 0];
    wire  [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit [NE-1 : 0];  
   
/*----------------------------------------------------------------------------*/
/*ProNoC interface */
/*----------------------------------------------------------------------------*/
 
 localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
        PRONOC_SNP_Fw = PRONOC_OFFSEET + SNP_FLIT_SIZE + 3;      
        
        
    

    //snoop chanel IO
    wire [PRONOC_SNP_Fw * NE-1 : 0] snp_flit_out_all;
    wire [PRONOC_SNP_Fw-1 : 0] snp_flit_out [NE-1 : 0];
    wire [NE-1 : 0] snp_flit_out_wr_all;
    wire [NE-1 : 0] snp_credit_in_all;
    wire [PRONOC_SNP_Fw * NE-1 : 0] snp_flit_in_all;
    wire [PRONOC_SNP_Fw-1 : 0] snp_flit_in [NE-1 : 0];
    wire [NE-1 : 0] snp_flit_in_wr_all;  
    wire [NE-1 : 0] snp_credit_out_all;
    
    
    wire [EAw-1 : 0] snp_target_id [NE-1 : 0];
    
    
    genvar i;
    generate 
    for(i=0;i<NE;i=i+1)begin :ne
     //connected router encoded address
        localparam CURRENTR=  i/T3;
        localparam CURRENTX=  CURRENTR%T1;
        localparam CURRENTY=  CURRENTR/T1;
        localparam [RAw-1 : 0] CURRENT_ADDR =  (CURRENTY<<NXw) + CURRENTX; 
        
        assign snp_target_id [i] = snp_target_id_all[(i+1)* EAw-1 : i* EAw];
        assign chi_noc_txsnpflit[i] = chi_noc_txsnpflit_all[(i+1)*SNP_FLIT_SIZE-1 : i*SNP_FLIT_SIZE];
        assign noc_chi_rxsnpflit_all [(i+1)*SNP_FLIT_SIZE-1 : i*SNP_FLIT_SIZE] = noc_chi_rxsnpflit[i];  
        assign snp_flit_out[i] = snp_flit_out_all [(i+1)*PRONOC_SNP_Fw-1 : i*PRONOC_SNP_Fw];
        assign snp_flit_in_all [(i+1)*PRONOC_SNP_Fw-1 : i*PRONOC_SNP_Fw] = snp_flit_in[i];
          
        
        
        chi_to_pronoc_snoop_wrapper #(
            .CHI_FLIT_SIZE(SNP_FLIT_SIZE),
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
            .chi_flitpend_i(chi_noc_txsnpflitpend_all[i]),
            .chi_flitv_i(chi_noc_txsnpflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxsnplcrdv_all[i]),        
            .chi_flit_i(chi_noc_txsnpflit[i]),
            .snp_target_id(snp_target_id[i]),//comes from home nodes
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(snp_flit_in[i]),
            .pronoc_flit_wr_o(snp_flit_in_wr_all[i]),
            .pronoc_credit_o(snp_credit_in_all[i]),
            .clk(clk)            
        );
        
   
        
        
        pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(SNP_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_snp
        (            
            .pronoc_flit_i(snp_flit_out[i]),
            .pronoc_flit_wr_i(snp_flit_out_wr_all[i]),
            .pronoc_credit_i(snp_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxsnpflit[i]),
            .chi_flitpend_o(noc_chi_rxsnpflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxsnpflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txsnplcrdv_all[i])
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
        .Fpay(PRONOC_SNP_Fw-3),
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
    noc_snp//snoop
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(snp_flit_out_all),
        .flit_out_wr_all(snp_flit_out_wr_all),
        .credit_in_all(snp_credit_in_all),
        .flit_in_all(snp_flit_in_all),
        .flit_in_wr_all(snp_flit_in_wr_all),
        .credit_out_all(snp_credit_out_all)
    );

endmodule

