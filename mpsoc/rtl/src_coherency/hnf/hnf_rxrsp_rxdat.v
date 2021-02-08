/**************************************
* Module: hnf_rx_rsp
* Date:2019-05-23  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  hnf_rxrsp_rxdat #(
    parameter VERBOSITY=3,
    //parameter snf_id=3,
    parameter B=4,
    //parameter src_id=0,
    parameter SNPF_SPVw=5,
    parameter EXPCT_RSP_Dw=6
    
)(
    src_id,
    snf_id,
    //CHI rxrsp
    noc_chi_rxrspflitpend,
    noc_chi_rxrspflitv,
    noc_chi_rxrspflit,
    chi_noc_rxrsplcrdv,
    
    //chi rxdat
    noc_chi_rxdatflitpend, 
    noc_chi_rxdatflitv, 
    noc_chi_rxdatflit, 
    chi_noc_rxdatlcrdv,     
    
    //rxreq
    rxrsp_to_txgen_txnid,
    rxrsp_to_txgen_txnid_release,
    txgen_to_rxrsp_ready,
    
    //snpf
    rxrsp_to_snpf_wr_addr,
    rxrsp_to_snpf_wr_en,
    rxrsp_to_snpf_wr_evict,
    rxrsp_to_snpf_wr_spv,
    //rxrsp_to_snpf_wr_state,
    rxrsp_to_snpf_update_state,
    rxrsp_to_snpf_action, 
    
    
    snpf_to_rxrsp_wr_hit,
    snpf_to_rxrsp_wr_chnl_ready,
    snpf_to_rxrsp_wr_is_failed,
    snpf_to_rxrsp_wr_done, 
      
    
    //lkpt  
    rxrsp_to_lkpt_txnid,  
    rxrsp_to_lkpt_rd_valid,
    lkpt_to_rxrsp_txndat, 
   
    
    //datlkpt
    /*
    rxdat_to_datlkpt_txnid,
    rxrsp_to_datlkpt_rd_valid,
    rxdat_to_datlkpt_txndat,
    rxdat_to_datlkpt_valid,     

    rxrsp_to_datlkpt_txnid, 
    datlkpt_to_rxrsp_txndat, 
     */     
    
    
    
    //undat
    rxdat_to_undat_action,
    undat_to_rxdat_nearly_full, 
    undat_to_rxdat_ready,  
    rxdat_to_undat_dat,  
    rxdat_to_undat_wr,  
    rxdat_to_undat_tgtid, 
    rxdat_to_undat_txnid, 
    rxdat_to_undat_dbid, 
    rxdat_to_undat_resp, 
    rxdat_to_undat_resperr,
    rxdat_to_undat_opcode,
    rxdat_to_undat_addr, 
    rxdat_to_undat_cache_wr, 
    rxdat_to_undat_txnid_release,
    rxdat_to_undat_snpf_update,
     
    //txrsp
    txrsp_to_rxrsp_nearly_full,
    txrsp_to_rxrsp_ready, 
    rxrsp_to_txrsp_wr_en,
    rxrsp_to_txrsp_txnid,
    rxrsp_to_txrsp_tgtid,
    rxrsp_to_txrsp_opcode,
    rxrsp_to_txrsp_resp,
    rxrsp_to_txrsp_resperr,
    rxrsp_txsnp_dbid,
    
    
    //txreq
    txreq_to_rxdat_ready, 
    rxdat_to_txreq_wr, 
    rxdat_to_txreq_opcode, 
    rxdat_to_txreq_tgtid, 
    rxdat_to_txreq_txnid, 
    rxdat_to_txreq_returnnid, 
    rxdat_to_txreq_returntxnid, 
    rxdat_to_txreq_addr, 
    rxdat_to_txreq_likelyshared, 
    
    
     //expct_rsp wr
    rxrsp_to_expct_rsp_txnid_wr,
    rxrsp_to_expct_rsp_dat_wr,
    rxrsp_to_expct_rsp_valid_wr,
    expct_rsp_to_rxrsp_ready_wr,
    
    
    //expct_rsp rd
    rxrsp_to_expct_rsp_txnid_rd,
    expct_rsp_to_rxrsp_dat_rd,
    rxrsp_to_expct_rsp_valid_rd,
    expct_rsp_to_rxrsp_ready_rd,    
    
    //general
   
    reset,
    clk
);

                 
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"             
                 
   
    input [31 : 0] src_id;
    input [31 : 0] snf_id;
      
    //CHI rxreq
    input    noc_chi_rxrspflitpend ;
    input    noc_chi_rxrspflitv ;
    input   [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit ;
    output    chi_noc_rxrsplcrdv ;
    
    
    //CHI rxdat
    input    noc_chi_rxdatflitpend; 
    input    noc_chi_rxdatflitv ; 
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output  reg chi_noc_rxdatlcrdv ; 
    
    //rxreq
    output reg [TXNID_REQ-1:0]   rxrsp_to_txgen_txnid;
    output reg rxrsp_to_txgen_txnid_release;
    input txgen_to_rxrsp_ready;    
    
    output reg [ADDR_REQ-1 : 0] rxrsp_to_snpf_wr_addr;
    output reg rxrsp_to_snpf_wr_en;
    output reg rxrsp_to_snpf_wr_evict;
    output reg [SNPF_SPVw-1 : 0] rxrsp_to_snpf_wr_spv;
 //   output reg [CACHE_STATUSw-1 : 0] rxrsp_to_snpf_wr_state;
    output reg rxrsp_to_snpf_update_state;
    output [SNPF_ACTw-1:0] rxrsp_to_snpf_action;
  
    
    input snpf_to_rxrsp_wr_hit;
    input snpf_to_rxrsp_wr_chnl_ready;
    input snpf_to_rxrsp_wr_is_failed;
    input snpf_to_rxrsp_wr_done;   
    
    //lkpt
    output reg [TXNID_REQ-1 :  0] rxrsp_to_lkpt_txnid;
    output reg rxrsp_to_lkpt_rd_valid;
    input [HNF_RXRSP_TXN_DATAw-1 :  0] lkpt_to_rxrsp_txndat;
    
    //datlkpt
    /*
    output [TXNID_REQ-1 : 0] rxdat_to_datlkpt_txnid;    
    output [DATA_DAT-1  : 0] rxdat_to_datlkpt_txndat;
    output rxdat_to_datlkpt_valid;
    
    output [TXNID_REQ-1 : 0] rxrsp_to_datlkpt_txnid;
    output rxrsp_to_datlkpt_rd_valid;
    input  [DATA_DAT-1  : 0] datlkpt_to_rxrsp_txndat;
     */ 
    
    
    
    
    //undat
    input  undat_to_rxdat_nearly_full;
    input  undat_to_rxdat_ready;
    output  [DU_ACTw-1 : 0] rxdat_to_undat_action;
    output reg [DATA_DAT-1 : 0] rxdat_to_undat_dat;
    output reg rxdat_to_undat_wr;
    output reg [TGTID_REQ-1:0]           rxdat_to_undat_tgtid;
    output reg [TXNID_REQ-1:0]           rxdat_to_undat_txnid;
    output reg [TXNID_REQ-1:0]  rxdat_to_undat_dbid;
    output reg [RESP_DAT-1 : 0] rxdat_to_undat_resp;
    output reg [RESPERR_DAT-1 : 0] rxdat_to_undat_resperr;
    output reg [OPCODE_DAT-1 : 0] rxdat_to_undat_opcode;
    output [ADDR_REQ-1 :0  ] rxdat_to_undat_addr;
    output reg rxdat_to_undat_cache_wr;
    output reg rxdat_to_undat_txnid_release;
    output reg rxdat_to_undat_snpf_update;
     //rxrsp
    input  txrsp_to_rxrsp_nearly_full;
    input  txrsp_to_rxrsp_ready;
    output reg rxrsp_to_txrsp_wr_en;
    output reg [TXNID_RSP-1:0] rxrsp_to_txrsp_txnid;
    output reg [TGTID_RSP-1:0] rxrsp_to_txrsp_tgtid;
    output reg [OPCODE_RSP-1:0] rxrsp_to_txrsp_opcode;
    output reg [RESP_RSP-1:0] rxrsp_to_txrsp_resp;
    output reg [RESPERR_RSP-1:0] rxrsp_to_txrsp_resperr;
    output reg [TXNID_RSP-1:0] rxrsp_txsnp_dbid;
    
    //expct_rsp wr
    output [TXNID_REQ-1 : 0] rxrsp_to_expct_rsp_txnid_wr;
    output reg [EXPCT_RSP_Dw-1 : 0] rxrsp_to_expct_rsp_dat_wr;
    output reg rxrsp_to_expct_rsp_valid_wr;
    input expct_rsp_to_rxrsp_ready_wr;
    
    
    //expct_rsp rd
    output [TXNID_REQ-1 : 0] rxrsp_to_expct_rsp_txnid_rd;
    input [EXPCT_RSP_Dw-1 : 0] expct_rsp_to_rxrsp_dat_rd;
    output rxrsp_to_expct_rsp_valid_rd;
    input expct_rsp_to_rxrsp_ready_rd;
    
    
    input txreq_to_rxdat_ready;
    output reg  rxdat_to_txreq_wr;
    output reg [OPCODE_REQ-1 : 0] rxdat_to_txreq_opcode;
    output reg [TGTID_REQ-1  : 0] rxdat_to_txreq_tgtid;
    output reg [TXNID_REQ-1  : 0] rxdat_to_txreq_txnid;
    output reg [RETURNNID_REQ-1 : 0] rxdat_to_txreq_returnnid;
    output reg [RETURNTXNID_REQ-1:0] rxdat_to_txreq_returntxnid;
    output reg [ADDR_REQ-1: 0] rxdat_to_txreq_addr;
    output reg rxdat_to_txreq_likelyshared;
    
    
  
    
    
    
    //general
    input reset,clk;

   
     
    //TODO Update cache state and comp data for other cases
    //currently only IDMT send data to home node
    // always @(*)begin 
        
  
    
   

   /**************************
    *   RSP flit
    * 
    * ***********************/
    localparam RSPDw=  SRCID_RSP + TXNID_RSP +  OPCODE_RSP + RESP_RSP;
     
    reg  rxrsp_read_fifo_en;
    wire rxrsp_flit_fifo_empty;
    
   // wire [RSP_FLIT_SIZE-1 : 0] current_rxrspflit;
    wire [TXNID_REQ-1 : 0 ] rxrsp_flit_in_txnid;
  

    wire [QOS_RSP-1:0]             noc_chi_rxrsp_qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           noc_chi_rxrsp_tgtid  ;
    wire [SRCID_RSP-1:0]           noc_chi_rxrsp_srcid  ;
    wire [TXNID_RSP-1:0]           noc_chi_rxrsp_txnid  ;
    wire [OPCODE_RSP-1:0]          noc_chi_rxrsp_opcode ;
    wire [RESPERR_RSP-1:0]         noc_chi_rxrsp_resperr;     
    wire [RESP_RSP-1:0]            noc_chi_rxrsp_resp;
    wire [FWD_DATAPULL_RSP-1:0]    noc_chi_rxrsp_fwd_datapull;
    wire [DBID_RSP-1:0]            noc_chi_rxrsp_dbid;
    wire [PCRDTYPE_RSP-1:0]        noc_chi_rxrsp_pcrdtype; // = 4'b0000;
    wire                           noc_chi_rxrsp_tracetag; // = 1'b0;

    assign {noc_chi_rxrsp_qos, noc_chi_rxrsp_tgtid,   noc_chi_rxrsp_srcid,   noc_chi_rxrsp_txnid,   noc_chi_rxrsp_opcode,  noc_chi_rxrsp_resperr,    noc_chi_rxrsp_resp,  noc_chi_rxrsp_fwd_datapull,  noc_chi_rxrsp_dbid,   noc_chi_rxrsp_pcrdtype,  noc_chi_rxrsp_tracetag} = noc_chi_rxrspflit;
    
   
   
    wire [RSPDw-1 : 0] rxrspflit,current_rxrspflit;
    wire rxrspflitv;

   // There is depencency between rsp and dat chanel in AMBA CHI protecol. We have to make sure that we can consume at least all packets from 
   // One of these two chanels (256 max buffer size is needed). RSP is smaller so lets atore it: 
   hnf_rsv_extend_buffer #(
    .B(B),
    .EXTND_B(2**TXNID_RSP),
    .Dw(RSPDw)
   )
   rsp_extend_buffer
   (
    .noc_chi_rxflitpend(noc_chi_rxrspflitpend),
    .noc_chi_rxflitv(noc_chi_rxrspflitv),
    .noc_chi_rxflit({ noc_chi_rxrsp_srcid, noc_chi_rxrsp_opcode,  noc_chi_rxrsp_resp, noc_chi_rxrsp_txnid}),
    .chi_noc_rxlcrdv(chi_noc_rxrsplcrdv),
    
    
    .rxflitpend( ),
    .rxflitv(rxrspflitv),
    .rxflit(rxrspflit),
    .rxlcrdv(rxrsp_read_fifo_en),
    .reset(reset),
    .clk(clk)
   );

    wire [TXNID_RSP-1:0] rxrsp_txnid_in = rxrspflit [TXNID_RSP-1:0];
  



    fifo #(
        .Dw(RSPDw),
        .B(B)
    )
    rxrsp_flit_fifo
    (
        .din(rxrspflit),
        .wr_en(rxrspflitv),
        .rd_en(rxrsp_read_fifo_en ),
        .dout(current_rxrspflit),
        .full(),
        .nearly_full(),
        .empty(rxrsp_flit_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
    
     fwft_fifo #(
        .DATA_WIDTH(TXNID_RSP),
        .MAX_DEPTH(B),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    lkpt_rsp_fifo
    (
        .din(rxrsp_txnid_in),
        .wr_en(rxrspflitv),
        .rd_en(rxrsp_read_fifo_en),
        .dout(rxrsp_flit_in_txnid),
        .full(),
        .nearly_full(),
        .recieve_more_than_0(),
        .recieve_more_than_1(),
        .reset(reset),
        .clk(clk)
    );
    
   
    wire [SRCID_RSP-1:0]           rxrsp_srcid  ;
    wire [TXNID_RSP-1:0]           rxrsp_txnid  ;
    wire [OPCODE_RSP-1:0]          rxrsp_opcode ;
    wire [RESP_RSP-1:0]            rxrsp_resp;
   
    
    
    assign {rxrsp_srcid,  rxrsp_opcode,  rxrsp_resp, rxrsp_txnid} =current_rxrspflit;
   
    
   
   
   /**************************
    *   DAT flit
    * 
    * ***********************/
    
    
    wire rxdat_flit_fifo_empty;
    reg  rxdat_read_fifo_en;
    wire [DAT_FLIT_SIZE-1 : 0] current_rxdatflit;
    wire [TXNID_REQ-1 : 0 ] rxdat_flit_in_txnid;

     //data fileds
    wire [QOS_DAT-1:0]             rxdat_qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_DAT-1:0]           rxdat_tgtid  ;
    wire [SRCID_DAT-1:0]           rxdat_srcid  ;
    wire [TXNID_DAT-1:0]           rxdat_txnid  ;
    wire [HOMENID_DAT-1:0]         rxdat_homenid; // 
    wire [OPCODE_DAT-1:0]          rxdat_opcode ;
    wire [RESPERR_DAT-1:0]         rxdat_resperr;     
    wire [RESP_DAT-1:0]            rxdat_resp;
    wire [FWD_DATAPULL_DAT-1:0]    rxdat_fwd_datapull;
    wire [DBID_DAT-1:0]            rxdat_dbid;
    wire [CCID_DAT-1:0]            rxdat_ccid;
    wire [DATAID_DAT-1:0]          rxdat_dataid;
    wire                           rxdat_tracetag; // = 1'b0;
    wire [BE_DAT-1:0]              rxdat_be;
    wire [DATA_DAT-1:0]            rxdat_data;
    wire [DATACHECK_DAT-1:0]       rxdat_datacheck;
    wire [POISON_DAT-1:0]          rxdat_poison;
    
    
    
    fifo #(
        .Dw(DAT_FLIT_SIZE),
        .B(B)
    )
    rxdat_flit_fifo
    (
        .din(noc_chi_rxdatflit),
        .wr_en(noc_chi_rxdatflitv),
        .rd_en(rxdat_read_fifo_en ),
        .dout(current_rxdatflit),
        .full( ),
        .nearly_full( ),
        .empty(rxdat_flit_fifo_empty),
        .reset(reset),
        .clk(clk)
   ); 
    
    
    
    //Read txn_id one cycle before reading the actual flit  
  wire [TXNID_DAT-1:0]  rxdat_txnid_in = noc_chi_rxdatflit[DAT_FLIT_SIZE-1-(QOS_DAT+TGTID_DAT+SRCID_DAT) :    DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT)-TXNID_DAT];
  wire [DATA_DAT-1 :0]  rxdat_data_in  = noc_chi_rxdatflit[DATA_DAT+ DATACHECK_DAT + POISON_DAT-1 :  DATACHECK_DAT + POISON_DAT ];
  
  
  
   fwft_fifo #(
        .DATA_WIDTH(TXNID_RSP),
        .MAX_DEPTH(B),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    rxdattxn_fifo
    (
        .din(rxdat_txnid_in),
        .wr_en(noc_chi_rxdatflitv),
        .rd_en(rxdat_read_fifo_en),
        .dout(rxdat_flit_in_txnid),
        .full(),
        .nearly_full(),
        .recieve_more_than_0(),
        .recieve_more_than_1(),
        .reset(reset),
        .clk(clk)
    );
  
  
  
  // save the recived data in lkpt 
  /*
   * This done by undat module now
  assign rxdat_to_datlkpt_valid = noc_chi_rxdatflitv ;    
  assign rxdat_to_datlkpt_txnid = rxdat_txnid_in;
  assign rxdat_to_datlkpt_txndat = rxdat_data_in;
  */
    
  assign {rxdat_qos,rxdat_tgtid,rxdat_srcid ,rxdat_txnid ,rxdat_homenid ,rxdat_opcode ,rxdat_resperr, rxdat_resp ,rxdat_fwd_datapull ,rxdat_dbid ,rxdat_ccid ,rxdat_dataid ,rxdat_tracetag ,rxdat_be ,rxdat_data ,rxdat_datacheck  ,rxdat_poison} = current_rxdatflit; 
    
      
    
    
    
    
    /*
    
    
    localparam DATDw=  SRCID_DAT + TXNID_DAT +  OPCODE_DAT + RESP_DAT;
    reg  rxdat_read_fifo_en;
    wire rxdat_flit_fifo_empty;
    wire [TXNID_REQ-1 : 0 ] rxdat_flit_in_txnid;
   
      //data fileds
    wire [QOS_DAT-1:0]           noc_chi_rxdat_qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_DAT-1:0]         noc_chi_rxdat_tgtid  ;
    wire [SRCID_DAT-1:0]         noc_chi_rxdat_srcid  ;
    wire [TXNID_DAT-1:0]         noc_chi_rxdat_txnid  ;
    wire [HOMENID_DAT-1:0]       noc_chi_rxdat_homenid; // 
    wire [OPCODE_DAT-1:0]        noc_chi_rxopcode_dat ;
    wire [RESPERR_DAT-1:0]       noc_chi_rxdat_resperr;     
    wire [RESP_DAT-1:0]          noc_chi_rxdat_resp;
    wire [FWD_DATAPULL_DAT-1:0]  noc_chi_rxdat_fwd_datapull;
    wire [DBID_DAT-1:0]          noc_chi_rxdat_dbid;
    wire [CCID_DAT-1:0]          noc_chi_rxdat_ccid;
    wire [DATAID_DAT-1:0]        noc_chi_rxdat_dataid;
    wire                         noc_chi_rxdat_tracetag; // = 1'b0;
    wire [BE_DAT-1:0]            noc_chi_rxdat_be;
    wire [DATA_DAT-1:0]          noc_chi_rxdat_data;
    wire [DATACHECK_DAT-1:0]     noc_chi_rxdat_datacheck;
    wire [POISON_DAT-1:0]        noc_chi_rxdat_poison;
   
  
   
      
    assign {noc_chi_rxdat_qos,noc_chi_rxdat_tgtid,noc_chi_rxdat_srcid ,noc_chi_rxdat_txnid ,noc_chi_rxdat_homenid ,noc_chi_rxopcode_dat ,noc_chi_rxdat_resperr, noc_chi_rxdat_resp ,noc_chi_rxdat_fwd_datapull ,noc_chi_rxdat_dbid ,noc_chi_rxdat_ccid ,noc_chi_rxdat_dataid ,noc_chi_rxdat_tracetag ,noc_chi_rxdat_be ,noc_chi_rxdat_data ,noc_chi_rxdat_datacheck  ,noc_chi_rxdat_poison} = noc_chi_rxdatflit; 
  
    wire [DATDw-1 : 0] rxdatflit,current_rxdatflit;
    wire rxdatflitv;



   hnf_rsv_extend_buffer #(
    .B(B),
    .EXTND_B(2**TXNID_RSP),
    .Dw(DATDw)
   )
   dat_extend_buffer
   (
    .noc_chi_rxflitpend(noc_chi_rxdatflitpend),
    .noc_chi_rxflitv(noc_chi_rxdatflitv),
    .noc_chi_rxflit({ noc_chi_rxdat_srcid, noc_chi_rxopcode_dat,  noc_chi_rxdat_resp, noc_chi_rxdat_txnid}),
    .chi_noc_rxlcrdv(chi_noc_rxdatlcrdv),
    
    
    .rxflitpend( ),
    .rxflitv(rxdatflitv),
    .rxflit(rxdatflit),
    .rxlcrdv(rxdat_read_fifo_en),
    .reset(reset),
    .clk(clk)
   );

    wire [TXNID_RSP-1:0] rxdat_txnid_in = rxdatflit [TXNID_RSP-1:0];
  
  
    fifo #(
        .Dw(DATDw),
        .B(B)
    )
    rxdat_flit_fifo
    (
        .din(rxdatflit),
        .wr_en(rxdatflitv),
        .rd_en(rxdat_read_fifo_en ),
        .dout(current_rxdatflit),
        .full(),
        .nearly_full(),
        .empty(rxdat_flit_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
    
     fwft_fifo #(
        .DATA_WIDTH(TXNID_DAT),
        .MAX_DEPTH(B),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    lkpt_dat_fifo
    (
        .din(rxdat_txnid_in),
        .wr_en(rxdatflitv),
        .rd_en(rxdat_read_fifo_en),
        .dout(rxdat_flit_in_txnid),
        .full(),
        .nearly_full(),
        .recieve_more_than_0(),
        .recieve_more_than_1(),
        .reset(reset),
        .clk(clk)
    );
    
   
    wire [SRCID_DAT-1:0]           rxdat_srcid  ;
    wire [TXNID_DAT-1:0]           rxdat_txnid  ;
    wire [OPCODE_DAT-1:0]          rxopcode_dat ;
    wire [RESP_DAT-1:0]            rxdat_resp;
   
    
    
    assign {rxdat_srcid,  rxopcode_dat,  rxdat_resp, rxdat_txnid} =current_rxdatflit;
    
   
     // save the recived data in lkpt 
  assign rxdat_to_datlkpt_valid = noc_chi_rxdatflitv ;  
  assign rxdat_to_datlkpt_txnid = noc_chi_rxdat_txnid;
  assign rxdat_to_datlkpt_txndat = noc_chi_rxdat_data;
    
    */
    
    

   

  //  assign {rxrsp_qos, rxrsp_tgtid,   rxrsp_srcid,   rxrsp_txnid,   rxrsp_opcode,  rxrsp_resperr,    rxrsp_resp,  rxrsp_fwd_datapull,  rxrsp_dbid,   rxrsp_pcrdtype,  rxrsp_tracetag} = current_rxrspflit;
    
    
    
    

  
    
    reg [TXNID_DAT-1 : 0] current_txnid;
    
   
    
    
    //Read txn_id one cycle before reading the actual flit  
  //wire [TXNID_DAT-1:0]  rxdat_txnid_in = noc_chi_rxdatflit[DAT_FLIT_SIZE-1-(QOS_DAT+TGTID_DAT+SRCID_DAT) :    DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT)-TXNID_DAT];
 // wire [DATA_DAT-1 :0]  rxdat_data_in  = noc_chi_rxdatflit[DATA_DAT+ DATACHECK_DAT + POISON_DAT-1 :  DATACHECK_DAT + POISON_DAT ];
  
  
    
    localparam ST_NUM=3;
    localparam [ST_NUM-1 : 0 ]  IDEAL = 1;
    localparam [ST_NUM-1 : 0 ]  PROCESS_RXRSP = 2;
    localparam [ST_NUM-1 : 0 ]  PROCESS_RXDAT=4;
    
   
    
    wire [ADDR_REQ-1 : 0] lkpt_addr;
    wire [TXNID_RSP-1 : 0]lkpt_txnid;
    wire [SRCID_REQ-1 : 0] lkpt_srcid;
   // wire [CACHE_STATUSw-1 : 0] lkpt_snpf_state;
    wire [RSPTw-1 : 0] lkpt_rsp_type;
    wire lkp_rsperr_flag;
    
    assign  {lkp_rsperr_flag,lkpt_rsp_type,
    //lkpt_snpf_state,
    lkpt_srcid, lkpt_addr ,lkpt_txnid} =  lkpt_to_rxrsp_txndat;
    reg [ST_NUM-1 : 0 ]   nst ,pst;
    
       
   
  
   
   wire [SNPF_SPVw-1 : 0] rxrsp_rnf_spv_o, rxrsp_resp_onehot;
   rnfid_to_spv_addr_decode #(
   	.SPVw(SNPF_SPVw),
   	.IDw(SRCID_RSP)
   )
   decode
   (
   	.rnf_id_i(rxrsp_srcid),
   	.rnf_spv_o(rxrsp_rnf_spv_o)
   );
    
   assign rxrsp_resp_onehot = (rxrsp_srcid == snf_id) ? {1'b1,{(SNPF_SPVw-1){1'b0}}} : rxrsp_rnf_spv_o;
   
   wire [SNPF_SPVw-1 : 0] rxdat_rnf_spv_o, rxdat_resp_onehot ;
   rnfid_to_spv_addr_decode #(
    .SPVw(SNPF_SPVw),
    .IDw(SRCID_RSP)
   )
   decode2
   (
    .rnf_id_i(rxdat_srcid),
    .rnf_spv_o(rxdat_rnf_spv_o)
   );
    
   assign rxdat_resp_onehot = (rxdat_srcid == snf_id[SRCID_RSP-1:0]) ? {1'b1,{(SNPF_SPVw-1){1'b0}}} : rxdat_rnf_spv_o;
     
   reg [SNPF_SPVw-1 : 0] src_spv; 
    
    
    
    reg [9:0]    unsupported_condition;
   
   
    
    
    reg[1:0] snpf_spv_action;
    //snpf actions
    localparam 
        SNPF_IDEAL = 0,
        SNPF_ADD_SRC=1,
        SNPF_REMOVE_SRC=2;
    
    // snpf_state  
    reg[1:0] snpf_state_action;
    localparam 
        SNPF_ST_IDEAL=0,
        /*
        SNPF_ST_ADD_I=1,
        SNPF_ST_ADD_U=2,
        SNPF_ST_ADD_S=3,
        */
        SNPF_EVICT=2;
    
        
        
    reg snpf_busy_action;
    localparam 
        SNPF_BUSY_IDEAL=0,
        SNPF_BUSY_CLEAR=1;      
        
    
    reg [2:0] undat_action;
    //send data action
    localparam
        UNDAT_IDEAL=0,
        UNDAT_FW_CompData_I=1,
        UNDAT_FW_CompData_UC=2,
        UNDAT_FW_CompData_SC=3,
        UNDAT_NCBWrData_I=4,
        UNDAT_CBWrData_I=5,
        UNDAT_WR_LKPT=6,
        UNDAT_TXN_END=7;
        
        
    
    
    
    reg txn_action;    
    localparam 
        TXN_ACTIVE=0,
        TXN_ENDED=1;
    
    reg [1 :0] txrsp_action;
    localparam 
        TXRSP_IDEAL=0,
        TXRSP_Comp_I=1,
        TXRSP_Comp_UC=2;
     
    reg [2: 0] expct_rsp_action;
    localparam 
        EXPCT_IDEAL=0,
        EXPCT_RMV_SRC=1,
        EXPCT_RMV_SRC_ADD_DAT=2,
        EXPCT_RMV_ALL_RNS=3,
        EXPCT_RMV_SRC_ADD_SNF_ADD_DAT=4,
        EXPCT_RMV_SRC_ADD_SNF_DAT_REQUSTER=5;
        
    
        
        
      //txreq action
    reg [1:0] txreq_action;
    localparam
        TXREQ_IDEAL=0,
        TXREQ_WriteNoSnpFull=1,
        TXREQ_IDMT_ReadNoSnp=2;
        
    
 //   reg [2: 0] sub_state;
    
    wire got_all_responses, lkpt_has_data;
    assign got_all_responses=   (|( expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-1 : 0] & ~src_spv[SNPF_SPVw-1 : 0])==1'b0);    //((|rxrsp_to_expct_rsp_dat_wr[SNPF_SPVw-1 : 0])==1'b0);
  
    assign lkpt_has_data = expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw];
    assign rxrsp_to_expct_rsp_txnid_wr = current_txnid;
    
     
   
    
    reg last_dat_is_not_proceed, last_dat_is_not_proceed_next;
    reg last_rsp_is_not_proceed, last_rsp_is_not_proceed_next;
    wire can_goto_process_rsp = ~rxrsp_flit_fifo_empty |  last_rsp_is_not_proceed;
    wire can_goto_process_dat = ~rxdat_flit_fifo_empty |  last_dat_is_not_proceed;
    
     always @(posedge clk or posedge reset) begin
        if(reset)begin 
            last_dat_is_not_proceed<=1'b0;
            last_rsp_is_not_proceed<=1'b0;
            end else begin 
                last_dat_is_not_proceed <= last_dat_is_not_proceed_next;
                last_rsp_is_not_proceed <= last_rsp_is_not_proceed_next;
            end        
    end//always
    
    
   wire current_dat_not_proceed = last_dat_is_not_proceed_next;
   wire current_rsp_not_proceed = last_rsp_is_not_proceed_next;
   
   assign rxdat_to_undat_addr=lkpt_addr; 
  
     
    
    reg [DU_CORE_ACTw-1 : 0] undat_core_action;
    reg [ALU_OPTw-1  : 0] undat_alu_opt;
    reg undat_init_flag;
    
    always @(*)begin         
        rxrsp_read_fifo_en=1'b0;
        nst=pst;
        rxdat_read_fifo_en=1'b0;        
        src_spv =rxrsp_resp_onehot;
        current_txnid=rxrsp_txnid;//rxrsp
        unsupported_condition=0;
       
        undat_action=UNDAT_IDEAL;
        undat_core_action=SAVE_ALU_TX_ALU;
        undat_alu_opt = ALU_BPASS;
        undat_init_flag=CURRENT_IS_INIT;
        
        snpf_spv_action=SNPF_IDEAL;
        //snpf_syscache_action=SNPF_IDEAL;
        snpf_state_action = SNPF_ST_IDEAL;
        snpf_busy_action = SNPF_BUSY_IDEAL;
        txn_action=TXN_ACTIVE;
        txrsp_action= TXRSP_IDEAL;
        expct_rsp_action = EXPCT_IDEAL;
        txreq_action = TXREQ_IDEAL;
       
        last_dat_is_not_proceed_next = last_dat_is_not_proceed;
        last_rsp_is_not_proceed_next = last_rsp_is_not_proceed;
        
        rxrsp_to_lkpt_txnid=  rxdat_flit_in_txnid ;
        rxrsp_to_lkpt_rd_valid = 1'b0;
        rxdat_to_undat_cache_wr=1'b0;
        rxdat_to_undat_txnid_release=1'b0;
        rxdat_to_undat_snpf_update=1'b0;
       
       
        case(pst)      
        IDEAL: begin
            //change state
            if      (can_goto_process_dat) begin 
                nst=PROCESS_RXDAT; 
                rxdat_read_fifo_en= ~last_dat_is_not_proceed;  
                rxrsp_to_lkpt_txnid=  (last_dat_is_not_proceed)? rxdat_txnid  : rxdat_flit_in_txnid;
                rxrsp_to_lkpt_rd_valid = 1;
            
            end             
            else if (can_goto_process_rsp) begin 
                nst=PROCESS_RXRSP; 
                rxrsp_read_fifo_en= ~last_rsp_is_not_proceed;  
                rxrsp_to_lkpt_txnid= (last_rsp_is_not_proceed) ?  rxrsp_txnid  : rxrsp_flit_in_txnid;
                rxrsp_to_lkpt_rd_valid = 1;
            end
        end // IDEAL
