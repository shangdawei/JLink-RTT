unit uJLinkProtocol;

interface

uses
  SysUtils, Windows, Classes, uJLinkUsb;

const
  { Constants for JLink command }
  JLINK_EMU_CMD_VERSION = $01;
  JLINK_EMU_CMD_RESET_TRST = $02;
  JLINK_EMU_CMD_RESET_TARGET = $03;
  JLINK_EMU_CMD_SET_SPEED = $05;
  JLINK_EMU_CMD_GET_STATE = $07;
  JLINK_EMU_CMD_GET_UNKNOW_09 = $09;
  JLINK_EMU_CMD_SET_KS_POWER = $08;
  JLINK_EMU_CMD_GET_SPEEDS = $C0;
  JLINK_EMU_CMD_GET_HW_INFO = $C1;
  JLINK_EMU_CMD_GET_COUNTERS = $C2;
  JLINK_EMU_CMD_GET_UNKNOW_C6 = $C6;
  JLINK_EMU_CMD_SELECT_IF = $C7;
  JLINK_EMU_CMD_HW_CLOCK = $C8;
  JLINK_EMU_CMD_HW_TMS0 = $C9;
  JLINK_EMU_CMD_HW_TMS1 = $CA;
  JLINK_EMU_CMD_HW_DATA0 = $CB;
  JLINK_EMU_CMD_HW_DATA1 = $CC;
  JLINK_EMU_CMD_HW_JTAG2 = $CE;
  JLINK_EMU_CMD_HW_JTAG3 = $CF;
  JLINK_EMU_CMD_HW_RELEASE_RESET_STOP_EX = $D0;
  JLINK_EMU_CMD_HW_RELEASE_RESET_STOP_TIMED = $D1;
  JLINK_EMU_CMD_GET_MAX_MEM_BLOCK = $D4;
  JLINK_EMU_CMD_HW_JTAG_GET_RESULT = $D6;
  JLINK_EMU_CMD_HW_RESET0 = $DC;
  JLINK_EMU_CMD_HW_RESET1 = $DD;
  JLINK_EMU_CMD_HW_TRST0 = $DE;
  JLINK_EMU_CMD_HW_TRST1 = $DF;
  JLINK_EMU_CMD_GET_UNKNOW_E6 = $E6;
  JLINK_EMU_CMD_GET_CAPS = $E8;
  JLINK_EMU_CMD_EXEC_CPU_CMD = $EA;
  JLINK_EMU_CMD_GET_UNKNOW_EB = $EB;
  JLINK_EMU_CMD_GET_CAPS_EX = $ED;
  JLINK_EMU_CMD_GET_HW_VERSION = $F0;
  JLINK_EMU_CMD_WRITE_DCC = $F1;
  JLINK_EMU_CMD_READ_CONFIG = $F2;
  JLINK_EMU_CMD_WRITE_CONFIG = $F3;
  JLINK_EMU_CMD_MEASURE_RTCK_REACT = $F6;

const
  JLINK_CPU_CAP_RESERVED = ( 1 shl 0 );
  JLINK_CPU_CAP_WRITE_MEM = ( 1 shl 1 );
  JLINK_CPU_CAP_READ_MEM = ( 1 shl 2 );

  JLINK_TIF_JTAG = ( 0 );
  JLINK_TIF_SWD = ( 1 );

  JLINK_TIF_JTAG_MASK = ( 1 shl JLINK_TIF_JTAG );
  JLINK_TIF_SWD_MASK = ( 1 shl JLINK_TIF_SWD );

