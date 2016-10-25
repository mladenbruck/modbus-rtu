$nocompile

Sub Send_exception
Local Crc As Word
   Mbuf_rcv(2) = Mbuf_rcv(2) + &H80
   Crc = Crcmb(mbuf_rcv(1) , 3)                             ' create checksum
   Mbuf_rcv(4) = Low(crc)                                   'add to buffer
   Mbuf_rcv(5) = High(crc)                                  'add to buffer
   Printbin Mbuf_rcv(1) ; 5
End Sub

Sub Modbus_exec
 Local Chr_count As Byte
 Local Word_count As Byte
 Local Modbus_error As Byte
 Local Local_dummy_byte As Byte
 Local Local_dummy_byte_2 As Byte
 Local Local_dummy_word As Word
 Local Crc_received As Word
 Local Modbus_device_end_adress As Word
 Local No_bytes_to_send As Byte
 Local No_words_to_send As Byte
 Local Byte_to_send As Byte
 Local Word_to_send As Word
   ' Since this sub is executed after 2 character pause,
   ' I hope all characters should be in receive buffer.
   ' Then let's put it in Modbus buffer
   Chr_count = 0
   While Ischarwaiting() = 1
     Incr Chr_count
     Inputbin Local_dummy_byte
     Mbuf_rcv(chr_count) = Local_dummy_byte
   Wend
   If Chr_count > 0 And Modbus_slave_adress_received = Modbus_slave_adress Then
         Local_dummy_byte = Chr_count - 1
         Crc_received = Makeint(mbuf_rcv(local_dummy_byte) , Mbuf_rcv(chr_count))       ' create word of received crc
         Decr Local_dummy_byte
         If Crc_received = Crcmb(mbuf_rcv(1) , Local_dummy_byte) Then
            Modbus_device_adress = Makeint(modbus_device_adress_lo , Modbus_device_adress_hi)
            Modbus_number_of_devices = Makeint(mb_number_of_devices_lo , Mb_number_of_devices_hi)
            Modbus_device_end_adress = Modbus_device_adress + Modbus_number_of_devices
            Modbus_error = 0
'*****************************
#if Use_bootloader_packet = 1
            ' Magic packet is writing value &HFFFF to single register &HFFFE
            ' In real life, this is almoust impossible
            ' IS MAGIC PACKET RECEIVED FOR BOOTLOADER ????
            If Modbus_function = F_write_single_register Then
               If Modbus_device_adress = &HFFFE Then
                  Local_dummy_word = Makeint(modbus_register_write_lo , Modbus_register_write_hi)
                  If Local_dummy_word = &HFFFF Then
                     ' Printbin &H02 ; &H06 ; &HFF ; &HFE ; &HFF ; &HFF ; &HD9 ; &HAD;
                     Printbin Mbuf_rcv(1) ; 8               ' Response is echo of query
                     Waitms 20                              ' Short wait before reset
                     Goto Bootloader_adr                    ' Reset to bootloader vector address
                  End If
               End If
            End If
#endif
            ' First check if modbus packet is from bootloader program
            If Modbus_function = F_write_single_register Then
               If Modbus_device_adress = $fffe Then
                  Printbin Mbuf_rcv(1) ; 8                  ' Response is echo of query
                  Waitms 200                                ' Wait for packet sent
                  Goto &H1C00
               End If
            End If
            ' Check if modbus packet is correct for this client
            Select Case Modbus_function
#if Use_read_coil_status = 1
               Case F_read_coil_status :
                    If Modbus_device_end_adress > Maximum_coil_number Then
                        Mbuf_rcv(3) = Illegal_data_address
                        Modbus_error = 1
                    End If
#endif
#if Use_read_discrete_inputs = 1
               Case F_read_discrete_inputs :
                     If Modbus_device_end_adress > Maximum_discrete_inputs Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                    End If
#endif
#if Use_read_holding_registers = 1
               Case F_read_holding_registers :
                     If Modbus_device_adress > Maximum_holding_registers Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                    End If
#endif
#if Use_read_input_registers = 1
               Case F_read_input_registers :
                     If Modbus_device_adress > Maximum_input_registers Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                    End If
#endif
#if Use_write_single_coil = 1
               Case F_write_single_coil :
                    If Modbus_device_adress > Maximum_coil_number Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                    End If
#endif
#if Use_write_multiple_coils = 1
               Case F_write_multiple_coils:
                    If Modbus_device_end_adress > Maximum_coil_number Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                    End If
#endif
#if Use_write_single_register = 1
               Case F_write_single_register :
                     If Modbus_device_adress > Maximum_holding_registers Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                     End If
