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
' write single coil  5
' write single register  6
' write multiple coils  15
'
'*******************************************************************************

'****************************************************************
' Compiler directives
'****************************************************************
$projecttime = 140
$regfile = "m32def.dat"                                     ' chip used
$hwstack = 48                                               ' default use 32 for the hardware stack
$swstack = 32                                               ' default use 10 for the SW stack
$framesize = 32                                             ' Maximum size for local variable

'Const _crystal = 8000000
'Const _crystal = 11059200
'Const _crystal = 14745600
Const _crystal = 18432000
'Const _crystal = 22118400
$crystal = _crystal                                         ' xtal used

Const Baudrate = 9600
'Const Baudrate = 19200
'Const Baudrate = 38400
'Const Baudrate = 57600
'Const Baudrate = 115200
$baud = Baudrate                                            ' baud rate used

'modbus.lib contains the crcMB function
$lib "modbus.lbx"

'****************************************************************
' MCU hardware configuration
'****************************************************************

'****************************************************************
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Config Serialin = Buffered , Size = 16 , Bytematch = All
Config Serialout = Buffered , Size = 16

' TIMER is configured for 2 character space based on baudrate speed
' So there is 1.5 characters time left for analyze packet.... Before new packet come¸

   Config Timer1 = Timer , Prescale = 64
   #if _crystal = 11059200
      #if Baudrate = 9600
          'Const Load_timer = &HFE98
          'Const Load_timer = &HFD8A
          Const Load_timer = &H0167
      #endif
      #if Baudrate = 19200
         Const Load_timer = &HFF4C
      #endif
      #if Baudrate = 38400
         Const Load_timer = &HFFA6
      #endif
      #if Baudrate = 57600
         Const Load_timer = &HFFC4
      #endif
      #if Baudrate = 115200
         Const Load_timer = &HFFE2
      #endif
   #endif

   #if _crystal = 14745600
      #if Baudrate = 9600
         Const Load_timer = &HFE20
      #endif
      #if Baudrate = 19200
         Const Load_timer = &HFF10
      #endif
      #if Baudrate = 38400
         Const Load_timer = &HFF88
      #endif
      #if Baudrate = 57600
         Const Load_timer = &HFFB0
      #endif
      #if Baudrate = 115200
         Const Load_timer = &HFFD8
      #endif
   #endif

   #if _crystal = 18432000
      #if Baudrate = 9600
         'Const Load_timer = &HFDA8
         Const Load_timer = &H0257
      #endif
      #if Baudrate = 19200
         Const Load_timer = &HFED4
      #endif
      #if Baudrate = 38400
         Const Load_timer = &HFF6A
      #endif
      #if Baudrate = 57600
         Const Load_timer = &HFFC9
      #endif
      #if Baudrate = 115200
         Const Load_timer = &HFFCE
      #endif
   #endif
   Load Timer1 , Load_timer
   On Timer1 Modbus_space

'**********************************************************************
' SUB and  function declarations
'**********************************************************************
Declare Function Bit_index_byte(byval Bit_index As Word , Lista As Byte) As Byte
Declare Sub Copy_coils_to_table
Declare Sub Copy_inputs_to_table
Declare Sub Copy_holding_registers_to_table
Declare Function Send_modbus(byval Mb_slave As Byte , Byval Mb_function As Byte , Byval Mb_address As Word , Mb_varbts As Byte) As Byte
Declare Sub Modbus_response

'************************************************************
' Const definitions
'************************************************************
Const Coil_on = 255
Const Coil_off = 0
'********************************************************************
' This is user configurable.
' Config to match modbus client's maximum hardware
Const Maximum_coil_number = 24                              ' Keep in mind that modbus adress start at 0 so this is 16 coils !
Const Maximum_discrete_inputs = 32                          ' Keep in mind that modbus adress start at 0 so this is 16 inputs !
Const Maximum_holding_registers = 15                        ' Keep in mind that modbus adress start at 0 so this is 16 registers !
Const Maximum_input_registers = 15                          ' Keep in mind that modbus adress start at 0 so this is 16 registers !
Const Maximum_adc_channel = 7                               ' Keep in mind that modbus adress start at 0 so this is 8 channels !
'********************************************************************