const
  JLINK_EMU_CAP_RESERVED_1 = ( 1 shl 0 );
  JLINK_EMU_CAP_GET_HW_VERSION = ( 1 shl 1 );
  JLINK_EMU_CAP_WRITE_DCC = ( 1 shl 2 );
  JLINK_EMU_CAP_ADAPTIVE_CLOCKING = ( 1 shl 3 );
  JLINK_EMU_CAP_READ_CONFIG = ( 1 shl 4 );
  JLINK_EMU_CAP_WRITE_CONFIG = ( 1 shl 5 );
  JLINK_EMU_CAP_TRACE = ( 1 shl 6 );
  JLINK_EMU_CAP_WRITE_MEM = ( 1 shl 7 );
  JLINK_EMU_CAP_READ_MEM = ( 1 shl 8 );
  JLINK_EMU_CAP_SPEED_INFO = ( 1 shl 9 );
  JLINK_EMU_CAP_EXEC_CODE = ( 1 shl 10 );
  JLINK_EMU_CAP_GET_MAX_BLOCK_SIZE = ( 1 shl 11 );
  JLINK_EMU_CAP_GET_HW_INFO = ( 1 shl 12 );
  JLINK_EMU_CAP_SET_KS_POWER = ( 1 shl 13 );
  JLINK_EMU_CAP_RESET_STOP_TIMED = ( 1 shl 14 );
  JLINK_EMU_CAP_RESERVED_2 = ( 1 shl 15 );
  JLINK_EMU_CAP_MEASURE_RTCK_REACT = ( 1 shl 16 );
  JLINK_EMU_CAP_SELECT_IF = ( 1 shl 17 );
  JLINK_EMU_CAP_RW_MEM_ARM79 = ( 1 shl 18 );
  JLINK_EMU_CAP_GET_COUNTERS = ( 1 shl 19 );
  JLINK_EMU_CAP_READ_DCC = ( 1 shl 20 );
  JLINK_EMU_CAP_GET_CPU_CAPS = ( 1 shl 21 );
  JLINK_EMU_CAP_EXEC_CPU_CMD = ( 1 shl 22 );
  JLINK_EMU_CAP_SWO = ( 1 shl 23 );
  JLINK_EMU_CAP_WRITE_DCC_EX = ( 1 shl 24 );
  JLINK_EMU_CAP_UPDATE_FIRMWARE_EX = ( 1 shl 25 );
  JLINK_EMU_CAP_FILE_IO = ( 1 shl 26 );
  JLINK_EMU_CAP_REGISTER = ( 1 shl 27 );
  JLINK_EMU_CAP_INDICATORS = ( 1 shl 28 );
  JLINK_EMU_CAP_TEST_NET_SPEED = ( 1 shl 29 );
  JLINK_EMU_CAP_RAWTRACE = ( 1 shl 30 );
  JLINK_EMU_CAP_RESERVED_3 = ( 1 shl 31 );

  JLINK_EMU_CAP_EX_RESERVED0 = ( 1 shl 0 );
  JLINK_EMU_CAP_EX_GET_HW_VERSION = ( 1 shl 1 );
  JLINK_EMU_CAP_EX_WRITE_DCC = ( 1 shl 2 );
  JLINK_EMU_CAP_EX_ADAPTIVE_CLOCKING = ( 1 shl 3 );
  JLINK_EMU_CAP_EX_READ_CONFIG = ( 1 shl 4 );
  JLINK_EMU_CAP_EX_WRITE_CONFIG = ( 1 shl 5 );
  JLINK_EMU_CAP_EX_TRACE = ( 1 shl 6 );
  JLINK_EMU_CAP_EX_WRITE_MEM = ( 1 shl 7 );
  JLINK_EMU_CAP_EX_READ_MEM = ( 1 shl 8 );
  JLINK_EMU_CAP_EX_SPEED_INFO = ( 1 shl 9 );
  JLINK_EMU_CAP_EX_EXEC_CODE = ( 1 shl 10 );
  JLINK_EMU_CAP_EX_GET_MAX_BLOCK_SIZE = ( 1 shl 11 );
  JLINK_EMU_CAP_EX_GET_HW_INFO = ( 1 shl 12 );
  JLINK_EMU_CAP_EX_SET_KS_POWER = ( 1 shl 13 );
  JLINK_EMU_CAP_EX_RESET_STOP_TIMED = ( 1 shl 14 );
  JLINK_EMU_CAP_RESERVED1 = ( 1 shl 15 );
  JLINK_EMU_CAP_EX_MEASURE_RTCK_REACT = ( 1 shl 16 );
  JLINK_EMU_CAP_EX_SELECT_IF = ( 1 shl 17 );
  JLINK_EMU_CAP_EX_RW_MEM_ARM79 = ( 1 shl 18 );
  JLINK_EMU_CAP_EX_GET_COUNTERS = ( 1 shl 19 );
  JLINK_EMU_CAP_EX_READ_DCC = ( 1 shl 20 );
  JLINK_EMU_CAP_EX_GET_CPU_CAPS = ( 1 shl 21 );
  JLINK_EMU_CAP_EX_EXEC_CPU_CMD = ( 1 shl 22 );
  JLINK_EMU_CAP_EX_SWO = ( 1 shl 23 );
  JLINK_EMU_CAP_EX_WRITE_DCC_EX = ( 1 shl 24 );
  JLINK_EMU_CAP_EX_UPDATE_FIRMWARE_EX = ( 1 shl 25 );
  JLINK_EMU_CAP_EX_FILE_IO = ( 1 shl 26 );
  JLINK_EMU_CAP_EX_REGISTER = ( 1 shl 27 );
  JLINK_EMU_CAP_EX_INDICATORS = ( 1 shl 28 );
  JLINK_EMU_CAP_EX_TEST_NET_SPEED = ( 1 shl 29 );
  JLINK_EMU_CAP_EX_RAWTRACE = ( 1 shl 30 );
  JLINK_EMU_CAP_EX_GET_CAPS_EX = ( 1 shl 31 );
  JLINK_EMU_CAP_EX_HW_JTAG_WRITE = ( 1 shl 31 );

  JLINKARM_EmulatorCapabilites : array [ 0 .. 31 ] of string =
    ( 'JLINK_EMU_CAP_RESERVED_1', 'JLINK_EMU_CAP_GET_HW_VERSION',
    'JLINK_EMU_CAP_WRITE_DCC', 'JLINK_EMU_CAP_ADAPTIVE_CLOCKING',
    'JLINK_EMU_CAP_READ_CONFIG', 'JLINK_EMU_CAP_WRITE_CONFIG',
    'JLINK_EMU_CAP_TRACE', 'JLINK_EMU_CAP_WRITE_MEM', 'JLINK_EMU_CAP_READ_MEM',
    'JLINK_EMU_CAP_SPEED_INFO', 'JLINK_EMU_CAP_EXEC_CODE',
    'JLINK_EMU_CAP_GET_MAX_BLOCK_SIZE', 'JLINK_EMU_CAP_GET_HW_INFO',
    'JLINK_EMU_CAP_SET_KS_POWER', 'JLINK_EMU_CAP_RESET_STOP_TIMED',
    'JLINK_EMU_CAP_RESERVED_2', 'JLINK_EMU_CAP_MEASURE_RTCK_REACT',
    'JLINK_EMU_CAP_SELECT_IF', 'JLINK_EMU_CAP_RW_MEM_ARM79',
    'JLINK_EMU_CAP_GET_COUNTERS', 'JLINK_EMU_CAP_READ_DCC',
    'JLINK_EMU_CAP_GET_CPU_CAPS', 'JLINK_EMU_CAP_EXEC_CPU_CMD',
    'JLINK_EMU_CAP_SWO', 'JLINK_EMU_CAP_WRITE_DCC_EX',
    'JLINK_EMU_CAP_UPDATE_FIRMWARE_EX', 'JLINK_EMU_CAP_FILE_IO',
    'JLINK_EMU_CAP_REGISTER', 'JLINK_EMU_CAP_INDICATORS',
    'JLINK_EMU_CAP_TEST_NET_SPEED', 'JLINK_EMU_CAP_RAWTRACE',
    'JLINK_EMU_CAP_RESERVED_3' );

  JLINKARM_EmulatorCapabilitesEx : array [ 0 .. 31 ] of string =
    ( 'JLINK_EMU_CAP_EX_RESERVED0', 'JLINK_EMU_CAP_EX_GET_HW_VERSION',
    'JLINK_EMU_CAP_EX_WRITE_DCC', 'JLINK_EMU_CAP_EX_ADAPTIVE_CLOCKING',
    'JLINK_EMU_CAP_EX_READ_CONFIG', 'JLINK_EMU_CAP_EX_WRITE_CONFIG',
    'JLINK_EMU_CAP_EX_TRACE', 'JLINK_EMU_CAP_EX_WRITE_MEM',
    'JLINK_EMU_CAP_EX_READ_MEM', 'JLINK_EMU_CAP_EX_SPEED_INFO',
    'JLINK_EMU_CAP_EX_EXEC_CODE', 'JLINK_EMU_CAP_EX_GET_MAX_BLOCK_SIZE',
    'JLINK_EMU_CAP_EX_GET_HW_INFO', 'JLINK_EMU_CAP_EX_SET_KS_POWER',
    'JLINK_EMU_CAP_EX_RESET_STOP_TIMED', 'JLINK_EMU_CAP_RESERVED1',
    'JLINK_EMU_CAP_EX_MEASURE_RTCK_REACT', 'JLINK_EMU_CAP_EX_SELECT_IF',
    'JLINK_EMU_CAP_EX_RW_MEM_ARM79', 'JLINK_EMU_CAP_EX_GET_COUNTERS',
    'JLINK_EMU_CAP_EX_READ_DCC', 'JLINK_EMU_CAP_EX_GET_CPU_CAPS',
    'JLINK_EMU_CAP_EX_EXEC_CPU_CMD', 'JLINK_EMU_CAP_EX_SWO',
    'JLINK_EMU_CAP_EX_WRITE_DCC_EX', 'JLINK_EMU_CAP_EX_UPDATE_FIRMWARE_EX',
    'JLINK_EMU_CAP_EX_FILE_IO', 'JLINK_EMU_CAP_EX_REGISTER',
    'JLINK_EMU_CAP_EX_INDICATORS', 'JLINK_EMU_CAP_EX_TEST_NET_SPEED',
    'JLINK_EMU_CAP_EX_RAWTRACE', 'JLINK_EMU_CAP_EX_GET_CAPS_EX' );

