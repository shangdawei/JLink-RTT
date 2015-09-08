unit uJLinkARM;

interface

uses
  System.SysUtils, Vcl.Forms, Vcl.Dialogs, Windows, Classes, uJLinkUsb,
  uJLinkProtocol;

const
  JLINKARM_SPEED_MIN_VALUE = 5000;
  JLINKARM_SPEED_MID_VALUE = 4000000;
  JLINKARM_SPEED_MAX_VALUE = 50000000;

  JLINKARM_SPEED_MAX = $FFFFFFFF; // JLINKARM_SetSpeedFunc( 0x00000000 )
  JLINKARM_SPEED_AUTO = $FFFFFFCE; // JLINKARM_SetSpeedFunc( 0x00000000 )
  JLINKARM_SPEED_ADAPTIVE = $0000FFFF; // JTAG only with RTCK

  JLINKARM_SpeedStrings : array [ 0 .. 27 ] of string = ( 'Auto', '10 KHz',
    '20 KHz', '50 KHz', '100 KHz', '200 KHz ', '300 KHz', '400 KHz', '500 KHz',
    '600 KHz', '750 KHz', '900 KHz', '1000 KHz', '1600 KHz', '2000 KHz',
    '3200 KHz', '4000 KHz', '4800 KHz', '6000 KHz', '8000 KHz', '9600 KHz',
    '12000 KHz', '15000 KHz', '20000 KHz', '25000 KHz', '30000 KHz',
    '40000 KHz', '50000 KHz' );

  JLINKARM_SpeedValues : array [ 0 .. 27 ] of NativeInt = ( -1, 10000, 20000,
    50000, 100000, 200000, 300000, 400000, 500000, 600000, 750000, 900000,
    1000000, 1600000, 2000000, 3200000, 4000000, 4800000, 6000000, 8000000,
    9600000, 12000000, 15000000, 20000000, 25000000, 30000000, 40000000,
    50000000 );

const
  JLINKARM_SWO_CMD_START = 0;
  JLINKARM_SWO_CMD_STOP = 1;
  JLINKARM_SWO_CMD_FLUSH = 2;
  JLINKARM_SWO_CMD_GET_SPEED_INFO = 3;
  JLINKARM_SWO_CMD_GET_NUM_BYTES = 10;
  JLINKARM_SWO_CMD_SET_BUFFERSIZE_HOST = 20;
  JLINKARM_SWO_CMD_SET_BUFFERSIZE_EMU = 21;

const

  JLINKARM_CM_R0 = $00;
  JLINKARM_CM_R1 = $01;
  JLINKARM_CM_R2 = $02;
  JLINKARM_CM_R3 = $03;
  JLINKARM_CM_R4 = $04;
  JLINKARM_CM_R5 = $05;
  JLINKARM_CM_R6 = $06;
  JLINKARM_CM_R7 = $07;
  JLINKARM_CM_R8 = $08;
  JLINKARM_CM_R9 = $09;
  JLINKARM_CM_R10 = $0A;
  JLINKARM_CM_R11 = $0B;
  JLINKARM_CM_R12 = $0C;
  JLINKARM_CM_R13 = $0D;
  JLINKARM_CM_R14 = $0E;
  JLINKARM_CM_R15 = $0F;
  JLINKARM_CM_XPSR = $10;
  JLINKARM_CM_MSP = $11;
  JLINKARM_CM_PSP = $12;
  JLINKARM_CM_RAZ = $13;
  JLINKARM_CM_CFBP = $14;
  JLINKARM_CM_APSR = $15;
  JLINKARM_CM_EPSR = $16;
  JLINKARM_CM_IPSR = $17;
  JLINKARM_CM_PRIMASK = $18;
  JLINKARM_CM_BASEPRI = $19;
  JLINKARM_CM_FAULTMASK = $1A;
  JLINKARM_CM_CONTROL = $1B;
  JLINKARM_CM_BASEPRI_MAX = $1C;
  JLINKARM_CM_IAPSR = $1D;
  JLINKARM_CM_EAPSR = $1E;
  JLINKARM_CM_IEPSR = $1F;
  JLINKARM_CM_FPSCR = $20;
  JLINKARM_CM_FPS0 = $21;
  JLINKARM_CM_FPS1 = $22;
  JLINKARM_CM_FPS2 = $23;
  JLINKARM_CM_FPS3 = $24;
  JLINKARM_CM_FPS4 = $25;
  JLINKARM_CM_FPS5 = $26;
  JLINKARM_CM_FPS6 = $27;
  JLINKARM_CM_FPS7 = $28;
  JLINKARM_CM_FPS8 = $29;
  JLINKARM_CM_FPS9 = $2A;
  JLINKARM_CM_FPS10 = $2B;
  JLINKARM_CM_FPS11 = $2C;
  JLINKARM_CM_FPS12 = $2D;
  JLINKARM_CM_FPS13 = $2E;
  JLINKARM_CM_FPS14 = $2F;
  JLINKARM_CM_FPS15 = $30;
  JLINKARM_CM_FPS16 = $31;
  JLINKARM_CM_FPS17 = $32;
  JLINKARM_CM_FPS18 = $33;
  JLINKARM_CM_FPS19 = $34;
  JLINKARM_CM_FPS20 = $35;
  JLINKARM_CM_FPS21 = $36;
  JLINKARM_CM_FPS22 = $37;
  JLINKARM_CM_FPS23 = $38;
  JLINKARM_CM_FPS24 = $39;
  JLINKARM_CM_FPS25 = $3A;
  JLINKARM_CM_FPS26 = $3B;
  JLINKARM_CM_FPS27 = $3C;
  JLINKARM_CM_FPS28 = $3D;
  JLINKARM_CM_FPS29 = $3E;
  JLINKARM_CM_FPS30 = $3F;
  JLINKARM_CM_FPS31 = $40;

const
  JLINKARM_ARM_R0 = $00;
  JLINKARM_ARM_R1 = $01;
  JLINKARM_ARM_R2 = $02;
  JLINKARM_ARM_R3 = $03;
  JLINKARM_ARM_R4 = $04;
  JLINKARM_ARM_R5 = $05;
  JLINKARM_ARM_R6 = $06;
  JLINKARM_ARM_R7 = $07;
  JLINKARM_ARM_CPSR = $08;
  JLINKARM_ARM_R15_PC = $09;
  JLINKARM_ARM_R8_USR = $0A;
  JLINKARM_ARM_R9_USR = $0B;
  JLINKARM_ARM_R10_USR = $0C;
  JLINKARM_ARM_R11_USR = $0D;
  JLINKARM_ARM_R12_USR = $0E;
  JLINKARM_ARM_R13_USR = $0F;
  JLINKARM_ARM_R14_USR = $10;
  JLINKARM_ARM_SPSR_FIQ = $11;
  JLINKARM_ARM_R8_FIQ = $12;
  JLINKARM_ARM_R9_FIQ = $13;
  JLINKARM_ARM_R10_FIQ = $14;
  JLINKARM_ARM_R11_FIQ = $15;
  JLINKARM_ARM_R12_FIQ = $16;
  JLINKARM_ARM_R13_FIQ = $17;
  JLINKARM_ARM_R14_FIQ = $18;
  JLINKARM_ARM_SPSR_SVC = $19;
  JLINKARM_ARM_R13_SVC = $1A;
  JLINKARM_ARM_R14_SVC = $1B;
  JLINKARM_ARM_SPSR_ABT = $1C;
  JLINKARM_ARM_R13_ABT = $1D;
  JLINKARM_ARM_R14_ABT = $1E;
  JLINKARM_ARM_SPSR_IRQ = $1F;
  JLINKARM_ARM_R13_IRQ = $20;
  JLINKARM_ARM_R14_IRQ = $21;
  JLINKARM_ARM_SPSR_UND = $22;
  JLINKARM_ARM_R13_UND = $23;
  JLINKARM_ARM_R14_UND = $24;
  JLINKARM_ARM_FPSID = $25;
  JLINKARM_ARM_FPSCR = $26;
  JLINKARM_ARM_FPEXC = $27;
  JLINKARM_ARM_FPS0 = $28;
  JLINKARM_ARM_FPS1 = $29;
  JLINKARM_ARM_FPS2 = $2A;
  JLINKARM_ARM_FPS3 = $2B;
  JLINKARM_ARM_FPS4 = $2C;
  JLINKARM_ARM_FPS5 = $2D;
  JLINKARM_ARM_FPS6 = $2E;
  JLINKARM_ARM_FPS7 = $2F;
  JLINKARM_ARM_FPS8 = $30;
  JLINKARM_ARM_FPS9 = $31;
  JLINKARM_ARM_FPS10 = $32;
  JLINKARM_ARM_FPS11 = $33;
  JLINKARM_ARM_FPS12 = $34;
  JLINKARM_ARM_FPS13 = $35;
  JLINKARM_ARM_FPS14 = $36;
  JLINKARM_ARM_FPS15 = $37;
  JLINKARM_ARM_FPS16 = $38;
  JLINKARM_ARM_FPS17 = $39;
  JLINKARM_ARM_FPS18 = $3A;
  JLINKARM_ARM_FPS19 = $3B;
  JLINKARM_ARM_FPS20 = $3C;
  JLINKARM_ARM_FPS21 = $3D;
  JLINKARM_ARM_FPS22 = $3E;
  JLINKARM_ARM_FPS23 = $3F;
  JLINKARM_ARM_FPS24 = $40;
  JLINKARM_ARM_FPS25 = $41;
  JLINKARM_ARM_FPS26 = $42;
  JLINKARM_ARM_FPS27 = $43;
  JLINKARM_ARM_FPS28 = $44;
  JLINKARM_ARM_FPS29 = $45;
  JLINKARM_ARM_FPS30 = $46;
  JLINKARM_ARM_FPS31 = $47;

const
  JLINKARM_CM_Registers : array [ 0 .. 64 ] of string = ( 'CM_R0', 'CM_R1',
    'CM_R2', 'CM_R3', 'CM_R4', 'CM_R5', 'CM_R6', 'CM_R7', 'CM_R8', 'CM_R9',
    'CM_R10', 'CM_R11', 'CM_R12', 'CM_R13', 'CM_R14', 'CM_R15', 'CM_XPSR',
    'CM_MSP', 'CM_PSP', 'CM_RAZ', 'CM_CFBP', 'CM_APSR', 'CM_EPSR', 'CM_IPSR',
    'CM_PRIMASK', 'CM_BASEPRI', 'CM_FAULTMASK', 'CM_CONTROL', 'CM_BASEPRI_MAX',
    'CM_IAPSR', 'CM_EAPSR', 'CM_IEPSR', 'CM_FPSCR', 'CM_FPS0', 'CM_FPS1',
    'CM_FPS2', 'CM_FPS3', 'CM_FPS4', 'CM_FPS5', 'CM_FPS6', 'CM_FPS7', 'CM_FPS8',
    'CM_FPS9', 'CM_FPS10', 'CM_FPS11', 'CM_FPS12', 'CM_FPS13', 'CM_FPS14',
    'CM_FPS15', 'CM_FPS16', 'CM_FPS17', 'CM_FPS18', 'CM_FPS19', 'CM_FPS20',
    'CM_FPS21', 'CM_FPS22', 'CM_FPS23', 'CM_FPS24', 'CM_FPS25', 'CM_FPS26',
    'CM_FPS27', 'CM_FPS28', 'CM_FPS29', 'CM_FPS30', 'CM_FPS31' );

const
  JLINKARM_ARM_Registers : array [ 0 .. $47 ] of string = ( 'R0', 'R1', 'R2',
    'R3', 'R4', 'R5', 'R6', 'R7', 'CPSR', 'R15 (PC)', 'R8_USR', 'R9_USR',
    'R10_USR', 'R11_USR', 'R12_USR', 'R13_USR', 'R14_USR', 'SPSR_FIQ', 'R8_FIQ',
    'R9_FIQ', 'R10_FIQ', 'R11_FIQ', 'R12_FIQ', 'R13_FIQ', 'R14_FIQ', 'SPSR_SVC',
    'R13_SVC', 'R14_SVC', 'SPSR_ABT', 'R13_ABT', 'R14_ABT', 'SPSR_IRQ',
    'R13_IRQ', 'R14_IRQ', 'SPSR_UND', 'R13_UND', 'R14_UND', 'FPSID', 'FPSCR',
    'FPEXC', 'FPS0', 'FPS1', 'FPS2', 'FPS3', 'FPS4', 'FPS5', 'FPS6', 'FPS7',
    'FPS8', 'FPS9', 'FPS10', 'FPS11', 'FPS12', 'FPS13', 'FPS14', 'FPS15',
    'FPS16', 'FPS17', 'FPS18', 'FPS19', 'FPS20', 'FPS21', 'FPS22', 'FPS23',
    'FPS24', 'FPS25', 'FPS26', 'FPS27', 'FPS28', 'FPS29', 'FPS30', 'FPS31' );

