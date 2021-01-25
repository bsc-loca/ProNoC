
`ifdef     INCLUDE_TEST_LOCALPARAM


localparam REPEAT_NUM=600;

    localparam 
        T1 = 3,
        T2 = 3,
	T3 = 1,
	SYS_CACHE_EN=1,
        NUM_OF_RNs=4,
        NUM_OF_HNs=4,
        NUM_OF_SNs=1;

    localparam VERBOSITY = 0
       //| MONITORE_FLIT_INJECT
      // | MONITORE_FLIT_INJECT_FILEDS
       | MONITORE_TXN_CMD 
       | MONITORE_WAIT_LIST
       | MONITORE_CACHE 
       | MONITORE_SNPF 
       | MONITORE_TXNID_GEN 
       | MONITORE_MAIN_MEM 
       | MONITORE_REQ_TYPE
       | MONITORE_EXCL_TXN
       | MONITORE_REQ_LKPT
       |0;


`endif
