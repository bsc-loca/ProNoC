
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/git/hca_git/ProNoC/mpsoc/src_topolgy/custom1/custom1_noc.v
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

module   custom1_noc #(  
    	parameter TOPOLOGY = "custom1",
	parameter ROUTE_NAME = "custom1_DETERMINISTIC",
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
	T5_credit_in,
	//T6,
	T6_flit_in,
	T6_flit_out,
	T6_flit_in_wr,
	T6_flit_out_wr,
	T6_credit_out,
	T6_credit_in,
	//T7,
	T7_flit_in,
	T7_flit_out,
	T7_flit_in_wr,
	T7_flit_out_wr,
	T7_credit_out,
	T7_credit_in,
	//T8,
	T8_flit_in,
	T8_flit_out,
	T8_flit_in_wr,
	T8_flit_out_wr,
	T8_credit_out,
	T8_credit_in,
	//T9,
	T9_flit_in,
	T9_flit_out,
	T9_flit_in_wr,
	T9_flit_out_wr,
	T9_credit_out,
	T9_credit_in,
	//T10,
	T10_flit_in,
	T10_flit_out,
	T10_flit_in_wr,
	T10_flit_out_wr,
	T10_credit_out,
	T10_credit_in,
	//T11,
	T11_flit_in,
	T11_flit_out,
	T11_flit_in_wr,
	T11_flit_out_wr,
	T11_credit_out,
	T11_credit_in,
	//T12,
	T12_flit_in,
	T12_flit_out,
	T12_flit_in_wr,
	T12_flit_out_wr,
	T12_credit_out,
	T12_credit_in,
	//T13,
	T13_flit_in,
	T13_flit_out,
	T13_flit_in_wr,
	T13_flit_out_wr,
	T13_credit_out,
	T13_credit_in,
	//T14,
	T14_flit_in,
	T14_flit_out,
	T14_flit_in_wr,
	T14_flit_out_wr,
	T14_credit_out,
	T14_credit_in,
	//T15,
	T15_flit_in,
	T15_flit_out,
	T15_flit_in_wr,
	T15_flit_out_wr,
	T15_credit_out,
	T15_credit_in
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
	*		T6
	*******************/
	input  [Fw-1 : 0] T6_flit_in;
	output  [Fw-1 : 0] T6_flit_out;
	input   T6_flit_in_wr;
	output   T6_flit_out_wr;
	output  [V-1 : 0] T6_credit_out;
	input  [V-1 : 0] T6_credit_in;

	/*******************
	*		T7
	*******************/
	input  [Fw-1 : 0] T7_flit_in;
	output  [Fw-1 : 0] T7_flit_out;
	input   T7_flit_in_wr;
	output   T7_flit_out_wr;
	output  [V-1 : 0] T7_credit_out;
	input  [V-1 : 0] T7_credit_in;

	/*******************
	*		T8
	*******************/
	input  [Fw-1 : 0] T8_flit_in;
	output  [Fw-1 : 0] T8_flit_out;
	input   T8_flit_in_wr;
	output   T8_flit_out_wr;
	output  [V-1 : 0] T8_credit_out;
	input  [V-1 : 0] T8_credit_in;

	/*******************
	*		T9
	*******************/
	input  [Fw-1 : 0] T9_flit_in;
	output  [Fw-1 : 0] T9_flit_out;
	input   T9_flit_in_wr;
	output   T9_flit_out_wr;
	output  [V-1 : 0] T9_credit_out;
	input  [V-1 : 0] T9_credit_in;

	/*******************
	*		T10
	*******************/
	input  [Fw-1 : 0] T10_flit_in;
	output  [Fw-1 : 0] T10_flit_out;
	input   T10_flit_in_wr;
	output   T10_flit_out_wr;
	output  [V-1 : 0] T10_credit_out;
	input  [V-1 : 0] T10_credit_in;

	/*******************
	*		T11
	*******************/
	input  [Fw-1 : 0] T11_flit_in;
	output  [Fw-1 : 0] T11_flit_out;
	input   T11_flit_in_wr;
	output   T11_flit_out_wr;
	output  [V-1 : 0] T11_credit_out;
	input  [V-1 : 0] T11_credit_in;

	/*******************
	*		T12
	*******************/
	input  [Fw-1 : 0] T12_flit_in;
	output  [Fw-1 : 0] T12_flit_out;
	input   T12_flit_in_wr;
	output   T12_flit_out_wr;
	output  [V-1 : 0] T12_credit_out;
	input  [V-1 : 0] T12_credit_in;

	/*******************
	*		T13
	*******************/
	input  [Fw-1 : 0] T13_flit_in;
	output  [Fw-1 : 0] T13_flit_out;
	input   T13_flit_in_wr;
	output   T13_flit_out_wr;
	output  [V-1 : 0] T13_credit_out;
	input  [V-1 : 0] T13_credit_in;

	/*******************
	*		T14
	*******************/
	input  [Fw-1 : 0] T14_flit_in;
	output  [Fw-1 : 0] T14_flit_out;
	input   T14_flit_in_wr;
	output   T14_flit_out_wr;
	output  [V-1 : 0] T14_credit_out;
	input  [V-1 : 0] T14_credit_in;

	/*******************
	*		T15
	*******************/
	input  [Fw-1 : 0] T15_flit_in;
	output  [Fw-1 : 0] T15_flit_out;
	input   T15_flit_in_wr;
	output   T15_flit_out_wr;
	output  [V-1 : 0] T15_credit_out;
	input  [V-1 : 0] T15_credit_in;

	/*******************
	*		R0
	*******************/
	wire R0_clk;
	wire R0_reset;
	wire [RAw-1 :  0] R0_current_r_addr;
	wire [(3*RAw)-1:  0] R0_neighbors_r_addr;
	wire [(3*Fw)-1 : 0] R0_flit_in_all;
	wire [(3*Fw)-1 : 0] R0_flit_out_all;
	wire [(3*1)-1 : 0] R0_flit_in_wr_all;
	wire [(3*1)-1 : 0] R0_flit_out_wr_all;
	wire [(3*CONGw)-1 : 0] R0_congestion_in_all;
	wire [(3*CONGw)-1 : 0] R0_congestion_out_all;
	wire [(3*V)-1 : 0] R0_credit_out_all;
	wire [(3*V)-1 : 0] R0_credit_in_all;

	/*******************
	*		R1
	*******************/
	wire R1_clk;
	wire R1_reset;
	wire [RAw-1 :  0] R1_current_r_addr;
	wire [(3*RAw)-1:  0] R1_neighbors_r_addr;
	wire [(3*Fw)-1 : 0] R1_flit_in_all;
	wire [(3*Fw)-1 : 0] R1_flit_out_all;
	wire [(3*1)-1 : 0] R1_flit_in_wr_all;
	wire [(3*1)-1 : 0] R1_flit_out_wr_all;
	wire [(3*CONGw)-1 : 0] R1_congestion_in_all;
	wire [(3*CONGw)-1 : 0] R1_congestion_out_all;
	wire [(3*V)-1 : 0] R1_credit_out_all;
	wire [(3*V)-1 : 0] R1_credit_in_all;

	/*******************
	*		R2
	*******************/
	wire R2_clk;
	wire R2_reset;
	wire [RAw-1 :  0] R2_current_r_addr;
	wire [(3*RAw)-1:  0] R2_neighbors_r_addr;
	wire [(3*Fw)-1 : 0] R2_flit_in_all;
	wire [(3*Fw)-1 : 0] R2_flit_out_all;
	wire [(3*1)-1 : 0] R2_flit_in_wr_all;
	wire [(3*1)-1 : 0] R2_flit_out_wr_all;
	wire [(3*CONGw)-1 : 0] R2_congestion_in_all;
	wire [(3*CONGw)-1 : 0] R2_congestion_out_all;
	wire [(3*V)-1 : 0] R2_credit_out_all;
	wire [(3*V)-1 : 0] R2_credit_in_all;

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
	wire [(4*RAw)-1:  0] R4_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R4_flit_in_all;
	wire [(4*Fw)-1 : 0] R4_flit_out_all;
	wire [(4*1)-1 : 0] R4_flit_in_wr_all;
	wire [(4*1)-1 : 0] R4_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R4_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R4_congestion_out_all;
	wire [(4*V)-1 : 0] R4_credit_out_all;
	wire [(4*V)-1 : 0] R4_credit_in_all;

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
	*		R6
	*******************/
	wire R6_clk;
	wire R6_reset;
	wire [RAw-1 :  0] R6_current_r_addr;
	wire [(4*RAw)-1:  0] R6_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R6_flit_in_all;
	wire [(4*Fw)-1 : 0] R6_flit_out_all;
	wire [(4*1)-1 : 0] R6_flit_in_wr_all;
	wire [(4*1)-1 : 0] R6_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R6_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R6_congestion_out_all;
	wire [(4*V)-1 : 0] R6_credit_out_all;
	wire [(4*V)-1 : 0] R6_credit_in_all;

	/*******************
	*		R7
	*******************/
	wire R7_clk;
	wire R7_reset;
	wire [RAw-1 :  0] R7_current_r_addr;
	wire [(4*RAw)-1:  0] R7_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R7_flit_in_all;
	wire [(4*Fw)-1 : 0] R7_flit_out_all;
	wire [(4*1)-1 : 0] R7_flit_in_wr_all;
	wire [(4*1)-1 : 0] R7_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R7_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R7_congestion_out_all;
	wire [(4*V)-1 : 0] R7_credit_out_all;
	wire [(4*V)-1 : 0] R7_credit_in_all;

	/*******************
	*		R12
	*******************/
	wire R12_clk;
	wire R12_reset;
	wire [RAw-1 :  0] R12_current_r_addr;
	wire [(4*RAw)-1:  0] R12_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R12_flit_in_all;
	wire [(4*Fw)-1 : 0] R12_flit_out_all;
	wire [(4*1)-1 : 0] R12_flit_in_wr_all;
	wire [(4*1)-1 : 0] R12_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R12_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R12_congestion_out_all;
	wire [(4*V)-1 : 0] R12_credit_out_all;
	wire [(4*V)-1 : 0] R12_credit_in_all;

	/*******************
	*		R13
	*******************/
	wire R13_clk;
	wire R13_reset;
	wire [RAw-1 :  0] R13_current_r_addr;
	wire [(4*RAw)-1:  0] R13_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R13_flit_in_all;
	wire [(4*Fw)-1 : 0] R13_flit_out_all;
	wire [(4*1)-1 : 0] R13_flit_in_wr_all;
	wire [(4*1)-1 : 0] R13_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R13_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R13_congestion_out_all;
	wire [(4*V)-1 : 0] R13_credit_out_all;
	wire [(4*V)-1 : 0] R13_credit_in_all;

	/*******************
	*		R14
	*******************/
	wire R14_clk;
	wire R14_reset;
	wire [RAw-1 :  0] R14_current_r_addr;
	wire [(4*RAw)-1:  0] R14_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R14_flit_in_all;
	wire [(4*Fw)-1 : 0] R14_flit_out_all;
	wire [(4*1)-1 : 0] R14_flit_in_wr_all;
	wire [(4*1)-1 : 0] R14_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R14_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R14_congestion_out_all;
	wire [(4*V)-1 : 0] R14_credit_out_all;
	wire [(4*V)-1 : 0] R14_credit_in_all;

	/*******************
	*		R15
	*******************/
	wire R15_clk;
	wire R15_reset;
	wire [RAw-1 :  0] R15_current_r_addr;
	wire [(4*RAw)-1:  0] R15_neighbors_r_addr;
	wire [(4*Fw)-1 : 0] R15_flit_in_all;
	wire [(4*Fw)-1 : 0] R15_flit_out_all;
	wire [(4*1)-1 : 0] R15_flit_in_wr_all;
	wire [(4*1)-1 : 0] R15_flit_out_wr_all;
	wire [(4*CONGw)-1 : 0] R15_congestion_in_all;
	wire [(4*CONGw)-1 : 0] R15_congestion_out_all;
	wire [(4*V)-1 : 0] R15_credit_out_all;
	wire [(4*V)-1 : 0] R15_credit_in_all;

	/*******************
	*		R8
	*******************/
	wire R8_clk;
	wire R8_reset;
	wire [RAw-1 :  0] R8_current_r_addr;
	wire [(5*RAw)-1:  0] R8_neighbors_r_addr;
	wire [(5*Fw)-1 : 0] R8_flit_in_all;
	wire [(5*Fw)-1 : 0] R8_flit_out_all;
	wire [(5*1)-1 : 0] R8_flit_in_wr_all;
	wire [(5*1)-1 : 0] R8_flit_out_wr_all;
	wire [(5*CONGw)-1 : 0] R8_congestion_in_all;
	wire [(5*CONGw)-1 : 0] R8_congestion_out_all;
	wire [(5*V)-1 : 0] R8_credit_out_all;
	wire [(5*V)-1 : 0] R8_credit_in_all;

	/*******************
	*		R9
	*******************/
	wire R9_clk;
	wire R9_reset;
	wire [RAw-1 :  0] R9_current_r_addr;
	wire [(5*RAw)-1:  0] R9_neighbors_r_addr;
	wire [(5*Fw)-1 : 0] R9_flit_in_all;
	wire [(5*Fw)-1 : 0] R9_flit_out_all;
	wire [(5*1)-1 : 0] R9_flit_in_wr_all;
	wire [(5*1)-1 : 0] R9_flit_out_wr_all;
	wire [(5*CONGw)-1 : 0] R9_congestion_in_all;
	wire [(5*CONGw)-1 : 0] R9_congestion_out_all;
	wire [(5*V)-1 : 0] R9_credit_out_all;
	wire [(5*V)-1 : 0] R9_credit_in_all;

	/*******************
	*		R10
	*******************/
	wire R10_clk;
	wire R10_reset;
	wire [RAw-1 :  0] R10_current_r_addr;
	wire [(5*RAw)-1:  0] R10_neighbors_r_addr;
	wire [(5*Fw)-1 : 0] R10_flit_in_all;
	wire [(5*Fw)-1 : 0] R10_flit_out_all;
	wire [(5*1)-1 : 0] R10_flit_in_wr_all;
	wire [(5*1)-1 : 0] R10_flit_out_wr_all;
	wire [(5*CONGw)-1 : 0] R10_congestion_in_all;
	wire [(5*CONGw)-1 : 0] R10_congestion_out_all;
	wire [(5*V)-1 : 0] R10_credit_out_all;
	wire [(5*V)-1 : 0] R10_credit_in_all;

	/*******************
	*		R11
	*******************/
	wire R11_clk;
	wire R11_reset;
	wire [RAw-1 :  0] R11_current_r_addr;
	wire [(5*RAw)-1:  0] R11_neighbors_r_addr;
	wire [(5*Fw)-1 : 0] R11_flit_in_all;
	wire [(5*Fw)-1 : 0] R11_flit_out_all;
	wire [(5*1)-1 : 0] R11_flit_in_wr_all;
	wire [(5*1)-1 : 0] R11_flit_out_wr_all;
	wire [(5*CONGw)-1 : 0] R11_congestion_in_all;
	wire [(5*CONGw)-1 : 0] R11_congestion_out_all;
	wire [(5*V)-1 : 0] R11_credit_out_all;
	wire [(5*V)-1 : 0] R11_credit_in_all;

    
    	
	/*******************
	*		R0
	*******************/
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
//Connect R0 port 1 to  R14 port 3
		assign  R0_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R14_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R0_flit_in_wr_all [1] = R14_flit_out_wr_all [3];
		assign  R0_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R14_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R14_credit_in_all [(4*V)-1 :	 3*V ]= R0_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R0 port 2 to  R13 port 3
		assign  R0_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R13_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R0_flit_in_wr_all [2] = R13_flit_out_wr_all [3];
		assign  R0_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R13_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R13_credit_in_all [(4*V)-1 :	 3*V ]= R0_credit_out_all [(3*V)-1 : 		 2*V ];
	
	/*******************
	*		R1
	*******************/
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
//Connect R1 port 1 to  R7 port 3
		assign  R1_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R7_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R1_flit_in_wr_all [1] = R7_flit_out_wr_all [3];
		assign  R1_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R7_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R7_credit_in_all [(4*V)-1 :	 3*V ]= R1_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R1 port 2 to  R2 port 2
		assign  R1_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R2_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R1_flit_in_wr_all [2] = R2_flit_out_wr_all [2];
		assign  R1_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R2_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R2_credit_in_all [(3*V)-1 :	 2*V ]= R1_credit_out_all [(3*V)-1 : 		 2*V ];
	
	/*******************
	*		R2
	*******************/
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
//Connect R2 port 1 to  R15 port 2
		assign  R2_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R15_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R2_flit_in_wr_all [1] = R15_flit_out_wr_all [2];
		assign  R2_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R15_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R15_credit_in_all [(3*V)-1 :	 2*V ]= R2_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R2 port 2 to  R1 port 2
		assign  R2_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R1_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R2_flit_in_wr_all [2] = R1_flit_out_wr_all [2];
		assign  R2_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R1_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R1_credit_in_all [(3*V)-1 :	 2*V ]= R2_credit_out_all [(3*V)-1 : 		 2*V ];
	
	/*******************
	*		R3
	*******************/
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
//Connect R3 port 1 to  R15 port 3
		assign  R3_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R15_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R3_flit_in_wr_all [1] = R15_flit_out_wr_all [3];
		assign  R3_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R15_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R15_credit_in_all [(4*V)-1 :	 3*V ]= R3_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R3 port 2 to  R4 port 2
		assign  R3_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R4_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R3_flit_in_wr_all [2] = R4_flit_out_wr_all [2];
		assign  R3_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R4_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R4_credit_in_all [(3*V)-1 :	 2*V ]= R3_credit_out_all [(3*V)-1 : 		 2*V ];
	
	/*******************
	*		R4
	*******************/
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
//Connect R4 port 1 to  R9 port 2
		assign  R4_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R9_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R4_flit_in_wr_all [1] = R9_flit_out_wr_all [2];
		assign  R4_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R9_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R9_credit_in_all [(3*V)-1 :	 2*V ]= R4_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R4 port 2 to  R3 port 2
		assign  R4_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R3_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R4_flit_in_wr_all [2] = R3_flit_out_wr_all [2];
		assign  R4_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R3_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R3_credit_in_all [(3*V)-1 :	 2*V ]= R4_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R4 port 3 to  R6 port 3
		assign  R4_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R6_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R4_flit_in_wr_all [3] = R6_flit_out_wr_all [3];
		assign  R4_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R6_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R6_credit_in_all [(4*V)-1 :	 3*V ]= R4_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R5
	*******************/
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
//Connect R5 port 1 to  R11 port 4
		assign  R5_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R11_flit_out_all [(5*Fw)-1 :	 4*Fw ];
		assign  R5_flit_in_wr_all [1] = R11_flit_out_wr_all [4];
		assign  R5_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R11_congestion_out_all [(5*CONGw)-1 :	 4*CONGw ];
		assign  R11_credit_in_all [(5*V)-1 :	 4*V ]= R5_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R5 port 2 to  R6 port 2
		assign  R5_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R6_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R5_flit_in_wr_all [2] = R6_flit_out_wr_all [2];
		assign  R5_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R6_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R6_credit_in_all [(3*V)-1 :	 2*V ]= R5_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R5 port 3 to  R13 port 2
		assign  R5_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R13_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R5_flit_in_wr_all [3] = R13_flit_out_wr_all [2];
		assign  R5_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R13_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R13_credit_in_all [(3*V)-1 :	 2*V ]= R5_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R6
	*******************/
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
	R6
	(	
		.clk(R6_clk), 
		.reset(R6_reset),
		.current_r_addr(R6_current_r_addr),
		.neighbors_r_addr(R6_neighbors_r_addr),
		.flit_in_all(R6_flit_in_all),
		.flit_out_all(R6_flit_out_all),
		.flit_in_wr_all(R6_flit_in_wr_all),
		.flit_out_wr_all(R6_flit_out_wr_all),
		.congestion_in_all(R6_congestion_in_all),
		.congestion_out_all(R6_congestion_out_all),
		.credit_out_all(R6_credit_out_all),
		.credit_in_all(R6_credit_in_all)
	);

		assign R6_clk = clk;
		assign R6_reset = reset;
		assign R6_current_r_addr = 6;
		assign R6_neighbors_r_addr=0;
