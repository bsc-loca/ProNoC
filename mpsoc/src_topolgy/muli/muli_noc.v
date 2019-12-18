
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/muli/muli_noc.v
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

module   muli_noc #(  
    	parameter TOPOLOGY = "muli",
	parameter ROUTE_NAME = "muli_DETERMINSTIC",
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
	parameter CONGw  = 3,
	parameter ADD_PIPREG_AFTER_CROSSBAR = 0,
	parameter CVw = (C==0)? V : C * V,
	parameter CLASS_SETTING  = {CVw{1'b1}},
	parameter SSA_EN = "NO",
	parameter SWA_ARBITER_TYPE  = "RRA",
	parameter WEIGHTw  = 7,
	parameter MIN_PCK_SIZE = 2
)(
    	reset,
	clk,
	//T0,
	T0_flit_in,
	T0_flit_out,
	T0_flit_in_wr,
	T0_flit_out_wr,
	T0_credit_out,
	T0_credit_in,
	//T1,
	T1_flit_in,
	T1_flit_out,
	T1_flit_in_wr,
	T1_flit_out_wr,
	T1_credit_out,
	T1_credit_in,
	//T2,
	T2_flit_in,
	T2_flit_out,
	T2_flit_in_wr,
	T2_flit_out_wr,
	T2_credit_out,
	T2_credit_in,
	//T3,
	T3_flit_in,
	T3_flit_out,
	T3_flit_in_wr,
	T3_flit_out_wr,
	T3_credit_out,
	T3_credit_in,
	//T4,
	T4_flit_in,
	T4_flit_out,
	T4_flit_in_wr,
	T4_flit_out_wr,
	T4_credit_out,
	T4_credit_in,
	//T5,
	T5_flit_in,
	T5_flit_out,
	T5_flit_in_wr,
	T5_flit_out_wr,
	T5_credit_out,
	T5_credit_in
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
		NE = 6,
		NR = 6,
		RAw=log2(NR),
        Fw = 2+V+Fpay; //flit width;    
       
      

    
    input reset,clk;    
       
    
	/*******************
	*		T0
	*******************/
	input  [Fw-1 : 0] T0_flit_in;
	output  [Fw-1 : 0] T0_flit_out;
	input   T0_flit_in_wr;
	output   T0_flit_out_wr;
	output  [V-1 : 0] T0_credit_out;
	input  [V-1 : 0] T0_credit_in;

	/*******************
	*		T1
	*******************/
	input  [Fw-1 : 0] T1_flit_in;
	output  [Fw-1 : 0] T1_flit_out;
	input   T1_flit_in_wr;
	output   T1_flit_out_wr;
	output  [V-1 : 0] T1_credit_out;
	input  [V-1 : 0] T1_credit_in;

	/*******************
	*		T2
	*******************/
	input  [Fw-1 : 0] T2_flit_in;
	output  [Fw-1 : 0] T2_flit_out;
	input   T2_flit_in_wr;
	output   T2_flit_out_wr;
	output  [V-1 : 0] T2_credit_out;
	input  [V-1 : 0] T2_credit_in;

	/*******************
	*		T3
	*******************/
	input  [Fw-1 : 0] T3_flit_in;
	output  [Fw-1 : 0] T3_flit_out;
	input   T3_flit_in_wr;
	output   T3_flit_out_wr;
	output  [V-1 : 0] T3_credit_out;
	input  [V-1 : 0] T3_credit_in;

	/*******************
	*		T4
	*******************/
	input  [Fw-1 : 0] T4_flit_in;
	output  [Fw-1 : 0] T4_flit_out;
	input   T4_flit_in_wr;
	output   T4_flit_out_wr;
	output  [V-1 : 0] T4_credit_out;
	input  [V-1 : 0] T4_credit_in;

	/*******************
	*		T5
	*******************/
	input  [Fw-1 : 0] T5_flit_in;
	output  [Fw-1 : 0] T5_flit_out;
	input   T5_flit_in_wr;
	output   T5_flit_out_wr;
	output  [V-1 : 0] T5_credit_out;
	input  [V-1 : 0] T5_credit_in;

	/*******************
	*		R0
	*******************/
	wire R0_clk;
	wire R0_reset;
	wire [RAw-1 :  0] R0_current_r_addr;
	wire [(2*RAw)-1:  0] R0_neighbors_r_addr;
	wire [(2*Fw)-1 : 0] R0_flit_in_all;
	wire [(2*Fw)-1 : 0] R0_flit_out_all;
	wire [(2*1)-1 : 0] R0_flit_in_wr_all;
	wire [(2*1)-1 : 0] R0_flit_out_wr_all;
	wire [(2*CONGw)-1 : 0] R0_congestion_in_all;
	wire [(2*CONGw)-1 : 0] R0_congestion_out_all;
	wire [(2*V)-1 : 0] R0_credit_out_all;
	wire [(2*V)-1 : 0] R0_credit_in_all;

	/*******************
	*		R1
	*******************/
	wire R1_clk;
	wire R1_reset;
	wire [RAw-1 :  0] R1_current_r_addr;
	wire [(2*RAw)-1:  0] R1_neighbors_r_addr;
	wire [(2*Fw)-1 : 0] R1_flit_in_all;
	wire [(2*Fw)-1 : 0] R1_flit_out_all;
	wire [(2*1)-1 : 0] R1_flit_in_wr_all;
	wire [(2*1)-1 : 0] R1_flit_out_wr_all;
	wire [(2*CONGw)-1 : 0] R1_congestion_in_all;
	wire [(2*CONGw)-1 : 0] R1_congestion_out_all;
	wire [(2*V)-1 : 0] R1_credit_out_all;
	wire [(2*V)-1 : 0] R1_credit_in_all;

	/*******************
	*		R2
	*******************/
	wire R2_clk;
	wire R2_reset;
	wire [RAw-1 :  0] R2_current_r_addr;
	wire [(2*RAw)-1:  0] R2_neighbors_r_addr;
	wire [(2*Fw)-1 : 0] R2_flit_in_all;
	wire [(2*Fw)-1 : 0] R2_flit_out_all;
	wire [(2*1)-1 : 0] R2_flit_in_wr_all;
	wire [(2*1)-1 : 0] R2_flit_out_wr_all;
	wire [(2*CONGw)-1 : 0] R2_congestion_in_all;
	wire [(2*CONGw)-1 : 0] R2_congestion_out_all;
	wire [(2*V)-1 : 0] R2_credit_out_all;
	wire [(2*V)-1 : 0] R2_credit_in_all;

	/*******************
	*		R3
	*******************/
	wire R3_clk;
	wire R3_reset;
	wire [RAw-1 :  0] R3_current_r_addr;
	wire [(3*RAw)-1:  0] R3_neighbors_r_addr;
	wire [(3*Fw)-1 : 0] R3_flit_in_all;
	wire [(3*Fw)-1 : 0] R3_flit_out_all;
	wire [(3*1)-1 : 0] R3_flit_in_wr_all;
	wire [(3*1)-1 : 0] R3_flit_out_wr_all;
	wire [(3*CONGw)-1 : 0] R3_congestion_in_all;
	wire [(3*CONGw)-1 : 0] R3_congestion_out_all;
	wire [(3*V)-1 : 0] R3_credit_out_all;
	wire [(3*V)-1 : 0] R3_credit_in_all;

	/*******************
	*		R4
	*******************/
	wire R4_clk;
	wire R4_reset;
	wire [RAw-1 :  0] R4_current_r_addr;
	wire [(3*RAw)-1:  0] R4_neighbors_r_addr;
	wire [(3*Fw)-1 : 0] R4_flit_in_all;
	wire [(3*Fw)-1 : 0] R4_flit_out_all;
	wire [(3*1)-1 : 0] R4_flit_in_wr_all;
	wire [(3*1)-1 : 0] R4_flit_out_wr_all;
	wire [(3*CONGw)-1 : 0] R4_congestion_in_all;
	wire [(3*CONGw)-1 : 0] R4_congestion_out_all;
	wire [(3*V)-1 : 0] R4_credit_out_all;
	wire [(3*V)-1 : 0] R4_credit_in_all;

	/*******************
	*		R5
	*******************/
	wire R5_clk;
	wire R5_reset;
	wire [RAw-1 :  0] R5_current_r_addr;
	wire [(4*RAw)-1:  0] R5_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R5_flit_in_all;
	wire [(4*Fw)-1 : 0] R5_flit_out_all;
	wire [(4*1)-1 : 0] R5_flit_in_wr_all;
	wire [(4*1)-1 : 0] R5_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R5_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R5_congestion_out_all;
	wire [(4*V)-1 : 0] R5_credit_out_all;
	wire [(4*V)-1 : 0] R5_credit_in_all;

    
    	
	/*******************
	*		R0
	*******************/
	router #(
		.P(2),
		.T1(6),
		.T2(6),
		.T3(4),
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
		.CONGw (CONGw ),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE)	
	)
	R0
	(	
		.clk(R0_clk), 
		.reset(R0_reset),
		.current_r_addr(R0_current_r_addr),
		.neighbors_r_addr(R0_neighbors_r_addr),
		.flit_in_all(R0_flit_in_all),
		.flit_out_all(R0_flit_out_all),
		.flit_in_wr_all(R0_flit_in_wr_all),
		.flit_out_wr_all(R0_flit_out_wr_all),
		.congestion_in_all(R0_congestion_in_all),
		.congestion_out_all(R0_congestion_out_all),
		.credit_out_all(R0_credit_out_all),
		.credit_in_all(R0_credit_in_all)
	);

		assign R0_clk = clk;
		assign R0_reset = reset;
		assign R0_current_r_addr = 0;
		assign R0_neighbors_r_addr=0;
