#!/bin/sh

echo "Running address generator testbench"
iverilog -o address_generator_exe hdl/address_generator.v testbench/address_generator_tb.v
vvp address_generator_exe

echo "Running strand driver testbench"
iverilog -o strand_driver_exe hdl/strand_driver.v testbench/strand_driver_tb.v
vvp strand_driver_exe