//Connect R6 port 0 to  T6 port 0
		assign  R6_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T6_flit_in ;
		assign  R6_flit_in_wr_all [0] = T6_flit_in_wr ;
		assign  R6_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T6_credit_out = R6_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R6 port 1 to  R9 port 3
		assign  R6_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R9_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R6_flit_in_wr_all [1] = R9_flit_out_wr_all [3];
		assign  R6_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R9_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R9_credit_in_all [(4*V)-1 :	 3*V ]= R6_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R6 port 2 to  R5 port 2
		assign  R6_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R5_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R6_flit_in_wr_all [2] = R5_flit_out_wr_all [2];
		assign  R6_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R5_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R5_credit_in_all [(3*V)-1 :	 2*V ]= R6_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R6 port 3 to  R4 port 3
		assign  R6_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R4_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R6_flit_in_wr_all [3] = R4_flit_out_wr_all [3];
		assign  R6_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R4_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R4_credit_in_all [(4*V)-1 :	 3*V ]= R6_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R7
	*******************/
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
	R7
	(	
		.clk(R7_clk), 
		.reset(R7_reset),
		.current_r_addr(R7_current_r_addr),
		.neighbors_r_addr(R7_neighbors_r_addr),
		.flit_in_all(R7_flit_in_all),
		.flit_out_all(R7_flit_out_all),
		.flit_in_wr_all(R7_flit_in_wr_all),
		.flit_out_wr_all(R7_flit_out_wr_all),
		.congestion_in_all(R7_congestion_in_all),
		.congestion_out_all(R7_congestion_out_all),
		.credit_out_all(R7_credit_out_all),
		.credit_in_all(R7_credit_in_all)
	);

		assign R7_clk = clk;
		assign R7_reset = reset;
		assign R7_current_r_addr = 7;
		assign R7_neighbors_r_addr=0;
