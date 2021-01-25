#!/bin/bash

trace_dir=/scratch/traces_alireza


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
HYDRO/tests_Lcals-HYDRO-1D_0_0_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_1_1_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_2_2_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_4_4_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_8_8_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_0_0_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_1_1_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_2_2_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_4_4_A72A53_16_0_16T/m5out
LTIMES/tests_Apps-LTIMES_8_8_A72A53_16_0_16T/m5out)


function gen_testbenche_files {
	
	for trace_name in "${my_traces[@]}"  
	do
		echo "Prepare simulation for $trace_name "
		#gen_trace_files_v $trace_name
		#gen_param_h "$comp_path/$trace_name/trace_files.v"
		#rm -rf	"$comp_path/$trace_name/obj_dir"	
		#cp -Rf  $obj_dir  "$comp_path/$trace_name/obj_dir"
		#wait
	done
}

 gen_testbenche_files
