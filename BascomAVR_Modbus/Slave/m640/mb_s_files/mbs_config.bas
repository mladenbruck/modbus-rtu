
' ModBus com port
$nocompile
#if HMI_serial_port = 1
   Config Com1 = HMI_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin = Buffered , Size = 32
   Config Serialout = Buffered , Size = 32
#endif
#if HMI_serial_port = 2
   Config Com2 = HMI_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin1 = Buffered , Size = 32
   Config Serialout1 = Buffered , Size = 32
   Open "com2:" For Binary As #2
#endif
#if HMI_serial_port = 3
   Config Com3 = HMI_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin2 = Buffered , Size = 32
   Config Serialout2 = Buffered , Size = 32
   Open "com3:" For Binary As #2
#endif
#if HMI_serial_port = 4
   Config Com4 = HMI_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin3 = Buffered , Size = 32
   Config Serialout3 = Buffered , Size = 32
   Open "com4:" For Binary As #2
#endif


' ModBus com port
#if Mbs_serial_port = 1
   Config Com1 = Mbs_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin = Buffered , Size = 128 , Bytematch = All
   Config Serialout = Buffered , Size = 128
#endif
#if Mbs_serial_port = 2
   Config Com2 = Mbs_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin1 = Buffered , Size = 128 , Bytematch = All
   Config Serialout1 = Buffered , Size = 128
   Open "com2:" For Binary As #2
#endif
#if Mbs_serial_port = 3
   Config Com3 = Mbs_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin2 = Buffered , Size = 128 , Bytematch = All
   Config Serialout2 = Buffered , Size = 128
   Open "com3:" For Binary As #2
#endif
#if Mbs_serial_port = 4
   Config Com4 = Mbs_baudrate , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
   Config Serialin3 = Buffered , Size = 128 , Bytematch = All
   Config Serialout3 = Buffered , Size = 128
   Open "com4:" For Binary As #2
#endif

' TIMER is configured for 3 character space based on baudrate speed
' So there is 0.5 characters time left for packet analyse.... Before new packet come in worst case.

   Config Timer3 = Timer , Prescale = 64

   #if _crystal = 11059200
      #if Mbs_baudrate = 9600
          Const Load_timer3 = &H0205            ' 3 ms
      #endif
      #if Mbs_baudrate = 19200
         Const Load_timer3 = &H0113             ' 1.6 ms
      #endif
      #if Mbs_baudrate = 38400
         Const Load_timer3 = &H0089             ' 0.8 ms
      #endif
      #if Mbs_baudrate = 57600
         Const Load_timer3 = &H0057             ' 0.5 ms
      #endif
      #if Mbs_baudrate = 115200
         Const Load_timer3 = &H002E             ' 0.27 ms
      #endif
   #endif

   #if _crystal = 14745600
      #if Mbs_baudrate = 9600
         Const Load_timer3 = &H0200                ' 3 ms
      #endif
      #if Mbs_baudrate = 19200
         Const Load_timer3 = &H115                ' 1.6 ms
      #endif
      #if Mbs_baudrate = 38400
         Const Load_timer3 = &H0089                ' 0.8 ms
      #endif
      #if Mbs_baudrate = 57600
         Const Load_timer3 = &H0057               ' 0.5 ms
      #endif
      #if Mbs_baudrate = 115200
         Const Load_timer3 = &H0030               ' 0.27 ms
      #endif
   #endif

   #if _crystal = 18432000
      #if Mbs_baudrate = 9600
         Const Load_timer3 = &H035F             ' 3 ms
      #endif
      #if Mbs_baudrate = 19200
         Const Load_timer3 = &H01CC             ' 1.6 ms
      #endif
      #if Mbs_baudrate = 38400
         Const Load_timer3 = &H00E5             ' 0.8 ms
      #endif
      #if Mbs_baudrate = 57600
         Const Load_timer3 = &H01CC             ' 1.6 ms
         'Const Load_timer3 = &H008F             ' 0.5 ms
      #endif
      #if Mbs_baudrate = 115200
         Const Load_timer3 = &H004D             ' 0.27 ms
      #endif
      #if Mbs_baudrate = 230400
         Const Load_timer3 = &H0024             ' 0.13 ms
      #endif
      #if Mbs_baudrate = 460800
         Const Load_timer3 = &H0016             ' 0.08 ms
      #endif
   #endif


   Load Timer3 , Load_timer3
   On Timer3 Mbs_space