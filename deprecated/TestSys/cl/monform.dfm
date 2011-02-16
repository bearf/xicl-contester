object mon: Tmon
  Left = 220
  Top = 152
  Width = 507
  Height = 265
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1052#1086#1085#1080#1090#1086#1088
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 197
    Width = 499
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      499
      30)
    object SpeedButton4: TSpeedButton
      Left = 8
      Top = 6
      Width = 485
      Height = 19
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Flat = True
      OnClick = SpeedButton4Click
    end
  end
  object DrawGrid1: TDrawGrid
    Left = 0
    Top = 0
    Width = 499
    Height = 197
    Align = alClient
    BorderStyle = bsNone
    FixedColor = clWhite
    FixedCols = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goColSizing]
    ParentFont = False
    PopupMenu = PopupMenu1
    ScrollBars = ssVertical
    TabOrder = 1
    OnDrawCell = DrawGrid1DrawCell
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 48
    object RefreshItem: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      OnClick = RefreshItemClick
    end
    object N1: TMenuItem
      Caption = #1055#1077#1088#1077#1089#1095#1080#1090#1072#1090#1100' '#1088#1072#1079#1084#1077#1088
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object SaveHTMLItem: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082' HTML'
      OnClick = SaveHTMLItemClick
    end
    object SaveTextItem: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082' '#1090#1077#1082#1089#1090
      OnClick = SaveTextItemClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object CloseItem: TMenuItem
      Caption = #1047#1072#1082#1088#1099#1090#1100
      OnClick = CloseItemClick
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = '|*.txt||*.htm; *.html'
    Left = 8
    Top = 88
  end
end
