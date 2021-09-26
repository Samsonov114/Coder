object GlForm: TGlForm
  Left = 940
  Top = 389
  Width = 886
  Height = 339
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Программа криптографической защиты информации "Барьер"'
  Color = clWindowText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  Visible = True
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 202
    Width = 868
    Height = 92
    Align = alBottom
    TabOrder = 0
    object Label1: TLabel
      Left = 6
      Top = 20
      Width = 109
      Height = 16
      Caption = 'Введите пароль:'
      Enabled = False
    end
    object Edit1: TEdit
      Left = 118
      Top = 10
      Width = 747
      Height = 24
      Hint = 'Для завершения ввода пароля нажмите "Enter"!'
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnKeyDown = Edit1KeyDown
    end
    object Button1: TButton
      Left = 645
      Top = 52
      Width = 102
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Зашифровать'
      Enabled = False
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 757
      Top = 52
      Width = 110
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Расшифровать'
      Enabled = False
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 18
      Top = 52
      Width = 93
      Height = 30
      Hint = 'Нажмите для выбора файла'
      Caption = 'Файл'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = Button3Click
    end
    object btList: TButton
      Left = 138
      Top = 52
      Width = 93
      Height = 30
      Hint = 'Нажмите для создания и редактирования списка  шифруемого файла.'
      Caption = 'Список'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btListClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 868
    Height = 70
    Align = alTop
    Enabled = False
    TabOrder = 1
    Visible = False
    object ProgressBar1: TProgressBar
      Left = 148
      Top = 20
      Width = 685
      Height = 30
      Min = 0
      Max = 100
      Smooth = True
      TabOrder = 0
    end
    object StaticText1: TStaticText
      Left = 10
      Top = 30
      Width = 124
      Height = 20
      Alignment = taRightJustify
      Caption = 'Идет шифрование'
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 70
    Width = 868
    Height = 132
    Align = alClient
    BorderStyle = bsSingle
    TabOrder = 2
    object Label2: TLabel
      Left = 1
      Top = 111
      Width = 862
      Height = 16
      Align = alBottom
      Alignment = taCenter
      Caption = 
        'Введите кодовую фразу и нажмите Enter, или можете выбрать другой' +
        ' файл. '
      Visible = False
    end
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 862
      Height = 72
      Align = alTop
      Lines.Strings = (
        ''
        ' '
        ''
        ''
        '')
      TabOrder = 0
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 24
    Top = 64
  end
  object SaveDialog1: TSaveDialog
    Left = 56
    Top = 64
  end
end
