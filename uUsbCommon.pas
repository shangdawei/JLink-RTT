unit uUsbCommon;

interface

uses
  Windows, SysUtils, Classes, Math, Messages, ExtCtrls, uAsyncIo;

const
  USB_MAX_DEVICE = 127;

  USB_DEVICE_DESCRIPTOR_TYPE = 1;
  USB_CONFIGURATION_DESCRIPTOR_TYPE = 2;
  USB_STRING_DESCRIPTOR_TYPE = 3;
  USB_INTERFACE_DESCRIPTOR_TYPE = 4;
  USB_ENDPOINT_DESCRIPTOR_TYPE = 5;

  USB_ENDPOINT_TYPE_CONTROL = 0;
  USB_ENDPOINT_TYPE_ISOCHRONOUS = 1;
  USB_ENDPOINT_TYPE_BULK = 2;
  USB_ENDPOINT_TYPE_INTERRUPT = 3;

  USB_REQ_TYPE_DIR_IN = $80;
  USB_REQ_TYPE_DIR_OUT = $00;

  USB_REQ_TYPE_STANDARD = ( $00 shl 5 );
  USB_REQ_TYPE_CLASS = ( $01 shl 5 );
  USB_REQ_TYPE_VENDOR = ( $02 shl 5 );
  USB_REQ_TYPE_RESERVED = ( $03 shl 5 );

  USB_REQ_TYPE_RECIP_DEVICE = $00;
  USB_REQ_TYPE_RECIP_INTERFACE = $01;
  USB_REQ_TYPE_RECIP_ENDPOINT = $02;
  USB_REQ_TYPE_RECIP_OTHER = $03;

const
  GUID_DEVINTERFACE_HID : TGUID = '{4D1E55B2-F16F-11Cf-88Cb-001111000030}';
  GUID_DEVINTERFACE_NETWORK_CARD
    : TGUID = '{AD498944-762F-11D0-8DCB-00C04FC3358C}';
  GUID_DEVINTERFACE_DISK_DEVICE
    : TGUID = '{53F56307-B6BF-11D0-94F2-00A0C91EFB8B}';
  // defined for USB devices that are attached to a USB hub.
  // to notify the system and applications of the presence of USB devices
  // that are attached to a USB hub.
  // This is the GUID for the USB device class
  // DEFINE_GUID(GUID_DEVINTERFACE_USB_RAW_DEVICE : HID, Disk, etc.
  // 0xA5DCBF10L, 0x6530, 0x11D2, 0x90, 0x1F, 0x00, 0xC0, 0x4F, 0xB9, 0x51, 0xED);
  GUID_DEVINTERFACE_USB_DEVICE
    : TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
  // device interface class
  DBT_DEVTYP_DEVICEINTERFACE = $00000005;
  // A device or piece of media has been inserted and is now available.
  DBT_DEVICEARRIVAL = $8000;
  // A device or piece of media is about to be removed. Cannot be denied.
  DBT_DEVICEREMOVECOMPLETE = $8004;

type
  TUSB_DEVICE_PATH_NAMES = array of string;

  TUSB_COMMON_DESCRIPTOR = packed record
    bLength : BYTE;
    bDescriptorType : BYTE;
  end;

  PUSB_COMMON_DESCRIPTOR = ^TUSB_COMMON_DESCRIPTOR;

  TUSB_STRING_DESCRIPTOR = packed record
    bLength : BYTE;
    bDescriptorType : BYTE;
    bString : array [ 0 .. 0 ] of WideChar;
  end;

  PUSB_STRING_DESCRIPTOR = ^TUSB_STRING_DESCRIPTOR;

  TUSB_DEVICE_DESCRIPTOR = packed record
    bLength : BYTE;
    bDescriptorType : BYTE;
    bcdUSB : word;
    bDeviceClass : BYTE;
    bDeviceSubClass : BYTE;
    bDeviceProtocol : BYTE;
    bMaxPacketSize0 : BYTE;
    idVendor : word;
    idProduct : word;
    bcdDevice : word;
    iManufacturer : BYTE;
    iProduct : BYTE;
    iSerialNumber : BYTE;
    bNumConfigurations : BYTE;
  end;

  PUSB_DEVICE_DESCRIPTOR = ^TUSB_DEVICE_DESCRIPTOR;

  TUSB_CONFIGURATION_DESCRIPTOR = packed record
    bLength : BYTE;
    bDescriptorType : BYTE;
    wTotalLength : word;
    bNumInterfaces : BYTE;
    bConfigurationValue : BYTE;
    iConfiguration : BYTE;
    bmAttributes : BYTE;
    bMaxPower : BYTE;
  end;

  PUSB_CONFIGURATION_DESCRIPTOR = ^TUSB_CONFIGURATION_DESCRIPTOR;

