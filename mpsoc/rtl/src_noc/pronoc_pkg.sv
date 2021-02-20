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
	T4 = 0,
	BEw = (BYTE_EN)? $clog2(Fpay/8) : 1;


 localparam CONGw= (CONGESTION_INDEX==3)?  3:
                      (CONGESTION_INDEX==5)?  3:
                      (CONGESTION_INDEX==7)?  3:
                      (CONGESTION_INDEX==9)?  3:
                      (CONGESTION_INDEX==10)? 4:
                      (CONGESTION_INDEX==12)? 3:2;


 localparam 
 	E_SRC_LSB =0,                   E_SRC_MSB = E_SRC_LSB + EAw-1,
 	E_DST_LSB = E_SRC_MSB +1,       E_DST_MSB = E_DST_LSB + EAw-1,  
 	DST_P_LSB = E_DST_MSB + 1,      DST_P_MSB = DST_P_LSB + DSTPw-1, 
 	CLASS_LSB = DST_P_MSB + 1,      CLASS_MSB = CLASS_LSB + Cw -1, 
 	MSB_CLASS = (C>1)? CLASS_MSB : DST_P_MSB,
 	WEIGHT_LSB= MSB_CLASS + 1,      WEIGHT_MSB = WEIGHT_LSB + WEIGHTw -1,
 	/* verilator lint_off WIDTH */ 
 	MSB_W = (SWA_ARBITER_TYPE== "WRRA")? WEIGHT_MSB : MSB_CLASS,
 	/* verilator lint_on WIDTH */
 	BE_LSB =  MSB_W + 1,            BE_MSB = BE_LSB+ BEw-1,
 	MSB_BE = (BYTE_EN==1)?   BE_MSB  : MSB_W;
	
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
		bit		sbp_en;
		bit     hdr_flit_req;
		logic 	[V-1 : 0]        ivc_sbp_en;
		logic   [DSTPw-1  :   0] lk_destport;
		logic   [DSTPw-1  :   0] destport;
		logic   [V-1 : 0] credit_out;
		logic   [V-1 : 0] buff_space_decreased;
		logic   [V-1 : 0] ovc_is_allocated;
		logic   [V-1 : 0] ovc_is_released;
		logic   [V-1 : 0] ivc_num_getting_ovc_grant;
		logic   [V-1 : 0] ivc_reset;
		logic   [V-1 : 0] mask_available_ovc;
		logic   [V*V-1: 0] ivc_granted_ovc_num;
	} sbp_ctrl_t;	
	localparam  SBP_CTRL_w = $bits(sbp_ctrl_t);
	
	/*****************
	 * port_info
	 * **************/
	typedef struct packed {
		logic [V-1 : 0] ivc_req; // input vc is not empty
		logic [V-1 : 0] swa_first_level_grant;// The vc number (one-hot) in an input port which get the first level switch allocator grant
		logic [V-1 : 0] swa_grant; // The VC number in an input port which got the swa grant
		logic [MAX_P-1 : 0] granted_oport_one_hot;	//The granted output port num (one-hot) for an input port	
		logic any_ivc_get_swa_grant;
		
	} iport_info_t;	
	localparam  IPORT_INFO_w = $bits(iport_info_t);
	
	typedef struct packed {
		logic [V-1 : 0] non_sbp_ovc_is_allocated;
		//logic [V-1 : 0] ovc_is_released;
		//logic [V-1 : 0] ovc_credit_increased; 
		//logic [V-1 : 0] ovc_credit_decreased;
		logic [V-1 : 0] ovc_avalable;
		bit crossbar_flit_wr;
			
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
* router_chanels 
*********************/
	
	typedef struct packed {	
		logic [EAw-1 	: 0] src_e_addr;
		logic [EAw-1 	: 0] dest_e_addr;
		logic [DSTPw-1	: 0] destport;    
		logic [Cw-1		: 0] message_class;
		logic [WEIGHTw-1: 0] weight;
		logic [BEw-1 	: 0] be;		
	} hdr_flit_t;
	localparam HDR_FLIT_w = $bits(hdr_flit_t); 
	
	
   	
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
		bit   hdr_flit;
	} sbp_chanel_t;
	localparam SBP_CHANEL_w = $bits(sbp_chanel_t);
	
	
	typedef struct packed {
		flit_chanel_t  flit_chanel;
		sbp_chanel_t   sbp_chanel; 		
	} router_chanel_t;
	localparam ROUTER_CHANEL_w = $bits(router_chanel_t); 
	
	
/***********
 * simulation
 * **********/
 	typedef struct packed {
 		integer   ip_num;
		bit send_enable;
		integer  percentage; // x10	
 	} hotspot_t;		
	
endpackage : pronoc_pkg


