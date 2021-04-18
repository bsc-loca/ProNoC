#!/bin/bash


vpn_path="/home/alireza/work/VPN/BSC_VPN_Client"




function run_vpn {
	echo "run vpn"
	exec sudo perl $vpn_path/jvpn.pl
	
}

run_vpn

