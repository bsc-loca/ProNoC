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
	WRRA_CONFIG_INDEX=0,
	SBP_MAX = 0,  
	SBP_EN = (SBP_MAX !=0),
	SBP_NUM= (SBP_EN) ? SBP_MAX : 1,
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
*    sbp 
*********************/
	typedef struct packed {
		logic [EAw-1 : 0] dest_e_addr;
		logic ovc_is_assigned;
		logic [Vw-1   : 0] assigned_ovc_bin;		
	} sbp_ivc_info_t;
	localparam SBP_IVC_w = $bits(sbp_ivc_info_t);
	
	
	
	typedef struct packed {
		logic 	sbp_en;
		logic   [DSTPw-1  :   0] lk_route;
		logic   [V-1 : 0] credit_out;
		logic   [V-1 : 0] buff_space_decreased;
		logic   [V-1 : 0] ovc_is_allocated;
		logic   [V-1 : 0] ovc_is_released;	
		logic   [V-1 : 0] ovc_is_masked;
	} sbp_ctrl_out_t;	
	
	/*****************
	 * port_info
	 * **************/
	typedef struct packed {
		logic [V-1 : 0] swa_first_level_grant;// The vc number (one-hot) in an input port which get the first level switch allocator grant
		logic [V-1 : 0] swa_grant; // The VC number in an input port which got the swa grant
		logic [MAX_P-1 : 0] granted_oport_one_hot;	//The granted output port num (one-hot) for an input port	
		logic any_ivc_get_swa_grant;		
	} iport_info_t;	
	localparam  IPORT_INFO_w = $bits(iport_info_t);
	
	typedef struct packed {
		logic [V-1 : 0] ovc_is_allocated;
		logic [V-1 : 0] ovc_is_released;
		logic [V-1 : 0] ovc_credit_increased; 
		logic [V-1 : 0] ovc_credit_decreased;
		bit any_ovc_get_swa_grant;
	}oport_info_t;	
	localparam  OPORT_INFO_w = $bits(oport_info_t);
	
	/*********************
	 * ivc 
	 *******************/
		
	
	typedef struct packed {
		logic [EAw-1 : 0] dest_e_addr;
		logic ovc_is_assigned;
		logic [V-1   : 0] assigned_ovc_num;	
		logic [Vw-1  : 0] assigned_ovc_bin;
		logic [MAX_P-1   : 0] destport_one_hot;
		logic ivc_req; // input vc is not empty
		logic flit_is_tail;
		logic assigned_ovc_not_full;
		logic [V-1  : 0] candidate_ovc;
		logic [Cw-1 : 0] class_num; 
		logic getting_swa_first_arbiter_grant;// got switch allocator first arbiter grant (valid for non-spec combination only) 
		logic getting_swa_grant;// got both first and second switch allocator
		
	} ivc_info_t;
	localparam  IVC_INFO_w = $bits( ivc_info_t);
	
	
	typedef struct packed {
		logic ss_ovc_avalable;
		logic assigned_to_ss_ovc;	
	} ivc_ss_ovc_info_t;
	localparam  IVC_SSOVC_INFO_w = $bits(ivc_ss_ovc_info_t);
    
	
/*********************
* router_channels 
*********************/
   	
	typedef struct packed {
		bit hdr_flag;
		bit tail_flag;
		logic [V-1 : 0] vc;
		logic [Fpay-1 : 0] payload;		
	} flit_t;
	localparam FLIT_w = $bits(flit_t); 
	
	typedef struct packed {
		logic  [RAw-1:  0]  neighbors_r_addr;
		flit_t  flit;
		logic  flit_wr;
		logic  [V-1 :  0]  credit;
		logic  [CONGw-1 :  0]  congestion;		
	} flit_chanel_t;
	localparam FLIT_CHANEL_w = $bits(flit_chanel_t); 
	
	
	typedef struct packed {
		logic [V-1   	: 0] ovc;
		logic [SBP_NUM-1: 0] requests;
		logic [EAw-1 	: 0] dest_e_addr;		
	} sbp_chanel_t;
	localparam SBP_LINK_w = $bits(sbp_chanel_t);
	
	
	typedef struct packed {
		flit_chanel_t  flit_chanel;
		sbp_chanel_t   sbp_chanel; 		
	} router_chanel_t;
	localparam ROUTER_CHANEL_w = $bits(router_chanel_t); 
	
	
endpackage : pronoc_pkg


