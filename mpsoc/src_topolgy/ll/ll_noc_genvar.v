
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: /home/alireza/work/hca_git/ProNoC/mpsoc/src_topolgy/ll/ll_noc_genvar.v
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

module   ll_noc_genvar #(  
    	parameter TOPOLOGY = "ll",
	parameter ROUTE_NAME = "ll_DETERMINISTIC",
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
	clk,
	flit_in_all,
	flit_out_all,
	flit_in_wr_all,
	flit_out_wr_all,
	credit_out_all,
	credit_in_all
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
	
	localparam
		P= MAX_P,
        PV = V * P,
        Fw = 2+V+Fpay, //flit width;    
        PFw = P * Fw,
        CONG_ALw = CONGw * P;
     
    	
		
       
      

    

	input reset;
	input clk;
	input [(NE*Fw)-1 : 0] flit_in_all;
	output [(NE*Fw)-1 : 0] flit_out_all;
	input [NE-1 : 0] flit_in_wr_all;
	output [NE-1 : 0] flit_out_wr_all;
	output [(NE*V)-1 : 0] credit_out_all;
	input [(NE*V)-1 : 0] credit_in_all;


	wire  [PFw-1 : 0] router_flit_in_all [NR-1 :0];
	wire  [PFw-1 : 0] router_flit_out_all [NR-1 :0];
	wire  [P-1 : 0] router_flit_in_wr_all [NR-1 :0];
	wire  [P-1 : 0] router_flit_out_wr_all [NR-1 :0];
	wire  [CONG_ALw-1 : 0] router_congestion_in_all [NR-1 :0];
	wire  [CONG_ALw-1 : 0] router_congestion_out_all [NR-1 :0];
	wire  [PV-1 : 0] router_credit_out_all [NR-1 :0];
	wire  [PV-1 : 0] router_credit_in_all [NR-1 :0];


	wire [Fw-1 : 0] ni_flit_in [NE-1 :0];
	wire [Fw-1 : 0] ni_flit_out [NE-1 :0];
	wire [NE-1 :0] ni_flit_in_wr;
	wire [NE-1 :0] ni_flit_out_wr;
	wire [V-1 : 0] ni_credit_out [NE-1 :0];
	wire [V-1 : 0] ni_credit_in [NE-1 :0];

   

	genvar i;
	generate	
	
	endgenerate


genvar pos;
generate
	for ( pos = 0; pos <  NE; pos=pos+1 ) begin : endpoints
		assign ni_flit_out[pos] = flit_in_all [(pos+1)*Fw-1 : pos*Fw];
		assign  flit_out_all [(pos+1)*Fw-1 : pos*Fw] = ni_flit_in[pos] ;
		assign ni_flit_out_wr[pos] = flit_in_wr_all [pos];
		assign  flit_out_wr_all [pos] = ni_flit_in_wr[pos] ;
		assign credit_out_all [(pos+1)*V-1 : pos*V] = ni_credit_in[pos];
		assign ni_credit_out[pos]=credit_in_all [(pos+1)*V-1 : pos*V];
	end
 endgenerate
   




  
             
endmodule
