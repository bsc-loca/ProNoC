`timescale  1ns/1ps

module  traffic_gen_top
		import pronoc_pkg::*; 
		#(
			parameter MAX_PCK_NUM   = 10000,
			parameter MAX_SIM_CLKs  = 100000,
			parameter MAX_PCK_SIZ   = 10,  // max packet size
			parameter TIMSTMP_FIFO_NUM=16,  
			parameter MAX_RATIO= 1000		
		)(
					
			//noc port
			noc_chan_in,
			noc_chan_out,  
			
			//input 
			ratio,// real injection ratio  = (MAX_RATIO/100)*ratio
			avg_pck_size_in, 
			pck_size_in,   
			current_r_addr,
			current_e_addr,
			dest_e_addr,
			pck_class_in,        
			start, 
			stop,  
			report,
			init_weight,
      
			//output
			pck_number,
			sent_done, // tail flit has been sent
			hdr_flit_sent,
			update, // update the noc_analayzer
			src_e_addr,
   
			distance,
			pck_class_out,   
			time_stamp_h2h,
			time_stamp_h2t,
			
			reset,
			clk
			
		);
		
		localparam
			RATIOw= $clog2(MAX_RATIO),
			Vw =    $clog2(V);
			
		input   router_channel_t 	noc_chan_in;
		output  router_channel_t 	noc_chan_out;  
		
		
   
   
		localparam
			PCK_CNTw = log2(MAX_PCK_NUM+1),
			CLK_CNTw = log2(MAX_SIM_CLKs+1),
			PCK_SIZw = log2(MAX_PCK_SIZ+1),
			/* verilator lint_off WIDTH */
			DISTw = (TOPOLOGY=="FATTREE" || TOPOLOGY=="TREE" ) ? log2(2*L+1): log2(NR+1),
			W=WEIGHTw;

		input reset, clk;
		input  [RATIOw-1                :0] ratio;
		input                               start,stop;
		output                              update;
		output [CLK_CNTw-1              :0] time_stamp_h2h,time_stamp_h2t;
		output [DISTw-1                  :0] distance;
		output [Cw-1                    :0] pck_class_out;
		// the connected router address
		input  [RAw-1                   :0] current_r_addr;    
		// the current endpoint address
		input  [EAw-1                   :0] current_e_addr;    
		// the destination endpoint adress
		input  [EAw-1                   :0] dest_e_addr;  
    
		output [PCK_CNTw-1              :0] pck_number;
		input  [PCK_SIZw-1              :0] avg_pck_size_in;
		input  [PCK_SIZw-1              :0] pck_size_in;
    
		output reg sent_done;
		output hdr_flit_sent;
		input  [Cw-1                    :0] pck_class_in;
		input  [W-1                     :0] init_weight;
		
		input                               report;
		// the recieved packet source endpoint address
		output [EAw-1        :   0]    src_e_addr;
		
		
		
		traffic_gen #(
			.V                     (V                    ), 
			.B                     (B                    ), 
			.T1                    (T1                   ), 
			.T2                    (T2                   ), 
			.T3                    (T3                   ), 
			.Fpay                  (Fpay                 ), 
			.VC_REALLOCATION_TYPE  (VC_REALLOCATION_TYPE ), 
			.TOPOLOGY              (TOPOLOGY             ), 
			.ROUTE_NAME            (ROUTE_NAME           ), 
			.C                     (C                    ), 
			.MAX_PCK_NUM           (MAX_PCK_NUM          ), 
			.MAX_SIM_CLKs          (MAX_SIM_CLKs         ), 
			.MAX_PCK_SIZ           (MAX_PCK_SIZ          ), 
			.TIMSTMP_FIFO_NUM      (TIMSTMP_FIFO_NUM     ), 
			.MAX_RATIO             (MAX_RATIO            ), 
			.SWA_ARBITER_TYPE      (SWA_ARBITER_TYPE     ), 
			.WEIGHTw               (WEIGHTw              ), 
			.MIN_PCK_SIZE          (MIN_PCK_SIZE         ), 
			.BYTE_EN               (BYTE_EN              )
			) traffic_gen (
			.ratio                 (ratio        ), 
			.avg_pck_size_in       (avg_pck_size_in      ), 
			.pck_size_in           (pck_size_in          ), 
			.current_r_addr        (current_r_addr       ), 
			.current_e_addr        (current_e_addr       ), 
			.dest_e_addr           (dest_e_addr          ), 
			.pck_class_in          (pck_class_in         ), 
			.start                 (start                ), 
			.stop                  (stop                 ), 
			.report                (report               ), 
			.init_weight           (init_weight          ), 
			.pck_number            (pck_number           ), 
			.sent_done             (sent_done            ), 
			.hdr_flit_sent         (hdr_flit_sent        ), 
			.update                (update               ), 
			.src_e_addr            (src_e_addr           ), 
			.distance              (distance             ), 
			.pck_class_out         (pck_class_out        ), 
			.time_stamp_h2h        (time_stamp_h2h       ), 
			.time_stamp_h2t        (time_stamp_h2t       ), 
			.flit_out              (noc_chan_out.flit), 
			.flit_out_wr           (noc_chan_out.flit_wr), 
			.credit_in             (noc_chan_in.credit), 
			.flit_in               (noc_chan_in.flit  ), 
			.flit_in_wr            (noc_chan_in.flit_wr), 
			.credit_out            (noc_chan_out.credit), 
			.reset                 (reset                ), 
			.clk                   (clk                  ));		
		
		
endmodule
