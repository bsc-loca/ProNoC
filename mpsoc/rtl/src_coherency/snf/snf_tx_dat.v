/**************************************
* Module: snf_tx_dat
* Date:2019-05-28  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  snf_tx_dat#(
    parameter VERBOSITY=0,
    parameter B=4
    //parameter src_id=0
    
)(

    src_id,
    
    //chi channel
    chi_noc_txdatflitpend,
    chi_noc_txdatflitv,
    chi_noc_txdatflit,
    noc_chi_txdatlcrdv,

     // rxreq
    rxreq_to_txdat_wr,
    rxreq_to_txdat_dat,
    rxreq_to_txdat_tgtid,        
    rxreq_to_txdat_txnid,       
    rxreq_to_txdat_dbid,
    rxreq_to_txdat_homenid,
    rxreq_to_txdat_resp,
    rxreq_to_txopcode_dat,
    txdat_to_rxreq_ready,
    
    //general
    reset,
    clk

);


    input [31 : 0] src_id;
    

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
   
    
    input reset,clk;
    
    //chi channel
    output   chi_noc_txdatflitpend ;
    output   chi_noc_txdatflitv ;
    output  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit  ;
    input    noc_chi_txdatlcrdv ;
    
    
     // rxreq
    input  rxreq_to_txdat_wr;
    input [DATA_DAT-1 : 0] rxreq_to_txdat_dat;
    input [TGTID_DAT-1:0]  rxreq_to_txdat_tgtid;        
    input [TXNID_DAT-1:0]  rxreq_to_txdat_txnid;        
    input [TXNID_DAT-1:0]  rxreq_to_txdat_dbid;
    input [SRCID_DAT-1:0]  rxreq_to_txdat_homenid;
    input [RESP_DAT-1:0]   rxreq_to_txdat_resp;
    input [OPCODE_DAT-1:0] rxreq_to_txopcode_dat;
    output txdat_to_rxreq_ready;
    
     wire have_cridit;

  
  
    wire [QOS_DAT-1:0]             qos  = {QOS_REQ{1'b0}}; // not supported
    wire [TGTID_DAT-1:0]           tgtid  = rxreq_to_txdat_tgtid;
    wire [SRCID_DAT-1:0]           srcid  = src_id [SRCID_DAT-1:0];
    wire [TXNID_DAT-1:0]           txnid = rxreq_to_txdat_txnid;
    wire [HOMENID_DAT-1:0]         homenid =  rxreq_to_txdat_homenid; 
    wire [OPCODE_DAT-1:0]          opcode = rxreq_to_txopcode_dat;
    wire [RESPERR_DAT-1:0]         resperr = {RESPERR_DAT{1'b0}};   // not supported  
    wire [RESP_DAT-1:0]            resp =rxreq_to_txdat_resp ;
    wire [FWD_DATAPULL_DAT-1:0]    fwd_datapull = {FWD_DATAPULL_DAT{1'b0}}; // not supported
    wire [DBID_DAT-1:0]            dbid = rxreq_to_txdat_dbid ;
    wire [CCID_DAT-1:0]            ccid = {CCID_DAT{1'b0}}; // not supported
    wire [DATAID_DAT-1:0]          dataid = {DATAID_DAT{1'b0}}; // not supported
    wire                           tracetag  = 1'b0; // not supported
    wire [BE_DAT-1:0]              be ={BE_DAT{1'b1}}; // not supported
    wire [DATA_DAT-1:0]            data = rxreq_to_txdat_dat;
    wire [DATACHECK_DAT-1:0]       datacheck = {DATACHECK_DAT{1'b0}} ;// not supported
    wire [POISON_DAT-1:0]          poison = {POISON_DAT{1'b0}}; // not supported
    
  
    assign chi_noc_txdatflitpend =1'b1;
    assign chi_noc_txdatflit = {qos,tgtid,srcid ,txnid ,homenid ,opcode ,resperr, resp ,fwd_datapull ,dbid ,ccid ,dataid ,tracetag ,be ,data ,datacheck  ,poison};
    assign chi_noc_txdatflitv =  rxreq_to_txdat_wr;
  
    credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txdatflitv),
        .noc_chi_lcrdv( noc_chi_txdatlcrdv),
        .have_cridit(have_cridit),
         .nearly_full(),
        .reset(reset),
        .clk(clk)
     );
    assign txdat_to_rxreq_ready = have_cridit;    


//synthesis translate_off 
//synopsys  translate_off


always @(posedge clk) begin
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) >0 )begin 
        if(chi_noc_txdatflitv) begin 
        $display("%t: snf ( %d ) txn ( %d ) send dat flit: qos ( %d ), tgtid ( %d ), srcid ( %d ), homenid ( %d ), opcode ( %d ), resperr ( %d ), resp ( %d ), fwd_datapull ( %d )",
        $time,src_id, txnid, qos, tgtid, srcid, homenid ,opcode, resperr, resp, fwd_datapull);
        $display("%t: snf ( %d ) txn ( %d ) send dat flit: dbid ( %d ), ccid ( %d ), dataid ( %d ), tracetag ( %d ), be ( %d ), data ( %d ), datacheck ( %d ), poison ( %d )",
        $time,src_id, txnid, dbid, ccid, dataid, tracetag, be, data, datacheck, poison);
        end
    end
end

//synopsys  translate_on
//synthesis translate_on 




endmodule

