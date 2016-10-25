#if Mbs_serial_port = 1
   Serial0bytereceived:
#endif
#if Mbs_serial_port = 2
   Serial1bytereceived:
#endif
#if Mbs_serial_port = 3
   Serial2bytereceived:
#endif
#if Mbs_serial_port = 4
   Serial3bytereceived:
#endif
   Load Timer3 , Load_timer3
   if timer_3_started=0 then
      Start Timer3
      timer_3_started=1
   end if
Return

Mbs_space:
   Stop Timer3                                              'No need for Timer3 before 1'st character in next message
   timer_3_started=0
   Call Mbs_exec
Return