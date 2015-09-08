unit uDeviceForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, uJLinkARM;

type
  TDeviceForm = class( TForm )
    Label1 : TLabel;
    Label2 : TLabel;
    lbManuafacturerName : TListBox;
    lbDeviceName : TListBox;
    btnCancel : TButton;
    btnOK : TButton;
    rgCoreType : TRadioGroup;
    edtSearch : TEdit;
    Label3 : TLabel;
    edtSramSize : TEdit;
    Label10 : TLabel;
    edtSramBase : TEdit;
    Label9 : TLabel;
    edtFlashSize : TEdit;
    Label8 : TLabel;
    edtFlashBase : TEdit;
    Label7 : TLabel;
    edtCore : TEdit;
    Label6 : TLabel;
    edtDevice : TEdit;
    Label5 : TLabel;
    Label4 : TLabel;
    edtManuafacturer : TEdit;
    GroupBox1 : TGroupBox;
    imgManuafacturerLogo : TImage;

    procedure FormClose( Sender : TObject; var Action : TCloseAction );
    procedure FormCreate( Sender : TObject );
    procedure edtSearchKeyUp( Sender : TObject; var Key : Word;
      Shift : TShiftState );
    procedure rgCoreTypeClick( Sender : TObject );
    procedure lbManuafacturerNameClick( Sender : TObject );
    procedure edtManuafacturerEnter( Sender : TObject );
    procedure lbDeviceNameClick( Sender : TObject );
    procedure lbDeviceNameDblClick( Sender : TObject );
    procedure FormMouseUp( Sender : TObject; Button : TMouseButton;
      Shift : TShiftState; X, Y : Integer );

  private
    { Private declarations }
    FJLinkARM : TJLinkARM;
    FJLINKARM_Device : PJLINKARM_Device;
    procedure LoadManuafacturerLogo( ManuafacturerName : string );
    procedure LoadManuafacturerLogoDll( ManuafacturerName : string );
    procedure LoadManuafacturerLogo2( ManuafacturerName : string );
    procedure LoadManuafacturerLogoJpeg( ManuafacturerName : string );
    procedure UpdateManuafacturerListBox( );
    function IsMatchSearchText( SearchText : string; Text : string ) : Boolean;

  public
    constructor Create( AOwner : TComponent; AJLinkRAM : TJLinkARM;
      JLINKARM_Device : PJLINKARM_Device );
    destructor Destroy; override;
  end;

implementation

uses
  uMainForm, uUtility;

{$R *.dfm}
{$R Logo.res Logo.rc}

type
  TManuafacturerLogoBitmap = record
    Name : string;
    Bitmap : string;
  end;

const
  ManuafacturerLogoBitmapCount = 40;

