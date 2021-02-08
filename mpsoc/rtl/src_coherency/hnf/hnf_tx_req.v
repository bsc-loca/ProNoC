/**************************************
* Module: hnf_tx_req
* Date:2019-05-27  
* Author: alireza     
*
* Description: 
***************************************/
module  hnf_tx_req #(
    parameter VERBOSITY=0,
    parameter B=4
    //parameter src_id=0
)(

    src_id,
    //chi txreq
    chi_noc_txreqflitpend,
    chi_noc_txreqflitv,
    chi_noc_txreqflit,          
    noc_chi_txreqlcrdv,


    //hnf_txreq   
    txreq_to_rxreq_ready,
    rxreq_to_txreq_wr,
    rxreq_to_txreq_opcode,
    rxreq_to_txreq_tgtid,
    rxreq_to_txreq_txnid,
    rxreq_to_txreq_returnnid,
    rxreq_to_txreq_returntxnid,
    rxreq_to_txreq_addr,
    rxreq_to_txreq_likelyshared,
    
    
    //hnf_rxdat
    txreq_to_rxdat_ready,
    rxdat_to_txreq_wr,
    rxdat_to_txreq_opcode,
    rxdat_to_txreq_tgtid,
    rxdat_to_txreq_txnid,
    rxdat_to_txreq_returnnid,
    rxdat_to_txreq_returntxnid,
    rxdat_to_txreq_addr,
    rxdat_to_txreq_likelyshared,
    
    //general 
    reset,
    clk

);

    
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
    
    input [31 : 0] src_id;

    //chi tx_req
    output   chi_noc_txreqflitpend ;
    output   chi_noc_txreqflitv;
    output  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit;          
    input  noc_chi_txreqlcrdv;


    //hnf_rxreq   
    output txreq_to_rxreq_ready;
    input rxreq_to_txreq_wr;
    input [OPCODE_REQ-1 : 0] rxreq_to_txreq_opcode;
    input [TGTID_REQ-1  : 0] rxreq_to_txreq_tgtid;
    input [TXNID_REQ-1  : 0] rxreq_to_txreq_txnid;
    input [RETURNNID_REQ-1 : 0] rxreq_to_txreq_returnnid;
    input [RETURNTXNID_REQ-1:0] rxreq_to_txreq_returntxnid;
    input [ADDR_REQ-1: 0] rxreq_to_txreq_addr;
    input rxreq_to_txreq_likelyshared;
    
    //hnf_rxdat   
    output txreq_to_rxdat_ready;
    input rxdat_to_txreq_wr;
    input [OPCODE_REQ-1 : 0] rxdat_to_txreq_opcode;
    input [TGTID_REQ-1  : 0] rxdat_to_txreq_tgtid;
    input [TXNID_REQ-1  : 0] rxdat_to_txreq_txnid;
    input [RETURNNID_REQ-1 : 0] rxdat_to_txreq_returnnid;
    input [RETURNTXNID_REQ-1:0] rxdat_to_txreq_returntxnid;
    input [ADDR_REQ-1: 0] rxdat_to_txreq_addr;
    input rxdat_to_txreq_likelyshared;
    

    //general 
    input reset,clk;
    
      
    
    wire have_cridit;
    
    
    
   localparam
        Dw = OPCODE_REQ + TGTID_REQ + TXNID_REQ + RETURNNID_REQ + RETURNTXNID_REQ + ADDR_REQ +1,
        DARRAYw = 2 * Dw;  
  
    wire [Dw-1 : 0 ] rxreq_din ={
        rxreq_to_txreq_opcode,
        rxreq_to_txreq_tgtid,
        rxreq_to_txreq_txnid,
        rxreq_to_txreq_returnnid,
        rxreq_to_txreq_returntxnid,
        rxreq_to_txreq_addr,
        rxreq_to_txreq_likelyshared};
        
    wire [Dw-1 : 0 ] rxdat_din = { rxdat_to_txreq_opcode,
    rxdat_to_txreq_tgtid,
    rxdat_to_txreq_txnid,
    rxdat_to_txreq_returnnid,
    rxdat_to_txreq_returntxnid,
    rxdat_to_txreq_addr,
    rxdat_to_txreq_likelyshared};
     
    wire [DARRAYw-1 : 0] qin_data_in =  {rxreq_din ,rxdat_din};
    wire [1 : 0] qin_we = {rxreq_to_txreq_wr,rxdat_to_txreq_wr};
    wire [1 : 0] qin_is_ready;
    assign  {txreq_to_rxreq_ready,txreq_to_rxdat_ready}  = qin_is_ready;
   
    
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
    
    
    
    
    
    
      // txreqflit
    wire [QOS_REQ-1:0]             qos = {QOS_REQ{1'b0}}; 
    wire [TGTID_REQ-1:0]           tgtid;
    wire [SRCID_REQ-1:0]           srcid = src_id;
    wire [TXNID_REQ-1:0]           txnid ;
    wire [RETURNNID_REQ-1:0]       returnnid ;
    wire               endian = 1'b1;
    wire [RETURNTXNID_REQ-1:0]     returntxnid ;
    wire [OPCODE_REQ-1:0]      opcode;
    wire [SIZE_REQ-1:0]        flitsize = 3'b110 ;
    wire [ADDR_REQ-1:0]        addr;
    
    wire               ns = 1'b1;
    wire               likelyshared;
    wire               allowretry  = 1'b1;
    wire [ORDER_REQ-1:0]       order  = 2'b11;
    wire [PCRDTYPE_REQ-1:0]    pcrdtype  = 4'b0000;
    wire [MEMATTR_REQ-1:0]     memattr = 4'b0111;
    wire               snpattr  = 1'b1;
    wire [LPID_REQ-1:0]        lpid  = 5'b00000;
    wire               excl_snoopme  = 1'b1;
    wire               expcompack=1'b0;
    wire               tracetag  = 1'b0;
    
    
    assign { opcode, tgtid, txnid, returnnid, returntxnid, addr, likelyshared} =qout_data_o;
    
    
    
    assign chi_noc_txreqflitpend =1'b1;
    assign chi_noc_txreqflit = {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} ;
    assign chi_noc_txreqflitv =  qout_we_o;
  
    credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txreqflitv),
        .noc_chi_lcrdv( noc_chi_txreqlcrdv),
        .have_cridit(have_cridit),
         .nearly_full(),
        .reset(reset),
        .clk(clk)
     );
   
    assign qout_is_ready =   have_cridit;    

  
  
//synthesis translate_off 
//synopsys  translate_off
    generate 
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) > 0)begin :debug
    
        monitor_req_flit #(
        	.AGENT_NAME("hnf"),
        	.TYPE("TX")
        )
        monitor
        (
        	.clk(clk),
        	.monitor (chi_noc_txreqflitv),
        	.req_flit(chi_noc_txreqflit),
        	.src_id(src_id)
        );
    
    end
    endgenerate
       


//synthesis translate_on 
//synopsys  translate_on
  

endmodule

