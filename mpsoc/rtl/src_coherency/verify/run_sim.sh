#!/bin/bash

function run_vsim {
	transcrpt=$1		
	
	
	#export LM_LICENSE_FILE=1717@84.88.187.145
	#export LM_LICENSE_FILE="1900@bsc-caos-gw.bsc.es"
	export LM_LICENSE_FILE=1717@epi03.bsc.es

	echo "Start simulation" >&3

	exec 3> /dev/tty # open fd 3 and point to controlling terminal
	#questasim
	#/home/alireza/intelFPGA_lite/questa/questasim/bin/vsim -l $transcrpt -quiet -do model.tcl
	/home/alireza/intelFPGA_lite/questa/questasim/bin/vsim -l $transcrpt -quiet -c -do model.tcl >&3

	#Modelsim altera edition
	#/home/alireza/intelFPGA_lite/18.1/modelsim_ase/bin/vsim -l $transcrpt -quiet -c -do model.tcl >&3
	#/home/alireza/intelFPGA_lite/18.1/modelsim_ase/bin/vsim -l $transcrpt -quiet  -do model.tcl  

	wait 
	echo "End of Simulation" >&3

	exec 3>&- # close fd 3

}
