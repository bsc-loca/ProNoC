#!/bin/bash
SCRPT_FULL_PATH=$(realpath ${BASH_SOURCE[0]})
SCRPT_DIR_PATH=$(dirname $SCRPT_FULL_PATH)


verilator  -f $SCRPT_DIR_PATH/file_list.f --cc --top-module  router_top_v  -GP=5    --prefix "Vrouter1" -O3  -CFLAGS -O3 &
verilator  -f $SCRPT_DIR_PATH/file_list.f --cc --top-module traffic_gen_top  --prefix "Vtraffic" -O3  -CFLAGS -O3 
wait
 
if ! [ -f $SCRPT_DIR_PATH/obj_dir/Vrouter1.cpp ]; then
	echo  "Failed to generate: $SCRPT_DIR_PATH/obj_dir/Vrouter1.cpp "
	exit 1	
fi
 
if ! [ -f $SCRPT_DIR_PATH/obj_dir/Vtraffic.cpp ]; then
	echo  "Failed to generate: $SCRPT_DIR_PATH/obj_dir/Vtraffic.cpp "
	exit 1	
fi
	echo  "Verilator modules are generated successfully". 

cd $SCRPT_DIR_PATH/obj_dir/

#run make file 
make lib0 &
make lib1 
wait

make sim
#done
