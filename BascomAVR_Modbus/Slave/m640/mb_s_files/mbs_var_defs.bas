$nocompile
Dim Mbs_watchdog As word
Dim timer_3_started as Byte


Dim Mbs_buffer(64) As Byte
Dim Mbs_adress_received As Byte At Mbs_buffer(1) Overlay
Dim Mbs_function As Byte At Mbs_buffer(2) Overlay
Dim Mbs_device_adress_hi As Byte At Mbs_buffer(3) Overlay
Dim Mbs_device_adress_lo As Byte At Mbs_buffer(4) Overlay
Dim Mbs_device_adress As Word
Dim Mb_number_of_devices_hi As Byte At Mbs_buffer(5) Overlay
Dim Mb_number_of_devices_lo As Byte At Mbs_buffer(6) Overlay
Dim Mbs_number_of_devices As Word
Dim Mbs_data_byte(8) As Byte At Mbs_buffer(4) Overlay
Dim Mbs_register_read(mbs_maximum_holding_registers) As Word At Mbs_buffer(4) Overlay
Dim Mbs_registers_write(mbs_maximum_holding_registers) As Word At Mbs_buffer(5) Overlay
Dim Mbs_register_write_hi As Byte At Mbs_buffer(5) Overlay
Dim Mbs_register_write_lo As Byte At Mbs_buffer(6) Overlay

Dim Mb_f15_count As Byte At Mbs_buffer(7) Overlay
Dim Mb_f15_data(8) As Byte At Mbs_buffer(8) Overlay

Dim Mbs_coil_status_table(5) As Byte                        ' One more than number_of_coils/8
Dim Mbs_discrete_inputs_table(6) As Byte                    ' One more than number_of_inputs/8
Dim Mbs_holding_registers_table(16) As Word
Dim Mbs_input_registers_table(16) As Word

Rem F_read_write_registers
Dim F23_read_adress as word At Mbs_buffer(3) Overlay
Dim F23_to_read as word At Mbs_buffer(5) Overlay
Dim F23_to_read_end as byte
Dim F23_no_off_data_bytes as Byte at Mbs_buffer(3) Overlay  ' Number of bytes to return
Dim F23_Read_data(8) as byte at Mbs_buffer(4) Overlay       ' Readed bytes
Dim F23_Read_data_word(4) as word at F23_Read_data(1) Overlay       ' Readed bytes

Dim F23_write_adress as word At Mbs_buffer(7) Overlay
Dim F23_to_write as word At Mbs_buffer(9) Overlay
Dim F23_Write_data(4) as word at Mbs_buffer(12) Overlay