type
  TJLINKARM_Log = ( jlInformation, jlWarning, jlError );
  TJLINKARM_LogOutCb = procedure( strLog : PAnsiChar ); cdecl;
  TJLINKARM_WarningOutCb = procedure( strWarning : PAnsiChar ); cdecl;
  TJLINKARM_ErrorOutCb = procedure( strError : PAnsiChar ); cdecl;
  TJLINKARM_LogEvent = procedure( JLinkLog : TJLINKARM_Log; Info : string )
    of object;

type
  TJLINKARM_Inteface = ( jiJTAG, jiSWD, jiAuto, jiUnknown );

  // 0 : JLINKARM_TIF_JTAG
  // 1 : JLINKARM_TIF_SWD
  // 2 : JLINKARM_TIF_BDM3
  // 3 : JLINKARM_TIF_FINE
  // 4 : JLINKARM_TIF_2_WIRE_JTAG_PIC32
  // 5 : ???
  // return mask for available interface
  // 0x3B : 00111011
  //
  TJLINKARM_TIF = ( JLINKARM_TIF_JTAG, JLINKARM_TIF_SWD, JLINKARM_TIF_BDM3,
    JLINKARM_TIF_FINE, JLINKARM_TIF_2_WIRE_JTAG_PIC32, JLINKARM_TIF_UNKNOWN );

type
  TJLINKRAM_MemoryUnit = ( mu8Bits, mu16Bits, mu32Bits, mu64Bits );

  // The size of a pointer depends on the operating system and/or the processor.
  // On 32-bit platforms, a pointer is stored on 4 bytes as a 32-bit address.
  // On 64-bit platforms, a pointer is stored on 8 bytes as a 64-bit address.
  TWriteMemMultiple = record
    memaddr : DWORD;
    size : DWORD;
    buff : Pointer;
    dummy0 : DWORD;
    Alignment : DWORD;
    dummy1 : DWORD;
    dummy2 : DWORD;
  end;

  PWriteMemMultiple = ^TWriteMemMultiple;

type
  TJLINKARM_RESET_TYPE = ( JLINKARM_RESET_TYPE_NORMAL, JLINKARM_RESET_TYPE_BP0,
    JLINKARM_RESET_TYPE_ADI, JLINKARM_RESET_TYPE_NO_RESET,
    JLINKARM_RESET_TYPE_HALT_WP, JLINKARM_RESET_TYPE_HALT_DBGRQ,
    JLINKARM_RESET_TYPE_SOFT, JLINKARM_RESET_TYPE_HALT_DURING,
    JLINKARM_RESET_TYPE_SAM7, JLINKARM_RESET_TYPE_LPC );

type
  TJLINKARM_CM_RESET_TYPE = ( JLINKARM_CM_RESET_TYPE_NORMAL,
    JLINKARM_CM_RESET_TYPE_CORE, JLINKARM_CM_RESET_TYPE_PIN );

type
  // JLINK_GetSpeedInfo() " %d Hz / n, n >= %d"
  // JLINK_GetSpeedInfo() 48000000 Hz / n, n >= 4
  // JLINK_GetSpeedInfo() 4000000 Hz / n, n >= 1
  TJLINKARM_SpeedInfo = record
    size : DWORD; // 12
    freq : DWORD; // 16,000,000
    nDiv : WORD; // 4
    unused : WORD;
  end;

  TJLINKARM_HWInfo = record
    Info : array [ 0 .. 31 ] of DWORD;
  end;

  TJLINKARM_JTAG_DeviceInfo = record
    Info : array [ 0 .. 3 ] of DWORD;
  end;

  TJLINKARM_Endian = ( ARM_ENDIAN_LITTLE, ARM_ENDIAN_BIG );

  TJLINKARM_HWStatus = record
    VTarget : WORD;
    TCK : Byte;
    TDI : Byte;
    TDO : Byte;
    TMS : Byte;
    TRES : Byte;
    TRST : Byte;
  end;

  TJLINKARM_DeviceMemoryInfo = record
    Base : DWORD;
    size : DWORD;
  end;

  // Total 32 Bytes
  TJLINKARM_IdData = record
    NumDevices : DWORD;
    TotalScanLen : DWORD;
    IDArray : array [ 0 .. 3 ] of DWORD;
    ScanLenArray : array [ 0 .. 3 ] of Byte; // TotalScanLen
    IrReadArray : array [ 0 .. 3 ] of Byte;
    ScanReadArray : array [ 0 .. 3 ] of Byte;
  end;

  PJLINKARM_DeviceInfo = ^TJLINKARM_DeviceInfo;

  TJLINKARM_DeviceInfo = record
    size : DWORD; // 0x228 = 552 Bytes - 4 = 548 Bytes / 4 = 137 DWORDs
    Name : PAnsiChar; // STM32F405VG
    Id : DWORD;
    FlashBase : DWORD;
    SramBase : DWORD;
    Endian : DWORD;
    FlashSize : DWORD;
    SramSize : DWORD;
    ManfName : PAnsiChar; // ST
    Flash : array [ 0 .. 31 ] of TJLINKARM_DeviceMemoryInfo;
    Sram : array [ 0 .. 31 ] of TJLINKARM_DeviceMemoryInfo;
    Family : DWORD; // Cortex-M3
  end;

  PJLINKARM_DeviceInfoEx = ^TJLINKARM_DeviceInfoEx;

  TJLINKARM_DeviceInfoEx = record
    Index : integer;
    // JLINKARM_GetId()
    // JTAG : JLINKARM_GetDeviceId(index), JLINKARM_JTAG_GetDeviceId(index)
    // SWD : JLINKARM_CORE_GetFound()
    Id : DWORD; // $4BA00477<JTAG>, $4BA01477<SWD>
    ManfName : array [ 0 .. 31 ] of AnsiChar; // ST

    // CORTEX-M4 : JLINKARM_Core2CoreName(Family)
    FamilyName : array [ 0 .. 31 ] of AnsiChar;
    Family : DWORD; // $0E0000FF

    Name : array [ 0 .. 63 ] of AnsiChar; // STM32F405RG
    Endian : DWORD; // 0 - Little, 1 - Big

    Flash : TJLINKARM_DeviceMemoryInfo;
    Sram : TJLINKARM_DeviceMemoryInfo;

    FlashBitMap : DWORD;
    SramBitMap : DWORD;
    FlashMap : array [ 0 .. 31 ] of TJLINKARM_DeviceMemoryInfo;
    SramMap : array [ 0 .. 31 ] of TJLINKARM_DeviceMemoryInfo;
  end;

const
  JLINKARM_CoreName : array [ 0 .. 3 ] of string = ( 'Cortex-M0', 'Cortex-M3',
    'Cortex-M4', 'Unknown' );

type
  TJLINKARM_CoreType = ( ctCortexM0, ctCortexM3, ctCortexM4, ctUnknown );

  PJLINKARM_Device = ^TJLINKARM_Device;

  TJLINKARM_Device = record
    ManuafacturerName : string;
    DeviceName : string;
    CoreType : TJLINKARM_CoreType;
    FlashBase : DWORD;
    FlashSize : DWORD;
    SramBase : DWORD;
    SramSize : DWORD;
  end;

  PJLINKARM_DeviceListItem = ^TJLINKARM_DeviceInfoListItem;

  TJLINKARM_DeviceInfoListItem = record
    CoreType : TJLINKARM_CoreType;
    ManuafacturerName : string;
    DeviceName : string;
  end;

  PJLINKARM_DeviceInfoList = ^TJLINKARM_DeviceInfoList;
  TJLINKARM_DeviceInfoList = array of TJLINKARM_DeviceInfoListItem;

  PManuafacturerListItem = ^TJLINKARM_ManuafacturerInfoListItem;

  TJLINKARM_ManuafacturerInfoListItem = record
    ManuafacturerName : string;
    EnabledCount : integer;
    DeviceIndexCapacity : integer;
    DeviceIndexCount : integer;
    DeviceIndexArray : array of integer;
  end;

  PJLINKARM_ManuafacturerInfoList = ^TJLINKARM_ManuafacturerInfoList;
  TJLINKARM_ManuafacturerInfoList = array of
    TJLINKARM_ManuafacturerInfoListItem;

  // TJLINKARM Object **********************************************************
  TJLINKARM = class( TJLINK_Protocol )
  protected
    FUserDeviceName : string;
    FDllOpened : Boolean; // JLINKARM.DLL opened ?
    FDevAttached : Boolean; // MCU powered ?
    FDevConnected : Boolean; // MCU identified ?

    FDeviceInfoCount : integer;
    FManuafacturerInfoCount : integer;
    FDeviceInfoList : TJLINKARM_DeviceInfoList;
    FManuafacturerInfoList : TJLINKARM_ManuafacturerInfoList;

    FDeviceName : AnsiString;
    FDeviceFamily : integer;
    FDeviceEndian : TJLINKARM_Endian;

    FSpeed : integer;
    FInterface : TJLINKARM_Inteface;

    FVTarget : Single;
    FITarget : Single;

    FLogFileName : AnsiString;

    class var FOnLog : TJLINKARM_LogEvent;
    class procedure LogOutCb( strLog : PAnsiChar ); cdecl; static;
    class procedure WarningOutCb( strWarning : PAnsiChar ); cdecl; static;
    class procedure ErrorOutCb( strError : PAnsiChar ); cdecl; static;

    class procedure Log( JLinkLog : TJLINKARM_Log; Info : PAnsiChar );
      overload; static;
    class procedure Log( JLinkLog : TJLINKARM_Log; Info : AnsiString );
      overload; static;

    function QueryInterface( ) : TJLINKARM_Inteface;
    function NextInterface( AInteface : TJLINKARM_Inteface )
      : TJLINKARM_Inteface;

    procedure ExtractFirmwareStr( FirmwareStr : AnsiString;
      var FirmwareName : AnsiString; var FirmwareDate : AnsiString );
    procedure ExtractEmuCapsStrings( EmuCaps : DWORD;
      EmuCapsStrings : TStrings );
    procedure ExtractVersionStr( Version : integer;
      var VersionStr : AnsiString );

  public

    property DllOpened : Boolean read FDllOpened;
    property DeviceAttached : Boolean read FDevAttached;
    property DeviceConnected : Boolean read FDevConnected;

    property DeviceInfoCount : integer read FDeviceInfoCount;
    property ManuafacturerInfoCount : integer read FManuafacturerInfoCount;

    property DeviceInfoList : TJLINKARM_DeviceInfoList read FDeviceInfoList;
    property ManuafacturerInfoList : TJLINKARM_ManuafacturerInfoList
      read FManuafacturerInfoList;

    constructor Create( LogEvent : TJLINKARM_LogEvent = nil;
      LogFileName : AnsiString = ''; AbortEvent : THandle = 0 ); overload;
    destructor Destroy; override;

    function Open( UserDeviceName : string ) : Boolean;
    procedure Close( );

    function GetInformation( Strings : TStringList;
      EmulatorCaps : Boolean = FALSE ) : Boolean;

    function GetDeviceCount( ) : integer;

    function QueryDeviceFamily( DeviceName : string ) : integer;
    function SelectDeviceFamily( hWndParent : HWND;
      var DeviceFamily : integer ) : string;

    function GetDeviceFamily( ) : integer;
    function SetDeviceFamily( DeviceFamily : integer ) : Boolean; overload;
    function SetDeviceFamily( DeviceName : AnsiString ) : Boolean; overload;
    function SetDeviceName( DeviceName : AnsiString ) : Boolean;

    function GetDeviceEndian( ) : TJLINKARM_Endian;
    procedure SetDeviceEndian( DeviceEndian : TJLINKARM_Endian );

    function Family2CoreType( Family : integer ) : TJLINKARM_CoreType;
    function CoreType2Name( CoreType : TJLINKARM_CoreType ) : string;
    procedure GenerateDeviceList( );
    procedure GenerateManuafacturerList( );

    // returnValue <> 0 : failed
    // DeviceIndex = -1, return AvailableDeviceInfoCount
    // DeviceIndex = 0..AvailableDeviceInfoCount-1
    // function JLINKARM_DEVICE_GetInfo( DeviceIndex : integer;
    // var DeviceInfo : TJLINKARM_DeviceInfo ) : integer; cdecl;
    // external 'jlinkarm.dll' name 'JLINKARM_DEVICE_GetInfo' delayed;
    function GetDeviceInfo( DeviceIndex : integer;
      DeviceInfo : PJLINKARM_DeviceInfo ) : integer; overload;

    // returnValue <> 0 : failed
    function GetDeviceInfo( DeviceName : AnsiString;
      DeviceInfo : PJLINKARM_DeviceInfo ) : integer; overload;

    procedure GetDeviceInfoEx( DeviceIndex : integer;
      var DeviceInfo : TJLINKARM_DeviceInfoEx );

    // returnValue <> 0 : failed
    // JLINK_GetSpeedInfo() 4000000 Hz / n, n >= 1
    function GetSpeedInfo( var SpeedInfo : TJLINKARM_SpeedInfo ) : integer;

    // Result = JLINKARM_ExecCommand() = 0 : OK
    // JLINKARM_ExecCommand("Device = STM32F103RE")
    function SelectDevice( DeviceName : AnsiString ) : integer;

    // JTAG --> SWD, Auto --> Max --> Normal ( 1000000 )
    function Attached( ) : Boolean;
    function Connect( AInteface : TJLINKARM_Inteface = jiAuto;
      Speed : integer = JLINKARM_SPEED_AUTO; DeviceName : AnsiString = '' )
      : Boolean;
    procedure Disconnect;

    function GetHwStatus( ) : TJLINKARM_HWStatus;

    function GetInterface( ) : TJLINKARM_Inteface;
    function SetInterface( AInteface : TJLINKARM_Inteface ) : Boolean;

    function GetSpeed( ) : integer;
    function SetSpeed( Speed : integer = JLINKARM_SPEED_AUTO ) : Boolean;
    //
    //
    function ReadReg( RegIndex : DWORD ) : integer;
    function WriteReg( RegIndex : DWORD; RegValue : DWORD ) : integer;
    //
    function ReadByte( Address : DWORD; var AByte : Byte ) : Boolean;
    function ReadWord( Address : DWORD; var AWord : WORD ) : Boolean;
    function ReadDWord( Address : DWORD; var ADWord : DWORD ) : Boolean;
    function ReadQWord( Address : DWORD; var AQWord : UInt64 ) : Boolean;

    // return status is 0 if read success !
    function ReadMemory( Address : DWORD; var Buffer; size : DWORD )
      : Boolean; overload;
    //
    // return size in items
    function ReadMemory( Address : DWORD; var Buffer; Items : DWORD;
      MemoryUnit : TJLINKRAM_MemoryUnit ) : integer; overload;
    //
    // return status is 0 if wrte success !
    function WriteByte( Address : DWORD; AByte : Byte ) : Boolean;
    function WriteWord( Address : DWORD; AWord : WORD ) : Boolean;
    function WriteDWord( Address : DWORD; ADWord : DWORD ) : Boolean;
    function WriteQWord( Address : DWORD; AQWord : UInt64 ) : Boolean;
    //
    // return size has written
    function WriteMemory( Address : DWORD; size : DWORD; const Buffer )
      : integer;

    function Download( FileName : PAnsiChar; Address : DWORD )
      : integer; overload;

    function Download( Address : DWORD; const Buffer; size : DWORD )
      : integer; overload;

    function Reset( Halt : Boolean; ResetDelay : DWORD = 0;
      PulseLen : DWORD = 200;
      ResetType : TJLINKARM_RESET_TYPE = JLINKARM_RESET_TYPE_NORMAL ) : Boolean;
    function IsHalted( ) : Boolean;
    function Halt( ) : Boolean;
    function Go( ) : Boolean;
    function GoIntDis( ) : Boolean;

    function ExecuteCodeCM( Address : DWORD; size : DWORD; Code : PDWORD )
      : Boolean; overload;
    function ExecuteCodeCM( Address : DWORD; size : DWORD;
      FileName : PAnsiChar ) : Boolean; overload;

  end;

