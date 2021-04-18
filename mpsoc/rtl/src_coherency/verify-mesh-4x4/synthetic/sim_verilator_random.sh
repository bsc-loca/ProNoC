#!/bin/bash
rn_nums=15
trace_num_per_rnf=10000
delay_array=( 1 2 4 6 10 14 18 26 34 50 66 98 )  
min_addr="0"
max_addr="0xFFFF" 


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


trace_path="$comp_path/samples"




function gen_verilator_libs {
	
	bash "$src_verilator/verilator.sh" $script_path $trace_path 0
	wait
	compile_trace_gen
}




function compile_trace_gen {
	cd  $trace_gen_path
	make
        wait
	cd $script_path
}


function gen_trace_files {
	u=$1	 	
	mkdir -p "$trace_path/delay$max_delay"
	$trace_gen_path/tracegen -p "$trace_path/delay$max_delay" -r $rn_nums -t "RANDOM" -a $min_addr -b $max_addr -l 1 -u $u -L 100 -S 0 -n $trace_num_per_rnf
}


function gen_trace_files_v {
	max_delay=$1
	file="
	\`ifdef     INCLUDE_TEST_LOCALPARAM\n
	\t function reg[256*8-1:0] get_trace_file;\n
	\t\t input integer rn_id; begin\n   
	\t\t case(rn_id) \n
	" 

	i=0
        m=$(expr $rn_nums - 1)
	until [ $i -gt $m ]
	do
		file="$file \t\t\t$i: get_trace_file=\"$trace_path/delay$max_delay/trace$i.bin\";\n"    
		((i++))
	done

	file=" $file \t\tendcase\n\t\tend\n\tendfunction\n\`endif\n"

	echo -e $file > "$trace_path/delay$max_delay/trace_files.v"

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
	
	for max_delay in "${delay_array[@]}"  
	do
		echo "Generate trace file for $max_delay max delay"
		gen_trace_files $max_delay
		gen_trace_files_v $max_delay
		gen_param_h "$trace_path/delay$max_delay/trace_files.v"
		rm -rf	"$trace_path/delay$max_delay/obj_dir"	
		cp -Rf $obj_dir  "$trace_path/delay$max_delay/obj_dir"
		wait
	done
}


function compile_testbenche_files {
	for max_delay in "${delay_array[@]}"  
	do
		cd  "$trace_path/delay$max_delay/obj_dir"; make sim &
	done
	wait
	cd $script_path
}


function run_all_simulation {
	for max_delay in "${delay_array[@]}"  
	do
		cd "$trace_path/delay$max_delay/obj_dir"; ./testbench &
	done
	wait
	cd $script_path

}

function collect_results {
	
	cmd='paste -d  "," ' 

	cmd="$cmd $trace_path/delay${delay_array[0]}/obj_dir/performance_result_name.txt"

	for max_delay in "${delay_array[@]}"  
	do
		cmd="$cmd $trace_path/delay$max_delay/obj_dir/performance_result_num.txt"
	done
	
	eval  "$cmd" > Result_random_all.txt


	
	#collect error files
	mkdir -p "errors"
	maxsize=10	
	for max_delay in "${delay_array[@]}"  
	do
		ff="$trace_path/delay$max_delay/obj_dir/error_result.txt"
		filesize=$(stat -c%s "$ff")
		if (( filesize > maxsize )); then
		    cp  $ff "errors/err$max_delay.txt"
		fi
	done







}


gen_verilator_libs

copy_verilator_srcs 

gen_testbenche_files
 
compile_testbenche_files

run_all_simulation

collect_results

	

