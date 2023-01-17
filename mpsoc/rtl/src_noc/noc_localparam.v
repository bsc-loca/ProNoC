
/**************************************************************************
**	WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
**	OVERWRITTEN AND LOST. Rename this file if you wish to do any modification.
****************************************************************************/


/**********************************************************************
**	File: noc_localparam.v
**    
**	Copyright (C) 2014-2021  Alireza Monemi
**    
**	This file is part of ProNoC 2.1.0 
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

	
	`ifdef   NOC_LOCAL_PARAM 
 
 
	

//NoC parameters
	parameter TOPOLOGY="MESH";
	parameter T1=4;
	parameter T2=4;
	parameter T3=2;
	parameter V=2;
	parameter B=4;
	parameter LB=7;
	parameter Fpay=32;
	parameter ROUTE_NAME="XY";
	parameter PCK_TYPE="MULTI_FLIT";
	parameter MIN_PCK_SIZE=2;
	parameter BYTE_EN=0;
	parameter CAST_TYPE="UNICAST";
	parameter MCAST_ENDP_LIST=32'hf;
	parameter SSA_EN="NO";
	parameter SMART_MAX=0;
	parameter CONGESTION_INDEX=3;
	parameter ESCAP_VC_MASK=2'b01;
	parameter VC_REALLOCATION_TYPE="NONATOMIC";
	parameter COMBINATION_TYPE="COMB_NONSPEC";
	parameter MUX_TYPE="BINARY";
	parameter C=0;
	parameter DEBUG_EN=0;
	parameter ADD_PIPREG_AFTER_CROSSBAR=1'b0;
	parameter FIRST_ARBITER_EXT_P_EN=1;
	parameter SWA_ARBITER_TYPE="RRA";
	parameter WEIGHTw=4;
	parameter SELF_LOOP_EN="NO";
	parameter AVC_ATOMIC_EN=0;
	parameter CLASS_SETTING={V{1'b1}};
 	parameter  CVw=(C==0)? V : C * V;
  
	
	
	//simulation parameter	
	//localparam MAX_RATIO = 1000;
	localparam MAX_PCK_NUM = 1000000000;
	localparam MAX_PCK_SIZ = 16383; 
	localparam MAX_SIM_CLKs=  1000000000;
	localparam TIMSTMP_FIFO_NUM = 16;	
	
		

 
 `endif