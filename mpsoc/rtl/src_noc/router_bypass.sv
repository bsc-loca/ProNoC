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
 * sbp_flag_o indicates how many more router in direct line can be bypassed
 * if SPB_OPORT_NUM  is also one of the possible output port in 
 * lk-ahead routing, The packet can by-pass the next router once the bypassing condition are met
 ***************************/



module onehot_mux #(
		parameter W = 5,//out width
		parameter N = 4 //sel width 
		)(
		input  [W-1 : 0] in [N-1 : 0],
		input  [N-1 : 0] sel,
		output [W-1 : 0] out	
		);

	logic  [W-1 : 0] mask [N-1 : 0];
	logic  [W-1 : 0] in_masked [N-1 : 0];
  
	//first selector 
	genvar i;
	generate    // first_mask = {sel[0],sel[0],sel[0],....,sel[n],sel[n],sel[n]}
		for(i=0; i<N; i=i+1) begin : mask_loop
			assign in_masked[i] = (sel[i]) ?  in[i] :  {W{1'b0}};
		end  	
	endgenerate

	assign out = 	in_masked.or;

    
endmodule


 
 
module sbp_forward_ivc_info
	import pronoc_pkg::*;
	#(
	parameter P=5
)(			
		ivc_info,
		iport_info,
		oport_info,
		sbp_chanel,
		ovc_alloc_is_not_allowed,
		reset,clk
);
		
	
	
	//ivc info 
	input reset,clk;
	input  ivc_info_t 	ivc_info    [P-1 : 0][V-1 : 0];
	input  iport_info_t iport_info  [P-1 : 0];
	input  oport_info_t oport_info  [P-1 : 0]; 
	output sbp_chanel_t sbp_chanel  [P-1 : 0];
	output [V-1 : 0] ovc_alloc_is_not_allowed [P-1 : 0];
			
	sbp_ivc_info_t  sbp_ivc_info [P-1 : 0][V-1 : 0];
	sbp_ivc_info_t  sbp_ivc_mux  [P-1 : 0];
	
	sbp_ivc_info_t  sbp_ivc_info_all_port [P-1 : 0] [P-1 : 0];
	sbp_ivc_info_t  sbp_vc_info_o [P-1 : 0];
	
	wire [V-1 : 0] assigned_ovc [P-1:0];
	
	genvar i,j;
	generate 
	for (i=0;i<P;i=i+1) begin : port_
		for (j=0; j < V; j=j+1) begin : ivc					
			assign sbp_ivc_info[i][j].dest_e_addr = ivc_info[i][j].dest_e_addr;
			assign sbp_ivc_info[i][j].ovc_is_assigned= ivc_info[i][j].ovc_is_assigned;
			assign sbp_ivc_info[i][j].assigned_ovc_bin=ivc_info[i][j].assigned_ovc_bin;		
		end//V
		
		onehot_mux	#(.W(SBP_IVC_w),.N(V)) mux1 ( .in(sbp_ivc_info[i]), .sel(iport_info[i].swa_first_level_grant), .out(sbp_ivc_mux[i]));
		//demux
		for (j=0;j<P;j=j+1) begin : port_
			assign sbp_ivc_info_all_port[j][i] = (iport_info[i].granted_oport_one_hot[j]==1'b1)? sbp_ivc_mux[i] : {SBP_IVC_w{1'b0}};	
		end		
		assign sbp_vc_info_o[i] = sbp_ivc_info_all_port[i].or;
		
		
		bin_to_one_hot #(
			.BIN_WIDTH      (Vw), 
			.ONE_HOT_WIDTH  (V )
		) conv (
			.bin_code       (sbp_vc_info_o[i].assigned_ovc_bin ), 
			.one_hot_code   (assigned_ovc[i]  )
		);
		
		
		`ifdef SYNC_RESET_MODE 
			always @ (posedge clk )begin 
		`else 
			always @ (posedge clk or posedge reset)begin 
		`endif  
				if(reset) begin 	
					sbp_chanel[i]<={SBP_LINK_w{1'b0}};
				end else begin 	
					sbp_chanel[i].dest_e_addr<= sbp_vc_info_o[i].dest_e_addr;	
					sbp_chanel[i].requests<= (oport_info[i].any_ovc_get_swa_grant)? {SBP_NUM{1'b1}}:{SBP_NUM{1'b0}} ;
					sbp_chanel[i].ovc<= (sbp_vc_info_o[i].ovc_is_assigned)? assigned_ovc[i] : oport_info[i].ovc_is_allocated;
				end
			end		
	end//port_
	endgenerate
	
//	generate for (i=0; i < P; i=i+1) begin : port
//			assign sbp_ivc_info_o[i] = (granted_dest_port[i]==1'b1)? ivc_info_mux : {SBP_IVC_w{1'b0}};		
//		end endgenerate 	
	
	
			
endmodule
 
 
 
 

 
module register_ld_en #(parameter W=1)( 
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

	
			module register #(parameter W=1)( 
				input [W-1:0] in,
				input reset,	
				input clk,		
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
					out<=in;
				end
			end
	
			endmodule	
 

	

 
 
 
 
 
 
 
 
 
 
 
 
 
/**********************
 * 	register def
 *******************/
 
 
 `ifdef DEVELOP
 


	
	
	
 
