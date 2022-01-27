    
//`define INCLUDE_CHI_LOCALPARAM
//`include "chi_localparam.v"
    
//`define INCLUDE_TEST_LOCALPARAM
//`include "test_localparam.v"

//`define INCLUDE_TOPOLOGY_LOCALPARAM
//`include "topology_localparam.v" 

//`define INCLUDE_MAPPING_FUNC
//`include "topology_mapping.v"  

//import chi_rn_params_pkg::*;

//localparam REQ_FLIT_SIZE_NE= NE * REQ_FLIT_SIZE ; 
//localparam DAT_FLIT_SIZE_NE= NE * DAT_FLIT_SIZE ;
//localparam RSP_FLIT_SIZE_NE= NE * RSP_FLIT_SIZE ;


import pronoc_pkg::*; 
import dpi_int_pkg::*; 


localparam NE = 4*4*2 ;
localparam NUM_OF_RNs = 16; //TODO: tmp
module top_dpi_interface (
    input   logic  clk_i, rst_i  ,
    input   logic                                  init_i                          ,
    input   logic                                  startCom_i                      ,
    input   deliver_t [NE-1:0]                     pronoc_synfull_del_all_i        ,
    output  req_t [NE-1:0]                         synfull_pronoc_req_all_o        ,
    output  logic                                  endCom_o                       // ,
  //input   logic [DAT_FLIT_SIZE_NE-1:0]           chi_synfull_rxdatflit_all_i     ,
  //input   logic [NE-1 : 0]                       chi_synfull_rxdatflitv_all_i    ,
  //input   logic [RSP_FLIT_SIZE_NE-1:0]           chi_synfull_rxrspflit_all_i     ,
  //input   logic [NE-1:0]                         chi_synfull_rxrspflitv_all_i    ,
  //input   logic [REQ_FLIT_SIZE_NE-1:0]           synfull_chi_hn_rxreqflit_all_i  ,
  //input   logic [NE-1 : 0]                       synfull_chi_hn_rxreqflitv_all_i ,
  //output  logic [REQ_FLIT_SIZE*NUM_OF_RNs-1:0]   synfull_hn_txreqflit_all_o      ,
  //output  logic [NUM_OF_RNs-1 : 0]               synfull_hn_txreqflitv_all_o     ,
  //output  logic [REQ_FLIT_SIZE*NUM_OF_RNs-1:0]   synfull_noc_txreqflit_all_o     ,
  //output  logic [NUM_OF_RNs-1:0]                 synfull_noc_txreqflitv_all_o    ,
  //output  logic [RSP_FLIT_SIZE*NUM_OF_RNs-1:0]   synfull_txrspflit_all_o         ,
  //output  logic [NUM_OF_RNs-1:0]                 synfull_txrspflitv_all_o        ,
  //output  logic [DAT_FLIT_SIZE*NUM_OF_RNs-1:0]   data_flit_rsp_all_o             ,
  //output  logic [NUM_OF_RNs-1:0]                 data_flit_rspv_all_o                  
);


