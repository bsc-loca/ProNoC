onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pck_injector_test/reset
add wave -noupdate /pck_injector_test/clk
add wave -noupdate /pck_injector_test/pck_injct_out
add wave -noupdate -expand {/pck_injector_test/endpoints[2]/pck_inj/pck_injct_in}
add wave -noupdate {/pck_injector_test/endpoints[2]/pck_inj/flit_type}
add wave -noupdate {/pck_injector_test/endpoints[2]/pck_inj/flit_wr}
add wave -noupdate -expand -subitemconfig {{/pck_injector_test/endpoints[2]/pck_inj/chan_out.flit_chanel} -expand} {/pck_injector_test/endpoints[2]/pck_inj/chan_out}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {237379 ps} 0}
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
WaveRestoreZoom {117599 ps} {395072 ps}
