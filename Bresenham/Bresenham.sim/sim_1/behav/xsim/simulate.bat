@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1.3 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Tue Oct 22 13:54:57 +0200 2019
REM SW Build 2644227 on Wed Sep  4 09:45:24 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim tb_DrawLine_behav -key {Behavioral:sim_1:Functional:tb_DrawLine} -tclbatch tb_DrawLine.tcl -log simulate.log"
call xsim  tb_DrawLine_behav -key {Behavioral:sim_1:Functional:tb_DrawLine} -tclbatch tb_DrawLine.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
