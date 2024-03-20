
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: noc_localparam.v
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

 
    `include "chi_noc_def.v"
    import `CHI_PCKG::*;
 
	localparam 
	   TOPOLOGY = `NOC_TOPOLOGY,
	   ROUTE_NAME = "XY",
	   T1= (TOPOLOGY == "STAR")? `NUM_PORTS : $clog2(`NUM_PORTS),
	   T2=`NUM_PORTS /$clog2(`NUM_PORTS),
	   T3= 1,
	   B= 15;

//NoC parameters
	localparam DEBUG_EN=0;
	localparam V=1;
	localparam LB=B;
	
	localparam PCK_TYPE="SINGLE_FLIT";
	localparam MIN_PCK_SIZE=1;
	localparam BYTE_EN=0;
	localparam SSA_EN="NO";
	localparam SMART_MAX=0;
	localparam CONGESTION_INDEX=3;
	localparam ESCAP_VC_MASK=1;
	localparam VC_REALLOCATION_TYPE="NONATOMIC";
	localparam COMBINATION_TYPE="COMB_NONSPEC";
	localparam MUX_TYPE="BINARY";
	localparam C=1;
	localparam ADD_PIPREG_AFTER_CROSSBAR=1'b0;
	localparam FIRST_ARBITER_EXT_P_EN=1;
	localparam SWA_ARBITER_TYPE="RRA";
	localparam WEIGHTw=4;
	localparam SELF_LOOP_EN="NO";
	localparam AVC_ATOMIC_EN=0;
	localparam CVw=(C==0)? V : C * V;
	localparam CLASS_SETTING={CVw{1'b1}};
    localparam CAST_TYPE = "UNICAST";
	localparam MCAST_ENDP_LIST = 'b11110011;	
	

	
	//simulation parameter	
	//localparam MAX_RATIO = 1000;
	localparam MAX_PCK_NUM = 1000000000;
	localparam MAX_PCK_SIZ = 16383; 
	localparam MAX_SIM_CLKs=  1000000000;
	localparam TIMSTMP_FIFO_NUM = 16;	
	
    localparam Fpay =
        (NOC_ID ==`REQ_CHI)? $bits(`REQ_FLIT_T) :
        (NOC_ID ==`DAT_CHI)? $bits(`DAT_FLIT_T) :
        (NOC_ID ==`RSP_CHI)? $bits(`RSP_FLIT_T) :       
	    (NOC_ID ==`SNP_CHI)? $bits(`SNP_FLIT_T) : 32; 


 