F_read_coil_status Alias 1
F_read_discrete_inputs Alias 2
F_read_holding_registers Alias 3
F_read_input_registers Alias 4
F_write_single_coil Alias 5
F_write_single_register Alias 6
F_write_multiple_coils Alias 15                             ' Not implemented yet
F_write_multiple_registers Alias 16                         ' Not implemented yet
F_read_single_adc Alias 65                                  ' Not defined in standard, user applicable
F_dummy Alias 255

'Exception response codes
Illegal_function Alias 1
Illegal_data_address Alias 2
Illegal_data_value Alias 3

'************************************************************
' Variables definitions
'************************************************************
Dim Modbus_slave_adress As Byte
Dim Modbus_buffer(16) As Byte                               ' Temp array for Modbus function
Dim Modbus_slave_adress_received As Byte At Modbus_buffer(1) Overlay
Dim Modbus_function As Byte At Modbus_buffer(2) Overlay
Dim Modbus_device_adress_hi As Byte At Modbus_buffer(3) Overlay
Dim Modbus_device_adress_lo As Byte At Modbus_buffer(4) Overlay
Dim Modbus_byte_count As Byte At Modbus_buffer(3) Overlay
Dim Modbus_device_adress As Word
Dim Mb_number_of_devices_hi As Byte At Modbus_buffer(5) Overlay
Dim Mb_number_of_devices_lo As Byte At Modbus_buffer(6) Overlay
Dim Modbus_number_of_devices As Word
Dim Modbus_data_byte(8) As Byte At Modbus_buffer(4) Overlay
Dim Modbus_register_read(maximum_holding_registers) As Word At Modbus_buffer(4) Overlay
Dim Modbus_registers_write(maximum_holding_registers) As Word At Modbus_buffer(5) Overlay
Dim Modbus_register_write_hi As Byte At Modbus_buffer(5) Overlay
Dim Modbus_register_write_lo As Byte At Modbus_buffer(6) Overlay
'Dim Mb_f15_count As Byte At Modbus_buffer(7) Overlay
'Dim Mb_f15_data(8) As Byte At Modbus_buffer(8) Overlay
Dim Response_received As Byte
Dim Modus_error As Byte
Dim Dummy_mb_byte As Byte
Dim Coils_to_read As Byte At Dummy_mb_byte Overlay
Dim Discrete_inputs As Byte At Dummy_mb_byte Overlay
Dim Write_coil_value As Byte At Dummy_mb_byte Overlay
Dim Registers_to_read As Byte At Dummy_mb_byte Overlay

   Dim Coil_status_table(5) As Byte                         ' One more than number_of_coils/8
   Dim Discrete_inputs_table(6) As Byte                     ' One more than number_of_inputs/8
   Dim Holding_registers_table(16) As Word
   Dim Input_registers_table(16) As Word

' Genereal program use
Dim For_loop As Byte

'************************************************************
' Program initialisation
'************************************************************
Coil_status_table(1) = 0
Coil_status_table(2) = 0
Coil_status_table(3) = 0
Coil_status_table(4) = 0
Coil_status_table(5) = 0

For For_loop = 1 To 16
   Holding_registers_table(for_loop) = 0
Next For_loop

'************************************************************
''  Program start
'************************************************************

Enable Timer1
'Start Timer1
Enable Interrupts
Clear Serialin

'****************** User program start here ****************
'   ' DEMO F_read_coil_status *****
'Modbus_slave_adress = 2
'Modbus_device_adress = 0                                    ' Don't forget device adress is zero based
'Coils_to_read = 1
'   Modus_error = Send_modbus(modbus_slave_adress , F_read_coil_status , Modbus_device_adress , Coils_to_read)
'*******************************

'   ' DEMO F_read_discrete_inputs *****
'Modbus_slave_adress = 2
'Modbus_device_adress = 0                                    ' Don't forget device adress is zero based
'Discrete_inputs = 1
'   Modus_error = Send_modbus(modbus_slave_adress , F_read_discrete_inputs , Modbus_device_adress , Discrete_inputs)
'*******************************

