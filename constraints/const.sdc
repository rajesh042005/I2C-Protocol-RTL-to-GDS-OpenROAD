current_design i2c_top

set clk_name core_clock
set clock_port_name clk

set clk_period 10.0
set clk_io_pct 0.2

set clk_port [get_ports clk]
create_clock -name $clk_name -period $clk_period $clk_port

# Apply delay to remaining inputs
set_input_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_inputs]

set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

# Reset as false path
set_false_path -from [get_ports rst]

# Driving cell
#set_driving_cell -lib_cell INV_X1 [all_inputs]

# Output load
set_load 0.1 [all_outputs]
