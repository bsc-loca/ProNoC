#!/bin/bash
script_path=$(pwd)
parent_path=$(pwd)/..
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
comp_path=~/injector/verilator
work_path=$comp_path/work
rtl_work=$work_path/rtl_work
processed_rtl=$work_path/processed_rtl
obj_dir=$processed_rtl/obj_dir

function clear_out_dir {
	mkdir -p $rtl_work
	mkdir -p $processed_rtl

	cp $src_verilator/split $work_path/split
	cp $src_verilator/EditFiles.pm  $work_path/EditFiles.pm
	cd $work_path

	# remove old files
	rm -rf $rtl_work/* 
	rm -rf $processed_rtl/* 
	rm -rf $obj_dir/*
}


function copy_pck_injector {
	echo "copy all Packet injector verilog files in rtl_work folder" 
	find  $src_verilator -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $injctor_path -name \*.v -exec cp '{}' $rtl_work/ \;
	find  $injctor_path -name \*.sv -exec cp '{}' $processed_rtl/ \;
	cp $chi_noc_path/chi_submodules.v $rtl_work/
	cp $chi_noc_path/../chi_localparam.v $rtl_work/..
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
	cp $script_path/test_localparam.v  $processed_rtl/
}



function verilate_hws {
	cd $processed_rtl
	verilator  --cc injct_top.v --profile-cfuncs --prefix "Vinject" -O3  -CFLAGS -O3 &
	verilator  --cc rnf_top.v --profile-cfuncs --prefix "Vrnf" -O3  -CFLAGS -O3 &
	verilator  --cc hnf_top.v --profile-cfuncs --prefix "Vhnf" -O3  -CFLAGS -O3 &
	verilator  --cc snf_top.v --profile-cfuncs --prefix "Vsnf" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_p5_req.sv --profile-cfuncs --prefix "Vreqrouter" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_p5_rsp.sv --profile-cfuncs --prefix "Vrsprouter" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_p5_snp.sv --profile-cfuncs --prefix "Vsnprouter" -O3  -CFLAGS -O3 &
	verilator  --cc -sv router_p5_dat.sv --profile-cfuncs --prefix "Vdatrouter" -O3  -CFLAGS -O3 &		

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

function make_sim {
    find  $src_verilator -name \*.h -exec cp '{}' $obj_dir/ \;	
	cp $src_verilator/testbench.cpp	$obj_dir/
	cp $script_path/parameter.h $obj_dir/ 
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




#regen_injector
gen_object_libs
make_sim