const
  ManuafacturerLogoBitmaps : array [ 0 .. ManuafacturerLogoBitmapCount - 1 ]
    of TManuafacturerLogoBitmap = //
    ( ( name : 'Actel'; Bitmap : 'LOGO_ACTEL' ), //
    ( name : 'Altera'; Bitmap : 'LOGO_ALTERA' ), //
    ( name : 'Analog'; Bitmap : 'LOGO_ANALOG' ), //
    ( name : 'Atmel'; Bitmap : 'LOGO_ATMEL' ), //
    ( name : 'AyDeeKay'; Bitmap : 'LOGO_AYDEEKAY' ), //
    ( name : 'Cirrus Logic'; Bitmap : 'LOGO_CIRRUS' ), //
    ( name : 'Cypress'; Bitmap : 'LOGO_CYPRESS' ), //
    ( name : 'Digi'; Bitmap : 'LOGO_DIGI' ), //
    ( name : 'Ember'; Bitmap : 'LOGO_EMBER' ), //
    ( name : 'Energy Micro'; Bitmap : 'LOGO_ENERGY_MICRO' ), //
    ( name : 'Epson'; Bitmap : 'LOGO_ESPON' ), //
    ( name : 'Faraday'; Bitmap : 'LOGO_FARADAY' ), //
    ( name : 'Freescale'; Bitmap : 'LOGO_FREESCALE' ), //
    ( name : 'Fujitsu'; Bitmap : 'LOGO_FUJITSU' ), //
    ( name : 'Hilscher'; Bitmap : 'LOGO_HILSCHER' ), //
    ( name : 'Holtek'; Bitmap : 'LOGO_HOLTEK' ), //
    ( name : 'Infineon'; Bitmap : 'LOGO_INFINEON' ), //
    ( name : 'Itron'; Bitmap : 'LOGO_ITRON' ), //
    ( name : 'Luminary'; Bitmap : 'LOGO_LUMINARY' ), //
    ( name : 'Marvell'; Bitmap : 'LOGO_MAXWELL' ), //
    ( name : 'Maxim'; Bitmap : 'LOGO_MAXIM' ), //
    ( name : 'Microchip'; Bitmap : 'LOGO_MICROCHIP' ), //
    ( name : 'Micronas'; Bitmap : 'LOGO_MICRONAS' ), //
    ( name : 'Microsemi'; Bitmap : 'LOGO_MICROSEMI' ), //
    ( name : 'NXP'; Bitmap : 'LOGO_NXP' ), //
    ( name : 'Nordic Semi'; Bitmap : 'LOGO_NORDIC' ), //
    ( name : 'Nuvoton'; Bitmap : 'LOGO_NUVOTON' ), //
    ( name : 'OKI'; Bitmap : 'LOGO_OKI' ), //
    ( name : 'ON Semi'; Bitmap : 'LOGO_ONSEMI' ), //
    ( name : 'Quintic'; Bitmap : 'LOGO_QUINTIC' ), //
    ( name : 'Renesas'; Bitmap : 'LOGO_RENESAS' ), //
    ( name : 'ST'; Bitmap : 'LOGO_ST' ), //
    ( name : 'Samsung'; Bitmap : 'LOGO_SAMSUNG' ), //
    ( name : 'Silicon Labs'; Bitmap : 'LOGO_SILICON_LABORATORIES' ), //
    ( name : 'Socle'; Bitmap : 'LOGO_SOCLE' ), //
    ( name : 'Sonix'; Bitmap : 'LOGO_SONIX' ), //
    ( name : 'Spansion'; Bitmap : 'LOGO_SPANSION' ), //
    ( name : 'TI'; Bitmap : 'LOGO_TI' ), //
    ( name : 'Toshiba'; Bitmap : 'LOGO_TOSHIBA' ), //
    ( name : 'Xilinx'; Bitmap : 'LOGO_XILINX' ) );

procedure TDeviceForm.FormClose( Sender : TObject; var Action : TCloseAction );
begin
  if Self.ModalResult = mrOK then
  begin
    if lbDeviceName.SelCount > 0 then
      lbDeviceNameClick( Self );
  end;
end;

procedure TDeviceForm.FormCreate( Sender : TObject );
begin
  edtSearch.Text := FJLINKARM_Device^.DeviceName;
  rgCoreType.ItemIndex := 4;
  lbManuafacturerName.Clear;
  lbManuafacturerName.Clear;

  UpdateManuafacturerListBox( );
end;

procedure TDeviceForm.FormMouseUp( Sender : TObject; Button : TMouseButton;
  Shift : TShiftState; X, Y : Integer );
var
  I : Integer;
  FileName : string;
  fs : TFileStream;
  FamilyList : TStringList;
  IdList : TStringList;
  DlgSave : TSaveDialog;
  DeviceCount : Integer;
  DeviceInfo : TJLinkARM_DeviceInfo;
begin
  if ( ssAlt in Shift ) and ( ssCtrl in Shift ) then
  begin
    DlgSave := TSaveDialog.Create( Self );
    try
      DlgSave.InitialDir := ExtractFilePath( Paramstr( 0 ) );
      DlgSave.FileName := 'JLinkDeviceList.bin';
      if not DlgSave.Execute then
        Exit;

      IdList := TStringList.Create;
      FamilyList := TStringList.Create;
      try
        DeviceCount := FJLinkARM.GetDeviceCount( );
        for I := 0 to DeviceCount - 1 do
        begin
          FJLinkARM.GetDeviceInfo( I, @DeviceInfo );
          if IdList.IndexOf( IntToHex( DeviceInfo.id, 8 ) ) = -1 then
            IdList.Add( IntToHex( DeviceInfo.id, 8 ) );

          if FamilyList.IndexOf( IntToHex( DeviceInfo.Family, 8 ) ) = -1 then
            FamilyList.Add( IntToHex( DeviceInfo.Family, 8 ) );
        end;

        Exit;

        fs := TFileStream.Create( DlgSave.FileName, fmOpenWrite or
          fmShareExclusive );
        try


        finally
          fs.Free;
        end;
      finally
        IdList.Free;
        FamilyList.Free;
      end;
    finally
      DlgSave.Free;
    end;
  end;
