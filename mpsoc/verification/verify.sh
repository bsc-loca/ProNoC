#!/bin/bash

SIM_PATH="$PWD"


#ProNoC paper results
SIM_TES_IN=(
# simulation_file					gen_model  	run_sim 	save_path  			reference_result 
"model_mesh_8x8_vc2_xy_sa_rra.SIM" 	"yes"  	 	"no"		"nop "	 	  		"nop"
"model_mesh_8x8_vc2_xy_nosa_rra.SIM" 	"yes"  	 	"no"		"nop "   			"nop "
"model_mesh_8x8_vc2_full_sa_rra.SIM" 	"yes"  	 	"no"		"nop "   			"nop "
"model_mesh_8x8_vc2_full_nosa_rra.SIM" 	"yes"  	 	"no"		"nop "   			"nop "
"model_mesh_8x8_vc1_xy_nosa.SIM" 	"yes"  	 	"no"		"nop "   			"nop "
"pronoc_mesh_8x8_random.SIM" 		"no"  	 	"yes"		"pronoc_random"   	"nop"
"pronoc_mesh_8x8_bitreverse.SIM" 	"no"  		"yes"		"pronoc_bitreverse"   "nop"
"pronoc_mesh_8x8_tran1.SIM"		"no"  	 	"yes"		"pronoc_tran1"   	"nop"
)


#ProNoC paper results
SIM_TES_IN1=(
# simulation_file					gen_model  	run_sim 	save_path  			reference_result 
"adaptive/model_mesh_8x8_vc4_c2_full_nosa.SIM"      	"yes"  	 	"no"		"nop "	 	  		"nop"
"adaptive/model_mesh_8x8_vc4_c2_oe_nosa.SIM"	"yes"  	 	"no"		"nop "	 	  		"nop"
"adaptive/model_mesh_8x8_vc4_c2_negetive_nosa.SIM"	"yes"  	 	"no"		"nop "	 	  		"nop"
"adaptive/model_mesh_8x8_vc4_c2_west_nosa.SIM"	"yes"  	 	"no"		"nop "	 	  		"nop"
"adaptive/model_mesh_8x8_vc4_c2_north_nosa.SIM"	"yes"  	 	"no"		"nop "	 	  		"nop"
"adaptive/model_mesh_8x8_vc4_c2_xy_nosa.SIM"	"yes"  	 	"no"		"nop "	 	  		"nop"
)











SIM_TES_IN2=(
# simulation_file  		save_path  			reference_result 
"test.SIM"  "result_test"  "ref1"
"test1.SIM"  "result_test1"  "ref2"
)




#"test_mesh_4x4_random.SIM"   "test_mesh_4x4_result"	"test_lib/test_mesh_4x4"
#"test_mesh_5x5_random.SIM"   "test_mesh_5x5"
#)

#################
#	press_alt_key
#################
function press_alt_key () {
	xdotool keydown alt; sleep .25;
	xdotool type $1; sleep .25; xdotool keyup alt 
}



#################
#	wait_for_specefic_out
#################
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
	#echo "successful";
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


#################
#	run_pronoc
#################
function run_pronoc(){
	local sim_file_name=$1
	local gen_model="$2"
    local run_sim="$3"
    	
	local sim_file_name_path="${SIM_PATH}/test_lib/${sim_file_name}"
	local save_results="${SIM_PATH}/results/$4"
	echo "ProNoC NoC verification using $sim_file "
# "Running ProNoC GUI"		
	run_ProNoC
	sleep 2
#select simulation window
	xdotool key Ctrl+2 
	sleep 1

#select simulation window
	press_alt_key "n" 
	sleep 1

#load simfile
	press_alt_key "l"
	sleep 1
	xdotool type  "$sim_file_name_path"
	sleep 1	
	xdotool key Return
	sleep 1
#gen_verilator_model
if [ "$gen_model" == "yes" ]; then
	if gen_verilator_model $1; then echo "successful"; else return; fi
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





for ((index=0; index<${#SIM_TES_IN[@]}; index+=5)) 
do
    sim_file=${SIM_TES_IN[index]}
    gen_model=${SIM_TES_IN[index+1]}
    run_sim=${SIM_TES_IN[index+2]}
    result_path=${SIM_TES_IN[index+3]}
    ref_file=${SIM_TES_IN[index+4]}
    run_pronoc $sim_file $gen_model $run_sim $result_path $ref_file

done


echo "done!"




