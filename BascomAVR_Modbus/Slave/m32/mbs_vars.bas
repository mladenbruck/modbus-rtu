$nocompile
Dim Mbuf_rcv(16) As Byte
Dim Modbus_slave_adress_received As Byte At Mbuf_rcv(1) Overlay
Dim Modbus_function As Byte At Mbuf_rcv(2) Overlay
Dim Modbus_device_adress_hi As Byte At Mbuf_rcv(3) Overlay
Dim Modbus_device_adress_lo As Byte At Mbuf_rcv(4) Overlay
Dim Modbus_device_adress As Word
Dim Mb_number_of_devices_hi As Byte At Mbuf_rcv(5) Overlay
Dim Mb_number_of_devices_lo As Byte At Mbuf_rcv(6) Overlay
Dim Modbus_number_of_devices As Word
Dim Modbus_data_byte(8) As Byte At Mbuf_rcv(4) Overlay
Dim Modbus_register_read(maximum_holding_registers) As Word At Mbuf_rcv(4) Overlay
Dim Modbus_registers_write(maximum_holding_registers) As Word At Mbuf_rcv(5) Overlay
Dim Modbus_register_write_hi As Byte At Mbuf_rcv(5) Overlay
Dim Modbus_register_write_lo As Byte At Mbuf_rcv(6) Overlay
Dim Mb_f15_count As Byte At Mbuf_rcv(7) Overlay
Dim Mb_f15_data(8) As Byte At Mbuf_rcv(8) Overlay
#if Use_read_coil_status = 1 Or Use_write_single_coil = 1
   Dim Coil_status_table(5) As Byte                         ' One more than number_of_coils/8
#endif
#if Use_read_discrete_inputs = 1
   Dim Discrete_inputs_table(6) As Byte                     ' One more than number_of_inputs/8
#endif
#if Use_read_holding_registers = 1 Or Use_write_single_register = 1
   Dim Holding_registers_table(Maximum_holding_registers) As Word
#endif
#if Use_read_input_registers = 1
   Dim Input_registers_table(16) As Word
#endif

' Genereal program use
Dim mbs_for_loop As Byte