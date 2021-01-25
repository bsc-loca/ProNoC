/**************************************
* Module: chi_req_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_req_noc_top (
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend_all,
    chi_noc_txreqflitv_all,
    chi_noc_txreqflit_all,
    noc_chi_txreqlcrdv_all,
      
    
     // RXREQ
    noc_chi_rxreqflitpend_all,
    noc_chi_rxreqflitv_all,
    noc_chi_rxreqflit_all,          
    chi_noc_rxreqlcrdv_all
    
 
    );
            
    
    
    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  
    
    localparam 
        EAw_NE = EAw * NE,
        REQ_FLIT_SIZE_NE= NE * REQ_FLIT_SIZE;
      
    
    
    // Clock and Reset
    input clk,reset;
        
    
    
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    input  [NE-1 : 0] chi_noc_txreqflitpend_all ;
    input  [NE-1 : 0] chi_noc_txreqflitv_all;
    input  [REQ_FLIT_SIZE_NE-1:0]    chi_noc_txreqflit_all;          
    output [NE-1 : 0] noc_chi_txreqlcrdv_all;
   
    
     // RXREQ
    output  [NE-1 : 0] noc_chi_rxreqflitpend_all ;
    output  [NE-1 : 0] noc_chi_rxreqflitv_all;
    output  [REQ_FLIT_SIZE_NE-1:0]    noc_chi_rxreqflit_all;          
    input  [NE-1 : 0] chi_noc_rxreqlcrdv_all;   
   
   
    chi_req_noc #(
    	.B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .DEBUG_EN(DEBUG_EN),
    	.REQ_FLIT_SIZE(REQ_FLIT_SIZE)
    )
    req_noc_top
    (
    	.clk(clk),
    	.reset(reset),
    	.chi_noc_txreqflitpend_all(chi_noc_txreqflitpend_all),
    	.chi_noc_txreqflitv_all(chi_noc_txreqflitv_all),
    	.chi_noc_txreqflit_all(chi_noc_txreqflit_all),
    	.noc_chi_txreqlcrdv_all(noc_chi_txreqlcrdv_all),
    	.noc_chi_rxreqflitpend_all(noc_chi_rxreqflitpend_all),
    	.noc_chi_rxreqflitv_all(noc_chi_rxreqflitv_all),
    	.noc_chi_rxreqflit_all(noc_chi_rxreqflit_all),
    	.chi_noc_rxreqlcrdv_all(chi_noc_rxreqlcrdv_all)
    );

endmodule
