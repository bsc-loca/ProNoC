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


   chi_nocs_top
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
	.debug_noc_empty_o(debug_noc_empty_o)
);




endmodule
