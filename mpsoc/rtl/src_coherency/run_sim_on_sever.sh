#!/bin/bash

server="amonemi@epi01.bsc.es"

path="/home/alireza/work/hca_git/ProNoC/mpsoc"
cpath="$path/src_coherency"
sim_path="$cpath/verify-4-pck-inj/excl160"
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
	"$cpath/verify-4-pck-inj "	
)



        
        

echo  $sim_path 



function login_in_server {
	sshpass -p amonemi@epi1423 ssh -X $server
	source /eda/env.sh
	export PATH=$PATH:/opt/verilator/bin
}




function copy_sources {
	sshpass -p "amonemi@epi1423" ssh "amonemi@epi01.bsc.es"  mkdir -p  "~/mpsoc"
	sshpass -p "amonemi@epi1423" ssh "amonemi@epi01.bsc.es"  mkdir -p  "~/mpsoc/src_coherency"
	sshpass -p "amonemi@epi1423" ssh "amonemi@epi01.bsc.es"  mkdir -p  "~/mpsoc/src_peripheral"
        
	sshpass -p "amonemi@epi1423" scp -r $src_ram   "$server:mpsoc/src_peripheral/ram"
	sshpass -p "amonemi@epi1423" scp -r $src_noc   "$server:mpsoc/"
	for i in "${my_array[@]}"; do
 		echo "copy $i on server"
		sshpass -p "amonemi@epi1423" scp -r $i  "$server:mpsoc/src_coherency/"
		
 	done	

}

copy_sources
#login_in_server