//Connect R0 port 0 to  T0 port 0
		assign  R0_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T0_flit_in ;
		assign  R0_flit_in_wr_all [0] = T0_flit_in_wr ;
		assign  R0_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T0_credit_out = R0_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R0 port 1 to  R3 port 1
		assign  R0_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R3_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R0_flit_in_wr_all [1] = R3_flit_out_wr_all [1];
		assign  R0_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R3_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R3_credit_in_all [(2*V)-1 :	 1*V ]= R0_credit_out_all [(2*V)-1 : 		 1*V ];
	
	/*******************
	*		R1
	*******************/
	router #(
		.P(2),
		.T1(6),
		.T2(6),
		.T3(4),
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
		.CONGw (CONGw ),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE)	
	)
	R1
	(	
		.clk(R1_clk), 
		.reset(R1_reset),
		.current_r_addr(R1_current_r_addr),
		.neighbors_r_addr(R1_neighbors_r_addr),
		.flit_in_all(R1_flit_in_all),
		.flit_out_all(R1_flit_out_all),
		.flit_in_wr_all(R1_flit_in_wr_all),
		.flit_out_wr_all(R1_flit_out_wr_all),
		.congestion_in_all(R1_congestion_in_all),
		.congestion_out_all(R1_congestion_out_all),
		.credit_out_all(R1_credit_out_all),
		.credit_in_all(R1_credit_in_all)
	);

		assign R1_clk = clk;
		assign R1_reset = reset;
		assign R1_current_r_addr = 1;
		assign R1_neighbors_r_addr=0;