//Connect R7 port 0 to  T7 port 0
		assign  R7_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T7_flit_in ;
		assign  R7_flit_in_wr_all [0] = T7_flit_in_wr ;
		assign  R7_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T7_credit_out = R7_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R7 port 1 to  R12 port 3
		assign  R7_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R12_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R7_flit_in_wr_all [1] = R12_flit_out_wr_all [3];
		assign  R7_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R12_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R12_credit_in_all [(4*V)-1 :	 3*V ]= R7_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R7 port 2 to  R14 port 2
		assign  R7_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R14_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R7_flit_in_wr_all [2] = R14_flit_out_wr_all [2];
		assign  R7_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R14_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R14_credit_in_all [(3*V)-1 :	 2*V ]= R7_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R7 port 3 to  R1 port 1
		assign  R7_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R1_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R7_flit_in_wr_all [3] = R1_flit_out_wr_all [1];
		assign  R7_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R1_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R1_credit_in_all [(2*V)-1 :	 1*V ]= R7_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R12
	*******************/
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
	R12
	(	
		.clk(R12_clk), 
		.reset(R12_reset),
		.current_r_addr(R12_current_r_addr),
		.neighbors_r_addr(R12_neighbors_r_addr),
		.flit_in_all(R12_flit_in_all),
		.flit_out_all(R12_flit_out_all),
		.flit_in_wr_all(R12_flit_in_wr_all),
		.flit_out_wr_all(R12_flit_out_wr_all),
		.congestion_in_all(R12_congestion_in_all),
		.congestion_out_all(R12_congestion_out_all),
		.credit_out_all(R12_credit_out_all),
		.credit_in_all(R12_credit_in_all)
	);

		assign R12_clk = clk;
		assign R12_reset = reset;
		assign R12_current_r_addr = 8;
		assign R12_neighbors_r_addr=0;