type
  TJLINK_Speed = record
    BaseFreq : DWORD; { base frequency of emulator CPU }
    MinDiv : WORD; { min. divider of emulator CPU }
  end;

  TJLINK_Caps = record
    Caps : DWORD;
    CapsEx : array [ 0 .. 27 ] of BYTE;
  end;

  TJLINK_State = record
    Voltage : WORD; { VCC stored in unit mV }
    TCK : BYTE;
    TDI : BYTE;
    TDO : BYTE;
    TMS : BYTE;
    TRES : BYTE;
    TRST : BYTE;
  end;

const
  JLINK_HW_INFO_POWER_ENABLED = ( 1 shl 0 );
  JLINK_HW_INFO_POWER_OVERCURRENT = ( 1 shl 1 );
  JLINK_HW_INFO_ITARGET = ( 1 shl 2 );
  JLINK_HW_INFO_ITARGET_PEAK = ( 1 shl 3 );
  JLINK_HW_INFO_ITARGET_PEAK_OPERATION = ( 1 shl 4 );
  JLINK_HW_INFO_ITARGET_MAX_TIME0 = ( 1 shl 10 );
  JLINK_HW_INFO_ITARGET_MAX_TIME1 = ( 1 shl 11 );
  JLINK_HW_INFO_ITARGET_MAX_TIME2 = ( 1 shl 12 );

