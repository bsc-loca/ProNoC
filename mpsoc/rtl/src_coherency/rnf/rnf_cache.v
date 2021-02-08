/**************************************
* Module: rnf_cache
* Date:2019-05-14  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  rnf_cache #(
    parameter B=4,
    parameter VERBOSITY=0,
 //  parameter src_id=0,
    parameter CACHE_WAY_NUM = 8,
    parameter CACHE_STATUSw = 3, // cache state width
    parameter CACHE_BLK_SIZ = 64, 
    parameter CACHE_DATAw = 32,
    parameter CACHE_INDEXw=10,
    parameter CACHE_ADDRw=32,
    parameter CACHE_ACTw=2
)(
   
    src_id,
    
    //core_cache_wr
    core_to_cache_wr_addr, 
    core_to_cache_wr_data, 
    core_to_cache_wr_state, 
    core_to_cache_wr_action, 
    core_to_cache_wr_en, 
    core_to_cache_wr_evict, 
    cache_to_core_wr_hit, 
    cache_to_core_wr_done, 
    cache_to_core_wr_ready, 
    
    //rxdat_wr
    rxdat_to_cache_wr_addr,
    rxdat_to_cache_wr_data,
    rxdat_to_cache_wr_evict,
    rxdat_to_cache_wr_state,
    rxdat_to_cache_wr_action,
    rxdat_to_cache_wr_en,
    cache_to_rxdat_wr_hit,    
    cache_to_rxdat_wr_ready,
    cache_to_rxdat_wr_done, 
    
    //rxsnp_wr    
    rxsnp_to_cache_wr_addr,
    rxsnp_to_cache_wr_data,
    rxsnp_to_cache_wr_evict,
    rxsnp_to_cache_wr_state,
    rxsnp_to_cache_wr_action,
    rxsnp_to_cache_wr_en,
    cache_to_rxsnp_wr_hit,    
    cache_to_rxsnp_wr_ready,
    cache_to_rxsnp_wr_done,  
    
    //rxsnp_rd
    rxsnp_to_cache_rd_addr,
    cache_to_rxsnp_rd_data,
    rxsnp_to_cache_rd_en,
    cache_to_rxsnp_rd_ready,   
    cache_to_rxsnp_rd_state,
    cache_to_rxsnp_rd_hit,
    cache_to_rxsnp_rd_done,
    
    //rxrsp_rd
    rxrsp_to_cache_rd_addr,
    cache_to_rxrsp_rd_data,
    rxrsp_to_cache_rd_en,
    cache_to_rxrsp_rd_ready,   
    cache_to_rxrsp_rd_state,
    cache_to_rxrsp_rd_hit,
    cache_to_rxrsp_rd_done,
    

    //general
    reset,
    clk


);


    input [31 : 0] src_id;

     //core_cache_wr
    input [CACHE_ADDRw-1 :0  ] core_to_cache_wr_addr;
    input [CACHE_DATAw-1 : 0] core_to_cache_wr_data;
    input [CACHE_STATUSw-1:0] core_to_cache_wr_state;
    input [CACHE_ACTw-1:0] core_to_cache_wr_action;
    input core_to_cache_wr_en;
    input  core_to_cache_wr_evict;
    output cache_to_core_wr_hit;
    output cache_to_core_wr_done;
    output cache_to_core_wr_ready;


    //rxdat_wr
    input [CACHE_ADDRw-1 :0  ] rxdat_to_cache_wr_addr;
    input [CACHE_DATAw-1 : 0] rxdat_to_cache_wr_data;
    input [CACHE_STATUSw-1:0] rxdat_to_cache_wr_state;
    input [CACHE_ACTw-1:0] rxdat_to_cache_wr_action;
    input rxdat_to_cache_wr_en;
    input rxdat_to_cache_wr_evict;
    output cache_to_rxdat_wr_hit;
    output cache_to_rxdat_wr_done;
    output cache_to_rxdat_wr_ready;

    //rxsnp_wr
    input [CACHE_ADDRw-1 :0  ] rxsnp_to_cache_wr_addr;
    input [CACHE_DATAw-1 : 0] rxsnp_to_cache_wr_data;
    input [CACHE_STATUSw-1:0] rxsnp_to_cache_wr_state;
    input [CACHE_ACTw-1:0] rxsnp_to_cache_wr_action;
    input rxsnp_to_cache_wr_en;
    input rxsnp_to_cache_wr_evict;
    output cache_to_rxsnp_wr_hit;
    output cache_to_rxsnp_wr_done;
    output cache_to_rxsnp_wr_ready;


    //rxsnp_rd
    input [CACHE_ADDRw-1 : 0] rxsnp_to_cache_rd_addr;
    output  [CACHE_DATAw-1 : 0] cache_to_rxsnp_rd_data;
    input rxsnp_to_cache_rd_en;
    output cache_to_rxsnp_rd_ready;   
    output [CACHE_STATUSw-1 : 0] cache_to_rxsnp_rd_state;
    output cache_to_rxsnp_rd_hit;
    output cache_to_rxsnp_rd_done;    


    //rxrsp_rd
    input [CACHE_ADDRw-1 : 0] rxrsp_to_cache_rd_addr;
    output  [CACHE_DATAw-1 : 0] cache_to_rxrsp_rd_data;
    input rxrsp_to_cache_rd_en;
    output cache_to_rxrsp_rd_ready;   
    output [CACHE_STATUSw-1 : 0] cache_to_rxrsp_rd_state;
    output cache_to_rxrsp_rd_hit;
    output cache_to_rxrsp_rd_done;    


    //general
    input reset;
    input clk;
  
  
    //read chanel 
    wire [CACHE_ADDRw-1 : 0] cache_wr_addr;
    wire [CACHE_DATAw-1 : 0] cache_wr_data;
    wire cache_wr_en;
    wire cache_wr_evict;
    wire [CACHE_STATUSw-1 : 0] cache_wr_state;
    wire [CACHE_ACTw-1:0] cache_wr_action;
    wire cache_wr_hit;
    wire cache_wr_ready;  
    wire cache_wr_done; 

    
        
  
    //write chanel
    wire [CACHE_ADDRw-1 : 0] cache_rd_addr;   
    wire [CACHE_DATAw-1 : 0] cache_rd_data;
    wire cache_rd_en;
    wire cache_rd_ready;    
    wire [CACHE_STATUSw-1 : 0] cache_rd_state;
    wire cache_rd_hit;    
    wire cache_rd_done;     
    wire cache_re_fill;
     
    
    
     localparam
        WCH_NUM=3,
        WDw= CACHE_ACTw + CACHE_ADDRw  + CACHE_STATUSw+ CACHE_DATAw +1,
        DARRAYw = WCH_NUM * WDw;  
    
  
    
    wire [WDw-1 : 0 ] rxsnp_wr_din = {rxsnp_to_cache_wr_action,rxsnp_to_cache_wr_evict,rxsnp_to_cache_wr_addr,rxsnp_to_cache_wr_data,  rxsnp_to_cache_wr_state};
    wire [WDw-1 : 0 ] rxdat_wr_din = {rxdat_to_cache_wr_action,rxdat_to_cache_wr_evict,rxdat_to_cache_wr_addr,rxdat_to_cache_wr_data,  rxdat_to_cache_wr_state};
    wire [WDw-1 : 0 ] core_wr_din  = {core_to_cache_wr_action,core_to_cache_wr_evict,core_to_cache_wr_addr,core_to_cache_wr_data,  core_to_cache_wr_state};
    
    
    wire rxsnp_we = rxsnp_to_cache_wr_evict | rxsnp_to_cache_wr_en;
    wire rxdat_we = rxdat_to_cache_wr_evict | rxdat_to_cache_wr_en;
    wire core_we  = core_to_cache_wr_evict  | core_to_cache_wr_en;    
     
    wire [DARRAYw-1 : 0] qin_data_in =  {core_wr_din, rxdat_wr_din, rxsnp_wr_din};
    wire [WCH_NUM-1 : 0] qin_we = {core_we, rxdat_we, rxsnp_we};
    wire [WCH_NUM-1 : 0] qin_is_ready;
    assign  {cache_to_core_wr_ready, cache_to_rxdat_wr_ready, cache_to_rxsnp_wr_ready}  = qin_is_ready;
    
    wire [WDw-1 : 0] qout_data_o;
    wire qout_we_o;
    wire qout_is_ready;
    wire [WCH_NUM-1 : 0 ] qout_winner, wr_out_chanel;
    
       
    
     
    //write chanel    
    many_to_one_pipereg #(
        .Dw(WDw),
        .IN_NUM(WCH_NUM),
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
     
   
    
    wire [1: 0 ] cache_rd_winner,rd_out_chanel; 
    
    many_to_one_pipe_fifo #(
        .B(B),
        .Dw(CACHE_ADDRw),
        .IN_NUM(2),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    rd_fifos
    (
        .qin_data_in({rxrsp_to_cache_rd_addr,rxsnp_to_cache_rd_addr}),
        .qin_we({rxrsp_to_cache_rd_en,rxsnp_to_cache_rd_en}),
        .qin_is_ready({cache_to_rxrsp_rd_ready,cache_to_rxsnp_rd_ready}),
        .qin_valid_o( ),
        .qin_data_o( ),
        
        .qout_data_o(cache_rd_addr),
        .qout_we_o(cache_rd_en),
        .qout_is_ready(cache_rd_ready ),
        .qout_winner(cache_rd_winner ),
        .reset(reset),
        .clk(clk)
    );
   
   
    fwft_fifo #(
        .DATA_WIDTH(2),
        .MAX_DEPTH(3),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
     )
     rd_winner_fifo
     (
        .din(cache_rd_winner),
        .wr_en(cache_rd_en),
        .rd_en(cache_rd_done),
        .dout(rd_out_chanel),
        .full(), // can mask the input rsp and req ready chanel using this
        .nearly_full(),
        .recieve_more_than_0(),
        .recieve_more_than_1(),
        .reset(reset),
        .clk(clk)
     );

   
   
   
    
    assign  cache_to_rxsnp_rd_hit = rd_out_chanel[0] & cache_rd_hit;
    assign  cache_to_rxsnp_rd_data = cache_rd_data;
    assign  cache_to_rxsnp_rd_done = rd_out_chanel[0] & cache_rd_done;
    assign  cache_to_rxsnp_rd_state = cache_rd_state ;
    
    assign  cache_to_rxrsp_rd_hit = rd_out_chanel[1] & cache_rd_hit;
    assign  cache_to_rxrsp_rd_data = cache_rd_data;
    assign  cache_to_rxrsp_rd_done = rd_out_chanel[1] & cache_rd_done;
    assign  cache_to_rxrsp_rd_state = cache_rd_state ;
     
     
     
     
     
     
     
     
     
     
     
    wire wr_evict; 
    assign {cache_wr_action,wr_evict,cache_wr_addr,cache_wr_data, cache_wr_state}   = qout_data_o;
  
    assign cache_wr_evict = qout_we_o & wr_evict;   
    assign cache_wr_en =  qout_we_o & ~wr_evict;      
    
    assign qout_is_ready = cache_wr_ready; 
     
   
     fwft_fifo #(
        .DATA_WIDTH(WCH_NUM),
        .MAX_DEPTH(3),
        .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
     )
     wr_winner_fifo
     (
        .din(qout_winner),
        .wr_en(qout_we_o),
        .rd_en(cache_wr_done),
        .dout(wr_out_chanel),
        .full(), // can mask the input rsp and req ready chanel using this
        .nearly_full(),
        .recieve_more_than_0(),
        .recieve_more_than_1(),
        .reset(reset),
        .clk(clk)
     );
 
 
 
    pronoc_cache_dualport #(
        .VERBOSITY(VERBOSITY),
       //.src_id(src_id),
        .WAY_NUM(CACHE_WAY_NUM),
        .STATUSw(CACHE_STATUSw),
        .BLK_SIZ(CACHE_BLK_SIZ),
        .ADDRw(CACHE_ADDRw),
        .INDEXw(CACHE_INDEXw),   
        .DATAw(CACHE_DATAw),       
        .BYTE_WR_EN("NO")
    )
    cache
    (
        .src_id(src_id),
        //wr
    	.wr_addr(cache_wr_addr),
    	.wr_data(cache_wr_data),
    	.wr_en(cache_wr_en),
    	.wr_evict(cache_wr_evict),
    	.wr_state(cache_wr_state),
    	.wr_hit(cache_wr_hit),
    	.wr_ready(cache_wr_ready),
    	.wr_byteen(1'b0),
    	.wr_done(cache_wr_done),
    	.wr_action(cache_wr_action),
    	//rd
    	.rd_addr(cache_rd_addr),
    	.rd_data(cache_rd_data),
    	.rd_en(cache_rd_en),
    	.rd_ready(cache_rd_ready),
    	.rd_state(cache_rd_state),
    	.rd_hit(cache_rd_hit),
    	.rd_done(cache_rd_done),
    	.re_fill(cache_re_fill),
    	.reset(reset),
    	.clk(clk)
    );
    
  assign cache_to_rxsnp_wr_hit = wr_out_chanel[0] &  cache_wr_hit;
  assign cache_to_rxsnp_wr_done =  wr_out_chanel[0] & cache_wr_done; 
  
  assign cache_to_rxdat_wr_hit = wr_out_chanel[1] &  cache_wr_hit;
  assign cache_to_rxdat_wr_done =  wr_out_chanel[1] & cache_wr_done;
  
  assign cache_to_core_wr_hit = wr_out_chanel[2] &  cache_wr_hit;
  assign cache_to_core_wr_done =  wr_out_chanel[2] & cache_wr_done;
  
 
 endmodule
 