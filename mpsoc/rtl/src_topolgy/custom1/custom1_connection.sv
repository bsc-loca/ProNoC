
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/git/hca_git/ProNoC/mpsoc/rtl/src_topolgy/custom1/custom1_connection.sv
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

module  custom1_connection 
	import pronoc_pkg::*; 
(
    	reset,
	clk,
	start_i,
	start_o,
	er_addr, 
	current_r_addr,
	chan_in_all,
	chan_out_all, 
	router_chan_in,
	router_chan_out  

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
        CONG_ALw = CONGw * P,
        PRAw = P * RAw;    
    	
		
       
      

    

	input reset;
	input clk;
	input start_i;
	output [RAw-1 : 0] er_addr [NE-1 : 0]; // provide router address for each connected endpoint 
	output [RAw-1 : 0] current_r_addr [NR-1 : 0]; // provide each router current address  ;
	output [NE-1 : 0] start_o;
	output router_channel_t chan_in_all [NE-1 : 0];
	input  router_channel_t chan_out_all [NE-1 : 0]; 
	input  router_channel_t    router_chan_in   [NR-1 :0][MAX_P-1 : 0];
	output router_channel_t    router_chan_out  [NR-1 :0][MAX_P-1 : 0];






   

//Connect R0 input ports 0 to  T0 output ports 0
		assign  chan_in_all [0] = router_chan_in [0][0];
		assign  router_chan_out [0][0] = chan_out_all [0];
//Connect R0 input ports 1 to  R14 output ports 3
		assign  router_chan_out [10][3] = router_chan_in [0][1];
//Connect R0 input ports 2 to  R13 output ports 3
		assign  router_chan_out [9][3] = router_chan_in [0][2];
//Connect R1 input ports 0 to  T1 output ports 0
		assign  chan_in_all [1] = router_chan_in [1][0];
		assign  router_chan_out [1][0] = chan_out_all [1];
//Connect R1 input ports 1 to  R7 output ports 3
		assign  router_chan_out [7][3] = router_chan_in [1][1];
//Connect R1 input ports 2 to  R2 output ports 2
		assign  router_chan_out [2][2] = router_chan_in [1][2];
//Connect R2 input ports 0 to  T2 output ports 0
		assign  chan_in_all [2] = router_chan_in [2][0];
		assign  router_chan_out [2][0] = chan_out_all [2];
//Connect R2 input ports 1 to  R15 output ports 2
		assign  router_chan_out [11][2] = router_chan_in [2][1];
//Connect R2 input ports 2 to  R1 output ports 2
		assign  router_chan_out [1][2] = router_chan_in [2][2];
//Connect R3 input ports 0 to  T3 output ports 0
		assign  chan_in_all [3] = router_chan_in [3][0];
		assign  router_chan_out [3][0] = chan_out_all [3];
//Connect R3 input ports 1 to  R15 output ports 3
		assign  router_chan_out [11][3] = router_chan_in [3][1];
//Connect R3 input ports 2 to  R4 output ports 2
		assign  router_chan_out [4][2] = router_chan_in [3][2];
//Connect R4 input ports 0 to  T4 output ports 0
		assign  chan_in_all [4] = router_chan_in [4][0];
		assign  router_chan_out [4][0] = chan_out_all [4];
//Connect R4 input ports 1 to  R9 output ports 2
		assign  router_chan_out [13][2] = router_chan_in [4][1];
//Connect R4 input ports 2 to  R3 output ports 2
		assign  router_chan_out [3][2] = router_chan_in [4][2];
//Connect R4 input ports 3 to  R6 output ports 3
		assign  router_chan_out [6][3] = router_chan_in [4][3];
//Connect R5 input ports 0 to  T5 output ports 0
		assign  chan_in_all [5] = router_chan_in [5][0];
		assign  router_chan_out [5][0] = chan_out_all [5];
//Connect R5 input ports 1 to  R11 output ports 4
		assign  router_chan_out [15][4] = router_chan_in [5][1];
//Connect R5 input ports 2 to  R6 output ports 2
		assign  router_chan_out [6][2] = router_chan_in [5][2];
//Connect R5 input ports 3 to  R13 output ports 2
		assign  router_chan_out [9][2] = router_chan_in [5][3];
//Connect R6 input ports 0 to  T6 output ports 0
		assign  chan_in_all [6] = router_chan_in [6][0];
		assign  router_chan_out [6][0] = chan_out_all [6];
//Connect R6 input ports 1 to  R9 output ports 3
		assign  router_chan_out [13][3] = router_chan_in [6][1];
//Connect R6 input ports 2 to  R5 output ports 2
		assign  router_chan_out [5][2] = router_chan_in [6][2];
//Connect R6 input ports 3 to  R4 output ports 3
		assign  router_chan_out [4][3] = router_chan_in [6][3];
//Connect R7 input ports 0 to  T7 output ports 0
		assign  chan_in_all [7] = router_chan_in [7][0];
		assign  router_chan_out [7][0] = chan_out_all [7];
//Connect R7 input ports 1 to  R12 output ports 3
		assign  router_chan_out [8][3] = router_chan_in [7][1];
//Connect R7 input ports 2 to  R14 output ports 2
		assign  router_chan_out [10][2] = router_chan_in [7][2];
//Connect R7 input ports 3 to  R1 output ports 1
		assign  router_chan_out [1][1] = router_chan_in [7][3];
//Connect R12 input ports 0 to  T8 output ports 0
		assign  chan_in_all [8] = router_chan_in [8][0];
		assign  router_chan_out [8][0] = chan_out_all [8];
//Connect R12 input ports 1 to  R8 output ports 4
		assign  router_chan_out [12][4] = router_chan_in [8][1];
//Connect R12 input ports 2 to  R10 output ports 3
		assign  router_chan_out [14][3] = router_chan_in [8][2];
//Connect R12 input ports 3 to  R7 output ports 1
		assign  router_chan_out [7][1] = router_chan_in [8][3];
//Connect R13 input ports 0 to  T9 output ports 0
		assign  chan_in_all [9] = router_chan_in [9][0];
		assign  router_chan_out [9][0] = chan_out_all [9];
//Connect R13 input ports 1 to  R8 output ports 2
		assign  router_chan_out [12][2] = router_chan_in [9][1];
//Connect R13 input ports 2 to  R5 output ports 3
		assign  router_chan_out [5][3] = router_chan_in [9][2];
//Connect R13 input ports 3 to  R0 output ports 2
		assign  router_chan_out [0][2] = router_chan_in [9][3];
//Connect R14 input ports 0 to  T10 output ports 0
		assign  chan_in_all [10] = router_chan_in [10][0];
		assign  router_chan_out [10][0] = chan_out_all [10];
//Connect R14 input ports 1 to  R8 output ports 3
		assign  router_chan_out [12][3] = router_chan_in [10][1];
//Connect R14 input ports 2 to  R7 output ports 2
		assign  router_chan_out [7][2] = router_chan_in [10][2];
//Connect R14 input ports 3 to  R0 output ports 1
		assign  router_chan_out [0][1] = router_chan_in [10][3];
//Connect R15 input ports 0 to  T11 output ports 0
		assign  chan_in_all [11] = router_chan_in [11][0];
		assign  router_chan_out [11][0] = chan_out_all [11];
//Connect R15 input ports 1 to  R10 output ports 4
		assign  router_chan_out [14][4] = router_chan_in [11][1];
//Connect R15 input ports 2 to  R2 output ports 1
		assign  router_chan_out [2][1] = router_chan_in [11][2];
//Connect R15 input ports 3 to  R3 output ports 1
		assign  router_chan_out [3][1] = router_chan_in [11][3];
//Connect R8 input ports 0 to  T12 output ports 0
		assign  chan_in_all [12] = router_chan_in [12][0];
		assign  router_chan_out [12][0] = chan_out_all [12];
//Connect R8 input ports 1 to  R11 output ports 1
		assign  router_chan_out [15][1] = router_chan_in [12][1];
//Connect R8 input ports 2 to  R13 output ports 1
		assign  router_chan_out [9][1] = router_chan_in [12][2];
//Connect R8 input ports 3 to  R14 output ports 1
		assign  router_chan_out [10][1] = router_chan_in [12][3];
//Connect R8 input ports 4 to  R12 output ports 1
		assign  router_chan_out [8][1] = router_chan_in [12][4];
//Connect R9 input ports 0 to  T13 output ports 0
		assign  chan_in_all [13] = router_chan_in [13][0];
		assign  router_chan_out [13][0] = chan_out_all [13];
//Connect R9 input ports 1 to  R11 output ports 3
		assign  router_chan_out [15][3] = router_chan_in [13][1];
//Connect R9 input ports 2 to  R4 output ports 1
		assign  router_chan_out [4][1] = router_chan_in [13][2];
//Connect R9 input ports 3 to  R6 output ports 1
		assign  router_chan_out [6][1] = router_chan_in [13][3];
//Connect R9 input ports 4 to  R10 output ports 2
		assign  router_chan_out [14][2] = router_chan_in [13][4];
//Connect R10 input ports 0 to  T14 output ports 0
		assign  chan_in_all [14] = router_chan_in [14][0];
		assign  router_chan_out [14][0] = chan_out_all [14];
//Connect R10 input ports 1 to  R11 output ports 2
		assign  router_chan_out [15][2] = router_chan_in [14][1];
//Connect R10 input ports 2 to  R9 output ports 4
		assign  router_chan_out [13][4] = router_chan_in [14][2];
//Connect R10 input ports 3 to  R12 output ports 2
		assign  router_chan_out [8][2] = router_chan_in [14][3];
//Connect R10 input ports 4 to  R15 output ports 1
		assign  router_chan_out [11][1] = router_chan_in [14][4];
//Connect R11 input ports 0 to  T15 output ports 0
		assign  chan_in_all [15] = router_chan_in [15][0];
		assign  router_chan_out [15][0] = chan_out_all [15];
//Connect R11 input ports 1 to  R8 output ports 1
		assign  router_chan_out [12][1] = router_chan_in [15][1];
//Connect R11 input ports 2 to  R10 output ports 1
		assign  router_chan_out [14][1] = router_chan_in [15][2];
//Connect R11 input ports 3 to  R9 output ports 1
		assign  router_chan_out [13][1] = router_chan_in [15][3];
//Connect R11 input ports 4 to  R5 output ports 1
		assign  router_chan_out [5][1] = router_chan_in [15][4];

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