const
  JLINK_CNT_INDEX_POWER_ON = ( 1 shl 0 );
  JLINK_CNT_INDEX_POWER_CHANGE = ( 1 shl 1 );

const
  JLINK_CPU_CAPS_RESERVED = ( 1 shl 0 );
  JLINK_CPU_CAPS_WRITE_MEM = ( 1 shl 1 );
  JLINK_CPU_CAPS_READ_MEM = ( 1 shl 2 );

type
  TJLINK_HwInfo = record
    { Retrieves KS power status.
      0x00000000: Power is off,
      0x00000001: Power is on }
    PowerEnabled : DWORD;
    { Retrieves information about why the target power was switched off.
      0x00000000: Everything is normal
      0x00000001: 2ms @ 3000mA
      0x00000002: 10ms @ 1000mA
      0x00000003: 40ms @ 400mA }
    PowerOverCurrent : DWORD;

    ITarget : DWORD; { Consumption of the target in mA }
    ITargetPeak : DWORD; { Peak consumption of the target in mA }
    { Peak consumption of the target in mA while operating.
      In most cases this is the	same value as HW_INFO_ITARGET_PEAK. }
    ITargetPeakOperation : DWORD;

    { Max. time in ms the consumption of the target exceeded
      HW_INFO_POWER_OVERCURRENT type 0x01. }
    ITargetMaxTime0 : DWORD;
    { Max. time in ms the consumption of the target exceeded
      HW_INFO_POWER_OVERCURRENT type 0x02. }
    ITargetMaxTime1 : DWORD;
    { Max. time in ms the consumption of the target exceeded
      HW_INFO_POWER_OVERCURRENT type 0x03. }
    ITargetMaxTime2 : DWORD;
  end;

