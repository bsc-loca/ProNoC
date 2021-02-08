/**************************************
* Module: hnf_data_process
* Date:2019-10-15  
* Author: alireza     
*
* Description: 
* This module is loacted before undat module. 
* It can recieves data from both syscache & rxdat chanel.
* It perform data manupulation according to rxdat command: atomic instruction/ partial merge etc
* Sends data to undat  
***************************************/
module  hnf_data_process #(
   parameter MIN_SIZ=32,
   parameter VERBOSITY =0,
  // parameter src_id = 0,
   parameter SNPF_SPVw=5
   
)(
    src_id,   
     
    //rxreq
    rxreq_to_undat_wr, 
    rxreq_to_undat_dat, 
    rxreq_to_undat_txnid,
    undat_to_rxreq_ready,  
    rxreq_to_undat_action,
    rxreq_to_undat_addr,
    rxreq_to_undat_cache_evict,
    rxreq_to_undat_tgtid, 
    rxreq_to_undat_dbid, 
    rxreq_to_undat_opcode, 
    rxreq_to_undat_resp, 
    rxreq_to_undat_resperr, 


    //rxdat
    undat_to_rxdat_ready,  
    rxdat_to_undat_dat,  
    rxdat_to_undat_wr,  
    rxdat_to_undat_tgtid, 
    rxdat_to_undat_txnid, 
    rxdat_to_undat_dbid, 
    rxdat_to_undat_resp, 
    rxdat_to_undat_resperr,
    rxdat_to_undat_opcode,
    rxdat_to_undat_action,
    rxdat_to_undat_addr,
    rxdat_to_undat_cache_wr,
    rxdat_to_undat_txnid_release, 
    rxdat_to_undat_snpf_update,
    
    
    //txdat
    txdat_to_undat_ready,
    undat_to_txdat_dat,
    undat_to_txdat_wr,
    undat_to_txdat_tgtid,
    undat_to_txdat_txnid,
    undat_to_txdat_dbid,
    undat_to_txdat_resp,
    undat_to_txdat_resperr,
    undat_to_txdat_opcode,
    
    //snpf
    undat_to_snpf_wr_addr, 
    undat_to_snpf_wr_en, 
    undat_to_snpf_wr_evict, 
    undat_to_snpf_wr_spv, 
   // undat_to_snpf_wr_state, 
    undat_to_snpf_update_state, 
    undat_to_snpf_action,  
    
    
    snpf_to_undat_wr_hit, 
    snpf_to_undat_wr_chnl_ready, 
    snpf_to_undat_wr_is_failed, 
    snpf_to_undat_wr_done,  
    
    
    
    //write on cache     
    undat_to_cache_wr_addr, 
    undat_to_cache_wr_data, 
    undat_to_cache_wr_evict, 
    undat_to_cache_wr_state, 
    undat_to_cache_wr_en, 
    cache_to_undat_wr_hit,     
    cache_to_undat_wr_ready, 
    cache_to_undat_wr_done,  
    
   //txgen
    undat_to_txgen_txnid, 
    undat_to_txgen_txnid_release,
    txgen_to_undat_ready,
    
    
    
    
    //general
    reset,clk

);


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"  
    
    input [31 : 0] src_id;   
    input reset,clk;
    
    //rxreq
    output undat_to_rxreq_ready;  
    input rxreq_to_undat_wr; 
    input  [DATA_DAT-1  : 0] rxreq_to_undat_dat;
    input  [TXNID_REQ-1 : 0] rxreq_to_undat_txnid;  
    input  [DU_ACTw-1 : 0] rxreq_to_undat_action;
    input [ADDR_REQ-1 : 0] rxreq_to_undat_addr;
    input  rxreq_to_undat_cache_evict;
    input [TGTID_DAT-1:0]rxreq_to_undat_tgtid;
    input [TXNID_DAT-1:0]rxreq_to_undat_dbid;
    input [OPCODE_DAT-1 : 0]rxreq_to_undat_opcode;
    input [RESP_DAT-1 : 0] rxreq_to_undat_resp;
    input [RESPERR_DAT-1 : 0] rxreq_to_undat_resperr;
    
    
                 
    //rxdat
    output undat_to_rxdat_ready;
    input  [DATA_DAT-1 : 0] rxdat_to_undat_dat;
    input  rxdat_to_undat_wr;
    input  [TGTID_REQ-1:0]           rxdat_to_undat_tgtid;
    input  [TXNID_REQ-1:0]           rxdat_to_undat_txnid;
    input  [TXNID_REQ-1:0]  rxdat_to_undat_dbid;
    input  [RESP_DAT-1 : 0] rxdat_to_undat_resp;
    input  [RESPERR_DAT-1 : 0] rxdat_to_undat_resperr;
    input  [OPCODE_DAT-1 : 0] rxdat_to_undat_opcode;
    input  [DU_ACTw-1 : 0] rxdat_to_undat_action;
    input  [ADDR_REQ-1 :0  ] rxdat_to_undat_addr;
    input rxdat_to_undat_cache_wr;
    input rxdat_to_undat_txnid_release;
    input rxdat_to_undat_snpf_update; 


    //tx_dat
    input  txdat_to_undat_ready;
    output reg [DATA_DAT-1 : 0] undat_to_txdat_dat;
    output reg undat_to_txdat_wr;
    output [TGTID_REQ-1:0]           undat_to_txdat_tgtid;
    output [TXNID_REQ-1:0]           undat_to_txdat_txnid;
    output [TXNID_REQ-1:0]  undat_to_txdat_dbid;
    output [RESP_DAT-1 : 0] undat_to_txdat_resp;
    output [RESPERR_DAT-1 : 0] undat_to_txdat_resperr;
    output [OPCODE_DAT-1 : 0] undat_to_txdat_opcode;
    
    
    
    //chache_wr
    output  [ADDR_REQ-1 :0  ] undat_to_cache_wr_addr;
    output  [DATA_DAT-1 : 0] undat_to_cache_wr_data;
    output  [CACHE_STATUSw-1:0] undat_to_cache_wr_state;
    output  reg undat_to_cache_wr_en;
    output  reg undat_to_cache_wr_evict;
    input cache_to_undat_wr_hit;
    input cache_to_undat_wr_done;
    input cache_to_undat_wr_ready;
    
    
    //txgen
    output [TXNID_REQ-1:0]   undat_to_txgen_txnid;
    output reg undat_to_txgen_txnid_release;
    input txgen_to_undat_ready;

   
   //snpf
    output  [ADDR_REQ-1 : 0] undat_to_snpf_wr_addr;
    output reg undat_to_snpf_wr_en;
    output  undat_to_snpf_wr_evict;
    output  [SNPF_SPVw-1 : 0] undat_to_snpf_wr_spv;
  //  output  [CACHE_STATUSw-1 : 0] undat_to_snpf_wr_state;
    output  undat_to_snpf_update_state;
    output [SNPF_ACTw-1:0] undat_to_snpf_action;
  
    
    input snpf_to_undat_wr_hit;
    input snpf_to_undat_wr_chnl_ready;
    input snpf_to_undat_wr_is_failed;
    input snpf_to_undat_wr_done;   
   


   

    // register-based fifo, with two wr port and one read 
    localparam  Dw = DATA_DAT+  TGTID_REQ + TXNID_REQ + TXNID_REQ + RESP_DAT + RESPERR_DAT + OPCODE_DAT + DU_ACTw +   ADDR_REQ + 4;
    wire [Dw-1 :0 ] din1 = {
            rxreq_to_undat_cache_evict,
            1'b0, //snpf_busy_clear
            1'b0, //txnid_release
            rxreq_to_undat_cache_evict, //cache_wr,
            rxreq_to_undat_tgtid, 
            rxreq_to_undat_txnid, 
            rxreq_to_undat_resp, 
            rxreq_to_undat_resperr,
            rxreq_to_undat_opcode,
            rxreq_to_undat_addr,
            rxreq_to_undat_action, 
            rxreq_to_undat_dat,
            rxreq_to_undat_dbid};
    wire [Dw-1 : 0] din2 = {   
            1'b0,//cache_evict
            rxdat_to_undat_snpf_update,
            rxdat_to_undat_txnid_release,
            rxdat_to_undat_cache_wr,            
            rxdat_to_undat_tgtid, 
            rxdat_to_undat_txnid, 
            rxdat_to_undat_resp, 
            rxdat_to_undat_resperr,
            rxdat_to_undat_opcode,
            rxdat_to_undat_addr,
            rxdat_to_undat_action,
            rxdat_to_undat_dat,
            rxdat_to_undat_dbid};
    wire [Dw-1 : 0] current_dout;
    wire [TXNID_REQ-1:0] next_txnid;
   
    
    wire fifo_nearly_full;
    reg fifo_rd_en;
    wire empty;
    
    
    //3:64 2:32 1:16 0:8
    wire [2: 0] size = 3; 
    
    
    
    fifo_two_wr_port #(
    	.Dw(Dw),
    	.SDw(TXNID_REQ), 
    	.B(4)
    )
    buffer
    (
    	.din1(din1),
    	.wr_en1(rxreq_to_undat_wr),
    	.din2(din2),
    	.wr_en2(rxdat_to_undat_wr),
    	.full( ),
    	.nearly_full(fifo_nearly_full),
    	.rd_en(fifo_rd_en),
    	.dout(current_dout),
    	.sdout(next_txnid),
    	.empty(empty),
    	.reset(reset),
    	.clk(clk)
    );
    
    
    
    
    assign undat_to_rxreq_ready = ~fifo_nearly_full;
    assign undat_to_rxdat_ready = ~fifo_nearly_full;
    wire fifo_has_dat = ~empty;

    wire  snpf_update;
    wire  txnid_release;
    wire  cache_wr;
    wire  cache_evict;
    wire  [ADDR_REQ-1 :0  ] addr;
    
    wire  [DATA_DAT-1 : 0 ] lkpt_txn_rd_dat;
    wire  [DATA_DAT-1 : 0]  current_txn_rd_dat;
    wire  [TGTID_REQ-1: 0] tgtid;
    wire  [TXNID_REQ-1: 0] txnid;
    wire  [TXNID_REQ-1: 0] dbid;
    wire  [RESP_DAT-1 : 0] resp;
    wire  [RESPERR_DAT-1: 0] resperr;
    wire  [OPCODE_DAT-1 : 0] opcode;
    wire  [DU_ACTw-1 : 0]  action;
     
    
    wire [DU_CORE_ACTw-1 : 0] core_action;
    wire [ALU_OPTw-1 : 0]  opt;
    wire init_flag; // a one bit flag indicates which of the current or lkpt data us the initial dat 

    wire  [CACHE_BLK_SIZ_BIT-1 : 0 ] lkpt_txn_wr_dat;
    reg lkpt_txn_wr_en;
    
    
    
    
    //pipeline registrs
    reg [CACHE_BLK_SIZ_BIT-1 : 0] init_dat;
    reg [63:0] init_dat64,txndat64;
    reg [63:0] mask;
    reg pipe_reg_wr_en,pipe_reg_rd_en;
    wire pipe_reg_valid;
    
   
    reg  cache_wr_pipe,txnid_release_pipe,cache_evict_pipe,snpf_update_pipe;
    reg  [ADDR_REQ-1 :0  ] addr_pipe;   
    reg  [TGTID_REQ-1: 0] tgtid_pipe;
    reg  [TXNID_REQ-1: 0] txnid_pipe;
    reg  [TXNID_REQ-1: 0] dbid_pipe;
    reg  [RESP_DAT-1 : 0] resp_pipe;
    reg  [RESPERR_DAT-1: 0] resperr_pipe;
    reg  [OPCODE_DAT-1 : 0] opcode_pipe;
    reg  [ALU_OPTw-1 : 0]  opt_pipe;
    reg  [DU_CORE_ACTw-1 : 0] core_action_pipe;
    
      
    
    assign {cache_evict,snpf_update,txnid_release,cache_wr,tgtid, txnid, resp, resperr, opcode,addr, action,  current_txn_rd_dat, dbid} = current_dout;
    assign {init_flag,core_action,opt} = action;

