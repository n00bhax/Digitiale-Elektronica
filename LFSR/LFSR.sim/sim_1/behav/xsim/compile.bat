@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1.3 (64-bit)
REM
REM Filename    : compile.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for compiling the simulation design source files
REM
REM Generated by Vivado on Mon Oct 28 12:18:57 +0100 2019
REM SW Build 2644227 on Wed Sep  4 09:45:24 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: compile.bat
REM
REM ****************************************************************************
echo "xvhdl --incr --relax -prj TB_LFSR16_vhdl.prj"
call xvhdl  --incr --relax -prj TB_LFSR16_vhdl.prj -log xvhdl.log
call type xvhdl.log > compile.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
