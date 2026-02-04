# OptoML_Submission

This project implements a single-stage pipeline register in SystemVerilog using the standard valid/ready handshake protocol.
The module sits between an upstream producer and a downstream consumer and ensures loss-free, duplication-free data transfer while correctly handling backpressure.

The design is fully synthesizable, reset-safe, and suitable for ASIC / FPGA / SoC pipeline designs.

Features

Standard valid/ready handshake

Single-entry pipeline buffer

Handles downstream backpressure

Supports simultaneous push and pop

No data loss or duplication

Fully synthesizable RTL

Self-checking SystemVerilog testbench

Input Interface
Signal	Description
in_valid	Indicates input data is valid
in_ready	Indicates pipeline can accept data
in_data	Input data
Output Interface
Signal	Description
out_valid	Indicates output data is valid
out_ready	Downstream ready signal
out_data	Output data
