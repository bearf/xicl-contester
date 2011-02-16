object res: Tres
  Left = 298
  Top = 136
  BorderIcons = []
  BorderStyle = bsSingle
  ClientHeight = 387
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    360
    387)
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton4: TSpeedButton
    Left = 284
    Top = 364
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    OnClick = SpeedButton4Click
  end
  object SpeedButton1: TSpeedButton
    Left = 205
    Top = 364
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 3
    Top = 364
    Width = 120
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1088#1077#1096#1077#1085#1080#1077
    OnClick = SpeedButton2Click
  end
  object DrawGrid1: TDrawGrid
    Left = 0
    Top = 0
    Width = 360
    Height = 257
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 3
    DefaultRowHeight = 16
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goDrawFocusSelected, goRowSelect, goThumbTracking]
    ScrollBars = ssVertical
    TabOrder = 0
    OnDrawCell = DrawGrid1DrawCell
    OnSelectCell = DrawGrid1SelectCell
    ColWidths = (
      177
      31
      124)
  end
  object GroupBox1: TGroupBox
    Left = 2
    Top = 260
    Width = 357
    Height = 101
    Caption = ' '#1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '
    TabOrder = 1
    object Label1: TLabel
      Left = 6
      Top = 18
      Width = 39
      Height = 13
      Caption = #1047#1072#1076#1072#1095#1072':'
    end
    object Label2: TLabel
      Left = 118
      Top = 18
      Width = 16
      Height = 13
      Caption = 'null'
    end
    object Label3: TLabel
      Left = 6
      Top = 32
      Width = 48
      Height = 13
      Caption = #1055#1086#1087#1099#1090#1082#1072':'
    end
    object Label4: TLabel
      Left = 118
      Top = 32
      Width = 16
      Height = 13
      Caption = 'null'
    end
    object Label5: TLabel
      Left = 6
      Top = 46
      Width = 83
      Height = 13
      Caption = #1042#1088#1077#1084#1103' '#1087#1086#1089#1099#1083#1082#1080':'
    end
    object Label6: TLabel
      Left = 118
      Top = 46
      Width = 16
      Height = 13
      Caption = 'null'
    end
    object Label7: TLabel
      Left = 6
      Top = 60
      Width = 109
      Height = 13
      Caption = #1042#1088#1077#1084#1103' '#1090#1077#1089#1090#1080#1088#1086#1074#1072#1085#1080#1103':'
    end
    object Label8: TLabel
      Left = 118
      Top = 60
      Width = 16
      Height = 13
      Caption = 'null'
    end
    object Label9: TLabel
      Left = 6
      Top = 74
      Width = 37
      Height = 13
      Caption = #1057#1090#1072#1090#1091#1089':'
    end
    object Label10: TLabel
      Left = 118
      Top = 74
      Width = 16
      Height = 13
      Caption = 'null'
    end
    object Label11: TLabel
      Left = 174
      Top = 72
      Width = 80
      Height = 13
      Caption = #1054#1095#1082#1080' '#1079#1072' '#1079#1072#1076#1072#1095#1091':'
      Visible = False
    end
    object Label12: TLabel
      Left = 286
      Top = 72
      Width = 16
      Height = 13
      Caption = 'null'
      Visible = False
    end
    object Label13: TLabel
      Left = 6
      Top = 86
      Width = 108
      Height = 13
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090' '#1087#1086' '#1079#1072#1076#1072#1095#1077':'
    end
    object Label14: TLabel
      Left = 118
      Top = 86
      Width = 16
      Height = 13
      Caption = 'null'
    end
    object Label15: TLabel
      Left = 174
      Top = 84
      Width = 90
      Height = 13
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' "OK":'
      Visible = False
    end
    object Label16: TLabel
      Left = 286
      Top = 84
      Width = 16
      Height = 13
      Caption = 'null'
      Visible = False
    end
    object Label17: TLabel
      Left = 174
      Top = 58
      Width = 43
      Height = 13
      Caption = #1054#1096#1080#1073#1082#1080':'
      Visible = False
    end
    object Label18: TLabel
      Left = 286
      Top = 58
      Width = 16
      Height = 13
      Caption = 'null'
      Visible = False
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Pascal|*.pas|C/C++|*.c;*.cpp|All files|*.*'
    Left = 4
    Top = 8
  end
end
