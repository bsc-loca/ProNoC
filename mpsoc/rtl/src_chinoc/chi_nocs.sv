`include "pronoc_def.v"
`include "chi_noc_def.v"

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
    credit_release_en    
);

    

    input logic clk, reset;
    output logic debug_noc_empty_o;
    
    chi_chan.rx req_a_link_in  [`NUM_PORTS];
    chi_chan.tx req_a_link_out [`NUM_PORTS];
    
    chi_chan.rx req_b_link_in  [`NUM_PORTS];
    chi_chan.tx req_b_link_out [`NUM_PORTS];
    
    chi_chan.rx rsp_link_in    [`NUM_PORTS];
    chi_chan.tx rsp_link_out   [`NUM_PORTS];
    
    chi_chan.rx data_link_in   [`NUM_PORTS];
    chi_chan.tx data_link_out  [`NUM_PORTS];
    
    chi_chan.rx snp_link_in    [`NUM_PORTS];
    chi_chan.tx snp_link_out   [`NUM_PORTS];

    input [`NUM_PORTS-1 : 0] credit_release_en;

    wire [4: 0 ] empty;
    assign debug_noc_empty_o = & empty;

    chi_noc_top #(
        .NOC_ID(`REQA_CHI)
    )req_a_noc(
        .reset(reset),
        .clk(clk),
        .link_in(req_a_link_in),
        .link_out(req_a_link_out),
        .credit_release_en(credit_release_en),
        .empty(empty[0])
    );
    
    

    chi_noc_top #(
        .NOC_ID(`REQB_CHI)
    )req_b_noc(
        .reset(reset),
        .clk(clk),
        .link_in(req_b_link_in),
        .link_out(req_b_link_out),
        .credit_release_en(credit_release_en),
        .empty(empty[1])
    );
    
    chi_noc_top #(
        .NOC_ID(`DAT_CHI)
    )data_noc(
        .reset(reset),
        .clk(clk),
        .link_in(data_link_in),
        .link_out(data_link_out),
        .credit_release_en(credit_release_en),
        .empty(empty[2])
    );

    chi_noc_top #(
        .NOC_ID(`RSP_CHI)
    )rsp_noc(
        .reset(reset),
        .clk(clk),
        .link_in(rsp_link_in),
        .link_out(rsp_link_out),
        .credit_release_en(credit_release_en),
        .empty(empty[3])
    );
    
    chi_noc_top #(
        .NOC_ID(`SNP_CHI)
    )snp_noc(
        .reset(reset),
        .clk(clk),
        .link_in(snp_link_in),
        .link_out(snp_link_out),
        .credit_release_en(credit_release_en),
        .empty(empty[4])      
    );

endmodule






module  chi_noc_top #(
   parameter NOC_ID = 0
)(
    reset,clk,
    link_in,
    link_out,
    credit_release_en,
    empty
    
    
);
     `NOC_CONF
     
    input logic reset,clk;
    chi_chan.rx link_in  [NE];
    chi_chan.tx link_out [NE];
    input logic [NE-1 : 0] credit_release_en ;
    output reg empty;
    
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
    
   // wire  [Fpay-1:0]    chi_noc_txflit [NE-1 : 0]; 
   // wire  [Fpay-1:0]    noc_chi_rxflit [NE-1 : 0]; 
  
  
   `TGIDS_DEF
   `HOME_NODE_IDS_DEF
   
      
   function automatic logic [63:0] tgid_to_port(
      input logic [7:0]  tgid
   );
       logic [7:0] port_id;
       port_id  =     `NUM_PORTS-1;
       for(int i=0; i< `NUM_PORTS; i++) if(CHI_NOC_PORT_ID[i]==tgid) port_id  = i;
       return port_id;
   endfunction : tgid_to_port
         
   localparam 
        NUM_HOME_NODES =`NUM_HOME_NODES,
        HOME_SELW =(NUM_HOME_NODES==1)? 1 : $clog2(NUM_HOME_NODES);           
    
   //assume SAM direct consequative cache blocks to consequaive homenode ID   
   function automatic logic [7:0] sam (
      input integer addr 
   );  
      logic [7:0] hmn_id;
      logic [HOME_SELW-1 : 0 ] sel;
      if(`NUM_HOME_NODES==1) sel=0;
      else begin 
        sel = addr[6+HOME_SELW : 6];
        if (sel >= NUM_HOME_NODES ) sel = NUM_HOME_NODES-1;
      end 
      hmn_id = HOME_NODE_IDS[sel];
      return hmn_id;
  endfunction : sam  
    
    
   logic [7: 0] tg_ids [NE-1 : 0]; 
   genvar i;
   generate
   for(i=0;i<NE;i=i+1)begin :ne_
        assign current_r_addr[i] = pronoc_chan_out[i].ctrl_chanel.neighbors_r_addr;   
        if (`IS_EMBEDED_SAM) begin :sam_
            always @(*) begin 
                tg_ids[i]=0;
                tg_ids[i] = sam (link_in[i].flit.`ADDR_E);                
            end        
        end else begin :no_sam
            always @(*) begin 
                tg_ids[i]=0;
                tg_ids[i]= link_in[i].flit.`TGT_ID_E;
            end        
        end              
            chi_to_pronoc_wrapper #(.NOC_ID(NOC_ID)) chi_to_pronoc        
            (
                
                .target_id (tgid_to_port(tg_ids[i])),
                .src_id    (i[NEw-1 : 0]),
                .chi_flitpend_i (link_in[i].flit_pend),
                .chi_flitv_i    (link_in[i].flit_v),
                .chi_lcrdv_i    (link_out[i].lcrd_v),        
                .chi_flit_i     (link_in[i].flit),
                .credit_release_en(credit_release_en[i]),                
               
                .current_r_addr_i(current_r_addr[i]),            
                .pronoc_chan_out(pronoc_chan_in[i]),  
                .clk(clk)  ,
                .reset(reset)
            );
             
            
            pronoc_to_chi_wrapper #(.NOC_ID(NOC_ID)) pronoc_to_chi            
            (            
                .chi_flit_o(link_out[i].flit),
                .chi_flitpend_o(link_out[i].flit_pend),
                .chi_flitv_o(link_out[i].flit_v),
                .chi_lcrdv_o(link_in[i].lcrd_v),
                .pronoc_chan_in(pronoc_chan_out[i])   
            );     
     
   end
   
   endgenerate      
    
   always @(*)begin 
	empty = 1'b1;
        for (int r=0; r<NR; r++) for( int p=0;p<MAX_P;p++) if(router_event[r][p].empty==1'b0) empty =1'b0;
   end
  
endmodule
