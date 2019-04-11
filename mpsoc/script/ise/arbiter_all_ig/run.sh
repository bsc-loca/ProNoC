#!/bin/sh

source /opt/Xilinx/10.1/ISE/settings64.sh
ise_lin=/opt/Xilinx/10.1/ISE/bin/lin64

path=$(pwd)
script_path=$path/../..
mpsoc_path=$script_path/..
comp_path=$mpsoc_path/../mpsoc_work/ise
work_path=$comp_path/arbiter_all
project=arbiter



#cd /opt/Xilinx/12.1/ISE_DS/ISE/bin/lin64/
#-l /opt/Xilinx/10.1/ISE_DS/ISE/lib/lin64/libNbBas_Bld.so

initial(){
	rm -Rf $work_path
	wait
	mkdir -p $work_path/xst/projnav.tmp
	wait
	cp $path/$project.*  $work_path/
	cp -R $path/src  $work_path/src

	cp $path/c/plot_command.h $mpsoc_path/src_c/plot
	cd $mpsoc_path/src_c/plot
	make
	mkdir -p $work_path/data	
	cp $mpsoc_path/src_c/plot/plot  $work_path/data

	cd $work_path
	

}




compile(){
	#"synthes"
	$ise_lin/xst   -ifn  $project.xst 



	#"Translate":
	$ise_lin/unwrapped/ngdbuild -ise  xlnx_auto_0.ise -intstyle ise -dd _ngo -nt timestamp   -p xc2vp30-ff1152-5 $project.ngc $project.ngd


	#"Map":


	$ise_lin/unwrapped/map -ise  xlnx_auto_0.ise -intstyle ise -p xc2vp30-ff1152-5 -cm area -pr off -k 4 -c 100 -tx off -o $project\_map.ncd $project.ngd $project.pcf 

	#"Place & Route":
	$ise_lin/unwrapped/par -w -intstyle ise -ol high -t 1 $project\_map.ncd $project.ncd $project.pcf 


	#"Generate Post-Place & Route Static Timing":
	$ise_lin/unwrapped/trce -intstyle ise -v 3 -s 5 -n 3 -fastpaths -xml $project.twx $project.ncd -o $project.twr $project.pcf


	# extract the worst case timing
	enty="Maximum frequency:"
	tim=$( grep -F "$enty" $project.twr )
	tim=${tim#*: }            # Remove everything up to a colon and space
	tim=${tim%ns*}              # Remove the M at the end


	# extract harware cost
	enty="Number of occupied Slices:"
	hdr=$( grep -F "$enty" $project\_map.mrp )
	hdr=${hdr#*: }            # Remove everything up to a colon and space
	hdr=${hdr%out*}              # Remove the out at the end

}


gen_param(){

	echo "arb is $arb"	
	rm -rf   src/param.v   
	printf  " \`ifdef INCLUDE_PARAM\n"  >> src/param.v 
	printf  "\tlocalparam\tARBITER_WIDTH\t=$width;\n" >> src/param.v 
	printf  "\tlocalparam\tARBITER_NAME\t=\"$arb\";\n" >> src/param.v
	printf  " \`endif\n"  >> src/param.v 	 


}

initial

cd $work_path

for dev in "2vp30"
do
	for top in   "arbiter_top" "arbiter_mux"
	do
		lc_file=$work_path/"data"/$dev\_$top\_"lc"
		tim_file=$work_path/"data"/$dev\_$top\_"tim"
		cp $path/$top.xst  $work_path/$project.xst

		for arb in   "ping_pong"  "ping_lock" "ppe" "tca" "fra" "prra" "iprra" 
		do
	

			printf  "#name:${arb,,}\n"  >> $lc_file
			printf  "#name:${arb,,}\n"  >> $tim_file
	

			for width in 2  4  8  16 32 64 128
			do	
				gen_param
				compile
				printf "$width $hdr\n" >> $lc_file
				printf "$width $tim\n" >> $tim_file
		
	

			done

			printf  "\n\n" >> $lc_file
			printf  "\n\n" >> $tim_file


		done #arb

		./data/plot $lc_file		"$lc_file.eps"		"Arbiter Width"  	"LC usage" 	"left"
		./data/plot $tim_file		"$tim_file.eps"		"Arbiter Width"  	"delay" 	"left"

	done #top
done #dev


echo DONE
