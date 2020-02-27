/**************************************
* Module: top_4x4
* Date:2019-05-07  
* Author: alireza     
*
* Description: 
***************************************/
module  top_4x4(
    reset,
    clk,
    //control
    Readshared,
    ReadUnique, 
    MakeUnique,
    WriteBackFull,
    read_addr,
    send_done
);


   parameter REQ_ADDR_SIZ =32;
   
   
   
    `define INCLUDE_CHI_LOCALPARAM
    `include "chi_localparam.v"
   
   
   
   localparam  
      B = 4,     // buffer space :flit per VC 
      TOPOLOGY= "MESH",     
      T1= 2,
      T2= 2,
      T3= 1,
      ROUTE_NAME = "XY",
      DEBUG_EN=1;  
   
   
   
      //control
    input reset,clk;
    input Readshared;
    input ReadUnique; 
    input MakeUnique;
    input WriteBackFull;
    input [REQ_ADDR_SIZ-1 : 0] read_addr;
    output send_done;
   
    
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
    endgenerate
    
    
    
    
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
    
    
//connect request node to endp 1
rnf #(
    .REQ_ADDR_SIZ(REQ_ADDR_SIZ), 
	.REQ_FLIT_SIZE(REQ_FLIT_SIZE),
	.DAT_FLIT_SIZE(DAT_FLIT_SIZE),
	.RSP_FLIT_SIZE(RSP_FLIT_SIZE),
	.SNP_FLIT_SIZE(SNP_FLIT_SIZE),
	//.src_id(0),
	.EAw(EAw),
	.B(B)
)
rnf
(
	.src_id(0),
	.clk(clk),
	.reset(reset),
	.Readshared(Readshared),
    .ReadUnique(ReadUnique),
    .MakeUnique(MakeUnique),
    .WriteBackFull(WriteBackFull),
    .read_addr(read_addr),
    .send_done(send_done),
	
	
	.chi_noc_txreqflitpend(chi_noc_txreqflitpend_all[0]),
	.chi_noc_txreqflitv(chi_noc_txreqflitv_all[0]),
	.chi_noc_txreqflit(chi_noc_txreqflit[0]),
	.noc_chi_txreqlcrdv(noc_chi_txreqlcrdv_all[0]),
	.chi_noc_txdatflitpend(chi_noc_txdatflitpend_all[0]),
	.chi_noc_txdatflitv(chi_noc_txdatflitv_all[0]),
	.chi_noc_txdatflit(chi_noc_txdatflit[0]),
	.noc_chi_txdatlcrdv(noc_chi_txdatlcrdv_all[0]),
	.chi_noc_txrspflitpend(chi_noc_txrspflitpend_all[0]),
	.chi_noc_txrspflitv(chi_noc_txrspflitv_all[0]),
	.chi_noc_txrspflit(chi_noc_txrspflit[0]),
	.noc_chi_txrsplcrdv(noc_chi_txrsplcrdv_all[0]),
	.noc_chi_rxrspflitpend(noc_chi_rxrspflitpend_all[0]),
	.noc_chi_rxrspflitv(noc_chi_rxrspflitv_all[0]),
	.noc_chi_rxrspflit(noc_chi_rxrspflit[0]),
	.chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv_all[0]),
	.noc_chi_rxdatflitpend(noc_chi_rxdatflitpend_all[0]),
	.noc_chi_rxdatflitv(noc_chi_rxdatflitv_all[0]),
	.noc_chi_rxdatflit(noc_chi_rxdatflit[0]),
	.chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv_all[0]),
	.noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend_all[0]),
	.noc_chi_rxsnpflitv(noc_chi_rxsnpflitv_all[0]),
	.noc_chi_rxsnpflit(noc_chi_rxsnpflit[0]),
	.chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv_all[0]),
	.chi_noc_txsnpflitpend(chi_noc_txsnpflitpend_all[0]),
	.chi_noc_txsnpflitv(chi_noc_txsnpflitv_all[0]),
	.chi_noc_txsnpflit(chi_noc_txsnpflit[0]),
	.noc_chi_txsnplcrdv(noc_chi_txsnplcrdv_all[0]),
	.noc_chi_rxreqflitpend(noc_chi_rxreqflitpend_all[0]),
	.noc_chi_rxreqflitv(noc_chi_rxreqflitv_all[0]),
	.noc_chi_rxreqflit(noc_chi_rxreqflit[0]),
	.chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv_all[0]),
	.snp_target_id(snp_target_id[0])
);



