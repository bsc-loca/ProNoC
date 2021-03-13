/**************************************
* Module: hnf_tx_snp
* Date:2019-06-04  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  hnf_tx_snp #(
    parameter B=4,
    parameter EAw=3,
    parameter VERBOSITY=0,
   // parameter src_id=1,
    parameter SNPF_SPVw=5

)(
    src_id,
    //CHI TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop chanel so need target ID
    chi_noc_txsnpflitpend,
    chi_noc_txsnpflitv,
    chi_noc_txsnpflit,
    noc_chi_txsnplcrdv,
    snp_target_id,     
    
    //rxreq
    txsnp_to_rxreq_ready,
    rxreq_to_txsnp_spv,
    rxreq_to_txsnp_we,
    rxreq_to_txsnp_txnid,
    rxreq_to_txsnp_fwdnid,
    rxreq_to_txsnp_fwdtxnid,
    rxreq_to_txsnp_opcode,
    rxreq_to_txsnp_addr,
    rxreq_to_txsnp_rettosrc,   
    
    
    //general
    reset,
    clk

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"            
     
    input [31 : 0] src_id;                 
   
    //TXSNP // snoop tx home node
    output   chi_noc_txsnpflitpend ;
    output   reg chi_noc_txsnpflitv ;
    output   [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit;
    input    noc_chi_txsnplcrdv ; 
    output   [EAw-1 : 0]  snp_target_id;   
    
    
    // rxreq
    output reg txsnp_to_rxreq_ready;
    input [SNPF_SPVw-1  : 0] rxreq_to_txsnp_spv;
    input rxreq_to_txsnp_we;
    input [TXNID_SNP-1   :0] rxreq_to_txsnp_txnid;
    input [FWDNID_SNP-1  :0] rxreq_to_txsnp_fwdnid;
    input [FWDTXNID_SNP-1:0] rxreq_to_txsnp_fwdtxnid;
    input [OPCODE_SNP-1  :0] rxreq_to_txsnp_opcode;
    input [ADDR_SNP-1    :0] rxreq_to_txsnp_addr;
    input rxreq_to_txsnp_rettosrc;   
    
  
    
    
    //general
    input reset,clk;
    
    reg  [SNPF_SPVw-1  : 0] spv, spv_next;
    wire [SNPF_SPVw-1  : 0] target_rn;
    wire any_target;
    wire have_cridit;    
         
    reg [QOS_SNP-1:0]             qos; // = {QOS_REQ{1'b0}};
    reg [SRCID_SNP-1:0]           srcid  ;
    reg [TXNID_SNP-1:0]           txnid  ;
    reg [FWDNID_SNP-1:0]          fwdnid  ;
    reg [FWDTXNID_SNP-1:0]        fwdtxnid  ;
    reg [OPCODE_SNP-1:0]          opcode ;
    reg [ADDR_SNP-1:0]            addr ;
    reg                           ns ;
    reg                           donotgotosd_datapull ;
    reg                           rettosrc ;
    reg                           tracetag; // = 1'b0;
    
    reg reset_rettosrc;
    
    assign  chi_noc_txsnpflitpend = 1'b1 ;
    assign  chi_noc_txsnpflit ={ qos, srcid, txnid, fwdnid, fwdtxnid, opcode, addr, ns, donotgotosd_datapull , rettosrc, tracetag};
    
    reg [1:0] pst,nst;
    localparam IDEAL =1 ;
    localparam SEND_SNOOP=2;
      
    
    always @(*) begin
        txsnp_to_rxreq_ready=1'b1;
        nst = pst;
        chi_noc_txsnpflitv=1'b0;
        
        reset_rettosrc=1'b0;// only one snop request with rettosrc asserted should be send
        
        // snp flit default values
        qos = {QOS_REQ{1'b0}};
        srcid = src_id;
        ns=1'b0; // not secure?
        donotgotosd_datapull=1'b0; // Applicable in SnpResp and SnpRespData response to a Stash request, not applicable in all other Snoop responses.
        tracetag = 1'b0;
        spv_next = spv;
        case(pst) 
        IDEAL: begin 
            if(  rxreq_to_txsnp_we ) begin 
                nst = SEND_SNOOP;
                spv_next = rxreq_to_txsnp_spv;
            end        
        end
        SEND_SNOOP : begin 
            txsnp_to_rxreq_ready=1'b0; // Donot get any new request untill sendinhg snoop to all RNs in spv
            if(any_target)begin 
              if( have_cridit) begin 
                spv_next = spv & ~(target_rn); // clear the target snoope from the spv 
                chi_noc_txsnpflitv = 1'b1;
                reset_rettosrc=1'b1;    
                
              
              end// have_cridit            
            end else begin // We are done as all snoop requsrts are sent
                nst = IDEAL;
                
            end        
        end //SEND_SNOOP
        endcase     
    end//always
    
    
    
    always @(posedge clk) begin
        if(reset)begin
            pst<= IDEAL;
            spv <= {SNPF_SPVw{1'b0}};
        end else begin
            pst<=nst;
            spv <= spv_next;
        end
    end
    
    //capture snoop data on we
    always @(posedge clk) begin
         if (rxreq_to_txsnp_we ) begin 
            txnid <= rxreq_to_txsnp_txnid;
            fwdnid <= rxreq_to_txsnp_fwdnid;
            fwdtxnid <= rxreq_to_txsnp_fwdtxnid;
            opcode <= rxreq_to_txsnp_opcode;
            addr <= rxreq_to_txsnp_addr;  
            rettosrc <= rxreq_to_txsnp_rettosrc;
         end
         else if (reset_rettosrc) rettosrc<=1'b0;
    end
    
    // select one snoope at a time. we dont support broad casting yet
    arbiter #(
    	.ARBITER_WIDTH(SNPF_SPVw)
    )
    arbiter
    (
    	.request(spv),
    	.grant(target_rn),
    	.any_grant(any_target),
    	.clk(clk),
    	.reset(reset)
    );
    
    // get the target id of one-hot target_rn
    spv_to_rnfid_addr_decode #(
        .SPVw(SNPF_SPVw),
        .IDw(EAw)
    )
    addr_decode
    (
        .rnf_id_o(snp_target_id),
        .rnf_spv_i(target_rn)
    );
    
    // check the credit availabilit in NoC
    credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txsnpflitv),
        .noc_chi_lcrdv( noc_chi_txsnplcrdv),
        .have_cridit(have_cridit),
         .nearly_full(),
        .reset(reset),
        .clk(clk)
     );
    
    
    //synthesis translate_off 
    //synopsys  translate_off
    
    wire opcode_fw_type =  
        (opcode == SNP_OPCODE_SnpSharedFwd) |
        (opcode == SNP_OPCODE_SnpCleanFwd)|
        (opcode == SNP_OPCODE_SnpOnceFwd)|
        (opcode == SNP_OPCODE_SnpNotSharedDirtyFwd)|
        (opcode == SNP_OPCODE_SnpUniqueFwd); 
    
    always @(posedge clk)begin
        if ((pst == SEND_SNOOP) &&  (spv_next>0) && (any_target &  have_cridit & opcode_fw_type)  ) begin
            $display("%t: Error hnf (%d) is sending forwarding type snoop request (opcode=%d) to more than one requester which is not allowed in ambachi spec C ) ",$time,src_id,opcode); 
            $stop;
        end
    end    
    
    
    
    
    generate 
    if((VERBOSITY & MONITORE_FLIT_OPCODE) > 0)begin :debug
    
        monitor_snp_flit #(
            .AGENT_NAME("hnf"),
            .EAw(EAw),
            .TYPE("TX")
        )
        monitor
        (
            .clk(clk),
            .snp_target_id(snp_target_id),
            .monitor (chi_noc_txsnpflitv),
            .snp_flit(chi_noc_txsnpflit),
            .src_id(src_id)
        );
    
    end
    endgenerate
       


    
    
    
    
    //synthesis translate_on 
    //synopsys  translate_on
    
    

endmodule

