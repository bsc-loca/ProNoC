/**************************************
* Module: request_full_node
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  rnf #(
    parameter VERBOSITY=4, // The higher the VERBOSITY the higher details are printed in simuation terminal
    parameter EAw=4,
   // parameter src_id=0,
    parameter NUM_OF_RNs=4,
    parameter NUM_OF_HNs=4, // must be power  of 2
    parameter B=4,
    parameter CACHE_WAY_NUM =8,
    parameter CACHE_INDEXw=10
    
    )(
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
    
   
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
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
    
    
    //rxdat_cache_wr
    wire [ADDR_REQ-1 :0  ] rxdat_to_cache_wr_addr;
    wire [DATA_DAT-1 : 0] rxdat_to_cache_wr_data;
    wire [CACHE_STATUSw-1:0] rxdat_to_cache_wr_state;
    wire [CACHE_ACTw-1:0] rxdat_to_cache_wr_action;
    wire rxdat_to_cache_wr_en;
    wire  rxdat_to_cache_wr_evict;
    wire cache_to_rxdat_wr_hit;
    wire cache_to_rxdat_wr_done;
    wire cache_to_rxdat_wr_ready;
   
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
    
    
    //rxsnp_cache_rd
    wire [ADDR_REQ-1 : 0] rxsnp_to_cache_rd_addr;
    wire  [DATA_DAT-1 : 0] cache_to_rxsnp_rd_data;
    wire rxsnp_to_cache_rd_en;
    wire cache_to_rxsnp_rd_ready;   
    wire [CACHE_STATUSw-1 : 0] cache_to_rxsnp_rd_state;
    wire cache_to_rxsnp_rd_hit;
    wire cache_to_rxsnp_rd_done;    
    
    //rxsnp_cache_wr     
    wire [ADDR_REQ-1 :0  ] rxsnp_to_cache_wr_addr;
    wire [DATA_DAT-1 : 0] rxsnp_to_cache_wr_data;
    wire [CACHE_STATUSw-1:0] rxsnp_to_cache_wr_state;
    wire [CACHE_ACTw-1:0] rxsnp_to_cache_wr_action;
    wire rxsnp_to_cache_wr_en;
    wire rxsnp_to_cache_wr_evict;
    wire cache_to_rxsnp_wr_hit;
    wire cache_to_rxsnp_wr_done;
    wire cache_to_rxsnp_wr_ready;
    
    //rxrsp_cache_rd
    wire [CACHE_ADDRw-1 : 0] rxrsp_to_cache_rd_addr;
    wire [DATA_DAT-1 : 0] cache_to_rxrsp_rd_data;
    wire rxrsp_to_cache_rd_en;
    wire cache_to_rxrsp_rd_ready;   
    wire [CACHE_STATUSw-1 : 0] cache_to_rxrsp_rd_state;
    wire cache_to_rxrsp_rd_hit;
    wire cache_to_rxrsp_rd_done;    
   
   
    
    wire [TXNID_REQ-1 :  0] txreq_to_lkpt_txnid,rxdat_to_lkpt_txnid;
    wire rxdat_to_lkpt_rd_valid;
    wire [RNF_TXN_DATAw-1 :  0] txreq_to_lkpt_txndat;
    wire txreq_to_lkpt_new_txn;
    wire  [RNF_TXN_DATAw-1 :  0] lkpt_to_rxdat_txndat;
    
    wire [TXNID_REQ-1 :  0] rxrsp_to_txreq_txnid; 
    wire rxrsp_to_txreq_txnid_release;
   
        
   
    //rxdat_txrsp
    wire  txrsp_to_rxdat_ready;
    wire rxdat_to_txrsp_wr_en;
    wire [TXNID_RSP-1:0] rxdat_to_txrsp_txnid;
    wire [TGTID_RSP-1:0] rxdat_to_txrsp_tgtid;
    wire [OPCODE_RSP-1:0] rxdat_to_txrsp_opcode;
    wire [RESP_RSP-1:0] rxdat_to_txrsp_resp;
    wire [TXNID_RSP-1:0] rxdat_txsnp_dbid;
    
    //rxsnp_txrsp
    wire  txrsp_to_rxsnp_ready;
    wire rxsnp_to_txrsp_wr_en;
    wire [TXNID_RSP-1:0] rxsnp_to_txrsp_txnid;
    wire [TGTID_RSP-1:0] rxsnp_to_txrsp_tgtid;
    wire [OPCODE_RSP-1:0] rxsnp_to_txrsp_opcode;
    wire [RESP_RSP-1:0] rxsnp_to_txrsp_resp;
    wire [FWD_DATAPULL_RSP-1 : 0] rxsnp_to_txrsp_fwstate;
    
    
    // txdat_rxsnp
    wire  txdat_to_rxsnp_ready;
    wire [DATA_DAT-1 : 0] rxsnp_to_txdat_dat;
    wire rxsnp_to_txdat_wr;
    wire [TGTID_DAT-1:0]  rxsnp_to_txdat_tgtid;
    wire [TXNID_DAT-1:0]  rxsnp_to_txdat_txnid;
    wire [TXNID_DAT-1:0]  rxsnp_to_txdat_dbid;
    wire [RESP_DAT-1 : 0] rxsnp_to_txdat_resp;
    wire [OPCODE_DAT-1 : 0] rxsnp_to_txopcode_dat;
    wire [SRCID_DAT-1:0] rxsnp_to_txdat_homenid;
    
   
    //txdat
    wire  txdat_to_undat_ready,txdat_to_undat_nearly_full;
    wire [DATA_DAT-1 : 0] undat_to_txdat_dat;
    wire undat_to_txdat_wr;
    wire [TGTID_DAT-1:0]  undat_to_txdat_tgtid;
    wire [TXNID_DAT-1:0]  undat_to_txdat_txnid;
    wire [TXNID_DAT-1:0]  undat_to_txdat_dbid;
    wire [RESP_DAT-1 : 0] undat_to_txdat_resp;
    wire [OPCODE_DAT-1 : 0] undat_to_txdat_opcode;
    wire [SRCID_DAT-1:0] undat_to_txdat_homenid;
    
     
     //datlkpt-rxdat
    wire [TXNID_REQ-1 : 0] txreq_to_datlkpt_txnid;
    wire [DATA_DAT+OPCODE_REQ-1  : 0] txreq_to_datlkpt_txndat;
    wire txreq_to_datlkpt_valid;
    
    //datlkpt-rxrsp
    wire [TXNID_REQ-1 : 0] rxrsp_to_datlkpt_txnid;
    wire rxrsp_to_datlkpt_rd_valid;
    wire [DATA_DAT+OPCODE_REQ-1  : 0] datlkpt_to_rxrsp_txndat;
          
          
        
    rnf_tx_req #(
        .VERBOSITY(VERBOSITY),
        //.src_id(src_id),
        .NUM_OF_RNs(NUM_OF_RNs),
        .NUM_OF_HNs(NUM_OF_HNs), // must be power  of 2
        
    	.EAw(EAw),
    	.B(B)
    )
    tx_req
    (
    	.src_id(src_id),
    	.reset(reset),
    	.clk(clk),
    	
    	//chi channel
    	.chi_noc_txreqflitpend(chi_noc_txreqflitpend),
    	.chi_noc_txreqflitv(chi_noc_txreqflitv),
    	.chi_noc_txreqflit(chi_noc_txreqflit),
    	.noc_chi_txreqlcrdv(noc_chi_txreqlcrdv),
    	
    	//control
    	.exclusive(exclusive), 
    	.likelyshared(likelyshared),
    	.ReqOpcode(ReqOpcode),
    	.Request_en(Request_en),
    	.Write_dat(Write_dat),
    	.read_addr(read_addr),    	
    	.send_done(send_done),
    	.can_accept_new_req(can_accept_new_req),
    	
    	
    	// to txn lkpt agent : save the txnid in lookup table
        .txreq_to_lkpt_txnid(txreq_to_lkpt_txnid),
        .txreq_to_lkpt_txndat(txreq_to_lkpt_txndat),
        .txreq_to_lkpt_new_txn(txreq_to_lkpt_new_txn),
        
        //datlkpt
        .txreq_to_datlkpt_txnid(txreq_to_datlkpt_txnid),
        .txreq_to_datlkpt_txndat(txreq_to_datlkpt_txndat),
        .txreq_to_datlkpt_valid(txreq_to_datlkpt_valid),
            
        //from response agent : reuse the txnid 
        .rxrsp_to_txreq_txnid(rxrsp_to_txreq_txnid),
        .rxrsp_to_txreq_txnid_release(rxrsp_to_txreq_txnid_release)   
    );
    
    
     rnf_rxdata_rxrsp #(
        .VERBOSITY(VERBOSITY),
       // .src_id(src_id),
        .B(B)
     )
     rxdata_rxrsp
     (
        .src_id(src_id),
        .reset(reset),
        .clk(clk),        
     
        //rxdat chi channel          
        .noc_chi_rxdatflitpend(noc_chi_rxdatflitpend),
        .noc_chi_rxdatflitv(noc_chi_rxdatflitv),
        .noc_chi_rxdatflit (noc_chi_rxdatflit ),  
        .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv),
        
        //rxrsp chi channel
        .noc_chi_rxrspflitpend(noc_chi_rxrspflitpend), 
        .noc_chi_rxrspflitv(noc_chi_rxrspflitv), 
        .noc_chi_rxrspflit(noc_chi_rxrspflit), 
        .chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv), 
        
     
        //txrsp
        .txrsp_to_rxdat_ready(txrsp_to_rxdat_ready),
        .rxdat_to_txrsp_wr_en(rxdat_to_txrsp_wr_en),
        .rxdat_to_txrsp_txnid(rxdat_to_txrsp_txnid),
        .rxdat_to_txrsp_tgtid(rxdat_to_txrsp_tgtid),
        .rxdat_to_txrsp_opcode(rxdat_to_txrsp_opcode),
        .rxdat_to_txrsp_resp(rxdat_to_txrsp_resp),
        .rxdat_txsnp_dbid(rxdat_txsnp_dbid),         
     
          
        // txn lookup
        .rxdat_to_lkpt_txnid(rxdat_to_lkpt_txnid),
        .rxdat_to_lkpt_rd_valid(rxdat_to_lkpt_rd_valid),
        .lkpt_to_rxdat_txndat(lkpt_to_rxdat_txndat),         
        
        
         //cache_wr
        .rxdat_to_cache_wr_addr(rxdat_to_cache_wr_addr),
        .rxdat_to_cache_wr_data(rxdat_to_cache_wr_data),
        .rxdat_to_cache_wr_state(rxdat_to_cache_wr_state),
        .rxdat_to_cache_wr_action(rxdat_to_cache_wr_action),
        .rxdat_to_cache_wr_en(rxdat_to_cache_wr_en),
        .rxdat_to_cache_wr_evict(rxdat_to_cache_wr_evict),
        .cache_to_rxdat_wr_hit(cache_to_rxdat_wr_hit),
        .cache_to_rxdat_wr_done(cache_to_rxdat_wr_done),
        .cache_to_rxdat_wr_ready(cache_to_rxdat_wr_ready),
        
        //cache_rd
        .rxrsp_to_cache_rd_addr(rxrsp_to_cache_rd_addr),
        .cache_to_rxrsp_rd_data(cache_to_rxrsp_rd_data),
        .rxrsp_to_cache_rd_en(rxrsp_to_cache_rd_en),
        .cache_to_rxrsp_rd_ready(cache_to_rxrsp_rd_ready),
        .cache_to_rxrsp_rd_state(cache_to_rxrsp_rd_state),
        .cache_to_rxrsp_rd_hit(cache_to_rxrsp_rd_hit),
        .cache_to_rxrsp_rd_done(cache_to_rxrsp_rd_done),
        
        
        //rxrsp
        .txdat_to_undat_ready(txdat_to_undat_ready),
        .txdat_to_undat_nearly_full(txdat_to_undat_nearly_full),
        .undat_to_txdat_dat(undat_to_txdat_dat),
        .undat_to_txdat_wr(undat_to_txdat_wr),
        .undat_to_txdat_tgtid(undat_to_txdat_tgtid),
        .undat_to_txdat_txnid(undat_to_txdat_txnid),
        .undat_to_txdat_dbid(undat_to_txdat_dbid),
        .undat_to_txdat_resp(undat_to_txdat_resp),
        .undat_to_txdat_opcode(undat_to_txdat_opcode),
        .undat_to_txdat_homenid(undat_to_txdat_homenid),
        
        .rxrsp_to_datlkpt_txnid(rxrsp_to_datlkpt_txnid), 
        .rxrsp_to_datlkpt_rd_valid(rxrsp_to_datlkpt_rd_valid),
        .datlkpt_to_rxrsp_txndat(datlkpt_to_rxrsp_txndat),
        
       
        //txreq
        .rxrsp_to_txreq_txnid(rxrsp_to_txreq_txnid),
        .rxrsp_to_txreq_txnid_release(rxrsp_to_txreq_txnid_release) 
        
        
     );
       
           
     
     rnf_tx_rsp #(
     	.B(B)
     	//.src_id(src_id)
     )
     tx_rsp
     (
     
        .src_id(src_id),
     	//general
     	.reset(reset),
     	.clk(clk),
     	
     	//chi
     	.chi_noc_txrspflitpend(chi_noc_txrspflitpend),
     	.chi_noc_txrspflitv(chi_noc_txrspflitv),
     	.chi_noc_txrspflit(chi_noc_txrspflit),
     	.noc_chi_txrsplcrdv(noc_chi_txrsplcrdv),
     	
     	//rxdat
     	.txrsp_to_rxdat_ready(txrsp_to_rxdat_ready),
     	.rxdat_to_txrsp_wr_en(rxdat_to_txrsp_wr_en),
     	.rxdat_to_txrsp_txnid(rxdat_to_txrsp_txnid),
     	.rxdat_to_txrsp_tgtid(rxdat_to_txrsp_tgtid),
     	.rxdat_to_txrsp_opcode(rxdat_to_txrsp_opcode),
     	.rxdat_to_txrsp_resp(rxdat_to_txrsp_resp),
     	.rxdat_txsnp_dbid(rxdat_txsnp_dbid),
     	
     	//rxsnp
     	.txrsp_to_rxsnp_ready(txrsp_to_rxsnp_ready),
     	.rxsnp_to_txrsp_wr_en(rxsnp_to_txrsp_wr_en),
     	.rxsnp_to_txrsp_txnid(rxsnp_to_txrsp_txnid),
     	.rxsnp_to_txrsp_tgtid(rxsnp_to_txrsp_tgtid),
     	.rxsnp_to_txrsp_opcode(rxsnp_to_txrsp_opcode),
     	.rxsnp_to_txrsp_resp(rxsnp_to_txrsp_resp),
     	.rxsnp_to_txrsp_fwstate(rxsnp_to_txrsp_fwstate)     	
     	
     );
     
          
     rnf_rx_snp #(
        .VERBOSITY(VERBOSITY),
        //.src_id(src_id),
     	.B(B)
     )
     rx_snp
     (
     	.src_id(src_id),
     	//general
     	.reset(reset),
     	.clk(clk),
     	
     	//chi
     	.noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend),
     	.noc_chi_rxsnpflitv(noc_chi_rxsnpflitv),
     	.noc_chi_rxsnpflit(noc_chi_rxsnpflit),
     	.chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv),
     	
     	//cache_rd
     	.rxsnp_to_cache_rd_addr(rxsnp_to_cache_rd_addr),
     	.cache_to_rxsnp_rd_data(cache_to_rxsnp_rd_data),
     	.rxsnp_to_cache_rd_en(rxsnp_to_cache_rd_en),
     	.cache_to_rxsnp_rd_ready(cache_to_rxsnp_rd_ready),
     	.cache_to_rxsnp_rd_state(cache_to_rxsnp_rd_state),
     	.cache_to_rxsnp_rd_hit(cache_to_rxsnp_rd_hit),
     	.cache_to_rxsnp_rd_done(cache_to_rxsnp_rd_done),
     	
     	//cache_wr
     	.rxsnp_to_cache_wr_addr(rxsnp_to_cache_wr_addr),
        .rxsnp_to_cache_wr_data(rxsnp_to_cache_wr_data),
        .rxsnp_to_cache_wr_state(rxsnp_to_cache_wr_state),
        .rxsnp_to_cache_wr_action(rxsnp_to_cache_wr_action),
        .rxsnp_to_cache_wr_en(rxsnp_to_cache_wr_en),
        .rxsnp_to_cache_wr_evict(rxsnp_to_cache_wr_evict),
        .cache_to_rxsnp_wr_hit(cache_to_rxsnp_wr_hit),
        .cache_to_rxsnp_wr_done(cache_to_rxsnp_wr_done),
        .cache_to_rxsnp_wr_ready(cache_to_rxsnp_wr_ready),
         	
     	
     	//txdat
     	.txdat_to_rxsnp_ready(txdat_to_rxsnp_ready),
     	.rxsnp_to_txdat_dat(rxsnp_to_txdat_dat),
     	.rxsnp_to_txdat_wr(rxsnp_to_txdat_wr),
     	.rxsnp_to_txdat_tgtid(rxsnp_to_txdat_tgtid),
     	.rxsnp_to_txdat_txnid(rxsnp_to_txdat_txnid),
     	.rxsnp_to_txdat_dbid(rxsnp_to_txdat_dbid),
     	.rxsnp_to_txdat_resp(rxsnp_to_txdat_resp),
     	.rxsnp_to_txopcode_dat(rxsnp_to_txopcode_dat),
     	.rxsnp_to_txdat_homenid(rxsnp_to_txdat_homenid),
     	
     	//rxsnp
     	.txrsp_to_rxsnp_ready(txrsp_to_rxsnp_ready),
     	.rxsnp_to_txrsp_wr_en(rxsnp_to_txrsp_wr_en),
     	.rxsnp_to_txrsp_txnid(rxsnp_to_txrsp_txnid),
     	.rxsnp_to_txrsp_tgtid(rxsnp_to_txrsp_tgtid),
     	.rxsnp_to_txrsp_opcode(rxsnp_to_txrsp_opcode),
     	.rxsnp_to_txrsp_resp(rxsnp_to_txrsp_resp),
     	.rxsnp_to_txrsp_fwstate(rxsnp_to_txrsp_fwstate)
     );
     
     rnf_tx_dat #(
        .VERBOSITY(VERBOSITY),
     	.B(B)
     //	.src_id(src_id)
     )
     tx_dat
     (
        .src_id(src_id),
     	.chi_noc_txdatflitpend(chi_noc_txdatflitpend),
     	.chi_noc_txdatflitv(chi_noc_txdatflitv),
     	.chi_noc_txdatflit(chi_noc_txdatflit),
     	.noc_chi_txdatlcrdv(noc_chi_txdatlcrdv),
     	
     	 //rxsnp
     	.txdat_to_rxsnp_ready(txdat_to_rxsnp_ready),
     	.rxsnp_to_txdat_dat(rxsnp_to_txdat_dat),
     	.rxsnp_to_txdat_wr(rxsnp_to_txdat_wr),
     	.rxsnp_to_txdat_tgtid(rxsnp_to_txdat_tgtid),
     	.rxsnp_to_txdat_txnid(rxsnp_to_txdat_txnid),
     	.rxsnp_to_txdat_dbid(rxsnp_to_txdat_dbid),
     	.rxsnp_to_txdat_resp(rxsnp_to_txdat_resp),
     	.rxsnp_to_txopcode_dat(rxsnp_to_txopcode_dat),
     	.rxsnp_to_txdat_homenid(rxsnp_to_txdat_homenid),
     	
     	 //rxrsp
     	.txdat_to_undat_nearly_full(txdat_to_undat_nearly_full),
        .txdat_to_undat_ready(txdat_to_undat_ready),
        .undat_to_txdat_dat(undat_to_txdat_dat),
        .undat_to_txdat_wr(undat_to_txdat_wr),
        .undat_to_txdat_tgtid(undat_to_txdat_tgtid),
        .undat_to_txdat_txnid(undat_to_txdat_txnid),
        .undat_to_txdat_dbid(undat_to_txdat_dbid),
        .undat_to_txdat_resp(undat_to_txdat_resp),
        .undat_to_txdat_opcode(undat_to_txdat_opcode),
        .undat_to_txdat_homenid(undat_to_txdat_homenid),
     	
     	
     	.reset(reset),
     	.clk(clk)
     );
     
     
     
    rnf_cache #(
        .VERBOSITY(VERBOSITY),
       // .src_id(src_id),
    	.CACHE_WAY_NUM(CACHE_WAY_NUM),
        .CACHE_STATUSw(CACHE_STATUSw),
        .CACHE_BLK_SIZ(CACHE_BLK_SIZ),
        .CACHE_DATAw(DATA_DAT),
        .CACHE_INDEXw(CACHE_INDEXw),
        .CACHE_ADDRw(CACHE_ADDRw)        
    )
    cache
    (
    	
    	.src_id(src_id),
    	//core_wr
    	.core_to_cache_wr_addr(core_to_cache_wr_addr),
        .core_to_cache_wr_data(core_to_cache_wr_data),
        .core_to_cache_wr_state(core_to_cache_wr_state),
        .core_to_cache_wr_action(core_to_cache_wr_action),
        .core_to_cache_wr_en(core_to_cache_wr_en),
        .core_to_cache_wr_evict(core_to_cache_wr_evict),        
        .cache_to_core_wr_hit(cache_to_core_wr_hit),
        .cache_to_core_wr_done(cache_to_core_wr_done),
        .cache_to_core_wr_ready(cache_to_core_wr_ready),
    	
    	//rxdat_wr
    	.rxdat_to_cache_wr_addr(rxdat_to_cache_wr_addr),
    	.rxdat_to_cache_wr_data(rxdat_to_cache_wr_data),
    	.rxdat_to_cache_wr_state(rxdat_to_cache_wr_state),
    	.rxdat_to_cache_wr_action(rxdat_to_cache_wr_action),
    	.rxdat_to_cache_wr_en(rxdat_to_cache_wr_en),
    	.rxdat_to_cache_wr_evict(rxdat_to_cache_wr_evict),    	
    	.cache_to_rxdat_wr_hit(cache_to_rxdat_wr_hit),
    	.cache_to_rxdat_wr_done(cache_to_rxdat_wr_done),
    	.cache_to_rxdat_wr_ready(cache_to_rxdat_wr_ready),
    	//rxsnp_wr
    	.rxsnp_to_cache_wr_addr(rxsnp_to_cache_wr_addr),
    	.rxsnp_to_cache_wr_data(rxsnp_to_cache_wr_data),
    	.rxsnp_to_cache_wr_state(rxsnp_to_cache_wr_state),
    	.rxsnp_to_cache_wr_action(rxsnp_to_cache_wr_action),
    	.rxsnp_to_cache_wr_en(rxsnp_to_cache_wr_en),
    	.rxsnp_to_cache_wr_evict(rxsnp_to_cache_wr_evict),
    	.cache_to_rxsnp_wr_hit(cache_to_rxsnp_wr_hit),
    	.cache_to_rxsnp_wr_done(cache_to_rxsnp_wr_done),
    	.cache_to_rxsnp_wr_ready(cache_to_rxsnp_wr_ready),
    	//rxsnp_rd
    	.rxsnp_to_cache_rd_addr(rxsnp_to_cache_rd_addr),
    	.cache_to_rxsnp_rd_data(cache_to_rxsnp_rd_data),
    	.rxsnp_to_cache_rd_en(rxsnp_to_cache_rd_en),
    	.cache_to_rxsnp_rd_ready(cache_to_rxsnp_rd_ready),
    	.cache_to_rxsnp_rd_state(cache_to_rxsnp_rd_state),
    	.cache_to_rxsnp_rd_hit(cache_to_rxsnp_rd_hit),
    	.cache_to_rxsnp_rd_done(cache_to_rxsnp_rd_done),    	
    	//rxrsp_rd
    	.rxrsp_to_cache_rd_addr(rxrsp_to_cache_rd_addr),
        .cache_to_rxrsp_rd_data(cache_to_rxrsp_rd_data),
        .rxrsp_to_cache_rd_en(rxrsp_to_cache_rd_en),
        .cache_to_rxrsp_rd_ready(cache_to_rxrsp_rd_ready),
        .cache_to_rxrsp_rd_state(cache_to_rxrsp_rd_state),
        .cache_to_rxrsp_rd_hit(cache_to_rxrsp_rd_hit),
        .cache_to_rxrsp_rd_done(cache_to_rxrsp_rd_done),
       
    	
    	
    	.reset(reset),
    	.clk(clk)
    );
            
      
      
    transaction_lookup_table #(
        .TXN_DATAw(RNF_TXN_DATAw),
        .TXN_IDw(TXNID_REQ)
    )
    active_transaction_lookup
    (
        .txn_wr_addr(txreq_to_lkpt_txnid),
        .txn_wr_dat(txreq_to_lkpt_txndat),
        .txn_wr_en(txreq_to_lkpt_new_txn),
        
        .txn_rd_addr(rxdat_to_lkpt_txnid),
        .txn_rd_dat(lkpt_to_rxdat_txndat),
        .txn_rd_en(rxdat_to_lkpt_rd_valid),
        .clk(clk)
    );
    
    
    transaction_lookup_table #(
        .TXN_DATAw(DATA_DAT+OPCODE_REQ),
        .TXN_IDw(TXNID_REQ)
    )
    lkpt_dat
    (
        .txn_wr_addr(txreq_to_datlkpt_txnid),
        .txn_wr_dat(txreq_to_datlkpt_txndat),
        .txn_wr_en(txreq_to_datlkpt_valid),
        
        .txn_rd_addr(rxrsp_to_datlkpt_txnid),
        .txn_rd_dat(datlkpt_to_rxrsp_txndat),
        .txn_rd_en(rxrsp_to_datlkpt_rd_valid),
        
        .clk(clk)
    ); 
    
    
    
      
      
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_FLIT_INJECT) > 0) begin 
            if(noc_chi_rxrspflitv) $display("%t: rnf ( %d ) rsp channel has recived a packet:%h",$time,src_id,noc_chi_rxrspflit);
            if(noc_chi_rxdatflitv) $display("%t: rnf ( %d ) dat channel has recived a packet:%h",$time,src_id,noc_chi_rxdatflit);
            if(noc_chi_rxreqflitv)begin 
                $display("%t:Error rnf ( %d ) req channel has recived a packet:%h. RXREQ is not activated in request node",$time,src_id,noc_chi_rxreqflit);
                $stop;
            end
            if(noc_chi_rxsnpflitv) $display("%t: rnf ( %d ) snp channel has recived a packet:%h",$time,src_id,noc_chi_rxsnpflit);
        end            
    end
    //synthesis translate_on 
    //synopsys  translate_on
      
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_FLIT_INJECT) > 0) begin 
            if(chi_noc_txrspflitv) $display("%t: rnf ( %d ) rsp channel has sent a packet:%h",$time,src_id,chi_noc_txrspflit);
            if(chi_noc_txdatflitv) $display("%t: rnf ( %d ) dat channel has sent a packet:%h",$time,src_id,chi_noc_txdatflit);
            if(chi_noc_txreqflitv) $display("%t: rnf ( %d ) req channel has sent a packet:%h",$time,src_id,chi_noc_txreqflit);
            if(chi_noc_txsnpflitv) $display("%t: rnf ( %d ) snp channel has sent a packet:%h",$time,src_id,chi_noc_txsnpflit);        
        end
    end
    //synthesis translate_on 
    //synopsys  translate_on  
     
    
endmodule  
