$nocompile

Sub Mbs_send_exception
 Local Crc As Word
   Mbs_buffer(2) = Mbs_buffer(2) + &H80
   Crc = Crcmb(mbs_buffer(1) , 3)                           ' create checksum
   Mbs_buffer(4) = Low(crc)                                 'add to buffer
   Mbs_buffer(5) = High(crc)                                'add to buffer
#if Mbs_serial_port = 1
   Printbin Mbs_buffer(1) ; 5
#endif
#if Mbs_serial_port <> 1
   Printbin #2 , Mbs_buffer(1) ; 5
#endif
End Sub

Sub Mbs_exec
 Local Chr_count As Byte
 Local Word_count As Byte
 Local Mbs_error As Byte
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Local_dummy_word As Word
 Local Crc_received As Word
 Local Mbs_device_end_adress As Word
 Local No_bytes_to_send As Byte
 Local No_words_to_send As Byte
 Local Byte_to_send As Byte
 Local Word_to_send As Word
   ' Since this sub is executed after 2 character pause,
   ' I hope all characters should be in receive buffer.
   ' Then let's put it in Modbus buffer
   Chr_count = 0
#if Mbs_serial_port = 1
   While Ischarwaiting() = 1
#endif
#if Mbs_serial_port <> 1
   While Ischarwaiting(#2) = 1
#endif
     Incr Chr_count
#if Mbs_serial_port = 1
     Inputbin Local_dummy_byte
#endif
#if Mbs_serial_port <> 1
     Inputbin #2 , Local_dummy_byte
#endif
     Mbs_buffer(chr_count) = Local_dummy_byte
     'debug hex(Local_dummy_byte) ; " ";
   Wend
   'debug ""
      Mbs_buffer(1)=&h01
      Mbs_buffer(2)=&h17
      Mbs_buffer(3)=&h0A
      Mbs_buffer(4)=&h00
      Mbs_buffer(5)=&h00
      Mbs_buffer(6)=&h00
      Mbs_buffer(7)=&h00
      Mbs_buffer(8)=&h00
      Mbs_buffer(9)=&h00
      Mbs_buffer(10)=&h07
      Mbs_buffer(11)=&hD1
      Mbs_buffer(12)=&h07
      Mbs_buffer(13)=&hD2
      Mbs_buffer(14)=&hC7
      Mbs_buffer(15)=&hA6
      No_bytes_to_send = 15
      For Chr_count = 1 To No_bytes_to_send
         Print #2 , chr(Mbs_buffer(Chr_count));
      next
      Chr_count=0

   'debug "Mbs_adress_received=" ; Mbs_adress_received
   If Chr_count > 0 And Mbs_adress_received = Mbs_adress Then
         Local_dummy_byte = Chr_count - 1
         Crc_received = Makeint(mbs_buffer(local_dummy_byte) , Mbs_buffer(chr_count))       ' create word of received crc
         Decr Local_dummy_byte
         If Crc_received = Crcmb(mbs_buffer(1) , Local_dummy_byte) Then
            Mbs_watchdog = 0
            Mbs_device_adress = Makeint(mbs_device_adress_lo , Mbs_device_adress_hi)
            Mbs_number_of_devices = Makeint(mb_number_of_devices_lo , Mb_number_of_devices_hi)
            Mbs_device_end_adress = Mbs_device_adress + Mbs_number_of_devices
            Mbs_error = 0
            ' First check if modbus packet is correct for this client
            Select Case Mbs_function
               Case Mbs_f_read_coil_status :
                    If Mbs_device_end_adress > Mbs_maximum_coil_number Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                    End If
               Case Mbs_f_read_discrete_inputs :
                     If Mbs_device_end_adress > Mbs_maximum_discrete_inputs Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                    End If
               Case Mbs_f_read_holding_registers :
                     If Mbs_device_adress > Mbs_maximum_holding_registers Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                    End If
               Case Mbs_f_read_input_registers :
                     If Mbs_device_adress > Mbs_maximum_input_registers Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                    End If
               Case Mbs_f_write_single_coil :
                    If Mbs_device_adress > Mbs_maximum_coil_number Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                    End If
               Case Mbs_f_write_multiple_coils:
                    If Mbs_device_end_adress > Mbs_maximum_coil_number Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                    End If
               Case Mbs_f_write_single_register :
                     If Mbs_device_adress > Mbs_maximum_holding_registers Then
                        Mbs_buffer(3) = Mbs_illegal_data_address
                        Mbs_error = 1
                     End If
               case Mbs_f_read_write_registers:

               Case Else                                    ' Ilegal fuction
                  Mbs_buffer(3) = Mbs_illegal_function
                  Mbs_error = 1
            End Select
            If Mbs_error = 1 Then
               Mbs_send_exception
               Mbs_function = 0
            End If
      ' If packet is is correct for this client then Mbs_function is <> 0
         Select Case Mbs_function
#if Use_read_coil_status = 1
               Case Mbs_f_read_coil_status :
                  If Mbs_function = Mbs_f_read_discrete_inputs Then Mbs_copy_inputs_to_table
                  No_bytes_to_send = Mbs_number_of_devices / 8
                  Local_dummy_byte = Mbs_number_of_devices Mod 8
                  If Local_dummy_byte > 0 Then Incr No_bytes_to_send
                  Chr_count = 0
                  For Local_dummy_word = Mbs_device_adress To Mbs_device_end_adress Step 8
                     Incr Chr_count
                     If Chr_count > No_bytes_to_send Then
                       Byte_to_send = 0
                     Else
                        Byte_to_send = Mbs_bit_index_byte(local_dummy_word , Mbs_coil_status_table(1))
                     End If
                     Mbs_data_byte(chr_count) = Byte_to_send
                  Next
                  Mbs_buffer(3) = No_bytes_to_send          ' byte count
                  Chr_count = 3 + No_bytes_to_send
                  Crc_received = Crcmb(mbs_buffer(1) , Chr_count)       ' create checksum
                  Incr Chr_count
                  Mbs_buffer(chr_count) = Low(crc_received) 'add to buffer
                  Incr Chr_count
                  Mbs_buffer(chr_count) = High(crc_received)       'add to buffer
                  For Local_dummy_byte = 1 To Chr_count
#if Mbs_serial_port = 1
                    Printbin Mbs_buffer(local_dummy_byte) ; 1
#endif
#if Mbs_serial_port <> 1
                    Printbin #2 , Mbs_buffer(local_dummy_byte) ; 1
#endif
                  Next
#endif

#if Use_read_discrete_inputs = 1
               Case Mbs_f_read_discrete_inputs :
                  If Mbs_function = Mbs_f_read_discrete_inputs Then Mbs_copy_inputs_to_table
                  No_bytes_to_send = Mbs_number_of_devices / 8
                  Local_dummy_byte = Mbs_number_of_devices Mod 8
                  If Local_dummy_byte > 0 Then Incr No_bytes_to_send
                  Chr_count = 0
                  For Local_dummy_word = Mbs_device_adress To Mbs_device_end_adress Step 8
                     Incr Chr_count
                     If Chr_count > No_bytes_to_send Then
                       Byte_to_send = 0
                     Else
                        Byte_to_send = Mbs_bit_index_byte(local_dummy_word , Mbs_discrete_inputs_table(1))
                     End If
                     Mbs_data_byte(chr_count) = Byte_to_send
                  Next
                  Mbs_buffer(3) = No_bytes_to_send          ' byte count
                  Chr_count = 3 + No_bytes_to_send
                  Crc_received = Crcmb(mbs_buffer(1) , Chr_count)       ' create checksum
                  Incr Chr_count
                  Mbs_buffer(chr_count) = Low(crc_received) 'add to buffer
                  Incr Chr_count
                  Mbs_buffer(chr_count) = High(crc_received)       'add to buffer
                  For Local_dummy_byte = 1 To Chr_count
#if Mbs_serial_port = 1
                    Printbin Mbs_buffer(local_dummy_byte) ; 1
#endif
#if Mbs_serial_port <> 1
                    Printbin #2 , Mbs_buffer(local_dummy_byte) ; 1
#endif
                  Next
#endif
#if Use_read_holding_registers = 1
               Case Mbs_f_read_holding_registers :
                  No_words_to_send = Mbs_number_of_devices
                  Word_count = 0
                  Incr Mbs_device_adress                    ' ModBus start with adress 0, but table start with 1
                  Incr Mbs_device_end_adress
                  For Local_dummy_word = Mbs_device_adress To Mbs_device_end_adress
                     Incr Word_count
                     If Word_count > No_words_to_send Then
                       Word_to_send = 0
                     Else
                        Word_to_send = Mbs_holding_registers_table(local_dummy_word)
                     End If
                     Local_dummy_byte = High(word_to_send)
                     Local_dummy_byte_2 = Low(word_to_send)
                     Mbs_register_read(word_count) = Makeint(local_dummy_byte , Local_dummy_byte_2)
                  Next
                  Mbs_buffer(3) = No_words_to_send * 2      ' byte count
                  Chr_count = Mbs_buffer(3)
                  Chr_count = 3 + Chr_count
                  Crc_received = Crcmb(mbs_buffer(1) , Chr_count)       ' create checksum
                  Incr Chr_count
                  Mbs_buffer(chr_count) = Low(crc_received) 'add to buffer
                  Incr Chr_count
                  Mbs_buffer(chr_count) = High(crc_received)       'add to buffer
                  For Local_dummy_byte = 1 To Chr_count
#if Mbs_serial_port = 1
                    Printbin Mbs_buffer(local_dummy_byte) ; 1
#endif
#if Mbs_serial_port <> 1
                    Printbin #2 , Mbs_buffer(local_dummy_byte) ; 1
#endif
                  Next
#endif

#if Use_read_input_registers = 1
               Case Mbs_f_read_input_registers :
                  No_words_to_send = Mbs_number_of_devices
                  Word_count = 0
                  Incr Mbs_device_adress                    ' ModBus start with adress 0, but table start with 1
                  Incr Mbs_device_end_adress
                  For Local_dummy_word = Mbs_device_adress To Mbs_device_end_adress
                     Incr Word_count
                     If Word_count > No_words_to_send Then
                       Word_to_send = 0
                     Else
                        Word_to_send = Mbs_input_registers_table(local_dummy_word)
                     End If
                     Local_dummy_byte = High(word_to_send)
                     Local_dummy_byte_2 = Low(word_to_send)
                     Mbs_register_read(word_count) = Makeint(local_dummy_byte , Local_dummy_byte_2)
                  Next
                  Mbs_buffer(3) = No_words_to_send * 2      ' byte count
                  Chr_count = Mbs_buffer(3)
                  Chr_count = 3 + Chr_count
                  Crc_received = Crcmb(mbs_buffer(1) , Chr_count)       ' create checksum
                  Incr Chr_count
                  Mbs_buffer(chr_count) = Low(crc_received) 'add to buffer
                  Incr Chr_count
                  Mbs_buffer(chr_count) = High(crc_received)       'add to buffer
                  For Local_dummy_byte = 1 To Chr_count
#if Mbs_serial_port = 1
                    Printbin Mbs_buffer(local_dummy_byte) ; 1
#endif
#if Mbs_serial_port <> 1
                    Printbin #2 , Mbs_buffer(local_dummy_byte) ; 1
#endif
                  Next
#endif
#if Use_write_single_coil = 1
               Case Mbs_f_write_single_coil :
                     If Mb_number_of_devices_hi = 255 Then
                        Call Mbs_write_single_coil(mbs_device_adress , 1)
#if Mbs_serial_port = 1
                        Printbin Mbs_buffer(1) ; 8
#endif
#if Mbs_serial_port <> 1
                        Printbin #2 , Mbs_buffer(1) ; 8
#endif
                     Elseif Mb_number_of_devices_hi = 0 Then
                        Call Mbs_write_single_coil(mbs_device_adress , 0)
#if Mbs_serial_port = 1
                        Printbin Mbs_buffer(1) ; 8
#endif
#if Mbs_serial_port <> 1
                        Printbin #2 , Mbs_buffer(1) ; 8
#endif
                     Else
                        Mbs_buffer(3) = Mbs_illegal_data_value
                        Mbs_send_exception
                     End If
#endif

#if Use_write_multiple_coils = 1
               Case Mbs_f_write_multiple_coils:
                     Local_dummy_word = Mbs_device_adress
                     For Chr_count = 1 To Mb_f15_count
                        For Local_dummy_byte = 0 To 7
                           If Local_dummy_word < Mbs_device_end_adress Then
                              Call Mbs_write_single_coil(local_dummy_word , Mb_f15_data(chr_count).local_dummy_byte)
                              Incr Local_dummy_word
                           Else
                              Exit For
                           End If
                        Next
                     Next
                     Crc_received = Crcmb(mbs_buffer(1) , 6)       ' create checksum
                     Mbs_buffer(7) = Low(crc_received)      ' add to buffer
                     Mbs_buffer(8) = High(crc_received)     ' add to buffer
#if Mbs_serial_port = 1
                        Printbin Mbs_buffer(1) ; 8
#endif
#if Mbs_serial_port <> 1
                        Printbin #2 , Mbs_buffer(1) ; 8
#endif
#endif
#if Use_write_single_register = 1
               Case Mbs_f_write_single_register:
                    Incr Mbs_device_adress                  ' ModBus start with adress 0, but table start with 1
                    Mbs_holding_registers_table(mbs_device_adress) = Makeint(mbs_register_write_lo , Mbs_register_write_hi)
#if Mbs_serial_port = 1
                    Printbin Mbs_buffer(1) ; 8
#endif
#if Mbs_serial_port <> 1
                    Printbin #2 , Mbs_buffer(1) ; 8
#endif
#endif
#if Use_Read_Write_registars = 1
               case Mbs_f_read_write_registers:
                  'debug "Primljen paket funkcija = " ; Mbs_function
                  '*  First write received data to coils !
                  swap F23_to_read
                  swap F23_read_adress
                  swap F23_to_write
                  swap F23_write_adress
                  'debug "R: " ; F23_to_read ; ";" ; F23_read_adress
                  'debug "W: " ; F23_to_write ; ";" ; F23_write_adress
                  Local_dummy_word = 1
                  For Chr_count = 1 to F23_to_write
                     swap F23_Write_data(chr_count)
                     Word_to_send = F23_Write_data(chr_count)
                     For Local_dummy_byte = 0 To 15
                        Local_dummy_byte_2 = Word_to_send.local_dummy_byte
                        Call Mbs_write_single_coil(local_dummy_word , Local_dummy_byte_2)
                        Incr Local_dummy_word
                     Next
                  Next Chr_count
                  ' Read inputs
                  Mbs_copy_inputs_to_table
                  Local_dummy_byte = F23_to_read
                  F23_no_off_data_bytes = F23_to_read * 2
                  For Chr_count = 1 To F23_no_off_data_bytes
                    F23_Read_data(Chr_count) = Mbs_discrete_inputs_table(Chr_count)
                  next
                  For Chr_count = 1 To Local_dummy_byte
                      swap F23_Read_data_word(chr_count)
                  next
                  No_bytes_to_send = F23_no_off_data_bytes + 3
                  Crc_received = Crcmb(mbs_buffer(1) , No_bytes_to_send)       ' create checksum
                  incr No_bytes_to_send
                  Mbs_buffer(No_bytes_to_send) = Low(crc_received)       ' add to buffer
                  incr No_bytes_to_send
                  Mbs_buffer(No_bytes_to_send) = High(crc_received)       ' add to buffer
                  'debug "No_bytes_to_send=" ; No_bytes_to_send
'                  For Chr_count = 1 To No_bytes_to_send
                    'debug hex(Mbs_buffer(Chr_count)) ; " ";
'                  next
                  'debug "#"
#if Mbs_serial_port = 1
'                  For Chr_count = 1 To No_bytes_to_send
'                     Print chr(Mbs_buffer(Chr_count));
'                  next
                  Printbin Mbs_buffer(1) ; No_bytes_to_send
#endif
#if Mbs_serial_port <> 1

                  For Chr_count = 1 To No_bytes_to_send
                     Print #2 , chr(Mbs_buffer(Chr_count));
                  next
#endif
#endif

#if Use_user_function = 1
               Case Mbs_f_user_function:
                     ' This function is implemented only for demonstration purpose !!! It does nothing !
                     ' User can select and implement a function code that is not supported by specification
                     ' The query message specifies the channel in word Mbs_device_adress (bytes 3 and 4)
                     ' where ADC=0 mean ADC channel number 1,  etc ADC=1 mean ADC channel number 2 etc                    '
                     ' Byte 1: Slave ID
                     ' Byze 2: User Function  (65)
                     ' Byte 3: User data HI byte
                     ' Byte 4: User data LO byte
                     ' Byte 5: CRC LO
                     ' Byte 6: CRC HI
                     '
                     ' HERE IS IMPLEMENTATION User function code
                     '
                     ' Function return some data
                     Mbs_buffer(3) = 0                      ' Sample data
                     Mbs_buffer(4) = 0                      ' sample data
                     '                  '
                     ' The response message contain 16bit  vaule in format
                     ' Byte 1: Slave ID
                     ' Byze 2: Function
                     ' Byte 3: Data value HI byte
                     ' Byte 4: Data value LO byte
                     ' Byte 5: CRC LO
                     ' Byte 6: CRC HI
                      Crc_received = Crcmb(mbs_buffer(1) , 4)       ' create checksum
                      Mbs_buffer(5) = Low(crc_received)     ' add to buffer
                      Mbs_buffer(6) = High(crc_received)    ' add to buffer
#if Mbs_serial_port = 1
                    Printbin Mbs_buffer(1) ; 6
#endif
#if Mbs_serial_port <> 1
                    Printbin #2 , Mbs_buffer(1) ; 6
#endif
#endif
               Case Else
         End Select
      else
'         'debug "WRONG CRC"
      End If
   else
'      'debug "WRONG MODBUS ADRESS RECEIVED " ; Mbs_adress_received
   End If
End Sub Mbs_exec

   '*******************************************************************************
   ' This is user configurable.
   ' Remark lines which are not in modbus client
   Sub Mbs_copy_inputs_to_table
      Mbs_discrete_inputs_table(1).0 = Input_1
      Mbs_discrete_inputs_table(1).1 = Input_2
      Mbs_discrete_inputs_table(1).2 = Input_3
      Mbs_discrete_inputs_table(1).3 = Input_4
      Mbs_discrete_inputs_table(1).4 = Input_5
      Mbs_discrete_inputs_table(1).5 = Input_6
      Mbs_discrete_inputs_table(1).6 = Input_7
      Mbs_discrete_inputs_table(1).7 = Input_8

      Mbs_discrete_inputs_table(2).0 = Input_9
      Mbs_discrete_inputs_table(2).1 = Input_10
      Mbs_discrete_inputs_table(2).2 = Input_11
      Mbs_discrete_inputs_table(2).3 = Input_12
      Mbs_discrete_inputs_table(2).4 = Input_13
      Mbs_discrete_inputs_table(2).5 = Input_14
      Mbs_discrete_inputs_table(2).6 = Input_15
      Mbs_discrete_inputs_table(2).7 = Input_16

      Mbs_discrete_inputs_table(3).0 = Input_17
      Mbs_discrete_inputs_table(3).1 = Input_18
      Mbs_discrete_inputs_table(3).2 = Input_19
      Mbs_discrete_inputs_table(3).3 = Input_20
      Mbs_discrete_inputs_table(3).4 = Input_21
      Mbs_discrete_inputs_table(3).5 = Input_22
      Mbs_discrete_inputs_table(3).6 = Input_23
      Mbs_discrete_inputs_table(3).7 = Input_24

      Mbs_discrete_inputs_table(4).0 = Input_25
      Mbs_discrete_inputs_table(4).1 = Input_26
      Mbs_discrete_inputs_table(4).2 = Input_27
      Mbs_discrete_inputs_table(4).3 = Input_28
      Mbs_discrete_inputs_table(4).4 = Input_29
      Mbs_discrete_inputs_table(4).5 = Input_30
      Mbs_discrete_inputs_table(4).6 = Input_31
      Mbs_discrete_inputs_table(4).7 = Input_32
#if Ploca_40 = 1
      Mbs_discrete_inputs_table(5).0 = Input_33
      Mbs_discrete_inputs_table(5).1 = Input_34
      Mbs_discrete_inputs_table(5).2 = Input_35
      Mbs_discrete_inputs_table(5).3 = Input_36
      Mbs_discrete_inputs_table(5).4 = Input_37
      Mbs_discrete_inputs_table(5).5 = Input_38
      Mbs_discrete_inputs_table(5).6 = Input_39
      Mbs_discrete_inputs_table(5).7 = Input_40
#endif
   End Sub

   ' This is user configurable.
   ' Drive outputs to match modbus client hardware
   Sub Mbs_write_single_coil(byval Coil As word , Byval Value As Byte)
      Select Case Coil
         Case 1 :
            Coil_1 = Value : Mbs_coil_status_table(4).0 = Value.0
         Case 2:
            Coil_2 = Value : Mbs_coil_status_table(4).1 = Value.0
         Case 3:
            Coil_3 = Value : Mbs_coil_status_table(4).2 = Value.0
         Case 4:
            Coil_4 = Value : Mbs_coil_status_table(4).3 = Value.0
         Case 5:
            Coil_5 = Value : Mbs_coil_status_table(4).4 = Value.0
         Case 6:
            Coil_6 = Value : Mbs_coil_status_table(4).5 = Value.0
         Case 7:
            Coil_7 = Value : Mbs_coil_status_table(4).6 = Value.0
         Case 8:
            Coil_8 = Value : Mbs_coil_status_table(4).7 = Value.0
         Case 9:
            Coil_9 = Value : Mbs_coil_status_table(3).0 = Value.0
         Case 10:
            Coil_10 = Value : Mbs_coil_status_table(3).1 = Value.0
         Case 11:
            Coil_11 = Value : Mbs_coil_status_table(3).2 = Value.0
         Case 12:
            Coil_12 = Value : Mbs_coil_status_table(3).3 = Value.0
         Case 13:
            Coil_13 = Value : Mbs_coil_status_table(3).4 = Value.0
         Case 14:
            Coil_14 = Value : Mbs_coil_status_table(3).5 = Value.0
         Case 15:
            Coil_15 = Value : Mbs_coil_status_table(3).6 = Value.0
         Case 16:
            Coil_16 = Value : Mbs_coil_status_table(3).7 = Value.0
         Case 17:
            Coil_17 = Value : Mbs_coil_status_table(2).0 = Value.0
         Case 18:
            Coil_18 = Value : Mbs_coil_status_table(2).1 = Value.0
         Case 19:
            Coil_19 = Value : Mbs_coil_status_table(2).2 = Value.0
         Case 20:
            Coil_20 = Value : Mbs_coil_status_table(2).3 = Value.0
         Case 21:
            Coil_21 = Value : Mbs_coil_status_table(2).4 = Value.0
         Case 22:
            Coil_22 = Value : Mbs_coil_status_table(2).5 = Value.0
         Case 23:
            Coil_23 = Value : Mbs_coil_status_table(2).6 = Value.0
         Case 24:
            Coil_24 = Value : Mbs_coil_status_table(2).7 = Value.0
 #if Ploca_40 = 1
          Case 25:
            Coil_25 = Value : Mbs_coil_status_table(1).0 = Value.0
         Case 26:
            Coil_26 = Value : Mbs_coil_status_table(1).1 = Value.0
         Case 27:
            Coil_27 = Value : Mbs_coil_status_table(1).2 = Value.0
         Case 28:
            Coil_28 = Value : Mbs_coil_status_table(1).3 = Value.0
         Case 29:
            Coil_29 = Value : Mbs_coil_status_table(1).4 = Value.0
         Case 30:
            Coil_30 = Value : Mbs_coil_status_table(1).5 = Value.0
         Case 31:
            Coil_31 = Value : Mbs_coil_status_table(1).6 = Value.0
         Case 32:
            Coil_32 = Value : Mbs_coil_status_table(1).7 = Value.0
 #endif
      End Select
   End Sub
   '*******************************************************************************

#if Use_read_coil_status = 1 Or Use_read_discrete_inputs = 1
   'Rem Return byte from array at adress of bit_index
   Function Mbs_bit_index_byte(byval Bit_index As Word , Lista() As Byte) As Byte
    Local Local_dummy As Byte
    Local Local_dummy_2 As Byte
    Local Byte_position As Byte
    Local Bit_position As Byte

      For Local_dummy = 0 To 7
         Byte_position = Bit_index / 8
         Incr Byte_position
         Bit_position = Bit_index Mod 8
         If Lista(byte_position).bit_position = 1 Then
            Local_dummy_2.local_dummy = 1
         Else
            Local_dummy_2.local_dummy = 0
         End If
         Incr Bit_index
      Next
      Mbs_bit_index_byte = Local_dummy_2
   End Function
#endif

sub shut_down_all
local coil as word
   for coil = 1 to 32
      Mbs_write_single_coil coil , 0
   next
#if Ploca_40 = 1
   for coil = 33 to 40
      Mbs_write_single_coil coil , 0
   next
#endif
end SUB