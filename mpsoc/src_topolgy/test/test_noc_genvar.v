
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/git/hca_git/ProNoC/mpsoc/src_topolgy/test/test_noc_genvar.v
**    
**	Copyright (C) 2014-2019  Alireza Monemi
**    
**	This file is part of ProNoC 1.9.1 
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
******************************************************************************/ 

module   test_noc_genvar #(  
    	parameter TOPOLOGY = "test",
	parameter ROUTE_NAME = "test_DETERMINISTIC",
	parameter V  = 2,
	parameter B  = 4,
	parameter C  = 2,
	parameter Fpay  = 32,
	parameter MUX_TYPE = "ONE_HOT",
	parameter VC_REALLOCATION_TYPE  = "NONATOMIC",
	parameter COMBINATION_TYPE = "COMB_NONSPEC",
	parameter FIRST_ARBITER_EXT_P_EN  = 1,
	parameter CONGESTION_INDEX  = 7,
	parameter DEBUG_EN = 0,
	parameter AVC_ATOMIC_EN = 0,
	parameter ADD_PIPREG_AFTER_CROSSBAR = 0,
	parameter CVw = (C==0)? V : C * V,
	parameter CLASS_SETTING  = {CVw{1'b1}},
	parameter SSA_EN = "NO",
	parameter SWA_ARBITER_TYPE  = "RRA",
	parameter WEIGHTw  = 7,
	parameter MIN_PCK_SIZE = 2,
	parameter BYTE_EN = 0
)(
    	reset,
	clk,
	flit_in_all,
	flit_out_all,
	flit_in_wr_all,
	flit_out_wr_all,
	credit_out_all,
	credit_in_all
);

	 function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end 	   
      end   
    endfunction // log2 

	localparam 
		NE = 16,
		NR = 16,
		RAw=log2(NR),
		MAX_P=5;
	
	localparam
		P= MAX_P,
        PV = V * P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = P * Fw,
        CONG_ALw = CONGw * P;
     
    	
		
       
      

    

	input reset;
	input clk;
	input [(NE*Fw)-1 : 0] flit_in_all;
	output [(NE*Fw)-1 : 0] flit_out_all;
	input [NE-1 : 0] flit_in_wr_all;
	output [NE-1 : 0] flit_out_wr_all;
	output [(NE*V)-1 : 0] credit_out_all;
	input [(NE*V)-1 : 0] credit_in_all;


	wire  [PFw-1 : 0] router_flit_in_all [NR-1 :0];
	wire  [PFw-1 : 0] router_flit_out_all [NR-1 :0];
	wire  [P-1 : 0] router_flit_in_wr_all [NR-1 :0];
	wire  [P-1 : 0] router_flit_out_wr_all [NR-1 :0];
	wire  [CONG_ALw-1 : 0] router_congestion_in_all [NR-1 :0];
	wire  [CONG_ALw-1 : 0] router_congestion_out_all [NR-1 :0];
	wire  [PV-1 : 0] router_credit_out_all [NR-1 :0];
	wire  [PV-1 : 0] router_credit_in_all [NR-1 :0];


	wire [Fw-1 : 0] ni_flit_in [NE-1 :0];
	wire [Fw-1 : 0] ni_flit_out [NE-1 :0];
	wire [NE-1 :0] ni_flit_in_wr;
	wire [NE-1 :0] ni_flit_out_wr;
	wire [V-1 : 0] ni_credit_out [NE-1 :0];
	wire [V-1 : 0] ni_credit_in [NE-1 :0];

   

	genvar i;
	generate	
	
	for( i=0; i<4; i=i+1) begin : router_3_port_lp
			
	
	router #(
		.P(3),
		.T1(16),
		.T2(16),
		.T3(5),
		.TOPOLOGY(TOPOLOGY),
		.ROUTE_NAME(ROUTE_NAME),
		.V (V ),
		.B (B ),
		.C (C ),
		.Fpay (Fpay ),
		.MUX_TYPE(MUX_TYPE),
		.VC_REALLOCATION_TYPE (VC_REALLOCATION_TYPE ),
		.COMBINATION_TYPE(COMBINATION_TYPE),
		.FIRST_ARBITER_EXT_P_EN (FIRST_ARBITER_EXT_P_EN ),
		.CONGESTION_INDEX (CONGESTION_INDEX ),
		.DEBUG_EN(DEBUG_EN),
		.AVC_ATOMIC_EN(AVC_ATOMIC_EN),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE),
		.BYTE_EN(BYTE_EN)	
	)
	router_3_port
	(	
		.clk(clk), 
		.reset(reset),
		.current_r_addr(i),
		.neighbors_r_addr({RAw{1'b0}}),
		.flit_in_all( router_flit_in_all [i][(3 * Fw)-1    :   0]),
		.flit_out_all( router_flit_out_all [i][(3 * Fw)-1    :   0]),
		.flit_in_wr_all( router_flit_in_wr_all [i][(3 * 1)-1    :   0]),
		.flit_out_wr_all( router_flit_out_wr_all [i][(3 * 1)-1    :   0]),
		.congestion_in_all( router_congestion_in_all [i][(3 * CONGw)-1    :   0]),
		.congestion_out_all( router_congestion_out_all [i][(3 * CONGw)-1    :   0]),
		.credit_out_all( router_credit_out_all [i][(3 * V)-1    :   0]),
		.credit_in_all( router_credit_in_all [i][(3 * V)-1    :   0])
	);

    
	end    
			
	for( i=0; i<8; i=i+1) begin : router_4_port_lp
			
	
	router #(
		.P(4),
		.T1(16),
		.T2(16),
		.T3(5),
		.TOPOLOGY(TOPOLOGY),
		.ROUTE_NAME(ROUTE_NAME),
		.V (V ),
		.B (B ),
		.C (C ),
		.Fpay (Fpay ),
		.MUX_TYPE(MUX_TYPE),
		.VC_REALLOCATION_TYPE (VC_REALLOCATION_TYPE ),
		.COMBINATION_TYPE(COMBINATION_TYPE),
		.FIRST_ARBITER_EXT_P_EN (FIRST_ARBITER_EXT_P_EN ),
		.CONGESTION_INDEX (CONGESTION_INDEX ),
		.DEBUG_EN(DEBUG_EN),
		.AVC_ATOMIC_EN(AVC_ATOMIC_EN),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE),
		.BYTE_EN(BYTE_EN)	
	)
	router_4_port
	(	
		.clk(clk), 
		.reset(reset),
		.current_r_addr(i+4),
		.neighbors_r_addr({RAw{1'b0}}),
		.flit_in_all( router_flit_in_all [i+4][(4 * Fw)-1    :   0]),
		.flit_out_all( router_flit_out_all [i+4][(4 * Fw)-1    :   0]),
		.flit_in_wr_all( router_flit_in_wr_all [i+4][(4 * 1)-1    :   0]),
		.flit_out_wr_all( router_flit_out_wr_all [i+4][(4 * 1)-1    :   0]),
		.congestion_in_all( router_congestion_in_all [i+4][(4 * CONGw)-1    :   0]),
		.congestion_out_all( router_congestion_out_all [i+4][(4 * CONGw)-1    :   0]),
		.credit_out_all( router_credit_out_all [i+4][(4 * V)-1    :   0]),
		.credit_in_all( router_credit_in_all [i+4][(4 * V)-1    :   0])
	);

    
	end    
			
	for( i=0; i<4; i=i+1) begin : router_5_port_lp
			
	
	router #(
		.P(5),
		.T1(16),
		.T2(16),
		.T3(5),
		.TOPOLOGY(TOPOLOGY),
		.ROUTE_NAME(ROUTE_NAME),
		.V (V ),
		.B (B ),
		.C (C ),
		.Fpay (Fpay ),
		.MUX_TYPE(MUX_TYPE),
		.VC_REALLOCATION_TYPE (VC_REALLOCATION_TYPE ),
		.COMBINATION_TYPE(COMBINATION_TYPE),
		.FIRST_ARBITER_EXT_P_EN (FIRST_ARBITER_EXT_P_EN ),
		.CONGESTION_INDEX (CONGESTION_INDEX ),
		.DEBUG_EN(DEBUG_EN),
		.AVC_ATOMIC_EN(AVC_ATOMIC_EN),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE),
		.BYTE_EN(BYTE_EN)	
	)
	router_5_port
	(	
		.clk(clk), 
		.reset(reset),
		.current_r_addr(i+12),
		.neighbors_r_addr({RAw{1'b0}}),
		.flit_in_all( router_flit_in_all [i+12][(5 * Fw)-1    :   0]),
		.flit_out_all( router_flit_out_all [i+12][(5 * Fw)-1    :   0]),
		.flit_in_wr_all( router_flit_in_wr_all [i+12][(5 * 1)-1    :   0]),
		.flit_out_wr_all( router_flit_out_wr_all [i+12][(5 * 1)-1    :   0]),
		.congestion_in_all( router_congestion_in_all [i+12][(5 * CONGw)-1    :   0]),
		.congestion_out_all( router_congestion_out_all [i+12][(5 * CONGw)-1    :   0]),
		.credit_out_all( router_credit_out_all [i+12][(5 * V)-1    :   0]),
		.credit_in_all( router_credit_in_all [i+12][(5 * V)-1    :   0])
	);

    
	end    
			
	endgenerate


//Connect R0 input ports 0 to  T0 output ports 0
		assign  router_flit_in_all [0][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [0];
		assign  router_flit_in_wr_all [0][0] = ni_flit_out_wr [0];
		assign  router_congestion_in_all [0][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [0] = router_credit_out_all [0][(1*V)-1 :	 0*V ];
//Connect R0 input ports 1 to  R9 output ports 2
		assign  router_flit_in_all [0][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [9][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [0][1] = router_flit_out_wr_all [9][2];
		assign  router_congestion_in_all [0][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [9][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [9][(3*V)-1 :	 2*V ] = router_credit_out_all [0][(2*V)-1 :	 1*V ];
//Connect R0 input ports 2 to  R11 output ports 3
		assign  router_flit_in_all [0][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [11][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [0][2] = router_flit_out_wr_all [11][3];
		assign  router_congestion_in_all [0][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [11][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [11][(4*V)-1 :	 3*V ] = router_credit_out_all [0][(3*V)-1 :	 2*V ];
//Connect R1 input ports 0 to  T1 output ports 0
		assign  router_flit_in_all [1][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [1];
		assign  router_flit_in_wr_all [1][0] = ni_flit_out_wr [1];
		assign  router_congestion_in_all [1][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [1] = router_credit_out_all [1][(1*V)-1 :	 0*V ];
//Connect R1 input ports 1 to  R14 output ports 4
		assign  router_flit_in_all [1][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [14][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_in_wr_all [1][1] = router_flit_out_wr_all [14][4];
		assign  router_congestion_in_all [1][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [14][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_in_all [14][(5*V)-1 :	 4*V ] = router_credit_out_all [1][(2*V)-1 :	 1*V ];
//Connect R1 input ports 2 to  R9 output ports 3
		assign  router_flit_in_all [1][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [9][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [1][2] = router_flit_out_wr_all [9][3];
		assign  router_congestion_in_all [1][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [9][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [9][(4*V)-1 :	 3*V ] = router_credit_out_all [1][(3*V)-1 :	 2*V ];
//Connect R2 input ports 0 to  T2 output ports 0
		assign  router_flit_in_all [2][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [2];
		assign  router_flit_in_wr_all [2][0] = ni_flit_out_wr [2];
		assign  router_congestion_in_all [2][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [2] = router_credit_out_all [2][(1*V)-1 :	 0*V ];
//Connect R2 input ports 1 to  R10 output ports 3
		assign  router_flit_in_all [2][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [10][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [2][1] = router_flit_out_wr_all [10][3];
		assign  router_congestion_in_all [2][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [10][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [10][(4*V)-1 :	 3*V ] = router_credit_out_all [2][(2*V)-1 :	 1*V ];
//Connect R2 input ports 2 to  R3 output ports 2
		assign  router_flit_in_all [2][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [3][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [2][2] = router_flit_out_wr_all [3][2];
		assign  router_congestion_in_all [2][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [3][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [3][(3*V)-1 :	 2*V ] = router_credit_out_all [2][(3*V)-1 :	 2*V ];
//Connect R3 input ports 0 to  T3 output ports 0
		assign  router_flit_in_all [3][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [3];
		assign  router_flit_in_wr_all [3][0] = ni_flit_out_wr [3];
		assign  router_congestion_in_all [3][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [3] = router_credit_out_all [3][(1*V)-1 :	 0*V ];
//Connect R3 input ports 1 to  R10 output ports 1
		assign  router_flit_in_all [3][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [10][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [3][1] = router_flit_out_wr_all [10][1];
		assign  router_congestion_in_all [3][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [10][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [10][(2*V)-1 :	 1*V ] = router_credit_out_all [3][(2*V)-1 :	 1*V ];
//Connect R3 input ports 2 to  R2 output ports 2
		assign  router_flit_in_all [3][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [2][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [3][2] = router_flit_out_wr_all [2][2];
		assign  router_congestion_in_all [3][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [2][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [2][(3*V)-1 :	 2*V ] = router_credit_out_all [3][(3*V)-1 :	 2*V ];
//Connect R4 input ports 0 to  T4 output ports 0
		assign  router_flit_in_all [4][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [4];
		assign  router_flit_in_wr_all [4][0] = ni_flit_out_wr [4];
		assign  router_congestion_in_all [4][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [4] = router_credit_out_all [4][(1*V)-1 :	 0*V ];
//Connect R4 input ports 1 to  R10 output ports 2
		assign  router_flit_in_all [4][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [10][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [4][1] = router_flit_out_wr_all [10][2];
		assign  router_congestion_in_all [4][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [10][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [10][(3*V)-1 :	 2*V ] = router_credit_out_all [4][(2*V)-1 :	 1*V ];
//Connect R4 input ports 2 to  R11 output ports 2
		assign  router_flit_in_all [4][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [11][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [4][2] = router_flit_out_wr_all [11][2];
		assign  router_congestion_in_all [4][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [11][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [11][(3*V)-1 :	 2*V ] = router_credit_out_all [4][(3*V)-1 :	 2*V ];
//Connect R4 input ports 3 to  R8 output ports 3
		assign  router_flit_in_all [4][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [8][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [4][3] = router_flit_out_wr_all [8][3];
		assign  router_congestion_in_all [4][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [8][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [8][(4*V)-1 :	 3*V ] = router_credit_out_all [4][(4*V)-1 :	 3*V ];
//Connect R5 input ports 0 to  T5 output ports 0
		assign  router_flit_in_all [5][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [5];
		assign  router_flit_in_wr_all [5][0] = ni_flit_out_wr [5];
		assign  router_congestion_in_all [5][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [5] = router_credit_out_all [5][(1*V)-1 :	 0*V ];
//Connect R5 input ports 1 to  R12 output ports 2
		assign  router_flit_in_all [5][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [12][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [5][1] = router_flit_out_wr_all [12][2];
		assign  router_congestion_in_all [5][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [12][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [12][(3*V)-1 :	 2*V ] = router_credit_out_all [5][(2*V)-1 :	 1*V ];
//Connect R5 input ports 2 to  R7 output ports 2
		assign  router_flit_in_all [5][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [7][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [5][2] = router_flit_out_wr_all [7][2];
		assign  router_congestion_in_all [5][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [7][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [7][(3*V)-1 :	 2*V ] = router_credit_out_all [5][(3*V)-1 :	 2*V ];
//Connect R5 input ports 3 to  R6 output ports 3
		assign  router_flit_in_all [5][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [6][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [5][3] = router_flit_out_wr_all [6][3];
		assign  router_congestion_in_all [5][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [6][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [6][(4*V)-1 :	 3*V ] = router_credit_out_all [5][(4*V)-1 :	 3*V ];
//Connect R6 input ports 0 to  T6 output ports 0
		assign  router_flit_in_all [6][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [6];
		assign  router_flit_in_wr_all [6][0] = ni_flit_out_wr [6];
		assign  router_congestion_in_all [6][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [6] = router_credit_out_all [6][(1*V)-1 :	 0*V ];
//Connect R6 input ports 1 to  R12 output ports 3
		assign  router_flit_in_all [6][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [12][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [6][1] = router_flit_out_wr_all [12][3];
		assign  router_congestion_in_all [6][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [12][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [12][(4*V)-1 :	 3*V ] = router_credit_out_all [6][(2*V)-1 :	 1*V ];
//Connect R6 input ports 2 to  R14 output ports 2
		assign  router_flit_in_all [6][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [14][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [6][2] = router_flit_out_wr_all [14][2];
		assign  router_congestion_in_all [6][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [14][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [14][(3*V)-1 :	 2*V ] = router_credit_out_all [6][(3*V)-1 :	 2*V ];
//Connect R6 input ports 3 to  R5 output ports 3
		assign  router_flit_in_all [6][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [5][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [6][3] = router_flit_out_wr_all [5][3];
		assign  router_congestion_in_all [6][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [5][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [5][(4*V)-1 :	 3*V ] = router_credit_out_all [6][(4*V)-1 :	 3*V ];
//Connect R7 input ports 0 to  T7 output ports 0
		assign  router_flit_in_all [7][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [7];
		assign  router_flit_in_wr_all [7][0] = ni_flit_out_wr [7];
		assign  router_congestion_in_all [7][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [7] = router_credit_out_all [7][(1*V)-1 :	 0*V ];
//Connect R7 input ports 1 to  R13 output ports 4
		assign  router_flit_in_all [7][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [13][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_in_wr_all [7][1] = router_flit_out_wr_all [13][4];
		assign  router_congestion_in_all [7][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [13][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_in_all [13][(5*V)-1 :	 4*V ] = router_credit_out_all [7][(2*V)-1 :	 1*V ];
//Connect R7 input ports 2 to  R5 output ports 2
		assign  router_flit_in_all [7][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [5][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [7][2] = router_flit_out_wr_all [5][2];
		assign  router_congestion_in_all [7][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [5][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [5][(3*V)-1 :	 2*V ] = router_credit_out_all [7][(3*V)-1 :	 2*V ];
//Connect R7 input ports 3 to  R11 output ports 1
		assign  router_flit_in_all [7][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [11][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [7][3] = router_flit_out_wr_all [11][1];
		assign  router_congestion_in_all [7][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [11][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [11][(2*V)-1 :	 1*V ] = router_credit_out_all [7][(4*V)-1 :	 3*V ];
//Connect R8 input ports 0 to  T8 output ports 0
		assign  router_flit_in_all [8][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [8];
		assign  router_flit_in_wr_all [8][0] = ni_flit_out_wr [8];
		assign  router_congestion_in_all [8][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [8] = router_credit_out_all [8][(1*V)-1 :	 0*V ];
//Connect R8 input ports 1 to  R14 output ports 3
		assign  router_flit_in_all [8][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [14][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [8][1] = router_flit_out_wr_all [14][3];
		assign  router_congestion_in_all [8][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [14][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [14][(4*V)-1 :	 3*V ] = router_credit_out_all [8][(2*V)-1 :	 1*V ];
//Connect R8 input ports 2 to  R15 output ports 4
		assign  router_flit_in_all [8][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [15][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_in_wr_all [8][2] = router_flit_out_wr_all [15][4];
		assign  router_congestion_in_all [8][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [15][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_in_all [15][(5*V)-1 :	 4*V ] = router_credit_out_all [8][(3*V)-1 :	 2*V ];
//Connect R8 input ports 3 to  R4 output ports 3
		assign  router_flit_in_all [8][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [4][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [8][3] = router_flit_out_wr_all [4][3];
		assign  router_congestion_in_all [8][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [4][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [4][(4*V)-1 :	 3*V ] = router_credit_out_all [8][(4*V)-1 :	 3*V ];
//Connect R9 input ports 0 to  T9 output ports 0
		assign  router_flit_in_all [9][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [9];
		assign  router_flit_in_wr_all [9][0] = ni_flit_out_wr [9];
		assign  router_congestion_in_all [9][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [9] = router_credit_out_all [9][(1*V)-1 :	 0*V ];
//Connect R9 input ports 1 to  R15 output ports 3
		assign  router_flit_in_all [9][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [15][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [9][1] = router_flit_out_wr_all [15][3];
		assign  router_congestion_in_all [9][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [15][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [15][(4*V)-1 :	 3*V ] = router_credit_out_all [9][(2*V)-1 :	 1*V ];
//Connect R9 input ports 2 to  R0 output ports 1
		assign  router_flit_in_all [9][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [0][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [9][2] = router_flit_out_wr_all [0][1];
		assign  router_congestion_in_all [9][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [0][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [0][(2*V)-1 :	 1*V ] = router_credit_out_all [9][(3*V)-1 :	 2*V ];
//Connect R9 input ports 3 to  R1 output ports 2
		assign  router_flit_in_all [9][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [1][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [9][3] = router_flit_out_wr_all [1][2];
		assign  router_congestion_in_all [9][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [1][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [1][(3*V)-1 :	 2*V ] = router_credit_out_all [9][(4*V)-1 :	 3*V ];
//Connect R10 input ports 0 to  T10 output ports 0
		assign  router_flit_in_all [10][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [10];
		assign  router_flit_in_wr_all [10][0] = ni_flit_out_wr [10];
		assign  router_congestion_in_all [10][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [10] = router_credit_out_all [10][(1*V)-1 :	 0*V ];
//Connect R10 input ports 1 to  R3 output ports 1
		assign  router_flit_in_all [10][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [3][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [10][1] = router_flit_out_wr_all [3][1];
		assign  router_congestion_in_all [10][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [3][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [3][(2*V)-1 :	 1*V ] = router_credit_out_all [10][(2*V)-1 :	 1*V ];
//Connect R10 input ports 2 to  R4 output ports 1
		assign  router_flit_in_all [10][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [4][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [10][2] = router_flit_out_wr_all [4][1];
		assign  router_congestion_in_all [10][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [4][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [4][(2*V)-1 :	 1*V ] = router_credit_out_all [10][(3*V)-1 :	 2*V ];
//Connect R10 input ports 3 to  R2 output ports 1
		assign  router_flit_in_all [10][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [2][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [10][3] = router_flit_out_wr_all [2][1];
		assign  router_congestion_in_all [10][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [2][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [2][(2*V)-1 :	 1*V ] = router_credit_out_all [10][(4*V)-1 :	 3*V ];
//Connect R11 input ports 0 to  T11 output ports 0
		assign  router_flit_in_all [11][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [11];
		assign  router_flit_in_wr_all [11][0] = ni_flit_out_wr [11];
		assign  router_congestion_in_all [11][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [11] = router_credit_out_all [11][(1*V)-1 :	 0*V ];
//Connect R11 input ports 1 to  R7 output ports 3
		assign  router_flit_in_all [11][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [7][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [11][1] = router_flit_out_wr_all [7][3];
		assign  router_congestion_in_all [11][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [7][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [7][(4*V)-1 :	 3*V ] = router_credit_out_all [11][(2*V)-1 :	 1*V ];
//Connect R11 input ports 2 to  R4 output ports 2
		assign  router_flit_in_all [11][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [4][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [11][2] = router_flit_out_wr_all [4][2];
		assign  router_congestion_in_all [11][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [4][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [4][(3*V)-1 :	 2*V ] = router_credit_out_all [11][(3*V)-1 :	 2*V ];
//Connect R11 input ports 3 to  R0 output ports 2
		assign  router_flit_in_all [11][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [0][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [11][3] = router_flit_out_wr_all [0][2];
		assign  router_congestion_in_all [11][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [0][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [0][(3*V)-1 :	 2*V ] = router_credit_out_all [11][(4*V)-1 :	 3*V ];
//Connect R12 input ports 0 to  T12 output ports 0
		assign  router_flit_in_all [12][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [12];
		assign  router_flit_in_wr_all [12][0] = ni_flit_out_wr [12];
		assign  router_congestion_in_all [12][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [12] = router_credit_out_all [12][(1*V)-1 :	 0*V ];
//Connect R12 input ports 1 to  R13 output ports 1
		assign  router_flit_in_all [12][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [13][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [12][1] = router_flit_out_wr_all [13][1];
		assign  router_congestion_in_all [12][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [13][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [13][(2*V)-1 :	 1*V ] = router_credit_out_all [12][(2*V)-1 :	 1*V ];
//Connect R12 input ports 2 to  R5 output ports 1
		assign  router_flit_in_all [12][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [5][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [12][2] = router_flit_out_wr_all [5][1];
		assign  router_congestion_in_all [12][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [5][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [5][(2*V)-1 :	 1*V ] = router_credit_out_all [12][(3*V)-1 :	 2*V ];
//Connect R12 input ports 3 to  R6 output ports 1
		assign  router_flit_in_all [12][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [6][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [12][3] = router_flit_out_wr_all [6][1];
		assign  router_congestion_in_all [12][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [6][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [6][(2*V)-1 :	 1*V ] = router_credit_out_all [12][(4*V)-1 :	 3*V ];
//Connect R12 input ports 4 to  R15 output ports 2
		assign  router_flit_in_all [12][(5*Fw)-1 :	 4*Fw ] = router_flit_out_all [15][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [12][4] = router_flit_out_wr_all [15][2];
		assign  router_congestion_in_all [12][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_out_all [15][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [15][(3*V)-1 :	 2*V ] = router_credit_out_all [12][(5*V)-1 :	 4*V ];
//Connect R13 input ports 0 to  T13 output ports 0
		assign  router_flit_in_all [13][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [13];
		assign  router_flit_in_wr_all [13][0] = ni_flit_out_wr [13];
		assign  router_congestion_in_all [13][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [13] = router_credit_out_all [13][(1*V)-1 :	 0*V ];
//Connect R13 input ports 1 to  R12 output ports 1
		assign  router_flit_in_all [13][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [12][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [13][1] = router_flit_out_wr_all [12][1];
		assign  router_congestion_in_all [13][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [12][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [12][(2*V)-1 :	 1*V ] = router_credit_out_all [13][(2*V)-1 :	 1*V ];
//Connect R13 input ports 2 to  R14 output ports 1
		assign  router_flit_in_all [13][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [14][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [13][2] = router_flit_out_wr_all [14][1];
		assign  router_congestion_in_all [13][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [14][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [14][(2*V)-1 :	 1*V ] = router_credit_out_all [13][(3*V)-1 :	 2*V ];
//Connect R13 input ports 3 to  R15 output ports 1
		assign  router_flit_in_all [13][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [15][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [13][3] = router_flit_out_wr_all [15][1];
		assign  router_congestion_in_all [13][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [15][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [15][(2*V)-1 :	 1*V ] = router_credit_out_all [13][(4*V)-1 :	 3*V ];
//Connect R13 input ports 4 to  R7 output ports 1
		assign  router_flit_in_all [13][(5*Fw)-1 :	 4*Fw ] = router_flit_out_all [7][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [13][4] = router_flit_out_wr_all [7][1];
		assign  router_congestion_in_all [13][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_out_all [7][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [7][(2*V)-1 :	 1*V ] = router_credit_out_all [13][(5*V)-1 :	 4*V ];
//Connect R14 input ports 0 to  T14 output ports 0
		assign  router_flit_in_all [14][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [14];
		assign  router_flit_in_wr_all [14][0] = ni_flit_out_wr [14];
		assign  router_congestion_in_all [14][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [14] = router_credit_out_all [14][(1*V)-1 :	 0*V ];
//Connect R14 input ports 1 to  R13 output ports 2
		assign  router_flit_in_all [14][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [13][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [14][1] = router_flit_out_wr_all [13][2];
		assign  router_congestion_in_all [14][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [13][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [13][(3*V)-1 :	 2*V ] = router_credit_out_all [14][(2*V)-1 :	 1*V ];
//Connect R14 input ports 2 to  R6 output ports 2
		assign  router_flit_in_all [14][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [6][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [14][2] = router_flit_out_wr_all [6][2];
		assign  router_congestion_in_all [14][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [6][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [6][(3*V)-1 :	 2*V ] = router_credit_out_all [14][(3*V)-1 :	 2*V ];
//Connect R14 input ports 3 to  R8 output ports 1
		assign  router_flit_in_all [14][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [8][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [14][3] = router_flit_out_wr_all [8][1];
		assign  router_congestion_in_all [14][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [8][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [8][(2*V)-1 :	 1*V ] = router_credit_out_all [14][(4*V)-1 :	 3*V ];
//Connect R14 input ports 4 to  R1 output ports 1
		assign  router_flit_in_all [14][(5*Fw)-1 :	 4*Fw ] = router_flit_out_all [1][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [14][4] = router_flit_out_wr_all [1][1];
		assign  router_congestion_in_all [14][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_out_all [1][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [1][(2*V)-1 :	 1*V ] = router_credit_out_all [14][(5*V)-1 :	 4*V ];
//Connect R15 input ports 0 to  T15 output ports 0
		assign  router_flit_in_all [15][(1*Fw)-1 :	 0*Fw ] = ni_flit_out [15];
		assign  router_flit_in_wr_all [15][0] = ni_flit_out_wr [15];
		assign  router_congestion_in_all [15][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  ni_credit_in [15] = router_credit_out_all [15][(1*V)-1 :	 0*V ];
//Connect R15 input ports 1 to  R13 output ports 3
		assign  router_flit_in_all [15][(2*Fw)-1 :	 1*Fw ] = router_flit_out_all [13][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_in_wr_all [15][1] = router_flit_out_wr_all [13][3];
		assign  router_congestion_in_all [15][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_out_all [13][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_in_all [13][(4*V)-1 :	 3*V ] = router_credit_out_all [15][(2*V)-1 :	 1*V ];
//Connect R15 input ports 2 to  R12 output ports 4
		assign  router_flit_in_all [15][(3*Fw)-1 :	 2*Fw ] = router_flit_out_all [12][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_in_wr_all [15][2] = router_flit_out_wr_all [12][4];
		assign  router_congestion_in_all [15][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_out_all [12][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_in_all [12][(5*V)-1 :	 4*V ] = router_credit_out_all [15][(3*V)-1 :	 2*V ];
//Connect R15 input ports 3 to  R9 output ports 1
		assign  router_flit_in_all [15][(4*Fw)-1 :	 3*Fw ] = router_flit_out_all [9][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_in_wr_all [15][3] = router_flit_out_wr_all [9][1];
		assign  router_congestion_in_all [15][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_out_all [9][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_in_all [9][(2*V)-1 :	 1*V ] = router_credit_out_all [15][(4*V)-1 :	 3*V ];
//Connect R15 input ports 4 to  R8 output ports 2
		assign  router_flit_in_all [15][(5*Fw)-1 :	 4*Fw ] = router_flit_out_all [8][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_in_wr_all [15][4] = router_flit_out_wr_all [8][2];
		assign  router_congestion_in_all [15][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_out_all [8][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_in_all [8][(3*V)-1 :	 2*V ] = router_credit_out_all [15][(5*V)-1 :	 4*V ];
//Connect T0 input ports 0 to  R0 output ports 0
		assign  ni_flit_in [0] = router_flit_out_all [0][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [0] = router_flit_out_wr_all [0][0];
		assign  router_congestion_out_all [0][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [0][(1*V)-1 :	 0*V ] = ni_credit_out [0];
//Connect T1 input ports 0 to  R1 output ports 0
		assign  ni_flit_in [1] = router_flit_out_all [1][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [1] = router_flit_out_wr_all [1][0];
		assign  router_congestion_out_all [1][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [1][(1*V)-1 :	 0*V ] = ni_credit_out [1];
//Connect T2 input ports 0 to  R2 output ports 0
		assign  ni_flit_in [2] = router_flit_out_all [2][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [2] = router_flit_out_wr_all [2][0];
		assign  router_congestion_out_all [2][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [2][(1*V)-1 :	 0*V ] = ni_credit_out [2];
//Connect T3 input ports 0 to  R3 output ports 0
		assign  ni_flit_in [3] = router_flit_out_all [3][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [3] = router_flit_out_wr_all [3][0];
		assign  router_congestion_out_all [3][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [3][(1*V)-1 :	 0*V ] = ni_credit_out [3];
//Connect T4 input ports 0 to  R4 output ports 0
		assign  ni_flit_in [4] = router_flit_out_all [4][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [4] = router_flit_out_wr_all [4][0];
		assign  router_congestion_out_all [4][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [4][(1*V)-1 :	 0*V ] = ni_credit_out [4];
//Connect T5 input ports 0 to  R5 output ports 0
		assign  ni_flit_in [5] = router_flit_out_all [5][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [5] = router_flit_out_wr_all [5][0];
		assign  router_congestion_out_all [5][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [5][(1*V)-1 :	 0*V ] = ni_credit_out [5];
//Connect T6 input ports 0 to  R6 output ports 0
		assign  ni_flit_in [6] = router_flit_out_all [6][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [6] = router_flit_out_wr_all [6][0];
		assign  router_congestion_out_all [6][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [6][(1*V)-1 :	 0*V ] = ni_credit_out [6];
//Connect T7 input ports 0 to  R7 output ports 0
		assign  ni_flit_in [7] = router_flit_out_all [7][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [7] = router_flit_out_wr_all [7][0];
		assign  router_congestion_out_all [7][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [7][(1*V)-1 :	 0*V ] = ni_credit_out [7];
//Connect T8 input ports 0 to  R8 output ports 0
		assign  ni_flit_in [8] = router_flit_out_all [8][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [8] = router_flit_out_wr_all [8][0];
		assign  router_congestion_out_all [8][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [8][(1*V)-1 :	 0*V ] = ni_credit_out [8];
//Connect T9 input ports 0 to  R9 output ports 0
		assign  ni_flit_in [9] = router_flit_out_all [9][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [9] = router_flit_out_wr_all [9][0];
		assign  router_congestion_out_all [9][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [9][(1*V)-1 :	 0*V ] = ni_credit_out [9];
//Connect T10 input ports 0 to  R10 output ports 0
		assign  ni_flit_in [10] = router_flit_out_all [10][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [10] = router_flit_out_wr_all [10][0];
		assign  router_congestion_out_all [10][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [10][(1*V)-1 :	 0*V ] = ni_credit_out [10];
//Connect T11 input ports 0 to  R11 output ports 0
		assign  ni_flit_in [11] = router_flit_out_all [11][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [11] = router_flit_out_wr_all [11][0];
		assign  router_congestion_out_all [11][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [11][(1*V)-1 :	 0*V ] = ni_credit_out [11];
//Connect T12 input ports 0 to  R12 output ports 0
		assign  ni_flit_in [12] = router_flit_out_all [12][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [12] = router_flit_out_wr_all [12][0];
		assign  router_congestion_out_all [12][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [12][(1*V)-1 :	 0*V ] = ni_credit_out [12];
//Connect T13 input ports 0 to  R13 output ports 0
		assign  ni_flit_in [13] = router_flit_out_all [13][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [13] = router_flit_out_wr_all [13][0];
		assign  router_congestion_out_all [13][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [13][(1*V)-1 :	 0*V ] = ni_credit_out [13];
//Connect T14 input ports 0 to  R14 output ports 0
		assign  ni_flit_in [14] = router_flit_out_all [14][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [14] = router_flit_out_wr_all [14][0];
		assign  router_congestion_out_all [14][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [14][(1*V)-1 :	 0*V ] = ni_credit_out [14];
//Connect T15 input ports 0 to  R15 output ports 0
		assign  ni_flit_in [15] = router_flit_out_all [15][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_in_wr [15] = router_flit_out_wr_all [15][0];
		assign  router_congestion_out_all [15][(1*CONGw)-1 :	 0*CONGw ] = 0;
		assign  router_credit_in_all [15][(1*V)-1 :	 0*V ] = ni_credit_out [15];
genvar pos;
generate
	for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints
		assign ni_flit_out[pos] = flit_in_all [(pos+1)*Fw-1 : pos*Fw];
		assign  flit_out_all [(pos+1)*Fw-1 : pos*Fw] = ni_flit_in[pos] ;
		assign ni_flit_out_wr[pos] = flit_in_wr_all [pos];
		assign  flit_out_wr_all [pos] = ni_flit_in_wr[pos] ;
		assign credit_out_all [(pos+1)*V-1 : pos*V] = ni_credit_in[pos];
		assign ni_credit_out[pos]=credit_in_all [(pos+1)*V-1 : pos*V];
	end
 endgenerate
   




  
             
endmodule
