/**************************************
* Module: hnf_rx_req
* Date:2019-05-16  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  hnf_rx_req #(
    parameter VERBOSITY=3,
   // parameter src_id=0,
   // parameter snf_id = 3, // For each home node only one SNF is assigned. (acording to mb2020 specefication) so no need for sam. 
    parameter B=4,
    parameter SNPF_SPVw=5,
    parameter SNPF_ADDRw=32,
    parameter EXPCT_RSP_Dw=6,
    parameter NUM_OF_RNs=32,
    parameter NUM_OF_HNs=32

)(

    src_id,
    snf_id,
    
    reset,
    clk,

    // CHI RXREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,          
    chi_noc_rxreqlcrdv,      

    //snoop-filter read channel
    rxreq_to_snpf_rd_addr,
    rxreq_to_snpf_rd_en,
    snpf_to_rxreq_rd_spv,
    snpf_to_rxreq_rd_state,
    snpf_to_rxreq_rd_ready,
    snpf_to_rxreq_rd_hit,
    snpf_to_rxreq_rd_done,
    snpf_to_rxreq_rd_busy_bit,
    snpf_to_rxreq_rd_cnt_acpt_new,
    
    //snoop-filter write channel
    rxreq_to_snpf_wr_addr,
    rxreq_to_snpf_wr_en,
    rxreq_to_snpf_wr_evict,
    rxreq_to_snpf_wr_spv,
  //  rxreq_to_snpf_wr_state,
    rxreq_to_snpf_update_state,
    rxreq_to_snpf_action, 
   
    
    snpf_to_rxreq_wr_hit,
    snpf_to_rxreq_wr_chnl_ready,
    snpf_to_rxreq_wr_is_failed,
    snpf_to_rxreq_wr_done,
        
    
    //cache read-channel
    rxreq_to_cache_rd_addr,
    cache_to_rxreq_rd_data,
    rxreq_to_cache_rd_en,
    cache_to_rxreq_rd_ready,   
    cache_to_rxreq_rd_state,
    cache_to_rxreq_rd_hit,
    cache_to_rexreq_rd_done, 
   
    //cahe wr channel is added to undat
    
       
    
    //txreq
    txreq_to_rxreq_ready,
    rxreq_to_txreq_wr,
    rxreq_to_txreq_opcode,
    rxreq_to_txreq_tgtid,
    rxreq_to_txreq_txnid,
    rxreq_to_txreq_returnnid,
    rxreq_to_txreq_returntxnid, 
    rxreq_to_txreq_addr,
    rxreq_to_txreq_likelyshared,
    
    //txnsnp
    txsnp_to_rxreq_ready,
    rxreq_to_txsnp_spv,
    rxreq_to_txsnp_we,
    rxreq_to_txsnp_txnid,
    rxreq_to_txsnp_fwdnid,
    rxreq_to_txsnp_fwdtxnid,
    rxreq_to_txsnp_opcode,
    rxreq_to_txsnp_addr,
    rxreq_to_txsnp_rettosrc,
    
      
         
    //rxrsplkpt   
    txreq_to_rxrsplkpt_txnid,
    txreq_to_rxrsplkpt_txndat,
    txreq_to_rxrsplkpt_valid, 
    
    
    //rxrsp snoop wait
    rxreq_to_expct_rsp_txnid_wr,
    rxreq_to_expct_rsp_dat_wr,
    rxreq_to_expct_rsp_valid_wr,
    expct_rsp_to_rxreq_ready_wr,
   
   
    //rxrsp
    rxrsp_to_txgen_txnid,
    rxrsp_to_txgen_txnid_release,
    txgen_to_rxrsp_ready,
    
    //txrsp
    txrsp_to_rxreq_ready,
    rxreq_to_txrsp_wr_en,
    rxreq_to_txrsp_txnid,
    rxreq_to_txrsp_tgtid,
    rxreq_to_txrsp_opcode,
    rxreq_to_txrsp_resp,
    rxreq_to_txrsp_resperr,
    rxreq_txsnp_dbid,
    
    //evbuff
    evbuf_to_rxreq_addr,
    evbuf_to_rxreq_dat,
    evbuf_to_rxreq_valid,
    rxreq_evbuf_rd_en,   
    
    //undat
    undat_to_rxreq_ready,  
    rxreq_to_undat_wr, 
    rxreq_to_undat_dat, 
    rxreq_to_undat_txnid,
    rxreq_to_undat_action,
    rxreq_to_undat_addr,
    rxreq_to_undat_tgtid, 
    rxreq_to_undat_dbid, 
    rxreq_to_undat_opcode,
    rxreq_to_undat_resp, 
    rxreq_to_undat_resperr,
    
    
    rxreq_to_undat_cache_evict,
    
    
    undat_to_txgen_txnid,
    undat_to_txgen_txnid_release,
    txgen_to_undat_ready
   
    
);


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
     
    
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
    
    
   localparam  ADRR_OFFSETw = log2(CACHE_BLK_SIZ);        // The address range in cache block
   
   input [31 : 0] src_id;
   input [31 : 0] snf_id;
   
    input reset,clk;

     // RXREQ
    input   noc_chi_rxreqflitpend ;
    input   noc_chi_rxreqflitv;
    input  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit;          
    output  chi_noc_rxreqlcrdv;   

    //snoop-filter read channel
    output [ADDR_REQ-1 : 0] rxreq_to_snpf_rd_addr;
    output rxreq_to_snpf_rd_en;
    input [SNPF_SPVw-1 : 0] snpf_to_rxreq_rd_spv;
    input [CACHE_STATUSw-1 : 0] snpf_to_rxreq_rd_state;
    input snpf_to_rxreq_rd_ready;    
    input snpf_to_rxreq_rd_hit;
    input snpf_to_rxreq_rd_done;
    input snpf_to_rxreq_rd_busy_bit;  
    input snpf_to_rxreq_rd_cnt_acpt_new;
    
    //snoop-filter write channel
    output reg [ADDR_REQ-1 : 0] rxreq_to_snpf_wr_addr;
    output reg rxreq_to_snpf_wr_en;
    output reg rxreq_to_snpf_wr_evict;
    output reg [SNPF_SPVw-1 : 0] rxreq_to_snpf_wr_spv;
 //   output reg [CACHE_STATUSw-1 : 0] rxreq_to_snpf_wr_state;
    output reg rxreq_to_snpf_update_state;
    output  [SNPF_ACTw-1:0] rxreq_to_snpf_action;
   
    
    
    input snpf_to_rxreq_wr_hit;
    input snpf_to_rxreq_wr_chnl_ready;
    input snpf_to_rxreq_wr_is_failed;
    input snpf_to_rxreq_wr_done;
    
    
    //cache read-channel
    output [ADDR_REQ-1 : 0] rxreq_to_cache_rd_addr;
    input  [DATA_DAT-1 : 0] cache_to_rxreq_rd_data;
    output rxreq_to_cache_rd_en;
    input cache_to_rxreq_rd_ready;   
    input [CACHE_STATUSw-1 : 0] cache_to_rxreq_rd_state;
    input cache_to_rxreq_rd_hit;
    input cache_to_rexreq_rd_done;  
  
   
    //cache write channel is added to undat     
    
   
  
    
    
    //txreq
    input txreq_to_rxreq_ready;
    output reg rxreq_to_txreq_wr;
    output reg [OPCODE_REQ-1 : 0] rxreq_to_txreq_opcode;
    output reg [TGTID_REQ-1  : 0] rxreq_to_txreq_tgtid;
    output reg [TXNID_REQ-1  : 0] rxreq_to_txreq_txnid;
    output reg [RETURNNID_REQ-1 : 0] rxreq_to_txreq_returnnid;
    output reg [RETURNTXNID_REQ-1:0] rxreq_to_txreq_returntxnid;
    output reg [ADDR_REQ-1: 0] rxreq_to_txreq_addr;
    output reg rxreq_to_txreq_likelyshared;
    
    
    //txsnp
    input  txsnp_to_rxreq_ready;
    output reg [SNPF_SPVw-1  : 0] rxreq_to_txsnp_spv;
    output reg rxreq_to_txsnp_we;
    output reg [TXNID_SNP-1   :0] rxreq_to_txsnp_txnid;
    output reg [FWDNID_SNP-1  :0] rxreq_to_txsnp_fwdnid;
    output reg [FWDTXNID_SNP-1:0] rxreq_to_txsnp_fwdtxnid;
    output reg [OPCODE_SNP-1  :0] rxreq_to_txsnp_opcode;
    output reg [ADDR_SNP-1    :0] rxreq_to_txsnp_addr;
    output reg rxreq_to_txsnp_rettosrc;   
    
    
            
    //rxrsplkpt   
    output [TXNID_REQ-1 : 0] txreq_to_rxrsplkpt_txnid;
    output [HNF_RXRSP_TXN_DATAw-1 : 0] txreq_to_rxrsplkpt_txndat;
    output txreq_to_rxrsplkpt_valid;
    
    //EXPCT_RSP
    // add the list of all RNs we expect to recive snoop comp/compdata from. 
    output  [TXNID_REQ-1 : 0] rxreq_to_expct_rsp_txnid_wr;
    output reg [EXPCT_RSP_Dw-1 : 0] rxreq_to_expct_rsp_dat_wr;
    output reg rxreq_to_expct_rsp_valid_wr;
    input expct_rsp_to_rxreq_ready_wr;
    
    //rxrsp
    input [TXNID_REQ-1:0]   rxrsp_to_txgen_txnid;
    input rxrsp_to_txgen_txnid_release;
    output txgen_to_rxrsp_ready;
    
    
    //txrsp
    input  txrsp_to_rxreq_ready;
    output reg  rxreq_to_txrsp_wr_en;
    output reg  [TXNID_RSP-1:0] rxreq_to_txrsp_txnid;
    output reg  [TGTID_RSP-1:0] rxreq_to_txrsp_tgtid;
    output reg  [OPCODE_RSP-1:0] rxreq_to_txrsp_opcode;
    output reg  [RESP_RSP-1:0] rxreq_to_txrsp_resp;
    output reg  [RESPERR_RSP-1:0] rxreq_to_txrsp_resperr;
    output reg  [TXNID_RSP-1:0] rxreq_txsnp_dbid;   
    
    
    //evbuf
    input [SNPF_ADDRw-1 : 0]  evbuf_to_rxreq_addr;
    input [SNPF_SPVw-1 : 0] evbuf_to_rxreq_dat;
    input evbuf_to_rxreq_valid;
    output reg  rxreq_evbuf_rd_en;     
    
    //undat
    input   undat_to_rxreq_ready; 
    output reg rxreq_to_undat_wr; 
    output  reg [DATA_DAT-1  : 0] rxreq_to_undat_dat;
    output reg  [TXNID_REQ-1 : 0] rxreq_to_undat_txnid;  
    output  reg [DU_ACTw-1 : 0] rxreq_to_undat_action;
    output reg [ADDR_REQ-1 : 0] rxreq_to_undat_addr;
    output reg rxreq_to_undat_cache_evict;
    output reg [TGTID_DAT-1:0]rxreq_to_undat_tgtid;
    output reg [TXNID_DAT-1:0]rxreq_to_undat_dbid;
    output reg [OPCODE_DAT-1 : 0]rxreq_to_undat_opcode;
    output reg [RESP_DAT-1 : 0] rxreq_to_undat_resp;
    output reg [RESPERR_DAT-1 : 0] rxreq_to_undat_resperr;
    
    
    input [TXNID_REQ-1:0]   undat_to_txgen_txnid;
    input  undat_to_txgen_txnid_release;
    output txgen_to_undat_ready;
   
    
    
    
  //  assign txgen_to_rxrsp_ready= 1'b1;   
       
     wire [SNPF_SPVw-1 : 0] srcid_spv;
     
    //input buffer
    wire [REQ_FLIT_SIZE-1 : 0] current_rxreqflit;
    reg read_fifo_en;
    reg rx_req_busy; 
    reg add_credit;
   
   
   //snoop filter
   //Gets addr one cycle before reading the actual flit and send it to snoop filter. Assum single cycle ideal snoop filter 
   // so the snoop result will be ready once the actual flit is read
 
   wire [ADDR_REQ-1:0]            next_req_addr;
 
  // exclusive monitor
  // Gets addr tag,  src_id and lpid, and opcode one cycle before reading the actual flit. Exclusive monitor has one cycle delay.
  
   wire [SRCID_REQ-1:0]           next_srcid;
   wire [LPID_REQ-1:0]            next_lpid; 
   wire [OPCODE_REQ-1:0]          next_opcode;
   wire next_excl_snoopme;
  
    wire next_exl_load_en  = 
        (next_excl_snoopme ==1'b1 ) & read_fifo_en  & (
        (next_opcode == REQ_OPCODE_ReadNoSnp) |
        (next_opcode == REQ_OPCODE_ReadClean) |
        (next_opcode == REQ_OPCODE_ReadNotSharedDirty) |
        (next_opcode == REQ_OPCODE_ReadShared));
    
    
    wire next_exl_store_en = 
        (next_excl_snoopme ==1'b1) & read_fifo_en & (
        (next_opcode ==  REQ_OPCODE_WriteNoSnpPtl) |
        (next_opcode ==  REQ_OPCODE_WriteNoSnpFull) |
        (next_opcode ==  REQ_OPCODE_CleanUnique));
        
   
    reg excl_transaction;
    always @(posedge clk) begin
        excl_transaction<=next_exl_store_en | next_exl_load_en;
    end
    
    //assign rxreq_to_snpf_rd_addr = addr_in; // assum idel single cycle pipe-stage Cache
   
      
  
    
    
    wire [SNPF_SPVw-2 : 0] shared_in_other_rns = snpf_to_rxreq_rd_spv[SNPF_SPVw-2 : 0] & ~srcid_spv[SNPF_SPVw-2: 0];
  
  
    
   
    
    // cache read 
   // assign rxreq_to_cache_rd_addr = addr_in; // assum idel single cycle pipe-stage Cache
  //  assign rxreq_to_cache_rd_en = noc_chi_rxreqflitv;
    wire [DATA_DAT : 0] current_cache_data, cache_din;
    wire current_cache_to_rxreq_rd_hit;
    wire [DATA_DAT-1 : 0] current_cache_to_rxreq_rd_data;
    
    assign current_cache_data = {cache_to_rxreq_rd_hit,cache_to_rxreq_rd_data};
    assign {current_cache_to_rxreq_rd_hit,current_cache_to_rxreq_rd_data} = current_cache_data;
    
    wire flit_fifo_empty, snpf_fifo_empty, cache_fifo_empty;
    assign snpf_fifo_empty = 1'b0;
    assign cache_fifo_empty=1'b0;
    
    
     // txreqflit
        wire [QOS_REQ-1:0]             qos; // = {QOS_REQ{1'b0}};
        wire [TGTID_REQ-1:0]           tgtid;
        wire [SRCID_REQ-1:0]           srcid;
        wire [TXNID_REQ-1:0]           txnid;
        wire [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
        wire                           endian; // = 1'b1;
        wire [RETURNTXNID_REQ-1:0]     returntxnid;
        wire [OPCODE_REQ-1:0]          opcode;
        wire [SIZE_REQ-1:0]            flitsize; // = 3'b110 ;
        wire [ADDR_REQ-1:0]            addr;
        wire                           ns; // = 1'b1;
        wire                           likelyshared; // = 1'b0;
        wire                           allowretry; // = 1'b1;
        wire [ORDER_REQ-1:0]           order; // = 2'b11;
        wire [PCRDTYPE_REQ-1:0]        pcrdtype; // = 4'b0000;
        wire [MEMATTR_REQ-1:0]         memattr;// = 4'b0111;
        wire                           snpattr; // = 1'b1;
        wire [LPID_REQ-1:0]            lpid; // = 5'b00000;
        wire                           excl_snoopme; // = 1'b1;
        wire                           expcompack;
        wire                           tracetag; // = 1'b0;
    
    
    reg re_try;
  
  
   reg got_data;
  
  
  //if we are going to read a new request send its address one cycle in advanced to snoop filter and cache
   assign rxreq_to_snpf_rd_addr  =    next_req_addr; //(read_fifo_en) ?  next_req_addr : addr;
   assign rxreq_to_cache_rd_addr =    next_req_addr;  //(read_fifo_en) ?  next_req_addr : addr;
  
   assign rxreq_to_snpf_rd_en = read_fifo_en;
   assign rxreq_to_cache_rd_en = read_fifo_en;
      
   wire  rxreqflitpend ;
   wire  rxreqflitv;
   wire  [REQ_FLIT_SIZE-1:0]    rxreqflit;          
   wire  rxreqlcrdv;   
   
   //TODO retry not yet supported in this buffer. 
   hnf_req_retry_manager #(
   	.B(B),
   	.EXTND_B(B+4)
   )
   hnf_req_buffer_manager
   (
   	.noc_chi_rxreqflitpend(noc_chi_rxreqflitpend),
   	.noc_chi_rxreqflitv(noc_chi_rxreqflitv),
   	.noc_chi_rxreqflit(noc_chi_rxreqflit),
   	.chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv),
   	
   	.rxreqflitpend(rxreqflitpend),
   	.rxreqflitv(rxreqflitv),
   	.rxreqflit(rxreqflit),
   	.rxreqlcrdv(rxreqlcrdv),
   	.reset(reset),
   	.clk(clk)
   );
      
      
         
      
   hnf_req_buffer #(
    .B(B+1)//  one more buffer space to support reytry 
   )
   flit_fifo
   (
    .req_din(rxreqflit),
    .wr_en(rxreqflitv),
    .credit_out(rxreqlcrdv),
    .add_credit(add_credit),
    .rd_en(read_fifo_en ),
    .req_dout(current_rxreqflit),
    .next_addr_out(next_req_addr),
    .next_srcid_out(next_srcid),
    .next_lpid_out(next_lpid), 
    .next_opcode_out(next_opcode),
    .next_excl_snoopme_out(next_excl_snoopme),    
    
    .re_try(re_try),
    .full(),
    .nearly_full(),
    .empty(flit_fifo_empty),
    .reset(reset),
    .clk(clk)
   );
   
  
   
   wire txnid_table_empty;
   wire txnid_gen_ready = ~ txnid_table_empty;
   reg new_txnid_gen;
   wire [TXNID_REQ-1:0]  new_txnid;
   
  
  
  
   
   
    
  
  wire [TXNID_REQ-1 : 0 ] txgen_txnid_in;  
  wire txgen_add;
  
   many_to_one_pipereg #(
   	.Dw(TXNID_REQ),
   	.IN_NUM(2),
   	.IGNORE_SAME_LOC_RD_WR_WARNING("YES")
   )
   pipereg_txn
   (
    .src_id(src_id),
   	.qin_data_in({rxrsp_to_txgen_txnid,undat_to_txgen_txnid}),
   	.qin_we({rxrsp_to_txgen_txnid_release,undat_to_txgen_txnid_release}),
   	.qin_is_ready({txgen_to_rxrsp_ready,txgen_to_undat_ready}),
   	.qout_data_o(txgen_txnid_in),
   	.qin_valid_o(),
   	.qout_we_o(txgen_add),
   	.qout_is_ready(1'b1),
   	.qout_winner( ),
   	.reset(reset),
   	.clk(clk),
   	.qin_data_o( )
   );
   
   
   
   txnid_gen #(
 // .src_id(src_id),
    .VERBOSITY(VERBOSITY),
   	.TAGw(TXNID_REQ)
  // 	.INIT_ID(100)
   )
   txnid_gen
   (
    .src_id(src_id),
   	.reset(reset),
   	.clk(clk),
   	.txnid_in(txgen_txnid_in),
   	.add(txgen_add),
   	.txnid_out(new_txnid),
   	.read(new_txnid_gen),
   	.empty(txnid_table_empty)
   );


   
    rnfid_to_spv_addr_decode #(
    	.SPVw(SNPF_SPVw),
    	.IDw(SRCID_REQ)
    )
    spv_addr_decoder
    (
    	.rnf_id_i(srcid),
    	.rnf_spv_o(srcid_spv)
    );




    localparam EXCL_LP_NUM = NUM_OF_RNs * MAX_EXCL_LP_PER_RN;
    localparam EXCL_LPw = log2(EXCL_LP_NUM);

    wire [EXCL_LPw-1 : 0] next_lp_bin_addr;
    wire [EXCL_TAG_ADRw-1 : 0] next_excl_tag_addr;
    wire excl_result;
    
// The phisical processor binary address. 
    rnf_lpid_addr_decode #(
        .NUM_OF_RNs(NUM_OF_RNs),
        .LPw(EXCL_LPw),
        .LP_IDw (LPID_REQ),            
        .RNF_IDw(SRCID_REQ),
        .MAX_EXCL_LP_PER_RN(MAX_EXCL_LP_PER_RN)
    )
    lpid_addr_decoder
    (
        .rnf_id_i(next_srcid),
        .lpid_in_rnf_i(next_lpid),
        .lp_bin_addr_o(next_lp_bin_addr)
    );

// The excl_tag addr. based on chi spec only a subset of address is required 
    hnf_exl_tag_addr_extract #(
        .EXCL_TAG_ADRw(EXCL_TAG_ADRw),
        .ADDR_REQ(ADDR_REQ),
        .CACHE_BLK_SIZ(CACHE_BLK_SIZ),
        .NUM_OF_HNs(NUM_OF_HNs)
    )
    tag_gen
    (
        .next_req_addr(next_req_addr),
        .next_excl_tag_addr(next_excl_tag_addr)    
    );


    hnf_excl_monitor #(
        .VERBOSITY(VERBOSITY),
    	// .src_id(src_id),
    	.LP_NUM(EXCL_LP_NUM),
    	.TAG_ADRw(EXCL_TAG_ADRw)
    )
    excl_monitor
    (
    	.src_id(src_id),
    	.reset(reset),
    	.clk(clk),
    	.read_fifo_en(read_fifo_en),
    	.next_lp_bin_addr(next_lp_bin_addr),
    	.next_tag_addr(next_excl_tag_addr),
    	.next_exl_load_en(next_exl_load_en),
    	.next_exl_store_en(next_exl_store_en),
    	.excl_result(excl_result),
    	.re_try(re_try) // the exclusive monitore result is captured in next clock cycle if only if re_try is not asserted.
    	
    );




     localparam LOCAL_CACHE_SPV = SNPF_SPVw-1;

     assign {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} = current_rxreqflit; 

    wire shared_in_system_cache = snpf_to_rxreq_rd_spv[LOCAL_CACHE_SPV];
    wire st_busy;
    
    //snpf cache state is ubtained by analayzing the read state from snpf and the current requset to adapt with scilent cache transient condition. 
    reg [2:0] snpf_cache_state;    
    always @(*)begin 
        snpf_cache_state =  snpf_to_rxreq_rd_state;
        if(snpf_to_rxreq_rd_hit) begin
            //need to check if snpf list is matching with reques
            case(opcode)
            REQ_OPCODE_ReadShared,REQ_OPCODE_ReadUnique,REQ_OPCODE_CleanUnique:begin 
                if((snpf_to_rxreq_rd_state == SNPF_U) && (shared_in_other_rns == {(SNPF_SPVw-1){1'b0}}) ) snpf_cache_state = SNPF_I;
            end
            endcase
        end else snpf_cache_state = SNPF_I;
     end
    
    
    assign st_busy =  snpf_to_rxreq_rd_busy_bit | snpf_to_rxreq_rd_cnt_acpt_new; // go to hazard ehen the cche line is busy or its not but there is no non-busy filed available in snpf line while the eviction buffer is full 
    
       
    
    assign  txreq_to_rxrsplkpt_txnid = new_txnid;
    assign  rxreq_to_expct_rsp_txnid_wr =  new_txnid;
   

    localparam 
        IDEAL=1,
        PROCESS_REQ=2,
        PROCESS_EVBUF=4;
    
    reg [2:0] pst;
    reg [2:0] nst; 
   
    
    
    reg [4: 0] action_type;
    localparam [4: 0] NO_TRANSFER = 0;
    localparam [4: 0] HAZARD =1;
    localparam [4: 0] LCT=2;
    localparam [4: 0] DCT=3;
    localparam [4: 0] IDCT=4;
    localparam [4: 0] DMT=5;
    localparam [4: 0] IDMT=6;
    localparam [4: 0] HAZARD_SAME_ADDR=7;
    localparam [4: 0] ATOMIC_RN=8;
    localparam [4: 0] ATOMIC_CAHCE=9;
    localparam [4: 0] ATOMIC_MEM=10;
   
   
    
    
    
    // snpf_state  
    /* snpf state will be obtained using SPV filed
    reg[2:0] snpf_state_action;
    localparam 
        SNPF_ST_IDEAL=0,
        SNPF_ST_ADD_I=1,
        SNPF_ST_ADD_U=2,
        SNPF_ST_ADD_S=3;
    */
       
    reg snpf_busy_action;
    localparam 
        SNPF_BUSY_IDEAL=0,
        SNPF_BUSY_SET=1;      
      
    reg[1:0] snpf_spv_action;
    //snpf actions
    localparam 
        SNPF_IDEAL = 0,
        SNPF_ADD_SRC=1,
        SNPF_REMOVE_SRC=2;
        
    reg [1: 0] snpf_syscache_action;
    localparam 
        SNPF_ADD_TO_SYSCACHE = 1,
        SNPF_REMOVE_SYSCACHE = 2;
            
    
    //txreq action
    reg [2:0] txreq_action;
    localparam
        TXREQ_IDEAL=0,
        TXREQ_DMT_ReadNoSnp=1,
        TXREQ_IDMT_ReadNoSnp=2,
        TXREQ_WriteNoSnpFull=3;
    
  
        
    reg [1:0] excl_action;
    localparam [1:0]
        EXL_ACTION_NORMAL_OK=2'b00,
        EXL_ACTION_EXL_OK=2'b01,
        EXL_ACTION_EXL_FAIL=2'b10; 
      
    
    
    //txsnp action
    reg[2:0]  txsnp_action;
    localparam
        TXSNP_IDEAL=0,
        TXSNP_SnpSharedFwd=1,
        TXSNP_SnpCleanInvalid=2,
        TXSNP_SnpUnique=3,
        TXSNP_SnpShared_RTOS=4,
        TXSNP_SnpShared=5,
        TXSNP_EVBUF_SnpCleanInvalid=6;

  
  
    //EXPCT_RSP action
    reg [2: 0] expct_rsp_action;
    localparam
        EXPCT_RSP_IDEAL=0,
        EXPCT_RSP_WAIT_FOR_RNS=1,
        EXPCT_RSP_WAIT_FOR_SN_REQUSETR_RN=2,
        EXPCT_RSP_RESET_WAIT_LIST=3,
        EXPCT_RSP_WAIT_FOR_EVBUF_SPV=4,      
        EXPCT_RSP_WAIT_FOR_RNS_REQUSETR_RN=5,
        EXPCT_RSP_WAIT_FOR_REQUSETR_RN=6;

    reg [2: 0 ] txrsp_action;
    localparam [2:0 ]
        TXRSP_IDEAL=0,
        TXRSP_COMP_UC=1,
        TXRSP_CompDBIDResp=2,
        TXRSP_COMP_EXC_FAIL=3,
        TXRSP_COMP_I=4;
        
        
     reg [1:0] undat_action;
     localparam [1:0]
            UNDAT_IDEAL=0,
            UNDAT_SAVE_CACHE_ON_LKPT=1,
            UNDAT_LCT_CompData_UC=2,
            UNDAT_LCT_CompData_SC=3;
  
      reg unsupported_opcode;
      
      
      //incase two continues read to the same address is asserted the snoop filter is not able to assert the busy bit. we need to detect this state and assert the hazard manually
  reg hazard_detect;   
  always @(posedge clk) begin
          if((next_req_addr [ADDR_REQ-1 : ADRR_OFFSETw] == addr [ADDR_REQ-1 : ADRR_OFFSETw]) & read_fifo_en & (snpf_busy_action==   SNPF_BUSY_SET)) hazard_detect<=1'b1;
          else hazard_detect<=1'b0;
  end
    
       reg [RSPTw-1 : 0] rsp_type; 
    
      always @(*)begin 
        re_try= 1'b0;
        add_credit=1'b0;
        action_type =    NO_TRANSFER;   
        rx_req_busy=0;
        read_fifo_en=1'b0;
        nst=pst;
        unsupported_opcode=1'b0;
        
        new_txnid_gen=1'b0; 
        snpf_spv_action = SNPF_IDEAL;
        snpf_syscache_action=SNPF_IDEAL;
     //   snpf_state_action = SNPF_ST_IDEAL;
        snpf_busy_action = SNPF_BUSY_IDEAL;  
        txreq_action = TXREQ_IDEAL;
        txsnp_action = TXSNP_IDEAL;
        expct_rsp_action = EXPCT_RSP_IDEAL;
        txrsp_action = TXRSP_IDEAL;
        rsp_type= RSP_TYPE_OPCODE_DAT_CompData;
        undat_action =   UNDAT_IDEAL;
      
        
        
        excl_action =  (excl_snoopme)?      EXL_ACTION_EXL_OK : EXL_ACTION_NORMAL_OK;
        
        rxreq_evbuf_rd_en=1'b0;
        got_data=1'b0;
        
        case(pst)
        IDEAL: begin 
            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)begin 
                read_fifo_en=1'b1;  
                nst=PROCESS_REQ;
                          
            end else if (evbuf_to_rxreq_valid ) begin 
                rxreq_evbuf_rd_en=1'b1;    
                nst=PROCESS_EVBUF;
                
            
            end
        end 
        PROCESS_EVBUF: begin
            if(txnid_gen_ready & txsnp_to_rxreq_ready & expct_rsp_to_rxreq_ready_wr) begin
                new_txnid_gen = 1'b1; 
                txsnp_action = TXSNP_EVBUF_SnpCleanInvalid;                
                rsp_type= RSP_TYPE_EVBUF_Evict;
                expct_rsp_action = EXPCT_RSP_WAIT_FOR_EVBUF_SPV;
                
                //this request is proceeds check for next
                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)begin nst=PROCESS_REQ; read_fifo_en=1'b1;          
                end  else nst=IDEAL;                
            end        
        end
        
        
        
        
        PROCESS_REQ: begin 
            rx_req_busy=1'b1;
            if(hazard_detect) begin
                action_type =    HAZARD_SAME_ADDR;
                re_try=1'b1;  
                
                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else                
                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
            end
            else begin
            
            case(opcode)
