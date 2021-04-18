/*------------------------------------------------------------------------------
* Copyright (C) 2018, 2019, SemiDynamics Technology Services, S.L.U.
* The copyright to the computer program(s) herein is the property of
* SemiDynamics Technology Services, S.L.U. All Rights Reserved.  NOTICE: the
* intellectual and technical concepts contained herein are proprietary to
* SemiDynamics Technology Services, S.L.U. and are protected by trade secret or
* copyright law.  Dissemination of this information and use or reproduction of
* this material is strictly forbidden unless prior written permission is
* obtained from SemiDynamics Technology Services, S.L.U. The program(s) may be
* used and/or reproduced only with the written permission of SemiDynamics
* Technology Services, S.L.U. and in accordance with the regulations under the
* Horizon 2020 Grant Agreement and the terms and conditions of MontBlanc 2020
* Consortium Agreement under which the program(s) have been distributed. Unless
* required by applicable law or agreed in writing, the program(s) is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied.
*-------------------------------------------------------------------------------
*   Author:         Xubin Tan
*   Email:          xubin.tan@semidynamics.com
*   Date:           12/02/2019
*-------------------------------------------------------------------------------
*   Title:          Package of localparams for the CHI Requestor agent
*
*   Description:    
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

package chi_rn_params_pkg;

/*----------------------------------------------------------------------------*/
/*CHI chanel specifications*/
/*----------------------------------------------------------------------------*/
    //localparams for the request flit 
    localparam QOS_REQ_DEFAULT = 4;
    localparam TGTID_REQ_DEFAULT = 7; //it can be from 7-11
    localparam SRCID_REQ_DEFAULT = 7; //it can be from 7-11
    localparam TXNID_REQ = 8;
    localparam RETURNNID_REQ_DEFAULT = 7; //it can be from 7-11
    localparam STASHNIDVALID_REQ = 1;
    localparam RETURNTXNID_REQ = 8;
    localparam OPCODE_REQ = 6;
    localparam SIZE_REQ = 3;
    localparam ADDR_REQ_DEFAULT = 44; //it can be from 44-52
    localparam NS_REQ = 1;
    localparam LIKELYSHARED_REQ = 1;
    localparam ALLOWRETRY_REQ = 1;
    localparam ORDER_REQ = 2;
    localparam PCRDTYPE_REQ = 4;
    localparam MEMATTR_REQ = 4;
    localparam SNPATTR_REQ = 1;
    localparam LPID_REQ_DEFAULT = 5;
    localparam EXCL_REQ = 1;
    localparam EXPCOMPACK_REQ = 1;
    localparam TRACETAG_REQ = 1;
    localparam RSVDC_REQ = 4; //in case there is no RSVDC bus
                              //in case there is values can be 4,12,16,24,32

    //localparams for the data flit 
    localparam QOS_DAT_DEFAULT = 4;
    localparam TGTID_DAT_DEFAULT = 7; //it can be from 7-11
    localparam SRCID_DAT_DEFAULT = 7; //it can be from 7-11
    localparam TXNID_DAT = 8;
    localparam HOMENID_DAT_DEFAULT = 7; //it can be from 7-11
    localparam OPCODE_DAT_DEFAULT = 4;
    localparam RESPERR_DAT = 2;
    localparam RESP_DAT = 3;
    localparam FWD_DATAPULL_DAT = 3;
    localparam DBID_DAT = 8;
    localparam CCID_DAT = 2;
    localparam DATAID_DAT = 2;
    localparam TRACETAG_DAT = 1;
    localparam RSVDC_DAT = 3; //in case there is no RSVDC bus
                              //in case there is values can be 4,12,16,24,32

    localparam DATA_DAT_DEFAULT = 512; //it can be 256 or 128  
    localparam BE_DAT_DEFAULT = DATA_DAT_DEFAULT/8;   //it can be also 32 or 64       
    localparam DATACHECK_DAT_DEFAULT = DATA_DAT_DEFAULT/8; //it can be also 16, 32 or 64
    localparam POISON_DAT_DEFAULT = DATA_DAT_DEFAULT/64; //it can be also 2, 4 or 8

    //localparams for the response flit 
    localparam QOS_RSP_DEFAULT = 4;
    localparam TGTID_RSP_DEFAULT = 7; //it can be from 7-11
    localparam SRCID_RSP_DEFAULT = 7; //it can be from 7-11
    localparam TXNID_RSP = 8;
    localparam OPCODE_RSP = 4;
    localparam RESPERR_RSP = 2;
    localparam RESP_RSP = 3;
    localparam FWD_DATAPULL_RSP = 3;
    localparam DBID_RSP = 8;
    localparam PCRDTYPE_RSP = 4;
    localparam TRACETAG_RSP = 1;

    //localparams for the income snoop flit 
    localparam QOS_SNP = 4;
    localparam SRCID_SNP = 7; //it can be from 7-11
    localparam TXNID_SNP = 8;
    localparam FWDNID_SNP = 7; //it can be from 7-11
    localparam FWDTXNID_SNP = 8;
    localparam OPCODE_SNP = 5;
    localparam ADDR_SNP_DEFAULT = 44;
    localparam NS_SNP = 1;
    localparam DONOTGOTOSD_DONOTDATAPULL_SNP = 1;
    localparam RETTOSRC = 1;
    localparam TRACETAG_SNP = 1;

    // chi reqflit logic packet definition
    typedef struct packed {
        logic [QOS_REQ_DEFAULT-1:0]     qos; 
        logic [TGTID_REQ_DEFAULT-1:0]   tgtid;
        logic [SRCID_REQ_DEFAULT-1:0]   srcid;
        logic [TXNID_REQ-1:0]           txnid;
        logic [RETURNNID_REQ_DEFAULT-1:0] returnnid; 
        logic                           endian; 
        logic [RETURNTXNID_REQ-1:0]     returntxnid;
        logic [OPCODE_REQ-1:0]          opcode;
        logic [SIZE_REQ-1:0]            flitsize; 
        logic [ADDR_REQ_DEFAULT-1:0]    addr;
        logic                           ns; 
        logic                           likelyshared; 
        logic                           allowretry; 
        logic [ORDER_REQ-1:0]           order; 
        logic [PCRDTYPE_REQ-1:0]        pcrdtype; 
        logic [MEMATTR_REQ-1:0]         memattr;
        logic                           snpattr; 
        logic [LPID_REQ_DEFAULT-1:0]    lpid; 
        logic                           excl_snoopme; 
        logic                           expcompack;
        logic                           tracetag; 
    } chi_reqflit_pkt_default_t;

    // chi datflit logic packet definition
    typedef struct packed {
        logic [QOS_DAT_DEFAULT-1:0]     qos; 
        logic [TGTID_DAT_DEFAULT-1:0]   tgtid;
        logic [SRCID_DAT_DEFAULT-1:0]   srcid;
        logic [TXNID_DAT-1:0]           txnid;
        logic [HOMENID_DAT_DEFAULT-1:0] homenid; 
        logic [OPCODE_DAT_DEFAULT-1:0]  opcode;
        logic [RESPERR_DAT-1:0]         resperr;     
        logic [RESP_DAT-1:0]            resp;
        logic [FWD_DATAPULL_DAT-1:0]    fwd_datapull;
        logic [DBID_DAT-1:0]            dbid;
        logic [CCID_DAT-1:0]            ccid;
        logic [DATAID_DAT-1:0]          dataid;
        logic                           tracetag;
        logic [BE_DAT_DEFAULT-1:0]      be;
        logic [DATA_DAT_DEFAULT-1:0]    data;
        logic [DATACHECK_DAT_DEFAULT-1:0]       datacheck;
        logic [POISON_DAT_DEFAULT-1:0]          poison;
    } chi_datflit_pkt_default_t;

    // chi rspflit logic packet definition
    typedef struct packed {
        logic [QOS_RSP_DEFAULT-1:0]     qos;
        logic [TGTID_RSP_DEFAULT-1:0]   tgtid;
        logic [SRCID_RSP_DEFAULT-1:0]   srcid;
        logic [TXNID_RSP-1:0]           txnid;
        logic [OPCODE_RSP-1:0]          opcode;
        logic [RESPERR_RSP-1:0]         resperr;     
        logic [RESP_RSP-1:0]            resp;
        logic [FWD_DATAPULL_RSP-1:0]    fwd_datapull;
        logic [DBID_RSP-1:0]            dbid;
        logic [PCRDTYPE_RSP-1:0]        pcrdtype;
        logic                           tracetag;
    } chi_rspflit_pkt_default_t;

    // chi snpflit logic packet definition
    typedef struct packed {
        logic [QOS_SNP-1:0]             qos; 
        logic [SRCID_SNP-1:0]           srcid;
        logic [TXNID_SNP-1:0]           txnid;
        logic [FWDNID_SNP-1:0]          fwdnid;
        logic [FWDTXNID_SNP-1:0]        fwdtxnid;
        logic [OPCODE_SNP-1:0]          opcode;
        logic [ADDR_SNP_DEFAULT-1:0]    addr;
        logic                           ns;
        logic                           donotgotosd_datapull;
        logic                           rettosrc;
        logic                           tracetag; 
    } chi_snpflit_pkt_default_t;

    // chi datflit logic packet definition specific for NoC integration
    // which is not the standard CHI DATA FLIT
    typedef struct packed {
        logic [QOS_DAT_DEFAULT-1:0]    qos; 
        logic [TGTID_DAT_DEFAULT-1:0]  tgtid;
        logic [SRCID_DAT_DEFAULT-1:0]  srcid;
        logic [TXNID_DAT-1:0]          txnid;
        logic [HOMENID_DAT_DEFAULT-1:0] homenid; 
        logic [OPCODE_DAT_DEFAULT-1:0]  opcode;
        logic [RESPERR_DAT-1:0]         resperr;     
        logic [RESP_DAT-1:0]            resp;
        logic [FWD_DATAPULL_DAT-1:0]    fwd_datapull;
        logic [DBID_DAT-1:0]            dbid;
        logic [CCID_DAT-1:0]            ccid;
        logic [DATAID_DAT-1:0]          dataid;
        logic                           tracetag;
        logic [BE_DAT_DEFAULT-1:0]      be;
        logic [DATA_DAT_DEFAULT-1:0]    data;
    } chi_datflit_snoc_pkt_t;

    localparam DAT_FLIT_SNOC_SIZE = $bits(chi_datflit_snoc_pkt_t);

    // arbitration queue constants
    localparam ARB_QUEUE_W = 2;
    localparam ARB_QUEUE_IS_REQ     = 2'b00;
    localparam ARB_QUEUE_IS_EVC     = 2'b01;
    localparam ARB_QUEUE_IS_EVANDRQ = 2'b11;

