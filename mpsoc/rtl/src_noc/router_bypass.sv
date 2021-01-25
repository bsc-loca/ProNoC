/**************************************
* Module: router_bypass
* Date:2020-11-24  
* Author: alireza     
*
* Description: 
*   This file contains HDL modules that can be added
*   to a 3-stage NoC router and provide router bypassing
***************************************/

/**************************
 * SBP_flags_gen:
 * generate SBP flags based on NoC parameter, current router's port and address,
 * and destination router address
 * located in router output port (port number:SPB_OPORT_NUM)
 * spb_flag_o indicates how many more router in direct line can be bypassed
 * if SPB_OPORT_NUM  is also one of the possible output port in 
 * lk-ahead routing, The packet can by-pass the next router once the bypassing condition are met
 ***************************/
 

 
module SBP_flags_gen_per_oport #(
    //SBP parameters
    parameter SBP_NUM =4,
    //NoC other parameters
    parameter TOPOLOGY          =   "MESH", 
    parameter ROUTE_NAME        =   "XY",
    parameter ROUTE_TYPE        =   "DETERMINISTIC", 
    parameter MAX_P             =   6,
    parameter T1                =   4,
    parameter T2                =   4,
    parameter T3                =   2,
    parameter RAw               =   3,  
    parameter EAw               =   3,   
    parameter DSTPw             =   4, 
    parameter SPB_OPORT_NUM     =   0 // output switch number.    
)
(   
    reset,
    clk,
    dest_e_addr ,
	src_e_addr,
    current_r_addr,
    spb_routers_in,
    spb_routers_out,
    spb_flag_o,
    sbp_destination_o
);   



    function integer log2;
    input integer number; begin   
       log2=(number <=1) ? 1: 0;    
       while(2**log2<number) begin    
          log2=log2+1;    
       end        
    end   
    endfunction // log2 
  
    input   reset,clk;          
    input   [RAw-1   :0] current_r_addr;    
   
    input   [EAw-1   :0] src_e_addr,dest_e_addr;
	input   [RAw-1   :0] spb_routers_in  [SBP_NUM-1 : 0];
	output 	[RAw-1   :0] spb_routers_out [SBP_NUM-1 : 0];
	output  [EAw-1   :0] sbp_destination_o;
	/* verilator lint_off UNOPTFLAT */ 
    output  [SBP_NUM-1 : 0] spb_flag_o ;
    /* verilator lint_on UNOPTFLAT */ 
    wire    [SBP_NUM-1 : 0] goes_straight;
    
    
    //generate the spb_routers_out for other routers
    //constant router address gen 
    assign spb_routers_out[0]=current_r_addr;
    assign spb_flag_o[0] = goes_straight[0];
    genvar i;
    generate 
    for (i=1; i<SBP_NUM; i=i+1) begin :lp1 
    	assign spb_routers_out[i]  = spb_routers_in[i-1];    	
	end	
	assign sbp_destination_o = dest_e_addr;
		
    wire [DSTPw-1  :   0]  lk_route [SBP_NUM-1 : 0];	
    	
    //Conventional-routing loop
   	for (i=0; i<SBP_NUM; i=i+1) begin :lp2 
   		
   		conventional_routing #(
   				.TOPOLOGY        (TOPOLOGY       ), 
   				.ROUTE_NAME      (ROUTE_NAME     ), 
   				.ROUTE_TYPE      (ROUTE_TYPE     ), 
   				.T1              (T1             ), 
   				.T2              (T2             ), 
   				.T3              (T3             ), 
   				.RAw             (RAw            ), 
   				.EAw             (EAw            ), 
   				.DSTPw           (DSTPw          ),
   				.LOCATED_IN_NI   (0              )
   			) routing (
   				.reset           (reset          ), 
   				.clk             (clk            ), 
   				.current_r_addr  (spb_routers_in[i]), 
   				.current_e_addr  (src_e_addr     ),
   				.dest_e_addr     (dest_e_addr    ), 
   				.destport        (lk_route[i]    )
   			); 
   		
   		check_straight_oport #(
   			.TOPOLOGY      ( TOPOLOGY     ),
   			.ROUTE_NAME    ( ROUTE_NAME   ),
   			.ROUTE_TYPE    ( ROUTE_TYPE   ),
   			.DSTPw         ( DSTPw        ),
   			.SPB_OPORT_NUM ( SPB_OPORT_NUM)
   			) check_straight (
   				.destport_coded_i (lk_route[i]),
   				.goes_straight_o  (goes_straight [i])
   			);   
   	
   		
   	end	
   	
   		for (i=1; i<SBP_NUM; i=i+1) begin :lp3
   			assign spb_flag_o[i]= (goes_straight[i] & spb_flag_o[i-1]); 	
   		end
   		
    endgenerate	

