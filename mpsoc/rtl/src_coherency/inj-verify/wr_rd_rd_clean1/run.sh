#!/bin/bash

source "../check_functions.sh"

rm "./transcript";

source "../run_sim.sh"


#check write on mem
get_repeat_num 
check_write_on_mem $REPEAT

#check_write_on_cache 4 7 "UC" $REPEAT
V1=$(( $REPEAT * 2 ))
check_write_on_cache 1 1 "UC" $REPEAT
check_write_on_cache 0 7 "SC" $REPEAT


check_general


