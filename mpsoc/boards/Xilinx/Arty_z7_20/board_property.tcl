proc set_project_properties { } {
	set_property "board_part_repo_paths" [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]] [current_project]
	set_property "part" "xc7z020clg400-1" [current_project]
	set_property "board_part" "digilentinc.com:arty-z7-20:part0:1.0" [current_project]
	set_property "default_lib" "xil_defaultlib" [current_project]
}