type
  TJLINK_Counters = record
    { Retrieves the counter describing how many ms a powered target
      is connected. The counter is reset after 24h. }
    PowerOn : DWORD;
    { Retrieves the counter describing how many times a powered target
      was connected or disconnected. }
    PowerChange : DWORD;
  end;

  TJLINK_RTCK = record
    Returned : DWORD;
    { 0x00000000: O.K. 0x00000001: RTCK did not react on time. }
    Minimum : DWORD; { Minimum RTCK reaction time in ns. }
    Maximum : DWORD; { Maximum RTCK reaction time in ns. }
    Average : DWORD; { Average RTCK reaction time in ns. }
  end;

  TJLINK_JTAG_ACC = record
    NumBits : WORD; { Number of bits to transfer. }
    TDI : PByte; { Data for TDI, TMS, NumBytes calculates as follows }
    TMS : PByte; { NumBytes = (NumBits + 7) >> 3 }
    TDO : PByte; { TDO Data, NumBytes calculates same }
    Returned : BYTE; { Return value: 0: O.K. Everything else: Error occured. }
  end;

  TJLINK_Criteria = record
    Offset : WORD; { Offset address where to check for criteria match. }
    Mask : WORD; { Criteria Mask }
    Data : WORD; { Criteria Data }
  end;

  TJLINK_CPU_CAPS_CMD = record
    DeviceFamily : BYTE; { Device family of the target CPU }
    { Target interface used to connect the emulator to the target CPU }
    InterfaceVal : BYTE;
    Dummy0 : BYTE;
    Dummy1 : BYTE;
  end;

  TJLINK_Config = packed record { 256 Bytes }
    UsbAddress : BYTE; { USB Address of the emulator }
    Dummy0 : array [ 0 .. 2 ] of BYTE;
    KS_Power : DWORD; { Kickstart power on JTAG-pin 19 }
    Dummy1 : array [ 0 .. 1 ] of DWORD;
    IpAddress : DWORD; { IP-Address (only for J-Link Pro). }
    IpMask : DWORD; { IP-Mask (only for J-Link Pro). }
    Dummy2 : DWORD;
    MacAddress : DWORD; { MAC-Address (only for J-Link Pro). }
    Dummy3 : array [ 0 .. 55 ] of DWORD;
  end;

  TJLINK_Protocol = class( TJLINK_USB )
  private
    procedure BufSetU16( var Buffer; Value : WORD );
    function BufGetU16( const Buffer ) : WORD;
    procedure BufSetU32( var Buffer; Value : DWORD );
    function BufGetU32( const Buffer ) : DWORD;
    procedure BufSetU64( var Buffer; Value : UInt64 );
    function BufGetU64( const Buffer ) : UInt64;
    function SimpleCommand( Command : BYTE ) : boolean;

  const
    INTERFACE_CMD_GET_CURRENT = $FE;
    INTERFACE_CMD_GET_AVAILABLE = $FF;
    { FF : Get Available, FE : Get Current, XX : Set Current }
    function InterfaceCommand( SubCmd : BYTE; var Respond : DWORD ) : boolean;

  public
    constructor Create( AbortEvent : THandle = 0 );
    destructor Destroy; override;

    function Open( UsbDeviceName : string ) : boolean;
    procedure Close( );

    function ReadConfig( var Config : TJLINK_Config ) : boolean;
    function WriteConfig( const Config : TJLINK_Config ) : boolean;

    function GetVersion( var Version112Bytes ) : boolean;
    function GetHwVersion( var HwVersion : DWORD ) : boolean;
    function GetState( var State : TJLINK_State ) : boolean;
    function GetHwInfo( var HwInfo : TJLINK_HwInfo ) : boolean;
    function GetCounters( var Counters : TJLINK_Counters ) : boolean;
    function GetMaxMemoryBlock( var MemoryBlock : DWORD ) : boolean;

    function GetCaps( var Caps : TJLINK_Caps ) : boolean;
    function GetCapsEx( var CapsEx : TJLINK_Caps ) : boolean;
    function GetCpuCaps( const CpuCapsCmd : TJLINK_CPU_CAPS_CMD;
      var CpuCaps : DWORD ) : boolean;

    function GetSpeed( var Speed : TJLINK_Speed ) : boolean;
    function SetSpeed( Speed : WORD ) : boolean;

    function SetCurrentInterface( InterfaceVal : BYTE ) : boolean;
    function GetCurrentInterface( var InterfaceVal : DWORD ) : boolean;
    function GetAvailableInterface( var InterfaceVal : DWORD ) : boolean;

    function SetKsPower( OnOff : BYTE ) : boolean;
    function MeasureRTCK( var RTCK : TJLINK_RTCK ) : boolean;

    function HwReset0( ) : boolean;
    function HwReset1( ) : boolean;
    function HwTms0( ) : boolean;
    function HwTms1( ) : boolean;
    function HwData0( ) : boolean;
    function HwData1( ) : boolean;
    function HwTrst0( ) : boolean;
    function HwTrst1( ) : boolean;
    function HwClock( var TDI : BYTE ) : boolean;
    function HwJtag3( JtagAcc : TJLINK_JTAG_ACC ) : boolean;
    function HwJtagWrite( JtagAcc : TJLINK_JTAG_ACC ) : boolean;
    function HwJtagGetResult( var Returned ) : boolean;
    function WriteDCC( ) : boolean;

    function ResetTrst( ) : boolean;
    function ResetTarget( ) : boolean;

    function HwReleaseResetStopEx( const JTAG_ACC; Reps : WORD; const Criteria )
      : boolean;
    function HwReleaseResetStopTimed( const JTAG_ACC; Timeout : WORD;
      const Criteria ) : boolean;
  end;

