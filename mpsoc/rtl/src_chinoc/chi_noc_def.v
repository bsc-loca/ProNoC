
`ifndef _CHI_NOC_DEF
`define _CHI_NOC_DEF


//These defintion should be define based on amba_chi_pck
`define CHI_PCKG      chi_pkg      //amba_5_chi_c_pkg
`define REQ_FLIT_T    req_flit_t   //reqflit_t
`define RSP_FLIT_T    rsp_flit_t   //rspflit_t
`define DAT_FLIT_T    data_flit_t  //datflit_t
`define SNP_FLIT_T    snp_flit_t   //snpflit_t

`define TGT_ID_E      tgt_id       
`define SRC_ID_E      src_id 
`define ADDR_E        addr
`define SNP_TGT_WIDTH 24


`define NUM_PORTS   6  // 
`define NOC_TOPOLOGY   "STAR"  // "STAR", "MESH", "FATTREE" ...

/*
localparam int RVOOO_RNI_NOC_PORT_ID  [HART_NUM    ] = '{0, 1};   1,0
  localparam int EACC_RNI_NOC_PORT_ID   [EACC_RNI_NUM] = '{2};       3,2
  localparam int L2C_HN_NOC_PORT_ID     [L2HN_NUM    ] = '{3, 4};  7,6,9,8
  localparam int CHI_XBAR_NOC_PORT_ID                  = 5;
*/
 

`define TGIDS_DEF localparam int CHI_NOC_PORT_ID  [`NUM_PORTS ] = '{0,1,2,8,9,10}; 
`define NUM_HOME_NODES 2
`define HOME_NODE_IDS_DEF localparam int HOME_NODE_IDS [`NUM_HOME_NODES ] = '{8,9}; 


//Assume we have 5 phtsical NoCs in CHi protocol. 
`define REQA_CHI   1
`define REQB_CHI   2
`define DAT_CHI    3
`define RSP_CHI    4
`define SNP_CHI    5

//Define which NoCs should have an Embeded SAM.
//SAM takes the requests address as input and return
//the home-node ID assigned to that address. 
//The home-node ID is replace the target id of the packet.
//define IS_EMBEDED_SAM as 0 to disable this feature
`define IS_EMBEDED_SAM  (NOC_ID == `REQA_CHI)  


`endif
