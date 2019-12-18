
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/test/TtestRtest_ni_conventional_routing.v
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
module TtestRtest_ni_conventional_routing  #(
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
		0: begin
			case(dest_e_addr)
			1,2,7,8: begin 
				destport= 1; 
			end
			3,4,5,6: begin 
				destport= 4; 
			end
			endcase
		end//0
		1: begin
			case(dest_e_addr)
			2,3,6,8: begin 
				destport= 1; 
			end
			0: begin 
				destport= 3; 
			end
			4,5,7: begin 
				destport= 4; 
			end
			endcase
		end//1
		2: begin
			case(dest_e_addr)
			0,3,4: begin 
				destport= 1; 
			end
			1: begin 
				destport= 3; 
			end
			5,6,7,8: begin 
				destport= 4; 
			end
			endcase
		end//2
		3: begin
			case(dest_e_addr)
			4,5: begin 
				destport= 1; 
			end
			0: begin 
				destport= 2; 
			end
			1,2: begin 
				destport= 3; 
			end
			6,7,8: begin 
				destport= 4; 
			end
			endcase
		end//3
		4: begin
			case(dest_e_addr)
			5,6: begin 
				destport= 1; 
			end
			0,1: begin 
				destport= 2; 
			end
			2,3: begin 
				destport= 3; 
			end
			7,8: begin 
				destport= 4; 
			end
			endcase
		end//4
		5: begin
			case(dest_e_addr)
			6,7: begin 
				destport= 1; 
			end
			0,1,2: begin 
				destport= 2; 
			end
			3,4: begin 
				destport= 3; 
			end
			8: begin 
				destport= 4; 
			end
			endcase
		end//5
		6: begin
			case(dest_e_addr)
			7: begin 
				destport= 1; 
			end
			0,2,3: begin 
				destport= 2; 
			end
			1,4,5,8: begin 
				destport= 3; 
			end
			endcase
		end//6
		7: begin
			case(dest_e_addr)
			8: begin 
				destport= 1; 
			end
			1,2,3,4: begin 
				destport= 2; 
			end
			0,5,6: begin 
				destport= 3; 
			end
			endcase
		end//7
		8: begin
			case(dest_e_addr)
			0,1,2,5: begin 
				destport= 2; 
			end
			3,4,6,7: begin 
				destport= 3; 
			end
			endcase
		end//8
		endcase
	end

		
	
endmodule  
    
