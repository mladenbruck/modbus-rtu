   '*******************************************************************************
'
'  MODBUS SERVER FUNCTIONS
'  Mladen Bruck
'  AVRBIT electronic
'  www.avrbit.com
'  info AT avrbit.com
'
'  December, 2009
'
'  Supported functions:
'
' read coil status  1
' read discrete inputs  2
' read holding registers  3
' read input registers  4
' write single coil  5
' write single register  6
' write multiple coils 15
'*******************************************************************************

'****************************************************************
' Compiler directives
'****************************************************************
'  $projecttime = 17
$regfile = "m640def.dat"                                    ' specify the used micro
$hwstack = 512                                              ' default use 32 for the hardware stack
$swstack = 256                                              ' default use 10 for the SW stack
$framesize = 128                                            ' default use 40 for the frame space

'Const _crystal = 11059200
'Const _crystal = 14745600
Const _crystal = 18432000
$crystal = _crystal                                         ' xtal used

'modbus.lib contains the crcMB function
$lib "modbus.lbx"

'****************************************************************
' MCU hardware configuration
'****************************************************************
Const Mbm_serial_port = 3                                   ' Modbus master serial port: 1 to 4
'Const mbm_baudrate = 9600
'Const Mbm_baudrate = 19200
'Const mbm_baudrate = 38400
Const Mbm_baudrate = 57600
'Const mbm_baudrate = 115200
'Const mbm_baudrate = 230400
'const mbm_baudrate = 460800
$include "mb_m_files\mbm_config.bas"

' FOR DEBUG PURPOSE ONLY !!!!
Config Com1 = 9600 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Serialin = Buffered , Size = 8
Config Serialout = Buffered , Size = 16

'**********************************************************************
' SUB's and function declarations
'**********************************************************************
$include "mb_m_files\mbm_defs.bas"
'************************************************************
' Const definitions
'************************************************************
$include "mb_m_files\mbm_consts_defs.bas"

'************************************************************
' Variables definitions
'************************************************************
$include "mb_m_files\mbm_var_defs.bas"

' Genereal program use
Dim Dummy_byte As Byte
Dim Dummy_word As word
Dim Random_byte As Byte

'************************************************************
' Program initialisation
'************************************************************

'************************************************************
''  Program start
'************************************************************
Enable Timer1
Stop Timer1
Enable Interrupts

'****************** User program start here ****************

'   ' DEMO F_read_coil_status *****
'mbm_slave_adress = 2
'mbm_device_adress = 0                                       ' Don't forget device adress is zero based
'Coils_to_read = 10
'call Send_modbus(mbm_slave_adress , F_read_coil_status , mbm_device_adress , Coils_to_read)
'Dummy_byte = 0
' While Response_received = 0
'   Waitms 1
'   Incr Dummy_byte
'   If Dummy_byte > 15 Then Exit While
' Wend
' If Dummy_byte > 15 Then
'   Print "Greška!"
' Else
'   Print "Response time: " ; Dummy_byte ; "ms"
'    For Dummy_byte = 1 To 10
'      Random_byte = Mbm_read_coil_status(dummy_byte)
'      Print Dummy_word;
'    Next
' End If
'*******************************

'   ' DEMO F_read_discrete_inputs *****
'Mbm_slave_adress = 2
'Mbm_device_adress = 0                                       ' Don't forget device adress is zero based
'Discrete_inputs = 16
'Send_modbus(mbm_slave_adress , F_read_discrete_inputs , Mbm_device_adress , Discrete_inputs)

'Dummy_byte = 0
' While Response_received = 0
'   Waitms 1
'   Incr Dummy_byte
'   If Dummy_byte > 15 Then Exit While
' Wend
' Term_cls
' If Dummy_byte > 15 Then
'   Print "Gre" ; Chr(0) ; "ka!"
' Else
'   Print "Resp. time: " ; Dummy_byte ; "ms"
'   Term_set_cursor_pos 2 , 1
'    For Dummy_byte = 1 To 16
'      Print Mbm_read_discrete_input(dummy_byte);
'    Next
' End If
'*******************************

   ' DEMO F_read_holding_registers *****