import "DPI-C" function void c_dpi_interface ( 
    logic          startCom                          , 
    logic          getData                           ,
    logic          ejectReq                          , 
    output  logic  endCom                            , 
    output  logic  newReq                            , 
    output  int    source_all[NE]                    , 
    output  int    destination_all[NE]               , 
    output  int    address_all[NE]                   ,
    output  int    opcode_all[NE]                    ,
    output  int    id_all[NE]                        ,
    output  int    valid_all[NE]                     ,
    input   int    rtrn_source_all[NE]               ,
    input   int    rtrn_opcode_all[NE]               ,
    input   int    rtrn_destination_all[NE]          ,
    input   int    rtrn_address_all[NE]              ,
    input   int    rtrn_pkgid_all[NE]                ,
    input   int    rtrn_valid_all[NE]                ,       
    input   int    rtrn_dat_source_all[NE]           ,
    input   int    rtrn_dat_opcode_all[NE]           ,
    input   int    rtrn_dat_destination_all[NE]      ,
    input   int    rtrn_dat_pkgid_all[NE]            ,
    input   int    rtrn_dat_valid_all[NE]            ,       
    input   int    rtrn_rsp_source_all[NE]           ,
    input   int    rtrn_rsp_opcode_all[NE]           ,
    input   int    rtrn_rsp_destination_all[NE]      ,
    input   int    rtrn_rsp_pkgid_all[NE]            ,
    input   int    rtrn_rsp_valid_all[NE]            ,       
    output  int    snp_source_all[NUM_OF_RNs]        ,
    output  int    snp_opcode_all[NUM_OF_RNs]        ,
    output  int    snp_destination_all[NUM_OF_RNs]   ,
    output  int    snp_address_all[NUM_OF_RNs]       ,
    output  int    snp_pkgid_all[NUM_OF_RNs]         ,
    output  int    snp_valid_all[NUM_OF_RNs]         ,       
    output  int    datrn_source_all[NUM_OF_RNs]      ,
    output  int    datrn_opcode_all[NUM_OF_RNs]      ,
    output  int    datrn_destination_all[NUM_OF_RNs] ,
    output  int    datrn_address_all[NUM_OF_RNs]     ,
    output  int    datrn_pkgid_all[NUM_OF_RNs]       ,
    output  int    datrn_valid_all[NUM_OF_RNs]       ,        
    output  int    rsp_source_all[NUM_OF_RNs]        ,
    output  int    rsp_opcode_all[NUM_OF_RNs]        ,
    output  int    rsp_destination_all[NUM_OF_RNs]   ,
    output  int    rsp_address_all[NUM_OF_RNs]       ,
    output  int    rsp_pkgid_all[NUM_OF_RNs]         ,
    output  int    rsp_valid_all[NUM_OF_RNs]         ,       
    input   int    fwd_id_all[NUM_OF_RNs]            ,
    input   int    fwd_idv_all[NUM_OF_RNs]                   
);

import "DPI-C" function void connection_init( 
    logic           startCom     , 
    output logic    ready         
);

int destination ;
int opcode      ;
int source      ;
int addr        ;
int pkgid       ;

int syn_source_all[NE]          ;
int syn_opcode_all[NE]          ;
int syn_destination_all[NE]     ;
int syn_address_all[NE]         ;
int syn_pkgid_all[NE]           ;
int syn_valid_all[NE]           ;

int chi_req_source_all[NE]      ;
int chi_req_opcode_all[NE]      ;
int chi_req_destination_all[NE] ;
int chi_req_address_all[NE]     ;
int chi_req_pkgid_all[NE]       ;
int chi_req_valid_all[NE]       ;

int chi_dat_source_all[NE]      ;
int chi_dat_opcode_all[NE]      ;
int chi_dat_destination_all[NE] ;
//int chi_dat_address_all[NE]     ;
int chi_dat_pkgid_all[NE]       ;
int chi_dat_valid_all[NE]       ;

int syn_hn_source_all[16]       ;
int syn_hn_opcode_all[16]       ;
int syn_hn_destination_all[16]  ;
int syn_hn_address_all[16]      ;
int syn_hn_pkgid_all[16]        ;
int syn_hn_valid_all[16]        ;

int syn_drn_source_all[16]      ;
int syn_drn_opcode_all[16]      ;
int syn_drn_destination_all[16] ;
int syn_drn_address_all[16]     ;
int syn_drn_pkgid_all[16]       ;
int syn_drn_valid_all[16]       ;

int syn_rsp_source_all[16]      ;
int syn_rsp_opcode_all[16]      ;
int syn_rsp_destination_all[16] ;
int syn_rsp_address_all[16]     ;
int syn_rsp_pkgid_all[16]       ;
int syn_rsp_valid_all[16]       ;

int fwd_id_all_d[16]       ;
int fwd_idv_all_d[16]      ;
int fwd_id_all_q[16]       ;
int fwd_idv_all_q[16]      ;
logic[15:0] fwd_bit_idv_all_q      ;
logic[15:0] fwd_bit_idv_all_d      ;

