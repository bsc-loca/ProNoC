
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/l/TlRl_look_ahead_routing_genvar.v
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

/*****************************
*	TlRl_look_ahead_routing_genvar
******************************/ 
module TlRl_look_ahead_routing_genvar  #(
	parameter RAw = 3,  
	parameter EAw = 3,   
	parameter DSTPw=4,
	parameter CURRENT_R_ADDR=0
)
(
	dest_e_addr,
	src_e_addr,
	destport,
	reset,
	clk        
);

	input   [EAw-1   :0] dest_e_addr;
	input   [EAw-1   :0] src_e_addr;
	output  [DSTPw-1 :0] destport;
	input reset,clk;

	reg [EAw-1   :0] dest_e_addr_delay;
	reg [EAw-1   :0] src_e_addr_delay;

	always @(posedge clk)begin 
		if(reset)begin 
			dest_e_addr_delay<={EAw{1'b0}};
			src_e_addr_delay<={EAw{1'b0}};			
		end else begin 
			dest_e_addr_delay<=dest_e_addr;
			src_e_addr_delay<=src_e_addr;					
		end 	
	end

	l_look_ahead_routing_genvar_comb  #(
		.RAw(RAw),  
		.EAw(EAw),   
		.DSTPw(DSTPw),
		.CURRENT_R_ADDR(CURRENT_R_ADDR)  
	)
	lkp_cmb
	(
		
		.dest_e_addr(dest_e_addr_delay),
		.src_e_addr(src_e_addr_delay),
		.destport(destport)        
	);


	
endmodule   
 
/*******************
* TlRl_look_ahead_routing_genvar_comb
********************/ 
  
 
 module TlRl_look_ahead_routing_genvar_comb  #(
	parameter RAw = 3,  
	parameter EAw = 3,   
	parameter DSTPw=4,
	parameter CURRENT_R_ADDR=0
)
(
	dest_e_addr,
	src_e_addr,
	destport        
);

	input   [EAw-1   :0] dest_e_addr;
	input   [EAw-1   :0] src_e_addr;
	output  reg [DSTPw-1 :0] destport;


        
	generate
	endgenerate
  

	
endmodule  


