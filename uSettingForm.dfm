object SettingForm: TSettingForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Setting'
  ClientHeight = 116
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object Label4: TLabel
    Left = 8
    Top = 16
    Width = 136
    Height = 16
    Caption = 'Capacity (MBytes)'
  end
  object edtCapacity: TEdit
    Left = 150
    Top = 13
    Width = 90
    Height = 24
    Cursor = crArrow
    MaxLength = 3
    TabOrder = 0
    Text = '1024'
  end
  object btnOK: TButton
    Left = 8
    Top = 64
    Width = 90
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 150
    Top = 64
    Width = 90
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