#endif
#if Use_read_single_adc = 1
               Case F_read_single_adc:
                     If Modbus_device_adress > Maximum_adc_channel Then
                        Mbuf_rcv(3) = Illegal_data_value
                        Modbus_error = 1
                     End If
#endif
               Case F_dummy:
                  Print "";
               Case Else                                    ' Ilegal fuction
                  Mbuf_rcv(3) = Illegal_function
                  Modbus_error = 1
            End Select
            If Modbus_error = 1 Then
               Send_exception
               Modbus_function = 0
            End If
      ' If packet is  is correct for this client then Modbus_function is <> 0
         Select Case Modbus_function
#if Use_read_coil_status = 1 Or Use_read_discrete_inputs = 1 = 1
               Case 1 To 2 :
#if Use_read_discrete_inputs = 1
                  If Modbus_function = F_read_discrete_inputs Then Copy_inputs_to_table
#endif
                  No_bytes_to_send = Modbus_number_of_devices / 8
                  Local_dummy_byte = Modbus_number_of_devices Mod 8
                  If Local_dummy_byte > 0 Then Incr No_bytes_to_send
                  Chr_count = 0
                  For Local_dummy_word = Modbus_device_adress To Modbus_device_end_adress Step 8
                     Incr Chr_count
                     If Chr_count > No_bytes_to_send Then
                       Byte_to_send = 0
                     Else
                       Select Case Modbus_function
#if Use_read_coil_status = 1
                           Case F_read_coil_status : Byte_to_send = Bit_index_byte(local_dummy_word , Coil_status_table(1))
#endif
#if Use_read_discrete_inputs = 1
                           Case F_read_discrete_inputs : Byte_to_send = Bit_index_byte(local_dummy_word , Discrete_inputs_table(1))
#endif
                        End Select
                     End If
                     Modbus_data_byte(chr_count) = Byte_to_send
                  Next
                  Mbuf_rcv(3) = No_bytes_to_send            ' byte count
                  Chr_count = 3 + No_bytes_to_send
                  Crc_received = Crcmb(mbuf_rcv(1) , Chr_count)       ' create checksum
                  Incr Chr_count
                  Mbuf_rcv(chr_count) = Low(crc_received)   'add to buffer
                  Incr Chr_count
                  Mbuf_rcv(chr_count) = High(crc_received)  'add to buffer
                  For Local_dummy_byte = 1 To Chr_count
                    Printbin Mbuf_rcv(local_dummy_byte) ; 1
                  Next
#endif
#if Use_read_holding_registers = 1 Or Use_read_input_registers = 1
               Case 3 To 4 :
                  No_words_to_send = Modbus_number_of_devices
                  Word_count = 0
                  Incr Modbus_device_adress                 ' ModBus start with adress 0, but table start with 1
                  Incr Modbus_device_end_adress
                  For Local_dummy_word = Modbus_device_adress To Modbus_device_end_adress
                     Incr Word_count
                     If Word_count > No_words_to_send Then
                       Word_to_send = 0
                     Else
                       Select Case Modbus_function
#if Use_read_holding_registers = 1
                           Case F_read_holding_registers : Word_to_send = Holding_registers_table(local_dummy_word)
#endif
#if Use_read_input_registers = 1
                           Case F_read_input_registers : Word_to_send = Input_registers_table(local_dummy_word)
#endif
                        End Select
                     End If
                     Local_dummy_byte = High(word_to_send)
                     Local_dummy_byte_2 = Low(word_to_send)
                     Modbus_register_read(word_count) = Makeint(local_dummy_byte , Local_dummy_byte_2)
                  Next
                  Mbuf_rcv(3) = No_words_to_send * 2        ' byte count
                  Chr_count = Mbuf_rcv(3)
                  Chr_count = 3 + Chr_count
                  Crc_received = Crcmb(mbuf_rcv(1) , Chr_count)       ' create checksum
                  Incr Chr_count
                  Mbuf_rcv(chr_count) = Low(crc_received)   'add to buffer
                  Incr Chr_count
                  Mbuf_rcv(chr_count) = High(crc_received)  'add to buffer
                  For Local_dummy_byte = 1 To Chr_count
                    Printbin Mbuf_rcv(local_dummy_byte) ; 1
                  Next
#endif
#if Use_write_single_coil = 1
               Case F_write_single_coil :
                     If Mb_number_of_devices_hi = 255 Then
                        Call Write_single_coil(modbus_device_adress , 1)
                        Printbin Mbuf_rcv(1) ; 8
                     Elseif Mb_number_of_devices_hi = 0 Then
                        Call Write_single_coil(modbus_device_adress , 0)
                        Printbin Mbuf_rcv(1) ; 8
                     Else
                        Mbuf_rcv(3) = Illegal_data_value
                        Send_exception
                     End If
