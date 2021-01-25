/**************************************
* Module: chi_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/
module  chi_noc #(
    parameter B = 4,     // buffer space :flit per VC 
    parameter TOPOLOGY= "MESH",     
    parameter T1= 2,
    parameter T2= 2,
    parameter T3= 1,
    parameter T4= 8,  
    parameter ROUTE_NAME = "XY",
    parameter DEBUG_EN=1,      
    parameter REQ_FLIT_SIZE=10,
    parameter DAT_FLIT_SIZE=10,
    parameter RSP_FLIT_SIZE=10,
    parameter SNP_FLIT_SIZE=10
    )(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend_all,
    chi_noc_txreqflitv_all,
    chi_noc_txreqflit_all,
    noc_chi_txreqlcrdv_all,
    
    // TXDAT
    chi_noc_txdatflitpend_all,
    chi_noc_txdatflitv_all,
    chi_noc_txdatflit_all,
    noc_chi_txdatlcrdv_all,
    
    // TXRSP
    chi_noc_txrspflitpend_all,
    chi_noc_txrspflitv_all,
    chi_noc_txrspflit_all,
    noc_chi_txrsplcrdv_all,
    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop channel so need target ID
    chi_noc_txsnpflitpend_all,
    chi_noc_txsnpflitv_all,
    chi_noc_txsnpflit_all,
    noc_chi_txsnplcrdv_all,         
    
     // RXREQ
    noc_chi_rxreqflitpend_all,
    noc_chi_rxreqflitv_all,
    noc_chi_rxreqflit_all,          
    chi_noc_rxreqlcrdv_all,      
    
    
    // CRSP/RXRSP
    noc_chi_rxrspflitpend_all,
    noc_chi_rxrspflitv_all,
    noc_chi_rxrspflit_all,
    chi_noc_rxrsplcrdv_all,
    
    // RDAT
    noc_chi_rxdatflitpend_all,
    noc_chi_rxdatflitv_all,
    noc_chi_rxdatflit_all,
    chi_noc_rxdatlcrdv_all, 
    
    // SNP/RXSNP
    noc_chi_rxsnpflitpend_all,
    noc_chi_rxsnpflitv_all,
    noc_chi_rxsnpflit_all,
    chi_noc_rxsnplcrdv_all,
    
    snp_target_id_all    
    );
            
    
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
 //   `include "../../src_noc/topology_localparam.v"    
   `include "../../src_noc/topology_localparam.v"    
    
    localparam 
        EAw_NE = EAw * NE,
        REQ_FLIT_SIZE_NE= NE * REQ_FLIT_SIZE,
        DAT_FLIT_SIZE_NE= NE * DAT_FLIT_SIZE,
        RSP_FLIT_SIZE_NE= NE * RSP_FLIT_SIZE,
        SNP_FLIT_SIZE_NE= NE * SNP_FLIT_SIZE;
    
    
    // Clock and Reset
    input clk,reset;
        
    input [EAw_NE-1 : 0]  snp_target_id_all;
    
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    input  [NE-1 : 0] chi_noc_txreqflitpend_all ;
    input  [NE-1 : 0] chi_noc_txreqflitv_all;
    input  [REQ_FLIT_SIZE_NE-1:0]    chi_noc_txreqflit_all;          
    output [NE-1 : 0] noc_chi_txreqlcrdv_all;
    // TXDAT
    input  [NE-1 : 0] chi_noc_txdatflitpend_all ;
    input  [NE-1 : 0] chi_noc_txdatflitv_all ;
    input  [DAT_FLIT_SIZE_NE-1:0]    chi_noc_txdatflit_all  ;
    output   [NE-1 : 0] noc_chi_txdatlcrdv_all ;
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
    // RDAT
    output   [NE-1 : 0] noc_chi_rxdatflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxdatflitv_all ;
    output   [DAT_FLIT_SIZE_NE-1:0]    noc_chi_rxdatflit_all ;
    input  [NE-1 : 0] chi_noc_rxdatlcrdv_all ; 
    // SNP/RXSNP
    output   [NE-1 : 0] noc_chi_rxsnpflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxsnpflitv_all ;
    output   [SNP_FLIT_SIZE_NE-1:0]    noc_chi_rxsnpflit_all ;
    input  [NE-1 : 0] chi_noc_rxsnplcrdv_all ;         
    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop channel so need target ID
    input   [NE-1 : 0] chi_noc_txsnpflitpend_all ;
    input   [NE-1 : 0] chi_noc_txsnpflitv_all ;
    input   [SNP_FLIT_SIZE_NE-1:0]    chi_noc_txsnpflit_all ;
    output  [NE-1 : 0] noc_chi_txsnplcrdv_all ;         
    
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
    req_noc
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
    rsp_noc
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
    dat_noc
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
    snp_noc
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

