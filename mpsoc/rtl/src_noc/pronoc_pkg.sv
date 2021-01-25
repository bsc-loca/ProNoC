
    
    
/****************************************************************************
 * pronoc_pkg.sv
 ****************************************************************************/
package pronoc_pkg; 
  
  
`define NOC_LOCAL_PARAM
`include "noc_localparam.v"

`define     INCLUDE_TOPOLOGY_LOCALPARAM
`include "topology_localparam.v"



localparam
	Vw=  $clog2(V),
	Cw=  (C==0)? 1 : $clog2(C),
	SBP_NUM=2,
	Fw = 2+V+Fpay,    //flit width;  ;
	NEFw = NE *Fw,
	NEV  = NE * V,
	T4 = 0;


 localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;

/*********************
 * router_interface 
 * *****************/
   	
	typedef struct packed {
		bit hdr_flag;
		bit tail_flag;
		logic [V-1 : 0] vc;
	} flit_append_t;
	
	
	typedef struct packed {
		logic  [RAw-1:  0]  neighbors_r_addr;
	    logic  [Fw-1 :  0]  flit;
		logic  flit_wr;
		logic  [V-1 :  0]  credit;
		logic  [CONGw-1 :  0]  congestion;
	} router_channel_t;
	localparam CHANEL_w = $bits(router_channel_t); 
		
	
/*********************
*    sbp struct
*********************/
	typedef struct packed {
		logic [EAw-1 : 0] dest_e_addr;
		logic ovc_is_assigned;
		logic [Vw-1   : 0] assigned_ovc_bin;
		
	} spb_ivc_t;
	localparam SPB_IVC_w = $bits(spb_ivc_t);
	
	typedef struct packed {
		logic [V-1   	: 0] ovc;
		logic [SBP_NUM-1: 0] flags;
		logic [EAw-1 	: 0] destination;		
	} spb_link_t;
	localparam SPB_LINK_w = $bits(spb_link_t);
	
	
	
	
	typedef struct packed {
		logic 	spb_en;
		logic   [DSTPw-1  :   0] lk_route;
		logic   [V-1 : 0] credit_out;
		logic   [V-1 : 0] buff_space_decreased;
		logic   [V-1 : 0] ovc_is_allocated;
		logic   [V-1 : 0] ovc_is_released;	
	} sbp_ctrl_out_t;	
	
	
	
	
	
 
	
	
	
	
	
    
    
	
	
	
	
	
endpackage : pronoc_pkg


