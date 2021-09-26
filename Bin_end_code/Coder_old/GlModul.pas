unit GlModul;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, USpisok;

type
  TCodeStr = record
    letter : Char;
    code   : integer
    end;
  TCodeTabl = array [0..255] of TCodeStr;
  TEndTabl = array of TCodeTabl; //��� �������� ��������� (=����� ������+1), ���������� ����� ������� �� ord(����� ������)
  TGlForm = class(TForm)
    Panel1: TPanel;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    ProgressBar1: TProgressBar;
    StaticText1: TStaticText;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button3: TButton;
    Panel3: TPanel;
    btList: TButton;
    Label2: TLabel;
    Memo1: TMemo;
    procedure OpenFiles;
    procedure MakeCode;
    function Code(symbol : AnsiChar): AnsiChar;
    function deCode(symbol : AnsiChar): AnsiChar;
    function GetCurrentDateTime: TDateTime;
    function SearchText(FileName: string; Text: string) : LongInt;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btListClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GlForm: TGlForm;
  NewCode : TCodeTabl;
  EndCode : TEndTabl;
  FNameInp,FNameOut, pw : string;
  FromF, ToF: file;
  flag : boolean;
  sdvig : byte = 1;   //��� �������� �� 100% �������������, �� ����� ���������� �� ������ ������!! ���� �����������!!     // �����������,�� ��� ������������!! ��� ������ � ������� �������� �� ������ ������� ������� �� �������� ���������!
  // �� ���� ������ ����� (��������� 0), �� ��� ������ �� ��������!! ������� �� ����� � ���������� ���������??
  n_zaprosa : word = 0;      // ��� Word, �� ����� ������ �� ����� 65535 ��������!,
  index : word = 0;          // ������� ������� � ������(J-�� ������� ���������)
//  period : byte = 4;         // ����������� ����� ������� ��������� (����� period ��������)  ���� �������! ������ ������ ���� 1!!
  tek : byte = 0;            // � ������� �������

implementation

{$R *.DFM}

//*************************************
// ��������� ��������� ���� � ������� *
//*************************************

function TGLForm.GetCurrentDateTime: TDateTime;
var
  SystemTime: TSystemTime;
