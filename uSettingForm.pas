unit uSettingForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TSettingForm = class( TForm )
    edtCapacity : TEdit;
    Label4 : TLabel;
    btnOK : TButton;
    btnCancel : TButton;
    procedure btnOKClick( Sender : TObject );
    procedure FormCreate( Sender : TObject );
  private
    { Private declarations }
    FCapacity : PInteger;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent; Capacity : PInteger );
  end;

var
  SettingForm : TSettingForm;
  CapacityVal : integer;

implementation

{$R *.dfm}

procedure TSettingForm.btnOKClick( Sender : TObject );
begin
  try
    CapacityVal := StrToInt( edtCapacity.Text );
  except
    ShowMessage( 'Capacity Value is error !' );
    Exit;
  end;

  if CapacityVal > 128 then
  begin
    ShowMessage( 'Capacity Value is too large !' );
    Exit;
  end;

  FCapacity^ := CapacityVal;
  Self.ModalResult := mrOK;
end;

constructor TSettingForm.Create( AOwner : TComponent; Capacity : PInteger );
begin
  inherited Create( AOwner );
  FCapacity := Capacity;
end;

procedure TSettingForm.FormCreate( Sender : TObject );
begin
  edtCapacity.Text := IntToStr( FCapacity^ );
end;

end.
