object TesterMainForm: TTesterMainForm
  Left = 162
  Top = 175
  AlphaBlendValue = 128
  BorderStyle = bsNone
  Caption = ')'
  ClientHeight = 516
  ClientWidth = 652
  Color = clMaroon
  TransparentColor = True
  TransparentColorValue = clMaroon
  Constraints.MinHeight = 255
  Constraints.MinWidth = 523
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 652
    Height = 516
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlData'
    Color = clMaroon
    TabOrder = 0
    object pbTest: TPaintBox
      Left = 0
      Top = 32
      Width = 321
      Height = 484
      Align = alCustom
      Anchors = [akLeft, akTop, akBottom]
      OnPaint = pbTestPaint
    end
    object pbLog: TPaintBox
      Left = 320
      Top = 32
      Width = 332
      Height = 484
      Align = alCustom
      Anchors = [akLeft, akTop, akBottom]
      OnPaint = pbLogPaint
    end
    object pbConsole: TPaintBox
      Left = 0
      Top = 0
      Width = 652
      Height = 33
      Align = alCustom
      Anchors = [akLeft, akTop, akRight]
      OnPaint = pbConsolePaint
    end
  end
  object ApplicationEvents: TApplicationEvents
    Left = 8
    Top = 8
  end
end
