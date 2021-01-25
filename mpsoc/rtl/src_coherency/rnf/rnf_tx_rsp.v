/**************************************
* Module: rnf_tx_rsp
* Date:2019-05-14  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  rnf_tx_rsp #(
    parameter B=4
   // parameter src_id =0
   
    
)(
    src_id,
    reset,
    clk,

    //chi channel 
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,        
    
    //rxdat
    txrsp_to_rxdat_ready,
    rxdat_to_txrsp_txnid,
    rxdat_to_txrsp_tgtid,
    rxdat_to_txrsp_opcode,
    rxdat_to_txrsp_resp,
    rxdat_to_txrsp_wr_en,
    rxdat_txsnp_dbid,
    
    //rxsnp
    txrsp_to_rxsnp_ready,
    rxsnp_to_txrsp_wr_en,
    rxsnp_to_txrsp_txnid,
    rxsnp_to_txrsp_tgtid,
    rxsnp_to_txrsp_opcode,
    rxsnp_to_txrsp_resp,  
    rxsnp_to_txrsp_fwstate
    
   
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
     
    input [31 : 0] src_id;    

    //chi channel
    input reset,clk;
    output  chi_noc_txrspflitpend ;
    output  chi_noc_txrspflitv ;
    output  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit  ;
    input   noc_chi_txrsplcrdv ;
    
    //rxdat
    output  txrsp_to_rxdat_ready;
    input rxdat_to_txrsp_wr_en;
    input [TXNID_RSP-1:0] rxdat_to_txrsp_txnid;
    input [TGTID_RSP-1:0] rxdat_to_txrsp_tgtid;
    input [OPCODE_RSP-1:0] rxdat_to_txrsp_opcode;
    input [RESP_RSP-1:0] rxdat_to_txrsp_resp;
    input [TXNID_RSP-1:0] rxdat_txsnp_dbid;
   
    
    //rxsnp
    output  txrsp_to_rxsnp_ready;
    input rxsnp_to_txrsp_wr_en;
    input [TXNID_RSP-1:0] rxsnp_to_txrsp_txnid;
    input [TGTID_RSP-1:0] rxsnp_to_txrsp_tgtid;
    input [OPCODE_RSP-1:0] rxsnp_to_txrsp_opcode;
    input [RESP_RSP-1:0] rxsnp_to_txrsp_resp;
    input [FWD_DATAPULL_RSP-1 : 0] rxsnp_to_txrsp_fwstate;
       
    
    

    wire have_cridit;  
  
    localparam
        MAXw= (FWD_DATAPULL_RSP>TXNID_RSP)?  FWD_DATAPULL_RSP : TXNID_RSP,
        Dw = MAXw + TXNID_RSP + TGTID_RSP +  OPCODE_RSP +  RESP_RSP,
        DARRAYw = 2 * Dw;  
        
   
    wire [MAXw-1 : 0] rxdata_diff, rxsnp_diff, diff; 
    assign rxdata_diff = rxdat_txsnp_dbid;
    assign rxsnp_diff[FWD_DATAPULL_RSP-1 : 0] = rxsnp_to_txrsp_fwstate;
    
    
    wire [Dw-1 : 0 ] rxdat_din = {rxdata_diff, rxdat_to_txrsp_txnid , rxdat_to_txrsp_tgtid , rxdat_to_txrsp_opcode ,  rxdat_to_txrsp_resp};
    wire [Dw-1 : 0 ] rxsnp_din = {rxsnp_diff, rxsnp_to_txrsp_txnid , rxsnp_to_txrsp_tgtid , rxsnp_to_txrsp_opcode ,  rxsnp_to_txrsp_resp};
          
     
    wire [DARRAYw-1 : 0] qin_data_in =  {rxdat_din ,rxsnp_din};
    wire [1 : 0] qin_we = {rxdat_to_txrsp_wr_en,rxsnp_to_txrsp_wr_en};
    wire [1 : 0] qin_is_ready;
   
    
    
    
   /* 
    //delay the ready signal to test conditions when the rsp reaches to home after all other responces
    reg [31: 0] counter;
    reg [1: 0] mask;
    always @(posedge clk) begin
        if(reset)begin 
            counter <=0;
            mask <= (src_id==1)? 2'b00 : 2'b11;
        end    
        else begin 
            if(rxdat_to_txrsp_wr_en | rxsnp_to_txrsp_wr_en )begin 
                counter <=0;
                mask <= (src_id==1)? 2'b00 : 2'b11;
            end    
            else if(counter <1000)  counter <=counter +1'b1;
            else   mask<=2'b11;
        end
    end    
    */
    
    
    assign  {txrsp_to_rxdat_ready, txrsp_to_rxsnp_ready}  = qin_is_ready; //& mask;
   
    
    wire [Dw-1 : 0] qout_data_o;
    wire qout_we_o;
    wire qout_is_ready;
    wire [1 : 0 ] qout_winner;
    
    
    
    
   //write channel    
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
        .qin_valid_o( ),
        .qin_data_o( ),
        
        .qout_data_o(qout_data_o),
        .qout_we_o(qout_we_o),
        .qout_is_ready(qout_is_ready),
        .qout_winner(qout_winner),
        .reset(reset),
        .clk(clk)
    );  
  
  
  
  
    wire [QOS_RSP-1:0]             qos  = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           tgtid;
    wire [SRCID_RSP-1:0]           srcid =   src_id [SRCID_RSP-1:0];
    wire [TXNID_RSP-1:0]           txnid;
    wire [OPCODE_RSP-1:0]          opcode;
    wire [RESPERR_RSP-1:0]         resperr ={RESPERR_RSP{1'b0}};     
    wire [RESP_RSP-1:0]            resp;
    wire [FWD_DATAPULL_RSP-1:0]    fwd_datapull = diff[FWD_DATAPULL_RSP-1:0];
    wire [DBID_RSP-1:0]            dbid = {DBID_RSP{1'b0}} ;
    wire [PCRDTYPE_RSP-1:0]        pcrdtype = 4'b0000;
    wire                           tracetag = 1'b0;
  
    assign  {diff,txnid , tgtid , opcode , resp} = qout_data_o ;
  
    assign chi_noc_txrspflitpend = 1'b1;
    assign chi_noc_txrspflit = {qos, tgtid,   srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag}; // = 1'b0;
    assign chi_noc_txrspflitv =  qout_we_o;
  
    
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
     
     
     
     
     
  
    assign qout_is_ready =   have_cridit;    
    
    
   
   
     

endmodule

