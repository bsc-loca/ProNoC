
    
    
/****************************************************************************
 * non_local_allocator.sv
 ****************************************************************************/

  
  
  
/**
 * Module: non_local_allocator
 * 
 * TODO: Add module documentation
 */
module non_local_allocator 
	import pronoc_pkg::*;
#(
	parameter P = 5  
)(
	flit_in_wr_all,
	flit_in_all,
	any_ovc_granted_in_outport_all ,
	any_ivc_sw_request_granted_all ,
	ovc_avalable_all,
	assigned_ovc_not_full_all,
	ivc_request_all,
	dest_port_encoded_all,
	assigned_ovc_num_all,
	ovc_is_assigned_all,      
        
	clk,
	reset,
	
	ssa_ivc_num_getting_sw_grant_all,
	ssa_ovc_allocated_all,
	ssa_flit_wr_all,
	
	nla_ovc_allocated_all,
	nla_ovc_released_all,
	nla_granted_ovc_num_all,	
	nla_ivc_num_getting_ovc_grant_all,
	nla_ivc_reset_all,
	nla_decreased_credit_in_ss_ovc_all,
	nla_single_flit_pck_all,
	
	sbp_ctrl_in,
	ssa_ctrl_o
	
);


localparam  PV          =   V   *   P,
	PVV         =   PV  *   V,
	PVDSTPw= PV * DSTPw,
	Fw          =   2+V+Fpay,//flit width
	PFw         =   P   *   Fw;
                

                   
               

                  
                
                

input   [PFw-1          :   0]  flit_in_all;
input   [P-1            :   0]  flit_in_wr_all;
input   [P-1            :   0]  any_ovc_granted_in_outport_all;
input   [P-1            :   0]  any_ivc_sw_request_granted_all;
input   [PV-1           :   0]  ovc_avalable_all;
input   [PV-1           :   0]  assigned_ovc_not_full_all;
input   [PV-1           :   0]  ivc_request_all;
input   [PVDSTPw-1      :   0]  dest_port_encoded_all;
input   [PVV-1          :   0]  assigned_ovc_num_all;
input   [PV-1           :   0]  ovc_is_assigned_all;
input   reset,clk;
input   sbp_ctrl_t     sbp_ctrl_in  [P-1 : 0];    
output  ssa_ctrl_t     ssa_ctrl_o     [P-1 : 0];    


output   [PV-1      :   0] nla_ovc_allocated_all;
output   [PV-1      :   0] nla_ovc_released_all;
output   [PVV-1     :   0] nla_granted_ovc_num_all;

output   [PV-1      :   0] nla_ivc_num_getting_ovc_grant_all;
output   [PV-1      :   0] nla_ivc_reset_all;
output   [PV-1      :   0] nla_decreased_credit_in_ss_ovc_all;
output   [PV-1		:	0] nla_single_flit_pck_all;



output [PV-1      :   0] ssa_ovc_allocated_all;
wire   [PV-1      :   0] ssa_ovc_released_all;
wire   [PVV-1     :   0] ssa_granted_ovc_num_all;
output [PV-1      :   0] ssa_ivc_num_getting_sw_grant_all;
wire   [PV-1      :   0] ssa_ivc_num_getting_ovc_grant_all;
wire   [PV-1      :   0] ssa_ivc_reset_all;
wire   [PV-1      :   0] ssa_decreased_credit_in_ss_ovc_all;
wire   [PV-1      :   0] ssa_single_flit_pck_all;
output  [P-1      :   0] ssa_flit_wr_all;

wire   [PV-1      :   0] sbp_ovc_allocated_all;
wire   [PV-1      :   0] sbp_ovc_released_all;
wire   [PVV-1     :   0] sbp_granted_ovc_num_all;
wire   [PV-1      :   0] sbp_ivc_num_getting_ovc_grant_all;
wire   [PV-1      :   0] sbp_ivc_reset_all;
wire   [PV-1      :   0] sbp_decreased_credit_in_ss_ovc_all;

genvar i;

