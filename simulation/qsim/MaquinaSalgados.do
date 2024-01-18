onerror {quit -f}
vlib work
vlog -work work MaquinaSalgados.vo
vlog -work work MaquinaSalgados.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.MaquinaSalgados_vlg_vec_tst
vcd file -direction MaquinaSalgados.msim.vcd
vcd add -internal MaquinaSalgados_vlg_vec_tst/*
vcd add -internal MaquinaSalgados_vlg_vec_tst/i1/*
add wave /*
run -all