//Connect R1 port 0 to  T1 port 0
		assign  R1_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T1_flit_in ;
		assign  R1_flit_in_wr_all [0] = T1_flit_in_wr ;
		assign  R1_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T1_credit_out = R1_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R1 port 1 to  R5 port 2
		assign  R1_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R5_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R1_flit_in_wr_all [1] = R5_flit_out_wr_all [2];
		assign  R1_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R5_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R5_credit_in_all [(3*V)-1 :	 2*V ]= R1_credit_out_all [(2*V)-1 : 		 1*V ];
	
	/*******************
	*		R2
	*******************/
	router #(
		.P(2),
		.T1(6),
		.T2(6),
		.T3(4),
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
		.CONGw (CONGw ),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE)	
	)
	R2
	(	
		.clk(R2_clk), 
		.reset(R2_reset),
		.current_r_addr(R2_current_r_addr),
		.neighbors_r_addr(R2_neighbors_r_addr),
		.flit_in_all(R2_flit_in_all),
		.flit_out_all(R2_flit_out_all),
		.flit_in_wr_all(R2_flit_in_wr_all),
		.flit_out_wr_all(R2_flit_out_wr_all),
		.congestion_in_all(R2_congestion_in_all),
		.congestion_out_all(R2_congestion_out_all),
		.credit_out_all(R2_credit_out_all),
		.credit_in_all(R2_credit_in_all)
	);

		assign R2_clk = clk;
		assign R2_reset = reset;
		assign R2_current_r_addr = 2;
		assign R2_neighbors_r_addr=0;
