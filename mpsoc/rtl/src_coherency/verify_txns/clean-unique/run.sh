#!/bin/bash

source "../check_functions.sh"

rm "./transcript";

source "../run_sim.sh"

# check write on cache
get_repeat_num 
check_write_on_cache 0 0 "UC" $REPEAT
check_write_on_cache 4 7 "UC" $REPEAT
check_cache_write_value 64 1 1 #value = addr/64 +1








check_general