implementation

{ TJLINK_Protocol }

function TJLINK_Protocol.BufGetU16( const Buffer ) : WORD;
var
  BufferArray : array [ 0 .. 1 ] of BYTE absolute Buffer;
begin
  Result := ( BufferArray[ 1 ] shl 8 ) or ( BufferArray[ 0 ] shl 0 );
end;

function TJLINK_Protocol.BufGetU32( const Buffer ) : DWORD;
var
  BufferArray : array [ 0 .. 3 ] of BYTE absolute Buffer;
begin
  Result := ( BufferArray[ 3 ] shl 24 ) or ( BufferArray[ 2 ] shl 16 ) or
    ( BufferArray[ 1 ] shl 8 ) or ( BufferArray[ 0 ] shl 0 );
end;

function TJLINK_Protocol.BufGetU64( const Buffer ) : UInt64;
var
  BufferArray : array [ 0 .. 7 ] of BYTE absolute Buffer;
  ResultHigh, ResultLow : DWORD;
begin
  ResultLow := BufGetU32( BufferArray[ 0 ] );
  ResultHigh := BufGetU32( BufferArray[ 4 ] );
  Result := ( ResultHigh shl 32 ) or ResultLow;
end;

procedure TJLINK_Protocol.BufSetU16( var Buffer; Value : WORD );
var
  BufferArray : array [ 0 .. 1 ] of BYTE absolute Buffer;
begin
  BufferArray[ 0 ] := Value and $FF;
  BufferArray[ 1 ] := Value shr 8;
end;

procedure TJLINK_Protocol.BufSetU32( var Buffer; Value : DWORD );
var
  BufferArray : array [ 0 .. 3 ] of BYTE absolute Buffer;
begin
  BufferArray[ 0 ] := Value and $FF;
  BufferArray[ 1 ] := Value shr 8;
  BufferArray[ 2 ] := Value shr 16;
  BufferArray[ 3 ] := Value shr 24;
end;

procedure TJLINK_Protocol.BufSetU64( var Buffer; Value : UInt64 );
var
  BufferArray : array [ 0 .. 7 ] of BYTE absolute Buffer;
begin
  BufSetU32( BufferArray[ 0 ], Value and $FFFFFFFF );
  BufSetU32( BufferArray[ 4 ], Value shr 32 );
end;

constructor TJLINK_Protocol.Create( AbortEvent : THandle );
begin
  inherited Create( AbortEvent );
end;

destructor TJLINK_Protocol.Destroy;
begin
  inherited Destroy;
end;

procedure TJLINK_Protocol.Close;
begin
  UsbClose;
end;

function TJLINK_Protocol.Open( UsbDeviceName : string ) : boolean;
begin
  Result := UsbOpen( UsbDeviceName );
end;

