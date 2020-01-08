
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/l/TlRl_ni_conventional_routing.v
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
module TlRl_ni_conventional_routing  #(
	parameter RAw = 3,  
	parameter EAw = 3,   
	parameter DSTPw=4  
)
(
	dest_e_addr,
	src_e_addr,
	destport        
);
    
	input   [EAw-1   :0] dest_e_addr;
	input   [EAw-1   :0] src_e_addr;
	output reg [DSTPw-1 :0] destport;	
        
    
	always@(*)begin
		destport=0;
		case(src_e_addr) //source address of each individual NI is fixed. So this CASE will be optimized by the sybthesizer for each endpoint. 
		endcase
	end

		
	
endmodule  
    