//Connect R12 port 0 to  T8 port 0
		assign  R12_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T8_flit_in ;
		assign  R12_flit_in_wr_all [0] = T8_flit_in_wr ;
		assign  R12_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T8_credit_out = R12_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R12 port 1 to  R8 port 4
		assign  R12_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R8_flit_out_all [(5*Fw)-1 :	 4*Fw ];
		assign  R12_flit_in_wr_all [1] = R8_flit_out_wr_all [4];
		assign  R12_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R8_congestion_out_all [(5*CONGw)-1 :	 4*CONGw ];
		assign  R8_credit_in_all [(5*V)-1 :	 4*V ]= R12_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R12 port 2 to  R10 port 3
		assign  R12_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R10_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R12_flit_in_wr_all [2] = R10_flit_out_wr_all [3];
		assign  R12_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R10_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R10_credit_in_all [(4*V)-1 :	 3*V ]= R12_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R12 port 3 to  R7 port 1
		assign  R12_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R7_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R12_flit_in_wr_all [3] = R7_flit_out_wr_all [1];
		assign  R12_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R7_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R7_credit_in_all [(2*V)-1 :	 1*V ]= R12_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R13
	*******************/
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
	R13
	(	
		.clk(R13_clk), 
		.reset(R13_reset),
		.current_r_addr(R13_current_r_addr),
		.neighbors_r_addr(R13_neighbors_r_addr),
		.flit_in_all(R13_flit_in_all),
		.flit_out_all(R13_flit_out_all),
		.flit_in_wr_all(R13_flit_in_wr_all),
		.flit_out_wr_all(R13_flit_out_wr_all),
		.congestion_in_all(R13_congestion_in_all),
		.congestion_out_all(R13_congestion_out_all),
		.credit_out_all(R13_credit_out_all),
		.credit_in_all(R13_credit_in_all)
	);

		assign R13_clk = clk;
		assign R13_reset = reset;
		assign R13_current_r_addr = 9;
		assign R13_neighbors_r_addr=0;
