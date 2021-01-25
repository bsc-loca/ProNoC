/**************************************
* Module: chi_definition
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/

`ifdef     INCLUDE_CHI_LOCALPARAM

/*********************
 * 
 * localparams for the request flit
 * 
 * *******************/
    localparam QOS_REQ = 4;
    localparam TGTID_REQ = 7; //it can be from 7-11
    localparam SRCID_REQ = 7; //it can be from 7-11
    localparam TXNID_REQ = 8;
    localparam RETURNNID_REQ = 7; //it can be from 7-11
    localparam STASHNIDVALID_REQ = 1;
    localparam RETURNTXNID_REQ = 8;
    localparam OPCODE_REQ = 6;
    localparam SIZE_REQ = 3;
    localparam ADDR_REQ = 44; //it can be from 44-52
    localparam NS_REQ = 1;
    localparam LIKELYSHARED_REQ = 1;
    localparam ALLOWRETRY_REQ = 1;
    localparam ORDER_REQ = 2;
    localparam PCRDTYPE_REQ = 4;
    localparam MEMATTR_REQ = 4;
    localparam SNPATTR_REQ = 1;
    localparam LPID_REQ = 5;
    localparam EXCL_REQ = 1;
    localparam EXPCOMPACK_REQ = 1;
    localparam TRACETAG_REQ = 1;
    localparam RSVDC_REQ = 4; //in case there is no RSVDC bus
                          //in case there is values can be 4,12,16,24,32


    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReqLCrdReturn  ='h00;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadShared ='h01; 
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadClean ='h02; 
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadOnce ='h03;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadNoSnp ='h04;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_PCrdReturn ='h05; 
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_Reserved ='h06;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadUnique ='h07;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_CleanShared ='h08;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_CleanInvalid ='h09;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_MakeInvalid ='h0A;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_CleanUnique ='h0B;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_MakeUnique ='h0C;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_Evict ='h0D;
    //0x0E Reserved (EOBarrier)
    //0x0F Reserved (ECBarrier)
    //0x10 - 0x13 Reserved
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_DVMOp ='h14;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteEvictFull ='h15;
    //0x16 Reserved (WriteCleanPtl) 16
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteCleanFull ='h17;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteUniquePtl ='h18;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteUniqueFull ='h19;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteBackPtl ='h1A;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteBackFull ='h1B;
    
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteNoSnpPtl ='h1C;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteNoSnpFull ='h1D;
    //0x1E - 0x1F Reserved 1E
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteUniqueFullStash ='h20;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_WriteUniquePtlStash ='h21;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_StashOnceShared ='h22;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_StashOnceUnique ='h23;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadOnceCleanInvalid ='h24;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadOnceMakeInvalid ='h25;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_ReadNotSharedDirty ='h26;
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_CleanSharedPersist ='h27;
    
   
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_ADD  = 6'b101000; //28
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_CLR  = 6'b101001; //29
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_EOR  = 6'b101010; //2A
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_SET  = 6'b101011; //2B
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_SMAX = 6'b101100; //2C
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_SMIN = 6'b101101; //2D
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_UMAX = 6'b101110; //2E 
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicStore_UMIN = 6'b101111; //2F

    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_ADD   = 6'b110000;  //30
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_CLR   = 6'b110001;  //31
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_EOR   = 6'b110010;  //32
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_SET   = 6'b110011;  //33
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_SMAX  = 6'b110100;  //34
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_SMIN  = 6'b110101;  //35
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_UMAX  = 6'b110110;  //36
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicLoad_UMIN  = 6'b110111;  //37
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicSwap       = 6'h38;     
    localparam [OPCODE_REQ-1 : 0] REQ_OPCODE_AtomicCompare    = 6'h39;
      
    
    //0x28 - 0x2F REQ_OPCODE_AtomicStore 28
    //0x30 - 0x37 REQ_OPCODE_AtomicLoad 
    //0x38 AtomicSwap
    //0x39 AtomicCompare
    localparam [OPCODE_REQ-1 : 0]   REQ_OPCODE_PrefetchTgt ='h3A;
    //0x3B - 0x3F Reserved


    localparam REQ_FLIT_SIZE = 
        QOS_REQ +         //     qos; // = {QOS_REQ{1'b0}};
        TGTID_REQ +       //   tgtid  ;
        SRCID_REQ +       //   srcid  ;
        TXNID_REQ +       //    txnid;
        RETURNNID_REQ +   //    returnnid; // = {RETURNNID_REQ{1'b0}};
        1 +               //    endian; // = 1'b1;
        RETURNTXNID_REQ + //     returntxnid ;
        OPCODE_REQ +      //     opcode ;
        SIZE_REQ  +       //    flitsize; // = 3'b110 ;
        ADDR_REQ  +       //    addr ;
        1 +               //             ns; // = 1'b1;
        1 +               //           likelyshared; // = 1'b0;
        1 +               //          allowretry; // = 1'b1;
        ORDER_REQ  +      //  order; // = 2'b11;
        PCRDTYPE_REQ +    //     pcrdtype; // = 4'b0000;
        MEMATTR_REQ  +    //    memattr;// = 4'b0111;
        1 +              //            snpattr; // = 1'b1;
        LPID_REQ  +      //    lpid; // = 5'b00000;
        1 +              //             excl_snoopme; // = 1'b1;
        1 +              //            expcompack;
        1 ;              //             tracetag; // = 1'b0;


