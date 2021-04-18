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



transcript="$log_path/transcript"
rm -f "$transcript"

run_vsim $transcript	

ln -s $transcript ./transcript


cd $log_path; 








#check write on mem
get_repeat_num 
check_write_on_mem $REPEAT
check_mem_write_value 1 1 0

V1=$(( $REPEAT * 2 ))

check_cache_write_value 1 1 0
check_write_on_cache 0 0 "UC" $V1
check_write_on_cache 1 1 "UC" 0
check_write_on_cache 0 0 "SC" $REPEAT
check_write_on_cache 1 1 "SC" $REPEAT


check_write_on_cache 4 7 "UC" $REPEAT

check_write_on_cache 0 7 "SC" $V1


count_excl_fail 0

echo "Number of exclusive transaction which is failed: 
Core 0 : $COUNTED"

if [ $COUNTED -eq  0 ]
then
    echo "Expected"
else 
    echo "Error: The Expected Value was 0"
fi


count_excl_fail 1
echo "Core 1 : $COUNTED"

if [ $COUNTED -eq  10 ]
then
    echo "Expected"
else 
    echo "Error: The Expected Value was 10"
fi


check_general











