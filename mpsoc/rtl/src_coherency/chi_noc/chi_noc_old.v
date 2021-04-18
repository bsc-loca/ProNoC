/**************************************
* Module: chi_noc
* Date:2019-04-29  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  chi_noc_old #(
    
   // parameter MAP_CHI_chanel_ON= "VC", 
    /*
    "VC"= map each CHI chanel on one Virtual chanel. Only one chanel can send a flit at each clock cycle
    "PHY" map each CHI chanel in a seperate physical NoC
    */
    parameter B = 4,     // buffer space :flit per VC 
    parameter TOPOLOGY= "MESH",     
    parameter T1= 2,
    parameter T2= 2,
    parameter T3= 1,
    parameter T4= 8,  
    parameter ROUTE_NAME = "XY",
    parameter DEBUG_EN=1,      
    parameter REQ_FLIT_SIZE=10,
    parameter DAT_FLIT_SIZE=10,
    parameter RSP_FLIT_SIZE=10,
    parameter SNP_FLIT_SIZE=10
    )(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend_all,
    chi_noc_txreqflitv_all,
    chi_noc_txreqflit_all,
    noc_chi_txreqlcrdv_all,
    
    // TXDAT
    chi_noc_txdatflitpend_all,
    chi_noc_txdatflitv_all,
    chi_noc_txdatflit_all,
    noc_chi_txdatlcrdv_all,
    
    // TXRSP
    chi_noc_txrspflitpend_all,
    chi_noc_txrspflitv_all,
    chi_noc_txrspflit_all,
    noc_chi_txrsplcrdv_all,
    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop chanel so need target ID
    chi_noc_txsnpflitpend_all,
    chi_noc_txsnpflitv_all,
    chi_noc_txsnpflit_all,
    noc_chi_txsnplcrdv_all,         
    
     // RXREQ
    noc_chi_rxreqflitpend_all,
    noc_chi_rxreqflitv_all,
    noc_chi_rxreqflit_all,          
    chi_noc_rxreqlcrdv_all,      
    
    
    // CRSP/RXRSP
    noc_chi_rxrspflitpend_all,
    noc_chi_rxrspflitv_all,
    noc_chi_rxrspflit_all,
    chi_noc_rxrsplcrdv_all,
    
    // RDAT
    noc_chi_rxdatflitpend_all,
    noc_chi_rxdatflitv_all,
    noc_chi_rxdatflit_all,
    chi_noc_rxdatlcrdv_all, 
    
    // SNP/RXSNP
    noc_chi_rxsnpflitpend_all,
    noc_chi_rxsnpflitv_all,
    noc_chi_rxsnpflit_all,
    chi_noc_rxsnplcrdv_all,
    
    snp_target_id_all    
    );
            
    
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
 //   `include "../../src_noc/topology_localparam.v"    
   `include "../../src_noc/topology_localparam.v"    
    
    localparam 
        EAw_NE = EAw * NE,
        REQ_FLIT_SIZE_NE= NE * REQ_FLIT_SIZE,
        DAT_FLIT_SIZE_NE= NE * DAT_FLIT_SIZE,
        RSP_FLIT_SIZE_NE= NE * RSP_FLIT_SIZE,
        SNP_FLIT_SIZE_NE= NE * SNP_FLIT_SIZE;
    
    
    // Clock and Reset
    input clk,reset;
        
    input [EAw_NE-1 : 0]  snp_target_id_all;
    
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    input  [NE-1 : 0] chi_noc_txreqflitpend_all ;
    input  [NE-1 : 0] chi_noc_txreqflitv_all;
    input  [REQ_FLIT_SIZE_NE-1:0]    chi_noc_txreqflit_all;          
    output [NE-1 : 0] noc_chi_txreqlcrdv_all;
    // TXDAT
    input  [NE-1 : 0] chi_noc_txdatflitpend_all ;
    input  [NE-1 : 0] chi_noc_txdatflitv_all ;
    input  [DAT_FLIT_SIZE_NE-1:0]    chi_noc_txdatflit_all  ;
    output   [NE-1 : 0] noc_chi_txdatlcrdv_all ;
    // TXRSP
    input   [NE-1 : 0] chi_noc_txrspflitpend_all ;
    input  [NE-1 : 0] chi_noc_txrspflitv_all ;
    input  [RSP_FLIT_SIZE_NE-1:0]    chi_noc_txrspflit_all  ;
    output   [NE-1 : 0] noc_chi_txrsplcrdv_all ;
    // CRSP/RXRSP
    output   [NE-1 : 0] noc_chi_rxrspflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxrspflitv_all ;
    output   [RSP_FLIT_SIZE_NE-1:0]    noc_chi_rxrspflit_all ;
    input  [NE-1 : 0] chi_noc_rxrsplcrdv_all ;
    // RDAT
    output   [NE-1 : 0] noc_chi_rxdatflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxdatflitv_all ;
    output   [DAT_FLIT_SIZE_NE-1:0]    noc_chi_rxdatflit_all ;
    input  [NE-1 : 0] chi_noc_rxdatlcrdv_all ; 
    // SNP/RXSNP
    output   [NE-1 : 0] noc_chi_rxsnpflitpend_all ;
    output   [NE-1 : 0] noc_chi_rxsnpflitv_all ;
    output   [SNP_FLIT_SIZE_NE-1:0]    noc_chi_rxsnpflit_all ;
    input  [NE-1 : 0] chi_noc_rxsnplcrdv_all ;         
    
    
      //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id_all ; // we are not supporting braod casting on snoop chanel so need target ID
    input   [NE-1 : 0] chi_noc_txsnpflitpend_all ;
    input   [NE-1 : 0] chi_noc_txsnpflitv_all ;
    input   [SNP_FLIT_SIZE_NE-1:0]    chi_noc_txsnpflit_all ;
    output  [NE-1 : 0] noc_chi_txsnplcrdv_all ;         
    
     // RXREQ
    output  [NE-1 : 0] noc_chi_rxreqflitpend_all ;
    output  [NE-1 : 0] noc_chi_rxreqflitv_all;
    output  [REQ_FLIT_SIZE_NE-1:0]    noc_chi_rxreqflit_all;          
    input  [NE-1 : 0] chi_noc_rxreqlcrdv_all;   
    
   
    wire  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit [NE-1 : 0]; 
    wire  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit [NE-1 : 0]; 
    wire  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit [NE-1 : 0];
    wire  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit [NE-1 : 0];
    wire  [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit [NE-1 : 0];
    wire  [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit [NE-1 : 0];
    wire  [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit [NE-1 : 0];
    wire  [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit [NE-1 : 0];  
   
/*----------------------------------------------------------------------------*/
/*ProNoC interface */
/*----------------------------------------------------------------------------*/
 
 localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
        PRONOC_REQ_Fw = PRONOC_OFFSEET + REQ_FLIT_SIZE + 3,
        PRONOC_DAT_Fw = PRONOC_OFFSEET + DAT_FLIT_SIZE + 3,
        PRONOC_RSP_Fw = PRONOC_OFFSEET + RSP_FLIT_SIZE + 3,
        PRONOC_SNP_Fw = PRONOC_OFFSEET + SNP_FLIT_SIZE + 3;      
        
        
    //request chanel IO
    wire [PRONOC_REQ_Fw * NE-1 : 0] req_flit_out_all;
    wire [PRONOC_REQ_Fw-1 : 0] req_flit_out [NE-1 : 0];
    wire [NE-1 : 0] req_flit_out_wr_all;
    wire [NE-1 : 0] req_credit_in_all;
    wire [PRONOC_REQ_Fw * NE -1 : 0] req_flit_in_all;
    wire [PRONOC_REQ_Fw-1 : 0] req_flit_in [NE-1 : 0];
    wire [NE-1 : 0] req_flit_in_wr_all;  
    wire [NE-1 : 0] req_credit_out_all;
    
    //data chanel IO
    wire [PRONOC_DAT_Fw * NE -1 : 0] dat_flit_out_all;
    wire [PRONOC_DAT_Fw-1 : 0] dat_flit_out [NE-1 : 0];
    wire [NE-1 : 0] dat_flit_out_wr_all;
    wire [NE-1 : 0] dat_credit_in_all;
    wire [PRONOC_DAT_Fw * NE-1 : 0] dat_flit_in_all;
    wire [PRONOC_DAT_Fw-1 : 0] dat_flit_in [NE-1 : 0];
    wire [NE-1 : 0] dat_flit_in_wr_all;  
    wire [NE-1 : 0] dat_credit_out_all;

    //Response chanel IO
    wire [PRONOC_RSP_Fw * NE-1 : 0] rsp_flit_out_all;
    wire [PRONOC_RSP_Fw-1 : 0] rsp_flit_out [NE-1 : 0];
    wire [NE-1 : 0] rsp_flit_out_wr_all;
    wire [NE-1 : 0] rsp_credit_in_all;
    wire [PRONOC_RSP_Fw * NE-1 : 0] rsp_flit_in_all;
    wire [PRONOC_RSP_Fw-1 : 0] rsp_flit_in [NE-1 : 0];
    wire [NE-1 : 0] rsp_flit_in_wr_all;  
    wire [NE-1 : 0] rsp_credit_out_all;

    //snoop chanel IO
    wire [PRONOC_SNP_Fw * NE-1 : 0] snp_flit_out_all;
    wire [PRONOC_SNP_Fw-1 : 0] snp_flit_out [NE-1 : 0];
    wire [NE-1 : 0] snp_flit_out_wr_all;
    wire [NE-1 : 0] snp_credit_in_all;
    wire [PRONOC_SNP_Fw * NE-1 : 0] snp_flit_in_all;
    wire [PRONOC_SNP_Fw-1 : 0] snp_flit_in [NE-1 : 0];
    wire [NE-1 : 0] snp_flit_in_wr_all;  
    wire [NE-1 : 0] snp_credit_out_all;
    
    
    wire [EAw-1 : 0] snp_target_id [NE-1 : 0];
    
    
    genvar i;
    generate 
    for(i=0;i<NE;i=i+1)begin :ne
     //connected router encoded address
        localparam CURRENTR=  i/T3;
        localparam CURRENTX=  CURRENTR%T1;
        localparam CURRENTY=  CURRENTR/T1;
        localparam [RAw-1 : 0] CURRENT_ADDR =  (CURRENTY<<NXw) + CURRENTX; 
        
        assign snp_target_id [i] = snp_target_id_all[(i+1)* EAw-1 : i* EAw];
        
        assign chi_noc_txreqflit[i] = chi_noc_txreqflit_all[(i+1)*REQ_FLIT_SIZE-1 : i*REQ_FLIT_SIZE];
        assign chi_noc_txdatflit[i] = chi_noc_txdatflit_all[(i+1)*DAT_FLIT_SIZE-1 : i*DAT_FLIT_SIZE];
        assign chi_noc_txrspflit[i] = chi_noc_txrspflit_all[(i+1)*RSP_FLIT_SIZE-1 : i*RSP_FLIT_SIZE];
        assign chi_noc_txsnpflit[i] = chi_noc_txsnpflit_all[(i+1)*SNP_FLIT_SIZE-1 : i*SNP_FLIT_SIZE];
        
        assign noc_chi_rxreqflit_all [(i+1)*REQ_FLIT_SIZE-1 : i*REQ_FLIT_SIZE] = noc_chi_rxreqflit[i];
        assign noc_chi_rxdatflit_all [(i+1)*DAT_FLIT_SIZE-1 : i*DAT_FLIT_SIZE] = noc_chi_rxdatflit[i];
        assign noc_chi_rxrspflit_all [(i+1)*RSP_FLIT_SIZE-1 : i*RSP_FLIT_SIZE] = noc_chi_rxrspflit[i];
        assign noc_chi_rxsnpflit_all [(i+1)*SNP_FLIT_SIZE-1 : i*SNP_FLIT_SIZE] = noc_chi_rxsnpflit[i];  
        
        assign req_flit_out[i] = req_flit_out_all [(i+1)*PRONOC_REQ_Fw-1 : i*PRONOC_REQ_Fw];
        assign dat_flit_out[i] = dat_flit_out_all [(i+1)*PRONOC_DAT_Fw-1 : i*PRONOC_DAT_Fw];
        assign rsp_flit_out[i] = rsp_flit_out_all [(i+1)*PRONOC_RSP_Fw-1 : i*PRONOC_RSP_Fw];
        assign snp_flit_out[i] = snp_flit_out_all [(i+1)*PRONOC_SNP_Fw-1 : i*PRONOC_SNP_Fw];
        
        assign req_flit_in_all [(i+1)*PRONOC_REQ_Fw-1 : i*PRONOC_REQ_Fw] = req_flit_in[i];
        assign dat_flit_in_all [(i+1)*PRONOC_DAT_Fw-1 : i*PRONOC_DAT_Fw] = dat_flit_in[i];
        assign rsp_flit_in_all [(i+1)*PRONOC_RSP_Fw-1 : i*PRONOC_RSP_Fw] = rsp_flit_in[i];
        assign snp_flit_in_all [(i+1)*PRONOC_SNP_Fw-1 : i*PRONOC_SNP_Fw] = snp_flit_in[i];
        
        
        //chi to pronoc wrapper
        chi_to_pronoc_wrapper #(
            .CHI_FLIT_SIZE(REQ_FLIT_SIZE),
            .P(MAX_P),
            .T1(T1),
            .T2(T2),
            .T3(T3),
            .RAw(RAw),
            .EAw(EAw),
            .NE(NE),
            .DSTPw(DSTPw),
            .TOPOLOGY(TOPOLOGY),
            .ROUTE_NAME(ROUTE_NAME),
            .ROUTE_TYPE(ROUTE_TYPE)
        )
        req_wrapper
        (        
            .chi_flitpend_i(chi_noc_txreqflitpend_all[i]),
            .chi_flitv_i(chi_noc_txreqflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxreqlcrdv_all[i]),        
            .chi_flit_i(chi_noc_txreqflit[i]),            
            .current_r_addr_i(CURRENT_ADDR),             
            .pronoc_flit_o(req_flit_in[i]),
            .pronoc_flit_wr_o(req_flit_in_wr_all[i]),
            .pronoc_credit_o(req_credit_in_all[i]),
            .clk(clk)
        );
        
        
        chi_to_pronoc_wrapper #(
            .CHI_FLIT_SIZE(DAT_FLIT_SIZE),
            .P(MAX_P),
            .T1(T1),
            .T2(T2),
            .T3(T3),
            .RAw(RAw),
            .EAw(EAw),
            .NE(NE),
            .DSTPw(DSTPw),
            .TOPOLOGY(TOPOLOGY),
            .ROUTE_NAME(ROUTE_NAME),
            .ROUTE_TYPE(ROUTE_TYPE)
        )
        dat_wrapper
        (
            .chi_flitpend_i(chi_noc_txdatflitpend_all[i]),
            .chi_flitv_i(chi_noc_txdatflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxdatlcrdv_all[i]),        
            .chi_flit_i(chi_noc_txdatflit[i]),            
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(dat_flit_in[i]),
            .pronoc_flit_wr_o(dat_flit_in_wr_all[i]),
            .pronoc_credit_o(dat_credit_in_all[i]),
            .clk(clk)
        );
        
        
        chi_to_pronoc_wrapper #(
            .CHI_FLIT_SIZE(RSP_FLIT_SIZE),
            .P(MAX_P),
            .T1(T1),
            .T2(T2),
            .T3(T3),
            .RAw(RAw),
            .EAw(EAw),
            .NE(NE),
            .DSTPw(DSTPw),
            .TOPOLOGY(TOPOLOGY),
            .ROUTE_NAME(ROUTE_NAME),
            .ROUTE_TYPE(ROUTE_TYPE)
        )
        rsp_wrapper
        (
            .chi_flitpend_i(chi_noc_txrspflitpend_all[i]),
            .chi_flitv_i(chi_noc_txrspflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxrsplcrdv_all[i]),        
            .chi_flit_i(chi_noc_txrspflit[i]),            
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(rsp_flit_in[i]),
            .pronoc_flit_wr_o(rsp_flit_in_wr_all[i]),
            .pronoc_credit_o(rsp_credit_in_all[i]),
            .clk(clk)
        );
        
        
        
        chi_to_pronoc_snoop_wrapper #(
            .CHI_FLIT_SIZE(SNP_FLIT_SIZE),
            .P(MAX_P),
            .T1(T1),
            .T2(T2),
            .T3(T3),
            .RAw(RAw),
            .EAw(EAw),
            .NE(NE),
            .DSTPw(DSTPw),
            .TOPOLOGY(TOPOLOGY),
            .ROUTE_NAME(ROUTE_NAME),
            .ROUTE_TYPE(ROUTE_TYPE)
        )
        snp_wrapper
        (
            .chi_flitpend_i(chi_noc_txsnpflitpend_all[i]),
            .chi_flitv_i(chi_noc_txsnpflitv_all[i]),
            .chi_lcrdv_i(chi_noc_rxsnplcrdv_all[i]),        
            .chi_flit_i(chi_noc_txsnpflit[i]),
            .snp_target_id(snp_target_id[i]),//comes from home nodes
            .current_r_addr_i(CURRENT_ADDR),            
            .pronoc_flit_o(snp_flit_in[i]),
            .pronoc_flit_wr_o(snp_flit_in_wr_all[i]),
            .pronoc_credit_o(snp_credit_in_all[i])            
        );
        
       // pronoc to chi    
        
        //req
        pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(REQ_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_req
        (            
            .pronoc_flit_i(req_flit_out[i]),
            .pronoc_flit_wr_i(req_flit_out_wr_all[i]),
            .pronoc_credit_i(req_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxreqflit[i]),
            .chi_flitpend_o(noc_chi_rxreqflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxreqflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txreqlcrdv_all[i])
        );
        
        
        //data
         pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(DAT_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_dat
        (
            
            .pronoc_flit_i(dat_flit_out[i]),
            .pronoc_flit_wr_i(dat_flit_out_wr_all[i]),
            .pronoc_credit_i(dat_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxdatflit[i]),
            .chi_flitpend_o(noc_chi_rxdatflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxdatflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txdatlcrdv_all[i])
        );
        
        
         pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(RSP_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_rsp
        (
            
            .pronoc_flit_i(rsp_flit_out[i]),
            .pronoc_flit_wr_i(rsp_flit_out_wr_all[i]),
            .pronoc_credit_i(rsp_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxrspflit[i]),
            .chi_flitpend_o(noc_chi_rxrspflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxrspflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txrsplcrdv_all[i])
        );
        
        
        pronoc_to_chi_wrapper #(
            .CHI_FLIT_SIZE(SNP_FLIT_SIZE),
            .P(MAX_P),
            .EAw(EAw),
            .DSTPw(DSTPw)
        )
        pronoc_to_chi_wrapper_snp
        (            
            .pronoc_flit_i(snp_flit_out[i]),
            .pronoc_flit_wr_i(snp_flit_out_wr_all[i]),
            .pronoc_credit_i(snp_credit_out_all[i]),            
            .chi_flit_o(noc_chi_rxsnpflit[i]),
            .chi_flitpend_o(noc_chi_rxsnpflitpend_all[i]),
            .chi_flitv_o(noc_chi_rxsnpflitv_all[i]),
            .chi_lcrdv_o(noc_chi_txsnplcrdv_all[i])
        );       
    
   end
   endgenerate    
    
    
    
     noc #(
        .V(1),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .C(1),
        .Fpay(PRONOC_REQ_Fw-3),
        .MUX_TYPE("ONE_HOT"),
        .VC_REALLOCATION_TYPE("NONATOMIC"),
        .COMBINATION_TYPE("COMB_NONSPEC"),
        .FIRST_ARBITER_EXT_P_EN(1),
        .CONGESTION_INDEX(1),
        .DEBUG_EN(DEBUG_EN),
        .AVC_ATOMIC_EN(0),
        .ADD_PIPREG_AFTER_CROSSBAR(0),
        .SSA_EN("NO"),
        .SWA_ARBITER_TYPE("RRA"),
        .MIN_PCK_SIZE(1)
    )
    noc_req
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(req_flit_out_all),
        .flit_out_wr_all(req_flit_out_wr_all),
        .credit_in_all(req_credit_in_all),
        .flit_in_all(req_flit_in_all),
        .flit_in_wr_all(req_flit_in_wr_all),
        .credit_out_all(req_credit_out_all)
    );
    
    
     noc #(
        .V(1),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .C(1),
        .Fpay(PRONOC_DAT_Fw-3),
        .MUX_TYPE("ONE_HOT"),
        .VC_REALLOCATION_TYPE("NONATOMIC"),
        .COMBINATION_TYPE("COMB_NONSPEC"),
        .FIRST_ARBITER_EXT_P_EN(1),
        .CONGESTION_INDEX(1),
        .DEBUG_EN(DEBUG_EN),
        .AVC_ATOMIC_EN(0),
        .ADD_PIPREG_AFTER_CROSSBAR(0),
        .SSA_EN("NO"),
        .SWA_ARBITER_TYPE("RRA"),
        .MIN_PCK_SIZE(1)
    )
    noc_dat //data
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(dat_flit_out_all),
        .flit_out_wr_all(dat_flit_out_wr_all),
        .credit_in_all(dat_credit_in_all),
        .flit_in_all(dat_flit_in_all),
        .flit_in_wr_all(dat_flit_in_wr_all),
        .credit_out_all(dat_credit_out_all)
    );
    
    
    
     noc #(
        .V(1),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .C(1),
        .Fpay(PRONOC_RSP_Fw-3),
        .MUX_TYPE("ONE_HOT"),
        .VC_REALLOCATION_TYPE("NONATOMIC"),
        .COMBINATION_TYPE("COMB_NONSPEC"),
        .FIRST_ARBITER_EXT_P_EN(1),
        .CONGESTION_INDEX(1),
        .DEBUG_EN(DEBUG_EN),
        .AVC_ATOMIC_EN(0),
        .ADD_PIPREG_AFTER_CROSSBAR(0),
        .SSA_EN("NO"),
        .SWA_ARBITER_TYPE("RRA"),
        .MIN_PCK_SIZE(1)
    )
    noc_rsp //response
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(rsp_flit_out_all),
        .flit_out_wr_all(rsp_flit_out_wr_all),
        .credit_in_all(rsp_credit_in_all),
        .flit_in_all(rsp_flit_in_all),
        .flit_in_wr_all(rsp_flit_in_wr_all),
        .credit_out_all(rsp_credit_out_all)
    );
    
    
     noc #(
        .V(1),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .T4(T4),
        .ROUTE_NAME(ROUTE_NAME),
        .C(1),
        .Fpay(PRONOC_SNP_Fw-3),
        .MUX_TYPE("ONE_HOT"),
        .VC_REALLOCATION_TYPE("NONATOMIC"),
        .COMBINATION_TYPE("COMB_NONSPEC"),
        .FIRST_ARBITER_EXT_P_EN(1),
        .CONGESTION_INDEX(1),
        .DEBUG_EN(DEBUG_EN),
        .AVC_ATOMIC_EN(0),
        .ADD_PIPREG_AFTER_CROSSBAR(0),
        .SSA_EN("NO"),
        .SWA_ARBITER_TYPE("RRA"),
        .MIN_PCK_SIZE(1)
    )
    noc_snp//snoop
    (
        .reset(reset),
        .clk(clk),
        .flit_out_all(snp_flit_out_all),
        .flit_out_wr_all(snp_flit_out_wr_all),
        .credit_in_all(snp_credit_in_all),
        .flit_in_all(snp_flit_in_all),
        .flit_in_wr_all(snp_flit_in_wr_all),
        .credit_out_all(snp_credit_out_all)
    );

endmodule

