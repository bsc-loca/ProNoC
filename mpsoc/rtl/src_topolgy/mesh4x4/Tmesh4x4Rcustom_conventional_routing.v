
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/git/hca_git/ProNoC/mpsoc/rtl/src_topolgy/mesh4x4/Tmesh4x4Rcustom_conventional_routing.v
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
module Tmesh4x4Rcustom_conventional_routing  #(
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
		case(src_e_addr) //source address of each individual NI is fixed. So this CASE will be optimized by the synthesizer for each endpoint. 
		0: begin
			case(dest_e_addr)
			1,2,3,5,6,7,11,13,14: begin 
				destport= 1; 
			end
			4,8,9,10,12,15: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//0
		1: begin
			case(dest_e_addr)
			2,3,6,7,10,11,14,15: begin 
				destport= 1; 
			end
			0: begin 
				destport= 3; 
			end
			4,5,8,9,12,13: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//1
		2: begin
			case(dest_e_addr)
			3: begin 
				destport= 1; 
			end
			0,1,4,5,8,12,13: begin 
				destport= 3; 
			end
			6,7,9,10,11,14,15: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//2
		3: begin
			case(dest_e_addr)
			0,1,2,4,5,8,10,12,13,14: begin 
				destport= 3; 
			end
			6,7,9,11,15: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//3
		4: begin
			case(dest_e_addr)
			1,2,3,5,6,7,9,10,11,13,14,15: begin 
				destport= 1; 
			end
			0: begin 
				destport= 2; 
			end
			8,12: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//4
		5: begin
			case(dest_e_addr)
			2,3,6,7,15: begin 
				destport= 1; 
			end
			0,1: begin 
				destport= 2; 
			end
			4,8,12: begin 
				destport= 3; 
			end
			9,10,11,13,14: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//5
		6: begin
			case(dest_e_addr)
			7,15: begin 
				destport= 1; 
			end
			2,3: begin 
				destport= 2; 
			end
			0,1,4,5,13: begin 
				destport= 3; 
			end
			8,9,10,11,12,14: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//6
		7: begin
			case(dest_e_addr)
			3: begin 
				destport= 2; 
			end
			0,1,2,4,5,6,8,9,10,12,13,14: begin 
				destport= 3; 
			end
			11,15: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//7
		8: begin
			case(dest_e_addr)
			2,3,6,9,10,11,13,14,15: begin 
				destport= 1; 
			end
			0,1,4,5,7: begin 
				destport= 2; 
			end
			12: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//8
		9: begin
			case(dest_e_addr)
			10,11,14,15: begin 
				destport= 1; 
			end
			0,1,2,3,4,5,6,7: begin 
				destport= 2; 
			end
			8,12: begin 
				destport= 3; 
			end
			13: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//9
		10: begin
			case(dest_e_addr)
			11,15: begin 
				destport= 1; 
			end
			0,1,2,3,4,5,6,7,13: begin 
				destport= 2; 
			end
			8,9,12: begin 
				destport= 3; 
			end
			14: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//10
		11: begin
			case(dest_e_addr)
			3,5,6,7,13: begin 
				destport= 2; 
			end
			0,1,2,4,8,9,10,12,14: begin 
				destport= 3; 
			end
			15: begin 
				destport= 4; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//11
		12: begin
			case(dest_e_addr)
			1,2,3,5,6,7,9,10,11,13,14,15: begin 
				destport= 1; 
			end
			0,4,8: begin 
				destport= 2; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//12
		13: begin
			case(dest_e_addr)
			2,3,6,7,10,11,14,15: begin 
				destport= 1; 
			end
			1,5,9: begin 
				destport= 2; 
			end
			0,4,8,12: begin 
				destport= 3; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//13
		14: begin
			case(dest_e_addr)
			3,7,11,15: begin 
				destport= 1; 
			end
			2,6,10: begin 
				destport= 2; 
			end
			0,1,4,5,8,9,12,13: begin 
				destport= 3; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//14
		15: begin
			case(dest_e_addr)
			3,7,11: begin 
				destport= 2; 
			end
			0,1,2,4,5,6,8,9,10,12,13,14: begin 
				destport= 3; 
			end

			default: begin 
				destport= {DSTPw{1'bX}};
			end
			endcase
		end//15

		default: begin 
			destport= {DSTPw{1'bX}};
		end
		endcase
	end

		
	
endmodule  
    
