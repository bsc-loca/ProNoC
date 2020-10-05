
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/git/hca_git/ProNoC/mpsoc/src_topolgy/test/test_connection.sv
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

module   test_connection (
    	reset,
	clk,
	start_i,
	start_o,
	er_addr, 
	current_r_addr,
	router_flit_in_all,
	router_flit_out_all,
	ni_flit_in,
	ni_flit_out,
	router_flit_in_wr_all,
	router_flit_out_wr_all,
	ni_flit_in_wr,
	ni_flit_out_wr,
	router_congestion_in_all,
	router_congestion_out_all,
	router_credit_out_all,
	router_credit_in_all,
	ni_credit_out,
	ni_credit_in
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
	
	
	
	`define  INCLUDE_PARAM
    `include"parameter.v"          
                      
    
    

    localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;
	
	
	
	
	localparam
		P= MAX_P,
        PV = V * P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = P * Fw,
        CONG_ALw = CONGw * P,
        PRAw = P * RAw;    
    	
		
       
      

    

	input reset;
	input clk;
	input start_i;
	output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint 
	output [RAw-1 : 0] current_r_addr [NR-1 : 0]; // provide each router current address  ;
	output [NE-1 : 0] start_o;
	input	[Fw-1 : 0] ni_flit_in [NE-1 : 0];
	output	[Fw-1 : 0] ni_flit_out [NE-1 : 0];
	input	 [PFw-1 : 0] router_flit_in_all [NR-1 :0];
	output	 [PFw-1 : 0] router_flit_out_all [NR-1 :0];
	input	[NE-1 : 0] ni_flit_in_wr ;
	output	[NE-1 : 0] ni_flit_out_wr ;
	input	 [P-1 : 0] router_flit_in_wr_all [NR-1 :0];
	output	 [P-1 : 0] router_flit_out_wr_all [NR-1 :0];
	input	 [CONG_ALw-1 : 0] router_congestion_in_all [NR-1 :0];
	output	 [CONG_ALw-1 : 0] router_congestion_out_all [NR-1 :0];
	output	[V-1 : 0] ni_credit_out [NE-1 : 0];
	input	[V-1 : 0] ni_credit_in [NE-1 : 0];
	output	 [PV-1 : 0] router_credit_out_all [NR-1 :0];
	input	 [PV-1 : 0] router_credit_in_all [NR-1 :0];





   

//Connect R0 input ports 0 to  T0 output ports 0
		assign  ni_flit_out [0] = router_flit_in_all [0][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [0] = router_flit_in_wr_all [0][0];
		assign  router_credit_out_all [0][(1*V)-1 :	 0*V ] = ni_credit_in [0];
//Connect R0 input ports 1 to  R9 output ports 2
		assign  router_flit_out_all [9][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [0][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [9][2] = router_flit_in_wr_all [0][1];
		assign  router_congestion_out_all [9][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [0][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [0][(2*V)-1 :	 1*V ] = router_credit_in_all [9][(3*V)-1 :	 2*V ];
//Connect R0 input ports 2 to  R11 output ports 3
		assign  router_flit_out_all [11][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [0][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [11][3] = router_flit_in_wr_all [0][2];
		assign  router_congestion_out_all [11][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [0][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [0][(3*V)-1 :	 2*V ] = router_credit_in_all [11][(4*V)-1 :	 3*V ];
//Connect R1 input ports 0 to  T1 output ports 0
		assign  ni_flit_out [1] = router_flit_in_all [1][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [1] = router_flit_in_wr_all [1][0];
		assign  router_credit_out_all [1][(1*V)-1 :	 0*V ] = ni_credit_in [1];
//Connect R1 input ports 1 to  R14 output ports 4
		assign  router_flit_out_all [14][(5*Fw)-1 :	 4*Fw ] = router_flit_in_all [1][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [14][4] = router_flit_in_wr_all [1][1];
		assign  router_congestion_out_all [14][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_in_all [1][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [1][(2*V)-1 :	 1*V ] = router_credit_in_all [14][(5*V)-1 :	 4*V ];
//Connect R1 input ports 2 to  R9 output ports 3
		assign  router_flit_out_all [9][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [1][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [9][3] = router_flit_in_wr_all [1][2];
		assign  router_congestion_out_all [9][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [1][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [1][(3*V)-1 :	 2*V ] = router_credit_in_all [9][(4*V)-1 :	 3*V ];
//Connect R2 input ports 0 to  T2 output ports 0
		assign  ni_flit_out [2] = router_flit_in_all [2][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [2] = router_flit_in_wr_all [2][0];
		assign  router_credit_out_all [2][(1*V)-1 :	 0*V ] = ni_credit_in [2];
//Connect R2 input ports 1 to  R10 output ports 3
		assign  router_flit_out_all [10][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [2][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [10][3] = router_flit_in_wr_all [2][1];
		assign  router_congestion_out_all [10][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [2][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [2][(2*V)-1 :	 1*V ] = router_credit_in_all [10][(4*V)-1 :	 3*V ];
//Connect R2 input ports 2 to  R3 output ports 2
		assign  router_flit_out_all [3][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [2][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [3][2] = router_flit_in_wr_all [2][2];
		assign  router_congestion_out_all [3][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [2][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [2][(3*V)-1 :	 2*V ] = router_credit_in_all [3][(3*V)-1 :	 2*V ];
//Connect R3 input ports 0 to  T3 output ports 0
		assign  ni_flit_out [3] = router_flit_in_all [3][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [3] = router_flit_in_wr_all [3][0];
		assign  router_credit_out_all [3][(1*V)-1 :	 0*V ] = ni_credit_in [3];
//Connect R3 input ports 1 to  R10 output ports 1
		assign  router_flit_out_all [10][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [3][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [10][1] = router_flit_in_wr_all [3][1];
		assign  router_congestion_out_all [10][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [3][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [3][(2*V)-1 :	 1*V ] = router_credit_in_all [10][(2*V)-1 :	 1*V ];
//Connect R3 input ports 2 to  R2 output ports 2
		assign  router_flit_out_all [2][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [3][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [2][2] = router_flit_in_wr_all [3][2];
		assign  router_congestion_out_all [2][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [3][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [3][(3*V)-1 :	 2*V ] = router_credit_in_all [2][(3*V)-1 :	 2*V ];
//Connect R4 input ports 0 to  T4 output ports 0
		assign  ni_flit_out [4] = router_flit_in_all [4][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [4] = router_flit_in_wr_all [4][0];
		assign  router_credit_out_all [4][(1*V)-1 :	 0*V ] = ni_credit_in [4];
//Connect R4 input ports 1 to  R10 output ports 2
		assign  router_flit_out_all [10][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [4][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [10][2] = router_flit_in_wr_all [4][1];
		assign  router_congestion_out_all [10][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [4][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [4][(2*V)-1 :	 1*V ] = router_credit_in_all [10][(3*V)-1 :	 2*V ];
//Connect R4 input ports 2 to  R11 output ports 2
		assign  router_flit_out_all [11][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [4][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [11][2] = router_flit_in_wr_all [4][2];
		assign  router_congestion_out_all [11][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [4][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [4][(3*V)-1 :	 2*V ] = router_credit_in_all [11][(3*V)-1 :	 2*V ];
//Connect R4 input ports 3 to  R8 output ports 3
		assign  router_flit_out_all [8][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [4][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [8][3] = router_flit_in_wr_all [4][3];
		assign  router_congestion_out_all [8][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [4][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [4][(4*V)-1 :	 3*V ] = router_credit_in_all [8][(4*V)-1 :	 3*V ];
//Connect R5 input ports 0 to  T5 output ports 0
		assign  ni_flit_out [5] = router_flit_in_all [5][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [5] = router_flit_in_wr_all [5][0];
		assign  router_credit_out_all [5][(1*V)-1 :	 0*V ] = ni_credit_in [5];
//Connect R5 input ports 1 to  R12 output ports 2
		assign  router_flit_out_all [12][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [5][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [12][2] = router_flit_in_wr_all [5][1];
		assign  router_congestion_out_all [12][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [5][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [5][(2*V)-1 :	 1*V ] = router_credit_in_all [12][(3*V)-1 :	 2*V ];
//Connect R5 input ports 2 to  R7 output ports 2
		assign  router_flit_out_all [7][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [5][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [7][2] = router_flit_in_wr_all [5][2];
		assign  router_congestion_out_all [7][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [5][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [5][(3*V)-1 :	 2*V ] = router_credit_in_all [7][(3*V)-1 :	 2*V ];
//Connect R5 input ports 3 to  R6 output ports 3
		assign  router_flit_out_all [6][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [5][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [6][3] = router_flit_in_wr_all [5][3];
		assign  router_congestion_out_all [6][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [5][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [5][(4*V)-1 :	 3*V ] = router_credit_in_all [6][(4*V)-1 :	 3*V ];
//Connect R6 input ports 0 to  T6 output ports 0
		assign  ni_flit_out [6] = router_flit_in_all [6][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [6] = router_flit_in_wr_all [6][0];
		assign  router_credit_out_all [6][(1*V)-1 :	 0*V ] = ni_credit_in [6];
//Connect R6 input ports 1 to  R12 output ports 3
		assign  router_flit_out_all [12][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [6][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [12][3] = router_flit_in_wr_all [6][1];
		assign  router_congestion_out_all [12][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [6][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [6][(2*V)-1 :	 1*V ] = router_credit_in_all [12][(4*V)-1 :	 3*V ];
//Connect R6 input ports 2 to  R14 output ports 2
		assign  router_flit_out_all [14][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [6][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [14][2] = router_flit_in_wr_all [6][2];
		assign  router_congestion_out_all [14][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [6][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [6][(3*V)-1 :	 2*V ] = router_credit_in_all [14][(3*V)-1 :	 2*V ];
//Connect R6 input ports 3 to  R5 output ports 3
		assign  router_flit_out_all [5][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [6][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [5][3] = router_flit_in_wr_all [6][3];
		assign  router_congestion_out_all [5][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [6][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [6][(4*V)-1 :	 3*V ] = router_credit_in_all [5][(4*V)-1 :	 3*V ];
//Connect R7 input ports 0 to  T7 output ports 0
		assign  ni_flit_out [7] = router_flit_in_all [7][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [7] = router_flit_in_wr_all [7][0];
		assign  router_credit_out_all [7][(1*V)-1 :	 0*V ] = ni_credit_in [7];
//Connect R7 input ports 1 to  R13 output ports 4
		assign  router_flit_out_all [13][(5*Fw)-1 :	 4*Fw ] = router_flit_in_all [7][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [13][4] = router_flit_in_wr_all [7][1];
		assign  router_congestion_out_all [13][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_in_all [7][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [7][(2*V)-1 :	 1*V ] = router_credit_in_all [13][(5*V)-1 :	 4*V ];
//Connect R7 input ports 2 to  R5 output ports 2
		assign  router_flit_out_all [5][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [7][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [5][2] = router_flit_in_wr_all [7][2];
		assign  router_congestion_out_all [5][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [7][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [7][(3*V)-1 :	 2*V ] = router_credit_in_all [5][(3*V)-1 :	 2*V ];
//Connect R7 input ports 3 to  R11 output ports 1
		assign  router_flit_out_all [11][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [7][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [11][1] = router_flit_in_wr_all [7][3];
		assign  router_congestion_out_all [11][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [7][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [7][(4*V)-1 :	 3*V ] = router_credit_in_all [11][(2*V)-1 :	 1*V ];
//Connect R8 input ports 0 to  T8 output ports 0
		assign  ni_flit_out [8] = router_flit_in_all [8][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [8] = router_flit_in_wr_all [8][0];
		assign  router_credit_out_all [8][(1*V)-1 :	 0*V ] = ni_credit_in [8];
//Connect R8 input ports 1 to  R14 output ports 3
		assign  router_flit_out_all [14][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [8][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [14][3] = router_flit_in_wr_all [8][1];
		assign  router_congestion_out_all [14][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [8][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [8][(2*V)-1 :	 1*V ] = router_credit_in_all [14][(4*V)-1 :	 3*V ];
//Connect R8 input ports 2 to  R15 output ports 4
		assign  router_flit_out_all [15][(5*Fw)-1 :	 4*Fw ] = router_flit_in_all [8][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [15][4] = router_flit_in_wr_all [8][2];
		assign  router_congestion_out_all [15][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_in_all [8][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [8][(3*V)-1 :	 2*V ] = router_credit_in_all [15][(5*V)-1 :	 4*V ];
//Connect R8 input ports 3 to  R4 output ports 3
		assign  router_flit_out_all [4][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [8][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [4][3] = router_flit_in_wr_all [8][3];
		assign  router_congestion_out_all [4][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [8][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [8][(4*V)-1 :	 3*V ] = router_credit_in_all [4][(4*V)-1 :	 3*V ];
//Connect R9 input ports 0 to  T9 output ports 0
		assign  ni_flit_out [9] = router_flit_in_all [9][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [9] = router_flit_in_wr_all [9][0];
		assign  router_credit_out_all [9][(1*V)-1 :	 0*V ] = ni_credit_in [9];
//Connect R9 input ports 1 to  R15 output ports 3
		assign  router_flit_out_all [15][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [9][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [15][3] = router_flit_in_wr_all [9][1];
		assign  router_congestion_out_all [15][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [9][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [9][(2*V)-1 :	 1*V ] = router_credit_in_all [15][(4*V)-1 :	 3*V ];
//Connect R9 input ports 2 to  R0 output ports 1
		assign  router_flit_out_all [0][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [9][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [0][1] = router_flit_in_wr_all [9][2];
		assign  router_congestion_out_all [0][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [9][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [9][(3*V)-1 :	 2*V ] = router_credit_in_all [0][(2*V)-1 :	 1*V ];
//Connect R9 input ports 3 to  R1 output ports 2
		assign  router_flit_out_all [1][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [9][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [1][2] = router_flit_in_wr_all [9][3];
		assign  router_congestion_out_all [1][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [9][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [9][(4*V)-1 :	 3*V ] = router_credit_in_all [1][(3*V)-1 :	 2*V ];
//Connect R10 input ports 0 to  T10 output ports 0
		assign  ni_flit_out [10] = router_flit_in_all [10][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [10] = router_flit_in_wr_all [10][0];
		assign  router_credit_out_all [10][(1*V)-1 :	 0*V ] = ni_credit_in [10];
//Connect R10 input ports 1 to  R3 output ports 1
		assign  router_flit_out_all [3][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [10][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [3][1] = router_flit_in_wr_all [10][1];
		assign  router_congestion_out_all [3][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [10][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [10][(2*V)-1 :	 1*V ] = router_credit_in_all [3][(2*V)-1 :	 1*V ];
//Connect R10 input ports 2 to  R4 output ports 1
		assign  router_flit_out_all [4][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [10][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [4][1] = router_flit_in_wr_all [10][2];
		assign  router_congestion_out_all [4][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [10][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [10][(3*V)-1 :	 2*V ] = router_credit_in_all [4][(2*V)-1 :	 1*V ];
//Connect R10 input ports 3 to  R2 output ports 1
		assign  router_flit_out_all [2][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [10][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [2][1] = router_flit_in_wr_all [10][3];
		assign  router_congestion_out_all [2][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [10][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [10][(4*V)-1 :	 3*V ] = router_credit_in_all [2][(2*V)-1 :	 1*V ];
//Connect R11 input ports 0 to  T11 output ports 0
		assign  ni_flit_out [11] = router_flit_in_all [11][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [11] = router_flit_in_wr_all [11][0];
		assign  router_credit_out_all [11][(1*V)-1 :	 0*V ] = ni_credit_in [11];
//Connect R11 input ports 1 to  R7 output ports 3
		assign  router_flit_out_all [7][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [11][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [7][3] = router_flit_in_wr_all [11][1];
		assign  router_congestion_out_all [7][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [11][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [11][(2*V)-1 :	 1*V ] = router_credit_in_all [7][(4*V)-1 :	 3*V ];
//Connect R11 input ports 2 to  R4 output ports 2
		assign  router_flit_out_all [4][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [11][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [4][2] = router_flit_in_wr_all [11][2];
		assign  router_congestion_out_all [4][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [11][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [11][(3*V)-1 :	 2*V ] = router_credit_in_all [4][(3*V)-1 :	 2*V ];
//Connect R11 input ports 3 to  R0 output ports 2
		assign  router_flit_out_all [0][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [11][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [0][2] = router_flit_in_wr_all [11][3];
		assign  router_congestion_out_all [0][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [11][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [11][(4*V)-1 :	 3*V ] = router_credit_in_all [0][(3*V)-1 :	 2*V ];
//Connect R12 input ports 0 to  T12 output ports 0
		assign  ni_flit_out [12] = router_flit_in_all [12][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [12] = router_flit_in_wr_all [12][0];
		assign  router_credit_out_all [12][(1*V)-1 :	 0*V ] = ni_credit_in [12];
//Connect R12 input ports 1 to  R13 output ports 1
		assign  router_flit_out_all [13][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [12][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [13][1] = router_flit_in_wr_all [12][1];
		assign  router_congestion_out_all [13][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [12][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [12][(2*V)-1 :	 1*V ] = router_credit_in_all [13][(2*V)-1 :	 1*V ];
//Connect R12 input ports 2 to  R5 output ports 1
		assign  router_flit_out_all [5][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [12][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [5][1] = router_flit_in_wr_all [12][2];
		assign  router_congestion_out_all [5][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [12][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [12][(3*V)-1 :	 2*V ] = router_credit_in_all [5][(2*V)-1 :	 1*V ];
//Connect R12 input ports 3 to  R6 output ports 1
		assign  router_flit_out_all [6][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [12][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [6][1] = router_flit_in_wr_all [12][3];
		assign  router_congestion_out_all [6][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [12][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [12][(4*V)-1 :	 3*V ] = router_credit_in_all [6][(2*V)-1 :	 1*V ];
//Connect R12 input ports 4 to  R15 output ports 2
		assign  router_flit_out_all [15][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [12][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_out_wr_all [15][2] = router_flit_in_wr_all [12][4];
		assign  router_congestion_out_all [15][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [12][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_out_all [12][(5*V)-1 :	 4*V ] = router_credit_in_all [15][(3*V)-1 :	 2*V ];
//Connect R13 input ports 0 to  T13 output ports 0
		assign  ni_flit_out [13] = router_flit_in_all [13][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [13] = router_flit_in_wr_all [13][0];
		assign  router_credit_out_all [13][(1*V)-1 :	 0*V ] = ni_credit_in [13];
//Connect R13 input ports 1 to  R12 output ports 1
		assign  router_flit_out_all [12][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [13][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [12][1] = router_flit_in_wr_all [13][1];
		assign  router_congestion_out_all [12][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [13][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [13][(2*V)-1 :	 1*V ] = router_credit_in_all [12][(2*V)-1 :	 1*V ];
//Connect R13 input ports 2 to  R14 output ports 1
		assign  router_flit_out_all [14][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [13][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [14][1] = router_flit_in_wr_all [13][2];
		assign  router_congestion_out_all [14][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [13][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [13][(3*V)-1 :	 2*V ] = router_credit_in_all [14][(2*V)-1 :	 1*V ];
//Connect R13 input ports 3 to  R15 output ports 1
		assign  router_flit_out_all [15][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [13][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [15][1] = router_flit_in_wr_all [13][3];
		assign  router_congestion_out_all [15][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [13][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [13][(4*V)-1 :	 3*V ] = router_credit_in_all [15][(2*V)-1 :	 1*V ];
//Connect R13 input ports 4 to  R7 output ports 1
		assign  router_flit_out_all [7][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [13][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_out_wr_all [7][1] = router_flit_in_wr_all [13][4];
		assign  router_congestion_out_all [7][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [13][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_out_all [13][(5*V)-1 :	 4*V ] = router_credit_in_all [7][(2*V)-1 :	 1*V ];
//Connect R14 input ports 0 to  T14 output ports 0
		assign  ni_flit_out [14] = router_flit_in_all [14][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [14] = router_flit_in_wr_all [14][0];
		assign  router_credit_out_all [14][(1*V)-1 :	 0*V ] = ni_credit_in [14];
//Connect R14 input ports 1 to  R13 output ports 2
		assign  router_flit_out_all [13][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [14][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [13][2] = router_flit_in_wr_all [14][1];
		assign  router_congestion_out_all [13][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [14][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [14][(2*V)-1 :	 1*V ] = router_credit_in_all [13][(3*V)-1 :	 2*V ];
//Connect R14 input ports 2 to  R6 output ports 2
		assign  router_flit_out_all [6][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [14][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [6][2] = router_flit_in_wr_all [14][2];
		assign  router_congestion_out_all [6][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [14][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [14][(3*V)-1 :	 2*V ] = router_credit_in_all [6][(3*V)-1 :	 2*V ];
//Connect R14 input ports 3 to  R8 output ports 1
		assign  router_flit_out_all [8][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [14][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [8][1] = router_flit_in_wr_all [14][3];
		assign  router_congestion_out_all [8][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [14][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [14][(4*V)-1 :	 3*V ] = router_credit_in_all [8][(2*V)-1 :	 1*V ];
//Connect R14 input ports 4 to  R1 output ports 1
		assign  router_flit_out_all [1][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [14][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_out_wr_all [1][1] = router_flit_in_wr_all [14][4];
		assign  router_congestion_out_all [1][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [14][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_out_all [14][(5*V)-1 :	 4*V ] = router_credit_in_all [1][(2*V)-1 :	 1*V ];
//Connect R15 input ports 0 to  T15 output ports 0
		assign  ni_flit_out [15] = router_flit_in_all [15][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [15] = router_flit_in_wr_all [15][0];
		assign  router_credit_out_all [15][(1*V)-1 :	 0*V ] = ni_credit_in [15];
//Connect R15 input ports 1 to  R13 output ports 3
		assign  router_flit_out_all [13][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [15][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [13][3] = router_flit_in_wr_all [15][1];
		assign  router_congestion_out_all [13][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [15][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [15][(2*V)-1 :	 1*V ] = router_credit_in_all [13][(4*V)-1 :	 3*V ];
//Connect R15 input ports 2 to  R12 output ports 4
		assign  router_flit_out_all [12][(5*Fw)-1 :	 4*Fw ] = router_flit_in_all [15][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [12][4] = router_flit_in_wr_all [15][2];
		assign  router_congestion_out_all [12][(5*CONGw)-1 :	 4*CONGw ] = router_congestion_in_all [15][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [15][(3*V)-1 :	 2*V ] = router_credit_in_all [12][(5*V)-1 :	 4*V ];
//Connect R15 input ports 3 to  R9 output ports 1
		assign  router_flit_out_all [9][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [15][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [9][1] = router_flit_in_wr_all [15][3];
		assign  router_congestion_out_all [9][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [15][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [15][(4*V)-1 :	 3*V ] = router_credit_in_all [9][(2*V)-1 :	 1*V ];
//Connect R15 input ports 4 to  R8 output ports 2
		assign  router_flit_out_all [8][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [15][(5*Fw)-1 :	 4*Fw ];
		assign  router_flit_out_wr_all [8][2] = router_flit_in_wr_all [15][4];
		assign  router_congestion_out_all [8][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [15][(5*CONGw)-1 :	 4*CONGw ];
		assign  router_credit_out_all [15][(5*V)-1 :	 4*V ] = router_credit_in_all [8][(3*V)-1 :	 2*V ];
//Connect T0 input ports 0 to  R0 output ports 0
		assign  router_flit_out_all [0][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [0];
		assign  router_flit_out_wr_all [0][0] = ni_flit_in_wr [0];
		assign  ni_credit_out [0] = router_credit_in_all [0][(1*V)-1 :	 0*V ];
//Connect T1 input ports 0 to  R1 output ports 0
		assign  router_flit_out_all [1][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [1];
		assign  router_flit_out_wr_all [1][0] = ni_flit_in_wr [1];
		assign  ni_credit_out [1] = router_credit_in_all [1][(1*V)-1 :	 0*V ];
//Connect T2 input ports 0 to  R2 output ports 0
		assign  router_flit_out_all [2][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [2];
		assign  router_flit_out_wr_all [2][0] = ni_flit_in_wr [2];
		assign  ni_credit_out [2] = router_credit_in_all [2][(1*V)-1 :	 0*V ];
//Connect T3 input ports 0 to  R3 output ports 0
		assign  router_flit_out_all [3][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [3];
		assign  router_flit_out_wr_all [3][0] = ni_flit_in_wr [3];
		assign  ni_credit_out [3] = router_credit_in_all [3][(1*V)-1 :	 0*V ];
//Connect T4 input ports 0 to  R4 output ports 0
		assign  router_flit_out_all [4][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [4];
		assign  router_flit_out_wr_all [4][0] = ni_flit_in_wr [4];
		assign  ni_credit_out [4] = router_credit_in_all [4][(1*V)-1 :	 0*V ];
//Connect T5 input ports 0 to  R5 output ports 0
		assign  router_flit_out_all [5][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [5];
		assign  router_flit_out_wr_all [5][0] = ni_flit_in_wr [5];
		assign  ni_credit_out [5] = router_credit_in_all [5][(1*V)-1 :	 0*V ];
//Connect T6 input ports 0 to  R6 output ports 0
		assign  router_flit_out_all [6][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [6];
		assign  router_flit_out_wr_all [6][0] = ni_flit_in_wr [6];
		assign  ni_credit_out [6] = router_credit_in_all [6][(1*V)-1 :	 0*V ];
//Connect T7 input ports 0 to  R7 output ports 0
		assign  router_flit_out_all [7][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [7];
		assign  router_flit_out_wr_all [7][0] = ni_flit_in_wr [7];
		assign  ni_credit_out [7] = router_credit_in_all [7][(1*V)-1 :	 0*V ];
//Connect T8 input ports 0 to  R8 output ports 0
		assign  router_flit_out_all [8][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [8];
		assign  router_flit_out_wr_all [8][0] = ni_flit_in_wr [8];
		assign  ni_credit_out [8] = router_credit_in_all [8][(1*V)-1 :	 0*V ];
//Connect T9 input ports 0 to  R9 output ports 0
		assign  router_flit_out_all [9][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [9];
		assign  router_flit_out_wr_all [9][0] = ni_flit_in_wr [9];
		assign  ni_credit_out [9] = router_credit_in_all [9][(1*V)-1 :	 0*V ];
//Connect T10 input ports 0 to  R10 output ports 0
		assign  router_flit_out_all [10][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [10];
		assign  router_flit_out_wr_all [10][0] = ni_flit_in_wr [10];
		assign  ni_credit_out [10] = router_credit_in_all [10][(1*V)-1 :	 0*V ];
//Connect T11 input ports 0 to  R11 output ports 0
		assign  router_flit_out_all [11][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [11];
		assign  router_flit_out_wr_all [11][0] = ni_flit_in_wr [11];
		assign  ni_credit_out [11] = router_credit_in_all [11][(1*V)-1 :	 0*V ];
//Connect T12 input ports 0 to  R12 output ports 0
		assign  router_flit_out_all [12][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [12];
		assign  router_flit_out_wr_all [12][0] = ni_flit_in_wr [12];
		assign  ni_credit_out [12] = router_credit_in_all [12][(1*V)-1 :	 0*V ];
//Connect T13 input ports 0 to  R13 output ports 0
		assign  router_flit_out_all [13][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [13];
		assign  router_flit_out_wr_all [13][0] = ni_flit_in_wr [13];
		assign  ni_credit_out [13] = router_credit_in_all [13][(1*V)-1 :	 0*V ];
//Connect T14 input ports 0 to  R14 output ports 0
		assign  router_flit_out_all [14][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [14];
		assign  router_flit_out_wr_all [14][0] = ni_flit_in_wr [14];
		assign  ni_credit_out [14] = router_credit_in_all [14][(1*V)-1 :	 0*V ];
//Connect T15 input ports 0 to  R15 output ports 0
		assign  router_flit_out_all [15][(1*Fw)-1 :	 0*Fw ] = ni_flit_in [15];
		assign  router_flit_out_wr_all [15][0] = ni_flit_in_wr [15];
		assign  ni_credit_out [15] = router_credit_in_all [15][(1*V)-1 :	 0*V ];

	assign er_addr [0] = 0;
	assign er_addr [1] = 1;
	assign er_addr [2] = 2;
	assign er_addr [3] = 3;
	assign er_addr [4] = 4;
	assign er_addr [5] = 5;
	assign er_addr [6] = 6;
	assign er_addr [7] = 7;
	assign er_addr [8] = 8;
	assign er_addr [9] = 9;
	assign er_addr [10] = 10;
	assign er_addr [11] = 11;
	assign er_addr [12] = 12;
	assign er_addr [13] = 13;
	assign er_addr [14] = 14;
	assign er_addr [15] = 15;

	assign current_r_addr [0] = 0;
	assign current_r_addr [1] = 1;
	assign current_r_addr [2] = 2;
	assign current_r_addr [3] = 3;
	assign current_r_addr [4] = 4;
	assign current_r_addr [5] = 5;
	assign current_r_addr [6] = 6;
	assign current_r_addr [7] = 7;
	assign current_r_addr [8] = 8;
	assign current_r_addr [9] = 9;
	assign current_r_addr [10] = 10;
	assign current_r_addr [11] = 11;
	assign current_r_addr [12] = 12;
	assign current_r_addr [13] = 13;
	assign current_r_addr [14] = 14;
	assign current_r_addr [15] = 15;
   


	start_delay_gen #(
        .NC(NE)
    )
    delay_gen
    (
        .clk(clk),
        .reset(reset),
        .start_i(start_i),
        .start_o(start_o)
    );
 
             
endmodule
