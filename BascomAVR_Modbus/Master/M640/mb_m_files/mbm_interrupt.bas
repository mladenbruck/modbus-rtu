$nocompile
#if Mbm_serial_port = 1
   Serialbytereceived:
#endif
#if Mbm_serial_port = 2
   Serial1bytereceived:
#endif
#if Mbm_serial_port = 3
   Serial2bytereceived:
#endif
#if Mbm_serial_port = 4
   Serial3bytereceived:
#endif
   Load Timer1 , Load_timer1
   Start Timer1
Return

Mbm_space:
   Stop Timer1                                              'No need for Timer1 before 1'st character in next message¸
   Call Mb_slave_response
Return