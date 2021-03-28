
    
    
/****************************************************************************
 * router_top.v
 ****************************************************************************/
  
/**
 * Module: router_top
 * 
 *  add optional bypass links to two stage router.
 */
module router_top 
		import pronoc_pkg::*;
        
	# (
		parameter P = 5     // router port num         
		)(
			current_r_addr,// connected to constant parameter  
        
			chan_in,
			chan_out,
        
			clk,
			reset

		);
  
	//synthesis translate_off 
	//synopsys  translate_off
	/* verilator lint_off WIDTH */
	initial begin
		if((SSA_EN=="YES")  && (SBP_EN==1'b1) )begin
			$display("ERROR: Only one of the SBP or SAA can be enabled at the same time");
			$finish;        
		end
		if((SBP_EN==1'b1) && COMBINATION_TYPE!="COMB_NONSPEC"  )begin
			$display("ERROR: SBP only works with non-speculative VSA");
			$finish;        
		end		
	end
	/* verilator lint_on WIDTH */
	//synopsys  translate_on
	//synthesis translate_on 
	
	
	localparam DISABLED =P;

	input [RAw-1 :  0]  current_r_addr;
    
	input   router_chanel_t chan_in [P-1 : 0];
	output  router_chanel_t chan_out [P-1 : 0];
	input   clk,reset;
	
	genvar i;
	
	flit_chanel_t r2_chan_in  [P-1 : 0];
	flit_chanel_t r2_chan_out [P-1 : 0];
	
	ivc_info_t 	 ivc_info    [P-1 : 0][V-1 : 0];
	ovc_info_t   ovc_info    [P-1 : 0][V-1 : 0];
	iport_info_t iport_info  [P-1 : 0];
	oport_info_t oport_info  [P-1 : 0]; 
	sbp_chanel_t sbp_chanel_new  [P-1 : 0];
	sbp_chanel_t sbp_chanel_in   [P-1 : 0];
	sbp_chanel_t sbp_chanel_out  [P-1 : 0]; 
	sbp_ctrl_t   sbp_ctrl        [P-1 : 0];
	
	
	
	// synthesis translate_off
	//header flit info, it is useful for debugin 
	hdr_flit_t hdr_flit_i [P-1 : 0]; // the received packet header flit info 
	hdr_flit_t hdr_flit_o [P-1 : 0]; // the sent packet header flit info 
	
	
	generate 
		for (i=0; i<P; i=i+1) begin :Port_		
		
		
			header_flit_info in_extract(
					.flit(chan_in[i].flit_chanel.flit),
					.hdr_flit( hdr_flit_i[i]),		
					.data_o()
				);
		
			header_flit_info out_extract(
					.flit(chan_out[i].flit_chanel.flit),
					.hdr_flit( hdr_flit_o[i]),
					.data_o()
				);
			
			if(DEBUG_EN) begin :dbg
			check_flit_chanel_type_is_in_order #(
					.V(V)
				)
				IVC_flit_type_check
				(
					.clk(clk),
					.reset(reset),
					.hdr_flg_in(chan_in[i].flit_chanel.flit.hdr_flag),
					.tail_flg_in(chan_in[i].flit_chanel.flit.tail_flag),
					.flit_in_wr(chan_in[i].flit_chanel.flit_wr),
					.vc_num_in(chan_in[i].flit_chanel.flit.vc)
				);
		
			end
		
		
		end
	endgenerate
	// synthesis translate_on
	
	
	
	
	
	wire [V-1 : 0] ovc_locally_requested [P-1 : 0]; 
	flit_chanel_t ss_flit_chanel [P-1 : 0]; //flit  bypass link goes to straight port

	router_two_stage  #(//r2
			.P (P)
		)router_ref (
			.ivc_info(ivc_info),
			.ovc_info(ovc_info),
			.iport_info(iport_info),
			.oport_info(oport_info),
			.sbp_ctrl_in(sbp_ctrl),
			.current_r_addr  (current_r_addr ), 
			.chan_in         (r2_chan_in     ), 
			.chan_out        (r2_chan_out    ), 
			.clk             (clk            ), 
			.reset           (reset          )			
		);                

	generate 
		
		if(SBP_EN) begin :sbp
		
		
			sbp_forward_ivc_info			
				#(
					.P(P)
				)forward_ivc(			
					.ivc_info(ivc_info),
					.iport_info(iport_info),
					.oport_info(oport_info),
					.sbp_chanel(sbp_chanel_new),
					.ovc_locally_requested(ovc_locally_requested),
					.reset(reset),
					.clk(clk)
				);
		
			sbp_bypass_chanels
				#(
					.P(P)
				)sbp_bypass(			
					.ivc_info(ivc_info),
					.iport_info(iport_info),
					.oport_info(oport_info),
					.sbp_chanel_new(sbp_chanel_new),
					.sbp_chanel_in(sbp_chanel_in),
					.sbp_chanel_out(sbp_chanel_out),
					.sbp_req( ),
					.reset(reset),
					.clk(clk)			
				);	
		
			wire  [RAw-1:  0]  neighbors_r_addr [P-1: 0];	
			wire  [V-1  :  0]  credit_out [P-1 : 0];
			wire  [V-1  :  0]  ivc_sbp_en [P-1 : 0];
			for (i=0;i<P;i=i+1)begin : Port_
				localparam SS_PORT = strieght_port (P,i);
				if(SS_PORT == DISABLED) begin: sbp_dis 
					assign r2_chan_in[i]   =  chan_in[i].flit_chanel;
					assign chan_out[i].flit_chanel     =  r2_chan_out[i];	
					assign sbp_ctrl[i]={SBP_CTRL_w{1'b0}};					
				end 
				else begin :sbp_en
					assign neighbors_r_addr [i] = chan_in[i].flit_chanel.neighbors_r_addr;
					//sbp allocator
					sbp_allocator_per_iport #(
							.P                         (P                        ), 
							.SW_LOC                    (i      		             ), 
							.SS_PORT_LOC               (SS_PORT     	         )
						) sbp_allocator(
							.clk                       (clk                      ), 
							.reset                     (reset                    ), 
							.current_r_addr_i          (current_r_addr           ), 
							.neighbors_r_addr_i        (neighbors_r_addr         ), 
							.sbp_chanel_i              (chan_in[i].sbp_chanel    ), 
							.flit_chanel_i             (chan_in[i].flit_chanel   ), 
							.ivc_info                  (ivc_info[i]              ), 
							.ss_ovc_info               (ovc_info[SS_PORT]        ),
							.ovc_locally_requested     (ovc_locally_requested[SS_PORT] ),
							.ss_sbp_chanel_new		   (sbp_chanel_new[SS_PORT]),
							.ss_port_link_reg_flit_wr  (r2_chan_out[SS_PORT].flit_wr), 
							
							.sbp_single_flit_pck_o       (sbp_ctrl[i].single_flit_pck),
							.sbp_destport_o				 (sbp_ctrl[i].destport     ),	
							.sbp_lk_destport_o			 (sbp_ctrl[i].lk_destport  ),	
							.sbp_hdr_flit_req_o          (sbp_ctrl[i].hdr_flit_req ),
							.sbp_ivc_sbp_en_o			 (ivc_sbp_en[i]   ),              		
							.sbp_credit_o				 (sbp_ctrl[i].credit_out   ),             	
							.sbp_buff_space_decreased_o	 (sbp_ctrl[SS_PORT].buff_space_decreased), 
							.sbp_ivc_num_getting_ovc_grant_o(sbp_ctrl[i].ivc_num_getting_ovc_grant),
							.sbp_ivc_reset_o             (sbp_ctrl[i].ivc_reset),
							.sbp_ivc_granted_ovc_num_o   (sbp_ctrl[i].ivc_granted_ovc_num),
							.sbp_ss_ovc_is_allocated_o	 (sbp_ctrl[SS_PORT].ovc_is_allocated),     
							.sbp_ss_ovc_is_released_o	 (sbp_ctrl[SS_PORT].ovc_is_released),      
							.sbp_mask_available_ss_ovc_o (sbp_ctrl[SS_PORT].mask_available_ovc)	
					
						);
				
					assign sbp_ctrl[i].ivc_sbp_en = ivc_sbp_en[i];
					assign sbp_ctrl[i].sbp_en = |ivc_sbp_en[i];
					
				   
				
				
					// synthesis translate_off
					//assign chan_out[i].sbp_chanel = (sbp_chanel[i].requests[0]) ? sbp_chanel_new[i] : take ss shifted sbp;	
					sbp_chanel_check check (
							.flit_chanel(chan_out[i].flit_chanel),
							.sbp_chanel(chan_out[i].sbp_chanel),
							.reset(reset),
							.clk(clk)		
						);
					// synthesis translate_on
					
					assign sbp_chanel_in[i] =   chan_in[i].sbp_chanel;
					assign chan_out[i].sbp_chanel = sbp_chanel_out[i];
				
					//r2 demux
					// flit_in_wr demux 
					always @(*) begin 
						//mask only flit_wr id sbp_en is asserted 
						r2_chan_in[i]   =  chan_in[i].flit_chanel;
						//can replace destport here and remove lk rout from internal router 
						if (sbp_ctrl[i].sbp_en) r2_chan_in[i].flit_wr = 1'b0;
					
						//send flit_in to straight out port. Replace lk destport in header flit
						ss_flit_chanel[SS_PORT] = chan_in[i].flit_chanel;
						if(sbp_ctrl[i].hdr_flit_req) ss_flit_chanel[SS_PORT].flit[DST_P_MSB : DST_P_LSB] =  sbp_ctrl[i].lk_destport;   
					end

					always @(*) begin 
						// mux out flit channel
						chan_out[i].flit_chanel = r2_chan_out[i];
						chan_out[i].flit_chanel.credit    =  credit_out[i] ;
						if(sbp_ctrl[SS_PORT].sbp_en) begin
							chan_out[i].flit_chanel.flit    =  ss_flit_chanel[i].flit;
							chan_out[i].flit_chanel.flit_wr =  ss_flit_chanel[i].flit_wr;
						
						end
					end
				
					sbp_credit_manage #(
							.V             (V             ), 
							.B             (B            )
						) sbp_credit_manage (
							.credit_in      (r2_chan_out[i].credit     ), 
							.sbp_credit_in  (sbp_ctrl[i].credit_out ), 
							.credit_out     ( credit_out[i]   ), 
							.reset          (reset         ), 
							.clk            (clk           ));
				
				
				
				end //for
			end//sbp_en
		
		
		
		end else begin :no_sbp
			for (i=0;i<P;i=i+1)begin : Port_
				assign r2_chan_in[i]   =  chan_in[i].flit_chanel;
				assign chan_out[i].flit_chanel     =  r2_chan_out[i];	
				assign sbp_ctrl[i]={SBP_CTRL_w{1'b0}};
			end//for
		end
	endgenerate	
endmodule 



module router_top_v //to be used as top module in veralator
		import pronoc_pkg::*;
        
	# (
		parameter P = 5     // router port num         
		)(
			current_r_addr,// connected to constant parameter  
        
			chan_in,
			chan_out,
        
			clk,
			reset

		);
  
	

	input [RAw-1 :  0]  current_r_addr;
    
	input   router_chanel_t chan_in [P-1 : 0];
	output  router_chanel_t chan_out [P-1 : 0];
	input reset,clk;

	router_top # (
			.P(P)           
		)
		router
		(
			.current_r_addr(current_r_addr),          
			.chan_in (chan_in),
			.chan_out(chan_out),       
			.clk(clk),
			.reset(reset)
		);
	
		