//Connect R13 port 0 to  T9 port 0
		assign  R13_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T9_flit_in ;
		assign  R13_flit_in_wr_all [0] = T9_flit_in_wr ;
		assign  R13_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T9_credit_out = R13_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R13 port 1 to  R8 port 2
		assign  R13_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R8_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R13_flit_in_wr_all [1] = R8_flit_out_wr_all [2];
		assign  R13_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R8_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R8_credit_in_all [(3*V)-1 :	 2*V ]= R13_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R13 port 2 to  R5 port 3
		assign  R13_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R5_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R13_flit_in_wr_all [2] = R5_flit_out_wr_all [3];
		assign  R13_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R5_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R5_credit_in_all [(4*V)-1 :	 3*V ]= R13_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R13 port 3 to  R0 port 2
		assign  R13_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R0_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R13_flit_in_wr_all [3] = R0_flit_out_wr_all [2];
		assign  R13_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R0_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R0_credit_in_all [(3*V)-1 :	 2*V ]= R13_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R14
	*******************/
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
	R14
	(	
		.clk(R14_clk), 
		.reset(R14_reset),
		.current_r_addr(R14_current_r_addr),
		.neighbors_r_addr(R14_neighbors_r_addr),
		.flit_in_all(R14_flit_in_all),
		.flit_out_all(R14_flit_out_all),
		.flit_in_wr_all(R14_flit_in_wr_all),
		.flit_out_wr_all(R14_flit_out_wr_all),
		.congestion_in_all(R14_congestion_in_all),
		.congestion_out_all(R14_congestion_out_all),
		.credit_out_all(R14_credit_out_all),
		.credit_in_all(R14_credit_in_all)
	);

		assign R14_clk = clk;
		assign R14_reset = reset;
		assign R14_current_r_addr = 10;
		assign R14_neighbors_r_addr=0;
