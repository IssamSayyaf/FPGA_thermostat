# ==============================================================================
# TEMPMUX Digital Thermostat Controller - Makefile
# ==============================================================================
# This Makefile automates the compilation, simulation, and testing of the
# TEMPMUX digital thermostat controller using Xilinx Vivado tools.
#
# Author: FPGA Development Team
# Date: August 8, 2025
# Version: 1.0
# ==============================================================================

# ==============================================================================
# MAKEFILE BASICS EXPLANATION
# ==============================================================================
# A Makefile consists of:
# 1. Variables - Store values that can be reused
# 2. Targets - Actions that can be executed (like functions)
# 3. Dependencies - Files that targets depend on
# 4. Rules - Commands to execute for each target
#
# Basic syntax:
# target: dependencies
# 	command1
# 	command2
#
# IMPORTANT: Commands must be indented with TABS, not spaces!

# ==============================================================================
# VARIABLES SECTION
# ==============================================================================
# Variables store commonly used values to avoid repetition and make
# maintenance easier. Use $(VARIABLE_NAME) to reference them.

# Project configuration
PROJECT_NAME = tempmux
TOP_MODULE = TEMPMUX
TESTBENCH = T_TEMPMUX_tb

# Source files (all VHDL files in the project)
VHDL_SOURCES = TEMPMUX.vhd T_TEMPMUX_tb.vhd

# Tool commands - Change these if tools are in different locations
# VHDL compiler
XVHDL = xvhdl
# Elaborator (links compiled units)
XELAB = xelab
# Simulator
XSIM = xsim

# Simulation configuration
# Run simulation until completion
SIM_TIME = --runall
# Default work library name
WORK_LIB = work

# Directory structure
# Directory for build artifacts
BUILD_DIR = build
# Directory for log files
LOG_DIR = logs
# Directory for reports
REPORT_DIR = reports

# File extensions and patterns
VHDL_EXT = .vhd
LOG_EXT = .log

# ==============================================================================
# DEFAULT TARGET (PHONY TARGETS)
# ==============================================================================
# .PHONY declares targets that don't create files with the same name
# This prevents conflicts if files with these names exist
.PHONY: all clean help compile elaborate simulate test setup dirs

# Default target - runs when you type just "make"
# This should be the most common action users want
all: test
	@echo "=== TEMPMUX Build Complete ==="
	@echo "All targets successfully built and tested!"

# ==============================================================================
# HELP TARGET
# ==============================================================================
# Provides user documentation for available targets
help:
	@echo "==============================================="
	@echo "TEMPMUX Digital Thermostat Controller Makefile"
	@echo "==============================================="
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Build and test everything (default)"
	@echo "  compile    - Compile VHDL source files"
	@echo "  elaborate  - Elaborate the design"
	@echo "  simulate   - Run the simulation"
	@echo "  test       - Complete test flow (compile + elaborate + simulate)"
	@echo "  setup      - Create necessary directories"
	@echo "  clean      - Remove all generated files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make           # Run complete test"
	@echo "  make compile   # Just compile VHDL files"
	@echo "  make clean     # Clean up generated files"
	@echo "  make help      # Show this help"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Xilinx Vivado tools must be in PATH"
	@echo "  - VHDL source files must be present"

# ==============================================================================
# SETUP TARGETS
# ==============================================================================
# Create directory structure for organized builds
setup: dirs
	@echo "=== Setting up build environment ==="

# Create necessary directories
# The @ symbol suppresses echo of the command
# The - symbol ignores errors (useful if directories already exist)
dirs:
	@echo "Creating build directories..."
	-@mkdir -p $(BUILD_DIR)
	-@mkdir -p $(LOG_DIR)
	-@mkdir -p $(REPORT_DIR)
	@echo "Directories created successfully."

# ==============================================================================
# COMPILATION TARGETS
# ==============================================================================