//connect home node to endp 1
hnf #(
    .REQ_FLIT_SIZE(REQ_FLIT_SIZE),
    .DAT_FLIT_SIZE(DAT_FLIT_SIZE),
    .RSP_FLIT_SIZE(RSP_FLIT_SIZE),
    .SNP_FLIT_SIZE(SNP_FLIT_SIZE),
  //  .src_id(1),
    .EAw(EAw)
)
hnf
(
    .src_id(1),
    .clk(clk),
    .reset(reset),
    .chi_noc_txreqflitpend(chi_noc_txreqflitpend_all[1]),
    .chi_noc_txreqflitv(chi_noc_txreqflitv_all[1]),
    .chi_noc_txreqflit(chi_noc_txreqflit[1]),
    .noc_chi_txreqlcrdv(noc_chi_txreqlcrdv_all[1]),
    .chi_noc_txdatflitpend(chi_noc_txdatflitpend_all[1]),
    .chi_noc_txdatflitv(chi_noc_txdatflitv_all[1]),
    .chi_noc_txdatflit(chi_noc_txdatflit[1]),
    .noc_chi_txdatlcrdv(noc_chi_txdatlcrdv_all[1]),
    .chi_noc_txrspflitpend(chi_noc_txrspflitpend_all[1]),
    .chi_noc_txrspflitv(chi_noc_txrspflitv_all[1]),
    .chi_noc_txrspflit(chi_noc_txrspflit[1]),
    .noc_chi_txrsplcrdv(noc_chi_txrsplcrdv_all[1]),
    .noc_chi_rxrspflitpend(noc_chi_rxrspflitpend_all[1]),
    .noc_chi_rxrspflitv(noc_chi_rxrspflitv_all[1]),
    .noc_chi_rxrspflit(noc_chi_rxrspflit[1]),
    .chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv_all[1]),
    .noc_chi_rxdatflitpend(noc_chi_rxdatflitpend_all[1]),
    .noc_chi_rxdatflitv(noc_chi_rxdatflitv_all[1]),
    .noc_chi_rxdatflit(noc_chi_rxdatflit[1]),
    .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv_all[1]),
    .noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend_all[1]),
    .noc_chi_rxsnpflitv(noc_chi_rxsnpflitv_all[1]),
    .noc_chi_rxsnpflit(noc_chi_rxsnpflit[1]),
    .chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv_all[1]),
    .chi_noc_txsnpflitpend(chi_noc_txsnpflitpend_all[1]),
    .chi_noc_txsnpflitv(chi_noc_txsnpflitv_all[1]),
    .chi_noc_txsnpflit(chi_noc_txsnpflit[1]),
    .noc_chi_txsnplcrdv(noc_chi_txsnplcrdv_all[1]),
    .noc_chi_rxreqflitpend(noc_chi_rxreqflitpend_all[1]),
    .noc_chi_rxreqflitv(noc_chi_rxreqflitv_all[1]),
    .noc_chi_rxreqflit(noc_chi_rxreqflit[1]),
    .chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv_all[1]),
    .snp_target_id(snp_target_id[1])
);



//connect slave node to endp 2
snf #(
    .REQ_FLIT_SIZE(REQ_FLIT_SIZE),
    .DAT_FLIT_SIZE(DAT_FLIT_SIZE),
    .RSP_FLIT_SIZE(RSP_FLIT_SIZE),
    .SNP_FLIT_SIZE(SNP_FLIT_SIZE),
    .EAw(EAw)
)
snf
(
    .clk(clk),
    .reset(reset),
    .chi_noc_txreqflitpend(chi_noc_txreqflitpend_all[2]),
    .chi_noc_txreqflitv(chi_noc_txreqflitv_all[2]),
    .chi_noc_txreqflit(chi_noc_txreqflit[2]),
    .noc_chi_txreqlcrdv(noc_chi_txreqlcrdv_all[2]),
    .chi_noc_txdatflitpend(chi_noc_txdatflitpend_all[2]),
    .chi_noc_txdatflitv(chi_noc_txdatflitv_all[2]),
    .chi_noc_txdatflit(chi_noc_txdatflit[2]),
    .noc_chi_txdatlcrdv(noc_chi_txdatlcrdv_all[2]),
    .chi_noc_txrspflitpend(chi_noc_txrspflitpend_all[2]),
    .chi_noc_txrspflitv(chi_noc_txrspflitv_all[2]),
    .chi_noc_txrspflit(chi_noc_txrspflit[2]),
    .noc_chi_txrsplcrdv(noc_chi_txrsplcrdv_all[2]),
    .noc_chi_rxrspflitpend(noc_chi_rxrspflitpend_all[2]),
    .noc_chi_rxrspflitv(noc_chi_rxrspflitv_all[2]),
    .noc_chi_rxrspflit(noc_chi_rxrspflit[2]),
    .chi_noc_rxrsplcrdv(chi_noc_rxrsplcrdv_all[2]),
    .noc_chi_rxdatflitpend(noc_chi_rxdatflitpend_all[2]),
    .noc_chi_rxdatflitv(noc_chi_rxdatflitv_all[2]),
    .noc_chi_rxdatflit(noc_chi_rxdatflit[2]),
    .chi_noc_rxdatlcrdv(chi_noc_rxdatlcrdv_all[2]),
    .noc_chi_rxsnpflitpend(noc_chi_rxsnpflitpend_all[2]),
    .noc_chi_rxsnpflitv(noc_chi_rxsnpflitv_all[2]),
    .noc_chi_rxsnpflit(noc_chi_rxsnpflit[2]),
    .chi_noc_rxsnplcrdv(chi_noc_rxsnplcrdv_all[2]),
    .chi_noc_txsnpflitpend(chi_noc_txsnpflitpend_all[2]),
    .chi_noc_txsnpflitv(chi_noc_txsnpflitv_all[2]),
    .chi_noc_txsnpflit(chi_noc_txsnpflit[2]),
    .noc_chi_txsnplcrdv(noc_chi_txsnplcrdv_all[2]),
    .noc_chi_rxreqflitpend(noc_chi_rxreqflitpend_all[2]),
    .noc_chi_rxreqflitv(noc_chi_rxreqflitv_all[2]),
    .noc_chi_rxreqflit(noc_chi_rxreqflit[2]),
    .chi_noc_rxreqlcrdv(chi_noc_rxreqlcrdv_all[2]),
    .snp_target_id(snp_target_id[2])
);




endmodule