/************************************** ReadShared **********************************
 *  Read request to a Snoopable address region
 *  Data is included with the completion response.
 *  Data size is a cache line length.
 *  Requester will accept the data in any valid state: UC, UD, SC, or SD.
 *  Can have exclusive attribute asserted. Data cannot be obtained directly from the Slave Node using DMT if the Exclusive bit is set.
 *  
 *********************************************************************************************/           
            
            REQ_OPCODE_ReadShared:begin            
                //check snpf 
                //if(snpf_to_rxreq_rd_hit) begin 
                // data location is presented in snoop filter
/********
 *    REQ_OPCODE_ReadShared - CACHE_busy
 * ******/                
                    if(st_busy) begin 
                   
                        action_type =    HAZARD;
                        re_try=1'b1; 
                        
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                        
                        
                    end else begin ///endof if(st_busy) 
                    
                    case(snpf_cache_state)
/********
 *    REQ_OPCODE_ReadShared - SNPF_S
 * ******/
                    SNPF_S : begin             
                    //This data is in the shared state so donot need to send snoop req
                        if(shared_in_system_cache && current_cache_to_rxreq_rd_hit)begin 
                            //the cache has a valid copy. Send it to requester
                            //send compdata_S
                            if(txnid_gen_ready & undat_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr )begin   // send data flit fileds
                                action_type = LCT; //local cache transfer 
                                //exlusive readshared is always successful as our home node suport it. so no need to check excl result.
                               
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action =   SNPF_BUSY_SET; 
                                undat_action = UNDAT_LCT_CompData_SC;
                                
                                expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                                rsp_type= RSP_TYPE_OPCODE_DAT_CompData;
                                //this req is procceeded check for the next req
                                add_credit=1'b1;
                                
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                
                            end  /// if( txdat_to_rxreq_ready & ~txnid_table_empty)
                            //else do nothing just wait for txdat channel to be ready                           
                        end ///if(shared_in_system_cache && current_cache_to_rxreq_rd_hit)
                        else if( txnid_gen_ready & txsnp_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr) begin 
                             // Its not shared in system cache but other RNs have the valid copy of this cache line. 
                             // This data is shared but missd in cach use IDCT to get a copy of data and then send it to the requester
                             /*
                            if(likelyshared==1'b0 && excl_snoopme==1'b0) begin 
                                
                                action_type =  DCT; //direct cache transfer
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action =  SNPF_BUSY_SET;
                                txsnp_action = TXSNP_SnpSharedFwd;
                                expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS; //_REQUSETR_RN;
                                rsp_type= RSP_TYPE_SnpSharedFwd; 
                                //TODO SnpSharedFwd should only be sent to one RN  
                                //this req is procceeded check for the next req
                                add_credit=1'b1;
                                
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                               
                            end ///   if(likelyshared==1'b0)
                          
                            else begin 
                              */
                                //This data is likely to be shared. Ask the RN having the data to transfer it to this hnf first
                                 action_type =  IDCT; //In direct cache transfer
                                 new_txnid_gen = 1'b1; 
                                 snpf_busy_action = SNPF_BUSY_SET;
                                 txsnp_action = TXSNP_SnpShared_RTOS;
                                 expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS;
                                 rsp_type= RSP_TYPE_SnpShared;
                                 
                                 //this req is procceeded check for the next req
                                   add_credit=1'b1;
                                   
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else      
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                
                           // end /// else  if(likelyshared==1'b0)
                        end /// if(snpf_to_rxreq_rd_spv[SNPF_SPVw-2 : 0] )   
                    
                    
                    
                    end//SNPF_S
                   
