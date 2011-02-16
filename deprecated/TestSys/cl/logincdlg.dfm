object loginC: TloginC
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103
  ClientHeight = 147
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OKButton: TButton
    Left = 109
    Top = 114
    Width = 75
    Height = 25
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 0
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 190
    Top = 114
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
    OnClick = CancelButtonClick
  end
  object Panel: TPanel
    Left = 8
    Top = 7
    Width = 257
    Height = 98
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object Label3: TLabel
      Left = 10
      Top = 6
      Width = 83
      Height = 13
      Caption = #1057#1084#1077#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
    end
    object Bevel: TBevel
      Left = 1
      Top = 24
      Width = 254
      Height = 9
      Shape = bsTopLine
    end
    object Panel1: TPanel
      Left = 2
      Top = 31
      Width = 253
      Height = 65
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 41
        Height = 13
        Caption = #1055#1072#1088#1086#1083#1100':'
        FocusControl = edit1
      end
      object Label2: TLabel
        Left = 8
        Top = 36
        Width = 40
        Height = 13
        Caption = #1055#1086#1074#1090#1086#1088':'
        FocusControl = edit2
      end
      object edit1: TEdit
        Left = 86
        Top = 5
        Width = 153
        Height = 21
        MaxLength = 31
        PasswordChar = '*'
        TabOrder = 0
      end
      object edit2: TEdit
        Left = 86
        Top = 33
        Width = 153
        Height = 21
        MaxLength = 31
        PasswordChar = '*'
        TabOrder = 1
      end
    end
  end
end
