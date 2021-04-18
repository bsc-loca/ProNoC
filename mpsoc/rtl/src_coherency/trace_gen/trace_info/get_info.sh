#!/bin/bash

my_traces=(EOS/tests_Lcals-EOS_0_0_A72A53_16_0_16T/m5out
EOS/tests_Lcals-EOS_1_1_A72A53_16_0_16T/m5out
EOS/tests_Lcals-EOS_2_2_A72A53_16_0_16T/m5out
EOS/tests_Lcals-EOS_4_4_A72A53_16_0_16T/m5out
EOS/tests_Lcals-EOS_8_8_A72A53_16_0_16T/m5out
Grid+Wilson/tests_Grid+wilson_1_1_A72A53_16_0_16T/m5out
Grid+Wilson/tests_Grid+wilson_2_2_A72A53_16_0_16T/m5out
Grid+Wilson/tests_Grid+wilson_4_4_A72A53_16_0_16T/m5out
Grid+Wilson/tests_Grid+wilson_8_8_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_0_0_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_1_1_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_2_2_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_4_4_A72A53_16_0_16T/m5out
HACCKernels/tests_HACCKernels_8_8_A72A53_16_0_16T/m5out
HPCG/tests_HPCG_0_0_A72A53_16_0_16T/m5out
HPCG/tests_HPCG_1_1_A72A53_16_0_16T/m5out
HPCG/tests_HPCG_2_2_A72A53_16_0_16T/m5out
HPCG/tests_HPCG_4_4_A72A53_16_0_16T/m5out
HPCG/tests_HPCG_8_8_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_0_0_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_1_1_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_2_2_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_4_4_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_8_8_A72A53_16_0_16T/m5out)

if [[ -z "${PRONOC_WORK}" ]]; then
   trace_dir=/scratch/traces_alireza/
else
   trace_dir=/home/alireza/work/hca_git/traces/
fi



function get_app_info {
	
	for trace_name in "${my_traces[@]}"  
	do
		
		./traceinfo -p ${trace_dir}$trace_name
		
		wait
	done
}



get_app_info
