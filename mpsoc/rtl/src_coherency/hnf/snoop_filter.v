/**************************************
* Module: snp_filter_cache
* Date:2019-05-16  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  snoop_filter#(
    parameter VERBOSITY = 0,
   // parameter src_id=0,
  
    parameter RESET_DELAY= "IGNORE",   /*
        "IGNORE" : No policy is implemented for resetting the cache valid bits at reset time. Assumption is that the ram is reset externally  
         "MULTI_CLKS": the cache controller reset the entire cache block after  reset assertion. The number of needed clock cycle is equal to cache line number
        */
    parameter SPVw = 32,
    
    parameter WAY_NUM = 8,
    parameter STATUSw = 3,
    parameter BLK_SIZ = 64, 
    parameter INDEXw=10,
    parameter ADDRw=32
   
)(  

    src_id,
    //rxreq
    rxreq_to_snpf_wr_addr,
    rxreq_to_snpf_wr_en,
    rxreq_to_snpf_wr_evict,
    rxreq_to_snpf_wr_spv,
   // rxreq_to_snpf_wr_state, // will be caclculated based on spv state 
    rxreq_to_snpf_update_state,
    rxreq_to_snpf_action,
    
    
    snpf_to_rxreq_wr_hit,
    snpf_to_rxreq_wr_chnl_ready,
    snpf_to_rxreq_wr_is_failed,
    snpf_to_rxreq_wr_done,
    snpf_to_rxreq_re_fill,
    snpf_to_rxreq_re_fill_wr_spv,     
    
    rxreq_to_snpf_rd_addr,
    rxreq_to_snpf_rd_en,
    snpf_to_rxreq_spv,
    snpf_to_rxreq_rd_state,
    snpf_to_rxreq_rd_hit,
    snpf_to_rxreq_rd_ready,
    snpf_to_rxreq_rd_done,    
    snpf_to_rxreq_rd_busy_bit,   
    snpf_to_rxreq_rd_cnt_acpt_new,
    
    
    //rxrsp
    rxrsp_to_snpf_wr_addr,
    rxrsp_to_snpf_wr_en,
    rxrsp_to_snpf_wr_evict,
    rxrsp_to_snpf_wr_spv,
 //   rxrsp_to_snpf_wr_state, // will be caclculated based on spv state 
    rxrsp_to_snpf_update_state,
    rxrsp_to_snpf_action,
    
    
    snpf_to_rxrsp_wr_hit,
    snpf_to_rxrsp_wr_chnl_ready,
    snpf_to_rxrsp_wr_is_failed,
    snpf_to_rxrsp_wr_done,
    snpf_to_rxrsp_re_fill,
    snpf_to_rxrsp_re_fill_wr_spv, 
    
    
    //undat
    undat_to_snpf_wr_addr, 
    undat_to_snpf_wr_en, 
    undat_to_snpf_wr_evict, 
    undat_to_snpf_wr_spv, 
   // undat_to_snpf_wr_state, // will be caclculated based on spv state 
    undat_to_snpf_update_state, 
    undat_to_snpf_action,  
    
    
    snpf_to_undat_wr_hit, 
    snpf_to_undat_wr_chnl_ready, 
    snpf_to_undat_wr_is_failed, 
    snpf_to_undat_wr_done,  
    
    
    
    
    //evbuf
    evbuf_to_rxreq_addr,
    evbuf_to_rxreq_dat,
    evbuf_to_rxreq_valid,
    rxreq_evbuf_rd_en,
    
    reset,     
    clk
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
      function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
    
    
   localparam  ADRR_OFFSETw = log2(CACHE_BLK_SIZ);        // The address range in cache block
   
   input [31 : 0] src_id;
                      
    //rxreq
    input [ADDRw-1 : 0] rxreq_to_snpf_wr_addr;
    input rxreq_to_snpf_wr_en;
    input rxreq_to_snpf_wr_evict;
    input [SPVw-1 : 0] rxreq_to_snpf_wr_spv;
  //  input [STATUSw-1 : 0] rxreq_to_snpf_wr_state;
    input rxreq_to_snpf_update_state;
    input [SNPF_ACTw-1: 0] rxreq_to_snpf_action;  
   
    
    output snpf_to_rxreq_wr_hit;
    output snpf_to_rxreq_wr_chnl_ready;
    output snpf_to_rxreq_wr_is_failed;
    output snpf_to_rxreq_wr_done;
    output snpf_to_rxreq_re_fill;
    output [SPVw-1 : 0] snpf_to_rxreq_re_fill_wr_spv;
    
       
    input [ADDRw-1 : 0] rxreq_to_snpf_rd_addr;
    input rxreq_to_snpf_rd_en;
    output[SPVw-1 : 0] snpf_to_rxreq_spv;
    output[STATUSw-1 : 0] snpf_to_rxreq_rd_state;
    output snpf_to_rxreq_rd_ready;    
    output snpf_to_rxreq_rd_hit;
    output snpf_to_rxreq_rd_done;
    output snpf_to_rxreq_rd_busy_bit;
    output snpf_to_rxreq_rd_cnt_acpt_new;
    
    //rxrsp
    input [ADDRw-1 : 0] rxrsp_to_snpf_wr_addr;
    input rxrsp_to_snpf_wr_en;
    input rxrsp_to_snpf_wr_evict;
    input [SPVw-1 : 0] rxrsp_to_snpf_wr_spv;
  //  input [STATUSw-1 : 0] rxrsp_to_snpf_wr_state;
    input rxrsp_to_snpf_update_state;
    input [SNPF_ACTw-1: 0] rxrsp_to_snpf_action;    
    
    output snpf_to_rxrsp_wr_hit;
    output snpf_to_rxrsp_wr_chnl_ready;
    output snpf_to_rxrsp_wr_is_failed;
    output snpf_to_rxrsp_wr_done;   
    output snpf_to_rxrsp_re_fill;
    output [SPVw-1 : 0] snpf_to_rxrsp_re_fill_wr_spv; 
    
    output [ADDRw-1 : 0]  evbuf_to_rxreq_addr;
    output [SPVw-1 : 0] evbuf_to_rxreq_dat;
    output evbuf_to_rxreq_valid;
    input rxreq_evbuf_rd_en;       
    
    // undat
    input  [ADDRw-1 : 0] undat_to_snpf_wr_addr;
    input  undat_to_snpf_wr_en;
    input  undat_to_snpf_wr_evict;
    input  [SPVw-1 : 0] undat_to_snpf_wr_spv;
  //  input  [CACHE_STATUSw-1 : 0] undat_to_snpf_wr_state;
    input  undat_to_snpf_update_state;
    input [SNPF_ACTw-1:0] undat_to_snpf_action;
  
    
    output snpf_to_undat_wr_hit;
    output snpf_to_undat_wr_chnl_ready;
    output snpf_to_undat_wr_is_failed;
    output snpf_to_undat_wr_done;   
   
    
    
  
    input reset;
    input clk;
    
    
    
    localparam
        IN_NUM=3,
       // Dw=  ADDRw + SPVw + STATUSw+2+SNPF_ACTw,
        Dw=  ADDRw + SPVw + //STATUSw+
        2+SNPF_ACTw,
        DARRAYw = IN_NUM * Dw;  
    
    wire [Dw-1 : 0 ] rxreq_din = 
    {rxreq_to_snpf_update_state,rxreq_to_snpf_action,rxreq_to_snpf_wr_evict,rxreq_to_snpf_wr_spv, // rxreq_to_snpf_wr_state,
    rxreq_to_snpf_wr_addr};
    wire [Dw-1 : 0 ] rxrsp_din =
    {rxrsp_to_snpf_update_state,rxrsp_to_snpf_action,rxrsp_to_snpf_wr_evict, rxrsp_to_snpf_wr_spv,// rxrsp_to_snpf_wr_state,
    rxrsp_to_snpf_wr_addr};
    wire [Dw-1 : 0 ] undat_din =
    {undat_to_snpf_update_state,undat_to_snpf_action,undat_to_snpf_wr_evict, undat_to_snpf_wr_spv,// undat_to_snpf_wr_state,
    undat_to_snpf_wr_addr};
   
    
    
    wire rxreq_we = rxreq_to_snpf_wr_evict | rxreq_to_snpf_wr_en;
    wire rxrsp_we = rxrsp_to_snpf_wr_evict | rxrsp_to_snpf_wr_en;
    wire undat_we = undat_to_snpf_wr_evict | undat_to_snpf_wr_en;
        
     
    wire [DARRAYw-1 : 0] qin_data_in =  {undat_din,rxrsp_din ,rxreq_din};
    wire [IN_NUM-1 : 0] qin_we = {undat_we,rxrsp_we,rxreq_we};
    wire [IN_NUM-1 : 0] qin_is_ready;
   
    
    wire [Dw-1 : 0] qout_data_o;
    wire qout_we_o;
    wire qout_is_ready;
    wire [IN_NUM-1 : 0 ] qout_winner, wr_out_chanel;
    
    wire [Dw-1 : 0 ] pipereg [IN_NUM-1:0]; 
    
  
    wire [ADDRw-1 : 0] rxreq_wr_addr;
    wire [SNPF_ACTw-1: 0] rxreq_wr_action;
    wire [IN_NUM-1:0] valid_o;
    
    assign rxreq_wr_addr=pipereg [0][ADDRw-1 : 0];
    assign rxreq_wr_action = pipereg [0][Dw-2 : Dw-SNPF_ACTw-1];
    
    
    
     
    //write chanel   
    many_to_one_pipereg #(
    	.Dw(Dw),
        .IN_NUM(3),
    	.IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    pipereg_queu
    (
    	.src_id(src_id),
    	.qin_data_in(qin_data_in),
        .qin_we(qin_we),
        .qin_is_ready(qin_is_ready),
        .qin_data_o({pipereg[2],pipereg[1],pipereg[0]}),
        .qin_valid_o(valid_o),
        
        .qout_data_o(qout_data_o),
        .qout_we_o(qout_we_o),
        .qout_is_ready(qout_is_ready),
        .qout_winner(qout_winner),
        .reset(reset),
        .clk(clk)
        
    	
    );
    
    assign  snpf_to_undat_wr_chnl_ready  = qin_is_ready[2];
    assign  snpf_to_rxrsp_wr_chnl_ready  = qin_is_ready[1];
    assign  snpf_to_rxreq_wr_chnl_ready  = qin_is_ready[0];
    
   
     
    wire [ADDRw-1 : 0] snpf_wr_addr;
    wire snpf_wr_en;
    wire snpf_wr_evict;
    wire [SPVw-1 : 0] snpf_wr_spv;
    //wire [STATUSw-1 : 0] snpf_wr_state;
    
    
    wire snpf_wr_hit;
    wire snpf_wr_chnl_ready;
    wire snpf_wr_is_failed;
    wire snpf_re_fill;
    wire [SPVw-1 : 0] snpf_re_fill_wr_spv;
    wire snpf_wr_done;        
   
    wire [ADDRw-1 : 0] snpf_rd_addr;
    wire snpf_rd_en;
    wire [SPVw-1 : 0] snpf_rd_spv;
    wire [STATUSw-1 : 0] snpf_rd_state;
    wire  snpf_rd_ready;    
    wire snpf_rd_hit;
    wire snpf_rd_done;
    wire snpf_rd_busy_bit;
    wire snpf_rd_cnt_acpt_new;
    wire update_state;
    wire [SNPF_ACTw-1: 0] snpf_wr_action;
   
    // manage busy bit read once write pending or in processing
    // The busy bit should be read in atomic manner
    wire atomic_rd_busy;
    /*
    reg busy_detect;
    always @(posedge clk) begin
        if(reset) busy_detect<=1'b0;
        else begin 
		if((snpf_rd_addr[ADDR_REQ-1 : ADRR_OFFSETw] == rxreq_wr_addr[ADDR_REQ-1 : ADRR_OFFSETw]) & (valid_o[0] & snpf_rd_en)) busy_detect<=1'b1; // snpf_to_rxreq_rd_hit must be one next clock cycle busy_bit must be one
		else busy_detect<=1'b0;    
	end
   end
   */
    assign  snpf_rd_addr = rxreq_to_snpf_rd_addr;
    assign  snpf_rd_en = rxreq_to_snpf_rd_en;
    assign  snpf_to_rxreq_spv = snpf_rd_spv;
    assign  snpf_to_rxreq_rd_state = snpf_rd_state ;
    assign  snpf_to_rxreq_rd_ready = snpf_rd_ready ;    
    assign  snpf_to_rxreq_rd_hit = (atomic_rd_busy)? 1'b1 : snpf_rd_hit;
    assign  snpf_to_rxreq_rd_done = snpf_rd_done;   
    assign  snpf_to_rxreq_rd_busy_bit = (atomic_rd_busy)? 1'b1 : snpf_rd_busy_bit ;
    assign  snpf_to_rxreq_rd_cnt_acpt_new =snpf_rd_cnt_acpt_new;
   
    
    
    
     
  wire wr_evict;    
  assign {update_state,snpf_wr_action,wr_evict,snpf_wr_spv, //snpf_wr_state,
  snpf_wr_addr}   = qout_data_o;
  
  assign snpf_wr_evict = qout_we_o & wr_evict;   
  assign snpf_wr_en =  qout_we_o & ~wr_evict;  
  assign qout_is_ready = snpf_wr_chnl_ready; 
     
   
     fwft_fifo #(
     	.DATA_WIDTH(IN_NUM),
     	.MAX_DEPTH(3),
     	.IGNORE_SAME_LOC_RD_WR_WARNING("YES")
     )
     winner_fifo
     (
     	.din(qout_winner),
     	.wr_en(qout_we_o),
     	.rd_en(snpf_wr_done),
     	.dout(wr_out_chanel),
     	.full(), // can mask the input rsp and req ready chanel using this
     	.nearly_full(),
     	.recieve_more_than_0(),
     	.recieve_more_than_1(),
     	.reset(reset),
     	.clk(clk)
     );
     
  
     
    snoop_filter_cache #(
        .VERBOSITY(VERBOSITY),        
    	// .src_id(src_id),
    	.WAY_NUM(WAY_NUM),
    	.STATUSw(STATUSw),
      	.RESET_DELAY(RESET_DELAY),
    	.BLK_SIZ(BLK_SIZ),
    	.SPVw(SPVw),
    	.INDEXw(INDEXw),
    	.ADDRw(ADDRw)
    )
    cache
    (
    	.src_id(src_id),
    	.wr_addr(snpf_wr_addr),
    	.wr_en(snpf_wr_en),
    	.wr_evict(snpf_wr_evict),
    	.wr_spv(snpf_wr_spv),
    //	.wr_state(snpf_wr_state),
    	.wr_ready(snpf_wr_chnl_ready),
    	.wr_update_state(update_state),
    	.wr_action(snpf_wr_action),
    	
    	
    	
    	.wr_hit(snpf_wr_hit),
    	.wr_is_failed(snpf_wr_is_failed),    	
    	.wr_done(snpf_wr_done),
    	
    	.re_fill(snpf_re_fill),
        .re_fill_wr_spv(snpf_re_fill_wr_spv),
    	
    	
    	.rd_addr(snpf_rd_addr),
    	.rd_en(snpf_rd_en),
    	.rd_spv(snpf_rd_spv),
    	.rd_state(snpf_rd_state),
    	.rd_ready(snpf_rd_ready),
    	.rd_hit(snpf_rd_hit),
    	.rd_done(snpf_rd_done),
    	.rd_busy_bit(snpf_rd_busy_bit),
    	.rd_cnt_acpt_new(snpf_rd_cnt_acpt_new),
    	
    	.evbuf_to_rxreq_addr(evbuf_to_rxreq_addr),
        .evbuf_to_rxreq_dat(evbuf_to_rxreq_dat),
        .evbuf_to_rxreq_valid(evbuf_to_rxreq_valid),
        .rxreq_evbuf_rd_en(rxreq_evbuf_rd_en),
    	
    
    	.reset(reset),
    	.clk(clk)
    );
    
    
  
   
     /*
   // wire [1: 0] wr_spv_action, wr_busy_bit_action, wr_sys_cache_action;
  //  assign {wr_sys_cache_action,wr_busy_bit_action,wr_spv_action} =rxreq_to_snpf_action;
    wire rxreq_to_snpf_set_busy = rxreq_to_snpf_action[2:1]  == SNPF_ASSERT;
    wire rxreq_wr_set_busy = rxreq_wr_action [2:1]  == SNPF_ASSERT;
  
    atomic_mem_rd #(
    	.PIPE_NUM(2),
    	.Dw(1),
    	.Aw(ADDRw)
    )
    atomic_busy_rd
    (
    	//input from mem
    	.rd_addr(snpf_rd_addr),
    	.rd_en(snpf_rd_en),
    	.mem_rd_dat(snpf_rd_busy_bit),
    	.rd_dat(atomic_rd_busy),    	
    	
    	.wr_addr_pipe({rxreq_to_snpf_wr_addr,rxreq_wr_addr}),
    	.wr_en_pipe({rxreq_to_snpf_wr_en,valid_o[0]}),
    	.wr_dat_pipe({rxreq_to_snpf_set_busy,rxreq_wr_set_busy}),
    	.clk(clk)
    );
    
    */
    
    //
    
    wire rd_same_way_multiple_times;
    atomic_mem_rd #(
        .PIPE_NUM(2),
        .Dw(1),
        .Aw(INDEXw)
    )
    atomic_busy_rd
    (
        //input from mem
        .rd_addr(snpf_rd_addr[INDEXw+ADRR_OFFSETw-1 : ADRR_OFFSETw]),
        .rd_en(snpf_rd_en),
        .mem_rd_dat(1'b0),
        .rd_dat(rd_same_way_multiple_times),        
        
        .wr_addr_pipe({rxreq_to_snpf_wr_addr[INDEXw+ADRR_OFFSETw-1 : ADRR_OFFSETw],rxreq_wr_addr[INDEXw+ADRR_OFFSETw-1 : ADRR_OFFSETw]}),
        .wr_en_pipe({rxreq_to_snpf_wr_en,valid_o[0]}),
        .wr_dat_pipe(2'b11),
        .clk(clk),
        .reset(reset)
    );
    
    
    
    
    
    reg rd_same_way_multiple_times_delay;
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                rd_same_way_multiple_times_delay<=1'b0;
            end else begin 
                rd_same_way_multiple_times_delay<=rd_same_way_multiple_times;
            end        
    end//always
    
    assign atomic_rd_busy = snpf_rd_busy_bit | rd_same_way_multiple_times  | rd_same_way_multiple_times_delay;
    
    
    
    
    
  assign snpf_to_rxreq_wr_hit = wr_out_chanel[0] &  snpf_wr_hit;
  assign snpf_to_rxreq_wr_is_failed =  wr_out_chanel[0] &  snpf_wr_is_failed;
  assign snpf_to_rxreq_re_fill=  wr_out_chanel[0] & snpf_re_fill;
  assign snpf_to_rxreq_wr_done =  wr_out_chanel[0] & snpf_wr_done;
  
  assign snpf_to_rxreq_re_fill_wr_spv = snpf_re_fill_wr_spv;
  
  
  assign snpf_to_rxrsp_wr_hit = wr_out_chanel[1] &  snpf_wr_hit;
  assign snpf_to_rxrsp_wr_is_failed =  wr_out_chanel[1] &  snpf_wr_is_failed;
  assign snpf_to_rxrsp_re_fill=  wr_out_chanel[1] & snpf_re_fill;
  assign snpf_to_rxrsp_wr_done =  wr_out_chanel[1] & snpf_wr_done;
 
  assign snpf_to_rxrsp_re_fill_wr_spv = snpf_re_fill_wr_spv; 
  
  
  assign snpf_to_undat_wr_hit = wr_out_chanel[2] &  snpf_wr_hit;
  assign snpf_to_undat_wr_is_failed =  wr_out_chanel[2] &  snpf_wr_is_failed;
//  assign snpf_to_undat_re_fill=  wr_out_chanel[2] & snpf_re_fill;
  assign snpf_to_undat_wr_done =  wr_out_chanel[2] & snpf_wr_done;
 
//  assign snpf_to_undat_re_fill_wr_spv = snpf_re_fill_wr_spv; 
  
  
  
  
   //synthesis translate_off 
   //synopsys  translate_off
   always @ (posedge clk) begin 
        if(undat_we & ~snpf_to_undat_wr_chnl_ready) begin 
            $display ( "Error:%t: hnf ( %d )  snoop wr happened by undat while it was not ready yet",$time,src_id);
            $stop;
        end 
        if(rxrsp_we & ~snpf_to_rxrsp_wr_chnl_ready) begin 
             $display ( "Error:%t: hnf ( %d )  snoop wr happened by rxrsp while it was not ready yet",$time,src_id);
             $stop;
        end
        if(rxreq_we & ~snpf_to_rxreq_wr_chnl_ready) begin 
              $display ( "Error:%t: hnf ( %d )  snoop wr happened by rsreq while it was not ready yet",$time,src_id);
              $stop;        
        end
        
        
    end
       
    
    //synopsys  translate_on
    //synthesis translate_on  
   
    
endmodule 






module  snoop_filter_cache#(
    parameter VERBOSITY = 0,
    //parameter src_id=0,
    parameter RESET_DELAY= "IGNORE",   /*
        "IGNORE" : No policy is implemented for resetting the cache valid bits at reset time. Assumption is that the ram is reset externally  
         "MULTI_CLKS": the cache controller reset the entire cache block after  reset assertion. The number of needed clock cycle is equal to cache line number
        */
    parameter SPVw = 32,   
    parameter WAY_NUM = 8,
    parameter STATUSw = 3, 
    parameter BLK_SIZ = 64,    
    parameter INDEXw=10,
    parameter ADDRw=32
   
)(
      
   src_id,   
      
    //rxreq
    wr_addr,
    wr_en,
    wr_evict,
    wr_spv,
  //  wr_state,
    wr_hit,
    wr_ready,
    wr_is_failed,
    wr_done,
    wr_update_state,
    wr_action,
       
    
    rd_addr,
    rd_en,
    rd_spv,
    rd_state,
    rd_hit,
    rd_ready,
    rd_busy_bit,
    rd_done,
    rd_cnt_acpt_new,
    
    evbuf_to_rxreq_addr,
    evbuf_to_rxreq_dat,
    evbuf_to_rxreq_valid,
    rxreq_evbuf_rd_en,       
        
    
    re_fill,
    re_fill_wr_spv,
    
       
    
    reset,     
    clk
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 


//On power-up / reset : clear all valid bits 
    localparam 
        
        RESET_RAM_CONTENT=(RESET_DELAY=="MULTI_CLKS")? "ENABLE" : "NONE";

    localparam 
        OFFSETw = log2(BLK_SIZ), // The address range in cache block
        TAGw = ADDRw - INDEXw - OFFSETw, // the remainig address bits are dedicated as tag
        INFOw  = TAGw +// STATUSw
        + SPVw +2, // 1 bit valid + 1 bit busy
        WAYw = log2(WAY_NUM),
        RAM_Aw = INDEXw;    
        
    // States
    localparam ST_NUM=3;

    localparam [ST_NUM-1 :   0]
        READ = 1,
        WRITE=2,
        EVICT=4;
     
    input [31 : 0] src_id;                   
                   
    //rxreq
    input [ADDRw-1 : 0] wr_addr;
    input wr_en;
    input wr_evict;
    input [SPVw-1 : 0] wr_spv;
 //   input [STATUSw-1 : 0] wr_state;
    input wr_update_state;
    input [SNPF_ACTw-1: 0] wr_action;
   
    
    output wr_hit;
    output wr_ready;
    output reg wr_is_failed;
    output reg re_fill;
    output [SPVw-1 : 0] re_fill_wr_spv;
    output reg wr_done;
        
   
    input [ADDRw-1 : 0] rd_addr;
    input rd_en;
    output[SPVw-1 : 0] rd_spv;
    output[STATUSw-1 : 0] rd_state;
    output rd_busy_bit;
    output rd_ready;
    output rd_hit;
    output reg rd_done;
    output rd_cnt_acpt_new; // once this pins is asserted means a rd miss happens while all the snpf ways were busy and the eviction buffer was full. So this address cannot be accepted to be written in snpf
    
    output [ADDRw-1 : 0]  evbuf_to_rxreq_addr;
    output [SPVw-1 : 0] evbuf_to_rxreq_dat;
    output evbuf_to_rxreq_valid;
    input rxreq_evbuf_rd_en;       
    
    
  
    input reset;
    input clk;
   
    
    
        
    wire [TAGw-1 : 0] tag_in_rd_next, tag_in_wr_next;
    reg  [TAGw-1 : 0] tag_in_wr,tag_in_rd; 
    wire [TAGw-1 : 0] re_fill_wr_tag;
    wire [INDEXw-1 : 0] index_in_rd_next,index_in_wr_next;
    reg  [INDEXw-1 : 0] index_in_wr;
    wire [RAM_Aw-1 : 0] ram_addr_i_rd = index_in_rd_next;
    reg  [RAM_Aw-1 : 0] ram_addr_i_wr;          
   
    reg  [WAY_NUM-1 : 0] ram_we_i_wr;
    reg  [INFOw-1:0] info_ram_in_wr;
    wire [INFOw-1:0] info_array_rd [WAY_NUM-1 : 0];
    wire [INFOw-1:0] info_array_wr [WAY_NUM-1 : 0];    
    wire [TAGw-1: 0] tag_array_rd [WAY_NUM-1 : 0];
    wire [TAGw-1: 0] tag_array_wr [WAY_NUM-1 : 0];    
    //wire [STATUSw-1 : 0] status_array_rd[WAY_NUM-1 : 0];
    //wire [STATUSw-1 : 0] status_array_wr[WAY_NUM-1 : 0];
    wire [WAY_NUM-1 : 0] valid_array_rd, busy_array_rd,valid_array_wr, busy_array_wr;
    
    wire [SPVw-1 : 0] spv_array_rd [WAY_NUM-1 : 0];
    wire [SPVw-1 : 0] spv_array_wr [WAY_NUM-1 : 0];
  
  
    wire [WAY_NUM-1 : 0] compartors_array_rd;
    wire [WAY_NUM-1 : 0] compartors_array_wr;
    wire [WAY_NUM-1 : 0] hit_array_rd;
    wire [WAY_NUM-1 : 0] hit_array_wr;
       
    wire [WAY_NUM-1 : 0] empty_ways_wr,empty_ways_rd;
   
    
    wire [WAY_NUM-1 : 0] ram_not_ready;
   
    reg  [ST_NUM-1 : 0] ps,ns;
    reg random_pos_en;
    wire [WAY_NUM-1 : 0] random_way;
    wire [WAY_NUM-1 : 0] empty_candidate_way_wr;
    wire any_empty_wr,any_empty_rd;
    wire any_non_busy; 
    
    reg wr_done_next;
    
    assign wr_ready = ~ram_not_ready[0] & (ps==READ);
    assign rd_ready = ~ram_not_ready[0];
    
    assign empty_ways_wr = ~ valid_array_wr;
    assign empty_ways_rd = ~ valid_array_rd;
    // decode the input addr
    assign {tag_in_rd_next,index_in_rd_next} = rd_addr[ADDRw-1 : OFFSETw];  
    assign {tag_in_wr_next,index_in_wr_next} = wr_addr[ADDRw-1 : OFFSETw]; 
    
    
    wire [SPVw-1 : 0] new_spv,wr_spv_old;
    reg  [SPVw-1 : 0] wr_spv_delay;
  //  reg  wr_update_state_delay;
    
 //   wire [STATUSw-1 : 0]  new_status;
    wire new_valid =1'b1;
    wire new_busy_bit;
 //   wire [STATUSw-1 : 0] wr_state_old;
    wire busy_bit_old;
  //  reg  [STATUSw-1 : 0]  wr_state_delay;
    reg [SNPF_ACTw-1: 0] wr_action_delay;
    
    
    wire [1: 0] wr_spv_action, wr_busy_bit_action, wr_sys_cache_action;
    wire evb_rd_hit;
    assign {wr_sys_cache_action,wr_busy_bit_action,wr_spv_action} =wr_action_delay;
    
    wire refill_is_allowed;
    
    always @(posedge clk) begin 
        tag_in_wr  <= tag_in_wr_next; 
        index_in_wr<= index_in_wr_next;
 //       wr_state_delay <=  wr_state;
        wr_spv_delay <=  wr_spv;
        wr_action_delay <= wr_action;  
   //     wr_update_state_delay <= wr_update_state; 
        
        if(rd_en) tag_in_rd<= tag_in_rd_next;
    end   
        
   
    assign new_spv [SPVw-2 : 0]=
        (wr_spv_action== SNPF_REPLACE)? wr_spv_delay [SPVw-2 : 0]  : 
        (wr_spv_action== SNPF_NO_CHANGE)? wr_spv_old [SPVw-2 : 0]  :
        (wr_spv_action== SNPF_CLEAR)? wr_spv_old [SPVw-2 : 0]& ~(wr_spv_delay[SPVw-2 : 0]):
        wr_spv_old [SPVw-2 : 0]| wr_spv_delay [SPVw-2 : 0]; //ASSERT
        
        
    assign new_spv[SPVw-1] =
        (wr_sys_cache_action == SNPF_ASSERT)? 1'b1 :
        (wr_sys_cache_action == SNPF_CLEAR)? 1'b0 :   wr_spv_old [SPVw-1];
      
   
    assign new_busy_bit =
        (wr_busy_bit_action == SNPF_ASSERT)? 1'b1 :
        (wr_busy_bit_action == SNPF_CLEAR )? 1'b0 : busy_bit_old;
   
   
    reg new_cache_block;
 //   assign new_status =
 //       (wr_update_state_delay)? wr_state_delay :
  //      (new_cache_block)?  SNPF_I :
  //      wr_state_old;
        
   
   //wr st 
    always @(*)begin 
        ns=ps;
        random_pos_en=1'b0;
        info_ram_in_wr={INFOw{1'b0}};//default for evict
        ram_we_i_wr={WAY_NUM{1'b0}};
        re_fill=1'b0;
        wr_is_failed=1'b0;
        wr_done_next=0;
	    ram_addr_i_wr=index_in_wr_next;// default for read in write chanel. addr directly gotton from input     
        new_cache_block=1'b0;
        case(ps)  
        READ: begin 
            if(wr_en) begin 
                ns=  WRITE;
            end  
            if(wr_evict) begin 
                ns= EVICT;            
            end
        end 
        WRITE:begin   
            ram_addr_i_wr =  index_in_wr;  // take it now from register to write  
            info_ram_in_wr={new_valid,new_busy_bit,
            //new_status,
            new_spv,tag_in_wr};
            wr_done_next = 1'b1;
            if(~wr_hit) new_cache_block=1'b1;
            if(wr_hit) begin // This cache exists inside the memory rewrite the new data
                ram_we_i_wr=hit_array_wr;           
            end 
            // this is a new cache data  
            else if (any_empty_wr) begin // select random way to rxreq_to_snpfwr_evict
                ram_we_i_wr=empty_candidate_way_wr;              
            end else begin  // all ways are full select one random loc to evict 
                random_pos_en=1'b1;
                ram_we_i_wr=random_way;  
                if(any_non_busy & refill_is_allowed) re_fill=1'b1;
                else wr_is_failed=1'b1;
            end
             ns=  READ;
        end    
        EVICT:begin  
            ram_addr_i_wr =  index_in_wr;  // take it now from register to write  
            wr_done_next = 1'b1;
            if(wr_hit) begin // This cache exists inside the memory rewrite the new data
                ram_we_i_wr=hit_array_wr;           
            end 
            ns=  READ;
        end        
        endcase    
    end
    
   
        
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            ps<= READ;
            rd_done<=1'b0;
            wr_done <= 1'b0;
         
        end else begin 
            ps<=ns;
            rd_done <= rd_en;
            wr_done <= wr_done_next;           
        end        
    end
    
    
    // The address which is selected to be refill must not be busy. We dont select the last read location as it may be in wr queue 
    reg [RAM_Aw-1 : 0] rx_req_ram_addr [1:0];
    reg [WAY_NUM-1 : 0] rx_req_rd_hit_array1;
    wire [WAY_NUM-1 : 0] rx_req_rd_hit_array0 = hit_array_rd;
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
            rx_req_ram_addr [0]<=0;
            rx_req_ram_addr [1]<=0;
            rx_req_rd_hit_array1<=0;
            end else begin 
            if(rd_en)rx_req_ram_addr[0] <=ram_addr_i_rd;
            if(rd_en)rx_req_ram_addr[1] <=rx_req_ram_addr[0];
            if(rd_en)rx_req_rd_hit_array1 <= rx_req_rd_hit_array0;
            end        
    end//always
    
      //  .addr_b(ram_addr_i_rd),
     //   .rd_en_b(rd_en),
    
    wire [WAY_NUM-1 : 0]  mask_random_req0 = (ram_addr_i_wr == rx_req_ram_addr[0])? ~rx_req_rd_hit_array0 :  {WAY_NUM{1'b1}};
    wire [WAY_NUM-1 : 0]  mask_random_req1 = (ram_addr_i_wr == rx_req_ram_addr[1])? ~rx_req_rd_hit_array1 :  {WAY_NUM{1'b1}};
    
    wire [WAY_NUM-1 : 0] random_way_req = ~ busy_array_wr & mask_random_req0 & mask_random_req1;
  
    
    
    // select one not busy way to randomly evict,  once all ways are full;  
    arbiter_priority_en #(
        .ARBITER_WIDTH(WAY_NUM)
    )
    rnd_arbiter
    (
        .request(random_way_req),
        .grant(random_way),
        .any_grant(any_non_busy ), 
        .clk(clk),
        .reset(reset),
        .priority_en(random_pos_en)
    );
    
        
    
    //select one empty way to write
    fixed_priority_arbiter #(
        .ARBITER_WIDTH(WAY_NUM),
        .HIGH_PRORITY_BIT("LSB")
    )
    arbiter
    (
        .request(empty_ways_wr),
        .grant(empty_candidate_way_wr),
        .any_grant(any_empty_wr)
    );    
    
    assign any_empty_rd = |empty_ways_rd;
    genvar i;
    generate 
    for (i=0; i<WAY_NUM; i=i+1)begin:way
      
      /*
      cache_dual_port_ram #(
        .Dw(INFOw),
        .Aw(INDEXw),
        .RESET_RAM_CONTENT(RESET_RAM_CONTENT),
        .BYTE_WR_EN("NO"),
        .INITIAL_EN("NO")      
      )
       info_cache_ram
       (
        //write
        .data_a(info_ram_in_wr),        
        .addr_a(ram_addr_i_wr),
        .byteen_a(),
        .we_a(ram_we_i_wr[i]),
        .q_a(info_array_wr[i]),
      
         //read
        .data_b( ),
        .addr_b(ram_addr_i_rd),
        .byteen_b(),      
        .we_b(1'b0),
        .q_b(info_array_rd[i] ),
        
        .clk(clk),
      
        
        .reset(reset),
        .not_ready(ram_not_ready[i])
      );
       */
       
       snpf_ram #(
        .Dw(INFOw),
        .Aw(INDEXw)
       )
       ram
       (
       //chanel a . rd & wr
       	.wr_dat_a(info_ram_in_wr),
       	.addr_a(ram_addr_i_wr),
       	.wr_en_a(ram_we_i_wr[i]),
       	.rd_dat_a(info_array_wr[i]),
       	
       //chanel b rd only	
       	.rd_dat_b(info_array_rd[i]),
       	.addr_b(ram_addr_i_rd),
       	.rd_en_b(rd_en),
       	
       	.clk(clk),
       	.reset(reset),
       	.not_ready(ram_not_ready[i])
       );
        
      
     
      assign {valid_array_rd[i],busy_array_rd[i],//status_array_rd[i],
      spv_array_rd[i], tag_array_rd[i]} = info_array_rd[i];
      assign compartors_array_rd[i] = tag_array_rd[i] == tag_in_rd;
      assign hit_array_rd[i] = compartors_array_rd[i] & valid_array_rd[i];
      
      assign {valid_array_wr[i],busy_array_wr[i],//status_array_wr[i],
      spv_array_wr[i], tag_array_wr[i]} = info_array_wr[i];
      assign compartors_array_wr[i] = tag_array_wr[i] == tag_in_wr;     
      
      assign hit_array_wr[i] = compartors_array_wr[i] & valid_array_wr[i];   
            
    end  
    endgenerate  
   
  
   
    wire [WAYw-1 : 0] hit_binary_rd,refilled_way_binary,hit_binary_wr;
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(WAY_NUM),
        .BIN_WIDTH(WAYw)
    )
    encoder_rd
    (
        .one_hot_code(hit_array_rd),
        .bin_code(hit_binary_rd)
    );
    
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(WAY_NUM),
        .BIN_WIDTH(WAYw)
    )
    encoder_wr
    (
        .one_hot_code(hit_array_wr),
        .bin_code(hit_binary_wr)
    );
       
   
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(WAY_NUM),
        .BIN_WIDTH(WAYw)
    )
    encoder_refill
    (
        .one_hot_code(random_way),
        .bin_code(refilled_way_binary)
    );
   
//we are reading an address while it has write pending request that try to assert the busy bit. we need to bypass the ram in this condition 
    reg bypass_busy_bit;
    always @(posedge clk) begin
       bypass_busy_bit  <= (({tag_in_rd_next,index_in_rd_next} ==  {tag_in_wr,index_in_wr}) & wr_done_next & (wr_busy_bit_action == SNPF_ASSERT) & rd_en );  
    end


    wire  valid_rd = (| hit_array_rd);   
    assign rd_spv = (valid_rd)? spv_array_rd[hit_binary_rd] : 0;
    //assign rd_state = (valid_rd)? state_array_rd[hit_binary_rd] : 0;
    //check how many RNs host this cache line 
   
    wire more_than_one_share;
    wire no_one_shares;
   
    check_num_asseted_bits #(
    	.Dw(SPVw-1)
    )
    check_num
    (
    	.n(rd_spv [SPVw-2: 0]),
    	.has_no_bit_asserted(no_one_shares),
    	.has_one_bit_asserted(),
    	.has_more_than_one_bit_asserted(more_than_one_share)
    );
      
  
    assign rd_state = 
        (~valid_rd)? SNPF_I:
        (no_one_shares) ? SNPF_I:
        (more_than_one_share)? SNPF_S :SNPF_U;
    
    
    
    assign re_fill_wr_spv = spv_array_wr [refilled_way_binary];
    assign re_fill_wr_tag = tag_array_wr [refilled_way_binary];
    
    
    
    assign rd_hit = (bypass_busy_bit| evb_rd_hit)? 1'b1: valid_rd; 
    assign rd_busy_bit = (bypass_busy_bit | evb_rd_hit)? 1'b1:  busy_array_rd[hit_binary_rd] & valid_rd;
     
    wire nearly_full,full;//its asserted once the evb is nearly full/full
    wire more_than_one_non_busy,not_enogh_empty_way,not_enogh_non_busy,more_than_one_non_empty;

   
    check_num_asseted_bits #(
        .Dw(WAY_NUM)
    )
    check_empty
    (
        .n(empty_ways_rd),
        .has_no_bit_asserted(),
        .has_one_bit_asserted(),
        .has_more_than_one_bit_asserted( more_than_one_non_empty )
    );
    
    assign not_enogh_empty_way =  ~more_than_one_non_empty;
    
    check_num_asseted_bits #(
        .Dw(WAY_NUM)
    )
    check_busy
    (
        .n(~busy_array_rd),
        .has_no_bit_asserted(),
        .has_one_bit_asserted(),
        .has_more_than_one_bit_asserted(more_than_one_non_busy )
    );
    assign not_enogh_non_busy = ~more_than_one_non_busy;
    
   
    assign rd_cnt_acpt_new = (~valid_rd & not_enogh_empty_way ) & (not_enogh_non_busy |  nearly_full);  
     //The snpf cannot accept the rd value to be written on its cache buffer once the following condtion happens:
    // ~valid_rd: The RD is not getting a hit. So it needs to be written to an empty or non-busy way location if it wants to be written later
    // not_enogh_empty_way: There is no empty location so it needs to be refilled.
    //  & not_enogh_non_busy: all ways are busy so non-of them can be refilled. 
    //  the refill buffer may becomes full at write time so we cannot accept a refill.  
      
    assign wr_spv_old =  spv_array_wr[hit_binary_wr];    
  //  assign wr_state_old = status_array_wr[hit_binary_wr];
    assign busy_bit_old = busy_array_wr[hit_binary_wr];
    
    
    
    
    assign wr_hit = | hit_array_wr;      
    wire [ADDRw-1 : 0] refill_addr;    
    assign refill_addr ={re_fill_wr_tag, index_in_wr,{OFFSETw{1'b0}}};
    
    wire evb_wr = wr_en & ~ wr_evict;
    
    assign refill_is_allowed = ~full;
    
   
    
    //make sure that data is existed in at least one snopee
    wire re_fill_en = re_fill & ( |re_fill_wr_spv[SPVw-2: 0]);
    
   
   
     eviction_buffer #(
     	.VERBOSITY(VERBOSITY),        
         //.src_id(src_id),
        .B(4),
        .Dw(SPVw),
        .Aw(ADDRw)
     )
     evbf
     (     	
     	
     	.src_id(src_id),
     	.rd_addr(rd_addr),
        .rd_hit(evb_rd_hit),
        .rd_en(rd_en),
     	
     	//send refill data to eviction buffer 
     	//refill
        .refill_addr(refill_addr),
        .refill_en(re_fill_en), //TODO need to check full signal before writting to snpf
        .refill_dat(re_fill_wr_spv),
     	.full(full),
     	.nearly_full(nearly_full),
     	
     	//evict
     	.evict_addr(wr_addr),
     	.evict_en(wr_evict),
     	.evict_hit( ),
     	
     	//check that write addr dose not exist in evb buf
     	.wr_addr(wr_addr),
     	.wr_en(evb_wr),
     	
     	//req
     	.evbuf_to_rxreq_addr(evbuf_to_rxreq_addr),
     	.evbuf_to_rxreq_dat(evbuf_to_rxreq_dat),
     	.evbuf_to_rxreq_valid(evbuf_to_rxreq_valid),
     	.rxreq_evbuf_rd_en(rxreq_evbuf_rd_en),
     	
     	
     	
     	.reset(reset),
     	.clk(clk)
     );
    
    
    
    
    //synthesis translate_off 
    //synopsys  translate_off
  
    
    wire [WAYw-1 : 0] wr_way;
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(WAY_NUM),
        .BIN_WIDTH(WAYw)
    )
    cn
    (
        .one_hot_code(ram_we_i_wr),
        .bin_code(wr_way)
    );
    
    
    reg  [ADDRw-1 : 0] wr_addr_reg;
   // wire [2 :0] st =   new_status;
    wire [31 : 0] busy = (new_busy_bit) ? "BUSY": "FREE";
  /*
    wire [15 : 0] st_str = 
        (st == SNPF_I )? " I" : 
        (st == SNPF_U )? " U" : 
        (st == SNPF_S )? " S" : " X";
  */ 
    always @(posedge clk)begin 
        if( wr_en) wr_addr_reg<= wr_addr;
        if(ram_we_i_wr) begin 
            if((VERBOSITY &  MONITORE_SNPF) > 0) begin 
               $display ("%t: hnf ( %d ) snpf addr ( %d ) in ram line ( %d ) way num ( %d ) is updated with status ( %s ) and spv ( %b )",$time, src_id, wr_addr_reg, ram_addr_i_wr,wr_way,busy, new_spv);
            end
        end
        if(ram_not_ready[0] && (wr_en | rd_en) ) begin 
            $display("%t: Error: hnf ( %d )  a cache read or write command is recived while the cache was not ready yet",$time, src_id);
            $stop;
        end
        if(wr_is_failed)begin 
            $display("%t: Error: hnf ( %d ) snpf write is failed on addr ( %d )",$time, src_id,wr_addr_reg);
            $stop;
        end
    end
    
    
    
    //check busy bit is ckered and asserted correctly
    always @(posedge clk)begin 
        if((ps== EVICT) && wr_hit && (busy_bit_old == 1'b1) && (ram_we_i_wr>0)) begin 
            $display("%t: Error: hnf ( %d ) snpf evictinig a busy way on addr ( %d )",$time, src_id,wr_addr_reg);
            $stop;
        end
        
        if((ps== WRITE) && wr_hit && (ram_we_i_wr>0) && (busy_bit_old == 1'b1) && (wr_busy_bit_action == SNPF_ASSERT)) begin 
            $display("%t: Error: hnf ( %d ) snpf got busy assert command while busy bit was asserted before on addr ( %d )",$time, src_id,wr_addr_reg);
            $stop;
        end
        if((ps== WRITE) && wr_hit && (ram_we_i_wr>0) && (busy_bit_old == 1'b0) && (wr_busy_bit_action ==  SNPF_CLEAR )) begin 
            $display("%t: Error: hnf ( %d ) snpf got busy clear command while busy bit was not asserted before on addr ( %d )",$time, src_id,wr_addr_reg);
            $stop;
        end
    
    end
    
    //synthesis translate_on 
    //synopsys  translate_on
   
 
endmodule 




module  snpf_ram #(
    parameter Dw=32, 
    parameter Aw=12    
)
(
   
   // chanel a
    wr_dat_a,
    addr_a,
    wr_en_a,   
    rd_dat_a,
   
    // chanel b 
    rd_dat_b, 
    addr_b,
    rd_en_b,
    
    //general
    clk,
    reset,
    not_ready
      
);   

    //chanel a
    input [Dw-1  :   0] wr_dat_a;
    input [Aw-1  :   0] addr_a;
    input wr_en_a;   
    output [Dw-1  :   0]rd_dat_a;
    
    // chanel b 
    output [Dw-1  :   0] rd_dat_b;
    input  [Aw-1  :   0] addr_b;
    input rd_en_b;
    
    //general
    input clk,  reset;
    output not_ready;
   
    
    reg [Aw-1: 0] counter,counter_next;
    reg busy,busy_next;
    wire [Dw-1 : 0] ram_data_a;
    wire [Aw-1:0] ram_addr_a;
    wire ram_we_a;    
    
    assign not_ready = busy;
    
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            counter <= {Aw{1'b0}};
            busy<= 1'b1;
        end else begin 
            counter <= counter_next;
            busy<= busy_next;
        end        
    end
        
    always @(*) begin
        counter_next = counter;
        busy_next = busy;
        if(busy) counter_next = counter +1'b1;
        if(counter=={Aw{1'b1}}) busy_next = 1'b0;
    end

   assign ram_data_a = (busy)? {Dw{1'b0}}: wr_dat_a;
   assign ram_addr_a= (busy)? counter : addr_a;
   assign ram_we_a= (busy)? 1'b1 : wr_en_a;


   // memory
   reg [Dw-1:0] queue [2**Aw-1:0]; 
   reg [Dw-1:0] mem_rd_data;
      
    //port a
    always @(posedge clk ) begin
        if (ram_we_a) queue[ram_addr_a] <= ram_data_a;
        mem_rd_data <= queue[ram_addr_a];
    end 

    assign rd_dat_a = mem_rd_data;

    //port b
    reg [Dw-1:0] mem_rd_dat_b;
    always @(posedge clk ) begin
        if (rd_en_b) mem_rd_dat_b <= queue[addr_b];
    end 

    assign rd_dat_b = mem_rd_dat_b;


//synthesis translate_off 
//synopsys  translate_off
integer k;
initial begin
    for (k = 0;k<2**Aw;k=k+1) queue[k]=k+1;
end


//synthesis translate_on 
//synopsys  translate_on




/*
    generic_dual_port_ram #(
        .Dw(Dw),
        .Aw(Aw),
        .BYTE_WR_EN(BYTE_WR_EN),
        .INITIAL_EN(INITIAL_EN),
        .INIT_FILE(INIT_FILE)
    )
    generic_dual_port_ram(
        .data_a(ram_data_a),
        .data_b(data_b),
        .addr_a(ram_addr_a),
        .addr_b(addr_b),
        .byteena_a(byteen_a),
        .byteena_b(byteen_b),
        .we_a(ram_we_a),
        .we_b(we_b),
        .clk(clk),
        .q_a(q_a),
        .q_b(q_b)
    );

  */  

endmodule


//only non busy filed are moved to this buffer So there would not be any read from rxrsp agent from this buffer
module eviction_buffer #(
    parameter VERBOSITY=0,
  //  parameter src_id=0,
    parameter B=4,
    parameter Dw=32,
    parameter Aw=32
)
(
    src_id,
    // The busy bit should be asserted once a req is waiting for eviction upon rd_hit assertaion
    rd_addr,
    rd_hit,
    rd_en,


    //refill will write on evication buffer. The refill addr adress should not exist 
    refill_addr,
    refill_en,
    refill_dat,
   
        
    //evict : eviction is asserted once   snoop response got invalidate response from all  RNs
    evict_addr, 
    evict_en,
    evict_hit, 
    
    // The addr of data written to snpf.     
    wr_addr, 
    wr_en,   
    
    
    //rxreq
    evbuf_to_rxreq_addr, 
    evbuf_to_rxreq_dat,
    evbuf_to_rxreq_valid,
    rxreq_evbuf_rd_en,   
   
    full,
    nearly_full,
    
    reset,
    clk


);


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
    
    localparam Bw=log2(B);

    input [31 : 0] src_id;
    
    input [Aw-1 : 0] refill_addr;
    input refill_en;
    input [Dw-1 : 0] refill_dat;
   
       
   
    input [Aw-1 : 0]  evict_addr;
    input evict_en;
    output  evict_hit;
    
    input [Aw-1 : 0]  wr_addr; 
    input wr_en;
    
    
    output reg [Aw-1 : 0]  evbuf_to_rxreq_addr;
    output reg [Dw-1 : 0] evbuf_to_rxreq_dat;
    output evbuf_to_rxreq_valid;
    input rxreq_evbuf_rd_en;       
    
    output full,nearly_full;
    input reset,clk;
    
    
    input [Aw-1 : 0] rd_addr;
    output reg rd_hit;
    input rd_en;
    
   
   
    reg [Aw-1 : 0] addr [B-1 : 0];
    reg [Dw-1 : 0] buff [B-1 : 0];
    reg [Aw-1 : 0] addr_next [B-1 : 0];
    reg [Dw-1 : 0] buff_next [B-1 : 0];
    wire [B-1 : 0] candidate_wr,evict_matched,rd_matched;

    reg [B-1 :0] valid,valid_next;
    reg [B-1 :0] rxreq_valid;
    reg [B-1 :0] rxreq_valid_assert,rxreq_valid_reset;
    
   // assign full = &valid;
    
    wire more_than_one;
    
    check_num_asseted_bits #(
        .Dw(B)
    )
    check_valid
    (
        .n(~valid),
        .has_no_bit_asserted(full),
        .has_one_bit_asserted(),
        .has_more_than_one_bit_asserted( more_than_one)
    );
    
    assign nearly_full = ~more_than_one;
   
   // the rd_hit is asserted once the addr exists inside the buffer or its going to be refill 
    wire rd_hit_next = (|rd_matched) | ((rd_addr == refill_addr) & refill_en )  ;
    
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                rd_hit <= 1'b0;
            end else begin 
               if(rd_en) rd_hit <= rd_hit_next;
            end        
    end//always
    
    
    wire [B-1 : 0]  empty_list = ~valid;
    
    arbiter #(
        .ARBITER_WIDTH(B)
    )
    refill_arbiter
    (
        .request(empty_list),
        .grant(candidate_wr),
        .any_grant(),
        .clk(clk),
        .reset(reset)
    );
    
    
    wire [B-1 :0] candidate_req;
    wire [Bw-1 : 0] candidate_req_bin;
  //  wire [Bw-1 : 0] candidate_req_bin_next;
    
    arbiter_priority_en #(
        .ARBITER_WIDTH(B)
    )
    req_arbiter
    (
        .request(rxreq_valid),
        .grant(candidate_req),
        .any_grant(evbuf_to_rxreq_valid),
        .clk(clk),
        .reset(reset),
        .priority_en(rxreq_evbuf_rd_en)
    );
    
  
    
     
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(4)
    )
    conv
    (
        .one_hot_code(candidate_req),
        .bin_code(candidate_req_bin)
    );
     
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                 evbuf_to_rxreq_addr <= 0;
                 evbuf_to_rxreq_dat  <= 0;  
            end else begin 
              if(rxreq_evbuf_rd_en)begin 
                 evbuf_to_rxreq_addr <= addr[candidate_req_bin];
                 evbuf_to_rxreq_dat  <= buff[candidate_req_bin];  
              end 
            end        
    end//always 
  
    
   
    
    assign evict_hit = evict_en & ( |evict_matched);
    
    
    
    genvar i;
    generate
        for (i = 0; i < B; i = i + 1) begin : block
        
            assign evict_matched[i]= (addr[i] == evict_addr) & valid[i];
            assign rd_matched[i] = (addr[i] == rd_addr) & valid[i];
        
            always @(*) begin
                buff_next[i] = buff[i];
                addr_next[i] = addr[i];
                valid_next[i]= valid[i];
                rxreq_valid_assert[i]=1'b0;
                rxreq_valid_reset[i]=1'b0;
                if(refill_en & candidate_wr[i]) begin 
                    buff_next[i] = refill_dat; 
                    addr_next[i] = refill_addr;
                    valid_next[i]= 1'b1;
                    rxreq_valid_assert[i]=1'b1;
                end                                
                else if(evict_en & evict_matched[i]) begin 
                    valid_next[i]= 1'b0; 
                    rxreq_valid_reset[i]=1'b1;
                end
                
            end//always
        
        
        
            always @(posedge clk or posedge reset) begin
                if(reset)begin 
                    addr[i] <= {Aw{1'b0}};
                    buff[i] <= {Dw{1'b0}};
                    valid[i]<= 1'b0;
                end else begin 
                    addr[i] <= addr_next[i];
                    buff[i] <= buff_next[i];
                    valid[i]<= valid_next[i];
                end        
            end//always
            
             always @(posedge clk or posedge reset) begin
                if(reset) rxreq_valid[i] = 1'b0;
                else begin 
                    if(rxreq_valid_assert[i])rxreq_valid[i] = 1'b1;
                    else if(rxreq_valid_reset[i]) rxreq_valid[i] = 1'b0;
                    else if(candidate_req[i] & rxreq_evbuf_rd_en) rxreq_valid[i] = 1'b0;
                end        
            end//always
            
            
        end
    endgenerate
    
     
     
     
  
    //synthesis translate_off 
    //synopsys  translate_off
    wire [B-1 : 0] wr_matched;
    wire [B-1 : 0] refill_matched;
    
    
    generate
        for (i = 0; i < B; i = i + 1) begin : b2
        
            assign refill_matched[i]= (addr[i] == refill_addr) & valid[i];
            assign wr_matched[i]= (addr[i] == wr_addr) & valid[i];   
             
        end
    endgenerate    
    
    wire refill_hit = (|refill_matched) & refill_en; 
    wire wr_hit = (| wr_matched) & wr_en;
    reg a;
     always @(posedge clk) begin
        a<= evbuf_to_rxreq_valid &  rxreq_evbuf_rd_en;
        if(refill_en & refill_hit)begin 
              $display("%t: Error: SPF ( %d ) received write req for an address waiting to be evicted: %d",$time,src_id,refill_addr);
              $stop;
        end
        if(refill_en & full )begin 
            $display("%t: Error: EVB ( %d ) received write req on addr ( %d ) while it was full we need to send reject response which is not supported yet",$time,src_id,refill_addr);
            $stop;
        end
        
        if(wr_hit) begin 
            $display("%t: Error: EVB ( %d ) received a write req on addr ( %d ) while it was quequed for eviction. The busy bit had to be asserted once reading from snoop filter",$time,src_id,wr_addr);
            $stop;
        end
        
        if (~evbuf_to_rxreq_valid & rxreq_evbuf_rd_en) begin
            $display("%t: Error: EVB ( %d ) received ack while valid req was not asserted",$time,src_id);
            $stop;
        end
        
        
        
        if((VERBOSITY & MONITORE_SNPF) > 0)begin
            if(evict_hit)  $display("%t: EVB ( %d )  addr ( %d ) is evicted from eviction buffer",$time,src_id,evict_addr);
            if(a ) $display("%t: EVB ( %d ) will send invalidate snoop req to addr ( %d )",$time,src_id,evbuf_to_rxreq_addr);
            if(refill_en ) $display("%t: EVB ( %d ) refill buffer is written on addr ( %d )",$time,src_id,refill_addr);   
        end
        
    end
    
     
          
    //synthesis translate_on 
    //synopsys  translate_on
    
   
    
    
   



endmodule