/**************************
 *  localparams for the data flit 
 * ***********************/


    localparam QOS_DAT = 4;
    localparam TGTID_DAT = 7; //it can be from 7-11
    localparam SRCID_DAT = 7; //it can be from 7-11
    localparam TXNID_DAT = 8;
    localparam HOMENID_DAT = 7; //it can be from 7-11
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




    localparam [OPCODE_DAT-1:0] OPCODE_DAT_aLCrdReturn  = 'h0 ;
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_SnpRespData = 'h1 ;
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_CopyBackWrData = 'h2; 
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_NonCopyBackWrData = 'h3; 
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_CompData = 'h4 ;
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_SnpRespDataPtl = 'h5; 
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_SnpRespDataFwded = 'h6; 
    localparam [OPCODE_DAT-1:0] OPCODE_DAT_WriteDataCancel = 'h7;
   // localparam [OPCODE_DAT-1:0] OPCODE_DAT_DataSepResp = 'hB;  
   // localparam [OPCODE_DAT-1:0] OPCODE_DAT_NCBWrDataCompAck = 'hC;


    // chi datflit logic packet definition
    localparam DAT_FLIT_SIZE = 
        QOS_DAT +         //    qos; // = {QOS_REQ{1'b0}};
        TGTID_DAT +       //    tgtid  ;
        SRCID_DAT +       //    srcid  ;
        TXNID_DAT +       //    txnid  ;
        HOMENID_DAT +     //    homenid; // 
        OPCODE_DAT +    //      opcode ;
        RESPERR_DAT +     //    resperr;     
        RESP_DAT +        // resp;
        FWD_DATAPULL_DAT +//    fwd_datapull;
        DBID_DAT +        //    dbid;
        CCID_DAT +        //    ccid;
        DATAID_DAT +      //    dataid;
        1 +               //            tracetag; // = 1'b0;
        BE_DAT +          //    be;
        DATA_DAT +        //      data;
        DATACHECK_DAT + //      datacheck;
        POISON_DAT ;      //    poison;



    localparam DAT_FLIT_SNOC_SIZE =
        QOS_DAT +         //    qos; // = {QOS_REQ{1'b0}};
        TGTID_DAT +       //    tgtid  ;
        SRCID_DAT +       //    srcid  ;
        TXNID_DAT +       //    txnid  ;
        HOMENID_DAT +     //    homenid; // 
        OPCODE_DAT +    //      opcode ;
        RESPERR_DAT +     //    resperr;     
        RESP_DAT +        // resp;
        FWD_DATAPULL_DAT +//    fwd_datapull;
        DBID_DAT +        //    dbid;
        CCID_DAT +        //    ccid;
        DATAID_DAT +      //    dataid;
        1 +               //            tracetag; // = 1'b0;
        BE_DAT +          //    be;
        DATA_DAT;         //      data;
   