endmodule


module check_straight_oport #(
		parameter TOPOLOGY          =   "MESH", 
		parameter ROUTE_NAME        =   "XY",
		parameter ROUTE_TYPE        =   "DETERMINISTIC", 
		parameter DSTPw             =   4,
		parameter SPB_OPORT_NUM     =   1
		)(
		destport_coded_i,
		goes_straight_o
		);
	
		input   [DSTPw-1 : 0] destport_coded_i;
		output  goes_straight_o;
		
		generate 
		/* verilator lint_off WIDTH */ 
		if(TOPOLOGY == "MESH" || TOPOLOGY == "TORUS"  ) begin :twoD		
		/* verilator lint_on WIDTH */ 
			if (SPB_OPORT_NUM == 0 || SPB_OPORT_NUM > 4) begin : local_ports
				assign goes_straight_o = 1'b0; // There is not a next router in this case at all	
			end	
			else begin :non_local
								
				wire [4 : 0 ] destport_one_hot;
				mesh_tori_decode_dstport decoder(
						.dstport_encoded(destport_coded_i),
						.dstport_one_hot(destport_one_hot)
				);
				
				assign goes_straight_o = destport_one_hot [SPB_OPORT_NUM];	
			end//else
		end//mesh_tori
		/* verilator lint_off WIDTH */ 
		else if(TOPOLOGY ==  "RING" || TOPOLOGY ==  "LINE"  ) begin :oneD		
		/* verilator lint_on WIDTH */ 
			if (SPB_OPORT_NUM == 0 || SPB_OPORT_NUM > 2) begin : local_ports
				assign goes_straight_o = 1'b0; // There is not a next router in this case at all	
			end	
			else begin :non_local
				
				wire [2: 0 ] destport_one_hot;
    
				line_ring_decode_dstport decoder(
						.dstport_encoded(destport_coded_i),
						.dstport_one_hot(destport_one_hot)
						
					);
				assign goes_straight_o = destport_one_hot [SPB_OPORT_NUM];	
				
			end	//non_local
		end// oneD
		
			//TODO Add fattree & custom 
			
		endgenerate	
	
endmodule	

module SPB_IVC_info	
		
		#(
			parameter MAX_PCK=3
		)(
		dest_e_addr_in,
		ovc_is_assigned,
		assigned_ovc_num,
		hdr_flit_wr,
		dst_rd_fifo,
		reset,
		clk,
		spb_ivc_info_o
		);
	import pronoc_pkg::*;
	
	input [EAw-1 : 0] dest_e_addr_in;
	input [V-1   : 0] assigned_ovc_num;	
	input ovc_is_assigned;
	input hdr_flit_wr;
	input dst_rd_fifo;
	input reset,clk;
	output spb_ivc_t spb_ivc_info_o;
	
	wire [EAw-1 : 0] dest_e_addr;
	logic [Vw-1 : 0] assigned_ovc_num_bin;
	
	fwft_fifo #(
			.DATA_WIDTH(EAw),
			.MAX_DEPTH (MAX_PCK)
		)
		dest_fifo
		(
			.din(dest_e_addr_in),
			.wr_en(hdr_flit_wr),   // Write enable
			.rd_en(dst_rd_fifo),   // Read the next word
			.dout(dest_e_addr),    // Data out
			.full(),
			.nearly_full(),
			.recieve_more_than_0(),
			.recieve_more_than_1(),
			.reset(reset),
			.clk(clk) 
		);               
	
	one_hot_to_bin #(
		.ONE_HOT_WIDTH  (V ), 
		.BIN_WIDTH      (Vw    )
		) conv (
		.one_hot_code   (assigned_ovc_num  ), 
		.bin_code       (assigned_ovc_num_bin      ));
	
	assign spb_ivc_info_o.dest_e_addr = dest_e_addr;
	assign spb_ivc_info_o.assigned_ovc_bin = assigned_ovc_num_bin;
	assign spb_ivc_info_o.ovc_is_assigned = ovc_is_assigned;
	
endmodule	