# Compile all VHDL source files
# Dependencies: source files must exist and directories must be set up
compile: setup $(VHDL_SOURCES)
	@echo "=== Compiling VHDL Sources ==="
	@echo "Compiling $(TOP_MODULE)..."
	$(XVHDL) $(TOP_MODULE)$(VHDL_EXT) 2>&1 | tee $(LOG_DIR)/compile_design$(LOG_EXT)
	@echo "Compiling $(TESTBENCH)..."
	$(XVHDL) $(TESTBENCH)$(VHDL_EXT) 2>&1 | tee $(LOG_DIR)/compile_testbench$(LOG_EXT)
	@echo "Compilation completed successfully!"

# Alternative target for compiling just the design (without testbench)
compile-design: setup $(TOP_MODULE)$(VHDL_EXT)
	@echo "=== Compiling Design Only ==="
	$(XVHDL) $(TOP_MODULE)$(VHDL_EXT) 2>&1 | tee $(LOG_DIR)/compile_design_only$(LOG_EXT)

# ==============================================================================
# ELABORATION TARGET
# ==============================================================================

# Elaborate the testbench (links all compiled units together)
# Dependencies: compilation must be completed first
elaborate: compile
	@echo "=== Elaborating Design ==="
	@echo "Elaborating testbench: $(TESTBENCH)"
	$(XELAB) $(TESTBENCH) 2>&1 | tee $(LOG_DIR)/elaborate$(LOG_EXT)
	@echo "Elaboration completed successfully!"

# ==============================================================================
# SIMULATION TARGETS
# ==============================================================================

# Run simulation
# Dependencies: elaboration must be completed first
simulate: elaborate
	@echo "=== Running Simulation ==="
	@echo "Starting simulation of $(TESTBENCH)..."
	$(XSIM) work.$(TESTBENCH) $(SIM_TIME) 2>&1 | tee $(LOG_DIR)/simulate$(LOG_EXT)
	@echo "Simulation completed!"

# Quick simulation (skips setup and logs)
sim-quick:
	@echo "=== Quick Simulation ==="
	$(XSIM) work.$(TESTBENCH) $(SIM_TIME)

# Interactive simulation (opens GUI)
sim-gui: elaborate
	@echo "=== Opening Simulation GUI ==="
	$(XSIM) work.$(TESTBENCH) -gui &

# ==============================================================================
# TESTING TARGETS
# ==============================================================================

# Complete test flow - most commonly used target
test: compile elaborate simulate
	@echo "=== Complete Test Flow Finished ==="
	@echo "Check $(LOG_DIR)/simulate$(LOG_EXT) for detailed results"
	@echo ""
	@echo "Test Summary:"
	@grep -E "(PASS|FAIL|ERROR)" $(LOG_DIR)/simulate$(LOG_EXT) || echo "No explicit PASS/FAIL found"
	@echo ""
	@echo "Build artifacts location: $(BUILD_DIR)/"
	@echo "Log files location: $(LOG_DIR)/"

# Run only testbench compilation and simulation (faster for iterative testing)
test-quick: setup
	@echo "=== Quick Test (Compile + Simulate) ==="
	$(XVHDL) $(TOP_MODULE)$(VHDL_EXT)
	$(XVHDL) $(TESTBENCH)$(VHDL_EXT)
	$(XELAB) $(TESTBENCH)
	$(XSIM) work.$(TESTBENCH) $(SIM_TIME)

# ==============================================================================
# UTILITY TARGETS
# ==============================================================================

# Show project status and file information
status:
	@echo "=== Project Status ==="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Top Module: $(TOP_MODULE)"
	@echo "Testbench: $(TESTBENCH)"
	@echo ""
	@echo "Source Files:"
	@ls -la *.vhd 2>/dev/null || echo "No VHDL files found"
	@echo ""
	@echo "Build Directory Contents:"
	@ls -la $(BUILD_DIR)/ 2>/dev/null || echo "Build directory not found"
	@echo ""
	@echo "Recent Log Files:"
	@ls -lat $(LOG_DIR)/ 2>/dev/null | head -5 || echo "No log files found"

# Check syntax of VHDL files without full compilation
syntax-check:
	@echo "=== Syntax Check ==="
	@echo "Checking $(TOP_MODULE)$(VHDL_EXT)..."
	$(XVHDL) -check_syntax $(TOP_MODULE)$(VHDL_EXT)
	@echo "Checking $(TESTBENCH)$(VHDL_EXT)..."
	$(XVHDL) -check_syntax $(TESTBENCH)$(VHDL_EXT)
	@echo "Syntax check completed!"

