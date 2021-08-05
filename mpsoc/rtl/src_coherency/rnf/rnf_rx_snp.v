`timescale   1ns/1ns

module  rnf_rx_snp #(
    parameter VERBOSITY=0,
    //parameter src_id=0,
    parameter B=4
)(
    src_id,
     
    //chi chanel
    noc_chi_rxsnpflitpend,
    noc_chi_rxsnpflitv,
    noc_chi_rxsnpflit,
    chi_noc_rxsnplcrdv,   
     
    //cache read-chanel
    rxsnp_to_cache_rd_addr,
    cache_to_rxsnp_rd_data,
    rxsnp_to_cache_rd_en,
    cache_to_rxsnp_rd_ready,   
    cache_to_rxsnp_rd_state,
    cache_to_rxsnp_rd_hit,
    cache_to_rxsnp_rd_done,
    
    
    //cache write chanel    
    rxsnp_to_cache_wr_addr,
    rxsnp_to_cache_wr_data,
    rxsnp_to_cache_wr_evict,
    rxsnp_to_cache_wr_state,
    rxsnp_to_cache_wr_action,
    rxsnp_to_cache_wr_en,
    cache_to_rxsnp_wr_hit,    
    cache_to_rxsnp_wr_ready,
    cache_to_rxsnp_wr_done,          
    
    //txdat
    txdat_to_rxsnp_ready,
    rxsnp_to_txdat_wr,
    rxsnp_to_txdat_dat,
    rxsnp_to_txdat_tgtid,
    rxsnp_to_txdat_txnid,
    rxsnp_to_txdat_dbid,
    rxsnp_to_txopcode_dat,
    rxsnp_to_txdat_resp,
    rxsnp_to_txdat_homenid,
        
    
    //txrsp
    txrsp_to_rxsnp_ready,
    rxsnp_to_txrsp_wr_en,
    rxsnp_to_txrsp_txnid,
    rxsnp_to_txrsp_tgtid,
    rxsnp_to_txrsp_opcode,
    rxsnp_to_txrsp_resp,
    rxsnp_to_txrsp_fwstate,
    
    reset,
    clk  
     
);
    
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
    input [31 : 0] src_id;  
    
    input reset,clk;
    
    //CHI chanel
    input    noc_chi_rxsnpflitpend ;
    input    noc_chi_rxsnpflitv ;
    input   [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit ;
    output reg  chi_noc_rxsnplcrdv ;  
    
    //cache_rd
    output [ADDR_REQ-1 : 0] rxsnp_to_cache_rd_addr;
    input  [DATA_DAT-1 : 0] cache_to_rxsnp_rd_data;
    output rxsnp_to_cache_rd_en;
    input cache_to_rxsnp_rd_ready;   
    input [CACHE_STATUSw-1 : 0] cache_to_rxsnp_rd_state;
    input cache_to_rxsnp_rd_hit;
    input cache_to_rxsnp_rd_done;    
    
    //cache_wr     
    output [ADDR_REQ-1 :0  ] rxsnp_to_cache_wr_addr;
    output [DATA_DAT-1 : 0] rxsnp_to_cache_wr_data;
    output [CACHE_STATUSw-1:0] rxsnp_to_cache_wr_state;
    output [CACHE_ACTw-1:0] rxsnp_to_cache_wr_action;
    output  reg rxsnp_to_cache_wr_en;
    output  reg rxsnp_to_cache_wr_evict;
    input cache_to_rxsnp_wr_hit;
    input cache_to_rxsnp_wr_done;
    input cache_to_rxsnp_wr_ready;
    
    
    //txdat
    input  txdat_to_rxsnp_ready;
    output reg [DATA_DAT-1 : 0] rxsnp_to_txdat_dat;
    output reg rxsnp_to_txdat_wr;
    output reg [TGTID_DAT-1:0]  rxsnp_to_txdat_tgtid;
    output reg [TXNID_DAT-1:0]  rxsnp_to_txdat_txnid;
    output reg [TXNID_DAT-1:0]  rxsnp_to_txdat_dbid;
    output reg [RESP_DAT-1 : 0] rxsnp_to_txdat_resp;
    output reg [OPCODE_DAT-1 : 0] rxsnp_to_txopcode_dat;
    output reg [SRCID_DAT-1:0] rxsnp_to_txdat_homenid;
    
    //txrsp
    input  txrsp_to_rxsnp_ready;
    output reg rxsnp_to_txrsp_wr_en;
    output reg [TXNID_RSP-1:0] rxsnp_to_txrsp_txnid;
    output reg [TGTID_RSP-1:0] rxsnp_to_txrsp_tgtid;
    output reg [OPCODE_RSP-1:0] rxsnp_to_txrsp_opcode;
    output reg [RESP_RSP-1:0] rxsnp_to_txrsp_resp;
    output reg [FWD_DATAPULL_RSP-1 : 0] rxsnp_to_txrsp_fwstate;
    
    
    
    reg rx_snp_busy;
    wire[SNP_FLIT_SIZE-1:0] current_rxsnpflit;   
    reg read_fifo_en;        
    wire flit_fifo_empty, cache_fifo_empty; 
    
   //Read addr one cycle before reading the actual flit 
   wire [ADDR_REQ-1:0]            addr_in;
   
   get_snp_flit_addr getaddr(
    .snpflit(noc_chi_rxsnpflit),
    .addr(addr_in)
   );
    
    
    
    
     // cache read 
    assign rxsnp_to_cache_rd_addr = addr_in; // assum ideal single cycle pipe-stage Cache
    assign rxsnp_to_cache_rd_en = noc_chi_rxsnpflitv;
    
    localparam CACHE_FIFOw = DATA_DAT + CACHE_STATUSw + 1;
    
    wire [CACHE_FIFOw-1 : 0] current_cache_data, cache_din;
    wire current_cache_to_rxsnp_rd_hit;
    wire [DATA_DAT-1 : 0] current_cache_to_rxsnp_rd_data;
    wire [CACHE_STATUSw-1 : 0] current_cache_to_rxsnp_rd_state;
    
    assign cache_din = {cache_to_rxsnp_rd_hit,cache_to_rxsnp_rd_state,cache_to_rxsnp_rd_data};
    assign {current_cache_to_rxsnp_rd_hit,current_cache_to_rxsnp_rd_state,current_cache_to_rxsnp_rd_data} = current_cache_data;
   
   
    bram_based_fifo #(
        .Dw(CACHE_FIFOw),
        .B(B)
    )
    cache_fifo
    (
        .din(cache_din),
        .wr_en(cache_to_rxsnp_rd_done),
        .rd_en(read_fifo_en),
        .dout(current_cache_data),
        .full(),
        .nearly_full(),
        .empty(cache_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
   
   
    bram_based_fifo #(
        .Dw(SNP_FLIT_SIZE),
        .B(B)
    )
    flit_fifo
    (
        .din(noc_chi_rxsnpflit),
        .wr_en(noc_chi_rxsnpflitv),
        .rd_en(read_fifo_en ),
        .dout(current_rxsnpflit),
        .full( ),
        .nearly_full( ),
        .empty(flit_fifo_empty ),
        .reset(reset),
        .clk(clk)
   ); 
   
   
   
   
   
   
    
    
    wire [QOS_SNP-1:0]             qos; // = {QOS_REQ{1'b0}};
    wire [SRCID_SNP-1:0]           srcid;
    wire [TXNID_SNP-1:0]           txnid;
    wire [FWDNID_SNP-1:0]          fwdnid;
    wire [FWDTXNID_SNP-1:0]        fwdtxnid;
    wire [OPCODE_SNP-1:0]          opcode;
    wire [ADDR_SNP-1:0]            addr;
    wire                           ns;
    wire                           donotgotosd_datapull;
    wire                           rettosrc;
    wire                           tracetag; // = 1'b0;
   
    assign { qos, srcid, txnid, fwdnid, fwdtxnid, opcode, addr, ns, donotgotosd_datapull , rettosrc, tracetag} = current_rxsnpflit;
   
    
    localparam IDEAL=1;
    localparam PROCESS_REQ=2;
    localparam SEND_DAT_TO_RN = 4;
    localparam SEND_DAT_TO_HOME = 8;
    localparam SEND_RSP_TO_HOME =16;
    
    
    reg [4:0] pst;
    reg [4:0] nst; 
    
    reg [4: 0] transfer_type;
    reg [CACHE_STATUSw-1 : 0] final_cache_st;
    
    //Response to Requester_Home
   
    
  
    reg [3: 0] txdat_cmd;
    reg [1: 0] txrsp_cmd;
    
    localparam [3: 0] DAT_NoTEnable = 0;
    localparam [3: 0] DAT_CompData_SC =1;
    localparam [3: 0] DAT_SnpRespData_SC=2;     
    localparam [3: 0] DAT_SnpRespData_I=3;
    localparam [3: 0] DAT_SnpRespData_SC_PD=4;
    
    localparam [3: 0] DAT_SnpRespData_SC_Fwded_SC=5;    
    localparam [3: 0] DAT_SnpRespData_SC_PD_Fwded_SC=6;   
    localparam [3: 0] DAT_SnpRespDataPtl_I_PD=7;
    localparam [3: 0] DAT_SnpRespData_I_PD=8;
    
   
    localparam [1:0] RSP_NoTEnable = 0;
    localparam [1:0] RSP_SnpResp_I= 1;
    localparam [1:0] RSP_SnpResp_SC = 2;
    localparam [1:0] RSP_SnpResp_SC_Fwded_SC=3;
    reg unsupported_updode;
    
    
     always @(*)begin 
        txdat_cmd =    DAT_NoTEnable;
        txrsp_cmd =    RSP_NoTEnable;   
        
        
        rx_snp_busy=1'b0;
        read_fifo_en=1'b0;
        nst=pst;
        final_cache_st = CACHE_SC;
        rxsnp_to_cache_wr_en = 1'b0;
        rxsnp_to_cache_wr_evict = 1'b0;
        unsupported_updode=1'b0;
        
        case(pst)
        IDEAL: begin 
            if(~flit_fifo_empty & ~cache_fifo_empty)begin 
                nst=PROCESS_REQ;
                read_fifo_en=1'b1;            
            end        
        end 
        PROCESS_REQ: begin 
            rx_snp_busy=1'b1;
            case(opcode)
            SNP_OPCODE_SnpSharedFwd: begin
                if(~current_cache_to_rxsnp_rd_hit) begin 
                //This data does not exist in this RN. Sends SnpResp_I
                    if(txrsp_to_rxsnp_ready)begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                        
                        final_cache_st = CACHE_I;                        
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end//~ cache hit
                else begin // data exist in cache. check cache state
                case(current_cache_to_rxsnp_rd_state)
                
                
                CACHE_I,CACHE_UCE : begin 
                   if(txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready )begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;  
                        final_cache_st = CACHE_I; 
                        rxsnp_to_cache_wr_evict=1'b1;
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end
                
                
                CACHE_UC  ,CACHE_SC : begin
                   if(rettosrc) begin 
                        // need to send two data packets. One to requester and another to home node
                        if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespData_SC_Fwded_SC;  //respose data to home                      
                            nst = SEND_DAT_TO_RN;
                            rxsnp_to_cache_wr_en = 1'b1;
                        end
                    end else begin
                        if(txrsp_to_rxsnp_ready & txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready) begin  //both chanels are ready        
                             txdat_cmd =  DAT_CompData_SC;  
                             txrsp_cmd =  RSP_SnpResp_SC_Fwded_SC;
                             rxsnp_to_cache_wr_en = 1'b1;
                             if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                              
                        end else if( txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready) begin  //Only rsp ready
                             txrsp_cmd =  RSP_SnpResp_SC_Fwded_SC;
                             nst =  SEND_DAT_TO_RN;
                             rxsnp_to_cache_wr_en = 1'b1;
                        end else if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready) begin  //Only txdata is ready
                             txdat_cmd =  DAT_CompData_SC; //response data to rn
                             nst =  SEND_RSP_TO_HOME;
                             rxsnp_to_cache_wr_en = 1'b1;
                        end 
                   end
                
                end                 
                CACHE_UD , CACHE_SD : begin 
                  /*
                   //pass responsibility to update the memory to the reciever Requester
                   transfer_type=  (rettosrc)? SnpRespDataSC_FwdedSDPD : SnpRespSC_FwdedSDPD;
                   */
                   
                   //pass responsibility to update the main memory to home node 
                   // need to send two data packets. One to requester and another to home node
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                        txrsp_cmd =   RSP_NoTEnable;
                        txdat_cmd =   DAT_SnpRespData_SC_PD_Fwded_SC;  //response data to home                      
                        nst = SEND_DAT_TO_RN;
                        rxsnp_to_cache_wr_en = 1'b1;
                    end
                   
                   
                end 
                
                CACHE_UDP: begin 
                    final_cache_st = CACHE_I; 
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                        txrsp_cmd =  RSP_NoTEnable;
                        txdat_cmd =  DAT_SnpRespDataPtl_I_PD;   
                        rxsnp_to_cache_wr_evict=1'b1;
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready   
                end
                default begin 
                     final_cache_st = CACHE_I; 
                     if(txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                        rxsnp_to_cache_wr_evict=1'b1;
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                         
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready           
                end                
                endcase                
                end
            end// SNP_OPCODE_SnpSharedFwd
            
 /*____________________________________________________________________________*/    
            SNP_OPCODE_SnpShared: begin 
            if(~current_cache_to_rxsnp_rd_hit) begin 
                //This data does not exist in this RN. Sends SnpResp_I
                    if(txrsp_to_rxsnp_ready)begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                        
                        final_cache_st = CACHE_I;                        
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end//~ cache hit
                else begin // data exist in cache. check cache state
                case(current_cache_to_rxsnp_rd_state)
                CACHE_I,CACHE_UCE : begin 
                    if(txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready )begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;  
                        final_cache_st = CACHE_I; 
                        rxsnp_to_cache_wr_evict=1'b1;
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end//CACHE_I,CACHE_UCE 
                CACHE_UC  ,CACHE_SC : begin
                   if(rettosrc) begin 
                        // need to send data packets to home 
                        if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespData_SC;  //respose data to home                      
                            rxsnp_to_cache_wr_en = 1'b1;
                            if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;   
                        end
                    end else begin
                        // only need to send ack response
                        if(txrsp_to_rxsnp_ready  & cache_to_rxsnp_wr_ready) begin 
                             txdat_cmd =  DAT_NoTEnable;  
                             txrsp_cmd =  RSP_SnpResp_SC;
                             rxsnp_to_cache_wr_en = 1'b1;
                             if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                              
                        end
                   end                
                end// CACHE_UC  ,CACHE_SC                 
                CACHE_UD , CACHE_SD : begin                                     
                   //pass responsibility to update the main memory to home node 
                   if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                        txrsp_cmd =   RSP_NoTEnable;
                        txdat_cmd =   DAT_SnpRespData_SC_PD;  //response data to home  
                        rxsnp_to_cache_wr_en = 1'b1;
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                         
                    end                  
                end // CACHE_UD , CACHE_SD
                
                CACHE_UDP: begin 
                    final_cache_st = CACHE_I; 
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                        txrsp_cmd =  RSP_NoTEnable;
                        txdat_cmd =  DAT_SnpRespDataPtl_I_PD;   
                        rxsnp_to_cache_wr_evict=1'b1;
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready   
                end
                
                endcase // current_cache_to_rxsnp_rd_state)
                end//else
            
            end
            
        
            
            SNP_OPCODE_SnpCleanInvalid: begin 
                final_cache_st = CACHE_I; 
               
                if(~current_cache_to_rxsnp_rd_hit) begin 
                //This data does not exist in this RN. Sends SnpResp_I
                if(txrsp_to_rxsnp_ready)begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                        
                        final_cache_st = CACHE_I;                        
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end//~ cache hit
                else begin // data exist in cache. check cache state
                case(current_cache_to_rxsnp_rd_state)
                CACHE_I,CACHE_UC,CACHE_UCE,CACHE_SC : begin //send RSP_SnpResp_I
                   if(txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready )begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                          
                        rxsnp_to_cache_wr_evict=1'b1;                       
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end //  CACHE_I,CACHE_UC,CACHE_UCE,CACHE_SC
                CACHE_UD, CACHE_SD: begin // send SnpRespData_I_PD 
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespData_I_PD;  //respose data to home                      
                            rxsnp_to_cache_wr_evict=1'b1;
                             if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;    
                     end
                end // CACHE_UD, CACHE_SD
                CACHE_UDP: begin// send SnpRespDataPtl_I_PD
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespDataPtl_I_PD;  //respose data to home                      
                            rxsnp_to_cache_wr_evict=1'b1;
                            if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;    
                     end                
                end // CACHE_UDP
                endcase // current_cache_to_rxsnp_rd_state
                end// else
               
            
            
            
            end //SNP_OPCODE_SnpCleanInvalid
            
              
            SNP_OPCODE_SnpUnique: begin
                final_cache_st = CACHE_I; 
                if(~current_cache_to_rxsnp_rd_hit) begin 
                //This data does not exist in this RN. Sends SnpResp_I
                if(txrsp_to_rxsnp_ready)begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                        
                        final_cache_st = CACHE_I;                        
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready
                end//~ cache hit
                else begin // data exist in cache. check cache state
                case(current_cache_to_rxsnp_rd_state)
                CACHE_I,CACHE_UCE : begin 
                    //send RSP_SnpResp_I
                    if(txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready )begin 
                        txrsp_cmd =  RSP_SnpResp_I;
                        txdat_cmd =  DAT_NoTEnable;                          
                        rxsnp_to_cache_wr_evict=1'b1;                       
                        if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                    end//txrsp_to_rxsnp_ready                
                end//CACHE_I
                
                CACHE_UC, CACHE_SC: begin
                    case(rettosrc)
                    1'b0:begin
                        //send RSP_SnpResp_I
                        if(txrsp_to_rxsnp_ready & cache_to_rxsnp_wr_ready )begin 
                            txrsp_cmd =  RSP_SnpResp_I;
                            txdat_cmd =  DAT_NoTEnable;                          
                            rxsnp_to_cache_wr_evict=1'b1;                       
                            if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;                        
                        end//txrsp_to_rxsnp_ready  
                    end
                    1'b1: begin
                        // send SnpRespData_I 
                        if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespData_I;  //respose data to home                      
                            rxsnp_to_cache_wr_evict=1'b1;
                            if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;    
                        end
                    end
                    endcase
                end//CACHE_UC
                CACHE_UD, CACHE_SD: begin // send SnpRespData_I_PD 
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespData_I_PD;  //respose data to home                      
                            rxsnp_to_cache_wr_evict=1'b1;
                             if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;    
                     end
                end // CACHE_UD, CACHE_SD
                CACHE_UDP: begin// send SnpRespDataPtl_I_PD
                    if(txdat_to_rxsnp_ready & cache_to_rxsnp_wr_ready)begin 
                            txrsp_cmd =   RSP_NoTEnable;
                            txdat_cmd =   DAT_SnpRespDataPtl_I_PD;  //respose data to home                      
                            rxsnp_to_cache_wr_evict=1'b1;
                            if(~flit_fifo_empty & ~cache_fifo_empty)  read_fifo_en=1'b1; else nst=IDEAL;    
                     end                
                end // CACHE_UDP
                endcase
                end 
            
            
            end//SNP_OPCODE_SnpUnique   
            
            
            
            
            default begin 
                unsupported_updode=1'b1;
            end
            endcase //opcode
        end //PROCESS_REQ
        SEND_DAT_TO_RN: begin 
            if(txdat_to_rxsnp_ready)begin 
                txdat_cmd =  DAT_CompData_SC;  
                /*
                //pass responsibility to update the memory to the reciever Requester
                if(current_cache_to_rxsnp_rd_state == CACHE_UD || current_cache_to_rxsnp_rd_state  CACHE_SD) transfer_type= CompData_SD_PD;  
                */            
            
                if(~flit_fifo_empty & ~cache_fifo_empty)  begin 
                    read_fifo_en=1'b1;
                    nst = PROCESS_REQ;
                end else nst=IDEAL;      
            
            end // txdat_to_rxsnp_ready
            
        
        
        end//SEND_DAT_TO_RN
        SEND_RSP_TO_HOME: begin 
            if (txrsp_to_rxsnp_ready)begin 
                case(current_cache_to_rxsnp_rd_state)
                CACHE_UC  ,CACHE_SC: txrsp_cmd =  RSP_SnpResp_SC_Fwded_SC;
                
                endcase
                
                if(~flit_fifo_empty & ~cache_fifo_empty)  begin 
                    read_fifo_en=1'b1;
                    nst = PROCESS_REQ;
                end else nst=IDEAL;     
            
            
            end        
        end //SEND_RSP_TO_HOME        
        endcase //pst
     end
    
    
    assign rxsnp_to_cache_wr_state = final_cache_st;
    assign rxsnp_to_cache_wr_action=2'b11;
    assign rxsnp_to_cache_wr_addr  = addr;
    assign rxsnp_to_cache_wr_data = current_cache_to_rxsnp_rd_data;
    
    
   
    
    
    always @(*) begin  
        
        rxsnp_to_txdat_wr=1'b0;
        //default for SnpRespData
        rxsnp_to_txdat_dat= current_cache_to_rxsnp_rd_data;
        rxsnp_to_txdat_tgtid=srcid;
        rxsnp_to_txdat_txnid=txnid;
        
        
        //default for DAT_SnpRespData_SC_Fwded_SC
        rxsnp_to_txdat_homenid=srcid;
        rxsnp_to_txopcode_dat= OPCODE_DAT_SnpRespDataFwded;
        rxsnp_to_txdat_resp= 3'b001;  
        
        
        case(txdat_cmd) 
        DAT_CompData_SC : begin
            rxsnp_to_txdat_tgtid=fwdnid;
            rxsnp_to_txdat_txnid=fwdtxnid;
            rxsnp_to_txdat_dbid= txnid;
            rxsnp_to_txopcode_dat= OPCODE_DAT_CompData; //3'h4
            rxsnp_to_txdat_resp= 3'b001;            
            rxsnp_to_txdat_wr=1'b1;
            
        end // DAT_CompData_SC
        DAT_SnpRespData_SC: begin 
            rxsnp_to_txopcode_dat=OPCODE_DAT_SnpRespData; //6;
            rxsnp_to_txdat_resp =3'b001;        
            rxsnp_to_txdat_wr=1'b1;        
        
        end
        DAT_SnpRespData_SC_PD: begin 
            rxsnp_to_txopcode_dat=OPCODE_DAT_SnpRespData;//1
            rxsnp_to_txdat_resp = 3'b101;
            rxsnp_to_txdat_wr=1'b1;         
        end 
        
        DAT_SnpRespData_SC_Fwded_SC : begin 
            rxsnp_to_txopcode_dat=OPCODE_DAT_SnpRespDataFwded; //6;
            rxsnp_to_txdat_resp =3'b001;        
            rxsnp_to_txdat_wr=1'b1;
            
        end //DAT_SnpRespData_SC_Fwded_SC
        DAT_SnpRespData_SC_PD_Fwded_SC :    begin 
            rxsnp_to_txopcode_dat= OPCODE_DAT_SnpRespDataFwded; //6;
            rxsnp_to_txdat_resp= 3'b101;            
            rxsnp_to_txdat_wr=1'b1;
            
        end //DAT_SnpRespData_SC_PD_Fwded_SC 
        DAT_SnpRespData_I:begin
            rxsnp_to_txopcode_dat=OPCODE_DAT_SnpRespData;//1
            rxsnp_to_txdat_resp = 3'b000;
            rxsnp_to_txdat_wr=1'b1;        
        end
        DAT_SnpRespDataPtl_I_PD : begin
            rxsnp_to_txopcode_dat=OPCODE_DAT_SnpRespDataPtl;//5
            rxsnp_to_txdat_resp = 3'b100;
            rxsnp_to_txdat_wr=1'b1;
           
        end // DAT_SnpRespDataPtl_I_PD 
        DAT_SnpRespData_I_PD: begin 
            rxsnp_to_txopcode_dat= OPCODE_DAT_SnpRespData;
            rxsnp_to_txdat_resp =  3'b100;
            rxsnp_to_txdat_wr=1'b1;
        end        
        endcase  //    transfer_type
    end
    
    
     always @(*) begin 
        
        rxsnp_to_txrsp_wr_en=1'b0;
        rxsnp_to_txrsp_txnid=txnid;
        rxsnp_to_txrsp_tgtid=srcid;
        rxsnp_to_txrsp_opcode=RSP_OPCODE_SnpResp;
        rxsnp_to_txrsp_resp=3'b000;   
        rxsnp_to_txrsp_fwstate= 3'b001;
    
    
        case(txrsp_cmd) 
        RSP_SnpResp_I: begin
            rxsnp_to_txrsp_opcode= RSP_OPCODE_SnpResp;//0x01
            rxsnp_to_txrsp_resp=3'b000;   
            rxsnp_to_txrsp_wr_en=1'b1;        
        end //RSP_SnpResp_I
        RSP_SnpResp_SC:begin 
            rxsnp_to_txrsp_opcode= RSP_OPCODE_SnpResp;//0x01
            rxsnp_to_txrsp_resp=3'b001;   
            rxsnp_to_txrsp_wr_en=1'b1;       
        
        end
        RSP_SnpResp_SC_Fwded_SC: begin 
            rxsnp_to_txrsp_opcode= RSP_OPCODE_SnpRespFwded;// 0x9;
            rxsnp_to_txrsp_resp=3'b001;
            rxsnp_to_txrsp_fwstate=3'b001;
            rxsnp_to_txrsp_wr_en=1'b1;
        end //RSP_SnpResp_SC_Fwded_SC    
        endcase  //    transfer_type
    end
    
    
     always @(posedge clk) begin
        if(reset) begin          
            chi_noc_rxsnplcrdv<=0;
            pst <= IDEAL;
        end  else begin 
            chi_noc_rxsnplcrdv<=read_fifo_en;
            pst<=nst;
        end
    end
    
    //synthesis translate_off 
   //synopsys  translate_off
    always @(posedge clk)begin 
    if((VERBOSITY & MONITORE_TXN_CMD) > 0)begin
        if(pst == PROCESS_REQ &&  (txdat_cmd !=    DAT_NoTEnable || txrsp_cmd !=    RSP_NoTEnable)) begin 
           case(opcode)
           SNP_OPCODE_SnpSharedFwd: $display("%t: rnf ( %d ) txn ( %d ) got SnpSharedFwd  snoop request.",$time,src_id,txnid);
           SNP_OPCODE_SnpCleanInvalid: $display("%t: rnf ( %d ) txn ( %d ) got SnpCleanInvalid snoop request.",$time,src_id,txnid);
           SNP_OPCODE_SnpUnique: $display("%t: rnf ( %d ) txn ( %d ) got SnpUnique snoop request.",$time,src_id,txnid);
           SNP_OPCODE_SnpShared: $display("%t: rnf ( %d ) txn ( %d ) got SnpShared snoop request.",$time,src_id,txnid);
           endcase        
        end 
        
        
        
        case(txdat_cmd)
        DAT_CompData_SC:        $display("%t: rnf ( %d ) txn ( %d ) sends CompData_SC to DAT chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txdat_tgtid);
        DAT_SnpRespData_SC:     $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespData_SC to DAT chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txdat_tgtid);
        DAT_SnpRespData_I:      $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespData_I to DAT chanel for adrr ( %d ) to core ( %d ).",$time,src_id,txnid,addr,rxsnp_to_txdat_tgtid);
        DAT_SnpRespData_SC_PD:  $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespData_SC_PD to DAT chanel for adrr ( %d ) to core ( %d ).",$time,src_id,txnid,addr,rxsnp_to_txdat_tgtid);
        DAT_SnpRespData_SC_Fwded_SC: $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespData_SC_Fwded_SC to DAT chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txdat_tgtid);
        DAT_SnpRespData_SC_PD_Fwded_SC: $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespData_SC_PD_Fwded_SC to DAT chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txdat_tgtid);
        DAT_SnpRespDataPtl_I_PD: $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespDataPtl_I_PD to DAT chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txdat_tgtid);
        DAT_SnpRespData_I_PD:   $display("%t: rnf ( %d ) txn ( %d ) sends SnpRespData_I_PD to DAT chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txdat_tgtid);
        endcase       
    
         
        case(txrsp_cmd)
        RSP_SnpResp_I:              $display("%t: rnf ( %d ) txn ( %d ) sends SnpResp_I to RSP chanel for addr ( %d ) to core ( %d )",$time,src_id,txnid,addr,rxsnp_to_txrsp_tgtid);
        RSP_SnpResp_SC:             $display("%t: rnf ( %d ) txn ( %d ) sends SnpResp_SC to RSP chanel for addr ( %d ) to core ( %d )",$time,src_id,txnid,addr,rxsnp_to_txrsp_tgtid);
        RSP_SnpResp_SC_Fwded_SC:    $display("%t: rnf ( %d ) txn ( %d ) sends SnpResp_SC_Fwded_SC to RSP chanel to core ( %d ).",$time,src_id,txnid,rxsnp_to_txrsp_tgtid);
        endcase
              
              
        if(unsupported_updode)begin  $display("%t: rnf ( %d ) txn ( %d ) got an Unsupported snoop request: %h.",$time,src_id,txnid,opcode);  $stop; end
    end   
    end
    //synthesis translate_on 
    //synopsys  translate_on
    
    

endmodule