// This lookup table store data for up to 256 transactions.

    transaction_lookup_table #(
        .TXN_DATAw(CACHE_BLK_SIZ_BIT),
        .TXN_IDw(TXNID_REQ),
        .RD_DURING_WR("NEW_DAT")
    )
    lkpt
    (
        .txn_wr_addr(dbid_pipe),//This is home node txnid
        .txn_wr_dat(lkpt_txn_wr_dat),
        .txn_wr_en(lkpt_txn_wr_en),
        
        .txn_rd_addr(next_txnid),// read txn one cycle before reading actual data
        .txn_rd_dat(lkpt_txn_rd_dat),
       
        .txn_rd_en(fifo_rd_en),
        .clk(clk)
    ); 

   

    wire [63 : 0] lkpt_dat,current_dat;
    
    //8:1 mux
    binary_mux #(
    	.IN_WIDTH(512),
    	.OUT_WIDTH(64)
    )
    lkpt_mux
    (
    	.mux_in(lkpt_txn_rd_dat),
    	.mux_out(lkpt_dat),
    	.sel(addr[5:3])
    );

   
    binary_mux #(
        .IN_WIDTH(CACHE_BLK_SIZ_BIT),
        .OUT_WIDTH(64)
    )
    current_mux
    (
        .mux_in(current_txn_rd_dat),
        .mux_out(current_dat),
        .sel(addr[5:3])
    );

    
    
    //convert to 64 bit to be proceesable with alu
    wire [63 : 0] lkpt_dat64,current_dat64;
    
    conv_to_64_bit #(
    	.MIN_SIZ(MIN_SIZ)
    )
    lkpt_conv
    (
    	.in(lkpt_dat),
    	.out(lkpt_dat64),
    	.size(size),
    	.addr(addr[2:0])
    );
    
    

    conv_to_64_bit #(
        .MIN_SIZ(32)
    )
    current
    (
        .in(current_dat),
        .out(current_dat64),
        .size(size),
        .addr(addr[2:0])
    );
    

 wire [63: 0]mask_in;
 alu_64_to_512_mask_gen #(
        .MIN_SIZ(MIN_SIZ)
    )
    mask_gen
    (
        .addr(addr[5:0]),
        .size(size),// .size(3'b011),
        .mask(mask_in)
    );


     
     //synthesis translate_off 
     //synopsys  translate_off
         always @(posedge clk) begin
            if( pipe_reg_wr_en  & ~ pipe_reg_rd_en & pipe_reg_valid  )begin 
                $display(" %t: ERROR: Attempt to write to pipereg once its not consumed yet: %m",$time);
                $stop;
            end    
            if(~ pipe_reg_wr_en &   pipe_reg_rd_en & ~pipe_reg_valid )begin 
                $display(" %t: ERROR: Attempt to read an empty pipereg: %m",$time);
                $stop;
            end
        end
     
     //synthesis translate_on 
     //synopsys  translate_on
    
    
    //The last core_action bit indicate if the initial data is sored in lkpt or current dat
    always @(posedge clk) begin
        if(pipe_reg_wr_en) begin 
            init_dat    <= (init_flag==LKPT_IS_INIT)? lkpt_txn_rd_dat : current_txn_rd_dat;
            init_dat64  <= (init_flag==LKPT_IS_INIT)? lkpt_dat64      : current_dat64;
            txndat64    <= (init_flag==LKPT_IS_INIT)? current_dat64   : lkpt_dat64;
            mask <=mask_in;
            opt_pipe<=opt;
            cache_wr_pipe<=cache_wr;
            cache_evict_pipe<=cache_evict;
            snpf_update_pipe<=snpf_update;
            txnid_release_pipe<=txnid_release;
            addr_pipe<=  addr;
            tgtid_pipe<= tgtid;
            txnid_pipe<= txnid;
            dbid_pipe<=  dbid;
            resp_pipe<=  resp;
            resperr_pipe<= resperr;
            opcode_pipe<= opcode;
            core_action_pipe<=core_action;
        end
    end



