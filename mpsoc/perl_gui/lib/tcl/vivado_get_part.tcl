if { $argc == 0 } {
        puts "The script requires board_part and repoto be input."
        puts "Please try again."
	exit
    } 



if { $argc >1 } {
	set path [lindex $argv 1] 
	set_param board.repoPaths [list "$path"]
}
       
  set board_part [lindex $argv 0]

  create_project -force tmp 
 
  set_property "board_part" $board_part [current_project]     
  set parts [get_parts [get_property PART_NAME [current_board_part]]]
	puts "*RESULT:$parts"
exit




