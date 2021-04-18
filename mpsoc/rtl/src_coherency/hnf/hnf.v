/**************************************
* Module: home_full_node
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  hnf #(
    parameter VERBOSITY=4, // The higher the VERBOSITY the higher details are printed in simuation terminal
  //  parameter snf_id = 3, // For each home node only one SNF is assigned. (acording to mb2020 specefication) so no need for sam. 
    parameter SYS_CACHE_EN=1,
    parameter EAw=5,
    parameter B=4,
    //parameter src_id=0,
    parameter NUM_OF_RNs=32,
    parameter NUM_OF_HNs=32,
    //snoop filter param 
    parameter SNPF_WAY_NUM =8,
    parameter SNPF_ADDRw =44,
    parameter SNPF_INDEXw=12,
    
    //system cache pram
    parameter CACHE_WAY_NUM =8,
    parameter CACHE_ADDRw =44,    
    parameter CACHE_INDEXw=12    
    )(
    
    
    src_id,
    snf_id,
    
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
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop chanel so need target ID
    chi_noc_txsnpflitpend,
    chi_noc_txsnpflitv,
    chi_noc_txsnpflit,
    noc_chi_txsnplcrdv,
    snp_target_id,  
    
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
    chi_noc_rxsnplcrdv
   
    );
     
    localparam  SNPF_SPVw = NUM_OF_RNs+1;  // one bit for syscache
    localparam  EXPCT_RSP_Dw = NUM_OF_RNs+2; //   one bit for SN, one bit for checking if data is received
                 
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"                     
       
    input [31 : 0] src_id;
    input [31 : 0] snf_id;
    
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
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop chanel so need target ID
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
   
   
   
   //snoop-filter read chanel
    wire [ADDR_REQ-1 : 0] rxreq_to_snpf_rd_addr;
    wire rxreq_to_snpf_rd_en;
    wire [SNPF_SPVw-1 : 0] snpf_to_rxreq_spv;
    wire [CACHE_STATUSw-1 : 0] snpf_to_rxreq_rd_state;
    wire snpf_to_rxreq_rd_ready;    
    wire snpf_to_rxreq_rd_hit;
    wire snpf_to_rxreq_rd_done;
    
    // snoop-filter write chanel
    wire [SNPF_ADDRw-1 : 0] rxreq_to_snpf_wr_addr;
    wire rxreq_to_snpf_wr_en;
    wire rxreq_to_snpf_wr_evict;
    wire [SNPF_SPVw-1 : 0] rxreq_to_snpf_wr_spv;
  //  wire [CACHE_STATUSw-1 : 0] rxreq_to_snpf_wr_state;
    wire rxreq_to_snpf_update_state;
    wire [SNPF_ACTw-1: 0] rxreq_to_snpf_action;
  
    
    wire snpf_to_rxreq_wr_hit;
    wire snpf_to_rxreq_wr_chnl_ready;
    wire snpf_to_rxreq_wr_is_failed;
    wire snpf_to_rxreq_wr_done;
    wire snpf_to_rxreq_rd_busy_bit;
    wire snpf_to_rxreq_rd_cnt_acpt_new;
    
   
    //rxrsp
    wire [SNPF_ADDRw-1 : 0] rxrsp_to_snpf_wr_addr;
    wire rxrsp_to_snpf_wr_en;
    wire rxrsp_to_snpf_wr_evict;
    wire [SNPF_SPVw-1 : 0] rxrsp_to_snpf_wr_spv;
 //   wire [CACHE_STATUSw-1 : 0] rxrsp_to_snpf_wr_state;
    wire rxrsp_to_snpf_update_state;
    wire [SNPF_ACTw-1: 0]rxrsp_to_snpf_action;
   
    
    wire snpf_to_rxrsp_wr_hit;
    wire snpf_to_rxrsp_wr_chnl_ready;
    wire snpf_to_rxrsp_wr_is_failed;
    wire snpf_to_rxrsp_wr_done;   
       
    
    //cache read-chanel
    wire [ADDR_REQ-1 : 0] rxreq_to_cache_rd_addr;
    wire  [DATA_DAT-1 : 0] cache_to_rxreq_rd_data;
    wire rxreq_to_cache_rd_en;
    wire cache_to_rxreq_rd_ready;   
    wire [CACHE_STATUSw-1 : 0] cache_to_rxreq_rd_state;
    wire cache_to_rxreq_rd_hit;
    wire cache_to_rexreq_rd_done;  
    
    //rxrsp_cache_wr
    wire [ADDR_REQ-1 :0  ] undat_to_cache_wr_addr;
    wire [DATA_DAT-1 : 0] undat_to_cache_wr_data;
    wire [CACHE_STATUSw-1:0] undat_to_cache_wr_state;
    wire undat_to_cache_wr_en;
    wire  undat_to_cache_wr_evict;
    wire cache_to_undat_wr_hit;
    wire cache_to_undat_wr_done;
    wire cache_to_undat_wr_ready;    
    
    
   
   
    //rxrsp_txngen
    wire [TXNID_REQ-1:0]   rxrsp_to_txgen_txnid;
    wire rxrsp_to_txgen_txnid_release;
    wire txgen_to_rxrsp_ready;
    
    
    //undat_txngen // by default it should be the cache who releaese the txn
    wire [TXNID_REQ-1:0]   undat_to_txgen_txnid;
    wire undat_to_txgen_txnid_release;
    wire txgen_to_undat_ready;
    
    
    //txreq
    wire txreq_to_rxreq_ready;
    wire rxreq_to_txreq_wr;
    wire [OPCODE_REQ-1 : 0] rxreq_to_txreq_opcode;
    wire [TGTID_REQ-1  : 0] rxreq_to_txreq_tgtid;
    wire [TXNID_REQ-1  : 0] rxreq_to_txreq_txnid;
    wire [RETURNNID_REQ-1 : 0] rxreq_to_txreq_returnnid;
    wire [RETURNTXNID_REQ-1:0] rxreq_to_txreq_returntxnid;
    wire [ADDR_REQ-1: 0] rxreq_to_txreq_addr;
    wire rxreq_to_txreq_likelyshared;           
    
         
    //rxrsp lkpt    
    wire [TXNID_REQ-1 : 0] txreq_to_rxrsplkpt_txnid;
    wire [HNF_RXRSP_TXN_DATAw-1 : 0] txreq_to_rxrsplkpt_txndat;
    wire txreq_to_rxrsplkpt_valid;
    wire [TXNID_REQ-1 : 0] rxrsp_to_lkpt_txnid;
    wire rxrsp_to_lkpt_rd_valid;
    wire [HNF_RXRSP_TXN_DATAw-1 : 0]lkpt_to_rxrsp_txndat;
     
    //undat_rxdat
    wire undat_to_rxdat_nearly_full;
    wire undat_to_rxdat_ready;
    wire [DATA_DAT-1 : 0] rxdat_to_undat_dat;
    wire [DU_ACTw-1 : 0] rxdat_to_undat_action;
    wire rxdat_to_undat_wr;
    wire [TGTID_REQ-1:0]           rxdat_to_undat_tgtid;
    wire [TXNID_REQ-1:0]           rxdat_to_undat_txnid;
    wire [TXNID_REQ-1:0]  rxdat_to_undat_dbid;
    wire [RESP_DAT-1 : 0] rxdat_to_undat_resp;
    wire [RESPERR_DAT-1 : 0] rxdat_to_undat_resperr;
    wire [OPCODE_DAT-1 : 0] rxdat_to_undat_opcode;
    wire rxdat_to_undat_txnid_release; 
    wire rxdat_to_undat_snpf_update;
    wire [ADDR_REQ-1 : 0] rxreq_to_undat_addr;
    wire rxreq_to_undat_cache_evict;
    
   
     // rxreq_to_txsnp
    wire [SNPF_SPVw-1  : 0] rxreq_to_txsnp_spv;
    wire rxreq_to_txsnp_we;
    wire txsnp_to_rxreq_ready;
    wire [TXNID_SNP-1   :0] rxreq_to_txsnp_txnid;
    wire [FWDNID_SNP-1  :0] rxreq_to_txsnp_fwdnid;
    wire [FWDTXNID_SNP-1:0] rxreq_to_txsnp_fwdtxnid;
    wire [OPCODE_SNP-1  :0] rxreq_to_txsnp_opcode;
    wire [ADDR_SNP-1    :0] rxreq_to_txsnp_addr;
    wire rxreq_to_txsnp_rettosrc;   
           
   //rxdat_rxrsp
   /*
    wire [TXNID_REQ-1:0] rxdat_rxrsp_txnid;
    wire rxrsp_rxdat_ready;
    wire [OPCODE_DAT-1:0] rxdat_rxrsp_opcode; 
    wire [RESP_DAT-1 : 0] rxdat_rxrsp_resp;
    wire rxdat_rxrsp_valid;  
    */  
    
    //datlkpt-rxdat
    /*
    wire [TXNID_REQ-1 : 0] rxdat_to_datlkpt_txnid;
    wire rxrsp_to_datlkpt_rd_valid;
    wire [DATA_DAT-1  : 0] rxdat_to_datlkpt_txndat;
    wire rxdat_to_datlkpt_valid;
    
    //datlkpt-rxrsp
    wire [TXNID_REQ-1 : 0] rxrsp_to_datlkpt_txnid;
    wire [DATA_DAT-1  : 0] datlkpt_to_rxrsp_txndat;
    */
    
    //tcrsp_rxrsp
    wire  txrsp_to_rxrsp_ready;
    wire txrsp_to_rxrsp_nearly_full;
    wire rxrsp_to_txrsp_wr_en;
    wire [TXNID_RSP-1:0] rxrsp_to_txrsp_txnid;
    wire [TGTID_RSP-1:0] rxrsp_to_txrsp_tgtid;
    wire [OPCODE_RSP-1:0] rxrsp_to_txrsp_opcode;
    wire [RESP_RSP-1:0] rxrsp_to_txrsp_resp;
    wire [RESPERR_RSP-1:0] rxrsp_to_txrsp_resperr;
    wire [TXNID_RSP-1:0] rxrsp_txsnp_dbid;
    
      
    //rxrsp snoop wait
    // add the list of all RNs we expect to recive snoop comp/compdata from. 
    /*
    wire [TXNID_REQ-1 : 0] txreq_to_rxrsp_txnid;
    wire [SNPF_SPVw-2: 0] txreq_to_rxrsp_spv;
    wire txreq_to_rxrsp_valid;
    wire rxrsp_to_txreq_ready;   
    */
    
    //rxreq__txrsp
    wire  txrsp_to_rxreq_ready;
    wire rxreq_to_txrsp_wr_en;
    wire [TXNID_RSP-1:0] rxreq_to_txrsp_txnid;
    wire [TGTID_RSP-1:0] rxreq_to_txrsp_tgtid;
    wire [OPCODE_RSP-1:0] rxreq_to_txrsp_opcode;
    wire [RESP_RSP-1:0] rxreq_to_txrsp_resp;
    wire [RESPERR_RSP-1:0] rxreq_to_txrsp_resperr;
    wire [TXNID_RSP-1:0] rxreq_txsnp_dbid;
    
    
     //txreq wr
    wire [TXNID_REQ-1 : 0] rxreq_to_expct_rsp_txnid_wr;
    wire [EXPCT_RSP_Dw-1 : 0] rxreq_to_expct_rsp_dat_wr;
    wire rxreq_to_expct_rsp_valid_wr;
    wire expct_rsp_to_rxreq_ready_wr;
    
    //rxrsp wr
    wire [TXNID_REQ-1 : 0] rxrsp_to_expct_rsp_txnid_wr;
    wire [EXPCT_RSP_Dw-1 : 0] rxrsp_to_expct_rsp_dat_wr;
    wire rxrsp_to_expct_rsp_valid_wr;
    wire expct_rsp_to_rxrsp_ready_wr;
    
    
    //rxrsp rd
    wire  [TXNID_REQ-1 : 0] rxrsp_to_expct_rsp_txnid_rd;
    wire  [EXPCT_RSP_Dw-1 : 0] expct_rsp_to_rxrsp_dat_rd;
    wire  rxrsp_to_expct_rsp_valid_rd;
    wire  expct_rsp_to_rxrsp_ready_rd;   
       
    
    
    wire [SNPF_ADDRw-1 : 0]  evbuf_to_rxreq_addr;
    wire [SNPF_SPVw-1 : 0] evbuf_to_rxreq_dat;
    wire evbuf_to_rxreq_valid;
    wire rxreq_evbuf_rd_en;       
        
       
    //undat_rxreq
    wire rxreq_to_undat_wr; 
    wire  [DATA_DAT-1  : 0] rxreq_to_undat_dat;
    wire  [TXNID_REQ-1 : 0] rxreq_to_undat_txnid;  
    wire  [DU_ACTw-1 : 0] rxreq_to_undat_action;
    wire   undat_to_rxreq_ready;  
    wire [TGTID_DAT-1:0]rxreq_to_undat_tgtid;
    wire [TXNID_DAT-1:0]rxreq_to_undat_dbid;
    wire [OPCODE_DAT-1 : 0]rxreq_to_undat_opcode;
    wire [RESP_DAT-1 : 0] rxreq_to_undat_resp;
    wire [RESPERR_DAT-1 : 0] rxreq_to_undat_resperr;
    
    //txdat_undat   
    wire txdat_to_undat_nearly_full;
    wire  txdat_to_undat_ready;
    wire [DATA_DAT-1 : 0] undat_to_txdat_dat;
    wire undat_to_txdat_wr;
    wire [TGTID_REQ-1:0]           undat_to_txdat_tgtid;
    wire [TXNID_REQ-1:0]           undat_to_txdat_txnid;
    wire [TXNID_REQ-1:0]  undat_to_txdat_dbid;
    wire [RESP_DAT-1 : 0] undat_to_txdat_resp;
    wire [RESPERR_DAT-1 : 0] undat_to_txdat_resperr;
    wire [OPCODE_DAT-1 : 0] undat_to_txdat_opcode;  
    wire [ADDR_REQ-1 :0  ] rxdat_to_undat_addr;
    wire rxdat_to_undat_cache_wr;
    
    
    //rxdat_rxreq   
    wire  txreq_to_rxdat_ready;
    wire rxdat_to_txreq_wr;
    wire [OPCODE_REQ-1 : 0] rxdat_to_txreq_opcode;
    wire [TGTID_REQ-1  : 0] rxdat_to_txreq_tgtid;
    wire [TXNID_REQ-1  : 0] rxdat_to_txreq_txnid;
    wire [RETURNNID_REQ-1 : 0] rxdat_to_txreq_returnnid;
    wire [RETURNTXNID_REQ-1:0] rxdat_to_txreq_returntxnid;
    wire [ADDR_REQ-1: 0] rxdat_to_txreq_addr;
    wire rxdat_to_txreq_likelyshared;
    
    
    //snpf_undat
    wire [ADDR_REQ-1 : 0] undat_to_snpf_wr_addr;
    wire undat_to_snpf_wr_en;
    wire undat_to_snpf_wr_evict;
    wire [SNPF_SPVw-1 : 0] undat_to_snpf_wr_spv;
 //   wire [CACHE_STATUSw-1 : 0] undat_to_snpf_wr_state;
    wire undat_to_snpf_update_state;
    wire [SNPF_ACTw-1:0] undat_to_snpf_action;
  
    
    wire snpf_to_undat_wr_hit;
    wire snpf_to_undat_wr_chnl_ready;
    wire snpf_to_undat_wr_is_failed;
    wire snpf_to_undat_wr_done;   
    
    
             
   hnf_rx_req #(
    .VERBOSITY(VERBOSITY),
   	.B(B),
   	.SNPF_SPVw(SNPF_SPVw),
   	.SNPF_ADDRw(SNPF_ADDRw),
   // .src_id(src_id),
   	.EXPCT_RSP_Dw(EXPCT_RSP_Dw),
   	.NUM_OF_RNs(NUM_OF_RNs),
   	.NUM_OF_HNs(NUM_OF_HNs)
   )
   rx_req
   (
    .snf_id(snf_id),
    .src_id(src_id),
   	.reset(reset),
   	.clk(clk),
   	//chi
   	.noc_chi_rxreqflitpend(noc_chi_rxreqflitpend),
   	.noc_chi_rxreqflitv(noc_chi_rxreqflitv),
   	.noc_chi_rxreqflit(noc_chi_rxreqflit),
   	.chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv),
   	
   	//snfp rd chanel
   	.rxreq_to_snpf_rd_addr(rxreq_to_snpf_rd_addr),
   	.rxreq_to_snpf_rd_en(rxreq_to_snpf_rd_en),
   	.snpf_to_rxreq_rd_spv(snpf_to_rxreq_spv),
   	.snpf_to_rxreq_rd_state(snpf_to_rxreq_rd_state),
   	.snpf_to_rxreq_rd_ready(snpf_to_rxreq_rd_ready),
   	.snpf_to_rxreq_rd_hit(snpf_to_rxreq_rd_hit),
   	.snpf_to_rxreq_rd_done(snpf_to_rxreq_rd_done),
   	.snpf_to_rxreq_rd_busy_bit(snpf_to_rxreq_rd_busy_bit),
   	.snpf_to_rxreq_rd_cnt_acpt_new(snpf_to_rxreq_rd_cnt_acpt_new),
   	
   	//snpf wr chanel
   	.rxreq_to_snpf_wr_addr(rxreq_to_snpf_wr_addr),
    .rxreq_to_snpf_wr_en(rxreq_to_snpf_wr_en),
    .rxreq_to_snpf_wr_evict(rxreq_to_snpf_wr_evict),
    .rxreq_to_snpf_wr_spv(rxreq_to_snpf_wr_spv),
   // .rxreq_to_snpf_wr_state(rxreq_to_snpf_wr_state),
    .rxreq_to_snpf_update_state(rxreq_to_snpf_update_state),
    .rxreq_to_snpf_action(rxreq_to_snpf_action),
    .snpf_to_rxreq_wr_hit(snpf_to_rxreq_wr_hit),
    .snpf_to_rxreq_wr_chnl_ready(snpf_to_rxreq_wr_chnl_ready),
    .snpf_to_rxreq_wr_is_failed(snpf_to_rxreq_wr_is_failed),
    .snpf_to_rxreq_wr_done(snpf_to_rxreq_wr_done),
   	
   	//cache
   	.rxreq_to_cache_rd_addr(rxreq_to_cache_rd_addr),
   	.cache_to_rxreq_rd_data(cache_to_rxreq_rd_data),
   	.rxreq_to_cache_rd_en(rxreq_to_cache_rd_en),
   	.cache_to_rxreq_rd_ready(cache_to_rxreq_rd_ready),
   	.cache_to_rxreq_rd_state(cache_to_rxreq_rd_state),
   	.cache_to_rxreq_rd_hit(cache_to_rxreq_rd_hit),
   	.cache_to_rexreq_rd_done(cache_to_rexreq_rd_done),
   	
   
   	
   	 //txrsp
    .txrsp_to_rxreq_ready(txrsp_to_rxreq_ready),
    .rxreq_to_txrsp_wr_en(rxreq_to_txrsp_wr_en),
    .rxreq_to_txrsp_txnid(rxreq_to_txrsp_txnid),
    .rxreq_to_txrsp_tgtid(rxreq_to_txrsp_tgtid),
    .rxreq_to_txrsp_opcode(rxreq_to_txrsp_opcode),
    .rxreq_to_txrsp_resp(rxreq_to_txrsp_resp),
    .rxreq_to_txrsp_resperr(rxreq_to_txrsp_resperr),
    .rxreq_txsnp_dbid(rxreq_txsnp_dbid),
   	
   	
   	//rxrsp_txngen
   	.rxrsp_to_txgen_txnid(rxrsp_to_txgen_txnid),
   	.rxrsp_to_txgen_txnid_release(rxrsp_to_txgen_txnid_release),
   	.txgen_to_rxrsp_ready(txgen_to_rxrsp_ready),
   	
   	//undat_txngen
    .undat_to_txgen_txnid(undat_to_txgen_txnid),         
    .undat_to_txgen_txnid_release(undat_to_txgen_txnid_release), 
    .txgen_to_undat_ready(txgen_to_undat_ready),         
   	
     	
   	//txreq
   	.txreq_to_rxreq_ready(txreq_to_rxreq_ready),
    .rxreq_to_txreq_wr(rxreq_to_txreq_wr),
    .rxreq_to_txreq_opcode(rxreq_to_txreq_opcode),
    .rxreq_to_txreq_tgtid(rxreq_to_txreq_tgtid),
    .rxreq_to_txreq_txnid(rxreq_to_txreq_txnid),
    .rxreq_to_txreq_returnnid(rxreq_to_txreq_returnnid),
    .rxreq_to_txreq_returntxnid(rxreq_to_txreq_returntxnid),
    .rxreq_to_txreq_addr(rxreq_to_txreq_addr),
    .rxreq_to_txreq_likelyshared(rxreq_to_txreq_likelyshared),     
    
    //txsnp
    .rxreq_to_txsnp_spv(rxreq_to_txsnp_spv),
    .rxreq_to_txsnp_we(rxreq_to_txsnp_we),
    .txsnp_to_rxreq_ready(txsnp_to_rxreq_ready),
    .rxreq_to_txsnp_txnid(rxreq_to_txsnp_txnid),
    .rxreq_to_txsnp_fwdnid(rxreq_to_txsnp_fwdnid),
    .rxreq_to_txsnp_fwdtxnid(rxreq_to_txsnp_fwdtxnid),
    .rxreq_to_txsnp_opcode(rxreq_to_txsnp_opcode),
    .rxreq_to_txsnp_addr(rxreq_to_txsnp_addr),
    .rxreq_to_txsnp_rettosrc(rxreq_to_txsnp_rettosrc),   
      	
    //lkpt
    .txreq_to_rxrsplkpt_txnid(txreq_to_rxrsplkpt_txnid),
    .txreq_to_rxrsplkpt_txndat(txreq_to_rxrsplkpt_txndat),
    .txreq_to_rxrsplkpt_valid(txreq_to_rxrsplkpt_valid),
    
    //expct_rsp
    .rxreq_to_expct_rsp_txnid_wr(rxreq_to_expct_rsp_txnid_wr),
    .rxreq_to_expct_rsp_dat_wr(rxreq_to_expct_rsp_dat_wr),
    .rxreq_to_expct_rsp_valid_wr(rxreq_to_expct_rsp_valid_wr),
    .expct_rsp_to_rxreq_ready_wr(expct_rsp_to_rxreq_ready_wr),
    
    //evbuf
    .evbuf_to_rxreq_addr(evbuf_to_rxreq_addr),
    .evbuf_to_rxreq_dat(evbuf_to_rxreq_dat),
    .evbuf_to_rxreq_valid(evbuf_to_rxreq_valid),
    .rxreq_evbuf_rd_en(rxreq_evbuf_rd_en),
    
    //undat
    .rxreq_to_undat_wr(rxreq_to_undat_wr), 
    .rxreq_to_undat_dat(rxreq_to_undat_dat),
    .rxreq_to_undat_txnid(rxreq_to_undat_txnid),  
    .rxreq_to_undat_action(rxreq_to_undat_action),
    .rxreq_to_undat_addr(rxreq_to_undat_addr),
    .rxreq_to_undat_cache_evict(rxreq_to_undat_cache_evict),
    .rxreq_to_undat_tgtid(rxreq_to_undat_tgtid ),
    .rxreq_to_undat_dbid(rxreq_to_undat_dbid  ),
    .rxreq_to_undat_opcode(rxreq_to_undat_opcode),
    .rxreq_to_undat_resp(rxreq_to_undat_resp  ),
    .rxreq_to_undat_resperr(rxreq_to_undat_resperr),
    
    
    .undat_to_rxreq_ready(undat_to_rxreq_ready)  
   	
   	
   );
   
  
   
   
   hnf_tx_dat #(
    .VERBOSITY(VERBOSITY),
     //.src_id(src_id),
   	.B(B)   
   )
   tx_dat
   (
    .src_id(src_id),
    //chi
   	.chi_noc_txdatflitpend(chi_noc_txdatflitpend),
   	.chi_noc_txdatflitv(chi_noc_txdatflitv),
   	.chi_noc_txdatflit(chi_noc_txdatflit),
   	.noc_chi_txdatlcrdv(noc_chi_txdatlcrdv),
   	
      
   	//undat
   	.txdat_to_undat_nearly_full(txdat_to_undat_nearly_full),
    .txdat_to_undat_ready(txdat_to_undat_ready),
    .undat_to_txdat_dat(undat_to_txdat_dat),
    .undat_to_txdat_wr(undat_to_txdat_wr),
    .undat_to_txdat_tgtid(undat_to_txdat_tgtid),
    .undat_to_txdat_txnid(undat_to_txdat_txnid),
    .undat_to_txdat_dbid(undat_to_txdat_dbid),
    .undat_to_txdat_resp(undat_to_txdat_resp),
    .undat_to_txdat_resperr(undat_to_txdat_resperr),
    .undat_to_txdat_opcode(undat_to_txdat_opcode),
    
   	//general
   	.reset(reset),
   	.clk(clk)
   );
   
            
  
   
   /*
   
   hnf_rx_data #(
   	 // .src_id(src_id),
      .B(B)
   )
   rx_data
   (
    .src_id(src_id),
   	.reset(reset),
   	.clk(clk),
   	.noc_chi_rxdatflitpend(noc_chi_rxdatflitpend),
   	.noc_chi_rxdatflitv(noc_chi_rxdatflitv),
   	.noc_chi_rxdatflit(noc_chi_rxdatflit),
   	.chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv),
   	.rxdat_rxrsp_txnid(rxdat_rxrsp_txnid),
   	.rxdat_rxrsp_opcode(rxdat_rxrsp_opcode),
   	.rxdat_rxrsp_resp(rxdat_rxrsp_resp),
   	.rxdat_rxrsp_srcid(rxdat_rxrsp_srcid),
   	
   	.rxdat_rxrsp_valid(rxdat_rxrsp_valid),
   	.rxrsp_rxdat_ready(rxrsp_rxdat_ready),
   	
   	.rxdat_to_datlkpt_txnid(rxdat_to_datlkpt_txnid),
   	.rxdat_to_datlkpt_txndat(rxdat_to_datlkpt_txndat),
   	.rxdat_to_datlkpt_valid(rxdat_to_datlkpt_valid)
   );
   */
              
    hnf_rxrsp_rxdat #(
        .VERBOSITY(VERBOSITY),
      //  .snf_id(snf_id),
    	.B(B),
        .SNPF_SPVw(SNPF_SPVw),
      // .src_id(src_id),
        .EXPCT_RSP_Dw(EXPCT_RSP_Dw)
    )
    rx_rsp
    (
        .snf_id(snf_id),
    	.src_id(src_id),
    	//chi rxrsp
    	.noc_chi_rxrspflitpend(noc_chi_rxrspflitpend),
    	.noc_chi_rxrspflitv(noc_chi_rxrspflitv),
    	.noc_chi_rxrspflit(noc_chi_rxrspflit),
    	.chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv),
    	
    	//chi rxdat
    	.noc_chi_rxdatflitpend(noc_chi_rxdatflitpend),
        .noc_chi_rxdatflitv(noc_chi_rxdatflitv),
        .noc_chi_rxdatflit(noc_chi_rxdatflit),
        .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv),
    	 
    	 //rxreq
    	.rxrsp_to_txgen_txnid(rxrsp_to_txgen_txnid),
    	.rxrsp_to_txgen_txnid_release(rxrsp_to_txgen_txnid_release),
    	.txgen_to_rxrsp_ready(txgen_to_rxrsp_ready),
    	    	
    	//snpf
    	.rxrsp_to_snpf_wr_addr(rxrsp_to_snpf_wr_addr),
    	.rxrsp_to_snpf_wr_en(rxrsp_to_snpf_wr_en),
    	.rxrsp_to_snpf_wr_evict(rxrsp_to_snpf_wr_evict),
    	.rxrsp_to_snpf_wr_spv(rxrsp_to_snpf_wr_spv),
    	//.rxrsp_to_snpf_wr_state(rxrsp_to_snpf_wr_state),
    	.rxrsp_to_snpf_update_state(rxrsp_to_snpf_update_state),
    	.rxrsp_to_snpf_action(rxrsp_to_snpf_action),
    	.snpf_to_rxrsp_wr_hit(snpf_to_rxrsp_wr_hit),
    	.snpf_to_rxrsp_wr_chnl_ready(snpf_to_rxrsp_wr_chnl_ready),
    	.snpf_to_rxrsp_wr_is_failed(snpf_to_rxrsp_wr_is_failed),
    	.snpf_to_rxrsp_wr_done(snpf_to_rxrsp_wr_done),
    	//lkpt
    	.rxrsp_to_lkpt_txnid(rxrsp_to_lkpt_txnid),
    	.rxrsp_to_lkpt_rd_valid(rxrsp_to_lkpt_rd_valid),
    	.lkpt_to_rxrsp_txndat(lkpt_to_rxrsp_txndat),
    	/*
    	.rxrsp_to_datlkpt_txnid(rxrsp_to_datlkpt_txnid),
    	.datlkpt_to_rxrsp_txndat(datlkpt_to_rxrsp_txndat),
    	    	
    	.rxdat_to_datlkpt_txnid(rxdat_to_datlkpt_txnid),
    	.rxrsp_to_datlkpt_rd_valid(rxrsp_to_datlkpt_rd_valid),
        .rxdat_to_datlkpt_txndat(rxdat_to_datlkpt_txndat),
        .rxdat_to_datlkpt_valid(rxdat_to_datlkpt_valid),
        */
    	
    	//undat
    	.rxdat_to_undat_action(rxdat_to_undat_action),
        .undat_to_rxdat_nearly_full(undat_to_rxdat_nearly_full),
        .undat_to_rxdat_ready(undat_to_rxdat_ready),
        .rxdat_to_undat_dat(rxdat_to_undat_dat),
        .rxdat_to_undat_wr(rxdat_to_undat_wr),
        .rxdat_to_undat_tgtid(rxdat_to_undat_tgtid),
        .rxdat_to_undat_txnid(rxdat_to_undat_txnid),
        .rxdat_to_undat_dbid(rxdat_to_undat_dbid),
        .rxdat_to_undat_resp(rxdat_to_undat_resp),
        .rxdat_to_undat_resperr(rxdat_to_undat_resperr),
        .rxdat_to_undat_opcode(rxdat_to_undat_opcode),
        .rxdat_to_undat_addr(rxdat_to_undat_addr),
        .rxdat_to_undat_cache_wr(rxdat_to_undat_cache_wr),     
        .rxdat_to_undat_txnid_release(rxdat_to_undat_txnid_release), 
        .rxdat_to_undat_snpf_update(rxdat_to_undat_snpf_update),
       
        
        
   
    	//txrsp
    	.txrsp_to_rxrsp_nearly_full(txrsp_to_rxrsp_nearly_full),
    	.txrsp_to_rxrsp_ready(txrsp_to_rxrsp_ready),
        .rxrsp_to_txrsp_wr_en(rxrsp_to_txrsp_wr_en),
        .rxrsp_to_txrsp_txnid(rxrsp_to_txrsp_txnid),
        .rxrsp_to_txrsp_tgtid(rxrsp_to_txrsp_tgtid),
        .rxrsp_to_txrsp_opcode(rxrsp_to_txrsp_opcode),
        .rxrsp_to_txrsp_resp(rxrsp_to_txrsp_resp),
        .rxrsp_to_txrsp_resperr(rxrsp_to_txrsp_resperr),
        .rxrsp_txsnp_dbid(rxrsp_txsnp_dbid),
      	//expct_rsp wr
        .rxrsp_to_expct_rsp_txnid_wr(rxrsp_to_expct_rsp_txnid_wr),
        .rxrsp_to_expct_rsp_dat_wr(rxrsp_to_expct_rsp_dat_wr),
        .rxrsp_to_expct_rsp_valid_wr(rxrsp_to_expct_rsp_valid_wr),
        .expct_rsp_to_rxrsp_ready_wr(expct_rsp_to_rxrsp_ready_wr),
        //expct_rsp rd
        .rxrsp_to_expct_rsp_txnid_rd(rxrsp_to_expct_rsp_txnid_rd),
        .expct_rsp_to_rxrsp_dat_rd(expct_rsp_to_rxrsp_dat_rd),
        .rxrsp_to_expct_rsp_valid_rd(rxrsp_to_expct_rsp_valid_rd),
        .expct_rsp_to_rxrsp_ready_rd(expct_rsp_to_rxrsp_ready_rd),         
        //txreq
        .txreq_to_rxdat_ready         (txreq_to_rxdat_ready           ),       
        .rxdat_to_txreq_wr            (rxdat_to_txreq_wr              ),          
        .rxdat_to_txreq_opcode        (rxdat_to_txreq_opcode          ),
        .rxdat_to_txreq_tgtid         (rxdat_to_txreq_tgtid           ),
        .rxdat_to_txreq_txnid         (rxdat_to_txreq_txnid           ),       
        .rxdat_to_txreq_returnnid     (rxdat_to_txreq_returnnid       ),        
        .rxdat_to_txreq_returntxnid   (rxdat_to_txreq_returntxnid     ),        
        .rxdat_to_txreq_addr          (rxdat_to_txreq_addr            ),       
        .rxdat_to_txreq_likelyshared  (rxdat_to_txreq_likelyshared    ),
            	
    	.reset(reset),
    	.clk(clk)
);
   
       
   
   
   hnf_tx_req #(
    .VERBOSITY(VERBOSITY),
   // .src_id(src_id),
   	.B(B)
  
   )
   tx_req
   (
    .src_id(src_id),
   	.chi_noc_txreqflitpend(chi_noc_txreqflitpend),
   	.chi_noc_txreqflitv(chi_noc_txreqflitv),
   	.chi_noc_txreqflit(chi_noc_txreqflit),
   	.noc_chi_txreqlcrdv(noc_chi_txreqlcrdv),
    
     //rxreq
   	.txreq_to_rxreq_ready(txreq_to_rxreq_ready),
   	.rxreq_to_txreq_wr(rxreq_to_txreq_wr),
   	.rxreq_to_txreq_opcode(rxreq_to_txreq_opcode),
   	.rxreq_to_txreq_tgtid(rxreq_to_txreq_tgtid),
   	.rxreq_to_txreq_txnid(rxreq_to_txreq_txnid),
   	.rxreq_to_txreq_returnnid(rxreq_to_txreq_returnnid),
   	.rxreq_to_txreq_returntxnid(rxreq_to_txreq_returntxnid),
   	.rxreq_to_txreq_addr(rxreq_to_txreq_addr),
   	.rxreq_to_txreq_likelyshared(rxreq_to_txreq_likelyshared),
   	
   	//rxdat
    .txreq_to_rxdat_ready         (txreq_to_rxdat_ready           ),       
    .rxdat_to_txreq_wr            (rxdat_to_txreq_wr              ),          
    .rxdat_to_txreq_opcode        (rxdat_to_txreq_opcode          ),
    .rxdat_to_txreq_tgtid         (rxdat_to_txreq_tgtid           ),
    .rxdat_to_txreq_txnid         (rxdat_to_txreq_txnid           ),       
    .rxdat_to_txreq_returnnid     (rxdat_to_txreq_returnnid       ),        
    .rxdat_to_txreq_returntxnid   (rxdat_to_txreq_returntxnid     ),        
    .rxdat_to_txreq_addr          (rxdat_to_txreq_addr            ),       
    .rxdat_to_txreq_likelyshared  (rxdat_to_txreq_likelyshared    ),
   	
   	.reset(reset),
   	.clk(clk)
   );
     
      
   hnf_tx_snp #(
   	.B(B),
   	.VERBOSITY(VERBOSITY),
   	// .src_id(src_id),
   	.EAw(EAw),   	
   	.SNPF_SPVw(SNPF_SPVw)
   )
   tx_snp
   (
   	.src_id(src_id),
   	.chi_noc_txsnpflitpend(chi_noc_txsnpflitpend),
   	.chi_noc_txsnpflitv(chi_noc_txsnpflitv),
   	.chi_noc_txsnpflit(chi_noc_txsnpflit),
   	.noc_chi_txsnplcrdv(noc_chi_txsnplcrdv),
   	.snp_target_id(snp_target_id),
   	.rxreq_to_txsnp_spv(rxreq_to_txsnp_spv),
   	.rxreq_to_txsnp_we(rxreq_to_txsnp_we),
   	.txsnp_to_rxreq_ready(txsnp_to_rxreq_ready),
   	.rxreq_to_txsnp_txnid(rxreq_to_txsnp_txnid),
   	.rxreq_to_txsnp_fwdnid(rxreq_to_txsnp_fwdnid),
   	.rxreq_to_txsnp_fwdtxnid(rxreq_to_txsnp_fwdtxnid),
   	.rxreq_to_txsnp_opcode(rxreq_to_txsnp_opcode),
   	.rxreq_to_txsnp_addr(rxreq_to_txsnp_addr),
   	.rxreq_to_txsnp_rettosrc(rxreq_to_txsnp_rettosrc),   
   	.reset(reset),
   	.clk(clk)
   );   
  
  
  hnf_tx_rsp #(
  // .src_id(src_id),
    .VERBOSITY(VERBOSITY),
  	.B(B)  	
  )
  tx_rsp
  (
  	.src_id(src_id),
  	.reset(reset),
  	.clk(clk),
  	.chi_noc_txrspflitpend(chi_noc_txrspflitpend),
  	.chi_noc_txrspflitv(chi_noc_txrspflitv),
  	.chi_noc_txrspflit(chi_noc_txrspflit),
  	.noc_chi_txrsplcrdv(noc_chi_txrsplcrdv),
  	//rxrsp
  	.txrsp_to_rxrsp_nearly_full(txrsp_to_rxrsp_nearly_full),
  	.txrsp_to_rxrsp_ready(txrsp_to_rxrsp_ready),
  	.rxrsp_to_txrsp_wr_en(rxrsp_to_txrsp_wr_en),
  	.rxrsp_to_txrsp_txnid(rxrsp_to_txrsp_txnid),
  	.rxrsp_to_txrsp_tgtid(rxrsp_to_txrsp_tgtid),
  	.rxrsp_to_txrsp_opcode(rxrsp_to_txrsp_opcode),
  	.rxrsp_to_txrsp_resp(rxrsp_to_txrsp_resp),
  	.rxrsp_to_txrsp_resperr(rxrsp_to_txrsp_resperr),
  	.rxrsp_txsnp_dbid(rxrsp_txsnp_dbid),
  	//rxreq
  	.txrsp_to_rxreq_ready(txrsp_to_rxreq_ready),
    .rxreq_to_txrsp_wr_en(rxreq_to_txrsp_wr_en),
    .rxreq_to_txrsp_txnid(rxreq_to_txrsp_txnid),
    .rxreq_to_txrsp_tgtid(rxreq_to_txrsp_tgtid),
    .rxreq_to_txrsp_opcode(rxreq_to_txrsp_opcode),
    .rxreq_to_txrsp_resp(rxreq_to_txrsp_resp),
    .rxreq_to_txrsp_resperr(rxreq_to_txrsp_resperr),
    .rxreq_txsnp_dbid(rxreq_txsnp_dbid)
  );
  
   
    snoop_filter #(
        .VERBOSITY(VERBOSITY),   
        // .src_id(src_id),
    	.RESET_DELAY("MULTI_CLKS"),
        .SPVw(SNPF_SPVw),
        .WAY_NUM(SNPF_WAY_NUM),
        .STATUSw(CACHE_STATUSw),
        .BLK_SIZ(CACHE_BLK_SIZ),
        .INDEXw(SNPF_INDEXw),
        .ADDRw(SNPF_ADDRw )     
    )
    snpf
    (
        //rxreq
        .src_id(src_id),
    	.rxreq_to_snpf_wr_addr(rxreq_to_snpf_wr_addr),
        .rxreq_to_snpf_wr_en(rxreq_to_snpf_wr_en),
        .rxreq_to_snpf_wr_evict(rxreq_to_snpf_wr_evict),
        .rxreq_to_snpf_wr_spv(rxreq_to_snpf_wr_spv),
  //      .rxreq_to_snpf_wr_state(rxreq_to_snpf_wr_state),
        .rxreq_to_snpf_update_state(rxreq_to_snpf_update_state),
        .rxreq_to_snpf_action(rxreq_to_snpf_action),
       
        
        .snpf_to_rxreq_wr_hit(snpf_to_rxreq_wr_hit),
        .snpf_to_rxreq_wr_chnl_ready(snpf_to_rxreq_wr_chnl_ready),
        .snpf_to_rxreq_wr_is_failed(snpf_to_rxreq_wr_is_failed),
        .snpf_to_rxreq_wr_done(snpf_to_rxreq_wr_done),  
        .snpf_to_rxreq_re_fill( ),
    	.snpf_to_rxreq_re_fill_wr_spv( ),    	
    
    	.rxreq_to_snpf_rd_addr(rxreq_to_snpf_rd_addr),
    	.rxreq_to_snpf_rd_en(rxreq_to_snpf_rd_en),
    	.snpf_to_rxreq_spv(snpf_to_rxreq_spv),
    	.snpf_to_rxreq_rd_state(snpf_to_rxreq_rd_state),
    	.snpf_to_rxreq_rd_ready(snpf_to_rxreq_rd_ready),
    	.snpf_to_rxreq_rd_hit(snpf_to_rxreq_rd_hit),
    	.snpf_to_rxreq_rd_done(snpf_to_rxreq_rd_done),
    	.snpf_to_rxreq_rd_busy_bit(snpf_to_rxreq_rd_busy_bit),
    	.snpf_to_rxreq_rd_cnt_acpt_new(snpf_to_rxreq_rd_cnt_acpt_new),
    	
    	//rxrsp
    	.rxrsp_to_snpf_wr_addr(rxrsp_to_snpf_wr_addr),
        .rxrsp_to_snpf_wr_en(rxrsp_to_snpf_wr_en),
        .rxrsp_to_snpf_wr_evict(rxrsp_to_snpf_wr_evict),
        .rxrsp_to_snpf_wr_spv(rxrsp_to_snpf_wr_spv),
    //    .rxrsp_to_snpf_wr_state(rxrsp_to_snpf_wr_state),
        .rxrsp_to_snpf_update_state(rxrsp_to_snpf_update_state),
        .rxrsp_to_snpf_action(rxrsp_to_snpf_action),
     
           
        .snpf_to_rxrsp_wr_hit(snpf_to_rxrsp_wr_hit),
        .snpf_to_rxrsp_wr_chnl_ready(snpf_to_rxrsp_wr_chnl_ready),
        .snpf_to_rxrsp_wr_is_failed(snpf_to_rxrsp_wr_is_failed),
        .snpf_to_rxrsp_wr_done(snpf_to_rxrsp_wr_done), 
        .snpf_to_rxrsp_re_fill( ),
        .snpf_to_rxrsp_re_fill_wr_spv( ),  
        
            
        //undat                                                  
        .undat_to_snpf_wr_addr       (undat_to_snpf_wr_addr       ), 
        .undat_to_snpf_wr_en         (undat_to_snpf_wr_en         ),                  
        .undat_to_snpf_wr_evict      (undat_to_snpf_wr_evict      ),                  
        .undat_to_snpf_wr_spv        (undat_to_snpf_wr_spv        ),
      //  .undat_to_snpf_wr_state      (undat_to_snpf_wr_state      ),
        .undat_to_snpf_update_state  (undat_to_snpf_update_state  ),                    
        .undat_to_snpf_action        (undat_to_snpf_action        ),                 
        .snpf_to_undat_wr_hit        (snpf_to_undat_wr_hit        ),                  
        .snpf_to_undat_wr_chnl_ready (snpf_to_undat_wr_chnl_ready ),                  
        .snpf_to_undat_wr_is_failed  (snpf_to_undat_wr_is_failed  ),                  
        .snpf_to_undat_wr_done       (snpf_to_undat_wr_done       ),   
        
        
        
        
        //evbuf
        .evbuf_to_rxreq_addr(evbuf_to_rxreq_addr),
        .evbuf_to_rxreq_dat(evbuf_to_rxreq_dat),
        .evbuf_to_rxreq_valid(evbuf_to_rxreq_valid),
        .rxreq_evbuf_rd_en(rxreq_evbuf_rd_en),
        
    	
    	.reset(reset),
    	.clk(clk)
    ); 
      
   
   generate
   if(SYS_CACHE_EN == 1 )begin : syscache
  
   pronoc_cache_dualport #(
    .VERBOSITY(VERBOSITY),    
   // .src_id(src_id),
    .WAY_NUM(CACHE_WAY_NUM),
   	.STATUSw(CACHE_STATUSw),
    .BLK_SIZ(CACHE_BLK_SIZ),
    .ADDRw(CACHE_ADDRw),
    .INDEXw(CACHE_INDEXw),   
   	.DATAw(DATA_DAT),   	
   	.BYTE_WR_EN("NO")
   )
   sytem_cache
   (
   	.src_id(src_id),
   	.wr_addr(undat_to_cache_wr_addr),
    .wr_data(undat_to_cache_wr_data),
    .wr_en(undat_to_cache_wr_en),
    .wr_evict(undat_to_cache_wr_evict),
    .wr_state(undat_to_cache_wr_state),
    .wr_hit(cache_to_undat_wr_hit),
    .wr_ready(cache_to_undat_wr_ready),
    .wr_byteen(1'b0),
    .wr_done(cache_to_undat_wr_done),
    .wr_action(CACHE_UPDATE_DAT_ST),
   	
   	.rd_addr(rxreq_to_cache_rd_addr),
   	.rd_data(cache_to_rxreq_rd_data),
   	.rd_en(rxreq_to_cache_rd_en),
   	.rd_ready(cache_to_rxreq_rd_ready),
   	.rd_state(cache_to_rxreq_rd_state),
   	.rd_hit(cache_to_rxreq_rd_hit),
   	.rd_done(cache_to_rexreq_rd_done),
   	.re_fill( ),
   	.reset(reset),
   	.clk(clk)
   );
  end else begin:nosys_cache
    assign cache_to_undat_wr_ready=1'b1;
    assign cache_to_undat_wr_hit=1'b0; 
    assign cache_to_rxreq_rd_ready=1'b1;
    assign cache_to_rxreq_rd_hit=1'b0;
  end
  endgenerate 
     
    
    
    transaction_lookup_table #(
        .TXN_DATAw(HNF_RXRSP_TXN_DATAw),
        .TXN_IDw(TXNID_REQ)
    )
    lkpt_rxrsp
    (
        .txn_wr_addr(txreq_to_rxrsplkpt_txnid),
        .txn_wr_dat(txreq_to_rxrsplkpt_txndat),
        .txn_wr_en(txreq_to_rxrsplkpt_valid),
        
        .txn_rd_addr(rxrsp_to_lkpt_txnid),
        .txn_rd_dat(lkpt_to_rxrsp_txndat),
        .txn_rd_en(rxrsp_to_lkpt_rd_valid),
        .clk(clk)
    ); 
   
   /*
    transaction_lookup_table #(
        .TXN_DATAw(DATA_DAT),
        .TXN_IDw(TXNID_REQ)
    )
    lkpt_dat
    (
        .txn_wr_addr(rxdat_to_datlkpt_txnid),
        .txn_wr_dat(rxdat_to_datlkpt_txndat),
        .txn_wr_en(rxdat_to_datlkpt_valid),
        
        .txn_rd_addr(rxrsp_to_datlkpt_txnid),
        .txn_rd_dat(datlkpt_to_rxrsp_txndat),
        .txn_rd_en(rxrsp_to_datlkpt_rd_valid),
        .clk(clk)
    ); 
   */
   
   
   hnf_data_process #(
    .SNPF_SPVw(SNPF_SPVw),
     //.src_id(src_id),
    .VERBOSITY(VERBOSITY)    
   )
   data_process
   (
   	.src_id(src_id),
   	.reset(reset),
   	.clk(clk),
   	//rxreq
   	.undat_to_rxreq_ready(undat_to_rxreq_ready),
   	.rxreq_to_undat_wr(rxreq_to_undat_wr),
   	.rxreq_to_undat_dat(rxreq_to_undat_dat),
   	.rxreq_to_undat_txnid(rxreq_to_undat_txnid),
   	.rxreq_to_undat_action(rxreq_to_undat_action),
   	.rxreq_to_undat_addr(rxreq_to_undat_addr),
    .rxreq_to_undat_cache_evict(rxreq_to_undat_cache_evict),   	
   	.rxreq_to_undat_tgtid(rxreq_to_undat_tgtid ),
    .rxreq_to_undat_dbid(rxreq_to_undat_dbid  ),
    .rxreq_to_undat_opcode(rxreq_to_undat_opcode),
    .rxreq_to_undat_resp(rxreq_to_undat_resp  ),
    .rxreq_to_undat_resperr(rxreq_to_undat_resperr),
   	
   	//rxdat
   	.undat_to_rxdat_ready(undat_to_rxdat_ready),
   	.rxdat_to_undat_dat(rxdat_to_undat_dat),
   	.rxdat_to_undat_wr(rxdat_to_undat_wr),
   	.rxdat_to_undat_tgtid(rxdat_to_undat_tgtid),
   	.rxdat_to_undat_txnid(rxdat_to_undat_txnid),
   	.rxdat_to_undat_dbid(rxdat_to_undat_dbid),
   	.rxdat_to_undat_resp(rxdat_to_undat_resp),
   	.rxdat_to_undat_resperr(rxdat_to_undat_resperr),
   	.rxdat_to_undat_opcode(rxdat_to_undat_opcode),
   	.rxdat_to_undat_action(rxdat_to_undat_action),
   	.txdat_to_undat_ready(txdat_to_undat_ready),
    .rxdat_to_undat_addr(rxdat_to_undat_addr),
    .rxdat_to_undat_cache_wr(rxdat_to_undat_cache_wr),
    .rxdat_to_undat_txnid_release(rxdat_to_undat_txnid_release), 
    .rxdat_to_undat_snpf_update(rxdat_to_undat_snpf_update),
   
    //txngen
    .undat_to_txgen_txnid(undat_to_txgen_txnid),         
    .undat_to_txgen_txnid_release(undat_to_txgen_txnid_release), 
    .txgen_to_undat_ready(txgen_to_undat_ready),         
   
   
   //txdat
   	.undat_to_txdat_dat(undat_to_txdat_dat),
   	.undat_to_txdat_wr(undat_to_txdat_wr),
   	.undat_to_txdat_tgtid(undat_to_txdat_tgtid),
   	.undat_to_txdat_txnid(undat_to_txdat_txnid),
   	.undat_to_txdat_dbid(undat_to_txdat_dbid),
   	.undat_to_txdat_resp(undat_to_txdat_resp),
   	.undat_to_txdat_resperr(undat_to_txdat_resperr),
   	.undat_to_txdat_opcode(undat_to_txdat_opcode),
   	
   	//snpf                                                   
    .undat_to_snpf_wr_addr       (undat_to_snpf_wr_addr       ), 
    .undat_to_snpf_wr_en         (undat_to_snpf_wr_en         ),                  
    .undat_to_snpf_wr_evict      (undat_to_snpf_wr_evict      ),                  
    .undat_to_snpf_wr_spv        (undat_to_snpf_wr_spv        ),
 //   .undat_to_snpf_wr_state      (undat_to_snpf_wr_state      ),
    .undat_to_snpf_update_state  (undat_to_snpf_update_state  ),                    
    .undat_to_snpf_action        (undat_to_snpf_action        ),                 
    .snpf_to_undat_wr_hit        (snpf_to_undat_wr_hit        ),                  
    .snpf_to_undat_wr_chnl_ready (snpf_to_undat_wr_chnl_ready ),                  
    .snpf_to_undat_wr_is_failed  (snpf_to_undat_wr_is_failed  ),                  
    .snpf_to_undat_wr_done       (snpf_to_undat_wr_done       ),                  
   	
   	
  
   	//cahe_wr
    .undat_to_cache_wr_addr(undat_to_cache_wr_addr),
    .undat_to_cache_wr_data(undat_to_cache_wr_data),
    .undat_to_cache_wr_state(undat_to_cache_wr_state),
    .undat_to_cache_wr_en(undat_to_cache_wr_en),
    .undat_to_cache_wr_evict(undat_to_cache_wr_evict),
    .cache_to_undat_wr_hit(cache_to_undat_wr_hit),
    .cache_to_undat_wr_done(cache_to_undat_wr_done),
    .cache_to_undat_wr_ready(cache_to_undat_wr_ready)
   );
   
   
   
     hnf_expct_rsp  #(
        .VERBOSITY(VERBOSITY),  
        // .src_id(src_id),
     	.EXPCT_RSP_Dw(EXPCT_RSP_Dw)     	
     )
     expct_rsp
     (
     	.src_id(src_id),
     	.reset(reset),
     	.clk(clk),
     	//txreq wr
     	.rxreq_to_expct_rsp_txnid_wr(rxreq_to_expct_rsp_txnid_wr),
     	.rxreq_to_expct_rsp_dat_wr(rxreq_to_expct_rsp_dat_wr),
     	.rxreq_to_expct_rsp_valid_wr(rxreq_to_expct_rsp_valid_wr),
     	.expct_rsp_to_rxreq_ready_wr(expct_rsp_to_rxreq_ready_wr),
     	//rxrsp wr
     	.rxrsp_to_expct_rsp_txnid_wr(rxrsp_to_expct_rsp_txnid_wr),
     	.rxrsp_to_expct_rsp_dat_wr(rxrsp_to_expct_rsp_dat_wr),
     	.rxrsp_to_expct_rsp_valid_wr(rxrsp_to_expct_rsp_valid_wr),
     	.expct_rsp_to_rxrsp_ready_wr(expct_rsp_to_rxrsp_ready_wr),
     	//rxtsp rd
     	.rxrsp_to_expct_rsp_txnid_rd(rxrsp_to_expct_rsp_txnid_rd),
     	.expct_rsp_to_rxrsp_dat_rd(expct_rsp_to_rxrsp_dat_rd),
     	.rxrsp_to_expct_rsp_valid_rd(rxrsp_to_expct_rsp_valid_rd),
     	.expct_rsp_to_rxrsp_ready_rd(expct_rsp_to_rxrsp_ready_rd)
     );
   
   
   
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_FLIT_INJECT) > 0) begin 
            if(noc_chi_rxrspflitv) $display("%t: hnf ( %d ) rsp chanel has recived a packet:%h",$time,src_id,noc_chi_rxrspflit);
            if(noc_chi_rxdatflitv) $display("%t: hnf ( %d ) dat chanel has recived a packet:%h",$time,src_id,noc_chi_rxdatflit);
            if(noc_chi_rxreqflitv) $display("%t: hnf ( %d ) req chanel has recived a packet:%h",$time,src_id,noc_chi_rxreqflit);
            if(noc_chi_rxsnpflitv) $display("%t: hnf ( %d ) snp chanel has recived a packet:%h",$time,src_id,noc_chi_rxsnpflit);
        end            
    end
     //synthesis translate_on 
    //synopsys  translate_on
   
   
   
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_FLIT_INJECT) > 0) begin 
            if(chi_noc_txrspflitv) $display("%t: hnf ( %d ) rsp chanel has sent a packet:%h",$time,src_id,chi_noc_txrspflit);
            if(chi_noc_txdatflitv) $display("%t: hnf ( %d ) dat chanel has sent a packet:%h",$time,src_id,chi_noc_txdatflit);
            if(chi_noc_txreqflitv) $display("%t: hnf ( %d ) req chanel has sent a packet:%h",$time,src_id,chi_noc_txreqflit);
            if(chi_noc_txsnpflitv) $display("%t: hnf ( %d ) snp chanel has sent a packet:%h",$time,src_id,chi_noc_txsnpflit);
        end            
    end
     //synthesis translate_on 
    //synopsys  translate_on


  //synthesis translate_off 
   //synopsys  translate_off

     
    
  
    /*
     
     initial begin 
        cache_wr_evict=1'b0;
        cache_wr_en=1'b0;
        cache_wr_addr = 0;
        cache_wr_state=0;
             
        
        @ (negedge cache_wr_busy) #20;
        
        @ (posedge clk) #1  
        cache_wr_addr = 50;
        cache_wr_en=1'b1;
        cache_wr_state =  {st_shared, st_clean, st_full , st_valid};
        cache_wr_data= 'hDEADBEEF;
        
        @ (posedge clk) #1
        cache_wr_en=1'b0;
        $display("cache address 50 is filed");
          
    end
    
    */
   



  //synthesis translate_on 
    //synopsys  translate_on


endmodule
