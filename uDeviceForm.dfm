object DeviceForm: TDeviceForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select Device'
  ClientHeight = 570
  ClientWidth = 723
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Fixedsys'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 164
    Width = 96
    Height = 16
    Caption = 'Manufacturer'
  end
  object Label2: TLabel
    Left = 232
    Top = 164
    Width = 88
    Height = 16
    Caption = 'Device Name'
  end
  object Label3: TLabel
    Left = 8
    Top = 112
    Width = 48
    Height = 16
    Caption = 'Search'
  end
  object Label10: TLabel
    Left = 536
    Top = 424
    Width = 72
    Height = 16
    Caption = 'Sram Size'
  end
  object Label9: TLabel
    Left = 536
    Top = 372
    Width = 72
    Height = 16
    Caption = 'Sram Base'
  end
  object Label8: TLabel
    Left = 536
    Top = 320
    Width = 80
    Height = 16
    Caption = 'Flash Size'
  end
  object Label7: TLabel
    Left = 536
    Top = 268
    Width = 80
    Height = 16
    Caption = 'Flash Base'
  end
  object Label6: TLabel
    Left = 536
    Top = 216
    Width = 32
    Height = 16
    Caption = 'Core'
  end
  object Label5: TLabel
    Left = 536
    Top = 164
    Width = 48
    Height = 16
    Caption = 'Device'
  end
  object Label4: TLabel
    Left = 536
    Top = 112
    Width = 96
    Height = 16
    Caption = 'Manufacturer'
  end
  object lbDeviceName: TListBox
    Left = 232
    Top = 186
    Width = 289
    Height = 367
    TabStop = False
    Ctl3D = True
    Items.Strings = (
      'STM32F100C4'
      'STM32F100C6'
      'STM32F100C8'
      'STM32F100CB'
      'STM32F100R4'
      'STM32F100R6'
      'STM32F100R8'
      'STM32F100RB'
      'STM32F100RC'
      'STM32F100RD'
      'STM32F100RE'
      'STM32F100V8'
      'STM32F100VB'
      'STM32F100VC'
      'STM32F100VD'
      'STM32F100VE'
      'STM32F100ZC'
      'STM32F100ZD'
      'STM32F100ZE'
      'STM32F101C4'
      'STM32F101C6'
      'STM32F101C8'
      'STM32F101CB'
      'STM32F101R4'
      'STM32F101R6'
      'STM32F101R8'
      'STM32F101RB'
      'STM32F101RC'
      'STM32F101RD'
      'STM32F101RE'
      'STM32F101RF'
      'STM32F101RG'
      'STM32F101T4'
      'STM32F101T6'
      'STM32F101T8'
      'STM32F101V8'
      'STM32F101VB'
      'STM32F101VC'
      'STM32F101VD'
      'STM32F101VE'
      'STM32F101VF'
      'STM32F101VG'
      'STM32F101ZC'
      'STM32F101ZD'
      'STM32F101ZE'
      'STM32F101ZF'
      'STM32F101ZG')
    ParentCtl3D = False
    TabOrder = 2
    OnClick = lbDeviceNameClick
    OnDblClick = lbDeviceNameDblClick
  end
  object lbManuafacturerName: TListBox
    Left = 8
    Top = 186
    Width = 201
    Height = 367
    TabStop = False
    Items.Strings = (
      'Actel'
      'Altera'
      'Analog'
      'Atmel'
      'AyDeeKay'
      'Cirrus Logic'
      'Cypress'
      'Digi'
      'Ember'
      'Energy Micro'
      'Epson'
      'Faraday'
      'Freescale'
      'Fujitsu'
      'Hilscher'
      'Holtek'
      'Infineon'
      'Itron'
      'Luminary'
      'Manufacturer'
      'Marvell'
      'Maxim'
      'Microchip'
      'Micronas'
      'Microsemi'
      'NXP'
      'Nordic Semi'
      'Nuvoton'
      'OKI'
      'ON Semi'
      'Quintic'
      'Renesas'
      'ST'
      'Samsung'
      'Silicon Labs'
      'Socle'
      'Sonix'
      'Spansion'
      'TI'
      'Toshiba'
      'Unspecified'
      'Xilinx')
    TabOrder = 1
    OnClick = lbManuafacturerNameClick
  end
  object btnCancel: TButton
    Left = 536
    Top = 528
    Width = 178
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    TabStop = False
  end
  object btnOK: TButton
    Left = 536
    Top = 488
    Width = 178
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 4
    TabStop = False
  end
  object rgCoreType: TRadioGroup
    Left = 8
    Top = 8
    Width = 513
    Height = 85
    Caption = 'Core'
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'Cortex-M0'
      'Cortex-M3'
      'Cortex-M4'
      'Any')
    TabOrder = 5
    OnClick = rgCoreTypeClick
  end
  object edtSearch: TEdit
    Left = 8
    Top = 134
    Width = 513
    Height = 24
    TabOrder = 0
    OnKeyUp = edtSearchKeyUp
  end
  object edtSramSize: TEdit
    Left = 536
    Top = 446
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 6
    OnEnter = edtManuafacturerEnter
  end
  object edtSramBase: TEdit
    Left = 536
    Top = 394
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 7
    OnEnter = edtManuafacturerEnter
  end
  object edtFlashSize: TEdit
    Left = 536
    Top = 342
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 8
    OnEnter = edtManuafacturerEnter
  end
  object edtFlashBase: TEdit
    Left = 536
    Top = 290
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 9
    OnEnter = edtManuafacturerEnter
  end
  object edtCore: TEdit
    Left = 536
    Top = 238
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 10
    OnEnter = edtManuafacturerEnter
  end
  object edtDevice: TEdit
    Left = 536
    Top = 186
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 11
    OnEnter = edtManuafacturerEnter
  end
  object edtManuafacturer: TEdit
    Left = 536
    Top = 134
    Width = 178
    Height = 24
    Cursor = crArrow
    TabStop = False
    ReadOnly = True
    TabOrder = 12
    OnEnter = edtManuafacturerEnter
  end
  object GroupBox1: TGroupBox
    Left = 536
    Top = 16
    Width = 178
    Height = 77
    TabOrder = 13
    object imgManuafacturerLogo: TImage
      Left = 27
      Top = 1
      Width = 124
      Height = 75
      Transparent = True
    end
  end
end