'   ' DEMO F_read_holding_registers *****
'Modbus_slave_adress = 2
'Modbus_device_adress = 0                                    ' Don't forget device adress is zero based
'Registers_to_read = 1
'   Modus_error = Send_modbus(modbus_slave_adress , F_read_holding_registers , Modbus_device_adress , Registers_to_read)
'*******************************

' DEMO F_write_single_coil *****
'Modbus_slave_adress = 2
'Modbus_device_adress = 0                                    ' Don't forget device adress is zero based
'Write_coil_value = Coil_on
'   Modus_error = Send_modbus(modbus_slave_adress , F_write_single_coil , Modbus_device_adress , Write_coil_value)
'*******************************

' DEMO F_write_single_register *****
'Modbus_slave_adress = 2
'Modbus_device_adress = 0                                    ' Don't forget device adress is zero based
'Modbus_registers_write(1)=1025
'Modus_error = Send_modbus(modbus_slave_adress , F_write_single_register , Modbus_device_adress , Dummy_mb_byte)
'*******************************

Do
   NOP
Loop

End

'************************************************************
'----------------- SUBS and Functions -----------------------
'************************************************************
Function Send_modbus(byval Mb_slave As Byte , Byval Mb_function As Byte , Byval Mb_address As Word , Mb_varbts As Byte) As Byte
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Local_dummy_word As Word
 Local No_bytes_to_send As Byte

   Modbus_buffer(1) = Mb_slave
   Modbus_function = Mb_function
   Modbus_device_adress_lo = Low(mb_address)
   Modbus_device_adress_hi = High(mb_address)
   Mb_number_of_devices_hi = 0
   Mb_number_of_devices_lo = Mb_varbts
            Select Case Mb_function
                Case F_write_single_coil :
                    Mb_number_of_devices_hi = Mb_varbts
                    Mb_number_of_devices_lo = 0
'                Case F_write_multiple_coils:
                Case F_write_single_register:
                    Local_dummy_word = Makeint(modbus_register_write_lo , Modbus_register_write_hi)
                    Modbus_registers_write(1) = Local_dummy_word
            End Select
   Local_dummy_word = Crcmb(modbus_buffer(1) , 6)           ' create checksum
   Modbus_buffer(7) = Low(local_dummy_word)                 'add to buffer
   Modbus_buffer(8) = High(local_dummy_word)                'add to buffer
   No_bytes_to_send = 8
   For Local_dummy_byte = 1 To No_bytes_to_send
      Print Chr(modbus_buffer(local_dummy_byte));
   Next
   Response_received = 0
   ' Now wait some time for response
   Send_modbus = Response_received
End Function Send_modbus

Rem ****************************************************************************
Sub Modbus_response
 Local Chr_count As Byte
 Local Word_count As Byte
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Local_dummy_word As Word
 Local Crc_received As Word
 Local Modbus_device_end_adress As Word
   ' Since this sub is executed after 2 character pause,
   ' I hope all characters should be in receive buffer.
   ' Then let's put it in Modbus buffer
   Chr_count = 0
   While Ischarwaiting() = 1
     Incr Chr_count
     Inputbin Local_dummy_byte
     Modbus_buffer(chr_count) = Local_dummy_byte
   Wend
   If Chr_count > 0 And Modbus_slave_adress_received = Modbus_slave_adress Then
      Local_dummy_byte = Chr_count - 1
      Crc_received = Makeint(modbus_buffer(local_dummy_byte) , Modbus_buffer(chr_count))       ' create word of received crc
      Decr Local_dummy_byte
      If Crc_received = Crcmb(modbus_buffer(1) , Local_dummy_byte) Then
         Response_received = 1
         Modbus_device_adress = Makeint(modbus_device_adress_lo , Modbus_device_adress_hi)
         Modbus_number_of_devices = Makeint(mb_number_of_devices_lo , Mb_number_of_devices_hi)
'         Modbus_device_end_adress = Modbus_device_adress + Modbus_number_of_devices_byte
         Select Case Modbus_function
            Case F_read_coil_status:
               Call Copy_coils_to_table
            Case F_read_discrete_inputs :
               Call Copy_inputs_to_table                    '
            Case F_read_holding_registers:
               Call Copy_holding_registers_to_table
'            Case F_read_input_registers:
            Case F_write_single_coil :