function TJLINK_Protocol.SimpleCommand( Command : BYTE ) : boolean;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      Result := UsbWrite( Command, 1 ) = 1;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.InterfaceCommand( SubCmd : BYTE; var Respond : DWORD )
  : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_SELECT_IF;
      OutBuffer[ 1 ] := SubCmd;
      RetLen := 4;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 2, InBuffer[ 0 ], RetLen );
      if Result then
        CopyMemory( @Respond, @InBuffer[ 0 ], RetLen );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetAvailableInterface( var InterfaceVal : DWORD )
  : boolean;
begin
  Result := InterfaceCommand( INTERFACE_CMD_GET_AVAILABLE, InterfaceVal );
end;

function TJLINK_Protocol.GetCurrentInterface( var InterfaceVal : DWORD )
  : boolean;
begin
  Result := InterfaceCommand( INTERFACE_CMD_GET_CURRENT, InterfaceVal );
end;

function TJLINK_Protocol.SetCurrentInterface( InterfaceVal : BYTE ) : boolean;
var
  PreviousInterfaceVal : DWORD;
begin
  Result := InterfaceCommand( InterfaceVal, PreviousInterfaceVal );
end;

function TJLINK_Protocol.GetVersion( var Version112Bytes ) : boolean;
const
  VersionSize = $70;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_VERSION;
      RetLen := 2 + VersionSize;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
        CopyMemory( Pointer( @Version112Bytes ), @InBuffer[ 0 ], VersionSize );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetHwVersion( var HwVersion : DWORD ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_HW_VERSION;
      RetLen := 4;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
        HwVersion := BufGetU32( InBuffer );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetCaps( var Caps : TJLINK_Caps ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_CAPS;
      RetLen := 4;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
        Caps.Caps := BufGetU32( InBuffer );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetCapsEx( var CapsEx : TJLINK_Caps ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_CAPS_EX;
      RetLen := 32;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
        CopyMemory( @CapsEx, @InBuffer[ 0 ], RetLen );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetCounters( var Counters : TJLINK_Counters )
  : boolean;
var
  RetLen : Integer;
  Mask : DWORD;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      Mask := JLINK_CNT_INDEX_POWER_ON or JLINK_CNT_INDEX_POWER_CHANGE;
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_COUNTERS;
      BufSetU32( OutBuffer[ 1 ], Mask );
      RetLen := sizeof( TJLINK_Counters );
      FillChar( InBuffer[ 0 ], RetLen, 0 );
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        Counters.PowerOn := BufGetU32( InBuffer[ 0 ] );
        Counters.PowerChange := BufGetU32( InBuffer[ 4 ] );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetCpuCaps( const CpuCapsCmd : TJLINK_CPU_CAPS_CMD;
  var CpuCaps : DWORD ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_EXEC_CPU_CMD;
      CopyMemory( @OutBuffer[ 1 ], @CpuCapsCmd, sizeof( TJLINK_CPU_CAPS_CMD ) );
      RetLen := sizeof( DWORD );
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        CpuCaps := BufGetU32( InBuffer[ 0 ] );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetHwInfo( var HwInfo : TJLINK_HwInfo ) : boolean;
var
  RetLen : Integer;
  Mask : DWORD;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      Mask := JLINK_HW_INFO_POWER_ENABLED or JLINK_HW_INFO_POWER_OVERCURRENT or
        JLINK_HW_INFO_ITARGET or JLINK_HW_INFO_ITARGET_PEAK;
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_HW_INFO;
      BufSetU32( OutBuffer[ 1 ], Mask );
      RetLen := 4 * sizeof( DWORD );
      FillChar( InBuffer[ 0 ], RetLen, 0 );
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        HwInfo.PowerEnabled := BufGetU32( InBuffer[ 0 ] );
        HwInfo.PowerOverCurrent := BufGetU32( InBuffer[ 4 ] );
        HwInfo.ITarget := BufGetU32( InBuffer[ 8 ] );
        HwInfo.ITargetPeak := BufGetU32( InBuffer[ 12 ] );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetMaxMemoryBlock( var MemoryBlock : DWORD ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_SPEEDS;
      RetLen := 4;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        MemoryBlock := BufGetU32( InBuffer );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetSpeed( var Speed : TJLINK_Speed ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_SPEEDS;
      RetLen := 6;
      FillChar( InBuffer[ 0 ], RetLen, 0 );
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        Speed.BaseFreq := BufGetU32( InBuffer[ 0 ] );
        Speed.MinDiv := BufGetU16( InBuffer[ 4 ] );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.GetState( var State : TJLINK_State ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_GET_STATE;
      RetLen := 8;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        CopyMemory( @State, @InBuffer[ 0 ], RetLen );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.HwClock( var TDI : BYTE ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_HW_CLOCK;
      RetLen := 1;
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        TDI := InBuffer[ 0 ];
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.MeasureRTCK( var RTCK : TJLINK_RTCK ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_MEASURE_RTCK_REACT;
      RetLen := sizeof( TJLINK_RTCK );
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        RTCK.Returned := BufGetU32( InBuffer[ 0 ] );
        RTCK.Minimum := BufGetU32( InBuffer[ 4 ] );
        RTCK.Maximum := BufGetU32( InBuffer[ 8 ] );
        RTCK.Average := BufGetU32( InBuffer[ 12 ] );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.ResetTarget : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_RESET_TARGET );
end;

function TJLINK_Protocol.ResetTrst : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_RESET_TRST );
end;

function TJLINK_Protocol.HwData0 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_DATA0 );
end;

function TJLINK_Protocol.HwData1 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_DATA1 );
end;

function TJLINK_Protocol.HwReset0 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_RESET0 );
end;

function TJLINK_Protocol.HwReset1 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_RESET1 );
end;

function TJLINK_Protocol.HwTms0 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_TMS0 );
end;

function TJLINK_Protocol.HwTms1 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_TMS1 );
end;

function TJLINK_Protocol.HwTrst0 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_TRST0 );
end;

