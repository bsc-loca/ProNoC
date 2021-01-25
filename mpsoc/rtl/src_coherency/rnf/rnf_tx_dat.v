/**************************************
* Module: rnf_tx_dat
* Date:2019-06-11  
* Author: alireza     
*
* Description: 
***************************************/
module  rnf_tx_dat #(
    parameter VERBOSITY=0,
    parameter B=4
    //parameter src_id=1
)(
    
    src_id,
    // chi TXDAT
    chi_noc_txdatflitpend,
    chi_noc_txdatflitv,
    chi_noc_txdatflit,
    noc_chi_txdatlcrdv,
    
    // rxsnp
    txdat_to_rxsnp_ready,
    rxsnp_to_txdat_wr,
    rxsnp_to_txdat_dat,
    rxsnp_to_txdat_tgtid,
    rxsnp_to_txdat_txnid,
    rxsnp_to_txdat_dbid,
    rxsnp_to_txopcode_dat,
    rxsnp_to_txdat_resp,
    rxsnp_to_txdat_homenid,
    
    //rxrsp
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
    

    // general
    reset,
    clk
);


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
   input [31 : 0] src_id;
    
    output   chi_noc_txdatflitpend ;
    output   chi_noc_txdatflitv ;
    output  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit  ;
    input    noc_chi_txdatlcrdv ;
    
    
    output   txdat_to_rxsnp_ready;
    input [DATA_DAT-1 : 0] rxsnp_to_txdat_dat;
    input rxsnp_to_txdat_wr;
    input [TGTID_DAT-1:0]  rxsnp_to_txdat_tgtid;
    input [TXNID_DAT-1:0]  rxsnp_to_txdat_txnid;
    input [TXNID_DAT-1:0]  rxsnp_to_txdat_dbid;
    input [RESP_DAT-1 : 0] rxsnp_to_txdat_resp;
    input [OPCODE_DAT-1 : 0] rxsnp_to_txopcode_dat;
    input [SRCID_DAT-1:0] rxsnp_to_txdat_homenid; 
    
    
    //rxrsp
    output txdat_to_undat_nearly_full;
    output   txdat_to_undat_ready;
    input [DATA_DAT-1 : 0] undat_to_txdat_dat;
    input undat_to_txdat_wr;
    input [TGTID_DAT-1:0]  undat_to_txdat_tgtid;
    input [TXNID_DAT-1:0]  undat_to_txdat_txnid;
    input [TXNID_DAT-1:0]  undat_to_txdat_dbid;
    input [RESP_DAT-1 : 0] undat_to_txdat_resp;
    input [OPCODE_DAT-1 : 0] undat_to_txdat_opcode;
    input [SRCID_DAT-1:0] undat_to_txdat_homenid;

    input reset,clk;
    
    wire have_cridit;


     localparam
        Dw=SRCID_DAT+  DATA_DAT + TGTID_REQ + TXNID_REQ + TXNID_REQ + RESP_DAT + OPCODE_DAT,
        DARRAYw = 2 * Dw;  
    
    wire [Dw-1 : 0 ] rxsnp_din = {rxsnp_to_txdat_homenid,rxsnp_to_txdat_dat, rxsnp_to_txdat_tgtid,   rxsnp_to_txdat_txnid,  rxsnp_to_txdat_dbid, rxsnp_to_txdat_resp, rxsnp_to_txopcode_dat};
    wire [Dw-1 : 0 ] rxrsp_din = {undat_to_txdat_homenid,undat_to_txdat_dat, undat_to_txdat_tgtid,   undat_to_txdat_txnid,  undat_to_txdat_dbid, undat_to_txdat_resp, undat_to_txdat_opcode};
          
     
    wire [DARRAYw-1 : 0] qin_data_in =  {rxrsp_din ,rxsnp_din};
    wire [1 : 0] qin_we = {undat_to_txdat_wr,rxsnp_to_txdat_wr};
    wire [1 : 0] qin_is_ready;
   
   
   
