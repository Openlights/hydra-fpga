#!/bin/sh

iverilog -o agtb hdl/address_generator.v testbench/address_generator_tb.v
vvp agtb