/***********************
 *  localparams for the response flit 
 * *********************/


    localparam QOS_RSP = 4;
    localparam TGTID_RSP = 7; //it can be from 7-11
    localparam SRCID_RSP = 7; //it can be from 7-11
    localparam TXNID_RSP = 8;
    localparam OPCODE_RSP = 4;
    localparam RESPERR_RSP = 2;
    localparam RESP_RSP = 3;
    localparam FWD_DATAPULL_RSP = 3;
    localparam DBID_RSP = 8;
    localparam PCRDTYPE_RSP = 4;
    localparam TRACETAG_RSP = 1;
    
    
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_RespLCrdReturn  = 4'd0;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_SnpResp = 4'd1;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_CompAck = 4'd2; 
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_RetryAck = 4'd3;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_Comp = 4'd4;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_CompDBIDResp = 4'd5;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_DBIDResp = 4'd6;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_PCrdGrant = 4'd7;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_ReadReceipt = 4'd8;
    localparam [OPCODE_RSP-1:0] RSP_OPCODE_SnpRespFwded = 4'd9;
    
    localparam RSP_FLIT_SIZE = 
        QOS_RSP +          //    qos; // = {QOS_REQ{1'b0}};
        TGTID_RSP +        //   tgtid  ;
        SRCID_RSP +        //   srcid  ;
        TXNID_RSP +        //   txnid  ;
        OPCODE_RSP +       //   opcode ;
        RESPERR_RSP +      //   resperr;     
        RESP_RSP +         //   resp;
        FWD_DATAPULL_RSP + //   fwd_datapull;
        DBID_RSP +         //   dbid;
        PCRDTYPE_RSP +     //   pcrdtype; // = 4'b0000;
        1;//                          tracetag; // = 1'b0;
   
    
    
    
    /*****************************
     * localparams for the   snoop flit 
     *****************************/
    

    
    localparam QOS_SNP = 4;
    localparam SRCID_SNP = 7; //it can be from 7-11
    localparam TXNID_SNP = 8;
    localparam FWDNID_SNP = 7;
    localparam FWDTXNID_SNP = 8;
    localparam OPCODE_SNP = 5;
    localparam ADDR_SNP = 44;
    localparam NS_SNP = 1;
    localparam DONOTGOTOSD_DONOTDATAPULL_SNP = 1;
    localparam RETTOSRC = 1;
    localparam TRACETAG_SNP = 1;



    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpLCrdReturn = 5'h0;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpShared     = 5'h1;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpClean      = 5'h2;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpOnce       = 5'h3;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpNotSharedDirty = 5'h4;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpUniqueStash  = 5'h5;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpMakeInvalidStash  = 5'h6;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpUnique  =5'h7;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpCleanShared  =5'h8;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpCleanInvalid  =5'h9;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpMakeInvalid  =5'hA;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpStashUnique  =5'hB;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpStashShared  =5'hC;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpDVMOp  =5'hD;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpSharedFwd  =5'h11;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpCleanFwd  =5'h12;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpOnceFwd  =5'h13;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpNotSharedDirtyFwd  =5'h14;
    localparam [OPCODE_SNP-1:0] SNP_OPCODE_SnpUniqueFwd  =5'h17;    

   
    localparam SNP_FLIT_SIZE = 
        QOS_SNP +          // qos; // = {QOS_REQ{1'b0}};
        SRCID_SNP +        //   srcid  ;
        TXNID_SNP +        //   txnid  ;
        FWDNID_SNP +       //   fwdnid  ;
        FWDTXNID_SNP +     //   fwdtxnid  ;
        OPCODE_SNP +       //   opcode ;
        ADDR_SNP +         //   addr ;
        1+                   //        ns ;
        1+                   //        donotgotosd_datapull ;
        1+                   //        rettosrc ;
        1;                   //        tracetag; // = 1'b0;
          
     
     
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
         
      //response type identifier
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
     1+ OPCODE_REQ + ADDR_REQ;   
     
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
    
    
    
    //VERBOSITY simulation parameter
    
    //synthesis translate_off 
    //synopsys  translate_off
    
    localparam 
        MONITORE_FLIT_INJECT = (2**0),
        MONITORE_TXN_CMD = (2**1),
        MONITORE_CACHE = (2**2),
        MONITORE_SNPF = (2**3),
        MONITORE_TXNID_GEN = (2**4),
        MONITORE_MAIN_MEM = (2**5),
        MONITORE_WAIT_LIST= (2**6),
        MONITORE_REQ_TYPE= (2**7),
        MONITORE_FLIT_INJECT_FILEDS=(2**8),
        MONITORE_HAZARDS=(2**9),
        MONITORE_EXCL_TXN=(2**10),
        MONITORE_DAT_ALU=(2**11),
        MONITORE_REQ_LKPT=(2**12);
        
    
    
    
    
    
    //synthesis translate_on 
    //synopsys  translate_on
    
    
    
    
    
    

