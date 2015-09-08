unit uJLinkUsb;

interface

uses
  SysUtils, Windows, Classes, uUsbCommon, uAsyncIo;

const
  JLINK_DEFAULT_TIMEOUT = 2000;
  JLINK_IN_BUFFER_SIZE = 2 * 1024;
  JLINK_OUT_BUFFER_SIZE = 4 * 1024 + 4;
  JLINK_EMU_RESULT_BUFFER_SIZE = 64;

const
  JLinkUserDeviceNames : array [ 0 .. 3 ] of string = ( //
    'JLINK 0', 'JLINK 1', 'JLINK 2', 'JLINK 3' );

  JLinkUsbDeviceNames : array [ 0 .. 3 ] of string = ( //
    '\\?\usb#vid_1366&pid_0101', //
    '\\?\usb#vid_1366&pid_0102', //
    '\\?\usb#vid_1366&pid_0103', //
    '\\?\usb#vid_1366&pid_0104' );

const
  // JLink.inf
  JLinkDeviceClassGUID : TGUID = '{36FC9E60-C465-11CF-8056-444553540000}';

  // JLink.sys, JLinkARM.dll
  JLinkInterfaceClassGUID : TGUID = '{54654E76-DCF7-4A7F-878A-4E8FCA0ACC9A}';

type
  TJLINK_USB = class
  private
    FUserDeviceName : string;
    FUsbDevicePathNames : TUSB_DEVICE_PATH_NAMES;

    FUsbPort : integer;
    FUsbDeviceName : string;
    FUsbDevicePathName : string;

    FUsbOpened : Boolean;
    FUsbLocked : Boolean;
    FAbortEvent : THandle;
    FMutexHandle : THandle;
    FDeviceHandle : THandle;
    FPipeInHandle : THandle;
    FPipeOutHandle : THandle;

    FUsbDeviceIndex : integer;
    FUsbReadTimeOut : integer;
    FUsbWriteTimeOut : integer;

  public
    InBuffer : array [ 0 .. JLINK_OUT_BUFFER_SIZE - 1 ] of Byte;
    OutBuffer : array [ 0 .. JLINK_IN_BUFFER_SIZE - 1 ] of Byte;
    EmuResultBuffer : array [ 0 .. JLINK_EMU_RESULT_BUFFER_SIZE - 1 ] of Byte;

    function UsbLock( ) : Boolean;
    function UsbUnlock( ) : Boolean;

    function UsbRead( var Buffer; BufferLength : DWORD ) : integer;

    function UsbWrite( const Buffer; BufferLength : DWORD ) : integer;

    function UsbAccess( const lpInBuffer; nInBufferSize : DWORD; //
      var lpOutBuffer; nOutBufferSize : DWORD ) : integer;

    function UsbIoControl( hControl : THandle; dwIoControlCode : DWORD;
      const lpInBuffer; nInBufferSize : DWORD; var lpOutBuffer;
      nOutBufferSize : DWORD ) : integer;

    function UsbDeviceNameMatch( UsbDeviceName : string ) : integer;
    function UserDeviceNameMatch( UserDeviceName : string ) : integer;

    function UserDeviceName2UsbPort( UserDeviceName : string ) : integer;
    function UserDeviceName2UsbDeviceName( UserDeviceName : string ) : string;

    function UsbDeviceName2UserDeviceName( UsbDeviceName : string ) : string;
    function UsbDeviceName2UsbDevicePathName( UsbDeviceName : string ) : string;

    procedure UsbEnumDevices( UserDeviceNames : TStrings );
    function UsbOpen( UserDeviceName : string ) : Boolean;
    procedure UsbClose( );

    constructor Create( AbortEvent : THandle = 0 );
    destructor Destroy; override;

    property UsbOpened : Boolean read FUsbOpened;
    property UsbPort : integer read FUsbPort;

    property UsbReadTimeOut : integer read FUsbReadTimeOut //
      write FUsbReadTimeOut default JLINK_DEFAULT_TIMEOUT;
    property UsbWriteTimeOut : integer read FUsbWriteTimeOut
      write FUsbWriteTimeOut default JLINK_DEFAULT_TIMEOUT;

  end;