/*    
    //delay the ready signal to test conditions when the data reaches to home after all other responces
    reg [31: 0] counter;
    reg [1: 0] mask;
    always @(posedge clk) begin
        if(reset)begin 
            counter <=0;
            mask <= (src_id==1)? 2'b00 : 2'b11;
        end    
        else begin 
            if(chi_noc_txdatflitv )begin 
                counter <=0;
                mask <= (src_id==1)? 2'b00 : 2'b11;
            end    
            else if(counter <1000)  counter <=counter +1'b1;
            else   mask<=2'b11;
        end
    end    
   */
    assign  {txdat_to_undat_ready, txdat_to_rxsnp_ready}  = qin_is_ready;// & mask;
   
    
    wire [Dw-1 : 0] qout_data_o;
    wire qout_we_o;
    wire qout_is_ready;
    
      
    
    
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
        .qout_winner( ),
        .reset(reset),
        .clk(clk)
    );  
  
    
    wire [QOS_DAT-1:0]             qos  = {QOS_REQ{1'b0}}; // not supported
    wire [TGTID_DAT-1:0]           tgtid   ;
    wire [SRCID_DAT-1:0]           srcid  = src_id;
    wire [TXNID_DAT-1:0]           txnid  ;
    wire [HOMENID_DAT-1:0]         homenid   ; 
    wire [OPCODE_DAT-1:0]          opcode ;
    wire [RESPERR_DAT-1:0]         resperr = {RESPERR_DAT{1'b0}};   // not supported  
    wire [RESP_DAT-1:0]            resp  ;
    wire [FWD_DATAPULL_DAT-1:0]    fwd_datapull = {FWD_DATAPULL_DAT{1'b0}}; // not supported
    wire [DBID_DAT-1:0]            dbid  ;
    wire [CCID_DAT-1:0]            ccid = {CCID_DAT{1'b0}}; // not supported
    wire [DATAID_DAT-1:0]          dataid = {DATAID_DAT{1'b0}}; // not supported
    wire                           tracetag  = 1'b0; // not supported
    wire [BE_DAT-1:0]              be ={BE_DAT{1'b1}}; // not supported
    wire [DATA_DAT-1:0]            data ;
    wire [DATACHECK_DAT-1:0]       datacheck = {DATACHECK_DAT{1'b0}} ;// not supported
    wire [POISON_DAT-1:0]          poison = {POISON_DAT{1'b0}}; // not supported
    
    
    
    assign  {homenid,data, tgtid, txnid,  dbid, resp, opcode} = qout_data_o ;
    
    
    assign chi_noc_txdatflitpend =1'b1;
    assign chi_noc_txdatflit = {qos,tgtid,srcid ,txnid ,homenid ,opcode ,resperr, resp ,fwd_datapull ,dbid ,ccid ,dataid ,tracetag ,be ,data ,datacheck  ,poison};
    assign chi_noc_txdatflitv =  qout_we_o;
  
    credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txdatflitv),
        .noc_chi_lcrdv( noc_chi_txdatlcrdv),
        .have_cridit(have_cridit),
        .nearly_full( ),
        .reset(reset),
        .clk(clk)
     );
  
  
  
    
   
  
  
    assign qout_is_ready =   have_cridit;
   

//synthesis translate_off 
//synopsys  translate_off


always @(posedge clk) begin
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) > 0)begin 
        if(chi_noc_txdatflitv) begin 
        $display("%t: rnf ( %d ) txn ( %d ) send dat flit: qos ( %d ), tgtid ( %d ), srcid ( %d ), homenid ( %d ), opcode ( %d ), resperr ( %d ), resp ( %d ), fwd_datapull ( %d )",
        $time,src_id, txnid, qos, tgtid, srcid, homenid ,opcode, resperr, resp, fwd_datapull);
        $display("%t: rnf ( %d ) txn ( %d ) send dat flit: dbid ( %d ), ccid ( %d ), dataid ( %d ), tracetag ( %d ), be ( %d ), data ( %d ), datacheck ( %d ), poison ( %d )",
        $time,src_id, txnid, dbid, ccid, dataid, tracetag, be, data, datacheck, poison);
        end
    end
end


//synthesis translate_on 
//synopsys  translate_on



endmodule

    
    
   