/********
 *    REQ_OPCODE_ReadShared - CACHE_UC
 * ******/                    
                    SNPF_U: begin 
                    //This data is in the unique and clean or unique dirty  state. send snoop to RN having it to change it to share state
                     if(likelyshared==1'b0 && excl_snoopme==1'b0) begin             
                        
                        
                        
                        if(txnid_gen_ready & txsnp_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr & undat_to_rxreq_ready ) begin 
                            // Only one RN have the data in clean or dirty state.  Send  SnpSharedFwd to that RN
                                              
                            
                            action_type = DCT; 
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action = SNPF_BUSY_SET;
                            txsnp_action = TXSNP_SnpSharedFwd;
                            expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS_REQUSETR_RN;
                            rsp_type= RSP_TYPE_SnpSharedFwd;                            
                            if( shared_in_system_cache & current_cache_to_rxreq_rd_hit) begin //we cannot directly use the sys cache data as it may be dirty in the RN
                               got_data=1'b1; //save cache in lkpt. In case the DCT fail we can use the cache data instead of caching it from mem.
                               undat_action =    UNDAT_SAVE_CACHE_ON_LKPT;// save cache data in lkpy so incase we got responseI from DCT we can send the cached data
                            end
                            
                            
                            //this req is procceeded check for the next req
                            add_credit=1'b1;                            
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else     
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                            
                                           
                        end  //     txsnp_to_rxreq_ready                       
                     end else begin 
                        if( txnid_gen_ready & txsnp_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr & undat_to_rxreq_ready) begin 
                       
                           action_type =  IDCT; //In direct cache transfer
                           new_txnid_gen = 1'b1; 
                           snpf_busy_action = SNPF_BUSY_SET;
                           txsnp_action = TXSNP_SnpShared_RTOS;
                           expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS;
                           rsp_type= RSP_TYPE_SnpShared;
                          
                           if( shared_in_system_cache & current_cache_to_rxreq_rd_hit) begin //we cannot directly use the sys cache data as it may be dirty in the RN
                               got_data=1'b1; //save cache in lkpt. In case the IDCT fail we can use the cache data instead of caching it from mem.
                               undat_action =    UNDAT_SAVE_CACHE_ON_LKPT;// save cache data in lkpy so incase we got responseI from DCT we can send the cached data
                           end
                                 
                           //this req is procceeded check for the next req
                           add_credit=1'b1;
                                   
                           if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else      
                           if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                
                       end
                     
                     end
                    
                    end//SNPF_U
                    
