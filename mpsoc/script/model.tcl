#!/usr/bin/tclsh

###################################################################
## Author      : Alireza Monemi
## Email       : 
## Description : Compile all verilog files inside the design folder 
##             : using modelsim
###################################################################



if { [info exists $::env(LM_WORK_PLACE)] } { 
  puts "You need to define the work dir as LM_WORK_PLACE linux envirement variable \n"
}


set text "###################################################################"
set text "##                Start Compilation Script "
set text "###################################################################"

###################################################################
##---- Specify variables
set text "###################################################################"
set text "##---- Specify variables"

##-- Project path variables


set path	[pwd]
set path1 	[file normalize $path/../src_noc]
set path2 	[file normalize $path/../src_modelsim]

set comp_path 	$::env(LM_WORK_PLACE)
set work_path	$comp_path/work
set dirs $path1+$path2


set text $comp_path   


##-- change directory
file mkdir $comp_path

cd $comp_path
exec rm -Rf *

proc q  {} {quit -force                  }

proc sleep {N} {
    after [expr {int($N * 1000)}]
}


#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

###################################################################
##---- 1. Creating working library
set text "###################################################################"
set text "##---- 1. Creating working library"

##-- Create work lib
vlib $work_path

##-- Mapping work lib
vmap work $work_path



###################################################################
##---- 3. Compile the Design
set text "###################################################################"
set text "##---- 3. Compile the Design"

#+acc=rn
vlog -sv -work  $work_path +acc=rn  +incdir+$dirs -F  $path1/filelist.f
vlog -sv -work  $work_path +acc=rn  +incdir+$dirs -F  $path2/filelist.f
 


set text "###################################################################"
set text "##                       END OF COMPILATION"
set text "###################################################################"


#vsim -t ps work.testbench_router // trun off non-unique case warning 8315,8360
vsim  -t ps  work.testbench_noc 	

#do "$comp_path/wave.do"

run 100 ms

quit



#####################################################################################

