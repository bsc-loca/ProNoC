`ifdef INCLUDE_TEST_LOCALPARAM
 	 function reg[256*8-1:0] get_trace_file;
 		 input integer rn_id; begin
 		 case(rn_id) 
 			0: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace0.bin";
 			1: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace1.bin";
 			2: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace2.bin";
 			3: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace3.bin";
 			4: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace4.bin";
 			5: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace5.bin";
 			6: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace6.bin";
 			7: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace7.bin";
 			8: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace8.bin";
 			9: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace9.bin";
 			10: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace10.bin";
 			11: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace11.bin";
 			12: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace12.bin";
 			13: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace13.bin";
 			14: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace14.bin";
			15: get_trace_file="/home/alireza/work/hca_git/traces/random/delay6/trace15.bin";
 		endcase
		end
	endfunction
`endif

