unit uJLinkJtag;

interface

uses
  SysUtils, Windows, Classes, uJLinkProtocol, uJtagTap;

type

  TJLINK_JTAG = class( TJLINK_Protocol )
  private
    FDeviceConfig : TJTAG_DeviceConfig;

    FCaps : TJLINK_Caps;
    FSpeed : TJLINK_Speed;
    FState : TJLINK_State;
    FHwInfo : TJLINK_HwInfo;
    FTapState : TJTAG_TAP_State;

    FJtagAcc : TJLINK_JTAG_ACC;
    FJataAccTMS : array [ 0 .. JTAG_MAX_BIT_STREAM_LENGTH - 1 ] of Byte;
    FJataAccTDI : array [ 0 .. JTAG_MAX_BIT_STREAM_LENGTH - 1 ] of Byte;
    FJataAccTDO : array [ 0 .. JTAG_MAX_BIT_STREAM_LENGTH - 1 ] of Byte;

    procedure JtagAccBuild( JtagAcc : TJLINK_JTAG_ACC; TDI : DWORD;
      TMS : DWORD );
    function JtagAccDebuild( JtagAcc : TJLINK_JTAG_ACC ) : Boolean;

  public
    constructor Create( AbortEvent : THandle = 0 );
    destructor Destroy; override;

    function Open( UsbDeviceName : string; DeviceConfig : TJTAG_DeviceConfig )
      : Boolean;
    procedure Close( );

    function Reinit( UsbDeviceName : string; DeviceConfig : TJTAG_DeviceConfig )
      : Boolean;

    function TargetAttached( var Attached : Boolean ) : Boolean;
    function RSTActive( ) : Boolean;
    function RSTDeactive( ) : Boolean;
    function TRSTActive( ) : Boolean;
    function TRSTDeactive( ) : Boolean;
    function TAPReset( UseTrst : Boolean ) : Boolean;
    function TAPRunTestIdle( ) : Boolean;
    function TAPGetState( var TAPState : TJTAG_TAP_State ) : Boolean;
    function TAPMoveTo( const TAPState : TJTAG_TAP_State ) : Boolean;
    function TransferData( const DataOut; var DataIn ) : Boolean;
    function TransferInst( const InstOut; var InstIn ) : Boolean;
  end;

implementation

{ TJLINK_JTAG }

constructor TJLINK_JTAG.Create( AbortEvent : THandle );
begin
  inherited Create( AbortEvent );
end;

destructor TJLINK_JTAG.Destroy;
begin
  inherited Destroy;
end;

procedure TJLINK_JTAG.JtagAccBuild( JtagAcc : TJLINK_JTAG_ACC;
  TDI, TMS : DWORD );
begin

end;

function TJLINK_JTAG.JtagAccDebuild( JtagAcc : TJLINK_JTAG_ACC ) : Boolean;
begin

end;

function TJLINK_JTAG.Open( UsbDeviceName : string;
  DeviceConfig : TJTAG_DeviceConfig ) : Boolean;
var
  AvailableInterface : DWORD;
begin
  Result := inherited Open( UsbDeviceName );
  if not Result then
    Exit( Result );

  FTapState := TAP_INVALID;
  FJtagAcc.NumBits := 0;
  FJtagAcc.TMS := @FJtagAcc.TMS;
  FJtagAcc.TDI := @FJtagAcc.TDI;
  FJtagAcc.TDO := @FJtagAcc.TDO;

  Result := GetCaps( FCaps );
  if not Result then { faild to read caps... }
    Exit( Result );

  if FCaps.Caps and JLINK_EMU_CAP_GET_CPU_CAPS > 0 then
  begin
    Result := GetCapsEx( FCaps );
    if not Result then { faild to read caps ex... }
      Exit( Result );
  end;

  if FCaps.Caps and JLINK_EMU_CAP_SPEED_INFO > 0 then
  begin
    Result := GetSpeed( FSpeed );
    if not Result then { faild to get speed... }
      Exit( Result );
  end;

  if FCaps.Caps and JLINK_EMU_CAP_EX_GET_HW_INFO > 0 then
  begin
    Result := GetHwInfo( FHwInfo );
    if not Result then { faild to get hardware info... }
      Exit( Result );
  end;

  Result := GetState( FState );
  if not Result then { faild to get pin status... }
    Exit( Result );

  Result := GetAvailableInterface( AvailableInterface );
  if not Result then { faild to get interface... }
    Exit( Result );

  if AvailableInterface and JLINK_TIF_JTAG_MASK > 0 then
  begin
    Result := SetCurrentInterface( JLINK_TIF_JTAG );
    if not Result then { faild to set interface 0x00... }
      Exit( Result );
  end;

  Exit( True );
end;

procedure TJLINK_JTAG.Close;
begin
  inherited Close;
end;

function TJLINK_JTAG.Reinit( UsbDeviceName : string;
  DeviceConfig : TJTAG_DeviceConfig ) : Boolean;
begin
  Close;
  Result := Open( UsbDeviceName, DeviceConfig );
end;

function TJLINK_JTAG.TargetAttached( var Attached : Boolean ) : Boolean;
begin
  Attached := GetState( FState );
  if Attached then
  begin
    if FState.Voltage < 1000 then
      Attached := False;
  end;
  Exit( Attached );
end;

function TJLINK_JTAG.RSTActive : Boolean;
begin
  Result := HwReset0( );
end;

function TJLINK_JTAG.RSTDeactive : Boolean;
begin
  Result := HwReset1( );
end;

function TJLINK_JTAG.TRSTActive : Boolean;
begin
  Result := HwTrst0( );
end;

function TJLINK_JTAG.TRSTDeactive : Boolean;
begin
  Result := HwTrst1( );
end;

function TJLINK_JTAG.TAPGetState( var TAPState : TJTAG_TAP_State ) : Boolean;
begin

end;

function TJLINK_JTAG.TAPMoveTo( const TAPState : TJTAG_TAP_State ) : Boolean;
begin

end;

function TJLINK_JTAG.TAPReset( UseTrst : Boolean ) : Boolean;
begin

end;

function TJLINK_JTAG.TAPRunTestIdle : Boolean;
begin

end;

function TJLINK_JTAG.TransferData( const DataOut; var DataIn ) : Boolean;
begin

end;

function TJLINK_JTAG.TransferInst( const InstOut; var InstIn ) : Boolean;
begin

end;

end.
