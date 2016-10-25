$nocompile

Mbs_f_read_coil_status Alias 1
Mbs_f_read_discrete_inputs Alias 2
Mbs_f_read_holding_registers Alias 3
Mbs_f_read_input_registers Alias 4
Mbs_f_write_single_coil Alias 5
Mbs_f_write_single_register Alias 6
Mbs_f_write_multiple_coils Alias 15
Mbs_f_write_multiple_registers Alias 16                     ' Not implemented yet
Mbs_f_read_write_registers Alias 23

Mbs_f_user_function Alias 65                                ' Not defined in standard what function do, this is user applicable code
Mbs_f_dummy Alias 255

'Exception response codes
Mbs_illegal_function Alias 1
Mbs_illegal_data_address Alias 2
Mbs_illegal_data_value Alias 3