
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/muli/TmuliRtest_ni_conventional_routing_genvar.v
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
module TmuliRtest_ni_conventional_routing_genvar  #(
	parameter RAw = 3,  
	parameter EAw = 3,   
	parameter DSTPw=4,
	parameter SRC_E_ADDR=0  
)
(
	dest_e_addr,
	destport        
);
    
	input   [EAw-1   :0] dest_e_addr;
	output reg [DSTPw-1 :0] destport;	
        
    
	generate

	if(SRC_E_ADDR == 0) begin : SRC0
		always@(*)begin	
			destport= 0; 
			case(dest_e_addr)
			1,2,3,4,5: begin 
				destport= 1; 
			end
			endcase
		end
	end//SRC0

	if(SRC_E_ADDR == 1) begin : SRC1
		always@(*)begin	
			destport= 0; 
			case(dest_e_addr)
			0,2,3,4,5: begin 
				destport= 1; 
			end
			endcase
		end
	end//SRC1

	if(SRC_E_ADDR == 2) begin : SRC2
		always@(*)begin	
			destport= 0; 
			case(dest_e_addr)
			0,1,3,4,5: begin 
				destport= 1; 
			end
			endcase
		end
	end//SRC2

	if(SRC_E_ADDR == 3) begin : SRC3
		always@(*)begin	
			destport= 0; 
			case(dest_e_addr)
			0: begin 
				destport= 1; 
			end
			1,2,4,5: begin 
				destport= 2; 
			end
			endcase
		end
	end//SRC3

	if(SRC_E_ADDR == 4) begin : SRC4
		always@(*)begin	
			destport= 0; 
			case(dest_e_addr)
			1,2,5: begin 
				destport= 1; 
			end
			0,3: begin 
				destport= 2; 
			end
			endcase
		end
	end//SRC4

	if(SRC_E_ADDR == 5) begin : SRC5
		always@(*)begin	
			destport= 0; 
			case(dest_e_addr)
			0,3,4: begin 
				destport= 1; 
			end
			1: begin 
				destport= 2; 
			end
			2: begin 
				destport= 3; 
			end
			endcase
		end
	end//SRC5

	endgenerate

		
	
endmodule  
    
