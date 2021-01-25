module rnf_top (
    src_id,    

    reset,
    clk,
    
    //control
    ReqOpcode,
    Request_en,  
        
    exclusive,
    likelyshared,
    Write_dat, 
    read_addr,
    send_done,
    can_accept_new_req,
   
    //core_cache_wr
    core_to_cache_wr_addr, 
    core_to_cache_wr_data, 
    core_to_cache_wr_state, 
    core_to_cache_wr_action, 
    core_to_cache_wr_en, 
    core_to_cache_wr_evict, 
    cache_to_core_wr_hit, 
    cache_to_core_wr_done, 
    cache_to_core_wr_ready, 
    
        
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
    
    
    // RXRSP
    noc_chi_rxrspflitpend,
    noc_chi_rxrspflitv,
    noc_chi_rxrspflit,
    chi_noc_rxrsplcrdv,
    
    // RXDAT
    noc_chi_rxdatflitpend,
    noc_chi_rxdatflitv,
    noc_chi_rxdatflit,
    chi_noc_rxdatlcrdv, 
    
    // RXSNP
    noc_chi_rxsnpflitpend,
    noc_chi_rxsnpflitv,
    noc_chi_rxsnpflit,
    chi_noc_rxsnplcrdv,
    
    snp_target_id
  
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
   
    //control
	
    input [OPCODE_REQ-1 : 0] ReqOpcode;
    input Request_en;
    input [DATA_DAT-1 : 0] Write_dat; 
    input [ADDR_REQ-1 : 0] read_addr;
   
    output send_done;
    output can_accept_new_req;
    input exclusive,likelyshared;
        
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
    // RXDAT
    input    noc_chi_rxdatflitpend ;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output   chi_noc_rxdatlcrdv ; 
    // RXSNP
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

    //core_cache_wr
    input [ADDR_REQ-1 :0  ] core_to_cache_wr_addr;
    input [DATA_DAT-1 : 0] core_to_cache_wr_data;
    input [CACHE_STATUSw-1:0] core_to_cache_wr_state;
    input [CACHE_ACTw-1:0] core_to_cache_wr_action;
    input core_to_cache_wr_en;
    input  core_to_cache_wr_evict;
    output cache_to_core_wr_hit;
    output cache_to_core_wr_done;
    output cache_to_core_wr_ready;

    rnf #(
    	.VERBOSITY(VERBOSITY),
    	.EAw(EAw),
    //	.src_id(src_id),
    	.NUM_OF_RNs(NUM_OF_RNs),
    	.NUM_OF_HNs(NUM_OF_HNs),
    	.B(B),
    	.CACHE_WAY_NUM(CACHE_WAY_NUM),
       	.CACHE_INDEXw(CACHE_INDEXw)
    )
    the_rnf
    (
    	.src_id(src_id),
    	.ReqOpcode(ReqOpcode),
    	.Request_en(Request_en),
    	.Write_dat(Write_dat),
    	.read_addr(read_addr),
    	.send_done(send_done),
    	.can_accept_new_req(can_accept_new_req),
    	.exclusive(exclusive),
    	.likelyshared(likelyshared),
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
    	.core_to_cache_wr_addr(core_to_cache_wr_addr),
    	.core_to_cache_wr_data(core_to_cache_wr_data),
    	.core_to_cache_wr_state(core_to_cache_wr_state),
    	.core_to_cache_wr_action(core_to_cache_wr_action),
    	.core_to_cache_wr_en(core_to_cache_wr_en),
    	.core_to_cache_wr_evict(core_to_cache_wr_evict),
    	.cache_to_core_wr_hit(cache_to_core_wr_hit),
    	.cache_to_core_wr_done(cache_to_core_wr_done),
    	.cache_to_core_wr_ready(cache_to_core_wr_ready)
    );

endmodule