end;

function TDeviceForm.IsMatchSearchText( SearchText : string; Text : string )
  : Boolean;
var
  I : Integer;
  Position : Integer;
  TextLength : Integer;
begin
  Result := FALSE;
  SearchText := UpperCase( SearchText );
  TextLength := Length( Text );
  Position := 0;
  for I := 1 to Length( SearchText ) do
  begin
    Position := Pos( SearchText[ I ], Text, Position + 1 );
    if Position = 0 then
      Exit;
  end;
  Result := TRUE;
end;

procedure TDeviceForm.lbDeviceNameClick( Sender : TObject );
var
  DeviceName : string;
  DeviceIndex : Integer;
  DeviceInfo : TJLinkARM_DeviceInfo;
  FlashBase : DWORD;
  FlashSize : DWORD;
  I : Integer;
begin
  if lbDeviceName.ItemIndex >= 0 then
  begin
    DeviceName := lbDeviceName.Items[ lbDeviceName.ItemIndex ];
    FJLinkARM.GetDeviceInfo( DeviceName, @DeviceInfo );
    FJLINKARM_Device^.ManuafacturerName := string( DeviceInfo.ManfName );
    FJLINKARM_Device^.DeviceName := DeviceName;
    FJLINKARM_Device^.CoreType := FJLinkARM.Family2CoreType
      ( DeviceInfo.Family );

    FlashBase := DeviceInfo.Flash[ 0 ].Base;
    FlashSize := DeviceInfo.Flash[ 0 ].Size;
    for I := 1 to 31 do
    begin
      if FlashSize < DeviceInfo.Flash[ I ].Size then
      begin
        FlashBase := DeviceInfo.Flash[ I ].Base;
        FlashSize := DeviceInfo.Flash[ I ].Size;
      end;
    end;
    FJLINKARM_Device^.FlashBase := FlashBase;
    FJLINKARM_Device^.FlashSize := FlashSize;

    FJLINKARM_Device^.SramBase := DeviceInfo.SramBase;
    FJLINKARM_Device^.SramSize := DeviceInfo.SramSize;

    edtManuafacturer.Text := FJLINKARM_Device^.ManuafacturerName;
    edtDevice.Text := FJLINKARM_Device^.DeviceName;
    edtCore.Text := FJLinkARM.CoreType2Name( FJLINKARM_Device^.CoreType );
    edtFlashBase.Text := '0x' + IntToHex( FJLINKARM_Device^.FlashBase, 8 );
    edtFlashSize.Text := '0x' + IntToHex( FJLINKARM_Device^.FlashSize, 8 );
    edtSramBase.Text := '0x' + IntToHex( FJLINKARM_Device^.SramBase, 8 );
    edtSramSize.Text := '0x' + IntToHex( FJLINKARM_Device^.SramSize, 8 );
  end;
end;

procedure TDeviceForm.lbDeviceNameDblClick( Sender : TObject );
begin
  // lbDeviceNameClick( Self );
  // Self.ModalResult := mrOK;
end;

procedure TDeviceForm.lbManuafacturerNameClick( Sender : TObject );
var
  I : Integer;
  DeviceNameList : TStringList;
  ManuafacturerListItem : PManuafacturerListItem;
  ManuafacturerName : string;
