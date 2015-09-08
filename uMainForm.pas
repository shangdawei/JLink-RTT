unit uMainForm;

interface

uses
  Windows,
  Messages,
  StrUtils,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.Mask,
  IniFiles,
  VirtualTrees,
  uDelayExcept,
  uUsbCommon,
  uJLinkUsb,
  uJLinkARM,
  uSeggerRTT,
  uWorker,
  Vcl.Grids,
  Vcl.ImgList,
  dcrHexEditorEx,
  dcrHexEditor, System.ImageList;

type

  PLogData = ^TLogData;

  TLogData = record
    LogType : TJLINKARM_Log;
    LogText : string;
  end;

  TTerminalDir = (tdRx, tdTx);

  PTerminalData = ^TTerminalData;

  TTerminalData = record
    Dir : TTerminalDir;
    Text : string;
  end;

type
  TMainForm = class(TForm)
    StatusBar : TStatusBar;
    DlgOpen : TOpenDialog;
    PopupMenu : TPopupMenu;
    Panel2 : TPanel;
    Splitter1 : TSplitter;
    ControlPanel : TPanel;
    JLinkBox : TGroupBox;
    Label1 : TLabel;
    Label2 : TLabel;
    Label3 : TLabel;
    cboJlinkArmSpeed : TComboBox;
    cboJlinkArmInterface : TComboBox;
    cboJLinkDriver : TComboBox;
    AppEvents : TApplicationEvents;
    edtActualJLinkArmSpeed : TEdit;
    Label11 : TLabel;
    DlgSave : TSaveDialog;
    btnDriverUSB : TRadioButton;
    btnDriverIP : TRadioButton;
    edtJLinkDriver : TMaskEdit;
    Label6 : TLabel;
    edtRTTControlBlock : TEdit;
    PageControl1 : TPageControl;
    TabSheetTerminal : TTabSheet;
    TabSheetRawRx : TTabSheet;
    vstTerminal : TVirtualStringTree;
    btnAbout : TButton;
    Clear1 : TMenuItem;
    Save1 : TMenuItem;
    LogTypeImageList : TImageList;
    TextHexImageList : TImageList;
    RawRxHex : TMPHexEditorEx;
    RawTxHex : TMPHexEditorEx;
    Label5 : TLabel;
    edtDevice : TEdit;
    btnClose : TButton;
    btnSetting : TButton;
    btnConnect : TButton;
    Panel1 : TPanel;
    TabSheetRawTx : TTabSheet;
    PageControl2 : TPageControl;
    TabSheetLog : TTabSheet;
    vstLog : TVirtualStringTree;
    TerminalSendPanel : TPanel;
    edtInput : TEdit;
    btnTerminalSend : TButton;
    RawSendPanel : TPanel;
    edtRawFileName : TEdit;
    btnRawSend : TButton;
    procedure FormCreate(Sender : TObject);
    procedure FormDestroy(Sender : TObject);
    procedure btnDriverUSBClick(Sender : TObject);
    procedure btnDriverIPClick(Sender : TObject);
    procedure edtJLinkDriverExit(Sender : TObject);
    procedure btnConnectClick(Sender : TObject);

    procedure vstLogGetText(Sender : TBaseVirtualTree; Node : PVirtualNode;
      Column : TColumnIndex; TextType : TVSTTextType; var CellText : string);

    procedure vstLogPaintText(Sender : TBaseVirtualTree;
      const TargetCanvas : TCanvas; Node : PVirtualNode; Column : TColumnIndex;
      TextType : TVSTTextType);

    procedure vstLogGetImageIndex(Sender : TBaseVirtualTree;
      Node : PVirtualNode; Kind : TVTImageKind; Column : TColumnIndex;
      var Ghosted : Boolean; var ImageIndex : Integer);

    procedure vstTerminalGetText(Sender : TBaseVirtualTree; Node : PVirtualNode;
      Column : TColumnIndex; TextType : TVSTTextType; var CellText : string);

    procedure AppEventsIdle(Sender : TObject; var Finished : Boolean);
    procedure cboJlinkArmSpeedChange(Sender : TObject);
    procedure cboJlinkArmInterfaceChange(Sender : TObject);
    procedure edtRTTControlBlockKeyPress(Sender : TObject; var Key : Char);
    procedure edtRTTControlBlockExit(Sender : TObject);
    procedure btnAboutClick(Sender : TObject);
    procedure Clear1Click(Sender : TObject);
    procedure Save1Click(Sender : TObject);
    procedure edtDeviceDblClick(Sender : TObject);
    procedure btnCloseClick(Sender : TObject);
    procedure btnSettingClick(Sender : TObject);
    procedure RawRxHexData(Sender : TObject; const Offset : Int64;
      var Data : Byte);
    procedure FormResize(Sender : TObject);
    procedure btnTerminalSendClick(Sender : TObject);
    procedure btnRawSendClick(Sender : TObject);
    procedure edtRawFileNameDblClick(Sender : TObject);
    procedure RawTxHexData(Sender : TObject; const Offset : Int64;
      var Data : Byte);
    procedure edtRawFileNameKeyPress(Sender : TObject; var Key : Char);
    procedure StatusBarDrawPanel(StatusBar : TStatusBar; Panel : TStatusPanel;
      const Rect : TRect);
    procedure edtInputKeyPress(Sender : TObject; var Key : Char);
    procedure vstTerminalPaintText(Sender : TBaseVirtualTree;
      const TargetCanvas : TCanvas; Node : PVirtualNode; Column : TColumnIndex;
      TextType : TVSTTextType);
  private

    procedure WMGetMinMaxInfo(var Msg : TWMGetMinMaxInfo);
      message WM_GETMINMAXINFO;

    procedure RawTxSave;
    procedure RawRxSave;
    procedure vstLogSave;
    procedure vstTerminalSave;
    procedure vstTerminalAddNode(TerminalDir : TTerminalDir; Str : string);
    procedure vstTerminalAddNodes(TerminalDir : TTerminalDir;
      Strings : TStringList);

    procedure UpdateDeviceInfo;
    procedure LoadIniFile;
    procedure SaveIniFile;

    function SaveBeforeConnect : Integer;
    function OpenJLinkARM : Boolean;
    function ConnectMCU : Boolean;
    procedure DisconnectMCU;
    procedure ResetStatusBar;
    procedure OnJlinkLog(JLINKARM_Log : TJLINKARM_Log; Info : string);
    procedure OnUsbNotify(Sender : TObject; UsbNotifyType : TUsbNotifyAction;
      const DeviceName : string);

    procedure FindWorkerState(Sender : TWorker; State : TWorkerState);
    procedure FindWorkerProgress(Sender : TWorker; Progress : Integer);
    function FindWorkerWork(Sender : TWorker; Param : TObject) : TWorkerState;

    procedure TransferWorkTimer();
    procedure TransferWorkerStart();
    procedure TransferWorkerData(Sender : TWorker; Count : Integer;
      Data0, Data1, Data2, Data3 : TObject);
    procedure TransferWorkerProgress(Sender : TWorker; Progress : Integer);
    procedure TransferWorkerState(Sender : TWorker; State : TWorkerState);
    procedure TransferWorkerQuery(Sender : TWorker; var Query : TWorkerQuery);
    function TransferWorkerWork(Sender : TWorker; Param : TObject)
      : TWorkerState;

  public
    { Public declarations }
    usbNotify : TusbNotify;
    FindWorker : TWorker;
    TransferWorker : TWorker;
    WorkerMgr : TWorkerMgr;
    SeggerRTT : TSeggerRTT;
    TxMemoryStream : TMemoryStream;
    RxStringList : TStringList;
  end;

