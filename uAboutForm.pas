unit uAboutForm;

interface

uses WinApi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.GIFImg, Vcl.Imaging.pngimage;

type
  TAboutBox = class( TForm )
    Panel1 : TPanel;
    ProgramIcon : TImage;
    ProductName : TLabel;
    Version : TLabel;
    OKButton : TButton;
    Label1 : TLabel;
    UrlLabel : TLabel;
    procedure ProgramIconClick( Sender : TObject );
    procedure UrlLabelClick( Sender : TObject );
    procedure UrlLabelMouseEnter( Sender : TObject );
    procedure UrlLabelMouseLeave( Sender : TObject );
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox : TAboutBox;

implementation

{$R *.dfm}

uses
  Registry, ShellAPI;

procedure TAboutBox.UrlLabelClick( Sender : TObject );
begin
  ProgramIconClick( ProgramIcon );
end;

procedure TAboutBox.UrlLabelMouseEnter( Sender : TObject );
begin
  UrlLabel.Font.Color := clBlue;
end;

procedure TAboutBox.UrlLabelMouseLeave( Sender : TObject );
begin
  UrlLabel.Font.Color := clBlack;
end;

procedure TAboutBox.ProgramIconClick( Sender : TObject );
begin
  ShellExecute( Handle, PChar( 'open' ), PChar( 'http://jtag.taobao.com' ), nil,
    nil, SW_SHOWNORMAL );
end;

end.
