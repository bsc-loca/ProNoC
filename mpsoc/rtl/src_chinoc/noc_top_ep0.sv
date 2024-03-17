module noc_top_ep0
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


    logic [NUM_PORTS-1 : 0] req_a_link_in_flit_v, req_a_link_in_flit_pend, req_a_link_out_lcrd_v ;
    logic [REQ_FLIT_SIZE-1 : 0]  req_a_link_in_flit [NUM_PORTS-1 : 0];
    
    
    genvar i;
	generate
	for (i=0; i<NUM_PORTS; i++) begin
	    assign
	    {req_a_link_in_flit_v[p], req_a_link_in_flit_pend[p], req_a_link_out_lcrd_v[p]}  =  
	    {req_a_link_in[p].flit_v, req_a_link_in[p].flit_pend, req_a_link_out[p].lcrd_v};
	    assign req_a_link_in_flit[p] = req_a_link_in [p].flit;
	
			



 chi_noc #(
    .NOC_ID()
 )req_a_noc
 (
    .reset(~arst_n),
    .clk(clk),
    /*--------- Interface with NoC ---------------------------------*/
    // TX
    .chi_noc_txflitpend_all(),
    .chi_noc_txflitv_all(),
    .chi_noc_txflit_all(),
    .noc_chi_txlcrdv_all(),      
    
    // RX
    .noc_chi_rxflitpend_all,
    .noc_chi_rxflitv_all,
    .noc_chi_rxflit_all,          
    .chi_noc_rxlcrdv_all
    
    //used only on snoop NoC
    .snp_target_id_all

);




endmodule
