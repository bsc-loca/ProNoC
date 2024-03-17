/**************************************
* Module: chi_definition
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/

package amba_5_chi_c_pkg;
// `ifdef     INCLUDE_CHI_LOCALPARAM
// `include "chi_localparam.v"

  /*****************************
   * localparams common for all the flits
   *****************************/

  // Field widths
  localparam  RESP_ERRw  =  2;
  localparam  ENDIANw    =  1;
  localparam  ORDERw     =  2;
  localparam  NSw        =  1;
  localparam  DATA_IDw   =  2;
  localparam  TRACE_TAGw =  1;

  // Field encodings

   typedef enum logic[DATA_IDw-1:0] {
    DATA_ID_512W_511_0 = 0
  } data_id_512w_e;

  typedef enum logic[TRACE_TAGw-1:0] {
    TRACE_TAG_NO  = 0,
    TRACE_TAG_YES = 1
  } trace_tag_e;

  typedef enum logic [ENDIANw-1:0] {
    ENDIAN_LIL = 0,
    ENDIAN_BIG = 1
  } endian_enc_e;


  typedef enum logic [NSw-1:0] {
    NS_SEC_ACC     = 0,
    NS_NON_SEC_ACC = 1
  } ns_enc_e;

  typedef enum logic [RESP_ERRw-1:0] {
    RESP_ERR_OK_NORM      =  0,
    RESP_ERR_OK_EXCL      =  1,
    RESP_ERR_NOK_DATA     =  2,
    RESP_ERR_NOK_NO_DATA  =  3
  } resp_err_enc_e;

  typedef enum logic [ORDERw-1:0] {
    ORDER_NO,
    ORDER_REQ_ACC,
    ORDER_REQ,
    ORDER_ENDP
  } order_enc_e;

/*********************
 * 
 * localparams for the request flit
 * 
 * *******************/
  localparam QOS_REQ = 1;
  localparam TGTID_REQ = 6; //it can be from 7-11
  localparam SRCID_REQ = 6; //it can be from 7-11
  localparam TXNID_REQ = 8;
  localparam RETURNNID_REQ = 6; //it can be from 7-11
  localparam STASHNIDVALID_REQ = 1;
  localparam RETURNTXNID_REQ = 8;
  localparam OPCODE_REQ = 6;
  localparam SIZE_REQ = 3;
  localparam ADDR_REQ = 48; //it can be from 44-52
  localparam NS_REQ = 1;
  localparam LIKELYSHARED_REQ = 1;
  localparam ALLOWRETRY_REQ = 1;
  localparam PCRDTYPE_REQ = 4;
  localparam MEMATTR_REQ = 4;
  localparam SNPATTR_REQ = 1;
  localparam LPID_REQ = 3;
  localparam EXCL_REQ = 1;
  localparam EXPCOMPACK_REQ = 1;
  localparam TRACETAG_REQ = 1;
  localparam RSVDC_REQ = 4; //in case there is no RSVDC bus
                        //in case there is values can be 4,12,16,24,32

  typedef enum logic [OPCODE_REQ-1:0] {
    REQ_OPCODE_ReqLCrdReturn         =  'h00,
    REQ_OPCODE_ReadShared            =  'h01,
    REQ_OPCODE_ReadClean             =  'h02,
    REQ_OPCODE_ReadOnce              =  'h03,
    REQ_OPCODE_ReadNoSnp             =  'h04,
    REQ_OPCODE_PCrdReturn            =  'h05,
    REQ_OPCODE_Reserved              =  'h06,
    REQ_OPCODE_ReadUnique            =  'h07,
    REQ_OPCODE_CleanShared           =  'h08,
    REQ_OPCODE_CleanInvalid          =  'h09,
    REQ_OPCODE_MakeInvalid           =  'h0A,
    REQ_OPCODE_CleanUnique           =  'h0B,
    REQ_OPCODE_MakeUnique            =  'h0C,
    REQ_OPCODE_Evict                 =  'h0D,
    //0x0E    Reserved  (EOBarrier)                
    //0x0F    Reserved  (ECBarrier)                
    //0x10    Reserved                             
    REQ_OPCODE_ReadNoSnpSep          =  'h11,
    //0x12 - 0x13 Reserved                                       
    REQ_OPCODE_DVMOp                 =  'h14,
    REQ_OPCODE_WriteEvictFull        =  'h15,
    //0x16    Reserved  (WriteCleanPtl)  16        
    REQ_OPCODE_WriteCleanFull        =  'h17,
    REQ_OPCODE_WriteUniquePtl        =  'h18,
    REQ_OPCODE_WriteUniqueFull       =  'h19,
    REQ_OPCODE_WriteBackPtl          =  'h1A,
    REQ_OPCODE_WriteBackFull         =  'h1B,
    REQ_OPCODE_WriteNoSnpPtl         =  'h1C,
    REQ_OPCODE_WriteNoSnpFull        =  'h1D,
    //0x1E - 0x1F  Reserved 1E
    REQ_OPCODE_WriteUniqueFullStash  =  'h20,
    REQ_OPCODE_WriteUniquePtlStash   =  'h21,
    REQ_OPCODE_StashOnceShared       =  'h22,
    REQ_OPCODE_StashOnceUnique       =  'h23,
    REQ_OPCODE_ReadOnceCleanInvalid  =  'h24,
    REQ_OPCODE_ReadOnceMakeInvalid   =  'h25,
    REQ_OPCODE_ReadNotSharedDirty    =  'h26,
    REQ_OPCODE_CleanSharedPersist    =  'h27,
    //0x28 - 0x2F REQ_OPCODE_AtomicStore 28
    //0x30 - 0x37 REQ_OPCODE_AtomicLoad 
    //0x38 AtomicSwap
    //0x39 AtomicCompare
    //0x3B - 0x3F Reserved
    REQ_OPCODE_AtomicStore_ADD       =  6'b101000,
    REQ_OPCODE_AtomicStore_CLR       =  6'b101001,
    REQ_OPCODE_AtomicStore_EOR       =  6'b101010,
    REQ_OPCODE_AtomicStore_SET       =  6'b101011,
    REQ_OPCODE_AtomicStore_SMAX      =  6'b101100,
    REQ_OPCODE_AtomicStore_SMIN      =  6'b101101,
    REQ_OPCODE_AtomicStore_UMAX      =  6'b101110,
    REQ_OPCODE_AtomicStore_UMIN      =  6'b101111,
    REQ_OPCODE_AtomicLoad_ADD        =  6'b110000,
    REQ_OPCODE_AtomicLoad_CLR        =  6'b110001,
    REQ_OPCODE_AtomicLoad_EOR        =  6'b110010,
    REQ_OPCODE_AtomicLoad_SET        =  6'b110011,
    REQ_OPCODE_AtomicLoad_SMAX       =  6'b110100,
    REQ_OPCODE_AtomicLoad_SMIN       =  6'b110101,
    REQ_OPCODE_AtomicLoad_UMAX       =  6'b110110,
    REQ_OPCODE_AtomicLoad_UMIN       =  6'b110111,
    REQ_OPCODE_AtomicSwap            =  6'h38,
    REQ_OPCODE_AtomicCompare         =  6'h39,
    REQ_OPCODE_PrefetchTgt           =  'h3A
  } req_opcode_enc_e;
  
  typedef struct packed {
    logic             [QOS_REQ-1           :  0]  qos;
    logic             [TGTID_REQ-1         :  0]  tgt_id;
    logic             [SRCID_REQ-1         :  0]  src_id;
    logic             [TXNID_REQ-1         :  0]  txn_id;
    logic             [RETURNNID_REQ-1     :  0]  return_stash_nid;
   // endian_enc_e                                  endian;
    logic             [RETURNTXNID_REQ-1   :  0]  return_txn_id;
    req_opcode_enc_e                              opcode;
    logic             [SIZE_REQ-1          :  0]  size;
    logic             [ADDR_REQ-1          :  0]  addr;
  //  ns_enc_e                                      ns;
  //  logic             [LIKELYSHARED_REQ-1  :  0]  likely_shared;
    logic             [ALLOWRETRY_REQ-1    :  0]  allow_retry;
    order_enc_e                                   order;
    logic             [PCRDTYPE_REQ-1      :  0]  pcrd_type;
    logic             [MEMATTR_REQ-1       :  0]  mem_attr;
    logic             [SNPATTR_REQ-1       :  0]  snp_attr;
    logic             [LPID_REQ-1          :  0]  lpid;
    logic             [EXCL_REQ-1          :  0]  excl_snoop_me;
    logic             [EXPCOMPACK_REQ-1    :  0]  exp_comp_ack;
  //  logic             [TRACETAG_REQ-1      :  0]  trace_tag;
    // logic  [RSVDC_REQ-1          :  0]  rsvdc;
  } reqflit_t;

  localparam REQ_FLIT_SIZE = $bits(reqflit_t);



