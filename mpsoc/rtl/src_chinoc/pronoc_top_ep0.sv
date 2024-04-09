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



    

   chi_nocs_top chi_nocs
(
	.req_a_link_in(req_a_link_in),
	.req_a_link_out(req_a_link_out),
	
	.req_b_link_in(req_b_link_in),
	.req_b_link_out(req_b_link_out),
	
	.rsp_link_in(rsp_link_in),
	.rsp_link_out(rsp_link_out),
	
	.data_link_in(data_link_in),
	.data_link_out(data_link_out),
	
	.snp_link_in(snp_link_in),
	.snp_link_out(snp_link_out),
	
	.clk(clk), .reset(~arst_n),
	.debug_noc_empty_o(debug_noc_empty_o),
    .credit_release_en(credit_release_en)
);

endmodule






