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
comp_path=${PRONOC_WORK}/injector/verilator
work_path=$comp_path/work




function copy_pck_injector {
	echo "copy all Packet injector verilog files in rtl_work folder" 
	find  $injctor_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $injctor_path -name \*.sv -exec cp '{}' processed_rtl/ \;
	cp $chi_noc_path/chi_submodules.v rtl_work/
	cp $chi_noc_path/../chi_localparam.v ./
	echo "split all verilog modules in separate  files"
	./split > foo
}




function copy_agents {
	echo "copy all rnf verilog files in rtl_work folder" 
	find  $noc_path -name \*.v -exec cp '{}' rtl_work/ \;	
	find  $src_verilator -name \*.v -exec cp '{}' rtl_work/ \;
	find  $rnf_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $cache_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $chi_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $hnf_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $snf_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $ram_path -name \*.v -exec cp '{}' rtl_work/ \;
	find  $ram_path -name \*.sv -exec cp '{}' processed_rtl/ \;
	cp $chi_noc_path/../chi_localparam.v ./
	echo "split all verilog modules in separate  files"
	./split > foo

}





function make_lib {
	cp $src_verilator/Makefile	obj_dir/
	cd obj_dir
	make lib
}


mkdir -p $work_path/rtl_work
mkdir -p $work_path/processed_rtl

cp $src_verilator/split $work_path/split
cd $work_path

# remove old files
rm -rf rtl_work/* 
rm -rf processed_rtl/* 
rm -rf processed_rtl/obj_dir/*


copy_pck_injector
copy_agents 

#copy testcase localparameter
cp $script_path/test_localparam.v  processed_rtl/



cd processed_rtl

verilator  --cc -sv injector_top.sv --profile-cfuncs --prefix "Vinject" -O3  -CFLAGS -O3
verilator  --cc rnf_top.v --profile-cfuncs --prefix "Vrnf" -O3  -CFLAGS -O3
verilator  --cc hnf_top.v --profile-cfuncs --prefix "Vhnf" -O3  -CFLAGS -O3
verilator  --cc snf_top.v --profile-cfuncs --prefix "Vsnf" -O3  -CFLAGS -O3
verilator  --cc chi_req_noc_top.v --profile-cfuncs --prefix "Vreqnoc" -O3  -CFLAGS -O3
verilator  --cc chi_dat_noc_top.v --profile-cfuncs --prefix "Vdatnoc" -O3  -CFLAGS -O3
verilator  --cc chi_snp_noc_top.v --profile-cfuncs --prefix "Vsnpnoc" -O3  -CFLAGS -O3
verilator  --cc chi_rsp_noc_top.v --profile-cfuncs --prefix "Vrspnoc" -O3  -CFLAGS -O3

make_lib