begin
  ManuafacturerName := lbManuafacturerName.Items
    [ lbManuafacturerName.ItemIndex ];

  LoadManuafacturerLogo( ManuafacturerName );

  ManuafacturerListItem := nil;
  for I := 0 to FJLinkARM.ManuafacturerInfoCount - 1 do
  begin
    if ManuafacturerName = FJLinkARM.ManuafacturerInfoList[ I ].ManuafacturerName
    then
    begin
      ManuafacturerListItem := @FJLinkARM.ManuafacturerInfoList[ I ];
      break;
    end;
  end;

  DeviceNameList := TStringList.Create;
  try
    for I := 0 to Length( ManuafacturerListItem^.DeviceIndexArray ) - 1 do
    begin
      if ManuafacturerListItem.DeviceIndexArray[ I ] > 0 then
        DeviceNameList.Add( FJLinkARM.DeviceInfoList
          [ ManuafacturerListItem.DeviceIndexArray[ I ] ].DeviceName );
    end;

    lbDeviceName.Clear;
    lbDeviceName.Items.AddStrings( DeviceNameList );
    lbDeviceName.ItemIndex := 0;
    lbDeviceNameClick( Self );
  finally
    DeviceNameList.Free;
  end;
end;

procedure TDeviceForm.LoadManuafacturerLogo( ManuafacturerName : string );
var
  I : Integer;
begin
  imgManuafacturerLogo.Visible := FALSE;
  for I := 0 to ManuafacturerLogoBitmapCount - 1 do
  begin
    if ManuafacturerName = ManuafacturerLogoBitmaps[ I ].Name then
    begin
      if ManuafacturerLogoBitmaps[ I ].Bitmap <> '' then
      begin
        imgManuafacturerLogo.Picture.Bitmap.LoadFromResourceName( HInstance,
          ManuafacturerLogoBitmaps[ I ].Bitmap );
        imgManuafacturerLogo.Visible := TRUE;
        Exit;
      end;
    end;
  end;
end;

procedure TDeviceForm.LoadManuafacturerLogo2( ManuafacturerName : string );
var
  I : Integer;
  Bitmap : TBitmap;
begin
  imgManuafacturerLogo.Visible := FALSE;
  for I := 0 to ManuafacturerLogoBitmapCount - 1 do
  begin
    if ManuafacturerName = ManuafacturerLogoBitmaps[ I ].Name then
    begin
      if ManuafacturerLogoBitmaps[ I ].Bitmap <> '' then
      begin
        Bitmap := TBitmap.Create;
        try
          Bitmap.LoadFromResourceName( HInstance,
            ManuafacturerLogoBitmaps[ I ].Bitmap );
          imgManuafacturerLogo.Picture.Assign( Bitmap );
        finally
          Bitmap.Free;
        end;
        imgManuafacturerLogo.Visible := TRUE;
        Exit;
      end;
    end;
  end;
end;

procedure TDeviceForm.LoadManuafacturerLogoDll( ManuafacturerName : string );
var
  I : Integer;
  Bitmap : TBitmap;
  Dll : THandle;
begin
  imgManuafacturerLogo.Visible := FALSE;
  for I := 0 to ManuafacturerLogoBitmapCount - 1 do
  begin
    if ManuafacturerName = ManuafacturerLogoBitmaps[ I ].Name then
    begin
      if ManuafacturerLogoBitmaps[ I ].Bitmap <> '' then
      begin
        Dll := LoadLibrary( 'Logo.dll' );
        try
          if Dll <> 0 then
          begin
            Bitmap := TBitmap.Create;
            try
              Bitmap.LoadFromResourceName( Dll,
                ManuafacturerLogoBitmaps[ I ].Bitmap );
              imgManuafacturerLogo.Picture.Assign( Bitmap );
            finally
              Bitmap.Free;
            end;
            imgManuafacturerLogo.Visible := TRUE;
            Exit;
          end;
        finally
          FreeLibrary( Dll );
        end;
      end;
    end;
  end;
end;

// JPEG_ST RCDATA "..\\Manuafacturer Logo\\ST.jpg"
procedure TDeviceForm.LoadManuafacturerLogoJpeg( ManuafacturerName : string );
var
  jpgLogo : TJpegImage;
  RStream : TResourceStream;
begin
  RStream := TResourceStream.Create( HInstance, 'JPEG_ST', RT_RCDATA );
  try
    jpgLogo := TJpegImage.Create;
    try
      jpgLogo.LoadFromStream( RStream );
      imgManuafacturerLogo.Picture.Graphic := jpgLogo;
    finally
      jpgLogo.Free;
    end;
  finally
    RStream.Free;
  end; { Try..Finally }