/********
*    REQ_OPCODE_ReadShared - CACHE_I
* ******/
                    SNPF_I: begin // we need to update snpf with SNPF_I state as snpf_cache_state may be different with the one read from snpf
                    if(shared_in_system_cache & current_cache_to_rxreq_rd_hit)begin  
                    // this data is not shared in any RNs but exist in syscache. send it from syscache to RN
                        if(txnid_gen_ready & undat_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr )begin   // send data flit fileds
                                action_type = LCT; //local cache transfer 
                                 //exlusive readshared is always successful as our home node suport it. so no need to check excl result.
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action =   SNPF_BUSY_SET; 
                              //  snpf_state_action=        SNPF_ST_ADD_I;
                                undat_action =   UNDAT_LCT_CompData_UC;                                         
                                expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                                // if its exclusive load we need to send excl_ok response
                                rsp_type= RSP_TYPE_OPCODE_DAT_CompData;
                                //this req is procceeded check for the next req
                                add_credit=1'b1;
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                
                        end  /// if( txdat_to_rxreq_ready & ~txnid_table_empty) 
                      
                    end
                    // The requested data is not valid in any RNs or cache so ask it from SN
                    else if(likelyshared==1'b0 && excl_snoopme==1'b0) begin 
                        // This data is not likly to be shared and its not exclusive so use DMT to transfer data to requester
                       
                        if(txnid_gen_ready & txreq_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr)begin
                            action_type = DMT;  //   DIRECT_MEMORY_TRANSFER; 
                            new_txnid_gen = 1'b1; 
                         //   snpf_state_action=        SNPF_ST_ADD_I;
                            snpf_busy_action = SNPF_BUSY_SET;  
                            txreq_action = TXREQ_DMT_ReadNoSnp;
                            rsp_type= RSP_TYPE_ReadNoSnp;
                            expct_rsp_action = EXPCT_RSP_WAIT_FOR_REQUSETR_RN;//EXPCT_RSP_RESET_WAIT_LIST;
                            
                            //this req is procceeded check for the next req
                            add_credit=1'b1;
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                                                        
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end ///if(likelyshared==1'b0) begin 
                    else begin /// not likliy to be shared
                        //This data is likely to be shared. Ask the SN to transfer the data to this hnf first                        
                        if(txnid_gen_ready & txreq_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr)begin
                             action_type =  IDMT; //   INDIRECT_MEMORY_TRANSFER;
                             new_txnid_gen = 1'b1; 
                             snpf_busy_action =   SNPF_BUSY_SET; 
                        //     snpf_state_action=        SNPF_ST_ADD_I;
                             txreq_action=TXREQ_IDMT_ReadNoSnp;                            
                             rsp_type=  RSP_TYPE_ReadNoSnp;
                            
                            
                             expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                             
                             //this req is procceeded check for the next req
                             add_credit=1'b1;
                             if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                             if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                       
                           
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end /// else if(likelyshared==1'b0) begin 
                    end//SNPF_I
                   
                    
                    
                    
                    endcase                    
                end//st_busy
                /*
                end // snpf_to_rxreq_rd_hit
                else begin //snpf miss
                            
                
                
********
*    REQ_OPCODE_ReadShared - no hit
* *****                
                     //TODO The requested data is not shared in any RNs/system cache so ask it from SN
                    if(likelyshared==1'b0 && excl_snoopme==1'b0) begin 
                        //TODO This data is not likly to be shared and its not exclusive so use DMT to transfer data to requester
                       
                        if(txreq_to_rxreq_ready & ~txnid_table_empty & snpf_to_rxreq_wr_chnl_ready)begin
                            action_type =     DMT;//DIRECT_MEMORY_TRANSFER; 
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action =   SNPF_BUSY_SET;
                            txreq_action=TXREQ_DMT_ReadNoSnp;
                            add_credit=1'b1;
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                                                                      
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end ///if(likelyshared==1'b0) begin 
                    else begin /// not likliy to be shared
                        //TODO This data is likely to be shared. Ask the SN to transfer the data to this hnf first    
                        if(txreq_to_rxreq_ready & ~txnid_table_empty & snpf_to_rxreq_wr_chnl_ready)begin
                             action_type = IDMT;//INDIRECT_MEMORY_TRANSFER;
                             new_txnid_gen = 1'b1; 
                             snpf_busy_action = SNPF_BUSY_SET; 
                             txreq_action = TXREQ_IDMT_ReadNoSnp;
                             expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                              add_credit=1'b1;
                             if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                          
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end /// else if(likelyshared==1'b0) begin 
                end //snpf miss
   */                     
              end//ReadShared
         
             
             
             
             
 /******************************  ReadUnique ****************************************  
  * Read request to a Snoopable address region to carry out a store to the cache line. 
  * All other cached copies must be invalidated.
  * Data is included with the completion response.
  * Data size is a cache line length.
  * Data must be provided to the Requester in unique state only: UC, or UD.
  * ********************************************************************************************/
             
            REQ_OPCODE_ReadUnique: begin   
             
                //check snpf 
//                if(snpf_to_rxreq_rd_hit) begin 
                // data location is presented in snoop filter
/********
 *    REQ_OPCODE_ReadUnique - CACHE_busy
 * ******/                
                    if(st_busy) begin 
                   
                        action_type =    HAZARD;  
                        re_try=1'b1;
                        
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                        
                    end else begin ///endof if(st_busy) 
                    
                    case(snpf_cache_state)
/********
 *    REQ_OPCODE_ReadUnique - CACHE_SC, CACHE_UC
 * ******/
                    SNPF_S, SNPF_U: begin  
                    //Send snoop SnpUnique req to all shared RNs to invalidate all copies. 
                    // Data will be send by home node. The cache will be updated when the data is sent out
                        if(txnid_gen_ready & txsnp_to_rxreq_ready  & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr & undat_to_rxreq_ready) begin 
                        //      action_type = SEND_SnpUnique;
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action = SNPF_BUSY_SET;  
                                txsnp_action = TXSNP_SnpUnique;
                                rsp_type= RSP_TYPE_SnpUnique;
                                expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS;
                                
                                if( shared_in_system_cache & current_cache_to_rxreq_rd_hit) begin //we cannot directly use the sys cache data as it need to invalidate the other RN first
                                    got_data=1'b1; //save cache in lkpt. In case the DCT fail we can use the cache data instead of caching it from mem.
                                    undat_action =    UNDAT_SAVE_CACHE_ON_LKPT;// save cache data in lkpy so incase we got responseI from DCT we can send the cached data
                                end
                                
                                add_credit=1'b1;
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                        end// txsnp_to_rxreq_ready               
                    end// SNPF_S, SNPF_U                    
                    
