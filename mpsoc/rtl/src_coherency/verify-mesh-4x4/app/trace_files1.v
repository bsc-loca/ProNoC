//5161850000:RN[          1] is hanged at line       6731 for     100000 clk cycle
`ifdef     INCLUDE_TEST_LOCALPARAM



	function reg[256*8-1:0] get_trace_file;
		input integer rn_id; begin   
		case(rn_id)
		0: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_0.bin";
		1: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_1.bin";
		2: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_2.bin";
		3: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_3.bin";
		4: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_4.bin";
		5: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_5.bin";
		6: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_6.bin";
		7: get_trace_file="/home/alireza/work/hca_git/traces/tread/trace/trace_7.bin";
		8: get_trace_file="OFF";
		9: get_trace_file="OFF";
		10:get_trace_file="OFF";
		11:get_trace_file="OFF";
		12:get_trace_file="OFF";
		13:get_trace_file="OFF";
		14:get_trace_file="OFF";
		endcase
		end   
	endfunction 


	

`endif
