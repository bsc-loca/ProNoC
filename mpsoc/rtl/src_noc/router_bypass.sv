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



module header_flit_info
	import pronoc_pkg::*;
#(
	parameter DATA_w = 0
)(
	flit,
	hdr_flit,		
	data_o    
);
 	localparam 
	Dw = (DATA_w==0)? 1 : DATA_w;
	
	input flit_t flit;
	output hdr_flit_t hdr_flit;
	output [Dw-1 : 0] data_o;
              
     
	localparam		         
		DATA_LSB= MSB_BE+1,               DATA_MSB= (DATA_LSB + DATA_w)<Fpay ? DATA_LSB + Dw-1 : Fpay-1,
		OFFSETw = DATA_MSB - DATA_LSB +1;
   
	wire [OFFSETw-1 : 0 ] offset;
  
	assign hdr_flit.src_e_addr  = flit.payload [E_SRC_MSB : E_SRC_LSB];
	assign hdr_flit.dest_e_addr = flit.payload [E_DST_MSB : E_DST_LSB];
	assign hdr_flit.destport    = flit.payload [DST_P_MSB : DST_P_LSB];
    
   
	generate
		if(C>1)begin :have_class 
			assign hdr_flit.message_class = flit.payload [CLASS_MSB : CLASS_LSB];
		end else begin : no_class
			assign hdr_flit.message_class = {Cw{1'b0}};
		end   

		/* verilator lint_off WIDTH */
		if(SWA_ARBITER_TYPE != "RRA")begin  : wrra_b
			/* verilator lint_on WIDTH */
			assign hdr_flit.weight =  flit.payload [WEIGHT_MSB : WEIGHT_LSB];    
		end else begin : rra_b
			assign hdr_flit.weight = {WEIGHTw{1'bX}};        
		end 
    
		if( BYTE_EN ) begin : be_1
			assign hdr_flit.be = flit.payload [BE_MSB : BE_LSB];    
		end else begin : be_0    
			assign hdr_flit.be = {BEw{1'bX}};
		end
    
    
		assign offset = flit.payload [DATA_MSB : DATA_LSB];    
    
    
		if(Dw > OFFSETw) begin : if1     
			assign data_o={{(Dw-OFFSETw){1'b0}},offset};
		end else begin : if2 
			assign data_o=offset[Dw-1 : 0];
		end    
    
	endgenerate          
   
	

endmodule


module sbp_chanel_check 
		import pronoc_pkg::*;
	(
		flit_chanel,
		sbp_chanel,
		reset,
		clk		
	);

	input flit_chanel_t  flit_chanel;
	input sbp_chanel_t   sbp_chanel; 		
	input reset,clk;
	
	sbp_chanel_t   sbp_chanel_delay; 
	always @(posedge clk) sbp_chanel_delay<=sbp_chanel;
	
	hdr_flit_t hdr_flit;
	header_flit_info extract(
			.flit(flit_chanel.flit),
			.hdr_flit(hdr_flit),		
			.data_o()
		);

	always @(posedge clk) begin 
		if(flit_chanel.flit_wr) begin 
			if(sbp_chanel_delay.ovc!=flit_chanel.flit.vc) begin 
				$display("%t: ERROR: sbp ovc %d is not equal with flit ovc %d. %m",$time,sbp_chanel_delay.ovc,flit_chanel.flit.vc );
				$finish;
			end
			if(flit_chanel.flit.hdr_flag==1'b1 &&   hdr_flit.dest_e_addr != sbp_chanel_delay.dest_e_addr) begin 
				$display("%t: ERROR: sbp dest_e_addr %d is not equal with flit dest_e_addr %d. %m",$time,sbp_chanel_delay.dest_e_addr,hdr_flit.dest_e_addr );
				$finish;
			end
			if(flit_chanel.flit.hdr_flag!=sbp_chanel_delay.hdr_flit) begin 
				$display("%t: ERROR: sbp and current hdr flag (%d!=%d) miss-match. %m",$time, sbp_chanel_delay.hdr_flit, flit_chanel.flit.hdr_flag);
				$finish;
			end
			
		end	
		
	end	
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
		ovc_locally_requested,
		reset,clk
);
		
	
	
	//ivc info 
	input reset,clk;
	input  ivc_info_t 	ivc_info    [P-1 : 0][V-1 : 0];
	input  iport_info_t iport_info  [P-1 : 0];
	input  oport_info_t oport_info  [P-1 : 0]; 
	output sbp_chanel_t sbp_chanel  [P-1 : 0];
	output [V-1 : 0] ovc_locally_requested [P-1 : 0];
			
	sbp_ivc_info_t  sbp_ivc_info [P-1 : 0][V-1 : 0];
	sbp_ivc_info_t  sbp_ivc_mux  [P-1 : 0];
	
	sbp_ivc_info_t  sbp_ivc_info_all_port [P-1 : 0] [P-1 : 0];
	sbp_ivc_info_t  sbp_vc_info_o [P-1 : 0];
	
	wire [V-1 : 0] assigned_ovc [P-1:0];
	wire [V-1 : 0] non_assigned_vc_req [P-1:0];
	wire [P-1 : 0] mask_gen  [P-1 : 0][V-1 :0];
	wire [V-1 : 0] ovc_locally_requested_next [P-1 : 0];
	
	/* 
						P  V                   P		P  V   p
	non_assigned_vc_req[i][j] destport_one_hot[z]-->   [z][ j][i]
	non_assigned_vc_req[0][0] destport_one_hot[3]--> | [3][0] [0]
	non_assigned_vc_req[1][0] destport_one_hot[3]--> | [3][0] [1]
	non_assigned_vc_req[2][0] destport_one_hot[3]--> | [3][0] [2]
	*/
	genvar i,j,z;
	generate 
	for (i=0;i<P;i=i+1) begin : port_
				
		for (j=0; j < V; j=j+1) begin : ivc					
			assign sbp_ivc_info[i][j].dest_e_addr = ivc_info[i][j].dest_e_addr;
			assign sbp_ivc_info[i][j].ovc_is_assigned= ivc_info[i][j].ovc_is_assigned;
			assign sbp_ivc_info[i][j].assigned_ovc_bin=ivc_info[i][j].assigned_ovc_bin;	
			assign non_assigned_vc_req[i][j] = ~ivc_info[i][j].ovc_is_assigned & ivc_info[i][j].ivc_req;
			for (z=0; z < P; z=z+1) begin : port
				assign mask_gen[z][j][i] = non_assigned_vc_req[i][j] & ivc_info[i][j].destport_one_hot[z]; 
			end
			assign ovc_locally_requested_next[i][j]=|mask_gen[i][j];
		end//V
		
		register #(.W(V)) reg1 (.in(ovc_locally_requested_next[i] ), .reset(reset), .clk(clk), .out(ovc_locally_requested[i]));
		
		
		
		
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
					sbp_chanel[i].dest_e_addr<= {EAw{1'b0}};	
					sbp_chanel[i].ovc<= {V{1'b0}};
					sbp_chanel[i].hdr_flit<=1'b0;
				end else begin 	
					sbp_chanel[i].dest_e_addr<= sbp_vc_info_o[i].dest_e_addr;	
					sbp_chanel[i].ovc<= (sbp_vc_info_o[i].ovc_is_assigned)? assigned_ovc[i] : oport_info[i].non_sbp_ovc_is_allocated;
					sbp_chanel[i].hdr_flit<=~sbp_vc_info_o[i].ovc_is_assigned;
				end
			end		
	
			assign sbp_chanel[i].requests = (oport_info[i].crossbar_flit_wr)? {SBP_NUM{1'b1}}:{SBP_NUM{1'b0}} ;
			
	
		
		end//port_
		endgenerate	
	
//	generate for (i=0; i < P; i=i+1) begin : port
//			assign sbp_ivc_info_o[i] = (granted_dest_port[i]==1'b1)? ivc_info_mux : {SBP_IVC_w{1'b0}};		
//		end endgenerate 	

			
endmodule
 
 
 
 
module sbp_bypass_chanels
 	import pronoc_pkg::*;
#(
	parameter P=5
)(			
	ivc_info,
	iport_info,
	oport_info,
	sbp_chanel_new,
	sbp_chanel_in,
	sbp_chanel_out,
	sbp_req,
	reset,
	clk
	
);

	input reset,clk;	
	input sbp_chanel_t sbp_chanel_new  [P-1 : 0];
	input sbp_chanel_t sbp_chanel_in   [P-1 : 0];
	input ivc_info_t   ivc_info    [P-1 : 0][V-1 : 0];
 	input iport_info_t iport_info  [P-1 : 0];
 	input oport_info_t oport_info  [P-1 : 0];
 	
 	output [P-1 : 0] sbp_req;
 	output sbp_chanel_t sbp_chanel_out   [P-1 : 0];
 	
 	
	sbp_chanel_t sbp_chanel_shifted  [P-1 : 0];
	localparam DISABLE = P;
	
	wire [V-1 : 0 ] ivc_forwardable [P-1 : 0];
	wire [P-1 :0] sbp_forwardable;
	wire [P-1 :0] outport_is_granted;
	
	genvar i;
	generate
	for (i=0;i<P;i=i+1) begin: port	
		assign ivc_forwardable[i] = iport_info[i].ivc_req;
		assign outport_is_granted[i] = oport_info[i].crossbar_flit_wr;
		
	
		localparam SS_PORT = strieght_port (P,i); // the straight port number
		if(SS_PORT != DISABLE) begin: ssp 
			
			//sbp_chanel_shifter
			assign sbp_forwardable[i] = |  (ivc_forwardable[i] & sbp_chanel_in[i].ovc);
			assign {sbp_chanel_shifted[i].requests,sbp_req[i]} =(sbp_forwardable[i])? {1'b0,sbp_chanel_in[i].requests}:{{SBP_NUM{1'b0}},sbp_chanel_in[i].requests[0]};
			
			// mux out sbp chanel
			assign sbp_chanel_out[i] = (outport_is_granted[i])? sbp_chanel_new[i] : sbp_chanel_shifted[SS_PORT];
			
			
			
			
		end else begin
			assign {sbp_chanel_shifted[i].requests,sbp_req[i]} = {(SBP_NUM+1){1'b0}};
			assign sbp_chanel_out[i] = {SBP_CHANEL_w{1'b0}};
		end
		
	end	
	endgenerate
 
 
endmodule 
 
 
 
 
 

module check_straight_oport #(
		parameter TOPOLOGY          =   "MESH", 
		parameter ROUTE_NAME        =   "XY",
		parameter ROUTE_TYPE        =   "DETERMINISTIC", 
		parameter DSTPw             =   4,
		parameter SS_PORT_LOC     =   1
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
			if (SS_PORT_LOC == 0 || SS_PORT_LOC > 4) begin : local_ports
				assign goes_straight_o = 1'b0; // There is not a next router in this case at all	
			end	
			else begin :non_local
								
				wire [4 : 0 ] destport_one_hot;
				mesh_tori_decode_dstport decoder(
						.dstport_encoded(destport_coded_i),
						.dstport_one_hot(destport_one_hot)
					);
				
				assign goes_straight_o = destport_one_hot [SS_PORT_LOC];	
			end//else
		end//mesh_tori
		/* verilator lint_off WIDTH */ 
		else if(TOPOLOGY ==  "RING" || TOPOLOGY ==  "LINE"  ) begin :oneD		
			/* verilator lint_on WIDTH */ 
			if (SS_PORT_LOC == 0 || SS_PORT_LOC > 2) begin : local_ports
				assign goes_straight_o = 1'b0; // There is not a next router in this case at all	
			end	
			else begin :non_local
				
				wire [2: 0 ] destport_one_hot;
    
				line_ring_decode_dstport decoder(
						.dstport_encoded(destport_coded_i),
						.dstport_one_hot(destport_one_hot)
						
					);
				assign goes_straight_o = destport_one_hot [SS_PORT_LOC];	
				
			end	//non_local
		end// oneD
		
		//TODO Add fattree & custom 
			
	endgenerate	
	
endmodule	

 

	
module sbp_validity_check_per_ivc  
	import pronoc_pkg::*;
#(
	parameter IVC_NUM = 0
)(
	reset                  ,
	clk                    ,
	//sbp channel
	goes_straight		   ,
	sbp_requests_i         ,
	sbp_ivc_i              ,
	sbp_hdr_flit		   ,		
	//flit		               
	flit_hdr_flag_i        ,
	flit_tail_flag_i       ,
	flit_wr_i              ,
	//router ivc status
	ovc_locally_requested     ,
	assigned_to_ss_ovc          ,
	assigned_ovc_not_full       ,
	ovc_is_assigned             ,
	ivc_request                 ,
	//ss port status		                    
	ss_ovc_avalable_in_ss_port  ,
	ss_port_link_reg_flit_wr    ,
	//output                          
	sbp_ivc_sbp_en_o            ,
	sbp_credit_o             	,
	sbp_buff_space_decreased_o  ,
	sbp_ss_ovc_is_allocated_o   ,
	sbp_ss_ovc_is_released_o    ,
	sbp_mask_available_ss_ovc_o ,
	sbp_ivc_granted_ovc_num_o
);
	
input reset, clk;
//sbp channel
input goes_straight		   ,
	sbp_requests_i         ,
	sbp_ivc_i              ,
	sbp_hdr_flit		   ,		
	//flit		               
	flit_hdr_flag_i        ,
	flit_tail_flag_i       ,
	flit_wr_i              ,
	//router ivc status
	ovc_locally_requested       ,
	assigned_to_ss_ovc          ,
	assigned_ovc_not_full       ,
	ovc_is_assigned             ,
	ivc_request                 ,
	//ss port status		                    
	ss_ovc_avalable_in_ss_port  ,
	ss_port_link_reg_flit_wr    ;
//output                          
output sbp_ivc_sbp_en_o         ,
	sbp_credit_o             	,
	sbp_buff_space_decreased_o  ,
	sbp_ss_ovc_is_allocated_o   ,
	sbp_ss_ovc_is_released_o    ,
	sbp_mask_available_ss_ovc_o;	
		
output reg [V-1 : 0] sbp_ivc_granted_ovc_num_o;

always @(*) begin 
	sbp_ivc_granted_ovc_num_o={V{1'b0}};
	sbp_ivc_granted_ovc_num_o[IVC_NUM]=sbp_ss_ovc_is_allocated_o;
end	
		
		
		
wire  sbp_req_valid_next  = sbp_requests_i &  sbp_ivc_i & goes_straight;
logic sbp_req_valid;	
wire  sbp_hdr_flit_req_next = sbp_req_valid_next  & sbp_hdr_flit;
logic sbp_hdr_flit_req;
	
register #(.W(1)) req1 (.in(sbp_req_valid_next), .reset(reset), .clk(clk), .out(sbp_req_valid));
register #(.W(1)) req2 (.in(sbp_hdr_flit_req_next), .reset(reset), .clk(clk), .out(sbp_hdr_flit_req));
	
	
// condition1: new sbp vc allocation condition
wire hdr_flit_condition = ~ovc_locally_requested &	ss_ovc_avalable_in_ss_port;	
wire nonhdr_flit_condition =  assigned_to_ss_ovc & assigned_ovc_not_full;
wire condition1 = (ovc_is_assigned)? nonhdr_flit_condition : hdr_flit_condition;
wire condition2 = ~(ivc_request | ss_port_link_reg_flit_wr);
wire conditions_met = condition1 & condition2;
assign sbp_ivc_sbp_en_o = conditions_met & sbp_req_valid;
	
	
	
assign sbp_buff_space_decreased_o =  sbp_ivc_sbp_en_o & flit_wr_i ;
assign sbp_ss_ovc_is_allocated_o  =  sbp_buff_space_decreased_o & !ovc_is_assigned  & flit_hdr_flag_i;  
assign sbp_ss_ovc_is_released_o   =  sbp_buff_space_decreased_o & flit_tail_flag_i;
	
//mask the available SS OVC for local requests allocation if the following conditions met
assign sbp_mask_available_ss_ovc_o = sbp_hdr_flit_req & ~ovc_locally_requested & condition2;
	
	
register #(.W(1)) credit(.in(sbp_buff_space_decreased_o), .reset(reset), .clk(clk), .out(sbp_credit_o));
	
endmodule
	
	
	
module sbp_allocator_per_iport 
	import pronoc_pkg::*;
#(
	parameter P=5,
	parameter SW_LOC=0,
	parameter SS_PORT_LOC=1
	)(
	//general
	clk,
	reset,
	current_r_addr_i,
	neighbors_r_addr_i,
	//sbp_chanel & flit in
	sbp_chanel_i,
	flit_chanel_i,
	//router status signals
	ivc_info,			
	ss_oport_info,
	ovc_locally_requested,//make sure no conflict is existed between local & SBP VC allocation
	ss_port_link_reg_flit_wr,	
	//output
	sbp_destport_o,
	sbp_lk_destport_o,
	sbp_ivc_sbp_en_o,              		
	sbp_credit_o,             	
	sbp_buff_space_decreased_o, 
	sbp_ss_ovc_is_allocated_o,     
	sbp_ss_ovc_is_released_o, 
	sbp_ivc_num_getting_ovc_grant_o,
	sbp_ivc_reset_o,
	sbp_mask_available_ss_ovc_o,
	sbp_hdr_flit_req_o,
	sbp_ivc_granted_ovc_num_o
);
	//general
 	input clk, reset;
 	input [RAw-1   :0]  current_r_addr_i;
 	input [RAw-1:  0]  neighbors_r_addr_i [P-1 : 0];	
	//channels
	input sbp_chanel_t sbp_chanel_i;
	input flit_chanel_t flit_chanel_i;
	//ivc
	input ivc_info_t ivc_info [V-1 : 0];
	input [V-1 : 0] ovc_locally_requested;
	//ss port
	input oport_info_t ss_oport_info; 
	input ss_port_link_reg_flit_wr;		
	//output
	output [DSTPw-1 : 0] sbp_destport_o,sbp_lk_destport_o;
	output sbp_hdr_flit_req_o;
	output [V-1 : 0] 
		sbp_ivc_sbp_en_o,              		
		sbp_credit_o,             	
		sbp_buff_space_decreased_o, 
		sbp_ss_ovc_is_allocated_o,     
		sbp_ss_ovc_is_released_o,      
		sbp_mask_available_ss_ovc_o,
		sbp_ivc_num_getting_ovc_grant_o,
		sbp_ivc_reset_o;	
	output [V*V-1 : 0] sbp_ivc_granted_ovc_num_o;
	
	wire  [DSTPw-1  :   0]  destport,lkdestport;
	wire  goes_straight;
	
	assign sbp_ivc_num_getting_ovc_grant_o = sbp_ss_ovc_is_allocated_o;
	assign sbp_ivc_reset_o = sbp_ss_ovc_is_released_o;
	
	/* verilator lint_off WIDTH */ 
	localparam  LOCATED_IN_NI=  
		(TOPOLOGY=="RING" || TOPOLOGY=="LINE") ? (SW_LOC == 0 || SW_LOC>2) :
		(TOPOLOGY =="MESH" || TOPOLOGY=="TORUS")? (SW_LOC == 0 || SW_LOC>4) : 0;
	/* verilator lint_on WIDTH */ 
	
	// does the route computation for the current router
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
		.src_e_addr  	 (			     ),// needed only for custom routing
		.dest_e_addr     (sbp_chanel_i.dest_e_addr    ), 
		.destport        (destport)
	); 
	
	register #(.W(DSTPw)) reg1 (.in(destport), .reset(reset), .clk(clk), .out(sbp_destport_o));
	
	check_straight_oport #(
		.TOPOLOGY      ( TOPOLOGY     ),
		.ROUTE_NAME    ( ROUTE_NAME   ),
		.ROUTE_TYPE    ( ROUTE_TYPE   ),
		.DSTPw         ( DSTPw        ),
		.SS_PORT_LOC   ( SS_PORT_LOC)
	) check_straight (
		.destport_coded_i (destport),
		.goes_straight_o  (goes_straight)
	);   
	
	//look ahead routing. take straight next router address as input
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
		) lkrouting (
			.reset           (reset          ), 
			.clk             (clk            ), 
			.current_r_addr  (neighbors_r_addr_i[SS_PORT_LOC] ), 
			.src_e_addr  	 (			     ),// needed only for custom routing
			.dest_e_addr     (sbp_chanel_i.dest_e_addr    ), 
			.destport        (lkdestport)
		); 
	
	register #(.W(DSTPw)) reg2 (.in(lkdestport), .reset(reset), .clk(clk), .out(sbp_lk_destport_o));
	
	
	
		
	
	
	
	genvar i,j;
	generate
	for (i=0;i<V; i=i+1) begin : vc
		sbp_validity_check_per_ivc #(
				.IVC_NUM(i)		
		)	validity_check (
			.reset                       (reset                   		), 
			.clk                         (clk                     		), 
			.goes_straight				 (goes_straight),
			.sbp_requests_i              (sbp_chanel_i.requests[0] 		), 
			.sbp_ivc_i                   (sbp_chanel_i.ovc  [i]    		),
			.sbp_hdr_flit				 (sbp_chanel_i.hdr_flit     ),
						
			.flit_hdr_flag_i         	(flit_chanel_i.flit.hdr_flag      	),
			.flit_tail_flag_i        	(flit_chanel_i.flit.tail_flag       ),
			.flit_wr_i               	(flit_chanel_i.flit_wr         ),
				
			.ovc_locally_requested      (ovc_locally_requested[i]	), 
						
			.assigned_to_ss_ovc          (ivc_info[i].assigned_ovc_num[i]),
			.assigned_ovc_not_full       (ivc_info[i].assigned_ovc_not_full), 
			.ovc_is_assigned             (ivc_info[i].ovc_is_assigned), 
			.ivc_request                 (ivc_info[i].ivc_req  	),
						
			.ss_ovc_avalable_in_ss_port  (ss_oport_info.ovc_avalable[i]), 
			.ss_port_link_reg_flit_wr    (ss_port_link_reg_flit_wr     ), 
				
				
			.sbp_ivc_sbp_en_o      		 (sbp_ivc_sbp_en_o[i]	),
			.sbp_credit_o             	 (sbp_credit_o[i]   	), 
			.sbp_buff_space_decreased_o  (sbp_buff_space_decreased_o[i]), 
			.sbp_ss_ovc_is_allocated_o   (sbp_ss_ovc_is_allocated_o[i] ), 
			.sbp_ss_ovc_is_released_o    (sbp_ss_ovc_is_released_o[i]  ),
			.sbp_mask_available_ss_ovc_o (sbp_mask_available_ss_ovc_o[i] ),
			.sbp_ivc_granted_ovc_num_o   (sbp_ivc_granted_ovc_num_o[(i+1)*V-1 : i*V]   )
		);	
				
		
		
		
		
	end//for
	endgenerate	
	
	
	register #(.W(1)) reg3 (.in(sbp_chanel_i.hdr_flit), .reset(reset), .clk(clk), .out(sbp_hdr_flit_req_o));
	
endmodule	
 
//
module sbp_credit_manage #(
	parameter V=4,	
	parameter B=2
	)(
		credit_in,
		sbp_credit_in,
		credit_out,
		reset,
		clk
	);
	localparam Bw=$clog2(B);
		
 	input [V-1 : 0]  credit_in, sbp_credit_in;
 	input reset,	clk;
 	output [V-1 : 0]  credit_out;
	genvar i;
	generate 
	for (i=0;i<V;i=i+1)begin :v_
	 	sbp_credit_manage_per_vc #(
	 		.Bw(Bw)
	 		)credit(
	 			.credit_in(credit_in[i]),
	 			.sbp_credit_in(sbp_credit_in[i]),
	 			.credit_out(credit_out[i]),
	 			.reset(reset),
	 			.clk(clk)
	 		);
	end
	endgenerate	
endmodule	
	
module sbp_credit_manage_per_vc #(
		parameter Bw=2
)(
	credit_in,
	sbp_credit_in,
	credit_out,
	reset,
	clk
);

 	input credit_in, sbp_credit_in,	reset,	clk;
 	output credit_out;

 	logic [Bw : 0] counter, counter_next;
 	
 	always @(*) begin 
 		counter_next=counter;
 		if(credit_in & 	sbp_credit_in ) counter_next = counter +1'b1;
 		else if(credit_in |	sbp_credit_in ) counter_next=counter;
 		else if(counter > 0) counter_next = counter -1'b1;
 	end

 	assign credit_out = credit_in | 	sbp_credit_in | (counter > 0);

 	register #(.W(Bw+1)) reg1 (.in(counter_next), .reset(reset), .clk(clk), .out(counter));
 	

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
   				.src_e_addr      (src_e_addr     ),
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
		ovc_locally_requested
	);
		
	localparam P_1=P-1;	
	
	//ivc info 
	input ivc_info_t ivc_info [V-1 : 0];
	
			
		
	//sw alloc grants
	input [V-1 : 0] first_arbiter_granted_ivc;
	input [P_1-1 :0] granted_dest_port_i;
	output  sbp_ivc_t  sbp_ivc_info_o [P-1 : 0];
	output [V-1 : 0] ovc_locally_requested  [P-1 : 0]; 

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
				assign ovc_locally_requested[j][i] = sbp_ovc_alloc_may_conflict[i] & ivc_info[i].destport_one_hot[j]; 
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
		.ovc_locally_requested   (ovc_locally_requested[i])
		);
	
	
		
	
	
	end
	endgenerate
		
	
	
endmodule 	
	
	

	
`endif	
	


