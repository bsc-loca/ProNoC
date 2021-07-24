// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

/**********************************************************************
 **    File:  mesh_torus_noc.v
 **    
 **    Copyright (C) 2014-2017  Alireza Monemi
 **    
 **    This file is part of ProNoC 
 **
 **    ProNoC ( stands for Prototype Network-on-chip)  is free software: 
 **    you can redistribute it and/or modify it under the terms of the GNU
 **    Lesser General Public License as published by the Free Software Foundation,
 **    either version 2 of the License, or (at your option) any later version.
 **
 **     ProNoC is distributed in the hope that it will be useful, but WITHOUT
 **     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 **     or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
 **     Public License for more details.
 **
 **     You should have received a copy of the GNU Lesser General Public
 **     License along with ProNoC. If not, see <http:**www.gnu.org/licenses/>.
 **
 **
 **    Description: 
 **    the NoC top module. It generate one of the mesh, torus, ring, or line  topologies by 
 **    connecting routers  
 **
 **************************************************************/





module asic_top  
		import pronoc_pkg::*; 
	#(parameter L=1)  // fake wire lentghth
		(
			clk,
			reset,
			chan_in_all,
			chan_out_all,
			east_flit_in, 
			west_flit_in,   //last and first router west and east ports
			east_flit_out, 
			west_flit_out  
		);
	localparam R_NUM=SBP_NUM+1;

	input   clk,reset;
	//local ports 
	input   router_chanel_t chan_in_all  [3*R_NUM-1 : 0];//all routers north, south & local
	output  router_chanel_t chan_out_all [3*R_NUM-1 : 0];
	input   flit_chanel_t east_flit_in, west_flit_in;   //last and first router west and east ports
	output  flit_chanel_t east_flit_out, west_flit_out;
	
	//all routers port 
	router_chanel_t    router_chan_in   [R_NUM-1 :0][MAX_P-1 : 0];
	router_chanel_t    router_chan_out  [R_NUM-1 :0][MAX_P-1 : 0];
	
	wire [RAw-1 : 0] current_r_addr [R_NUM-1 : 0];
	
	// mesh torus            
	localparam
		EAST   =       3'd1, 
		NORTH  =       3'd2,  
		WEST   =       3'd3,  
		SOUTH  =       3'd4,
		LOCAL  =       0;
	
	
	genvar i;
	
	generate
		for (i=0; i<R_NUM;  i=i+1) begin: R_
				
			assign ctrl_in[i].current_r_addr  = i;
			router_top 	 the_router (
					.current_r_addr  (current_r_addr[i]),
					.chan_in         (router_chan_in [i]), 
					.chan_out        (router_chan_out[i]), 
					.clk             (clk            ), 
					.reset           (reset          ));
			//connect router's East ports to West port of 		
			if(i<(R_NUM-1)) begin : E2W
				fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw ( 
						.out(router_chan_in[i][EAST]),
						.in(router_chan_out [i+1][WEST]));

			end else begin : last
				always @(posedge clk) begin 
					router_chan_in[i][EAST].sbp_chanel  <= {SBP_CHANEL_w{1'b0}};
					router_chan_in[i][EAST].flit_chanel <= east_flit_in;
					east_flit_out <= router_chan_out [i][EAST].flit_chanel;
				end

			end
			if(i>0) begin : W2E
				fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw ( 
						.out(router_chan_in[i][WEST]),
						.in (router_chan_out [i-1][EAST]));

			end else begin : first
				always @(posedge clk) begin 
					router_chan_in[i][WEST].sbp_chanel  <= {SBP_CHANEL_w{1'b0}};
					router_chan_in[i][WEST].flit_chanel <= west_flit_in;
					west_flit_out <= router_chan_out [i][WEST].flit_chanel;
				end

			end

		
			fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw1 ( 
					.out(chan_out_all[i*3]),
					.in(router_chan_out [i][NORTH]));

			fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw2 ( 
					.out(chan_out_all[i*3+1]),
					.in(router_chan_out [i][SOUTH]));

			fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw3 ( 
					.out(chan_out_all[i*3+2]),
					.in(router_chan_out [i][LOCAL]));

		
			fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw4 ( 
					.out(router_chan_in [i][NORTH]),
					.in(chan_in_all[i*3] ));

			fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw5 ( 
					.out(router_chan_in [i][SOUTH]),
					.in(chan_in_all[i*3+1] ));


			fake_chanel #(.L(L),.W(ROUTER_CHANEL_w)) fw6 ( 
					.out(router_chan_in [i][LOCAL]),
					.in(chan_in_all[i*3+2] ));

		end
	endgenerate				





endmodule



module  fake_wire #(
		parameter L = 2
		)(
		input  in, 
		output out 
		);

	genvar i;
    assign out = in;
	
	/*
	wire [L : 0] connection;


	generate 
		for (i=0;i<L;i=i+1) begin : lp 
			(* DONT_TOUCH = "true" *)  BUFX2 buf_cmb (.Y(connection[i+1]), .A(connection[i]));
			
		end
	endgenerate

	assign out = connection[L];
	assign connection[0]=in;
*/

endmodule


module fake_chanel #( 
		parameter W = 32, // width
		parameter L = 10 // wire lenght
		)(
		in, 
		out 
		);

	input  [W-1 : 0] in; 
	output [W-1 : 0] out; 

	genvar i;
	generate 
		for (i=0;i<W;i=i+1) begin : lp 
			fake_wire #(.L(L)) one_bite_wire (.in(in[i]),.out(out[i]));	
		end
	endgenerate
	
endmodule





