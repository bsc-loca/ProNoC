
`timescale   1ns/1ps
/***********************

    modified for basline duato
    
**********************/


module  vc_alloc_request_gen_determinstic #(
    parameter P = 5,
    parameter V = 4

)(
    ovc_avalable_all,
    dest_port_in_all,
    candidate_ovc_all,
    ivc_request_all,
    ovc_is_assigned_all,
    dest_port_out_all,
    masked_ovc_request_all
);

    localparam  P_1     =   P-1,
                PV      =   V       *   P,
                PVV     =   PV      *  V,
                PVP_1   =   PV      *   P_1,
                VP_1    =   V       *   P_1;

    input   [PV-1       :   0]  ovc_avalable_all;
    input   [PVP_1-1    :   0]  dest_port_in_all;
    input   [PV-1       :   0]  ivc_request_all;
    input   [PV-1       :   0]  ovc_is_assigned_all;
    output  [PVP_1-1    :   0]  dest_port_out_all;
    output  [PVV-1      :   0]  masked_ovc_request_all;
    input   [PVV-1      :   0]  candidate_ovc_all;
    
    wire    [PV-1       :   0]  non_assigned_ovc_request_all; 
    wire    [VP_1-1     :   0]  ovc_avalable_perport        [P-1    :   0];
    wire    [VP_1-1     :   0]  ovc_avalable_ivc            [PV-1   :   0];
    wire    [P_1-1      :   0]  dest_port_ivc               [PV-1   :   0];
    wire    [V-1        :   0]  ovc_avb_muxed               [PV-1   :   0];  
    wire    [V-1        :   0]  ovc_request_ivc             [PV-1   :   0];
  
  assign non_assigned_ovc_request_all =   ivc_request_all & ~ovc_is_assigned_all;
  
  // having determinsit routing only one destination port has been requested
  assign dest_port_out_all = dest_port_in_all;
    
  genvar i;

generate
    //remove avalable ovc of reciver port 
    for(i=0;i< P;i=i+1) begin :port_loop
        if(i==0) assign ovc_avalable_perport[i]=ovc_avalable_all [PV-1              :   V];
        else if(i==(P-1)) assign ovc_avalable_perport[i]=ovc_avalable_all [PV-V-1               :   0];
        else    assign ovc_avalable_perport[i]={ovc_avalable_all [PV-1  :   (i+1)*V],ovc_avalable_all [(i*V)-1  :   0]};
    end
        
    // IVC loop
    for(i=0;i< PV;i=i+1) begin :total_vc_loop
        //seprate input/output
        assign ovc_avalable_ivc[i]  =   ovc_avalable_perport[(i/V)];
        assign dest_port_ivc   [i]  =   dest_port_in_all [(i+1)*P_1-1  :   i*P_1   ];
        assign ovc_request_ivc [i]  = (non_assigned_ovc_request_all[i])? candidate_ovc_all  [(i+1)*V-1  :   i*V ]: {V{1'b0}};
          
       
        //available ovc multiplexer
        one_hot_mux #(
            .IN_WIDTH       (VP_1   ),
            .SEL_WIDTH      (P_1)
        )
        multiplexer
        (
            .mux_in     (ovc_avalable_ivc   [i]),
            .mux_out    (ovc_avb_muxed      [i]),
            .sel        (dest_port_ivc      [i])

        );
        
        // mask unavailable ovc from requests
        assign masked_ovc_request_all  [(i+1)*V-1   :   i*V ]     =   ovc_avb_muxed[i] & ovc_request_ivc [i];
        
    end
   endgenerate


endmodule
/*****************************************

pre-sel[xy]
    y
1   |   3
    |
 -------x
0   |   2
    |

*****************************************/


module  vc_alloc_request_gen_adaptive #(
    parameter V = 4,
    parameter ROUTE_TYPE           =  "FULL_ADAPTIVE",    // "FULL_ADAPTIVE", "PAR_ADAPTIVE"  
    parameter [V-1  :   0] ESCAP_VC_MASK = 4'b1000,   // mask scape vc, valid only for full adaptive       
    parameter ROUTE_SUBFUNC="XY"

)(
    ovc_avalable_all,
    dest_port_in_all,
    candidate_ovc_all,
    ivc_request_all,
    ovc_is_assigned_all,
    dest_port_out_all,
    masked_ovc_request_all,
    port_pre_sel,
    port_pre_sel_ld_all,
    current_x_0,
    x_diff_is_one_all,
    sel,
    reset,
    clk
    
);
    localparam  P = 5;
    
    localparam  P_1     =   P-1,
                PV      =   V       *   P,
                PVV     =   PV      *  V,
                PVP_1   =   PV      *   P_1,
                VP_1    =   V       *   P_1;
                
     localparam LOCAL   =   3'd0,  
                EAST    =   3'd1, 
                NORTH   =   3'd2,  
                WEST    =   3'd3,  
                SOUTH   =   3'd4;  

    input   [PV-1       :   0]  ovc_avalable_all;
    input   [PVP_1-1    :   0]  dest_port_in_all;
    input   [PV-1       :   0]  ivc_request_all;
    input   [PV-1       :   0]  ovc_is_assigned_all;
    output  [PVP_1-1    :   0]  dest_port_out_all;
    output  [PVV-1      :   0]  masked_ovc_request_all;
    input   [PVV-1      :   0]  candidate_ovc_all;
    input   [P_1-1      :   0]  port_pre_sel;
    input   [PV-1       :   0]  port_pre_sel_ld_all;
    output  [PV-1       :   0]  sel;
    input                       reset,clk,current_x_0;
    input   [PV-1       :   0]  x_diff_is_one_all;
    
    wire    [PV-1       :   0]  non_assigned_ovc_request_all; 
    wire    [PV-1       :   0]  route_subfunc_violated;
    wire    [V-1        :   0]  ovc_avb_x_plus,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_y_minus,ovc_avb_local;
    wire    [VP_1-1     :   0]  ovc_avalable_perport        [P-1    :   0];
    wire    [P_1-1      :   0]  port_pre_sel_perport             [P-1    :   0];
    wire    [PVV-1      :   0]  candidate_ovc_x_all, candidate_ovc_y_all;
   
    assign non_assigned_ovc_request_all =   ivc_request_all & ~ovc_is_assigned_all;   
    assign {ovc_avb_y_minus,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_x_plus,ovc_avb_local} = ovc_avalable_all;
    
    assign ovc_avalable_perport[LOCAL]  = {ovc_avb_x_plus,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_y_minus};
    assign ovc_avalable_perport[EAST]   = {ovc_avb_local,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_y_minus};
    assign ovc_avalable_perport[NORTH]  = {ovc_avb_x_plus,ovc_avb_x_minus,ovc_avb_local,ovc_avb_y_minus};
    assign ovc_avalable_perport[WEST]   = {ovc_avb_x_plus,ovc_avb_local,ovc_avb_y_plus,ovc_avb_y_minus};
    assign ovc_avalable_perport[SOUTH]  = {ovc_avb_x_plus,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_local};
    
    
    assign port_pre_sel_perport[LOCAL]   = port_pre_sel;
    assign port_pre_sel_perport[EAST]    = {2'b00,port_pre_sel[1:0]};
    assign port_pre_sel_perport[NORTH]   = {1'b0,port_pre_sel[2],1'b0,port_pre_sel[0]};
    assign port_pre_sel_perport[WEST]    = {port_pre_sel[3:2],2'b0};
    assign port_pre_sel_perport[SOUTH]   = {port_pre_sel[3],1'b0,port_pre_sel[1],1'b0};
    
     
    genvar i;
    generate 
    for(i=0;i< PV;i=i+1) begin :all_vc_loop
        
       adaptive_avb_ovc_mux #(
       	.V(V)
       )
       the_adaptive_avb_ovc_mux
       (
       	.ovc_avalable               (ovc_avalable_perport   [i/V]),
       	.sel                        (sel                    [i]),
       	.candidate_ovc_x            (candidate_ovc_x_all    [((i+1)*V)-1 : i*V]),
       	.candidate_ovc_y            (candidate_ovc_y_all    [((i+1)*V)-1 : i*V]),
       	.non_assigned_ovc_request   (non_assigned_ovc_request_all[i]),
       	.xydir                      (dest_port_in_all       [((i+1)*P_1)-1 : ((i+1)*P_1)-2]),
       	.masked_ovc_request         (masked_ovc_request_all [((i+1)*V)-1 : i*V])
       );
       
       
       
        portsel #(
	       .SW_LOC     (i/V),
	       .ROUTE_SUBFUNC (ROUTE_SUBFUNC)
        )
        the_portsel(
	       .reset              (reset),
	       .clk                (clk),
	       .port_pre_sel       (port_pre_sel_perport[i/V]),
	       .port_pre_sel_ld    (port_pre_sel_ld_all[i]),
	       .sel                (sel[i]),
	       .dest_port_in       (dest_port_in_all[((i+1)*P_1)-1 : i*P_1]),
	       .dest_port_out      (dest_port_out_all[((i+1)*P_1)-1 : i*P_1]),
	       .route_subfunc_violated(route_subfunc_violated[i])
	      );
	      
	      if(ROUTE_TYPE ==  "FULL_ADAPTIVE") begin: full_adpt
	         // In full adaptive a packet which can be set to both x and y direction is not allowed to use escape VC in the y direction 
             // The EVC can only forward the packet to another EVC
             
              if(  ESCAP_VC_MASK[i%V])  begin  // the sender is EVC
                 assign candidate_ovc_y_all[((i+1)*V)-1 : i*V] =  (route_subfunc_violated[i]) ? {V{1'b0}}:  // packet can not be sent to any EVC or AVC  
                                                                 candidate_ovc_all[((i+1)*V)-1 : i*V] & ESCAP_VC_MASK; // packet can be sent only to EVC                            
                assign candidate_ovc_x_all[((i+1)*V)-1 : i*V]=  candidate_ovc_all[((i+1)*V)-1 : i*V] & ESCAP_VC_MASK; // packet can be sent only to EVC               ;
        
              end else begin // the sender is AVC
                assign candidate_ovc_y_all[((i+1)*V)-1 : i*V] =  (route_subfunc_violated[i]) ? candidate_ovc_all[((i+1)*V)-1 : i*V] & (~ESCAP_VC_MASK) : // // packet can not be sent to any EVC
                                                                 candidate_ovc_all[((i+1)*V)-1 : i*V];// packet can  be sent to any EVC or AVC  
                assign candidate_ovc_x_all[((i+1)*V)-1 : i*V]=  candidate_ovc_all[((i+1)*V)-1 : i*V];
        
              end   
             
             
             //assign candidate_ovc_y_all[((i+1)*V)-1 : i*V] =  (route_subfunc_violated[i]) ? candidate_ovc_all[((i+1)*V)-1 : i*V] & (~ESCAP_VC_MASK) :  candidate_ovc_all[((i+1)*V)-1 : i*V];
                  
          end else begin : partial_adpt
              assign candidate_ovc_y_all[((i+1)*V)-1 : i*V] =   candidate_ovc_all [((i+1)*V)-1 : i*V];
              assign candidate_ovc_x_all[((i+1)*V)-1 : i*V]=  candidate_ovc_all[((i+1)*V)-1 : i*V];
          end// ROUTE_TYPE
    end//for
    
    
    
    
endgenerate








endmodule


/************************

    adaptive_avb_ovc_mux


************************/
module  adaptive_avb_ovc_mux #(
    parameter V= 4

)(
    ovc_avalable,
    sel,
    candidate_ovc_x, 
    candidate_ovc_y,
    non_assigned_ovc_request,
    xydir,
    masked_ovc_request
    

);
    localparam  P       =   5;
    localparam  P_1     =   P-1,
                VP_1    =   V  *  P_1;
                
    input   [VP_1-1    :    0] ovc_avalable;
    input                      sel;
    input   [V-1       :    0] candidate_ovc_x;
    input   [V-1       :    0] candidate_ovc_y;
    input                      non_assigned_ovc_request;
    input   [1         :    0] xydir;
    output  [V-1        :   0] masked_ovc_request;
    wire    x,y;
    wire    [V-1        :   0] ovc_avb_x_plus,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_y_minus;
    wire    [V-1        :   0] mux_out_x,mux_out_y;
    wire    [V-1        :   0] ovc_request_x,ovc_request_y,masked_ovc_request_x,masked_ovc_request_y;
    
    assign {x,y}= xydir;
    assign {ovc_avb_x_plus,ovc_avb_x_minus,ovc_avb_y_plus,ovc_avb_y_minus}=ovc_avalable;
    //first level mux
    //assign mux_out_x = (x)?  ovc_avb_x_plus :  ovc_avb_x_minus;
    //assign mux_out_y = (y)?  ovc_avb_y_plus :  ovc_avb_y_minus;
    assign mux_out_x = (ovc_avb_x_plus &{V{x}}) |  (ovc_avb_x_minus &{V{~x}});
    assign mux_out_y = (ovc_avb_y_plus &{V{y}}) |  (ovc_avb_y_minus &{V{~y}});
     
     
    //assign ovc_request_x = (non_assigned_ovc_request)? candidate_ovc_x : {V{1'b0}};
    //assign ovc_request_y = (non_assigned_ovc_request)? candidate_ovc_y : {V{1'b0}};
     assign ovc_request_x =  candidate_ovc_x & {V{non_assigned_ovc_request}};
    assign ovc_request_y =  candidate_ovc_y & {V{non_assigned_ovc_request}};
    
    //mask unavailble ovc
    assign masked_ovc_request_x = mux_out_x & ovc_request_x;
    assign masked_ovc_request_y = mux_out_y & ovc_request_y;
    
    //second mux 
   // assign masked_ovc_request = (sel)?  masked_ovc_request_y: masked_ovc_request_x;
     assign masked_ovc_request =  (masked_ovc_request_y & {V{sel}})| (masked_ovc_request_x & {V{~sel}});


endmodule





/*****************************************************

                portsel


*****************************************************/


module portsel #(
    parameter SW_LOC    = 0,
    parameter ROUTE_SUBFUNC="XY"

)
(
    port_pre_sel,
    dest_port_out,
    dest_port_in,
    port_pre_sel_ld,
    sel,
    route_subfunc_violated,
    reset,
    clk


);

/************************
                
        destination-port_in
            x:  1 EAST, 0 WEST  
            y:  1 NORTH, 0 SOUTH
            ab: 00 : LOCAL, 10: xdir, 01: ydir, 11 x&y dir 
        sel:
             0: xdir
             1: ydir
        port_pre_sel
             0: xdir
             1: ydir  

************************/


    input           reset,clk;
    input   [3:0]   port_pre_sel;
    input           port_pre_sel_ld;
    output          sel;
    input   [3:0]   dest_port_in;
    output  [3:0]   dest_port_out;
    output          route_subfunc_violated;
    
    wire  x,y,a,b;
    reg  [3:0] port_pre_sel_delayed , port_pre_sel_latched;
    wire o1,o2;
    reg [4:0] portout;

    localparam LOCAL    =       3'd0,  
               EAST     =       3'd1, 
               NORTH    =       3'd2,  
               WEST     =       3'd3,  
               SOUTH    =       3'd4;  

    localparam LOCAL_SEL = (SW_LOC == NORTH || SW_LOC == SOUTH )? 1'b1 : 1'b0; 
   
    assign {x,y,a,b} = dest_port_in;
    // the destination port must not change after assigning OVC. latch the port_pre_sel result after assigning OVC.  
     always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            port_pre_sel_delayed <= 4'd0;
            port_pre_sel_latched <= 4'd0;
        end else begin 
            if(port_pre_sel_ld) port_pre_sel_delayed <= port_pre_sel;
            if(port_pre_sel_ld) port_pre_sel_latched <= port_pre_sel;
            else                port_pre_sel_latched <= port_pre_sel_delayed;
            
        end
    end
    
   // assign port_pre_sel_latched = (port_pre_sel_ld)? port_pre_sel : port_pre_sel_delayed; 

    // mux1
    assign o1 = (x&y & port_pre_sel_latched[3] ) | (~x&~y & port_pre_sel_latched[0] );
    assign o2 = (~x&y & port_pre_sel_latched[1] ) | (x&~y & port_pre_sel_latched[2] );
    //mux2
    assign sel= (~a&b)|(a&b&(o1|o2))|(~a&~b& LOCAL_SEL);
    
    generate 
    if(ROUTE_SUBFUNC=="XY") begin 
        assign route_subfunc_violated = a&b;
    end else begin
        assign route_subfunc_violated = a&b&y;    
    end
    endgenerate
    
    
    always @(*)begin 
        case({a,b})
            2'b10 : portout = {1'b0,~x,1'b0,x,1'b0};
            2'b01 : portout = {~y,1'b0,y,1'b0,1'b0};
            2'b11 : portout = (port_pre_sel_latched[{x,y}])?  {~y,1'b0,y,1'b0,1'b0} : {1'b0,~x,1'b0,x,1'b0} ;
            2'b00 : portout =  5'b00001;
         endcase
   end //always
    
    remove_sw_loc_one_hot #(
    	.P(5),
    	.SW_LOC(SW_LOC)
    )conv
    (
    	.destport_in(portout),
    	.destport_out(dest_port_out)
    );
    
  

endmodule


module  vc_alloc_request_gen_adaptive_classic #(
    parameter V = 4,
    parameter ROUTE_TYPE           =  "FULL_ADAPTIVE",    // "FULL_ADAPTIVE", "PAR_ADAPTIVE"  
    parameter [V-1  :   0] ESCAP_VC_MASK = 4'b001,   // mask scape vc, valid only for full adaptive  
    parameter ROUTE_SUBFUNC = "XY"

)(
    ovc_avalable_all,
    dest_port_in_all,
    candidate_ovc_all,
    ivc_request_all,
    ovc_is_assigned_all,
    dest_port_out_all,
    masked_ovc_request_all,
    port_pre_sel,
    port_pre_sel_ld_all,
    sel,
    reset,
    clk
    
);
    localparam  P = 5;
    
    localparam  P_1     =   P-1,
                PV      =   V       *   P,
                PVV     =   PV      *  V,
                PVP_1   =   PV      *   P_1,
                VP_1    =   V       *   P_1;
                
     localparam LOCAL   =   3'd0,  
                EAST    =   3'd1, 
                NORTH   =   3'd2,  
                WEST    =   3'd3,  
                SOUTH   =   3'd4;  

    input   [PV-1       :   0]  ovc_avalable_all;
    input   [PVP_1-1    :   0]  dest_port_in_all;
    input   [PV-1       :   0]  ivc_request_all;
    input   [PV-1       :   0]  ovc_is_assigned_all; 
    output  [PVP_1-1    :   0]  dest_port_out_all;
    output  [PVV-1      :   0]  masked_ovc_request_all;
    input   [PVV-1      :   0]  candidate_ovc_all;
    input   [P_1 -1     :   0]  port_pre_sel;
    input   [PV-1       :   0]  port_pre_sel_ld_all;
    output  [PV-1       :   0]  sel;
    input                       reset,clk;

    wire    [PV-1       :   0]  non_assigned_ovc_request_all; 
    wire    [P_1-1      :   0]  port_pre_sel_perport        [P-1    :   0];
    wire    [VP_1-1     :   0]  ovc_avalable_perport        [P-1    :   0];  
    wire    [VP_1-1     :   0]  ovc_avalable_ivc            [PV-1   :   0];
    wire    [P_1-1      :   0]  dest_port_ivc               [PV-1   :   0];
    wire    [V-1        :   0]  ovc_avb_muxed               [PV-1   :   0];  
    wire    [V-1        :   0]  ovc_request_ivc             [PV-1   :   0];
    wire    [PVV-1      :   0]  candidate_ovc_all_muxed;
    
    wire    [PVV-1      :   0]  candidate_ovc_x_all, candidate_ovc_y_all;
    wire    [PV-1       :   0]  route_subfunc_violated;
    
    assign non_assigned_ovc_request_all  = ivc_request_all & ~ovc_is_assigned_all;  
    assign port_pre_sel_perport[LOCAL]   = port_pre_sel;
    assign port_pre_sel_perport[EAST]    = {2'b00,port_pre_sel[1:0]};
    assign port_pre_sel_perport[NORTH]   = {1'b0,port_pre_sel[2],1'b0,port_pre_sel[0]};
    assign port_pre_sel_perport[WEST]    = {port_pre_sel[3:2],2'b0};
    assign port_pre_sel_perport[SOUTH]   = {port_pre_sel[3],1'b0,port_pre_sel[1],1'b0};
   

genvar i;
generate
 //remove avalable ovc of reciver port 
    for(i=0;i< P;i=i+1) begin :port_loop
        if(i==0) assign ovc_avalable_perport[i]=ovc_avalable_all [PV-1              :   V];
        else if(i==(P-1)) assign ovc_avalable_perport[i]=ovc_avalable_all [PV-V-1               :   0];
        else    assign ovc_avalable_perport[i]={ovc_avalable_all [PV-1  :   (i+1)*V],ovc_avalable_all [(i*V)-1  :   0]};
    end
        
    // IVC loop
    for(i=0;i< PV;i=i+1) begin :total_vc_loop
        //seprate input/output
        assign ovc_avalable_ivc[i]  =   ovc_avalable_perport[(i/V)];
        assign dest_port_ivc   [i]  =   dest_port_out_all [(i+1)*P_1-1  :   i*P_1   ];
        assign ovc_request_ivc [i]  = (non_assigned_ovc_request_all[i])? candidate_ovc_all_muxed  [(i+1)*V-1  :   i*V ]: {V{1'b0}};
        assign candidate_ovc_all_muxed[(i+1)*V-1 : i*V] = (sel[i]) ? candidate_ovc_y_all [(i+1)*V-1 : i*V] : candidate_ovc_x_all [(i+1)*V-1 : i*V]; 
       
        //available ovc multiplexer
        one_hot_mux #(
            .IN_WIDTH       (VP_1),
            .SEL_WIDTH      (P_1)
        )
        multiplexer
        (
            .mux_in     (ovc_avalable_ivc   [i]),
            .mux_out    (ovc_avb_muxed      [i]),
            .sel        (dest_port_ivc      [i])

        );
        
        // mask unavailable ovc from requests
        assign masked_ovc_request_all  [(i+1)*V-1   :   i*V ]     =   ovc_avb_muxed[i] & ovc_request_ivc [i];
        
           
         
       
        portsel_classic #(
           .SW_LOC    (i/V),
           .ROUTE_SUBFUNC   (ROUTE_SUBFUNC)
        )
        the_portsel(
           .reset             (reset),
           .clk               (clk),
           .port_pre_sel      (port_pre_sel_perport[i/V]),
           .port_pre_sel_ld       (port_pre_sel_ld_all[i]),
           .sel               (sel[i]),
           .dest_port_in      (dest_port_in_all[((i+1)*P_1)-1 : i*P_1]),
           .dest_port_out     (dest_port_out_all[((i+1)*P_1)-1 : i*P_1]),
          // .multi_dir         (multi_dir[i])
           .route_subfunc_violated    (route_subfunc_violated[i])
        );
           if(ROUTE_TYPE ==  "FULL_ADAPTIVE") begin: full_adpt
             // in full adaptive a packet which can be set to both x and y direction is not allowed to use escape VC in the y direction 
              assign candidate_ovc_y_all[((i+1)*V)-1 : i*V]=  (route_subfunc_violated[i]) ? candidate_ovc_all[((i+1)*V)-1 : i*V] & (~ESCAP_VC_MASK) :  candidate_ovc_all[((i+1)*V)-1 : i*V];       
          end else begin : partial_adpt
              assign candidate_ovc_y_all[((i+1)*V)-1 : i*V] =   candidate_ovc_all [((i+1)*V)-1 : i*V];
          end// ROUTE_TYPE
    end//for
    
    assign candidate_ovc_x_all=  candidate_ovc_all;
        
    
    
endgenerate



endmodule



module portsel_classic #(
    parameter SW_LOC    = 0,
    parameter ROUTE_SUBFUNC="XY"

)
(
    port_pre_sel,
    dest_port_out,
    dest_port_in,
    port_pre_sel_ld,
    sel,
    route_subfunc_violated,
    reset,
    clk


);

/************************
                
        destination-port_in
            x:  1 EAST, 0 WEST  
            y:  1 NORTH, 0 SOUTH
            ab: 00 : LOCAL, 10: xdir, 01: ydir, 11 x&y dir 
        sel:
             0: xdir
             1: ydir
        port_pre_sel
             0: xdir
             1: ydir  

************************/


    input           reset,clk;
    input   [3:0]   port_pre_sel;
    input           port_pre_sel_ld;
    output          sel;
    input   [3:0]   dest_port_in;
    output  [3:0]   dest_port_out;
    output          route_subfunc_violated;
    
    wire  x,y,a,b;
    reg  [3:0] port_pre_sel_delayed ,  port_pre_sel_latched;
    
    reg [4:0] portout;

    localparam LOCAL    =       3'd0,  
               EAST     =       3'd1, 
               NORTH    =       3'd2,  
               WEST     =       3'd3,  
               SOUTH    =       3'd4;  

    
   
    assign {x,y,a,b} = dest_port_in;
    // the destination port must not change after assigning OVC. latch the port_pre_sel result after assigning OVC.  
    always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            port_pre_sel_delayed <= 4'd0;
            port_pre_sel_latched <= 4'd0;
        end else begin 
            if(port_pre_sel_ld) port_pre_sel_delayed <= port_pre_sel;
            if(port_pre_sel_ld) port_pre_sel_latched <= port_pre_sel;
            else                port_pre_sel_latched <= port_pre_sel_delayed;
            
        end
    end
    
    always @(*)begin 
        case({a,b})
            2'b10 : portout = {1'b0,~x,1'b0,x,1'b0};
            2'b01 : portout = {~y,1'b0,y,1'b0,1'b0};
            2'b11 : portout = (port_pre_sel_latched[{x,y}])?  {~y,1'b0,y,1'b0,1'b0}: {1'b0,~x,1'b0,x,1'b0} ;
            2'b00 : portout =  5'b00001;
         endcase
   end //always
    
   assign sel =  portout[NORTH] | portout[SOUTH];
    
    remove_sw_loc_one_hot #(
        .P(5),
        .SW_LOC(SW_LOC)
    )conv
    (
        .destport_in(portout),
        .destport_out(dest_port_out)
    );
    
    generate 
    if(ROUTE_SUBFUNC=="XY") begin 
        assign route_subfunc_violated = a&b;
    end else begin
        assign route_subfunc_violated = a&b&y;    
    end
    endgenerate
    
    


endmodule