endmodule


/**********************************
The router top module that can be called in Verilog module. 
 ***********************************

module router_top_v
		import pronoc_pkg::*;        
	# (
		parameter P = 5     // router port num         
		)(
	
			current_r_addr,
			neighbors_r_addr_in,
			neighbors_r_addr_out,
   
			flit_in_all,
			flit_in_wr_all,
			credit_out_all,
			congestion_in_all,
			sbp_chan_in,
    
			flit_out_all,
			flit_out_wr_all,
			credit_in_all,
			congestion_out_all,
			sbp_chan_out,
    
			clk,reset

		);

	localparam 
		PRAw	=P * RAw,
		PFw		=P * Fw,
		PV		=P * V,
		PCONGw	=P * CONGw,
		PSBPw	=P * SBP_CHANEL_w;


	input  [RAw-1 :  0]  current_r_addr;
	input  [PRAw-1:  0]  neighbors_r_addr_in;
	output [PRAw-1:  0]  neighbors_r_addr_out;

	input  [PFw-1 :  0]  flit_in_all;
	input  [P-1 :  0]  flit_in_wr_all;
	output [PV-1 :  0]  credit_out_all;
	input  [PCONGw-1 :  0]  congestion_in_all;
    
	output [PFw-1 :  0]  flit_out_all;
	output [P-1 :  0]  flit_out_wr_all;
	input  [PV-1 :  0]  credit_in_all;
	output [PCONGw-1 :  0]  congestion_out_all;
    
    input  [PSBPw-1 : 0] sbp_chan_in;
	output [PSBPw-1 : 0] sbp_chan_out;
    
    
	input clk,reset;

	//internal var
	router_chanel_t chan_in  [P-1 : 0];
	router_chanel_t chan_out [P-1 : 0];


	router_top # (
			.P(P)           
		)
		router
		(
			.current_r_addr(current_r_addr),          
			.chan_in (chan_in),
			.chan_out(chan_out),       
			.clk(clk),
			.reset(reset)
		);

	genvar i;
	generate
		for(i=0;i<P;i=i+1) begin: p
			assign chan_in[i].flit_chanel.flit 		= flit_in_all   [(i+1)*Fw-1 : i*Fw];
			assign chan_in[i].flit_chanel.flit_wr 	= flit_in_wr_all[i];
			assign chan_in[i].flit_chanel.credit 	= credit_in_all [(i+1)*V-1 : i*V];
			assign chan_in[i].flit_chanel.congestion 	= congestion_in_all [(i+1)*CONGw-1 : i*CONGw];
			assign chan_in[i].flit_chanel.neighbors_r_addr =neighbors_r_addr_in [(i+1)*RAw-1 : i*RAw];
			assign chan_in[i].sbp_chanel =  sbp_chan_in [(i+1)*SBP_CHANEL_w-1 : i*SBP_CHANEL_w];
	

			assign flit_out_all   [(i+1)*Fw-1 : i*Fw] = chan_out[i].flit_chanel.flit;
			assign flit_out_wr_all[i] = chan_out[i].flit_chanel.flit_wr;
			assign credit_out_all [(i+1)*V-1 : i*V] = chan_out[i].flit_chanel.credit;
			assign congestion_out_all [(i+1)*CONGw-1 : i*CONGw] = chan_out[i].flit_chanel.congestion;
			assign neighbors_r_addr_out [(i+1)*RAw-1 : i*RAw] = chan_out[i].flit_chanel.neighbors_r_addr;
			assign sbp_chan_out [(i+1)*SBP_CHANEL_w-1 : i*SBP_CHANEL_w]= chan_out[i].sbp_chanel;
		

		end
	endgenerate 


endmodule 
*/
