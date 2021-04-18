#!/usr/bin/tclsh

###################################################################
## Author      : Alireza Monemi
## Email       : 
## Description : Compile all verilog files inside the design folder 
##             : using modelsim
###################################################################
set text "###################################################################"
set text "##                Start Compilation Script "
set text "###################################################################"

###################################################################
##---- Specify variables
set text "###################################################################"
set text "##---- Specify variables"

##-- Project path variables


set path0	[pwd]
set path 			[pwd]/../..
	
set path1		$path/../src_noc
set path2		$path/../src_peripheral/ram
set path3		$path/cache
set path4		$path/chi_noc
set path5		$path/hnf
set path6		$path/snf
set path7		$path/rnf

set comp_path 			$path/../../../verify/modelsim
set work_path			$comp_path/work



##-- change directory
file mkdir $comp_path

cd $comp_path
exec rm -Rf *
proc r  {} {uplevel #0 source compile.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
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


# Compile out of date files
set time_now [clock seconds]

if {[file isfile start_time.txt] != 0} {
 	set fp [open start_time.txt r]
	set line [gets $fp]
  	close $fp
  	regexp {\d+} $line last_compile_time
 	puts "last compiled time is  $last_compile_time"
} else {
	set last_compile_time 0
}

set last_compile_time 0




 foreach a [list $path0 $path $path1 $path2 $path3 $path4 $path5 $path6 $path7]  {
      puts "$a "
      set lib_file_list [glob -directory $a *.v *.sv]
	foreach f $lib_file_list {
       
		if { $last_compile_time < [file mtime $f] } {
			#vlog  -work  $work_path  +acc=rn +incdir+$a  $f
			vlog  -work  $work_path   +incdir+$a  $f
			 set last_compile_time 0
        	} else {
			 puts "$f is uptodate"
		}    
        }
  }


set last_compile_time $time_now



set text "###################################################################"
set text "##                       END OF COMPILATION"
set text "###################################################################"


#vsim -t ps work.testbench_router
vsim  -t ps  work.testbench

do "$comp_path/wave.do"

run 100 ms

quit


#####################################################################################