//alu
    wire [63 : 0 ] alu_dout64;
    dat_alu_64_bit 
    alu
    (
        .init_dat(init_dat64),
        .txn_dat(txndat64),
        .opt(opt_pipe),
        .out(alu_dout64)       
    );


//merge alu with initil dat

wire    [CACHE_BLK_SIZ_BIT-1: 0 ] alu_dout,repeated_alu_dout64;

assign repeated_alu_dout64 = {8{alu_dout64}};

genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin : block
        assign alu_dout[(i+1)* 8-1 : i*8] =(mask[i])? repeated_alu_dout64[(i+1)* 8-1 : i*8] : init_dat [(i+1)* 8-1 : i*8]; 
    end
endgenerate

assign lkpt_txn_wr_dat = alu_dout;

// state machin
    localparam IDEAL=1;
    localparam PROCESS_REQ=2;
    
    reg [1:0] pst;
    reg [1:0] nst; 

  


   wire qin_is_ready;
   
 
    pipereg_ctrl #(
    	.IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    ctrl
    (
    	.qin_we(pipe_reg_wr_en),
    	.qin_is_ready(qin_is_ready),
    	.qin_valid_o(pipe_reg_valid),
    
        .qin_rd_en(pipe_reg_rd_en),    
     
    	.reset(reset),
    	.clk(clk)
    );
 
  
   //if next_id== txnid or txnid_pipe== next_txnid, we have to wait until lkpt becomes updated   
    wire  hazard;
    reg possible_consequative_txn;
     always @(posedge clk) begin
        if(reset) begin          
             pst <= IDEAL;
             possible_consequative_txn<=1'b0;
        end  else begin 
             pst<=nst;
             if(qin_is_ready) possible_consequative_txn<=   fifo_rd_en  ;
           
        end
    end
   
 
    wire cond1 = possible_consequative_txn & (txnid ==next_txnid);
    wire cond2 = pipe_reg_valid & ( txnid_pipe== next_txnid);
    assign hazard = cond1  | cond2 ;
    
    
    
    
    always @(*)begin  
        fifo_rd_en=1'b0;
        pipe_reg_wr_en=1'b0;
        nst =pst;
        case(pst)
        IDEAL: begin 
            if(fifo_has_dat  & ~hazard )begin 
                nst=PROCESS_REQ;
                fifo_rd_en=1'b1;            
            end        
        end 
        PROCESS_REQ: begin 
            if( qin_is_ready   )begin 
                pipe_reg_wr_en=1'b1;
                if(fifo_has_dat & ~hazard)   fifo_rd_en=1'b1; else nst=IDEAL;                        
            end//txrsp_to_rxsnp_ready
        end
       endcase 
    end      



    //txdat
    assign undat_to_txdat_tgtid = tgtid_pipe ;
    assign undat_to_txdat_txnid = txnid_pipe;
    assign undat_to_txdat_dbid  = dbid_pipe;
    assign undat_to_txdat_resp  = resp_pipe;
    assign undat_to_txdat_resperr = resperr_pipe;
    assign undat_to_txdat_opcode = opcode_pipe;
    
    //txgen
    assign undat_to_txgen_txnid = txnid_pipe;
    

     //cache
    assign undat_to_cache_wr_addr = addr_pipe;
    assign undat_to_cache_wr_data = alu_dout;
    assign undat_to_cache_wr_state = CACHE_UC;//its not important. The state will be obtained using snpf result
   
    
    //snpf
    assign undat_to_snpf_wr_addr = addr_pipe;
    assign undat_to_snpf_wr_evict = 1'b0; // evict is only generated for eviction buff and is handled by dat/rsprx.
    assign undat_to_snpf_wr_spv = {SNPF_SPVw{1'b0}};// spv is updated  only by rsprx;
//    assign undat_to_snpf_wr_state = SNPF_I;
    assign undat_to_snpf_update_state = 1'b0; 

    wire [1: 0] wr_spv_action,wr_busy_bit_action, wr_sys_cache_action;
    assign  wr_spv_action = SNPF_NO_CHANGE;  
    assign  wr_busy_bit_action = (undat_to_txgen_txnid_release)? SNPF_CLEAR  :SNPF_NO_CHANGE;
    assign  wr_sys_cache_action = 
        (undat_to_cache_wr_evict)? SNPF_CLEAR :
        (undat_to_cache_wr_en)?    SNPF_ASSERT: SNPF_NO_CHANGE;
    
    
    assign undat_to_snpf_action = {wr_sys_cache_action,wr_busy_bit_action,wr_spv_action};  
   



    wire cache_ready =  (cache_wr_pipe)?  cache_to_undat_wr_ready : 1'b1;
    wire txngen_ready = (txnid_release_pipe)?  txgen_to_undat_ready : 1'b1;
    wire snpf_ready = (cache_wr_pipe | txnid_release_pipe)? snpf_to_undat_wr_chnl_ready  : 1'b1;
    wire ready = cache_ready & txngen_ready & snpf_ready;

   
   



    always @(*)begin       
        lkpt_txn_wr_en=1'b0;
        undat_to_txdat_wr=1'b0;
        undat_to_txdat_dat = alu_dout;
        undat_to_cache_wr_en=1'b0;
        undat_to_cache_wr_evict=1'b0;
        undat_to_txgen_txnid_release=1'b0;
        undat_to_snpf_wr_en= 1'b0;
        pipe_reg_rd_en=1'b0;
       
        
        if(pipe_reg_valid )begin
            case(core_action_pipe) 
            SAVE_ALU_TX_OFF: begin                 
                if(ready )begin 
                    lkpt_txn_wr_en=1'b1;
                    undat_to_cache_wr_en=cache_wr_pipe;
                    undat_to_cache_wr_evict=cache_evict_pipe;
                    undat_to_txgen_txnid_release=txnid_release_pipe;
                    undat_to_snpf_wr_en=(cache_wr_pipe | txnid_release_pipe) & snpf_update_pipe;
                     
                    pipe_reg_rd_en=1'b1;
                end   
            end
            SAVE_ALU_TX_DIN: begin 
                if(txdat_to_undat_ready & ready)begin
                    undat_to_cache_wr_en=cache_wr_pipe;
                    undat_to_cache_wr_evict=cache_evict_pipe;
                    undat_to_snpf_wr_en=cache_wr_pipe;
                    undat_to_txgen_txnid_release=txnid_release_pipe & snpf_update_pipe;
                    lkpt_txn_wr_en=1'b1;
                    undat_to_txdat_wr=1'b1;//tx on
                    undat_to_txdat_dat = init_dat;
                    
                    pipe_reg_rd_en=1'b1;
                end 
            end
            SAVE_ALU_TX_ALU: begin 
                if(txdat_to_undat_ready & ready)begin
                    undat_to_cache_wr_en=cache_wr_pipe;
                    undat_to_cache_wr_evict=cache_evict_pipe;
                    undat_to_txgen_txnid_release=txnid_release_pipe;
                    undat_to_snpf_wr_en=(cache_wr_pipe | txnid_release_pipe) & snpf_update_pipe;
                    lkpt_txn_wr_en=1'b1;
                    undat_to_txdat_wr=1'b1;//tx on                   
                    pipe_reg_rd_en=1'b1;
                end  
            end
            default : begin 
                lkpt_txn_wr_en=1'b0;
                undat_to_txdat_wr=1'b0;
                undat_to_txdat_dat = alu_dout;
                undat_to_cache_wr_en=1'b0;
                undat_to_cache_wr_evict=1'b0;
                undat_to_txgen_txnid_release=1'b0;
                undat_to_snpf_wr_en= 1'b0;
                pipe_reg_rd_en=1'b0;            
            end
            
            endcase
             
        end
    end//always


   
   
   


    //synthesis translate_off 
    //synopsys  translate_off
    reg [159:0] core_str;
    always @(*)begin
        core_str= "UNDEFF";
        case(core_action_pipe)
        SAVE_ALU_TX_OFF :  core_str= "SAVE_ALU_TX_OFF"; 
        SAVE_ALU_TX_DIN :  core_str= "SAVE_ALU_TX_DIN"; 
        SAVE_ALU_TX_ALU :  core_str= "SAVE_ALU_TX_ALU"; 
        endcase
    end
    
    reg [47: 0] alu_str;
    always @(*) begin
        alu_str = "UNDEF";
        case(opt_pipe)
        ALU_ADD:     alu_str = "ADD  ";
        ALU_CLR:     alu_str = "CLR  "; 
        ALU_EOR:     alu_str = "EOR  "; 
        ALU_SET:     alu_str = "SET  "; 
        ALU_SMAX:    alu_str = "SMAX ";
        ALU_SMIN:    alu_str = "SMIN ";
        ALU_UMAX:    alu_str = "USMAX";
        ALU_UMIN:    alu_str = "USMIN";
        ALU_SWAP:    alu_str = "SWAP ";
        ALU_BPASS:   alu_str = "BPASS";
        endcase
    end
    
    reg [79: 0 ]init_str;
    always @(posedge clk) begin
        init_str <= (init_flag==LKPT_IS_INIT)? "LKPT" : "CURRENT";
        if((VERBOSITY & MONITORE_DAT_ALU) >0 ) begin 
           if(pipe_reg_rd_en)   $display("%t: hnf ( %d ) txn ( %d ) DU:%s,%s, %s is initial, cache_wr %d, cache_evict %d, alu ( %h ), ",$time,src_id,txnid_pipe ,core_str,alu_str,init_str,cache_wr_pipe,undat_to_cache_wr_evict,alu_dout); 
          
        end
    end
    
    
    always @ (posedge clk) begin 
        if(undat_to_snpf_wr_en & ~snpf_to_undat_wr_chnl_ready)begin 
            $display ( "%t: hnf ( %d ) txn ( %d ) error snoop wr happens while it was not ready yet",$time,src_id,txnid_pipe);
            $stop;
        end               
    end
    
    
    //synopsys  translate_on
    //synthesis translate_on 


endmodule





module conv_to_64_bit #(
    parameter MIN_SIZ=32 //32,16,8

)(
    in,
    out,
    size,
    addr
);


   input   [63:0] in;
   output  [63:0] out;
   input   [2: 0] size;
   input   [2: 0] addr; // start addr. we have totaly 8 bytes


 //we need to find the most & list significent bit
    reg [5: 0]msb,lsb;
    genvar i;
    wire msb_val= in[msb];
    generate 
    if(MIN_SIZ==8) begin: min8
    
        always @(*) begin
            msb=63; 
            lsb=0;
            case(size)
            3'b000:        //1 byte
                case(addr)
                3'd0:  begin   msb = 7; lsb= 0; end
                3'd1:  begin   msb =15; lsb= 8; end  
                3'd2:  begin   msb =23; lsb=16; end  
                3'd3:  begin   msb =31; lsb=24; end  
                3'd4:  begin   msb =39; lsb=32; end  
                3'd5:  begin   msb =47; lsb=40; end  
                3'd6:  begin   msb =55; lsb=48; end  
                3'd7:  begin   msb =63; lsb=56; end  
                default: begin msb =63; lsb= 0; end
                endcase
                
            3'b001:       // 2 bytes
                 case(addr)
                 3'd0:  begin   msb =15; lsb= 0; end
                 3'd2:  begin   msb =31; lsb=16; end
                 3'd4:  begin   msb =47; lsb=32; end
                 3'd6:  begin   msb =63; lsb=48; end 
                 default: begin msb =63; lsb= 0; end
                 endcase
            3'b010:       //  4 bytes
                 case(addr)
                 3'd0: begin msb = 31; lsb=0;end
                 3'd4: begin msb = 63; lsb=32;end
                 endcase                        
            default: begin msb=63;   lsb=0;end
                /*
                3'b011:       //  8
                
                3'b100:         16
                3'b101:         32
                3'b110:         64
                */
            endcase
        end
        
    end else if (MIN_SIZ==16) begin :min16
        
         always @(*) begin
            msb=63; 
            lsb=0;
            case(size)                        
            3'b001:       // 2 bytes
                 case(addr)
                 3'd0:  begin   msb =15; lsb= 0; end
                 3'd2:  begin   msb =31; lsb=16; end
                 3'd4:  begin   msb =47; lsb=32; end
                 3'd6:  begin   msb =63; lsb=48; end 
                 default: begin msb =63; lsb= 0; end
                 endcase
            3'b010:       //  4 bytes
                 case(addr)
                 3'd0: begin msb = 31; lsb=0;end
                 3'd4: begin msb = 63; lsb=32;end
                 endcase                        
            default: begin msb=63;   lsb=0;end
                /*
                3'b011:       //  8
                
                3'b100:         16
                3'b101:         32
                3'b110:         64
                */
            endcase
        end
    
    
    
    end else begin:min32
    
    
        always @(*) begin
            msb=63; 
            lsb=0;
            case(size)                        
            3'b010:       //  4 bytes
                 case(addr)
                 3'd0: begin msb = 31; lsb=0;end
                 3'd4: begin msb = 63; lsb=32;end
                 endcase                        
            default: begin msb=63;   lsb=0;end
                /*
                3'b011:       //  8
                
                3'b100:         16
                3'b101:         32
                3'b110:         64
                */
            endcase
        end
    
    
    
    end
    
       
        for (i = 0; i < 64; i = i + 1) begin : block
            assign out[i]= (lsb>i)? 1'b0 : (msb<i)?  msb_val : in[i];       
        end
    
    
    
    
    endgenerate

endmodule


module alu_64_to_512_mask_gen #(
    parameter MIN_SIZ=32 //32,16,8
)(
    addr,
    size,
    mask
);


   
    input [5: 0 ]addr;
    input [2: 0 ]size;
    output [63 : 0] mask;
    reg  [7 : 0] local_mask;
    reg  [7 : 0] mask_gen [7:0];

    generate 
    if(MIN_SIZ==8) begin: min8


        always @(*) begin
            local_mask=8'h00;
            case(size)
            3'b000:        //1 byte
                case(addr[2:0])
                3'd0:  begin   local_mask[0]=1'b1; end
                3'd1:  begin   local_mask[1]=1'b1; end
                3'd2:  begin   local_mask[2]=1'b1; end  
                3'd3:  begin   local_mask[3]=1'b1; end  
                3'd4:  begin   local_mask[4]=1'b1; end  
                3'd5:  begin   local_mask[5]=1'b1; end  
                3'd6:  begin   local_mask[6]=1'b1; end  
                3'd7:  begin   local_mask[7]=1'b1; end             
                endcase
                
            3'b001:       // 2 bytes
                 case(addr[2:0])
                 3'd0:  begin   local_mask[1:0]=2'b11; end
                 3'd2:  begin   local_mask[3:2]=2'b11; end
                 3'd4:  begin   local_mask[5:4]=2'b11; end
                 3'd6:  begin   local_mask[7:6]=2'b11; end                 
                 endcase
                 
            3'b010:       //  4 bytes
                 case(addr[2:0])
                 3'd0: begin local_mask[3:0]=4'b1111;end
                 3'd4: begin local_mask[7:4]=4'b1111;end
                 endcase                        
            default: begin local_mask=8'hFF; end //8 bytes
                /*
                3'b011:       //  8
                
                3'b100:         16
                3'b101:         32
                3'b110:         64
                */
            endcase
        end
    
    end else if (MIN_SIZ==16) begin :min16
    
        always @(*) begin
            local_mask=8'h00;
            case(size)
                           
            3'b001:       // 2 bytes
                 case(addr[2:0])
                 3'd0:  begin   local_mask[1:0]=2'b11; end
                 3'd2:  begin   local_mask[3:2]=2'b11; end
                 3'd4:  begin   local_mask[5:4]=2'b11; end
                 3'd6:  begin   local_mask[7:6]=2'b11; end                 
                 endcase
                 
            3'b010:       //  4 bytes
                 case(addr[2:0])
                 3'd0: begin local_mask[3:0]=4'b1111;end
                 3'd4: begin local_mask[7:4]=4'b1111;end
                 endcase                        
            default: begin local_mask=8'hFF; end //8 bytes
                /*
                3'b011:       //  8
                
                3'b100:         16
                3'b101:         32
                3'b110:         64
                */
            endcase
        end
    
    
    end else begin :min32
         always @(*) begin
            local_mask=8'h00;
            case(size)
                
                 
            3'b010:       //  4 bytes
                 case(addr[2:0])
                 3'd0: begin local_mask[3:0]=4'b1111;end
                 3'd4: begin local_mask[7:4]=4'b1111;end
                 endcase                        
            default: begin local_mask=8'hFF; end //8 bytes
                /*
                3'b011:       //  8
                
                3'b100:         16
                3'b101:         32
                3'b110:         64
                */
            endcase
        end
    
    
    end
    endgenerate



    always @(*) begin
        mask_gen [0] = 8'h00;
        mask_gen [1] = 8'h00;
        mask_gen [2] = 8'h00;
        mask_gen [3] = 8'h00;
        mask_gen [4] = 8'h00;
        mask_gen [5] = 8'h00;
        mask_gen [6] = 8'h00;
        mask_gen [7] = 8'h00;
        case(addr[5:3])
                3'd0:  begin   mask_gen [0] = local_mask; end
                3'd1:  begin   mask_gen [1] = local_mask; end
                3'd2:  begin   mask_gen [2] = local_mask; end  
                3'd3:  begin   mask_gen [3] = local_mask; end  
                3'd4:  begin   mask_gen [4] = local_mask; end  
                3'd5:  begin   mask_gen [5] = local_mask; end  
                3'd6:  begin   mask_gen [6] = local_mask; end  
                3'd7:  begin   mask_gen [7] = local_mask; end             
        endcase
   end             
           

    assign mask = { mask_gen [7], mask_gen [6],  mask_gen [5],  mask_gen [4], mask_gen [3], mask_gen [2],  mask_gen [1],  mask_gen [0]};
    
   endmodule 
   
   
   
   
   
   
