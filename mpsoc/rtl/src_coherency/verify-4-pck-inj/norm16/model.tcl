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
set path8		$path0/..
set injct_path          $path/injector/rtl

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



#-svinputport=net

vlog -sv  -svinputport=net -source -work  $work_path  +acc=rn  \
$injct_path/inj_common/sync_ff_fifo.sv \
$injct_path/l2/l2_pkg.sv                                                 \
$injct_path/l2/ptr_table.sv                                              \
$injct_path/l2/l2_ctrl.sv                                                \
$injct_path/l2/l2.sv                                                     \
$injct_path/l2/lp_monitor.sv                                             \
$injct_path/l2/psd_rr_arb.sv                                             \
$injct_path/l2/l2_sb_wrapper.sv                                          \
$injct_path/l2/l2_wrapper.sv                                             \
$injct_path/chi_rn_agent/rtl/rn_agent/chi_rn_params_pkg.sv               \
$injct_path/chi_rn_agent/rtl/chi_rn_agent.sv                         \
$injct_path/chi_rn_agent/rtl/rn_agent/fill_arb.sv                        \
$injct_path/chi_rn_agent/rtl/rn_agent/flit_flow.sv                       \
$injct_path/chi_rn_agent/rtl/rn_agent/rx_queue.sv                        \
$injct_path/chi_rn_agent/rtl/rn_agent/rx_queue_nobypass.sv               \
$injct_path/chi_rn_agent/rtl/rn_agent/snp_p/snp_p_l2_to_chi.sv           \
$injct_path/chi_rn_agent/rtl/rn_agent/snp_p/snp_p_chi_to_l2.sv           \
$injct_path/chi_rn_agent/rtl/rn_agent/tables/wdat_mem.sv                 \
$injct_path/chi_rn_agent/rtl/rn_agent/tables/txnid_mem.sv                \
$injct_path/chi_rn_agent/rtl/rn_agent/tables/snoop_mem.sv                \
$injct_path/chi_rn_agent/rtl/rn_agent/tables/pcrdgrant_mem.sv            \
$injct_path/chi_rn_agent/rtl/rn_agent/txreq_p/txreq_p_arb.sv             \
$injct_path/chi_rn_agent/rtl/rn_agent/txreq_p/txreq_p_alloc.sv           \
$injct_path/chi_rn_agent/rtl/rn_agent/txreq_p/txreq_p_enc.sv             \
$injct_path/chi_rn_agent/rtl/rn_agent/txreq_p/txreq_p_tx.sv              \
$injct_path/chi_rn_agent/rtl/rn_agent/txreq_p/txreq_p.sv                 \
$injct_path/chi_rn_agent/rtl/rn_agent/rxdat_p/rxdat_p_rx.sv              \
$injct_path/chi_rn_agent/rtl/rn_agent/rxdat_p/rxdat_p_dec.sv             \
$injct_path/chi_rn_agent/rtl/rn_agent/rxdat_p/rxdat_p_arb.sv             \
$injct_path/chi_rn_agent/rtl/rn_agent/rxdat_p/rxdat_p_tx.sv              \
$injct_path/chi_rn_agent/rtl/rn_agent/rxdat_p/rxdat_p.sv                 \
$injct_path/chi_rn_agent/rtl/rn_agent/rxrsp_p/rxrsp_p_rx.sv              \
$injct_path/chi_rn_agent/rtl/rn_agent/rxrsp_p/rxrsp_p_dec.sv             \
$injct_path/chi_rn_agent/rtl/rn_agent/rxrsp_p/rxrsp_p_arb.sv             \
$injct_path/chi_rn_agent/rtl/rn_agent/rxrsp_p/rxrsp_p_tx.sv              \
$injct_path/chi_rn_agent/rtl/rn_agent/rxrsp_p/rxrsp_p.sv                 \
$injct_path/chi_rn_agent/rtl/rn_agent/retry_logic/retry_logic.sv         \
$injct_path/tim/tim_pkg.sv                                               \
$injct_path/tim/miss_table.sv                                            \
$injct_path/tim/tim.sv                                                   \
$injct_path/injector_top.sv   						 \
$injct_path/chi_rn_agent/rtl/chi_rn_agent_snoc/chi_rn_agent_if.sv	 \
$injct_path/chi_rn_agent/rtl/chi_rn_agent_snoc/chi_rn_agent_snoc.sv
                                           
			
		


 



foreach a [list $path0 $path $path1 $path2 $path3 $path4 $path5 $path6 $path7 $path8]  {
      puts "$a "
      set lib_file_list [glob -directory $a *.v *.sv]
	foreach f $lib_file_list {
       
		if { $last_compile_time < [file mtime $f] } {
			vlog  -work  $work_path  +acc=rn +incdir+$a+$path0  $f
			
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

#do "$comp_path/wave.do"

run 100 ms

quit


#####################################################################################

