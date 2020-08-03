#!/bin/bash

#remove address from make_project.tcl & program_board.tcl  
#fix jtag_intfc.sh ~/mpsoc/jtag_xilinx_xsct/jtag_xilinx_xsct


function login_in_server {
	sshpass -p "123qwe@#" ssh -X "alireza@84.88.52.232"
	source /opt/Xilinx/Vivado/2018.1/settings64.sh
	#export XILINXD_LICENSE_FILE=4100@bsc-caos-gw.bsc.es
	export XILINXD_LICENSE_FILE=4100@epi03.bsc.es      # 192.168.10.36
	export PRONOC_WORK=~
}


function check_fpga_exist_on_server {
   xsct
   connect 
   jtag targets
}

server="alireza@84.88.52.232"

#server_folder_name="xilinx_mesh"
#source_path="/home/alireza/work/hca_git/mpsoc_work/MPSOC/xilinx_mesh"

#server_folder_name="mor1k_soc_kc"
#source_path="/home/alireza/work/hca_git/mpsoc_work/SOC/mor1k_soc_kc"

server_folder_name="kc07_mesh12"
source_path="/home/alireza/work/git/hca_git/mpsoc_work/MPSOC/kc07_mesh12"





my_array=("$source_path/src_verilog "
	"$source_path/sw "
	"$source_path/xilinx_compile "
	"$source_path/xilinx_mem "
	"$source_path/*.tcl "
	"$source_path/*.xdc ")





function copy_sources_all {
	sshpass -p "123qwe@#" ssh "alireza@84.88.52.232" mkdir -p  "~/mpsoc/$server_folder_name"
	echo "copy $source_all on server"  
	#sshpass -p "123qwe@#" scp -r $source_all   "$server:mpsoc/"
	for i in "${my_array[@]}"; do
 		echo "copy $i on server"
		sshpass -p "123qwe@#" scp -r $i  "$server:mpsoc/$server_folder_name/"		
 	done
	copy_uart_terminal
}


function copy_sources_sw {
	echo "copy $source_path/sw on server"  
	sshpass -p "123qwe@#" scp -r "$source_path/sw"   "$server:mpsoc/$server_folder_name/"
}

function copy_uart_terminal {
	echo "copy uart_terminal on server"
	sshpass -p "123qwe@#" scp -r "/home/alireza/work/git/hca_git/ProNoC/mpsoc/src_c/jtag/uart_xsct_terminal" "$server:mpsoc/"
	sshpass -p "123qwe@#" scp -r "/home/alireza/work/git/hca_git/ProNoC/mpsoc/src_c/jtag/jtag_xilinx_xsct" "$server:mpsoc/"

}


function copy_board_files {
	echo "copy board files"
	sshpass -p "123qwe@#" scp -r "/home/alireza/work/git/hca_git/mpsoc_work/toolchain/board_files" "$server:mpsoc/"
	# update  board_part_repo_paths manulay in $server:mpsoc/$server_folder_name/board_property.tcl file with new addr:    " /mnt/SSD-2TB/alireza/mpsoc/board_files "
}


function update_jtag_xilinx_xsct {
	# should be run inside the server
	cd ~/mpsoc/jtag_xilinx_xsct/; make
	cp ~/mpsoc/jtag_xilinx_xsct/jtag_xilinx_xsct ~/toolchain/bin/

	cd ~/mpsoc/uart_xsct_terminal/; make
        cp ~/mpsoc/uart_xsct_terminal/uart ~/toolchain/bin/


}

#should be run in server folder
function compile_vivado {
       
	vivado -mode tcl -source make_project.tcl

}

function program_fpga {
        cd ~/mpsoc/kc07_mesh12/
	vivado  -mode tcl -source program_board.tcl

}


function run_uart {
	cd ~/toolchain/bin
	./uart -a 2 -b 36 -t 3 -n 126,125,124,123,122,121,120,119,118,117,116,115

}

function program_cpus {
	 cd ~/mpsoc/kc07_mesh12/sw

}


function copy_back_from_server {
	echo "copy back xilinx_compile to $source_path"
	sshpass -p "123qwe@#" scp -r  "$server:mpsoc/$server_folder_name/xilinx_compile/*"  "$source_path/xilinx_compile/"
}

#copy_sources_all


# copy_board_files

#copy_back_from_server

#copy_uart_terminal



copy_sources_sw

