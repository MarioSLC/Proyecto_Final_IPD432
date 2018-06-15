onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+clock_mig -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clock_mig xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {clock_mig.udo}

run -all

endsim

quit -force
