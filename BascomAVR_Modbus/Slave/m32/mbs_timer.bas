$nocompile
' TIMER is configured for 2 character space based on Modbus_baudrate speed
' So There Is 1.5 Characters Time Left For Analyze Packet.... Before New Packet Come
   Config Timer1 = Timer , Prescale = 64

   #if _crystal = 8000000
      #if Modbus_baudrate = 9600                            ' 2.084 ms
          Const Load_timer = &H0104
      #endif
      #if Modbus_baudrate = 19200                           ' 1.042 ms
         Const Load_timer = &H0081
      #endif
      #if Modbus_baudrate = 38400                           ' 0.520 ms
         Const Load_timer = &H0040
      #endif
   #endif

   #if _crystal = 11059200
      #if Modbus_baudrate = 9600                            ' 2.084 ms
          Const Load_timer = &H0167
      #endif
      #if Modbus_baudrate = 19200                           ' 1.042 ms
         Const Load_timer = &H00B3
      #endif
      #if Modbus_baudrate = 38400                           ' 0.520 ms
         Const Load_timer = &H0059
      #endif
      #if Modbus_baudrate = 57600                           ' 0.348 ms
         Const Load_timer = &H003B
      #endif
      #if Modbus_baudrate = 115200                          ' 0.174 ms
         Const Load_timer = &H001D
      #endif
   #endif

   #if _crystal = 12288000
      #if Modbus_baudrate = 9600                            ' 2.084 ms
         Const Load_timer = &H018F
      #endif
      #if Modbus_baudrate = 19200                           ' 1.042 ms
         Const Load_timer = &H00C7
      #endif
      #if Modbus_baudrate = 38400                           ' 0.520 ms
         Const Load_timer = &H0063
      #endif
      #if Modbus_baudrate = 76800                           ' 0.260 ms
         Const Load_timer = &H0031
      #endif
      #if Modbus_baudrate = 153600                          ' 0.130 ms
         Const Load_timer = &H0018
      #endif
   #endif


   #if _crystal = 14745600
      #if Modbus_baudrate = 9600                            ' 2.084 ms
          Const Load_timer = &H01DF
      #endif
      #if Modbus_baudrate = 19200                           ' 1.042 ms
         Const Load_timer = &H00EF
      #endif
      #if Modbus_baudrate = 38400                           ' 0.520 ms
         Const Load_timer = &H0077
      #endif
      #if Modbus_baudrate = 57600                           ' 0.348 ms
         Const Load_timer = &H004F
      #endif
      #if Modbus_baudrate = 115200                          ' 0.174 ms
         Const Load_timer = &H0027
      #endif
   #endif

   #if _crystal = 18432000
      #if Modbus_baudrate = 9600                            ' 2.084 ms
          Const Load_timer = &H0257
      #endif
      #if Modbus_baudrate = 19200                           ' 1.042 ms
         Const Load_timer = &H012B
      #endif
      #if Modbus_baudrate = 38400                           ' 0.520 ms
         Const Load_timer = &H0095
      #endif
      #if Modbus_baudrate = 57600                           ' 0.348 ms
         Const Load_timer = &H0063
      #endif
      #if Modbus_baudrate = 115200                          ' 0.174 ms
         Const Load_timer = &H0031
      #endif
   #endif

   #if _crystal = 22118400
      #if Modbus_baudrate = 9600                            ' 2.084 ms
          Const Load_timer = &H02CF
      #endif
      #if Modbus_baudrate = 19200                           ' 1.042 ms
         Const Load_timer = &H0167
      #endif
      #if Modbus_baudrate = 38400                           ' 0.520 ms
         Const Load_timer = &H00B3
      #endif
      #if Modbus_baudrate = 57600                           ' 0.348 ms
         Const Load_timer = &H0077
      #endif
      #if Modbus_baudrate = 115200                          ' 0.174 ms
         Const Load_timer = &H003B
      #endif
   #endif

   Load Timer1 , Load_timer
   On Timer1 Modbus_space