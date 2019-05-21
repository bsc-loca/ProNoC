onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_4x4_testbench/uut/rnf/chi_noc_txreqflitpend
add wave -noupdate /top_4x4_testbench/uut/rnf/chi_noc_txreqflitv
add wave -noupdate /top_4x4_testbench/uut/rnf/chi_noc_txreqflit
add wave -noupdate /top_4x4_testbench/uut/rnf/noc_chi_txreqlcrdv
add wave -noupdate /top_4x4_testbench/uut/the_chi_noc/clk
add wave -noupdate /top_4x4_testbench/uut/rnf/Readshared
add wave -noupdate /top_4x4_testbench/Readshared
add wave -noupdate /top_4x4_testbench/read_addr
add wave -noupdate /top_4x4_testbench/reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1350 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 309
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {13934 ps}
