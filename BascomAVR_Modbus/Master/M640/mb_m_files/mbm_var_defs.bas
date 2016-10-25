$nocompile
Dim Mbm_slave_adress As Byte
Dim Mbm_buffer(48) As Byte                                  ' Temp array for Modbus function
Dim Mbm_slave_adress_received As Byte At Mbm_buffer(1) Overlay
Dim Mbm_function As Byte At Mbm_buffer(2) Overlay
Dim Mbm_device_adress_hi As Byte At Mbm_buffer(3) Overlay
Dim Mbm_device_adress_lo As Byte At Mbm_buffer(4) Overlay
Dim Mbm_byte_count As Byte At Mbm_buffer(3) Overlay
Dim Mbm_device_adress As Word
Dim Mbm_number_of_devices_hi As Byte At Mbm_buffer(5) Overlay
Dim Mbm_number_of_devices_lo As Byte At Mbm_buffer(6) Overlay
Dim Mbm_number_of_devices As Word
Dim Mbm_data_byte(8) As Byte At Mbm_buffer(4) Overlay
Dim Mbm_register_read(maximum_holding_registers) As Word At Mbm_buffer(4) Overlay
Dim Mbm_registers_write(maximum_holding_registers) As Word At Mbm_buffer(5) Overlay
Dim Mbm_register_write_hi As Byte At Mbm_buffer(5) Overlay
Dim Mbm_register_write_lo As Byte At Mbm_buffer(6) Overlay
'Rem Dim mbm_f15_count As Byte At mbm_buffer(7) Overlay
'Rem Dim mbm_f15_data(8) As Byte At mbm_buffer(8) Overlay
Dim Response_received As Byte
Dim Modus_error As Byte
Dim Dummy_mbm_byte As Byte
Dim Coils_to_read As Byte At Dummy_mbm_byte Overlay
Dim Discrete_inputs As Byte At Dummy_mbm_byte Overlay
Dim Write_coil_value As Byte At Dummy_mbm_byte Overlay
Dim Registers_to_read As Byte At Dummy_mbm_byte Overlay
Dim Coils_to_write As Byte At Dummy_mbm_byte Overlay

   Dim Mbm_coil_status_table(5) As Byte                     ' One more than number_of_coils/8
   Dim Mbm_discrete_inputs_table(6) As Byte                 ' One more than number_of_inputs/8
   Dim Mbm_holding_registers_table(maximum_holding_registers) As Word
   Dim Mbm_input_registers_table(maximum_input_registers) As Word