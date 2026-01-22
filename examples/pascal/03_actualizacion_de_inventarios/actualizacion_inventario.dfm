object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 427
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 55
    Top = 8
    Width = 107
    Height = 15
    Caption = 'Codigo de producto'
  end
  object Label2: TLabel
    Left = 74
    Top = 51
    Width = 88
    Height = 15
    Caption = 'Nueva existencia'
  end
  object edCodProd: TEdit
    Left = 168
    Top = 8
    Width = 249
    Height = 23
    TabOrder = 0
  end
  object edNuevaExistencia: TEdit
    Left = 168
    Top = 48
    Width = 249
    Height = 23
    TabOrder = 1
  end
  object Button1: TButton
    Left = 256
    Top = 77
    Width = 75
    Height = 25
    Caption = 'Actualizar'
    TabOrder = 2
    OnClick = Button1Click
  end
  object memoLog: TMemo
    Left = 8
    Top = 130
    Width = 601
    Height = 289
    Lines.Strings = (
      'memoLog')
    TabOrder = 3
  end
end
