// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2700185 Thu Oct 24 18:46:05 MDT 2019
// Date        : Mon Dec  9 11:11:36 2019
// Host        : C940-van-Willem running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top TriangleFifo -prefix
//               TriangleFifo_ TriangleFifo_stub.v
// Design      : TriangleFifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2019.2" *)
module TriangleFifo(clk, srst, din, wr_en, rd_en, dout, full, almost_full, 
  empty)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[58:0],wr_en,rd_en,dout[58:0],full,almost_full,empty" */;
  input clk;
  input srst;
  input [58:0]din;
  input wr_en;
  input rd_en;
  output [58:0]dout;
  output full;
  output almost_full;
  output empty;
endmodule
