object StartTournamentForm: TStartTournamentForm
  Left = 370
  Top = 258
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
  ClientHeight = 160
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 80
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1086' '#1090#1091#1088#1085#1080#1088#1072
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 106
    Height = 13
    Caption = #1047#1072#1074#1077#1088#1096#1077#1085#1080#1077' '#1090#1091#1088#1085#1080#1088#1072
  end
  object Label3: TLabel
    Left = 144
    Top = 128
    Width = 35
    Height = 13
    Caption = #1089#1077#1082#1091#1085#1076
  end
  object StartDatePicker: TDateTimePicker
    Left = 16
    Top = 24
    Width = 186
    Height = 21
    Date = 38401.530350289400000000
    Time = 38401.530350289400000000
    DateFormat = dfLong
    TabOrder = 0
  end
  object StartTimePicker: TDateTimePicker
    Left = 208
    Top = 24
    Width = 73
    Height = 21
    Date = 38401.531574791700000000
    Time = 38401.531574791700000000
    Kind = dtkTime
    TabOrder = 1
  end
  object StartTimeSetButton: TButton
    Left = 288
    Top = 22
    Width = 75
    Height = 25
    Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
    TabOrder = 2
    OnClick = StartTimeSetButtonClick
  end
  object ContinueTimeSetButton: TButton
    Left = 288
    Top = 70
    Width = 75
    Height = 25
    Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
    TabOrder = 3
    OnClick = ContinueTimeSetButtonClick
  end
  object FinishDatePicker: TDateTimePicker
    Left = 16
    Top = 72
    Width = 186
    Height = 21
    Date = 38401.530350289400000000
    Time = 38401.530350289400000000
    DateFormat = dfLong
    TabOrder = 4
  end
  object FinishTimePicker: TDateTimePicker
    Left = 208
    Top = 72
    Width = 73
    Height = 21
    Date = 38401.531574791700000000
    Time = 38401.531574791700000000
    Kind = dtkTime
    TabOrder = 5
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 112
    Width = 153
    Height = 17
    Caption = #1047#1072#1084#1086#1088#1086#1079#1082#1072' '#1084#1086#1085#1080#1090#1086#1088#1072' '#1079#1072
    TabOrder = 6
    OnClick = CheckBox1Click
  end
  object Button1: TButton
    Left = 288
    Top = 120
    Width = 75
    Height = 25
    Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
    TabOrder = 7
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 16
    Top = 128
    Width = 121
    Height = 21
    TabOrder = 8
    Text = 'Edit1'
  end
end
