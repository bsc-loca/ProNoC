`include "pronoc_def.v"
`include "chi_noc_def.v"

module tgid_to_port #(
    parameter NOC_ID=0,
    parameter TGTID_WIDTH=7
)(
    tgid,
    port_id
)

    `NOC_CONF 
    `TGIDS_DEF
     
    input [TGTID_WIDTH-1 : 0]  tgid;
    output reg [NEw-1 : 0]  port_id;
    
    always @(*)begin 
       port_id  =     `NUM_PORTS-1;
       for(int i=0; i< `NUM_PORTS; i++) if(CHI_NOC_PORT_ID[i]==tgid) port_id  = i;
    end


endmodule 


module port_to_tgid #(
    parameter NOC_ID=0,
    parameter TGTID_WIDTH=7
)(
    tgid,
    port_id
)

    `NOC_CONF 
    `TGIDS_DEF
     
    output reg [TGTID_WIDTH-1 : 0]  tgid;
    input [NEw-1 : 0]  port_id;
    
      
    always @(*)begin 
       //tgid    portid
       tgid  =      CHI_NOC_PORT_ID[port_id];
    end


endmodule 