/*----------------------------------------------------------------------------*/
/*L2 Cache Interface Specifications*/
/*----------------------------------------------------------------------------*/
    //package for defining the necessary fields for the signals
    //between l2 and the chi_rn_agent

    //localparams from L2 Request Queue
    localparam RSP_CH1 = 3; 
    localparam OPCODE1 = 6;
    localparam RESP1 = 3;
    localparam RESPERR1 = 2;
    localparam RSP_CH2 = 3; 
    localparam OPCODE2 = 6;
    localparam RESP2 = 3;
    localparam RESPERR2 = 2;
    localparam L2_BANK_ID = 2;
    localparam L2_EXCL_SNOOPME = 1;
    localparam L2_TBL_ID_DEFAULT = 5;
    localparam L2_ADDR_DEFAULT = ADDR_REQ_DEFAULT;
    localparam L2_DATA_DEFAULT = DATA_DAT_DEFAULT;
    localparam L2_DMASK_DEFAULT = BE_DAT_DEFAULT;

    // Response chanels
    typedef enum logic [2:0] {
        NORP    = 'b000 ,   // No Response
        REQT    = 'b001 ,   // Request chanel
        SRSP    = 'b010 ,   // Snoop Response chanel
        WDAT    = 'b011     // Write Data chanel
    } rsp_ch_t;


    //localparams from L2 Evict
    typedef struct packed {
        logic [OPCODE1-1:0] opcode;
        logic [L2_ADDR_DEFAULT-1:0] addr;
        logic [L2_TBL_ID_DEFAULT-1:0] tbl_id;
        logic [L2_BANK_ID-1:0] bank_addr;
        logic [L2_DATA_DEFAULT-1:0] data;
        logic [L2_DMASK_DEFAULT-1:0] dmask;
        logic [1:0] atomic_size;
        logic excl_snoopme;
    } l2_evict_pkt_default_t;

    typedef struct packed {
        logic [L2_DATA_DEFAULT-1:0] data;
        logic [L2_DMASK_DEFAULT-1:0] dmask;
    } l2_data_pkt_default_t;

    // FILL to L2
    localparam COMP_BIT = 1;
    localparam L2_ST_W = 2; 
    localparam L2_RESPERR = 2; 
   // return line status to L2 FILL
   // corresponds to RESP_COMPDATA_I
   localparam L2_ST_I = 2'b00;
   // corresponds to RESP_COMPDATA_SC
   localparam L2_ST_S = 2'b01;
   // corresponds to RESP_COMPDATA_UC
   localparam L2_ST_E = 2'b10;
   // corresponds to RESP_COMPDATA_UD_PD
   localparam L2_ST_M = 2'b11;

   typedef struct packed {
       logic                         comp;
       logic [L2_ST_W-1:0]           st_w;
       logic [L2_TBL_ID_DEFAULT-1:0] tbl_id;
       logic [L2_BANK_ID-1:0]        bank_addr;
       logic [L2_RESPERR-1:0]        resperr;
       logic [L2_DATA_DEFAULT-1:0]   data;
   } l2_fill_pkt_default_t;
    
    // SNOOP to L2
    localparam L2_SP_REQ_W         = 32;

    // Resp types
    typedef enum logic [2:0] {
        ST_I        = 'b000,
        ST_UCD      = 'b010,
        ST_SC       = 'b001,
        ST_SD       = 'b011,
        ST_I_PD     = 'b100,
        ST_UCD_PD   = 'b110,
        ST_SC_PD    = 'b101,
        ST_NOCARE   = 'b111
    } noc_resp_t;

    // NoC Request/Response packet type
    typedef struct packed {
        rsp_ch_t                      rsp_ch1     ; //_
        logic [          OPCODE1-1:0] opcode1     ; // \
        noc_resp_t                    resp1       ; //  > RSP 1 to HOME  in SNOOP
        logic [         RESPERR1-1:0] resperr1    ; //  > RSP 1 to HOME  in SNOOP
        //_/
        rsp_ch_t                      rsp_ch2     ; // \
        logic [          OPCODE2-1:0] opcode2     ; //  > RSP 2 to REQUESTOR in SNOOP
        noc_resp_t                    resp2       ; // /
        logic [         RESPERR2-1:0] resperr2    ; // /

        logic [  L2_ADDR_DEFAULT-1:0] addr        ;
        logic [L2_TBL_ID_DEFAULT-1:0] tbl_id      ;
        logic [       L2_BANK_ID-1:0] bank_addr   ;
        logic                         excl_snoopme;
    } l2_req_pkt_default_t;

    localparam SNOOP_TABLE_ADDR = 5;
    typedef struct packed {
        logic                         rettosrc;
        logic [L2_ADDR_DEFAULT-1:0]   addr;
        logic [OPCODE_SNP-1:0]        opcode;
        logic [SNOOP_TABLE_ADDR-1:0]  snoop_table_index;
    } l2_snoop_req_pkt_default_t;

    typedef enum logic [1:0] {
        NORMAL_OK       = 'b00,             // NORMAL_OK --> Normal access was successful
                                            //               Exclusive failed
        EXCL_OK         = 'b01,             //Exclusive OK
        DATA_ERR        = 'b10,             //Data Error
        NONDATA_ERR     = 'b11              //Non-data Error
    } resperr_bits;


