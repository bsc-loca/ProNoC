`include "pronoc_def.v"

/**************************************
 * Module: router_bypass
 * Date:2021-11-14  
 * Author: alireza     
 *
 * Description: 
 *   This file contains HDL modules that can be added
 *   to NoC router to provide multicasting
 ***************************************/
 

module multicast_dst_sel 
		import pronoc_pkg::*;
(
	destport_in,
	destport_out	
);

    input  [DSTPw-1 : 0] destport_in;
    output [DSTPw-1 : 0] destport_out; 
    
    generate 
    /* verilator lint_off WIDTH */ 
    if(TOPOLOGY == "MESH" || TOPOLOGY == "TORUS" || TOPOLOGY == "FMESH"  ) begin : mesh
    /* verilator lint_on WIDTH */ 
    	mesh_torus_multicast_dst_sel sel    			
    	(
    		.destport_in(destport_in),
    		.destport_out(destport_out)    
    	);
    /* verilator lint_off WIDTH */ 
    end else if(TOPOLOGY == "RING" || TOPOLOGY == "LINE") begin : ring
    /* verilator lint_on WIDTH */ 		
    	ring_line_multicast_dst_sel sel
    	(
    		.destport_in(destport_in),
    		.destport_out(destport_out)    
    	);
  
    end else begin : other 
    	
    	fattree_multicast_dst_sel #(
    		.DSTPw(DSTPw)
    	)
    	sel
    	(
    		.destport_in(destport_in),
    		.destport_out(destport_out)    
    	);   	
    	
    	
    end
    endgenerate
    
endmodule



/************************************

     look_ahead_routing

 *************************************/

module multicast_routing
	import pronoc_pkg::*;
	#(
		parameter P = 5,
		parameter SW_LOC = 0		
	)
	(
		current_r_addr,  //current router  address
		dest_e_addr,  // destination endpoint address		
		destport		
	);
     
	
	
		
   
	
	input   [RAw-1   :   0]  current_r_addr;
	input   [DAw-1   :   0]  dest_e_addr;
	output  reg [DSTPw-1  :   0] destport;

    
	genvar i,j;
	generate 
	/* verilator lint_off WIDTH */ 
	if(TOPOLOGY == "MESH" )begin :mesh_torus
	/* verilator lint_on WIDTH */ 
     
		localparam
			NX = T1,
			NY = T2,
			RXw = log2(NX),   
			RYw = log2(NY),  
			EXw = RXw,
			EYw = RYw;
        
			wire   [RXw-1   :   0]  current_rx;
			wire   [RYw-1   :   0]  current_ry;                  
			
        
			
         
			mesh_tori_router_addr_decode #(
					.TOPOLOGY(TOPOLOGY),
					.T1(T1),
					.T2(T2),
					.T3(T3),
					.RAw(RAw)
			)
			router_addr_decode
			(
				.r_addr(current_r_addr),
				.rx(current_rx),
				.ry(current_ry),
				.valid( )
			);
			
			
		
			wire [NX-1 : 0] row_has_any_dest;
			wire [NE-1 : 0] dest_mcast_all_endp;			
			
			mcast_dest_list_decode decode (
				.dest_e_addr(dest_e_addr),
				.dest_o(dest_mcast_all_endp),
				.row_has_any_dest(row_has_any_dest)
			);
			
					
			
			//mask gen. x_plus: all rows larger than current router x address are asserted.
			wire [NX-1 : 0] x_plus,x_minus;
			for(i=0; i< NX; i=i+1) begin : X_
				assign x_plus[i]  = (current_rx	>	i);
				/* verilator lint_off UNSIGNED */
				assign x_minus[i] = (current_rx	<	i);
				/* verilator lint_on UNSIGNED */
			end
			
			
			
			
			//mask generation. Only the corresponding bits to destination located in current column are asserted in each mask 	
			wire [NE-1 : 0] y_plus,y_min;
			//Only one-bit is asserted for each local_p[i]
			wire [NE-1 : 0] local_p [NL-1 : 0];
			//get all endp addresses located in the same x
			for(i=0; i< NE; i=i+1) begin : endpoints
			//Endpoint decoded address
				/* verilator lint_off WIDTH */
				localparam 
					
					YY = ((i/NL) / NX ), 
					XX = ((i/NL) % NX ), 
					LL = (i % NL);
					
					/* verilator lint_off CMPCONST */
					assign y_plus[i]  = (current_rx	==	XX) && (current_ry >  YY);
					/* verilator lint_off CMPCONST */
					
					/* verilator lint_off UNSIGNED */
					assign y_min[i]   = (current_rx	==	XX) && (current_ry <  YY);
					/* verilator lint_on UNSIGNED */
					for(j=0;j<NL;j++)begin : lp
						assign local_p[j][i] = (current_rx	==	XX) && (current_ry == YY) && (LL == j);
					end						
			end
			
			
			
			
			
			wire goto_north = |(y_plus  & dest_mcast_all_endp);
			wire goto_south = |(y_min   & dest_mcast_all_endp);
			wire goto_east  = |(x_minus & row_has_any_dest);
			wire goto_west  = |(x_plus  & row_has_any_dest);
			
			
			wire [NL-1 : 0] goto_local;
			for(i=0; i< NL; i=i+1) begin : endps
				assign goto_local[i] = |(local_p[i] & dest_mcast_all_endp);// will be synthesized as single bit assign
			end//for
			
			
			
			integer k;
			
			always @(*) begin 
				destport = {DSTPw{1'b0}};
				for(k=0;k<NL;k++) begin
					if(k==LOCAL )begin 
						destport[LOCAL]=goto_local[LOCAL];
					end else begin 
						destport[SOUTH+K]=goto_local[k];
					end
				end
				if     (SW_LOC == SOUTH) destport [NORTH] = goto_north;
				else if(SW_LOC == NORTH) destport [SOUTH] = goto_south;
				else if(SW_LOC == WEST)begin 
					destport [NORTH] = goto_north;
					destport [SOUTH] = goto_south;
					destport [EAST ] = goto_east;					
				end
				else if(SW_LOC == EAST) begin 
					destport [NORTH] = goto_north;
					destport [SOUTH] = goto_south;
					destport [WEST ] = goto_west;					
				end
				else if(SW_LOC == LOCAL) begin
					destport [NORTH] = goto_north;
					destport [SOUTH] = goto_south;
					destport [EAST]  = goto_east;
					destport [WEST]  = goto_west;
				end							
			end

	end
	endgenerate
endmodule



module mcast_dest_list_decode
		import pronoc_pkg::*;
		(
		dest_e_addr,
		dest_o,
		row_has_any_dest
		);
	
	
	input  [DAw-1 :0]  dest_e_addr;
	output [NE-1 : 0]  dest_o;
	output [NX-1 : 0] row_has_any_dest;
	wire [MCASTw-1 : 0] mcast_dst_coded;
	
	assign {row_has_any_dest,mcast_dst_coded}=dest_e_addr;
		
	genvar i;
	generate
	if(CAST_TYPE == "MULTICAST_FULL") begin : full
		assign dest_o = mcast_dst_coded;		
	end else begin : partial
		for(i=0; i< NE; i=i+1) begin : endpoints
			localparam MCAST_ID = endp_id_to_mcast_id(i);
			assign dest_o [i] = (MCAST_ENDP_LIST[i]==1'b1)? mcast_dst_coded[MCAST_ID] : 1'b0;				
		end
	end
	endgenerate		
	
	
endmodule




module multicast_chan_in_process 		
		import pronoc_pkg::*;
	#(
		parameter P = 5,
		parameter SW_LOC = 0			
		
	)
	(
		current_r_addr,
		chan_in,
		chan_out
	);
	
	input   [RAw-1   :   0]  current_r_addr;
	input   flit_chanel_t chan_in;
	output  flit_chanel_t chan_out;
	
	
	wire  [MCASTw-1   :   0]  mcast_dst_coded;
	wire  [NE-1 : 0] dest_mcast_all_endp;
	wire [NX-1 : 0] row_has_any_dest,row_has_any_dest_in;	
	
	hdr_flit_t hdr_flit;
	header_flit_info extract(
			.flit(chan_in.flit),
			.hdr_flit(hdr_flit),		
			.data_o()
		);
	
	mcast_dest_list_decode decoder
	(
		.dest_e_addr(hdr_flit.dest_e_addr),
		.dest_o(dest_mcast_all_endp),
		.row_has_any_dest(row_has_any_dest_in)
	);
	
	
	assign mcast_dst_coded = hdr_flit.dest_e_addr[MCASTw-1:0];
	
	
	genvar i;
	generate 
	if(TOPOLOGY == "MESH") begin : mesh
		if(SW_LOC == LOCAL || SW_LOC > SOUTH) begin :endp
				
			wire [NE/NX-1   :   0] endp_mask [NX-1 : 0];		
			for(i=0; i< NE; i=i+1) begin : endpoints
				//Endpoint decoded address
				/* verilator lint_off WIDTH */
				localparam 
					MCAST_ID = endp_id_to_mcast_id(i),
					YY = ((i/NL) / NX ), 
					XX = ((i/NL) % NX ), 
					LL = (i % NL),
					PP = YY*NL + LL;
				assign endp_mask [XX] [PP] = dest_mcast_all_endp [i];			
			end
				
			for(i=0;i<NX; i++) begin : X_
				assign row_has_any_dest[i] =| endp_mask[i];			
			end		
		end else begin : no_endp
			assign  row_has_any_dest = 	 row_has_any_dest_in;		
		end
			
			
		
		wire [DAw-1 : 0] dest_e_addr = {row_has_any_dest,mcast_dst_coded};
		wire  [DSTPw-1  :   0] destport;
		
		multicast_routing
		#(
			.P(P) ,
			.SW_LOC(SW_LOC)		
		)
		routing
		(
			.current_r_addr(current_r_addr),  //current router  address
			.dest_e_addr(dest_e_addr),  // destination endpoint address		
			.destport(destport)		
		);
		
		
		always @(*) begin 
			chan_out=chan_in;
			if(chan_in.flit.hdr_flag == 1'b1) begin
				chan_out.flit [E_DST_MSB : E_DST_LSB] = dest_e_addr;
				chan_out.flit [DST_P_MSB : DST_P_LSB] = destport;		
			end
		end	
		
	end
	endgenerate
endmodule