int chi_rsp_source_all[NE]      ;
int chi_rsp_opcode_all[NE]      ;
int chi_rsp_destination_all[NE] ;
int chi_rsp_pkgid_all[NE]       ;
int chi_rsp_valid_all[NE]       ;

logic newData             ;
logic newReq              ;
logic isldst              ;
logic ready_connection    ;
logic eject_req           ;

logic [NE-1:0] valid_check ;

//chi_datflit_pkt_default_t [NUM_OF_RNs-1:0] data_flit_rsp                ;
//chi_reqflit_pkt_default_t [NUM_OF_RNs-1:0] reqflit                      ;
//chi_rspflit_pkt_default_t [NUM_OF_RNs-1:0] rspflit                      ;
//chi_reqflit_pkt_default_t [NUM_OF_RNs-1:0] hn_reqflit                   ;          
//chi_reqflit_pkt_default_t [NE-1:0]         noc_chi_rxreqflit_all        ;          
//chi_datflit_pkt_default_t [NE-1:0]         noc_chi_rxdatflit_all        ;          
//chi_rspflit_pkt_default_t [NE-1:0]         noc_chi_rxrspflit_all        ;          
//    
//logic [REQ_FLIT_SIZE-1:0]                  synfull_noc_txreqflit     ;
//logic [NUM_OF_RNs-1:0][DAT_FLIT_SIZE-1:0]  data_flit_rsp_all         ;
//logic [NUM_OF_RNs-1:0][REQ_FLIT_SIZE-1:0]  synfull_noc_txreqflit_all ;
//logic [NUM_OF_RNs-1:0][RSP_FLIT_SIZE-1:0]  synfull_noc_txrspflit_all ;
//logic [NUM_OF_RNs-1:0][REQ_FLIT_SIZE-1:0]  synfull_hn_txreqflit_all  ;
////logic [NUM_OF_RNs-1:0][RSP_FLIT_SIZE-1:0]  synfull_chi_rxrspflit_all ;
//logic [TGTID_REQ-1:0]                      target_hnf_id             ;
//logic [NUM_OF_RNs-1:0][43:0]               addr_shift                ; 


// socket connection
always_ff @(posedge clk_i) begin 
    connection_init(
        init_i,ready_connection
    );
end

// trace injection
always_ff @(posedge clk_i) begin 
    c_dpi_interface(
        startCom_i&ready_connection ,
        clk_i                       ,
        eject_req                   ,
        endCom_o                    ,
        newData                     ,
        syn_source_all              ,
        syn_destination_all         ,
        syn_address_all             , 
        syn_opcode_all              , 
        syn_pkgid_all               , 
        syn_valid_all               ,
        chi_req_source_all          ,  
        chi_req_opcode_all          ,  
        chi_req_destination_all     ,  
        chi_req_address_all         ,  
        chi_req_pkgid_all           ,  
        chi_req_valid_all           ,           
        chi_dat_source_all          ,  
        chi_dat_opcode_all          ,  
        chi_dat_destination_all     ,  
        chi_dat_pkgid_all           ,  
        chi_dat_valid_all           ,           
        chi_rsp_source_all          ,
        chi_rsp_opcode_all          ,
        chi_rsp_destination_all     ,
        chi_rsp_pkgid_all           ,
        chi_rsp_valid_all           ,
        syn_hn_source_all           ,  
        syn_hn_opcode_all           ,  
        syn_hn_destination_all      ,  
        syn_hn_address_all          ,  
        syn_hn_pkgid_all            ,  
        syn_hn_valid_all            ,                     
        syn_drn_source_all          ,  
        syn_drn_opcode_all          ,  
        syn_drn_destination_all     ,  
        syn_drn_address_all         ,  
        syn_drn_pkgid_all           ,  
        syn_drn_valid_all           ,          
        syn_rsp_source_all          ,  
        syn_rsp_opcode_all          ,  
        syn_rsp_destination_all     ,  
        syn_rsp_address_all         ,  
        syn_rsp_pkgid_all           ,  
        syn_rsp_valid_all           ,
        fwd_id_all_q                ,
        fwd_idv_all_q                   
    );
