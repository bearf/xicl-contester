object frConnect: TfrConnect
  Left = 192
  Top = 110
  BorderStyle = bsToolWindow
  Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1073#1072#1079#1086#1081' '#1076#1072#1085#1085#1099#1093
  ClientHeight = 163
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 20
    Height = 13
    Caption = 'host'
  end
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 20
    Height = 13
    Caption = 'user'
  end
  object Label3: TLabel
    Left = 16
    Top = 64
    Width = 45
    Height = 13
    Caption = 'password'
  end
  object Label4: TLabel
    Left = 16
    Top = 88
    Width = 44
    Height = 13
    Caption = 'database'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 72
    Width = 201
    Height = 50
    Shape = bsBottomLine
  end
  object edHost: TEdit
    Left = 88
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'localhost'
  end
  object edUser: TEdit
    Left = 88
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'contest'
  end
  object edPassword: TEdit
    Left = 88
    Top = 64
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
  end
  object edDataBase: TEdit
    Left = 88
    Top = 88
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'icl2015'
  end
  object btnOK: TButton
    Left = 56
    Top = 128
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 136
    Top = 128
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 5
    OnClick = btnCancelClick
  end
end
