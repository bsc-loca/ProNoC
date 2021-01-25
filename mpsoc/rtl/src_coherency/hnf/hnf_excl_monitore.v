/**************************************
* Module: hnf_excl_monitore
* Date:2019-09-03  
* Author: alireza     
*
* Description: 
* The hnf exclusive_monitor can tag one address for each phisical processor in the system that supports exclusive accesses. 
* When a processor performs a Load-Exclusive to a Shareable location, the global monitor tags the accessed address for exclusive
* use by that processor. The following events reset the global monitor entry for processor N to open state:
*
* processor N performs an exclusive load from a different location
* a different processor successfully performs a Store-Exclusive, to the location tagged for exclusive use by processor N.
* 
* use Additional address  monitore + plus minimum single-bit monitor
***************************************/

module  hnf_excl_monitor #(
    parameter VERBOSITY=4, // The higher the VERBOSITY the higher details are printed in simuation terminal
   // parameter src_id=0,
    parameter LP_NUM =32, // Maximum number of phisical processors with allowable excluse access 
    parameter TAG_ADRw=10 // address tag width. The exclusive address is partiall registred
)(
    src_id,   
    reset,
    clk,
    read_fifo_en,
    next_lp_bin_addr,
    next_tag_addr,
    next_exl_load_en,
    next_exl_store_en,
    excl_result,// 1: success 0:fail
    re_try
);
   
    
     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
        
  localparam LPw = log2(LP_NUM);      

  input [31 : 0] src_id;   
   
  input reset, clk;
  input [LPw-1 : 0] next_lp_bin_addr;
  input [TAG_ADRw-1 : 0] next_tag_addr;
  input next_exl_load_en,  next_exl_store_en;
  input re_try;
  input read_fifo_en;
  output  excl_result;
    
    
    
  
    
   wire exl_load_en  =   next_exl_load_en  &  read_fifo_en;
   wire exl_store_en =   next_exl_store_en &  read_fifo_en;
    
    
    
    
/* based on AMBA CHI specefication
An Exclusive Store transaction is permitted to progress if one of the following occurs:
    • The address monitor has registered an exclusive sequence for a matching address from the same LP and has
      not been reset by an Exclusive Store transaction from a different LP with a matching address.
    • The minimum single-bit monitor has been set by an exclusive sequence from the same LP, and it has not been
      reset by an Exclusive Store transaction from a different LP to any address.
*/
    
    
    wire excl_result1, excl_result2;
    
    minimum_single_bit_monitor #(
        .VERBOSITY(VERBOSITY),
        //.src_id(src_id),
    	.LP_NUM(LP_NUM)
    )
    single_bit_monitor
    (
    	.src_id(src_id),
    	.lp_bin_addr(next_lp_bin_addr),
    	.exl_load_en(exl_load_en),
    	.exl_store_en(exl_store_en),
    	.reset(reset),
    	.clk(clk),
    	.re_try(re_try),
    	.excl_result(excl_result1)
    );
   

    address_monitor #(
    	.LP_NUM(LP_NUM),
    	.TAG_ADRw(TAG_ADRw)
    )
    the_address_monitor
    (
    	.lp_bin_addr(next_lp_bin_addr),
    	.reset(reset),
    	.clk(clk),
    	.re_try(re_try),
    	.exl_load_en(exl_load_en),
    	.exl_store_en(exl_store_en),
    	.tag_addr(next_tag_addr),
    	.excl_result(excl_result2)
    );

    assign excl_result = excl_result1 | excl_result2;


endmodule


