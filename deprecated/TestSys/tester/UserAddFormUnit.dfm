object UserAddForm: TUserAddForm
  Left = 340
  Top = 198
  BorderStyle = bsToolWindow
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1091#1095#1072#1089#1090#1085#1080#1082#1072
  ClientHeight = 210
  ClientWidth = 233
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
  object NameEdit: TLabeledEdit
    Left = 8
    Top = 24
    Width = 217
    Height = 21
    EditLabel.Width = 25
    EditLabel.Height = 13
    EditLabel.Caption = #1048#1084#1103':'
    TabOrder = 0
  end
  object LoginEdit: TLabeledEdit
    Left = 8
    Top = 64
    Width = 217
    Height = 21
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = #1059#1095#1077#1090#1085#1072#1103' '#1079#1072#1087#1080#1089#1100':'
    TabOrder = 1
  end
  object PassEdit: TLabeledEdit
    Left = 8
    Top = 104
    Width = 217
    Height = 21
    EditLabel.Width = 41
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1072#1088#1086#1083#1100':'
    PasswordChar = '*'
    TabOrder = 2
  end
  object IPEdit: TLabeledEdit
    Left = 8
    Top = 144
    Width = 217
    Height = 21
    EditLabel.Width = 43
    EditLabel.Height = 13
    EditLabel.Caption = 'IP-'#1072#1076#1088#1077#1089
    TabOrder = 3
  end
  object OkButton: TButton
    Left = 32
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 4
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 128
    Top = 176
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 5
    OnClick = CancelButtonClick
  end
end