var
  MainForm : TMainForm;

implementation

{$R *.dfm}

uses
  uDeviceForm,
  uAboutForm,
  uSettingForm,
  uUtility;

type
  TJLINKARM_DriverType = (jdUSB, jdIP);

const
  IniFileName : string = 'SeggerRTT.ini';
  LogFileName : string = 'SeggerRTT.log';

const
  RX_BUFFER_MAX_SIZE = $1000;

var
  cboJlinkDriverEnabled : Boolean;
  cboJlinkInterfaceEnabled : Boolean;

  btnConnectEnabled : Boolean;
  btnRawSendEnabled : Boolean;
  btnTerminalSendEnabled : Boolean;

  HostPortName : string;
  UsbDeviceName : string;

  JLINKARM_ManuafacturerName : string;
  JLINKARM_DeviceName : AnsiString;

  JLINKARM_DriverType : TJLINKARM_DriverType;
  JLINKARM_Speed : Integer;
  JLINKARM_Interface : TJLINKARM_Inteface;
  JLINKARM_Device : TJLINKARM_Device;

  TxString : string;
  TxStringPending : Boolean;
  TxMemoryStreamPending : Boolean;
  TxStringAbort : Boolean;
  TxMemoryStreamAbort : Boolean;

  TotalTxSize : Integer;
  PreviousTxSize : Integer;
  TxtTxSize : Integer;
  RawTxSize : Integer;

  TotalRxSize : Integer;
  PreviousRxSize : Integer;

  TxtRxSize : Integer;
  TxtBuffer : array [0 .. RX_BUFFER_MAX_SIZE - 1 + 1] of Byte;
  // Last Byte is NULL marker to split strings

  RawRxSize : Integer;

  RawRxHexCapacity : Integer;
  RawRxHexOffset : Integer;
  RawRxHexBuffer : array of Byte;

  PrevTickCount, TickCount : Cardinal;
  TickCountDelta : Cardinal;

procedure TMainForm.AppEventsIdle(Sender : TObject; var Finished : Boolean);
begin
  cboJlinkArmInterface.Enabled := not SeggerRTT.DeviceConnected;
  btnDriverUSB.Enabled := not SeggerRTT.DeviceConnected;
  btnDriverIP.Enabled := not SeggerRTT.DeviceConnected;
  cboJLinkDriver.Enabled := not SeggerRTT.DeviceConnected;
  edtDevice.Enabled := not SeggerRTT.DeviceConnected;
  btnSetting.Enabled := not SeggerRTT.DeviceConnected;
  edtRTTControlBlock.Enabled := not SeggerRTT.FFound;

  btnTerminalSend.Enabled := SeggerRTT.FFound and (edtInput.Text <> '') and
    btnTerminalSendEnabled and (SeggerRTT.FInfo.MaxNumDonwBuffers > 0);
  btnRawSend.Enabled := SeggerRTT.FFound and (RawTxHex.DataSize > 0) and
    btnRawSendEnabled and (SeggerRTT.FInfo.MaxNumDonwBuffers > 1);
end;

procedure TMainForm.ResetStatusBar;
begin
  StatusBar.Panels[0].Text := 'Disconnected';
  StatusBar.Panels[1].Text := '';
  StatusBar.Panels[2].Text := '';
  StatusBar.Panels[3].Text := '';
  StatusBar.Panels[4].Text := '';
  StatusBar.Panels[5].Text := '';
  StatusBar.Panels[6].Text := '';
end;

procedure TMainForm.TransferWorkTimer();
var
  RxByteSize : Integer;
  TxByteSize : Integer;
begin
  RxByteSize := TotalRxSize - PreviousRxSize;
  PreviousRxSize := TotalRxSize;
  StatusBar.Panels[3].Text := Format('Rx %3.3f KB/s',
    [RxByteSize / 1024 / TickCountDelta * 1000]);

  TxByteSize := TotalTxSize - PreviousTxSize;
  PreviousTxSize := TotalTxSize;
  StatusBar.Panels[6].Text := Format('Tx %3.3f KB/s',
    [TxByteSize / 1024 / TickCountDelta * 1000]);
end;

procedure TMainForm.btnAboutClick(Sender : TObject);
begin
  with TAboutBox.Create(Self) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TMainForm.btnConnectClick(Sender : TObject);
var
  Information : TStringList;
  I : Integer;
begin
  btnConnect.Enabled := False;

  if btnConnect.Caption = 'Disconnect' then
  begin
    if Assigned(TransferWorker) then
      TransferWorker.Abort();

    DisconnectMCU();

  end
  else
  begin
    if not OpenJLinkARM() then
    begin
      btnConnect.Enabled := True;
      Exit;
    end;

    Information := TStringList.Create;
    try
      SeggerRTT.GetInformation(Information);
      for I := 0 to Information.Count - 1 do
        OnJlinkLog(jlInformation, Information.Strings[I]);
    finally
      Information.Free;
    end;

    if ConnectMCU() then
      btnConnect.Caption := 'Disconnect';
  end;

  btnConnect.Enabled := True;
end;

procedure TMainForm.btnDriverIPClick(Sender : TObject);
begin
  if not btnDriverIP.Checked then
    btnDriverIP.Checked := True;

  edtJLinkDriver.Text := HostPortName;
  edtJLinkDriver.BringToFront;
end;

procedure TMainForm.btnDriverUSBClick(Sender : TObject);
begin
  if not btnDriverUSB.Checked then
    btnDriverUSB.Checked := True;

  cboJLinkDriver.Items.Clear;
  SeggerRTT.UsbEnumDevices(cboJLinkDriver.Items);

  if cboJLinkDriver.Items.Count > 0 then
  begin
    cboJLinkDriver.ItemIndex := 0;
    cboJLinkDriver.BringToFront;
  end
  else
  begin
    cboJLinkDriver.ItemIndex := -1;
    btnDriverIPClick(Self);
  end;
end;

procedure TMainForm.btnSettingClick(Sender : TObject);
var
  ModelVal : Integer;
  NewCapacity : Integer;
