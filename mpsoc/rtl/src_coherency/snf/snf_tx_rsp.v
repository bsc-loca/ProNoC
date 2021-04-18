/**************************************
* Module: rnf_tx_rsp
* Date:2019-05-14  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  snf_tx_rsp #(
    parameter B=4
    //parameter src_id =0    
)(
   
    src_id,
    reset,
    clk,

    //chi chanel 
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,        
    
        
    //rxreq
    txrsp_to_rxreq_ready, 
    rxreq_to_txrsp_txnid, 
    rxreq_to_txrsp_tgtid, 
    rxreq_to_txrsp_opcode, 
    rxreq_to_txrsp_resp, 
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
    
   
    //rxreq
    output  txrsp_to_rxreq_ready;
    input rxreq_to_txrsp_wr_en;
    input [TXNID_RSP-1:0] rxreq_to_txrsp_txnid;
    input [TGTID_RSP-1:0] rxreq_to_txrsp_tgtid;
    input [OPCODE_RSP-1:0] rxreq_to_txrsp_opcode;
    input [RESP_RSP-1:0] rxreq_to_txrsp_resp;
    input [TXNID_RSP-1:0] rxreq_txsnp_dbid;
   
    wire have_cridit;  
  
  
    
  
  
   
    wire [QOS_RSP-1:0]             qos  = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           tgtid;
    wire [SRCID_RSP-1:0]           srcid =   src_id [SRCID_RSP-1:0];
    wire [TXNID_RSP-1:0]           txnid;
    wire [OPCODE_RSP-1:0]          opcode;
    wire [RESPERR_RSP-1:0]         resperr ={RESPERR_RSP{1'b0}};     
    wire [RESP_RSP-1:0]            resp;
    wire [FWD_DATAPULL_RSP-1:0]    fwd_datapull = 0;
    wire [DBID_RSP-1:0]            dbid;
    wire [PCRDTYPE_RSP-1:0]        pcrdtype = 4'b0000;
    wire                           tracetag = 1'b0;
  
  
    assign  {txnid, tgtid, opcode, resp, dbid} = {rxreq_to_txrsp_txnid, rxreq_to_txrsp_tgtid, rxreq_to_txrsp_opcode, rxreq_to_txrsp_resp, rxreq_txsnp_dbid};
  
  
  
    assign chi_noc_txrspflitpend = 1'b1;
    assign chi_noc_txrspflit = {qos, tgtid,   srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag}; // = 1'b0;
    assign chi_noc_txrspflitv =   rxreq_to_txrsp_wr_en;
  
    
    credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txrspflitv),
        .noc_chi_lcrdv( noc_chi_txrsplcrdv),
        .have_cridit(have_cridit),
         .nearly_full(),
        .reset(reset),
        .clk(clk)
     );
  
  
  /* 
    
    //delay the ready signal to test conditions when the rsp reaches to home after all other responces
    reg [31: 0] counter;
    reg  mask;
    always @(posedge clk) begin
        if(reset)begin 
            counter <=0;
            mask <=   1'b0; 
        end    
        else begin 
            if(rxreq_to_txrsp_wr_en )begin 
                counter <=0;
                mask <= 1'b0;// : 2'b11;
            end    
            else if(counter <2000)  counter <=counter +1'b1;
            else   mask<=1'b1;
        end
    end    
   */
  
  
     assign txrsp_to_rxreq_ready =   have_cridit;// & mask;    
    
    
  
   
     

endmodule

