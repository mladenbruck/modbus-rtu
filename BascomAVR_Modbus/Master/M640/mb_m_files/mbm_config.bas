$nocompile
' ModBus com port
#if Mbm_serial_port = 1
   Config Com1 = Mbm_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin = Buffered , Size = 48 , Bytematch = All
   Config Serialout = Buffered , Size = 16
#endif
#if Mbm_serial_port = 2
   Config Com2 = Mbm_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin1 = Buffered , Size = 48 , Bytematch = All
   Config Serialout1 = Buffered , Size = 16
   Open "com2:" For Binary As #1
#endif
#if Mbm_serial_port = 3
   Config Com3 = Mbm_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin2 = Buffered , Size = 48 , Bytematch = All
   Config Serialout2 = Buffered , Size = 16
   Open "com3:" For Binary As #1
#endif
#if Mbm_serial_port = 4
   Config Com4 = Mbm_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin3 = Buffered , Size = 48 , Bytematch = All
   Config Serialout3 = Buffered , Size = 16
   Open "com4:" For Binary As #1
#endif

' TIMER is configured for 2 character space based on baudrate speed
' So there is 1.5 characters time left for analyze packet.... Before new packet come¸

   Config Timer1 = Timer , Prescale = 64
   #if _crystal = 11059200
      #if Mbm_baudrate = 9600
          Const Load_timer1 = &H0167
      #endif
      #if Mbm_baudrate = 19200
         Const Load_timer1 = &H00B3
      #endif
      #if Mbm_baudrate = 38400
         Const Load_timer1 = &HFFA6
      #endif
      #if Mbm_baudrate = 57600
         Const Load_timer1 = &HFFC4
      #endif
      #if Mbm_baudrate = 115200
         Const Load_timer1 = &HFFE2
      #endif
   #endif

   #if _crystal = 14745600
      #if Mbm_baudrate = 9600
         Const Load_timer1 = &HFE20
      #endif
      #if Mbm_baudrate = 19200
         Const Load_timer1 = &HFF10
      #endif
      #if Mbm_baudrate = 38400
         Const Load_timer1 = &HFF88
      #endif
      #if Mbm_baudrate = 57600
         Const Load_timer1 = &HFFB0
      #endif
      #if Mbm_baudrate = 115200
         Const Load_timer1 = &HFFD8
      #endif
   #endif

   #if _crystal = 18432000
      #if Mbm_baudrate = 9600
         Const Load_timer1 = &H0257
      #endif
      #if Mbm_baudrate = 19200
         Const Load_timer1 = &H012B
      #endif
      #if Mbm_baudrate = 38400
         Const Load_timer1 = &H0095
      #endif
      #if Mbm_baudrate = 57600
         Const Load_timer1 = &H0063
      #endif
      #if Mbm_baudrate = 115200
         Const Load_timer1 = &H0031
      #endif
      #if Mbm_baudrate = 230400
         Const Load_timer1 = &H0018
      #endif
      #if Mbm_baudrate = 460800
         Const Load_timer1 = &H000C
      #endif
   #endif
   Load Timer1 , Load_timer1
   On Timer1 Mbm_space