begin
  NewCapacity := RawRxHexCapacity div 1024 div 1024;
  with TSettingForm.Create(Self, @NewCapacity) do
  begin
    try
      ModelVal := ShowModal;
    finally
      if NewCapacity * 1024 * 1024 <> RawRxHexCapacity then
      begin
        RawRxHexCapacity := NewCapacity * 1024 * 1024;
        SetLength(RawRxHexBuffer, RawRxHexCapacity);
      end;
      Free;
    end;
  end;
end;

procedure TMainForm.btnCloseClick(Sender : TObject);
begin
  Close();
end;

procedure TMainForm.cboJlinkArmInterfaceChange(Sender : TObject);
begin
  if cboJlinkArmInterface.ItemIndex = 0 then
    JLINKARM_Interface := jiAuto
  else if cboJlinkArmInterface.ItemIndex = 1 then
    JLINKARM_Interface := jiJTAG // JTAG
  else if cboJlinkArmInterface.ItemIndex = 2 then
    JLINKARM_Interface := jiSWD; // SWD
end;

procedure TMainForm.cboJlinkArmSpeedChange(Sender : TObject);
begin
  JLINKARM_Speed := JLinkARM_SpeedValues[cboJlinkArmSpeed.ItemIndex];

  if SeggerRTT.DeviceConnected then
  begin
    SeggerRTT.SetSpeed(JLINKARM_Speed);
    JLINKARM_Speed := SeggerRTT.GetSpeed();
    edtActualJLinkArmSpeed.Text := IntToStr(JLINKARM_Speed div 1000) + ' KHz';
  end;
end;

procedure TMainForm.edtDeviceDblClick(Sender : TObject);
var
  ModalResult : Integer;
  DeviceForm : TDeviceForm;
begin
  if edtDevice.Text <> '' then
    JLINKARM_Device.DeviceName := edtDevice.Text;

  DeviceForm := TDeviceForm.Create(Self, SeggerRTT, @JLINKARM_Device);
  try
    ModalResult := DeviceForm.ShowModal();
    if ModalResult = mrCancel then
      Exit;

    UpdateDeviceInfo();

    if SeggerRTT.DllOpened then
    begin
      if not SeggerRTT.SetDeviceName(JLINKARM_DeviceName) then
        OnJlinkLog(jlError, Format('Can not select device : %s',
          [JLINKARM_DeviceName]));
    end;
  finally
    DeviceForm.Free;
  end;
end;

procedure TMainForm.edtInputKeyPress(Sender : TObject; var Key : Char);
begin
  if Key = Char(VK_Return) then
  begin
    Key := #0;
    if btnTerminalSend.Enabled then
      btnTerminalSendClick(btnTerminalSend);
  end;
end;

procedure TMainForm.edtJLinkDriverExit(Sender : TObject);
begin
  HostPortName := edtJLinkDriver.Text;
end;

procedure TMainForm.edtRawFileNameDblClick(Sender : TObject);
begin
  if DlgOpen.Execute then
  begin
    edtRawFileName.Text := DlgOpen.FileName;
    TxMemoryStream.LoadFromFile(edtRawFileName.Text);
    RawTxHex.DataSize := TxMemoryStream.Size;
  end;
end;

procedure TMainForm.edtRawFileNameKeyPress(Sender : TObject; var Key : Char);
begin
  if Key = Char(VK_Return) then
  begin
    Key := #0;
    if FileExists(edtRawFileName.Text) then
    begin
      TxMemoryStream.LoadFromFile(edtRawFileName.Text);
      RawTxHex.DataSize := TxMemoryStream.Size;
    end;
  end;
end;

procedure TMainForm.edtRTTControlBlockExit(Sender : TObject);
var
  Str : string;
begin
  try
    Str := Copy(edtRTTControlBlock.Text, 3,
      Length(edtRTTControlBlock.Text) - 2);
    SeggerRTT.FFind.userAddress := StrToInt('$' + Str);
  except
    edtRTTControlBlock.Text := '0x' + IntToHex(JLINKARM_Device.SramBase, 8);
    SeggerRTT.FFind.userAddress := JLINKARM_Device.SramBase;
  end;

  // Finding RTT Control Bloack ....
  SeggerRTT.FFind.SramBase := JLINKARM_Device.SramBase;
  SeggerRTT.FFind.SramSize := JLINKARM_Device.SramSize;
  SeggerRTT.FFind.SramOffset := SeggerRTT.FFind.userAddress -
    SeggerRTT.FFind.SramBase;
end;