//Connect R2 port 0 to  T2 port 0
		assign  R2_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T2_flit_in ;
		assign  R2_flit_in_wr_all [0] = T2_flit_in_wr ;
		assign  R2_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T2_credit_out = R2_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R2 port 1 to  R5 port 3
		assign  R2_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R5_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R2_flit_in_wr_all [1] = R5_flit_out_wr_all [3];
		assign  R2_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R5_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R5_credit_in_all [(4*V)-1 :	 3*V ]= R2_credit_out_all [(2*V)-1 : 		 1*V ];
	
	/*******************
	*		R3
	*******************/
	router #(
		.P(3),
		.T1(6),
		.T2(6),
		.T3(4),
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
		.CONGw (CONGw ),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE)	
	)
	R3
	(	
		.clk(R3_clk), 
		.reset(R3_reset),
		.current_r_addr(R3_current_r_addr),
		.neighbors_r_addr(R3_neighbors_r_addr),
		.flit_in_all(R3_flit_in_all),
		.flit_out_all(R3_flit_out_all),
		.flit_in_wr_all(R3_flit_in_wr_all),
		.flit_out_wr_all(R3_flit_out_wr_all),
		.congestion_in_all(R3_congestion_in_all),
		.congestion_out_all(R3_congestion_out_all),
		.credit_out_all(R3_credit_out_all),
		.credit_in_all(R3_credit_in_all)
	);

		assign R3_clk = clk;
		assign R3_reset = reset;
		assign R3_current_r_addr = 3;
		assign R3_neighbors_r_addr=0;
//Connect R3 port 0 to  T3 port 0
		assign  R3_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T3_flit_in ;
		assign  R3_flit_in_wr_all [0] = T3_flit_in_wr ;
		assign  R3_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T3_credit_out = R3_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R3 port 1 to  R0 port 1
		assign  R3_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R0_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R3_flit_in_wr_all [1] = R0_flit_out_wr_all [1];
		assign  R3_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R0_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R0_credit_in_all [(2*V)-1 :	 1*V ]= R3_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R3 port 2 to  R4 port 2
		assign  R3_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R4_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R3_flit_in_wr_all [2] = R4_flit_out_wr_all [2];
		assign  R3_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R4_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R4_credit_in_all [(3*V)-1 :	 2*V ]= R3_credit_out_all [(3*V)-1 : 		 2*V ];
	
	/*******************
	*		R4
	*******************/
	router #(
		.P(3),
		.T1(6),
		.T2(6),
		.T3(4),
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
		.CONGw (CONGw ),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE)	
	)
	R4
	(	
		.clk(R4_clk), 
		.reset(R4_reset),
		.current_r_addr(R4_current_r_addr),
		.neighbors_r_addr(R4_neighbors_r_addr),
		.flit_in_all(R4_flit_in_all),
		.flit_out_all(R4_flit_out_all),
		.flit_in_wr_all(R4_flit_in_wr_all),
		.flit_out_wr_all(R4_flit_out_wr_all),
		.congestion_in_all(R4_congestion_in_all),
		.congestion_out_all(R4_congestion_out_all),
		.credit_out_all(R4_credit_out_all),
		.credit_in_all(R4_credit_in_all)
	);

		assign R4_clk = clk;
		assign R4_reset = reset;
		assign R4_current_r_addr = 4;
		assign R4_neighbors_r_addr=0;
