#!/bin/bash

SIM_PATH="$PWD"




#################
#	press_alt_key
#################
function press_alt_key () {
	xdotool keydown alt; sleep .25;
	xdotool type $1; sleep .25; xdotool keyup alt 
}

#################
#	press_ctrl_key
#################
function press_ctrl_key () {
	xdotool keydown ctrl; sleep .25;
	xdotool type $1; sleep .25; xdotool keyup ctrl 
}


#################
#	wait_for_specefic_out
#################
function get_compilation_result(){
# Read the output of wminput line by line until one line contains Ready
	local f="failed"
	local p="successfull"	
	while read line; do
	   case "$line" in
	   *$f*)
	      echo "'$line' contains failed!. Exiting loop"
              cresult="fail"
	      break
	      ;;
	   *$p*)
	      echo "'$line' contains successfull!. Exiting loop"
              cresult="pass"
	      break
	      ;;
	   *)
	    # echo "'$line' does not contain Ready."
	      ;;
	   esac
	done <&3
	#wmctrl -R ProNoC
}

function wait_for_specefic_out(){

# Read the output of wminput line by line until one line contains Ready
	while read line; do
	   case "$line" in
	   *$1*)
	     # echo "'$line' contains Ready. Exiting loop"
	      break
	      ;;
	   *)
	    # echo "'$line' does not contain Ready."
	      ;;
	   esac
	done <&3
	#wmctrl -R ProNoC
}




#################
#	run_ProNoC
#################
function run_ProNoC(){
	# Start wminput in the background and send its output to file descriptor 3
	cd ../perl_gui;
	exec  3< <(perl ProNoC.pl) 
        sleep 2
}


#################
#	close_ProNoC
#################
function close_ProNoC(){
	#wmctrl -R ProNoC
	xdotool key Ctrl+q 
	exec 3>&-
	cd $SIM_PATH
}


#################
#	gen_verilator_model
#################
function gen_verilator_model(){

# select generate tab
	press_alt_key "g" 
	sleep 1

# press the generate button
	press_alt_key "a" 
	sleep 1

# wait for compilation to be done
	wait_for_specefic_out "gen-ended"
	sleep 1
	xdotool key Return
	sleep 1

#check if the bin file is generated
#echo $line
	if [[ "${line}" != *"gen-ended successfully"* ]]; then
                echo "compilation failed"
		return 1;
	fi
	#echo "successfull";
		return 0;
}


#################
#	run_simulation
#################
function run_simulation(){
	  
    local sim_file_name_path="$1"
	local save_results="$2"
#run simfile
	press_alt_key "u" 
	sleep .5

# wait for simulation to be done
	wait_for_specefic_out "Simulation is done!"
#save all results
	
	press_alt_key "x" 
	sleep 1
	xdotool type  "$save_results"
	sleep 1
	xdotool key Return
	xdotool key Return
	sleep 1
}

############
#  gen_tile
############

function gen_tile(){
#select window
	xdotool key Ctrl+1
	sleep 1

#select tile gen window
	press_alt_key "r" 
	sleep 1

#generate tile
	local tile_file_name=$1
	press_alt_key "l"
	sleep 1
	press_ctrl_key "a"
        sleep 1
	xdotool type  "$1"
	sleep 1	
	xdotool key Return
	sleep 1
	press_alt_key "g"
        sleep 2
	press_alt_key "y"
        sleep 1
}


function gen_mpsoc(){
	#select mpsoc window
	press_alt_key "n" 
	sleep 1
	press_alt_key "l"
	sleep 1
	press_ctrl_key "a"
        sleep 1
	xdotool type  "$1"
	sleep 1	
	xdotool key Return
	sleep 1
	press_alt_key "g"
        sleep 2
        xdotool key Return
	sleep 1
}


function run_test(){
	test_folder=$1
	mpsoc="$PRONOC_WORK/MPSOC/$2"
	echo "Copy $test_folder/sw files to $mpsoc/sw"
	cp -rf "$test_folder/sw/"* "$mpsoc/sw/" 
	#select mpsoc window
	press_alt_key "n" 
	sleep .5
	press_alt_key "s" 
	sleep 1
        press_alt_key "c" 
	sleep 2
	get_compilation_result
        press_ctrl_key "q"
        if [[ "$cresult" != "pass" ]]; then
                echo "$test_folder test failed: software compilation is failed\n"
        	return 1;
	fi
	sleep .5	
	press_alt_key "c" 
	sleep 1
	press_alt_key "n" 
 	sleep 1
	press_alt_key "r" 
}

function run_pronoc1(){
#load simfile
	press_alt_key "l"
	sleep 1
	xdotool type  "$sim_file_name_path"
	sleep 1	
	xdotool key Return
	sleep 1
#gen_verilator_model
if [ "$gen_model" == "yes" ]; then
	if gen_verilator_model $1; then echo "successfull"; else return; fi
	sleep 1
fi	
	
#run simulation
if [ "$run_sim" == "yes" ]; then
	run_simulation $sim_file_name_path $save_results
fi

	#save simulation objct file
	press_alt_key "e" 
	sleep 2
	xdotool key Return
	sleep .5

#copy object file
	mkdir -p $save_results
	b=$(basename $sim_file_name)
	mv "$SIM_PATH/../perl_gui/lib/simulate/${b}" $save_results
	
	close_ProNoC
}


   




	echo "ProNoC NI verification"
	# Running ProNoC GUI		
	run_ProNoC
	#gen_tile "${SIM_PATH}/test_lib/ni_test/mor1k_tile.SOC"
        gen_mpsoc "${SIM_PATH}/test_lib/ni_test/mesh3x2.MPSOC"
        run_test "${SIM_PATH}/test_lib/ni_test/t1" "mesh3x2"	


echo "done!"




