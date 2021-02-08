/**************************************
* Module: chi_wrapper
* Date:2019-05-03  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  chi_to_pronoc_wrapper #(
    parameter  CHI_FLIT_SIZE = 50, // CHI chanel data width
    parameter P         =5,
    parameter T1= 8,
    parameter T2= 8,
    parameter T3= 1,
    parameter RAw = 3,  
    parameter EAw = 3, 
    parameter NE=64,
    parameter DSTPw=P-1,
    parameter TOPOLOGY  ="MESH",//"MESH","TORUS"
    parameter ROUTE_NAME="XY",// 
    parameter ROUTE_TYPE="DETERMINISTIC",
    parameter BYTE_EN=0
)(
    chi_flit_i,
    chi_flitpend_i,
    chi_flitv_i,
    chi_lcrdv_i,   
   
    current_r_addr_i,
    
    pronoc_flit_o,
    pronoc_flit_wr_o,
    pronoc_credit_o,
    
    clk
);


   

    input chi_flitpend_i,   chi_flitv_i,     chi_lcrdv_i, clk;
    output pronoc_flit_wr_o,     pronoc_credit_o;
    
    assign pronoc_flit_wr_o = chi_flitv_i;
    assign pronoc_credit_o = chi_lcrdv_i;



   localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,
        PRONOC_PYLDw   =   PRONOC_OFFSEET + CHI_FLIT_SIZE,
        PRONOC_FLIT_SIZE = PRONOC_PYLDw + 3;

    input [CHI_FLIT_SIZE-1 : 0]  chi_flit_i;
    input [RAw-1 : 0] current_r_addr_i;
    output [PRONOC_FLIT_SIZE-1 : 0]  pronoc_flit_o;
    
    // chi mst significent bits
    localparam QOS_REQ = 4;
    localparam TGTID_REQ = 7; //it can be from 7-11
    localparam SRCID_REQ = 7; //it can be from 7-11

    wire [TGTID_REQ-1 : 0] target_id;
    wire [SRCID_REQ-1 : 0] src_id;
    assign {target_id,src_id} = chi_flit_i[CHI_FLIT_SIZE-1-QOS_REQ  :  CHI_FLIT_SIZE-QOS_REQ-TGTID_REQ-SRCID_REQ];

   
    wire [ EAw-1 : 0] dest_e_addr;// = target_id[ EAw-1 : 0];//TODO need to check how they code the destiation adreeses
    wire [ EAw-1 : 0] src_e_addr;// = src_id[ EAw-1 : 0];//TODO need to check how they code the source adreeses
   
    
    mesh_tori_addr_encoder #(
    	.NX(T1),
    	.NY(T2),
    	.NL(T3),
    	.NE(NE),
    	.EAw(EAw),
    	.TOPOLOGY("MESH")
    )
    des_addr_encoder
    (
    	.id(target_id[EAw-1:0]),
    	.code(dest_e_addr)
    );
    
    mesh_tori_addr_encoder #(
        .NX(T1),
        .NY(T2),
        .NL(T3),
        .NE(NE),
        .EAw(EAw),
        .TOPOLOGY("MESH")
    )
    src_addr_encoder
    (
        .id(src_id[EAw-1:0]),
        .code(src_e_addr)
    );
    
    
    wire [DSTPw-1: 0] destport;  
    
   
    wire [PRONOC_FLIT_SIZE-1 : 0] pronoc_hdr_flit;
    
        
    conventional_routing #(
        .TOPOLOGY(TOPOLOGY),
        .ROUTE_NAME(ROUTE_NAME),
        .ROUTE_TYPE(ROUTE_TYPE),  
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .RAw(RAw),
        .EAw(EAw),
        .DSTPw(DSTPw),
        .LOCATED_IN_NI(1)
    )
    route_compute
    (
        .reset(1'b0), //only needed for fattree
        .clk(1'b0), // only needed for fattree
        .current_r_addr(current_r_addr_i),
        .dest_e_addr(dest_e_addr),
        .current_e_addr(src_e_addr),
        .destport(destport)
    );
    
       
     header_flit_generator #(
        .SWA_ARBITER_TYPE("RRA"),
        .Fpay(PRONOC_PYLDw ),
        .V(1),
        .EAw(EAw),
        .DSTPw(DSTPw),
        .C(0),
        .WEIGHTw(1),
        .DATA_w(CHI_FLIT_SIZE),
        .BYTE_EN(BYTE_EN)
    )
    hdr_flit_gen
    (
        .flit_out(pronoc_hdr_flit),
        .class_in(1'b0),
        .dest_e_addr_in(dest_e_addr),
        .src_e_addr_in(src_e_addr),
        .destport_in(destport),
        .vc_num_in(1'b0),
        .weight_in(1'b0),
        .data_in(chi_flit_i),
        .be_in(1'b0)
    );
  
assign pronoc_flit_o = {2'b11,1'b1,pronoc_hdr_flit [PRONOC_PYLDw-1:0]};


//synthesis translate_off 
always @(posedge clk) begin 

    if((dest_e_addr == src_e_addr ) & chi_flitv_i ) begin 
        $display("%t:Error: The src and destination address of injected packet is the same in core (%d) %m",$time,src_id);
        $stop;
    end
end
//synthesis translate_on


endmodule





//snoop chanel doesnot have target id. our home node does not support broad casting so we need to add target id from home node  
module  chi_to_pronoc_snoop_wrapper #(
    parameter  CHI_FLIT_SIZE = 50, // CHI chanel data width
    parameter P         =5,
    parameter T1= 8,
    parameter T2= 8,
    parameter T3= 8,
    parameter RAw = 3,  
    parameter EAw = 3, 
    parameter NE=64,    
    parameter DSTPw=P-1,
    parameter TOPOLOGY  ="MESH",//"MESH","TORUS"
    parameter ROUTE_NAME="XY",// 
    parameter ROUTE_TYPE="DETERMINISTIC"
)(
    chi_flit_i,
    chi_flitpend_i,
    chi_flitv_i,
    chi_lcrdv_i,
        
    
    current_r_addr_i,
    snp_target_id, 
    
    pronoc_flit_o,
    pronoc_flit_wr_o,
    pronoc_credit_o,
    clk
);
    input clk;
    input chi_flitpend_i,   chi_flitv_i,     chi_lcrdv_i;
    output pronoc_flit_wr_o,     pronoc_credit_o;
    
    assign pronoc_flit_wr_o = chi_flitv_i;
    assign pronoc_credit_o = chi_lcrdv_i;


   localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,
        PRONOC_PYLDw   =   PRONOC_OFFSEET + CHI_FLIT_SIZE,
        PRONOC_FLIT_SIZE = PRONOC_PYLDw + 3;

    input [CHI_FLIT_SIZE-1 : 0]  chi_flit_i;
    input [EAw-1 : 0] snp_target_id;
    input [RAw-1 : 0] current_r_addr_i;
    output [PRONOC_FLIT_SIZE-1 : 0]  pronoc_flit_o;
    
    // chi mst significent bits
    localparam QOS_REQ = 4;
    localparam SRCID_REQ = 7; //it can be from 7-11

   
    wire [SRCID_REQ-1 : 0] src_id;
    assign src_id = chi_flit_i[CHI_FLIT_SIZE-1-QOS_REQ  :  CHI_FLIT_SIZE-QOS_REQ-SRCID_REQ];

    
    wire [ EAw-1 : 0] dest_e_addr;
    wire [ EAw-1 : 0] src_e_addr ;//= src_id[ EAw-1 : 0];//TODO need to check how they code the source adreeses
    
    
    
    
    mesh_tori_addr_encoder #(
        .NX(T1),
        .NY(T2),
        .NL(T3),
        .NE(NE),
        .EAw(EAw),
        .TOPOLOGY("MESH")
    )
    des_addr_encoder
    (
        .id(snp_target_id),
        .code(dest_e_addr)
    );
    
    mesh_tori_addr_encoder #(
        .NX(T1),
        .NY(T2),
        .NL(T3),
        .NE(NE),
        .EAw(EAw),
        .TOPOLOGY("MESH")
    )
    src_addr_encoder
    (
        .id(src_id[EAw-1:0]),
        .code(src_e_addr)
    );
    
    
    
    
    
    wire [DSTPw-1: 0] destport;  
    
     wire [PRONOC_FLIT_SIZE-1 : 0] pronoc_hdr_flit;
        
    conventional_routing #(
        .TOPOLOGY(TOPOLOGY),
        .ROUTE_NAME(ROUTE_NAME),
        .ROUTE_TYPE(ROUTE_TYPE),  
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .RAw(RAw),
        .EAw(EAw),
        .DSTPw(DSTPw),
        .LOCATED_IN_NI(1)
    )
    route_compute
    (
        .reset(1'b0), //only needed for fattree
        .clk(1'b0), // only needed for fattree
        .current_r_addr(current_r_addr_i),
        .dest_e_addr(dest_e_addr),
        .current_e_addr(src_e_addr),
        .destport(destport)
    );
    
       
     header_flit_generator #(
        .SWA_ARBITER_TYPE("RRA"),
        .Fpay(PRONOC_PYLDw ),
        .V(1),
        .EAw(EAw),
        .DSTPw(DSTPw),
        .C(0),
        .WEIGHTw(1),
        .DATA_w(CHI_FLIT_SIZE),
        .BYTE_EN(0)
    )
    hdr_flit_gen
    (
        .flit_out( pronoc_hdr_flit),
        .class_in(1'b0),
        .dest_e_addr_in(dest_e_addr),
        .src_e_addr_in(src_e_addr),
        .destport_in(destport),
        .vc_num_in(1'b0),
        .weight_in(1'b0),
        .data_in(chi_flit_i),
        .be_in(1'b0)
    );
   
assign pronoc_flit_o = {2'b11,1'b1,pronoc_hdr_flit [PRONOC_PYLDw-1:0]};


//synthesis translate_off 
always @(posedge clk) begin 

    if((dest_e_addr == src_e_addr ) & chi_flitv_i ) begin 
        $display("%t:Error: The src and destination address of injected packet is the same in core (%d),%m",$time,src_id);
        $stop;
    end
end
//synthesis translate_on



endmodule





module pronoc_to_chi_wrapper #(
    parameter  CHI_FLIT_SIZE = 50, // CHI chanel data width
    parameter P         =5,
    parameter EAw = 3,  
    parameter DSTPw=P-1
   
)(
    pronoc_flit_i,
    pronoc_flit_wr_i,
    pronoc_credit_i,
    
    chi_flit_o,
    chi_flitpend_o,
    chi_flitv_o,
    chi_lcrdv_o
    
    
);

   localparam
        PRONOC_OFFSEET =    (2*EAw)+DSTPw+1,
        PRONOC_PYLDw   =   PRONOC_OFFSEET + CHI_FLIT_SIZE,
        PRONOC_FLIT_SIZE = PRONOC_PYLDw + 3;

    output [CHI_FLIT_SIZE-1 : 0]  chi_flit_o;
    input  [PRONOC_FLIT_SIZE-1 : 0]  pronoc_flit_i;
    input pronoc_flit_wr_i,    pronoc_credit_i;
    output  chi_flitpend_o,   chi_flitv_o,     chi_lcrdv_o;
    
    assign chi_flitv_o = pronoc_flit_wr_i;
    assign chi_lcrdv_o = pronoc_credit_i; 
    assign chi_flitpend_o = 1'b1;
    
    

   extract_header_flit_info #(
   	.SWA_ARBITER_TYPE("RRA"),
   	.WEIGHTw(1),
   	.V(1),
   	.EAw(EAw),
   	.DSTPw(DSTPw),
   	.C(1),
   	.Fpay(PRONOC_PYLDw),
   	.DATA_w(CHI_FLIT_SIZE),
   	.BYTE_EN(0)
   )
   extract_header_flit_info
   (
   	.flit_in(pronoc_flit_i),
   	.flit_in_wr(1'b0),
   	.src_e_addr_o( ),
   	.dest_e_addr_o( ),
   	.destport_o( ),
   	.class_o( ),
   	.weight_o( ),
   	.tail_flg_o( ),
   	.hdr_flg_o( ),
   	.vc_num_o( ),
   	.hdr_flit_wr_o( ),
   	.be_o( ),
   	.data_o( chi_flit_o)
   );

endmodule

