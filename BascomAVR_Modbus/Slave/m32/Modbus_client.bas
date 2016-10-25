'*******************************************************************************
'
'  MODBUS SERIAL CLIENT
'  Mladen Bruck
'  AVRBIT electronic
'  www.avrbit.com
'  info AT avrbit.com
'
'  Start: December, 2009
'  Last modification: July, 2011
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
' read single adc Alias 65                                  ' User function 65
'
'
' Function need to   be implement
' write multiple register  16
'
'*******************************************************************************

'****************************************************************
' Compiler directives
'****************************************************************
$projecttime = 0
'$regfile = "m32def.dat"                                     ' chip used
$regfile = "m16def.dat"                                     ' chip used

$hwstack = 48                                               ' default use 32 for the hardware stack
$swstack = 48                                               ' default use 10 for the SW stack
$framesize = 32                                             ' default use 40 for the frame space


' ************* !!!!!!!!!!!!!!!!!! ********************
' THIS MUST BE IN MAIN PROGRAM ALSO

'Const _crystal = 8000000
'Const _crystal = 11059200
'Const _crystal = 12288000
'Const _crystal = 14745600
Const _crystal = 18432000
'Const _crystal = 22118400
$crystal = _crystal                                         ' xtal used

'Const Modbus_baudrate = 9600
'Const Modbus_baudrate = 19200
'Const Modbus_baudrate = 38400
Const Modbus_baudrate = 57600                               ' NOT FOR 1228800 crystal
'Const Modbus_baudrate = 76800
'Const Modbus_baudrate = 115200                              ' NOT FOR 1228800 crystal
'Const Modbus_baudrate = 153600                             ' Only for 1228800 crystal (for now)
$baud = Modbus_baudrate                                     ' baud rate used

'Const Use_read_coil_status = 0
'Const Use_read_discrete_inputs = 0
'Const Use_read_holding_registers = 1
'Const Use_read_input_registers = 0
'Const Use_write_single_coil = 0
'Const Use_write_multiple_coils = 0                          ' If 1 then Use_write_single_coil must be 1 also
'Const Use_write_single_register = 1
'Const Use_write_multiple_registers = 0                      ' Not implemented yet
'Const Use_bootloader_packet = 0
'#if Use_bootloader_packet = 1
'   Bootloader_adr Alias &H1C00
'   $loadersize = &H1C00
'#endif
'Const Use_read_single_adc = 1                               ' Not defined in standard, user applicable

'Const Modbus_slave_adress = 1
'Const Maximum_coil_number = 10                              ' Keep in mind that modbus adress start at 0 so this is 16 coils !
'Const Maximum_discrete_inputs = 16                          ' Keep in mind that modbus adress start at 0 so this is 16 inputs !
'Const Maximum_holding_registers = 15                        ' Keep in mind that modbus adress start at 0 so this is 16 registers !
'Const Maximum_input_registers = 15                          ' Keep in mind that modbus adress start at 0 so this is 16 registers !
'Const Maximum_adc_channel = 7                               ' Keep in mind that modbus adress start at 0 so this is 8 channels !

'modbus.lib contains the crcMB function
$lib "modbus.lbx"
'****************************************************************


'****************************************************************
' MCU hardware configuration
'****************************************************************
$include "mbs_timer.bas"
'Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'Config Serialin = Buffered , Size = 16 , Bytematch = All

$include "mbs_io_config.bas"

'**********************************************************************
' SUB and  function declarations
'**********************************************************************
$include "mbs_subs_defs.bas"                                ' Modebus Slave subs defs

'************************************************************
' Const definitions
'************************************************************
$include "mbs_const.bas"

'************************************************************
' Variables definitions
'************************************************************
$include "mbs_vars.bas"


'************************************************************
' Program initialisation
'************************************************************
$include "mbs_init.bas"

'************************************************************
'  Program start
'************************************************************

'****************** User program start here ****************
Do
   NOP
Loop

End

'************************************************************
'----------------- SUBS and Functions ---------------------
'************************************************************
$include "mbs_subs.bas"

'***********************************************************
' INTERUPTS !
'***********************************************************
$include "mbs_interrupts.bas"