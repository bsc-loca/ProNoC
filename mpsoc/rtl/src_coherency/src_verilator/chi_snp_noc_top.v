/**************************************
* Module: chi_snp_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_snp_noc_top(
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
     
    
    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  
    
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
    
    
   chi_snp_noc #(
    .B(B),
    .TOPOLOGY(TOPOLOGY),
    .T1(T1),
    .T2(T2),
    .T3(T3),
    .T4(T4),
    .ROUTE_NAME(ROUTE_NAME),
    .DEBUG_EN(DEBUG_EN),
   	.SNP_FLIT_SIZE(SNP_FLIT_SIZE)
   )
   snp_noc_top
   (
   	.clk(clk),
   	.reset(reset),
   	.snp_target_id_all(snp_target_id_all),
   	.noc_chi_rxsnpflitpend_all(noc_chi_rxsnpflitpend_all),
   	.noc_chi_rxsnpflitv_all(noc_chi_rxsnpflitv_all),
   	.noc_chi_rxsnpflit_all(noc_chi_rxsnpflit_all),
   	.chi_noc_rxsnplcrdv_all(chi_noc_rxsnplcrdv_all),
   	.chi_noc_txsnpflitpend_all(chi_noc_txsnpflitpend_all),
   	.chi_noc_txsnpflitv_all(chi_noc_txsnpflitv_all),
   	.chi_noc_txsnpflit_all(chi_noc_txsnpflit_all),
   	.noc_chi_txsnplcrdv_all(noc_chi_txsnplcrdv_all)
   );

endmodule

