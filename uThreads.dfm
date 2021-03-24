object ThreadsForm: TThreadsForm
  Left = 0
  Top = 0
  Caption = 'ThreadsForm'
  ClientHeight = 375
  ClientWidth = 481
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI Semibold'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  DesignSize = (
    481
    375)
  PixelsPerInch = 96
  TextHeight = 13
  object StartButton: TButton
    Left = 8
    Top = 116
    Width = 105
    Height = 33
    Caption = 'Start Log'
    TabOrder = 0
    OnClick = StartButtonClick
  end
  object LogFileNameEdit: TEdit
    Left = 8
    Top = 8
    Width = 216
    Height = 21
    ReadOnly = True
    TabOrder = 1
    Text = 'LogFileNameEdit'
  end
  object StopButton: TButton
    Left = 119
    Top = 116
    Width = 105
    Height = 33
    Caption = 'Stop Log'
    TabOrder = 2
    OnClick = StopButtonClick
  end
  object OptionGrid: TStringGrid
    Left = 8
    Top = 35
    Width = 465
    Height = 75
    Anchors = [akLeft, akRight]
    RowCount = 2
    TabOrder = 3
  end
  object LogMemo: TMemo
    Left = 8
    Top = 155
    Width = 465
    Height = 212
    TabOrder = 4
  end
  object ShowButton: TButton
    Left = 230
    Top = 116
    Width = 110
    Height = 33
    Caption = 'Show Log'
    TabOrder = 5
    OnClick = ShowButtonClick
  end
  object IniFileNameEdit: TEdit
    Left = 230
    Top = 8
    Width = 243
    Height = 21
    ReadOnly = True
    TabOrder = 6
    Text = 'IniFileNameEdit'
  end
end
