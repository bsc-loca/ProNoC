// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on


/**********************************************************************
**    File:  noc_top.sv
**    
**    Copyright (C) 2014-2017  Alireza Monemi
**    
**    This file is part of ProNoC 
**
**    ProNoC ( stands for Prototype Network-on-chip)  is free software: 
**    you can redistribute it and/or modify it under the terms of the GNU
**    Lesser General Public License as published by the Free Software Foundation,
**    either version 2 of the License, or (at your option) any later version.
**
**     ProNoC is distributed in the hope that it will be useful, but WITHOUT
**     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
**     or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
**     Public License for more details.
**
**     You should have received a copy of the GNU Lesser General Public
**     License along with ProNoC. If not, see <http:**www.gnu.org/licenses/>.
**
**
**    Description: 
**    the NoC top module. 
**
**************************************************************/
module  noc_top 
	import pronoc_pkg::*; 
(
	reset,
	clk,    
	chan_in_all,
	chan_out_all  
);
  
  	
	input   clk,reset;
	//local ports 
	input   router_channel_t chan_in_all  [NE-1 : 0];
	output  router_channel_t chan_out_all [NE-1 : 0];

 
   


	generate 
	if (TOPOLOGY ==    "MESH" || TOPOLOGY ==  "TORUS" || TOPOLOGY == "RING" || TOPOLOGY == "LINE") begin : tori_noc 

		mesh_torus_noc_top noc_top (
			.reset         (reset        ), 
			.clk           (clk          ), 
			.chan_in_all   (chan_in_all  ), 
			.chan_out_all  (chan_out_all )
		);
	
    
    end else if (TOPOLOGY == "FATTREE") begin : fat_
    
        fattree_noc_top noc_top (
        		.reset         (reset        ), 
        		.clk           (clk          ), 
        		.chan_in_all   (chan_in_all  ), 
        		.chan_out_all  (chan_out_all )
        );
        
        
    end else if (TOPOLOGY == "TREE") begin : tree_
        tree_noc_top  noc_top ( 
        	.reset         (reset        ), 
        	.clk           (clk          ), 
        	.chan_in_all   (chan_in_all  ), 
        	.chan_out_all  (chan_out_all )
        );
    
    end else begin :custom_

	custom_noc_top noc_top ( 
			.reset         (reset        ), 
			.clk           (clk          ), 
			.chan_in_all   (chan_in_all  ), 
			.chan_out_all  (chan_out_all )
		);

    end     
    endgenerate
endmodule

