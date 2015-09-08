program SeggerRTT;

{$R 'Logo.res' 'Logo.rc'}

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {MainForm} ,
  uDeviceForm in 'uDeviceForm.pas' {DeviceForm} ,
  uWorker in 'uWorker.pas',
  uUtility in 'uUtility.pas',
  uSeggerRTT in 'uSeggerRTT.pas',
  uJLinkARM in 'uJLinkARM.pas',
  uJLinkUsb in 'uJLinkUsb.pas',
  uAsyncIo in 'uAsyncIo.pas',
  uUsbCommon in 'uUsbCommon.pas',
  uJLinkJtag in 'uJLinkJtag.pas',
  uJLinkProtocol in 'uJLinkProtocol.pas',
  uJtagTap in 'uJtagTap.pas',
  uAboutForm in 'uAboutForm.pas' {AboutBox} ,
  uSettingForm in 'uSettingForm.pas' {SettingForm} ,
  uDelayExcept in 'uDelayExcept.pas';

{$R *.res}

begin
  if JLINKARM_IsFound( ) then
  begin
    Application.Initialize;
    Application.Title := 'Segger RTT';
    Application.MainFormOnTaskbar := True;
    Application.CreateForm( TMainForm, MainForm );
    Application.Run;
  end;

end.
