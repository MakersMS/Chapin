object MenuForm: TMenuForm
  Left = 958
  Top = 132
  BorderStyle = bsSingle
  Caption = #1052#1077#1090#1088#1080#1082#1072' '#1063#1077#1087#1080#1085#1072
  ClientHeight = 392
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 0
    Width = 155
    Height = 16
    Caption = #1040#1085#1072#1083#1080#1079#1080#1088#1091#1077#1084#1099#1081' '#1082#1086#1076':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Code: TMemo
    Left = 16
    Top = 24
    Width = 241
    Height = 257
    ScrollBars = ssBoth
    TabOrder = 0
    Visible = False
  end
  object LoadButton: TButton
    Left = 16
    Top = 288
    Width = 225
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1050#1086#1076
    TabOrder = 1
    OnClick = LoadButtonClick
  end
  object ChapinButton: TButton
    Left = 16
    Top = 320
    Width = 225
    Height = 25
    Caption = #1055#1086#1089#1095#1080#1090#1072#1090#1100' '#1052#1077#1090#1088#1080#1082#1091' '#1063#1077#1087#1080#1085#1072
    Enabled = False
    TabOrder = 2
    OnClick = ChapinButtonClick
  end
  object ResultButton: TButton
    Left = 16
    Top = 352
    Width = 225
    Height = 25
    Caption = #1055#1086#1076#1088#1086#1073#1085#1077#1077' '#1086' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1077
    Enabled = False
    TabOrder = 3
    OnClick = ResultButtonClick
  end
  object Codc: TMemo
    Left = 16
    Top = 16
    Width = 241
    Height = 257
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object LoadDialog: TOpenDialog
  end
  object SaveDialog: TSaveDialog
    Left = 40
  end
end
