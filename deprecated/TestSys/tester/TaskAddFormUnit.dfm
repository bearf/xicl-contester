object TaskAddForm: TTaskAddForm
  Left = 412
  Top = 215
  BorderStyle = bsToolWindow
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1079#1072#1076#1072#1095#1091
  ClientHeight = 410
  ClientWidth = 243
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object OkButton: TButton
    Left = 24
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 0
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 128
    Top = 376
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 1
    OnClick = CancelButtonClick
  end
  object TaskEdit: TLabeledEdit
    Left = 8
    Top = 24
    Width = 225
    Height = 21
    EditLabel.Width = 50
    EditLabel.Height = 13
    EditLabel.Caption = #1053#1072#1079#1074#1072#1085#1080#1077
    TabOrder = 2
  end
  object AuthorEdit: TLabeledEdit
    Left = 8
    Top = 64
    Width = 225
    Height = 21
    EditLabel.Width = 30
    EditLabel.Height = 13
    EditLabel.Caption = #1040#1074#1090#1086#1088
    TabOrder = 3
  end
  object InputEdit: TLabeledEdit
    Left = 8
    Top = 104
    Width = 225
    Height = 21
    EditLabel.Width = 71
    EditLabel.Height = 13
    EditLabel.Caption = #1042#1093#1086#1076#1085#1086#1081' '#1092#1072#1081#1083
    TabOrder = 4
    Text = 'input.txt'
  end
  object OutputEdit: TLabeledEdit
    Left = 8
    Top = 144
    Width = 225
    Height = 21
    EditLabel.Width = 79
    EditLabel.Height = 13
    EditLabel.Caption = #1042#1099#1093#1086#1076#1085#1086#1081' '#1092#1072#1081#1083
    TabOrder = 5
    Text = 'output.txt'
  end
  object RansEdit: TLabeledEdit
    Left = 8
    Top = 184
    Width = 225
    Height = 21
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = #1060#1072#1081#1083' '#1086#1090#1074#1077#1090#1072
    TabOrder = 6
    Text = 'rans.txt'
  end
  object CheckerEdit: TLabeledEdit
    Left = 8
    Top = 224
    Width = 225
    Height = 21
    EditLabel.Width = 32
    EditLabel.Height = 13
    EditLabel.Caption = #1063#1077#1082#1077#1088
    TabOrder = 7
    Text = '.exe'
  end
  object TestCountEdit: TLabeledEdit
    Left = 8
    Top = 264
    Width = 225
    Height = 21
    EditLabel.Width = 96
    EditLabel.Height = 13
    EditLabel.Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1090#1077#1089#1090#1086#1074
    TabOrder = 8
  end
  object TimeLimitEdit: TLabeledEdit
    Left = 8
    Top = 304
    Width = 225
    Height = 21
    EditLabel.Width = 128
    EditLabel.Height = 13
    EditLabel.Caption = #1054#1075#1088#1072#1085#1080#1095#1077#1085#1080#1077' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080
    TabOrder = 9
    Text = '0'
  end
  object MemLimitEdit: TLabeledEdit
    Left = 8
    Top = 344
    Width = 225
    Height = 21
    EditLabel.Width = 121
    EditLabel.Height = 13
    EditLabel.Caption = #1054#1075#1088#1072#1085#1080#1095#1077#1085#1080#1077' '#1087#1086' '#1087#1072#1084#1103#1090#1080
    TabOrder = 10
    Text = '0'
  end
end
