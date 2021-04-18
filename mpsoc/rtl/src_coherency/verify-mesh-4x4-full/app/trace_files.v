//           2227350 ns:RN[          3] is hanged at line        595 for     100000 clk cycle  tim fsm state : 2
//           2278130000:RN[          5] is hanged at line        817 for     100000 clk cycle

`ifdef INCLUDE_TEST_LOCALPARAM
 	 function reg[256*8-1:0] get_trace_file;
 		 input integer rn_id; begin
 		 case(rn_id) 
 			0: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_0.bin";
 			1: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_10.bin";
 			2: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_11.bin";
 			3: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_12.bin";
 			4: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_13.bin";
 			5: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_14.bin";
 			6: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_15.bin";
 			7: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_1.bin";
 			8: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_2.bin";
 			9: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_3.bin";
 			10: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_4.bin";
 			11: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_5.bin";
 			12: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_6.bin";
 			13: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_7.bin";
 			14: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_8.bin";
 			15: get_trace_file="/home/alireza/work/git/hca_git/traces/failed/HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/trace_9.bin";
 		endcase
		end
	endfunction
`endif


	