function JLINK_Configure( param : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_Configure' delayed;

// JLINK Functions *************************************************************

function JLINK_EraseChip( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EraseChip' delayed;

// Result = 5 : 'RDI,FlashBP,FlashDL,JFlash,GDB'#0
function JLINK_GetAvailableLicense( Licenses : PAnsiChar; MaxSize : integer )
  : integer; stdcall;
  external 'jlinkarm.dll' name 'JLINK_GetAvailableLicense' delayed;

function JLINK_EMU_GPIO_GetProps( param : integer; param1 : integer ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINK_EMU_GPIO_GetProps' delayed;

function JLINK_EMU_GPIO_GetState( param : integer; param1 : integer;
  param2 : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_GPIO_GetState' delayed;

function JLINK_EMU_GPIO_SetState( param : integer; param1 : integer;
  param2 : integer; param3 : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_GPIO_SetState' delayed;

// JLINKARM Functions **********************************************************
//
function JLINKARM_Test( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Test' delayed;

// User Select one device, return index in database
function JLINKARM_DEVICE_SelectDialog( hWndParent : HWND ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_DEVICE_SelectDialog' delayed;

// STM32F405VG --> index in database
// Result = -1 : invalid device name
function JLINKARM_DEVICE_GetIndex( DeviceName : PAnsiChar ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_DEVICE_GetIndex' delayed;

function JLINKARM_HasError( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_HasError' delayed;

function JLINKARM_ClrError( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_HasError' delayed;

function JLINKARM_SetLogFile( FileName : PAnsiChar ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetLogFile' delayed;

function JLINKARM_EnableLog( JLINKARM_LogOutCb : TJLINKARM_LogOutCb ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_EnableLog' delayed;

function JLINKARM_SetWarnOutHandler( JLINKARM_WarningOutCb
  : TJLINKARM_WarningOutCb ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetWarnOutHandler' delayed;

function JLINKARM_SetErrorOutHandler( JLINKARM_ErrorOutCb
  : TJLINKARM_WarningOutCb ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetErrorOutHandler' delayed;

// Connect to J-Link via USB
// Port : 0..3
// Return 0 success else failed
function JLINKARM_SelectUSB( Port : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SelectUSB' delayed;

// Connect to J-Link ARM Pro or J-Link TCP/IP Server via TCP/TP
// Default Port = 19020
function JLINKARM_SelectIP( HostName : PAnsiChar; Port : integer ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_SelectIP' delayed;

// JLINKARM Information Functions **********************************************
//
// JLINK_GetDLLVersion() : 47400 : 4.74
// JLINK_GetDLLVersion() : 49005 : 4.90e
// JLINK_GetDLLVersion() : 49999 : 4.99z73
function JLINKARM_GetDLLVersion( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetDLLVersion' delayed;

// Sep  8 2014 18:46:31
function JLINKARM_GetCompileDateTime( ) : PAnsiChar; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetCompileDateTime' delayed;

// Retrieves the firmware version.
// JLINK_GetFirmwareString(...)
// Firmware: J-Link ARM-OB STM32 compiled Aug 22 2012 19:52:04
// Firmware: J-Link V9 compiled Nov 29 2013 19:55:47
function JLINKARM_GetFirmwareString( FirmwareString : PAnsiChar;
  MaxSize : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetFirmwareString' delayed;

// call JLINKARM_GetFirmwareString
// ATMEL, Analog Devices, DIGI, SEGGER, IAR
//
// J-Link ARM, J-Link CF, J-Link CE, J-Link EDU, J-Link KS,
// J-Link ARM Pro, J-Link Ultra
// J-Link ARM Lite, J-Link Lite-Cortex-M, J-Link Lite-LPC, J-Link Lite-STM32
// J-Link Lite-FSL, J-Link Lite-ADI, J-Link Lite-XMC4000, J-Link Lite-XMC4200
// J-Link LPC-Link 2, Energy Micro EMF32
// J-Link OB RX200 V1, J-Link OB-SAM3U128,
// JTAG-Link, mIDAS-Link, SAM-ICE,
// J-Trace ARM, J-Trace CS,
// Flasher ARM, Flasher PRO, Flasher PPC, Flasher RX
function JLINKARM_EMU_GetProductName( Name : PAnsiChar; size : integer )
  : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_EMU_GetProductName' delayed;

// Buffer must be larger to place OEMString
function JLINKARM_GetOEMString( OEMString : PAnsiChar ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetOEMString' delayed;

function JLINKARM_GetSN( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetSN' delayed;

// Buffer must be larger to place FeatureString
// FeatureString0, FeatureString1, FeatureStringN[0x00]
function JLINKARM_GetFeatureString( FeatureString : PAnsiChar ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_GetFeatureString' delayed;

// J-Link V9 compiled Sep  5 2014 18:54:08
// ********** Compare, return EmbeddedFWString from .dll
function JLINKARM_GetEmbeddedFWString( FWString : PAnsiChar;
  EmbeddedFWString : PAnsiChar; size : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetEmbeddedFWString' delayed;

// 12005 --> '1.20e'
function JLINKARM_GetEmbeddedFWVersion( ) : WORD; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetEmbeddedFWVersion' delayed;

// Retrieves the hardware version of the emulator.
// JLINK_GetHardwareVersion()  returns 0x11170 = 70000 : Hardware: V7.00
// JLINK_GetHardwareVersion()  returns 0x13880 = 80000 : Hardware: V8.00
// JLINK_GetHardwareVersion()  returns 0x15F90 = 90000 : Hardware: V9.00
function JLINKARM_GetHardwareVersion( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetHardwareVersion' delayed;

// Retrieves capabilities of the emulator
function JLINKARM_GetEmuCaps( ) : DWORD; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetEmuCaps' delayed;

// Retrieves capabilities (including extended ones) of the emulator.
// BF 7B FF B9 0D 7C B1 03 00 00 00 00 .. 00 00 00 00 : Max 64 Bytes
// **EmuCaps**
function JLINKARM_GetEmuCapsEx( Caps : PAnsiChar; MaxSize : integer ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_GetEmuCapsEx' delayed;

// extern String JLINKARM_Open();
function JLINKARM_Open( ) : PAnsiChar; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Open' delayed;

// return string : Failed to open DLL
// NULL success else failed
function JLINKARM_OpenEx( JLINKARM_LogOutCb : TJLINKARM_LogOutCb;
  JLINKARM_ErrorOutCb : TJLINKARM_ErrorOutCb ) : PAnsiChar; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_OpenEx' delayed;

// extern void JLINKARM_Close()
// == 0 after JLINKARM_Open() or JLINKARM_OpenEx()
function JLINKARM_Close( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Close' delayed;

// <> 0 after JLINKARM_Open() or JLINKARM_OpenEx()
// Dont care whether the target is present or not
function JLINKARM_IsOpen( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_IsOpen' delayed;

// JLINKARM_ExecCommand() can be called after JLINKARM_IsOpen() = TRUE
// "ProjectFile = Driver:\path\file.jlink" -- IAR
// "ProjectFile = Driver:\path\file.ini" -- KEIL
// "device = STM32F103xE"
// "Device = STM32F107VC"
// "map ram 0x20000000 - 0x20004FFF"
// "SetResetType = 0"
// "SetResetPulseLen = 200"
// Buffer = nil : MaxSize = 256 in stack
function JLINKARM_ExecCommand( Command : PAnsiChar; Buffer : PByte;
  size : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ExecCommand' delayed;

// Result == 0x00 : Success
// [ VTargetLow VTargetHigh TCK TDI TDO TMS TRES TRST ]
function JLINKARM_GetHWStatus( var HWStatus : TJLINKARM_HWStatus ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_GetHWStatus' delayed;

// returnValue <> 0 : failed
// mask = 0x00000004 : 4 bytes buffer for ITarget mA
// HWInfo[00] = Target power is disabled
// HWInfo[02] = 0mA (ITarget)
// HWInfo[03] = 0mA (ITargetPeak)
// HWInfo[04] = 0mA (ITargetPeakOperation)
// HWInfo[10] = 0ms (ITargetMaxTime0)
// HWInfo[11] = 0ms (ITargetMaxTime1)
// HWInfo[12] = 0ms (ITargetMaxTime2)
// HWInfo[13] = 0x00000000
// HWInfo[27] = 0x00000000
// HWInfo[28] = 0x00000000
function JLINKARM_GetHWInfo( Mask : DWORD; var HWInfo : TJLINKARM_HWInfo )
  : integer; cdecl; external 'jlinkarm.dll' name 'JLINKARM_GetHWInfo' delayed;

// -----------------------------------------------------------------------------
// Result ==  0 : Connect to target : JLINKARM_IsConnected()
// Result >=  1 : Could not connect to target
// Result == -1 : OpenEx Failed
// Result == -259 : VTarget too low < 1.0V
// (1) VTarget be checked
// (2) Check if other debugger has connected, if no debugger connected
// -------- Select gCurrentInterface, Set Default Speed
// (3) Try to Connect and Find Core and Family
function JLINKARM_Connect( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Connect' delayed;

// Result >  0 : the target is already identified
// Result == 0 : the target is not identified, bue maybe present
function JLINKARM_IsConnected( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_IsConnected' delayed;

// -----------------------------------------------------------------------------
// For Both JTAG and SWD
//
// Device ID Code Register :
// 0BA01477 :
// 1BA01477 : early Sandstorm parts, Cortex-M3 r1p1, STM32F103RE
// 2BA00477 : later SandStorm parts, e.g. lm3s811 Rev C2
// 3BA01477 : Cortex-M3 r1p2 (on Fury, DustDevil)
// 4BA00477 : Cortex-M3 r2p0 (on Tempest), Cortex-M4 r0p1
// ____*___ : Bit 12 : 0 = JTAG, 1 = SWD
//
// Version[31..28] : JTAG-DP : 4,       SW-DP : 2
// PartNum[27..12] : JTAG-DP : 0xBA00   SW-DP : 0xBA01
// ManfVal[11...8] : JEDEC Manufacturer ID, Continuation Code : 0x02
// ManfVal[7....1] : JEDEC Manufacturer ID, Identify Code : 0x3B
// Reserve[0]      : Always 1
//
// Get First Device Id ?
// JTAG Device ID Code Register
// 31...28  27....12  11.....1  0
// Version  Part No.  Manuf ID  1
// 3        BA0*      476       1 :  3BA0*477
// 23B - ARM
//
// 00000000
//
// 1F0F0F0F -- ARM7TDMI
//
// 07C1C01D
// 07E0E01D
//
// 3100E02F
// 3F0F0F0F
//
// 4F1F0041
//
// 04570041 -- STR912 Flash
// 1457f041 -- STR912 BS A1
// 2457f041 -- STR912 BS A2
// 25966041 -- STR912 CPU
//
// 05946041 -- STA8088F
// 0792603F -- ARM9
// 0B6D602F -- OMAP3630
//
// 0BB1*477
// 0BC1*477
//
// 0BA0*477
// 1BA0*477
// 2BA0*477
// 3BA0*477
// 4BA0*477
//
// LM3S301 RevB (Sandstorm class) silicon : 0x1BA00477 (r0p1 core)
// LM3S301 RevC (Sandstorm class) silicon : 0x2BA00477 (r1p0 core)
// LM3S301 RevA (Fury class) silicon : 0x3BA00477 (r1p1 core)
//
function JLINKARM_GetId( ) : DWORD; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetId' delayed;

// Get Devices Id Data : NumDevices, IdArray[NumDevices], etc.
function JLINKARM_GetIdData( var IdData : TJLINKARM_IdData ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetIdData' delayed;
// -----------------------------------------------------------------------------
// Result == 0 : No Core found, JLINKARM_TIF_Select(0)
// Result >  0 : Core found by JLINKARM_Connect()
function JLINKARM_CORE_GetFound( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_CORE_GetFound' delayed;

// -----------------------------------------------------------------------------
// JLINKARM : Family
// Family[31..24]   [23..16]   [15..8]   [7..4] [3..0]
// ______ARM7, RX   TDMI       -S, JF-S  Rev    Patch
//
// 00000000 -- None
//
// 010000FF -- Cortex-M1
//
// 020000FF -- Coldfire
//
// 030000FF -- Cortex-M3
//
// 060000FF -- Cortex-M0
//
// 070000FF -- ARM7TDMI
// 070001FF -- ARM7TDMI-S
// 07FFFFFF -- ARM7
//
// 080000FF -- Cortex-A8
// 080900FF -- Cortex-A9
// 080B00FF -- Cortex-A15
//
// 092601FF -- ARM926EJ-S
// 094601FF -- ARM946E-S
// 096601FF -- ARM966E-S
// 09FFFFFF -- ARM9
//
// 0C0000FF -- Cortex-R4, 0C0100FF -- Cortex-R5,
//
// 0E0000FF -- Cortex-M4
//
// 10FF00FF -- PowerPC (Nexus 1)
// 10FF01FF -- PowerPC (Nexus 2)
//
// CoreFound = JLINKARM_CORE_GetFound( )
// TJLINKARM_DeviceInfo.Family --> Cortex-M4
//
// ARM7
// ARM7TDMI
// ARM7TDMI-S
//
// ARM9
// ARM920T
// ARM926EJ-S
// ARM946E-S
// ARM966E-S
// ARM968E-S
//
// ARM11
//
// Cortex-M0
// Cortex-M1
// Cortex-M3
// Cortex-M4
//
// Cortex-R4
// Cortex-R5
//
// Cortex-A5
// Cortex-A7
// Cortex-A8
// Cortex-A9
// Cortex-A12
// Cortex-A15
// Cortex-A17
//
// MIPS
//
// PowerPC (Nexus 1)
// PowerPC (Nexus 2+)
//
// RX
// RX111
// RX210
// RX610
// RX62N
// RX62T
// RX630
// RX63N
// RX63T
function JLINKARM_Core2CoreName( Core : integer; JLINKARM_CoreName : PAnsiChar;
  MaxSize : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Core2CoreName' delayed;

// JLINKARM_CORE_Select()
function JLINKARM_CORE_Select( Core : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_CORE_Select' delayed;

// -----------------------------------------------------------------------------
// For JTAG only
// if ( CurrentInterface == JTAG ) { ... }
//
// JLINKARM_GetId( ) : Get First Device Id ?
//
// call JLINKARM_JTAG_GetDeviceId()
// The device closest to TDO has index 0.
function JLINKARM_GetDeviceId( DeviceIndex : integer ) : DWORD; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetDeviceId' delayed;
//
// called by JLINK_JTAG_GetDeviceId() and JLINKARM_GetDeviceId()
// if ( CurrentInterface == JTAG ) { ... }
function JLINKARM_JTAG_GetDeviceId( DeviceIndex : integer ) : DWORD; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_JTAG_GetDeviceId' delayed;
//
function JLINKARM_ConfigJTAG( IRPre : integer; DRPre : integer ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_ConfigJTAG' delayed;

// called by JLINK_JTAG_GetDeviceInfo()
// if ( CurrentInterface == JTAG ) { ... }
function JLINKARM_JTAG_GetDeviceInfo( DeviceIndex : integer;
  var DeviceInfo : TJLINKARM_JTAG_DeviceInfo ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_JTAG_GetDeviceInfo' delayed;

// maxDeviceCount : 10
// dwSizeInBytes0 : dwParam0 : dwParam1 : dwParam2 : dwParam3_18[16] : 20 DWORDs
// dwSizeInBytes1 : dwParam0 : dwParam1 : dwParam2 : dwParam3_18[16] : 20 DWORDs
function JLINKARM_JTAG_ConfigDevices( DeviceCount : integer; var pConfigDatas )
  : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_JTAG_ConfigDevices' delayed;

function JLINK_EMU_IsConnected( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_IsConnected' delayed;

function JLINK_EMU_GetNumConnections( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_GetNumConnections' delayed;

// Devices in JTAG
function JLINK_EMU_GetNumDevices( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_GetNumDevices' delayed;

function JLINK_EMU_GetProductId( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_GetProductId' delayed;

function JLINK_EMU_HasCPUCap( Mask : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_HasCPUCap' delayed;

function JLINK_EMU_HasCapEx( Mask : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_EMU_HasCapEx' delayed;

// -----------------------------------------------------------------------------
// JLINKARM_CORE_GetFound( ) for SWD OK
// -- JLINKARM_GetDeviceFamily( ) : JLINKARM_CORE_GetFound( ) >> 24
// Result == 0x00 : None
//
function JLINKARM_GetDeviceFamily( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetDeviceFamily' delayed;

// 3:Cortex-M3 / 5:XScale / 7:ARM7 / 9:ARM9 / 11:ARM11
// Result == 0x00 : OK
function JLINKARM_SelectDeviceFamily( DeviceFamily : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SelectDeviceFamily' delayed;

function JLINKARM_SelDevice( Device : WORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SelDevice' delayed;

// -----------------------------------------------------------------------------
// 0 : ARM_ENDIAN_LITTLE
// 1 : ARM_ENDIAN_BIG
// return previous Identified Endian
function JLINKARM_SetEndian( NewEndian : TJLINKARM_Endian ) : TJLINKARM_Endian;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_SetEndian' delayed;

// Speed Functions *************************************************************
//
// 0xFFFFFFEC : Auto -- JTAG and SWD
// 0x0000FFFF : Adaptive -- only for JTAG
// Result = 1 : OK
function JLINKARM_SetSpeed( jlink_speed : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetSpeed' delayed;
// Result = 1 : OK
function JLINKARM_SetMaxSpeed( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetMaxSpeed' delayed;
// 0xFFFF : Adaptive -- only for JTAG
// Other  : Speed in KHz
function JLINKARM_GetSpeed( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetSpeed' delayed;

// Interface Functions *********************************************************
//
function JLINKARM_TIF_GetAvailable( var Available ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_TIF_GetAvailable' delayed;

// JLINK_TIF_Select(JLINKARM_TIF_SWD)  returns 0x00
// Result = 0 : OK
// --- InterfaceIndex == -1 : select Available[lsb], JTAG at first
// --- InterfaceIndex != -1 : select JTAG or SWD
// Result = 1 : Error
function JLINKARM_TIF_Select( InterfaceIndex : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_TIF_Select' delayed;

function JLINKARM_SWO_Control( Control : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_TIF_Select' delayed;

function JLINKARM_SWO_GetCompatibleSpeeds( var CPISpeed; var MaxSWOSpeed;
  Buffer : Pointer; var NumEntries ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SWO_GetCompatibleSpeeds' delayed;

function JLINKARM_SWO_Read( const Unknown; Offset : DWORD; NumBytes : DWORD )
  : integer; cdecl; external 'jlinkarm.dll' name 'JLINKARM_SWO_Read' delayed;

// Reset Functions *************************************************************
//
// JLINK_ExecCommand("SetResetType = 0")
// JLINKARM_RESET_TYPE_NORMAL = 0, and so on ...
// Result : ResetType before set
function JLINKARM_SetResetType( ResetType : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetResetType' delayed;

// Result : ResetPara before set
function JLINKARM_SetResetPara( ResetDelay : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetResetPara' delayed;

// Result = 1 : OK
function JLINK_ResetPullsRESET( OnNotOff : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_ResetPullsRESET' delayed;

// Result > 0 : OK
function JLINKARM_SetResetDelay( ResetDelay : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_SetResetDelay' delayed;

// JLINK_ExecCommand("SetResetPulseLen = 200"
// JLINKARM_SetResetPulseLen()

// JLINK_ResetPullsTRST(OFF)
// JLINK_ResetPullsRESET(ON)

// JLINKARM_Reset then JLINKARM_Halt
// Result = 0 : OK
function JLINKARM_Reset( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Reset' delayed;

// JLINKARM_Reset then JLINKARM_Go
// Result = 0 : OK
function JLINKARM_ResetNoHalt( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ResetNoHalt' delayed;

// Go and Halt Functions *******************************************************
//
// Result <> 0 : OK
function JLINKARM_Halt( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Halt' delayed;

function JLINKARM_IsHalted( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_IsHalted' delayed;

// Result = 0 : OK
function JLINKARM_Go( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_Go' delayed;

// Result = 0 : OK
function JLINKARM_GoEx( param1 : integer; param2 : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GoEx' delayed;

// Result = 0 : OK
function JLINKARM_GoIntDis( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GoIntDis' delayed;

// Step Execute ?
function JLINKARM_GoHalt( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GoHalt' delayed;

// Memory and Register Functions ***********************************************
//
function JLINKARM_ReadCodeMem( memaddr : DWORD; size : DWORD; var buff )
  : integer; cdecl; external 'jlinkarm.dll' name 'JLINKARM_ReadCodeMem' delayed;

// return status is 0 if read success !
function JLINKARM_ReadMem( memaddr : DWORD; size : DWORD; var buff ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_ReadMem' delayed;

// return status -- HW means JTAG/SWD ?
function JLINKARM_ReadMemHW( memaddr : DWORD; size : DWORD; var buff )
  : integer; cdecl; external 'jlinkarm.dll' name 'JLINKARM_ReadMemHW' delayed;

// AccessWidth : Alignment = 1 : JLINKARM_ReadMemU8
// return size
function JLINKARM_ReadMemEx( memaddr : DWORD; size : DWORD; var buff;
  Alignment : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadMemEx' delayed;

// return Items
function JLINKARM_ReadMemU8( memaddr : DWORD; Items : DWORD; var buff;
  Status : PDWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadMemU8' delayed;

// size in U16, not U8, return Items
function JLINKARM_ReadMemU16( memaddr : DWORD; Items : DWORD; var buff;
  Status : PDWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadMemU16' delayed;

// extern uint JLINKARM_ReadMemU32(uint Addr, uint NumBytes,
// [Out] IntPtr pData, [Out] IntPtr pStatus)
// size in U32, not U8, return Items
function JLINKARM_ReadMemU32( memaddr : DWORD; Items : DWORD; var buff;
  Status : PDWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadMemU32' delayed;

// size in U64, not U8, return Items
function JLINKARM_ReadMemU64( memaddr : DWORD; Items : DWORD; var buff;
  Status : PDWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadMemU64' delayed;

// extern int JLINKARM_WriteMem(uint Addr, uint NumBytes, IntPtr pData)
// return size has written
function JLINKARM_WriteMem( memaddr : DWORD; size : DWORD; const buff )
  : integer; cdecl; external 'jlinkarm.dll' name 'JLINKARM_WriteMem' delayed;

function JLINKARM_WriteMemDelayed( memaddr : DWORD; size : DWORD; const buff )
  : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteMemDelayed' delayed;

// return size has written
function JLINKARM_WriteMemHW( memaddr : DWORD; size : DWORD; const buff )
  : integer; cdecl; external 'jlinkarm.dll' name 'JLINKARM_WriteMemHW' delayed;

// return size has written
function JLINKARM_WriteMemEx( memaddr : DWORD; size : DWORD; const buff;
  Alignment : integer ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteMemEx' delayed;

// return size has written last
function JLINKARM_WriteMemMultiple( WriteMemMultiple : PWriteMemMultiple;
  Multiple : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteMemMultiple' delayed;

// return status is 0 if wrte success !
function JLINKARM_WriteU8( memaddr : DWORD; data : Byte ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteU8' delayed;
// return status is 0 if wrte success !
function JLINKARM_WriteU16( memaddr : DWORD; data : WORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteU16' delayed;
// return status is 0 if wrte success !
function JLINKARM_WriteU32( memaddr : DWORD; data : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteU32' delayed;
// return status is 0 if wrte success !
function JLINKARM_WriteU64( memaddr : DWORD; data : UInt64 ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteU64' delayed;

function JLINKARM_GetRegisterName( RegIndex : DWORD ) : PAnsiChar; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetRegisterName' delayed;

function JLINKARM_ReadReg( RegIndex : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadReg' delayed;

function JLINKARM_WriteReg( RegIndex : DWORD; RegValue : DWORD ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_WriteReg' delayed;

function JLINKARM_ReadEmu( var Buffer; Count : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadEmu' delayed;
function JLINKARM_WriteEmu( const Buffer; Count : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteEmu' delayed;

function JLINKARM_ReadEmuConfigMem( var Buffer; Offset : DWORD; Count : DWORD )
  : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_ReadEmuConfigMem' delayed;
function JLINKARM_WriteEmuConfigMem( const Buffer; Offset : DWORD;
  Count : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_WriteEmuConfigMem' delayed;

// Download Functions **********************************************************
//
// JLink commander : loadbin filename, addr
// JLink commander : loadfile filename [addr]
// *.mot, *.srec, *.s19, *.s, *.hex, *.bin, *.raw
//
// Result >= 0 : OK
// -255 : Error while programming flash: Comparing flash contens failed
// -266 : Error while programming flash: Programming failed
// -267 : Error while programming flash: Verify failed
// -268 : Failed to open file
// -269 : File is of unknown / supported format
// -270 : Writing target memory failed < RAM ? >
// else : Unspecified error
function JLINK_DownloadFile( FileName : PAnsiChar; Address : DWORD ) : integer;
  stdcall; external 'jlinkarm.dll' name 'JLINK_DownloadFile' delayed;

function JLINKARM_DownloadECode( FileName : PAnsiChar; Address : DWORD )
  : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_DownloadECode' delayed;
function JLINKARM_ExecECode( FileName : PAnsiChar; Address : DWORD ) : integer;
  cdecl; external 'jlinkarm.dll' name 'JLINKARM_ExecECode' delayed;

// Flags = 0x00, 0x03 ?
// Setup, Halt ... etc. ?
// Result >= 0 : OK
function JLINKARM_BeginDownload( Flags : DWORD ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINK_BeginDownload' delayed;
// JLINK_WriteMem( ... )
// Result >= 0 : OK
function JLINKARM_EndDownload( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_EndDownload' delayed;

// JLINK_UpdateFirmware() --- OBSOLETE, NO FUNCTION
function JLINKARM_UpdateFirmware( ) : SmallInt; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_UpdateFirmware' delayed;

// result == 0 : FAILED
// Update : DLL --> Emulator if ( Emulator < DLL )
function JLINKARM_UpdateFirmwareIfNewer( ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_UpdateFirmwareIfNewer' delayed;

// FirmwareString : JLINKARM_GetFirmwareString()
// Replace : DLL --> Emulator always ?
// Update : DLL --> Emulator if ( Emulator < DLL )
function JLINKARM_UpdateReplaceFirmware( ReplaceNotUpdate : integer;
  FirmwareString : PAnsiChar ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_UpdateReplaceFirmware' delayed;

function JLINK_RTTERMINAL_Control( param0 : integer; param1 : PAnsiChar )
  : integer; stdcall;
  external 'jlinkarm.dll' name 'JLINK_RTTERMINAL_Control' delayed;

// Result = 0 : OK
function JLINK_RTTERMINAL_Read( Index : integer; Buffer : PAnsiChar;
  size : integer ) : integer; stdcall;
  external 'jlinkarm.dll' name 'JLINK_RTTERMINAL_Read' delayed;

// Result = 0 : OK
function JLINK_RTTERMINAL_Write( Index : integer; Buffer : PAnsiChar;
  size : integer ) : integer; stdcall;
  external 'jlinkarm.dll' name 'JLINK_RTTERMINAL_Write' delayed;

// returnValue <> 0 : failed
// DeviceIndex = -1, return AvailableDeviceInfoCount
// DeviceIndex = 0..AvailableDeviceInfoCount-1
function JLINKARM_DEVICE_GetInfo( DeviceIndex : integer;
  DeviceInfo : PJLINKARM_DeviceInfo ) : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_DEVICE_GetInfo' delayed;

// returnValue <> 0 : failed
// JLINK_GetSpeedInfo() 4000000 Hz / n, n >= 1
function JLINKARM_DLL_GetSpeedInfo( var SpeedInfo : TJLINKARM_SpeedInfo )
  : integer; cdecl;
  external 'jlinkarm.dll' name 'JLINKARM_GetSpeedInfo' delayed;

function JLINKARM_IsFound( ) : Boolean;

implementation

uses
  uUtility;

function JLINKARM_IsFound( ) : Boolean;
const
  JLinkRegKey = HKEY_CURRENT_USER;
  JLinkRegPath : string = 'Software\SEGGER\J-Link';
  JLinkArmDllName : string = 'JLINKARM.DLL';

  AppRegKey = HKEY_LOCAL_MACHINE;
  AppRegPath : string = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths';
var
  hRegKey : HKEY;
  iType : DWORD;
  iSize : DWORD;
  iTotalSize : DWORD;
  pBuffer : PByte;
  AppExeName : string;
  AppExePathName : string;
  JLinkPath : string;
  JLinkPathName : string;
  CurrentVersion : DWORD; // 4.92 : 49200 : 0xC030
  AppRegPathName : string;
begin
  Result := FALSE;
  AppExePathName := Application.ExeName;
  AppExeName := ExtractFileName( AppExePathName );
  AppRegPathName := AppRegPath + '\' + AppExeName;

  if ( RegOpenKeyEx( JLinkRegKey, PChar( JLinkRegPath ), 0, KEY_QUERY_VALUE,
    hRegKey ) = ERROR_SUCCESS ) then
  begin
    try
      iType := REG_SZ;
      if ( RegQueryValueEx( hRegKey, 'InstallPath', nil, @iType, nil, @iSize )
        = ERROR_SUCCESS ) then
      begin
        SetLength( JLinkPath, iSize );
        RegQueryValueEx( hRegKey, 'InstallPath', nil, @iType,
          PByte( JLinkPath ), @iSize );
        iSize := Pos( AnsiChar( #0 ), JLinkPath );
        Dec( iSize );
        SetLength( JLinkPath, iSize );
        JLinkPathName := JLinkPath + JLinkArmDllName;
        if FileExists( JLinkPathName ) then
        begin
          iType := REG_DWORD;
          if ( RegQueryValueEx( hRegKey, 'CurrentVersion', nil, @iType,
            PByte( @CurrentVersion ), @iSize ) = ERROR_SUCCESS ) then
          begin
            // if CurrentVersion = 49200 then
            begin
              Result := True;
            end;
          end;
        end;
      end;
    finally
      RegCloseKey( hRegKey );
    end;
  end;

  if not Result then
    MessageBox( 0, 'Can not find JLinkARM.dll.', 'Segger RTT', MB_ICONERROR )
  else
  begin
    { Open or Create the registry key }
    if ( RegOpenKeyEx( AppRegKey, PChar( AppRegPathName ), 0, KEY_QUERY_VALUE,
      hRegKey ) <> ERROR_SUCCESS ) then
      RegCreateKey( AppRegKey, PChar( AppRegPathName ), hRegKey );

    {
      RegSetValueEx( hRegKey, nil, 0, REG_SZ, PChar( AppExePathName ),
      Length( AppExePathName ) * sizeof( Char ) );
    }

    { C:\Program Files (x86)\SEGGER }
    { C:\Program Files (x86)\SEGGER\ }
    RegSetValueEx( hRegKey, PChar( 'Path' ), 0, REG_SZ, PChar( JLinkPath ),
      ( Length( JLinkPath ) - 0 ) * sizeof( Char ) );

    RegCloseKey( hRegKey );
  end;
end;

{ TJLINKARM }

function TJLINKARM.CoreType2Name( CoreType : TJLINKARM_CoreType ) : string;
begin
  Result := JLINKARM_CoreName[ Ord( CoreType ) ];
end;

function TJLINKARM.Family2CoreType( Family : integer ) : TJLINKARM_CoreType;
begin
  Result := ctUnknown;
  if Family shr 24 = 3 then
    Result := ctCortexM3
  else if Family shr 24 = 6 then
    Result := ctCortexM0
  else if Family shr 24 = 14 then
    Result := ctCortexM4
end;

procedure TJLINKARM.GenerateDeviceList( );
var
  I : integer;
  DeviceInfo : TJLINKARM_DeviceInfo;
  CoreType : TJLINKARM_CoreType;
begin
  FDeviceInfoCount := GetDeviceInfo( -1, nil );
  SetLength( FDeviceInfoList, FDeviceInfoCount );
  for I := 0 to FDeviceInfoCount - 1 do
  begin
    GetDeviceInfo( I, @DeviceInfo );
    if 'Unspecified' = DeviceInfo.ManfName then
      Continue;

    CoreType := Family2CoreType( DeviceInfo.Family );
    if CoreType = ctUnknown then
      Continue;

    FDeviceInfoList[ I ].CoreType := CoreType;
    FDeviceInfoList[ I ].DeviceName := string( DeviceInfo.Name );
    FDeviceInfoList[ I ].ManuafacturerName := string( DeviceInfo.ManfName );
  end;

end;

// JLink Commander : Export Device List, Get Manuafacturer Count
procedure TJLINKARM.GenerateManuafacturerList( );
const
  DEFAULT_MANUAFACTURER_COUNT : integer = 64;
  DEFAULT_DEVICE_COUNT : integer = 128;
var
  I : integer;
  CoreType : TJLINKARM_CoreType;
  SearchText : string;
  ManuafacturerName : string;

  ManuafacturerInfoIndex : integer;
  ManuafacturerInfoListCapacity : integer;
begin
  GenerateDeviceList( );

  FManuafacturerInfoCount := 0;
  ManuafacturerInfoIndex := 0;
  ManuafacturerInfoListCapacity := DEFAULT_MANUAFACTURER_COUNT;
  SetLength( FManuafacturerInfoList, ManuafacturerInfoListCapacity );
  for I := 0 to ManuafacturerInfoListCapacity - 1 do
    FManuafacturerInfoList[ I ].ManuafacturerName := '';

  for I := 0 to Length( FDeviceInfoList ) - 1 do
  begin
    ManuafacturerName := FDeviceInfoList[ I ].ManuafacturerName;
    if ManuafacturerName = '' then
      Continue;

    for ManuafacturerInfoIndex := 0 to FManuafacturerInfoCount - 1 do
    begin
      if ManuafacturerName = //
        FManuafacturerInfoList[ ManuafacturerInfoIndex ].ManuafacturerName then
        break;
    end;

    // Need add ManuafacturerName to FManuafacturerInfoList
    if ManuafacturerInfoIndex > FManuafacturerInfoCount - 1 then
    begin
      ManuafacturerInfoIndex := FManuafacturerInfoCount;
      Inc( FManuafacturerInfoCount );

      if ManuafacturerInfoIndex = ManuafacturerInfoListCapacity then
      begin
        ManuafacturerInfoListCapacity := ManuafacturerInfoListCapacity * 2;
        SetLength( FManuafacturerInfoList, ManuafacturerInfoListCapacity );
      end;

      FManuafacturerInfoList[ ManuafacturerInfoIndex ] := FManuafacturerInfoList
        [ ManuafacturerInfoIndex ];
      FManuafacturerInfoList[ ManuafacturerInfoIndex ].ManuafacturerName :=
        ManuafacturerName;
      FManuafacturerInfoList[ ManuafacturerInfoIndex ].DeviceIndexCount := 0;
      FManuafacturerInfoList[ ManuafacturerInfoIndex ].DeviceIndexCapacity :=
        DEFAULT_DEVICE_COUNT;
      SetLength( FManuafacturerInfoList[ ManuafacturerInfoIndex ]
        .DeviceIndexArray, FManuafacturerInfoList[ ManuafacturerInfoIndex ]
        .DeviceIndexCapacity );
    end;

    with FManuafacturerInfoList[ ManuafacturerInfoIndex ] do
    begin
      if DeviceIndexCount = DeviceIndexCapacity then
      begin
        DeviceIndexCapacity := DeviceIndexCapacity * 2;
        SetLength( DeviceIndexArray, DeviceIndexCapacity );
      end;

      DeviceIndexArray[ DeviceIndexCount ] := I;
      Inc( DeviceIndexCount );
    end;
  end;

  SetLength( FManuafacturerInfoList, FManuafacturerInfoCount );
  for I := 0 to FManuafacturerInfoCount - 1 do
  begin
    FManuafacturerInfoList[ I ].DeviceIndexCapacity := //
      FManuafacturerInfoList[ I ].DeviceIndexCount;
    SetLength( FManuafacturerInfoList[ I ].DeviceIndexArray,
      FManuafacturerInfoList[ I ].DeviceIndexCount );
  end;
end;

function TJLINKARM.GetDeviceInfo( DeviceIndex : integer;
  DeviceInfo : PJLINKARM_DeviceInfo ) : integer;
begin
  if DeviceInfo <> nil then
    DeviceInfo.size := sizeof( TJLINKARM_DeviceInfo );
  Result := JLINKARM_DEVICE_GetInfo( DeviceIndex, DeviceInfo );
end;

// returnValue <> 0 : failed
function TJLINKARM.GetDeviceInfo( DeviceName : AnsiString;
  DeviceInfo : PJLINKARM_DeviceInfo ) : integer;
var
  DeviceIndex : integer;
begin
  DeviceIndex := JLINKARM_DEVICE_GetIndex( PAnsiChar( DeviceName ) );
  if DeviceIndex = -1 then
    Exit( -1 );
  Result := GetDeviceInfo( DeviceIndex, DeviceInfo );
end;

// returnValue <> 0 : failed
// JLINK_GetSpeedInfo() 4000000 Hz / n, n >= 1
function TJLINKARM.GetSpeedInfo( var SpeedInfo : TJLINKARM_SpeedInfo )
  : integer;
begin
  SpeedInfo.size := sizeof( SpeedInfo );
  Result := JLINKARM_DLL_GetSpeedInfo( SpeedInfo );
end;

function TJLINKARM.SelectDevice( DeviceName : AnsiString ) : integer;
var
  Command : AnsiString;
begin
  Command := 'Device = ' + DeviceName;
  Result := JLINKARM_ExecCommand( PAnsiChar( Command ), nil, 0 );
end;

function TJLINKARM.Attached : Boolean;
var
  HWStatus : TJLINKARM_HWStatus;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_GetHWStatus( HWStatus ) = 0;
  if not Result then
    Exit;

  Result := HWStatus.VTarget >= 1000;
  if not Result then
  begin
    Disconnect( );
    Exit;
  end;

  FVTarget := HWStatus.VTarget / 1000;
end;

procedure TJLINKARM.Close;
begin
  if FDllOpened then
  begin
    FDllOpened := FALSE;
    JLINKARM_Close( );
  end;
end;

// Set Interface, Set Speed, Set DeviceName or Set All
function TJLINKARM.Connect( AInteface : TJLINKARM_Inteface; Speed : integer;
  DeviceName : AnsiString ) : Boolean;
var
  RetValue : integer;
  ConnectTimes : integer;
  DoConnect : Boolean;
  VInterface : TJLINKARM_Inteface;
  AvailableInterface : integer;
begin
  Result := SetDeviceName( DeviceName );
  if not Result then
    Exit( FALSE );

  Result := Attached( );
  if not Result then
    Exit;

  Result := SetInterface( AInteface );
  if not Result then
    Exit;

  Result := SetSpeed( Speed );
  if not Result then
    Exit( FALSE );

  Exit( True );
end;

constructor TJLINKARM.Create( LogEvent : TJLINKARM_LogEvent;
  LogFileName : AnsiString; AbortEvent : THandle );
begin
  inherited Create( AbortEvent );

  GenerateManuafacturerList( );

  FOnLog := LogEvent;
  FLogFileName := LogFileName;
  if FLogFileName <> '' then
    JLINKARM_SetLogFile( PAnsiChar( LogFileName ) );

  if Assigned( FOnLog ) then
  begin
    JLINKARM_EnableLog( LogOutCb );
    JLINKARM_SetWarnOutHandler( WarningOutCb );
    JLINKARM_SetErrorOutHandler( ErrorOutCb );
  end;

  FDeviceFamily := -1;
  FDeviceName := '';
  FDevAttached := FALSE;
  FDevConnected := FALSE;
  FSpeed := JLINKARM_SPEED_AUTO;
  FDeviceEndian := ARM_ENDIAN_LITTLE;
  FInterface := jiUnknown;
end;

destructor TJLINKARM.Destroy;
begin
  Close;
  inherited;
end;

procedure TJLINKARM.Disconnect;
begin
  if FDevConnected then
  begin
    FDevConnected := FALSE;
    FSpeed := JLINKARM_SPEED_AUTO;
    FInterface := jiUnknown;
  end;

  Close( );
end;

// return size has written : -1 : failed
function TJLINKARM.Download( Address : DWORD; const Buffer; size : DWORD )
  : integer;
begin
  if not FDllOpened then
    Exit( -1 );

  Result := JLINKARM_BeginDownload( 0 );
  if Result >= 0 then
  begin
    Result := JLINKARM_WriteMem( Address, size, Buffer );
    if Result <> size then
      Exit;
    if JLINKARM_EndDownload( ) >= 0 then
      Exit;
    Result := -1;
  end;
end;

// JLink commander : loadbin filename, addr
// JLink commander : loadfile filename [addr]
// *.mot, *.srec, *.s19, *.s, *.hex, *.bin, *.raw
//
// Result >= 0 : OK
// -255 : Error while programming flash: Comparing flash contens failed
// -266 : Error while programming flash: Programming failed
// -267 : Error while programming flash: Verify failed
// -268 : Failed to open file
// -269 : File is of unknown / supported format
// -270 : Writing target memory failed < RAM ? >
// else : Unspecified error
function TJLINKARM.Download( FileName : PAnsiChar; Address : DWORD ) : integer;
begin
  if not FDllOpened then
    Exit( -1 );

  Result := JLINK_DownloadFile( FileName, Address );
end;

class procedure TJLINKARM.ErrorOutCb( strError : PAnsiChar );
begin
  Log( jlError, strError );
end;

//
// JLINK_BeginDownload(Flags = 0x00)
// JLINK_BeginDownload(Flags = 0x03)
// JLINK_WriteMem(0x20000000, 0x12D8 Bytes, ...)
// JLINK_EndDownload()
// JLINK_ReadMemU32(0x20000000, 0x04B6 Items, ...)
// JLINK_Reset(), JLINK_IsHalted()  returns TRUE
// JLINK_ReadRegs(NumRegs = 1, Indexes: 15) -- R15 (PC)=0xFFFFFFFE  returns 0x00
// JLINK_WriteReg(R15 (PC), 0x2000127C)  returns 0x00
// JLINK_ReadRegs(NumRegs = 1, Indexes: 17) -- MSP=0xFFFFFFFC  returns 0x00
// JLINK_ReadRegs(NumRegs = 1, Indexes: 18) -- PSP=0x80D20C30  returns 0x00
// JLINK_WriteReg(MSP, 0x200026E8)  returns 0x00
// JLINK_SetBPEx(Addr = 0x20000F2C, Type = 0xFFFFFFF2)
// JLINK_Go()
// JLINK_IsHalted() -- CPU_ReadMem(2 bytes @ 0x20000F2C)  returns TRUE
// JLINK_ReadRegs(NumRegs = 1, Indexes: 15) -- R15 (PC)=0x20000F2C  returns 0x00
// JLINK_ClrBPEx(BPHandle = 0x00000001)  returns 0x00
//
function TJLINKARM.ExecuteCodeCM( Address, size : DWORD; Code : PDWORD )
  : Boolean;
var
  CM_MSP_Val, CM_PC_Val : DWORD;
  Buffer : array [ 0 .. 4095 ] of Byte;
  Count : DWORD;
  CodeBuffer : PByte;
begin
  Result := Connect( );
  if not Result then
    Exit;

  Result := Reset( True );
  if not Result then
    Exit;

  Result := JLINKARM_BeginDownload( 0 ) >= 0;
  if not Result then
    Exit;

  // Download Code
  Result := WriteMemory( Address, size, Code^ ) = size;

  JLINKARM_EndDownload( );

  if not Result then
    Exit;

  // Verity Downloaded Code
  CodeBuffer := PByte( Code );
  while size > 0 do
  begin
    Count := size;
    if Count > 4096 then
      Count := 4096;
    Result := ReadMemory( Address, Buffer, Count );
    if not Result then
      Exit;

    Result := CompareMem( @Buffer, CodeBuffer, Count );
    if not Result then
      Exit;

    Inc( CodeBuffer, Count );
    Inc( Address, Count );
    Dec( size, Count );
  end;

  // Execution Program Status Register
  // N Z C V Q  ICI/IT T ... ICI/IT ... ISR_NUM
  // 31         26     24    15         8
  // **
  // T = 1 : The Cortex-M3 processor only supports execution of instructions
  // in Thumb state. Attempting to execute instructions when the T bit is 0
  // results in a fault or lockup.
  Result := WriteReg( JLINKARM_CM_XPSR, $01000000 ) = 0;
  if not Result then
    Exit;

  // Execute Downloaded Code
  CM_MSP_Val := Code^;
  Inc( Code );
  CM_PC_Val := Code^;

  Result := WriteReg( JLINKARM_CM_MSP, CM_MSP_Val ) = 0;
  if not Result then
    Exit;

  Result := WriteReg( JLINKARM_CM_R15, CM_PC_Val ) = 0;
  if not Result then
    Exit;

  (* TRCENA ( bit 24 :  Debug Exception and Monitor Control Register )
    This bit must be set to 1 to enable use of the trace and debug blocks:
    Data Watchpoint and Trace (DWT)
    Instrumentation Trace Macrocell (ITM)
    Embedded Trace Macrocell (ETM)
    Trace Port Interface Unit (TPIU).
    This enables control of power usage unless tracing is required.
    The application can enable this, for ITM use, or use by a debugger.
    Note If no debug or trace components are present in the implementation
    then it is not possible to set TRCENA. *)
  Result := WriteDWord( $E000EDFC, $10000000 );
  if not Result then
    Exit;

  Result := GoIntDis( );

end;

function TJLINKARM.ExecuteCodeCM( Address, size : DWORD; FileName : PAnsiChar )
  : Boolean;
begin
  Exit( FALSE );
end;

procedure TJLINKARM.ExtractEmuCapsStrings( EmuCaps : DWORD;
  EmuCapsStrings : TStrings );
const
  StrTrue : string = ' : TRUE';
  StrFalse : string = ' : FALSE';
var
  StrResult : string;
  Index : integer;
begin
  for index := 0 to 31 do
  begin
    if index = JLINK_EMU_CAP_RESERVED_1 then
      Continue;
    if index = JLINK_EMU_CAP_RESERVED_2 then
      Continue;
    if index = JLINK_EMU_CAP_RESERVED_3 then
      Continue;

    StrResult := JLINKARM_EmulatorCapabilites[ index ];
    if EmuCaps and ( 1 shl index ) > 0 then
      StrResult := StrResult + StrTrue
    else
      StrResult := StrResult + StrFalse;
    EmuCapsStrings.Add( StrResult );
  end;
end;

procedure TJLINKARM.ExtractFirmwareStr( FirmwareStr : AnsiString;
  var FirmwareName, FirmwareDate : AnsiString );
var
  PositionName, PositionDate : integer;
begin
  PositionName := Pos( 'compiled', FirmwareStr );
  if PositionName = 0 then
    PositionName := Pos( 'Compiled', FirmwareStr );

  // J-Link V9
  FirmwareName := Copy( FirmwareStr, 1, PositionName - 1 );
  PositionDate := Pos( ' ', FirmwareStr, PositionName );
  Inc( PositionDate );
  // Skip Space

  // Sep  5 2014 18:54:08
  FirmwareDate := Copy( FirmwareStr, PositionDate, Length( FirmwareStr ) -
    PositionName + 1 );
end;

procedure TJLINKARM.ExtractVersionStr( Version : integer;
  var VersionStr : AnsiString );
var
  Major, Minor, Patch : integer;
  PatchStr : AnsiString;
begin
  Major := Version div 10000;
  Minor := Version mod 10000;
  Minor := Minor div 100;
  VersionStr := Format( 'V%d.%.2d', [ Major, Minor ] );

  Patch := Version mod 100;
  PatchStr := '';
  if Patch > 0 then
  begin
    if Patch <= 26 then
    begin
      PatchStr := AnsiChar( Patch + Ord( 'a' ) - 1 );
    end else begin
      PatchStr := 'z' + IntToStr( Patch - 26 );
    end;
    VersionStr := VersionStr + PatchStr;
  end;
end;

function TJLINKARM.GetDeviceCount : integer;
begin
  if not FDllOpened then
    Exit( -1 );

  Result := GetDeviceInfo( -1, nil );
end;

function TJLINKARM.GetDeviceEndian : TJLINKARM_Endian;
begin
  JLINKARM_SetEndian( FDeviceEndian );
  Result := FDeviceEndian;
end;

function TJLINKARM.GetDeviceFamily : integer;
begin
  Result := FDeviceFamily;
end;

procedure TJLINKARM.GetDeviceInfoEx( DeviceIndex : integer;
  var DeviceInfo : TJLINKARM_DeviceInfoEx );
var
  DevInfo : TJLINKARM_DeviceInfo;
  I : integer;
begin
  if not FDllOpened then
  begin
    DeviceInfo.Index := -1;
    Exit;
  end;

  GetDeviceInfo( DeviceIndex, @DevInfo );

  DeviceInfo.Index := DeviceIndex;
  DeviceInfo.Id := DevInfo.Id;
  CStrCopy( @DeviceInfo.ManfName[ 0 ], DevInfo.ManfName,
    sizeof( DeviceInfo.ManfName ) );
  DeviceInfo.Family := DevInfo.Family;

  // ---------------------------------------------------------------------------
  // JLINKARM : Family
  // Family[31..24]   [23..16]   [15..8]   [7..4] [3..0]
  // ______ARM7, RX   TDMI       -S, JF-S  Rev    Patch
  JLINKARM_Core2CoreName( DevInfo.Family, @DeviceInfo.FamilyName[ 0 ],
    sizeof( DeviceInfo.FamilyName ) );
  CStrShrink( DeviceInfo.FamilyName );

  CStrCopy( @DeviceInfo.Name[ 0 ], DevInfo.Name, sizeof( DeviceInfo.Name ) );

  DeviceInfo.Endian := DevInfo.Endian;
  DeviceInfo.Flash.Base := DevInfo.FlashBase;
  DeviceInfo.Flash.size := DevInfo.FlashSize;
  DeviceInfo.Sram.Base := DevInfo.SramBase;
  DeviceInfo.Sram.size := DevInfo.SramSize;

  DeviceInfo.FlashBitMap := 0;
  DeviceInfo.SramBitMap := 0;

  for I := 0 to 31 do
  begin
    DeviceInfo.FlashMap[ I ].Base := 0;
    DeviceInfo.FlashMap[ I ].size := 0;
    DeviceInfo.SramMap[ I ].Base := 0;
    DeviceInfo.SramMap[ I ].size := 0;
  end;

  for I := 0 to 31 do
  begin
    if DevInfo.Flash[ I ].size = 0 then
      break;

    DeviceInfo.FlashBitMap := DeviceInfo.FlashBitMap or ( 1 shl I );
    DeviceInfo.FlashMap[ I ].Base := DevInfo.Flash[ I ].Base;
    DeviceInfo.FlashMap[ I ].size := DevInfo.Flash[ I ].size;
  end;

  for I := 0 to 31 do
  begin
    if DevInfo.Sram[ I ].size = 0 then
      break;
    DeviceInfo.SramBitMap := DeviceInfo.SramBitMap or ( 1 shl I );
    DeviceInfo.SramMap[ I ].Base := DevInfo.Sram[ I ].Base;
    DeviceInfo.SramMap[ I ].size := DevInfo.Sram[ I ].size;
  end;

end;

function TJLINKARM.GetHwStatus : TJLINKARM_HWStatus;
begin
  if not FDllOpened then
  begin
    Result.VTarget := 0;
    Exit;
  end;

  JLINKARM_GetHWStatus( Result );
end;

function TJLINKARM.GetInterface : TJLINKARM_Inteface;
begin
  Result := FInterface;
end;

function TJLINKARM.GetSpeed : integer;
begin
  Result := FSpeed;
end;

function TJLINKARM.Go : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_Go( ) = 0;
end;

function TJLINKARM.GoIntDis : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_GoIntDis( ) = 0;
end;

function TJLINKARM.Halt : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_Halt( ) > 0;
end;

function TJLINKARM.GetInformation( Strings : TStringList;
  EmulatorCaps : Boolean ) : Boolean;
var
  size : integer;
  Major, Minor, Patch : integer;
  Version : integer;
  EmuCaps : DWORD;

  AnsiPtr : PAnsiChar;

  VersionStr : AnsiString;
  ProductName : AnsiString;
  OEMProductName : AnsiString;
  FeatureString : AnsiString;
  LicenseString : AnsiString;
  FirmwareString : AnsiString;
  FirmwareName : AnsiString;
  FirmwareDate : AnsiString;
  CompileDateTime : AnsiString;
  EmbeddedFWString : AnsiString;
  EmuCapsEx : AnsiString;
begin
  if not FDllOpened then
    Exit( FALSE );

  size := 1024;

  // SEGGER J-Link EDU
  SetLength( ProductName, size );
  JLINKARM_EMU_GetProductName( @ProductName[ 1 ], size );
  SetLength( ProductName, CStrLen( @ProductName[ 1 ] ) );
  Strings.Add( Format( ' Product : %s', [ ProductName ] ) );

  // SEGGER-EDU
  SetLength( OEMProductName, size );
  JLINKARM_GetOEMString( @OEMProductName[ 1 ] );
  SetLength( OEMProductName, CStrLen( @OEMProductName[ 1 ] ) );
  AnsiPtr := @OEMProductName[ 1 ];

  if CStrLen( AnsiPtr ) > 0 then
    Strings.Add( Format( '     OEM : %s', [ OEMProductName ] ) );

  // 269200283
  Major := JLINKARM_GetSN( );
  Strings.Add( Format( 'SerialNo : %.10d', [ Major ] ) );

  // RDI,FlashBP,FlashDL,JFlash,GDB
  SetLength( LicenseString, size );
  JLINK_GetAvailableLicense( @LicenseString[ 1 ], size );
  SetLength( LicenseString, CStrLen( @LicenseString[ 1 ] ) );
  // Strings.Add( Format( ' License : %s', [ LicenseString ] ) );

  // FlashBP, GDB, JFlash, RDI, FlashDL
  SetLength( FeatureString, size );
  JLINKARM_GetFeatureString( @FeatureString[ 1 ] );
  SetLength( FeatureString, CStrLen( @FeatureString[ 1 ] ) );
  Strings.Add( Format( ' Feature : %s', [ FeatureString ] ) );

  // 90000 : 9.00
  Version := JLINKARM_GetHardwareVersion( );
  ExtractVersionStr( Version, VersionStr );
  Strings.Add( Format( 'Hardware : %s', [ VersionStr ] ) );

  // 49005 : 4.90e
  Version := JLINKARM_GetDLLVersion( );
  ExtractVersionStr( Version, VersionStr );
  Strings.Add( Format( 'Software : %s', [ VersionStr ] ) );

  // Sep  8 2014 18:46:31
  AnsiPtr := JLINKARM_GetCompileDateTime( );
  SetString( CompileDateTime, AnsiPtr, CStrLen( AnsiPtr ) );
  Strings.Add( Format( 'Compiled : %s', [ CompileDateTime ] ) );

  // J-Link V9 compiled Sep  5 2014 18:54:08
  SetLength( FirmwareString, size );
  JLINKARM_GetFirmwareString( @FirmwareString[ 1 ], size );
  SetLength( FirmwareString, CStrLen( @FirmwareString[ 1 ] ) );

  // 'J-Link V9 compiled Sep  5 2014 18:54:08'
  SetLength( EmbeddedFWString, size );
  JLINKARM_GetEmbeddedFWString( @FirmwareString[ 1 ],
    @EmbeddedFWString[ 1 ], size );
  SetLength( EmbeddedFWString, CStrLen( @EmbeddedFWString[ 1 ] ) );
  ExtractFirmwareStr( EmbeddedFWString, FirmwareName, FirmwareDate );

  Version := JLINKARM_GetEmbeddedFWVersion( );
  ExtractVersionStr( Version, VersionStr );

  Strings.Add( Format( 'Firmware : %s', [ FirmwareName ] ) );
  Strings.Add( Format( 'Firmware : %s', [ VersionStr ] ) );
  Strings.Add( Format( 'Compiled : %s', [ FirmwareDate ] ) );

  // J-Link V9 compiled Sep  5 2014 18:54:08
  // *********          ********************
  ExtractFirmwareStr( FirmwareString, FirmwareName, FirmwareDate );
  Strings.Add( Format( 'Emulator : %s', [ FirmwareName ] ) );
  Strings.Add( Format( 'Compiled : %s', [ FirmwareDate ] ) );

  if EmulatorCaps then
  begin

    EmuCaps := JLINKARM_GetEmuCaps( );
    ExtractEmuCapsStrings( EmuCaps, Strings );

    // **EmuCaps** **ExtCaps**
    // BF 7B FF B9 0D 7C B1 03 00 00 00 00 .. 00 00 00 00 : 64 Bytes
    size := 64;
    SetLength( EmuCapsEx, size );
    JLINKARM_GetEmuCapsEx( @EmuCapsEx[ 1 ], size );
  end;

  Exit( True );
end;

function TJLINKARM.IsHalted : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_IsHalted( ) > 0;
end;

class procedure TJLINKARM.Log( JLinkLog : TJLINKARM_Log; Info : AnsiString );
begin
  Log( JLinkLog, PAnsiChar( Info ) );
end;

class procedure TJLINKARM.Log( JLinkLog : TJLINKARM_Log; Info : PAnsiChar );
var
  Str : string;
begin
  if Assigned( FOnLog ) then
  begin
    SetString( Str, Info, CStrLen( Info ) );
    FOnLog( JLinkLog, Str );
  end;
end;

class procedure TJLINKARM.LogOutCb( strLog : PAnsiChar );
begin
  Log( jlInformation, strLog );
end;

function TJLINKARM.NextInterface( AInteface : TJLINKARM_Inteface )
  : TJLINKARM_Inteface;
begin
  if AInteface = jiJTAG then
    Result := jiSWD
  else
    Result := jiJTAG;
end;

function TJLINKARM.Open( UserDeviceName : string ) : Boolean;
var
  JLinkError : PAnsiChar;
  InterfaceVal : DWORD;
  HostName : AnsiString;
  Port : integer;
  PortPos : integer;
begin
  if FUserDeviceName <> UserDeviceName then
  begin
    FUserDeviceName := UserDeviceName;
    Close( );

    UserDeviceName2UsbPort( UserDeviceName );
    if UsbPort <> -1 then
    begin
      if not inherited UsbOpen( UserDeviceName ) then
      begin
        Log( jlError, PAnsiChar( Format( 'Can not open %s !',
          [ UserDeviceName ] ) ) );
        Exit( FALSE );
      end;
    end;
  end;

  if FDllOpened then
    Exit( True );

  FInterface := jiUnknown;

  if UsbPort <> -1 then
  begin
    if GetCurrentInterface( InterfaceVal ) then
    begin
      if ( InterfaceVal <= Ord( jiSWD ) ) then
        FInterface := TJLINKARM_Inteface( InterfaceVal );
    end;
    UsbClose;

    // Select Only
    if JLINKARM_SelectUSB( UsbPort ) <> 0 then
      Exit( FALSE );

  end else begin
    // UserDeviceName = 'localhost', 'localhost:19020', '127.0.0.1:19020' etc.
    PortPos := Pos( ':', UserDeviceName );
    if PortPos = 0 then
    begin
      HostName := UserDeviceName;
      Port := 19020;
    end else begin
      // 'localhost:19020' : PortPos = 10, Length = 15
      HostName := Copy( UserDeviceName, 1, PortPos - 1 );
      Port := StrToInt( Copy( UserDeviceName, PortPos + 1,
        Length( UserDeviceName ) - PortPos ) );
    end;

    // Select Only
    if JLINKARM_SelectIP( PAnsiChar( HostName ), Port ) <> 0 then
      Exit( FALSE );
  end;

  if JLINKARM_HasError( ) <> 0 then
    JLINKARM_ClrError( );

  if Assigned( FOnLog ) then
    JLinkError := JLINKARM_OpenEx( LogOutCb, ErrorOutCb )
  else
    JLinkError := JLINKARM_OpenEx( nil, nil );

  Result := JLinkError = nil;
  if not Result then
  begin
    JLINKARM_Close( );
    Log( jlError, JLinkError );
  end else if JLINKARM_IsOpen( ) > 0 then
  begin
    FDllOpened := True;
  end;

  Result := FDllOpened;
end;

function TJLINKARM.QueryDeviceFamily( DeviceName : string ) : integer;
begin
  if not UsbOpened then
    Exit( -1 );

  Result := JLINKARM_DEVICE_GetIndex( PAnsiChar( AnsiString( DeviceName ) ) )
end;

function TJLINKARM.QueryInterface : TJLINKARM_Inteface;
var
  FirstDeviceId : DWORD;
begin
  Result := jiUnknown;
  // Only Current Interface < Defaut JTAG, or Other Debugger's Interface >
  FirstDeviceId := JLINKARM_GetId( );

  // Current Interface is valid
  if FirstDeviceId > 0 then
  begin
    FirstDeviceId := JLINKARM_JTAG_GetDeviceId( 0 );
    if FirstDeviceId > 0 then
      Result := jiJTAG
      // Current Interface is JTAG
    else
      Result := jiSWD; // Current Interface is SWD
  end;
end;

// return size in items
function TJLINKARM.ReadByte( Address : DWORD; var AByte : Byte ) : Boolean;
begin
  Result := JLINKARM_ReadMemU8( Address, 1, AByte, nil ) = 1;
end;

function TJLINKARM.ReadWord( Address : DWORD; var AWord : WORD ) : Boolean;
begin
  Result := JLINKARM_ReadMemU16( Address, 1, AWord, nil ) = 1;
end;

function TJLINKARM.ReadDWord( Address : DWORD; var ADWord : DWORD ) : Boolean;
begin
  Result := JLINKARM_ReadMemU32( Address, 1, ADWord, nil ) = 1;
end;

function TJLINKARM.ReadQWord( Address : DWORD; var AQWord : UInt64 ) : Boolean;
begin
  Result := JLINKARM_ReadMemU64( Address, 1, AQWord, nil ) = 1;
end;

function TJLINKARM.ReadMemory( Address : DWORD; var Buffer; Items : DWORD;
  MemoryUnit : TJLINKRAM_MemoryUnit ) : integer;
begin
  if not FDllOpened then
    Exit( -1 );

  case MemoryUnit of
    mu8Bits :
      Result := JLINKARM_ReadMemU8( Address, Items, Buffer, nil );
    mu16Bits :
      Result := JLINKARM_ReadMemU16( Address, Items, Buffer, nil );
    mu32Bits :
      Result := JLINKARM_ReadMemU32( Address, Items, Buffer, nil );
    mu64Bits :
      Result := JLINKARM_ReadMemU64( Address, Items, Buffer, nil );
  end;
end;

// return status is 0 if read success !
function TJLINKARM.ReadMemory( Address : DWORD; var Buffer; size : DWORD )
  : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );
  Result := 0 = JLINKARM_ReadMem( Address, size, Buffer );
end;

function TJLINKARM.ReadReg( RegIndex : DWORD ) : integer;
begin
  if not FDllOpened then
    Exit( 0 );

  Result := JLINKARM_ReadReg( RegIndex );
end;

// Result = 1 : OK
function TJLINKARM.Reset( Halt : Boolean; ResetDelay, PulseLen : DWORD;
  ResetType : TJLINKARM_RESET_TYPE ) : Boolean;
var
  Str : AnsiString;
  Buffer : array [ 0 .. 255 ] of Byte;
begin
  if not FDllOpened then
    Exit( FALSE );

  // Type 0: Hardware, halt after reset (normal)
  if ResetType <> JLINKARM_RESET_TYPE_NORMAL then
    JLINKARM_SetResetType( Ord( ResetType ) );
  {
    SetLength( Str, 256 );
    Str := Format( 'SetResetType = %d', [ Ord( JLINKARM_RESET_TYPE_NORMAL ) ] );
    FillChar( Buffer[ 0 ], 256, $55 );
    JLINKARM_ExecCommand( PAnsiChar( Str ), @Buffer[ 0 ], 256 );
  }

  if PulseLen > 0 then
  begin
    SetLength( Str, 256 );
    Str := Format( 'SetResetPulseLen = %d', [ PulseLen ] );
    FillChar( Buffer[ 0 ], 256, $55 );
    JLINKARM_ExecCommand( PAnsiChar( Str ), @Buffer[ 0 ], 256 );
  end;

  if ResetDelay > 0 then
  begin
    Result := JLINKARM_SetResetDelay( ResetDelay ) > 0;
    if not Result then
      Exit;
  end;

  Result := JLINK_ResetPullsRESET( 1 ) = 1;
  if not Result then
    Exit;

  if Halt then
  begin
    Result := JLINKARM_Reset( ) = 0;
  end else begin
    Result := JLINKARM_ResetNoHalt( ) = 0;
  end;
end;

function TJLINKARM.SelectDeviceFamily( hWndParent : HWND;
  var DeviceFamily : integer ) : string;
var
  DlgResult : integer;
  DeviceInfo : TJLINKARM_DeviceInfo;
begin
  Result := '';
  if not UsbOpened then
    Exit;

  DlgResult := JLINKARM_DEVICE_SelectDialog( hWndParent );
  if DlgResult >= 0 then
  begin
    DlgResult := GetDeviceInfo( DlgResult, @DeviceInfo );
    if DlgResult = 0 then
    begin
      SetString( Result, DeviceInfo.Name, CStrLen( DeviceInfo.Name ) );
      DeviceFamily := JLINKARM_DEVICE_GetIndex( DeviceInfo.Name );
    end else begin
      DeviceFamily := DlgResult; // Device Count
      Result := '';
    end;
  end else begin
    DeviceFamily := -1; // Canceled
    Result := '';
  end;
end;

procedure TJLINKARM.SetDeviceEndian( DeviceEndian : TJLINKARM_Endian );
begin
  if FDeviceEndian <> DeviceEndian then
    FDeviceEndian := JLINKARM_SetEndian( DeviceEndian );
end;

function TJLINKARM.SetDeviceFamily( DeviceName : AnsiString ) : Boolean;
var
  DeviceFamily : integer;
begin
  Result := FALSE;
  if not UsbOpened then
    Exit;

  DeviceFamily := JLINKARM_DEVICE_GetIndex( PAnsiChar( DeviceName ) );

  if DeviceFamily >= 0 then
    Result := SetDeviceFamily( DeviceFamily );

end;

function TJLINKARM.SetDeviceFamily( DeviceFamily : integer ) : Boolean;
begin
  Result := JLINKARM_SelectDeviceFamily( DeviceFamily ) = 0;
  if Result then
    FDeviceFamily := DeviceFamily;
end;

function TJLINKARM.SetDeviceName( DeviceName : AnsiString ) : Boolean;
var
  Command : AnsiString;
begin
  Result := True;
  if DeviceName <> FDeviceName then
  begin
    Command := 'Device = ' + DeviceName;
    Result := JLINKARM_ExecCommand( PAnsiChar( Command ), nil, 0 ) = 0;
    if Result then
      FDeviceName := DeviceName;
  end;
end;

function TJLINKARM.SetInterface( AInteface : TJLINKARM_Inteface ) : Boolean;
var
  RetValue : integer;
  ConnectTimes : integer;
  VInterface : TJLINKARM_Inteface;
  AvailableInterface : integer;
begin
  VInterface := QueryInterface( );
  // Other debugger is connected, Uses Current Interface
  if VInterface <> jiUnknown then
  begin
    FInterface := VInterface;
    FDevConnected := True;
    Exit( True );
  end;

  // Other debugger is not connected
  AvailableInterface := JLINKARM_GetEmuCaps( ) and JLINK_EMU_CAP_SELECT_IF;
  if AvailableInterface > 0 then
    JLINKARM_TIF_GetAvailable( AvailableInterface ) // JTAG or SWD ?
  else
    AvailableInterface := 1; // JTAG Only

  if ( 1 shl Ord( AInteface ) ) and AvailableInterface = 0 then
  begin
    Log( jlError,
      'Selected interface is not supported by connected debug probe.' );
    Exit( FALSE );
  end;

  VInterface := AInteface;
  ConnectTimes := 0;
  while ( ConnectTimes < 2 ) do
  begin
    if JLINKARM_HasError( ) <> 0 then
      JLINKARM_ClrError( );

    if ( 1 shl Ord( VInterface ) ) and AvailableInterface > 0 then
    begin
      JLINKARM_TIF_Select( Ord( VInterface ) );
      if ( JLINKARM_Connect( ) = 0 ) then
      begin
        FDevConnected := True;
        FInterface := VInterface;
        break;
      end;
    end;

    VInterface := NextInterface( VInterface );
    Inc( ConnectTimes );
  end;

  Exit( FDevConnected );
end;

function TJLINKARM.SetSpeed( Speed : integer ) : Boolean;
var
  RetValue : integer;
begin
  // Set Speed
  // JTAG : Max Speed is used < 4,000,000 Hz >
  // JTAG : Default Speed is used < 4,000,000 Hz >
  // SWD : Max Speed is used < 2,000,000 Hz >
  // SWD : Default Speed is used < 2,000,000 Hz >
  if ( Speed = integer( JLINKARM_SPEED_AUTO ) ) or
    ( Speed = integer( JLINKARM_SPEED_MAX ) ) then
  begin
    // RetValue := JLINKARM_SetMaxSpeed( );
    // FSpeed := JLINKARM_GetSpeed( ) * 1000;
    // if RetValue <> 1 then
    begin
      // JLINKARM_SetMaxSpeed( ) : JLINKARM_SetSpeed( JLINKARM_SPEED_AUTO )
      RetValue := JLINKARM_SetSpeed( JLINKARM_SPEED_AUTO );
    end;
  end else begin
    if Speed > JLINKARM_SPEED_MAX_VALUE then
      Speed := JLINKARM_SPEED_MAX_VALUE;
    if Speed < JLINKARM_SPEED_MIN_VALUE then
      Speed := JLINKARM_SPEED_MIN_VALUE;

    Speed := Speed div 1000;
    RetValue := JLINKARM_SetSpeed( Speed );
  end;

  if RetValue <> 1 then
  begin
    RetValue := JLINKARM_SetSpeed( JLINKARM_SPEED_MID_VALUE );
    if RetValue <> 1 then
    begin
      RetValue := JLINKARM_SetSpeed( JLINKARM_SPEED_MIN_VALUE );
      if RetValue <> 1 then
      begin
        Disconnect( );
        Log( jlError, 'Can not set speed.' );
        Exit( FALSE );
      end;
    end;
  end;

  FSpeed := JLINKARM_GetSpeed( ) * 1000;
  Exit( True );
end;

class procedure TJLINKARM.WarningOutCb( strWarning : PAnsiChar );
begin
  Log( jlWarning, strWarning );
end;

function TJLINKARM.WriteByte( Address : DWORD; AByte : Byte ) : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_WriteU8( Address, AByte ) = 0;
end;

function TJLINKARM.WriteDWord( Address, ADWord : DWORD ) : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_WriteU32( Address, ADWord ) = 0;
end;

function TJLINKARM.WriteMemory( Address, size : DWORD; const Buffer ) : integer;
begin
  if not FDllOpened then
    Exit( -1 );

  Result := JLINKARM_WriteMem( Address, size, Buffer );
end;

function TJLINKARM.WriteQWord( Address : DWORD; AQWord : UInt64 ) : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_WriteU64( Address, AQWord ) = 0;
end;

function TJLINKARM.WriteReg( RegIndex, RegValue : DWORD ) : integer;
begin
  if not FDllOpened then
    Exit( -1 );

  Result := JLINKARM_WriteReg( RegIndex, RegValue );
end;

function TJLINKARM.WriteWord( Address : DWORD; AWord : WORD ) : Boolean;
begin
  if not FDllOpened then
    Exit( FALSE );

  Result := JLINKARM_WriteU16( Address, AWord ) = 0;
end;

end.
