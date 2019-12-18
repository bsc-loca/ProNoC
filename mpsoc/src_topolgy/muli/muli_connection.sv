
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/muli/muli_connection.sv
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

module   muli_connection (
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
		NE = 6,
		NR = 6,
		RAw=log2(NR),
		MAX_P=4;
	
	
	
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
//Connect R0 input ports 1 to  R3 output ports 1
		assign  router_flit_out_all [3][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [0][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [3][1] = router_flit_in_wr_all [0][1];
		assign  router_congestion_out_all [3][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [0][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [0][(2*V)-1 :	 1*V ] = router_credit_in_all [3][(2*V)-1 :	 1*V ];
//Connect R1 input ports 0 to  T1 output ports 0
		assign  ni_flit_out [1] = router_flit_in_all [1][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [1] = router_flit_in_wr_all [1][0];
		assign  router_credit_out_all [1][(1*V)-1 :	 0*V ] = ni_credit_in [1];
//Connect R1 input ports 1 to  R5 output ports 2
		assign  router_flit_out_all [5][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [1][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [5][2] = router_flit_in_wr_all [1][1];
		assign  router_congestion_out_all [5][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [1][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [1][(2*V)-1 :	 1*V ] = router_credit_in_all [5][(3*V)-1 :	 2*V ];
//Connect R2 input ports 0 to  T2 output ports 0
		assign  ni_flit_out [2] = router_flit_in_all [2][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [2] = router_flit_in_wr_all [2][0];
		assign  router_credit_out_all [2][(1*V)-1 :	 0*V ] = ni_credit_in [2];
//Connect R2 input ports 1 to  R5 output ports 3
		assign  router_flit_out_all [5][(4*Fw)-1 :	 3*Fw ] = router_flit_in_all [2][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [5][3] = router_flit_in_wr_all [2][1];
		assign  router_congestion_out_all [5][(4*CONGw)-1 :	 3*CONGw ] = router_congestion_in_all [2][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [2][(2*V)-1 :	 1*V ] = router_credit_in_all [5][(4*V)-1 :	 3*V ];
//Connect R3 input ports 0 to  T3 output ports 0
		assign  ni_flit_out [3] = router_flit_in_all [3][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [3] = router_flit_in_wr_all [3][0];
		assign  router_credit_out_all [3][(1*V)-1 :	 0*V ] = ni_credit_in [3];
//Connect R3 input ports 1 to  R0 output ports 1
		assign  router_flit_out_all [0][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [3][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [0][1] = router_flit_in_wr_all [3][1];
		assign  router_congestion_out_all [0][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [3][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [3][(2*V)-1 :	 1*V ] = router_credit_in_all [0][(2*V)-1 :	 1*V ];
//Connect R3 input ports 2 to  R4 output ports 2
		assign  router_flit_out_all [4][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [3][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [4][2] = router_flit_in_wr_all [3][2];
		assign  router_congestion_out_all [4][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [3][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [3][(3*V)-1 :	 2*V ] = router_credit_in_all [4][(3*V)-1 :	 2*V ];
//Connect R4 input ports 0 to  T4 output ports 0
		assign  ni_flit_out [4] = router_flit_in_all [4][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [4] = router_flit_in_wr_all [4][0];
		assign  router_credit_out_all [4][(1*V)-1 :	 0*V ] = ni_credit_in [4];
//Connect R4 input ports 1 to  R5 output ports 1
		assign  router_flit_out_all [5][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [4][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [5][1] = router_flit_in_wr_all [4][1];
		assign  router_congestion_out_all [5][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [4][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [4][(2*V)-1 :	 1*V ] = router_credit_in_all [5][(2*V)-1 :	 1*V ];
//Connect R4 input ports 2 to  R3 output ports 2
		assign  router_flit_out_all [3][(3*Fw)-1 :	 2*Fw ] = router_flit_in_all [4][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [3][2] = router_flit_in_wr_all [4][2];
		assign  router_congestion_out_all [3][(3*CONGw)-1 :	 2*CONGw ] = router_congestion_in_all [4][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [4][(3*V)-1 :	 2*V ] = router_credit_in_all [3][(3*V)-1 :	 2*V ];
//Connect R5 input ports 0 to  T5 output ports 0
		assign  ni_flit_out [5] = router_flit_in_all [5][(1*Fw)-1 :	 0*Fw ];
		assign  ni_flit_out_wr [5] = router_flit_in_wr_all [5][0];
		assign  router_credit_out_all [5][(1*V)-1 :	 0*V ] = ni_credit_in [5];
//Connect R5 input ports 1 to  R4 output ports 1
		assign  router_flit_out_all [4][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [5][(2*Fw)-1 :	 1*Fw ];
		assign  router_flit_out_wr_all [4][1] = router_flit_in_wr_all [5][1];
		assign  router_congestion_out_all [4][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [5][(2*CONGw)-1 :	 1*CONGw ];
		assign  router_credit_out_all [5][(2*V)-1 :	 1*V ] = router_credit_in_all [4][(2*V)-1 :	 1*V ];
//Connect R5 input ports 2 to  R1 output ports 1
		assign  router_flit_out_all [1][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [5][(3*Fw)-1 :	 2*Fw ];
		assign  router_flit_out_wr_all [1][1] = router_flit_in_wr_all [5][2];
		assign  router_congestion_out_all [1][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [5][(3*CONGw)-1 :	 2*CONGw ];
		assign  router_credit_out_all [5][(3*V)-1 :	 2*V ] = router_credit_in_all [1][(2*V)-1 :	 1*V ];
//Connect R5 input ports 3 to  R2 output ports 1
		assign  router_flit_out_all [2][(2*Fw)-1 :	 1*Fw ] = router_flit_in_all [5][(4*Fw)-1 :	 3*Fw ];
		assign  router_flit_out_wr_all [2][1] = router_flit_in_wr_all [5][3];
		assign  router_congestion_out_all [2][(2*CONGw)-1 :	 1*CONGw ] = router_congestion_in_all [5][(4*CONGw)-1 :	 3*CONGw ];
		assign  router_credit_out_all [5][(4*V)-1 :	 3*V ] = router_credit_in_all [2][(2*V)-1 :	 1*V ];
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

	assign er_addr [0] = 0;
	assign er_addr [1] = 1;
	assign er_addr [2] = 2;
	assign er_addr [3] = 3;
	assign er_addr [4] = 4;
	assign er_addr [5] = 5;

	assign current_r_addr [0] = 0;
	assign current_r_addr [1] = 1;
	assign current_r_addr [2] = 2;
	assign current_r_addr [3] = 3;
	assign current_r_addr [4] = 4;
	assign current_r_addr [5] = 5;
   


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
