object frMain: TfrMain
  Left = 192
  Top = 113
  Width = 870
  Height = 640
  Caption = #1086#1095#1077#1088#1077#1076#1100' '#1087#1077#1095#1072#1090#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mainMenu
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object meLog: TMemo
    Left = 0
    Top = 0
    Width = 862
    Height = 594
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object mySQLTimer: TTimer
    Enabled = False
    OnTimer = mySQLTimerTimer
    Left = 16
    Top = 40
  end
  object mainMenu: TMainMenu
    Left = 48
    Top = 40
    object itmPrint: TMenuItem
      Caption = '&'#1055#1077#1095#1072#1090#1100
      object itmAwake: TMenuItem
        Caption = '&'#1047#1072#1087#1091#1089#1082
        OnClick = itmAwakeClick
      end
      object itmPause: TMenuItem
        Caption = '&'#1055#1072#1091#1079#1072
        Enabled = False
        OnClick = itmPauseClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object itmExit: TMenuItem
        Caption = #1042'&'#1099#1093#1086#1076
        OnClick = itmExitClick
      end
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMinimize = ApplicationEvents1Minimize
    Left = 80
    Top = 40
  end
end
