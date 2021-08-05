/*********************
* 
* *****************/
`timescale   1ns/1ns

module  rnf_rxdata_rxrsp #(
     parameter VERBOSITY=0,
    // parameter src_id=0,
     parameter B=4
     )(
    
    src_id,
    //CHI RXDAT 
    noc_chi_rxdatflitpend,
    noc_chi_rxdatflitv,
    noc_chi_rxdatflit,
    chi_noc_rxdatlcrdv,    
    
    //CHI CRSP/RXRSP
    noc_chi_rxrspflitpend, 
    noc_chi_rxrspflitv, 
    noc_chi_rxrspflit, 
    chi_noc_rxrsplcrdv, 
    
    
    //txrsp
    txrsp_to_rxdat_ready,
    rxdat_to_txrsp_wr_en,
    rxdat_to_txrsp_txnid,
    rxdat_to_txrsp_tgtid,
    rxdat_to_txrsp_opcode,
    rxdat_to_txrsp_resp,
    rxdat_txsnp_dbid,
    
    //cache_wr    
    rxdat_to_cache_wr_addr,
    rxdat_to_cache_wr_data,
    rxdat_to_cache_wr_evict,
    rxdat_to_cache_wr_state,
    rxdat_to_cache_wr_action,
    rxdat_to_cache_wr_en,
    cache_to_rxdat_wr_hit,    
    cache_to_rxdat_wr_ready,
    cache_to_rxdat_wr_done,  
    
    //cache_rd
    rxrsp_to_cache_rd_addr,
    cache_to_rxrsp_rd_data,
    rxrsp_to_cache_rd_en,
    cache_to_rxrsp_rd_ready,   
    cache_to_rxrsp_rd_state,
    cache_to_rxrsp_rd_hit,
    cache_to_rxrsp_rd_done,
            
    //datlkpt-rxrsp
    rxrsp_to_datlkpt_txnid, 
    rxrsp_to_datlkpt_rd_valid,
    datlkpt_to_rxrsp_txndat,    
    
    //txdat
    txdat_to_undat_nearly_full,
    txdat_to_undat_ready,
    undat_to_txdat_wr,
    undat_to_txdat_dat,
    undat_to_txdat_tgtid,
    undat_to_txdat_txnid,
    undat_to_txdat_dbid,
    undat_to_txdat_opcode,
    undat_to_txdat_resp,
    undat_to_txdat_homenid,
    
    
    //txn lookup
    rxdat_to_lkpt_txnid,
    rxdat_to_lkpt_rd_valid, 
    lkpt_to_rxdat_txndat,
    
    //txreq
    rxrsp_to_txreq_txnid,
    rxrsp_to_txreq_txnid_release,   
    
    //general
    reset,
    clk      
    );
    
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
    
    input [31 : 0] src_id; 
    
    input reset,clk;
    
   
    
    //CHI RXDAT 
    input    noc_chi_rxdatflitpend ;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output   reg chi_noc_rxdatlcrdv ; 
    
    
    //CHI CRSP/RXRSP
    input    noc_chi_rxrspflitpend ;
    input    noc_chi_rxrspflitv ;
    input   [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit ;
    output reg   chi_noc_rxrsplcrdv ;
    
    //txrsp
    input  txrsp_to_rxdat_ready;
    output reg rxdat_to_txrsp_wr_en;
    output reg [TXNID_RSP-1:0] rxdat_to_txrsp_txnid;
    output reg [TGTID_RSP-1:0] rxdat_to_txrsp_tgtid;
    output reg [OPCODE_RSP-1:0] rxdat_to_txrsp_opcode;
    output reg [RESP_RSP-1:0] rxdat_to_txrsp_resp;
    output reg [TXNID_RSP-1:0] rxdat_txsnp_dbid;
    
        
    // from txn lookup
    // txn lookup
    output  [TXNID_REQ-1 :  0] rxdat_to_lkpt_txnid;
    output  rxdat_to_lkpt_rd_valid;
    input  [RNF_TXN_DATAw-1 :  0] lkpt_to_rxdat_txndat;        
    
        
    
    // chache_wr
    output reg [ADDR_REQ-1 :0  ] rxdat_to_cache_wr_addr;
    output reg [DATA_DAT-1 : 0] rxdat_to_cache_wr_data;
    output reg [CACHE_STATUSw-1:0] rxdat_to_cache_wr_state;
    output reg [CACHE_ACTw-1:0] rxdat_to_cache_wr_action;
    output  reg rxdat_to_cache_wr_en;
    output  rxdat_to_cache_wr_evict;
    input cache_to_rxdat_wr_hit;
    input cache_to_rxdat_wr_done;
    input cache_to_rxdat_wr_ready;
    
    
    //cache_rd
    output [ADDR_REQ-1 : 0] rxrsp_to_cache_rd_addr;
    output rxrsp_to_cache_rd_en;
    input  [DATA_DAT-1 : 0] cache_to_rxrsp_rd_data;    
    input cache_to_rxrsp_rd_ready;   
    input [CACHE_STATUSw-1 : 0] cache_to_rxrsp_rd_state;
    input cache_to_rxrsp_rd_hit;
    input cache_to_rxrsp_rd_done;        
    
    //txdat
    input  txdat_to_undat_ready , txdat_to_undat_nearly_full;
    output reg [DATA_DAT-1 : 0] undat_to_txdat_dat;
    output reg undat_to_txdat_wr;
    output reg [TGTID_DAT-1:0]  undat_to_txdat_tgtid;
    output reg [TXNID_DAT-1:0]  undat_to_txdat_txnid;
    output reg [TXNID_DAT-1:0]  undat_to_txdat_dbid;
    output reg [RESP_DAT-1 : 0] undat_to_txdat_resp;
    output reg [OPCODE_DAT-1 : 0] undat_to_txdat_opcode;
    output reg [SRCID_DAT-1:0] undat_to_txdat_homenid;
    
    //datlkpt-rxrsp
    output reg [TXNID_REQ-1 : 0] rxrsp_to_datlkpt_txnid;
    output reg rxrsp_to_datlkpt_rd_valid;
    input  [DATA_DAT+OPCODE_REQ-1  : 0] datlkpt_to_rxrsp_txndat;
    
    output reg [TXNID_REQ-1 :  0] rxrsp_to_txreq_txnid;
    output reg rxrsp_to_txreq_txnid_release;         
    
    
    //rxdata
    
    wire [DAT_FLIT_SIZE-1 : 0] current_rxdatflit;    
   // wire [TXNID_DAT-1:0] rxdat_txnid_next;
    
    //data fileds
    wire [QOS_DAT-1:0]             rxdat_qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_DAT-1:0]           rxdat_tgtid  ;
    wire [SRCID_DAT-1:0]           rxdat_srcid  ;
    wire [TXNID_DAT-1:0]           rxdat_txnid  ;
    wire [HOMENID_DAT-1:0]         rxdat_homenid; // 
    wire [OPCODE_DAT-1:0]          rxopcode_dat ;
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
    
          
    
   reg rxdat_read_fifo_en;
   wire rxdat_fifo_empty; 
   wire rxdat_fifo_not_empty = ~ rxdat_fifo_empty;
   wire [OPCODE_REQ-1  : 0] datlkpt_to_rxrsp_req_opcode=    datlkpt_to_rxrsp_txndat [DATA_DAT+OPCODE_REQ-1  : DATA_DAT];
   wire [TXNID_DAT-1:0]  rxdat_txnid_in = noc_chi_rxdatflit[DAT_FLIT_SIZE-1-(QOS_DAT+TGTID_DAT+SRCID_DAT) :    DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT)-TXNID_DAT];
  
  
    
   bram_based_fifo #(
   	.Dw(DAT_FLIT_SIZE),
   	.B(B)
   )
   rxdat_fifo
   (
   	.din(noc_chi_rxdatflit),
        .wr_en(noc_chi_rxdatflitv),
        .rd_en(rxdat_read_fifo_en ),
        .dout(current_rxdatflit),
        .full( ),
        .nearly_full( ),
        .empty(rxdat_fifo_empty ),
        .reset(reset),
        .clk(clk)
   ); 
    
   assign {rxdat_qos,rxdat_tgtid,rxdat_srcid ,rxdat_txnid ,rxdat_homenid ,rxopcode_dat ,rxdat_resperr, rxdat_resp ,rxdat_fwd_datapull ,rxdat_dbid ,rxdat_ccid ,rxdat_dataid ,rxdat_tracetag ,rxdat_be ,rxdat_data ,rxdat_datacheck  ,rxdat_poison} = current_rxdatflit; 
    
  
  
  //this fifo and data lkpt should be removed later and take cache data instead
  wire [TXNID_DAT-1:0] rxdat_txnid_next;  
   fwft_fifo #(
    .DATA_WIDTH(TXNID_DAT),
    .MAX_DEPTH(B),
    .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
   )
   rxdat_txnid_fifo
   (
    .din(rxdat_txnid_in),
    .wr_en(noc_chi_rxdatflitv),
    .rd_en(rxdat_read_fifo_en),
    .dout(rxdat_txnid_next),
    .full(),
    .nearly_full(),
    .recieve_more_than_0(),
    .recieve_more_than_1(),
    .reset(reset),
    .clk(clk)
   );
    
 
  
  
   
   
   //rxrsp
    wire [RSP_FLIT_SIZE-1 : 0] current_rxrspflit;
    wire [TXNID_RSP-1:0] rxrsp_txnid_next;
   
    wire [QOS_RSP-1:0]             rxrsp_qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           rxrsp_tgtid  ;
    wire [SRCID_RSP-1:0]           rxrsp_srcid  ;
    wire [TXNID_RSP-1:0]           rxrsp_txnid  ;
    wire [OPCODE_RSP-1:0]          rxrsp_opcode ;
    wire [RESPERR_RSP-1:0]         rxrsp_resperr;     
    wire [RESP_RSP-1:0]            rxrsp_resp;
    wire [FWD_DATAPULL_RSP-1:0]    rxrsp_fwd_datapull;
    wire [DBID_RSP-1:0]            rxrsp_dbid;
    wire [PCRDTYPE_RSP-1:0]        rxrsp_pcrdtype; // = 4'b0000;
    wire                           rxrsp_tracetag; // = 1'b0;


    reg rxrsp_read_fifo_en;
    wire rxrsp_fifo_empty; 
    wire rxrsp_fifo_not_empty = ~ rxrsp_fifo_empty;

     
    bram_based_fifo #(
        .Dw(RSP_FLIT_SIZE),
        .B(B)
    )
    rxrsp_flit_fifo
    (
        .din(noc_chi_rxrspflit),
        .wr_en(noc_chi_rxrspflitv),
        .rd_en(rxrsp_read_fifo_en ),
        .dout(current_rxrspflit),
        .full(),
        .nearly_full(),
        .empty(rxrsp_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
      assign {rxrsp_qos, rxrsp_tgtid,   rxrsp_srcid,   rxrsp_txnid,   rxrsp_opcode,  rxrsp_resperr,    rxrsp_resp,  rxrsp_fwd_datapull,  rxrsp_dbid,   rxrsp_pcrdtype,  rxrsp_tracetag} = current_rxrspflit;
 
    
   
    wire [TXNID_RSP-1:0] rxrsp_txnid_in;
    get_rsp_flit_txnid get_rsp_flit_txnid(
        .rspflit(noc_chi_rxrspflit),
        .txnid(rxrsp_txnid_in)
    );
    
    
    
    
     fwft_fifo #(
        .DATA_WIDTH(TXNID_RSP),
        .MAX_DEPTH(B),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    rxrsp_txnid_fifo
    (
        .din(rxrsp_txnid_in),
        .wr_en(noc_chi_rxrspflitv),
        .rd_en(rxrsp_read_fifo_en),
        .dout(rxrsp_txnid_next),
        .full(),
        .nearly_full(),
        .recieve_more_than_0(),
        .recieve_more_than_1(),
        .reset(reset),
        .clk(clk)
    );
   
    
    
    
    
     
    wire  [DATA_DAT-1 : 0] txn_cache_data_o;
    wire  [OPCODE_REQ-1:0] txn_req_opcode_o;
    wire  [ADDR_REQ-1:0]   txn_addr_o; 
    wire  [CACHE_STATUSw-1: 0] txn_cache_state_o;
    wire  txn_req_excl_o;
    wire  txn_wr_o;
    wire  rxdat_info_wr, rxrsp_info_wr;
    
   get_txn_comp_info #(
   	.B(B)
   )
   get_txn_comp_info
   (
   	.reset(reset),
   	.clk(clk),
   	.rxdat_txnid_in(rxdat_txnid_in),
   	.rxrsp_txnid_in(rxrsp_txnid_in),
   	.rxdat_wr(noc_chi_rxdatflitv),
   	.rxrsp_wr(noc_chi_rxrspflitv),
   	
   	
   	.rxdat_to_lkpt_txnid(rxdat_to_lkpt_txnid),
   	.rxdat_to_lkpt_rd_valid(rxdat_to_lkpt_rd_valid),
   	.lkpt_to_rxdat_txndat(lkpt_to_rxdat_txndat),
  
   	.rxrsp_to_cache_rd_addr(rxrsp_to_cache_rd_addr),
   	.rxrsp_to_cache_rd_en(rxrsp_to_cache_rd_en),
   	.cache_to_rxrsp_rd_data(cache_to_rxrsp_rd_data),
   	.cache_to_rxrsp_rd_ready(cache_to_rxrsp_rd_ready),
   	.cache_to_rxrsp_rd_state(cache_to_rxrsp_rd_state),
   	.cache_to_rxrsp_rd_hit(cache_to_rxrsp_rd_hit),
   	.cache_to_rxrsp_rd_done(cache_to_rxrsp_rd_done),
  
   	.rxdat_info_wr(rxdat_info_wr),
   	.rxrsp_info_wr(rxrsp_info_wr),
   	.txn_cache_data_o(txn_cache_data_o),
   	.txn_req_opcode_o(txn_req_opcode_o),
   	.txn_addr_o(txn_addr_o),
   	.txn_cache_state_o(txn_cache_state_o),
   	.txn_req_excl_o(txn_req_excl_o),
   	.txn_wr_o(txn_wr_o)
   );
    
    wire rxrsp_comp_fifo_empty,rxdat_comp_fifo_empty;
    
    wire  [DATA_DAT-1 : 0] rxrsp_cache_data;
    wire  [OPCODE_REQ-1:0] rxrsp_req_opcode;
    wire  [ADDR_REQ-1:0]   rxrsp_addr; 
    wire  [CACHE_STATUSw-1: 0] rxrsp_cache_state;
    wire  rxrsp_excl;
    
    wire  [DATA_DAT-1 : 0] rxdat_cache_data;
    wire  [OPCODE_REQ-1:0] rxdat_req_opcode;
    wire  [ADDR_REQ-1:0]   rxdat_addr; 
    wire  [CACHE_STATUSw-1: 0] rxdat_cache_state;
    wire  rxdat_excl;
    
    
    
    bram_based_fifo #(
        .Dw(DATA_DAT + OPCODE_REQ + ADDR_REQ + CACHE_STATUSw + 1 ),
        .B(B)
    )
    rxrsp_comp_info_fifo
    (
        .din({ txn_cache_data_o, txn_req_opcode_o, txn_addr_o, txn_cache_state_o, txn_req_excl_o} ),
        .wr_en(rxrsp_info_wr & txn_wr_o),
        .rd_en(rxrsp_read_fifo_en ),
        .dout({ rxrsp_cache_data, rxrsp_req_opcode, rxrsp_addr, rxrsp_cache_state, rxrsp_excl} ),
        .full(),
        .nearly_full(),
        .empty(rxrsp_comp_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
    
     bram_based_fifo #(
        .Dw(DATA_DAT + OPCODE_REQ + ADDR_REQ + CACHE_STATUSw + 1 ),
        .B(B)
    )
    rxdat_comp_info_fifo
    (
        .din({ txn_cache_data_o, txn_req_opcode_o, txn_addr_o, txn_cache_state_o, txn_req_excl_o} ),
        .wr_en(rxdat_info_wr & txn_wr_o),
        .rd_en(rxdat_read_fifo_en ),
        .dout({ rxdat_cache_data, rxdat_req_opcode, rxdat_addr, rxdat_cache_state, rxdat_excl} ),
        .full(),
        .nearly_full(),
        .empty(rxdat_comp_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
    
    
   
    reg   [TXNID_RSP-1:0]           current_txnid;  
   
  
  
   
  
 //  assign rxrsp_to_datlkpt_txnid = rxdat_to_lkpt_txnid;
   
    localparam [2:0]
        IDEAL = 1,
        PROCESS_RXDAT = 2,
        PROCESS_RXRSP = 4;
        
    reg [2:0] pst;
    reg [2:0] nst;
    
    
    
  //  wire [OPCODE_REQ-1:0]   txreq_to_rxdat_txn_opcode;
  //  wire [ADDR_REQ-1:0] txreq_to_rxdat_txn_addr; 
  //  wire [CACHE_STATUSw-1: 0] txreq_to_rxdat_initial_cache_state;
  //  wire txreq_to_rxdat_txn_excl;
   // assign {txreq_to_rxdat_initial_cache_state,txreq_to_rxdat_txn_excl,txreq_to_rxdat_txn_opcode,txreq_to_rxdat_txn_addr} = lkpt_to_rxdat_txndat; 
    
    wire compdat_illegal;
    wire [CACHE_STATUSw-1 : 0] compdat_cache_wr_state;
   
    rnf_final_cache_state_datcomp    compdat_cache_state_gen
    (
        .request_type(rxdat_req_opcode),
        .resp(rxdat_resp),
        .initial_cache_state(rxdat_cache_state  ),  
        .cache_state_o(compdat_cache_wr_state),
        .illegal_condition(compdat_illegal)
    );
    
    wire comp_illegal;
    wire [CACHE_STATUSw-1 : 0] comp_cache_wr_state;
    
    rnf_final_cache_state_comp    comp_cache_state_gen
    (
        .request_type(rxrsp_req_opcode),
        .resp(rxrsp_resp),
        .initial_cache_state(rxrsp_cache_state ),  
        .cache_state_o(comp_cache_wr_state),
        .illegal_condition(comp_illegal)
    );                                     
    
    reg unsupported_rxopcode_dat,unsupported_rxrsp_opcode;
   
    reg [1:0] txrsp_action;
    localparam [1:0]
        TXRSP_IDEAL =0,
        TXRSP_CompAck=1,
        TXRSP_CompAck_Excl_Failed=2;
    
    
    reg [2:0] txdat_action;
    localparam [2:0]
        TXDAT_IDEAL =0,
        TXDAT_NCBWrData_I=1,
        TXDAT_CBWrData_UD_PD=2, 
        TXDAT_CBWrData_UC=3,  
        TXDAT_CBWrData_SD_PD=4, 
        TXDAT_CBWrData_SC=5, 
        TXDAT_CBWrData_I=6;
    
    
   
    
    
    reg [TXNID_RSP-1:0] txrsp_txnid;
    reg [TGTID_RSP-1:0] txrsp_tgtid;
    
    reg last_dat_is_not_proceed, last_dat_is_not_proceed_next;
    reg last_rsp_is_not_proceed, last_rsp_is_not_proceed_next;
    wire can_goto_process_rsp = (rxrsp_fifo_not_empty & ~rxrsp_comp_fifo_empty) |  last_rsp_is_not_proceed;
    wire can_goto_process_dat = (rxdat_fifo_not_empty & ~rxdat_comp_fifo_empty) |  last_dat_is_not_proceed;
    
    
    
    
    
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
    always @(*)begin 
        rxdat_read_fifo_en=1'b0;
        rxrsp_read_fifo_en=1'b0;
        nst=pst;        
        unsupported_rxopcode_dat = 1'b0;
        unsupported_rxrsp_opcode = 1'b0;    
        
        
        rxdat_to_cache_wr_data = rxdat_data;
        rxdat_to_cache_wr_state= compdat_cache_wr_state;
        rxdat_to_cache_wr_action=  CACHE_UPDATE_DAT_ST;// update both data and state
        rxdat_to_cache_wr_addr = rxdat_addr;
        rxdat_to_cache_wr_en=1'b0;
        rxdat_to_cache_wr_action=CACHE_UPDATE_DAT_ST;
        
        
        txrsp_txnid=rxdat_dbid;
        txrsp_tgtid=rxdat_homenid;
        txrsp_action = TXRSP_IDEAL;
        txdat_action = TXDAT_IDEAL;
      
        
        rxrsp_to_txreq_txnid_release=1'b0;
        rxrsp_to_txreq_txnid=rxrsp_txnid;
        current_txnid= rxrsp_txnid;
        
   //     rxdat_to_lkpt_rd_valid = 1'b0; 
        rxrsp_to_datlkpt_rd_valid  = 1'b0;
        rxrsp_to_datlkpt_txnid= rxrsp_txnid_next;
        
        last_dat_is_not_proceed_next = last_dat_is_not_proceed;
        last_rsp_is_not_proceed_next = last_rsp_is_not_proceed;
        
        case(pst)
        IDEAL: begin         
            if( can_goto_process_dat )begin 
                nst=PROCESS_RXDAT; 
                rxdat_read_fifo_en= ~last_dat_is_not_proceed; 
   //             rxdat_to_lkpt_rd_valid = 1; 
                  rxrsp_to_datlkpt_rd_valid  = 1;
                  rxrsp_to_datlkpt_txnid= (last_dat_is_not_proceed)?  rxdat_txnid : rxdat_txnid_next;
                
               
            end else if (can_goto_process_rsp ) begin 
                nst=PROCESS_RXRSP;
                rxrsp_read_fifo_en= ~last_rsp_is_not_proceed; 
               // rxdat_to_lkpt_rd_valid = 1; 
                rxrsp_to_datlkpt_rd_valid  = 1;
                rxrsp_to_datlkpt_txnid= (last_rsp_is_not_proceed) ? rxrsp_txnid : rxrsp_txnid_next;
               
            end
        end         
        
        PROCESS_RXDAT: begin 
            rxrsp_to_txreq_txnid=rxdat_txnid;  
            current_txnid= rxdat_txnid;
        
            if (can_goto_process_rsp) begin 
                nst=PROCESS_RXRSP;
                rxrsp_read_fifo_en= ~last_rsp_is_not_proceed; 
           //     rxdat_to_lkpt_rd_valid = 1; 
                rxrsp_to_datlkpt_rd_valid  = 1;
                rxrsp_to_datlkpt_txnid= (last_rsp_is_not_proceed) ? rxrsp_txnid : rxrsp_txnid_next;
                
            end 
            else if(~rxdat_comp_fifo_empty |  current_dat_not_proceed )begin 
                rxdat_read_fifo_en= ~current_dat_not_proceed; 
          //      rxdat_to_lkpt_rd_valid = ~current_dat_not_proceed; 
                rxrsp_to_datlkpt_rd_valid  = ~current_dat_not_proceed;
                rxrsp_to_datlkpt_txnid= rxdat_txnid_next;
                
            end else nst=IDEAL;                     
                    
        
            case(rxopcode_dat) 
            OPCODE_DAT_CompData: begin 
                case(datlkpt_to_rxrsp_req_opcode)
                REQ_OPCODE_AtomicLoad_ADD  ,
                REQ_OPCODE_AtomicLoad_CLR  ,
                REQ_OPCODE_AtomicLoad_EOR  ,
                REQ_OPCODE_AtomicLoad_SET  ,
                REQ_OPCODE_AtomicLoad_SMAX ,
                REQ_OPCODE_AtomicLoad_SMIN ,
                REQ_OPCODE_AtomicLoad_UMAX ,
                REQ_OPCODE_AtomicLoad_UMIN ,
                REQ_OPCODE_AtomicSwap      ,
                REQ_OPCODE_AtomicCompare: begin  
                    
                    if( cache_to_rxdat_wr_ready )begin
                            rxdat_to_cache_wr_en=1'b1;
                            rxrsp_to_txreq_txnid_release=1'b1;
                            last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1;      
                    
                    
                end//atomic load
                default : begin 
                    if( cache_to_rxdat_wr_ready &  txrsp_to_rxdat_ready)begin
                            rxdat_to_cache_wr_en=1'b1;
                            rxrsp_to_txreq_txnid_release=1'b1;
                            txrsp_action=TXRSP_CompAck;
                            last_dat_is_not_proceed_next=1'b0;
                    end
                    else last_dat_is_not_proceed_next=1'b1;                 
                end
                
                
                endcase
                
                          
                
                    
                
                  
            end
            default: begin 
                unsupported_rxopcode_dat = 1'b1;
            
            end
            endcase
                     
        end//   PROCESS_REQ  
        
        
        PROCESS_RXRSP : begin 
            txrsp_txnid=rxrsp_dbid;
            txrsp_tgtid=rxrsp_srcid;        
        
             if (can_goto_process_dat) begin
                nst=PROCESS_RXDAT;  
                rxdat_read_fifo_en=~last_dat_is_not_proceed; 
             //   rxdat_to_lkpt_rd_valid = 1; 
                rxrsp_to_datlkpt_rd_valid  = 1;
                rxrsp_to_datlkpt_txnid= (last_dat_is_not_proceed)?  rxdat_txnid : rxdat_txnid_next;
             end 
             else if (~rxrsp_comp_fifo_empty | current_rsp_not_proceed ) begin 
                rxrsp_read_fifo_en= ~current_rsp_not_proceed;  
            //    rxdat_to_lkpt_rd_valid = ~current_rsp_not_proceed; 
                rxrsp_to_datlkpt_rd_valid  = ~current_rsp_not_proceed;
                rxrsp_to_datlkpt_txnid=  rxrsp_txnid_next;
             end else nst=IDEAL;                 
               
        
            case(rxrsp_opcode) 
            RSP_OPCODE_Comp: begin 
                case(rxrsp_req_opcode)
                REQ_OPCODE_Evict:begin 
                    rxrsp_to_txreq_txnid_release=1'b1; 
                    last_rsp_is_not_proceed_next=1'b0;
                                         
                end 
                default:begin
                
                
                
                if(rxrsp_excl & (rxrsp_resperr == Excl_Failed))begin
                    // exclusive transaction is faild the RNF should restatrt the transaction again we donot need to change the cache state
                    // TODO not sure if we still need to send ack
                   if( txrsp_to_rxdat_ready)begin
                       
                        txrsp_action=TXRSP_CompAck_Excl_Failed;                    
                        rxrsp_to_txreq_txnid_release=1'b1;              
                        //This flit is processed check for next
                        last_rsp_is_not_proceed_next=1'b0;
                
                    end else last_rsp_is_not_proceed_next=1'b1;            
            
            
                end else  begin //successful exclusive or normal transaxion
                    if( cache_to_rxdat_wr_ready & txrsp_to_rxdat_ready)begin
                            rxdat_to_cache_wr_state= comp_cache_wr_state;
                            rxdat_to_cache_wr_addr = rxrsp_addr;
                            rxdat_to_cache_wr_action=  CACHE_UPDATE_ST;// do not change data
                            rxdat_to_cache_wr_en=1'b1;
                            txrsp_action=TXRSP_CompAck;                    
                            rxrsp_to_txreq_txnid_release=1'b1;              
                            //This flit is processed check for next
                            last_rsp_is_not_proceed_next=1'b0;
                    end else last_rsp_is_not_proceed_next=1'b1;
               end      
              end
              endcase
            end// RSP_OPCODE_Comp   
            RSP_OPCODE_CompDBIDResp :begin
                if(txdat_to_undat_ready)begin 
                    case(datlkpt_to_rxrsp_req_opcode)
                    REQ_OPCODE_WriteUniqueFull,
                    REQ_OPCODE_WriteNoSnpPtl: begin
                        txdat_action= TXDAT_NCBWrData_I;
                        //TODO check if ack is reqired
                        rxrsp_to_txreq_txnid_release=1'b1;
                        rxrsp_to_txreq_txnid=rxrsp_txnid;
                        last_rsp_is_not_proceed_next=1'b0;
                    end
                    REQ_OPCODE_WriteBackFull,
                    REQ_OPCODE_WriteCleanFull:begin 
                        txdat_action= 
                            (rxrsp_cache_state == CACHE_UD )?  TXDAT_CBWrData_UD_PD:
                            (rxrsp_cache_state == CACHE_UC )?  TXDAT_CBWrData_UC:
                            (rxrsp_cache_state == CACHE_SD )?  TXDAT_CBWrData_SD_PD:
                            (rxrsp_cache_state == CACHE_SC )?  TXDAT_CBWrData_SC:
                            TXDAT_CBWrData_I;
                            //TODO check if ack is reqired
                        rxrsp_to_txreq_txnid_release=1'b1;
                        rxrsp_to_txreq_txnid=rxrsp_txnid;
                        last_rsp_is_not_proceed_next=1'b0;                    
                        
                    end // all atomic 
                    REQ_OPCODE_AtomicLoad_ADD  ,
                    REQ_OPCODE_AtomicLoad_CLR  ,
                    REQ_OPCODE_AtomicLoad_EOR  ,
                    REQ_OPCODE_AtomicLoad_SET  ,
                    REQ_OPCODE_AtomicLoad_SMAX ,
                    REQ_OPCODE_AtomicLoad_SMIN ,
                    REQ_OPCODE_AtomicLoad_UMAX ,
                    REQ_OPCODE_AtomicLoad_UMIN ,
                    REQ_OPCODE_AtomicSwap      ,
                    REQ_OPCODE_AtomicCompare: begin  
                        txdat_action= TXDAT_NCBWrData_I;
                        //TODO check if ack is reqired
                        rxrsp_to_txreq_txnid=rxrsp_txnid;
                        last_rsp_is_not_proceed_next=1'b0;
                    end
                    default begin 
                     unsupported_rxrsp_opcode = 1'b1;
                    
                    end
                    endcase
                 end else last_rsp_is_not_proceed_next=1'b1;
                
               
            end
            default:begin
                unsupported_rxrsp_opcode = 1'b1;
            end
            endcase
                    
        end        
        endcase        
    end
    
    
    //txrsp
    always @(*) begin
        rxdat_to_txrsp_wr_en=1'b0;
        rxdat_to_txrsp_txnid=txrsp_txnid;
        rxdat_to_txrsp_tgtid=txrsp_tgtid;
        rxdat_to_txrsp_opcode=RSP_OPCODE_CompAck;
        rxdat_to_txrsp_resp=0;
        case(txrsp_action)
            TXRSP_CompAck,TXRSP_CompAck_Excl_Failed: begin
                 rxdat_to_txrsp_wr_en=1'b1;
            end
        endcase
    end
    
    
    //txdat
    always @(*) begin
        
        undat_to_txdat_wr=1'b0;       
       // undat_to_txdat_dat=datlkpt_to_rxrsp_txndat [DATA_DAT-1 : 0];
        undat_to_txdat_dat= rxrsp_cache_data; 
        undat_to_txdat_tgtid =rxrsp_srcid;
        undat_to_txdat_txnid= rxrsp_dbid;
        undat_to_txdat_dbid=0;
        undat_to_txdat_opcode=OPCODE_DAT_CopyBackWrData;
        undat_to_txdat_resp=3'b000;
        undat_to_txdat_homenid=rxrsp_srcid;
        case(txdat_action)
        TXDAT_NCBWrData_I:begin 
            undat_to_txdat_opcode = OPCODE_DAT_NonCopyBackWrData;
            undat_to_txdat_wr=1'b1;
        end
        TXDAT_CBWrData_UD_PD:begin 
            undat_to_txdat_resp=   3'b110;
            undat_to_txdat_wr = 1'b1;
        end 
        TXDAT_CBWrData_UC:begin 
            undat_to_txdat_resp= 3'b010;
            undat_to_txdat_wr = 1'b1;
        end  
        TXDAT_CBWrData_SD_PD:begin 
            undat_to_txdat_resp=3'b111;
            undat_to_txdat_wr=1'b1;
        end 
        TXDAT_CBWrData_SC:begin 
             undat_to_txdat_resp=3'b001;
             undat_to_txdat_wr=1'b1;
        end 
        TXDAT_CBWrData_I:begin 
             undat_to_txdat_wr=1'b1;
        end
        endcase         
    end        
   
   
   
   
   
    
    always @(posedge clk) begin
        if(reset) begin          
            chi_noc_rxdatlcrdv<=0;
            chi_noc_rxrsplcrdv<=1'b0;
            pst<=IDEAL;
        end  else begin 
            chi_noc_rxdatlcrdv<=rxdat_read_fifo_en;
            chi_noc_rxrsplcrdv<=rxrsp_read_fifo_en;
            pst<=nst;            
        end
    end
      
  
    
    
    
    
    // rxdat_txsnp_dbid is received one cycle in advanced 
   always @(posedge clk)begin 
    if(reset) begin 
        rxdat_txsnp_dbid <=0;
    end else begin 
        rxdat_txsnp_dbid <=rxdat_to_lkpt_txnid;
    end
   end 
   
   assign rxdat_to_cache_wr_evict=1'b0;
   
    
    //synthesis translate_off 
    //synopsys  translate_off
    
    reg [159 : 0] txdat_str;  
    always @(*)begin 
        case(txdat_action)
        TXDAT_NCBWrData_I:      txdat_str= "TXDAT_NCBWrData_I";
        TXDAT_CBWrData_UD_PD:   txdat_str= "TXDAT_CBWrData_UD_PD";
        TXDAT_CBWrData_UC:      txdat_str= "TXDAT_CBWrData_UC";
        TXDAT_CBWrData_SD_PD:   txdat_str= "TXDAT_CBWrData_SD_PD";
        TXDAT_CBWrData_SC:      txdat_str= "TXDAT_CBWrData_SC";
        TXDAT_CBWrData_I:       txdat_str= "TXDAT_CBWrData_I";   
        endcase       
    end
     
    
    
    
    always @(posedge clk)begin 
        if(unsupported_rxopcode_dat) begin 
            $display("Error: %t: rnf ( %d ) txn ( %d ) rxdat has received an unsupported opcode:%h",$time,src_id,rxopcode_dat,current_txnid);
            $stop;
        end    
        if(unsupported_rxrsp_opcode)begin 
            $display("Error: %t: rnf ( %d ) txn ( %d ) rxrsp has received an unsupported opcode:%h",$time,src_id,rxrsp_opcode,current_txnid);
            $stop;
        end
        if((pst == PROCESS_RXDAT) & rxdat_to_cache_wr_en & compdat_illegal) begin 
            $display("Error: %t: rnf ( %d ) txn ( %d ) rxdat has received an illegal cache configuration state",$time,src_id,current_txnid);
            $stop;
        end
        if((pst == PROCESS_RXRSP) & rxdat_to_cache_wr_en & comp_illegal) begin 
            $display("Error: %t: rnf ( %d ) txn ( %d ) rxrsp has received an illegal cache configuration state",$time,src_id,current_txnid);
            $stop;
        end
        
            
        
        
        
        if((VERBOSITY & MONITORE_TXN_CMD) > 0)begin
            if( txrsp_action==TXRSP_CompAck) $display("%t: rnf ( %d ) txn ( %d ) rxrsp sends CompAck to core ( %d )",$time,src_id,current_txnid,
        rxdat_to_txrsp_tgtid);
            if( txdat_action!=TXDAT_IDEAL)  $display("%t: rnf ( %d ) txn ( %d ) rxrsp sends %s Dat( %h ) to core ( %d )",$time,src_id,current_txnid,txdat_str,
        undat_to_txdat_dat,rxdat_to_txrsp_tgtid);
        end
        
        
         if((VERBOSITY & MONITORE_EXCL_TXN) >0  )begin
             if(txrsp_action==  TXRSP_CompAck_Excl_Failed) $display("%t: rnf ( %d ) txn ( %d ) got exclusive fail response",$time,src_id,current_txnid);
         end
        
        
    end
    
   
    
    
     //synthesis translate_on 
    //synopsys  translate_on
    
    
    
    
    

endmodule





/***************
 *   rnf_final_cache_state_datcomp
 * ************/
 
 
 module rnf_final_cache_state_datcomp (
    request_type,  
    initial_cache_state,
    resp,
    cache_state_o,
    illegal_condition
 );
 
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
   
   
    
 
    input [OPCODE_REQ-1 : 0  ] request_type; 
    input [RESP_DAT-1 : 0 ] resp;
    input [CACHE_STATUSw-1 : 0] initial_cache_state;
    output reg [CACHE_STATUSw-1 : 0] cache_state_o;
    output reg  illegal_condition;

    
    always @ (*) begin 
        cache_state_o = CACHE_I;
        illegal_condition=1'b0;
        case(request_type) 
        REQ_OPCODE_ReadNoSnp : begin
            cache_state_o = CACHE_I;        
        end
        REQ_OPCODE_ReadShared: begin
           // case(initial_cache_state)
           // CACHE_I, CACHE_UCE: //TODO the is line coment should be removed later
                case(resp)
                CompData_SC: cache_state_o = CACHE_SC;
                CompData_UC: cache_state_o = CACHE_UC;
                CompData_SD_PD: cache_state_o =  CACHE_SD;
                CompData_UD_PD: cache_state_o = CACHE_UD;
                default : illegal_condition=1'b1;
                endcase
           //default : illegal_condition=1'b1;
          // endcase                
        
        end
        REQ_OPCODE_ReadClean: begin //TODO complete this
            illegal_condition=1'b1;
        
        end 
        REQ_OPCODE_ReadUnique: begin 
            case(initial_cache_state)
            CACHE_I, CACHE_SC, CACHE_UC, CACHE_UCE:begin
                case(resp)
                CompData_UC: cache_state_o = CACHE_UC;
                CompData_UD_PD: cache_state_o = CACHE_UD;
                default : illegal_condition=1'b1;
                endcase
           end
           CACHE_UD, CACHE_UDP, CACHE_SD:begin
                case(resp)
                CompData_UC: cache_state_o = CACHE_UD;
                CompData_UD_PD: cache_state_o = CACHE_UD;
                default : illegal_condition=1'b1;
                endcase
           end
           endcase
        
        end
        REQ_OPCODE_CleanUnique: begin 
            illegal_condition=1'b1;
        
        end
        REQ_OPCODE_MakeUnique: begin
            illegal_condition=1'b1;
        
        end
        REQ_OPCODE_Evict: begin 
            illegal_condition=1'b1;
        
        end
        //atomic transactions
        REQ_OPCODE_AtomicStore_ADD ,
        REQ_OPCODE_AtomicStore_CLR ,
        REQ_OPCODE_AtomicStore_EOR ,
        REQ_OPCODE_AtomicStore_SET ,
        REQ_OPCODE_AtomicStore_SMAX,
        REQ_OPCODE_AtomicStore_SMIN,
        REQ_OPCODE_AtomicStore_UMAX,
        REQ_OPCODE_AtomicStore_UMIN,
        REQ_OPCODE_AtomicLoad_ADD  ,
        REQ_OPCODE_AtomicLoad_CLR  ,
        REQ_OPCODE_AtomicLoad_EOR  ,
        REQ_OPCODE_AtomicLoad_SET  ,
        REQ_OPCODE_AtomicLoad_SMAX ,
        REQ_OPCODE_AtomicLoad_SMIN ,
        REQ_OPCODE_AtomicLoad_UMAX ,
        REQ_OPCODE_AtomicLoad_UMIN ,
        REQ_OPCODE_AtomicSwap      ,
        REQ_OPCODE_AtomicCompare   :begin
            case(initial_cache_state)
            CACHE_I, CACHE_SC ,CACHE_UCE, CACHE_SD, CACHE_UC, CACHE_UD, CACHE_UDP:begin 
                cache_state_o = CACHE_I;
            end
            default :              illegal_condition=1'b1;
            endcase
        
        end
        
        
        
        
        
        
        
        default : illegal_condition=1'b1;
            
    endcase
    end
 
 
 
 endmodule
 
 

/***************
 *   rnf_final_cache_state_comp
 * ************/
 
 
 module rnf_final_cache_state_comp (
    request_type,
    initial_cache_state,
    resp,
    cache_state_o,
    illegal_condition
 );
 
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
  
  
 
    input [OPCODE_REQ-1 : 0  ] request_type;
    input [RESP_RSP-1 : 0 ] resp;
    input [CACHE_STATUSw-1 : 0] initial_cache_state;
    output reg [CACHE_STATUSw-1 : 0] cache_state_o;
    output reg illegal_condition;
    
   
    always @ (*) begin 
        cache_state_o = CACHE_I;
        illegal_condition=1'b0;
        case(request_type) 
        REQ_OPCODE_CleanUnique: begin
            case(initial_cache_state)
            CACHE_I, CACHE_UC, CACHE_UCE : begin 
                case(resp)
                Comp_UC: cache_state_o = CACHE_UCE;
                default : illegal_condition=1'b1;
                endcase//resp
            end// CACHE_I, CACHE_UC, CACHE_UCE
            CACHE_SC, CACHE_UC:begin
                case(resp)
                Comp_UC: cache_state_o = CACHE_UC;
                default : illegal_condition=1'b1;
                endcase//resp
            end  //CACHE_SC, CACHE_UC          
            CACHE_SD, CACHE_UD: begin
                case(resp)
                Comp_UC: cache_state_o = CACHE_UD;
                default : illegal_condition=1'b1;
                endcase//resp
            end //CACHE_SD, CACHE_UD   
            default : illegal_condition=1'b1;
            endcase//initial_cache_state
           
        end//  REQ_OPCODE_CleanUnique    
        
        
        REQ_OPCODE_MakeUnique:begin
            case(initial_cache_state)
            CACHE_I, CACHE_SC, CACHE_SD, CACHE_UC, CACHE_UCE: begin
                case(resp)
                Comp_UC: cache_state_o = CACHE_UD;
                default : illegal_condition=1'b1;
                endcase//resp
            end
            default : illegal_condition=1'b1;
            endcase//resp
        
        end //REQ_OPCODE_MakeUnique
        
        
        
        REQ_OPCODE_Evict:begin
            case(initial_cache_state)
            CACHE_I: begin
                case(resp)
                Comp_I: cache_state_o = CACHE_I;
                default : illegal_condition=1'b1;
                endcase//resp
            end
            default : illegal_condition=1'b1;
            endcase//resp
        end
        
        
        REQ_OPCODE_CleanShared : begin
            case(initial_cache_state)
            CACHE_I, CACHE_SC, CACHE_UC: begin
                case(resp)
                Comp_UC, Comp_SC,Comp_I: cache_state_o = initial_cache_state;
                default : illegal_condition=1'b1;
                endcase//resp
            end
            default : illegal_condition=1'b1;
            endcase//resp       
        end
        
         
        REQ_OPCODE_CleanInvalid: begin
             case(initial_cache_state)
            CACHE_I: begin
                case(resp)
                Comp_I: cache_state_o = CACHE_I;
                default : illegal_condition=1'b1;
                endcase//resp
            end
            default : illegal_condition=1'b1;
            endcase//resp
        end
        
        REQ_OPCODE_MakeInvalid: begin
             case(initial_cache_state)
            CACHE_I: begin
                case(resp)
                Comp_I: cache_state_o = CACHE_I;
                default : illegal_condition=1'b1;
                endcase//resp
            end
            default : illegal_condition=1'b1;
            endcase//resp
        end
        
    endcase
    end
 
    
 
 
 endmodule





module get_txn_comp_info #(
    parameter B=4

)(
   reset,
   clk,
   rxdat_txnid_in,
   rxdat_wr,
   rxrsp_txnid_in,
   rxrsp_wr,
   
   //lkpt_txnid
   rxdat_to_lkpt_txnid,
   rxdat_to_lkpt_rd_valid,
   lkpt_to_rxdat_txndat,        
   
   //cache_rd
   rxrsp_to_cache_rd_addr,
   cache_to_rxrsp_rd_data,
   rxrsp_to_cache_rd_en,
   cache_to_rxrsp_rd_ready,   
   cache_to_rxrsp_rd_state,
   cache_to_rxrsp_rd_hit,
   cache_to_rxrsp_rd_done,
   
   //output
   txn_cache_data_o,
   txn_cache_state_o,
   txn_req_opcode_o,
   txn_req_excl_o,
   txn_addr_o,
   txn_wr_o,
   rxdat_info_wr,
   rxrsp_info_wr
   

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
        
   
    
    input reset,clk;
    input [TXNID_DAT-1 : 0] rxdat_txnid_in , rxrsp_txnid_in;
    input rxdat_wr, rxrsp_wr;
   
   //lkpt_txnid
    output  [TXNID_REQ-1 :  0] rxdat_to_lkpt_txnid;
    output  rxdat_to_lkpt_rd_valid;
    input  [RNF_TXN_DATAw-1 :  0] lkpt_to_rxdat_txndat;  
    
   

    //cache_rd
    output [ADDR_REQ-1 : 0] rxrsp_to_cache_rd_addr;
    output rxrsp_to_cache_rd_en;
    input  [DATA_DAT-1 : 0] cache_to_rxrsp_rd_data;    
    input cache_to_rxrsp_rd_ready;   
    input [CACHE_STATUSw-1 : 0] cache_to_rxrsp_rd_state;
    input cache_to_rxrsp_rd_hit;
    input cache_to_rxrsp_rd_done;        

    //txninfo
    output rxdat_info_wr;
    output rxrsp_info_wr;

    output  [DATA_DAT-1 : 0] txn_cache_data_o;
    output  [OPCODE_REQ-1:0] txn_req_opcode_o;
    output  [ADDR_REQ-1:0]   txn_addr_o; 
    output  [CACHE_STATUSw-1: 0] txn_cache_state_o;
    output  txn_req_excl_o;
    output  txn_wr_o;
   


    //step 1 make a queue for both dat and rsp txnand pik up one
     wire [1: 0 ]winner_txn;
     wire fifo_lkpt_info_ready;
    
    many_to_one_pipe_fifo #(
    	.B(B),
    	.Dw(TXNID_REQ),
    	.IN_NUM(2),
    	.IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    txn_merg_fifo
    (
    	.qin_data_in({rxdat_txnid_in , rxrsp_txnid_in} ),
    	.qin_we({rxdat_wr, rxrsp_wr}),
    	.qin_is_ready( ),// we will never get more than B txn so no need to check this flag
    	.qin_valid_o( ),
    	.qin_data_o( ),
    	
    	.qout_data_o(rxdat_to_lkpt_txnid),    	
    	.qout_we_o(rxdat_to_lkpt_rd_valid),
    	.qout_is_ready(fifo_lkpt_info_ready),
    	.qout_winner(winner_txn),
    	.reset(reset),
    	.clk(clk)
    	
    );

    

    // lkpt data will comes in one clock cycle
    reg rxdat_to_lkpt_rd_valid_pipe_reg;
    reg [1: 0 ]winner_txn_pipe_reg;
    
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                rxdat_to_lkpt_rd_valid_pipe_reg<=1'b0;
                winner_txn_pipe_reg<=2'b00;
            end else begin 
                rxdat_to_lkpt_rd_valid_pipe_reg<=rxdat_to_lkpt_rd_valid;
                winner_txn_pipe_reg<=winner_txn;
            end        
    end//always
      
      
      
      
      
    localparam LKPT_FIFO_B=4;
    
    wire empty1,empty2;
    wire rd_en1 = ~empty1 & cache_to_rxrsp_rd_ready;
    wire rd_en2 = ~empty2 & cache_to_rxrsp_rd_done ;
    wire [RNF_TXN_DATAw+2-1 : 0 ]  dout1,dout2;
   
    fifo_two_rd_port #(
    	.Dw(RNF_TXN_DATAw+2),
    	.B(LKPT_FIFO_B)
    )
    fifo_lkpt_info
    (
    	.din( {winner_txn_pipe_reg,lkpt_to_rxdat_txndat}),
    	.wr_en(rxdat_to_lkpt_rd_valid_pipe_reg),
    	.full(), // cannot use this signal as write has a pipe delay
    	.rd_en1(rd_en1),
    	.dout1(dout1),
    	.empty1( empty1),
    	.rd_en2(rd_en2),
    	.dout2(dout2),
    	.empty2(empty2),
    	.reset(reset),
    	.clk(clk)
    );



  localparam LBw= log2(LKPT_FIFO_B+1);
     // fifo full signal has delay wee need to re-calculate it using rxdat_to_lkpt_rd_valid. 
     // port 1 is used for pathing the data to the cache
     // port 2 is read once the data is recived from the cache. 

    reg [LBw-1: 0 ] depth;
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            depth<={LBw{1'b0}};
        end else begin            
            if (rxdat_to_lkpt_rd_valid & ~rd_en2) depth <= depth + 1'b1;
            else if (~rxdat_to_lkpt_rd_valid & rd_en2) depth <=  depth - 1'b1;
        end//else
    end // always

    wire fifo_lkpt_info_full = depth == LKPT_FIFO_B;
    assign fifo_lkpt_info_ready  = ~  fifo_lkpt_info_full;



    //take txn addr and send it to cache
    wire [ADDR_REQ-1:0] txreq_to_rxdat_txn_addr; 
    assign txreq_to_rxdat_txn_addr = dout1[ADDR_REQ-1:0];
    
    
   
   
    //handel cace rd input
    
   
  assign  rxrsp_to_cache_rd_addr = txreq_to_rxdat_txn_addr;
  assign  rxrsp_to_cache_rd_en  = rd_en1;
  
  assign  txn_cache_data_o  = cache_to_rxrsp_rd_data;
  assign  txn_cache_state_o = cache_to_rxrsp_rd_state;
  assign  txn_wr_o = cache_to_rxrsp_rd_done; 
   
  //wire [CACHE_STATUSw-1: 0] initial_cache_state;
  assign { rxdat_info_wr, rxrsp_info_wr,//initial_cache_state,
  txn_req_excl_o,txn_req_opcode_o,txn_addr_o} = dout2;

endmodule






