/**************************************
* Module: chi_dat_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_dat_noc_top  (
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
            
    
    
   `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  
    
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
 
 chi_dat_noc #(
 	.B(B),
    .TOPOLOGY(TOPOLOGY),
    .T1(T1),
    .T2(T2),
    .T3(T3),
    .T4(T4),
    .ROUTE_NAME(ROUTE_NAME),
    .DEBUG_EN(DEBUG_EN),
 	.DAT_FLIT_SIZE(DAT_FLIT_SIZE)
 )
 dat_noc_top
 (
 	.clk(clk),
 	.reset(reset),
 	.chi_noc_txdatflitpend_all(chi_noc_txdatflitpend_all),
 	.chi_noc_txdatflitv_all(chi_noc_txdatflitv_all),
 	.chi_noc_txdatflit_all(chi_noc_txdatflit_all),
 	.noc_chi_txdatlcrdv_all(noc_chi_txdatlcrdv_all),
 	.noc_chi_rxdatflitpend_all(noc_chi_rxdatflitpend_all),
 	.noc_chi_rxdatflitv_all(noc_chi_rxdatflitv_all),
 	.noc_chi_rxdatflit_all(noc_chi_rxdatflit_all),
 	.chi_noc_rxdatlcrdv_all(chi_noc_rxdatlcrdv_all)
 );
    
       
    
     
endmodule