module minimum_single_bit_monitor #(
    parameter VERBOSITY=4,
    //parameter src_id=0,
    parameter LP_NUM=32

)(
    src_id,   
    lp_bin_addr,
    exl_load_en,
    exl_store_en,
    excl_result,
    re_try,
    reset,clk

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

    localparam LPw = log2(LP_NUM);      
 
     input [31 : 0] src_id;   
 
    input [LPw-1 : 0] lp_bin_addr;
    input exl_load_en,    exl_store_en;
    input reset,clk;
    input re_try;
    
    output reg excl_result;
    
    
    wire  [LP_NUM-1 : 0] lp_one_hot_addr;
    
    bin_to_one_hot #(
    	.BIN_WIDTH(LPw),
    	.ONE_HOT_WIDTH(LP_NUM)
    )
    convert
    (
    	.bin_code(lp_bin_addr),
    	.one_hot_code(lp_one_hot_addr)
    );
    
    
    reg excl_result_next;

    reg [LP_NUM-1 : 0] single_bit_monitor_reg,single_bit_monitor_next,single_bit_monitor_reg_backup;
    wire [LP_NUM-1 : 0 ] single_bit_monitor;
    
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                single_bit_monitor_reg<= {LP_NUM{1'b0}};
                single_bit_monitor_reg_backup<={LP_NUM{1'b0}};
                excl_result<=1'b0;
            end else begin 
                single_bit_monitor_reg<= single_bit_monitor_next;
                if(~(re_try)) single_bit_monitor_reg_backup <= single_bit_monitor_reg;
                excl_result<=excl_result_next;
            end        
    end//always


  assign   single_bit_monitor = (re_try)? single_bit_monitor_reg_backup : single_bit_monitor_reg;


    always @(*) begin
        single_bit_monitor_next = single_bit_monitor;
        if(exl_load_en)  single_bit_monitor_next = single_bit_monitor | lp_one_hot_addr;
      //  if(exl_store_en) single_bit_monitor_next = single_bit_monitor & lp_one_hot_addr;
        
        excl_result_next = excl_result; 
        if(exl_load_en) excl_result_next=1'b1;
        if(exl_store_en) begin 
            // exclusive access of this LP is registred and it has not been reset by an Exclusive Store transaction from another LP, then the Exclusive Store transaction is successful
            if((single_bit_monitor & lp_one_hot_addr) != {LP_NUM{1'b0}}  )begin 
                excl_result_next=1'b1;//successful
                single_bit_monitor_next = single_bit_monitor & lp_one_hot_addr;
            //exclusive access of this LP is not registred, that is, it has been reset by an Exclusive Store from another LP, then the Exclusive Store transaction is failed    
           end else excl_result_next=1'b0;
        end
    end
    
//synthesis translate_off 
//synopsys  translate_off
generate
if((VERBOSITY & MONITORE_EXCL_TXN) > 0) begin :monitor
   reg [LP_NUM-1 : 0 ] single_bit_monitor_old;

    always @(posedge clk) begin 
       single_bit_monitor_old <= single_bit_monitor;
       if(single_bit_monitor_old != single_bit_monitor)  $display("%t: hnf ( %d ) exl single_bit_monitor_reg=%b \n",$time,src_id,single_bit_monitor );
    end
end
endgenerate
 
//synthesis translate_on 
//synopsys  translate_on




endmodule

module address_monitor  #(
    parameter LP_NUM=32,
    parameter TAG_ADRw=10 // the exclusive address is partiall registred
)(
    lp_bin_addr,
    tag_addr,
    exl_load_en,
    exl_store_en,
    excl_result,
    re_try,
    reset,clk
);

     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 

    localparam LPw = log2(LP_NUM);
    
    input reset,clk;
    input exl_load_en , exl_store_en;
    input [TAG_ADRw-1 : 0] tag_addr;
    input [LPw-1 : 0 ] lp_bin_addr;
    output reg excl_result;
    input re_try;

 reg [LP_NUM-1 : 0] valid,valid_next;
 reg [TAG_ADRw-1 : 0 ] addr_regs [LP_NUM-1 : 0];
 reg [TAG_ADRw-1 : 0 ] addr_regs_next [LP_NUM-1 : 0];
 reg excl_result_next;
 
 
 reg exl_load_en_reg , exl_store_en_reg;
 reg [LPw-1 : 0 ] lp_bin_addr_reg;
 reg [TAG_ADRw-1 : 0 ] tag_addr_reg;
 
 always @(posedge clk or posedge reset) begin
         if(reset)begin 
            exl_load_en_reg <=1'b0; 
            exl_store_en_reg<=1'b0;
            lp_bin_addr_reg<={LPw{1'b0}};
            tag_addr_reg <= {TAG_ADRw{1'b0}};
         end else begin 
            exl_load_en_reg <= exl_load_en; 
            exl_store_en_reg<= exl_store_en;
            lp_bin_addr_reg <= lp_bin_addr;
            tag_addr_reg<= tag_addr;
         end        
 end//always
 
 
 genvar i;
 generate
     for (i = 0; i < LP_NUM; i = i + 1) begin : block
         
        always @(posedge clk or posedge reset) begin
         if(reset)begin 
            addr_regs[i] <= {TAG_ADRw{1'b0}};
            valid[i] <= 1'b0;
         end else begin 
            addr_regs[i] <= addr_regs_next[i];
            valid[i] <= valid_next[i];
         end        
        end//always
         
         
        always @(*) begin
            addr_regs_next[i] = addr_regs[i];
            valid_next[i]=valid[i];
            if((exl_load_en_reg | exl_store_en_reg ) & (lp_bin_addr_reg == i) & (~re_try)) begin 
                addr_regs_next[i] = tag_addr_reg;
                valid_next[i] = 1'b1;
            end
             
            else if ((exl_store_en_reg & excl_result & (~re_try)) & (addr_regs[i] == tag_addr_reg ) & (lp_bin_addr_reg != i)) begin 
                addr_regs_next[i] = {TAG_ADRw{1'b0}};
                valid_next[i] = 1'b0;
            end
      
         end            
         
         
     end //for
 endgenerate
 
   
 
 
 
    always @(*) begin
        excl_result_next = excl_result;
        if (exl_load_en ) excl_result_next=1'b1;
        if (exl_store_en) begin 
            if ((addr_regs[lp_bin_addr] == tag_addr) &  valid[lp_bin_addr] ) excl_result_next=1'b1;
            else excl_result_next=1'b0;
        end      
    end//always
 
 
 
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                excl_result<=1'b0;
            end else begin 
                excl_result<=excl_result_next;
                
            end        
    end//always


endmodule






module  hnf_exl_tag_addr_extract #(
        parameter EXCL_TAG_ADRw =10,
        parameter ADDR_REQ=44,
        parameter CACHE_BLK_SIZ=64,
        parameter NUM_OF_HNs=32
        
)(
    next_req_addr,
    next_excl_tag_addr    
);

    input [ADDR_REQ-1 : 0] next_req_addr;  
    output [EXCL_TAG_ADRw-1 : 0] next_excl_tag_addr;

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

     localparam 
        LOW_OFFSETw = log2(CACHE_BLK_SIZ),        // The address range in cache block
      //  BLK_ADDRw = RAW_ADDR_SIZ - OFFSETw,
        HNF_ADDRw = log2(NUM_OF_HNs),
        HIGH_OFFSETw = ADDR_REQ - HNF_ADDRw - LOW_OFFSETw,
        STEPw= HIGH_OFFSETw/EXCL_TAG_ADRw;


       
        wire [HIGH_OFFSETw-1 : 0] high_offset_addr;       
        assign high_offset_addr = next_req_addr[ADDR_REQ-1 :   LOW_OFFSETw+HNF_ADDRw];
        
        
        // select tag address from input address. 
        genvar i;
        generate
            for (i = 0; i < EXCL_TAG_ADRw; i = i + 1) begin : block
                assign next_excl_tag_addr[i] = high_offset_addr[i*STEPw]; 
            end
        endgenerate

endmodule


module rnf_lpid_addr_decode #(
        parameter NUM_OF_RNs= 15,
        parameter LPw=5,
        parameter LP_IDw = 5,            
        parameter RNF_IDw=8,
        parameter MAX_EXCL_LP_PER_RN=2 // must be pow of 2
)(
        rnf_id_i,
        lpid_in_rnf_i,
        lp_bin_addr_o
);

    input [RNF_IDw-1 : 0] rnf_id_i;
    input [LP_IDw-1 : 0 ] lpid_in_rnf_i;
    output [LPw-1 : 0] lp_bin_addr_o;
    
     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
    
    localparam 
        MAX_LP_PER_RNw =   log2(MAX_EXCL_LP_PER_RN),
        RNF_NUMw=log2(NUM_OF_RNs);
            
    
    wire [MAX_LP_PER_RNw-1 : 0] local_lpid = lpid_in_rnf_i [MAX_LP_PER_RNw-1 : 0];
    wire [NUM_OF_RNs-1 : 0] rnf_num_one_hot;
    wire [RNF_NUMw-1 : 0] rnf_num;
 
    rnfid_to_spv_addr_decode #(
        .SPVw(NUM_OF_RNs),
        .IDw(RNF_IDw)
    )
    one_hot_addr_decode
    (
        .rnf_id_i(rnf_id_i),
        .rnf_spv_o(rnf_num_one_hot)
    );
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(NUM_OF_RNs),
        .BIN_WIDTH(RNF_NUMw)
    )
    to_bin
    (
        .one_hot_code(rnf_num_one_hot),
        .bin_code(rnf_num)
    );
       
    
    assign lp_bin_addr_o = {rnf_num , local_lpid};

endmodule







/*
 module rnf_lpid_addr_decode #(
        parameter LP_IDw = 5,            
        parameter RNF_IDw=8,
        parameter RNF_SPVw=16,
        parameter MAX_EXCL_LP_PER_RN=2 // Its better to be multiplcation of two
)(
        rnf_id_i,
        lpid_in_rnf_i,
        lp_one_hot_o
);

    localparam LP_ONE_HOTw = MAX_EXCL_LP_PER_RN * RNF_SPVw;

    input  [RNF_IDw-1 : 0] rnf_id_i;
    input  [LP_IDw-1 : 0 ] lpid_in_rnf_i;
    output [LP_ONE_HOTw-1 : 0] lp_one_hot_o;
    
    function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
    localparam MAX_LP_PER_RNw = log2(MAX_EXCL_LP_PER_RN);
    
    wire [MAX_LP_PER_RNw-1 : 0] local_lpid = lpid_in_rnf_i [MAX_LP_PER_RNw-1 : 0];
    
    wire [RNF_SPVw-1 : 0] rnf_spv_o;
    rnfid_to_spv_addr_decode #(
        .SPVw(RNF_SPVw),
        .IDw(RNF_IDw)
    )
    rnfid_to_spv_addr_decode(
        .rnf_id_i(rnf_id_i),
        .rnf_spv_o(rnf_spv_o)
    );
    
    
    one_hot_demux #(
        .IN_WIDTH(RNF_SPVw),
        .SEL_WIDTH(MAX_LP_PER_RNw),
        .OUT_WIDTH(LP_ONE_HOTw)
    )
    one_hot_demux(
        .demux_sel(local_lpid),
        .demux_in(rnf_spv_o),
        .demux_out(lp_one_hot_o)
    );
endmodule
*/


