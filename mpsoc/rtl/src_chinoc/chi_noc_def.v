
`ifndef _CHI_NOC_DEF
`define _CHI_NOC_DEF


//These defintion should be define based on amba_chi_pck
`define CHI_PCKG      chi_pkg     //amba_5_chi_c_pkg
`define REQ_FLIT_T    req_flit_t  //reqflit_t
`define RSP_FLIT_T    rsp_flit_t  //rspflit_t
`define DAT_FLIT_T    data_flit_t  //datflit_t
`define SNP_FLIT_T    snp_flit_t  //snpflit_t

`define TGT_ID_E  tgt_id  
`define SRC_ID_E  src_id 
`define SNP_TGT_WIDTH 24

`define NUM_PORTS   6  // 
`define NOC_TOPOLOGY   "STAR"  // "STAR", "MESH", "FATTREE" ...

//Do not change anything from here
`define REQ_CHI   1
`define DAT_CHI   2
`define RSP_CHI   3
`define SNP_CHI   4




`endif