function TJLINK_Protocol.HwTrst1 : boolean;
begin
  Result := SimpleCommand( JLINK_EMU_CMD_HW_TRST1 );
end;

function TJLINK_Protocol.SetKsPower( OnOff : BYTE ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_SET_SPEED;
      OutBuffer[ 1 ] := OnOff;
      RetLen := 1 + sizeof( BYTE );
      Result := RetLen = UsbWrite( OutBuffer[ 0 ], RetLen );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.SetSpeed( Speed : WORD ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_SET_SPEED;
      BufSetU16( OutBuffer[ 1 ], Speed );
      RetLen := 1 + sizeof( WORD );
      Result := RetLen = UsbWrite( OutBuffer[ 0 ], RetLen );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.ReadConfig( var Config : TJLINK_Config ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      OutBuffer[ 0 ] := JLINK_EMU_CMD_READ_CONFIG;
      RetLen := sizeof( TJLINK_Config );
      Result := RetLen = UsbAccess( OutBuffer[ 0 ], 1, InBuffer[ 0 ], RetLen );
      if Result then
      begin
        CopyMemory( @Config, @InBuffer[ 0 ], RetLen );
      end;
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.WriteConfig( const Config : TJLINK_Config ) : boolean;
var
  RetLen : Integer;
begin
  Result := UsbLock( );
  if Result then
  begin
    try
      RetLen := sizeof( TJLINK_Config );
      OutBuffer[ 0 ] := JLINK_EMU_CMD_WRITE_CONFIG;
      CopyMemory( @OutBuffer[ 1 ], @Config, RetLen );
      Inc( RetLen );
      Result := RetLen = UsbWrite( OutBuffer[ 0 ], RetLen );
    finally
      UsbUnlock( );
    end;
  end;
end;

function TJLINK_Protocol.HwReleaseResetStopEx( const JTAG_ACC; Reps : WORD;
  const Criteria ) : boolean;
begin
  Exit( False );
end;

function TJLINK_Protocol.HwReleaseResetStopTimed( const JTAG_ACC;
  Timeout : WORD; const Criteria ) : boolean;
begin
  Exit( False );
end;

function TJLINK_Protocol.HwJtag3( JtagAcc : TJLINK_JTAG_ACC ) : boolean;
begin
  Exit( False );
end;

function TJLINK_Protocol.HwJtagWrite( JtagAcc : TJLINK_JTAG_ACC ) : boolean;
begin
  Exit( False );
end;

function TJLINK_Protocol.HwJtagGetResult( var Returned ) : boolean;
begin
  Exit( False );
end;

function TJLINK_Protocol.WriteDCC : boolean;
begin
  Exit( False );
end;

end.
