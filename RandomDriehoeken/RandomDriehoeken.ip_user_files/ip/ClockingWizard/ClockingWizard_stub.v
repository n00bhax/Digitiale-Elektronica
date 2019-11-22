// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2700185 Thu Oct 24 18:46:05 MDT 2019
// Date        : Thu Nov  7 17:35:28 2019
// Host        : DESKTOP-B92ENGA running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Universiteit/VivadoProjects/RandomDriehoeken/RandomDriehoeken.srcs/sources_1/ip/ClockingWizard/ClockingWizard_stub.v
// Design      : ClockingWizard
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module ClockingWizard(PixelClk, Clk100MHz)
/* synthesis syn_black_box black_box_pad_pin="PixelClk,Clk100MHz" */;
  output PixelClk;
  input Clk100MHz;
endmodule
