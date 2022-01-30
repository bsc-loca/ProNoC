
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
    output  logic                                  endCom_o                             
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




endmodule
