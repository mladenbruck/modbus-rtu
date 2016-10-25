$nocompile
'********************************************************************
' This is user configurable.
' Config to match modbus client hardware
'********************************************************************

F_read_coil_status Alias 1
F_read_discrete_inputs Alias 2
F_read_holding_registers Alias 3
F_read_input_registers Alias 4
F_write_single_coil Alias 5
F_write_multiple_coils Alias 15
F_write_single_register Alias 6
F_write_multiple_registers Alias 16                         ' Not implemented yet
F_read_single_adc Alias 65                                  ' Not defined in standard, user applicable
F_dummy Alias 255

'Exception response codes
Illegal_function Alias 1
Illegal_data_address Alias 2
Illegal_data_value Alias 3