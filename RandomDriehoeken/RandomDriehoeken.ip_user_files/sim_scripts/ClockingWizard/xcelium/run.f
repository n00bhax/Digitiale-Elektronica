-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../RandomDriehoeken.srcs/sources_1/ip/ClockingWizard/ClockingWizard_clk_wiz.v" \
  "../../../../RandomDriehoeken.srcs/sources_1/ip/ClockingWizard/ClockingWizard.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

