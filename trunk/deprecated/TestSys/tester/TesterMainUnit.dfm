object TesterMainForm: TTesterMainForm
  Left = 333
  Top = 147
  Width = 619
  Height = 510
  Caption = #1058#1077#1089#1090#1080#1088#1091#1102#1097#1072#1103' '#1089#1080#1089#1090#1077#1084#1072
  Color = clBtnFace
  Constraints.MinHeight = 255
  Constraints.MinWidth = 523
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object RichEdit: TMemo
    Left = 0
    Top = 0
    Width = 504
    Height = 433
    TabStop = False
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 504
    Top = 0
    Width = 107
    Height = 433
    Align = alRight
    BevelInner = bvLowered
    TabOrder = 1
    Visible = False
    object TesterBitBtn: TBitBtn
      Left = 16
      Top = 16
      Width = 75
      Height = 25
      Caption = #1057#1090#1072#1088#1090
      TabOrder = 0
      OnClick = TesterBitBtnClick
    end
    object ClearBitBtn: TBitBtn
      Left = 16
      Top = 48
      Width = 75
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 1
      OnClick = ClearBitBtnClick
    end
    object ExitBitBtn: TBitBtn
      Left = 16
      Top = 80
      Width = 75
      Height = 25
      Caption = #1042#1099#1093#1086#1076
      TabOrder = 2
      OnClick = ExitBitBtnClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 433
    Width = 611
    Height = 19
    Panels = <>
  end
  object ApplicationEvents: TApplicationEvents
    Left = 32
    Top = 16
  end
  object MainMenu: TMainMenu
    Left = 32
    Top = 72
    object N11: TMenuItem
      Caption = '&'#1058#1091#1088#1085#1080#1088
      object StartTournamentMenu: TMenuItem
        Caption = '&'#1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099'...'
        Visible = False
        OnClick = StartTournamentMenuClick
      end
      object N16: TMenuItem
        Caption = '-'
        Visible = False
      end
      object N17: TMenuItem
        Caption = '&'#1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1090#1077#1089#1090#1077#1088
        OnClick = N17Click
      end
      object N18: TMenuItem
        Caption = '&'#1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1090#1077#1089#1090#1077#1088
        Enabled = False
        OnClick = N18Click
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object N20: TMenuItem
        Caption = '&'#1042#1099#1093#1086#1076
        OnClick = N20Click
      end
    end
    object N12: TMenuItem
      Caption = '&'#1052#1086#1085#1080#1090#1086#1088
      Visible = False
      object N13: TMenuItem
        Caption = #1055#1086#1076'&'#1075#1086#1090#1086#1074#1080#1090#1100
        OnClick = N13Click
      end
      object N14: TMenuItem
        Caption = #1055#1077#1088#1077#1089'&'#1095#1080#1090#1072#1090#1100
        OnClick = N14Click
      end
      object N15: TMenuItem
        Caption = #1055#1086#1089'&'#1084#1086#1090#1088#1077#1090#1100
        OnClick = N15Click
      end
    end
    object N1: TMenuItem
      Caption = '&'#1069#1082#1088#1072#1085
      object N2: TMenuItem
        Caption = '&'#1054#1095#1080#1089#1090#1080#1090#1100
        OnClick = ClearBitBtnClick
      end
      object N3: TMenuItem
        Caption = '&'#1064#1088#1080#1092#1090'...'
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = '&'#1060#1086#1085'...'
        OnClick = N4Click
      end
    end
    object N6: TMenuItem
      Caption = #1041#1044
      Visible = False
      object N7: TMenuItem
        Caption = #1047#1072#1076#1072#1095#1080
        object N8: TMenuItem
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100
          OnClick = N8Click
        end
      end
      object N9: TMenuItem
        Caption = #1059#1095#1072#1089#1090#1085#1080#1082#1080
        object N10: TMenuItem
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100
          OnClick = N10Click
        end
      end
    end
    object N5: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      Visible = False
      OnClick = ExitBitBtnClick
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 32
    Top = 128
  end
  object ColorDialog: TColorDialog
    Left = 32
    Top = 176
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 32
    Top = 240
  end
end
