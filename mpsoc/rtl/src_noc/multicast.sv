`timescale 1ns / 1ps

/**************************************
 * Module: router_bypass
 * Date:2021-11-14  
 * Author: alireza     
 *
 * Description: 
 *   This file contains HDL modules that can be added
 *   to NoC router to provide multicasting
 ***************************************/
 


/**********************************

    full_ovc_predictor

 *********************************/

module multicast_full_ovc_predictor 
		import pronoc_pkg::*;
		#(
		parameter P = 5, // router port num
		parameter OVC_ALLOC_MODE=1'b0        
		)(
		granted_ovc_num,
		ovc_is_assigned,
		assigned_ovc_num,
		dest_port, 
		full,
		credit_increased,
		nearly_full,
		ivc_getting_sw_grant,
		
		granted_dest_port,
		any_assigned_ovc_is_not_full,
		assigned_ovc_is_full_in_oport,
		
		clk,
		reset
		);
 
		localparam      P_1   =  ( SELF_LOOP_EN=="NO")?  P-1 : P,
			VP_1    =    V        *     P_1;
		input	clk,reset;                
		input	ovc_is_assigned;
		input	[V-1           :    0]	assigned_ovc_num,granted_ovc_num;
		input	[P_1-1         :    0]	dest_port;
		input	[VP_1-1        :    0]	full;
		input	[VP_1-1        :    0]	credit_increased;
		input	[VP_1-1        :    0]	nearly_full;
		input 	ivc_getting_sw_grant;		  
		input   [P_1-1 : 0] granted_dest_port;
		output	any_assigned_ovc_is_not_full;  
		output  [P_1-1 : 0] assigned_ovc_is_full_in_oport;
		
		wire    [VP_1-1  :    0] full_muxin1,nearly_full_muxin1;
		wire    [P_1-1   :    0] full_muxout1,nearly_full_muxout1;
		wire    [P_1-1   :    0] full_next1,full_next2,full_next;
		
		assign full_muxin1        = full & (~credit_increased);
		assign nearly_full_muxin1 = nearly_full & (~credit_increased);
		
		// Assigned OVC num mux
		onehot_mux_1D_reverse #(
			.W  (P_1),//out w
			.N  (V)// sel w
		)full_mux1
		(
			.in     (full_muxin1),
			.out    (full_muxout1),
			.sel    (assigned_ovc_num)
		);
    
		assign  full_next1 = full_muxout1 | ~ dest_port;  // set non- accessible destport as full		
		
		wire [V-1 : 0]  nearlyfull_sel = (ovc_is_assigned | ~OVC_ALLOC_MODE)? assigned_ovc_num : granted_ovc_num;	
				
		onehot_mux_1D_reverse #(
				.W  (V),
				.N  (P_1)
		)nearly_full_mux1
		(
			.in        (nearly_full_muxin1),
			.out       (nearly_full_muxout1),
			.sel       (nearlyfull_sel)
		);
	
		assign full_next2 = (ivc_getting_sw_grant)? nearly_full_muxout1 & granted_dest_port : {P_1{1'b0}};  
 		assign full_next = full_next1 | full_next2;
 		pronoc_register #(.W(P_1)) reg1 (.in(full_next ), .out(assigned_ovc_is_full_in_oport), .reset(reset), .clk(clk));
		assign any_assigned_ovc_is_not_full = |(~assigned_ovc_is_full_in_oport);
 		
 		
endmodule 





module multicast_dst_sel 
		import pronoc_pkg::*;
(
	destport_in,
	destport_out	
);

    input  [DSTPw-1 : 0] destport_in;
    output [DSTPw-1 : 0] destport_out; 
    
    generate 
    /* verilator lint_off WIDTH */ 
    if(TOPOLOGY == "MESH" || TOPOLOGY == "TORUS" || TOPOLOGY == "FMESH"  ) begin : mesh
    /* verilator lint_on WIDTH */ 
    	mesh_torus_multicast_dst_sel sel    			
    	(
    		.destport_in(destport_in),
    		.destport_out(destport_out)    
    	);
    /* verilator lint_off WIDTH */ 
    end else if(TOPOLOGY == "RING" || TOPOLOGY == "LINE") begin : ring
    /* verilator lint_on WIDTH */ 		
    	ring_line_multicast_dst_sel sel
    	(
    		.destport_in(destport_in),
    		.destport_out(destport_out)    
    	);
  
    end else begin : other 
    	
    	fattree_multicast_dst_sel #(
    		.DSTPw(DSTPw)
    	)
    	sel
    	(
    		.destport_in(destport_in),
    		.destport_out(destport_out)    
    	);   	
    	
    	
    end
    endgenerate
    
    
    
endmodule

