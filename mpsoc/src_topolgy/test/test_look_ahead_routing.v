
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/test/test_look_ahead_routing.v
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

/*******************
*  test_look_ahead_routing
*******************/  
module test_look_ahead_routing  #(
	parameter RAw = 3,  
	parameter EAw = 3,   
	parameter DSTPw=4  
)
(
	reset,
	clk,
	current_r_addr,
	dest_e_addr,
	src_e_addr,
	destport        
);
    
	input   [RAw-1   :0] current_r_addr;
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

	test_look_ahead_routing_comb  #(
		.RAw(RAw),  
		.EAw(EAw),   
		.DSTPw(DSTPw)  
	)
	lkp_cmb
	(
		.current_r_addr(current_r_addr),
		.dest_e_addr(dest_e_addr_delay),
		.src_e_addr(src_e_addr_delay),
		.destport(destport)        
	);


	
endmodule  
 
/*******************
*  test_look_ahead_routing_comb
*******************/ 
  
 module test_look_ahead_routing_comb  #(
	parameter RAw = 3,  
	parameter EAw = 3,   
	parameter DSTPw=4  
)
(
	current_r_addr,
	dest_e_addr,
	src_e_addr,
	destport        
);
    
	input   [RAw-1   :0] current_r_addr;
	input   [EAw-1   :0] dest_e_addr;
	input   [EAw-1   :0] src_e_addr;
	output reg [DSTPw-1 :0] destport;	

localparam [EAw-1 : 0]	E0=0;
localparam [EAw-1 : 0]	E1=1;
localparam [EAw-1 : 0]	E2=2;
localparam [EAw-1 : 0]	E3=3;
localparam [EAw-1 : 0]	E4=4;
localparam [EAw-1 : 0]	E5=5;
localparam [EAw-1 : 0]	E6=6;
localparam [EAw-1 : 0]	E7=7;
localparam [EAw-1 : 0]	E8=8;

        
	always@(*)begin
		destport=0;
		case(current_r_addr) //current_r_addr of each individual router is fixed. So this CASE will be optimized by the sybthesizer for each router. 
		0: begin
			case({src_e_addr,dest_e_addr})
			{E0,E1},{E0,E3}: begin 
				destport= 0; 
			end
			{E0,E2},{E0,E4},{E0,E5}: begin 
				destport= 1; 
			end
			{E0,E6},{E0,E7},{E0,E8}: begin 
				destport= 4; 
			end
			endcase
		end//0
		1: begin
			case({src_e_addr,dest_e_addr})
			{E0,E2},{E1,E0},{E1,E2},{E1,E4},{E4,E0},{E5,E0},{E8,E0}: begin 
				destport= 0; 
			end
			{E1,E3},{E1,E5},{E1,E6}: begin 
				destport= 1; 
			end
			{E0,E7},{E0,E8},{E1,E7},{E1,E8}: begin 
				destport= 4; 
			end
			endcase
		end//1
		2: begin
			case({src_e_addr,dest_e_addr})
			{E1,E3},{E2,E1},{E2,E3},{E2,E5},{E3,E1},{E5,E1}: begin 
				destport= 0; 
			end
			{E2,E4},{E2,E6},{E2,E7}: begin 
				destport= 1; 
			end
			{E2,E0}: begin 
				destport= 2; 
			end
			{E5,E0},{E8,E0}: begin 
				destport= 3; 
			end
			{E1,E6},{E1,E8},{E2,E8}: begin 
				destport= 4; 
			end
			endcase
		end//2
		3: begin
			case({src_e_addr,dest_e_addr})
			{E0,E4},{E0,E6},{E1,E6},{E2,E0},{E2,E4},{E3,E0},{E3,E2},{E3,E4},{E3,E6},{E4,E2},{E6,E0},{E6,E2},{E7,E0},{E7,E2}: begin 
				destport= 0; 
			end
			{E0,E5},{E3,E5},{E3,E7},{E3,E8}: begin 
				destport= 1; 
			end
			{E3,E1}: begin 
				destport= 3; 
			end
			endcase
		end//3
		4: begin
			case({src_e_addr,dest_e_addr})
			{E0,E5},{E0,E7},{E1,E5},{E1,E7},{E3,E5},{E4,E1},{E4,E3},{E4,E5},{E4,E7},{E5,E3},{E6,E1},{E7,E1},{E7,E3},{E8,E1}: begin 
				destport= 0; 
			end
			{E0,E8},{E4,E6},{E4,E8}: begin 
				destport= 1; 
			end
			{E4,E0},{E4,E2},{E7,E2}: begin 
				destport= 3; 
			end
			endcase
		end//4
		5: begin
			case({src_e_addr,dest_e_addr})
			{E1,E8},{E2,E6},{E2,E8},{E4,E6},{E5,E2},{E5,E4},{E5,E6},{E5,E8},{E6,E4},{E6,E8},{E8,E2}: begin 
				destport= 0; 
			end
			{E2,E7},{E5,E7}: begin 
				destport= 1; 
			end
			{E6,E1},{E8,E1}: begin 
				destport= 2; 
			end
			{E5,E0},{E5,E1},{E5,E3},{E8,E0}: begin 
				destport= 3; 
			end
			endcase
		end//5
		6: begin
			case({src_e_addr,dest_e_addr})
			{E2,E7},{E3,E7},{E5,E7},{E6,E3},{E6,E5},{E6,E7},{E7,E5},{E8,E3}: begin 
				destport= 0; 
			end
			{E3,E8}: begin 
				destport= 1; 
			end
			{E6,E0},{E7,E0}: begin 
				destport= 2; 
			end
			{E6,E1},{E6,E2},{E6,E4}: begin 
				destport= 3; 
			end
			{E6,E8}: begin 
				destport= 4; 
			end
			endcase
		end//6
		7: begin
			case({src_e_addr,dest_e_addr})
			{E0,E8},{E3,E8},{E4,E8},{E7,E4},{E7,E6},{E7,E8},{E8,E4},{E8,E6}: begin 
				destport= 0; 
			end
			{E7,E0},{E7,E1},{E8,E3}: begin 
				destport= 2; 
			end
			{E7,E2},{E7,E3},{E7,E5}: begin 
				destport= 3; 
			end
			endcase
		end//7
		8: begin
			case({src_e_addr,dest_e_addr})
			{E8,E5},{E8,E7}: begin 
				destport= 0; 
			end
			{E8,E0},{E8,E2},{E8,E4}: begin 
				destport= 2; 
			end
			{E8,E1},{E8,E3},{E8,E6}: begin 
				destport= 3; 
			end
			endcase
		end//8
		endcase
	end
  

	
endmodule  