type
  TUSB_INTERFACE_DESCRIPTOR = packed record
    bLength : BYTE;
    bDescriptorType : BYTE;
    bInterfaceNumber : BYTE;
    bAlternateSetting : BYTE;
    bNumEndpoints : BYTE;
    bInterfaceClass : BYTE;
    bInterfaceSubClass : BYTE;
    bInterfaceProtocol : BYTE;
    iInterface : BYTE;
  end;

  PUSB_INTERFACE_DESCRIPTOR = ^TUSB_INTERFACE_DESCRIPTOR;

  TUSB_ENDPOINT_DESCRIPTOR = packed record
    bLength : BYTE;
    bDescriptorType : BYTE;
    bEndpointAddress : BYTE;
    bmAttributes : BYTE;
    wMaxPacketSize : word;
    bInterval : BYTE;
  end;

  PUSB_ENDPOINT_DESCRIPTOR = ^TUSB_ENDPOINT_DESCRIPTOR;

type
  TUSB_SETUP_PACKET = packed record
    bmRequestType : BYTE;
    bRequest : BYTE;
    wValue : word;
    wIndex : word;
    wLength : word;
  end;

  PUSB_SETUP_PACKET = ^TUSB_SETUP_PACKET;

const
  DIGCF_DEFAULT = $00000001;
  DIGCF_PRESENT = $00000002;
  DIGCF_ALLCLASSES = $00000004;
  DIGCF_PROFILE = $00000008;
  DIGCF_DEVICEINTERFACE = $00000010;

type
  SP_DEVICE_INTERFACE_DATA = record
    cbSize : DWORD;
    InterfaceClassGuid : TGUID;
    Flags : DWORD;
    Reserved : Pointer;
  end;

  PSP_DEVICE_INTERFACE_DATA = ^SP_DEVICE_INTERFACE_DATA;

  SP_DEVINFO_DATA = record
    cbSize : LongWord;
    ClassGUID : TGUID;
    DevInst : LongWord;
    Reserved : Pointer;
  end;

  PSP_DEVINFO_DATA = ^SP_DEVINFO_DATA;

  SP_DEVICE_INTERFACE_DETAIL_DATA = record
    cbSize : LongWord;
    DevicePath : array [ 0 .. 0 ] of AnsiChar;
  end;

  PSP_DEVICE_INTERFACE_DETAIL_DATA = ^SP_DEVICE_INTERFACE_DETAIL_DATA;

type
  PDevBroadcastHdr = ^DEV_BROADCAST_HDR;

  DEV_BROADCAST_HDR = packed record
    dbch_size : DWORD;
    dbch_devicetype : DWORD;
    dbch_reserved : DWORD;
  end;

  PDevBroadcastDeviceInterface = ^DEV_BROADCAST_DEVICEINTERFACE;

  DEV_BROADCAST_DEVICEINTERFACE = record
    dbcc_size : DWORD;
    dbcc_devicetype : DWORD;
    dbcc_reserved : DWORD;
    dbcc_classguid : TGUID;
    dbcc_name : array [ 0 .. 0 ] of WideChar;
  end;

type
  EUsbUtility = class( Exception )
  public
    constructor Create( AWinCode : Integer );
  end;

  { TUSBusbNotify }

type
  TUsbNotifyAction = ( UsbArrival, UsbRemoval );

  TusbNotifyEvent = procedure( Sender : TObject;
    UsbNotifyType : TUsbNotifyAction; const DeviceName : string ) of object;

  TusbNotify = class( TObject )
  private
    FWindowHandle : HWND;
    FNotificationHandle : Pointer;
    FOnUSBNotify : TusbNotifyEvent;
    FDeviceName : string;
    FTimer : TTimer;
    FUsbNotifyAction : TUsbNotifyAction;
    procedure OnTimer( Sender : TObject );
    procedure WndProc( var Msg : TMessage );
  public
    constructor Create( OnUSBNotify : TusbNotifyEvent ); overload;
    destructor Destroy; override;
  published
    property OnUSBNotify : TusbNotifyEvent read FOnUSBNotify write FOnUSBNotify;
  end;

