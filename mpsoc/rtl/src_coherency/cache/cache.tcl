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
set path 			[pwd]
set src_path			$path	
set src_lib_path		$path/../src_noc
set src_ram_path		$path/../src_peripheral/ram
set comp_path 			$path/../../mpsoc_work/modelsim
set work_path			$comp_path/work
		
set file_list [glob -directory $src_path *.v]
set lib_file_list [glob -directory $src_lib_path *.v]
set ram_file_list [glob -directory $src_ram_path *.v]


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


foreach f $lib_file_list {
       
		if { $last_compile_time < [file mtime $f] } {
			vlog -work  $work_path  +incdir+$src_lib_path  $f
			 set last_compile_time 0
        	} else {
			 puts "$f is uptodate"
		}    
        }

foreach f $ram_file_list {
       
		if { $last_compile_time < [file mtime $f] } {
			vlog -work  $work_path  +incdir+$src_ram_path  $f
			 set last_compile_time 0
        	} else {
			 puts "$f is uptodate"
		}    
        }


foreach f $file_list {
       
		if { $last_compile_time < [file mtime $f] } {
			vlog -work  $work_path  +incdir+$src_path  $f
			 set last_compile_time 0
        	} else {
			 puts "$f is uptodate"
		}    
        }


set last_compile_time $time_now



set text "###################################################################"
set text "##                       END OF COMPILATION"
set text "###################################################################"


#vsim -t ps work.testbench_router
vsim  -t ps  work.pronoc_cache_testbench

run 100 ms

#save last compile time

  set fp [open start_time.txt w]
  puts $fp "Start time was [clock seconds]"
  close $fp

#q


#####################################################################################

