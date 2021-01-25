
`ifdef     INCLUDE_TEST_LOCALPARAM


localparam REPEAT_NUM=10000000;

    localparam 
        T1 = 3,
        T2 = 3,
	T3 = 1,
	SYS_CACHE_EN=1,
        NUM_OF_RNs=4,
        NUM_OF_HNs=4,
        NUM_OF_SNs=1,
	WRAP_REQ_W=64;

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



	integer file;
	reg [63: 0] trace;
	integer  ignore_lines [99 : 0];

	// ignore lines should be in ordered
	integer ignore_line, trace_line;

	initial begin 
	    ignore_lines[0]=12000;
	    ignore_lines[1]=16;
	    ignore_lines[2]=20;
	    ignore_lines[3]=22;
	    ignore_lines[4]=0;//end
	end


`endif