end;

procedure TDeviceForm.rgCoreTypeClick( Sender : TObject );
begin
  UpdateManuafacturerListBox( );
end;

constructor TDeviceForm.Create( AOwner : TComponent; AJLinkRAM : TJLinkARM;
  JLINKARM_Device : PJLINKARM_Device );
begin
  inherited Create( AOwner );
  FJLinkARM := AJLinkRAM;
  FJLINKARM_Device := JLINKARM_Device;
end;

destructor TDeviceForm.Destroy;
begin
  inherited;
end;

procedure TDeviceForm.edtManuafacturerEnter( Sender : TObject );
begin
  edtSearch.SetFocus( );
end;

procedure TDeviceForm.edtSearchKeyUp( Sender : TObject; var Key : Word;
  Shift : TShiftState );
begin
  UpdateManuafacturerListBox( );
end;

procedure TDeviceForm.UpdateManuafacturerListBox;
// JLink Commander : Export Device List, Get Manuafacturer Count
const
  DEFAULT_MANUAFACTURER_COUNT : Integer = 64;
  DEFAULT_DEVICE_COUNT : Integer = 128;
var
  I, J : Integer;
  CoreType : TJLINKARM_CoreType;
  SearchText : string;
  DeviceListItem : PJLINKARM_DeviceListItem;
  ManuafacturerListItem : PManuafacturerListItem;
  DeviceIndex : Integer;
  DisplayEnable : Boolean;
  ManuafacturerNameList : TStringList;
  CurrentManuafacturerName : string;
  IndexOfManuafacturerName : Integer;
begin
  SearchText := edtSearch.Text;
  CoreType := TJLINKARM_CoreType( rgCoreType.ItemIndex );

  if lbManuafacturerName.ItemIndex < 0 then
    CurrentManuafacturerName := ''
  else
    CurrentManuafacturerName := lbManuafacturerName.Items
      [ lbManuafacturerName.ItemIndex ];

  ManuafacturerNameList := TStringList.Create;
  try

    for I := 0 to FJLinkARM.ManuafacturerInfoCount - 1 do
    begin
      ManuafacturerListItem := @FJLinkARM.ManuafacturerInfoList[ I ];
      ManuafacturerListItem.EnabledCount := 0;

      for J := 0 to ManuafacturerListItem^.DeviceIndexCount - 1 do
      begin
        DeviceIndex := ManuafacturerListItem^.DeviceIndexArray[ J ];
        DeviceListItem := @FJLinkARM.DeviceInfoList
          [ DeviceIndex and $7FFFFFFF ];

        DisplayEnable := TRUE;

        if CoreType <> ctUnknown then
          DisplayEnable := DeviceListItem^.CoreType = CoreType;

        if DisplayEnable then
          DisplayEnable := IsMatchSearchText( SearchText,
            DeviceListItem^.DeviceName );

        if DisplayEnable then
          DeviceIndex := DeviceIndex and $7FFFFFFF
        else
          DeviceIndex := DeviceIndex or $80000000;

        ManuafacturerListItem^.DeviceIndexArray[ J ] := DeviceIndex;
        if DeviceIndex > 0 then
          Inc( ManuafacturerListItem^.EnabledCount );
      end;

      if ManuafacturerListItem^.EnabledCount > 0 then
        ManuafacturerNameList.Add( ManuafacturerListItem^.ManuafacturerName );
    end;

    lbDeviceName.Clear;
    lbManuafacturerName.Clear;
    if ManuafacturerNameList.Count > 0 then
    begin
      lbManuafacturerName.Items.AddStrings( ManuafacturerNameList );
      IndexOfManuafacturerName := lbManuafacturerName.Items.IndexOf
        ( CurrentManuafacturerName );
      if IndexOfManuafacturerName >= 0 then
        lbManuafacturerName.ItemIndex := IndexOfManuafacturerName
      else
        lbManuafacturerName.ItemIndex := 0;

      lbManuafacturerNameClick( Self );
    end;

  finally
    ManuafacturerNameList.Free;
  end;
end;

end.
