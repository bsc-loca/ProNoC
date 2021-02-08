/**************************************
* Module: rnf_tx_rsp
* Date:2019-05-14  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  hnf_tx_rsp #(
    parameter VERBOSITY=0,
    parameter B=4
 //   parameter src_id =0
   
    
)(
    src_id,
    reset,
    clk,

    //chi chanel 
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,        
    
    //rxrsp
    txrsp_to_rxrsp_nearly_full, 
    txrsp_to_rxrsp_ready,
    rxrsp_to_txrsp_txnid,
    rxrsp_to_txrsp_tgtid,
    rxrsp_to_txrsp_opcode,
    rxrsp_to_txrsp_resp,
    rxrsp_to_txrsp_resperr,
    rxrsp_to_txrsp_wr_en,
    rxrsp_txsnp_dbid,
    
    //rxreq
    txrsp_to_rxreq_ready, 
    rxreq_to_txrsp_txnid, 
    rxreq_to_txrsp_tgtid, 
    rxreq_to_txrsp_opcode, 
    rxreq_to_txrsp_resp,
    rxreq_to_txrsp_resperr,
    rxreq_to_txrsp_wr_en, 
    rxreq_txsnp_dbid 
   
    
   
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
     
   input [31 : 0] src_id;

    //chi chanel
    input reset,clk;
    output  chi_noc_txrspflitpend ;
    output  chi_noc_txrspflitv ;
    output  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit  ;
    input   noc_chi_txrsplcrdv ;
    
    //rxrsp
    output txrsp_to_rxrsp_nearly_full;
    output  txrsp_to_rxrsp_ready;
    input rxrsp_to_txrsp_wr_en;
    input [TXNID_RSP-1:0] rxrsp_to_txrsp_txnid;
    input [TGTID_RSP-1:0] rxrsp_to_txrsp_tgtid;
    input [OPCODE_RSP-1:0] rxrsp_to_txrsp_opcode;
    input [RESP_RSP-1:0] rxrsp_to_txrsp_resp;
    input [RESPERR_RSP-1:0] rxrsp_to_txrsp_resperr;
    input [TXNID_RSP-1:0] rxrsp_txsnp_dbid;
   
    //rxreq
    output  txrsp_to_rxreq_ready;
    input rxreq_to_txrsp_wr_en;
    input [TXNID_RSP-1:0] rxreq_to_txrsp_txnid;
    input [TGTID_RSP-1:0] rxreq_to_txrsp_tgtid;
    input [OPCODE_RSP-1:0] rxreq_to_txrsp_opcode;
    input [RESP_RSP-1:0] rxreq_to_txrsp_resp;
    input [RESPERR_RSP-1:0] rxreq_to_txrsp_resperr;
    input [TXNID_RSP-1:0] rxreq_txsnp_dbid;
   
    wire have_cridit;  
  
  
    localparam
        Dw =  TXNID_RSP + TGTID_RSP +  OPCODE_RSP +  RESP_RSP + RESPERR_RSP + TXNID_RSP,
        DARRAYw = 2 * Dw;  
  
    wire [Dw-1 : 0 ] rxdat_din = {rxrsp_to_txrsp_txnid, rxrsp_to_txrsp_tgtid, rxrsp_to_txrsp_opcode, rxrsp_to_txrsp_resp, rxrsp_to_txrsp_resperr, rxrsp_txsnp_dbid};
    wire [Dw-1 : 0 ] rxsnp_din = {rxreq_to_txrsp_txnid, rxreq_to_txrsp_tgtid, rxreq_to_txrsp_opcode, rxreq_to_txrsp_resp, rxreq_to_txrsp_resperr, rxreq_txsnp_dbid};
          
     
    wire [DARRAYw-1 : 0] qin_data_in =  {rxdat_din ,rxsnp_din};
    wire [1 : 0] qin_we = {rxrsp_to_txrsp_wr_en,rxreq_to_txrsp_wr_en};
    wire [1 : 0] qin_is_ready;
    assign  {txrsp_to_rxrsp_ready, txrsp_to_rxreq_ready}  = qin_is_ready;
   
    
    wire [Dw-1 : 0] qout_data_o;
    wire qout_we_o;
    wire qout_is_ready;
    wire [1 : 0 ] qout_winner;
    
    
    
    
   //write chanel    
    many_to_one_pipereg #(
        .Dw(Dw),
        .IN_NUM(2),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    piperegs
    (
        .src_id(src_id),
        .qin_data_in(qin_data_in),
        .qin_we(qin_we),
        .qin_is_ready(qin_is_ready),
        .qin_valid_o(),
        .qin_data_o(),
        
        .qout_data_o(qout_data_o),
        .qout_we_o(qout_we_o),
        .qout_is_ready(qout_is_ready),
        .qout_winner(qout_winner),
        .reset(reset),
        .clk(clk)
    );  
  
   
    wire [QOS_RSP-1:0]             qos  = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           tgtid;
    wire [SRCID_RSP-1:0]           srcid =   src_id [SRCID_RSP-1:0] ;
    wire [TXNID_RSP-1:0]           txnid;
    wire [OPCODE_RSP-1:0]          opcode;
    wire [RESPERR_RSP-1:0]         resperr;     
    wire [RESP_RSP-1:0]            resp;
    wire [FWD_DATAPULL_RSP-1:0]    fwd_datapull = 0;
    wire [DBID_RSP-1:0]            dbid;
    wire [PCRDTYPE_RSP-1:0]        pcrdtype = 4'b0000;
    wire                           tracetag = 1'b0;
  
  
    assign  {txnid, tgtid, opcode, resp,resperr, dbid} = qout_data_o ;
  
  
  
    assign chi_noc_txrspflitpend = 1'b1;
    assign chi_noc_txrspflit = {qos, tgtid,   srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag}; // = 1'b0;
    assign chi_noc_txrspflitv =   qout_we_o;
  
    
    credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txrspflitv),
        .noc_chi_lcrdv( noc_chi_txrsplcrdv),
        .have_cridit(have_cridit),
         .nearly_full(txrsp_to_rxrsp_nearly_full),
        .reset(reset),
        .clk(clk)
     );
  
     assign qout_is_ready =   have_cridit;    
    
//synthesis translate_off 
//synopsys  translate_off
    generate 
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) > 0)begin :debug
    
        monitor_rsp_flit #(
            .AGENT_NAME("hnf"),
            .TYPE("TX")
        )
        monitor
        (
            .clk(clk),
            .monitor (chi_noc_txrspflitv),
            .rsp_flit(chi_noc_txrspflit),
            .src_id(src_id)
        );
    
    end
    endgenerate
       


//synthesis translate_on 
//synopsys  translate_on
  
   
     

endmodule

