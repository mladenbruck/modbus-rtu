#if Use_read_coil_status = 1 Or Use_read_discrete_inputs = 1
   Declare Function Bit_index_byte(byval Bit_index As Word , Lista() As Byte) As Byte
#endif
#if Use_read_discrete_inputs = 1
   Declare Sub Copy_inputs_to_table
#endif
#if Use_write_single_coil = 1
   Declare Sub Write_single_coil(byval Coil As Word , Byval Value As Byte)
#endif
Declare Sub Modbus_exec
Declare Sub Send_exception
