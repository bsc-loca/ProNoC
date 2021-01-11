`timescale     1ns/1ps

//`define MONITORE_PATH

/***********************************************************************
 **	File: router.v
 **    
 **	Copyright (C) 2014-2017  Alireza Monemi
 **    
 **	This file is part of ProNoC 
 **
 **	ProNoC ( stands for Prototype Network-on-chip)  is free software: 
 **	you can redistribute it and/or modify it under the terms of the GNU
 **	Lesser General Public License as published by the Free Software Foundation,
 **	either version 2 of the License, or (at your option) any later version.
 **
 ** 	ProNoC is distributed in the hope that it will be useful, but WITHOUT
 ** 	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 ** 	or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
 ** 	Public License for more details.
 **
 ** 	You should have received a copy of the GNU Lesser General Public
 ** 	License along with ProNoC. If not, see <http:**www.gnu.org/licenses/>.
 **
 **
 **	Description: 
 **	A two stage router 
 **   stage1: lk-route,sw/VC allocation
 **   stage2: switch-traversal
 **************************************************************/


module router_two_stage 
		import pronoc_pkg::*;
		
		# (
			parameter P = 6     // router port num		   
		)(
		current_r_addr,// connected to constant parameter  
		
		chan_in,
		chan_out,
		
		clk,
		reset

		);
 
                

	// The current/neighbor routers addresses/port. These values are fixed in each router and they are supposed to be given as parameter. 
	// However, in order to give an identical RTL code to each router, they are given as input ports. The identical RTL code reduces the
	// compilation time. Note that they wont be implimented as  input ports in the final synthesized code. 

	input [RAw-1 :  0]  current_r_addr;
	
	input   router_channel_t chan_in [P-1 : 0];
	output  router_channel_t chan_out [P-1 : 0];
	input   clk,reset;
	
	
	
	localparam
		PV = V * P,
		PVV = PV * V,    
		P_1 = P-1,
		PP_1 = P_1 * P,
		PVP_1 = PV * P_1,		  
		PFw = P*Fw,
		CONG_ALw = CONGw* P,    //  congestion width per router
		W = WEIGHTw,
		WP = W * P, 
		WPP=  WP * P,
		PRAw= P * RAw;     
	
	
	
	wire [PRAw-1:  0]  neighbors_r_addr;
    

	wire  [PFw-1 :  0]  flit_in_all;
	wire  [P-1 :  0]  flit_in_wr_all;
	wire  [PV-1 :  0]  credit_out_all;
	wire  [CONG_ALw-1 :  0]  congestion_in_all;
    
	wire  [PFw-1 :  0]  flit_out_all;
	wire  [P-1 :  0]  flit_out_wr_all;
	wire  [PV-1 :  0]  credit_in_all;
	wire  [CONG_ALw-1 :  0]  congestion_out_all;
    
	genvar i;
	generate for (i=0; i<P; i=i+1 ) begin 
			assign  neighbors_r_addr  [(i+1)*RAw-1:  i*RAw] = chan_in[i].neighbors_r_addr;
			assign  flit_in_all       [(i+1)*Fw-1:  i*Fw] = chan_in[i].flit;
			assign  flit_in_wr_all    [i] = chan_in[i].flit_wr;   
			assign  credit_in_all     [(i+1)*V-1:  i*V] = chan_in[i].credit;
			assign  congestion_in_all [(i+1)*CONGw-1:  i*CONGw] = chan_in[i].congestion; 
			
			assign  chan_out[i].neighbors_r_addr = current_r_addr;
			assign  chan_out[i].flit=          flit_out_all       [(i+1)*Fw-1:  i*Fw];       
			assign  chan_out[i].flit_wr=       flit_out_wr_all    [i];                       
			assign  chan_out[i].credit=        credit_out_all     [(i+1)*V-1:  i*V];         
			assign  chan_out[i].congestion=    congestion_out_all [(i+1)*CONGw-1:  i*CONGw];			
	end		
	endgenerate
	

	// old router verilog code
    
	localparam WRRA_CONFIG_INDEX = 0; 
	
	//internal wires
	wire  [PV-1 : 0] ovc_allocated_all;
	wire  [PVV-1 : 0] granted_ovc_num_all;
	wire  [PV-1 : 0] ivc_num_getting_sw_grant;
	wire  [PV-1 : 0] ivc_num_getting_ovc_grant;
	wire  [PVV-1 : 0] spec_ovc_num_all;
	wire  [PV-1 : 0] nonspec_first_arbiter_granted_ivc_all;
	wire  [PV-1 : 0] spec_first_arbiter_granted_ivc_all;
	wire  [PP_1-1 : 0] nonspec_granted_dest_port_all;
	wire  [PP_1-1 : 0] spec_granted_dest_port_all;    
	wire  [PP_1-1 : 0] granted_dest_port_all;
	wire  [P-1 : 0] any_ivc_sw_request_granted_all;
	wire  [P-1 :  0] any_ovc_granted_in_outport_all;    
	wire  [P-1 : 0] granted_dst_is_from_a_single_flit_pck;
	// to vc/sw allocator
	wire  [PVP_1-1 :  0] dest_port_all;
	wire  [PV-1 :  0] ovc_is_assigned_all;
	wire  [PV-1 :  0] ivc_request_all;
	wire  [PV-1 :  0] assigned_ovc_not_full_all;
	wire  [PVV-1 :  0] masked_ovc_request_all;
	wire  [PV-1 : 0] pck_is_single_flit_all; 
	wire  [PV-1 :  0] vc_weight_is_consumed_all;
	wire  [P-1 :  0]iport_weight_is_consumed_all;       
        
	// to the crossbar
	wire  [PFw-1 : 0] iport_flit_out_all;
	wire  [P-1 : 0] ssa_flit_wr_all;
	wire  [PFw-1 :  0] cross_bar_flit_out_all;
	reg   [PP_1-1 : 0] granted_dest_port_all_delayed;
    
    
	//to weight control
	wire [WP-1 : 0] iport_weight_all;
	wire [WPP-1: 0] oports_weight_all;
	wire refresh_w_counter;
            
	inout_ports
		#(
			.V(V),
			.P(P),
			.B(B), 
			.T1(T1),
			.T2(T2),
			.T3(T3),
			.T4(T4),
			.RAw(RAw),  
			.EAw(EAw), 
			.C(C),    
			.Fpay(Fpay),    
			.VC_REALLOCATION_TYPE(VC_REALLOCATION_TYPE),
			.COMBINATION_TYPE(COMBINATION_TYPE),
			.TOPOLOGY(TOPOLOGY),
			.ROUTE_TYPE(ROUTE_TYPE),
			.ROUTE_NAME(ROUTE_NAME),
			.CONGESTION_INDEX(CONGESTION_INDEX),
			.DEBUG_EN(DEBUG_EN),
			.AVC_ATOMIC_EN(AVC_ATOMIC_EN),
			.CONGw(CONGw),
			.CVw(CVw),
			.CLASS_SETTING(CLASS_SETTING),   
			.ESCAP_VC_MASK(ESCAP_VC_MASK),
			.DSTPw(DSTPw),
			.SSA_EN(SSA_EN),
			.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE),
			.WEIGHTw(WEIGHTw),
			.WRRA_CONFIG_INDEX(WRRA_CONFIG_INDEX),
			.PPSw(PPSw),
			.MIN_PCK_SIZE(MIN_PCK_SIZE),
			.BYTE_EN(BYTE_EN)
        
		)
		the_inout_ports
		(
			.current_r_addr(current_r_addr),
			.neighbors_r_addr(neighbors_r_addr),
			.flit_in_all(flit_in_all),
			.flit_in_wr_all(flit_in_wr_all),
			.credit_out_all(credit_out_all),
			.credit_in_all(credit_in_all),
			.masked_ovc_request_all(masked_ovc_request_all),
			.pck_is_single_flit_all(pck_is_single_flit_all),
			.granted_dst_is_from_a_single_flit_pck(granted_dst_is_from_a_single_flit_pck),
			.ovc_allocated_all(ovc_allocated_all), 
			.granted_ovc_num_all(granted_ovc_num_all), 
			.ivc_num_getting_sw_grant(ivc_num_getting_sw_grant), 
			.ivc_num_getting_ovc_grant(ivc_num_getting_ovc_grant), 
			.spec_ovc_num_all(spec_ovc_num_all), 
			.nonspec_first_arbiter_granted_ivc_all(nonspec_first_arbiter_granted_ivc_all), 
			.spec_first_arbiter_granted_ivc_all(spec_first_arbiter_granted_ivc_all), 
			.nonspec_granted_dest_port_all(nonspec_granted_dest_port_all), 
			.spec_granted_dest_port_all(spec_granted_dest_port_all), 
			.granted_dest_port_all(granted_dest_port_all), 
			.any_ivc_sw_request_granted_all(any_ivc_sw_request_granted_all), 
			.any_ovc_granted_in_outport_all(any_ovc_granted_in_outport_all),
			.dest_port_all(dest_port_all), 
			.ovc_is_assigned_all(ovc_is_assigned_all), 
			.ivc_request_all(ivc_request_all), 
			.assigned_ovc_not_full_all(assigned_ovc_not_full_all), 
			.flit_out_all(iport_flit_out_all),
			.congestion_in_all(congestion_in_all),
			.congestion_out_all(congestion_out_all),
			//  .lk_destination_all(lk_destination_all),
			.ssa_flit_wr_all(ssa_flit_wr_all),
			.iport_weight_all(iport_weight_all),
			.oports_weight_all(oports_weight_all),
			.vc_weight_is_consumed_all(vc_weight_is_consumed_all),
			.iport_weight_is_consumed_all(iport_weight_is_consumed_all), 
			.refresh_w_counter(refresh_w_counter), 
			.clk(clk), 
			.reset(reset)
		);


	combined_vc_sw_alloc #(
			.V(V),    
			.P(P), 
			.COMBINATION_TYPE(COMBINATION_TYPE),
			.FIRST_ARBITER_EXT_P_EN (FIRST_ARBITER_EXT_P_EN),
			.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ), 
			.DEBUG_EN(DEBUG_EN),
			.MIN_PCK_SIZE(MIN_PCK_SIZE)
		)
		the_combined_vc_sw_alloc
		(
			.dest_port_all(dest_port_all), 
			.masked_ovc_request_all(masked_ovc_request_all),
			.ovc_is_assigned_all(ovc_is_assigned_all), 
			.ivc_request_all(ivc_request_all), 
			.assigned_ovc_not_full_all(assigned_ovc_not_full_all), 
			.pck_is_single_flit_all(pck_is_single_flit_all),
			.granted_dst_is_from_a_single_flit_pck(granted_dst_is_from_a_single_flit_pck),
			.ovc_allocated_all(ovc_allocated_all), 
			.granted_ovc_num_all(granted_ovc_num_all), 
			.ivc_num_getting_ovc_grant(ivc_num_getting_ovc_grant), 
			.ivc_num_getting_sw_grant(ivc_num_getting_sw_grant), 
			.spec_first_arbiter_granted_ivc_all(spec_first_arbiter_granted_ivc_all), 
			.nonspec_first_arbiter_granted_ivc_all(nonspec_first_arbiter_granted_ivc_all), 
			.nonspec_granted_dest_port_all(nonspec_granted_dest_port_all), 
			.spec_granted_dest_port_all(spec_granted_dest_port_all), 
			.granted_dest_port_all(granted_dest_port_all), 
			.any_ivc_sw_request_granted_all(any_ivc_sw_request_granted_all), 
			.any_ovc_granted_in_outport_all(any_ovc_granted_in_outport_all),
			.spec_ovc_num_all(spec_ovc_num_all),       
			// .lk_destination_all(lk_destination_all),  
			.vc_weight_is_consumed_all(vc_weight_is_consumed_all),  
			.iport_weight_is_consumed_all(iport_weight_is_consumed_all),  
			.clk(clk), 
			.reset(reset)
		);
        
   
	`ifdef SYNC_RESET_MODE 
		always @ (posedge clk )begin 
		`else 
			always @ (posedge clk or posedge reset)begin 
			`endif  
			if(reset) begin 
				granted_dest_port_all_delayed<= {PP_1{1'b0}};            
			end else begin
				granted_dest_port_all_delayed<= granted_dest_port_all;            
			end    
		end//always
    
		crossbar #(
				.TOPOLOGY(TOPOLOGY),
				.V (V),     // vc_num_per_port
				.P (P),     // router port num
				.Fpay (Fpay),
				.MUX_TYPE (MUX_TYPE),
				.ADD_PIPREG_AFTER_CROSSBAR (ADD_PIPREG_AFTER_CROSSBAR),
				.SSA_EN (SSA_EN)
			)
			the_crossbar
			(
				.granted_dest_port_all (granted_dest_port_all_delayed),
				.flit_in_all (iport_flit_out_all),
				.flit_out_all (cross_bar_flit_out_all),
				.flit_out_wr_all (flit_out_wr_all),
				.ssa_flit_wr_all (ssa_flit_wr_all),
				.clk (clk),
				.reset (reset)
        
			);    
     
      
		generate
		/* verilator lint_off WIDTH */ 
			if (SWA_ARBITER_TYPE != "RRA" ) begin : wrra_arb 
			/* verilator lint_on WIDTH */ 
   
			wire [WP-1 : 0] contention_all;
		wire [WP-1 : 0] limited_oport_weight_all;
   
		wrra_contention_gen #(
				.WEIGHTw(WEIGHTw),
				.WRRA_CONFIG_INDEX(WRRA_CONFIG_INDEX),
				.V(V),
				.P(P)
			)
			contention_gen
			(
				.limited_oport_weight_all(limited_oport_weight_all),
				.dest_port_all(dest_port_all),
				.ivc_request_all(ivc_request_all),
				.ovc_is_assigned_all(ovc_is_assigned_all), 
				.contention_all(contention_all),
				.iport_weight_all(iport_weight_all),
				.oports_weight_all(oports_weight_all)
            
			); 
        
		weights_update #(
				.ARBITER_TYPE(SWA_ARBITER_TYPE),
				.V(V),
				.P(P),
				.Fpay(Fpay),
				.WEIGHTw(WEIGHTw),
				.WRRA_CONFIG_INDEX(WRRA_CONFIG_INDEX),
				.C(C),
				.TOPOLOGY(TOPOLOGY),
				.EAw(EAw),
				.DSTPw(DSTPw),
				.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR)
        	
			)
			updater
			(
				.limited_oports_weight(limited_oport_weight_all),
				.refresh_w_counter(refresh_w_counter),
				.iport_weight_all(iport_weight_all),
				.contention_all(contention_all),
				.flit_in_all(cross_bar_flit_out_all),
				.flit_out_all(flit_out_all),
				.flit_out_wr_all(flit_out_wr_all),
				.clk(clk),
				.reset(reset)
			);        
         
	end // WRRA
	else begin : rra_arb
    
		assign flit_out_all  =  cross_bar_flit_out_all;  
    
	end
		endgenerate 
     
       
		//synthesis translate_off 
		//synopsys  translate_off
		generate 
		/* verilator lint_off WIDTH */ 
		if(DEBUG_EN && TOPOLOGY == "MESH")begin :dbg
		/* verilator lint_on WIDTH */ 
		debug_mesh_edges #(
			.T1(T1),
			.T2(T2),
			.T3(T3),
			.T4(T4),
			.RAw(RAw),
			.P(P)
		)
		debug_edges
		(
			.clk(clk),
			.current_r_addr(current_r_addr),
			.flit_out_wr_all(flit_out_wr_all)
		);
	end// DEBUG
		endgenerate 
		// synopsys  translate_on  
		// synthesis translate_on
      
    
    
		// for testing the route path
    

   
		// synthesis translate_off
		// synopsys  translate_off                                  
		`ifdef MONITORE_PATH
     
			genvar i;
		reg[P-1 :0] t1,t2;
		generate
			for (i=0;i<P;i=i+1)begin : lp                     
    
   
				always @(posedge clk) begin
					if(reset)begin 
						t1[i]<=1'b0;
						t2[i]<=1'b0;             
					end else begin 
						if(flit_in_wr_all[i]>0 && t1[i]==0)begin 
							$display("%t : router (addr=%h, port=%d)",$time,current_r_addr,i);
							$display("%t : Flit_in=%b, current_r_addr=%x, Port=%x, neighbors_r_addr=%x, ",$time,flit_in_all[(i+1)*Fw-1 : i*Fw],current_r_addr, i, neighbors_r_addr);
							t1[i]<=1;
						end
						if(flit_out_wr_all[i]>0 && t2[i]==0)begin 
							$display("%t port=%d: Flit_out=%b",$time,i,flit_out_all[(i+1)*Fw-1 : i*Fw]);
							t2[i]<=1;
						end
            
            
					end
				end
			end
		endgenerate
	`endif
   
   
   
	/*



    reg [10 :  0]  counter;
    reg [31 :  0]  flit_counter;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            flit_counter <=0;
            counter <= 0;
        end else begin 
            if(flit_in_wr_all>0 )begin 
                counter <=0;
                flit_counter<=flit_counter+1'b1;
                          
            end else begin 
                counter <= counter+1'b1;
                if( counter == 512 ) $display("%t : total flits received in (x=%d,Y=%d) is %d ",$time,current_r_addr,current_y,flit_counter);
            end
        end
    end
	 */


	//synopsys  translate_on
	//synthesis translate_on 


endmodule

