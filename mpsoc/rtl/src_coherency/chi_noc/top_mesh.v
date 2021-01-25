/**************************************
* Module: top_4x4
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  top_mesh #
(
    parameter VERBOSITY=0,
    parameter SYS_CACHE_EN=1,
    parameter B = 4,     // buffer space :flit per VC 
    parameter TOPOLOGY= "MESH",     
    parameter T1= 2,
    parameter T2= 2,
    parameter T3= 1,
    parameter ROUTE_NAME = "XY",
    parameter NUM_OF_RNs=2,
    parameter NUM_OF_HNs=1,
    parameter NUM_OF_SNs=1,

  
    parameter SNPF_WAY_NUM = 8,
    parameter SNPF_ADDRw   = 44,
    parameter SNPF_INDEXw  = 10,
    parameter CACHE_WAY_NUM= 8,
    parameter CACHE_INDEXw =10,

    //snf param 
    parameter MEM_RD_PIPE_LATENCY =50,
    parameter MEM_WR_PIPE_LATENCY =500
)
(
    reset,
    clk,
    
    //RN controls signals
    exclusive_all,
    likelyshared_all,
    
    
    ReqOpcode_all,
    Request_en_all,
    Write_dat_all, 
    read_addr_all,
 
    send_done_all,
    can_accept_new_req_all,  
    
    //core_cache_wr
    core_to_cache_wr_addr_all,
    core_to_cache_wr_data_all,
    core_to_cache_wr_state_all,
    core_to_cache_wr_action_all,
    core_to_cache_wr_en_all,
    core_to_cache_wr_evict_all,
    cache_to_core_wr_hit_all,
    cache_to_core_wr_done_all,
    cache_to_core_wr_ready_all
    
    
);
   
   
        
        
   
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
   
     localparam CACHE_ADDRw = ADDR_REQ,
              CACHE_DATAw = DATA_DAT;
   
   localparam        
      DEBUG_EN=1;  
   
   
   
      //control
    input reset,clk;
    
    
    
    input [NUM_OF_RNs-1 : 0] exclusive_all,likelyshared_all;
    input [(NUM_OF_RNs * OPCODE_REQ)-1 : 0 ] ReqOpcode_all;
    input [NUM_OF_RNs-1 : 0] Request_en_all;
    output[NUM_OF_RNs-1 : 0] send_done_all;
    output[NUM_OF_RNs-1 : 0] can_accept_new_req_all;
    
    
    input [DATA_DAT*NUM_OF_RNs-1 : 0] Write_dat_all; 
    input [ADDR_REQ*NUM_OF_RNs-1 : 0] read_addr_all;
   
   
 
    
    //core_cache_wr
    input [CACHE_ADDRw*NUM_OF_RNs-1 :0  ] core_to_cache_wr_addr_all;
    input [CACHE_DATAw*NUM_OF_RNs-1 : 0] core_to_cache_wr_data_all;
    input [CACHE_STATUSw*NUM_OF_RNs-1:0] core_to_cache_wr_state_all;
    input [CACHE_ACTw*NUM_OF_RNs-1:0] core_to_cache_wr_action_all;
    input [NUM_OF_RNs-1 : 0] core_to_cache_wr_en_all;
    input [NUM_OF_RNs-1 : 0] core_to_cache_wr_evict_all;
    output[NUM_OF_RNs-1 : 0] cache_to_core_wr_hit_all;
    output[NUM_OF_RNs-1 : 0] cache_to_core_wr_done_all;
    output [NUM_OF_RNs-1 : 0] cache_to_core_wr_ready_all;
    
    
    
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "../../src_noc/topology_localparam.v"  
    
        
    
    localparam 
        EAw_NE = EAw * NE,
        REQ_FLIT_SIZE_NE= NE * REQ_FLIT_SIZE,
        DAT_FLIT_SIZE_NE= NE * DAT_FLIT_SIZE,
        RSP_FLIT_SIZE_NE= NE * RSP_FLIT_SIZE,
        SNP_FLIT_SIZE_NE= NE * SNP_FLIT_SIZE;
    
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    wire  [NE-1 : 0] chi_noc_txreqflitpend_all ;
    wire  [NE-1 : 0] chi_noc_txreqflitv_all;
    wire  [REQ_FLIT_SIZE_NE-1:0]    chi_noc_txreqflit_all;          
    wire  [NE-1 : 0] noc_chi_txreqlcrdv_all;
    // TXDAT
    wire  [NE-1 : 0] chi_noc_txdatflitpend_all ;
    wire  [NE-1 : 0] chi_noc_txdatflitv_all ;
    wire  [DAT_FLIT_SIZE_NE-1:0]    chi_noc_txdatflit_all  ;
    wire  [NE-1 : 0] noc_chi_txdatlcrdv_all ;
    // TXRSP
    wire  [NE-1 : 0] chi_noc_txrspflitpend_all ;
    wire  [NE-1 : 0] chi_noc_txrspflitv_all ;
    wire  [RSP_FLIT_SIZE_NE-1:0]    chi_noc_txrspflit_all  ;
    wire  [NE-1 : 0] noc_chi_txrsplcrdv_all ;
    // CRSP/RXRSP
    wire  [NE-1 : 0] noc_chi_rxrspflitpend_all ;
    wire  [NE-1 : 0] noc_chi_rxrspflitv_all ;
    wire  [RSP_FLIT_SIZE_NE-1:0]    noc_chi_rxrspflit_all ;
    wire  [NE-1 : 0] chi_noc_rxrsplcrdv_all ;
    // RDAT
    wire  [NE-1 : 0] noc_chi_rxdatflitpend_all ;
    wire  [NE-1 : 0] noc_chi_rxdatflitv_all ;
    wire  [DAT_FLIT_SIZE_NE-1:0]    noc_chi_rxdatflit_all ;
    wire  [NE-1 : 0] chi_noc_rxdatlcrdv_all ; 
    // SNP/RXSNP
    wire  [NE-1 : 0] noc_chi_rxsnpflitpend_all ;
    wire  [NE-1 : 0] noc_chi_rxsnpflitv_all ;
    wire  [SNP_FLIT_SIZE_NE-1:0]    noc_chi_rxsnpflit_all ;
    wire  [NE-1 : 0] chi_noc_rxsnplcrdv_all ;         
    
    
      //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop channel so need target ID
    wire   [NE-1 : 0] chi_noc_txsnpflitpend_all ;
    wire   [NE-1 : 0] chi_noc_txsnpflitv_all ;
    wire   [SNP_FLIT_SIZE_NE-1:0]    chi_noc_txsnpflit_all ;
    wire  [NE-1 : 0] noc_chi_txsnplcrdv_all ;         
    
     // RXREQ
    wire  [NE-1 : 0] noc_chi_rxreqflitpend_all ;
    wire  [NE-1 : 0] noc_chi_rxreqflitv_all;
    wire  [REQ_FLIT_SIZE_NE-1:0]    noc_chi_rxreqflit_all;          
    wire  [NE-1 : 0] chi_noc_rxreqlcrdv_all;   
    
    wire [EAw_NE-1 : 0]  snp_target_id_all;
    wire [EAw-1 : 0] snp_target_id [NE-1 : 0];
   
   
    wire  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit [NE-1 : 0]; 
    wire  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit [NE-1 : 0]; 
    wire  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit [NE-1 : 0];
    wire  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit [NE-1 : 0];
    wire  [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit [NE-1 : 0];
    wire  [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit [NE-1 : 0];
    wire  [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit [NE-1 : 0];
    wire  [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit [NE-1 : 0];  
    
    
    
    
    
    
    chi_noc #(
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .ROUTE_NAME(ROUTE_NAME),
        .DEBUG_EN(DEBUG_EN),
        .REQ_FLIT_SIZE(REQ_FLIT_SIZE),
        .DAT_FLIT_SIZE(DAT_FLIT_SIZE),
        .RSP_FLIT_SIZE(RSP_FLIT_SIZE),
        .SNP_FLIT_SIZE(SNP_FLIT_SIZE)
        
    )
    the_chi_noc
    (
        .clk(clk),
        .reset(reset),
        .snp_target_id_all(snp_target_id_all),
        .chi_noc_txreqflitpend_all(chi_noc_txreqflitpend_all),
        .chi_noc_txreqflitv_all(chi_noc_txreqflitv_all),
        .chi_noc_txreqflit_all(chi_noc_txreqflit_all),
        .noc_chi_txreqlcrdv_all(noc_chi_txreqlcrdv_all),
        .chi_noc_txdatflitpend_all(chi_noc_txdatflitpend_all),
        .chi_noc_txdatflitv_all(chi_noc_txdatflitv_all),
        .chi_noc_txdatflit_all(chi_noc_txdatflit_all),
        .noc_chi_txdatlcrdv_all(noc_chi_txdatlcrdv_all),
        .chi_noc_txrspflitpend_all(chi_noc_txrspflitpend_all),
        .chi_noc_txrspflitv_all(chi_noc_txrspflitv_all),
        .chi_noc_txrspflit_all(chi_noc_txrspflit_all),
        .noc_chi_txrsplcrdv_all(noc_chi_txrsplcrdv_all),
        .noc_chi_rxrspflitpend_all(noc_chi_rxrspflitpend_all),
        .noc_chi_rxrspflitv_all(noc_chi_rxrspflitv_all),
        .noc_chi_rxrspflit_all(noc_chi_rxrspflit_all),
        .chi_noc_rxrsplcrdv_all(chi_noc_rxrsplcrdv_all),
        .noc_chi_rxdatflitpend_all(noc_chi_rxdatflitpend_all),
        .noc_chi_rxdatflitv_all(noc_chi_rxdatflitv_all),
        .noc_chi_rxdatflit_all(noc_chi_rxdatflit_all),
        .chi_noc_rxdatlcrdv_all(chi_noc_rxdatlcrdv_all),
        .noc_chi_rxsnpflitpend_all(noc_chi_rxsnpflitpend_all),
        .noc_chi_rxsnpflitv_all(noc_chi_rxsnpflitv_all),
        .noc_chi_rxsnpflit_all(noc_chi_rxsnpflit_all),
        .chi_noc_rxsnplcrdv_all(chi_noc_rxsnplcrdv_all),
        .chi_noc_txsnpflitpend_all(chi_noc_txsnpflitpend_all),
        .chi_noc_txsnpflitv_all(chi_noc_txsnpflitv_all),
        .chi_noc_txsnpflit_all(chi_noc_txsnpflit_all),
        .noc_chi_txsnplcrdv_all(noc_chi_txsnplcrdv_all),
        .noc_chi_rxreqflitpend_all(noc_chi_rxreqflitpend_all),
        .noc_chi_rxreqflitv_all(noc_chi_rxreqflitv_all),
        .noc_chi_rxreqflit_all(noc_chi_rxreqflit_all),
        .chi_noc_rxreqlcrdv_all(chi_noc_rxreqlcrdv_all)
    );
    
    
    
    
    
    
    
    
    genvar i;
    generate 
    for(i=0;i<NE;i=i+1)begin :ne
     //connected router encoded address       
        
        assign snp_target_id_all [(i+1)* EAw-1 : i* EAw] = snp_target_id[i];        
        assign chi_noc_txreqflit_all[(i+1)*REQ_FLIT_SIZE-1 : i*REQ_FLIT_SIZE] = chi_noc_txreqflit[i];
        assign chi_noc_txdatflit_all[(i+1)*DAT_FLIT_SIZE-1 : i*DAT_FLIT_SIZE] = chi_noc_txdatflit[i];
        assign chi_noc_txrspflit_all[(i+1)*RSP_FLIT_SIZE-1 : i*RSP_FLIT_SIZE] = chi_noc_txrspflit[i];
        assign chi_noc_txsnpflit_all[(i+1)*SNP_FLIT_SIZE-1 : i*SNP_FLIT_SIZE] = chi_noc_txsnpflit[i];
        
        assign noc_chi_rxreqflit[i] = noc_chi_rxreqflit_all [(i+1)*REQ_FLIT_SIZE-1 : i*REQ_FLIT_SIZE];
        assign noc_chi_rxdatflit[i] = noc_chi_rxdatflit_all [(i+1)*DAT_FLIT_SIZE-1 : i*DAT_FLIT_SIZE];
        assign noc_chi_rxrspflit[i] = noc_chi_rxrspflit_all [(i+1)*RSP_FLIT_SIZE-1 : i*RSP_FLIT_SIZE];
        assign noc_chi_rxsnpflit[i] = noc_chi_rxsnpflit_all [(i+1)*SNP_FLIT_SIZE-1 : i*SNP_FLIT_SIZE];    
    end
   
    
     //RNs are mapped to core 0 to to NUM_OF_RNs-1
    
 
   
    
    for(i=0;i<NUM_OF_RNs;i=i+1)begin: rn
        //connect request node to endp 1
        rnf #(            
            .NUM_OF_RNs(NUM_OF_RNs),
            .NUM_OF_HNs(NUM_OF_HNs), // must be power  of 2
            .CACHE_WAY_NUM(CACHE_WAY_NUM),
            //.CACHE_ADDRw(CACHE_ADDRw),
            .CACHE_INDEXw(CACHE_INDEXw),            
            .VERBOSITY(VERBOSITY),
           // .src_id(i),
            .EAw(EAw),
            .B(B)
        )
        the_rnf
        (
             .src_id(i),
            .clk(clk),
            .reset(reset),
            .exclusive(exclusive_all[i]),
            .likelyshared(likelyshared_all[i]),
            .ReqOpcode(ReqOpcode_all[(i+1)* OPCODE_REQ-1 : i*OPCODE_REQ ]),
            .Request_en(Request_en_all[i]),
            .Write_dat(Write_dat_all [DATA_DAT*(i+1)-1 : DATA_DAT*i]), 
            .read_addr(read_addr_all [ADDR_REQ*(i+1)-1 : ADDR_REQ*i]),
           
            .core_to_cache_wr_addr   (core_to_cache_wr_addr_all  [CACHE_ADDRw  *(i+1)-1 : CACHE_ADDRw  *i]),
            .core_to_cache_wr_data   (core_to_cache_wr_data_all  [CACHE_DATAw  *(i+1)-1 : CACHE_DATAw  *i]),
            .core_to_cache_wr_state  (core_to_cache_wr_state_all [CACHE_STATUSw*(i+1)-1 : CACHE_STATUSw*i]),
            .core_to_cache_wr_action (core_to_cache_wr_action_all[CACHE_ACTw   *(i+1)-1 : CACHE_ACTw   *i]),
            .core_to_cache_wr_en     (core_to_cache_wr_en_all    [ i]),
            .core_to_cache_wr_evict  (core_to_cache_wr_evict_all [ i ]),
            .cache_to_core_wr_hit    (cache_to_core_wr_hit_all   [ i]),
            .cache_to_core_wr_done   (cache_to_core_wr_done_all  [ i]),
            .cache_to_core_wr_ready  (cache_to_core_wr_ready_all [ i]),
           
           
            .send_done(send_done_all[i]),
            .can_accept_new_req(can_accept_new_req_all[i]),
            
            
            .chi_noc_txreqflitpend(chi_noc_txreqflitpend_all[i]),
            .chi_noc_txreqflitv(chi_noc_txreqflitv_all[i]),
            .chi_noc_txreqflit(chi_noc_txreqflit[i]),
            .noc_chi_txreqlcrdv(noc_chi_txreqlcrdv_all[i]),
            .chi_noc_txdatflitpend(chi_noc_txdatflitpend_all[i]),
            .chi_noc_txdatflitv(chi_noc_txdatflitv_all[i]),
            .chi_noc_txdatflit(chi_noc_txdatflit[i]),
            .noc_chi_txdatlcrdv(noc_chi_txdatlcrdv_all[i]),
            .chi_noc_txrspflitpend(chi_noc_txrspflitpend_all[i]),
            .chi_noc_txrspflitv(chi_noc_txrspflitv_all[i]),
            .chi_noc_txrspflit(chi_noc_txrspflit[i]),
            .noc_chi_txrsplcrdv(noc_chi_txrsplcrdv_all[i]),
            .noc_chi_rxrspflitpend(noc_chi_rxrspflitpend_all[i]),
            .noc_chi_rxrspflitv(noc_chi_rxrspflitv_all[i]),
            .noc_chi_rxrspflit(noc_chi_rxrspflit[i]),
            .chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv_all[i]),
            .noc_chi_rxdatflitpend(noc_chi_rxdatflitpend_all[i]),
            .noc_chi_rxdatflitv(noc_chi_rxdatflitv_all[i]),
            .noc_chi_rxdatflit(noc_chi_rxdatflit[i]),
            .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv_all[i]),
            .noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend_all[i]),
            .noc_chi_rxsnpflitv(noc_chi_rxsnpflitv_all[i]),
            .noc_chi_rxsnpflit(noc_chi_rxsnpflit[i]),
            .chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv_all[i]),
            .chi_noc_txsnpflitpend(chi_noc_txsnpflitpend_all[i]),
            .chi_noc_txsnpflitv(chi_noc_txsnpflitv_all[i]),
            .chi_noc_txsnpflit(chi_noc_txsnpflit[i]),
            .noc_chi_txsnplcrdv(noc_chi_txsnplcrdv_all[i]),
            .noc_chi_rxreqflitpend(noc_chi_rxreqflitpend_all[i]),
            .noc_chi_rxreqflitv(noc_chi_rxreqflitv_all[i]),
            .noc_chi_rxreqflit(noc_chi_rxreqflit[i]),
            .chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv_all[i]),
            .snp_target_id(snp_target_id[i])
        );
        
    
    end//RNs  
    
    /* verilator lint_off WIDTH */
    localparam 
        MAX_HNFs_ASSIGND_TO_A_SN = (NUM_OF_HNs  / NUM_OF_SNs) + ((NUM_OF_HNs  % NUM_OF_SNs)>0);
    /* verilator lint_on WIDTH */
    
    wire [SRCID_REQ*MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] assign_hnfs [NUM_OF_SNs-1 : 0];
    
    
    for(i=NUM_OF_RNs;i<NUM_OF_RNs+NUM_OF_HNs; i=i+1)begin: hn
       
       // devide SNs equally to HNs
        localparam 
            SN_NUM = ((i-NUM_OF_RNs) * NUM_OF_SNs )/NUM_OF_HNs,
            snf_id = SN_NUM + NUM_OF_RNs + NUM_OF_HNs,
            HN_NUM_IN_SN = ((i-NUM_OF_RNs) * NUM_OF_SNs )%NUM_OF_HNs;
            
            if(MAX_HNFs_ASSIGND_TO_A_SN>1) begin 
                assign assign_hnfs [SN_NUM ][(HN_NUM_IN_SN+1)*SRCID_REQ-1 : HN_NUM_IN_SN*SRCID_REQ]  =  i[SRCID_REQ-1 :0];  
            end
        
        hnf #(
           
            .VERBOSITY(VERBOSITY),
            .SYS_CACHE_EN(SYS_CACHE_EN),
            .EAw(EAw),
            .B(B),
            .NUM_OF_RNs(NUM_OF_RNs),
            .NUM_OF_HNs(NUM_OF_HNs),
            
           // .src_id(i),
            .SNPF_WAY_NUM(SNPF_WAY_NUM),
            .SNPF_ADDRw(SNPF_ADDRw),
            .SNPF_INDEXw(SNPF_INDEXw),
            
            
            .CACHE_WAY_NUM(CACHE_WAY_NUM),
            .CACHE_ADDRw(CACHE_ADDRw),
            .CACHE_INDEXw(CACHE_INDEXw)
           
        )
        hnf
        (
            .src_id(i),
            .snf_id(snf_id),
            
            .clk(clk),
            .reset(reset),
            .chi_noc_txreqflitpend(chi_noc_txreqflitpend_all[i]),
            .chi_noc_txreqflitv(chi_noc_txreqflitv_all[i]),
            .chi_noc_txreqflit(chi_noc_txreqflit[i]),
            .noc_chi_txreqlcrdv(noc_chi_txreqlcrdv_all[i]),
            .chi_noc_txdatflitpend(chi_noc_txdatflitpend_all[i]),
            .chi_noc_txdatflitv(chi_noc_txdatflitv_all[i]),
            .chi_noc_txdatflit(chi_noc_txdatflit[i]),
            .noc_chi_txdatlcrdv(noc_chi_txdatlcrdv_all[i]),
            .chi_noc_txrspflitpend(chi_noc_txrspflitpend_all[i]),
            .chi_noc_txrspflitv(chi_noc_txrspflitv_all[i]),
            .chi_noc_txrspflit(chi_noc_txrspflit[i]),
            .noc_chi_txrsplcrdv(noc_chi_txrsplcrdv_all[i]),
            .noc_chi_rxrspflitpend(noc_chi_rxrspflitpend_all[i]),
            .noc_chi_rxrspflitv(noc_chi_rxrspflitv_all[i]),
            .noc_chi_rxrspflit(noc_chi_rxrspflit[i]),
            .chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv_all[i]),
            .noc_chi_rxdatflitpend(noc_chi_rxdatflitpend_all[i]),
            .noc_chi_rxdatflitv(noc_chi_rxdatflitv_all[i]),
            .noc_chi_rxdatflit(noc_chi_rxdatflit[i]),
            .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv_all[i]),
            .noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend_all[i]),
            .noc_chi_rxsnpflitv(noc_chi_rxsnpflitv_all[i]),
            .noc_chi_rxsnpflit(noc_chi_rxsnpflit[i]),
            .chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv_all[i]),
            .chi_noc_txsnpflitpend(chi_noc_txsnpflitpend_all[i]),
            .chi_noc_txsnpflitv(chi_noc_txsnpflitv_all[i]),
            .chi_noc_txsnpflit(chi_noc_txsnpflit[i]),
            .noc_chi_txsnplcrdv(noc_chi_txsnplcrdv_all[i]),
            .noc_chi_rxreqflitpend(noc_chi_rxreqflitpend_all[i]),
            .noc_chi_rxreqflitv(noc_chi_rxreqflitv_all[i]),
            .noc_chi_rxreqflit(noc_chi_rxreqflit[i]),
            .chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv_all[i]),
            .snp_target_id(snp_target_id[i])
        );
    end
    
    
   
     
    
    for(i=NUM_OF_RNs+NUM_OF_HNs;i<NUM_OF_RNs+NUM_OF_HNs+NUM_OF_SNs; i=i+1)begin: sn
        
       snf #(
            .VERBOSITY(VERBOSITY),
            .MAX_HNFs_ASSIGND_TO_A_SN(MAX_HNFs_ASSIGND_TO_A_SN),
            //.src_id(i),
            .B(B),
            .EAw(EAw),
            .MEM_RD_PIPE_LATENCY(MEM_RD_PIPE_LATENCY),
            .MEM_WR_PIPE_LATENCY(MEM_WR_PIPE_LATENCY)
           
        )
        snf
        (
            
             .src_id(i),
            .clk(clk),
            .reset(reset),
           
            .chi_noc_txreqflitpend(chi_noc_txreqflitpend_all[i]),
            .chi_noc_txreqflitv(chi_noc_txreqflitv_all[i]),
            .chi_noc_txreqflit(chi_noc_txreqflit[i]),
            .noc_chi_txreqlcrdv(noc_chi_txreqlcrdv_all[i]),
            .chi_noc_txdatflitpend(chi_noc_txdatflitpend_all[i]),
            .chi_noc_txdatflitv(chi_noc_txdatflitv_all[i]),
            .chi_noc_txdatflit(chi_noc_txdatflit[i]),
            .noc_chi_txdatlcrdv(noc_chi_txdatlcrdv_all[i]),
            .chi_noc_txrspflitpend(chi_noc_txrspflitpend_all[i]),
            .chi_noc_txrspflitv(chi_noc_txrspflitv_all[i]),
            .chi_noc_txrspflit(chi_noc_txrspflit[i]),
            .noc_chi_txrsplcrdv(noc_chi_txrsplcrdv_all[i]),
            .noc_chi_rxrspflitpend(noc_chi_rxrspflitpend_all[i]),
            .noc_chi_rxrspflitv(noc_chi_rxrspflitv_all[i]),
            .noc_chi_rxrspflit(noc_chi_rxrspflit[i]),
            .chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv_all[i]),
            .noc_chi_rxdatflitpend(noc_chi_rxdatflitpend_all[i]),
            .noc_chi_rxdatflitv(noc_chi_rxdatflitv_all[i]),
            .noc_chi_rxdatflit(noc_chi_rxdatflit[i]),
            .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv_all[i]),
            .noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend_all[i]),
            .noc_chi_rxsnpflitv(noc_chi_rxsnpflitv_all[i]),
            .noc_chi_rxsnpflit(noc_chi_rxsnpflit[i]),
            .chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv_all[i]),
            .chi_noc_txsnpflitpend(chi_noc_txsnpflitpend_all[i]),
            .chi_noc_txsnpflitv(chi_noc_txsnpflitv_all[i]),
            .chi_noc_txsnpflit(chi_noc_txsnpflit[i]),
            .noc_chi_txsnplcrdv(noc_chi_txsnplcrdv_all[i]),
            .noc_chi_rxreqflitpend(noc_chi_rxreqflitpend_all[i]),
            .noc_chi_rxreqflitv(noc_chi_rxreqflitv_all[i]),
            .noc_chi_rxreqflit(noc_chi_rxreqflit[i]),
            .chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv_all[i]),
            .snp_target_id(snp_target_id[i]),
            
            .assign_hnfs(assign_hnfs[i-(NUM_OF_RNs+NUM_OF_HNs)])
        );   
    
    end//for
     
    
    endgenerate
    
    
   
    








endmodule