end

genvar k;
generate     
for(k=0;k<NE;k=k+1)begin
    //to pronoc
    assign synfull_pronoc_req_all_o[k].dest  =  syn_destination_all[k];
    assign synfull_pronoc_req_all_o[k].src   = syn_source_all[k];
    assign synfull_pronoc_req_all_o[k].id    = syn_pkgid_all[k];
    assign synfull_pronoc_req_all_o[k].valid = syn_valid_all[k][0];

    //from pronoc
    assign chi_req_pkgid_all[k]       = pronoc_synfull_del_all_i[k].id       ;
    assign chi_req_valid_all[k]       = pronoc_synfull_del_all_i[k].valid    ;

    assign valid_check[k] = pronoc_synfull_del_all_i[k].valid;
end
endgenerate

assign eject_req = !(valid_check=='0);



//genvar k;
//generate     
//for(k=0;k<NUM_OF_RNs;k=k+1)begin
////========= RN TXREQ ==============
//    assign reqflit[k].tgtid          = gen_hn_endp_id(syn_destination_all[k][7:0])  ; // target id
//    assign reqflit[k].srcid          = gen_rn_endp_id(syn_source_all[k][6:0])       ; // source id
//    assign reqflit[k].txnid          = syn_pkgid_all[k][7:0]        ; // transaction id
//    assign reqflit[k].returntxnid    = '0                           ;
//    assign reqflit[k].opcode         = syn_opcode_all[k][5:0]       ;
//    //assign reqflit[k].addr           = {addr_shift[k][33:0],syn_source_all[k][3:0],6'b0} ;
//    //assign reqflit[k].addr           =  {12'b0,syn_address_all[k]} ;
//    assign reqflit[k].addr           =  {12'b0,syn_pkgid_all[k]};
//    assign reqflit[k].expcompack     = (syn_opcode_all[k][5:0] == READSHARED || 
//                                        syn_opcode_all[k][5:0] == READUNIQUE || 
//                                        syn_opcode_all[k][5:0] == CLEANUNIQUE) ? 1'b1 : 1'b0;
//    assign reqflit[k].qos            = '0              ;
//    assign reqflit[k].returnnid      = '0              ;
//    assign reqflit[k].endian         = 1'b0            ;
//    assign reqflit[k].flitsize       = 3'b110          ;
//    assign reqflit[k].ns             = 1'b1            ;
//    assign reqflit[k].likelyshared   = 1'b0            ;
//    assign reqflit[k].allowretry     = 1'b1            ;
//    assign reqflit[k].order          = 2'b11           ;
//    assign reqflit[k].pcrdtype       = '0              ;
//    assign reqflit[k].memattr        = 4'b1101         ;
//    assign reqflit[k].snpattr        = 1'b1            ;
//    assign reqflit[k].lpid           = '0              ;
//    assign reqflit[k].excl_snoopme   = '0              ;
//    assign reqflit[k].tracetag       = 1'b0            ;
//
//assign synfull_noc_txreqflit_all[k] =
//{
//    reqflit[k].qos          ,
//    reqflit[k].tgtid        ,
//    reqflit[k].srcid        ,
//    reqflit[k].txnid        ,
//    reqflit[k].returnnid    ,
//    reqflit[k].endian       ,
//    reqflit[k].returntxnid  ,
//    reqflit[k].opcode       ,
//    reqflit[k].flitsize     ,
//    reqflit[k].addr         ,
//    reqflit[k].ns           ,
//    reqflit[k].likelyshared ,
//    reqflit[k].allowretry   ,
//    reqflit[k].order        ,
//    reqflit[k].pcrdtype     ,
//    reqflit[k].memattr      ,
//    reqflit[k].snpattr      ,
//    reqflit[k].lpid         ,
//    reqflit[k].excl_snoopme ,
//    reqflit[k].expcompack   ,
//    reqflit[k].tracetag             
//};
//
////========= HN TXREQ ==============
//    assign hn_reqflit[k].tgtid   = gen_rn_endp_id(syn_hn_destination_all[k][7:0]) ; // target id
//    assign hn_reqflit[k].srcid   = gen_hn_endp_id(syn_hn_source_all[k][6:0])      ; // source id
//    assign hn_reqflit[k].txnid          = syn_hn_pkgid_all[k][7:0]        ; // transaction id
//    assign hn_reqflit[k].returntxnid    = '0                           ;
//    assign hn_reqflit[k].opcode         = syn_hn_opcode_all[k][5:0]       ;
//  //assign hn_reqflit[k].addr           = {addr_shift[k][33:0],syn_source_all[k][3:0],6'b0} ;
//  //assign hn_reqflit[k].addr           =  {12'b0,syn_hn_address_all[k]} ;
//    assign hn_reqflit[k].addr           = {12'b0,syn_hn_pkgid_all[k]} ;
//    assign hn_reqflit[k].expcompack     = (syn_hn_opcode_all[k][5:0] == READSHARED || 
//                                        syn_hn_opcode_all[k][5:0] == READUNIQUE || 
//                                        syn_hn_opcode_all[k][5:0] == CLEANUNIQUE) ? 1'b1 : 1'b0;
//    assign hn_reqflit[k].qos            = '0              ;
//    assign hn_reqflit[k].returnnid      = '0              ;
//    assign hn_reqflit[k].endian         = 1'b0            ;
//    assign hn_reqflit[k].flitsize       = 3'b110          ;
//    assign hn_reqflit[k].ns             = 1'b1            ;
//    assign hn_reqflit[k].likelyshared   = 1'b0            ;
//    assign hn_reqflit[k].allowretry     = 1'b1            ;
//    assign hn_reqflit[k].order          = 2'b11           ;
//    assign hn_reqflit[k].pcrdtype       = '0              ;
//    assign hn_reqflit[k].memattr        = 4'b1101         ;
//    assign hn_reqflit[k].snpattr        = 1'b1            ;
//    assign hn_reqflit[k].lpid           = '0              ;
//    assign hn_reqflit[k].excl_snoopme   = '0              ;
//    assign hn_reqflit[k].tracetag       = 1'b0            ;
//
//assign synfull_hn_txreqflit_all[k] =
//{
//    hn_reqflit[k].qos          ,
//    hn_reqflit[k].tgtid        ,
//    hn_reqflit[k].srcid        ,
//    hn_reqflit[k].txnid        ,
//    hn_reqflit[k].returnnid    ,
//    hn_reqflit[k].endian       ,
//    hn_reqflit[k].returntxnid  ,
//    hn_reqflit[k].opcode       ,
//    hn_reqflit[k].flitsize     ,
//    hn_reqflit[k].addr         ,
//    hn_reqflit[k].ns           ,
//    hn_reqflit[k].likelyshared ,
//    hn_reqflit[k].allowretry   ,
//    hn_reqflit[k].order        ,
//    hn_reqflit[k].pcrdtype     ,
//    hn_reqflit[k].memattr      ,
//    hn_reqflit[k].snpattr      ,
//    hn_reqflit[k].lpid         ,
//    hn_reqflit[k].excl_snoopme ,
//    hn_reqflit[k].expcompack   ,
//    hn_reqflit[k].tracetag             
//};
//
////========= DATA RN RESP ==============
//
//// ******  encode rsp data  ********
//assign data_flit_rsp[k].qos          = '0                  ; 
//assign data_flit_rsp[k].tgtid        = gen_hn_endp_id(syn_drn_destination_all[k][7:0])    ;
//assign data_flit_rsp[k].srcid        = gen_hn_endp_id(syn_drn_source_all[k][7:0])         ;
//assign data_flit_rsp[k].txnid        = syn_drn_pkgid_all[k][7:0]                       ;
//assign data_flit_rsp[k].homenid      = '0                  ; 
//assign data_flit_rsp[k].opcode       = syn_drn_opcode_all[k][5:0]       ;
//assign data_flit_rsp[k].resperr      = '0                  ;     
//assign data_flit_rsp[k].resp         = '0                  ;
//assign data_flit_rsp[k].fwd_datapull = '0                  ;
//assign data_flit_rsp[k].dbid         = '0                  ;
//assign data_flit_rsp[k].ccid         = '0                  ;
//assign data_flit_rsp[k].dataid       = '0                  ;
//assign data_flit_rsp[k].tracetag     = '0                  ;
//assign data_flit_rsp[k].be           = '0                  ;
////assign data_flit_rsp[k].data         = '0                  ;
//assign data_flit_rsp[k].data         = {479'b0 ,syn_drn_pkgid_all[k]} ;
//assign data_flit_rsp[k].datacheck    = '0                  ;
//assign data_flit_rsp[k].poison       = '0                  ;
//
//
//assign data_flit_rsp_all[k]  =
//    {
//    data_flit_rsp[k].qos           , 
//    data_flit_rsp[k].tgtid         ,
//    data_flit_rsp[k].srcid         ,
//    data_flit_rsp[k].txnid         ,
//    data_flit_rsp[k].homenid       , 
//    data_flit_rsp[k].opcode        ,
//    data_flit_rsp[k].resperr       ,     
//    data_flit_rsp[k].resp          ,
//    data_flit_rsp[k].fwd_datapull  ,
//    data_flit_rsp[k].dbid          ,
//    data_flit_rsp[k].ccid          ,
//    data_flit_rsp[k].dataid        ,
//    data_flit_rsp[k].tracetag      ,
//    data_flit_rsp[k].be            ,
//    data_flit_rsp[k].data          ,
//    data_flit_rsp[k].datacheck     ,
//    data_flit_rsp[k].poison           
//};
//
//assign fwd_id_all_d[k]      = (data_flit_rsp[k].tgtid == data_flit_rsp[k].srcid) ? data_flit_rsp[k].data[31:0] : '0    ;
//assign fwd_idv_all_d[k]     = (syn_drn_valid_all[k][0] & (data_flit_rsp[k].tgtid == data_flit_rsp[k].srcid))      ;
//assign fwd_bit_idv_all_d[k] = (syn_drn_valid_all[k][0] & (data_flit_rsp[k].tgtid == data_flit_rsp[k].srcid))      ;
//
////========= RN TXRSP ==============
//    assign rspflit[k].qos            = '0              ;
//    assign rspflit[k].tgtid          = gen_hn_endp_id(syn_rsp_destination_all[k][7:0])  ; // target id
//    assign rspflit[k].srcid          = gen_rn_endp_id(syn_rsp_source_all[k][6:0])       ; // source id
//    assign rspflit[k].txnid          = syn_rsp_pkgid_all[k][7:0]        ; // transaction id
//    assign rspflit[k].opcode         = syn_rsp_opcode_all[k][5:0]       ;
//    assign rspflit[k].resperr        = '0                  ;     
//    assign rspflit[k].resp           = '0                  ;
//    assign rspflit[k].fwd_datapull   = '0                  ;
//    //assign rspflit[k].dbid           = '0                  ;
//    assign rspflit[k].dbid           = syn_rsp_pkgid_all[k][16:8] ;
//    assign rspflit[k].pcrdtype       = '0                  ;
//    assign rspflit[k].tracetag       = 1'b0                ;
//
//assign synfull_noc_txrspflit_all[k] =
//{
//    rspflit[k].qos           ,
//    rspflit[k].tgtid         ,
//    rspflit[k].srcid         ,
//    rspflit[k].txnid         ,
//    rspflit[k].opcode        ,
//    rspflit[k].resperr       ,
//    rspflit[k].resp          ,
//    rspflit[k].fwd_datapull  ,
//    rspflit[k].dbid          ,
//    rspflit[k].pcrdtype      ,
//    rspflit[k].tracetag         
//};
//
//end 
//endgenerate 

//genvar i;
//generate     
//for(i=0;i<NUM_OF_RNs;i=i+1)begin
//    // txreq flit    
//    assign synfull_noc_txreqflit_all_o [REQ_FLIT_SIZE*(i+1)-1:REQ_FLIT_SIZE*i] = 
//        synfull_noc_txreqflit_all[i];
//    assign synfull_noc_txreqflitv_all_o[i] = syn_valid_all[i][0]  ;
//    // txrsp flit    
//    assign synfull_txrspflit_all_o [RSP_FLIT_SIZE*(i+1)-1:RSP_FLIT_SIZE*i] = 
//        synfull_noc_txrspflit_all[i];
//    assign synfull_txrspflitv_all_o[i] = syn_rsp_valid_all[i][0]  ;
//    //hn txreq flit  
//    assign synfull_hn_txreqflit_all_o [REQ_FLIT_SIZE*(i+1)-1:REQ_FLIT_SIZE*i] = 
//        synfull_hn_txreqflit_all[i];
//    assign synfull_hn_txreqflitv_all_o[i] = syn_hn_valid_all[i][0]  ;
//    //rn data rsp
//    assign data_flit_rsp_all_o [DAT_FLIT_SIZE*(i+1)-1:DAT_FLIT_SIZE*i] = data_flit_rsp_all[i];
//    assign data_flit_rspv_all_o[i] = syn_drn_valid_all[i][0] & (data_flit_rsp[i].tgtid != data_flit_rsp[i].srcid) ;
//end 
//endgenerate 


// requests reaching their destination
//genvar j;
//generate 
//for(j=0;j<NE;j=j+1)begin 
//    //========================= RX REQ ===============================
//    assign noc_chi_rxreqflit_all[j] = 
//        synfull_chi_hn_rxreqflit_all_i [(j+1)*REQ_FLIT_SIZE-1 : j*REQ_FLIT_SIZE];
//
//    assign chi_req_pkgid_all[j]       = noc_chi_rxreqflit_all[j].addr       ;
//    assign chi_req_valid_all[j]       = (synfull_chi_hn_rxreqflitv_all_i[j]) ? 32'h1 : 32'b0 ;
//    
//    //========================= RX DATA ===============================
//    assign noc_chi_rxdatflit_all[j] = 
//        chi_synfull_rxdatflit_all_i [(j+1)*DAT_FLIT_SIZE-1 : j*DAT_FLIT_SIZE];
//    
//    assign chi_dat_pkgid_all[j]       = noc_chi_rxdatflit_all[j].data[31:0]       ;
//    assign chi_dat_valid_all[j]       = (chi_synfull_rxdatflitv_all_i[j]) ? 32'h1 : 32'b0 ;
//
//    //========================= RX RSP ===============================
//    assign noc_chi_rxrspflit_all[j] = 
//        chi_synfull_rxrspflit_all_i [(j+1)*RSP_FLIT_SIZE-1 : j*RSP_FLIT_SIZE];
//
//    assign chi_rsp_pkgid_all[j]       =  {noc_chi_rxrspflit_all[j].dbid,noc_chi_rxrspflit_all[j].txnid}       ;
//    assign chi_rsp_valid_all[j]       = (chi_synfull_rxrspflitv_all_i[j]) ? 32'h1 : 32'b0 ;
//    
//end
//endgenerate

// request to the same node, this is not supported by pronoc
//always_ff @(posedge clk_i) begin
//    if (!rst_i) begin
//        fwd_id_all_q  = '{default:'0}  ;
//        fwd_idv_all_q = '{default:'0}  ;
//        fwd_bit_idv_all_q  = '0  ;
//    end
//    else begin
//        fwd_id_all_q  = fwd_id_all_d   ;
//        fwd_idv_all_q = fwd_idv_all_d  ;
//        fwd_bit_idv_all_q = fwd_bit_idv_all_d  ;
//    end
//
//end



//assign eject_req = !(synfull_chi_hn_rxreqflitv_all_i == '0) || 
//                   !(chi_synfull_rxdatflitv_all_i=='0)      ||
//                   !(chi_synfull_rxrspflitv_all_i=='0)      ||
//                   !(fwd_bit_idv_all_q=='0);
//


endmodule