module sbp_requests_gen_per_oport 
	import pronoc_pkg::*;
#(
	parameter SPB_OPORT_NUM     =   0 // output switch number.  
)(   
    reset,
    clk,
    dest_e_addr ,
	src_e_addr,
    current_r_addr,
    sbp_routers_in,
    sbp_routers_out,
    sbp_requests_o,
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
	input   [RAw-1   :0] sbp_routers_in  [SBP_NUM-1 : 0];
	output 	[RAw-1   :0] sbp_routers_out [SBP_NUM-1 : 0];
	output  [EAw-1   :0] sbp_destination_o;
	/* verilator lint_off UNOPTFLAT */ 
    output  [SBP_NUM-1 : 0] sbp_requests_o ;
    /* verilator lint_on UNOPTFLAT */ 
    wire    [SBP_NUM-1 : 0] goes_straight;
    
    
    //generate the sbp_routers_out for other routers
    //constant router address gen 
    assign sbp_routers_out[0]=current_r_addr;
    assign sbp_requests_o[0] = goes_straight[0];
    genvar i;
    generate 
    for (i=1; i<SBP_NUM; i=i+1) begin :lp1 
    	assign sbp_routers_out[i]  = sbp_routers_in[i-1];    	
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
   				.current_r_addr  (sbp_routers_in[i]), 
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
   			assign sbp_requests_o[i]= (goes_straight[i] & sbp_requests_o[i-1]); 	
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





module sbp_sig_gen_per_iport
		import pronoc_pkg::*;
	#(
		parameter SW_LOC=0,
		parameter P=5
	)(			
		ivc_info,
		first_arbiter_granted_ivc,
		granted_dest_port_i,	
		sbp_ivc_info_o,
		ovc_alloc_is_not_allowed
	);
		
	localparam P_1=P-1;	
	
	//ivc info 
	input ivc_info_t ivc_info [V-1 : 0];
	
			
		
	//sw alloc grants
	input [V-1 : 0] first_arbiter_granted_ivc;
	input [P_1-1 :0] granted_dest_port_i;
	output  sbp_ivc_t  sbp_ivc_info_o [P-1 : 0];
	output [V-1 : 0] ovc_alloc_is_not_allowed  [P-1 : 0]; 

	logic [Vw-1 : 0] grant_bin;
	wire  [Vw-1   : 0] assigned_ovc_num_bin [V-1   : 0];
	logic [P-1 : 0 ] granted_dest_port;
	
	sbp_ivc_t  ivc_info_sub [V-1 : 0];
	sbp_ivc_t  ivc_info_mux;
	wire [V-1 : 0] sbp_ovc_alloc_may_conflict;
	
	
	
	
	genvar i,j;
	generate for (i=0; i < V; i=i+1) begin : ivc
			localparam [V-1 : 0]  IVC_CODE =  1<<i;
			one_hot_to_bin #(
					.ONE_HOT_WIDTH  (V ), 
					.BIN_WIDTH      (Vw    )
				) conv2 (
					.one_hot_code   (ivc_info[i].assigned_ovc_num  ), 
					.bin_code       (assigned_ovc_num_bin[i]));	
			assign ivc_info_sub[i].dest_e_addr = ivc_info[i].dest_e_addr;
			assign ivc_info_sub[i].ovc_is_assigned= ivc_info[i].ovc_is_assigned;
			assign ivc_info_sub[i].assigned_ovc_bin=assigned_ovc_num_bin[i];	
				
			
			
			assign sbp_ovc_alloc_may_conflict[i] = (ivc_info[i].candidate_ovc == IVC_CODE) & 	~ivc_info[i].ovc_is_assigned & ivc_info[i].ivc_req; 
			for (j=0; j < P; j=j+1) begin : port
				assign ovc_alloc_is_not_allowed[j][i] = sbp_ovc_alloc_may_conflict[i] & ivc_info[i].destport_one_hot[j]; 
			end
			
	end endgenerate 	
	
	
	
	
	
		
	
	onehot_mux	#(.W(SBP_IVC_w),.N(V)) mux1 ( .in(ivc_info_sub), .sel(first_arbiter_granted_ivc), .out(ivc_info_mux));
	
	
	
	
	
	
	add_sw_loc_one_hot #(
		.P             (P            ), 
		.SW_LOC        (SW_LOC       )
		) add_sw_loc(
		.destport_in   (granted_dest_port_i  ), 
		.destport_out  (granted_dest_port ));
	
	//demux
	
	generate for (i=0; i < P; i=i+1) begin : port
		assign sbp_ivc_info_o[i] = (granted_dest_port[i]==1'b1)? ivc_info_mux : {SBP_IVC_w{1'b0}};		
    end endgenerate 	
	
	
			
