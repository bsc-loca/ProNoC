`include "pronoc_def.v"

module chi_nocs_top
(
	req_a_link_in,
	req_a_link_out,
	
	req_b_link_in,
	req_b_link_out,
	
	rsp_link_in,
	rsp_link_out,
	
	data_link_in,
	data_link_out,
	
	snp_link_in,
	snp_link_out,
	
	clk, reset,
	debug_noc_empty_o,	
);

    `NOC_CONF

    input logic clk, reset;
    output logic debug_noc_empty_o;
	
	chi_chan.rx req_a_link_in  [NE];
	chi_chan.tx req_a_link_out [NE];
	
	chi_chan.rx req_b_link_in  [NE];
	chi_chan.tx req_b_link_out [NE];
	
	chi_chan.rx rsp_link_in    [NE];
	chi_chan.tx rsp_link_out   [NE];
	
	chi_chan.rx data_link_in   [NE];
	chi_chan.tx data_link_out  [NE];
	
	chi_chan.rx snp_link_in    [NE];
	chi_chan.tx snp_link_out   [NE];


    chi_noc_top #(
       .NOC_ID(`REQ_CHI)
    )req_a_noc(
        reset(reset),
        clk(clk),
        link_in(req_a_link_in),
	    link_out(req_a_link_out),
	    snp_target_id_all()
    );
    
    chi_noc_top #(
       .NOC_ID(`REQ_CHI)
    )req_b_noc(
        reset(reset),
        clk(clk),
        link_in(req_b_link_in),
	    link_out(req_b_link_out),
	    snp_target_id_all()
    );
    
    chi_noc_top #(
       .NOC_ID(`DAT_CHI)
    )data_noc(
        reset(reset),
        clk(clk),
        link_in(data_link_in),
	    link_out(data_link_out),
	    snp_target_id_all()
    );

    chi_noc_top #(
       .NOC_ID(`RSP_CHI)
    )rsp_noc(
        reset(reset),
        clk(clk),
        link_in(rsp_link_in),
	    link_out(rsp_link_out),
	    snp_target_id_all()
    );
    
    chi_noc_top #(
       .NOC_ID(`SNP_CHI)
    )snp_noc(
        reset(reset),
        clk(clk),
        link_in(snp_link_in),
	    link_out(snp_link_out),
	    snp_target_id_all()
    );

endmodule






module  chi_noc_top #(
   parameter NOC_ID = 0
)(
    reset,clk,
    link_in,
	link_out,
	snp_target_id_all
);
     `NOC_CONF
     
    input logic reset,clk;
    chi_chan.rx link_in  [NE];
	chi_chan.tx link_out [NE];
	
/*----------------------------------------------------------------------------*/
/*ProNoC interface */
/*----------------------------------------------------------------------------*/
    
    //local ports 
    smartflit_chanel_t pronoc_chan_in  [NE-1 : 0];
    smartflit_chanel_t pronoc_chan_out [NE-1 : 0];
    router_event_t  router_event [NR-1 : 0][MAX_P-1 : 0];
    wire [RAw-1 : 0] current_r_addr [NE-1 : 0]; 
	
	
	
	
	 noc_top #(.NOC_ID(NOC_ID)) _noc 
    (
        .reset(reset),
        .clk(clk),    
        .chan_in_all (pronoc_chan_in),
        .chan_out_all(pronoc_chan_out),
        .router_event(router_event)  
    );
	
	wire  [Fpay-1:0]    chi_noc_txflit [NE-1 : 0]; 
    wire  [Fpay-1:0]    noc_chi_rxflit [NE-1 : 0]; 
    
	genvar i;
    generate
    for(i=0;i<NE;i=i+1)begin :ne
        assign current_r_addr[i] = router_event[i][0].router_addr;   
        assign chi_noc_txflit[i] = link_in[i].flit;        
        assign link_out.flit [i] = noc_chi_rxflit[i];
                      
            
            chi_to_pronoc_wrapper #(.NOC_ID(NOC_ID)) chi_to_pronoc        
            (
                .chi_flitpend_i (link_in[i].flit_pend),
                .chi_flitv_i    (link_in[i].flit_v),
                .chi_lcrdv_i    (link_out[i].lcrd_v),        
                .chi_flit_i     (link_in[i].flit),                
               
                .current_r_addr_i(current_r_addr[i]),            
                .pronoc_chan_out(pronoc_chan_in[i]),  
                .clk(clk)  ,
                .reset(reset)
            );
             
            
            pronoc_to_chi_wrapper #(.NOC_ID(NOC_ID)) pronoc_to_chi        	
            (            
                .chi_flit_o(noc_chi_rxflit[i]),
                .chi_flitpend_o(noc_chi_rxflitpend_all[i]),
                .chi_flitv_o(noc_chi_rxflitv_all[i]),
                .chi_lcrdv_o(noc_chi_txlcrdv_all[i]),
                .pronoc_chan_in(pronoc_chan_out[i])   
            );       
    
       
        end else begin : no_snp_        
     
        
            // chi to pronoc 
            chi_to_pronoc_wrapper #(.NOC_ID(NOC_ID)) chi_to_pronoc
            (        
                .chi_flitpend_i(chi_noc_txflitpend_all[i]),
                .chi_flitv_i(chi_noc_txflitv_all[i]),
                .chi_lcrdv_i(chi_noc_rxlcrdv_all[i]),        
                .chi_flit_i(chi_noc_txflit[i]),            
                .current_r_addr_i(current_r_addr[i]),             
                .pronoc_chan_out(pronoc_chan_in[i]),    
                .clk(clk),
                .reset(reset)
            );
        
        
            // pronoc to chi       
            pronoc_to_chi_wrapper #(.NOC_ID(NOC_ID)) pronoc_to_chi
            (            
                .chi_flit_o(noc_chi_rxflit[i]),
                .chi_flitpend_o(noc_chi_rxflitpend_all[i]),
                .chi_flitv_o(noc_chi_rxflitv_all[i]),
                .chi_lcrdv_o(noc_chi_txlcrdv_all[i]),
                .pronoc_chan_in(pronoc_chan_out[i])     
            );
        
        end 
     
   end
   endgenerate    
	
	
	
	
	
	
	
	
	     
    logic [NE-1 : 0] link_in_flit_v, link_in_flit_pend, link_in_lcrd_v ;
    logic [REQ_FLIT_SIZE-1 : 0]  link_in_flit [NE-1 : 0];
    
    logic [NE-1 : 0] link_out_flit_v, link_out_flit_pend, link_out_lcrd_v ;
    logic [REQ_FLIT_SIZE-1 : 0]  link_out_flit [NE-1 : 0];
    
    genvar i;
	generate
	for (i=0; i<NE; i++) begin
	    assign
	    {link_in_flit_v[i], link_in_flit_pend[i], link_out_lcrd_v[i]}  = {link_in[i].flit_v, link_in[i].flit_pend, link_out[i].lcrd_v};
	    assign link_in_flit[i] = link_in [i].flit;
	    
	    assign
	    {link_out[i].flit_v, link_out[i].flit_pend, link_in[i].lcrd_v} = {link_out_flit_v[i], link_out_flit_pend[i], link_in_lcrd_v[i]}
	    assign link_out_flit[i] = link_out [i].flit;	    
	end 
	endgenerate
			
     
     
     
  chi_noc_wrapper #(
    .NOC_ID(NOC_ID)
  )(
    .reset(reset),
    .clk(clk),
    /*--------- Interface with NoC ---------------------------------*/
    // TX
    .chi_noc_txflitpend_all(link_in_flit_pend),
    .chi_noc_txflitv_all(link_out_flit_v),
    .chi_noc_txflit_all(link_out_flit),
    .noc_chi_txlcrdv_all(link_out_lcrd_v),      
    
    // RX
    .noc_chi_rxflitpend_all(link_in_flit_pend),
    .noc_chi_rxflitv_all(link_in_flit_v),
    .noc_chi_rxflit_all(link_in_flit),          
    .chi_noc_rxlcrdv_all(link_in_lcrd_v)
    
    //used only on snoop NoC
    .snp_target_id_all(snp_target_id_all)

);
  
endmodule
