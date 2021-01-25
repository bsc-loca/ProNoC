/**************************************
* Module: chi_rsp_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_rsp_noc_top(
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
            
    
    
    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  
    
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
  
    
    chi_rsp_noc #(
    	.B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .DEBUG_EN(DEBUG_EN),
    	.RSP_FLIT_SIZE(RSP_FLIT_SIZE)
    )
    rsp_noc_top
    (
    	.clk(clk),
    	.reset(reset),
    	.chi_noc_txrspflitpend_all(chi_noc_txrspflitpend_all),
    	.chi_noc_txrspflitv_all(chi_noc_txrspflitv_all),
    	.chi_noc_txrspflit_all(chi_noc_txrspflit_all),
    	.noc_chi_txrsplcrdv_all(noc_chi_txrsplcrdv_all),
    	.noc_chi_rxrspflitpend_all(noc_chi_rxrspflitpend_all),
    	.noc_chi_rxrspflitv_all(noc_chi_rxrspflitv_all),
    	.noc_chi_rxrspflit_all(noc_chi_rxrspflit_all),
    	.chi_noc_rxrsplcrdv_all(chi_noc_rxrsplcrdv_all)
    );
    
    

endmodule


