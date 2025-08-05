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

### New Enhanced Features

- **Pipelined Architecture**: 2-stage pipeline design for improved timing and performance
  - Stage 1: Input registration to sample all asynchronous inputs
  - Stage 2: Logic processing on registered inputs for stable operation
- **Synchronous Reset**: Complete system reset functionality with proper initialization
- **Input Stabilization**: All asynchronous inputs are registered to prevent metastability
- **Improved HVAC Logic**: Enhanced temperature control with proper priority handling
  - Prevents simultaneous heating and cooling operation
  - Temperature comparison logic with hysteresis consideration
- **Robust I/O Handling**: All outputs are properly registered for clean signal transitions

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

### Architecture Overview

The TEMPMUX module implements a **2-stage pipelined architecture** for optimal performance:

1. **Input Registration Stage**: All asynchronous inputs (temperature sensors, control signals) are sampled and registered on the rising edge of the clock
2. **Logic Processing Stage**: Temperature comparison, display multiplexing, and HVAC control logic operate on the stable registered inputs

### Control Logic

The TEMPMUX module implements the following control logic:

- **Display Multiplexer**: Selects between current and desired temperature for display
- **Temperature Comparison**: Continuously compares current vs. desired temperature using registered values
- **Heating Control**: Activates furnace when (heat='1' AND cool='0' AND current < desired)
- **Cooling Control**: Activates AC when (cool='1' AND heat='0' AND current > desired)
- **Safety Logic**: Prevents simultaneous heating and cooling operations
- **System Status**: Provides real-time status of HVAC systems with registered outputs

### Key Design Improvements

- **Metastability Prevention**: All asynchronous inputs are properly synchronized
- **Pipeline Efficiency**: 2-clock latency for complete input-to-output processing
- **Resource Optimization**: Efficient use of FPGA registers and logic resources
- **Timing Closure**: Improved setup/hold time margins for high-frequency operation

## Testing

The included testbench (`T_TEMPMUX_tb`) provides comprehensive testing scenarios:

### Test Coverage

- **8-Case Truth Table Testing**: Complete verification of all input combinations
- **Temperature Range Validation**: Testing with various temperature values (2°C to 8°C range)
- **Display Selection Functionality**: Verification of multiplexer operation
- **Heating/Cooling Logic Verification**: All HVAC control scenarios tested
- **Pipeline Timing Analysis**: 2-stage pipeline operation verification
- **Reset Functionality**: Proper initialization and reset behavior testing
- **Edge Case Testing**: Boundary conditions and simultaneous signal scenarios
- **System Response Timing**: 20ns test slots with 100MHz clock (10ns period)

### Testbench Features

- **Comprehensive Stimulus**: 8 distinct test cases covering all logical combinations
- **Proper Timing**: Each test case runs for 20ns (2 clock cycles) to verify pipeline operation
- **Clean Reset**: 25ns reset period for proper initialization
- **Signal Monitoring**: All inputs and outputs monitored for complete verification