/********
*    REQ_OPCODE_ReadUnique - CACHE_I
* ******/
                    SNPF_I: begin                      
                     if( shared_in_system_cache & current_cache_to_rxreq_rd_hit)begin  
                    // this data is not shared in any RNs but exist in syscache. send it from syscache to RN
                     if( txnid_gen_ready & undat_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr )begin   // send data flit fileds
                                action_type = LCT; //local cache transfer 
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action =   SNPF_BUSY_SET; 
                          //      snpf_state_action=        SNPF_ST_ADD_I;
                                undat_action = UNDAT_LCT_CompData_UC;
                                expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                                rsp_type= RSP_TYPE_OPCODE_DAT_CompData;
                                //exlusive readshared is always successful as our home node suport it. so no need to check excl result.
                                
                                
                                //this req is procceeded check for the next req
                                add_credit=1'b1;
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                
                        end  /// if( txdat_to_rxreq_ready & ~txnid_table_empty) 
                      
                    end
                    //The requested data is not valid in any RNs or cache so ask it from SN
                    else if(likelyshared==1'b0 && excl_snoopme==1'b0) begin 
                        // This data is not likly to be shared and its not exclusive so use DMT to transfer data to requester
                       
                        if(txnid_gen_ready & txreq_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr)begin
                            action_type = DMT;  //   DIRECT_MEMORY_TRANSFER; 
                            new_txnid_gen = 1'b1; 
                         //   snpf_state_action=        SNPF_ST_ADD_I;
                            snpf_busy_action = SNPF_BUSY_SET;
                            txreq_action = TXREQ_DMT_ReadNoSnp;
                            rsp_type= RSP_TYPE_ReadNoSnp;
                            expct_rsp_action =  EXPCT_RSP_WAIT_FOR_REQUSETR_RN;
                             
                            //this req is procceeded check for the next req
                            add_credit=1'b1;
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                                                        
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end ///if(likelyshared==1'b0) begin 
                    else begin /// not likly to be shared
                        // This data is likely to be shared. Ask the SN to transfer the data to this hnf first                        
                        if(txnid_gen_ready & txreq_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr)begin
                             action_type =  IDMT; //   INDIRECT_MEMORY_TRANSFER; 
                             new_txnid_gen = 1'b1; 
                             snpf_busy_action =   SNPF_BUSY_SET;
                           //  snpf_state_action=        SNPF_ST_ADD_I;
                             txreq_action=TXREQ_IDMT_ReadNoSnp;
                             rsp_type= RSP_TYPE_ReadNoSnp;
                             expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                             //this req is procceeded check for the next req
                             add_credit=1'b1;
                             if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                             if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                       
                           
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end /// else if(likelyshared==1'b0) begin 
                    end//SNPF_I
                    endcase                    
                end//st_busy
/*                end // snpf_to_rxreq_rd_hit
                else begin //snpf miss
********
*    REQ_OPCODE_ReadUnique - no hit
* ******                
                     //TODO The requested data is not shared in any RNs/system cache so ask it from SN
                    if(likelyshared==1'b0 && excl_snoopme==1'b0) begin 
                        //TODO This data is not likly to be shared and its not exclusive so use DMT to transfer data to requester
                       
                        if(txreq_to_rxreq_ready & ~txnid_table_empty & snpf_to_rxreq_wr_chnl_ready)begin
                            action_type =     DMT;//DIRECT_MEMORY_TRANSFER; 
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action =   SNPF_BUSY_SET; 
                            txreq_action=TXREQ_DMT_ReadNoSnp;
                            add_credit=1'b1;
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                                                                      
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end ///if(likelyshared==1'b0) begin 
                    else begin /// not likliy to be shared
                        //TODO This data is likely to be shared. Ask the SN to transfer the data to this hnf first    
                        if(txreq_to_rxreq_ready & ~txnid_table_empty & snpf_to_rxreq_wr_chnl_ready)begin
                             action_type = IDMT;//INDIRECT_MEMORY_TRANSFER;
                             new_txnid_gen = 1'b1; 
                             snpf_busy_action = SNPF_BUSY_SET;
                             txreq_action = TXREQ_IDMT_ReadNoSnp;
                             expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                             add_credit=1'b1;
                             if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                          
                        end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                    end /// else if(likelyshared==1'b0) begin 
                end //snpf miss
   */                 
                               
              end //  REQ_OPCODE_ReadUnique
              
              REQ_OPCODE_CleanUnique: begin 
/****************************************CleanUnique*******************************
 * Request to a Snoopable address region to change the state to Unique to carry out a store to the cache line.
 * Typical usage is when the Requester has a shared copy of the cache line and wants to obtain permission to store to the cache line.
 * Data is not included with the completion response.
 * Any dirty copy of the cache line at a snooped cache must be written back to the next level cache or memory.
 * Can have exclusive attribute asserted. 
 * Communicating node pairs: HN-F to ICN(HN-F). 
 * *******************************************************************************/
              
               //check snpf 
  //              if(snpf_to_rxreq_rd_hit) begin 
                // data location is presented in snoop filter
/********
 *    REQ_OPCODE_CleanUnique - CACHE_busy
 * ******/                
                    if(st_busy) begin 
                   
                        action_type =    HAZARD; 
                        re_try=1'b1;
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                    // if it is an exlusive cleanunique & it fails we need to send a Compresponse with Exlusive fail result.
                    //we dont send snoop req to other RNs in this case
                    end //endof if(st_busy) 
                    else if(excl_snoopme & ~excl_result) begin 
                        if(txnid_gen_ready & snpf_to_rxreq_wr_chnl_ready & txrsp_to_rxreq_ready & expct_rsp_to_rxreq_ready_wr )begin
                                        
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action = SNPF_BUSY_SET;  //TODO need to check if we need to set this line busy for response
                            //txrsp_action = TXRSP_COMP_UC;
                            txrsp_action = TXRSP_COMP_UC;
                            excl_action=   EXL_ACTION_EXL_FAIL;
                            
                            expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                            rsp_type= RSP_TYPE_Comp;//TODO need to check if we need to wait for response
                            add_credit=1'b1;
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;  
                        end
                    end
                    
                    
                    
                    else begin 
                    
                    case(snpf_cache_state)
/********
 *    REQ_OPCODE_CleanUnique - CACHE_SC, CACHE_UC
 * ******/
                    SNPF_S, SNPF_U: begin  
                    // Send snoop SnpCleanInvalid request to all shared RNs to invalidate all copies. 
                        if(txnid_gen_ready & txsnp_to_rxreq_ready  &  snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr) begin 
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action = SNPF_BUSY_SET;  
                            txsnp_action = TXSNP_SnpCleanInvalid;
                            
                            rsp_type= RSP_TYPE_SnpCleanInvalid;
                            expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS;
                            add_credit=1'b1;
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                        end// txsnp_to_rxreq_ready 
                    
               
                    end// CACHE_SC, CACHE_UC                    
                    
/********
*    REQ_OPCODE_CleanUnique - CACHE_I
* ******/
                    SNPF_I: begin     //This data is not shared anyware sends rsp_comp_uc to requester                 
                        if(txnid_gen_ready & txsnp_to_rxreq_ready & txrsp_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr) begin 
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action = SNPF_BUSY_SET;  
                     //       snpf_state_action=        SNPF_ST_ADD_I;
                            txrsp_action = TXRSP_COMP_UC;
                            expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                            rsp_type= RSP_TYPE_Comp;
                            add_credit=1'b1;
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                        end
                    end//CACHE_I
                    endcase                    
                end//st_busy
 /*            end // snpf_to_rxreq_rd_hit
                 else begin //snpf miss
********
*    REQ_OPCODE_CleanUnique - no hit
* ******              
                     if(txsnp_to_rxreq_ready & txrsp_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready ) begin 
                            new_txnid_gen = 1'b1; 
                            snpf_busy_action = SNPF_BUSY_SET;  
                            txrsp_action = TXRSP_COMP_UC;
                            add_credit=1'b1;
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                     end

                     
                end //snpf miss
    */             
              end // REQ_OPCODE_CleanUnique
              
              REQ_OPCODE_WriteBackFull: begin 
              // optimized solution 
              //sends CompDBIDResp to requester
              //send WriteNoSnp to SN
              // Do not need to check snoop filter
                if(st_busy) begin 
                
                        action_type =    HAZARD;  
                        re_try=1'b1;
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL; 
                        
                end else begin ///endof if(st_busy) 
                
                
                    if(txnid_gen_ready & txreq_to_rxreq_ready & txrsp_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr ) begin 
                      
                        new_txnid_gen = 1'b1; 
                        snpf_busy_action = SNPF_BUSY_SET;  
                        txrsp_action = TXRSP_CompDBIDResp;
                        txreq_action = TXREQ_WriteNoSnpFull;
                        expct_rsp_action = EXPCT_RSP_WAIT_FOR_SN_REQUSETR_RN;
                        rsp_type= RSP_TYPE_WriteBackFull;
                        add_credit=1'b1;
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                    end
                end
              
              end  
                       
              
/*******************************ReadNoSnp***********************
 * Read request to a Non-snoopable address region
 * Data is included with the completion response.
 * Data size is up to a cache line length, based on size attribute value in the request,
 * Data will not be cached at the Requester in a system coherent manner.
 * Can have exclusive attribute asserted. 
 * Permitted to use DMT if ExpCompAck is asserted
**************************************************************/
              
                REQ_OPCODE_ReadNoSnp: begin 
                      if(st_busy) begin 
                        action_type =    HAZARD;  
                        re_try=1'b1;
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL; 
                        
                    end else begin ///endof if(st_busy) 
                    
                        if(likelyshared==1'b0 && excl_snoopme==1'b0) begin 
                            // This data is not likly to be shared and its not exclusive so use DMT to transfer data to requester
                            if(txnid_gen_ready & txreq_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr)begin
                                action_type = DMT;  //   DIRECT_MEMORY_TRANSFER; 
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action = SNPF_BUSY_SET; 
                          //      snpf_state_action=        SNPF_ST_ADD_I;
                                txreq_action = TXREQ_DMT_ReadNoSnp;
                                rsp_type= RSP_TYPE_ReadNoSnp_NoSnpf;
                                expct_rsp_action =  EXPCT_RSP_WAIT_FOR_REQUSETR_RN;
                                 
                                //this req is procceeded check for the next req
                                add_credit=1'b1;
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                                                            
                            end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                                
                        end else begin              
                    
                            if(txnid_gen_ready & txreq_to_rxreq_ready & snpf_to_rxreq_wr_chnl_ready & expct_rsp_to_rxreq_ready_wr)begin
                                 action_type =  IDMT; //   INDIRECT_MEMORY_TRANSFER; 
                                 new_txnid_gen = 1'b1; 
                                 snpf_busy_action =   SNPF_BUSY_SET;
                              //   snpf_state_action=        SNPF_ST_ADD_I;
                                 txreq_action=TXREQ_IDMT_ReadNoSnp;
                                 rsp_type= RSP_TYPE_ReadNoSnp_NoSnpf;
                                 expct_rsp_action = EXPCT_RSP_RESET_WAIT_LIST;
                                 //this req is procceeded check for the next req
                                 add_credit=1'b1;
                                 if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                 if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                       
                               
                            end///if(txreq_to_rxreq_ready & ~txnid_table_empty)
                                  
                        end   
                    end// else
              end //REQ_OPCODE_ReadNoSnp
              
