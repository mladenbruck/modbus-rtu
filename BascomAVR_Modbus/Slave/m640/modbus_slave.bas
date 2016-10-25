'*******************************************************************************
'
'  MODBUS SERIAL CLIENT
'  Mladen Bruck
'  AVRBIT electronic
'  www.avrbit.com
'  info AT avrbit.com
'
'  Started December 2009
'  Last modification March, 2010
'
'  Supported functions:
'
' read coil status  1
' read discrete inputs  2
' read holding registers  3
' read input registers  4
' write single coil  5
' write single register  6
' write multiple coils  15
' Read_Write registars 23
' user function 65            ' Not defined what function do, this user applicable function code
'
' To do
' Write multiple registers 16

'*******************************************************************************

'****************************************************************
' Compiler directives
'****************************************************************
'$PROGRAMMER = 7

$projecttime = 4
'$regfile = "m640def.dat"                                    ' chip used
$regfile = "m1280def.dat"                                   ' chip used
$hwstack = 256
$swstack = 128
$framesize = 64


'Crystal MUST one of this for %0 communicatio error
'Const _crystal = 11059200
'Const _crystal = 14745600
Const _crystal = 18432000
$crystal = _crystal                                         ' xtal used

'modbus.lib contains the crcMB function
$lib "modbus.lbx"

'DEBUG on
'DEBUG off

'****************************************************************
' MCU hardware configuration
'****************************************************************
Const HMI_serial_port = 1

'Const HMI_baudrate = 9600
Const HMI_baudrate = 19200
'Const HMI_baudrate = 38400
'Const HMI_baudrate = 57600
'Const HMI_baudrate = 115200
'Const HMI_baudrate = 230400
'Const HMI_baudrate = 460800

Const Mbs_serial_port = 3                                   '  3=485, 4=TIBBO
'Const Mbs_baudrate = 9600
'Const Mbs_baudrate = 19200
'Const Mbs_baudrate = 38400
Const Mbs_baudrate = 57600
'Const Mbs_baudrate = 76800
'Const Mbs_baudrate = 115200
'Const Mbs_baudrate = 230400
'Const Mbs_baudrate = 460800
$include "mb_s_files\mbs_config.bas"

Const Ploca_32 =  0
Const Ploca_40 = 1

'*********************************************************************
' MODBUS functions configuration
'*********************************************************************
Const Mbs_adress = 1
#if Ploca_32 = 1
   Const Mbs_maximum_coil_number = 23                       ' Keep in mind that modbus adress start at 0 so this is 16 coils !
   Const Mbs_maximum_discrete_inputs = 31                   ' Keep in mind that modbus adress start at 0 so this is 16 inputs !
#endif
#if Ploca_40 = 1
   Const Mbs_maximum_coil_number = 31                       ' Keep in mind that modbus adress start at 0 so this is 16 coils !
   Const Mbs_maximum_discrete_inputs = 39                   ' Keep in mind that modbus adress start at 0 so this is 16 inputs !
#endif
Const Mbs_maximum_holding_registers = 32                    ' Keep in mind that modbus adress start at 0 so this is 16 registers !
Const Mbs_maximum_input_registers = 16                      ' Keep in mind that modbus adress start at 0 so this is 16 registers !
const Mbs_watchdog_alarm = 100                              ' 150 * 10ms

Const Use_read_coil_status = 1
Const Use_read_discrete_inputs = 1
Const Use_read_holding_registers = 1
Const Use_read_input_registers = 1
Const Use_write_single_register = 1
Const Use_write_single_coil = 1                             ' If 0 then Use_write_multiple_coils must be 0 also
Const Use_write_multiple_coils = 1                          ' If 1 then Use_write_single_coil must be 1 also
Const Use_Read_Write_registars = 1
Const Use_user_function = 0

'*********************************************************************
' I/O configuration
'**********************************************************************
$include "mb_s_files\mbs_io_setup.bas"

'**********************************************************************
' SUB and  function declarations
'**********************************************************************
$include "mb_s_files\mbs_defs.bas"

'************************************************************
' Const definitions
'************************************************************
$include "mb_s_files\mbs_consts.bas"

'************************************************************
' Variables definitions
'************************************************************
$include "mb_s_files\mbs_var_defs.bas"

' Genereal program use
Dim For_loop As Byte


'************************************************************
' Program initialisation
'************************************************************
#if Use_read_holding_registers = 1
   For For_loop = 1 To Mbs_maximum_holding_registers
      Mbs_holding_registers_table(for_loop) = For_loop + 2000
   Next For_loop
#endif
#if Use_read_input_registers = 1
   For For_loop = 1 To Mbs_maximum_input_registers
      Mbs_input_registers_table(for_loop) = For_loop + 3000
   Next For_loop
#endif

'************************************************************
''  Program start
'************************************************************
Enable Timer3
Stop Timer3
timer_3_started = 0
Enable Interrupts

Print "Start modbus slave"

'****************** User program start here ****************
Do
   NOP
   waitms 10
   incr Mbs_watchdog
   if Mbs_watchdog > Mbs_watchdog_alarm then
      shut_down_all
      Mbs_watchdog = 0
   end if
Loop

End

'************************************************************
'----------------- SUBS and Functions ---------------------
'************************************************************
$include "mb_s_files\mbs_subs.bas"

'***********************************************************
' INTERUPTS !
'***********************************************************
$include "mb_s_files\mbs_interrupt.bas"