onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multicast_test/reset
add wave -noupdate /multicast_test/clk
add wave -noupdate /multicast_test/current_e_addr
add wave -noupdate -expand -subitemconfig {{/multicast_test/the_noc/chan_out_all[1]} -expand {/multicast_test/the_noc/chan_out_all[0]} -expand {/multicast_test/the_noc/chan_out_all[0].flit_chanel} -expand} /multicast_test/the_noc/chan_out_all
add wave -noupdate {/multicast_test/the_noc/chan_out_all[0].flit_chanel.flit_wr}
add wave -noupdate {/multicast_test/the_noc/chan_out_all[1].flit_chanel.flit_wr}
add wave -noupdate {/multicast_test/the_noc/chan_out_all[2].flit_chanel.flit_wr}
add wave -noupdate {/multicast_test/the_noc/chan_out_all[3].flit_chanel.flit_wr}
add wave -noupdate {/multicast_test/the_noc/chan_out_all[4].flit_chanel.flit_wr}
add wave -noupdate -expand -subitemconfig {{/multicast_test/the_noc/chan_in_all[1]} -expand {/multicast_test/the_noc/chan_in_all[1].flit_chanel} -expand} /multicast_test/the_noc/chan_in_all
add wave -noupdate -radix binary -childformat {{{/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/dest_port_encoded[0]} -radix binary}} -expand -subitemconfig {{/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/dest_port_encoded[0]} {-radix binary}} {/multicast_test/the_noc/star_/noc_top/the_router/router_ref/the_inout_ports/the_input_port/Port_[1]/the_input_queue_per_port/dest_port_encoded}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {287103 ps} 0}
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
WaveRestoreZoom {0 ps} {1024 ns}
