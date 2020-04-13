set l [llength $argv]
if {$l > 0} {
	set path [lindex $argv 0]
	puts "Set repo path: $path"
	set_param board.repoPaths [list "$path"]
}
	
	puts [get_board_parts]

exit