implementation

procedure TJLINK_USB.UsbEnumDevices( UserDeviceNames : TStrings );
var
  I : integer;
  UsbClassName : string;
begin
  // The SetupDiClassNameFromGuid function retrieves the class name associated
  // with a class GUID. e.g. {36FC9E60-C465-11CF-8056-444553540000}
  // UsbClassName := USB_GetDeviceClassName( JLinkDeviceClassGUID );

  FUsbDevicePathNames := USB_GetDevicePathNames( JLinkInterfaceClassGUID );
  for I := low( FUsbDevicePathNames ) to high( FUsbDevicePathNames ) do
    UserDeviceNames.Add( UsbDeviceName2UserDeviceName
      ( FUsbDevicePathNames[ I ] ) );
end;

function TJLINK_USB.UserDeviceName2UsbDeviceName( UserDeviceName
  : string ) : string;
var
  I : integer;
begin
  Result := '';
  I := UserDeviceNameMatch( UserDeviceName );
  if I >= 0 then
    Result := JLinkUsbDeviceNames[ I ];
end;

function TJLINK_USB.UserDeviceName2UsbPort( UserDeviceName : string ) : integer;
begin
  FUsbPort := UserDeviceNameMatch( UserDeviceName );
  Result := FUsbPort;
end;

function TJLINK_USB.UserDeviceNameMatch( UserDeviceName : string ) : integer;
var
  I : integer;
begin
  for I := low( JLinkUsbDeviceNames ) to high( JLinkUsbDeviceNames ) do
  begin
    if Pos( JLinkUserDeviceNames[ I ], UserDeviceName ) > 0 then
      Exit( I );
  end;
  Exit( -1 );
end;

function TJLINK_USB.UsbDeviceName2UserDeviceName( UsbDeviceName
  : string ) : string;
var
  I : integer;
begin
  Result := '';
  I := UsbDeviceNameMatch( UsbDeviceName );
  if I >= 0 then
    Result := JLinkUserDeviceNames[ I ];
end;

function TJLINK_USB.UsbDeviceName2UsbDevicePathName( UsbDeviceName
  : string ) : string;
var
  I : integer;
begin
  for I := low( FUsbDevicePathNames ) to high( FUsbDevicePathNames ) do
  begin
    if Pos( UsbDeviceName, FUsbDevicePathNames[ I ] ) > 0 then
      Exit( FUsbDevicePathNames[ I ] );
  end;
  Exit( '' );
end;

function TJLINK_USB.UsbDeviceNameMatch( UsbDeviceName : string ) : integer;
var
  I : integer;
begin
  UsbDeviceName := LowerCase( UsbDeviceName );
  for I := low( JLinkUsbDeviceNames ) to high( JLinkUsbDeviceNames ) do
  begin
    if Pos( JLinkUsbDeviceNames[ I ], UsbDeviceName ) > 0 then
      Exit( I );
  end;
  Exit( -1 );
end;

// Read UsbDeviceIndex to check whether JLink Device Present
constructor TJLINK_USB.Create( AbortEvent : THandle );
begin
  inherited Create;
  FAbortEvent := AbortEvent;
  FUsbReadTimeOut := JLINK_DEFAULT_TIMEOUT;
  FUsbWriteTimeOut := JLINK_DEFAULT_TIMEOUT;
end;

destructor TJLINK_USB.Destroy;
begin
  UsbClose;
  inherited Destroy;
end;

