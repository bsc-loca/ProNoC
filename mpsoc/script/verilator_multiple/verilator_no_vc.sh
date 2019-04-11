#!/bin/sh
set -e
# Any subsequent commands which fail will cause the shell script to exit immediately

my_dir="$(dirname "$0")"
source "$my_dir/../parameter.sh"


cd ..
script_path=$(pwd)
path=$script_path/..
comp_path=$path/../mpsoc_work/verilator
work_path=$comp_path/work
bin_path=$work_path/bin
multiple_path=$work_path/no_vc2
data_path=$multiple_path/data
src_c_path=$path/src_c
plot_c_path=$src_c_path/plot
plot_path=$multiple_path/plot	

rm -Rf $multiple_path
mkdir -p $data_path
mkdir -p $plot_path
cp $path/src_c/plot/plot $multiple_path/plot_bin



    V=1   # number of VC per port
    B=4   # buffer space :flit per VC 
    NX=8  # number of node in x axis
    NY=8  # number of node in y axis
    
    COMBINATION_TYPE="COMB_NONSPEC" # "BASELINE" or "COMB_SPEC1" or "COMB_SPEC2" or "COMB_NONSPEC"
    FIRST_ARBITER_EXT_P_EN=0  
    TOPOLOGY="MESH" #"MESH" or "TORUS"
    ROUTE_NAME="XY" 
            
	 
   

     
    
    
 # Simulation parameters:   
   
    #Hotspot Traffic setting
    HOTSPOT_PERCENTAGE=3		   	#maximum 20
    HOTSOPT_NUM=4					#maximum 5
    HOTSPOT_CORE_1=$(CORE_NUM 2 2)
    HOTSPOT_CORE_2=$(CORE_NUM 2 6)
    HOTSPOT_CORE_3=$(CORE_NUM 6 2)
    HOTSPOT_CORE_4=$(CORE_NUM 6 6)
   
    
                 
    
    
	MAX_PCK_NUM=28000
    MAX_SIM_CLKs=100000
	MAX_PCK_SIZ=10  # maximum flit number in a single packet
    TIMSTMP_FIFO_NUM=64
    
   
    
	
	STND_DEV_EN=0 # 1: generate standard devision  



 CLASS_SETTING="4'b1001" # There are total of two classes. each class use half of avb VCs   


generate_plot_command(){

rm -f plot_command.h

cat > plot_command.h << EOF
#ifndef PLOT_COMMAND_H
	#define PLOT_COMMAND_H

char * commandsForGnuplot[] = {
	"set terminal postscript eps enhanced color font 'Helvetica,15'",
	"set output 'temp.eps' ",
	"set style line 1 lc rgb \"red\"    	lt 1 lw 2 pt 4  ps 1.5",
	"set style line 2 lc rgb \"blue\"   	lt 1 lw 2 pt 6  ps 1.5", 
	"set style line 3 lc rgb \"green\"  	lt 1 lw 2 pt 10 ps 1.5",
	"set style line 4 lc rgb '#8B008B' 	lt 1 lw 2 pt 14 ps 1.5",//darkmagenta
	"set style line 5 lc rgb '#B8860B' 	lt 1 lw 2 pt 2  ps 1.5", //darkgoldenrod
	"set style line 6 lc rgb \"gold\" 	lt 1 lw 2 pt 3  ps 1.5",
	"set style line 7 lc rgb '#FF8C00' 	lt 1 lw 2 pt 10 ps 1.5",//darkorange
	"set style line 8 lc rgb \"black\" 	lt 1 lw 2 pt 1  ps 1.5",
	"set style line 9 lc rgb \"spring-green\" 	lt 1 lw 2 pt 8  ps 1.5",
	"set style line 10 lc rgb \"yellow4\" 	lt 1 lw 2 pt 0  ps 1.5",
	"set yrange [0:50]",
	"set xrange [0:]",
	
	0
};

#endif

EOF

	mv -f plot_command.h	$plot_c_path/plot_command.h	
	cd $plot_c_path
	make
	cp $plot_c_path/plot $multiple_path/plot_bin
	cd $script_path	

}




################
#	
#	regenerate_NoC
#
################	
			
regenerate_NoC() {
	generate_parameter_v
	mv -f parameter.v ../src_verilator/
			
	#verilate the NoC and make the library files
#################################################################3
			./verilator_compile_hw.sh

	# compile the testbench file
	generate_parameter_h
	mv -f parameter.h ../src_verilator/

			./verilator_compile_sw.sh
	
		
	cp $bin_path/testbench $multiple_path/$testbench_name		
}

routename="NULL"
################
#	
#	merg_files
#
################	
		
				
merg_files(){
						 
	data_file=$data_path/$plot_name"_all.txt"
	plot_file=$plot_path/$plot_name"_all.eps"
		
	printf "#name:"$CURVE_NAME"\n" >> $data_file
	cat 	$testbench_name"_all.txt" >> $data_file
	printf "\n\n" >> $data_file
	
	./plot_bin $data_file  $plot_file "Injection ratio flits/node/clk" "Average latency clk" "outside left"
	
	
	
	if [ $C  -gt 1  ] 
	then
			
		data_file=$data_path/$plot_name"_c0.txt"
		plot_file=$plot_path/$plot_name"_c0.eps"
	
	
		printf "#name:"$CURVE_NAME"\n" >> $data_file
		cat 	$testbench_name"_c0.txt" >> $data_file
		printf "\n\n" >> $data_file
	
		./plot_bin $data_file  $plot_file "Injection ratio flits/node/clk" "Average latency clk" "outside left"
	
		data_file=$data_path/$plot_name"_c1.txt"
		plot_file=$plot_path/$plot_name"_c1.eps"
	
	
		printf "#name:"$CURVE_NAME"\n" >> $data_file
		cat 	$testbench_name"_c1.txt" >> $data_file
		printf "\n\n" >> $data_file
	
		./plot_bin $data_file  $plot_file "Injection ratio flits/node/clk" "Average latency clk" "outside left"
	
	fi
	
	
	rm	$testbench_name* 	
			
}	

gen_testbench_name(){
	testbench_name=$V"_"$ROUTE_NAME"_"$TRAFFIC"_"$PACKET_SIZE
		
}

gen_plot_name(){
	plot_name=$ROUTE_NAME"_"$TRAFFIC"_"$PACKET_SIZE
	
}



	
	




################
#	
#	run_sim
#
################
run_sim(){

	for   V  in  1 2 3
	do
		gen_testbench_name
		regenerate_NoC
	done
				
	



	cd $multiple_path
	
	
	
	for   V  in  1 2 3
	do	
		
		gen_testbench_name
		CMD="./$testbench_name $testbench_name"
        
		command $CMD &
	done
	
				
	# wait for all simulation to be done
	wait
	
	
	# merge the results in one file 

	
	for   V  in  1 2 3
	do
		gen_testbench_name
		gen_plot_name
		CURVE_NAME="VC="$V
		merg_files
	done # ROUTE_NAME
	

	cd $script_path			
																		
}		

generate_plot_command																																		
					
 for PACKET_SIZE in  4 
 do 
	for	TRAFFIC in "HOTSPOT" "TRANSPOSE2"  "TRANSPOSE1" "BIT_REVERSE" "RANDOM"   
	do
		for  ROUTE_NAME in "XY" 
		do
			
			run_sim
			
		done 
	done 
done #PACKET_SIZE
			