//Connect R14 port 0 to  T10 port 0
		assign  R14_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T10_flit_in ;
		assign  R14_flit_in_wr_all [0] = T10_flit_in_wr ;
		assign  R14_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T10_credit_out = R14_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R14 port 1 to  R8 port 3
		assign  R14_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R8_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R14_flit_in_wr_all [1] = R8_flit_out_wr_all [3];
		assign  R14_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R8_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R8_credit_in_all [(4*V)-1 :	 3*V ]= R14_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R14 port 2 to  R7 port 2
		assign  R14_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R7_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R14_flit_in_wr_all [2] = R7_flit_out_wr_all [2];
		assign  R14_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R7_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R7_credit_in_all [(3*V)-1 :	 2*V ]= R14_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R14 port 3 to  R0 port 1
		assign  R14_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R0_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R14_flit_in_wr_all [3] = R0_flit_out_wr_all [1];
		assign  R14_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R0_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R0_credit_in_all [(2*V)-1 :	 1*V ]= R14_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R15
	*******************/
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
	R15
	(	
		.clk(R15_clk), 
		.reset(R15_reset),
		.current_r_addr(R15_current_r_addr),
		.neighbors_r_addr(R15_neighbors_r_addr),
		.flit_in_all(R15_flit_in_all),
		.flit_out_all(R15_flit_out_all),
		.flit_in_wr_all(R15_flit_in_wr_all),
		.flit_out_wr_all(R15_flit_out_wr_all),
		.congestion_in_all(R15_congestion_in_all),
		.congestion_out_all(R15_congestion_out_all),
		.credit_out_all(R15_credit_out_all),
		.credit_in_all(R15_credit_in_all)
	);

		assign R15_clk = clk;
		assign R15_reset = reset;
		assign R15_current_r_addr = 11;
		assign R15_neighbors_r_addr=0;
//Connect R15 port 0 to  T11 port 0
		assign  R15_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T11_flit_in ;
		assign  R15_flit_in_wr_all [0] = T11_flit_in_wr ;
		assign  R15_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T11_credit_out = R15_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R15 port 1 to  R10 port 4
		assign  R15_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R10_flit_out_all [(5*Fw)-1 :	 4*Fw ];
		assign  R15_flit_in_wr_all [1] = R10_flit_out_wr_all [4];
		assign  R15_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R10_congestion_out_all [(5*CONGw)-1 :	 4*CONGw ];
		assign  R10_credit_in_all [(5*V)-1 :	 4*V ]= R15_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R15 port 2 to  R2 port 1
		assign  R15_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R2_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R15_flit_in_wr_all [2] = R2_flit_out_wr_all [1];
		assign  R15_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R2_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R2_credit_in_all [(2*V)-1 :	 1*V ]= R15_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R15 port 3 to  R3 port 1
		assign  R15_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R3_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R15_flit_in_wr_all [3] = R3_flit_out_wr_all [1];
		assign  R15_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R3_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R3_credit_in_all [(2*V)-1 :	 1*V ]= R15_credit_out_all [(4*V)-1 : 		 3*V ];
	
	/*******************
	*		R8
	*******************/
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
	R8
	(	
		.clk(R8_clk), 
		.reset(R8_reset),
		.current_r_addr(R8_current_r_addr),
		.neighbors_r_addr(R8_neighbors_r_addr),
		.flit_in_all(R8_flit_in_all),
		.flit_out_all(R8_flit_out_all),
		.flit_in_wr_all(R8_flit_in_wr_all),
		.flit_out_wr_all(R8_flit_out_wr_all),
		.congestion_in_all(R8_congestion_in_all),
		.congestion_out_all(R8_congestion_out_all),
		.credit_out_all(R8_credit_out_all),
		.credit_in_all(R8_credit_in_all)
	);

		assign R8_clk = clk;
		assign R8_reset = reset;
		assign R8_current_r_addr = 12;
		assign R8_neighbors_r_addr=0;
//Connect R8 port 0 to  T12 port 0
		assign  R8_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T12_flit_in ;
		assign  R8_flit_in_wr_all [0] = T12_flit_in_wr ;
		assign  R8_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T12_credit_out = R8_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R8 port 1 to  R11 port 1
		assign  R8_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R11_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R8_flit_in_wr_all [1] = R11_flit_out_wr_all [1];
		assign  R8_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R11_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R11_credit_in_all [(2*V)-1 :	 1*V ]= R8_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R8 port 2 to  R13 port 1
		assign  R8_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R13_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R8_flit_in_wr_all [2] = R13_flit_out_wr_all [1];
		assign  R8_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R13_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R13_credit_in_all [(2*V)-1 :	 1*V ]= R8_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R8 port 3 to  R14 port 1
		assign  R8_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R14_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R8_flit_in_wr_all [3] = R14_flit_out_wr_all [1];
		assign  R8_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R14_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R14_credit_in_all [(2*V)-1 :	 1*V ]= R8_credit_out_all [(4*V)-1 : 		 3*V ];
//Connect R8 port 4 to  R12 port 1
		assign  R8_flit_in_all [(5*Fw)-1 : 		 4*Fw ] = R12_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R8_flit_in_wr_all [4] = R12_flit_out_wr_all [1];
		assign  R8_congestion_in_all [(5*CONGw)-1 : 		 4*CONGw ] = R12_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R12_credit_in_all [(2*V)-1 :	 1*V ]= R8_credit_out_all [(5*V)-1 : 		 4*V ];
	
	/*******************
	*		R9
	*******************/
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
	R9
	(	
		.clk(R9_clk), 
		.reset(R9_reset),
		.current_r_addr(R9_current_r_addr),
		.neighbors_r_addr(R9_neighbors_r_addr),
		.flit_in_all(R9_flit_in_all),
		.flit_out_all(R9_flit_out_all),
		.flit_in_wr_all(R9_flit_in_wr_all),
		.flit_out_wr_all(R9_flit_out_wr_all),
		.congestion_in_all(R9_congestion_in_all),
		.congestion_out_all(R9_congestion_out_all),
		.credit_out_all(R9_credit_out_all),
		.credit_in_all(R9_credit_in_all)
	);

		assign R9_clk = clk;
		assign R9_reset = reset;
		assign R9_current_r_addr = 13;
		assign R9_neighbors_r_addr=0;