/*

    // chi reqflit logic packet definition
    typedef struct packed {
        logic [QOS_REQ-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [TGTID_REQ-1:0]           tgtid  ;
        logic [SRCID_REQ-1:0]           srcid  ;
        logic [TXNID_REQ-1:0]           txnid;
        logic [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
        logic                           endian; // = 1'b1;
        logic [RETURNTXNID_REQ-1:0]     returntxnid ;
        logic [OPCODE_REQ-1:0]          opcode ;
        logic [SIZE_REQ-1:0]            flitsize; // = 3'b110 ;
        logic [ADDR_REQ-1:0]            addr ;
        logic                           ns; // = 1'b1;
        logic                           likelyshared; // = 1'b0;
        logic                           allowretry; // = 1'b1;
        logic [ORDER_REQ-1:0]           order; // = 2'b11;
        logic [PCRDTYPE_REQ-1:0]        pcrdtype; // = 4'b0000;
        logic [MEMATTR_REQ-1:0]         memattr;// = 4'b0111;
        logic                           snpattr; // = 1'b1;
        logic [LPID_REQ-1:0]            lpid; // = 5'b00000;
        logic                           excl_snoopme; // = 1'b1;
        logic                           expcompack;
        logic                           tracetag; // = 1'b0;
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
        logic [CCID_DAT-1:0]            ccid;
        logic [DATAID_DAT-1:0]          dataid;
        logic                           tracetag; // = 1'b0;
        logic [BE_DAT-1:0]              be;
        logic [DATA_DAT:0]              data;
        logic [DATACHECK_DAT-1:0]       datacheck;
        logic [POISON_DAT-1:0]          poison;
    } chi_datflit_pkt_t;

    localparam CHI_DATFLIT_PKT_W = $bits(chi_datflit_pkt_t);
    localparam DAT_FLIT_SIZE = CHI_DATFLIT_PKT_W;
 
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
        logic                           tracetag; // = 1'b0;
    } chi_rspflit_pkt_t;

    localparam CHI_RSPFLIT_PKT_W = $bits(chi_rspflit_pkt_t);
    localparam RSP_FLIT_SIZE = CHI_RSPFLIT_PKT_W;
 
    // chi snpflit logic packet definition
    typedef struct packed {
        logic [QOS_SNP-1:0]             qos; // = {QOS_REQ{1'b0}};
        logic [SRCID_SNP-1:0]           srcid  ;
        logic [TXNID_SNP-1:0]           txnid  ;
        logic [FWDNID_SNP-1:0]          fwdnid  ;
        logic [FWDTXNID_SNP-1:0]        fwdtxnid  ;
        logic [OPCODE_SNP-1:0]          opcode ;
        logic [ADDR_SNP-1:0]            addr ;
        logic                           ns ;
        logic                           donotgotosd_datapull ;
        logic                           rettosrc ;
        logic                           tracetag; // = 1'b0;
    } chi_snpflit_pkt_t;

    localparam CHI_SNPFLIT_PKT_W = $bits(chi_snpflit_pkt_t);
    localparam SNP_FLIT_SIZE = CHI_SNPFLIT_PKT_W; 

    localparam L_CREDITS_NUM = 15;
    localparam LOG_LCREDITS_NUM = 4;

*/



`endif
