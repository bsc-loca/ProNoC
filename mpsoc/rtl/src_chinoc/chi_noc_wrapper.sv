`include "pronoc_def.v"
`include "chi_noc_def.v"


module  chi_noc_wrapper #(
    parameter NOC_ID=0
)(
    reset,
    clk,
    /*--------- Interface with NoC ---------------------------------*/
    // TX
    chi_noc_txflitpend_all,
    chi_noc_txflitv_all,
    chi_noc_txflit_all,
    noc_chi_txlcrdv_all,      
    
    // RX
    noc_chi_rxflitpend_all,
    noc_chi_rxflitv_all,
    noc_chi_rxflit_all,          
    chi_noc_rxlcrdv_all
);
     
    `NOC_CONF    
     
    // Clock and Reset
    input clk,reset;
    
    
/*--------- Interface with NoC ---------------------------------*/
    // TX
    input  [NE-1 : 0] chi_noc_txflitpend_all ;
    input  [NE-1 : 0] chi_noc_txflitv_all;
    input  [Fpay*NE-1:0]    chi_noc_txflit_all;          
    output [NE-1 : 0] noc_chi_txlcrdv_all;
   
    
     // RX
    output  [NE-1 : 0] noc_chi_rxflitpend_all ;
    output  [NE-1 : 0] noc_chi_rxflitv_all;
    output  [Fpay*NE-1:0]    noc_chi_rxflit_all;          
    input   [NE-1 : 0] chi_noc_rxlcrdv_all;   
    
    input [TGTID_DAT *NE-1 : 0]  snp_target_id_all;
    
    wire  [Fpay-1:0]    chi_noc_txflit [NE-1 : 0]; 
    wire  [Fpay-1:0]    noc_chi_rxflit [NE-1 : 0]; 
  
   
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
   

    
    genvar i;
    generate
    for(i=0;i<NE;i=i+1)begin :ne
        assign current_r_addr[i] = router_event[i][0].router_addr;   
        assign chi_noc_txflit[i] = chi_noc_txflit_all[(i+1)*Fpay-1 : i*Fpay];        
        assign noc_chi_rxflit_all [(i+1)*Fpay-1 : i*Fpay] = noc_chi_rxflit[i];
    
        if(NOC_ID== `SNP_CHI)  begin : snp_        
        
            assign snp_target_id [i] = snp_target_id_all[(i+1)* TGTID_DAT-1 : i* TGTID_DAT];   
                   
            
            snp_chi_to_pronoc_wrapper #(.NOC_ID(NOC_ID)) chi_to_pronoc        
            (
                .chi_flitpend_i(chi_noc_txflitpend_all[i]),
                .chi_flitv_i(chi_noc_txflitv_all[i]),
                .chi_lcrdv_i(chi_noc_rxlcrdv_all[i]),        
                .chi_flit_i(chi_noc_txflit[i]),
                .snp_target_id(snp_target_id[i]),//comes from home nodes
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
                

endmodule