'            Case F_write_multiple_coils:
            Case F_write_single_register:
         End Select
      End If
   End If
End Sub Modbus_response


Rem ****************************************************************************
Sub Copy_coils_to_table
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Byte_position As Byte
 Local Bit_position As Byte
 Local Coil_adress As Byte
   Coil_adress = 0
   For Local_dummy_byte = 1 To Modbus_byte_count
       For Local_dummy_byte_2 = 0 To 7
           If Coil_adress = Discrete_inputs Then Exit For
           Byte_position = Coil_adress / 8
           Incr Byte_position
           Bit_position = Coil_adress Mod 8
           If Modbus_data_byte(local_dummy_byte).local_dummy_byte_2 = 1 Then
               Coil_status_table(byte_position).bit_position = 1
           Else
               Coil_status_table(byte_position).bit_position = 0
           End If
Rem           Print "I" ; Coil_adress ; "=" ; Coil_status_table(byte_position).bit_position ; " ";
           Incr Coil_adress
Rem           Print "Byte_position=" ; Byte_position ; " I(" ; Byte_position ; ")=" ; Coil_status_table(byte_position)
       Next
   Next
End Sub


Rem ****************************************************************************
Sub Copy_inputs_to_table
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Byte_position As Byte
 Local Bit_position As Byte
 Local Input_adress As Byte
   Input_adress = 0
   For Local_dummy_byte = 1 To Modbus_byte_count
       For Local_dummy_byte_2 = 0 To 7
           If Input_adress = Discrete_inputs Then Exit For
           Byte_position = Input_adress / 8
           Incr Byte_position
           Bit_position = Input_adress Mod 8
           If Modbus_data_byte(local_dummy_byte).local_dummy_byte_2 = 1 Then
              Discrete_inputs_table(byte_position).bit_position = 1
           Else
               Discrete_inputs_table(byte_position).bit_position = 0
           End If
Rem           Print "I" ; Input_adress ; "=" ; Discrete_inputs_table(byte_position).bit_position ; " ";
           Incr Input_adress
Rem           Print "Byte_position=" ; Byte_position ; " I(" ; Byte_position ; ")=" ; Discrete_inputs_table(byte_position)
       Next
   Next
End Sub


Rem ****************************************************************************
Sub Copy_holding_registers_to_table
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Byte_position As Byte
 Local Bit_position As Byte
 Local Input_adress As Byte
                  Word_count = 0
                  Incr Modbus_device_adress                 ' ModBus start with adress 0, but table start with 1
                  Incr Modbus_device_end_adress
                  For Local_dummy_word = 1 To Modbus_byte_count               'Registers_to_read
                     Incr Word_count
                     If Word_count > No_words_to_send Then
                       Word_to_send = 0
                     Else
                           Word_to_send = Holding_registers_table(local_dummy_word)

                        End Select
                     End If
                     Local_dummy_byte = High(word_to_send)
                     Local_dummy_byte_2 = Low(word_to_send)
                     Modbus_register_read(word_count) = Makeint(local_dummy_byte , Local_dummy_byte_2)
                  Next

End Sub


Rem Return byte from array at adress of bit_index
Function Bit_index_byte(byval Bit_index As Word , Lista As Byte) As Byte
'   Local Dummy_byte_sub As Byte
'   Local Rest As Byte
'   Local Index_byte As Byte
'   Local Start_byte As Byte

'   Dummy_byte_sub = 0
'   Rest = 0
'   Index_byte = 0
'   Start_byte = 0

'   Rest = Bit_index Mod 8
'   Start_byte = Bit_index / 8
'   Incr Start_byte
'   Index_byte = Lista(start_byte)
'   Shift Index_byte , Left , Rest
'   Incr Start_byte
'   Dummy_byte_sub = Lista(start_byte)
'   Rest = 8 - Rest
'   Shift Dummy_byte_sub , Right , Rest
'   Bit_index_byte = Index_byte Or Dummy_byte_sub
End Function


'***********************************************************
' INTERUPTS !
'***********************************************************
Serial0bytereceived:
   Load Timer1 , Load_timer
   Start Timer1
Return

Modbus_space:
   Stop Timer1                                              'No need for Timer1 before 1'st character in next message
   Call Modbus_response
Return