module   dat_alu_64_bit
    (
        init_dat,
        txn_dat,
        opt,
        out       
    );
   
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"    
    
    input [63 : 0] init_dat,   txn_dat;
    input [ALU_OPTw-1 : 0]  opt;
    output reg [63 : 0]  out;       
   
   
   
    wire  bigger_sign,bigger;
    assign bigger_sign = ($signed(txn_dat) > $signed(init_dat));
    assign bigger = (txn_dat > init_dat);

   
    always @(*) begin
        out = init_dat;
        case(opt)
        ALU_ADD:begin //Update location with (TxnData + InitialData).
            out = init_dat + txn_dat;        
        end
        ALU_CLR: begin // Update location with (InitialData AND (NOT TxnData)) Bitwise.
            out = init_dat & (~txn_dat);     
        end
        ALU_EOR:begin // Update location with (InitialData XOR TxnData) Bitwise.
            out = init_dat ^  txn_dat;            
        end
        ALU_SET:begin //Update location with (InitialData OR TxnData) Bitwise.
            out = init_dat |  txn_dat;      
        end
        ALU_SMAX:begin //Update location with TxnData if: (((Signed INT) TxnData – (Signed INT) InitialData) > 0). 
            if(bigger_sign) out = txn_dat;        
        end
        ALU_SMIN:begin // Update location with TxnData if:(((Signed INT) TxnData – (Signed INT) InitialData) < 0).
            if(~bigger_sign) out = txn_dat;        
        end       
        ALU_UMAX: begin //Update location with TxnData if:(((Unsigned INT) TxnData – (Unsigned INT) InitialData) > 0).
            if(bigger) out = txn_dat;        
        end
        ALU_UMIN: begin //Update location with TxnData if: (((Unsigned INT) TxnData – (Unsigned INT) InitialData) < 0).
            if(~bigger) out = txn_dat; 
        end        
        ALU_SWAP: begin 
            out = txn_dat;
        end  
        ALU_BPASS: begin 
            out = init_dat;
        end
        endcase
    end
   
endmodule   
