proc impliment_arb { lib_name arb report_dir args } {
	file mkdir $report_dir
	foreach i [list 4 8 16 32 64 128 256] { 
		puts ${arb}_$i 
		set top ${arb}_$i
		elaborate $top 
		for { set j 1 } { $j <= 10 } { incr j } {
			optimize .work.$top.INTERFACE -target $lib_name -macro -auto -effort remap -hierarchy flatten 
			optimize_timing .work.$top.INTERFACE -force 
			report_delay $report_dir/${top}_delay${j}.txt -num_paths 1 -critical_paths -clock_frequency
			report_area $report_dir/${top}_area${j}.txt -cell_usage -all_leafs 
		}
	}
}


set lib_name gdk
set arb tca

load_library $lib_name
set_working_dir C:/leonardo/work


read  { C:/leonardo/new_src/carison.v C:/leonardo/new_src/fra.v C:/leonardo/new_src/iprra.v C:/leonardo/new_src/ping_arbiter.v C:/leonardo/new_src/ping_lock.v C:/leonardo/new_src/ping_org.v C:/leonardo/new_src/ppe.v C:/leonardo/new_src/prra.v C:/leonardo/new_src/tca.v }
pre_optimize -common_logic -unused_logic -boundary -xor_comparator_optimize 
pre_optimize -extract 

foreach arb [list prra iprra tca fra  ping_arbiter ping_lock ping_org  ppe] { 

set report_dir C:/leonardo/work/report/${arb}/


impliment_arb $lib_name $arb $report_dir

}