module SBP_sig_gen_per_iport
		import pronoc_pkg::*;
	#(
		parameter SW_LOC=0,
		parameter P=5
	)(	
		spb_ivc_info_i,
		first_arbiter_granted_ivc,
		granted_dest_port_i,	
		spb_ivc_info_o
	);
		
	localparam P_1=P-1;
	input spb_ivc_t spb_ivc_info_i [V-1 : 0];
	input [V-1 : 0] first_arbiter_granted_ivc;
	input [P_1-1 :0] granted_dest_port_i;
	output  spb_ivc_t  spb_ivc_info_o [P-1 : 0];

	logic [Vw-1 : 0] grant_bin;
	logic [P-1 : 0 ] granted_dest_port;
	spb_ivc_t spb_ivc_info;	
	
	wire [SPB_IVC_w * V-1 : 0] muxin = (SPB_IVC_w * V)'(spb_ivc_info_i);
	one_hot_mux #(
		.IN_WIDTH   (SPB_IVC_w * V ), 
		.SEL_WIDTH  (V ), 
		.OUT_WIDTH  (SPB_IVC_w )
		) one_hot_mux (
		.mux_in     (  muxin  ), 
		.mux_out    ( spb_ivc_info ), 
		.sel        (first_arbiter_granted_ivc       ));
	
	
	add_sw_loc_one_hot #(
		.P             (P            ), 
		.SW_LOC        (SW_LOC       )
		) add_sw_loc(
		.destport_in   (granted_dest_port_i  ), 
		.destport_out  (granted_dest_port ));
	
	//demux
	genvar i;
	generate for (i=0; i < P; i=i+1) begin : port
		assign spb_ivc_info_o[i] = (granted_dest_port[i]==1'b1)? spb_ivc_info : 0;	
	end endgenerate 	
	
	
endmodule


module SBP_sig_gen_per_oport
		import pronoc_pkg::*;
		#(
		parameter SPB_OPORT_NUM=0,
		parameter P=5
		)(
		clk,
		reset,
		current_r_addr,
		spb_ivc_info_i,
		any_ovc_granted_i,
		ovc_allocated_i,
		
		spb_routers_in,
		spb_routers_out,
		sbp_link_o
		
	);	
	input reset,clk;
	input  spb_ivc_t  spb_ivc_info_i [P-1 : 0];
	input   [RAw-1   :0] current_r_addr;
	input any_ovc_granted_i;
	input   [RAw-1   :0] spb_routers_in  [SBP_NUM-1 : 0];
	input [V-1 : 0] ovc_allocated_i;
	output 	[RAw-1   :0] spb_routers_out [SBP_NUM-1 : 0];
	output spb_link_t sbp_link_o;
	
	wire [EAw-1 : 0] sbp_destination;
	
	
	reg [SBP_NUM-1 : 0] spb_flag;	    
	
	spb_ivc_t spb_ivc_info_o_or;
	integer i;
	always @(*)begin 
		spb_ivc_info_o_or=0;
		for (i=0;i<P;i=i+1)		spb_ivc_info_o_or = spb_ivc_info_o_or | spb_ivc_info_i[i];
	end
	
	wire [SBP_NUM-1 : 0] spb_flag_o_next;
	SBP_flags_gen_per_oport #(
		.SBP_NUM          (SBP_NUM         ), 
		.TOPOLOGY         (TOPOLOGY        ), 
		.ROUTE_NAME       (ROUTE_NAME      ), 
		.ROUTE_TYPE       (ROUTE_TYPE      ), 
		.MAX_P            (MAX_P           ), 
		.T1               (T1              ), 
		.T2               (T2              ), 
		.T3               (T3              ), 
		.RAw              (RAw             ), 
		.EAw              (EAw             ), 
		.DSTPw            (DSTPw           ), 
		.SPB_OPORT_NUM    (SPB_OPORT_NUM   )
		) SBP_flags_gen_per_oport (
		.reset            (reset           ), 
		.clk              (clk             ), 
		.dest_e_addr      (spb_ivc_info_o_or.dest_e_addr), 
		.src_e_addr       (      ), 
		.current_r_addr   (current_r_addr  ), 
		.spb_routers_in   (spb_routers_in  ), 
		.spb_routers_out  (spb_routers_out ), 
		.spb_flag_o       (spb_flag_o_next  ), 
		.sbp_destination_o(sbp_destination  ));
	

	wire [V-1 : 0] assigned_ovc;
	bin_to_one_hot #(
		.BIN_WIDTH      (Vw), 
		.ONE_HOT_WIDTH  (V )
		) bin_to_one_hot (
		.bin_code       (spb_ivc_info_o_or.assigned_ovc_bin ), 
		.one_hot_code   (assigned_ovc  ));
	
	
	reg  [V-1: 0]  spb_ovc; 
	
	
	
	`ifdef SYNC_RESET_MODE 
	always @ (posedge clk )begin 
	`else 
	always @ (posedge clk or posedge reset)begin 
	`endif  
		if(reset) begin 	
			sbp_link_o.flags<={SBP_NUM{1'b0}};
			sbp_link_o.ovc<={V{1'b0}};
			sbp_link_o.destination <={EAw{1'b0}};
		end else begin
			sbp_link_o.flags <= (any_ovc_granted_i)? spb_flag_o_next : {SBP_NUM{1'b0}}; 
			sbp_link_o.ovc    <= (spb_ivc_info_o_or.ovc_is_assigned) ? assigned_ovc : ovc_allocated_i;
			sbp_link_o.destination <=sbp_destination;
		end
	end
	
endmodule
	
	
module spb_allocator_per_iport 
    import pronoc_pkg::*;
#(
	parameter SW_LOC=0,
	parameter LOCATED_IN_NI=0
)(
	sbp_link_i,
	current_r_addr_i,
	reset,
	clk,
	
	//router ctrl signals
	starvation_ctrl,
	ssport_is_granted_locally,
	ovc_avalable_in_ss_port,
	assigned_ovc_not_full,
	assigned_to_ssovc,
	ovc_is_assigned,
	ivc_request,
	
	//input from sbp packet
	sbp_flit_in_append,
	sbp_flit_in_wr,
	
	//output
	sbp_ctrl_o
	
	//input form sbp packet 
	
);


	input spb_link_t sbp_link_i;
	input [RAw-1   :0]  current_r_addr_i;
	input reset;
	input clk;
	
	input starvation_ctrl;
	input ssport_is_granted_locally;
	input [V-1 : 0] ovc_avalable_in_ss_port;
	input [V-1 : 0] assigned_ovc_not_full;
	input [V-1 : 0] assigned_to_ssovc;
	input [V-1 : 0] ovc_is_assigned;
	input [V-1 : 0] ivc_request;
	
	input flit_append_t sbp_flit_in_append;
	input sbp_flit_in_wr;
	
	
	
	output sbp_ctrl_out_t  sbp_ctrl_o;

	reg [EAw-1 : 0] destination;
	
	`ifdef SYNC_RESET_MODE 
		always @ (posedge clk )begin 
	`else 
		always @ (posedge clk or posedge reset)begin 
	`endif  
			if(reset) begin 	
				destination<={EAw{1'b0}};
			end else begin
				destination<=sbp_link_i.destination;
			end
		end
	
	wire [V-1 : 0] spb_allowed_o;

	conventional_routing #(
			.TOPOLOGY        (TOPOLOGY       ), 
			.ROUTE_NAME      (ROUTE_NAME     ), 
			.ROUTE_TYPE      (ROUTE_TYPE     ), 
			.T1              (T1             ), 
			.T2              (T2             ), 
			.T3              (T3             ), 
			.RAw             (RAw            ), 
			.EAw             (EAw            ), 
			.DSTPw           (DSTPw          ),
			.LOCATED_IN_NI   (LOCATED_IN_NI  )
		) routing (
			.reset           (reset          ), 
			.clk             (clk            ), 
			.current_r_addr  (current_r_addr_i ), 
			.current_e_addr  (			     ),
			.dest_e_addr     (destination    ), 
			.destport        (sbp_ctrl_o.lk_route )
		); 
	
	genvar i;
	generate
		for (i=0;i<V; i=i+1) begin : vc
		spb_validity_check_per_ivc 
		validity_check (
			.spb_flag_i               (sbp_link_i.flags[0]     ), 
			.spb_ivc_i                (sbp_link_i.ovc  [i]     ), 
			.reset                    (reset                   ), 
			.clk                      (clk                     ), 
			.starvation_ctrl          (starvation_ctrl         ), 
			.ovc_avalable_in_ss_port  (ovc_avalable_in_ss_port[i] ), 
			.assigned_ovc_not_full    (assigned_ovc_not_full [i]  ), 
			.assigned_to_ssovc        (assigned_to_ssovc [i]   ), 
			.ovc_is_assigned          (ovc_is_assigned  [i]    ), 
			.ivc_request              (ivc_request      [i]    ), 
			.ssport_is_granted        (ssport_is_granted_locally), 
			.spb_allowed_o            (spb_allowed_o[i]        ),
			.sbp_flit_tail_flag_i     (sbp_flit_in_append.tail_flag),
			.sbp_credit_o             (sbp_ctrl_o.credit_out[i]   ), 
			.sbp_buff_space_decreased_o  (sbp_ctrl_o.buff_space_decreased[i] ), 
			.sbp_ovc_is_allocated_o      (sbp_ctrl_o.ovc_is_allocated[i]     ), 
			.sbp_ovc_is_released_o       (sbp_ctrl_o.ovc_is_released[i]    )
			);
		
		
		
		
	end//for
	endgenerate	
	
	assign sbp_ctrl_o.spb_en = |spb_allowed_o;
	
	//synthesis translate_off 
	//synopsys  translate_off
	always @(posedge clk) begin
		if(sbp_flit_in_append.hdr_flag & sbp_flit_in_wr & ( sbp_ctrl_o.ovc_is_allocated=={V{1'b0}})) $display("Error: a header flit is bypassed witout allocating an OVC: %m");
		if(sbp_flit_in_wr & (sbp_ctrl_o.buff_space_decreased != sbp_flit_in_append.vc))              $display("Error: spb OVC missmatchs with ovc in spb flit: %m");
	end		
	//synopsys  translate_on
	//synthesis translate_on 
	

endmodule

module register #(
	parameter W=1
	)( 
	input [W-1:0] in,
	input reset,	
	input clk,
	input en,
	output reg [W-1:0] out
	);
	
`ifdef SYNC_RESET_MODE 
	always @ (posedge clk )begin 
`else 
		always @ (posedge clk or posedge reset)begin 
`endif  
		if(reset) begin 	
			out<={W{1'b0}};
		end else begin
			if(en) out<=in;
		end
	end
	
endmodule
	
	
module spb_validity_check_per_ivc  
	import pronoc_pkg::*;
	(
	spb_flag_i,
	spb_ivc_i,
	reset,
	clk,
	
	starvation_ctrl,
	ovc_avalable_in_ss_port,
	assigned_ovc_not_full,
	assigned_to_ssovc,
	ovc_is_assigned,
	ivc_request, // if asserted means ivc is not empty and spb is not allowed
	ssport_is_granted,//
	
	
	sbp_flit_tail_flag_i,
	
	
	spb_allowed_o,
	sbp_credit_o,
	sbp_buff_space_decreased_o,
	sbp_ovc_is_allocated_o,
	sbp_ovc_is_released_o	
		
	);
	
	input spb_flag_i;
	input spb_ivc_i;
	
	input starvation_ctrl;
	input ovc_avalable_in_ss_port;
	input assigned_ovc_not_full;
	input assigned_to_ssovc;
	input ovc_is_assigned;
	
	input ivc_request;
	input ssport_is_granted;
	
	input reset;
	input clk;
	
	
	input sbp_flit_tail_flag_i;

	output  spb_allowed_o;
	output  sbp_credit_o;
	output	sbp_buff_space_decreased_o;
	output	sbp_ovc_is_allocated_o;
	output	sbp_ovc_is_released_o;	
	
	logic sbp_req;
	
	register #(.W(1)) req (.in(spb_flag_i &  spb_ivc_i), .reset(reset), .clk(clk), .en(1'b1), .out(sbp_req));
	
	
	// condition1: The input ivc must be empty & the destination straight port should not be granted locally
	wire condition1 = ~(ivc_request | ssport_is_granted);
	wire hdr_flit_condition =     (~starvation_ctrl & ovc_avalable_in_ss_port);
	wire nonhdr_flit_condition =  (assigned_to_ssovc & assigned_ovc_not_full );
	wire condition2 = (ovc_is_assigned)? nonhdr_flit_condition : hdr_flit_condition;
	wire ivc_condition_met = condition1 & condition2;
	
	assign spb_allowed_o = ivc_condition_met & sbp_req;
	assign sbp_buff_space_decreased_o = spb_allowed_o;
	assign sbp_ovc_is_allocated_o =  !ovc_is_assigned & spb_allowed_o;  
	assign sbp_ovc_is_released_o = sbp_flit_tail_flag_i & spb_allowed_o;
	
	register #(.W(1)) credit(.in(spb_allowed_o), .reset(reset), .clk(clk), .en(1'b1), .out(sbp_credit_o));
	
		
	
endmodule

	
