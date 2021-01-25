
`ifdef     INCLUDE_TEST_LOCALPARAM


    localparam REPEAT_NUM=10000000;

    localparam 
      	DEBUG_EN=1,
      	
      	//NoC param
        T1 = 3,
        T2 = 3,
        T3 = 1,
        T4 = 1,
        B  = 15,
        TOPOLOGY="MESH",
        ROUTE_NAME="XY",


	//agent nums
        SYS_CACHE_EN=1,
        NUM_OF_RNs=4,
        NUM_OF_HNs=4,
        NUM_OF_SNs=1,
       
	//snf param
	SNPF_WAY_NUM = 8,
        SNPF_ADDRw   = 44,
        SNPF_INDEXw  = 10,
        CACHE_WAY_NUM= 8,
        CACHE_INDEXw =10,

	//pck-injector 	
	WRAP_REQ_W=64,

	//snf param 
	MEM_RD_PIPE_LATENCY =50,
        MEM_WR_PIPE_LATENCY =500;



    localparam VERBOSITY = 0
       | MONITORE_FLIT_INJECT
      // | MONITORE_FLIT_INJECT_FILEDS
       | MONITORE_TXN_CMD 
     //  | MONITORE_WAIT_LIST
       | MONITORE_CACHE 
       | MONITORE_SNPF 
       | MONITORE_TXNID_GEN 
       | MONITORE_MAIN_MEM 
       | MONITORE_REQ_TYPE
       | MONITORE_EXCL_TXN
       |0;

 localparam 
        MAX_HNFs_ASSIGND_TO_A_SN = (NUM_OF_HNs  / NUM_OF_SNs) + ((NUM_OF_HNs  % NUM_OF_SNs)>0);

	integer  file [NUM_OF_RNs-1 : 0];
	


	// ignore lines should be in ordered

	reg  [NUM_OF_RNs-1 : 0] injct_done;

	

`endif