function TJLINK_USB.UsbOpen( UserDeviceName : string ) : Boolean;
begin
  if UserDeviceName <> FUserDeviceName then
  begin
    FUserDeviceName := UserDeviceName;
    // FUsbPort = -1 if UserDeviceName = 'localhost', '127.0.0.1' etc.
    FUsbPort := UserDeviceName2UsbPort( FUserDeviceName );
    FUsbDeviceName := UserDeviceName2UsbDeviceName( FUserDeviceName );
    FUsbDevicePathName := UsbDeviceName2UsbDevicePathName( FUsbDeviceName );
    if FUsbDevicePathName = '' then
      Exit( False );

    UsbClose( );
  end;

  if FUsbOpened then
    Exit( FUsbOpened );

  FDeviceHandle := CreateFile( PChar( FUsbDevicePathName ), GENERIC_READ or
    GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
    FILE_FLAG_OVERLAPPED, 0 );

  if FDeviceHandle = INVALID_HANDLE_VALUE then
    Exit( False );

  FPipeInHandle := CreateFile( PChar( FUsbDevicePathName + '\\pipe00' ),
    GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0 );

  if FPipeInHandle = INVALID_HANDLE_VALUE then
  begin
    CloseHandle( FDeviceHandle );
    Exit( False );
  end;

  FPipeOutHandle := CreateFile( PChar( FUsbDevicePathName + '\\pipe01' ),
    GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0 );

  if FPipeOutHandle = INVALID_HANDLE_VALUE then
  begin
    CloseHandle( FPipeInHandle );
    CloseHandle( FDeviceHandle );
    Exit( False );
  end;

  FMutexHandle := CreateMutex( nil, False, nil );
  if FMutexHandle = INVALID_HANDLE_VALUE then
  begin
    CloseHandle( FPipeOutHandle );
    CloseHandle( FPipeInHandle );
    CloseHandle( FDeviceHandle );
  end;

  FUsbOpened := True;
  Exit( True );
end;

procedure TJLINK_USB.UsbClose;
begin
  if FUsbOpened then
  begin
    CloseHandle( FMutexHandle );
    CloseHandle( FPipeOutHandle );
    CloseHandle( FPipeInHandle );
    CloseHandle( FDeviceHandle );
    FUsbOpened := False;
  end;
end;

function TJLINK_USB.UsbLock : Boolean;
begin
  if not UsbOpened then
    Exit( False );
  WaitForSingleObject( FMutexHandle, INFINITE );
  FUsbLocked := True;
  Exit( True );
end;

function TJLINK_USB.UsbUnlock : Boolean;
begin
  if not UsbOpened then
    Exit( False );
  if FUsbLocked then
  begin
    ReleaseMutex( FMutexHandle );
    FUsbLocked := False;
  end;
  Exit( True );
end;

function TJLINK_USB.UsbAccess( const lpInBuffer; nInBufferSize : DWORD;
  var lpOutBuffer; nOutBufferSize : DWORD ) : integer;
begin
  Result := -1;
  if FUsbOpened then
  begin
    Result := UsbWrite( lpInBuffer, nInBufferSize );
    if Result <> nInBufferSize then
      Exit( -1 );
    Result := UsbRead( lpOutBuffer, nOutBufferSize );
  end;
end;

function TJLINK_USB.UsbIoControl( hControl : THandle; dwIoControlCode : DWORD;
  const lpInBuffer; nInBufferSize : DWORD; var lpOutBuffer;
  nOutBufferSize : DWORD ) : integer;
begin
  Result := -1;
  if FUsbOpened then
    Result := USB_IoControl( hControl, dwIoControlCode, lpInBuffer,
      nInBufferSize, lpOutBuffer, nOutBufferSize, FUsbReadTimeOut );
end;

function TJLINK_USB.UsbRead( var Buffer; BufferLength : DWORD ) : integer;
begin
  Result := -1;
  if FUsbOpened then
    Result := USB_Read( FPipeInHandle, Buffer, BufferLength, FUsbReadTimeOut,
      FAbortEvent );
end;

function TJLINK_USB.UsbWrite( const Buffer; BufferLength : DWORD ) : integer;
begin
  Result := -1;
  if FUsbOpened then
    Result := USB_Write( FPipeOutHandle, Buffer, BufferLength, FUsbWriteTimeOut,
      FAbortEvent );
end;

end.