'mbm_slave_adress = 2
'mbm_device_adress = 0                                    ' Don't forget device adress is zero based
'Registers_to_read = 10
'call Send_modbus(mbm_slave_adress , F_read_holding_registers , mbm_device_adress , Registers_to_read)
'Dummy_byte = 0
' While Response_received = 0
'   Waitms 1
'   Incr Dummy_byte
'   If Dummy_byte > 30 Then Exit While
' Wend
' If Dummy_byte > 30 Then
'   Print "Error!"
' Else
'   Print "Response time: " ; Dummy_byte ; "ms"
'   For Dummy_byte = 1 To 10
'      Print Dummy_byte ; "=" ; Holding_registers_table(dummy_byte)
'   Next
' End If
'*******************************

'   ' DEMO F_read_input_registers *****
'mbm_slave_adress = 2
'mbm_device_adress = 0                                    ' Don't forget device adress is zero based
'Registers_to_read = 10
'Send_modbus(mbm_slave_adress , F_read_input_registers , mbm_device_adress , Registers_to_read)
'Dummy_byte = 0
' While Response_received = 0
'   Waitms 1
'   Incr Dummy_byte
'   If Dummy_byte > 30 Then Exit While
' Wend
' If Dummy_byte > 30 Then
'   Print "Error!"
' Else
'   Print "Response time: " ; Dummy_byte ; "ms"
'   For Dummy_byte = 1 To 10
'      Print Dummy_byte ; "=" ; Input_registers_table(dummy_byte)
'   Next
' End If
'*******************************
' DEMO F_write_single_coil *****
'mbm_slave_adress = 2
'mbm_device_adress = 0                                    ' Don't forget device adress is zero based
'Write_coil_value = Coil_on
'Send_modbus(mbm_slave_adress , F_write_single_coil , mbm_device_adress , Write_coil_value)
'   For Dummy_byte = 0 To 23
'      mbm_slave_adress = 2
'      mbm_device_adress = Dummy_byte                     ' Don't forget device adress is zero based
'      Write_coil_value = Coil_on
'      Send_modbus(mbm_slave_adress , F_write_single_coil , mbm_device_adress , Write_coil_value)
'      Waitms 10
'   Next
'   For Dummy_byte = 0 To 23
'      mbm_slave_adress = 2
'      mbm_device_adress = Dummy_byte                     ' Don't forget device adress is zero based
'      Write_coil_value = Coil_off
'      Send_modbus(mbm_slave_adress , F_write_single_coil , mbm_device_adress , Write_coil_value)
'      Waitms 10
'   Next
'*******************************
'DEMO F_write_single_register *****
mbm_slave_adress = 2
mbm_device_adress = 0                                    ' Don't forget device adress is zero based
mbm_registers_write(1)=1025
call Send_modbus(mbm_slave_adress , F_write_single_register , mbm_device_adress , Dummy_mbm_byte)
   Waitms 5
   Dummy_byte = 0
    While Response_received = 0
      Waitms 1
      Incr Dummy_byte
      If Dummy_byte > 30 Then Exit While
    Wend
    If Dummy_byte > 30 Then
      Print "Error!"
    Else
      Print "Response time: " ; Dummy_byte ; "ms"
    End If
'*******************************

' DEMO F_write_multiple_coils *****
'   For Dummy_byte = 1 To 24
'      Call Mbm_set_coil(dummy_byte , Coil_off)
'   Next
'   For Dummy_byte = 3 To 15
'      Call Mbm_set_coil(dummy_byte , Coil_on)
'   Next
'   Call Mbm_set_coil(5 , Coil_off)
'   Call Mbm_set_coil(6 , Coil_off)

'   Mbm_slave_adress = 2
'   Mbm_device_adress = 2                                    ' Don't forget device adress is zero based
'   Coils_to_write = 13
'   Send_modbus(mbm_slave_adress , F_write_multiple_coils , Mbm_device_adress , Coils_to_write)
'   Waitms 5
'   Dummy_byte = 0
'    While Response_received = 0
'      Waitms 1
'      Incr Dummy_byte
'      If Dummy_byte > 30 Then Exit While
'    Wend
'    If Dummy_byte > 30 Then
'      Print "Error!"
'    Else
'      Print "Response time: " ; Dummy_byte ; "ms"
'    End If
'*******************************
Do
   NOP
Loop

End

'************************************************************
'----------------- SUBS and Functions -----------------------
'************************************************************
$include "mb_m_files\mbm_subs.bas"

'***********************************************************
' INTERUPTS !
'***********************************************************
$include "mb_m_files\mbm_interrupt.bas"