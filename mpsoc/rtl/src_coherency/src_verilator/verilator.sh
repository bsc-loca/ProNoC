#!/bin/bash


if [ "$#" -eq 0 ];then
   echo "Error Script needs the sumulation source path as input" 
   exit 1
fi


if [ "$#" -le 2 ];then
   traces_file="trace_files.v"
else
   traces_file=$2  
fi





script_path=$1
#check script path is exist
if [ -d "$script_path" ]; then
  ### Take action if $DIR exists ###
  echo "Simulation path is ${script_path}..."
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Error: ${script_path} not found. Can not continue."
  exit 1
fi



if [[ -z "${PRONOC_WORK}" ]]; then
   comp_path=~/injector/verilator
else
   comp_path=${PRONOC_WORK}/injector/verilator
fi


parent_path=$script_path/..
path=$parent_path/..
injctor_path=$path/injector/rtl
rnf_path=$path/rnf
cache_path=$path/cache
chi_path=$path/chi_noc
hnf_path=$path/hnf
snf_path=$path/snf
noc_path=$path/../src_noc
noc_verilator_path=$path/../src_verilator
ram_path=$path/../src_peripheral/ram
chi_noc_path=$parent_path/../chi_noc/
src_verilator=$parent_path/../src_verilator/
work_path=$comp_path/work
rtl_work=$work_path/rtl_work
processed_rtl=$work_path/processed_rtl
obj_dir=$processed_rtl/obj_dir

function clear_out_dir {
	
	mkdir -p $rtl_work
	mkdir -p $processed_rtl

	# remove old files
      	rm -rf $rtl_work/* 
	rm -rf $processed_rtl/* 
	rm -rf $obj_dir/*


	cp $src_verilator/split $work_path/split
	cp $src_verilator/EditFiles.pm  $work_path/EditFiles.pm
	cp $src_verilator/Scanf.pm  $processed_rtl/Scanf.pm
	
}


function copy_pck_injector {
	echo "copy all Packet injector verilog files in rtl_work folder" 
	find  $src_verilator -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $injctor_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $injctor_path -name \*.sv -exec cp '{}' $processed_rtl/ \;
	cp $chi_noc_path/chi_submodules.v $rtl_work/
	cp $chi_noc_path/../chi_localparam.v $rtl_work/..
	cp $parent_path/fake_sam.v $rtl_work/
	cp $parent_path/topology_mapping.v $rtl_work/

	echo "split all verilog modules in separate  files"
	cd $work_path
	./split > foo
}




function copy_agents {
	echo "copy all rnf verilog files in rtl_work folder" 
	find  $noc_path -name \*.v -exec cp '{}' $rtl_work/ \;	
	find  $src_verilator -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $rnf_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $cache_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $chi_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $hnf_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $snf_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $ram_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $ram_path -name \*.sv -exec cp '{}' $processed_rtl/ \;
    	find  $src_verilator -name \*.sv -exec cp '{}' $processed_rtl/ \;

	cp $chi_noc_path/../chi_localparam.v $rtl_work/..
	echo "split all verilog modules in separate  files"
	cd $work_path
	./split > foo

}

function copy_hw_sources {
	copy_pck_injector
	copy_agents 
	#copy testcase localparameter
	cp $parent_path/test_localparam.v  $processed_rtl/
}



function verilate_hws {
	cd $processed_rtl
	verilator  --cc chi_rn_params_pkg.sv l2_pkg.sv tim_pkg.sv injct_top.v --profile-cfuncs --prefix "Vinject" -O3  -CFLAGS -O3 &
	verilator  --cc rnf_top.v --profile-cfuncs --prefix "Vrnf" -O3  -CFLAGS -O3 &
	verilator  --cc hnf_top.v --profile-cfuncs --prefix "Vhnf" -O3  -CFLAGS -O3 &
	verilator  --cc -sv snf_top.sv       --profile-cfuncs --prefix "Vsnf" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_mesh_req.sv --profile-cfuncs --prefix "Vreqrouter" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_mesh_rsp.sv --profile-cfuncs --prefix "Vrsprouter" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_mesh_snp.sv --profile-cfuncs --prefix "Vsnprouter" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_mesh_dat.sv --profile-cfuncs --prefix "Vdatrouter" -O3  -CFLAGS -O3 &		

	#verilator  --cc chi_req_noc_top.v --profile-cfuncs --prefix "Vreqnoc" -O3  -CFLAGS -O3
	#verilator  --cc chi_dat_noc_top.v --profile-cfuncs --prefix "Vdatnoc" -O3  -CFLAGS -O3
	#verilator  --cc chi_snp_noc_top.v --profile-cfuncs --prefix "Vsnpnoc" -O3  -CFLAGS -O3
	#verilator  --cc chi_rsp_noc_top.v --profile-cfuncs --prefix "Vrspnoc" -O3  -CFLAGS -O3
	wait
}

function make_libs {
	cp $src_verilator/Makefile	$obj_dir/
	cd $obj_dir
	make lib0 &
	make lib1 &
	make lib2 &
	make lib3 &
	make lib4 &
	make lib5 &
	make lib6 &
	make lib7 &
	wait
}


function gen_object_libs {
	clear_out_dir
	copy_hw_sources
	verilate_hws
	make_libs
}

function gen_param_h {
	cp -f $src_verilator/gen_param_h.pl $processed_rtl/
	cd $processed_rtl
	cp -f $parent_path/test_localparam.v  $processed_rtl/
	cp -f $parent_path/topology_mapping.v $processed_rtl/
	rm -f parameter.h
	perl gen_param_h.pl test_localparam.v topology_mapping.v $traces_file
	wait
	mv -f parameter.h $obj_dir/
}


function make_sim {
    find  $src_verilator -name \*.h -exec cp -f '{}' $obj_dir/ \;	
	cp -f $src_verilator/testbench.cpp	$obj_dir/
	gen_param_h 
	cp -r $script_path/sample $obj_dir/sample 	
	cd $obj_dir
	make sim
}

function regen_injector {
	copy_pck_injector
	cd $processed_rtl
	verilator  --cc injct_top.v --profile-cfuncs --prefix "Vinject" -O3  -CFLAGS -O3
	cd $obj_dir
	make lib0
}


function run_sim {
	cd $obj_dir
	./testbench

}

#regen_injector
#gen_object_libs
#make_sim
#run_sim

if [ "$#" -le 2 ];then
   run=2 # if no argument is given run only the simulation
else
   run=$3  
fi


 
if [ $run -eq 0 ]
then
    echo "make object libs"
    gen_object_libs
fi

if [ $run -eq 1 ]
then
    echo "make_sim"
    make_sim
fi


if [ $run -eq 2 ]
then
    echo "run_sim"
    run_sim
fi


