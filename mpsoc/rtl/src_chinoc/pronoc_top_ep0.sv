module pronoc_top_ep0
	import chi_pkg::*;
	import noc_axi4l_pkg::*;
	import noc_router_pkg::*;
(
	input logic clk, arst_n,
	
	input logic config_pin_0, config_pin_1,

	output logic debug_noc_empty_o,
	
	noc_axi4l_inf.axi_s axi_if,
	
	chi_chan.rx req_a_link_in  [NUM_PORTS],
	chi_chan.tx req_a_link_out [NUM_PORTS],
	
	chi_chan.rx req_b_link_in  [NUM_PORTS],
	chi_chan.tx req_b_link_out [NUM_PORTS],
	
	chi_chan.rx rsp_link_in    [NUM_PORTS],
	chi_chan.tx rsp_link_out   [NUM_PORTS],
	
	chi_chan.rx data_link_in   [NUM_PORTS],
	chi_chan.tx data_link_out  [NUM_PORTS],
	
	chi_chan.rx snp_link_in    [NUM_PORTS],
	chi_chan.tx snp_link_out   [NUM_PORTS]
);


// AXI WRITE
	logic                    	axi_wr_en;
	logic [NOC_BASE_ADDR_W-1:0] axi_wr_addr;
	logic [2:0]              	axi_wr_prot;
	logic [AXI_DATA_W/8-1:0] 	axi_wr_strb;
	logic [AXI_DATA_W-1:0]   	axi_wr_data;
	AXI_RESP_T               	axi_wr_resp;
	// AXI READ
	logic                    	axi_rd_en;
	logic [NOC_BASE_ADDR_W-1:0] axi_rd_addr;
	logic [2:0]              	axi_rd_prot;
	logic [AXI_DATA_W-1:0]   	axi_rd_data;
	AXI_RESP_T               	axi_rd_resp;
	
	
	NOC_CONFIG_T config_r;
	logic req_a_noc_empty_w, req_b_noc_empty_w, rsp_noc_empty_w, dat_noc_empty_w, snp_noc_empty_w;
	
	//AXI slave
	noc_axi_slave_dev axi_slave_dev_i (
		.clk     ( clk         ),
		.arst_n  ( arst_n      ),
		.axi_if  ( axi_if      ),
		
		.wr_en   ( axi_wr_en   ),
		.wr_addr ( axi_wr_addr ),
		.wr_prot ( axi_wr_prot ),
		.wr_strb ( axi_wr_strb ),
		.wr_data ( axi_wr_data ),
		.wr_resp ( axi_wr_resp ),
		
		.rd_en   ( axi_rd_en   ),
		.rd_addr ( axi_rd_addr ),
		.rd_prot ( axi_rd_prot ),
		.rd_data ( axi_rd_data ),
		.rd_resp ( axi_rd_resp )
	);


assign axi_rd_data='0;
assign axi_wr_resp=OKAY;


logic [NUM_PORTS-1 : 0] credit_release_en;
always @(posedge clk)begin 
	if(axi_wr_en && (axi_wr_addr=='0) && (axi_wr_strb =='hFF)) credit_release_en <=axi_wr_data;
        else credit_release_en<='0; 
end




    chi_chan #(.DATA_T(`REQ_FLIT_T)) req_a_link_in_m  [NUM_PORTS]();
	chi_chan #(.DATA_T(`REQ_FLIT_T)) req_a_link_out_m  [NUM_PORTS]();
	
	chi_chan req_b_link_in_m  [NUM_PORTS];
	chi_chan req_b_link_out_m  [NUM_PORTS];
	
	chi_chan rsp_link_in_m     [NUM_PORTS];
	chi_chan rsp_link_out_m    [NUM_PORTS];
	
	chi_chan data_link_in_m    [NUM_PORTS];
	chi_chan data_link_out_m  [NUM_PORTS];
	
	chi_chan snp_link_in_m     [NUM_PORTS];
	chi_chan snp_link_out_m   [NUM_PORTS];

genvar i;
generate 
for (i=0;i<NUM_PORTS;i++) begin 
    tgid_to_port_modifier m_reqa_in (.link_in(req_a_link_in[i]), .link_out(req_a_link_in_m[i]));
    port_to_tgid_modifier m_reqa_out (.link_in(req_a_link_out_m[i]), .link_out(req_a_link_out[i]));
    
    tgid_to_port_modifier m_reqb_in (.link_in(req_b_link_in[i]), .link_out(req_b_link_in_m[i]));
    port_to_tgid_modifier m_reqb_out (.link_in(req_b_link_out_m[i]), .link_out(req_b_link_out[i]));
    
    tgid_to_port_modifier m_rsp_in (.link_in(rsp_link_in[i]), .link_out(rsp_link_in_m[i]));
    port_to_tgid_modifier m_rsp_out (.link_in(rsp_link_out_m[i]), .link_out(rsp_link_out[i]));
    
    tgid_to_port_modifier data_in (.link_in(data_link_in[i]), .link_out(data_link_in_m[i]));
    port_to_tgid_modifier data_out (.link_in(data_link_out_m[i]), .link_out(data_link_out[i]));
    
    tgid_to_port_modifier m_snp_in (.link_in(req_a_link_in[i]), .link_out(req_a_link_in_m[i]));
    port_to_tgid_modifier m_snp_out (.link_in(req_a_link_out_m[i]), .link_out(req_a_link_out[i])); 

end
endgenerate



   chi_nocs_top chi_nocs
(
	.req_a_link_in(req_a_link_in_m),
	.req_a_link_out(req_a_link_out_m),
	
	.req_b_link_in(req_b_link_in_m),
	.req_b_link_out(req_b_link_out_m),
	
	.rsp_link_in(rsp_link_in_m),
	.rsp_link_out(rsp_link_out_m),
	
	.data_link_in(data_link_in_m),
	.data_link_out(data_link_out_m),
	
	.snp_link_in(snp_link_in_m),
	.snp_link_out(snp_link_out_m),
	
	.clk(clk), .reset(~arst_n),
	.debug_noc_empty_o(debug_noc_empty_o),
    .credit_release_en(credit_release_en)
);

endmodule


module tgid_to_port_modifier
    import chi_pkg::*;
	import noc_router_pkg::*;
(
	chi_chan.rx link_in  ,
	chi_chan.tx link_out 
);

     wire [6: 0] port_id;
     
     tgid_to_port #(
          .TGTID_WIDTH(7)
      )conv (
          .tgid(link_in.flit.tgt_id),
          .port_id(port_id)                
     );

    always @(*) begin 
         
         link_out.flit_pend = link_in.flit_pend;
         link_out.flit_v = link_in.flit_v;
         link_in.lcrd_v = link_out.lcrd_v;
         link_out.flit = link_in.flit;
       //replace target id  
         link_out.flit.tgt_id = port_id; 
    end

endmodule



module port_to_tgid_modifier 
    import chi_pkg::*;
	import noc_router_pkg::*;
(
	chi_chan.rx link_in  ,
	chi_chan.tx link_out 
);

     wire [6: 0] tgid;
     
     tgid_to_port #(
          .TGTID_WIDTH(7)
      )conv (
          .tgid(link_in.flit.tgt_id),
          .port_id(tgid)                
     );

    always @(*) begin 
         
         link_out.flit_pend = link_in.flit_pend;
         link_out.flit_v = link_in.flit_v;
         link_in.lcrd_v = link_out.lcrd_v;
         link_out.flit = link_in.flit;
       //replace target id  
         link_out.flit.tgt_id = tgid; 
    end

endmodule



