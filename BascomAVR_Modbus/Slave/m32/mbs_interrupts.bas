$nocompile
Serial0bytereceived:
   Load Timer1 , Load_timer
   Start Timer1
Return

Modbus_space:
   Stop Timer1
   Call Modbus_exec
Return