//Connect R4 port 0 to  T4 port 0
		assign  R4_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T4_flit_in ;
		assign  R4_flit_in_wr_all [0] = T4_flit_in_wr ;
		assign  R4_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T4_credit_out = R4_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R4 port 1 to  R5 port 1
		assign  R4_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R5_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R4_flit_in_wr_all [1] = R5_flit_out_wr_all [1];
		assign  R4_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R5_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R5_credit_in_all [(2*V)-1 :	 1*V ]= R4_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R4 port 2 to  R3 port 2
		assign  R4_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R3_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R4_flit_in_wr_all [2] = R3_flit_out_wr_all [2];
		assign  R4_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R3_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R3_credit_in_all [(3*V)-1 :	 2*V ]= R4_credit_out_all [(3*V)-1 : 		 2*V ];
	
	/*******************
	*		R5
	*******************/
	router #(
		.P(4),
		.T1(6),
		.T2(6),
		.T3(4),
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
		.CONGw (CONGw ),
		.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR),
		.CVw(CVw),
		.CLASS_SETTING (CLASS_SETTING ),
		.SSA_EN(SSA_EN),
		.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ),
		.WEIGHTw (WEIGHTw ),
		.MIN_PCK_SIZE(MIN_PCK_SIZE)	
	)
	R5
	(	
		.clk(R5_clk), 
		.reset(R5_reset),
		.current_r_addr(R5_current_r_addr),
		.neighbors_r_addr(R5_neighbors_r_addr),
		.flit_in_all(R5_flit_in_all),
		.flit_out_all(R5_flit_out_all),
		.flit_in_wr_all(R5_flit_in_wr_all),
		.flit_out_wr_all(R5_flit_out_wr_all),
		.congestion_in_all(R5_congestion_in_all),
		.congestion_out_all(R5_congestion_out_all),
		.credit_out_all(R5_credit_out_all),
		.credit_in_all(R5_credit_in_all)
	);

		assign R5_clk = clk;
		assign R5_reset = reset;
		assign R5_current_r_addr = 5;
		assign R5_neighbors_r_addr=0;
//Connect R5 port 0 to  T5 port 0
		assign  R5_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T5_flit_in ;
		assign  R5_flit_in_wr_all [0] = T5_flit_in_wr ;
		assign  R5_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T5_credit_out = R5_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R5 port 1 to  R4 port 1
		assign  R5_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R4_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R5_flit_in_wr_all [1] = R4_flit_out_wr_all [1];
		assign  R5_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R4_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R4_credit_in_all [(2*V)-1 :	 1*V ]= R5_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R5 port 2 to  R1 port 1
		assign  R5_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R1_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R5_flit_in_wr_all [2] = R1_flit_out_wr_all [1];
		assign  R5_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R1_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R1_credit_in_all [(2*V)-1 :	 1*V ]= R5_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R5 port 3 to  R2 port 1
		assign  R5_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R2_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R5_flit_in_wr_all [3] = R2_flit_out_wr_all [1];
		assign  R5_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R2_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R2_credit_in_all [(2*V)-1 :	 1*V ]= R5_credit_out_all [(4*V)-1 : 		 3*V ];

    
    //Connect T0 output ports 0 to  R0 input ports 0
		assign  T0_flit_out [Fw-1 : 		 0 ] = R0_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T0_flit_out_wr   = R0_flit_out_wr_all [0];
		assign  R0_credit_in_all [(1*V)-1 :	 0*V ]= T0_credit_in [V-1 : 		 0 ];
//Connect T1 output ports 0 to  R1 input ports 0
		assign  T1_flit_out [Fw-1 : 		 0 ] = R1_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T1_flit_out_wr   = R1_flit_out_wr_all [0];
		assign  R1_credit_in_all [(1*V)-1 :	 0*V ]= T1_credit_in [V-1 : 		 0 ];
//Connect T2 output ports 0 to  R2 input ports 0
		assign  T2_flit_out [Fw-1 : 		 0 ] = R2_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T2_flit_out_wr   = R2_flit_out_wr_all [0];
		assign  R2_credit_in_all [(1*V)-1 :	 0*V ]= T2_credit_in [V-1 : 		 0 ];
//Connect T3 output ports 0 to  R3 input ports 0
		assign  T3_flit_out [Fw-1 : 		 0 ] = R3_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T3_flit_out_wr   = R3_flit_out_wr_all [0];
		assign  R3_credit_in_all [(1*V)-1 :	 0*V ]= T3_credit_in [V-1 : 		 0 ];
//Connect T4 output ports 0 to  R4 input ports 0
		assign  T4_flit_out [Fw-1 : 		 0 ] = R4_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T4_flit_out_wr   = R4_flit_out_wr_all [0];
		assign  R4_credit_in_all [(1*V)-1 :	 0*V ]= T4_credit_in [V-1 : 		 0 ];
//Connect T5 output ports 0 to  R5 input ports 0
		assign  T5_flit_out [Fw-1 : 		 0 ] = R5_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T5_flit_out_wr   = R5_flit_out_wr_all [0];
		assign  R5_credit_in_all [(1*V)-1 :	 0*V ]= T5_credit_in [V-1 : 		 0 ];

             
endmodule
