
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/l/l_noc.v
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

module   l_noc #(  
    	parameter TOPOLOGY = "l",
	parameter ROUTE_NAME = "l_DETERMINISTIC",
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
	clk
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
        Fw = 2+V+Fpay; //flit width;    
       
      

    
    input reset,clk;    
       
    
    
    
    
    
             
endmodule