/*******************************AtomicLoad/SWAP***********************
 * Sends a single data value with an address and the atomic operation to be performed.
 * The target, an HN performs the required operation on the address location specified with the data value supplied in the Atomic transaction.
 * AtomicStore: The target returns a completion response without data.
 * AtomicLoad/SWAP: The target returns the completion response with data. The data value is the original value at the addressed location.
 * Data will not be cached at the Requester.
 * Outbound data size is 1, 2, 4, or 8 byte.
 * Only appropriate byte enables must be asserted.
 * Inbound data size is the same as the outbound data size.
**************************************************************/
                REQ_OPCODE_AtomicStore_ADD , //28
                REQ_OPCODE_AtomicStore_CLR , //29
                REQ_OPCODE_AtomicStore_EOR , //2A
                REQ_OPCODE_AtomicStore_SET , //2B
                REQ_OPCODE_AtomicStore_SMAX, //2C
                REQ_OPCODE_AtomicStore_SMIN, //2D
                REQ_OPCODE_AtomicStore_UMAX, //2E 
                REQ_OPCODE_AtomicStore_UMIN, //2F
                
                
                REQ_OPCODE_AtomicLoad_ADD,
                REQ_OPCODE_AtomicLoad_CLR,
                REQ_OPCODE_AtomicLoad_EOR,  
                REQ_OPCODE_AtomicLoad_SET,   
                REQ_OPCODE_AtomicLoad_SMAX,  
                REQ_OPCODE_AtomicLoad_SMIN, 
                REQ_OPCODE_AtomicLoad_UMAX, 
                REQ_OPCODE_AtomicLoad_UMIN,  
                REQ_OPCODE_AtomicSwap
                //,  REQ_OPCODE_AtomicCompare  //TODO support atomic compare
                : begin 
                
                    rsp_type=  opcode[5:0];
                
                    if(st_busy) begin 
                        action_type =    HAZARD;  
                        re_try=1'b1;
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL; 
                        
                    end else begin 
                        //We need to read the old data and it may be read from one of other RN, syscache or main mem  
                        case(snpf_cache_state)
                        SNPF_S, SNPF_U: begin  //transaction are similar to ReadUnique
                        //Send snoop SnpUnique req to all shared RNs to invalidate all copies.                 
                    
                            if(txnid_gen_ready & snpf_to_rxreq_wr_chnl_ready & txrsp_to_rxreq_ready & txsnp_to_rxreq_ready & expct_rsp_to_rxreq_ready_wr )begin
                                action_type =    ATOMIC_RN;
                                new_txnid_gen = 1'b1; 
                                snpf_busy_action = SNPF_BUSY_SET;  
                                txrsp_action = TXRSP_CompDBIDResp;
                                txsnp_action = TXSNP_SnpUnique; 
                                expct_rsp_action = EXPCT_RSP_WAIT_FOR_RNS_REQUSETR_RN;  
                               
                        
                                
                                add_credit=1'b1;
                               
                                if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                             end
                        end//SNPF_S, SNPF_U
                        SNPF_I: begin     //This data is not shared anyware, take the data value from sys-cache or main mem
                            if( shared_in_system_cache & current_cache_to_rxreq_rd_hit)begin  
                            // send old data from cache, update data_table. 
                                if(txnid_gen_ready & snpf_to_rxreq_wr_chnl_ready & txreq_to_rxreq_ready & expct_rsp_to_rxreq_ready_wr & txrsp_to_rxreq_ready  & undat_to_rxreq_ready)begin
                                    action_type =  ATOMIC_CAHCE;  
                                    undat_action =    UNDAT_SAVE_CACHE_ON_LKPT;
                                    new_txnid_gen = 1'b1; 
                                    snpf_busy_action = SNPF_BUSY_SET;  
                                    txrsp_action = TXRSP_CompDBIDResp;
                                   // txreq_action = TXREQ_WriteNoSnpFull;
                                    expct_rsp_action =  EXPCT_RSP_RESET_WAIT_LIST;//EXPCT_RSP_WAIT_FOR_SN_REQUSETR_RN;                                    
                                    add_credit=1'b1;
                                    if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                    if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                end
                            
                            end else begin //read data from main memory
                                 if(txnid_gen_ready & snpf_to_rxreq_wr_chnl_ready & txreq_to_rxreq_ready & expct_rsp_to_rxreq_ready_wr & txrsp_to_rxreq_ready )begin 
                                    action_type =  ATOMIC_MEM;  
                                    new_txnid_gen = 1'b1; 
                                    snpf_busy_action =   SNPF_BUSY_SET;
                               //     snpf_state_action=        SNPF_ST_ADD_I;
                                    txreq_action=TXREQ_IDMT_ReadNoSnp;
                                    txrsp_action = TXRSP_CompDBIDResp;
                                    expct_rsp_action = EXPCT_RSP_WAIT_FOR_SN_REQUSETR_RN;                                    
                                    
                                    
                                    
                                    add_credit=1'b1;
                                    if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                                    if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                                end
                            end
                        end//SNPF_I    
                        endcase
                
                
                
                     
                    end//else
                end//AtomicLoad/SWAP/Store
