
`ifdef     INCLUDE_TEST_LOCALPARAM


localparam REPEAT_NUM=1;

   localparam 
	DEBUG_EN=1,
        T1 = 3,
        T2 = 3,
	T3 = 1,
	SYS_CACHE_EN=1,
        NUM_OF_RNs=4,
        NUM_OF_HNs=4,
        NUM_OF_SNs=1,
	TOPOLOGY="MESH",
	ROUTE_NAME="XY",
      
       
       
	//snf param
	SNPF_WAY_NUM = 8,
        SNPF_ADDRw   = 44,
        SNPF_INDEXw  = 10,
        CACHE_WAY_NUM= 8,
        CACHE_INDEXw =10,
	MEM_RD_PIPE_LATENCY =50,
        MEM_WR_PIPE_LATENCY =500;


    localparam VERBOSITY = 0
       | MONITORE_FLIT_INJECT
      // | MONITORE_FLIT_OPCODE
       | MONITORE_TXN_CMD 
       | MONITORE_WAIT_LIST
       | MONITORE_CACHE 
       | MONITORE_SNPF 
       | MONITORE_TXNID_GEN 
       | MONITORE_MAIN_MEM 
       | MONITORE_REQ_TYPE
       | MONITORE_EXCL_TXN
       |0;


`endif
