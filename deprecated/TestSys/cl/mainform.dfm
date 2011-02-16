object main: Tmain
  Left = 519
  Top = 165
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1058#1077#1089#1090#1080#1088#1091#1102#1097#1072#1103' '#1089#1080#1089#1090#1077#1084#1072
  ClientHeight = 323
  ClientWidth = 272
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton5: TSpeedButton
    Left = 164
    Top = 296
    Width = 50
    Height = 21
    Caption = 'Logout'
    OnClick = SpeedButton5Click
  end
  object SpeedButton6: TSpeedButton
    Left = 218
    Top = 296
    Width = 50
    Height = 21
    Caption = #1042#1099#1093#1086#1076
    OnClick = SpeedButton6Click
  end
  object Label10: TLabel
    Left = 6
    Top = 4
    Width = 76
    Height = 13
    Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
  end
  object Label11: TLabel
    Left = 86
    Top = 4
    Width = 3
    Height = 13
  end
  object Label12: TLabel
    Left = 6
    Top = 300
    Width = 38
    Height = 13
    Caption = 'Label12'
    Visible = False
  end
  object SpeedButton9: TSpeedButton
    Left = 58
    Top = 296
    Width = 102
    Height = 21
    Caption = #1057#1084#1077#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
    Visible = False
    OnClick = SpeedButton9Click
  end
  object Label8: TLabel
    Left = 8
    Top = 24
    Width = 36
    Height = 13
    Caption = #1042#1088#1077#1084#1103':'
  end
  object Panel: TPanel
    Left = 4
    Top = 47
    Width = 265
    Height = 102
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      265
      102)
    object Label3: TLabel
      Left = 10
      Top = 4
      Width = 84
      Height = 13
      Caption = #1055#1086#1089#1099#1083#1082#1072' '#1079#1072#1076#1072#1095#1080
    end
    object Bevel: TBevel
      Left = 1
      Top = 20
      Width = 262
      Height = 9
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object Panel1: TPanel
      Left = 2
      Top = 24
      Width = 261
      Height = 76
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 4
        Top = 4
        Width = 32
        Height = 13
        Caption = '&'#1060#1072#1081#1083':'
        FocusControl = FileEdit
      end
      object SpeedButton1: TSpeedButton
        Left = 236
        Top = 1
        Width = 23
        Height = 21
        Caption = '...'
        OnClick = SpeedButton1Click
      end
      object SpeedButton2: TSpeedButton
        Left = 208
        Top = 50
        Width = 51
        Height = 21
        Caption = 'Submit'
        OnClick = SpeedButton2Click
      end
      object Label7: TLabel
        Left = 4
        Top = 30
        Width = 39
        Height = 13
        Caption = '&'#1047#1072#1076#1072#1095#1072':'
        FocusControl = TaskComboBox
      end
      object Label9: TLabel
        Left = 4
        Top = 54
        Width = 31
        Height = 13
        Caption = '&'#1071#1079#1099#1082':'
        FocusControl = LangComboBox
      end
      object TaskInfoButton: TSpeedButton
        Left = 208
        Top = 26
        Width = 51
        Height = 21
        Caption = #1048#1085#1092#1086
        OnClick = TaskInfoButtonClick
      end
      object FileEdit: TEdit
        Left = 64
        Top = 1
        Width = 169
        Height = 21
        MaxLength = 31
        TabOrder = 0
        OnChange = FileEditChange
      end
      object TaskComboBox: TComboBox
        Left = 64
        Top = 26
        Width = 141
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
      end
      object LangComboBox: TComboBox
        Left = 64
        Top = 50
        Width = 141
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
      end
    end
  end
  object Panel2: TPanel
    Left = 4
    Top = 153
    Width = 265
    Height = 74
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    DesignSize = (
      265
      74)
    object Label2: TLabel
      Left = 10
      Top = 4
      Width = 60
      Height = 13
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
    end
    object Bevel1: TBevel
      Left = 1
      Top = 20
      Width = 262
      Height = 9
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object Panel3: TPanel
      Left = 2
      Top = 23
      Width = 261
      Height = 49
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object Label4: TLabel
        Left = 4
        Top = 4
        Width = 59
        Height = 13
        Caption = #1055#1086#1089#1083#1077#1076#1085#1080#1081':'
      end
      object SpeedButton3: TSpeedButton
        Left = 166
        Top = 24
        Width = 93
        Height = 21
        Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
        OnClick = SpeedButton3Click
      end
      object Label5: TLabel
        Left = 4
        Top = 28
        Width = 29
        Height = 13
        Caption = #1044#1072#1090#1072':'
        Visible = False
      end
      object SpeedButton8: TSpeedButton
        Left = 236
        Top = 1
        Width = 23
        Height = 21
        Caption = 'R'
        OnClick = SpeedButton8Click
      end
      object LastResultEdit: TEdit
        Left = 64
        Top = 2
        Width = 167
        Height = 19
        Color = clBtnFace
        Ctl3D = False
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 0
        Text = 'LastResultEdit'
      end
      object DateTimePicker1: TDateTimePicker
        Left = 64
        Top = 24
        Width = 93
        Height = 21
        Date = 37462.000000000000000000
        Time = 37462.000000000000000000
        TabOrder = 1
        Visible = False
      end
    end
  end
  object Panel4: TPanel
    Left = 4
    Top = 231
    Width = 265
    Height = 58
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    DesignSize = (
      265
      58)
    object Label6: TLabel
      Left = 10
      Top = 4
      Width = 44
      Height = 13
      Caption = #1052#1086#1085#1080#1090#1086#1088
    end
    object Bevel2: TBevel
      Left = 1
      Top = 20
      Width = 262
      Height = 9
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object Panel5: TPanel
      Left = 2
      Top = 25
      Width = 261
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object SpeedButton7: TSpeedButton
        Left = 4
        Top = 2
        Width = 255
        Height = 21
        Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1084#1086#1085#1080#1090#1086#1088
        OnClick = SpeedButton7Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Pascal|*.pas|C/C++|*.c;*.cpp|All files|*.*'
    Title = 'Select file to submit'
    Left = 182
    Top = 2
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 212
    Top = 2
  end
  object PopupMenu1: TPopupMenu
    Left = 240
    object N1: TMenuItem
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      OnClick = N3Click
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMinimize = ApplicationEvents1Minimize
    Left = 152
  end
end
