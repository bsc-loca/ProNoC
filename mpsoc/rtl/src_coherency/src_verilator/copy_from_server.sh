#!/bin/bash

my_traces=(Grid+Wilson/tests_Grid+wilson_1_1_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_0_0_A72A53_16_0_16T/m5out
HPCG/tests_HPCG_0_0_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/m5out
Grid+Wilson/tests_Grid+wilson_2_2_A72A53_16_0_16T/m5out)

newlist=(Grid+Wilson/tests_Grid+wilson_8_8_A72A53_16_0_16T/m5out)

function copy_files {
	
	for trace_name in "${newlist[@]}"  
	do
		echo "Copy $trace_name "
		mkdir -p "/home/alireza/work/git/hca_git/traces/failed/$trace_name"
		sshpass -p "amonemi@epi1423" scp -r  "amonemi@epi01.bsc.es:/scratch/traces_alireza/$trace_name"   "/home/alireza/work/git/hca_git/traces/failed/$trace_name/"

	done
}


 copy_files
