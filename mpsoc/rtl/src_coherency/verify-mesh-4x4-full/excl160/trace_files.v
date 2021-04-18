
`ifdef     INCLUDE_TEST_LOCALPARAM




function reg[256*8-1:0] get_trace_file;
      input integer rn_id; begin   
        case(rn_id)
        0: get_trace_file="/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/verify-mesh-4x4/excl160/sample/validation_llsc-scalar_trace_0.bin";
        1: get_trace_file="/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/verify-mesh-4x4/excl160/sample/validation_llsc-scalar_trace_0.bin";
        2: get_trace_file="OFF";
        3: get_trace_file="OFF";
        4: get_trace_file="OFF";
        5: get_trace_file="OFF";
        6: get_trace_file="OFF";
        7: get_trace_file="OFF";
        8: get_trace_file="OFF";
        9: get_trace_file="OFF";
        10:get_trace_file="OFF";
        11:get_trace_file="OFF";
        12:get_trace_file="OFF";
        13:get_trace_file="OFF";
        14:get_trace_file="OFF";
        endcase
      end   
    endfunction // log2 


	

`endif
