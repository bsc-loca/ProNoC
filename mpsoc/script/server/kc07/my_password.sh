#!/bin/bash
my_server="alireza@84.88.52.232"
my_passwd="123qwe@#"

function login_in_server {
	sshpass -p "123qwe@#" ssh -X "alireza@84.88.52.232"
	source /opt/Xilinx/Vivado/2018.1/settings64.sh
	#export XILINXD_LICENSE_FILE=4100@bsc-caos-gw.bsc.es
	export XILINXD_LICENSE_FILE=4100@epi03.bsc.es      # 192.168.10.36
	export PRONOC_WORK=~
}
