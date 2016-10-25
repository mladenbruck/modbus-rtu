$nocompile

#if Use_read_coil_status = 1 Or Use_write_single_coil = 1
   Coil_status_table(1) = 0
   Coil_status_table(2) = 0
   Coil_status_table(3) = 0
   Coil_status_table(4) = 0
   Coil_status_table(5) = 0
#endif
#if Use_read_holding_registers = 1
   For mbs_for_loop = 1 To 16
      Holding_registers_table(mbs_for_loop) = 0
   Next For_loop
#endif