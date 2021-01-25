/**************************************
* Module: rnf_wrap_req
* Date:2019-09-19  
* Author: alireza     
*
* Description: 
***************************************/
module  rnf_wrap_req #(
    parameter WRAP_REQ_W=64

)(
    reset,
    clk,
    
    //interface to testbench (read from trace file)
    wrapreq,
    wrapreqvalid,
    tim_wrap_strobereq,
   
    
    //iterface to rnf_tx_req
    exclusive,
    likelyshared,
    Readshared,
    ReadUnique, 
    CleanUnique, 
    WriteBackFull,
    
    data_o,
    addr_o,//donot change it until send done
    send_done,
    initial_cache_state,
    can_accept_new_req
);


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
    input   reset,clk;
    input   [WRAP_REQ_W-1:0]   wrapreq;
    input                      wrapreqvalid;
    output                     tim_wrap_strobereq;
    
    output exclusive, likelyshared, Readshared, ReadUnique, CleanUnique,  WriteBackFull;
    output [DATA_DAT-1 : 0] data_o;
    output [ADDR_REQ-1 : 0] addr_o;//donot change it until send done
    
    input  [CACHE_STATUSw-1 : 0]  initial_cache_state;
    input can_accept_new_req;
    
    output send_done;
    
   wire [21: 0] ReqId;
   wire [33 : 0] addr;
   wire [2 : 0] OpC;
   wire Excl;
   wire Ld_St;
   wire [2 : 0] OpCode;
   
   
    assign {ReqId, addr, OpC, Excl, Ld_St, OpCode} = wrapreq;
   
    localparam [2: 0] OpCode_L1MissData  =  3'd0;
    localparam [2: 0] OpCode_L1MissInst  =  3'd1; //001
    localparam [2: 0] OpCode_EvictDirty  =  3'd2; //010
    localparam [2: 0] OpCode_WFI         =  3'd3; //011
    localparam [2: 0] OpCode_WFE         =  3'd3; //011
    localparam [2: 0] OpCode_Wait_For    =  3'd4; //100
    localparam [2: 0] OpCode_Wait        =  3'd5;   //101
    localparam [2: 0] OpCode_AtomicLd    =  3'd6;   //110
    localparam [2: 0] OpCode_AtomicSt    =  3'd6;   //110

   
  
    
  
  
  
    

 
endmodule