/**************************
*  localparams for the data flit 
* ***********************/


  localparam QOS_DAT = 1;
  localparam TGTID_DAT = 6; //it can be from 7-11
  localparam SRCID_DAT = 6; //it can be from 7-11
  localparam TXNID_DAT = 8;
  localparam HOMENID_DAT = 6; //it can be from 7-11
  localparam OPCODE_DAT = 4;
  localparam RESPERR_DAT = 2;
  localparam RESP_DAT = 3;
  localparam FWD_DATAPULL_DAT = 3;
  localparam DBID_DAT = 8;
  localparam CCID_DAT = 2;
  localparam DATAID_DAT = 2;
  localparam TRACETAG_DAT = 1;
  localparam RSVDC_DAT = 3; //in case there is no RSVDC bus
                            //in case there is values can be 4,12,16,24,32   
  localparam DATA_DAT = 512; // 512; //it can be also 256 or 128  *******************************************************************************
  localparam BE_DAT = DATA_DAT/8;   
  localparam DATACHECK_DAT = DATA_DAT/8; //it can be also 16, 32 or 64
  localparam POISON_DAT = DATA_DAT/64; //it can be also 2, 4 or 8
  
  // Encodings exclusive to datflit
  typedef enum logic [OPCODE_DAT-1:0] {
    OPCODE_DAT_aLCrdReturn        =  'h0  ,
    OPCODE_DAT_SnpRespData        =  'h1  ,
    OPCODE_DAT_CopyBackWrData     =  'h2  ,
    OPCODE_DAT_NonCopyBackWrData  =  'h3  ,
    OPCODE_DAT_CompData           =  'h4  ,
    OPCODE_DAT_SnpRespDataPtl     =  'h5  ,
    OPCODE_DAT_SnpRespDataFwded   =  'h6  ,
    OPCODE_DAT_WriteDataCancel    =  'h7  
    // localparam [OPCODE_DAT-1:0] OPCODE_DAT_DataSepResp = 'hB;  
    // localparam [OPCODE_DAT-1:0] OPCODE_DAT_NCBWrDataCompAck = 'hC;
  } opcode_dat_e;


  typedef struct packed {
    logic        [QOS_DAT-1           :  0]  qos;
    logic        [TGTID_DAT-1         :  0]  tgt_id;
    logic        [SRCID_DAT-1         :  0]  src_id;
    logic        [TXNID_DAT-1         :  0]  txn_id;
    logic        [HOMENID_DAT-1       :  0]  home_nid;
    opcode_dat_e  opcode;
    logic        [RESPERR_DAT-1       :  0]  resp_err;
    logic        [RESP_DAT-1          :  0]  resp;
    logic        [FWD_DATAPULL_DAT-1  :  0]  fwd_data_pull;
    logic        [DBID_DAT-1          :  0]  dbid;
   // logic        [CCID_DAT-1          :  0]  ccid;
   // logic        [DATAID_DAT-1        :  0]  data_id;
   // trace_tag_e                              trace_tag;
    //  logic  [RSVDC_DAT-1  :  0]  rsvdc;
    logic        [BE_DAT-1            :  0]  be;
    logic        [DATA_DAT-1          :  0]  data;
  //  logic        [DATACHECK_DAT-1     :  0]  data_check;
  //  logic        [POISON_DAT-1        :  0]  poison;
  } datflit_t;

   localparam DAT_FLIT_SIZE = $bits(datflit_t);

  

 