begin

  GetLocalTime(SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

//***********************************************************************************
// ����� � ����� ��������� ���������� ���������                                     *
// (�� �������� � ������� ����� 2147483647 ����!!!)                                 *                                               *
// ���������� ������� ���������� �� ���������� ����� ��� 0, ���� �������� �� ������.*
//***********************************************************************************
// ����� ������ ��� �������� ���������� ���������� ��������/����������!!

function TGLForm.SearchText(FileName: string; Text: string) : LongInt;
var
  FromF: file;
  symbol : char;
  NumRead, i, k : integer;
  flag : boolean;
begin
  flag := true;
  k := 1;
  AssignFile(FromF, FileName);
  Reset(FromF, 1);	{ Record size = 1}
  BlockRead(FromF, symbol, 1, NumRead);
  if NumRead <> -1 then
          begin

           while (not Eof(FromF)) and flag do
           begin
             if symbol=Text[k]
               then
                 begin
                   k := k+1;
                   BlockRead(FromF, symbol, 1, NumRead);
                 end
               else
                 if k=(Length(Text)+1)
                   then
                     begin
                       Result := FilePos(FromF)-1;
                       flag := false;
                     end
                   else
                     begin
                       k:=1;
                       BlockRead(FromF, symbol, 1, NumRead);
                     end;

           end;
           if flag then Result := 0;
           CloseFile(FromF);
          end
        else
          begin
          MessageDlg('�������� � ��������� ����� '+FileName+' ��� ������!!', mtInformation,
                      [mbOk], 0);
          Result := 0;
          end;
end;

//**************************************************
//������� ������������� ������� �� ������� ������� *
//**************************************************

function TGLForm.deCode(symbol : AnsiChar): AnsiChar;
var k : integer;
begin
  if index > Length(pw) then index :=1;
  k := 0+sdvig;
  if ord (symbol) >= sdvig then
    begin
       while (EndCode[index-1,k].code <> Ord(symbol)) do inc(k);
       deCode := EndCode[index-1,k].letter;
    end
  else
    begin
      deCode := symbol;
    end;
  inc(index);
end;
//**********************************************
//������� ��������� ������� �� ������� ������� *
//**********************************************

function TGLForm.Code(symbol : AnsiChar): AnsiChar;
var k : integer;
begin
 if index > Length(pw) then index :=1;
 k := 0+sdvig;

 if ord (symbol) >= sdvig then
         begin
           while (EndCode[index-1,k].letter <> symbol) do inc(k);
           Code := Chr(EndCode[index-1,k].code);
         end
 else
   Code := symbol;

 inc(index);
end;

//************************************************
// �������� ������� ������� �� ���������� ������ *
// ������� ������ ����������� 1 ���!! ����� ������ ������� ����� �� ord(����� ������)!
// ���� ����������� ��� � ������� ���������/�����������!! ������� ����� � ��������� �� ����� ����� ����� ������
// ��� ����� �����!
//************************************************
procedure TGlForm.MakeCode;
var   k,i,j : integer;
      symbol  : AnsiChar;
begin
  Edit1.Text := Edit1.Text + '�������������������������������������Ũ�������ABCDXYZefgijklmn'; //����������� ����� ������
  pw := Edit1.text;
  {������� ������ �������}
  for i:=0 to sdvig-1 do
    begin
      NewCode[i].letter := Chr(i);
      NewCode[i].code := i;
    end;
  for i:=0+sdvig to 255 do
   begin
     NewCode[i].letter := Chr(i);
     NewCode[i].code := 256;
   end;
// ����� � ���������?? ����� ������� ��������� �� �������, ���� �� ����������� �� ������������??
// �������� ��� ���� ������������ ��� ��������� ����������? (�� ������� ������������ ��������, �. �. �� ���������� ������ � ����������??)
// ����� ����� ���� �� ������� ��������� (ord = 13) ������.  ������, ����� �������� �� �����!!
// �� - �����!!! �� ������� ��������������, ����� �� �������� (������ ����� ��-�� 0-�� �������!!!)

//���� ����� ������ � ������� �������� ������ ��� ��������, ������� ����� � ������ + �����, ������� ������ ���� � ������.
     k:=0+sdvig;
     for i:=1 to length(Edit1.text) do
         begin
           if ord(Edit1.Text[i])>= sdvig then //���������� ���
              begin
                 symbol := Char(Edit1.Text[i]);
                 j :=0+sdvig;
                 while (NewCode[j].letter <> symbol) do
                       inc(j);
                 if NewCode[j].code = 256 then
                   begin
                     NewCode[j].code := k;
                     inc(k);
                   end;
           end; //if
         end;//for


         {��������� ������� ��������}
   for i:=0+sdvig to 255 do
      if NewCode[i].code = 256 then
             begin
                NewCode[i].code := k;
                inc(k);
             end;
// �������� �������� ������� �� ��������� ������(� �������������� ��������, �������� � ������)

// ����� ���� ������� ������ ���� ���������, ������������ �� ����� ord(����� ������), �������� �
// ���������� �������� ������+1
SetLength(EndCode, Length(pw)); //�������� ����� ��� ��� �������� ��������� (�� ������ ����������!! Finalize(EndCode) )

// ��������� ������ �������
for i :=0 to 255 do
   EndCode[0,i] := NewCode[i];

// ������ �������� �� ����� ������, ��������� ��������� (� ����������� �� ����� ������) �������
for j := 1 to Length(pw)-1 do
   begin
      k := ord(pw[j]);
      for i := 0 to sdvig-1 do EndCode[j,i] := NewCode[i]; //��������� ������� ���������

// ��������� ������
      for i :=sdvig to 255 do
         begin
            EndCode[j,i] := NewCode[i];
            EndCode[j,i].code := EndCode[j-1,i].code+k;
            if EndCode[j,i].code > 255 then EndCode[j,i].code := sdvig+EndCode[j,i].code - 256;//??
         end;
   end;
 Edit1.text := '';
// ��� ���������� ��� ������ - pw. �������� � ���� ��� �� ��� � ����������� ������ �� ��������� ���������
end;


//***************************************
// ��������� ����� ����� ������         *
//***************************************
procedure TGlForm.OpenFiles;
begin
 flag := false; // ������ � ��� �� ����

 {case MessageDlg('������ ��� ����� ����������?', mtCustom,
                  [mbYes, mbNo], 0) of
          mrYes:begin
                 flag := true; // ������� ��� ������ �����
                 if SaveDialog1.Execute then
                    begin
                    FNameOut := SaveDialog1.Filename;
                    end
                 else
                    begin
                    MessageDlg('�� �� ������ ��� �����! ��������� ����� ������� � ���� temp1.cdc',
                               mtCustom, [mbOk], 0);
                    FNameOut := 'temp1.cdc';
                    end;
                end;
          mrNo: begin

                 MessageDlg('��������� ����� ������� � ���� temp1.cdc',
                               mtCustom, [mbOk], 0);
                 FNameOut := 'temp1.cdc';
                end;
          end // case }
end;


procedure TGlForm.Button1Click(Sender: TObject);
var ErrorCode,n,i,NumRead,NumWritten : integer;
    symbol : char;
    str  : string;
    str1 : string[2];
    HandleFileInp, Size : integer;
    Buf: array[1..20480] of Char; // ����� ���������� ��� ������������ ������, ������ ������� �������!!
    T1, T2 : TDateTime;
    Time1, Time2 : TTimeStamp;
    F_Pos, Count_Byte : LongInt;
begin

  index :=0;
  Finalize(EndCode);

  MakeCode;
  Button1.Enabled := false;
  Button2.Enabled := false;
  Button3.Enabled := false;
  btList.Enabled := false;
  Edit1.Enabled := false;
  OpenFiles;
  AssignFile(FromF, FNameInp);
  Reset(FromF, 1);	{ Record size = 1}
  AssignFile(ToF, FNameOut); { Open output file}
  Rewrite(ToF, 1);	{ Record size = 1}
  if (sender as TButton).Name = 'Button2' then
          GlForm.StaticText1.Caption:='�����������:';
  GlForm.Panel2.Visible := true;
  StaticText1.Repaint;
  Memo1.Lines.Strings[0] := '�������� ����: '+FNameInp+'.';
//  Memo1.Lines.Strings[1] := '��������� � '+FNameOut;
  Memo1.Repaint;
  Panel3.Caption := '';
  //'�������� ����: '+FNameInp+'. ��������� � '+FNameOut;
  Panel3.Repaint;
  n:=0;
  ProgressBar1.Max := Trunc(FileSize(FromF)/SizeOf(Buf));

//********************************
// ����� ����������
//********************************
 { str:= 'C:\Program Files\Borland\Delphi5\��� �������\������������\USpisok.dfm';
  F_Pos := SearchText(str, '���������� ������');
  if F_Pos>0 then
      begin
        AssignFile(FromF, str);
        Reset(FromF,1);
        Seek(FromF,F_Pos);
        str1 := '';
        BlockRead(FromF,symbol,1);
        str1 := str1+symbol;
        BlockRead(FromF,symbol,1);
        str1 := str1+symbol;
        CloseFile(FromF);
        NumRead := StrToInt(str1)-1;
        // ����� ������ ���� ��������
        if NumRead = 1 then
          begin
           MessageDlg('�������� ����� ������ ��������-����������! ��������� �� ����� www.salon-nefertiti.ru',
                      mtInformation, [mbOk], 0);
           exit;
          end
        else
          begin
            if NumRead<10 then
                 str1:='0'+IntToStr(NumRead)
            else
                 str1 := IntToStr(NumRead);
            AssignFile(FromF, str);
            Reset(FromF,1);
            Seek(FromF,F_Pos);
            BlockWrite(FromF,str1[1],1);
            BlockWrite(FromF,str1[2],1);
            CloseFile(FromF);
          end;
      end;     }

//*********************************
// � ������ �������� ������ � ������ �������������� ������, �������� � ���� ����
// ��� ����������� �� ����, ��� ������� � �������� ����� ���������� !!!
//*********************************

//����� �������
T1 := GetCurrentDateTime;
repeat
        BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
        // F_Pos := FilePos(FromF);
        // Memo1.Lines.Strings[2] := '��������� ����� ������ = ' + IntToStr(F_Pos);
        F_Pos := FilePos(FromF)-NumRead;
        // Memo1.Lines.Strings[3] := '��������� ��� ������ = ' + IntToStr(F_Pos);
        ProgressBar1.Position := n;
        if NumRead <> -1 then
          begin
          for i := 0 to NumRead do
               begin
               if (Sender as TButton).Name = 'Button1'
                  then Buf[i]:=Code(Buf[i])
                  else Buf[i]:=deCode(Buf[i])
               end;
// ������ ����� �����. ����� ������������ ��������� �����,
// �� ���������� �������� ������ �� ���� ������ �� SizeOf(Buf), ������
// NumRead � ���������� ����� �� �����.
         if NumRead <> SizeOf(Buf) then
           begin
             Count_Byte := NumRead;
             NumRead := 0; //����� �� �����
           end
         else
           begin
             Count_Byte := SizeOf(Buf);
           end;
          Seek(FromF, F_Pos);
          // F_Pos := FilePos(FromF);
          // Memo1.Lines.Strings[4] := '��������� �� ������ = ' + IntToStr(F_Pos);
          BlockWrite(FromF, Buf, Count_Byte, NumWritten);
          // F_Pos := FilePos(FromF);
          // Memo1.Lines.Strings[4] := '��������� ����� ������ = ' + IntToStr(F_Pos);
          inc(n);
          end
        else
          begin
          MessageDlg('�������� � ��������� ����� ��� ������!! �������� ���� ������������ ������ ����������. ���������� ������� ��� ���������, ������������ ���� � ��������� �������.', mtInformation,
                      [mbOk], 0);
          NumRead := 0; //����� �� ����� ������-������
          end;
  until (NumRead = 0) or (NumWritten <> NumRead);


///********************************
//������ �������, ��� ������ ������
{  repeat
        BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
        F_Pos := FilePos(FromF);
        Memo1.Lines.Strings[2] := '��������� ����� ������ = ' + IntToStr(F_Pos);
        //F_Pos := FilePos(FromF)-SizeOf(Buf);
        Memo1.Lines.Strings[3] := '��������� ��� ������ = ' + IntToStr(F_Pos);
        ProgressBar1.Position := n;
        if NumRead <> -1 then
          begin
          for i := 0 to NumRead do
               begin
               if (Sender as TButton).Name = 'Button1'
                  then Buf[i]:=Code(Buf[i])
                  else Buf[i]:=deCode(Buf[i])
               end;
         // Seek(ToF, F_Pos);
          BlockWrite(ToF, Buf, SizeOf(Buf), NumWritten);
          F_Pos := FilePos(ToF);
          Memo1.Lines.Strings[4] := '��������� ����� ������ = ' + IntToStr(F_Pos);
          inc(n);
          end
        else
          begin
          MessageDlg('�������� � ��������� ����� ��� ������!!', mtInformation,
                      [mbOk], 0);
          NumRead := 0; //����� �� ����� ������-������
          end;
  until (NumRead = 0) or (NumWritten <> NumRead); }

// ����� �������
  CloseFile(FromF);
  CloseFile(ToF);
  pw := '';
  T2 := GetCurrentDateTime;
  Time2 := DateTimeToTimeStamp(T2);
  Time1 := DateTimeToTimeStamp(T1);
  n:= Time2.Time - Time1.Time;
  MessageDlg('���� ������ � ��������� �� '+FloatToStr(n/1000)+' ������',
             mtInformation, [mbOk], 0);
  GlForm.Panel2.Visible := false;
  Button3.Enabled := true;
  btList.Enabled := true;
end;

procedure TGlForm.Button3Click(Sender: TObject);
begin
GlForm.Memo1.Lines.Strings[1] := '';
GlForm.Memo1.Lines.Strings[0] := '';
GlForm.Memo1.Repaint;
Panel3.Caption := '';
Panel3.Repaint;
Edit1.Text := '';
GlForm.Label2.Visible := false;
{�������� ������}
if OpenDialog1.Execute then
   begin
     FNameInp := OpenDialog1.Filename;
     GlForm.Label1.Enabled := true;
     GlForm.Label2.Visible := true;
     Edit1.Enabled := true;
     Edit1.SetFocus;
     Panel3.Caption := '������ ����: '+FNameInp+'.';
     Button3.Enabled := false;
     btList.Enabled := false;
   end
else
   begin
     MessageBeep(MB_OK);
     MessageDlg('������ ���� ������ ����!', mtInformation,
                      [mbOk], 0);
   end;
end;

procedure TGlForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key = VK_RETURN then
begin
 if Edit1.Text <> '' then
   begin
     Button1.Enabled := true;
     Button2.Enabled := true;
     GlForm.Label1.Enabled := false;
     GlForm.Label2.Visible := false;
     MessageBeep(MB_OK);
//     MessageDlg('������ "'+Edit1.Text+'" ������', mtCustom,
//                      [mbOk], 0);

     Edit1.Enabled := false;
     Button3.Enabled := false;
     btList.Enabled := false;
   end
 else
   begin
     MessageBeep(MB_OK);
     MessageDlg('������ ���� ������ ������!', mtInformation,
                      [mbOk], 0);
   end;
end;


end;

procedure TGlForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var H :HWND;
begin
{���� ��c�������� ��������� ������ ��������� �������� �������� - ESC}
  if Key = VK_ESCAPE then
  begin
     Edit1.Text := '';
     Edit1.Enabled := false;
     Button3.Enabled := true;
     btList.Enabled := true;
     Button1.Enabled := false;
     Button2.Enabled := false;
     GlForm.Memo1.Lines.Strings[1] := '';
     GlForm.Memo1.Repaint;
     FNameInp := '';
     Panel3.Caption := '���� ������ ������� ����!';

    if Panel2.Visible then
       begin
          case MessageDlg('�������� ���������� ?', mtCustom,
                  [mbYes, mbNo], 0) of
          mrYes:begin
                CloseFile(FromF);
                CloseFile(ToF);
                H:=FindWindow('TGlForm', '������������');
                SendMessage (H,WM_CLOSE,0,0);
                end;
          mrNo: begin
                end;
          end
       end;

  end;

end;

procedure TGlForm.btListClick(Sender: TObject);
begin
   Label2.Visible := false;
   Panel3.Caption := '';
   Panel3.Repaint;
   Edit1.Text := '';
   MessageDlg('������ ������ ��������� �� ������������ ������ �� �������� ����������!' +
    '���������� ������������ ������! �������� ��������������� ����� ������������ �������.', mtInformation,
                      [mbOk], 0);
   fmSpisok.ShowModal;
end;

end.