function USB_GetVidPidFromRegistry( DevPathName : string;
  DevInterfaceGuidStr : string; var Vid : word; var Pid : word;
  var DevInstanceName : string ) : boolean;

function USB_GetDeviceClassName( ClassGUID : TGUID ) : string;

function USB_GetDevicePathNames( DevInterfaceGUID : TGUID )
  : TUSB_DEVICE_PATH_NAMES;

function USB_ParseDescriptor( DescriptorBuffer : PBYTE; BufferSize : DWORD;
  DescriptorType : DWORD; var pNextDescriptor : PBYTE )
  : PUSB_COMMON_DESCRIPTOR;

function USB_ParseInterfaceDescriptor( ConfDescriptor
  : PUSB_CONFIGURATION_DESCRIPTOR; InterfaceNumber, AltSetting, InterfaceClass,
  InterfaceSubClass, InterfaceProtocol : Integer; var IfDescriptorSize : DWORD;
  var pNextDescriptor : PBYTE ) : PUSB_INTERFACE_DESCRIPTOR;

function USB_IoControl( hControl : THandle; dwIoControlCode : DWORD;
  const lpInBuffer; nInBufferSize : DWORD; var lpOutBuffer;
  nOutBufferSize : DWORD; Timeout : DWORD; AsyncEvent : THandle = 0 ) : Integer;

function USB_Read( hRead : THandle; var Buffer; BufferLength : DWORD;
  Timeout : DWORD; AsyncEvent : THandle = 0 ) : Integer;

function USB_Write( hWrite : THandle; const Buffer; BufferLength : DWORD;
  Timeout : DWORD; AsyncEvent : THandle = 0 ) : Integer;

implementation

function SetupDiEnumDeviceInterfaces( DeviceInfoSet : THandle;
  DeviceInfoData : PSP_DEVINFO_DATA; const InterfaceClassGuid : TGUID;
  MemberIndex : LongWord; var DeviceInterfaceData : SP_DEVICE_INTERFACE_DATA )
  : BOOL; stdcall; external 'SetupAPI.dll';

function SetupDiDestroyDeviceInfoList( DeviceInfoSet : THandle ) : BOOL;
  stdcall; external 'SetupAPI.dll';

function SetupDiGetClassDevs( ClassGUID : PGUID; Enumerator : PAnsiChar;
  hwndParent : THandle; Flags : LongWord ) : THandle; stdcall;
  external 'SetupAPI.dll' name 'SetupDiGetClassDevsA';

function SetupDiGetDeviceInterfaceDetail( DeviceInfoSet : THandle;
  DeviceInterfaceData : PSP_DEVICE_INTERFACE_DATA;
  DeviceInterfaceDetailData : PSP_DEVICE_INTERFACE_DETAIL_DATA;
  DeviceInterfaceDetailDataSize : LongWord; pRequiredSize : PLongWord;
  DeviceInfoData : PSP_DEVINFO_DATA ) : BOOL; stdcall;
  external 'SetupAPI.dll' name 'SetupDiGetDeviceInterfaceDetailA';

function SetupDiClassNameFromGuid( ClassGUID : PGUID; ClassName : PAnsiChar;
  ClassNameSize : DWORD; RequiredSize : PDWORD ) : BOOL; stdcall;
  external 'Setupapi.dll' name 'SetupDiClassNameFromGuidA';

function USB_GetVidPidFromRegistry( DevPathName : string;
  DevInterfaceGuidStr : string; var Vid : word; var Pid : word;
  var DevInstanceName : string ) : boolean;
const
  USB_SUBKEY : string = 'SYSTEM\\CURRENTCONTROLSET\\CONTROL\\DEVICECLASSES\\';
var
  i : Integer;
  DevPathInRegistry : string;
  lpSubKeyStr : string;
  Key : HKEY;
  dwType : DWORD;
  RequiredSize : DWORD;
  VidPidStr : string;
  VidPidPos : Integer;
