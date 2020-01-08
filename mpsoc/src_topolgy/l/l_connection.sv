
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/l/l_connection.sv
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

module   l_connection (
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
		NE = 0,
		NR = 0,
		RAw=log2(NR),
		MAX_P=0;
	
	
	
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
