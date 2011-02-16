object info: Tinfo
  Left = 376
  Top = 229
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1087#1086' '#1079#1072#1076#1072#1095#1077
  ClientHeight = 247
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    380
    247)
  PixelsPerInch = 96
  TextHeight = 13
  object CloseButton: TSpeedButton
    Left = 168
    Top = 224
    Width = 59
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    Flat = True
    OnClick = CloseButtonClick
  end
  object TaskInfoMemo: TMemo
    Left = 0
    Top = 0
    Width = 380
    Height = 221
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    Ctl3D = True
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'TaskInfoMemo')
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
end
