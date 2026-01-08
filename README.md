# Smart Parking Management System

## Overview
This repository contains the SystemVerilog implementation of a **Smart Parking Management System**. The project was designed as a digital logic circuit to automate parking lot operations, utilizing a **Finite State Machine (FSM)** to handle state transitions for vehicle entry and exit processes.

## Features
* **Automated Access Control:** Manages barrier gate logic based on sensor inputs (entry/exit request).
* **Capacity Tracking:** Real-time counter logic to track available slots and prevent entry when full.
* **FSM Implementation:** Robust state machine design to handle distinct system states (IDLE, CHECK_CAPACITY, OPEN_GATE, CLOSE_GATE).
* **Simulation & Verification:** Logic verified through waveform simulations.

## Tech Stack
* **Language:** SystemVerilog / Verilog
* **Tools:** Xilinx Vivado / ModelSim
* **Hardware Target:** FPGA (Basys 3 / Generic)
