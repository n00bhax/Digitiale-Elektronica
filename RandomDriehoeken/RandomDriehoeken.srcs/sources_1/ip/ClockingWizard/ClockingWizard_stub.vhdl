-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2700185 Thu Oct 24 18:46:05 MDT 2019
-- Date        : Thu Nov  7 17:35:28 2019
-- Host        : DESKTOP-B92ENGA running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Universiteit/VivadoProjects/RandomDriehoeken/RandomDriehoeken.srcs/sources_1/ip/ClockingWizard/ClockingWizard_stub.vhdl
-- Design      : ClockingWizard
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockingWizard is
  Port ( 
    PixelClk : out STD_LOGIC;
    Clk100MHz : in STD_LOGIC
  );

end ClockingWizard;

architecture stub of ClockingWizard is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "PixelClk,Clk100MHz";
begin
end;
