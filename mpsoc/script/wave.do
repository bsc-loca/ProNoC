onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multicast_test/reset
add wave -noupdate /multicast_test/clk
add wave -noupdate /multicast_test/current_e_addr
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/dest_port_multi}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/clear_dspt_mulicast}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/reset_ivc}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/multiple_dest}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/flit_is_tail}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/flit_in}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/flit_in_wr}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/any_ivc_sw_request_granted}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/ivc_num_getting_sw_grant}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/reset_ivc}
add wave -noupdate {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/nonspec/the_flit_buffer/sub_rd_ptr_ld}
add wave -noupdate -expand {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/nonspec/the_flit_buffer/no_pow2/loop0[0]/multicast/sub_rd_ptr}
add wave -noupdate -expand -subitemconfig {{/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/nonspec/the_flit_buffer/tail_fifo[0]} -expand} {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/nonspec/the_flit_buffer/tail_fifo}
add wave -noupdate -expand {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/nonspec/the_flit_buffer/flit_is_tail}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {281793 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {215489 ps} {343489 ps}
