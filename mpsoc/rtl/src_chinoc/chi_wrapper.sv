`include "pronoc_def.v"
`include "chi_noc_def.v"

/**************************************
* Module: chi_wrapper
* Date:2019-05-03  
* Author: alireza     
*
* Description: 
***************************************/


module  chi_to_pronoc_wrapper #(
     parameter NOC_ID=0
)(
    target_id,
    src_id,
    
    chi_flit_i,
    chi_flitpend_i,
    chi_flitv_i,
    chi_lcrdv_i,   
   
    current_r_addr_i,
    pronoc_chan_out,    
    clk,
    reset
);



    `NOC_CONF 
    
    input chi_flitpend_i,   chi_flitv_i,     chi_lcrdv_i, clk,reset;  
    input [Fpay-1 : 0]  chi_flit_i;
    input [RAw-1 : 0] current_r_addr_i;

    output smartflit_chanel_t pronoc_chan_out;   
    
 
    input [NEw-1 : 0] target_id, src_id;
 
            
 
        
    wire [ EAw-1 : 0] dest_e_addr;// = target_id[ EAw-1 : 0];//TODO need to check how they code the destiation adreeses
    wire [ EAw-1 : 0] src_e_addr;// = src_id[ EAw-1 : 0];//TODO need to check how they code the source adreeses
    wire [DSTPw-1: 0] destport;   
    wire [Fw-1 : 0] pronoc_hdr_flit;
    
    endp_addr_encoder #(
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .EAw(EAw),
        .NE(NE)
    )
    des_addr_encoder
    (
        .id(target_id),
        .code(dest_e_addr)
     );    


   
    endp_addr_encoder #(
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .EAw(EAw),
        .NE(NE)
    )
    
    src_addr_encoder
    (
        .id(src_id[NEw-1:0]),
        .code(src_e_addr)
    );
       
        
    conventional_routing #(
        .NOC_ID(NOC_ID),
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
        .src_e_addr(src_e_addr),
        .destport(destport)
    );
    
    localparam [WEIGHTw-1 : 0] WINIT = 1;
       
    header_flit_generator #(
    .NOC_ID(NOC_ID),
        .DATA_w(Fpay)
    )
    hdr_flit_gen
    (
        .flit_out(pronoc_hdr_flit),
        .class_in(1'b0),
        .dest_e_addr_in(dest_e_addr),
        .src_e_addr_in(src_e_addr),
        .destport_in(destport),
        .vc_num_in(1'b0),
        .weight_in(WINIT),
        .data_in(chi_flit_i),
        .be_in(1'b0)
    );
    

    assign  pronoc_chan_out.flit_chanel.flit_wr  = chi_flitv_i;
    assign  pronoc_chan_out.flit_chanel.credit   = chi_lcrdv_i;
    assign  pronoc_chan_out.flit_chanel.flit.hdr_flag = 1'b1;
    assign  pronoc_chan_out.flit_chanel.flit.tail_flag= 1'b1;
    assign  pronoc_chan_out.flit_chanel.flit.vc= 1'b1;
    assign  pronoc_chan_out.flit_chanel.flit.payload= pronoc_hdr_flit[FPAYw-1 : 0];    

    //credit release should be asserted externaly via register. For simulation we just use a counter to set it few cycles after reset
    reg [3:0] counter;
    always @(posedge clk or posedge reset)begin 
        if(reset)  counter<=0;
        else if(counter<4) counter=counter+1'b1;
    end
    
    wire credit_release = counter==4;
    
    genvar i;
    generate
    for (i=0; i<V;i++) begin :V_
        assign pronoc_chan_out.ctrl_chanel.credit_init_val[i]= 0;
        assign pronoc_chan_out.ctrl_chanel.credit_release_en[i]= credit_release;
    end
    endgenerate
 
    

//synthesis translate_off 
always @(posedge clk) begin 

    if((dest_e_addr == src_e_addr ) & chi_flitv_i ) begin 
        $display("%t:Error: The src and destination address of injected packet is the same in core (%d) %m",$time,src_id);
        $stop;
    end
end
//synthesis translate_on


endmodule





module pronoc_to_chi_wrapper #(
   parameter NOC_ID=0
)(
    pronoc_chan_in,
    
    chi_flit_o,
    chi_flitpend_o,
    chi_flitv_o,
    chi_lcrdv_o
    
    
);
 
    `NOC_CONF 
 
    input smartflit_chanel_t pronoc_chan_in;   


    output [Fpay-1 : 0]  chi_flit_o;
    output  chi_flitpend_o,   chi_flitv_o,     chi_lcrdv_o;
    
    assign chi_flitv_o = pronoc_chan_in.flit_chanel.flit_wr;
    assign chi_lcrdv_o = pronoc_chan_in.flit_chanel.credit; 
    assign chi_flitpend_o = 1'b1;
    
   
    header_flit_info 
    #(
        .NOC_ID(NOC_ID),    
        .DATA_w(Fpay)
    )extr(
        .flit(pronoc_chan_in.flit_chanel.flit),
        .hdr_flit(),        
        .data_o(chi_flit_o)    
    );
 

endmodule