procedure TMainForm.edtRTTControlBlockKeyPress(Sender : TObject;
  var Key : Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    edtRTTControlBlockExit(edtRTTControlBlock);
  end;
end;

procedure TMainForm.FormCreate(Sender : TObject);
var
  I : Integer;
begin
  TThread.CurrentThread.NameThreadForDebugging('Main');

  vstLog.NodeDataSize := sizeof(TLogData);
  vstLog.RootNodeCount := 0;
  vstLog.Header.AutoSizeIndex := vstLog.Header.Columns.Count;

  vstTerminal.NodeDataSize := sizeof(TTerminalData);
  vstTerminal.RootNodeCount := 0;
  vstTerminal.Header.AutoSizeIndex := vstTerminal.Header.Columns.Count;

  cboJlinkInterfaceEnabled := True;
  btnTerminalSendEnabled := True;
  btnRawSendEnabled := True;

  ResetStatusBar();

  LoadIniFile();

  usbNotify := TusbNotify.Create(OnUsbNotify);

  try
    SeggerRTT := TSeggerRTT.Create(OnJlinkLog, LogFileName);
  except
    Close;
  end;

  WorkerMgr := TWorkerMgr.Create();

  TxMemoryStream := TMemoryStream.Create;
  RxStringList := TStringList.Create;

  if btnDriverIP.Checked then
    btnDriverIPClick(Self)
  else if btnDriverUSB.Checked then
    btnDriverUSBClick(Self);

  if cboJLinkDriver.ItemIndex = -1 then
    btnDriverIPClick(Self);

end;

procedure TMainForm.FormDestroy(Sender : TObject);
begin
  if Assigned(RxStringList) then
    RxStringList.Free;

  if Assigned(TxMemoryStream) then
    TxMemoryStream.Free;

  if Assigned(WorkerMgr) then
    WorkerMgr.Free;

  if Assigned(SeggerRTT) then
    SeggerRTT.Free;

  if Assigned(usbNotify) then
    usbNotify.Free;

  SaveIniFile();
end;

procedure TMainForm.FormResize(Sender : TObject);
begin
  edtInput.Width := TerminalSendPanel.Width - 110;
  btnTerminalSend.Left := edtInput.Width + 15;

  edtRawFileName.Width := RawSendPanel.Width - 110;
  btnRawSend.Left := edtRawFileName.Width + 15;
end;

procedure TMainForm.LoadIniFile;
var
  INIFile : TIniFile;
  JLinkInterfaceVal : Integer;
  JLinkDriverVal : Integer;
  JLinkARM_SpeedValuesCount : Integer;
  I : Integer;
  DeviceName : string;
  DeviceIndex : Integer;
  DeviceInfo : TJLINKARM_DeviceInfo;
begin
  INIFile := TIniFile.Create(ExtractFilePath(Paramstr(0)) + IniFileName);
  try
    RawRxHexCapacity := INIFile.ReadInteger('CAPACITY', 'CAPACITY', 128);
    RawRxHexCapacity := RawRxHexCapacity * 1024 * 1024;
    SetLength(RawRxHexBuffer, RawRxHexCapacity);

    // Check Driver
    // 0 =  USB, 1 = IP
    JLinkDriverVal := INIFile.ReadInteger('JLINK', 'DRIVER', 0);
    if JLinkDriverVal = 0 then
      btnDriverUSB.Checked := True
    else
      btnDriverIP.Checked := True;

    HostPortName := INIFile.ReadString('JLINK', 'HOSTPORT',
      '127.000.000.001:19020');
    if HostPortName = '' then
      HostPortName := '127.000.000.001:19020';

    // Check Interface Value
    // Auto -- 0, JTAG -- 1, SWD  -- 2
    JLinkInterfaceVal := INIFile.ReadInteger('JLINK', 'INTERFACE', 0);
    if JLinkInterfaceVal = 1 then
    begin
      cboJlinkArmInterface.ItemIndex := 1;
      JLINKARM_Interface := jiJTAG;
    end
    else if JLinkInterfaceVal = 2 then
    begin
      cboJlinkArmInterface.ItemIndex := 2;
      JLINKARM_Interface := jiSWD;
    end
    else
    begin
      cboJlinkArmInterface.ItemIndex := 0;
      JLINKARM_Interface := jiAuto;
    end;

    // Check Speed Value
    JLinkARM_SpeedValuesCount := sizeof(JLinkARM_SpeedValues)
      div sizeof(JLinkARM_SpeedValues[0]);
    cboJlinkArmSpeed.Items.Clear;
    for I := 0 to JLinkARM_SpeedValuesCount - 1 do
      cboJlinkArmSpeed.Items.Append(JLINKARM_SpeedStrings[I]);

    JLINKARM_Speed := INIFile.ReadInteger('JLINK', 'SPEED', -1);

    if JLINKARM_Speed <> -1 then
    begin
      for I := low(JLinkARM_SpeedValues) to high(JLinkARM_SpeedValues) do
      begin
        if JLINKARM_Speed <= JLinkARM_SpeedValues[I] then
        begin
          JLINKARM_Speed := JLinkARM_SpeedValues[I];
          break;
        end;
      end;
    end;

    if JLINKARM_Speed > JLinkARM_SpeedValues[high(JLinkARM_SpeedValues)] then
      JLINKARM_Speed := JLinkARM_SpeedValues[high(JLinkARM_SpeedValues)];

    for I := low(JLinkARM_SpeedValues) to high(JLinkARM_SpeedValues) do
    begin
      if JLINKARM_Speed = JLinkARM_SpeedValues[I] then
      begin
        cboJlinkArmSpeed.ItemIndex := I;
        break;
      end;
    end;

    DeviceName := INIFile.ReadString('DEVICE', 'DEVICE', 'STM32F103RE');

    DeviceIndex := JLINKARM_DEVICE_GetIndex(PAnsiChar(AnsiString(DeviceName)));

    if DeviceIndex >= 0 then
    begin
      SeggerRTT.GetDeviceInfo(DeviceIndex, @DeviceInfo);

      JLINKARM_Device.ManuafacturerName := DeviceInfo.ManfName;
      JLINKARM_Device.DeviceName := DeviceInfo.name;
      JLINKARM_Device.CoreType := SeggerRTT.Family2CoreType(DeviceInfo.Family);
      JLINKARM_Device.FlashBase := DeviceInfo.FlashBase;
      JLINKARM_Device.FlashSize := DeviceInfo.FlashSize;
      JLINKARM_Device.SramBase := DeviceInfo.SramBase;
      JLINKARM_Device.SramSize := DeviceInfo.SramSize;
      UpdateDeviceInfo();
    end;

  finally
    INIFile.Free;
  end;

end;

procedure TMainForm.OnJlinkLog(JLINKARM_Log : TJLINKARM_Log; Info : string);
var
  InformationStr : string;
  Node : PVirtualNode;
  LogDataPtr : PLogData;
begin
  vstLog.BeginUpdate;
  try
    Node := vstLog.AddChild(nil);
    vstLog.ValidateNode(Node, False);

    LogDataPtr := vstLog.GetNodeData(Node);
    LogDataPtr.LogType := JLINKARM_Log;
    LogDataPtr.LogText := Info;
  finally
    vstLog.EndUpdate;
    vstLog.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  end;

  Exit;

  case JLINKARM_Log of
    jlInformation :
      InformationStr := '-I- ';
    jlWarning :
      InformationStr := '-W- ';
    jlError :
      InformationStr := '-E- ';
  end;
  InformationStr := InformationStr + Info;

end;

procedure TMainForm.OnUsbNotify(Sender : TObject;
  UsbNotifyType : TUsbNotifyAction; const DeviceName : string);
begin
  if SeggerRTT.UsbDeviceNameMatch(DeviceName) <> -1 then
  begin
    btnDriverUSB.Checked := True;
    btnDriverUSBClick(Self);
  end;
end;

function TMainForm.OpenJLinkARM : Boolean;
begin
  if btnDriverIP.Checked then
    UsbDeviceName := HostPortName
  else if cboJLinkDriver.Items.Count > 0 then
    UsbDeviceName := cboJLinkDriver.Text
  else
    Exit(False);

  Result := SeggerRTT.Open(UsbDeviceName);
end;

procedure TMainForm.DisconnectMCU;
begin
  if not SeggerRTT.DeviceConnected then
    Exit;

  ResetStatusBar();
  SeggerRTT.Disconnect();
  SeggerRTT.FFound := False;
  btnConnect.Caption := 'Connect';
end;

procedure TMainForm.Save1Click(Sender : TObject);
begin
  if PopupMenu.PopupComponent = vstLog then
  begin
    if not SeggerRTT.DeviceConnected then
      vstLogSave();
  end
  else if PopupMenu.PopupComponent = RawRxHex then
  begin
    if not SeggerRTT.DeviceConnected then
      RawRxSave();
  end
  else if PopupMenu.PopupComponent = RawTxHex then
  begin
    RawTxSave();
  end
  else if PopupMenu.PopupComponent = vstTerminal then
  begin
    if not SeggerRTT.DeviceConnected then
    begin
      vstTerminalSave();
    end;
  end;
end;

function TMainForm.SaveBeforeConnect : Integer;
const
  MessageStr = 'Save data ?';
var
  Dlg : Integer;
begin
  if (vstTerminal.RootNodeCount = 0) and (RawRxHex.DataSize <= 0) then
    Exit(mrYes);

  Dlg := MessageDlg(MessageStr, mtConfirmation, [mbYes, mbNo, mbCancel], 0,
    mbCancel);

  if Dlg = mrCancel then
    Exit(mrCancel);

  if vstTerminal.RootNodeCount > 0 then
    vstTerminalSave;

  if RawRxHex.DataSize > 0 then
    RawRxSave;
end;

procedure TMainForm.Clear1Click(Sender : TObject);
begin
  if PopupMenu.PopupComponent = vstLog then
  begin
    vstLog.Clear;
    vstLog.Invalidate;
  end
  else if PopupMenu.PopupComponent = RawRxHex then
  begin
    if not SeggerRTT.DeviceConnected then
    begin
      RawRxHexOffset := 0;
      RawRxHex.DataSize := 0;
      RawRxHex.Invalidate;
    end;
  end
  else if PopupMenu.PopupComponent = RawTxHex then
  begin
    RawTxHex.DataSize := 0;
    RawTxHex.Invalidate;
  end
  else if PopupMenu.PopupComponent = vstTerminal then
  begin
    if not SeggerRTT.DeviceConnected then
    begin
      vstTerminal.Clear;
      vstTerminal.Invalidate;
    end;
  end;
end;

function TMainForm.ConnectMCU : Boolean;
begin
  if not SeggerRTT.Connect(JLINKARM_Interface, JLINKARM_Speed,
    JLINKARM_DeviceName) then
  begin
    OnJlinkLog(jlError, Format('Can not connect to device : %s',
      [JLINKARM_DeviceName]));
    Exit(False);
  end;

  // Update Interface
  JLINKARM_Interface := SeggerRTT.GetInterface();
  if JLINKARM_Interface = jiSWD then
    cboJlinkArmInterface.ItemIndex := 2
  else
    cboJlinkArmInterface.ItemIndex := 1;

  // Update Speed
  JLINKARM_Speed := SeggerRTT.GetSpeed();
  edtActualJLinkArmSpeed.Text := IntToStr(JLINKARM_Speed div 1000) + ' KHz';

  edtRTTControlBlockExit(edtRTTControlBlock);

  FindWorker := WorkerMgr.AllocWorker('FindWorker');
  FindWorker.Start(FindWorkerWork, nil, FindWorkerState, nil,
    FindWorkerProgress, nil);

  Exit(True);
end;

procedure TMainForm.SaveIniFile;
var
  INIFile : TIniFile;
begin
  INIFile := TIniFile.Create(ExtractFilePath(Paramstr(0)) + IniFileName);
  try
    INIFile.WriteInteger('CAPACITY', 'CAPACITY',
      RawRxHexCapacity div 1024 div 1024);

    if btnDriverUSB.Checked then
      INIFile.WriteInteger('JLINK', 'DRIVER', 0)
    else
    begin
      INIFile.WriteInteger('JLINK', 'DRIVER', 1);
    end;

    if HostPortName <> '' then
      INIFile.WriteString('JLINK', 'HOSTPORT', HostPortName);

    INIFile.WriteInteger('JLINK', 'SPEED',
      JLinkARM_SpeedValues[cboJlinkArmSpeed.ItemIndex]);

    // Auto -- 0, JTAG -- 1, SWD  -- 2
    INIFile.WriteInteger('JLINK', 'INTERFACE', cboJlinkArmInterface.ItemIndex);

    if edtDevice.Text <> '' then
      INIFile.WriteString('DEVICE', 'DEVICE', edtDevice.Text);

  finally
    INIFile.Free;
  end;
end;

procedure TMainForm.StatusBarDrawPanel(StatusBar : TStatusBar;
  Panel : TStatusPanel; const Rect : TRect);
var
  X, Y, W, H : Integer;
begin
  W := Rect.Right - Rect.Left + 1;
  H := Rect.Bottom - Rect.Top + 1;
  X := (W - StatusBar.Canvas.TextWidth(Panel.Text)) div 2;
  Y := (H - StatusBar.Canvas.TextHeight(Panel.Text)) div 2 - 1;
  StatusBar.Canvas.Brush.Color := clHighlightText;
  StatusBar.Canvas.FillRect(Rect);
  StatusBar.Canvas.TextRect(Rect, Rect.Left + X, Rect.Top + Y, Panel.Text);
end;

procedure TMainForm.UpdateDeviceInfo;
begin
  JLINKARM_ManuafacturerName := JLINKARM_Device.ManuafacturerName;
  JLINKARM_DeviceName := JLINKARM_Device.DeviceName;

  edtDevice.Text := JLINKARM_Device.DeviceName;
  edtRTTControlBlock.Text := '0x' + IntToHex(JLINKARM_Device.SramBase, 8);
end;

procedure TMainForm.vstLogPaintText(Sender : TBaseVirtualTree;
  const TargetCanvas : TCanvas; Node : PVirtualNode; Column : TColumnIndex;
  TextType : TVSTTextType);
var
  LogDataPtr : PLogData;
begin

  LogDataPtr := Sender.GetNodeData(Node);
  if Assigned(LogDataPtr) then
  begin
    if False then
    begin
      if Node.Index and 1 = 1 then
        TargetCanvas.Font.Color := clBlack
      else
        TargetCanvas.Font.Color := clBlue;
    end;

    if LogDataPtr.LogType = jlError then
      TargetCanvas.Font.Color := clRed
    else if LogDataPtr.LogType = jlWarning then
      TargetCanvas.Font.Color := clOlive;
  end;
end;

procedure TMainForm.vstLogGetImageIndex(Sender : TBaseVirtualTree;
  Node : PVirtualNode; Kind : TVTImageKind; Column : TColumnIndex;
  var Ghosted : Boolean; var ImageIndex : Integer);
var
  LogDataPtr : PLogData;
begin
  LogDataPtr := Sender.GetNodeData(Node);
  case Column of
    0 :
      case LogDataPtr.LogType of
        jlInformation :
          ImageIndex := 2;
        jlWarning :
          ImageIndex := 1;
        jlError :
          ImageIndex := 0;
      end;
  end;
end;

procedure TMainForm.vstLogGetText(Sender : TBaseVirtualTree;
  Node : PVirtualNode; Column : TColumnIndex; TextType : TVSTTextType;
  var CellText : string);
var
  LogDataPtr : PLogData;
begin
  LogDataPtr := Sender.GetNodeData(Node);
  case Column of
    0 :
      case LogDataPtr.LogType of
        jlInformation :
          CellText := '-I- ';
        jlWarning :
          CellText := '-W- ';
        jlError :
          CellText := '-E- ';
      end;
    1 :
      CellText := LogDataPtr.LogText;
  end;
end;

procedure TMainForm.vstTerminalAddNode(TerminalDir : TTerminalDir;
  Str : string);
var
  Node : PVirtualNode;
  TerminalDataPtr : PTerminalData;
begin
  Node := vstTerminal.AddChild(nil);
  vstTerminal.ValidateNode(Node, False);
  TerminalDataPtr := vstTerminal.GetNodeData(Node);
  TerminalDataPtr.Dir := TerminalDir;
  TerminalDataPtr.Text := Str;
end;

procedure TMainForm.vstTerminalAddNodes(TerminalDir : TTerminalDir;
  Strings : TStringList);
var
  I : Integer;
begin
  vstTerminal.BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
    begin
      vstTerminalAddNode(TerminalDir, Strings.Strings[I]);
    end;
  finally
    vstTerminal.EndUpdate;
    vstTerminal.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  end;
end;

procedure TMainForm.vstTerminalGetText(Sender : TBaseVirtualTree;
  Node : PVirtualNode; Column : TColumnIndex; TextType : TVSTTextType;
  var CellText : string);
var
  TerminalDataPtr : PTerminalData;
begin
  TerminalDataPtr := Sender.GetNodeData(Node);
  case Column of
    0 :
      case TerminalDataPtr.Dir of
        tdRx :
          CellText := 'Rx';
        tdTx :
          CellText := 'Tx';
      end;
    1 :
      CellText := TerminalDataPtr.Text;
  end;
end;

procedure TMainForm.vstTerminalPaintText(Sender : TBaseVirtualTree;
  const TargetCanvas : TCanvas; Node : PVirtualNode; Column : TColumnIndex;
  TextType : TVSTTextType);
var
  TerminalDataPtr : PTerminalData;
begin

  TerminalDataPtr := Sender.GetNodeData(Node);
  if Assigned(TerminalDataPtr) then
  begin
    if TerminalDataPtr.Dir = tdRx then
      TargetCanvas.Font.Color := clBlack
    else if TerminalDataPtr.Dir = tdTx then
      TargetCanvas.Font.Color := clBlue;
  end;
end;

procedure TMainForm.RawRxHexData(Sender : TObject; const Offset : Int64;
  var Data : Byte);
begin
  if Offset < Length(RawRxHexBuffer) then
    Data := RawRxHexBuffer[Offset]
  else
  begin
    Data := 0;
  end;
end;

procedure TMainForm.RawRxSave;
begin
  DlgSave.FileName := '*.bin';
  if (RawRxHex.DataSize > 0) and DlgSave.Execute then
  begin
    RawRxHex.SaveToFile(DlgSave.FileName);
  end;
end;

procedure TMainForm.RawTxHexData(Sender : TObject; const Offset : Int64;
  var Data : Byte);
begin
  if Offset < TxMemoryStream.Size then
    Data := PByte(Cardinal(TxMemoryStream.Memory) + Cardinal(Offset))^
  else
  begin
    Data := 0;
  end;
end;

procedure TMainForm.RawTxSave;
begin
  DlgSave.FileName := '*.bin';
  if (RawTxHex.DataSize > 0) and DlgSave.Execute then
  begin
    RawTxHex.SaveToFile(DlgSave.FileName);
  end;
end;

procedure TMainForm.vstLogSave;
var
  Node : PVirtualNode;
  LogDataPtr : PLogData;
  StringList : TStringList;
  AString : string;
begin
  DlgSave.FileName := '*.txt';
  if (vstLog.RootNodeCount > 0) and DlgSave.Execute then
  begin
    StringList := TStringList.Create;
    try
      Node := vstLog.RootNode.FirstChild;
      while Assigned(Node) do
      begin
        LogDataPtr := vstLog.GetNodeData(Node);
        if Assigned(LogDataPtr) then
        begin
          if LogDataPtr.LogType = jlInformation then
            AString := '-I- : ' + LogDataPtr.LogText
          else if LogDataPtr.LogType = jlWarning then
            AString := '-W- : ' + LogDataPtr.LogText
          else
            AString := '-E- : ' + LogDataPtr.LogText;
          StringList.Add(AString);
        end;
        Node := Node.NextSibling;
      end;
    finally
      if StringList.Count > 0 then
        StringList.SaveToFile(DlgSave.FileName);
      StringList.Free;
    end;
  end;
end;

procedure TMainForm.vstTerminalSave;
var
  Node : PVirtualNode;
  TerminalDataPtr : PTerminalData;
  StringList : TStringList;
  AString : string;
  Column : Integer;
begin
  DlgSave.FileName := '*.txt';
  if (vstTerminal.RootNodeCount > 0) and DlgSave.Execute then
  begin
    StringList := TStringList.Create;
    try
      Node := vstTerminal.RootNode.FirstChild;
      while Assigned(Node) do
      begin
        TerminalDataPtr := vstTerminal.GetNodeData(Node);
        if Assigned(TerminalDataPtr) then
        begin
          if TerminalDataPtr.Dir = tdTx then
            AString := 'Tx : ' + TerminalDataPtr.Text
          else
            AString := 'Rx : ' + TerminalDataPtr.Text;
          StringList.Add(AString);
        end;
        Node := Node.NextSibling;
      end;
    finally
      if StringList.Count > 0 then
        StringList.SaveToFile(DlgSave.FileName);
      StringList.Free;
    end;
  end;
end;

procedure TMainForm.WMGetMinMaxInfo(var Msg : TWMGetMinMaxInfo);
begin
  inherited;
  with Msg.MinMaxInfo^ do
  begin
    ptMinTrackSize.X := 900;
    ptMinTrackSize.Y := 560;
  end;
end;

function TMainForm.FindWorkerWork(Sender : TWorker; Param : TObject)
  : TWorkerState;
begin
  SeggerRTT.FindConfig();

  while True do
  begin
    if Sender.AbortPending then
      Exit(wsAborted);

    case SeggerRTT.FindControlBlock() of
      0 :
        Sender.FeedbackProgress(SeggerRTT.FFind.SramAddr);
      -1 :
        Exit(wsFailed);
    else
      Exit(wsFinished)
    end;
  end;
end;

procedure TMainForm.FindWorkerProgress(Sender : TWorker; Progress : Integer);
begin
  StatusBar.Panels[0].Text := 'Search : 0x' + IntToHex(Progress, 8);
end;

procedure TMainForm.FindWorkerState(Sender : TWorker; State : TWorkerState);
begin
  case State of
    wsAborted .. wsFailed :
      DisconnectMCU();
    wsFinished :
      TransferWorkerStart();
  end;
end;

procedure TMainForm.TransferWorkerStart;
begin
  vstTerminal.Clear;

  TotalRxSize := 0;
  PreviousRxSize := 0;
  TxtRxSize := 0;
  RawRxSize := 0;

  RawRxHex.DataSize := 0;
  RawRxHexOffset := 0;

  TotalTxSize := 0;
  PreviousTxSize := 0;
  TxtTxSize := 0;
  RawTxSize := 0;

  TxStringPending := False;
  TxStringAbort := False;

  TxMemoryStreamPending := False;
  TxMemoryStreamAbort := False;

  edtRTTControlBlock.Text := '0x' + IntToHex(SeggerRTT.FFind.realAddress, 8);
  StatusBar.Panels[0].Text := 'Connected';
  StatusBar.Panels[1].Text := 'Rx[0] 0 Bytes';
  StatusBar.Panels[2].Text := 'Rx[1] 0 Bytes';
  StatusBar.Panels[3].Text := 'Rx 000,000 KB/s';
  StatusBar.Panels[4].Text := 'Tx[0] 0 Bytes';
  StatusBar.Panels[5].Text := 'Tx[1] 0 Bytes';
  StatusBar.Panels[6].Text := 'Tx 000,000 KB/s';

  TransferWorker := WorkerMgr.AllocWorker('TransferWorker');
  TransferWorker.Start(TransferWorkerWork, nil, TransferWorkerState,
    TransferWorkerQuery, TransferWorkerProgress, TransferWorkerData);

  SeggerRTT.FFound := True;
  PrevTickCount := 0;
  TickCount := 0;
end;

procedure TMainForm.btnTerminalSendClick(Sender : TObject);
begin
  if btnTerminalSend.Caption = 'Send' then
  begin
    btnTerminalSend.Caption := 'Abort';
    TxStringPending := True;
    TxStringAbort := False;
    TxString := edtInput.Text;

    btnRawSendEnabled := False;
  end
  else
  begin
    TxStringAbort := True;
  end;
end;

procedure TMainForm.btnRawSendClick(Sender : TObject);
begin
  if btnRawSend.Caption = 'Send' then
  begin
    btnRawSend.Caption := 'Abort';
    edtRawFileName.Enabled := False;
    TxMemoryStreamPending := True;
    TxMemoryStreamAbort := False;

    btnTerminalSendEnabled := False;
  end
  else
  begin
    TxMemoryStreamAbort := True;
  end;
end;

function TMainForm.TransferWorkerWork(Sender : TWorker; Param : TObject)
  : TWorkerState;
var
  UpBufferred : Integer;
  UpSplitted : Integer;

  UpRingBuffer : PRingBufferEx;
  UpIndex : Integer;
  UpCount : Integer;
  UpSize : Integer;

  DownRingBuffer : PRingBufferEx;
  DownCount : Integer;
  DownIndex : Integer;
  DownSize : Integer;

  DownRemaining : Integer;
  DownTransferred : Integer;

  DownTransferBuffer : Pointer;
  DownTransferOffset : Integer;
begin
  UpBufferred := 0;

  DownTransferBuffer := nil;
  DownTransferOffset := 0;
  DownSize := 0;

  UpCount := SeggerRTT.FInfo.MaxNumUpBuffers;
  if UpCount > 2 then
    UpCount := 2;

  while True do
  begin
    if Sender.AbortPending then
      Exit(wsAborted);

    if SeggerRTT.ReadControlBlock() <= 0 then
      Exit(wsFailed);

    // Try to read all up buffer at first
    for UpIndex := 0 to UpCount - 1 do
    begin
      UpSize := SeggerRTT.UpReadable(UpIndex, UpRingBuffer);
      if UpSize > 0 then
      begin
        if UpIndex = 0 then
        begin
          if UpSize > RX_BUFFER_MAX_SIZE - UpBufferred then
            UpSize := RX_BUFFER_MAX_SIZE - UpBufferred;

          if UpSize > 0 then
            UpSize := SeggerRTT.ReadUpBuffer(UpRingBuffer, UpSize,
              TxtBuffer[UpBufferred]);
        end
        else if UpIndex = 1 then
        begin
          if UpSize > RawRxHexCapacity - RawRxHexOffset then
            UpSize := RawRxHexCapacity - RawRxHexOffset;

          if UpSize > 0 then
            UpSize := SeggerRTT.ReadUpBuffer(UpRingBuffer, UpSize,
              RawRxHexBuffer[RawRxHexOffset])
        end;

        if UpSize = -1 then
          Exit(wsFailed);

        if UpSize > 0 then
        begin
          if UpIndex = 0 then
          begin
            UpSize := UpBufferred + UpSize;
            TxtBuffer[UpSize] := 0;
            RxStringList.Clear;
            UpSplitted := SplitStrings(PAnsiChar(@TxtBuffer[0]), UpSize,
              RxStringList);
            UpBufferred := UpSize - UpSplitted;
            if UpBufferred > 0 then
              CopyMemory(@TxtBuffer[0], @TxtBuffer[UpSplitted], UpBufferred);

            Sender.FeedbackData3(TObject(UpIndex), TObject(UpSize),
              RxStringList);
          end
          else if UpIndex = 1 then
          begin
            Sender.FeedbackData3(TObject(UpIndex), TObject(UpSize),
              TObject(@RawRxHexBuffer[RawRxHexOffset]))
          end;
        end;
      end;
    end;

    // Try to write down buffer if data is pending
    if TxStringPending then
    begin
      DownIndex := 0;
      if TxStringAbort then
      begin
        DownTransferBuffer := nil;
        TxStringPending := False;
        TxStringAbort := False;
        Sender.FeedbackProgress(DownIndex or $80000000); // Aborted
      end
      else if DownTransferBuffer = nil then
      begin
        DownTransferBuffer := @TxString[1];
        DownRemaining := Length(TxString);
        DownTransferred := 0;
        DownTransferOffset := 0;
      end;
    end
    else if TxMemoryStreamPending then
    begin
      DownIndex := 1;
      if TxMemoryStreamAbort then
      begin
        DownTransferBuffer := nil;
        TxMemoryStreamAbort := False;
        TxMemoryStreamPending := False;
        Sender.FeedbackProgress(DownIndex or $80000000); // Aborted
      end
      else if DownTransferBuffer = nil then
      begin
        DownTransferBuffer := TxMemoryStream.Memory;
        DownRemaining := TxMemoryStream.Size;
        DownTransferred := 0;
        DownTransferOffset := 0;
      end;
    end;

    if DownTransferBuffer <> nil then
    begin
      if DownRemaining = 0 then // Transfer Finished
      begin
        DownTransferBuffer := nil;
        Sender.FeedbackProgress(DownIndex); // Finished
      end
      else
      begin // Transferring

        DownSize := SeggerRTT.DownWritable(DownIndex, DownRingBuffer);
        if DownSize > DownRemaining then
          DownSize := DownRemaining;

        if DownSize > 0 then
        begin
          DownSize := SeggerRTT.WriteDownBuffer(DownRingBuffer, DownSize,
            DownTransferBuffer^);

          if DownSize = -1 then
            Exit(wsFailed);

          if DownSize > 0 then
          begin
            Sender.FeedbackData2(TObject(DownIndex), TObject(DownSize));

            DownRemaining := DownRemaining - DownSize;
            DownTransferred := DownTransferred + DownSize;
            DownTransferBuffer := PByte(DownTransferBuffer) + DownSize;
          end;
        end;
      end;
    end;
  end
end;

procedure TMainForm.TransferWorkerProgress(Sender : TWorker;
  Progress : Integer);
begin
  case Progress of
    0 : // TxString Finished
      begin
        btnTerminalSend.Caption := 'Send';
        btnRawSendEnabled := True;
        TxStringPending := False;
        TxStringAbort := False;

        // Add String to Terminal
        vstTerminalAddNode(tdTx, TxString);

      end;
    1 : // TxMemoryStream Finished
      begin
        btnRawSend.Caption := 'Send';
        btnTerminalSendEnabled := True;
        edtRawFileName.Enabled := True;
        TxMemoryStreamPending := False;
        TxMemoryStreamPending := False;
      end;
    $80000000 : // TxString Aborted
      begin
        btnTerminalSend.Caption := 'Send';
        btnRawSendEnabled := True;
        TxStringPending := False;
        TxStringAbort := False;
      end;
    $80000001 : // TxMemoryStream Aborted
      begin
        btnRawSend.Caption := 'Send';
        btnTerminalSendEnabled := True;
        edtRawFileName.Enabled := True;
        TxMemoryStreamPending := False;
        TxMemoryStreamPending := False;
      end;
  end;
end;

procedure TMainForm.TransferWorkerState(Sender : TWorker; State : TWorkerState);
begin
  case State of
    wsAborted, wsFailed, wsFinished :
      begin
        DisconnectMCU();

        btnTerminalSend.Caption := 'Send';
        btnRawSend.Caption := 'Send';
        btnTerminalSendEnabled := True;
        btnRawSendEnabled := True;
        edtRawFileName.Enabled := True;
      end;
  end;
end;

procedure TMainForm.TransferWorkerQuery(Sender : TWorker;
  var Query : TWorkerQuery);
var
  Abort : LongBool;
begin
  TickCount := GetTickCount();
  if TickCount <> PrevTickCount then
  begin
    TickCountDelta := TickCount - PrevTickCount;
    if TickCountDelta >= 1000 then
    begin
      PrevTickCount := TickCount;
      TransferWorkTimer();
    end;
  end;

  Abort := RawRxHexOffset + RX_BUFFER_MAX_SIZE > RawRxHexCapacity;
  if not Abort then
    Abort := TotalRxSize > RawRxHexCapacity * 2;
  if Abort then
  begin
    OnJlinkLog(jlWarning, 'A buffer overflow has occurred.');
    Query := wqAbort;
  end;
end;

procedure TMainForm.TransferWorkerData(Sender : TWorker; Count : Integer;
  Data0, Data1, Data2, Data3 : TObject);
var
  UpIndex : Integer;
  UpSize : Integer;
  DownIndex : Integer;
  DownSize : Integer;
  Time : DWORD;
  Mega, Kilo, One : Integer;
begin
  if Count = 2 then // Down : FeedbackData2
  begin
    DownIndex := Integer(Data0);
    DownSize := Integer(Data1);
    Inc(TotalTxSize, DownSize); // To Calc Speed
    if DownIndex = 0 then
    begin
      Inc(TxtTxSize, DownSize); // To Display in StatusBar

      Mega := TxtTxSize div 1000000;
      Kilo := (TxtTxSize mod 1000000) div 1000;
      One := TxtTxSize mod 1000;

      if Mega > 0 then
        StatusBar.Panels[4].Text := Format('Tx[0] %d,%.3d,%.3d Bytes',
          [Mega, Kilo, One])
      else if Kilo > 0 then
        StatusBar.Panels[4].Text := Format('Tx[0] %d,%.3d Bytes', [Kilo, One])
      else
        StatusBar.Panels[4].Text := Format('Tx[0] %d Bytes', [One]);

    end
    else
    begin
      Inc(RawTxSize, DownSize); // To Display in StatusBar

      Mega := RawTxSize div 1000000;
      Kilo := (RawTxSize mod 1000000) div 1000;
      One := RawTxSize mod 1000;

      if Mega > 0 then
        StatusBar.Panels[5].Text := Format('Tx[1] %d,%.3d,%.3d Bytes',
          [Mega, Kilo, One])
      else if Kilo > 0 then
        StatusBar.Panels[5].Text := Format('Tx[1] %d,%.3d Bytes', [Kilo, One])
      else
        StatusBar.Panels[5].Text := Format('Tx[1] %d Bytes', [One]);

    end;
  end
  else if Count = 3 then // Up : FeedbackData3
  begin
    UpIndex := Integer(Data0);
    UpSize := Integer(Data1);
    Inc(TotalRxSize, UpSize);

    if UpIndex = 0 then
    begin
      Inc(TxtRxSize, UpSize);
      Mega := TxtRxSize div 1000000;
      Kilo := (TxtRxSize mod 1000000) div 1000;
      One := TxtRxSize mod 1000;

      if Mega > 0 then
        StatusBar.Panels[1].Text := Format('Rx[0] %d,%.3d,%.3d Bytes',
          [Mega, Kilo, One])
      else if Kilo > 0 then
        StatusBar.Panels[1].Text := Format('Rx[0] %d,%.3d Bytes', [Kilo, One])
      else
        StatusBar.Panels[1].Text := Format('Rx[0] %d Bytes', [One]);

      vstTerminalAddNodes(tdRx, TStringList(Data2));

    end
    else if UpIndex = 1 then
    begin
      Inc(RawRxSize, UpSize);
      Mega := RawRxSize div 1000000;
      Kilo := (RawRxSize mod 1000000) div 1000;
      One := RawRxSize mod 1000;

      if Mega > 0 then
        StatusBar.Panels[2].Text := Format('Rx[1] %d,%.3d,%.3d Bytes',
          [Mega, Kilo, One])
      else if Kilo > 0 then
        StatusBar.Panels[2].Text := Format('Rx[1] %d,%.3d Bytes', [Kilo, One])
      else
        StatusBar.Panels[2].Text := Format('Rx[1] %d Bytes', [One]);

      Inc(RawRxHexOffset, UpSize);
      RawRxHex.BeginUpdate;
      RawRxHex.DataSize := RawRxHex.DataSize + UpSize;
      RawRxHex.SelStart := RawRxHex.DataSize - 1;
      RawRxHex.EndUpdate;

    end;
  end;
end;

end.
