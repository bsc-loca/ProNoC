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


my_traces2=(HYDRO/tests_Lcals-HYDRO-1D_0_0_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_1_1_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_2_2_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_4_4_A72A53_16_0_16T/m5out
HYDRO/tests_Lcals-HYDRO-1D_8_8_A72A53_16_0_16T/m5out
SWFFT/tests_SWFFT_2_2_A72A53_16_0_16T/m5out
Stream/tests_Stream-DOT_0_0_A72A53_16_0_16T/m5out
Stream/tests_Stream-DOT_1_1_A72A53_16_0_16T/m5out
Stream/tests_Stream-DOT_2_2_A72A53_16_0_16T/m5out
Stream/tests_Stream-DOT_4_4_A72A53_16_0_16T/m5out
Stream/tests_Stream-DOT_8_8_A72A53_16_0_16T/m5out
VOL3D/tests_Apps-VOL3D_0_0_A72A53_16_0_16T/m5out
VOL3D/tests_Apps-VOL3D_1_1_A72A53_16_0_16T/m5out
VOL3D/tests_Apps-VOL3D_2_2_A72A53_16_0_16T/m5out
VOL3D/tests_Apps-VOL3D_4_4_A72A53_16_0_16T/m5out
VOL3D/tests_Apps-VOL3D_8_8_A72A53_16_0_16T/m5out
XSBench/tests_XSBench_0_0_A72A53_16_0_16T/m5out
XSBench/tests_XSBench_1_1_A72A53_16_0_16T/m5out
XSBench/tests_XSBench_2_2_A72A53_16_0_16T/m5out
XSBench/tests_XSBench_4_4_A72A53_16_0_16T/m5out
XSBench/tests_XSBench_8_8_A72A53_16_0_16T/m5out
example1/tests_example1_0_0_A72A53_16_0_16T/m5out
example1/tests_example1_1_1_A72A53_16_0_16T/m5out
example1/tests_example1_2_2_A72A53_16_0_16T/m5out
example1/tests_example1_4_4_A72A53_16_0_16T/m5out
example1/tests_example1_8_8_A72A53_16_0_16T/m5out
miniAMR27/tests_miniAMR27pt+unrolli1j2_2_2_A72A53_16_0_16T/m5out
miniAMR27/tests_miniAMR27pt_0_0_A72A53_16_0_16T/m5out
miniAMR7/tests_miniAMR7pt+unrolli2j3fusion_1_1_A72A53_16_0_16T/m5out
miniAMR7/tests_miniAMR7pt+unrolli2j3fusion_8_8_A72A53_16_0_16T/m5out
miniAMR7/tests_miniAMR7pt_0_0_A72A53_16_0_16T/m5out)



rn_nums=16
#my_traces=( "tests_Apps-LTIMES_0b_8T" )


script_path=$(pwd)
parent_path="$script_path/.."
src_verilator="$parent_path/../src_verilator/"
trace_gen_path="$parent_path/../trace_gen/"


if [[ -z "${PRONOC_WORK}" ]]; then
   comp_path=~/injector/verilator
else
   comp_path=${PRONOC_WORK}/injector/verilator
fi

work_path=$comp_path/work
rtl_work=$work_path/rtl_work
processed_rtl=$work_path/processed_rtl
obj_dir=$processed_rtl/obj_dir




if [[ -z "${PRONOC_WORK}" ]]; then
   trace_dir=/scratch/traces_alireza/
else
   trace_dir=/home/alireza/work/hca_git/traces/
fi




function gen_verilator_libs {
	echo ""
	bash "$src_verilator/verilator.sh" $script_path "tmp" 0
	wait
	compile_trace_gen
}




function gen_trace_files_v {
	trace_name=$1
	file="
	\`ifdef     INCLUDE_TEST_LOCALPARAM\n
	\t function reg[256*8-1:0] get_trace_file;\n
	\t\t input integer rn_id; begin\n   
	\t\t case(rn_id) \n
	" 
	i=0
	yourfilenames=`ls ${trace_dir}$trace_name/*.bin`
	for entry in $yourfilenames
	do   
  		
		file="$file \t\t\t$i: get_trace_file=\"$entry\";\n"
		((i++)) 
	done
	
	m=$(expr $rn_nums - 1)
	until [ $i -gt $m ]
	do
		file="$file \t\t\t$i: get_trace_file=\"OFF\";\n"    
		((i++))
	done




	file=" $file \t\tendcase\n\t\tend\n\tendfunction\n\`endif\n"

	mkdir -p "$comp_path/$trace_name/"
	echo -e $file > "$comp_path/$trace_name/trace_files.v"
	echo "creat $comp_path/$trace_name/trace_files.v"

}





function gen_param_h {
	traces_file=$1
	cp -f $src_verilator/gen_param_h.pl $processed_rtl/
	cd $processed_rtl
	cp -f $parent_path/test_localparam.v  $processed_rtl/
	cp -f $parent_path/topology_mapping.v $processed_rtl/
	rm -f parameter.h
	perl gen_param_h.pl test_localparam.v topology_mapping.v $traces_file
	wait
	mv -f parameter.h $obj_dir/
	cd $script_path
}


function copy_verilator_srcs {
        find  $src_verilator -name \*.h -exec cp -f '{}' $obj_dir/ \;	
	cp -f $src_verilator/testbench.cpp	$obj_dir/
}






function gen_testbenche_files {
	
	for trace_name in "${my_traces[@]}"  
	do
		echo "Prepare simulation for $trace_name "
		gen_trace_files_v $trace_name
		gen_param_h "$comp_path/$trace_name/trace_files.v"
		rm -rf	"$comp_path/$trace_name/obj_dir"	
		cp -Rf  $obj_dir  "$comp_path/$trace_name/obj_dir"
		wait
	done
}


function compile_testbenche_files {
	 echo "compile  testbench"	
	for trace_name in "${my_traces[@]}"  
	do
		cd  "$comp_path/$trace_name/obj_dir"; make sim &
	done
	wait
	cd $script_path
}


function run_all_simulation {
        echo "run simulation"
	for trace_name in "${my_traces[@]}"  
	do
		cd "$comp_path/$trace_name/obj_dir"; ./testbench &
	done
	wait
	cd $script_path

}

function collect_results {
	
	cmd='paste -d  "," ' 

	cmd="$cmd $comp_path/${my_traces[0]}/obj_dir/performance_result_name.txt"

	for trace_name in "${my_traces[@]}"    
	do
		cmd="$cmd $comp_path/$trace_name/obj_dir/performance_result_num.txt"
	done
	
	eval  "$cmd" > Result_random_all.txt


	
	#collect error files
	mkdir -p "errors"
	maxsize=10	
	for trace_name in "${my_traces[@]}" 
	do
		ff="$cmd $comp_path/$trace_name/obj_dir/error_result.txt"
		filesize=$(stat -c%s "$ff")
		if (( filesize > maxsize )); then
		    cp  $ff "errors/err$trace_name.txt"
		fi
	done







}


gen_verilator_libs

copy_verilator_srcs 

gen_testbenche_files
 
compile_testbenche_files

run_all_simulation

collect_results



	