begin
  DevPathInRegistry := DevPathName;

  // ---------------------------------------------------------------------------
  // The string info stored in 'DeviceInstance' is the same across all
  // Windows platforms: 98SE, ME, 2K, and XP.
  // Upper-case in 98SE, ME Converts all to lower-case anyway.
  //
  // Modify DevicePath to use registry format
  DevPathInRegistry[ 1 ] := '#';
  DevPathInRegistry[ 2 ] := '#';
  DevPathInRegistry[ 4 ] := '#';

  // ---------------------------------------------------------------------------
  // 'SYSTEM\\CURRENTCONTROLSET\\CONTROL\\DEVICECLASSES\\
  // {798ACD1A-5EF1-4159-97B7-D895BF85C6DD}\
  // ##?#usb#vid_ffff&pid_ffff#0123456789abcdef#
  // {798acd1a-5ef1-4159-97b7-d895bf85c6dd}'
  //
  lpSubKeyStr := USB_SUBKEY + DevInterfaceGuidStr + '\' + DevPathInRegistry;

  if ( RegOpenKeyEx( HKEY_LOCAL_MACHINE, PChar( lpSubKeyStr ), 0,
    KEY_QUERY_VALUE, Key ) <> ERROR_SUCCESS ) then
    raise EUsbUtility.Create( GetLastError( ) )
  else
  begin
    if ( RegQueryValueEx( Key, 'DeviceInstance', nil, @dwType, nil,
      @RequiredSize ) <> ERROR_SUCCESS ) then
      raise EUsbUtility.Create( GetLastError( ) )
    else
    begin
      SetLength( DevInstanceName, RequiredSize );
      RegQueryValueEx( Key, 'DeviceInstance', nil, @dwType,
        PBYTE( DevInstanceName ), @RequiredSize );
      i := Pos( AnsiChar( #0 ), DevInstanceName );
      if i <> 0 then
        // 'USB\VID_FFFF&PID_FFFF\0123456789ABCDEF'
        SetLength( DevInstanceName, i - 1 );
    end;
    RegCloseKey( Key );
  end;

  VidPidPos := Pos( LowerCase( 'vid_' ), LowerCase( DevPathName ) );
  if VidPidPos <> 0 then
    VidPidStr := Copy( DevPathName, VidPidPos, 17 )
  else
  begin
    VidPidPos := Pos( LowerCase( 'vid_' ), LowerCase( DevInstanceName ) );
    if VidPidPos <> 0 then
      VidPidStr := Copy( DevInstanceName, VidPidPos, 17 );
  end;

  Vid := 0;
  Pid := 0;
  Result := FALSE;
  if VidPidStr <> '' then
  begin
    Vid := StrToInt( '$' + Copy( VidPidStr, 5, 4 ) );
    Pid := StrToInt( '$' + Copy( VidPidStr, 14, 4 ) );
    Result := TRUE;
  end;
end;

// -----------------------------------------------------------------------------
// Query A Descriptor from Descriptor Buffer
//
function USB_ParseDescriptor( DescriptorBuffer : PBYTE; BufferSize : DWORD;
  DescriptorType : DWORD; var pNextDescriptor : PBYTE )
  : PUSB_COMMON_DESCRIPTOR;
begin
  while TRUE do
  begin
    Result := PUSB_COMMON_DESCRIPTOR( pNextDescriptor );
    pNextDescriptor := pNextDescriptor + Result.bLength;

    if PBYTE( Result ) >= DescriptorBuffer + BufferSize then
    begin
      Result := nil;
      Exit;
    end;

    if Result.bDescriptorType = DescriptorType then
      Exit;
  end;
end;

// -----------------------------------------------------------------------------
// Query An Interface Descriptor from Configuration Descriptor
//
function USB_ParseInterfaceDescriptor( ConfDescriptor
  : PUSB_CONFIGURATION_DESCRIPTOR; InterfaceNumber, AltSetting, InterfaceClass,
  InterfaceSubClass, InterfaceProtocol : Integer; var IfDescriptorSize : DWORD;
  var pNextDescriptor : PBYTE ) : PUSB_INTERFACE_DESCRIPTOR;
var
  pNextIfDescriptor : PUSB_INTERFACE_DESCRIPTOR;
begin
  Result := nil;
  while TRUE do
  begin
    pNextIfDescriptor := PUSB_INTERFACE_DESCRIPTOR
      ( USB_ParseDescriptor( PBYTE( ConfDescriptor ),
      ConfDescriptor.wTotalLength, USB_INTERFACE_DESCRIPTOR_TYPE,
      pNextDescriptor ) );

    if pNextIfDescriptor = nil then
      break;

    if ( InterfaceNumber <> -1 ) and
      ( pNextIfDescriptor.bInterfaceNumber <> InterfaceNumber ) then
      continue;

    if ( AltSetting <> -1 ) and ( pNextIfDescriptor.bAlternateSetting <>
      AltSetting ) then
      continue;

    if ( InterfaceClass <> -1 ) and
      ( pNextIfDescriptor.bInterfaceClass <> InterfaceClass ) then
      continue;

    if ( InterfaceSubClass <> -1 ) and
      ( pNextIfDescriptor.bInterfaceSubClass <> InterfaceSubClass ) then
      continue;

    if ( InterfaceProtocol <> -1 ) and
      ( pNextIfDescriptor.bInterfaceProtocol <> InterfaceProtocol ) then
      continue;

    if Result <> nil then
      break;

    Result := pNextIfDescriptor;
    InterfaceNumber := -1;
    AltSetting := -1;
  end;

  IfDescriptorSize := 0;
  if Result = nil then
    Exit;

  if pNextIfDescriptor = nil then
    pNextIfDescriptor := PUSB_INTERFACE_DESCRIPTOR( DWORD( ConfDescriptor ) +
      ConfDescriptor.wTotalLength );

  IfDescriptorSize := DWORD( pNextIfDescriptor ) - DWORD( Result );
end;

// -----------------------------------------------------------------------------
// The SetupDiClassNameFromGuid function retrieves the class name associated
// with a class GUID. e.g. {36FC9E60-C465-11CF-8056-444553540000}
//
function USB_GetDeviceClassName( ClassGUID : TGUID ) : string;
const
  MAX_CLASS_NAME_LEN = 128;
var
  ClassName : PAnsiChar;
  ClassNameSize : DWORD;
begin
  ClassNameSize := 0;
  GetMem( ClassName, ClassNameSize );
  while not SetupDiClassNameFromGuid( @ClassGUID, ClassName, ClassNameSize,
    @ClassNameSize ) do
  begin
    if GetLastError( ) <> ERROR_INSUFFICIENT_BUFFER then
      break;
    if ClassName <> nil then
      FreeMem( ClassName );
    GetMem( ClassName, ClassNameSize );
  end;

  Result := ClassName;
  if ClassName <> nil then
    FreeMem( ClassName );
end;

// -----------------------------------------------------------------------------
// The SetupDiGetClassDevs function returns a handle to a device information set
// that contains requested device information elements for a local computer.
// a device setup class or a device interface class.
//
// DIGCF_DEVICEINTERFACE : Return devices that support device interfaces
// for the specified device interface classes.
// DIGCF_PRESENT : Return only devices that are currently present in a system.
//
// The SetupDiEnumDeviceInterfaces function enumerates the device interfaces
// that are contained in a device information set.
// MemberIndex : A zero-based index into the list of interfaces
// in the device information set
//
// The SetupDiGetDeviceInterfaceDetail function returns details
// about a device interface.
//

function USB_GetDevicePathNames( DevInterfaceGUID : TGUID )
  : TUSB_DEVICE_PATH_NAMES;
var
  i : Integer;
  hDevInfo : THandle;

  DevInterfaceDataSize : LongWord;
  DevInformationData : SP_DEVINFO_DATA;
  DevInterfaceData : SP_DEVICE_INTERFACE_DATA;
  pDevInterfaceDetailData : PSP_DEVICE_INTERFACE_DETAIL_DATA;

  DevPathIndex : Integer;
  DevPathCount : Integer;
begin
  // Get information about all the installed  (plugged in) devices
  // for the specified device interface class.
  hDevInfo := SetupDiGetClassDevs( @DevInterfaceGUID, nil, 0, DIGCF_PRESENT or
    DIGCF_DEVICEINTERFACE );

  if hDevInfo = INVALID_HANDLE_VALUE then
  begin
    GetLastError( );
    Exit;
  end;

  try
    // Prepare to enumerate all device interfaces for the device information
    // set that we retrieved with SetupDiGetClassDevs(..)
    // we will keep calling this SetupDiEnumDeviceInterfaces(..) until this
    // function causes GetLastError() to return  ERROR_NO_MORE_ITEMS. With each
    // call the dwMemberIdx value needs to be incremented to retrieve the next
    // device interface information.
    DevInterfaceData.cbSize := SizeOf( DevInterfaceData );
    DevPathIndex := 0;
    DevPathCount := 0;
    SetLength( Result, DevPathIndex );

    while TRUE do
    begin

      SetupDiEnumDeviceInterfaces( hDevInfo, nil, DevInterfaceGUID,
        DevPathIndex, DevInterfaceData );
      if GetLastError( ) = ERROR_NO_MORE_ITEMS then
        break;

      // Interface data is returned in SP_DEVICE_INTERFACE_DETAIL_DATA
      // which we need to allocate, so we have to call this function twice.
      // First to get the required size so that we know how much to allocate
      // Call SetupDiGetDeviceInterfaceDetail with
      // a NULL DevIntfDetailData pointer, a DevIntfDetailDataSize
      // of zero, and a valid RequiredSize variable. In response to such a call,
      // this function returns the required buffer size at dwSize.
      DevInterfaceDataSize := 0;
      SetupDiGetDeviceInterfaceDetail( hDevInfo, @DevInterfaceData, nil, 0,
        @DevInterfaceDataSize, nil );
      if ( GetLastError( ) <> ERROR_INSUFFICIENT_BUFFER ) or
        ( DevInterfaceDataSize = 0 ) then
      begin
        Inc( DevPathIndex );
        continue;
      end;

      // Allocate memory for the DeviceInterfaceDetail struct after got the size
      // Don't forget to deallocate it later!
      GetMem( pDevInterfaceDetailData, DevInterfaceDataSize ); // EOutOfMemory

      DevInformationData.cbSize := SizeOf( SP_DEVINFO_DATA );
      if SizeOf( Pointer ) = 8 then
        pDevInterfaceDetailData.cbSize := 8
      else
        pDevInterfaceDetailData.cbSize := 5;

      if not SetupDiGetDeviceInterfaceDetail( hDevInfo, @DevInterfaceData,
        pDevInterfaceDetailData, DevInterfaceDataSize, @DevInterfaceDataSize,
        @DevInformationData ) then
      begin
        FreeMem( pDevInterfaceDetailData );
        Inc( DevPathIndex );
        continue;
      end;

      // -----------------------------------------------------------------------
      // The DevicePath looks something like this
      //
      // '\\?\usb#vid_ffff&pid_ffff#0123456789abcdef
      // #{798acd1a-5ef1-4159-97b7-d895bf85c6dd}'
      //
      // DevPath : StrPas( @pDevInterfaceDetailData.DevicePath )
      SetLength( Result, DevPathCount + 1 );
      SetString( Result[ DevPathCount ],
        PAnsiChar( @pDevInterfaceDetailData.DevicePath[ 0 ] ),
        DevInterfaceDataSize - 4 );
      FreeMem( pDevInterfaceDetailData );

      i := Pos( AnsiChar( #0 ), Result[ DevPathCount ] );
      if i <> 0 then
        SetLength( Result[ DevPathCount ], i - 1 );

      Inc( DevPathCount );
      Inc( DevPathIndex );
    end;

  finally
    SetupDiDestroyDeviceInfoList( hDevInfo );
  end;
end;

{ EUsbUtility }

constructor EUsbUtility.Create( AWinCode : Integer );
begin
  // raise UsbExcept.Create( GetLastError() );
  // RaiseLastOSError();
  inherited Create( SysErrorMessage( AWinCode ) );
end;

{ TUSBusbNotify }

constructor TusbNotify.Create( OnUSBNotify : TusbNotifyEvent );
var
  Size : Integer;
  dbi : DEV_BROADCAST_DEVICEINTERFACE;
begin
  inherited Create;

  FDeviceName := '';
  FOnUSBNotify := OnUSBNotify;

  FWindowHandle := AllocateHWnd( WndProc );

  Size := SizeOf( DEV_BROADCAST_DEVICEINTERFACE );
  ZeroMemory( @dbi, Size );

  dbi.dbcc_size := Size;
  dbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  dbi.dbcc_classguid := GUID_DEVINTERFACE_USB_DEVICE;

  FNotificationHandle := RegisterDeviceNotification( FWindowHandle, @dbi,
    DEVICE_NOTIFY_WINDOW_HANDLE );

  FTimer := TTimer.Create( nil );
  FTimer.Enabled := FALSE;
  FTimer.OnTimer := OnTimer;
end;

destructor TusbNotify.Destroy;
begin
  FTimer.Free;

  UnregisterDeviceNotification( FNotificationHandle );

  DeallocateHWnd( FWindowHandle );

  inherited Destroy;
end;

procedure TusbNotify.OnTimer( Sender : TObject );
begin
  FTimer.Enabled := FALSE;
  FOnUSBNotify( Self, FUsbNotifyAction, FDeviceName );
end;

// A null-terminated string that specifies the name of the device.
// When this structure is returned to a window through the WM_DEVICECHANGE msg,
// the dbcc_name string is converted to ANSI as appropriate.
// Services always receive a Unicode string, whether they call
// RegisterDeviceNotificationW or RegisterDeviceNotificationA.
//
// \\?\USB#VID_FFFF&PID_FFFF#0123456789ABCDEF#{a5dcbf10-6530-11d2-901f-00c04fb951ed}
// -------------------------------------------*****GUID_DEVINTERFACE_USB_DEVICE*****
// wParam : device-change event
// lParam : A pointer to a structure that contains event-specific data.
// Its format depends on the value of the wParam parameter.
// For more information, refer to the documentation for each event.
//
// However, by default, Windows OS will only post WM_DEVICECHANGE to
// All applications with a top-level window, and
// Only upon port and volume change.
//
procedure TusbNotify.WndProc( var Msg : TMessage );
var
  dbi : PDevBroadcastDeviceInterface;
  handled : boolean;
begin
  handled := FALSE;
  if Msg.Msg = WM_DEVICECHANGE then
  begin
    if ( ( Msg.wParam = DBT_DEVICEARRIVAL ) or
      ( Msg.wParam = DBT_DEVICEREMOVECOMPLETE ) ) then
    begin
      try
        dbi := PDevBroadcastDeviceInterface( Msg.lParam );
        if Assigned( FOnUSBNotify ) then
        begin
          if FTimer.Enabled = FALSE then
          begin
            FDeviceName := string( PWideChar( @dbi.dbcc_name ) );

            if ( Msg.wParam = DBT_DEVICEARRIVAL ) then
              FUsbNotifyAction := UsbArrival;

            if ( Msg.wParam = DBT_DEVICEREMOVECOMPLETE ) then
              FUsbNotifyAction := UsbRemoval;

            FTimer.Interval := 1000;
            FTimer.Enabled := TRUE;

            handled := TRUE;
          end;
        end;
      except
      end;
    end;
  end;

  if not handled then
    Msg.Result := DefWindowProc( FWindowHandle, Msg.Msg, Msg.wParam,
      Msg.lParam );
end;

function USB_IoControl( hControl : THandle; dwIoControlCode : DWORD;
  const lpInBuffer; nInBufferSize : DWORD; var lpOutBuffer;
  nOutBufferSize : DWORD; Timeout : DWORD; AsyncEvent : THandle ) : Integer;
begin
  Result := DeviceIoControlAsync( hControl, dwIoControlCode, lpInBuffer,
    nInBufferSize, lpOutBuffer, nOutBufferSize, Timeout, AsyncEvent );
end;

function USB_Read( hRead : THandle; var Buffer; BufferLength : DWORD;
  Timeout : DWORD; AsyncEvent : THandle ) : Integer;
begin
  Result := ReadAsync( hRead, Buffer, BufferLength, Timeout, AsyncEvent );
end;

function USB_Write( hWrite : THandle; const Buffer; BufferLength : DWORD;
  Timeout : DWORD; AsyncEvent : THandle ) : Integer;
begin
  Result := WriteAsync( hWrite, Buffer, BufferLength, Timeout, AsyncEvent );
end;

end.