//Connect R9 port 0 to  T13 port 0
		assign  R9_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T13_flit_in ;
		assign  R9_flit_in_wr_all [0] = T13_flit_in_wr ;
		assign  R9_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T13_credit_out = R9_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R9 port 1 to  R11 port 3
		assign  R9_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R11_flit_out_all [(4*Fw)-1 :	 3*Fw ];
		assign  R9_flit_in_wr_all [1] = R11_flit_out_wr_all [3];
		assign  R9_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R11_congestion_out_all [(4*CONGw)-1 :	 3*CONGw ];
		assign  R11_credit_in_all [(4*V)-1 :	 3*V ]= R9_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R9 port 2 to  R4 port 1
		assign  R9_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R4_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R9_flit_in_wr_all [2] = R4_flit_out_wr_all [1];
		assign  R9_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R4_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R4_credit_in_all [(2*V)-1 :	 1*V ]= R9_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R9 port 3 to  R6 port 1
		assign  R9_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R6_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R9_flit_in_wr_all [3] = R6_flit_out_wr_all [1];
		assign  R9_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R6_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R6_credit_in_all [(2*V)-1 :	 1*V ]= R9_credit_out_all [(4*V)-1 : 		 3*V ];
//Connect R9 port 4 to  R10 port 2
		assign  R9_flit_in_all [(5*Fw)-1 : 		 4*Fw ] = R10_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R9_flit_in_wr_all [4] = R10_flit_out_wr_all [2];
		assign  R9_congestion_in_all [(5*CONGw)-1 : 		 4*CONGw ] = R10_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R10_credit_in_all [(3*V)-1 :	 2*V ]= R9_credit_out_all [(5*V)-1 : 		 4*V ];
	
	/*******************
	*		R10
	*******************/
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
	R10
	(	
		.clk(R10_clk), 
		.reset(R10_reset),
		.current_r_addr(R10_current_r_addr),
		.neighbors_r_addr(R10_neighbors_r_addr),
		.flit_in_all(R10_flit_in_all),
		.flit_out_all(R10_flit_out_all),
		.flit_in_wr_all(R10_flit_in_wr_all),
		.flit_out_wr_all(R10_flit_out_wr_all),
		.congestion_in_all(R10_congestion_in_all),
		.congestion_out_all(R10_congestion_out_all),
		.credit_out_all(R10_credit_out_all),
		.credit_in_all(R10_credit_in_all)
	);

		assign R10_clk = clk;
		assign R10_reset = reset;
		assign R10_current_r_addr = 14;
		assign R10_neighbors_r_addr=0;
//Connect R10 port 0 to  T14 port 0
		assign  R10_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T14_flit_in ;
		assign  R10_flit_in_wr_all [0] = T14_flit_in_wr ;
		assign  R10_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T14_credit_out = R10_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R10 port 1 to  R11 port 2
		assign  R10_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R11_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R10_flit_in_wr_all [1] = R11_flit_out_wr_all [2];
		assign  R10_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R11_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R11_credit_in_all [(3*V)-1 :	 2*V ]= R10_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R10 port 2 to  R9 port 4
		assign  R10_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R9_flit_out_all [(5*Fw)-1 :	 4*Fw ];
		assign  R10_flit_in_wr_all [2] = R9_flit_out_wr_all [4];
		assign  R10_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R9_congestion_out_all [(5*CONGw)-1 :	 4*CONGw ];
		assign  R9_credit_in_all [(5*V)-1 :	 4*V ]= R10_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R10 port 3 to  R12 port 2
		assign  R10_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R12_flit_out_all [(3*Fw)-1 :	 2*Fw ];
		assign  R10_flit_in_wr_all [3] = R12_flit_out_wr_all [2];
		assign  R10_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R12_congestion_out_all [(3*CONGw)-1 :	 2*CONGw ];
		assign  R12_credit_in_all [(3*V)-1 :	 2*V ]= R10_credit_out_all [(4*V)-1 : 		 3*V ];
//Connect R10 port 4 to  R15 port 1
		assign  R10_flit_in_all [(5*Fw)-1 : 		 4*Fw ] = R15_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R10_flit_in_wr_all [4] = R15_flit_out_wr_all [1];
		assign  R10_congestion_in_all [(5*CONGw)-1 : 		 4*CONGw ] = R15_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R15_credit_in_all [(2*V)-1 :	 1*V ]= R10_credit_out_all [(5*V)-1 : 		 4*V ];
	
	/*******************
	*		R11
	*******************/
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
	R11
	(	
		.clk(R11_clk), 
		.reset(R11_reset),
		.current_r_addr(R11_current_r_addr),
		.neighbors_r_addr(R11_neighbors_r_addr),
		.flit_in_all(R11_flit_in_all),
		.flit_out_all(R11_flit_out_all),
		.flit_in_wr_all(R11_flit_in_wr_all),
		.flit_out_wr_all(R11_flit_out_wr_all),
		.congestion_in_all(R11_congestion_in_all),
		.congestion_out_all(R11_congestion_out_all),
		.credit_out_all(R11_credit_out_all),
		.credit_in_all(R11_credit_in_all)
	);

		assign R11_clk = clk;
		assign R11_reset = reset;
		assign R11_current_r_addr = 15;
		assign R11_neighbors_r_addr=0;
//Connect R11 port 0 to  T15 port 0
		assign  R11_flit_in_all [(1*Fw)-1 : 		 0*Fw ] = T15_flit_in ;
		assign  R11_flit_in_wr_all [0] = T15_flit_in_wr ;
		assign  R11_congestion_in_all [(1*CONGw)-1 : 		 0*CONGw ] = 0;
		assign  T15_credit_out = R11_credit_out_all [(1*V)-1 : 		 0*V ];
