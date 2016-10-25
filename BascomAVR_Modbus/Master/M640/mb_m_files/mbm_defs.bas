$nocompile
Declare Function Mbm_bit_index_byte(byval Bit_index As Word , Lista As Byte) As Byte
Declare Sub Mbm_copy_coils_to_table
Declare Sub Mbm_copy_inputs_to_table
Declare Sub Mbm_copy_registers_to_table
Declare sub Send_modbus(byval Mb_slave As Byte , Byval Mb_function As Byte , Byval Mb_address As Word , Mb_varbts As Byte)
Declare Sub Mb_slave_response
Declare Sub Mbm_set_coil(byval Coil_no As Byte , Byval Coil_value As Byte)
Declare Function Mbm_read_coil_status(byval Coil_no As Byte) As Byte
Declare Function Mbm_read_discrete_input(byval Input_no As Byte) As Byte