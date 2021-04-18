#!/bin/bash

source "../check_functions.sh"
source "../run_sim.sh"


full_path=$(realpath $0)
dir_path=$(dirname $full_path)
p_path=$(dirname $dir_path )
pname1=$(basename $dir_path)
pname2=$(basename $p_path)
log_path="${PRONOC_WORK}/simulation/$pname2/$pname1"


echo "save logfile in $log_path"
mkdir -p "$log_path"
cp -f ./test_localparam.v   $log_path/test_localparam.v


transcript="$log_path/transcript"
rm -f "$transcript"

run_vsim $transcript	

ln -s $transcript ./transcript


cd $log_path; 



echo "####################check atomic ADD 64-bit##############################"
check_last_mem_written_value_on_addr 0 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000000011
check_cache_last_written_value_on_addr 2 0 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000000012







check_general
