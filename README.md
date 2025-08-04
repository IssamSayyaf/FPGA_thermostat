# TEMPMUX - Temperature Multiplexer FPGA Project

## Overview

TEMPMUX is a VHDL-based FPGA project that implements a temperature control system. The design provides functionality to monitor current temperature, set desired temperature, and control heating/cooling systems accordingly. It features a display multiplexer that can switch between showing current and desired temperature values.

## Project Details

- **Target FPGA**: Xilinx Zynq-7000 (xc7z100ffg900-2)
- **Development Tool**: Xilinx Vivado 2020.1
- **Language**: VHDL
- **Project Type**: Digital Temperature Controller

## Features

### Core Functionality

- **Temperature Monitoring**: 7-bit current temperature input (0-127°F/°C)
- **Temperature Setting**: 7-bit desired temperature input (0-127°F/°C)
- **Display Multiplexer**: Switch between current and desired temperature display
- **Heating Control**: Automatic furnace control based on temperature comparison
- **Cooling Control**: Automatic AC control based on temperature comparison

### Input/Output Signals

- `current_temp[6:0]` - Current temperature reading
- `desired_temp[6:0]` - User-set desired temperature
- `display_select` - Control signal to select display mode
- `cool` - Cooling request signal
- `heat` - Heating request signal
- `temp_display[6:0]` - Multiplexed temperature output for display
- `furance_on` - Furnace control output
- `ac_on` - Air conditioning control output

## File Structure

```text
TEMPMUX/
├── TEMPMUX.xpr                    # Vivado project file
├── T_TEMPMUX_tb_behav.wcfg        # Waveform configuration
├── TEMPMUX.cache/                 # Vivado cache files
├── TEMPMUX.hbs/                   # Hierarchy browser files
├── TEMPMUX.hw/                    # Hardware files
├── TEMPMUX.ip_user_files/         # IP user files
├── TEMPMUX.sim/                   # Simulation files
│   └── sim_1/behav/xsim/          # XSim simulation results
├── ../TEMPMUX.vhd                 # Main VHDL source file
└── ../T_TEMPMUX_tb.vhd           # Testbench file
```

## Getting Started

### Prerequisites

- Xilinx Vivado 2020.1 or compatible version
- Basic knowledge of VHDL and digital design
- Understanding of FPGA development workflow

### Opening the Project

1. Launch Xilinx Vivado
2. Open the project file: `TEMPMUX.xpr`
3. The project will load with all source files and constraints

### Source Files

The project references two main VHDL files located in the parent directory:

- `TEMPMUX.vhd` - Main temperature controller module
- `T_TEMPMUX_tb.vhd` - Comprehensive testbench

## Simulation

### Running Simulation

1. In Vivado, navigate to **Flow Navigator > Simulation**
2. Click **Run Simulation > Run Behavioral Simulation**
3. The testbench will execute and display waveforms

### Waveform Analysis

The simulation includes monitoring of:

- Input temperature values
- Display selection control
- Heating and cooling request signals
- Temperature display output
- HVAC system control outputs

### Pre-configured Waveform

A waveform configuration file (`T_TEMPMUX_tb_behav.wcfg`) is included with:

- All relevant signals pre-configured
- Proper time scale (629ns simulation time)
- Signal grouping for easy analysis

## Implementation

### Synthesis

1. Navigate to **Flow Navigator > Synthesis**
2. Click **Run Synthesis**
3. Review synthesis reports for resource utilization

### Place and Route

1. After successful synthesis, click **Run Implementation**
2. Review timing and placement reports
3. Generate bitstream if targeting hardware deployment

## Design Logic

The TEMPMUX module implements the following control logic:

- **Display Multiplexer**: Selects between current and desired temperature for display
- **Temperature Comparison**: Continuously compares current vs. desired temperature
- **Heating Control**: Activates furnace when current < desired temperature
- **Cooling Control**: Activates AC when current > desired temperature
- **System Status**: Provides real-time status of HVAC systems

## Testing

The included testbench (`T_TEMPMUX_tb`) provides comprehensive testing scenarios:

- Temperature range validation
- Display selection functionality
- Heating/cooling logic verification
- Edge case testing
- System response timing analysis