#endif
#if Use_write_multiple_coils = 1 And Use_write_single_coil = 1
               Case F_write_multiple_coils:
                     Local_dummy_word = Modbus_device_adress
                     For Chr_count = 1 To Mb_f15_count
                        For Local_dummy_byte = 0 To 7
                           If Local_dummy_word < Modbus_device_end_adress Then
                              Call Write_single_coil(local_dummy_word , Mb_f15_data(chr_count).local_dummy_byte)
                              Incr Local_dummy_word
                           Else
                              Exit For
                           End If
                        Next
                     Next Local_dummy_word
                     Crc_received = Crcmb(mbuf_rcv(1) , 6)  ' create checksum
                     Mbuf_rcv(7) = Low(crc_received)        ' add to buffer
                     Mbuf_rcv(8) = High(crc_received)       ' add to buffer
                     Printbin Mbuf_rcv(1) ; 8
#endif
#if Use_write_single_register = 1
               Case F_write_single_register:
                    Incr Modbus_device_adress               ' ModBus start with adress 0, but table start with 1
                    Holding_registers_table(modbus_device_adress) = Makeint(modbus_register_write_lo , Modbus_register_write_hi)
                    Printbin Mbuf_rcv(1) ; 8                ' Response is echo of query
#endif
#if Use_write_multiple_registers = 1
               Case F_write_multiple_registers:
#endif


#if Use_read_single_adc = 1
               Case F_read_single_adc:
                     ' This function is implemented only for demonstration purpose !!! It does nothing !
                     ' User can select and implement a function code that is not supported by specification
                     ' The query message specifies the channel in word Modbus_device_adress (bytes 3 and 4)
                     ' where ADC=0 mean ADC channel number 1,  etc ADC=1 mean ADC channel number 2 etc                    '
                     ' Byte 1: Slave ID
                     ' Byze 2: Function ADC read
                     ' Byte 3: ADC channel HI byte
                     ' Byte 4: ADC channel LO byte
                     ' Byte 5: CRC LO
                     ' Byte 6: CRC HI
                     '
                     ' HERE YOU SHOULD IMPLEMENT ADC conversion code
                     '
                     Mbuf_rcv(3) = 0                        ' Instead of 0 you put actual ADC reading  HI byte
                     Mbuf_rcv(4) = 0                        ' Instead of 0 you put actual ADC reading  LOW byte
                     '                  '
                     ' The response message contain 16bit ADC vaule in format
                     ' Byte 1: Slave ID
                     ' Byze 2: Function
                     ' Byte 3: ADC conversion value HI byte
                     ' Byte 4: ADC conversion value LO byte
                     ' Byte 5: CRC LO
                     ' Byte 6: CRC HI
                       Crc_received = Crcmb(mbuf_rcv(1) , 4)       ' create checksum
                      Mbuf_rcv(5) = Low(crc_received)       ' add to buffer
                      Mbuf_rcv(6) = High(crc_received)      ' add to buffer
                      Printbin Mbuf_rcv(1) ; 6
#endif
               Case F_dummy:
                  Print "";
               Case Else
         End Select
      End If
   End If
End Sub Modbus_exec

#if Use_read_discrete_inputs = 1
   '*******************************************************************************
   ' This is user configurable.
   ' Remark lines which are not in modbus client
   Sub Copy_inputs_to_table
      Discrete_inputs_table(1).0 = Input_1
      Discrete_inputs_table(1).1 = Input_2
      Discrete_inputs_table(1).2 = Input_3
      Discrete_inputs_table(1).3 = Input_4
      Discrete_inputs_table(1).4 = Input_5
      Discrete_inputs_table(1).5 = Input_6
      Discrete_inputs_table(1).6 = Input_7
      Discrete_inputs_table(1).7 = Input_8

      Discrete_inputs_table(2).0 = Input_9
      Discrete_inputs_table(2).1 = Input_10
      Discrete_inputs_table(2).2 = Input_11
      Discrete_inputs_table(2).3 = Input_12
      Discrete_inputs_table(2).4 = Input_13
      Discrete_inputs_table(2).5 = Input_14
      Discrete_inputs_table(2).6 = Input_15
      Discrete_inputs_table(2).7 = Input_16

   '   Discrete_inputs_table(3).7 = Input_17
   '   Discrete_inputs_table(3).6 = Input_18
   '   Discrete_inputs_table(3).5 = Input_19
   '   Discrete_inputs_table(3).4 = Input_20
   '   Discrete_inputs_table(3).3 = Input_21
   '   Discrete_inputs_table(3).2 = Input_22
   '   Discrete_inputs_table(3).1 = Input_23
   '   Discrete_inputs_table(3).0 = Input_24

   '   Discrete_inputs_table(4).7 = Input_25
   '   Discrete_inputs_table(4).6 = Input_26
   '   Discrete_inputs_table(4).5 = Input_27
   '   Discrete_inputs_table(4).4 = Input_28
   '   Discrete_inputs_table(4).3 = Input_29
   '   Discrete_inputs_table(4).2 = Input_30
   '   Discrete_inputs_table(4).1 = Input_31
   '   Discrete_inputs_table(4).0 = Input_32

   '   Discrete_inputs_table(5).7 = Input_33
   '   Discrete_inputs_table(5).6 = Input_34
   '   Discrete_inputs_table(5).5 = Input_35
   '   Discrete_inputs_table(5).4 = Input_36
   '   Discrete_inputs_table(5).3 = Input_37
   '   Discrete_inputs_table(5).2 = Input_38
   '   Discrete_inputs_table(5).1 = Input_39
   '   Discrete_inputs_table(5).0 = Input_40
   End Sub