generate
	
	/* verilator lint_off WIDTH */
	if( SSA_EN =="YES" ) begin : ssa 
	/* verilator lint_on WIDTH */
		ss_allocator #(
				.P(P)
			)
			the_ssa
			(
				.flit_in_wr_all(flit_in_wr_all),
				.flit_in_all(flit_in_all),
				.any_ivc_sw_request_granted_all(any_ivc_sw_request_granted_all),
				.any_ovc_granted_in_outport_all(any_ovc_granted_in_outport_all),
				.ovc_avalable_all(ovc_avalable_all),
				.ivc_request_all(ivc_request_all),
				.assigned_ovc_not_full_all(assigned_ovc_not_full_all),
				.dest_port_encoded_all(dest_port_encoded_all),
				.assigned_ovc_num_all(assigned_ovc_num_all),
				.ovc_is_assigned_all(ovc_is_assigned_all),
				.clk(clk),
				.reset(reset),
         
				.ovc_allocated_all(ssa_ovc_allocated_all),
				.ovc_released_all(ssa_ovc_released_all),
				.granted_ovc_num_all(ssa_granted_ovc_num_all),
				.ivc_num_getting_sw_grant_all(ssa_ivc_num_getting_sw_grant_all),
				.ivc_num_getting_ovc_grant_all(ssa_ivc_num_getting_ovc_grant_all),
				.ivc_reset_all(ssa_ivc_reset_all),
				.decreased_credit_in_ss_ovc_all(ssa_decreased_credit_in_ss_ovc_all),
				.single_flit_pck_all(ssa_single_flit_pck_all),
				.ssa_flit_wr_all(ssa_flit_wr_all),
				.ssa_ctrl_o(ssa_ctrl_o)
			);

	end else begin :non_ssa
		assign  ssa_ovc_allocated_all=  {PV{1'b0}};
		assign  ssa_ovc_released_all=  {PV{1'b0}};
		assign  ssa_granted_ovc_num_all= {PVV{1'b0}};
		assign  ssa_ivc_num_getting_sw_grant_all= {PV{1'b0}};
		assign  ssa_ivc_num_getting_ovc_grant_all= {PV{1'b0}};
		assign  ssa_ivc_reset_all=  {PV{1'b0}};
		assign  ssa_flit_wr_all= {P{1'b0}}; 
		assign  ssa_decreased_credit_in_ss_ovc_all = {PV{1'b0}};
		assign  ssa_single_flit_pck_all ={PV{1'b0}};
	end
		
		
	
	if(SBP_EN==1) begin :sbp
		for (i=0;i<P;i=i+1) begin :P_
			
			assign  sbp_ovc_allocated_all	[(i+1)*V-1  : i*V] = sbp_ctrl_in[i].ovc_is_allocated; 
			assign  sbp_ovc_released_all 	[(i+1)*V-1  : i*V] = sbp_ctrl_in[i].ovc_is_released;
			assign  sbp_granted_ovc_num_all	[(i+1)*V*V-1  : i*V*V]=sbp_ctrl_in[i].ivc_granted_ovc_num;
			assign  sbp_ivc_num_getting_ovc_grant_all [(i+1)*V-1  : i*V]=  sbp_ctrl_in[i].ivc_num_getting_ovc_grant;
			assign  sbp_ivc_reset_all [(i+1)*V-1  : i*V]=  sbp_ctrl_in[i].ivc_reset;
			assign  sbp_decreased_credit_in_ss_ovc_all [(i+1)*V-1  : i*V]= sbp_ctrl_in[i].buff_space_decreased;
		end// p
		
	end else begin : nosbp 
		assign  sbp_ovc_allocated_all=  {PV{1'b0}};
		assign  sbp_ovc_released_all=  {PV{1'b0}};
		assign  sbp_granted_ovc_num_all= {PVV{1'b0}};
		assign  sbp_ivc_num_getting_ovc_grant_all= {PV{1'b0}};
		assign  sbp_ivc_reset_all=  {PV{1'b0}};
		assign  sbp_decreased_credit_in_ss_ovc_all = {PV{1'b0}};
	
	end
		
 	endgenerate
	


	assign  nla_ovc_allocated_all             = ssa_ovc_allocated_all              | sbp_ovc_allocated_all             ;
	assign  nla_ovc_released_all              = ssa_ovc_released_all               | sbp_ovc_released_all              ;
	assign  nla_granted_ovc_num_all           = ssa_granted_ovc_num_all            | sbp_granted_ovc_num_all           ;

	assign  nla_ivc_num_getting_ovc_grant_all = ssa_ivc_num_getting_ovc_grant_all  | sbp_ivc_num_getting_ovc_grant_all ;
	assign  nla_ivc_reset_all                 = ssa_ivc_reset_all                  | sbp_ivc_reset_all                 ;
	assign  nla_decreased_credit_in_ss_ovc_all= ssa_decreased_credit_in_ss_ovc_all | sbp_decreased_credit_in_ss_ovc_all;
	assign  nla_single_flit_pck_all = ssa_single_flit_pck_all;
	
endmodule