/************* Evict**************
 * Used to indicate that a Clean cache line is no longer cached by an RN.•
 * Data is not sent for this transaction.
 ******************************/
                REQ_OPCODE_Evict : begin 
                     if(st_busy) begin 
                        action_type =    HAZARD;  
                        re_try=1'b1;
                        if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                        if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL; 
                        
                    end else begin 
                        if(snpf_to_rxreq_wr_chnl_ready & txrsp_to_rxreq_ready)begin
 
                            txrsp_action =      TXRSP_COMP_I;
                            snpf_spv_action =   SNPF_REMOVE_SRC;
                            add_credit=1'b1;                           
                            if (evbuf_to_rxreq_valid ) begin rxreq_evbuf_rd_en=1'b1;  nst=PROCESS_EVBUF; end else   
                            if(~flit_fifo_empty & ~snpf_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;
                        end
                
                
                    end
                end//REQ_OPCODE_Evict
                    
                default begin //unsupported request 
                   unsupported_opcode=1'b1;
                 
              end
              endcase
              end//hazard detect
        end
        endcase//case        
      end//always
     
       //new snpf default is current snpf 
       
       
     reg [1: 0] wr_spv_action, wr_busy_bit_action, wr_sys_cache_action;  
     assign rxreq_to_snpf_action = {wr_sys_cache_action,wr_busy_bit_action,wr_spv_action};   
        
            
            
      //snpf
    always @(*)begin 
        rxreq_to_snpf_update_state = 1'b0; 
        wr_spv_action =SNPF_REPLACE;
        wr_sys_cache_action = SNPF_REPLACE;
        wr_busy_bit_action =SNPF_NO_CHANGE;
       
 
        rxreq_to_snpf_wr_spv = snpf_to_rxreq_rd_spv;//If the cache evict or invalid is detected the spv rd becomes zero. we replace it once writiing busy bit
     //   rxreq_to_snpf_wr_state= snpf_to_rxreq_rd_state; 
        rxreq_to_snpf_wr_addr= addr; //current requset address        
        rxreq_to_snpf_wr_en= 1'b0;
        rxreq_to_snpf_wr_evict=1'b0;       
         
               
        case(snpf_spv_action)
        SNPF_ADD_SRC:begin 
            rxreq_to_snpf_wr_spv = {1'b0,srcid_spv[SNPF_SPVw-2: 0]};
            wr_spv_action =SNPF_ASSERT; // add RN to SPV  SNPF_NO_CHANGE
            rxreq_to_snpf_wr_en= 1'b1;
        end
        SNPF_REMOVE_SRC: begin
            rxreq_to_snpf_wr_spv = {1'b0,srcid_spv[SNPF_SPVw-2: 0]};
            wr_spv_action =SNPF_CLEAR; // remove RN from SPV
            rxreq_to_snpf_wr_en= 1'b1;
        end       
        endcase
        /*
        case(snpf_syscache_action)
        SNPF_ADD_TO_SYSCACHE: begin
            wr_sys_cache_action=SNPF_ASSERT;  
            rxreq_to_snpf_wr_en= 1'b1;    
        end
        SNPF_REMOVE_SYSCACHE: begin
            wr_sys_cache_action=SNPF_CLEAR;  
            rxreq_to_snpf_wr_en= 1'b1;    
        end
        endcase
        */
        case(snpf_busy_action)
        SNPF_BUSY_SET: begin
            wr_busy_bit_action=SNPF_ASSERT;        
            rxreq_to_snpf_wr_en= 1'b1;    
        end
        endcase
        
        /*
        case(snpf_state_action)        
        SNPF_ST_ADD_I: begin
            rxreq_to_snpf_wr_state  = SNPF_I;
            rxreq_to_snpf_update_state=1'b1;
            rxreq_to_snpf_wr_en= 1'b1;       
        end                
        SNPF_ST_ADD_U: begin
            rxreq_to_snpf_wr_state  = SNPF_U;
            rxreq_to_snpf_update_state=1'b1;
            rxreq_to_snpf_wr_en= 1'b1;       
        end
        SNPF_ST_ADD_S: begin
            rxreq_to_snpf_wr_state  = SNPF_S;
            rxreq_to_snpf_update_state=1'b1;
            rxreq_to_snpf_wr_en= 1'b1;         
        end        
        endcase
        */
        
       
    end
      
      
    //txreq
    always @(*)begin 
         //default for readnosnoop DMT from SN
        rxreq_to_txreq_wr = 1'b0;  
        rxreq_to_txreq_opcode = REQ_OPCODE_ReadNoSnp;
        rxreq_to_txreq_tgtid = snf_id [TGTID_REQ-1  : 0];
        rxreq_to_txreq_txnid = new_txnid;
        // return data directoly to the requester node        
        rxreq_to_txreq_returnnid = srcid;
        rxreq_to_txreq_returntxnid = txnid;
        rxreq_to_txreq_addr = addr;
        rxreq_to_txreq_likelyshared = likelyshared;
        case(txreq_action)
        TXREQ_DMT_ReadNoSnp:begin
            rxreq_to_txreq_wr = 1'b1; 
        end
        TXREQ_IDMT_ReadNoSnp:begin
            rxreq_to_txreq_returnnid = src_id; //send data to hnf first
            rxreq_to_txreq_returntxnid  =  new_txnid; // as data will be sent to home node it suposed to be sent by the same transaction id it sent to SN;
            rxreq_to_txreq_wr = 1'b1;   //generate a new req 
        end
        TXREQ_WriteNoSnpFull: begin 
            rxreq_to_txreq_opcode = REQ_OPCODE_WriteNoSnpFull;            
            rxreq_to_txreq_wr = 1'b1;
        end
        endcase
    end//always        
      
      
      
      
     
   
    
    
    always @(*) begin
         rxreq_to_undat_resperr=Normal_Okay;
         if(excl_action == EXL_ACTION_EXL_OK) rxreq_to_undat_resperr= Excl_Okey;
         if(excl_action == EXL_ACTION_EXL_FAIL) rxreq_to_undat_resperr= Excl_Failed;
    end
    
    
    
    
    //txsnp 
    always@(*)begin
        rxreq_to_txsnp_we = 1'b0;
        // snoop default for  ReadShared_SnpSharedFwd       
        rxreq_to_txsnp_rettosrc=1'b1;  // we can save the return data in home cache 
        rxreq_to_txsnp_spv = {1'b0,shared_in_other_rns} ;
        rxreq_to_txsnp_txnid = new_txnid;
        rxreq_to_txsnp_fwdnid = srcid;
        rxreq_to_txsnp_fwdtxnid = txnid;
        rxreq_to_txsnp_opcode = SNP_OPCODE_SnpSharedFwd;
        rxreq_to_txsnp_addr = addr;       
       
        case(txsnp_action)
        TXSNP_SnpSharedFwd: begin 
            rxreq_to_txsnp_we = 1'b1;
        end
        TXSNP_SnpCleanInvalid: begin
            rxreq_to_txsnp_opcode = SNP_OPCODE_SnpCleanInvalid;
            rxreq_to_txsnp_rettosrc=1'b0;  
            rxreq_to_txsnp_txnid = new_txnid;
            rxreq_to_txsnp_we = 1'b1;           
        end
        TXSNP_SnpUnique: begin
            rxreq_to_txsnp_opcode = SNP_OPCODE_SnpUnique;
            rxreq_to_txsnp_rettosrc=1'b1;  
            rxreq_to_txsnp_txnid = new_txnid;
            rxreq_to_txsnp_we = 1'b1;         
        end
        
        TXSNP_SnpShared_RTOS: begin 
            rxreq_to_txsnp_opcode = SNP_OPCODE_SnpShared;
            rxreq_to_txsnp_rettosrc=1'b1; 
            rxreq_to_txsnp_txnid = new_txnid;
            rxreq_to_txsnp_we = 1'b1;         
        end
        TXSNP_SnpShared: begin
            rxreq_to_txsnp_opcode = SNP_OPCODE_SnpShared;
            rxreq_to_txsnp_rettosrc=1'b0;  
            rxreq_to_txsnp_txnid = new_txnid;
            rxreq_to_txsnp_we = 1'b1;      
        end
        TXSNP_EVBUF_SnpCleanInvalid:begin
            rxreq_to_txsnp_opcode = SNP_OPCODE_SnpCleanInvalid;
            rxreq_to_txsnp_rettosrc=1'b0;  
            rxreq_to_txsnp_spv ={1'b0,evbuf_to_rxreq_dat[SNPF_SPVw-2: 0]};
            rxreq_to_txsnp_txnid = new_txnid;
            rxreq_to_txsnp_we = 1'b1;
            rxreq_to_txsnp_addr=evbuf_to_rxreq_addr;
        end
        
        endcase
    end        
        
       
     
    //EXPCT_RSP action
    always @(*)begin 
        rxreq_to_expct_rsp_valid_wr=1'b0;
        rxreq_to_expct_rsp_dat_wr= {EXPCT_RSP_Dw{1'b0}};// Reset entire wait list
       
        case(expct_rsp_action)
      /*  
        
         EXPCT_RSP_RESET_WAIT_LIST_RNS : begin
            rxreq_to_expct_rsp_dat_wr = {2'b01,shared_in_other_rns[SNPF_SPVw-2: 0]} ;
            rxreq_to_expct_rsp_valid_wr=1'b1;
        end
        
        EXPCT_RSP_RESET_WAIT_LIST : begin 
            rxreq_to_expct_rsp_dat_wr = 0;//{2'b0,srcid_spv[SNPF_SPVw-2: 0]} ;
            rxreq_to_expct_rsp_valid_wr=1'b1;
        end
        */
        EXPCT_RSP_WAIT_FOR_RNS_REQUSETR_RN:begin 
             rxreq_to_expct_rsp_dat_wr = {got_data,1'b0,shared_in_other_rns[SNPF_SPVw-2: 0]} | {2'b00,srcid_spv[SNPF_SPVw-2: 0]};
             rxreq_to_expct_rsp_valid_wr=1'b1;
        
        end        
       
        
        EXPCT_RSP_RESET_WAIT_LIST : begin
                                 
            rxreq_to_expct_rsp_valid_wr=1'b1;  
        end
        
        
        EXPCT_RSP_WAIT_FOR_RNS : begin
            rxreq_to_expct_rsp_dat_wr = {got_data,1'b0,shared_in_other_rns[SNPF_SPVw-2: 0]} ;
            rxreq_to_expct_rsp_valid_wr=1'b1;
        end
       
        
        
        EXPCT_RSP_WAIT_FOR_SN_REQUSETR_RN : begin 
            rxreq_to_expct_rsp_dat_wr = {2'b01,srcid_spv[SNPF_SPVw-2: 0]} ;
            rxreq_to_expct_rsp_valid_wr=1'b1;
        end
        
        EXPCT_RSP_WAIT_FOR_EVBUF_SPV : begin 
            rxreq_to_expct_rsp_dat_wr = {2'b00,evbuf_to_rxreq_dat[SNPF_SPVw-2: 0]};
            rxreq_to_expct_rsp_valid_wr=1'b1;
        end
        
        EXPCT_RSP_WAIT_FOR_REQUSETR_RN : begin 
            rxreq_to_expct_rsp_dat_wr = {2'b00,srcid_spv[SNPF_SPVw-2: 0]} ;
            rxreq_to_expct_rsp_valid_wr=1'b1;
        end
        
        
        endcase
    end //always
        
    
        
    always @(*) begin
        rxreq_to_txrsp_wr_en=1'b0;
        //deafult for COMP_UC
        rxreq_to_txrsp_txnid= txnid;
        rxreq_to_txrsp_tgtid= srcid;
        rxreq_to_txrsp_opcode= RSP_OPCODE_Comp;
        rxreq_to_txrsp_resp= 3'b010; //resp for Comp_UC        
        rxreq_txsnp_dbid=new_txnid;
    
        case(txrsp_action)
            TXRSP_COMP_UC: begin
                rxreq_to_txrsp_wr_en=1'b1;
            end
            TXRSP_CompDBIDResp: begin
                rxreq_to_txrsp_opcode= RSP_OPCODE_CompDBIDResp;
                rxreq_to_txrsp_resp= 3'b000; //resp for Comp_UC
                rxreq_to_txrsp_wr_en=1'b1;
            end
            TXRSP_COMP_I: begin 
                rxreq_to_txrsp_resp= 3'b000; //resp for Comp_I  
                rxreq_to_txrsp_wr_en=1'b1;
            end
            
        endcase
    end     
        
     always @(*) begin
         rxreq_to_txrsp_resperr= Normal_Okay;
         if(excl_action == EXL_ACTION_EXL_OK) rxreq_to_txrsp_resperr= Excl_Okey;
         if(excl_action == EXL_ACTION_EXL_FAIL) rxreq_to_txrsp_resperr= Excl_Failed;
    end    
                
    //txrsp
    wire rsperr_flag =  (excl_snoopme & excl_result)? 1'b1 :1'b0;
    wire  [ADDR_REQ-1:0] lkpt_addr = (pst == PROCESS_EVBUF)? evbuf_to_rxreq_addr : addr;   
    assign txreq_to_rxrsplkpt_txndat = {rsperr_flag,rsp_type,//   rxreq_to_snpf_wr_state[CACHE_STATUSw-1:0],
    srcid, lkpt_addr ,txnid};// save the addr and txnid so after reciving the data we can update the chache and send back data to RN    
    assign txreq_to_rxrsplkpt_valid =  new_txnid_gen; 
    

    // undat 
    //{undat_core_action,undat_alu_action};   
   
    always @(*) begin
        rxreq_to_undat_wr=1'b0; 
        rxreq_to_undat_cache_evict=1'b0;
        rxreq_to_undat_action ={CURRENT_IS_INIT,SAVE_ALU_TX_OFF,ALU_BPASS}; // pass cache dat and write it on lkptdat 
        rxreq_to_undat_dat = current_cache_to_rxreq_rd_data;
        rxreq_to_undat_opcode = OPCODE_DAT_CompData;
        rxreq_to_undat_resp =   CompData_UC;
        rxreq_to_undat_tgtid = srcid;
        rxreq_to_undat_txnid = new_txnid;
        rxreq_to_undat_addr=addr;
        rxreq_to_undat_dbid = new_txnid;
        case (undat_action )
        UNDAT_SAVE_CACHE_ON_LKPT: begin
          //  if( current_cache_to_rxreq_rd_hit)begin
                rxreq_to_undat_wr=1'b1; 
              //  rxreq_to_undat_cache_evict=1'b1;//the cache will be updated at the end of this transaction. so lets invalidate it now inrrder to avoid racing condition
           // end
        end
        UNDAT_LCT_CompData_UC: begin
            rxreq_to_undat_action ={CURRENT_IS_INIT,SAVE_ALU_TX_DIN,ALU_BPASS};
            rxreq_to_undat_txnid = txnid; 
            rxreq_to_undat_wr=1'b1; 
            
        end//TXDAT_LCT_CompData_UC
        UNDAT_LCT_CompData_SC: begin
            rxreq_to_undat_action ={CURRENT_IS_INIT,SAVE_ALU_TX_DIN,ALU_BPASS};
            rxreq_to_undat_txnid = txnid;
            rxreq_to_undat_resp =   CompData_SC;             
            rxreq_to_undat_wr=1'b1; 
              
            
        end//TXDAT_LCT_CompData_UC        
        
        endcase
   end     
   
  
  
   
   
   


     always @(posedge clk) begin
        if(reset) begin          
           // chi_noc_rxreqlcrdv<=1'b0;
            pst <= IDEAL;
        end  else begin 
           // chi_noc_rxreqlcrdv<=add_credit;
            pst<=nst;
        end
    end


     //synthesis translate_off 
    //synopsys  translate_off
    
     wire [15 : 0] st_str = 
        (snpf_cache_state == SNPF_I )? " I" : 
        (snpf_cache_state == SNPF_U )? " U" : 
        (snpf_cache_state == SNPF_S )? " S" : " X";
    
    reg [159 : 0] opcode_str;
    always @(*)begin 
        opcode_str = "Undefined          ";
        case(opcode)                            
        REQ_OPCODE_ReqLCrdReturn         :       opcode_str =       "ReqLCrdReturn       ";
        REQ_OPCODE_ReadShared            :       opcode_str =       "ReadShared          ";
        REQ_OPCODE_ReadClean             :       opcode_str =       "ReadClean           ";
        REQ_OPCODE_ReadOnce              :       opcode_str =       "ReadOnce            ";
        REQ_OPCODE_ReadNoSnp             :       opcode_str =       "ReadNoSnp           ";
        REQ_OPCODE_PCrdReturn            :       opcode_str =       "PCrdReturn          ";
        REQ_OPCODE_Reserved              :       opcode_str =       "Reserved            ";
        REQ_OPCODE_ReadUnique            :       opcode_str =       "ReadUnique          ";
        REQ_OPCODE_CleanShared           :       opcode_str =       "CleanShared         ";
        REQ_OPCODE_CleanInvalid          :       opcode_str =       "CleanInvalid        ";
        REQ_OPCODE_MakeInvalid           :       opcode_str =       "MakeInvalid         ";
        REQ_OPCODE_CleanUnique           :       opcode_str =       "CleanUnique         ";
        REQ_OPCODE_MakeUnique            :       opcode_str =       "MakeUnique          ";
        REQ_OPCODE_Evict                 :       opcode_str =       "Evict               ";
        REQ_OPCODE_DVMOp                 :       opcode_str =       "DVMOp               ";
        REQ_OPCODE_WriteEvictFull        :       opcode_str =       "WriteEvictFull      ";
        REQ_OPCODE_WriteCleanFull        :       opcode_str =       "WriteCleanFull      ";
        REQ_OPCODE_WriteUniquePtl        :       opcode_str =       "WriteUniquePtl      ";
        REQ_OPCODE_WriteUniqueFull       :       opcode_str =       "WriteUniqueFull     ";     
        REQ_OPCODE_WriteBackPtl          :       opcode_str =       "WriteBackPtl        ";
        REQ_OPCODE_WriteBackFull         :       opcode_str =       "WriteBackFull       ";
        REQ_OPCODE_WriteNoSnpPtl         :       opcode_str =       "WriteNoSnpPtl       ";
        REQ_OPCODE_WriteNoSnpFull        :       opcode_str =       "WriteNoSnpFull      ";
        REQ_OPCODE_WriteUniqueFullStash  :       opcode_str =       "WriteUniqueFullStash";     
        REQ_OPCODE_WriteUniquePtlStash   :       opcode_str =       "WriteUniquePtlStash ";     
        REQ_OPCODE_StashOnceShared       :       opcode_str =       "StashOnceShared     ";     
        REQ_OPCODE_StashOnceUnique       :       opcode_str =       "StashOnceUnique     ";     
        REQ_OPCODE_ReadOnceCleanInvalid  :       opcode_str =       "ReadOnceCleanInvalid";     
        REQ_OPCODE_ReadOnceMakeInvalid   :       opcode_str =       "ReadOnceMakeInvalid ";     
        REQ_OPCODE_ReadNotSharedDirty    :       opcode_str =       "ReadNotSharedDirty  ";     
        REQ_OPCODE_CleanSharedPersist    :       opcode_str =       "CleanSharedPersist  ";     
        REQ_OPCODE_PrefetchTgt           :       opcode_str =       "PrefetchTgt         ";
            
        REQ_OPCODE_AtomicStore_ADD       :       opcode_str =      "AtomicStore_ADD     ";
        REQ_OPCODE_AtomicStore_CLR       :       opcode_str =      "AtomicStore_CLR     "; 
        REQ_OPCODE_AtomicStore_EOR       :       opcode_str =      "AtomicStore_EOR     "; 
        REQ_OPCODE_AtomicStore_SET       :       opcode_str =      "AtomicStore_SET     "; 
        REQ_OPCODE_AtomicStore_SMAX      :       opcode_str =      "AtomicStore_SMAX    "; 
        REQ_OPCODE_AtomicStore_SMIN      :       opcode_str =      "AtomicStore_SMIN    "; 
        REQ_OPCODE_AtomicStore_UMAX      :       opcode_str =      "AtomicStore_UMAX    "; 
        REQ_OPCODE_AtomicStore_UMIN      :       opcode_str =      "AtomicStore_UMIN    "; 

        REQ_OPCODE_AtomicLoad_ADD        :       opcode_str =      "AtomicLoad_ADD      "; 
        REQ_OPCODE_AtomicLoad_CLR        :       opcode_str =      "AtomicLoad_CLR      "; 
        REQ_OPCODE_AtomicLoad_EOR        :       opcode_str =      "AtomicLoad_EOR      "; 
        REQ_OPCODE_AtomicLoad_SET        :       opcode_str =      "AtomicLoad_SET      "; 
        REQ_OPCODE_AtomicLoad_SMAX       :       opcode_str =      "AtomicLoad_SMAX     "; 
        REQ_OPCODE_AtomicLoad_SMIN       :       opcode_str =      "AtomicLoad_SMIN     "; 
        REQ_OPCODE_AtomicLoad_UMAX       :       opcode_str =      "AtomicLoad_UMAX     "; 
        REQ_OPCODE_AtomicLoad_UMIN       :       opcode_str =      "AtomicLoad_UMIN     "; 
        REQ_OPCODE_AtomicSwap            :       opcode_str =      "AtomicSwap          "; 
        REQ_OPCODE_AtomicCompare         :       opcode_str =      "AtomicCompare       "; 
                                                                                         
           
        endcase
   end     

  

    
    
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_REQ_TYPE) > 0) begin
            if(new_txnid_gen & (pst==PROCESS_REQ))begin 
                $display("%t: hnf ( %d ) txn ( %d ) a new %s req from core ( %d ) is accepted on addr ( %d ) dbid ( %d ) snpf_rdhit ( %d ) snpf_status %s   spv ( %b ) ",$time,src_id, txnid,opcode_str,srcid, 
            addr, new_txnid,  snpf_to_rxreq_rd_hit,st_str,snpf_to_rxreq_rd_spv);
             if(excl_transaction) $display("%t: hnf ( %d ) got an exclusive transaction",$time,src_id);
             
             end
             
              if(new_txnid_gen & (pst==PROCESS_EVBUF))begin 
                $display("%t: hnf ( %d ) txn ( %d ) an eviction buffer is accepted on addr ( %d )  spv ( %b ) ",$time,src_id, new_txnid,
            lkpt_addr, evbuf_to_rxreq_dat);
             end
             
             
        end
        if((VERBOSITY & MONITORE_TXN_CMD) > 0)begin
            //txsnp
            case(txsnp_action)
                TXSNP_SnpSharedFwd: $display("%t: hnf ( %d ) txn ( %d ) sends SnpSharedFwd" ,$time,src_id,new_txnid);
                TXSNP_SnpCleanInvalid: $display("%t: hnf ( %d ) txn ( %d ) sends SnpCleanInvalid" ,$time,src_id, new_txnid);
                TXSNP_SnpUnique: $display("%t: hnf ( %d ) txn ( %d ) sends SnpUnique" ,$time,src_id,new_txnid);
                TXSNP_SnpShared_RTOS:$display("%t: hnf ( %d ) txn ( %d ) sends SnpShared_RTOS" ,$time,src_id,new_txnid);
                TXSNP_SnpShared: $display("%t: hnf ( %d ) txn ( %d ) sends SnpShared" ,$time,src_id,new_txnid);
                TXSNP_EVBUF_SnpCleanInvalid:$display("%t: hnf ( %d ) txn ( %d ) sends SnpCleanInvalid" ,$time,src_id,new_txnid);
            endcase
                     
            case(txreq_action)
                TXREQ_DMT_ReadNoSnp:  $display("%t: hnf ( %d ) txn ( %d ) sends ReadNoSnp" ,$time,src_id,new_txnid);
                TXREQ_IDMT_ReadNoSnp: $display("%t: hnf ( %d ) txn ( %d ) sends IDMT_ReadNoSnp" ,$time,src_id,new_txnid); 
                TXREQ_WriteNoSnpFull: $display("%t: hnf ( %d ) txn ( %d ) sends WriteNoSnpFull" ,$time,src_id,new_txnid);         
            endcase         
            
            case(txrsp_action)
                TXRSP_COMP_UC: $display("%t: hnf ( %d ) txn ( %d ) sends COMP_UC" ,$time,src_id,new_txnid);
                TXRSP_CompDBIDResp: $display("%t: hnf ( %d ) txn ( %d ) sends CompDBIDResp" ,$time,src_id,new_txnid);
            endcase
       
            if(action_type ==     LCT)  $display("%t: hnf ( %d ) txn ( %d ) LCT" ,$time,src_id,new_txnid);
            if(action_type ==     DCT)  $display("%t: hnf ( %d ) txn ( %d ) DCT  " ,$time,src_id,new_txnid);
            if(action_type ==     IDCT) $display("%t: hnf ( %d ) txn ( %d ) IDCT  " ,$time,src_id,new_txnid);
            if(action_type ==     DMT)  $display("%t: hnf ( %d ) txn ( %d ) DMT " ,$time,src_id,new_txnid);
            if(action_type ==     IDMT) $display("%t: hnf ( %d ) txn ( %d ) IDMT " ,$time,src_id,new_txnid);
            if(action_type ==     ATOMIC_RN) $display("%t: hnf ( %d ) txn ( %d ) ATOMIC_RN " ,$time,src_id,new_txnid);
            if(action_type ==     ATOMIC_CAHCE) $display("%t: hnf ( %d ) txn ( %d ) ATOMIC_LD_CACHE " ,$time,src_id,new_txnid);
            if(action_type ==     ATOMIC_MEM) $display("%t: hnf ( %d ) txn ( %d ) ATOMIC_MEM " ,$time,src_id,new_txnid);
            if(rxreq_to_txrsp_wr_en && excl_action ==   EXL_ACTION_EXL_FAIL) $display("%t: hnf ( %d ) txn ( %d ) exclusive transaction failed." ,$time,src_id,new_txnid);
            if(rxreq_to_txrsp_wr_en && excl_action ==   EXL_ACTION_EXL_OK) $display("%t: hnf ( %d ) txn ( %d ) exclusive transaction success." ,$time,src_id,new_txnid);
        
        end
        
         if((VERBOSITY  & MONITORE_REQ_LKPT) > 0)
         if(txreq_to_rxrsplkpt_valid) $display("%t: hnf ( %d ) txn ( %d ) update lkpt  with rsperr_flag ( %d ) rsp_type ( %d )  srcid ( %d ) lkpt_addr ( %d ), txnid ( %d )",$time,src_id,txreq_to_rxrsplkpt_txnid,rsperr_flag,rsp_type,  srcid, lkpt_addr ,txnid); 
        
        
        if((VERBOSITY & MONITORE_HAZARDS )> 0)begin                     
                     
            if(action_type ==     HAZARD ) begin 
                $display("%t: hnf ( %d ) txn ( %d ) HAZARD on addr ( %d ) " ,$time,src_id, txnid, addr);
               // #1 $stop;
            end
            if(action_type ==     HAZARD_SAME_ADDR ) begin 
                $display("%t: hnf ( %d ) txn ( %d ) HAZARD (two consequative reqs the same addr) on addr ( %d ) " ,$time,src_id,txnid,addr);
               // #1 $stop;
            end
         end   
     
       // if(action_type ==     SEND_SnpSharedFwd) $display("%t:hnf (%d) SEND_SnpSharedFwd" ,$time,src_id);
      
        if(unsupported_opcode) begin 
            $display("%t: Error: hnf ( %d ) txn ( %d ) received an unsupported request opcode ( %h )",$time,src_id,txnid,opcode);
            $stop;
        end
        
        
        
        if(snpf_to_rxreq_wr_is_failed) begin 
            $display("%t: Error: hnf ( %d ) got snpf failed write. Need to send error/retry to sender which is not supported yet",$time,src_id);
            $stop;        
        end
            
    end
    
    generate
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) > 0)begin 
    
        monitor_req_flit #(
            .AGENT_NAME("hnf"),
        	// .src_id(src_id),
        	.TYPE("RX")
        	
        )
        monitor
        (
        	.src_id(src_id),
        	.clk(clk),
        	.monitor(noc_chi_rxreqflitv),
        	.req_flit(noc_chi_rxreqflit)
        );
    
     
    end
    endgenerate
    
    
     //synthesis translate_on 
    //synopsys  translate_on




endmodule
