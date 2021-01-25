#!/bin/bash


server="amonemi@epi03.bsc.es"
path=$PWD"/../.."

cpath="$path/src_coherency"
src_noc="$path/src_noc"
src_ram="$path/src_peripheral/ram"

my_array=( \	
	"$cpath/cache "
	"$cpath/rnf "
	"$cpath/src_verilator "
	"$cpath/chi_localparam.v "
	"$cpath/hnf "
	"$cpath/chi_noc "
	"$cpath/injector "   
	"$cpath/snf "
	"$cpath/trace_gen "	
)


my_snth=( \
	"$cpath/verify-mesh-4x4/app "	
	"$cpath/verify-mesh-4x4/synthetic "
	"$cpath/verify-mesh-4x4/testbench.v "
	"$cpath/verify-mesh-4x4/fake_sam.v "
	"$cpath/verify-mesh-4x4/test_localparam.v "
	"$cpath/verify-mesh-4x4/top_chi_noc.v "
	"$cpath/verify-mesh-4x4/topology_mapping.v "	
)
 

my_snth_full=( \
	"$cpath/verify-mesh-4x4-full/app_server "	
	"$cpath/verify-mesh-4x4-full/synthetic "
	"$cpath/verify-mesh-4x4-full/testbench.v "
	"$cpath/verify-mesh-4x4-full/fake_sam.v "
	"$cpath/verify-mesh-4x4-full/test_localparam.v "
	"$cpath/verify-mesh-4x4-full/top_chi_noc.v "
	"$cpath/verify-mesh-4x4-full/topology_mapping.v "	
)     










function copy_sources {
	sshpass -p "amonemi@epi1423" ssh  -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  rm -rf  "~/mpsoc"
	sshpass -p "amonemi@epi1423" ssh  -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  mkdir -p  "~/mpsoc"
	sshpass -p "amonemi@epi1423" ssh  -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  mkdir -p  "~/mpsoc/src_coherency/verify-mesh-4x4"
	sshpass -p "amonemi@epi1423" ssh  -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  mkdir -p  "~/mpsoc/src_coherency/verify-mesh-4x4-full"
	sshpass -p "amonemi@epi1423" ssh  -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  mkdir -p  "~/mpsoc/src_peripheral"
        
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r $src_ram   "$server:mpsoc/src_peripheral/ram"
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r $src_noc   "$server:mpsoc/"
	for i in "${my_array[@]}"; do
 		echo "copy $i on server"
		sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r $i  "$server:mpsoc/src_coherency/"
		
 	done

	for i in "${my_snth[@]}"; do
 		echo "copy $i on server"
		sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r $i  "$server:mpsoc/src_coherency/verify-mesh-4x4/"
		
 	done

	for i in "${my_snth_full[@]}"; do
 		echo "copy $i on server"
		sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r $i  "$server:mpsoc/src_coherency/verify-mesh-4x4-full/"
		
 	done
	
	

}


function copy_app_trace {
	
	sshpass -p "amonemi@epi1423" ssh  -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  mkdir -p  "~/app_trace"	
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r "/home/alireza/work/hca_git/traces/tests_example1_0b_8T"     "amonemi@epi03.bsc.es:app_trace/tests_example1_0b_8T"
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r "/home/alireza/work/hca_git/traces/tests_HACCKernels_0b_8T"  "amonemi@epi03.bsc.es:app_trace/"
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r "/home/alireza/work/hca_git/traces/tests_Apps-LTIMES_0b_8T"  "amonemi@epi03.bsc.es:app_trace/"
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r "/home/alireza/work/hca_git/traces/tests_Grid+wilson_0b_8T"  "amonemi@epi03.bsc.es:app_trace/"      

}


function login_in_server {
	sshpass -p amonemi@epi1423 ssh  -o "StrictHostKeyChecking no" -X amonemi@epi03.bsc.es
	source /eda/env.sh
	export PATH=$PATH:/opt/verilator/bin
}


function run_sim {
	cd ~/mpsoc/src_coherency/verify-mesh-4x4-full/app_server/
	stdbuf -o0 ./sim_verilator.sh 2>&1 | tee log.tx
	#check how many paralel sim running
	ps aux | grep testbench
}


function run_synthetic {
	cd ~/mpsoc/src_coherency/verify-mesh-4x4-full/synthetic/
	stdbuf -o0 ./sim_verilator_random.sh 2>&1 | tee log.tx
	#check how many paralel sim running
	ps aux | grep testbench
}

function create_screen {
	screen -S sim
}

function kill_screen {
	 screen -X -S sim quit
}



function copy_from_server {
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r   "amonemi@epi03.bsc.es:injector/verilator/samples/delay6"  "/home/alireza/work/tmp1"
	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r   "amonemi@epi03.bsc.es:mpsoc/src_coherency/verify-mesh-4x4-full/app_server/log.tx"  "/home/alireza/work/tmp1/log3.tx"

	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r   "amonemi@epi03.bsc.es:/scratch/traces_alireza/"  "/home/alireza/work/tmp1/log1.tx"

	sshpass -p "amonemi@epi1423" ssh -o "StrictHostKeyChecking no" "amonemi@epi03.bsc.es"  mkdir -p  "/scratch/traces_alireza"

	sshpass -p "amonemi@epi1423" scp  -o "StrictHostKeyChecking no" -r  "/scratch/traces_alireza"   "amonemi@epi03.bsc.es:/scratch/traces_alireza"

}


copy_sources
#login_in_server





