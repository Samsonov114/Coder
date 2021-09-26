unit USpisok;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfmSpisok = class(TForm)
    Panel1: TPanel;
    btAdd: TButton;
    btDel: TButton;
    btSave: TButton;
    ListBox1: TListBox;
    btExit: TButton;
    lbKod: TLabel;
    edKod: TEdit;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    procedure btExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btAddClick(Sender: TObject);
    procedure btDelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmSpisok: TfmSpisok;

implementation

{$R *.DFM}

procedure TfmSpisok.btExitClick(Sender: TObject);
begin
   close;
end;

procedure TfmSpisok.FormCreate(Sender: TObject);
begin
   ListBox1.Items.LoadFromFile('list.txt');
end;

procedure TfmSpisok.btAddClick(Sender: TObject);
var FileName : string;
begin
   if OpenDialog1.Execute then
   begin
     FileName := OpenDialog1.Filename;
     ListBox1.Items.Add(FileName);
   end // then
else
   begin
     MessageBeep(MB_OK);
     MessageDlg('Должен быть выбран файл!', mtInformation,
                      [mbOk], 0);
   end;
end;

procedure TfmSpisok.btDelClick(Sender: TObject);
begin
   ListBox1.Items.Delete(ListBox1.ItemIndex);
end;

procedure TfmSpisok.btSaveClick(Sender: TObject);
begin
  ListBox1.Items.SaveToFile('list.txt');
end;

end.