/*----------------------------------------------------------------------------*/
/*CHI Requestor Agent Internal Specifications*/
/*----------------------------------------------------------------------------*/
    // REQ chanel opcode
    localparam NOP              = 6'h0;
    localparam READSHARED       = 6'h01;
    localparam READONCE         = 6'h03;
    localparam READNOSNP        = 6'h04;
    localparam PCRDRETURN       = 6'h05;
    localparam READUNIQUE       = 6'h07;
    localparam CLEANSHARED      = 6'h08;
    localparam CLEANINVALID     = 6'h09;
    localparam CLEANUNIQUE      = 6'h0B;
    localparam MAKEINVALID      = 6'h0A;
    localparam WRITEUNIQUEPTL   = 6'h18;
    localparam WRITEUNIQUEFULL  = 6'h19;
    localparam WRITEBACKFULL    = 6'h1B;
    localparam WRITENOSNPPTL    = 6'h1C;
    localparam WRITENOSNPFULL   = 6'h1D;
    //opcodes for atomic operations and the exclusive instructions
    //to notify the RN to prepare for LOADX and STOREX
    localparam ATOMICSTORE      = 6'h28;  // it is actually from 0x28 to 0x2F
    localparam ATOMICSTORE_ADD  = 6'b101000;
    localparam ATOMICSTORE_CLR  = 6'b101001;
    localparam ATOMICSTORE_EOR  = 6'b101010;
    localparam ATOMICSTORE_SET  = 6'b101011;
    localparam ATOMICSTORE_SMAX = 6'b101100;
    localparam ATOMICSTORE_SMIN = 6'b101101;
    localparam ATOMICSTORE_UMAX = 6'b101110;
    localparam ATOMICSTORE_UMIN = 6'b101111;
    localparam ATOMICLOAD       = 6'h30;  // it is actually from 0x30 to 0x37
    localparam ATOMICLOAD_ADD  = 6'b110000;
    localparam ATOMICLOAD_CLR  = 6'b110001;
    localparam ATOMICLOAD_EOR  = 6'b110010;
    localparam ATOMICLOAD_SET  = 6'b110011;
    localparam ATOMICLOAD_SMAX = 6'b110100;
    localparam ATOMICLOAD_SMIN = 6'b110101;
    localparam ATOMICLOAD_UMAX = 6'b110110;
    localparam ATOMICLOAD_UMIN = 6'b110111;
    localparam ATOMICSWAP       = 6'h38;  
    localparam ATOMICCOMPARE    = 6'h39;
    localparam LOADX            = 6'h3B;
    localparam STOREX           = 6'h3C; 

    localparam ATOMICS_START    = 6'h28;
    localparam ATOMICS_END      = 6'h39;
    // RXRSP chanel opcode[3:0], we only support a subset of them for now
    localparam RESPLCRDRETURN  = 4'h0;
    localparam SNPRESP         = 4'h1;
    localparam COMPACK         = 4'h2;
    localparam RETRYACK        = 4'h3;
    localparam COMP            = 4'h4;
    localparam COMPDBIDRESP    = 4'h5;
    localparam DBIDRESP        = 4'h6;
    localparam PCRDGRANT       = 4'h7;
    localparam READRECEIPT     = 4'h8;
    localparam SNPRESPFWDED    = 4'h9;
    
    // TXDAT chanel opcode[N:0], we only support a subset of them for now
    // don't specify a number of bits as this can vary
    localparam DATALCRDRETURN   = 'h0;
    localparam SNPRESPDATA      = 'h1;
    localparam COPYBACKWRDATA   = 'h2;
    localparam NOCOPYBACKWRDATA = 'h3;
    localparam COMPDATA         = 'h4;
    localparam SNPRESPDATAPTL   = 'h5;
    localparam SNPRESPDATAFWDED = 'h6;
    localparam WRITEDATACANCEL  = 'h7; 
    // COMPDATA_I, COMPDATA_UC, ..., have the same opcode, but different RESP value
    localparam RESP_COMPDATA_I       = 3'h0;
    localparam RESP_COMPDATA_SC      = 3'h1;
    localparam RESP_COMPDATA_UC      = 3'h2;
    localparam RESP_COMPDATA_UD_PD   = 3'h3;

    // SNP chanel opcode[4:0] 
    localparam SNPLCRDRETURN            = 5'h00;
    localparam SNPSHARED                = 5'h01; 
    localparam SNPCLEAN                 = 5'h02; 
    localparam SNPONCE                  = 5'h03; 
    localparam SNPNOTSHAREDDIRTY        = 5'h04; 
    localparam SNPUNIQUESTASH           = 5'h05; 
    localparam SNPMAKEINVALIDSTASH      = 5'h06; 
    localparam SNPUNIQUE                = 5'h07; 
    localparam SNPCLEANSHARED           = 5'h08; 
    localparam SNPCLEANINVALID          = 5'h09; 
    localparam SNPMAKEINVALID           = 5'h0A; 
    localparam SNPSTASHUNIQUE           = 5'h0B; 
    localparam SNPSTASHSHARED           = 5'h0C; 
    localparam SNPDVMOP                 = 5'h0D; 
    localparam SNPSHAREDFWD             = 5'h11; 
    localparam SNPCLEANFWD              = 5'h12; 
    localparam SNPONCEFWD               = 5'h13; 
    localparam SNPNOTSHAREDDIRTYFWD     = 5'h14; 
    localparam SNPUNIQUEFWD             = 5'h17; 


    // LOCALPARAMS for TXNID TABLE
    localparam VALID_BIT = 1;
    localparam COMPACK_BIT = 1;
    localparam RETRY_BIT  = 1;
    localparam PCRDGRANT_BIT = 1;
    localparam RETRY_ADDR = 44;
    localparam TXNID_TABLE_ADDR = 6; // TXNID_REQ; change to 64 entries
    localparam WDAT_TABLE_ADDR = 5;

    //package for defining the necessary fields for the snoop_table entry
    typedef struct packed {
        logic [SRCID_SNP-1:0]         srcid;  
        logic [TXNID_SNP-1:0]         txnid;  
        logic [FWDNID_SNP-1:0]        fwdnid;  
        logic [FWDTXNID_SNP-1:0]      fwdtxnid;  
    } snoop_table_pkt2_t;

    typedef struct packed {
        //logic                         valid;
        snoop_table_pkt2_t            mem2;
    } snoop_table_pkt_t;
    localparam SNOOP_TABLE_DAT = $bits(snoop_table_pkt_t);

    localparam PCRDGRANT_TABLE_ADDR = 5;
    localparam HIT_DAT = TXNID_RSP+PCRDGRANT_TABLE_ADDR+PCRDGRANT_TABLE_ADDR;
    typedef struct packed{
        logic [TXNID_RSP-1:0]            first_txnid;
        logic [PCRDGRANT_TABLE_ADDR-1:0] cnt_retryack;
        logic [PCRDGRANT_TABLE_ADDR-1:0] cnt_pcrdgrant;
    } pcrdgrant_table_hit_pkt_t;

    localparam PCRDGRANT_TABLE_DAT3 = TXNID_RSP;
    localparam PCRDGRANT_TABLE_DAT4 = PCRDGRANT_TABLE_ADDR;
    localparam PCRDGRANT_TABLE_DAT5 = PCRDGRANT_TABLE_ADDR;

    /* The following structs and definitions have been
    moved inside the chi_rn_agent module file, as they are
    dependent on parameter values, hence it's easier to define
    them inside and let the option of configuring them
    at instantiation. If the parameters are not set, the defaults
    are kept so to not break compatibility                        */

    typedef struct packed{
         logic   [OPCODE_REQ-1:0]      opcode_req;
         logic   [L2_TBL_ID_DEFAULT-1:0] tbl_id;
         logic   [L2_BANK_ID-1:0]      bank_addr;
         logic   [WDAT_TABLE_ADDR-1:0] wdat_table_addr; // = {WDAT_TABLE_ADDR{1'b0}};
         logic   [RETRY_ADDR-1:0]      addr; // = {RETRY_ADDR{1'b0}};
         logic                         compack;
         logic                         excl_snoopme;
         logic   [1:0]                 amo_size;
     } txnid_table_pkt2_default_t;

     typedef struct packed {
        // write field 1
        //logic                         valid;
        // write field 2
        txnid_table_pkt2_default_t    mem2;
        // write field 3
        logic   [TXNID_REQ-1:0]       next_txnid; 
     } txnid_table_pkt_default_t;

    // localparam TXNID_TABLE_DAT = $bits(txnid_table_pkt_t);
    // localparam TXNID_TABLE_DAT2 = $bits(txnid_table_pkt2_t);
    // //localparam TXNID_TABLE_DAT3 = $bits(txnid_table_pkt3_t);
    // localparam TXNID_TABLE_DAT3 = TXNID_REQ;
    // localparam TXNID_TABLE_DAT1_OFFSET = TXNID_TABLE_DAT;
    // //localparam TXNID_TABLE_DAT2_OFFSET = TXNID_TABLE_DAT2 + TXNID_TABLE_DAT3;
    // //localparam TXNID_TABLE_DAT3_OFFSET = TXNID_TABLE_DAT3;
    // //localparam CMPACK_OFFSET = 1 + 2 + 1 + TXNID_TABLE_DAT3;
    // localparam TBL_BANK_ID_OFFSET = TXNID_TABLE_DAT-OPCODE_REQ; 
    // localparam TXNID_TABLE_WDAT_OFFSET = TBL_BANK_ID_OFFSET - L2_TBL_ID_DEFAULT - L2_BANK_ID; 
    // localparam TXNID_TABLE_ADDR_OFFSET = TXNID_TABLE_WDAT_OFFSET - WDAT_TABLE_ADDR; 

    // //package for defining the necessary fields for the wdat_table entry
    typedef struct packed {
         //logic                         valid;
         logic   [L2_DATA_DEFAULT-1:0]   data; 
         logic   [L2_DMASK_DEFAULT-1:0]  dmask; 
     } wdat_table_pkt_default_t;

    localparam CACHE_BLK_SIZ=64;

    // localparam WDAT_TABLE_DAT = $bits(wdat_table_pkt_t);


    // typedef struct packed{
    //     logic                            valid ;
    //     logic [PCRDTYPE_RSP-1:0]         pcrdtype;
    //     logic [SRCID_RSP-1:0]            srcid;
    //     logic [TXNID_RSP-1:0]            first_txnid;
    //     logic [PCRDGRANT_TABLE_ADDR-1:0] cnt_retryack;
    //     logic [PCRDGRANT_TABLE_ADDR-1:0] cnt_pcrdgrant;
    // } pcrdgrant_table_pkt_t;
    // localparam PCRDGRANT_TABLE_DAT2 = PCRDTYPE_RSP+SRCID_RSP;

    //localparam PCRDGRANT_TABLE_DAT = $bits(pcrdgrant_table_pkt_t);


endpackage : chi_rn_params_pkg