endmodule


module sbp_sig_gen_per_oport
		import pronoc_pkg::*;
		#(
		parameter SPB_OPORT_NUM=0,
		parameter P=5
		)(
		clk,
		reset,
		current_r_addr,
		sbp_ivc_info_i,
		any_ovc_granted_i,
		ovc_allocated_i,
		
		sbp_routers_in,
		sbp_routers_out,
		sbp_chanel_o
		
	);	
	input reset,clk;
	input  sbp_ivc_t  sbp_ivc_info_i [P-1 : 0];
	input   [RAw-1   :0] current_r_addr;
	input any_ovc_granted_i;
	input   [RAw-1   :0] sbp_routers_in  [SBP_NUM-1 : 0];
	input [V-1 : 0] ovc_allocated_i;
	output 	[RAw-1   :0] sbp_routers_out [SBP_NUM-1 : 0];
	output sbp_chanel_t sbp_chanel_o;
	
	wire [EAw-1 : 0] sbp_destination;
	
	
	reg [SBP_NUM-1 : 0] sbp_flag;	    
	
	sbp_ivc_t sbp_ivc_info_o_or;
	integer i;
	always @(*)begin 
		sbp_ivc_info_o_or=0;
		for (i=0;i<P;i=i+1)		sbp_ivc_info_o_or = sbp_ivc_info_o_or | sbp_ivc_info_i[i];
	end
	
	wire [SBP_NUM-1 : 0] sbp_requests_o_next;
	sbp_requests_gen_per_oport #(
		.SPB_OPORT_NUM    (SPB_OPORT_NUM   )
	) req_gen (
		.reset            (reset           ), 
		.clk              (clk             ), 
		.dest_e_addr      (sbp_ivc_info_o_or.dest_e_addr), 
		.src_e_addr       (      ), 
		.current_r_addr   (current_r_addr  ), 
		.sbp_routers_in   (sbp_routers_in  ), 
		.sbp_routers_out  (sbp_routers_out ), 
		.sbp_requests_o   (sbp_requests_o_next), 
		.sbp_destination_o(sbp_destination  )
	);
	

	wire [V-1 : 0] assigned_ovc;
	bin_to_one_hot #(
		.BIN_WIDTH      (Vw), 
		.ONE_HOT_WIDTH  (V )
		) bin_to_one_hot (
		.bin_code       (sbp_ivc_info_o_or.assigned_ovc_bin ), 
		.one_hot_code   (assigned_ovc  ));
	
	
	reg  [V-1: 0]  sbp_ovc; 
	
	
	
	`ifdef SYNC_RESET_MODE 
	always @ (posedge clk )begin 
	`else 
	always @ (posedge clk or posedge reset)begin 
	`endif  
		if(reset) begin 	
			sbp_chanel_o.requests<={SBP_NUM{1'b0}};
			sbp_chanel_o.ovc<={V{1'b0}};
			sbp_chanel_o.destination <={EAw{1'b0}};
		end else begin
			sbp_chanel_o.requests <= (any_ovc_granted_i)? sbp_requests_o_next : {SBP_NUM{1'b0}}; 
			sbp_chanel_o.ovc    <= (sbp_ivc_info_o_or.ovc_is_assigned) ? assigned_ovc : ovc_allocated_i;
			sbp_chanel_o.destination <=sbp_destination;
		end
	end
	
endmodule
	
	
	
	
	
module sbp_sig_gen  
 	import pronoc_pkg::*;
#(
	parameter P=5	
)(
	
	
);
	genvar i;
	generate
	for (i=0;i<P;i=i+1) begin: port
		sbp_sig_gen_per_iport #(
			.SW_LOC (i), 
			.P(P)
		)
		sbp_sig_gen_per_iport 
		(
		.ivc_info                   (ivc_info[i]               ), 
		.first_arbiter_granted_ivc  (first_arbiter_granted_ivc[i] ), 
		.granted_dest_port_i        (granted_dest_port_i[i]    ), 
		.sbp_ivc_info_o             (sbp_ivc_info_o[i]         ), 
		.ovc_alloc_is_not_allowed   (ovc_alloc_is_not_allowed[i])
		);
	
	
		
	
	
	end
	endgenerate
		
	
	
endmodule 	
	
	
	
	
module sbp_allocator_per_iport 
    import pronoc_pkg::*;
#(
	parameter SW_LOC=0	
)(
	
	clk,
	reset,
	current_r_addr_i,
	
	//sbp_chanel & flit in
	sbp_chanel_i,
	sbp_chanel_i,
		
	
	//router ctrl signals
	ivc_info,
	ivc_ss_ovc_info,
	sbp_vc_alloc_is_allowed,//make sure no conflict is existed between local & SBP VC allocation
	ss_port_link_reg_flit_wr,	
		
	//output
	sbp_ctrl_o	
);

 	input clk, reset;
 	input [RAw-1   :0]  current_r_addr_i;

	input sbp_chanel_t sbp_chanel_i;
	input router_chanel_t sbp_chanel_i;
	
		
	input [V-1 : 0] sbp_vc_alloc_is_allowed;
	
	input ss_port_link_reg_flit_wr;		
	
	input ivc_info_t ivc_info [V-1 : 0];
	input ivc_ss_ovc_info_t ivc_ss_ovc_info [V-1 : 0];
	
	
			
	output sbp_ctrl_out_t  sbp_ctrl_o;

	wire  sbp_flit_hdr_flag = sbp_chanel_i.hdr_flag;
	wire  sbp_flit_tail_flag= sbp_chanel_i.tail_flag;
	wire  sbp_flit_wr_i = sbp_chanel_i.flit_wr;
	
	
	reg [EAw-1 : 0] destination;	
	register #(.W(EAw)) dest_reg(.in(sbp_chanel_i.destination), .reset(reset), .clk(clk), .out(destination));
	
	localparam  LOCATED_IN_NI=  
		(TOPOLOGY=="RING" || TOPOLOGY=="LINE") ? (SW_LOC == 0 || SW_LOC>2) :
		(TOPOLOGY =="MESH" || TOPOLOGY=="TORUS")? (SW_LOC == 0 || SW_LOC>4) : 0;
	
	
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
			.destport        (sbp_ctrl_o.lk_route)
	); 
	
	
	wire [V-1 : 0] sbp_allowed_o;
	
	genvar i;
	generate
		for (i=0;i<V; i=i+1) begin : vc
		sbp_validity_check_per_ivc 
		validity_check (
			.reset                       (reset                   		), 
			.clk                         (clk                     		), 
			
			.sbp_requests_i              (sbp_chanel_i.requests[0]  		), 
			.sbp_ivc_i                   (sbp_chanel_i.ovc  [i]     		),
			.sbp_flit_hdr_flag_i         (sbp_flit_hdr_flag         	),
			.sbp_flit_tail_flag_i        (sbp_flit_tail_flag            ),
			.sbp_flit_wr_i               (sbp_flit_wr_i                 ),
			
			.sbp_vc_alloc_is_allowed     (sbp_vc_alloc_is_allowed[i]	), 
			.ss_ovc_avalable_in_ss_port  (ivc_ss_ovc_info[i].ss_ovc_avalable), 
			.assigned_to_ss_ovc          (ivc_ss_ovc_info[i].assigned_to_ss_ovc),
			.assigned_ovc_not_full       (ivc_info[i].assigned_ovc_not_full), 
			.ovc_is_assigned             (ivc_info[i].ovc_is_assigned), 
			.ivc_request                 (ivc_info[i].ivc_request  	), 
			.ss_port_link_reg_flit_wr    (ss_port_link_reg_flit_wr      ), 
			
			
			.sbp_allowed_o               (sbp_allowed_o[i]        		),
			.sbp_credit_o             	 (sbp_ctrl_o.credit_out[i]   	), 
			.sbp_buff_space_decreased_o  (sbp_ctrl_o.buff_space_decreased[i] ), 
			.sbp_ovc_is_allocated_o      (sbp_ctrl_o.ovc_is_allocated[i] ), 
			.sbp_ovc_is_released_o       (sbp_ctrl_o.ovc_is_released[i]  ),
			.sbp_masks_free_ovc_o 		 (sbp_ctrl_o.ovc_is_masked[i]    )
			);	
		
	end//for
	endgenerate	
	
	assign sbp_ctrl_o.sbp_en = |sbp_allowed_o;
	
	//synthesis translate_off 
	//synopsys  translate_off
	always @(posedge clk) begin
		if(sbp_flit_append_i.hdr_flag & sbp_flit_wr_i & ( sbp_ctrl_o.ovc_is_allocated=={V{1'b0}})) $display("Error: a header flit is bypassed witout allocating an OVC: %m");
		if(sbp_flit_wr_i & (sbp_ctrl_o.buff_space_decreased != sbp_flit_append_i.vc))              $display("Error: sbp OVC missmatchs with ovc in sbp flit: %m");
	end		
	//synopsys  translate_on
	//synthesis translate_on 
	

endmodule


	
	
module sbp_validity_check_per_ivc  
	import pronoc_pkg::*;
	(
	reset                      ,
	clk                        ,
	//sbp link and flit                           
	sbp_requests_i             ,
	sbp_ivc_i                  ,
	sbp_flit_hdr_flag_i        ,
	sbp_flit_tail_flag_i       , 
	sbp_flit_wr_i              ,
	//internal router status                           
	sbp_vc_alloc_is_allowed    ,
	ss_ovc_avalable_in_ss_port ,
	assigned_to_ss_ovc         ,
	assigned_ovc_not_full      ,
	ovc_is_assigned            ,
	ss_port_link_reg_flit_wr   ,
	ivc_request                ,
	//sbp ctrl out                           
	sbp_allowed_o              ,
	sbp_credit_o               ,
	sbp_buff_space_decreased_o ,
	sbp_ovc_is_allocated_o     ,
	sbp_ovc_is_released_o      ,
	sbp_masks_free_ovc_o
	
	);
	
	input reset, clk;
	//sbp link and flit                           
	input sbp_requests_i, sbp_ivc_i,sbp_flit_wr_i,sbp_flit_tail_flag_i,sbp_flit_hdr_flag_i;
	
		              
	//internal router status                           
	input	sbp_vc_alloc_is_allowed,
		ss_ovc_avalable_in_ss_port ,
		assigned_to_ss_ovc         ,
		assigned_ovc_not_full      ,
		ovc_is_assigned            ,
		ss_port_link_reg_flit_wr   ,
		ivc_request                ;
	//sbp ctrl out                           
	output	sbp_allowed_o          ,
		sbp_credit_o               ,
		sbp_buff_space_decreased_o ,
		sbp_ovc_is_allocated_o     ,
		sbp_ovc_is_released_o      ,
		sbp_masks_free_ovc_o       ;	
	
	logic sbp_req;
	
	register #(.W(1)) req (.in(sbp_requests_i &  sbp_ivc_i), .reset(reset), .clk(clk), .out(sbp_req));
	
	
	
	
	// condition1: new sbp vc allocation condition
	wire hdr_flit_condition = sbp_vc_alloc_is_allowed &	ss_ovc_avalable_in_ss_port;	
	wire nonhdr_flit_condition =  assigned_to_ss_ovc & assigned_ovc_not_full;
	wire condition1 = (ovc_is_assigned)? nonhdr_flit_condition : hdr_flit_condition;
	wire condition2 = ~(ivc_request | ss_port_link_reg_flit_wr);
	wire conditions_met = condition1 & condition2;
	assign sbp_allowed_o = conditions_met & sbp_req;
	
	
	
	assign sbp_buff_space_decreased_o = sbp_allowed_o & sbp_flit_wr_i ;
	assign sbp_ovc_is_allocated_o =  !ovc_is_assigned & sbp_allowed_o & sbp_flit_wr_i;  
	assign sbp_ovc_is_released_o =  sbp_flit_tail_flag_i & sbp_allowed_o & sbp_flit_wr_i;
	
	//mask the available SS OVC for local requests allocation if the following conditions happen
	assign sbp_masks_free_ovc_o = ~(sbp_req & sbp_vc_alloc_is_allowed & ~ovc_is_assigned );
	
	
	register #(.W(1)) credit(.in(sbp_allowed_o), .reset(reset), .clk(clk), .out(sbp_credit_o));
	
endmodule



module sbp_components
	import pronoc_pkg::*;
	#(
	parameter P=5
	)(
		chan_in,
		chan_out,
		to_r2_chan_out,
		from_r2_chan_in,
		reset,
		clk
	);
	
	input   reset,clk;
	input   router_chanel_t chan_in [P-1 : 0];
	output  router_chanel_t chan_out [P-1 : 0];
	
	output flit_chanel_t to_r2_chan_out  [P-1 : 0];
	input  flit_chanel_t from_r2_chan_in [P-1 : 0];
	
	
	
	flit_chanel_t ss_flit_chanel [P-1 : 0];
	sbp_chanel_t  ss_sbp_chanel  [P-1 : 0];
	sbp_chanel_t  sbp_chanel_shifted  [P-1 : 0];
	wire [P-1 : 0] sbp_req;
	
	// input to 2 stage router
	assign to_r2_chan_out.neighbors_r_addr = chan_in.flit_chanel.neighbors_r_addr;
	assign to_r2_chan_out.flit = chan_in.flit_chanel.flit;
	assign to_r2_chan_out.credit = chan_in.flit_chanel.credit;
	assign to_r2_chan_out.congestion = chan_in.flit_chanel.congestion;
	
	assign sbp_chanel_shifted.ovc = chan_in.sbp_chanel.ovc;
	assign sbp_chanel_shifted.destination = chan_in.sbp_chanel.destination;	
	
	// output from 2 stage router
	assign chan_out.flit_chanel.neighbors_r_addr = from_r2_chan_in.neighbors_r_addr;
	assign chan_out.flit_chanel.credit = from_r2_chan_in.credit;
	assign chan_out.flit_chanel.congestion = from_r2_chan_in.congestion;

	
	sbp_ctrl_out_t  sbp_ctrl_o [P-1 : 0];
	reg flit_t flit_chanel_reg [P-1 : 0];
	
	localparam DISABLE = P;
	
	genvar i;
	generate
	for (i=0;i<P;i=i+1) begin: port
		
		localparam SS_PORT = strieght_port (P,i);

		
		
		if( SS_PORT != DISABLE ) begin : ssp
			
			//allocator
			sbp_allocator_per_iport #(
				.SW_LOC                      (i)			
			) sbp_allocator			(
				.clk                         (clk                        ), 
				.reset                       (reset                      ), 
				.current_r_addr_i            (current_r_addr_i           ), 
				
				.sbp_chanel_i				 (sbp_chanel_i[i]            ),
				.sbp_chanel_i                (sbp_chanel_i[i]            ),
				.ivc_info                    (ivc_info [i]				 ),
				.ivc_ss_ovc_info			 (ivc_ss_ovc_info[i]         ),
				.sbp_vc_alloc_is_allowed     (sbp_vc_alloc_is_allowed[i] ),
				.ss_port_link_reg_flit_wr    (ss_port_link_reg_flit_wr[i]),	
				.sbp_ctrl_o					 (sbp_ctrl_o [i]             )
			);
			
			
			
			
			
			//sbp_chanel_shifter
			assign {sbp_chanel_shifted[i].requests,sbp_req[i]} = {1'b0,chan_in[i].sbp_chanel.requests};
			
			// flit_in_wr mux 
			assign to_r2_chan_out.flit_wr = (sbp_ctrl_o [i].sbp_en)? 1'b0 : chan_in.flit_chanel.flit_wr;
			
			// streight port
			assign ss_flit_chanel[SS_PORT] = chan_in[i].flit_chanel;
			assign ss_sbp_chanel [SS_PORT] = sbp_chanel_shifted[i];
			
			// mux out flit chanel
			assign chan_out[i].flit_chanel.flit    = (sbp_ctrl_o [i].sbp_en)? ss_flit_chanel[i].flit    : from_r2_chan_in[i].flit;
			assign chan_out[i].flit_chanel.flit_wr = (sbp_ctrl_o [i].sbp_en)? ss_flit_chanel[i].flit_wr : from_r2_chan_in[i].flit_wr;
				
			// mux out sbp chanel
			assign chan_out[i].sbp_channel = (outport_is_granted[i])? new_sbp_channel[i] : ss_sbp_chanel[i];
			
			
			
			
			
		end else begin : no_sbp 
			assign to_r2_chan_out.flit_wr =  chan_in.flit_chanel.flit_wr;			
		end	
			
	end //for
	endgenerate
endmodule	
	
`endif	
	


