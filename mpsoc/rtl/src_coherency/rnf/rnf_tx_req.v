`timescale   1ns/1ns

module rnf_tx_req #(
    parameter VERBOSITY=0,
   // parameter src_id =0,
    parameter NUM_OF_RNs=4,
    parameter NUM_OF_HNs=4, // must be power  of 2
    parameter EAw=2,
    parameter B=4

)(
    src_id,
    reset,
    clk,
    chi_noc_txreqflitpend,
    chi_noc_txreqflitv,
    chi_noc_txreqflit,          
    noc_chi_txreqlcrdv,
    
    //interface from the wrapper
    exclusive,
    likelyshared,
    ReqOpcode, 
    Request_en,
    Write_dat,
    read_addr,//donot change it until send done
    send_done,
   // initial_cache_state,
    can_accept_new_req,
     
   
    // to txn lkpt agent : save the txnid in lookup table
    txreq_to_lkpt_txnid,
    txreq_to_lkpt_txndat,
    txreq_to_lkpt_new_txn,
    
    //datlkpt-rxdat
    txreq_to_datlkpt_txnid,
    txreq_to_datlkpt_txndat,
    txreq_to_datlkpt_valid,
    
    
    //from response agent : reuse the txnid 
    rxrsp_to_txreq_txnid,
    rxrsp_to_txreq_txnid_release        


);
   


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
  input [31 : 0 ] src_id;

    input reset,clk;
    
    output   chi_noc_txreqflitpend;
    output   reg chi_noc_txreqflitv;
    output  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit;          
    input  noc_chi_txreqlcrdv;

    assign chi_noc_txreqflitpend = 1'b1;

    input [OPCODE_REQ-1 : 0] ReqOpcode;
    input Request_en;
    input [DATA_DAT-1 : 0] Write_dat;
    input [ADDR_REQ-1 : 0] read_addr;
    input exclusive,likelyshared;
   
    
    output send_done;
    output  can_accept_new_req;
     
    assign send_done = chi_noc_txreqflitv ;
    
     // to txn lookup agent
    output reg [TXNID_REQ-1 :  0] txreq_to_lkpt_txnid;
    output [RNF_TXN_DATAw-1 :  0] txreq_to_lkpt_txndat;
    output reg txreq_to_lkpt_new_txn;
    
    
    //datlkpt-rxdat
    output  [TXNID_REQ-1 : 0] txreq_to_datlkpt_txnid;
    output [DATA_DAT+OPCODE_REQ-1  : 0] txreq_to_datlkpt_txndat;
    output txreq_to_datlkpt_valid;
    
    // from reponse agent
    input [TXNID_REQ-1 :  0] rxrsp_to_txreq_txnid;
    input rxrsp_to_txreq_txnid_release;    
    
    
    wire [ADDR_REQ-1 : 0] target_addr;
    wire have_credit;
    wire tag_empty;
    assign can_accept_new_req = have_credit &  ~tag_empty;

    // txreqflit
        reg [QOS_REQ-1:0]             qos; // = {QOS_REQ{1'b0}};
        reg [TGTID_REQ-1:0]           tgtid;
        reg [SRCID_REQ-1:0]           srcid;
        reg [TXNID_REQ-1:0]           txnid;
        reg [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
        reg                           endian; // = 1'b1;
        reg [RETURNTXNID_REQ-1:0]     returntxnid;
        reg [OPCODE_REQ-1:0]          opcode;
        reg [SIZE_REQ-1:0]            flitsize; // = 3'b110 ;
        reg [ADDR_REQ-1:0]            addr;
        reg                           ns; // = 1'b1;
       // reg                           likelyshared; // = 1'b0;
        reg                           allowretry; // = 1'b1;
        reg [ORDER_REQ-1:0]           order; // = 2'b11;
        reg [PCRDTYPE_REQ-1:0]        pcrdtype; // = 4'b0000;
        reg [MEMATTR_REQ-1:0]         memattr;// = 4'b0111;
        reg                           snpattr; // = 1'b1;
        reg [LPID_REQ-1:0]            lpid; // = 5'b00000;
        reg                           excl_snoopme; // = 1'b1;
        reg                           expcompack;
        reg                           tracetag; // = 1'b0;
        
    assign txreq_to_datlkpt_txndat = {opcode,Write_dat};
    assign txreq_to_datlkpt_txnid=txnid;
    assign txreq_to_datlkpt_valid = chi_noc_txreqflitv;
    assign chi_noc_txreqflitpend = 1'b1;

   
    wire [TXNID_REQ-1 :  0] txnid_out;
    reg new_txnid_gen;
    

    wire [OPCODE_REQ-1:0] txreq_to_rxrsp_txn_opcode;
    reg [ADDR_REQ-1:0] req_rsp_txn_addr;    

    assign txreq_to_lkpt_txndat = {exclusive,txreq_to_rxrsp_txn_opcode,req_rsp_txn_addr} ;

    txnid_gen #(
        //.src_id(src_id),
        .VERBOSITY(VERBOSITY),
    	.TAGw(TXNID_REQ)
    )
    the_txnid_gen
    (
    	.src_id(src_id),
    	.reset(reset),
    	.clk(clk),
    	.txnid_in(rxrsp_to_txreq_txnid),
    	.add(rxrsp_to_txreq_txnid_release),
    	.txnid_out(txnid_out),
    	.read(new_txnid_gen),
    	.empty(tag_empty)
    );
    
    wire [TGTID_REQ-1 : 0] target_id;
    
       
    
    fake_sam #(
       	.RAW_ADDR_SIZ(ADDR_REQ),
    	.TRGT_ADDR_SIZ(ADDR_REQ)    	
    )
    the_sam
    (
    	.raw_addr(read_addr),
    	.target_hnf_id(target_id),
    	.target_addr(target_addr)
    );


   

assign txreq_to_rxrsp_txn_opcode=opcode; 





always @(*) begin 
    qos = {QOS_REQ{1'b0}};
    tgtid = 0; 
    tgtid [EAw-1 : 0] = target_id;    
    srcid = src_id;
    txnid = txnid_out;
    //ReturnNID is inapplicable from Requester to Home and must be set to zero in all requests.
    returnnid = {RETURNNID_REQ{1'b0}};
    endian = 1'b1;
    //ReturnTxnID is inapplicable from Requester to Home and Requester to Slave, and must be set to zero in all requests.
    returntxnid= {RETURNTXNID_REQ{1'b0}};
    opcode = {OPCODE_REQ{1'b0}};
    flitsize = 3'b110;
    addr  = target_addr; 
    ns=1'b1;
    allowretry=1'b1;
    order = 2'b11;
    pcrdtype=4'b0000;    
    memattr=4'b0111;
    snpattr=1'b1;
    lpid = 5'b00000;
    expcompack =1'b1;
    tracetag = 1'b0;
    
    excl_snoopme=exclusive;
    //likelyshared=1'b1;
    
    
    txreq_to_lkpt_new_txn = 1'b0;
    req_rsp_txn_addr = read_addr;
    txreq_to_lkpt_txnid = txnid;
    
    new_txnid_gen=1'b0;
   
    chi_noc_txreqflitv=1'b0;
    
    opcode = ReqOpcode;
     
    
   
   if(Request_en & can_accept_new_req ) begin 
            new_txnid_gen=1'b1;
            chi_noc_txreqflitv=1'b1;
            txreq_to_lkpt_new_txn = 1'b1;                 
   end
   
   
end    
     
     
     credict_ckeck #(
     	.B(B)
     )
     credict
     (
     	.chi_noc_flitv(chi_noc_txreqflitv),
     	.noc_chi_lcrdv(noc_chi_txreqlcrdv),
     	.have_cridit(have_credit),
     	 .nearly_full(),
     	.reset(reset),
     	.clk(clk)
     );
     
   
    
     
      
    
    assign chi_noc_txreqflit =  {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
    ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag}; 


    //synthesis translate_off 
    //synopsys  translate_off
    
    
     reg [159 : 0] opcode_str;
    always @(*)begin 
        opcode_str = "Undefined          ";
        case(opcode)                            
        REQ_OPCODE_ReqLCrdReturn         :       opcode_str =       "ReqLCrdReturn       ";
        REQ_OPCODE_ReadShared            :       opcode_str =       "ReadShared          ";
        REQ_OPCODE_ReadClean             :       opcode_str =       "ReadClean           ";
        REQ_OPCODE_ReadOnce              :       opcode_str =       "ReadOnce            ";
        REQ_OPCODE_ReadNoSnp             :       opcode_str =       "ReadNoSnp           ";
        REQ_OPCODE_PCrdReturn            :       opcode_str =       "PCrdReturn          ";
        REQ_OPCODE_Reserved              :       opcode_str =       "Reserved            ";
        REQ_OPCODE_ReadUnique            :       opcode_str =       "ReadUnique          ";
        REQ_OPCODE_CleanShared           :       opcode_str =       "CleanShared         ";
        REQ_OPCODE_CleanInvalid          :       opcode_str =       "CleanInvalid        ";
        REQ_OPCODE_MakeInvalid           :       opcode_str =       "MakeInvalid         ";
        REQ_OPCODE_CleanUnique           :       opcode_str =       "CleanUnique         ";
        REQ_OPCODE_MakeUnique            :       opcode_str =       "MakeUnique          ";
        REQ_OPCODE_Evict                 :       opcode_str =       "Evict               ";
        REQ_OPCODE_DVMOp                 :       opcode_str =       "DVMOp               ";
        REQ_OPCODE_WriteEvictFull        :       opcode_str =       "WriteEvictFull      ";
        REQ_OPCODE_WriteCleanFull        :       opcode_str =       "WriteCleanFull      ";
        REQ_OPCODE_WriteUniquePtl        :       opcode_str =       "WriteUniquePtl      ";
        REQ_OPCODE_WriteUniqueFull       :       opcode_str =       "WriteUniqueFull     ";     
        REQ_OPCODE_WriteBackPtl          :       opcode_str =       "WriteBackPtl        ";
        REQ_OPCODE_WriteBackFull         :       opcode_str =       "WriteBackFull       ";
        REQ_OPCODE_WriteNoSnpPtl         :       opcode_str =       "WriteNoSnpPtl       ";
        REQ_OPCODE_WriteNoSnpFull        :       opcode_str =       "WriteNoSnpFull      ";
        REQ_OPCODE_WriteUniqueFullStash  :       opcode_str =       "WriteUniqueFullStash";     
        REQ_OPCODE_WriteUniquePtlStash   :       opcode_str =       "WriteUniquePtlStash ";     
        REQ_OPCODE_StashOnceShared       :       opcode_str =       "StashOnceShared     ";     
        REQ_OPCODE_StashOnceUnique       :       opcode_str =       "StashOnceUnique     ";     
        REQ_OPCODE_ReadOnceCleanInvalid  :       opcode_str =       "ReadOnceCleanInvalid";     
        REQ_OPCODE_ReadOnceMakeInvalid   :       opcode_str =       "ReadOnceMakeInvalid ";     
        REQ_OPCODE_ReadNotSharedDirty    :       opcode_str =       "ReadNotSharedDirty  ";     
        REQ_OPCODE_CleanSharedPersist    :       opcode_str =       "CleanSharedPersist  ";     
        REQ_OPCODE_PrefetchTgt           :       opcode_str =       "PrefetchTgt         ";
            
        REQ_OPCODE_AtomicStore_ADD       :       opcode_str =      "AtomicStore_ADD     ";
        REQ_OPCODE_AtomicStore_CLR       :       opcode_str =      "AtomicStore_CLR     "; 
        REQ_OPCODE_AtomicStore_EOR       :       opcode_str =      "AtomicStore_EOR     "; 
        REQ_OPCODE_AtomicStore_SET       :       opcode_str =      "AtomicStore_SET     "; 
        REQ_OPCODE_AtomicStore_SMAX      :       opcode_str =      "AtomicStore_SMAX    "; 
        REQ_OPCODE_AtomicStore_SMIN      :       opcode_str =      "AtomicStore_SMIN    "; 
        REQ_OPCODE_AtomicStore_UMAX      :       opcode_str =      "AtomicStore_UMAX    "; 
        REQ_OPCODE_AtomicStore_UMIN      :       opcode_str =      "AtomicStore_UMIN    "; 

        REQ_OPCODE_AtomicLoad_ADD        :       opcode_str =      "AtomicLoad_ADD      "; 
        REQ_OPCODE_AtomicLoad_CLR        :       opcode_str =      "AtomicLoad_CLR      "; 
        REQ_OPCODE_AtomicLoad_EOR        :       opcode_str =      "AtomicLoad_EOR      "; 
        REQ_OPCODE_AtomicLoad_SET        :       opcode_str =      "AtomicLoad_SET      "; 
        REQ_OPCODE_AtomicLoad_SMAX       :       opcode_str =      "AtomicLoad_SMAX     "; 
        REQ_OPCODE_AtomicLoad_SMIN       :       opcode_str =      "AtomicLoad_SMIN     "; 
        REQ_OPCODE_AtomicLoad_UMAX       :       opcode_str =      "AtomicLoad_UMAX     "; 
        REQ_OPCODE_AtomicLoad_UMIN       :       opcode_str =      "AtomicLoad_UMIN     "; 
        REQ_OPCODE_AtomicSwap            :       opcode_str =      "AtomicSwap          "; 
        REQ_OPCODE_AtomicCompare         :       opcode_str =      "AtomicCompare       "; 
                                                                                         
           
        endcase
   end     
    
    
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_REQ_TYPE) > 0) begin
            if(new_txnid_gen) $display("%t: rnf ( %d ) txn ( %d ) a new %s req is accepted on addr( %d ) ",$time,src_id, txnid,opcode_str,
            addr);
        end
    
    
        if((VERBOSITY & MONITORE_TXN_CMD) > 0) begin 
	       if(new_txnid_gen) 
	       $display("%t: rnf ( %d ) txn ( %d ) sends %s req on addr ( %d )",$time,src_id, txnid,opcode_str,addr);
        end
    end
    //synthesis translate_on 
    //synopsys  translate_on



//synthesis translate_off 
//synopsys  translate_off

always @(posedge clk) begin
    if((VERBOSITY & MONITORE_FLIT_INJECT_FILEDS) > 0)begin 
        if(chi_noc_txreqflitv) begin 
        $display("%t: rnf ( %d ) txn ( %d ) send req flit: qos ( %d ) tgtid ( %d ) srcid ( %d ) returnnid ( %d ) endian ( %d ) returntxnid ( %d ) opcode ( %d ) flitsize ( %d ) addr ( %d ) ns ( %d ) likelyshared ( %d ).", $time, src_id,txnid, qos, tgtid,srcid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared);
        $display("%t: rnf ( %d ) txn ( %d ) send req flit: allowretry ( %d ) order ( %d ) pcrdtype ( %d ) memattr ( %d ) snpattr ( %d ) lpid ( %d ) excl_snoopme ( %d ) expcompack ( %d ) tracetag ( %d )", $time,src_id,txnid, allowretry,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag);
        end
    end
end

//synthesis translate_on 
//synopsys  translate_on


endmodule