#endif

#if Use_write_single_coil = 1
   ' This is user configurable.
   ' Drive outputs to match modbus client hardware
   Sub Write_single_coil(byval Coil As Word , Byval Value As Byte)
      Select Case Coil
         Case 0 :
            Coil_1 = Value : Coil_status_table(1).0 = Value.0
         Case 1:
            Coil_2 = Value : Coil_status_table(1).1 = Value.0
         Case 2:
            Coil_3 = Value : Coil_status_table(1).2 = Value.0
         Case 3:
            Coil_4 = Value : Coil_status_table(1).3 = Value.0
         Case 4:
            Coil_5 = Value : Coil_status_table(1).4 = Value.0
         Case 5:
            Coil_6 = Value : Coil_status_table(1).5 = Value.0
         Case 6:
            Coil_7 = Value : Coil_status_table(1).6 = Value.0
         Case 7:
            Coil_8 = Value : Coil_status_table(1).7 = Value.0
         Case 8:
            Coil_9 = Value : Coil_status_table(2).0 = Value.0
         Case 9:
            Coil_10 = Value : Coil_status_table(2).1 = Value.0
   '      Case 10:
   '         Coil_11 = Value : Coil_status_table(2).2 = Value.0
   '      Case 11:
   '         Coil_12 = Value : Coil_status_table(2).3 = Value.0
   '      Case 12:
   '         Coil_13 = Value : Coil_status_table(2).4 = Value.0
   '      Case 13:
   '         Coil_14 = Value : Coil_status_table(2).5 = Value.0
   '      Case 14:
   '         Coil_15 = Value : Coil_status_table(2).6 = Value.0
   '      Case 15:
   '         Coil_16 = Value : Coil_status_table(2).7 = Value.0
   '      Case 16:
   '         Coil_17 = Value : Coil_status_table(3).0 = Value.0
   '      Case 17:
   '         Coil_18 = Value : Coil_status_table(3).1 = Value.0
   '      Case 18:
   '         Coil_19 = Value : Coil_status_table(3).2 = Value.0
   '      Case 19:
   '         Coil_20 = Value : Coil_status_table(3).3 = Value.0
   '      Case 20:
   '         Coil_21 = Value : Coil_status_table(3).4 = Value.0
   '      Case 21:
   '         Coil_22 = Value : Coil_status_table(3).5 = Value.0
   '      Case 22:
   '         Coil_23 = Value : Coil_status_table(3).6 = Value.0
   '      Case 23:
   '         Coil_24 = Value : Coil_status_table(3).7 = Value.0
      End Select
   End Sub
   '*******************************************************************************
#endif

#if Use_read_coil_status = 1 Or Use_read_discrete_inputs = 1
   ' Return byte from array at adress of bit_index
   Function Bit_index_byte(byval Bit_index As Word , Lista() As Byte) As Byte
      Local Dummy_byte_sub As Byte
      Local Rest As Byte
      Local Index_byte As Byte
      Local Start_byte As Byte

      Dummy_byte_sub = 0
      Rest = 0
      Index_byte = 0
      Start_byte = 0

      Rest = Bit_index Mod 8
      Start_byte = Bit_index / 8
      Incr Start_byte
      Index_byte = Lista(start_byte)
      Shift Index_byte , Left , Rest
      Incr Start_byte
      Dummy_byte_sub = Lista(start_byte)
      Rest = 8 - Rest
      Shift Dummy_byte_sub , Right , Rest
      Bit_index_byte = Index_byte Or Dummy_byte_sub
   End Function
#endif