# ==============================================================================
# ANALYSIS TARGETS
# ==============================================================================

# Generate timing report (if synthesis tools are available)
timing-report: compile
	@echo "=== Generating Timing Report ==="
	@echo "This would typically run timing analysis tools"
	@echo "Feature not implemented - requires synthesis tools"

# Show simulation waveforms (if supported)
waveform: elaborate
	@echo "=== Opening Waveform Viewer ==="
	@echo "This would open waveform viewer"
	@echo "Use 'make sim-gui' for interactive simulation"

# ==============================================================================
# MAINTENANCE TARGETS
# ==============================================================================

# Clean up all generated files and directories
clean:
	@echo "=== Cleaning Build Artifacts ==="
	@echo "Removing generated files..."
	-rm -rf $(BUILD_DIR)/
	-rm -rf $(LOG_DIR)/
	-rm -rf $(REPORT_DIR)/
	-rm -rf xsim.dir/
	-rm -rf .Xil/
	-rm -f *.jou
	-rm -f *.log
	-rm -f *.pb
	-rm -f *.wdb
	-rm -f webtalk*
	-rm -f xsim_*.backup.*
	@echo "Clean completed!"

# Deep clean - removes everything including Vivado project files
clean-all: clean
	@echo "=== Deep Clean (Including Project Files) ==="
	-rm -rf $(PROJECT_NAME).cache/
	-rm -rf $(PROJECT_NAME).hw/
	-rm -rf $(PROJECT_NAME).ip_user_files/
	-rm -rf $(PROJECT_NAME).sim/
	-rm -rf $(PROJECT_NAME).hbs/
	-rm -f $(PROJECT_NAME).xpr
	@echo "Deep clean completed!"

# ==============================================================================
# DEBUGGING TARGETS
# ==============================================================================

# Show variables (useful for debugging Makefile)
show-vars:
	@echo "=== Makefile Variables ==="
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "TOP_MODULE: $(TOP_MODULE)"
	@echo "TESTBENCH: $(TESTBENCH)"
	@echo "VHDL_SOURCES: $(VHDL_SOURCES)"
	@echo "BUILD_DIR: $(BUILD_DIR)"
	@echo "LOG_DIR: $(LOG_DIR)"
	@echo "WORK_LIB: $(WORK_LIB)"
	@echo "XVHDL: $(XVHDL)"
	@echo "XELAB: $(XELAB)"
	@echo "XSIM: $(XSIM)"

# Check if required tools are available
check-tools:
	@echo "=== Checking Tool Availability ==="
	@which $(XVHDL) || echo "ERROR: $(XVHDL) not found in PATH"
	@which $(XELAB) || echo "ERROR: $(XELAB) not found in PATH"
	@which $(XSIM) || echo "ERROR: $(XSIM) not found in PATH"
	@echo "Tool check completed."

# ==============================================================================
# ADVANCED FEATURES
# ==============================================================================

# Parallel compilation (if multiple files)
# Use -j flag with make: "make -j4 compile-parallel"
compile-parallel: setup
	@echo "=== Parallel Compilation ==="
	$(XVHDL) $(TOP_MODULE)$(VHDL_EXT) & \
	$(XVHDL) $(TESTBENCH)$(VHDL_EXT) & \
	wait
	@echo "Parallel compilation completed!"

# Regression testing (run multiple test configurations)
regression: clean test
	@echo "=== Regression Test ==="
	@echo "Running complete test suite..."
	$(MAKE) test-quick
	@echo "Regression testing completed!"

# ==============================================================================
# FILE DEPENDENCIES
# ==============================================================================
# These rules tell make when to rebuild targets based on file changes

# Recompile if source files change
$(BUILD_DIR)/$(TOP_MODULE).compiled: $(TOP_MODULE)$(VHDL_EXT) | $(BUILD_DIR)
	$(XVHDL) $<
	@touch $@

$(BUILD_DIR)/$(TESTBENCH).compiled: $(TESTBENCH)$(VHDL_EXT) | $(BUILD_DIR)
	$(XVHDL) $<
	@touch $@

