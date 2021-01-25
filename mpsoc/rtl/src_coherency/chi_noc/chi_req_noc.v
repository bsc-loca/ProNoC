/**************************************
* Module: chi_req_noc
* Date:2020-02-28  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  chi_req_noc #(
    parameter B = 4,     // buffer space :flit per VC 
    parameter TOPOLOGY= "MESH",     
    parameter T1= 2,
    parameter T2= 2,
    parameter T3= 1,
    parameter T4= 8,  
    parameter ROUTE_NAME = "XY",
    parameter DEBUG_EN=1,      
    parameter REQ_FLIT_SIZE=10
    )(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend_all,
    chi_noc_txreqflitv_all,
    chi_noc_txreqflit_all,
    noc_chi_txreqlcrdv_all,
      
    
     // RXREQ
    noc_chi_rxreqflitpend_all,
    noc_chi_rxreqflitv_all,
    noc_chi_rxreqflit_all,          
    chi_noc_rxreqlcrdv_all
    
 
    );
            
    
      
`define INCLUDE_TOPOLOGY_LOCALPARAM
`ifdef VERILATOR
     `include "topology_localparam.v"    
`else
   `include "../../src_noc/topology_localparam.v"    
`endif


    localparam 
        EAw_NE = EAw * NE,
        REQ_FLIT_SIZE_NE= NE * REQ_FLIT_SIZE;
      
    
    
    // Clock and Reset
    input clk,reset;
        
    
    
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    input  [NE-1 : 0] chi_noc_txreqflitpend_all ;
    input  [NE-1 : 0] chi_noc_txreqflitv_all;
    input  [REQ_FLIT_SIZE_NE-1:0]    chi_noc_txreqflit_all;          
    output [NE-1 : 0] noc_chi_txreqlcrdv_all;
   
    
     // RXREQ
    output  [NE-1 : 0] noc_chi_rxreqflitpend_all ;
    output  [NE-1 : 0] noc_chi_rxreqflitv_all;
    output  [REQ_FLIT_SIZE_NE-1:0]    noc_chi_rxreqflit_all;          
    input  [NE-1 : 0] chi_noc_rxreqlcrdv_all;   
    
   
    wire  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit [NE-1 : 0]; 
    wire  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit [NE-1 : 0]; 
  
   
/*----------------------------------------------------------------------------*/
/*ProNoC interface */
/*----------------------------------------------------------------------------*/
 
 localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,       
        PRONOC_REQ_Fw = PRONOC_OFFSEET + REQ_FLIT_SIZE + 3;
       
        
    //request channel IO
    wire [PRONOC_REQ_Fw * NE-1 : 0] req_flit_out_all;
    wire [PRONOC_REQ_Fw-1 : 0] req_flit_out [NE-1 : 0];
    wire [NE-1 : 0] req_flit_out_wr_all;
    wire [NE-1 : 0] req_credit_in_all;
    wire [PRONOC_REQ_Fw * NE -1 : 0] req_flit_in_all;
    wire [PRONOC_REQ_Fw-1 : 0] req_flit_in [NE-1 : 0];
    wire [NE-1 : 0] req_flit_in_wr_all;  
    wire [NE-1 : 0] req_credit_out_all;
    
  
    
    
    genvar i;
    generate 
    for(i=0;i<NE;i=i+1)begin :ne
     //connected router encoded address
        localparam CURRENTR=  i/T3;
        localparam CURRENTX=  CURRENTR%T1;
        localparam CURRENTY=  CURRENTR/T1;
        localparam [RAw-1 : 0] CURRENT_ADDR =  (CURRENTY<<NXw) + CURRENTX; 
        
           
        assign chi_noc_txreqflit[i] = chi_noc_txreqflit_all[(i+1)*REQ_FLIT_SIZE-1 : i*REQ_FLIT_SIZE];
    
        
        assign noc_chi_rxreqflit_all [(i+1)*REQ_FLIT_SIZE-1 : i*REQ_FLIT_SIZE] = noc_chi_rxreqflit[i];
     
        
        assign req_flit_out[i] = req_flit_out_all [(i+1)*PRONOC_REQ_Fw-1 : i*PRONOC_REQ_Fw];
   
        
        assign req_flit_in_all [(i+1)*PRONOC_REQ_Fw-1 : i*PRONOC_REQ_Fw] = req_flit_in[i];
      
        
        
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
        
        
      
        
       // pronoc to chi    
        
      
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

endmodule