/***********************
*  localparams for the response flit 
* *********************/


  localparam QOS_RSP = 1;
  localparam TGTID_RSP = 6; //it can be from 7-11
  localparam SRCID_RSP = 6; //it can be from 7-11
  localparam TXNID_RSP = 8;
  localparam OPCODE_RSP = 4;
  localparam RESPERR_RSP = 2;
  localparam RESP_RSP = 3;
  localparam FWD_DATAPULL_RSP = 3;
  localparam DBID_RSP = 8;
  localparam PCRDTYPE_RSP = 4;
  localparam TRACETAG_RSP = 1;
  localparam TGID_SNP =24;
  
  // Encodings exclusive to datflit
  typedef enum logic [OPCODE_RSP-1:0] {
  	RSP_OPCODE_RespLCrdReturn  = 4'd0,
	RSP_OPCODE_SnpResp = 4'd1,
	RSP_OPCODE_CompAck = 4'd2, 
	RSP_OPCODE_RetryAck = 4'd3,
	RSP_OPCODE_Comp = 4'd4,
	RSP_OPCODE_CompDBIDResp = 4'd5,
	RSP_OPCODE_DBIDResp = 4'd6,
	RSP_OPCODE_PCrdGrant = 4'd7,
	RSP_OPCODE_ReadReceipt = 4'd8,
	RSP_OPCODE_SnpRespFwded = 4'd9  
  }opcode_rsp_e;
  
  
  
  typedef struct packed {
    logic [QOS_RSP-1:0]             qos; // = {QOS_REQ{1'b0}};
    logic [TGTID_RSP-1:0]           tgt_id  ;
    logic [SRCID_RSP-1:0]           src_id  ;
    logic [TXNID_RSP-1:0]           txn_id  ;
    opcode_rsp_e          opcode ;
    logic [RESPERR_RSP-1:0]         resp_err;     
    logic [RESP_RSP-1:0]            resp;
    logic [FWD_DATAPULL_RSP-1:0]    fwd_datapull;
    logic [DBID_RSP-1:0]            dbid;
    logic [PCRDTYPE_RSP-1:0]        pcrd_type; // = 4'b0000;
  //  logic [TRACETAG_RSP-1:0]        trace_tag; // = 1'b0;
  } rspflit_t;
  

  
  localparam RSP_FLIT_SIZE = $bits(rspflit_t);
      
  
  
  
  /*****************************
   * localparams for the   snoop flit 
   *****************************/
  

  
  localparam QOS_SNP = 1;
  localparam SRCID_SNP = 6; //it can be from 7-11
  localparam TXNID_SNP = 8;
  localparam FWDNID_SNP = 6;
  localparam FWDTXNID_SNP = 8;
  localparam OPCODE_SNP = 5;
  localparam ADDR_SNP = ADDR_REQ-3;
  localparam NS_SNP = 1;
  localparam DONOTGOTOSD_DONOTDATAPULL_SNP = 1;
  localparam RETTOSRC = 1;
  localparam TRACETAG_SNP = 1;


  // Encodings exclusive to datflit
  typedef enum logic [OPCODE_SNP-1:0] {
  	 SNP_OPCODE_SnpLCrdReturn = 5'h0,
  	 SNP_OPCODE_SnpShared     = 5'h1,
  	 SNP_OPCODE_SnpClean      = 5'h2,
  	 SNP_OPCODE_SnpOnce       = 5'h3,
  	 SNP_OPCODE_SnpNotSharedDirty = 5'h4,
  	 SNP_OPCODE_SnpUniqueStash  = 5'h5,
  	 SNP_OPCODE_SnpMakeInvalidStash  = 5'h6,
  	 SNP_OPCODE_SnpUnique  =5'h7,
  	 SNP_OPCODE_SnpCleanShared  =5'h8,
  	 SNP_OPCODE_SnpCleanInvalid  =5'h9,
  	 SNP_OPCODE_SnpMakeInvalid  =5'hA,
  	 SNP_OPCODE_SnpStashUnique  =5'hB,
  	 SNP_OPCODE_SnpStashShared  =5'hC,
  	 SNP_OPCODE_SnpDVMOp  =5'hD,
  	 SNP_OPCODE_SnpSharedFwd  =5'h11,
  	 SNP_OPCODE_SnpCleanFwd  =5'h12,
  	 SNP_OPCODE_SnpOnceFwd  =5'h13,
  	 SNP_OPCODE_SnpNotSharedDirtyFwd  =5'h14,
  	 SNP_OPCODE_SnpUniqueFwd  =5'h17    
 }opcode_snp_e;
 

   
   
    // chi snpflit logic packet definition
    typedef struct packed {
        logic [QOS_SNP-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [SRCID_SNP-1:0]           src_id  ;
        logic [TXNID_SNP-1:0]           txn_id  ;
        logic [FWDNID_SNP-1:0]          fwd_nid  ;
        logic [FWDTXNID_SNP-1:0]        fwd_txn_id  ;
        opcode_snp_e          opcode ;
        logic [ADDR_SNP-1:0]            addr ;
        //logic                           ns ;
        logic                           donot_goto_sd_datapull ;
        logic                           ret_to_src ;
        logic [TGID_SNP-1:0]            tgt_id;
       // logic                           tracetag; // = 1'b0;
    } snpflit_t;

    localparam SNP_FLIT_SIZE= $bits(snpflit_t);
    
    
    /*******************************/
   
   
   localparam CACHE_STATUSw =3;
   localparam CACHE_BLK_SIZ = 64; // cache block ram size in bytes
   localparam CACHE_BLK_SIZ_BIT =CACHE_BLK_SIZ * 8;
   localparam CACHE_ACTw =2;
   
    localparam [1:0]
      CACHE_NO_UPDATE     = 2'b00, // can be used for pther pourposes
      CACHE_UPDATE_DAT_ST = 2'b11,
      CACHE_UPDATE_DAT    = 2'b10,
      CACHE_UPDATE_ST     = 2'b01;
  
   
   
   localparam [2:0] CACHE_I   = 3'd0; //  Invalid 
   localparam [2:0] CACHE_UC  = 3'd1; //  Unique Clean
   localparam [2:0] CACHE_SC  = 3'd2; //  Shared Clean   
   localparam [2:0] CACHE_UCE = 3'd3; //  Unique Clean Empty
   localparam [2:0] CACHE_UD  = 3'd4; //  Unigue Dirty
   localparam [2:0] CACHE_SD  = 3'd5; //  Shared Dirty
   localparam [2:0] CACHE_UDP = 3'd6; //  Unigue Dirty Partial
   
   //snoopfilter parameter    
   localparam [2:0] SNPF_I   = 3'd0; //  Invalid 
   localparam [2:0] SNPF_U  = 3'd1; //  Unique , only peresented in one request node
   localparam [2:0] SNPF_S  = 3'd2; //  Shared , peresented in multiple request nodes   
       
  // response type identifier
  localparam RSPTw = 6;
  localparam [RSPTw-1 : 0] RSP_TYPE_OPCODE_DAT_CompData =1;
  localparam [RSPTw-1 : 0] RSP_TYPE_SnpSharedFwd=2;
  localparam [RSPTw-1 : 0] RSP_TYPE_SnpShared=3;
  localparam [RSPTw-1 : 0] RSP_TYPE_ReadNoSnp=4;
  localparam [RSPTw-1 : 0] RSP_TYPE_SnpCleanInvalid=5;
  localparam [RSPTw-1 : 0] RSP_TYPE_Comp=6;
  localparam [RSPTw-1 : 0] RSP_TYPE_WriteUniqueFull=7;
  localparam [RSPTw-1 : 0] RSP_TYPE_SnpUnique=8;
  localparam [RSPTw-1 : 0] RSP_TYPE_EVBUF_Evict=9;
  localparam [RSPTw-1 : 0] RSP_TYPE_WriteBackFull=10;
  localparam [RSPTw-1 : 0] RSP_TYPE_ReadNoSnp_NoSnpf=11;// no need to update snpf
  localparam [RSPTw-1 : 0] RSP_TYPE_SnpOnceFwd=12;
  localparam [RSPTw-1 : 0] RSP_TYPE_WriteUnique_SNP_CLEAN_I =13;
  localparam [RSPTw-1 : 0] RSP_TYPE_UPDATE_SYS_CACHE =14;
  //max can be 27h, 28h to 39h is resereved for atomic transactions 
  



  
  localparam [RSPTw-1 : 0] ST_ADD  = 6'b101000; //h28    
  localparam [RSPTw-1 : 0] ST_CLR  = 6'b101001; //h29    
  localparam [RSPTw-1 : 0] ST_EOR  = 6'b101010; //h2A    
  localparam [RSPTw-1 : 0] ST_SET  = 6'b101011; //h2B    
  localparam [RSPTw-1 : 0] ST_SMAX = 6'b101100; //h2C    
  localparam [RSPTw-1 : 0] ST_SMIN = 6'b101101; //h2D    
  localparam [RSPTw-1 : 0] ST_UMAX = 6'b101110; //h2E    
  localparam [RSPTw-1 : 0] ST_UMIN = 6'b101111; //h2F    
                                       
  localparam [RSPTw-1 : 0] LD_ADD  = 6'b110000;  //h30   
  localparam [RSPTw-1 : 0] LD_CLR  = 6'b110001;  //h31   
  localparam [RSPTw-1 : 0] LD_EOR  = 6'b110010;  //h32   
  localparam [RSPTw-1 : 0] LD_SET  = 6'b110011;  //h33   
  localparam [RSPTw-1 : 0] LD_SMAX = 6'b110100;  //h34   
  localparam [RSPTw-1 : 0] LD_SMIN = 6'b110101;  //h35   
  localparam [RSPTw-1 : 0] LD_UMAX = 6'b110110;  //h36   
  localparam [RSPTw-1 : 0] LD_UMIN = 6'b110111;  //h37   
  localparam [RSPTw-1 : 0] LD_SWAP = 6'b111000;  //h38;             
  localparam [RSPTw-1 : 0] LD_COMP = 6'b111001;  //h39;             
     
    
    
    



     localparam RNF_TXN_DATAw = //CACHE_STATUSw +
     1+ OPCODE_REQ + ADDR_REQ + BE_DAT;   
     
     localparam HNF_RXRSP_TXN_DATAw = 1+ RSPTw + ADDR_REQ + TXNID_REQ + SRCID_REQ;// + CACHE_STATUSw;
     localparam SNF_TXN_DATAw =   ADDR_REQ + OPCODE_REQ;
     localparam SNPF_ACTw=6;
   
   
   
     localparam [1:0]
        SNPF_NO_CHANGE = 2'b00,
        SNPF_ASSERT = 2'b01,
        SNPF_CLEAR = 2'b10,
        SNPF_REPLACE = 2'b11;
   
   
    // CompDat 
    localparam [RESP_DAT-1 : 0 ] CompData_I ='b000 ;
    localparam [RESP_DAT-1 : 0 ] CompData_SC ='b001;  
    localparam [RESP_DAT-1 : 0 ] CompData_UC = 'b010; 
  
    localparam [RESP_DAT-1 : 0 ] CompData_UD_PD ='b110;  
    localparam [RESP_DAT-1 : 0 ] CompData_SD_PD ='b111;
    
    //Comp
    localparam [RESP_DAT-1 : 0 ] Comp_I  = 3'b000;
    localparam [RESP_DAT-1 : 0 ] Comp_UC = 3'b010;
    localparam [RESP_DAT-1 : 0 ] Comp_SC = 3'b001;
    
    //snp_rsp 
    localparam [RESP_RSP-1 : 0 ] SnpResp_I  = 3'b000;// Snoop response without data.Cache line state is I.
    localparam [RESP_RSP-1 : 0 ] SnpResp_SC = 3'b001;// Snoop response without data.Cache line state is SC, or I.
    localparam [RESP_RSP-1 : 0 ] SnpResp_UC = 3'b010;// Snoop response without data.Cache line state is UC, UCE, SC, or I.
    localparam [RESP_RSP-1 : 0 ] SnpResp_UD = 3'b010;// Snoop response without data.Cache line state is UD.
    localparam [RESP_RSP-1 : 0 ] SnpResp_SD = 3'b011;// Snoop response without data.Cache line state is SD.
    
   //exclusive monitor parameters
   localparam EXCL_TAG_ADRw =10;
   localparam MAX_EXCL_LP_PER_RN =2;
  
    
   localparam [1: 0]  Normal_Okay = 2'b00;
   localparam [1: 0]  Excl_Failed = 2'b00;
   localparam [1: 0]  Excl_Okey   = 2'b01;
   localparam [1: 0]  Data_Error  = 2'b10;

  
   localparam  DU_CORE_ACTw = 2;
   localparam  ALU_OPTw=4;
   localparam  DU_ACTw = DU_CORE_ACTw+ALU_OPTw+1; 
   localparam  LKPT_IS_INIT = 1'b1;
   localparam  CURRENT_IS_INIT = 1'b0;
   
 
    localparam [DU_CORE_ACTw-1 : 0] SAVE_ALU_TX_OFF  = 2'b00;
    localparam [DU_CORE_ACTw-1 : 0] SAVE_ALU_TX_DIN  = 2'b01;
    localparam [DU_CORE_ACTw-1 : 0] SAVE_ALU_TX_ALU  = 2'b10;

    
   
    
    localparam [ALU_OPTw-1 : 0] ALU_ADD   = 0 ;
    localparam [ALU_OPTw-1 : 0] ALU_CLR   = 1 ;
    localparam [ALU_OPTw-1 : 0] ALU_EOR   = 2 ;
    localparam [ALU_OPTw-1 : 0] ALU_SET   = 3 ;
    localparam [ALU_OPTw-1 : 0] ALU_SMAX  = 4 ;
    localparam [ALU_OPTw-1 : 0] ALU_SMIN  = 5 ;
    localparam [ALU_OPTw-1 : 0] ALU_UMAX  = 6 ;
    localparam [ALU_OPTw-1 : 0] ALU_UMIN  = 7 ;
    localparam [ALU_OPTw-1 : 0] ALU_SWAP  = 8 ;
    localparam [ALU_OPTw-1 : 0] ALU_BPASS = 9 ;
    
    
    
 
    
    
    

localparam ST_SEL_BIT =4;

localparam 
        RD_HIT_NUM  =0,
        RD_MISS_NUM =1,
        WR_HIT_NUM  =2,
        WR_MISS_NUM =3,
        EVICT_HIT_NUM=4,
        EVICT_MISS_NUM=5,
        REFILL_NUM=6,
        USED_NUM=7,
        STATIC_NUM=8;

localparam 
      RDSHD_HIT  = 0,
      RDSHD_MISS = 1,
      RDUNQ_HIT  = 2, 
      RDUNQ_MISS = 3,
      RDCLNQ_HIT = 4,
      RDCLNQ_MISS =5,
      RDREQ_ST_NUM=6; 








	//synthesis translate_off 
    //synopsys  translate_off

     
    //statistic variables
    localparam [1: 0]
        RNF_CODE=2'b01,
        HNF_CODE=2'b10,
        SNF_CODE=2'b11;    
            
    localparam 
    STATISTICw= 8 + 1 + 1 + 2, //{opcode, sent+/receive, exel, NODE_CODE}
    STATISTIC_NUM = 2**STATISTICw;
    

      function [159 : 0] get_req_opcode_str;
      input  [OPCODE_REQ-1 : 0] opcode; begin   
        get_req_opcode_str = "Undefined          ";
        case(opcode)                            
        REQ_OPCODE_ReqLCrdReturn         :       get_req_opcode_str =       "ReqLCrdReturn       ";
        REQ_OPCODE_ReadShared            :       get_req_opcode_str =       "ReadShared          ";
        REQ_OPCODE_ReadClean             :       get_req_opcode_str =       "ReadClean           ";
        REQ_OPCODE_ReadOnce              :       get_req_opcode_str =       "ReadOnce            ";
        REQ_OPCODE_ReadNoSnp             :       get_req_opcode_str =       "ReadNoSnp           ";
        REQ_OPCODE_PCrdReturn            :       get_req_opcode_str =       "PCrdReturn          ";
        REQ_OPCODE_Reserved              :       get_req_opcode_str =       "Reserved            ";
        REQ_OPCODE_ReadUnique            :       get_req_opcode_str =       "ReadUnique          ";
        REQ_OPCODE_CleanShared           :       get_req_opcode_str =       "CleanShared         ";
        REQ_OPCODE_CleanInvalid          :       get_req_opcode_str =       "CleanInvalid        ";
        REQ_OPCODE_MakeInvalid           :       get_req_opcode_str =       "MakeInvalid         ";
        REQ_OPCODE_CleanUnique           :       get_req_opcode_str =       "CleanUnique         ";
        REQ_OPCODE_MakeUnique            :       get_req_opcode_str =       "MakeUnique          ";
        REQ_OPCODE_Evict                 :       get_req_opcode_str =       "Evict               ";
        REQ_OPCODE_DVMOp                 :       get_req_opcode_str =       "DVMOp               ";
        REQ_OPCODE_WriteEvictFull        :       get_req_opcode_str =       "WriteEvictFull      ";
        REQ_OPCODE_WriteCleanFull        :       get_req_opcode_str =       "WriteCleanFull      ";
        REQ_OPCODE_WriteUniquePtl        :       get_req_opcode_str =       "WriteUniquePtl      ";
        REQ_OPCODE_WriteUniqueFull       :       get_req_opcode_str =       "WriteUniqueFull     ";     
        REQ_OPCODE_WriteBackPtl          :       get_req_opcode_str =       "WriteBackPtl        ";
        REQ_OPCODE_WriteBackFull         :       get_req_opcode_str =       "WriteBackFull       ";
        REQ_OPCODE_WriteNoSnpPtl         :       get_req_opcode_str =       "WriteNoSnpPtl       ";
        REQ_OPCODE_WriteNoSnpFull        :       get_req_opcode_str =       "WriteNoSnpFull      ";
        REQ_OPCODE_WriteUniqueFullStash  :       get_req_opcode_str =       "WriteUniqueFullStash";     
        REQ_OPCODE_WriteUniquePtlStash   :       get_req_opcode_str =       "WriteUniquePtlStash ";     
        REQ_OPCODE_StashOnceShared       :       get_req_opcode_str =       "StashOnceShared     ";     
        REQ_OPCODE_StashOnceUnique       :       get_req_opcode_str =       "StashOnceUnique     ";     
        REQ_OPCODE_ReadOnceCleanInvalid  :       get_req_opcode_str =       "ReadOnceCleanInvalid";     
        REQ_OPCODE_ReadOnceMakeInvalid   :       get_req_opcode_str =       "ReadOnceMakeInvalid ";     
        REQ_OPCODE_ReadNotSharedDirty    :       get_req_opcode_str =       "ReadNotSharedDirty  ";     
        REQ_OPCODE_CleanSharedPersist    :       get_req_opcode_str =       "CleanSharedPersist  ";     
        REQ_OPCODE_PrefetchTgt           :       get_req_opcode_str =       "PrefetchTgt         ";
            
        REQ_OPCODE_AtomicStore_ADD       :       get_req_opcode_str =      "AtomicStore_ADD     ";
        REQ_OPCODE_AtomicStore_CLR       :       get_req_opcode_str =      "AtomicStore_CLR     "; 
        REQ_OPCODE_AtomicStore_EOR       :       get_req_opcode_str =      "AtomicStore_EOR     "; 
        REQ_OPCODE_AtomicStore_SET       :       get_req_opcode_str =      "AtomicStore_SET     "; 
        REQ_OPCODE_AtomicStore_SMAX      :       get_req_opcode_str =      "AtomicStore_SMAX    "; 
        REQ_OPCODE_AtomicStore_SMIN      :       get_req_opcode_str =      "AtomicStore_SMIN    "; 
        REQ_OPCODE_AtomicStore_UMAX      :       get_req_opcode_str =      "AtomicStore_UMAX    "; 
        REQ_OPCODE_AtomicStore_UMIN      :       get_req_opcode_str =      "AtomicStore_UMIN    "; 

        REQ_OPCODE_AtomicLoad_ADD        :       get_req_opcode_str =      "AtomicLoad_ADD      "; 
        REQ_OPCODE_AtomicLoad_CLR        :       get_req_opcode_str =      "AtomicLoad_CLR      "; 
        REQ_OPCODE_AtomicLoad_EOR        :       get_req_opcode_str =      "AtomicLoad_EOR      "; 
        REQ_OPCODE_AtomicLoad_SET        :       get_req_opcode_str =      "AtomicLoad_SET      "; 
        REQ_OPCODE_AtomicLoad_SMAX       :       get_req_opcode_str =      "AtomicLoad_SMAX     "; 
        REQ_OPCODE_AtomicLoad_SMIN       :       get_req_opcode_str =      "AtomicLoad_SMIN     "; 
        REQ_OPCODE_AtomicLoad_UMAX       :       get_req_opcode_str =      "AtomicLoad_UMAX     "; 
        REQ_OPCODE_AtomicLoad_UMIN       :       get_req_opcode_str =      "AtomicLoad_UMIN     "; 
        REQ_OPCODE_AtomicSwap            :       get_req_opcode_str =      "AtomicSwap          "; 
        REQ_OPCODE_AtomicCompare         :       get_req_opcode_str =      "AtomicCompare       "; 
	    default                          :       get_req_opcode_str =      "Undefined           ";
        endcase
      end   
    endfunction 
    
    
    function [159 : 0] get_rsp_opcode_str;
    input  [OPCODE_RSP-1:0] opcode;
    begin    
        get_rsp_opcode_str = "Undefined     ";
        case(opcode)     
       4'h0: get_rsp_opcode_str = "RESP_LCRD_RETURN    "; 
       4'h1: get_rsp_opcode_str = "SNP_RESP            "; 
       4'h2: get_rsp_opcode_str = "COMP_ACK            "; 
       4'h3: get_rsp_opcode_str = "RETRY_ACK           "; 
       4'h4: get_rsp_opcode_str = "COMP                "; 
       4'h5: get_rsp_opcode_str = "COMP_DBID_RESP      "; 
       4'h6: get_rsp_opcode_str = "DBID_RESP           "; 
       4'h7: get_rsp_opcode_str = "PC_RD_GRANT         "; 
       4'h8: get_rsp_opcode_str = "READ_RECEIPT        "; 
       4'h9: get_rsp_opcode_str = "SNP_RESP_FWDED      "; 
       4'hb: get_rsp_opcode_str = "RESP_SEP_DATA       ";
	   default:  get_rsp_opcode_str = "Undefined     ";                        
       endcase
    end
    endfunction
    
    function [159 : 0] get_rsp_opcode_resp_str;
    input  [OPCODE_RSP-1:0] opcode;
    input  [RESP_DAT-1: 0 ] resp;
    begin    
        get_rsp_opcode_resp_str = "Undefined     ";
        case(opcode)     
       4'h0: get_rsp_opcode_resp_str = "RESP_LCRD_RETURN    "; 
       4'h1: case(resp)                        
           SnpResp_I  : get_rsp_opcode_resp_str = "SNP_RESP_I          ";
           SnpResp_SC : get_rsp_opcode_resp_str = "SNP_RESP_SC         ";
           SnpResp_UC : get_rsp_opcode_resp_str = "SNP_RESP_UC         ";
           SnpResp_UD : get_rsp_opcode_resp_str = "SNP_RESP_UD         ";
           SnpResp_SD : get_rsp_opcode_resp_str = "SNP_RESP_SD         ";
           default:     get_rsp_opcode_resp_str = "SnpResp_Undefined   ";
           endcase
       4'h2: get_rsp_opcode_resp_str = "COMP_ACK            "; 
       4'h3: get_rsp_opcode_resp_str = "RETRY_ACK           "; 
       4'h4: case(resp)
           Comp_I:  get_rsp_opcode_resp_str = "COMP_I              ";
           Comp_UC: get_rsp_opcode_resp_str = "COMP_UC             ";
           Comp_SC: get_rsp_opcode_resp_str = "COMP_SC             ";
           default: get_rsp_opcode_resp_str = "COMP_Undefined      "; 
     
            endcase 
       4'h5: get_rsp_opcode_resp_str = "COMP_DBID_RESP      "; 
       4'h6: get_rsp_opcode_resp_str = "DBID_RESP           "; 
       4'h7: get_rsp_opcode_resp_str = "PC_RD_GRANT         "; 
       4'h8: get_rsp_opcode_resp_str = "READ_RECEIPT        "; 
       4'h9: get_rsp_opcode_resp_str = "SNP_RESP_FWDED      "; 
       4'hb: get_rsp_opcode_resp_str = "RESP_SEP_DATA       ";
       default:  get_rsp_opcode_resp_str = "Undefined     ";                        
       endcase
    end
    endfunction
    
  
  
   
  
    
    
    
    function [159 : 0] get_dat_opcode_str;
    input  [OPCODE_DAT-1 : 0]  opcode;  
    begin   
        get_dat_opcode_str = "Undefined     ";
        case(opcode)                      
        4'h0: get_dat_opcode_str = "DATA_LCRD_RETURN    ";
        4'h1: get_dat_opcode_str = "SNP_RSP_DATA        ";
        4'h2: get_dat_opcode_str = "COPY_BACK_WR_DATA   ";
        4'h3: get_dat_opcode_str = "NON_COPY_BACK_WR_DAT"; 
        4'h4: get_dat_opcode_str = "COMP_DATA           ";        
        4'h5: get_dat_opcode_str = "SNP_RESP_DATA_PTL   ";
        4'h6: get_dat_opcode_str = "SNP_RESP_DATA_FWDED ";
        4'h7: get_dat_opcode_str = "WRITE_DATA_CANCEL   ";
        4'hb: get_dat_opcode_str = "DATA_SEP_RESP       ";
        4'hc: get_dat_opcode_str = "NCB_WR_DATA_COMP_ACK"; 
	  	default: get_dat_opcode_str = "Undefined     ";         
        endcase
   end
   endfunction 
   
   
   function [159 : 0] get_dat_opcode_resp_str;
    input  [OPCODE_DAT-1 : 0]  opcode;
    input  [RESP_DAT-1   : 0]  resp;
    begin   
        get_dat_opcode_resp_str = "Undefined     ";
        case(opcode)                      
        4'h0: get_dat_opcode_resp_str = "DATA_LCRD_RETURN    ";
        4'h1: get_dat_opcode_resp_str = "SNP_RSP_DATA        ";
        4'h2: get_dat_opcode_resp_str = "COPY_BACK_WR_DATA   ";
        4'h3: get_dat_opcode_resp_str = "NON_COPY_BACK_WR_DAT"; 
        4'h4: case( resp)  
             CompData_I     :   get_dat_opcode_resp_str = "COMP_DATA_I         ";
             CompData_SC    :   get_dat_opcode_resp_str = "COMP_DATA_SC        ";
             CompData_UC    :   get_dat_opcode_resp_str = "COMP_DATA_UC        ";
             CompData_UD_PD :   get_dat_opcode_resp_str = "COMP_DATA_UD_PD     ";
             CompData_SD_PD :   get_dat_opcode_resp_str = "COMP_DATA_SD_PD     ";
             default        :   get_dat_opcode_resp_str = "COMP_DATA_Undefined ";       
              endcase
        4'h5: get_dat_opcode_resp_str = "SNP_RESP_DATA_PTL   ";
        4'h6: get_dat_opcode_resp_str = "SNP_RESP_DATA_FWDED ";
        4'h7: get_dat_opcode_resp_str = "WRITE_DATA_CANCEL   ";
        4'hb: get_dat_opcode_resp_str = "DATA_SEP_RESP       ";
        4'hc: get_dat_opcode_resp_str = "NCB_WR_DATA_COMP_ACK"; 
        default: get_dat_opcode_resp_str = "Undefined     ";         
        endcase
   end
   endfunction 
   
    
    
    function [159 : 0] get_snp_opcode_str;
    input  [OPCODE_SNP-1:0] opcode;
    begin   
        get_snp_opcode_str = "Undefined     ";
        case(opcode)                         
          5'h0:   get_snp_opcode_str = "SNP_LCRD_RETURN     ";
          5'h1:   get_snp_opcode_str = "SNP_SHARED          ";
          5'h2:   get_snp_opcode_str = "SNP_CLEAN           ";
          5'h3:   get_snp_opcode_str = "SNP_ONCE            ";
          5'h4:   get_snp_opcode_str = "SNP_NOT_SHARED_DIRTY";
          5'h5:   get_snp_opcode_str = "SNP_UNIQUE_STASH    ";
          5'h6:   get_snp_opcode_str = "SNP_MAKE_INVALID_STA";
          5'h7:   get_snp_opcode_str = "SNP_UNIQUE          ";
          5'h8:   get_snp_opcode_str = "SNP_CLEAN_SHARED    ";
          5'h9:   get_snp_opcode_str = "SNP_CLEAN_INVALID   ";
          5'ha:   get_snp_opcode_str = "SNP_MAKE_INVALID    ";
          5'hb:   get_snp_opcode_str = "SNP_STASH_UNIQUE    ";
          5'hc:   get_snp_opcode_str = "SNP_STASH_SHARED    ";
          5'hd:   get_snp_opcode_str = "SNP_DVM_OP          ";
          5'h11:  get_snp_opcode_str = "SNP_SHARED_FWD      ";
          5'h12:  get_snp_opcode_str = "SNP_CLEAN_FWD       ";
          5'h13:  get_snp_opcode_str = "SNP_ONCE_FWD        ";
          5'h14:  get_snp_opcode_str = "SNP_NOT_SHARED_DIR_F";
          5'h17:  get_snp_opcode_str = "SNP_UNIQUE_FWD      ";
		  default:  get_snp_opcode_str = "Undefined     ";         
        endcase
    end
    endfunction
    
     ////{NODE_CODE, opcode, exel,sent+/receive }
    function [STATISTICw-1 : 0]  get_statistic_target;
        input [7: 0] opcode;
        input [15 : 0] txrx;
        input xcl;
        input [23 : 0] node;
       
        
        begin
        
        get_statistic_target[0]= (txrx == "TX" )? 1'b1 : 1'b0;
        get_statistic_target[1]= xcl;      
        get_statistic_target[9:2]=opcode;
        get_statistic_target [11:10] = 
            ( node == "rnf")? RNF_CODE :
            ( node == "hnf")? HNF_CODE : SNF_CODE;
        end
    endfunction
   
   
     
   
   
   
   
   
 
     //synopsys  translate_on
    //synthesis translate_on 
   


    // chi reqflit logic packet definition
    typedef struct packed {
        logic [QOS_REQ-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [TGTID_REQ-1:0]           tgtid  ;
        logic [SRCID_REQ-1:0]           srcid  ;
        logic [TXNID_REQ-1:0]           txnid;
        logic [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
        //logic                           endian; // = 1'b1;
        logic [RETURNTXNID_REQ-1:0]     returntxnid ;
        logic [OPCODE_REQ-1:0]          opcode ;
        logic [SIZE_REQ-1:0]            flitsize; // = 3'b110 ;
        logic [ADDR_REQ-1:0]            addr ;
      //  logic                           ns; // = 1'b1;
      //  logic                           likelyshared; // = 1'b0;
        logic                           allowretry; // = 1'b1;
        logic [ORDER_REQ-1:0]           order; // = 2'b11;
        logic [PCRDTYPE_REQ-1:0]        pcrdtype; // = 4'b0000;
        logic [MEMATTR_REQ-1:0]         memattr;// = 4'b0111;
        logic                           snpattr; // = 1'b1;
        logic [LPID_REQ-1:0]            lpid; // = 5'b00000;
        logic                           excl_snoopme; // = 1'b1;
        logic                           expcompack;
       // logic                           tracetag; // = 1'b0;
    } chi_reqflit_pkt_t;

    localparam CHI_REQFLIT_PKT_W = $bits(chi_reqflit_pkt_t);
   
                               

    // chi datflit logic packet definition
    typedef struct packed {
        logic [QOS_DAT-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [TGTID_DAT-1:0]           tgtid  ;
        logic [SRCID_DAT-1:0]           srcid  ;
        logic [TXNID_DAT-1:0]           txnid  ;
        logic [HOMENID_DAT-1:0]         homenid; // 
        logic [OPCODE_DAT-1:0]          opcode ;
        logic [RESPERR_DAT-1:0]         resperr;     
        logic [RESP_DAT-1:0]            resp;
        logic [FWD_DATAPULL_DAT-1:0]    fwd_datapull;
        logic [DBID_DAT-1:0]            dbid;
        //logic [CCID_DAT-1:0]            ccid;
       // logic [DATAID_DAT-1:0]          dataid;
        //logic                           tracetag; // = 1'b0;
        logic [BE_DAT-1:0]              be;
        logic [DATA_DAT-1:0]              data;
       // logic [DATACHECK_DAT-1:0]       datacheck;
       // logic [POISON_DAT-1:0]          poison;
    } chi_datflit_pkt_t;

    //localparam CHI_DATFLIT_PKT_W = $bits(chi_datflit_pkt_t);
    //localparam DAT_FLIT_SIZE = CHI_DATFLIT_PKT_W;
 
    // chi rspflit logic packet definition
    typedef struct packed {
        logic [QOS_RSP-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [TGTID_RSP-1:0]           tgtid  ;
        logic [SRCID_RSP-1:0]           srcid  ;
        logic [TXNID_RSP-1:0]           txnid  ;
        logic [OPCODE_RSP-1:0]          opcode ;
        logic [RESPERR_RSP-1:0]         resperr;     
        logic [RESP_RSP-1:0]            resp;
        logic [FWD_DATAPULL_RSP-1:0]    fwd_datapull;
        logic [DBID_RSP-1:0]            dbid;
        logic [PCRDTYPE_RSP-1:0]        pcrdtype; // = 4'b0000;
       // logic                           tracetag; // = 1'b0;
    } chi_rspflit_pkt_t;

    //localparam CHI_RSPFLIT_PKT_W = $bits(chi_rspflit_pkt_t);
    //localparam RSP_FLIT_SIZE = CHI_RSPFLIT_PKT_W;
 
    // chi snpflit logic packet definition
    typedef struct packed {
        logic [QOS_SNP-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [SRCID_SNP-1:0]           srcid  ;
        logic [TXNID_SNP-1:0]           txnid  ;
        logic [FWDNID_SNP-1:0]          fwdnid  ;
        logic [FWDTXNID_SNP-1:0]        fwdtxnid  ;
        logic [OPCODE_SNP-1:0]          opcode ;
        logic [ADDR_SNP-1:0]            addr ;
        //logic                           ns ;
        logic                           donotgotosd_datapull ;
        logic                           rettosrc ;
       // logic                           tracetag; // = 1'b0;
    } chi_snpflit_pkt_t;

   // localparam SNP_FLIT_SIZE= $bits(chi_snpflit_pkt_t);
    //localparam SNP_FLIT_SIZE = CHI_SNPFLIT_PKT_W; 

    //localparam L_CREDITS_NUM = 15;
    //localparam LOG_LCREDITS_NUM = 4;

    localparam 
    	MONITORE_FLIT_INJECT = (2**0),
    	MONITORE_TXN_CMD = (2**1),
    	MONITORE_CACHE = (2**2),
    	MONITORE_SNPF = (2**3),
    	MONITORE_TXNID_GEN = (2**4),
    	MONITORE_MAIN_MEM = (2**5),
    	MONITORE_WAIT_LIST= (2**6),
    	MONITORE_REQ_TYPE= (2**7),
    	MONITORE_FLIT_OPCODE=(2**8),
    	MONITORE_HAZARDS=(2**9),
    	MONITORE_EXCL_TXN=(2**10),
    	MONITORE_DAT_ALU=(2**11),
    	MONITORE_REQ_LKPT=(2**12),
    	DISPALY_FINAL_STATISTICS=(2**13),
    	MONITORE_FLIT_FILEDS=(2**14);










	
	






//  `endif
endpackage
