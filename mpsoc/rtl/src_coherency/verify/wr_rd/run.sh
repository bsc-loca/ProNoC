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





#check write on mem
get_repeat_num 
check_write_on_mem $REPEAT
check_mem_write_value 1 1 0

check_write_on_cache 0 0 "UC" $REPEAT
check_write_on_cache 4 7 "UC" $REPEAT



check_general





