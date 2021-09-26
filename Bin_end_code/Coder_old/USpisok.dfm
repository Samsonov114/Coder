object fmSpisok: TfmSpisok
  Left = 890
  Top = 257
  BorderStyle = bsSingle
  Caption = 'Список файлов для экстренного кодирования'
  ClientHeight = 573
  ClientWidth = 792
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 480
    Width = 792
    Height = 93
    Align = alBottom
    TabOrder = 0
    object lbKod: TLabel
      Left = 16
      Top = 64
      Width = 308
      Height = 16
      Caption = 'Кодовая фраза для экстренного кодирования: '
      Enabled = False
    end
    object Label1: TLabel
      Left = 16
      Top = 48
      Width = 143
      Height = 16
      Caption = 'Разрешение экрана0-'
      Visible = False
    end
    object btAdd: TButton
      Left = 16
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Добавить'
      TabOrder = 0
      OnClick = btAddClick
    end
    object btDel: TButton
      Left = 112
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Удалить'
      TabOrder = 1
      OnClick = btDelClick
    end
    object btSave: TButton
      Left = 208
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Сохранить'
      TabOrder = 2
      OnClick = btSaveClick
    end
    object btExit: TButton
      Left = 699
      Top = 16
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Выход'
      TabOrder = 3
      OnClick = btExitClick
    end
    object edKod: TEdit
      Left = 328
      Top = 56
      Width = 452
      Height = 24
      Anchors = [akTop, akRight]
      AutoSize = False
      Enabled = False
      TabOrder = 4
    end
  end
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 792
    Height = 480
    Align = alClient
    ItemHeight = 16
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    Left = 16
    Top = 16
  end
end
