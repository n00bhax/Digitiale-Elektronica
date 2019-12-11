onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+TriangleFifo -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.TriangleFifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {TriangleFifo.udo}

run -all

endsim

quit -force
