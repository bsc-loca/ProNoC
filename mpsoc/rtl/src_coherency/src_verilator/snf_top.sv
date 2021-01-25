/**************************************
* Module: snf_verilator_top
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/
module  snf_top(
    src_id,
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend,
    chi_noc_txreqflitv,
    chi_noc_txreqflit,
    noc_chi_txreqlcrdv,
    
    // TXDAT
    chi_noc_txdatflitpend,
    chi_noc_txdatflitv,
    chi_noc_txdatflit,
    noc_chi_txdatlcrdv,
    
    // TXRSP
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,
    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop channel so need target ID
    chi_noc_txsnpflitpend,
    chi_noc_txsnpflitv,
    chi_noc_txsnpflit,
    noc_chi_txsnplcrdv,         
    
     // RXREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,          
    chi_noc_rxreqlcrdv,      
    
    
    // CRSP/RXRSP
    noc_chi_rxrspflitpend,
    noc_chi_rxrspflitv,
    noc_chi_rxrspflit,
    chi_noc_rxrsplcrdv,
    
    // RDAT
    noc_chi_rxdatflitpend,
    noc_chi_rxdatflitv,
    noc_chi_rxdatflit,
    chi_noc_rxdatlcrdv, 
    
    // SNP/RXSNP
    noc_chi_rxsnpflitpend,
    noc_chi_rxsnpflitv,
    noc_chi_rxsnpflit,
    chi_noc_rxsnplcrdv,
    
    snp_target_id,
    assign_hnfs

  
    );            
    
    
    
     `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  
    
     localparam CACHE_ADDRw = ADDR_REQ,
              CACHE_DATAw = DATA_DAT; 
    
    
    
    input [31 : 0] src_id;
    
    // Clock and Reset
    input clk,reset;
           
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    output   chi_noc_txreqflitpend ;
    output   chi_noc_txreqflitv;
    output  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit;          
    input  noc_chi_txreqlcrdv;
    // TXDAT
    output   chi_noc_txdatflitpend ;
    output   chi_noc_txdatflitv ;
    output  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit  ;
    input    noc_chi_txdatlcrdv ;
    // TXRSP
    output    chi_noc_txrspflitpend ;
    output   chi_noc_txrspflitv ;
    output  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit  ;
    input    noc_chi_txrsplcrdv ;
    // CRSP/RXRSP
    input    noc_chi_rxrspflitpend ;
    input    noc_chi_rxrspflitv ;
    input   [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit ;
    output   chi_noc_rxrsplcrdv ;
    // RDAT
    input    noc_chi_rxdatflitpend ;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output   chi_noc_rxdatlcrdv ; 
    // SNP/RXSNP
    input    noc_chi_rxsnpflitpend ;
    input    noc_chi_rxsnpflitv ;
    input   [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit ;
    output   chi_noc_rxsnplcrdv ;         
    
    
      //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop channel so need target ID
    output    chi_noc_txsnpflitpend ;
    output    chi_noc_txsnpflitv ;
    output   [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit ;
    input   noc_chi_txsnplcrdv ;         
    
     // RXREQ
    input   noc_chi_rxreqflitpend ;
    input   noc_chi_rxreqflitv;
    input  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit;          
    output   chi_noc_rxreqlcrdv;   

    output [EAw-1 : 0]  snp_target_id;   

    input [SRCID_REQ-1 : 0] assign_hnfs [MAX_HNFs_ASSIGND_TO_A_SN-1 : 0];
    
    wire [SRCID_REQ*MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] assign_hnfs_all;
    
    genvar i;
    generate 
	for(i=0;i<MAX_HNFs_ASSIGND_TO_A_SN;i=i+1)begin 
		assign assign_hnfs_all[(i+1)*SRCID_REQ-1 : i*SRCID_REQ]=assign_hnfs[i];
	end
    endgenerate 




    snf #(
    	.VERBOSITY(VERBOSITY),
    	.MAX_HNFs_ASSIGND_TO_A_SN(MAX_HNFs_ASSIGND_TO_A_SN),
    	.B(B),
    	.EAw(EAw),
    	.MEM_RD_PIPE_LATENCY(MEM_RD_PIPE_LATENCY),
    	.MEM_WR_PIPE_LATENCY(MEM_WR_PIPE_LATENCY)
    )
    the_snf
    (
    	.src_id(src_id),
    	.clk(clk),
    	.reset(reset),
    	.chi_noc_txreqflitpend(chi_noc_txreqflitpend),
    	.chi_noc_txreqflitv(chi_noc_txreqflitv),
    	.chi_noc_txreqflit(chi_noc_txreqflit),
    	.noc_chi_txreqlcrdv(noc_chi_txreqlcrdv),
    	.chi_noc_txdatflitpend(chi_noc_txdatflitpend),
    	.chi_noc_txdatflitv(chi_noc_txdatflitv),
    	.chi_noc_txdatflit(chi_noc_txdatflit),
    	.noc_chi_txdatlcrdv(noc_chi_txdatlcrdv),
    	.chi_noc_txrspflitpend(chi_noc_txrspflitpend),
    	.chi_noc_txrspflitv(chi_noc_txrspflitv),
    	.chi_noc_txrspflit(chi_noc_txrspflit),
    	.noc_chi_txrsplcrdv(noc_chi_txrsplcrdv),
    	.noc_chi_rxrspflitpend(noc_chi_rxrspflitpend),
    	.noc_chi_rxrspflitv(noc_chi_rxrspflitv),
    	.noc_chi_rxrspflit(noc_chi_rxrspflit),
    	.chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv),
    	.noc_chi_rxdatflitpend(noc_chi_rxdatflitpend),
    	.noc_chi_rxdatflitv(noc_chi_rxdatflitv),
    	.noc_chi_rxdatflit(noc_chi_rxdatflit),
    	.chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv),
    	.noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend),
    	.noc_chi_rxsnpflitv(noc_chi_rxsnpflitv),
    	.noc_chi_rxsnpflit(noc_chi_rxsnpflit),
    	.chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv),
    	.chi_noc_txsnpflitpend(chi_noc_txsnpflitpend),
    	.chi_noc_txsnpflitv(chi_noc_txsnpflitv),
    	.chi_noc_txsnpflit(chi_noc_txsnpflit),
    	.noc_chi_txsnplcrdv(noc_chi_txsnplcrdv),
    	.noc_chi_rxreqflitpend(noc_chi_rxreqflitpend),
    	.noc_chi_rxreqflitv(noc_chi_rxreqflitv),
    	.noc_chi_rxreqflit(noc_chi_rxreqflit),
    	.chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv),
    	.snp_target_id(snp_target_id),
    	.assign_hnfs(assign_hnfs_all)
    );


















endmodule

