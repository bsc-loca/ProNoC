`ifdef     INCLUDE_TEST_PATTERN  

	pck_injct_trace_file[0] =1'b0;
	pck_injct_trace_file[1] =1'b0;

	#25000

	pck_injct_trace_file[0] =1'b1;
end //initial

initial begin 

	file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/norm16/sample/validation_16_trace.bin", "rb");
	@(posedge pck_injct_trace_file[0]) #1	
	pck_inject_rd_trace(2*REPEAT_NUM);
	$fclose(file);
	#10100;  

`endif