//Connect R11 port 1 to  R8 port 1
		assign  R11_flit_in_all [(2*Fw)-1 : 		 1*Fw ] = R8_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R11_flit_in_wr_all [1] = R8_flit_out_wr_all [1];
		assign  R11_congestion_in_all [(2*CONGw)-1 : 		 1*CONGw ] = R8_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R8_credit_in_all [(2*V)-1 :	 1*V ]= R11_credit_out_all [(2*V)-1 : 		 1*V ];
//Connect R11 port 2 to  R10 port 1
		assign  R11_flit_in_all [(3*Fw)-1 : 		 2*Fw ] = R10_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R11_flit_in_wr_all [2] = R10_flit_out_wr_all [1];
		assign  R11_congestion_in_all [(3*CONGw)-1 : 		 2*CONGw ] = R10_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R10_credit_in_all [(2*V)-1 :	 1*V ]= R11_credit_out_all [(3*V)-1 : 		 2*V ];
//Connect R11 port 3 to  R9 port 1
		assign  R11_flit_in_all [(4*Fw)-1 : 		 3*Fw ] = R9_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R11_flit_in_wr_all [3] = R9_flit_out_wr_all [1];
		assign  R11_congestion_in_all [(4*CONGw)-1 : 		 3*CONGw ] = R9_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R9_credit_in_all [(2*V)-1 :	 1*V ]= R11_credit_out_all [(4*V)-1 : 		 3*V ];
//Connect R11 port 4 to  R5 port 1
		assign  R11_flit_in_all [(5*Fw)-1 : 		 4*Fw ] = R5_flit_out_all [(2*Fw)-1 :	 1*Fw ];
		assign  R11_flit_in_wr_all [4] = R5_flit_out_wr_all [1];
		assign  R11_congestion_in_all [(5*CONGw)-1 : 		 4*CONGw ] = R5_congestion_out_all [(2*CONGw)-1 :	 1*CONGw ];
		assign  R5_credit_in_all [(2*V)-1 :	 1*V ]= R11_credit_out_all [(5*V)-1 : 		 4*V ];

    
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
//Connect T6 output ports 0 to  R6 input ports 0
		assign  T6_flit_out [Fw-1 : 		 0 ] = R6_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T6_flit_out_wr   = R6_flit_out_wr_all [0];
		assign  R6_credit_in_all [(1*V)-1 :	 0*V ]= T6_credit_in [V-1 : 		 0 ];
//Connect T7 output ports 0 to  R7 input ports 0
		assign  T7_flit_out [Fw-1 : 		 0 ] = R7_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T7_flit_out_wr   = R7_flit_out_wr_all [0];
		assign  R7_credit_in_all [(1*V)-1 :	 0*V ]= T7_credit_in [V-1 : 		 0 ];
//Connect T8 output ports 0 to  R12 input ports 0
		assign  T8_flit_out [Fw-1 : 		 0 ] = R12_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T8_flit_out_wr   = R12_flit_out_wr_all [0];
		assign  R12_credit_in_all [(1*V)-1 :	 0*V ]= T8_credit_in [V-1 : 		 0 ];
//Connect T9 output ports 0 to  R13 input ports 0
		assign  T9_flit_out [Fw-1 : 		 0 ] = R13_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T9_flit_out_wr   = R13_flit_out_wr_all [0];
		assign  R13_credit_in_all [(1*V)-1 :	 0*V ]= T9_credit_in [V-1 : 		 0 ];
//Connect T10 output ports 0 to  R14 input ports 0
		assign  T10_flit_out [Fw-1 : 		 0 ] = R14_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T10_flit_out_wr   = R14_flit_out_wr_all [0];
		assign  R14_credit_in_all [(1*V)-1 :	 0*V ]= T10_credit_in [V-1 : 		 0 ];
//Connect T11 output ports 0 to  R15 input ports 0
		assign  T11_flit_out [Fw-1 : 		 0 ] = R15_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T11_flit_out_wr   = R15_flit_out_wr_all [0];
		assign  R15_credit_in_all [(1*V)-1 :	 0*V ]= T11_credit_in [V-1 : 		 0 ];
//Connect T12 output ports 0 to  R8 input ports 0
		assign  T12_flit_out [Fw-1 : 		 0 ] = R8_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T12_flit_out_wr   = R8_flit_out_wr_all [0];
		assign  R8_credit_in_all [(1*V)-1 :	 0*V ]= T12_credit_in [V-1 : 		 0 ];
//Connect T13 output ports 0 to  R9 input ports 0
		assign  T13_flit_out [Fw-1 : 		 0 ] = R9_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T13_flit_out_wr   = R9_flit_out_wr_all [0];
		assign  R9_credit_in_all [(1*V)-1 :	 0*V ]= T13_credit_in [V-1 : 		 0 ];
//Connect T14 output ports 0 to  R10 input ports 0
		assign  T14_flit_out [Fw-1 : 		 0 ] = R10_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T14_flit_out_wr   = R10_flit_out_wr_all [0];
		assign  R10_credit_in_all [(1*V)-1 :	 0*V ]= T14_credit_in [V-1 : 		 0 ];
//Connect T15 output ports 0 to  R11 input ports 0
		assign  T15_flit_out [Fw-1 : 		 0 ] = R11_flit_out_all [(1*Fw)-1 :	 0*Fw ];
		assign  T15_flit_out_wr   = R11_flit_out_wr_all [0];
		assign  R11_credit_in_all [(1*V)-1 :	 0*V ]= T15_credit_in [V-1 : 		 0 ];

             
endmodule