/***********************
 *  Response
 * *********************/
        PROCESS_RXRSP: begin 
            //rx_req_busy=1'b1;
            undat_init_flag=LKPT_IS_INIT;
            //change state    
             if (can_goto_process_dat) begin
                nst=PROCESS_RXDAT;  
                rxdat_read_fifo_en=~last_dat_is_not_proceed; 
                rxrsp_to_lkpt_txnid=  (last_dat_is_not_proceed)? rxdat_txnid  : rxdat_flit_in_txnid;
                rxrsp_to_lkpt_rd_valid = 1;
             end 
             else if (~rxrsp_flit_fifo_empty | current_rsp_not_proceed ) begin 
                rxrsp_read_fifo_en= ~current_rsp_not_proceed;
                rxrsp_to_lkpt_txnid=  rxrsp_flit_in_txnid;
                rxrsp_to_lkpt_rd_valid = ~current_rsp_not_proceed;
             end else nst=IDEAL;                 
            
            
            case(rxrsp_opcode)
            RSP_OPCODE_CompAck:begin
                if(got_all_responses )  begin    
                    //a responce compack is recived release the txnid
                    if( snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txgen_to_rxrsp_ready & undat_to_rxdat_ready) begin 
                        if(lkpt_rsp_type!=RSP_TYPE_ReadNoSnp_NoSnpf) snpf_spv_action=SNPF_ADD_SRC;
                      //   snpf_busy_action = SNPF_BUSY_CLEAR; //we cannot end the txn as there might be a write in process in undat due to getting  pass dirty response 
                      //   txn_action=TXN_ENDED;
                       
                        rxdat_to_undat_txnid_release=1'b1;
                        rxdat_to_undat_snpf_update=1'b1;//snpf_busy_action = SNPF_BUSY_CLEAR; 
                        //just save lkpt on itself
                        undat_action =UNDAT_TXN_END;
                        undat_core_action =  SAVE_ALU_TX_OFF; 
                        undat_alu_opt = ALU_BPASS;
                        undat_init_flag=LKPT_IS_INIT;
                    
                        expct_rsp_action= EXPCT_RMV_SRC;                     
                        
                        last_rsp_is_not_proceed_next=1'b0;
                    end else last_rsp_is_not_proceed_next=1'b1; 
                end else begin
                    if( snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr ) begin 
                        if(lkpt_rsp_type!=RSP_TYPE_ReadNoSnp_NoSnpf) snpf_spv_action=SNPF_ADD_SRC;
                        expct_rsp_action= EXPCT_RMV_SRC;                     
                        last_rsp_is_not_proceed_next=1'b0;
                    end else last_rsp_is_not_proceed_next=1'b1; 
                
                end
            end //RSP_OPCODE_CompAck
            
            RSP_OPCODE_SnpResp:begin 
                if(got_all_responses )  begin                         
                          
                    /******************** rspcomp function*******************/
                    case(lkpt_rsp_type)
                    RSP_TYPE_SnpCleanInvalid:begin
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txrsp_to_rxrsp_ready)begin
                            if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC; else begin unsupported_condition=1; end //RSP_SnpResp_I
                            expct_rsp_action= EXPCT_RMV_SRC;
                            txrsp_action= TXRSP_Comp_UC;                            
                            last_rsp_is_not_proceed_next=1'b0;
                        end else last_rsp_is_not_proceed_next=1'b1;                       
                    end//RSP_TYPE_SnpCleanInvalid
                    
                    
                    
                    
                    RSP_TYPE_SnpUnique: begin
                        if(lkpt_has_data)begin 
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin 
                                if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC; else begin unsupported_condition=1; end //RSP_SnpResp_I
                                expct_rsp_action= EXPCT_RMV_SRC;
                                undat_action= UNDAT_FW_CompData_UC;                              
                                last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;
                        end else begin 
                            // we have expected to get a data from an RN but we didnt. we need to send req to SN now and ask to send the data to home node.
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr  & txreq_to_rxdat_ready)begin
                                 if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                 expct_rsp_action= EXPCT_RMV_SRC;
                                 txreq_action=TXREQ_IDMT_ReadNoSnp;
                                 last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;
                        
                        end
                    end //RSP_TYPE_SnpUnique
                    
                    
                    RSP_TYPE_EVBUF_Evict: begin 
                        if(lkpt_has_data) begin // we need to update main memory
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txreq_to_rxdat_ready )begin //& undat_to_rxdat_ready
                                snpf_state_action= SNPF_EVICT;                               
                                expct_rsp_action=EXPCT_RMV_SRC_ADD_SNF_ADD_DAT;
                                txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn 
                               // undat_action= UNDAT_FW_CompData_UC;
                                last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;
                        end else begin 
                        
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txgen_to_rxrsp_ready)begin
                                snpf_state_action= SNPF_EVICT;
                                expct_rsp_action= EXPCT_RMV_SRC;
                                txn_action=TXN_ENDED;   
                                last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;                        
                  
                        end
                    
                    end //RSP_TYPE_EVBUF_Evict
                    
                    
                    RSP_TYPE_SnpShared: begin 
                        if(lkpt_has_data)begin 
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin 
                                if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                if  (rxrsp_resp == 3'b001)  snpf_spv_action=SNPF_ADD_SRC;// SnpResp_SC not really nesserly as it should be already included in spv
                                expct_rsp_action= EXPCT_RMV_SRC;
                                undat_action= UNDAT_FW_CompData_SC; // TODO we need to check data response and if its dirty update the mem
                                last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;
                        end else begin //~lkpt_has_data
                            // we have expected to get a data from an RN but we didnt. we need to send req to SN now and ask to send the data to home node.
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr  & txreq_to_rxdat_ready)begin
                                 if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                 expct_rsp_action= EXPCT_RMV_SRC;
                                 txreq_action=TXREQ_IDMT_ReadNoSnp;
                                 last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;
                                 
                                
                        end
                    end//RSP_TYPE_SnpShared            
                               

                    RSP_TYPE_SnpSharedFwd: begin //snp
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txgen_to_rxrsp_ready)begin
                            if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                            expct_rsp_action= EXPCT_RMV_SRC;
                            // we have recived ack from both rns end of transaction
                            snpf_busy_action = SNPF_BUSY_CLEAR;
                            txn_action=TXN_ENDED;
                            last_rsp_is_not_proceed_next=1'b0;
                        end else last_rsp_is_not_proceed_next=1'b1;                        
                    end //RSP_TYPE_SnpSharedFwd
                    LD_ADD,LD_CLR,LD_EOR,LD_SET,LD_SMAX,
                    LD_SMIN ,LD_UMAX,LD_UMIN,LD_SWAP,LD_COMP:begin 
                        //a scilent cache transition happend we need to ask the old data from SN
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr  & txreq_to_rxdat_ready)begin
                                 if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                 expct_rsp_action= EXPCT_RMV_SRC;
                                 txreq_action=TXREQ_IDMT_ReadNoSnp;
                                 last_rsp_is_not_proceed_next=1'b0;
                        end else last_rsp_is_not_proceed_next=1'b1;             
                       
                    end
                    default unsupported_condition=19; 
                    endcase
                         
                         
                end else begin // if(~got_all_responses) begin
                
                    case(lkpt_rsp_type)
                    RSP_TYPE_SnpCleanInvalid, RSP_TYPE_SnpUnique,
                    LD_ADD,LD_CLR,LD_EOR,LD_SET,LD_SMAX,
                    LD_SMIN ,LD_UMAX,LD_UMIN,LD_SWAP,LD_COMP,
                    ST_ADD,ST_CLR,ST_EOR,ST_SET,
                    ST_SMAX,ST_SMIN ,ST_UMAX,ST_UMIN
                    // we have just got an invalidition ack. just remove src from expected requetsres list
                    : begin
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr)begin
                            if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC; else begin unsupported_condition=2; end //RSP_SnpResp_I
                            expct_rsp_action= EXPCT_RMV_SRC;                            
                            last_rsp_is_not_proceed_next=1'b0;
                        end else last_rsp_is_not_proceed_next=1'b1;                       
                    end //RSP_TYPE_SnpCleanInvalid, RSP_TYPE_SnpUnique
                        
                        
                    RSP_TYPE_EVBUF_Evict: begin 
                        if( expct_rsp_to_rxrsp_ready_wr)begin
                            expct_rsp_action= EXPCT_RMV_SRC;
                            last_rsp_is_not_proceed_next=1'b0;
                        end else last_rsp_is_not_proceed_next=1'b1;          
                    end //RSP_TYPE_EVBUF_Evict
                    
                    
                    RSP_TYPE_SnpShared: begin 
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr)begin
                            if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                            else if  (rxrsp_resp == 3'b001)  snpf_spv_action=SNPF_ADD_SRC;// SnpResp_SC not relly nesserly as it should be included in spv
                            else unsupported_condition=2; 
                            expct_rsp_action= EXPCT_RMV_SRC; 
                            last_rsp_is_not_proceed_next=1'b0;
                        end else last_rsp_is_not_proceed_next=1'b1;                            
                    end //RSP_TYPE_SnpShared
                    
                    
                    RSP_TYPE_SnpSharedFwd: begin //snp
                        //we are here because we have recived  SnpResp_I from RN who suposed to do DCT. we need to ask SN or SyScache to prepre the data
                       if(lkpt_has_data)begin
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready )begin // Data was in cache and sis aved in lkpt
                                    if  (rxrsp_resp == 3'b000) snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                    expct_rsp_action= EXPCT_RMV_SRC; 
                                    undat_action = UNDAT_FW_CompData_UC;
                                    undat_core_action =  SAVE_ALU_TX_ALU;  
                                    undat_init_flag=LKPT_IS_INIT; 
                                    last_rsp_is_not_proceed_next=1'b0;
                            end else last_rsp_is_not_proceed_next=1'b1;
                        end else  begin  
                             if (snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txreq_to_rxdat_ready  )begin
                                    if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                    expct_rsp_action= EXPCT_RMV_ALL_RNS;
                                    txreq_action=TXREQ_IDMT_ReadNoSnp;
                                    last_rsp_is_not_proceed_next=1'b0;                     
                            
                            end else last_rsp_is_not_proceed_next=1'b1;
                         end   
                               
                             
                         /*     
                        // end else begin //~got data
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txreq_to_rxdat_ready)begin
                                 if  (rxrsp_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC;// SnpResp_I
                                 expct_rsp_action= EXPCT_RESET;
                                 txreq_action=TXREQ_IDMT_ReadNoSnp;
                                 last_rsp_is_not_proceed_next=1'b0;
                                 unsupported_condition=88;  
                            end else last_rsp_is_not_proceed_next=1'b1;
                      //  end//else got data  
                         */  
                    end //RSP_TYPE_SnpSharedFwd
                    default unsupported_condition=8;  
                    endcase             
                       
                end//  else(~got_all_responses) begin  
            end //RSP_OPCODE_SnpResp
            
           
            
            RSP_OPCODE_CompDBIDResp:begin
               // if(lkpt_rsp_type != RSP_TYPE_WriteUniqueFull) unsupported_condition=12;
                if(got_all_responses) begin 
                    if(  expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready  ) begin
                        // snpf_busy_action= SNPF_BUSY_CLEAR; snpf will be cleared by undat after  rxdat_to_undat_txnid_release is done
                        expct_rsp_action= EXPCT_RMV_SRC;
                        //cahe_wr         
                        rxdat_to_undat_cache_wr =1'b1;  //snpf cache loc will be updated by undat after cache wr                  
                        rxdat_to_undat_txnid_release=1'b1; //txn_action=TXN_ENDED; txn will be ended after cache write by undat                        
                        rxdat_to_undat_snpf_update=1'b1;
                        case(lkpt_rsp_type)
                        RSP_TYPE_WriteUniqueFull:    undat_action= UNDAT_NCBWrData_I;
                        RSP_TYPE_WriteBackFull:    undat_action= UNDAT_CBWrData_I;
                        RSP_TYPE_SnpShared,RSP_TYPE_SnpSharedFwd,
                        RSP_TYPE_SnpCleanInvalid,RSP_TYPE_SnpUnique: undat_action= UNDAT_NCBWrData_I;
                        LD_ADD,LD_CLR,LD_EOR,LD_SET,LD_SMAX,
                        LD_SMIN ,LD_UMAX,LD_UMIN,LD_SWAP,LD_COMP:   undat_action= UNDAT_CBWrData_I;
                        ST_ADD,ST_CLR,ST_EOR,ST_SET,
                        ST_SMAX,ST_SMIN ,ST_UMAX,ST_UMIN :   undat_action= UNDAT_CBWrData_I;
                        RSP_TYPE_EVBUF_Evict: begin 
                            undat_action= UNDAT_NCBWrData_I;
                            rxdat_to_undat_cache_wr =1'b0; 
                            rxdat_to_undat_snpf_update=1'b0;
                        end    
                        default : unsupported_condition=12;
                        endcase                            
                       
                        last_rsp_is_not_proceed_next=1'b0;
                    end else last_rsp_is_not_proceed_next=1'b1; 
                        
                end else begin // ~got_all_responses
                    if( expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready) begin
                        expct_rsp_action= EXPCT_RMV_SRC;
                        
                        case(lkpt_rsp_type)                       
                        RSP_TYPE_SnpShared,
                        RSP_TYPE_SnpSharedFwd,
                        RSP_TYPE_SnpUnique,
                        RSP_TYPE_SnpCleanInvalid: begin 
                            undat_action= UNDAT_NCBWrData_I;
                            rxdat_to_undat_cache_wr =1'b1;
                            rxdat_to_undat_snpf_update=1'b1;
                        end    
                        RSP_TYPE_EVBUF_Evict:begin 
                            undat_action= UNDAT_NCBWrData_I;                           
                        end
                        endcase
                        
                        last_rsp_is_not_proceed_next=1'b0;
                    end else last_rsp_is_not_proceed_next=1'b1; 
                
                end //got_all_responses
            end  //RSP_OPCODE_CompDBIDResp  
           
            
            default : unsupported_condition=3;            
           
            endcase //rxrsp_opcode           
        end// PROCESS_RXRSP
        
/*********************************
 * 
 *      DATA
 * 
 * *******************************/
        
        
        PROCESS_RXDAT: begin 
            //update response waiting list
            src_spv =rxdat_resp_onehot;
            current_txnid=rxdat_txnid;            
           
            
            if (can_goto_process_rsp) begin 
                nst=PROCESS_RXRSP; 
                rxrsp_read_fifo_en= ~last_rsp_is_not_proceed; 
                rxrsp_to_lkpt_txnid= (last_rsp_is_not_proceed) ?  rxrsp_txnid  : rxrsp_flit_in_txnid;
                rxrsp_to_lkpt_rd_valid = 1;
            end 
            else if(~rxdat_flit_fifo_empty |  current_dat_not_proceed )begin
                rxdat_read_fifo_en= ~current_dat_not_proceed; 
                rxrsp_to_lkpt_txnid=   rxdat_flit_in_txnid; 
                rxrsp_to_lkpt_rd_valid = ~current_dat_not_proceed;
            end else nst=IDEAL;                     
                     
            
            case(rxdat_opcode) 
            OPCODE_DAT_CompData: begin 
              
                if(got_all_responses) begin //TODO check if its from SN
                    case(lkpt_rsp_type)
                    RSP_TYPE_ReadNoSnp_NoSnpf,
                    RSP_TYPE_ReadNoSnp: begin 
                    
                        if( expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready ) begin // update cache, snoopfilter and send data to undata
                            //snpf_syscache_action=SNPF_ADD_TO_SYSCACHE; will be done by undat 
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;                
                            undat_action = UNDAT_FW_CompData_UC;
                            rxdat_to_undat_cache_wr =1'b1; //cache_action = CACHE_ADD_UC;               
                            rxdat_to_undat_snpf_update=1'b1;
                            
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1; 
                    end
                    //AtomicLoad/Swap transactions
                    LD_ADD,LD_CLR,LD_EOR,LD_SET,LD_SMAX,
                    LD_SMIN ,LD_UMAX,LD_UMIN,LD_SWAP,LD_COMP:   begin        
                    //Atomic load, We have the old data in current flit. We need to return it to the source and execute the atomic instruction on lkpt dat and save it the result there. And WriteNoSnp to write it in mem. 
                        if(expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready)begin
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;  
                            txreq_action = TXREQ_WriteNoSnpFull;//write to sn                            
                            undat_action = UNDAT_FW_CompData_UC;
                            undat_core_action =  SAVE_ALU_TX_DIN;//execute atomic transaction and save it in lkpt. Send initial dat to src requestor
                            
                            case (lkpt_rsp_type)
                            LD_ADD : undat_alu_opt = ALU_ADD;
                            LD_CLR : undat_alu_opt = ALU_CLR;  
                            LD_EOR : undat_alu_opt = ALU_EOR;
                            LD_SET : undat_alu_opt = ALU_SET;
                            LD_SWAP: undat_alu_opt = ALU_SWAP;
                            LD_SMAX: undat_alu_opt = ALU_SMAX;
                            LD_SMIN: undat_alu_opt = ALU_SMIN;
                            LD_UMAX: undat_alu_opt = ALU_UMAX;
                            LD_UMIN: undat_alu_opt = ALU_UMIN;
                            default: unsupported_condition=14;
                            endcase
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1; 
                      
                    end//atomic load
                    //AtomicStore
                    ST_ADD,ST_CLR,ST_EOR,ST_SET,
                    ST_SMAX,ST_SMIN ,ST_UMAX,ST_UMIN :   begin        
                    //Atomic store, We have the old data in current flit. We need to send comp to the source and execute the atomic instruction on lkpt dat and save it the result there. And WriteNoSnp to write it in mem. 
                        if(expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready & txrsp_to_rxrsp_ready)begin
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;  
                            txreq_action = TXREQ_WriteNoSnpFull;//write to sn                            
                            
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action =  SAVE_ALU_TX_OFF;// executae atomic transaction and save it in lkpt
                            
                            txrsp_action= TXRSP_Comp_I;//send comp to source
                            
                        
                            case (lkpt_rsp_type)
                            ST_ADD : undat_alu_opt = ALU_ADD;
                            ST_CLR : undat_alu_opt = ALU_CLR;  
                            ST_EOR : undat_alu_opt = ALU_EOR;
                            ST_SET : undat_alu_opt = ALU_SET;
                            ST_SMAX: undat_alu_opt = ALU_SMAX;
                            ST_SMIN: undat_alu_opt = ALU_SMIN;
                            ST_UMAX: undat_alu_opt = ALU_UMAX;
                            ST_UMIN: undat_alu_opt = ALU_UMIN;
                            default: unsupported_condition=14;
                            endcase
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1; 
                      
                    end//atomicStore
                    RSP_TYPE_SnpShared,RSP_TYPE_SnpSharedFwd,RSP_TYPE_SnpUnique: begin 
                    // we are here becasue the snoopshard to  RNs didnot return any data so we have send req to memory and got comdata from mem.
                        if( expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready )begin                         
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;  
                            undat_action = UNDAT_FW_CompData_UC;
                            rxdat_to_undat_cache_wr =1'b1; //cache_action = CACHE_ADD_UC;
                            rxdat_to_undat_snpf_update=1'b1;
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1; 
                    
                    end
                    
                    default unsupported_condition=16; 
                     
                     
                     endcase
                end else begin //if  (~got_all_responses )  
                    //There is still more data to be recived, just save recived data on lkpt
                    if(expct_rsp_to_rxrsp_ready_wr   & undat_to_rxdat_ready) begin 
                        undat_action =UNDAT_WR_LKPT;
                        undat_core_action = SAVE_ALU_TX_OFF;
                       // snpf_syscache_action=SNPF_ADD_TO_SYSCACHE; // will be done by undat later
                        expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                        rxdat_to_undat_cache_wr=1'b1; 
                        rxdat_to_undat_snpf_update=1'b1;        
                        last_dat_is_not_proceed_next=1'b0;
                       
                    end
                    else last_dat_is_not_proceed_next=1'b1;                    
                end // else (~got_all_responses )
            end // OPCODE_DAT_CompData
            
            
            OPCODE_DAT_SnpRespDataFwded: begin
                 case(rxdat_resp)
                 3'b001: begin //SnpRespData_SC_Fwded_SC
                    //update cache , no need to do furthor action
                    if( expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready )begin
                        //snpf_syscache_action=SNPF_ADD_TO_SYSCACHE;// will be done bu undat
                        expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                        undat_action =UNDAT_WR_LKPT;
                        undat_core_action = SAVE_ALU_TX_OFF;
                        rxdat_to_undat_cache_wr=1;
                        rxdat_to_undat_snpf_update=1'b1;
                        if(got_all_responses)  begin 
                            rxdat_to_undat_txnid_release=1'b1; //txn_action=TXN_ENDED; we need to wait unil the cache is written then release the txn.
                            rxdat_to_undat_snpf_update=1'b1;//snpf_busy_action = SNPF_BUSY_CLEAR; the busy bit is de asserted by undat 
                            
                        end
                        last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1; 
                 end//3'b001
                 3'b101: begin //DAT_SnpRespData_SC_PD_Fwded_SC 
                 //send update req to main memory
                    if( expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready)begin
                        expct_rsp_action=EXPCT_RMV_SRC_ADD_SNF_ADD_DAT;
                        txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn 
                        
                        undat_action =UNDAT_WR_LKPT;
                        undat_core_action = SAVE_ALU_TX_OFF;
                        rxdat_to_undat_cache_wr=1'b0;//The cache will be updated once we send the data to SN
                       
                        last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1; 
            
            
                 end
                 default: begin 
                    unsupported_condition=4;                 
                 end
                 endcase                
            end // OPCODE_DAT_SnpRespDataFwded         
                       
           
           
           
            OPCODE_DAT_SnpRespData:begin
                if(got_all_responses)  begin 
                    /******************** rspcomp function*******************/
                    case(lkpt_rsp_type)
                    RSP_TYPE_SnpCleanInvalid: begin
                        case(rxdat_resp)
                        3'b000: begin
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & txrsp_to_rxrsp_ready)begin
                                snpf_spv_action=SNPF_REMOVE_SRC; 
                                expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;                                
                                txrsp_action= TXRSP_Comp_UC;
                                last_dat_is_not_proceed_next=1'b0;
                            end
                            else last_dat_is_not_proceed_next=1'b1; 
                        end
                        3'b100: begin //DAT_SnpRespData_I_PD
                             //send update req to main memory
                              if( expct_rsp_to_rxrsp_ready_wr &  txreq_to_rxdat_ready & snpf_to_rxrsp_wr_chnl_ready & txrsp_to_rxrsp_ready  & undat_to_rxdat_ready)begin
                                    expct_rsp_action=EXPCT_RMV_SRC_ADD_SNF_DAT_REQUSTER;
                                    txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn 
                                    snpf_spv_action=SNPF_REMOVE_SRC;
                                    txrsp_action= TXRSP_Comp_UC;
                                    undat_action =UNDAT_WR_LKPT;
                                    undat_core_action =  SAVE_ALU_TX_OFF;
                                    rxdat_to_undat_cache_wr=1'b0;  //The cache will be updated once we send the data to SN                    
                                                                      
                                    last_dat_is_not_proceed_next=1'b0;
                                end
                                else last_dat_is_not_proceed_next=1'b1; 
                        
                        end
                        default: begin
                            unsupported_condition=5;
                        end
                        endcase 
                        
                    end // RSP_TYPE_SnpCleanInvalid           
                    
                    RSP_TYPE_SnpUnique: begin
                        case(rxdat_resp)
                        3'b000:begin
                    
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin
                                snpf_spv_action=SNPF_REMOVE_SRC; 
                                expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                                undat_action= UNDAT_FW_CompData_UC;
                                last_dat_is_not_proceed_next=1'b0;
                               
                            end
                            else last_dat_is_not_proceed_next=1'b1;
                        end
                        3'b100: begin //DAT_SnpRespData_I_PD
                             //send update req to main memory
                              if( expct_rsp_to_rxrsp_ready_wr & snpf_to_rxrsp_wr_chnl_ready & undat_to_rxdat_ready & txreq_to_rxdat_ready)begin
                                    expct_rsp_action=EXPCT_RMV_SRC_ADD_SNF_DAT_REQUSTER;
                                    txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn 
                                    snpf_spv_action=SNPF_REMOVE_SRC;
                                    undat_action= UNDAT_FW_CompData_UC;
                                    rxdat_to_undat_cache_wr=1'b0;//The cache will be updated once we send the data to SN
                                   
                                    last_dat_is_not_proceed_next=1'b0;
                                end
                                else last_dat_is_not_proceed_next=1'b1; 
                        
                        end
                        default: begin
                            unsupported_condition=6;
                        end
                        endcase 
                        
                        
                    end //RSP_TYPE_SnpUnique
                         
                    RSP_TYPE_SnpShared: begin                        
                            
                        case(rxdat_resp)
                        3'b000: begin 
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin
                                expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                                snpf_spv_action=SNPF_REMOVE_SRC;                                 
                                undat_action= UNDAT_FW_CompData_SC;
                                last_dat_is_not_proceed_next=1'b0;
                            end 
                            else last_dat_is_not_proceed_next=1'b1;   
                        end
                        3'b001: begin 
                            if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin
                                expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                                undat_action= UNDAT_FW_CompData_SC;
                                last_dat_is_not_proceed_next=1'b0;
                            end 
                            else last_dat_is_not_proceed_next=1'b1;   
                        end
                        3'b101: begin //DAT_SnpRespData_SC_PD 
                             //send update req to main memory
                              if( expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready)begin
                                    expct_rsp_action=EXPCT_RMV_SRC_ADD_SNF_DAT_REQUSTER;
                                    txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn 
                                    
                                    undat_action= UNDAT_FW_CompData_SC;
                                    rxdat_to_undat_cache_wr=1'b0;//The cache will be updated once we send the data to SN
                                   
                                    last_dat_is_not_proceed_next=1'b0;
                                end
                                else last_dat_is_not_proceed_next=1'b1; 
                        
                        end
                        
                        
                        
                        default: begin
                            unsupported_condition=15;
                        end
                        endcase 
                            
                    end //RSP_TYPE_SnpShared
                         
                    RSP_TYPE_SnpSharedFwd: begin //snp
                        if(expct_rsp_to_rxrsp_ready_wr  & undat_to_rxdat_ready)begin 
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                            //we have recived ack and dat
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action =  SAVE_ALU_TX_OFF;
                            rxdat_to_undat_cache_wr=1'b1;                       
                            rxdat_to_undat_txnid_release=1'b1;
                            rxdat_to_undat_snpf_update=1'b1;//snpf_busy_action = SNPF_BUSY_CLEAR; the busy bit is de asserted by undat 
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;      
                    end //RSP_TYPE_SnpSharedFwd
                    LD_ADD,LD_CLR,LD_EOR,LD_SET,LD_SMAX,
                    LD_SMIN ,LD_UMAX,LD_UMIN,LD_SWAP,LD_COMP:begin 
                         if(expct_rsp_to_rxrsp_ready_wr & snpf_to_rxrsp_wr_chnl_ready& undat_to_rxdat_ready & txreq_to_rxdat_ready)begin
                         
                            if  (rxdat_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC; else unsupported_condition=17;
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                            //we have got old dat(initial)
                            txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn                            
                            undat_action = UNDAT_FW_CompData_UC;//send initia data back to requetnode
                            undat_core_action =  SAVE_ALU_TX_DIN; 
                            case (lkpt_rsp_type)
                            LD_ADD : undat_alu_opt = ALU_ADD;
                            LD_CLR : undat_alu_opt = ALU_CLR;  
                            LD_EOR : undat_alu_opt = ALU_EOR;
                            LD_SET : undat_alu_opt = ALU_SET;
                            LD_SWAP: undat_alu_opt = ALU_SWAP;
                            LD_SMAX: undat_alu_opt = ALU_SMAX;
                            LD_SMIN: undat_alu_opt = ALU_SMIN;
                            LD_UMAX: undat_alu_opt = ALU_UMAX;
                            LD_UMIN: undat_alu_opt = ALU_UMIN;                      
                            default: unsupported_condition=13;
                            endcase
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;  
                    
                    end
                    ST_ADD,ST_CLR,ST_EOR,ST_SET,
                    ST_SMAX, ST_SMIN ,ST_UMAX,ST_UMIN:begin 
                         if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready & txrsp_to_rxrsp_ready)begin
                         
                            if  (rxdat_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC; else unsupported_condition=17;
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                            //we have got old dat(initial)
                            txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn                            
                            
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action =  SAVE_ALU_TX_OFF;// execute atomic transaction and save it in lkpt
                            
                            txrsp_action= TXRSP_Comp_I;//send comp to source                   
                            
                           
                            case (lkpt_rsp_type)
                            ST_ADD : undat_alu_opt = ALU_ADD;
                            ST_CLR : undat_alu_opt = ALU_CLR;  
                            ST_EOR : undat_alu_opt = ALU_EOR;
                            ST_SET : undat_alu_opt = ALU_SET;
                            ST_SMAX: undat_alu_opt = ALU_SMAX;
                            ST_SMIN: undat_alu_opt = ALU_SMIN;
                            ST_UMAX: undat_alu_opt = ALU_UMAX;
                            ST_UMIN: undat_alu_opt = ALU_UMIN;                      
                            default: unsupported_condition=13;
                            endcase
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;  
                    
                    end
                    RSP_TYPE_EVBUF_Evict:begin 
                        case(rxdat_resp)
                        3'b100: begin //DAT_SnpRespData_I_PD
                            //send update req to main memory
                            if( expct_rsp_to_rxrsp_ready_wr & snpf_to_rxrsp_wr_chnl_ready & txreq_to_rxdat_ready & undat_to_rxdat_ready)begin
                                    expct_rsp_action=EXPCT_RMV_SRC_ADD_SNF_ADD_DAT;
                                    txreq_action = TXREQ_WriteNoSnpFull;//send write req to sn 
                                    snpf_state_action= SNPF_EVICT;
                                    undat_action =UNDAT_WR_LKPT;
                                    undat_core_action =  SAVE_ALU_TX_OFF;
                                   
                                   
                                   
                                    last_dat_is_not_proceed_next=1'b0;
                                end
                                else last_dat_is_not_proceed_next=1'b1; 
                           
                            
                        end
                        default: begin 
                            unsupported_condition=10; 
                        end
                        endcase
                    
                    end
                    
                    
                    
                    default unsupported_condition=7; 
                    endcase
                         

                end else begin // if(~got_all_responses) begin
                    if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin
                        undat_action =UNDAT_WR_LKPT;
                        undat_core_action = SAVE_ALU_TX_OFF;
                        if  (lkpt_rsp_type != RSP_TYPE_EVBUF_Evict  && rxdat_resp == 3'b000)  snpf_spv_action=SNPF_REMOVE_SRC; 
                        expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;                         
                        //TODO we got dirty result and the RN did not forward the data to requester we have to do it by home node
                        if(lkpt_rsp_type == RSP_TYPE_SnpSharedFwd && rxdat_resp == 3'b100) unsupported_condition= 17;// SnpRespDataPtl_I_PD for share forward)
                        //this response is proceeded read the next one. give priority now to undata
                        last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1;
                end//  ~got_all_responses                  
            end//OPCODE_DAT_SnpRespData
            
            OPCODE_DAT_NonCopyBackWrData: begin 
                case(lkpt_rsp_type) 
                RSP_TYPE_WriteUniqueFull:begin 
                     if(got_all_responses) begin 
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr  & undat_to_rxdat_ready ) begin
                            if(rxdat_resp != 3'b000) unsupported_condition=9; //currently  support only NCBWrData_I 
                            snpf_spv_action=SNPF_REMOVE_SRC; 
                            //snpf_busy_action= SNPF_BUSY_CLEAR; busy bit will be deasserted later by undat 
                            //snpf_syscache_action=SNPF_ADD_TO_SYSCACHE;  //will be dne later by undat                         
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                            rxdat_to_undat_cache_wr=1'b1;                       
                            undat_action=UNDAT_NCBWrData_I;
                            rxdat_to_undat_txnid_release=1'b1; //txn_action=TXN_ENDED;  
                            rxdat_to_undat_snpf_update=1'b1;//snpf_busy_action = SNPF_BUSY_CLEAR; 
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;
                     end else begin // got_all_responses
                        if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr  & undat_to_rxdat_ready)begin
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action = SAVE_ALU_TX_OFF;
                            
                            if  (rxdat_resp != 3'b000)  unsupported_condition=18;  
                            snpf_spv_action=SNPF_REMOVE_SRC;
                            //snpf_syscache_action=SNPF_ADD_TO_SYSCACHE;//will be done bu undat 
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT; 
                            rxdat_to_undat_cache_wr=1'b1; 
                            rxdat_to_undat_snpf_update=1'b1;
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;                  
                     end //~got_all_response
                
                end
                LD_ADD,LD_CLR,LD_EOR,LD_SET,LD_SMAX,
                LD_SMIN ,LD_UMAX,LD_UMIN,LD_SWAP,LD_COMP:begin 
                    if(got_all_responses) begin 
                        if(expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready)begin
                        
                            //we have the txndat in current datflit, so old data is saved in lkpt and we have to send it back to requester
                            undat_core_action =   SAVE_ALU_TX_DIN;
                            undat_action = UNDAT_FW_CompData_UC;
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;  
                            txreq_action = TXREQ_WriteNoSnpFull;//write txnreq to sn 
                            undat_init_flag=LKPT_IS_INIT;
                            case (lkpt_rsp_type)
                            LD_ADD : undat_alu_opt = ALU_ADD;
                            LD_CLR : undat_alu_opt = ALU_CLR;  
                            LD_EOR : undat_alu_opt = ALU_EOR;
                            LD_SET : undat_alu_opt = ALU_SET;
                            LD_SWAP: undat_alu_opt = ALU_SWAP;
                            LD_SMAX: undat_alu_opt = ALU_SMAX;
                            LD_SMIN: undat_alu_opt = ALU_SMIN;
                            LD_UMAX: undat_alu_opt = ALU_UMAX;
                            LD_UMIN: undat_alu_opt = ALU_UMIN;
                            default: unsupported_condition=13;
                            endcase
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1; 
                            
                    
                    end else begin // got_all_responses
                    // we have to save data and wait for old data to be pereped
                        if(undat_to_rxdat_ready & expct_rsp_to_rxrsp_ready_wr)begin     
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action = SAVE_ALU_TX_OFF;
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT; 
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;  
                    end               
                end//AtomicLoad
                ST_ADD,ST_CLR,ST_EOR,ST_SET,
                ST_SMAX,ST_SMIN,ST_UMAX,ST_UMIN:begin 
                    if(got_all_responses) begin 
                        if(expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready & txreq_to_rxdat_ready & txrsp_to_rxrsp_ready)begin
                        
                            //we have the txndat in current datflit, so old data is saved in lkpt and we have to send it back to requester
                            undat_init_flag=LKPT_IS_INIT;
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action =  SAVE_ALU_TX_OFF;// execute atomic transaction and save it in lkpt
                            
                            txrsp_action= TXRSP_Comp_I;//send comp to source
                                                        
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;  
                            txreq_action = TXREQ_WriteNoSnpFull;//write txnreq to sn 
                            
                            case (lkpt_rsp_type)
                            ST_ADD : undat_alu_opt = ALU_ADD;
                            ST_CLR : undat_alu_opt = ALU_CLR;  
                            ST_EOR : undat_alu_opt = ALU_EOR;
                            ST_SET : undat_alu_opt = ALU_SET;
                            ST_SMAX: undat_alu_opt = ALU_SMAX;
                            ST_SMIN: undat_alu_opt = ALU_SMIN;
                            ST_UMAX: undat_alu_opt = ALU_UMAX;
                            ST_UMIN: undat_alu_opt = ALU_UMIN;
                            default: unsupported_condition=13;
                            endcase
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1; 
                            
                    
                    end else begin // got_all_responses
                    // we have to save data and wait for old data to be pereped
                        if(undat_to_rxdat_ready & expct_rsp_to_rxrsp_ready_wr)begin     
                            undat_action =UNDAT_WR_LKPT;
                            undat_core_action = SAVE_ALU_TX_OFF;
                            expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT; 
                            last_dat_is_not_proceed_next=1'b0;
                        end
                        else last_dat_is_not_proceed_next=1'b1;  
                    end               
                end//loadtransactions
                
                default  unsupported_condition=13;
                endcase
                
            end //OPCODE_DAT_NonCopyBackWrData  
            
            OPCODE_DAT_CopyBackWrData: begin 
                if(lkpt_rsp_type != RSP_TYPE_WriteBackFull) unsupported_condition=13;
                if(got_all_responses) begin 
                    if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr  & undat_to_rxdat_ready ) begin
                       // if(rxdat_resp != 3'b000) unsupported_condition=19; //currently  support only CBWrData_I 
                        snpf_spv_action=SNPF_REMOVE_SRC; 
                        //snpf_busy_action= SNPF_BUSY_CLEAR; will be done by undat   
                        //snpf_syscache_action=SNPF_ADD_TO_SYSCACHE; will be done by undat                          
                        expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT;
                        rxdat_to_undat_cache_wr=1'b1;                          
                        undat_action=UNDAT_CBWrData_I;
                        rxdat_to_undat_txnid_release=1'b1; // txn_action=TXN_ENDED;   
                        rxdat_to_undat_snpf_update=1'b1;//snpf_busy_action = SNPF_BUSY_CLEAR; 
                        last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1;
                 end else begin // got_all_responses
                    if(snpf_to_rxrsp_wr_chnl_ready & expct_rsp_to_rxrsp_ready_wr & undat_to_rxdat_ready)begin
                        undat_action =UNDAT_WR_LKPT;
                        undat_core_action = SAVE_ALU_TX_OFF;
                       // if  (rxdat_resp != 3'b000)  unsupported_condition=20;  //currently  support only CBWrData_I 
                        snpf_spv_action=SNPF_REMOVE_SRC;
                        //snpf_syscache_action=SNPF_ADD_TO_SYSCACHE; //will be done by undat
                        expct_rsp_action= EXPCT_RMV_SRC_ADD_DAT; 
                        rxdat_to_undat_cache_wr=1'b1;  
                        rxdat_to_undat_snpf_update=1'b1;
                        last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1;                  
                 end //~got_all_response
            end //OPCODE_DAT_NonCopyBackWrData  
            
            
            
            
            default: unsupported_condition=11;
                      
            endcase   
            
            
        end       
        endcase
        end// always 
     
     
    
    
    
    assign rxrsp_to_expct_rsp_txnid_rd = rxrsp_to_lkpt_txnid;    
    assign rxrsp_to_expct_rsp_valid_rd = rxrsp_to_lkpt_rd_valid;
  //  assign rxrsp_to_datlkpt_rd_valid = rxrsp_to_lkpt_rd_valid;
   
   
   
   
   reg [1: 0] wr_spv_action, wr_busy_bit_action, wr_sys_cache_action;  
   assign rxrsp_to_snpf_action = {wr_sys_cache_action,wr_busy_bit_action,wr_spv_action};  
   
   wire [SNPF_SPVw-1 : 0] lkpt_spv;
    rnfid_to_spv_addr_decode #(
        .SPVw(SNPF_SPVw),
        .IDw(SRCID_RSP)
    )
    lkpt_decode
    (
        .rnf_id_i(lkpt_srcid),
        .rnf_spv_o(lkpt_spv)
    );
   
    //expct
    always @(*) begin 
        rxrsp_to_expct_rsp_dat_wr = {expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw], expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-1 : 0] & ~src_spv[SNPF_SPVw-1 : 0]};//defaut for RMV_SRC
        rxrsp_to_expct_rsp_valid_wr = 1'b0; 
        case(expct_rsp_action)
        EXPCT_RMV_ALL_RNS: begin 
            rxrsp_to_expct_rsp_dat_wr = {expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw],1'b1,{(SNPF_SPVw-1){1'b0}}};
            rxrsp_to_expct_rsp_valid_wr = 1'b1; 
        end
        EXPCT_RMV_SRC_ADD_SNF_ADD_DAT:begin 
            rxrsp_to_expct_rsp_dat_wr = {2'b11,expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-2 : 0] & ~src_spv[SNPF_SPVw-2 : 0]};
            rxrsp_to_expct_rsp_valid_wr = 1'b1;//update snpresp 
        end
        EXPCT_RMV_SRC_ADD_SNF_DAT_REQUSTER: begin
            rxrsp_to_expct_rsp_dat_wr = ({2'b11,expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-2 : 0] & ~src_spv[SNPF_SPVw-2 : 0]})| lkpt_spv;
           // rxrsp_to_expct_rsp_dat_wr[lkpt_srcid]=1'b1;
            rxrsp_to_expct_rsp_valid_wr = 1'b1;//update snpresp 
        
        end
        EXPCT_RMV_SRC:begin 
            rxrsp_to_expct_rsp_valid_wr = 1'b1; 
        end
        EXPCT_RMV_SRC_ADD_DAT: begin 
            rxrsp_to_expct_rsp_dat_wr = {1'b1,expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-1 : 0] & ~src_spv[SNPF_SPVw-1 : 0]};
            rxrsp_to_expct_rsp_valid_wr = 1'b1;//update snpresp 
        end
        endcase
    end
    
  
       
   
    
    //snpf
    always @(*)begin 
        rxrsp_to_snpf_wr_en= 1'b0;
        rxrsp_to_snpf_wr_evict=1'b0;
    //    rxrsp_to_snpf_wr_state = lkpt_snpf_state;//new cache status
        rxrsp_to_snpf_update_state = 1'b0; 
        rxrsp_to_snpf_wr_spv = {1'b0,src_spv[SNPF_SPVw-2 : 0]};
        rxrsp_to_snpf_wr_addr= lkpt_addr;
        wr_spv_action =SNPF_NO_CHANGE;
        wr_busy_bit_action =SNPF_NO_CHANGE;
        wr_sys_cache_action = SNPF_NO_CHANGE;
        
        case(snpf_spv_action)
        SNPF_ADD_SRC:begin 
            wr_spv_action =SNPF_ASSERT; // add RN to SPV  SNPF_NO_CHANGE
            rxrsp_to_snpf_wr_en= 1'b1;
        end
        SNPF_REMOVE_SRC: begin
            wr_spv_action =SNPF_CLEAR; // remove RN from SPV
            rxrsp_to_snpf_wr_en= 1'b1;
        end      
        endcase
        
        
        
        case(snpf_busy_action)
        SNPF_BUSY_CLEAR: begin
            wr_busy_bit_action=SNPF_CLEAR;  
            rxrsp_to_snpf_wr_en= 1'b1;    
        end
        endcase
       
        
        
        
        
        case(snpf_state_action)
        /*
        SNPF_ST_ADD_I: begin
            rxrsp_to_snpf_wr_state  = SNPF_I;
            rxrsp_to_snpf_update_state=1'b1;
            rxrsp_to_snpf_wr_en= 1'b1;       
        end        
        SNPF_ST_ADD_U: begin
            rxrsp_to_snpf_wr_state  = SNPF_U;
            rxrsp_to_snpf_update_state=1'b1;
            rxrsp_to_snpf_wr_en= 1'b1;       
        end
        SNPF_ST_ADD_S: begin
            rxrsp_to_snpf_wr_state  = SNPF_S;
            rxrsp_to_snpf_update_state=1'b1;
            rxrsp_to_snpf_wr_en= 1'b1;         
        end   
        */
        SNPF_EVICT:begin 
            rxrsp_to_snpf_wr_evict=1'b1;
            rxrsp_to_snpf_wr_en= 1'b1; 
        end
        endcase
        
       
    end
   
   
   
   
   
   
   
   assign rxdat_to_undat_action={undat_init_flag,undat_core_action,undat_alu_opt};
   
    //undata
    always @(*) begin
        rxdat_to_undat_wr=1'b0;
        rxdat_to_undat_dat = rxdat_data;
        rxdat_to_undat_tgtid = lkpt_srcid;   // read it from lookup table
        rxdat_to_undat_txnid = lkpt_txnid;
        rxdat_to_undat_dbid = current_txnid;
        rxdat_to_undat_opcode = OPCODE_DAT_CompData;
        rxdat_to_undat_resp = 3'b000;
        rxdat_to_undat_resperr= (lkp_rsperr_flag)?   Excl_Okey : Normal_Okay;
      
        
        
        case( undat_action)
        UNDAT_TXN_END:begin 
             rxdat_to_undat_txnid = current_txnid;
            rxdat_to_undat_wr=1'b1;
        end
        UNDAT_WR_LKPT: begin 
          
            rxdat_to_undat_txnid = current_txnid;
            rxdat_to_undat_wr=1'b1;
        end        
        UNDAT_FW_CompData_I: begin   
            rxdat_to_undat_wr=1'b1;
        end
        UNDAT_FW_CompData_UC: begin
            rxdat_to_undat_resp = 3'b010;
            rxdat_to_undat_wr=1'b1;
        end
        UNDAT_FW_CompData_SC: begin 
            rxdat_to_undat_resp = 03'b001;
            rxdat_to_undat_wr=1'b1;
        end
        UNDAT_NCBWrData_I: begin 
            rxdat_to_undat_tgtid = snf_id [TGTID_REQ-1:0];   // send data to SN
            rxdat_to_undat_txnid = current_txnid;
            rxdat_to_undat_opcode = OPCODE_DAT_NonCopyBackWrData;
            rxdat_to_undat_wr=1'b1;
        
        end
        UNDAT_CBWrData_I:begin 
            rxdat_to_undat_tgtid = snf_id [TGTID_REQ-1:0];   // send data to SN
            rxdat_to_undat_txnid = current_txnid;
            rxdat_to_undat_opcode = OPCODE_DAT_CopyBackWrData;
            rxdat_to_undat_wr=1'b1;
        
        end
        endcase
    end
    
    
  
    
    
    
    
    
    //txreq
    always @(*)begin 
        //default for readnosnoop WriteNoSnpFull to SN
        rxdat_to_txreq_wr = 1'b0;  
        rxdat_to_txreq_opcode = REQ_OPCODE_WriteNoSnpFull;
        rxdat_to_txreq_tgtid = snf_id[TGTID_REQ-1:0];        
        rxdat_to_txreq_txnid = current_txnid;
        
        rxdat_to_txreq_returnnid = src_id[RETURNNID_REQ-1 : 0];
        rxdat_to_txreq_returntxnid = current_txnid;
        rxdat_to_txreq_addr = lkpt_addr;
        rxdat_to_txreq_likelyshared = 1'b0;
        case(txreq_action)
        TXREQ_WriteNoSnpFull: begin             
            rxdat_to_txreq_wr = 1'b1;
        end
        TXREQ_IDMT_ReadNoSnp:begin 
            rxdat_to_txreq_opcode= REQ_OPCODE_ReadNoSnp;
            rxdat_to_txreq_wr = 1'b1;
        end
        endcase
    end//always        
    
    
      
    
    
    
    
    
    
    
    //rxreq
    always @(*) begin
        rxrsp_to_txgen_txnid_release=1'b0;
        //default for RSP_OPCODE_CompAck
        rxrsp_to_txgen_txnid = current_txnid;//release this id;       
        case(txn_action)
        TXN_ENDED:begin
            rxrsp_to_txgen_txnid_release=1'b1; 
        end
        endcase
    end
   
   // txrsp
    always @(*) begin
        rxrsp_to_txrsp_wr_en=1'b0;
        // defualt for Comp_UC
        rxrsp_to_txrsp_txnid=lkpt_txnid;
        rxrsp_to_txrsp_tgtid=lkpt_srcid;
        rxrsp_to_txrsp_opcode= RSP_OPCODE_Comp;
        rxrsp_to_txrsp_resp= 3'b010; //resp for Comp_UC
        rxrsp_to_txrsp_resperr= (lkp_rsperr_flag)?   Excl_Okey : Normal_Okay;
        rxrsp_txsnp_dbid=current_txnid;
        case(txrsp_action)
        TXRSP_Comp_I:begin 
            rxrsp_to_txrsp_resp= 3'b000; //resp for Comp_I
            rxrsp_to_txrsp_wr_en=1'b1;
        end
        TXRSP_Comp_UC: begin
            rxrsp_to_txrsp_wr_en=1'b1;
        end
        endcase
    end    
       
        
         
         
        
        always @ (posedge clk or posedge reset)begin 
            if(reset) begin 
               // chi_noc_rxrsplcrdv<=1'b0;
                chi_noc_rxdatlcrdv<=1'b0;
                pst<= IDEAL;
            end else begin 
              //  chi_noc_rxrsplcrdv<=rxrsp_read_fifo_en;
                chi_noc_rxdatlcrdv<=rxdat_read_fifo_en;
                pst<=nst;
            end
        end
        
    
     //synthesis translate_off 
    //synopsys  translate_off
    reg [111 : 0] undat_str;
    always @(*)begin 
        undat_str= "UNDEF";
        case(undat_action)
        UNDAT_WR_LKPT:          undat_str= "WR_LKPT"        ;
        UNDAT_FW_CompData_I:    undat_str= "FW_CompData_I"   ;
        UNDAT_FW_CompData_UC:   undat_str= "FW_CompData_UC"  ;
        UNDAT_FW_CompData_SC:   undat_str= "FW_CompData_SC"  ;
        UNDAT_NCBWrData_I:      undat_str= "NCBWrData_I"     ;
        UNDAT_CBWrData_I:       undat_str= "CBWrData_I"      ;
        UNDAT_TXN_END:          undat_str= "UNDAT_TXN_END";
        endcase
    end
    
    
    reg [111 : 0] rsp_str;
    always @(*)begin 
       rsp_str= "UNDEF";
      case(txrsp_action)
        TXRSP_Comp_I:   rsp_str="TXRSP_Comp_I";
        TXRSP_Comp_UC:  rsp_str="TXRSP_Comp_UC";
      endcase
    end  
    
    
     wire got_data = rxrsp_to_expct_rsp_dat_wr[SNPF_SPVw];
    
    
    always @(posedge clk)begin 
        
        
        
        if( unsupported_condition>0)begin 
            $display("%t: hnf ( %d ) txn ( %d ) Error: rxrsp got an unsupported condition ( %d ), lkpt_rsp_type ( %h ) ",$time,src_id, current_txnid, unsupported_condition,lkpt_rsp_type);
            $stop;
        end
        if (rxrsp_to_expct_rsp_valid_wr & ~got_all_responses & ((expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-1 : 0] & src_spv[SNPF_SPVw-1 : 0])==0)) begin
             $display("%t: hnf ( %d ) txn ( %d ) Error :rxrsp/rxdat got an unexpected response flit on expected ( %b ) but got on ( %b )",$time,src_id,rxrsp_to_expct_rsp_txnid_wr,expct_rsp_to_rxrsp_dat_rd[SNPF_SPVw-1 : 0],src_spv);
             $stop;
        end
        
        if ( undat_action != 0 && (got_data ==0) && undat_action!=UNDAT_TXN_END) begin 
             $display("%t: hnf ( %d ) txn ( %d ) Error :rxrsp/rxdat have not get any response with valid data to send. Need to ask SN now which is not yet implimented",$time,src_id,current_txnid);
             /* verilator lint_off STMTDLY */
             #10  $stop;
            /* verilator lint_on STMTDLY */
        end
       
        if((VERBOSITY & MONITORE_TXN_CMD) > 0) begin  
            if( undat_action!=0 ) $display("%t: hnf ( %d ) txn ( %d ) sends %s to Data processing Unit" ,$time,src_id,current_txnid,undat_str);  
            if( txrsp_action!=0 ) $display("%t: hnf ( %d ) txn ( %d ) sends %s to core (%d)" ,$time,src_id,current_txnid, rsp_str,lkpt_srcid);  
            if( snpf_state_action ==  SNPF_EVICT)  $display("%t: hnf ( %d ) txn ( %d ) sends eviction" ,$time,src_id,current_txnid);       
            if( txreq_action == TXREQ_WriteNoSnpFull) $display("%t: hnf ( %d ) txn ( %d ) sends TXREQ_WriteNoSnpFull to reqchanel" ,$time,src_id,current_txnid);
            if( txreq_action == TXREQ_IDMT_ReadNoSnp) $display("%t: hnf ( %d ) txn ( %d ) sends TXREQ_IDMT_ReadNoSnp to reqchanel" ,$time,src_id,current_txnid);       
      
        
        
        
        
        end 
         
    end
    
   
    generate
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) > 0)begin 
        monitor_rsp_flit #(
        	// .src_id(src_id),
        	.TYPE("RX"),
        	.AGENT_NAME("hnf")
        )
        monitor_rsp
        (
        	.src_id(src_id),
        	.clk(clk),
        	.monitor(noc_chi_rxrspflitv),
        	.rsp_flit( noc_chi_rxrspflit)
        );
    end
    endgenerate
    
    
     //synthesis translate_on 
    //synopsys  translate_on  
  
    
    
    

endmodule



// currently we dont use retry only make a large buffer


module  hnf_rsv_extend_buffer #(
    parameter B=4,
    parameter EXTND_B=8,
    parameter Dw=32

   )(
   
    // CHI RXREQ
    noc_chi_rxflitpend,
    noc_chi_rxflitv,
    noc_chi_rxflit,          
    chi_noc_rxlcrdv,      
    
    // to buffer
    rxflitpend,
    rxflitv,
    rxflit,          
    rxlcrdv,      
 
    reset,
    clk
);

  

       // RXREQ
    input   noc_chi_rxflitpend ;
    input   noc_chi_rxflitv;
    input  [Dw-1:0]    noc_chi_rxflit;          
    output reg chi_noc_rxlcrdv;   

   
    output   rxflitpend ;
    output  reg rxflitv;
    output  [Dw-1:0]    rxflit;          
    input  rxlcrdv;   

    assign rxflitpend=1'b1;
    
    input reset,clk;
    
    
    reg read_fifo_en ;
    wire fifo_empty;
    localparam IDEAL=1;
    localparam PROCESS_REQ=2;
    reg [1:0] pst;
    reg [1:0] nst;
   
    fifo #(
        .Dw(Dw),
        .B(EXTND_B)
    )
    flit_fifo
    (
        .din(noc_chi_rxflit),
        .wr_en(noc_chi_rxflitv),
        .rd_en(read_fifo_en ),
        .dout(rxflit),
        .full(),
        .nearly_full(),
        .empty(fifo_empty),
        .reset(reset),
        .clk(clk)
    ); 
    
    wire buff_ready;
    
     credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(rxflitv),
        .noc_chi_lcrdv(rxlcrdv),
        .have_cridit(buff_ready),
        .nearly_full(),
        .reset(reset),
        .clk(clk)
     );
    
    
    
 always @(*)begin 
        read_fifo_en=1'b0;
        nst=pst;
        rxflitv=1'b0;
  
        
  
         
        case(pst)
        IDEAL: begin 
            if(~fifo_empty  )begin 
                nst=PROCESS_REQ;
                read_fifo_en=1'b1;            
            end        
        end 
        PROCESS_REQ: begin 
            if(buff_ready) begin         
                rxflitv=1'b1;   
                if(~fifo_empty )begin read_fifo_en=1'b1;  end else begin nst=IDEAL;
                end
            end
        end//   PROCESS_REQ  
        endcase        
    end
    
    
     always @(posedge clk) begin
        if(reset) begin          
          
            pst<=IDEAL;
        end  else begin 
            
            pst<=nst;            
        end
    end
    
    
      function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
        
    localparam  EBw = log2(EXTND_B+1);
    
    reg [EBw-1 : 0] credit_counter;
        
        
    
    always@(posedge clk or posedge reset)begin
        if(reset)begin
            credit_counter <={EBw{1'b0}};           
        end else begin
            if(  noc_chi_rxflitv   & ~ read_fifo_en)   credit_counter <= credit_counter+1'b1;
            if( ~noc_chi_rxflitv   &   read_fifo_en)   credit_counter <= credit_counter-1'b1;           
        end //reset
     end//always


    always @(posedge clk or posedge reset) begin
        if (reset) chi_noc_rxlcrdv<=1'b0;
        else begin 
            if(credit_counter < (EXTND_B-B))begin 
                chi_noc_rxlcrdv<=noc_chi_rxflitv;              
            
            end else if (credit_counter == (EXTND_B-B) ) begin 
                 chi_noc_rxlcrdv<=noc_chi_rxflitv &read_fifo_en ;  
            
            end else begin    
                 chi_noc_rxlcrdv<=read_fifo_en; 
                                        
            end
        end
    end
    
   

endmodule






