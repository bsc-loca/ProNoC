/**************************************
* Module: slave_full_node
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/
`timescale     1ns/1ps

module  snf #(
    parameter VERBOSITY=4, // The higher the VERBOSITY the higher details are printed in simuation terminal
    parameter MAX_HNFs_ASSIGND_TO_A_SN = 2,
   // parameter src_id=2,
    parameter B=4,
    parameter EAw=4,
    parameter MEM_RD_PIPE_LATENCY=50,
    parameter MEM_WR_PIPE_LATENCY=50
    )(
    src_id,
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend,
    chi_noc_txreqflitv,
    chi_noc_txreqflit,
    noc_chi_txreqlcrdv,
    
    // TXDAT
    chi_noc_txdatflitpend,
    chi_noc_txdatflitv,
    chi_noc_txdatflit,
    noc_chi_txdatlcrdv,
    
    // TXRSP
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,
    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop channel so need target ID
    chi_noc_txsnpflitpend,
    chi_noc_txsnpflitv,
    chi_noc_txsnpflit,
    noc_chi_txsnplcrdv,         
    
     // RXREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,          
    chi_noc_rxreqlcrdv,      
    
    
    // CRSP/RXRSP
    noc_chi_rxrspflitpend,
    noc_chi_rxrspflitv,
    noc_chi_rxrspflit,
    chi_noc_rxrsplcrdv,
    
    // RDAT
    noc_chi_rxdatflitpend,
    noc_chi_rxdatflitv,
    noc_chi_rxdatflit,
    chi_noc_rxdatlcrdv, 
    
    // SNP/RXSNP
    noc_chi_rxsnpflitpend,
    noc_chi_rxsnpflitv,
    noc_chi_rxsnpflit,
    chi_noc_rxsnplcrdv,
    
    snp_target_id,
    assign_hnfs
  
    );            
    
     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
    
    
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"   
    
     localparam TXN_IDw = (MAX_HNFs_ASSIGND_TO_A_SN>1)? TXNID_REQ + log2(MAX_HNFs_ASSIGND_TO_A_SN): TXNID_REQ;
    
    input [31 : 0] src_id;
    
    // Clock and Reset
    input clk,reset;
           
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    output   chi_noc_txreqflitpend ;
    output   chi_noc_txreqflitv;
    output  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit;          
    input  noc_chi_txreqlcrdv;
    // TXDAT
    output   chi_noc_txdatflitpend ;
    output   chi_noc_txdatflitv ;
    output  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit  ;
    input    noc_chi_txdatlcrdv ;
    // TXRSP
    output    chi_noc_txrspflitpend ;
    output   chi_noc_txrspflitv ;
    output  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit  ;
    input    noc_chi_txrsplcrdv ;
    // CRSP/RXRSP
    input    noc_chi_rxrspflitpend ;
    input    noc_chi_rxrspflitv ;
    input   [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit ;
    output   chi_noc_rxrsplcrdv ;
    // RDAT
    input    noc_chi_rxdatflitpend ;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output   chi_noc_rxdatlcrdv ; 
    // SNP/RXSNP
    input    noc_chi_rxsnpflitpend ;
    input    noc_chi_rxsnpflitv ;
    input   [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit ;
    output   chi_noc_rxsnplcrdv ;         
    
    
      //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop channel so need target ID
    output    chi_noc_txsnpflitpend ;
    output    chi_noc_txsnpflitv ;
    output   [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit ;
    input   noc_chi_txsnplcrdv ;         
    
     // RXREQ
    input   noc_chi_rxreqflitpend ;
    input   noc_chi_rxreqflitv;
    input  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit;          
    output   chi_noc_rxreqlcrdv;   

    output [EAw-1 : 0]  snp_target_id;   


    input [SRCID_REQ*MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] assign_hnfs;

    //rxreq_txdat
    wire rxreq_to_txdat_wr;
    wire [DATA_DAT-1 : 0] rxreq_to_txdat_dat;
    wire [TGTID_DAT-1:0]  rxreq_to_txdat_tgtid;        
    wire [TXNID_DAT-1:0]  rxreq_to_txdat_txnid;        
    wire [TXNID_DAT-1:0]  rxreq_to_txdat_dbid;
    wire [SRCID_DAT-1:0]  rxreq_to_txdat_homenid;
    wire [RESP_DAT-1:0]   rxreq_to_txdat_resp;
    wire [OPCODE_DAT-1:0] rxreq_to_txopcode_dat;
    wire txdat_to_rxreq_ready;


    //txrsp
    wire  txrsp_to_rxreq_ready;
    wire  rxreq_to_txrsp_wr_en;
    wire  [TXNID_RSP-1:0] rxreq_to_txrsp_txnid;
    wire  [TGTID_RSP-1:0] rxreq_to_txrsp_tgtid;
    wire  [OPCODE_RSP-1:0] rxreq_to_txrsp_opcode;
    wire  [RESP_RSP-1:0] rxreq_to_txrsp_resp;
    wire  [TXNID_RSP-1:0] rxreq_txsnp_dbid;


    //main memory rd
    wire [DATA_DAT-1 : 0] mem_to_rxreq_rd_data;
    wire [ADDR_REQ-1 : 0] rxreq_to_mem_rd_addr;   
    wire rxreq_to_mem_rd_en;
    wire mem_to_rxreq_rd_ready;
    wire mem_to_rxreq_rd_done; 
    
    //main mem wr
    wire [DATA_DAT-1 : 0] rxdat_to_mem_wr_data;
    wire [ADDR_REQ-1 : 0] rxdat_to_mem_wr_addr;
    wire rxdat_to_mem_wr_en;
    wire mem_to_rxdat_wr_ready;
    wire mem_to_rxdat_wr_done;
    wire mem_to_rxreq_wr_credit_incr;

    //txnlkpt_txreq
    wire [TXN_IDw-1 : 0] txreq_to_txnlkpt_txnid;
    wire [SNF_TXN_DATAw-1 : 0] txreq_to_txnlkpt_txndat;
    wire txreq_to_txnlkpt_valid;
    
    //txnlkpt_rxdat
    wire [TXN_IDw-1 : 0] rxdat_to_txnlkpt_txnid;
    wire rxdat_to_txnlkpt_rd_valid;
    wire [SNF_TXN_DATAw-1 : 0]txnlkpt_to_rxdat_txndat;      
   
   
   snf_rx_req #(
    .VERBOSITY(VERBOSITY),
    .MAX_HNFs_ASSIGND_TO_A_SN(MAX_HNFs_ASSIGND_TO_A_SN),
   	.B(B)
   	//.src_id(src_id)
   )
   rx_req
   (
   .src_id(src_id),
   	.noc_chi_rxreqflitpend(noc_chi_rxreqflitpend),
   	.noc_chi_rxreqflitv(noc_chi_rxreqflitv),
   	.noc_chi_rxreqflit(noc_chi_rxreqflit),
   	.chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv),
   	//txdat
   	.rxreq_to_txdat_wr(rxreq_to_txdat_wr),
   	.rxreq_to_txdat_dat(rxreq_to_txdat_dat),
   	.rxreq_to_txdat_tgtid(rxreq_to_txdat_tgtid),
   	.rxreq_to_txdat_txnid(rxreq_to_txdat_txnid),
   	.rxreq_to_txdat_dbid(rxreq_to_txdat_dbid),
   	.rxreq_to_txdat_homenid(rxreq_to_txdat_homenid),
   	.rxreq_to_txdat_resp(rxreq_to_txdat_resp),
   	.rxreq_to_txopcode_dat(rxreq_to_txopcode_dat),
   	.txdat_to_rxreq_ready(txdat_to_rxreq_ready),
   	
   	//mem
   	.mem_to_rxreq_rd_data(mem_to_rxreq_rd_data),
   	.rxreq_to_mem_rd_addr(rxreq_to_mem_rd_addr),
   	.rxreq_to_mem_rd_en(rxreq_to_mem_rd_en),
   	.mem_to_rxreq_rd_ready(mem_to_rxreq_rd_ready),
   	.mem_to_rxreq_rd_done(mem_to_rxreq_rd_done),
   	.mem_to_rxreq_wr_credit_incr(mem_to_rxreq_wr_credit_incr),
   
    //txnlkpt
    .txreq_to_txnlkpt_txnid(txreq_to_txnlkpt_txnid), 
    .txreq_to_txnlkpt_txndat(txreq_to_txnlkpt_txndat), 
    .txreq_to_txnlkpt_valid(txreq_to_txnlkpt_valid), 
   
   
    /*
    * 
    * 
    * 
    * 
   	.rxdat_to_mem_wr_data(rxdat_to_mem_wr_data),
   	.rxdat_to_mem_wr_addr(rxdat_to_mem_wr_addr),
   	.rxdat_to_mem_wr_en(rxdat_to_mem_wr_en),
   	.mem_to_rxdat_wr_ready(mem_to_rxdat_wr_ready),
   	.mem_to_rxdat_wr_done(mem_to_rxdat_wr_done),   	
   	*/
   	//txrsp
   	.txrsp_to_rxreq_ready(txrsp_to_rxreq_ready),
    .rxreq_to_txrsp_wr_en(rxreq_to_txrsp_wr_en),
    .rxreq_to_txrsp_txnid(rxreq_to_txrsp_txnid),
    .rxreq_to_txrsp_tgtid(rxreq_to_txrsp_tgtid),
    .rxreq_to_txrsp_opcode(rxreq_to_txrsp_opcode),
    .rxreq_to_txrsp_resp(rxreq_to_txrsp_resp),
    .rxreq_txsnp_dbid(rxreq_txsnp_dbid),
   	
   	
    //general
   	.assign_hnfs(assign_hnfs),
   	.reset(reset),
   	.clk(clk)
   );
   
   
   
   
   
   snf_tx_dat #(
    .VERBOSITY(VERBOSITY),
   	.B(B)
  // 	.src_id(src_id)
   )
   tx_dat
   (
   	
   	.src_id(src_id),
   	
   	.reset(reset),
   	.clk(clk),
  
   	
   	.chi_noc_txdatflitpend(chi_noc_txdatflitpend),
   	.chi_noc_txdatflitv(chi_noc_txdatflitv),
   	.chi_noc_txdatflit(chi_noc_txdatflit),
   	.noc_chi_txdatlcrdv(noc_chi_txdatlcrdv),
   	
   	//rxreq   	
   	.rxreq_to_txdat_wr(rxreq_to_txdat_wr),
   	.rxreq_to_txdat_dat(rxreq_to_txdat_dat),
   	.rxreq_to_txdat_tgtid(rxreq_to_txdat_tgtid),
   	.rxreq_to_txdat_txnid(rxreq_to_txdat_txnid),
   	.rxreq_to_txdat_dbid(rxreq_to_txdat_dbid),
   	.rxreq_to_txdat_homenid(rxreq_to_txdat_homenid),
   	.rxreq_to_txdat_resp(rxreq_to_txdat_resp),
   	.rxreq_to_txopcode_dat(rxreq_to_txopcode_dat),
   	.txdat_to_rxreq_ready(txdat_to_rxreq_ready)
   );
   
   snf_tx_rsp #(
   	.B(B)
  // 	.src_id(src_id)
   )
   tx_rsp
   (
   	.src_id(src_id),
   	.reset(reset),
   	.clk(clk),
   	.chi_noc_txrspflitpend(chi_noc_txrspflitpend),
   	.chi_noc_txrspflitv(chi_noc_txrspflitv),
   	.chi_noc_txrspflit(chi_noc_txrspflit),
   	.noc_chi_txrsplcrdv(noc_chi_txrsplcrdv),
   	.txrsp_to_rxreq_ready(txrsp_to_rxreq_ready),
   	.rxreq_to_txrsp_wr_en(rxreq_to_txrsp_wr_en),
   	.rxreq_to_txrsp_txnid(rxreq_to_txrsp_txnid),
   	.rxreq_to_txrsp_tgtid(rxreq_to_txrsp_tgtid),
   	.rxreq_to_txrsp_opcode(rxreq_to_txrsp_opcode),
   	.rxreq_to_txrsp_resp(rxreq_to_txrsp_resp),
   	.rxreq_txsnp_dbid(rxreq_txsnp_dbid)
   );
   
    
    snf_rx_dat #(
    	.B(B),
    //	.src_id(src_id),
    	.MAX_HNFs_ASSIGND_TO_A_SN(MAX_HNFs_ASSIGND_TO_A_SN)
    )
    rx_dat
    (
        .src_id(src_id),
    	.clk(clk),
    	.reset(reset),
    	.assign_hnfs(assign_hnfs),
    	   
    	.noc_chi_rxdatflitpend(noc_chi_rxdatflitpend),
    	.noc_chi_rxdatflitv(noc_chi_rxdatflitv),
    	.noc_chi_rxdatflit(noc_chi_rxdatflit),
    	.chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv),
    	.rxdat_to_mem_wr_data(rxdat_to_mem_wr_data),
    	.rxdat_to_mem_wr_addr(rxdat_to_mem_wr_addr),
    	.rxdat_to_mem_wr_en(rxdat_to_mem_wr_en),
    	.mem_to_rxdat_wr_ready(mem_to_rxdat_wr_ready),
    	.mem_to_rxdat_wr_done(mem_to_rxdat_wr_done),
    	.rxdat_to_txnlkpt_txnid(rxdat_to_txnlkpt_txnid),
    	.rxdat_to_txnlkpt_rd_valid(rxdat_to_txnlkpt_rd_valid),
    	.txnlkpt_to_rxdat_txndat(txnlkpt_to_rxdat_txndat)
    );
    
    //main memory module
    main_mem_emulator #(
        .VERBOSITY(VERBOSITY),
      //  .src_id(src_id),
    	.B(B),
    	.RD_LATENCY(MEM_RD_PIPE_LATENCY),
    	.WR_LATENCY(MEM_WR_PIPE_LATENCY),
      	.Dw(DATA_DAT),    	
    	.Aw(20)
    )
    main_mem_emulator
    (
    	.src_id(src_id),
    	.mem_to_rxreq_rd_data(mem_to_rxreq_rd_data),
    	.rxreq_to_mem_rd_addr(rxreq_to_mem_rd_addr),
    	.rxreq_to_mem_rd_en(rxreq_to_mem_rd_en),
    	.mem_to_rxreq_rd_ready(mem_to_rxreq_rd_ready),
    	.mem_to_rxreq_rd_done(mem_to_rxreq_rd_done),
    	.mem_to_rxreq_wr_credit_incr(mem_to_rxreq_wr_credit_incr),
    	
    	.rxdat_to_mem_wr_data(rxdat_to_mem_wr_data),
    	.rxdat_to_mem_wr_addr(rxdat_to_mem_wr_addr),
    	.rxdat_to_mem_wr_en(rxdat_to_mem_wr_en),
    	.mem_to_rxdat_wr_ready(mem_to_rxdat_wr_ready),
    	.mem_to_rxdat_wr_done(mem_to_rxdat_wr_done),
    	
    	.clk(clk),
    	.reset(reset)
    );

  
   
   transaction_lookup_table #(
   	.TXN_DATAw(SNF_TXN_DATAw),
   	.TXN_IDw(TXN_IDw)
   )
   txn_lookup(
   	.txn_wr_addr(txreq_to_txnlkpt_txnid),   
   	.txn_wr_dat(txreq_to_txnlkpt_txndat),
   	.txn_wr_en(txreq_to_txnlkpt_valid),
   	
   	.txn_rd_addr(rxdat_to_txnlkpt_txnid),
   	.txn_rd_dat(txnlkpt_to_rxdat_txndat), 
   	.txn_rd_en(rxdat_to_txnlkpt_rd_valid),
   	.clk(clk)
   );
   
   
    
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_FLIT_INJECT) > 0) begin 
            if(noc_chi_rxrspflitv) $display("%t: snf ( %d ) rsp channel has recived a packet:%h",$time,src_id,noc_chi_rxrspflit);
            if(noc_chi_rxdatflitv) $display("%t: snf ( %d ) dat channel has recived a packet:%h",$time,src_id,noc_chi_rxdatflit);
            if(noc_chi_rxreqflitv) $display("%t: snf ( %d ) req channel has recived a packet:%h",$time,src_id,noc_chi_rxreqflit);
            if(noc_chi_rxsnpflitv) $display("%t: snf ( %d ) snp channel has recived a packet:%h",$time,src_id,noc_chi_rxsnpflit);
        end
    end
    //synthesis translate_on 
    //synopsys  translate_on
   
   
   
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_FLIT_INJECT) > 0) begin 
            if(chi_noc_txrspflitv) $display("%t: snf ( %d ) rsp channel has sent a packet:%h",$time,src_id,chi_noc_txrspflit);
            if(chi_noc_txdatflitv) $display("%t: snf ( %d ) dat channel has sent a packet:%h",$time,src_id,chi_noc_txdatflit);
            if(chi_noc_txreqflitv) $display("%t: snf ( %d ) req channel has sent a packet:%h",$time,src_id,chi_noc_txreqflit);
            if(chi_noc_txsnpflitv) $display("%t: snf ( %d ) snp channel has sent a packet:%h",$time,src_id,chi_noc_txsnpflit);
        end
    end
    //synthesis translate_on 
    //synopsys  translate_on




endmodule

