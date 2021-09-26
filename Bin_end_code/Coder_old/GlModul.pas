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
  TEndTabl = array of TCodeTabl; //Все варианты кодировок (=длине пароля+1), полученные после сдвигов на ord(буква пароля)
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
  sdvig : byte = 1;   //Так работает со 100% идентичностью, но гдето выбивается за адреса чтения!! Надо разобраться!!     // реализовано,не как задумывалось!! Это просто в скольки символах от начала кодовой таблицы не меняется кодировка!
  // но если убрать сдвиг (присвоить 0), то эта собака не работает!! Вводить ли сдвиг в дальнейшие кодировки??
  n_zaprosa : word = 0;      // раз Word, то длина пароля не более 65535 символов!,
  index : word = 0;          // текущая позиция в пароле(J-ая таблица кодировки)
//  period : byte = 4;         // Цикличность смены таблицы кодировки (через period символов)  НАДО УДАЛИТЬ! всегда должно быть 1!!
  tek : byte = 0;            // и текущая позиция

implementation

{$R *.DFM}

//*************************************
// Получение системных даты и времени *
//*************************************

function TGLForm.GetCurrentDateTime: TDateTime;
var
  SystemTime: TSystemTime;
begin

  GetLocalTime(SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

//***********************************************************************************
// Поиск в файле заданного текстового фрагмента                                     *
// (не работает с файлами более 2147483647 байт!!!)                                 *                                               *
// Возвращает позицию СЛЕДУЮЩЕГО за фрагментом байта или 0, если фрагмент не найден.*
//***********************************************************************************
// Нужна только для проверки количества проведённых шифровок/дешифровок!!

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
          MessageDlg('Проблемы с открытием файла '+FileName+' для чтения!!', mtInformation,
                      [mbOk], 0);
          Result := 0;
          end;
end;

//**************************************************
//Функция декодирования символа по готовой таблице *
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
//Функция кодировки символа по готовой таблице *
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
// Создание кодовой таблицы по введенному паролю *
// Таблица должна создаваться 1 раз!! Через каждый символа сдвиг на ord(буква пароля)!
// Надо реализовать это в запросе кодировки/декодировки!! Таблица может и крутиться на кажды сдвиг буквы пароля
// Так проще будет!
//************************************************
procedure TGlForm.MakeCode;
var   k,i,j : integer;
      symbol  : AnsiChar;
begin
  Edit1.Text := Edit1.Text + 'абвгдеёжзийклмнопрстуфхцчшщьыъэюяАБВГДЕЁЖЗИКЛМНABCDXYZefgijklmn'; //Увеличиваем длину пароля
  pw := Edit1.text;
  {Создаем пустую таблицу}
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
// Зачем её создавать?? Зачем столько заморочек со сдвигом, если он практически не используется??
// Возможно это надо использовать для ускорения шифрования? (не трогаем несимвольные значения, т. к. их невозможно ввести с клавиатуры??)
// тогда сдвиг надо до символа табуляции (ord = 13) делать.  Сделал, плохо работает на видео!!
// Всё - фигня!!! Со сдвигом заморачиваемся, иначе не работает (скорее всего из-за 0-го символа!!!)

//Этот кусок меняет в таблице значения только тех символов, которые вошли в пароль + кусок, который пихаем сами в пароль.
     k:=0+sdvig;
     for i:=1 to length(Edit1.text) do
         begin
           if ord(Edit1.Text[i])>= sdvig then //Символьный ряд
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


         {Заполняем остаток символов}
   for i:=0+sdvig to 255 do
      if NewCode[i].code = 256 then
             begin
                NewCode[i].code := k;
                inc(k);
             end;
// Получаем основную таблицу по введённому паролю(с перекодировкой символов, вошедших в пароль)

// Далее надо создать массив этих кодировок, прокрученных на сдвиг ord(буква пароля), размером в
// количество символов пароля+1
SetLength(EndCode, Length(pw)); //Выделяем место под все варианты кодировки (не забыть освободить!! Finalize(EndCode) )

// Формируем первую колонку
for i :=0 to 255 do
   EndCode[0,i] := NewCode[i];

// Крутим смещение по букве пароля, формируем остальные (в зависимости от длины пароля) колонки
for j := 1 to Length(pw)-1 do
   begin
      k := ord(pw[j]);
      for i := 0 to sdvig-1 do EndCode[j,i] := NewCode[i]; //Сдвиговые символы неизменны

// Остальные меняем
      for i :=sdvig to 255 do
         begin
            EndCode[j,i] := NewCode[i];
            EndCode[j,i].code := EndCode[j-1,i].code+k;
            if EndCode[j,i].code > 255 then EndCode[j,i].code := sdvig+EndCode[j,i].code - 256;//??
         end;
   end;
 Edit1.text := '';
// Ввёл переменную для пароля - pw. Обнулять её надо там же где и освобождаем память от вариантов кодировки
end;


//***************************************
// Получение имени файла вывода         *
//***************************************
procedure TGlForm.OpenFiles;
begin
 flag := false; // Запись в тот же файл

 {case MessageDlg('Задать имя файла результата?', mtCustom,
                  [mbYes, mbNo], 0) of
          mrYes:begin
                 flag := true; // открыто два разных файла
                 if SaveDialog1.Execute then
                    begin
                    FNameOut := SaveDialog1.Filename;
                    end
                 else
                    begin
                    MessageDlg('Вы не задали имя файла! Результат будет помещён в файл temp1.cdc',
                               mtCustom, [mbOk], 0);
                    FNameOut := 'temp1.cdc';
                    end;
                end;
          mrNo: begin

                 MessageDlg('Результат будет помещён в файл temp1.cdc',
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
    Buf: array[1..20480] of Char; // Можно переделать под динамический массив, равный размеру сектора!!
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
          GlForm.StaticText1.Caption:='Расшифровка:';
  GlForm.Panel2.Visible := true;
  StaticText1.Repaint;
  Memo1.Lines.Strings[0] := 'Исходный файл: '+FNameInp+'.';
//  Memo1.Lines.Strings[1] := 'Результат в '+FNameOut;
  Memo1.Repaint;
  Panel3.Caption := '';
  //'Исходный файл: '+FNameInp+'. Результат в '+FNameOut;
  Panel3.Repaint;
  n:=0;
  ProgressBar1.Max := Trunc(FileSize(FromF)/SizeOf(Buf));

//********************************
// Лимит шифрования
//********************************
 { str:= 'C:\Program Files\Borland\Delphi5\Мои проекты\Шифровальщик\USpisok.dfm';
  F_Pos := SearchText(str, 'Разрешение экрана');
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
        // Нужен анализ этой величины
        if NumRead = 1 then
          begin
           MessageDlg('Превышен лимит циклов шифровки-дешифровки! Продление на сайте www.salon-nefertiti.ru',
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
// В данном варианте чтение и запись зашифрованного текста, ведуться в один файл
// ВНЕ ЗАВИСИМОСТИ от того, что выбрано в качестве файла результата !!!
//*********************************

//старт таймера
T1 := GetCurrentDateTime;
repeat
        BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
        // F_Pos := FilePos(FromF);
        // Memo1.Lines.Strings[2] := 'Указатель после чтения = ' + IntToStr(F_Pos);
        F_Pos := FilePos(FromF)-NumRead;
        // Memo1.Lines.Strings[3] := 'Указатель для записи = ' + IntToStr(F_Pos);
        ProgressBar1.Position := n;
        if NumRead <> -1 then
          begin
          for i := 0 to NumRead do
               begin
               if (Sender as TButton).Name = 'Button1'
                  then Buf[i]:=Code(Buf[i])
                  else Buf[i]:=deCode(Buf[i])
               end;
// Анализ конца файла. Когда записывается последний кусок,
// не происходит накладка записи за счёт сдвига на SizeOf(Buf), вместо
// NumRead и происходит выход из цикла.
         if NumRead <> SizeOf(Buf) then
           begin
             Count_Byte := NumRead;
             NumRead := 0; //Выход из цикла
           end
         else
           begin
             Count_Byte := SizeOf(Buf);
           end;
          Seek(FromF, F_Pos);
          // F_Pos := FilePos(FromF);
          // Memo1.Lines.Strings[4] := 'Указатель до записи = ' + IntToStr(F_Pos);
          BlockWrite(FromF, Buf, Count_Byte, NumWritten);
          // F_Pos := FilePos(FromF);
          // Memo1.Lines.Strings[4] := 'Указатель после записи = ' + IntToStr(F_Pos);
          inc(n);
          end
        else
          begin
          MessageDlg('Проблемы с открытием файла для чтения!! Возможно файл используется другой программой. Попробуйте закрыть все программы, использующие файл и повторите попытку.', mtInformation,
                      [mbOk], 0);
          NumRead := 0; //Выход из цикла чтения-запись
          end;
  until (NumRead = 0) or (NumWritten <> NumRead);


///********************************
//Старый вариант, для разных файлов
{  repeat
        BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
        F_Pos := FilePos(FromF);
        Memo1.Lines.Strings[2] := 'Указатель после чтения = ' + IntToStr(F_Pos);
        //F_Pos := FilePos(FromF)-SizeOf(Buf);
        Memo1.Lines.Strings[3] := 'Указатель для записи = ' + IntToStr(F_Pos);
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
          Memo1.Lines.Strings[4] := 'Указатель после записи = ' + IntToStr(F_Pos);
          inc(n);
          end
        else
          begin
          MessageDlg('Проблемы с открытием файла для чтения!!', mtInformation,
                      [mbOk], 0);
          NumRead := 0; //Выход из цикла чтения-запись
          end;
  until (NumRead = 0) or (NumWritten <> NumRead); }

// финиш таймера
  CloseFile(FromF);
  CloseFile(ToF);
  pw := '';
  T2 := GetCurrentDateTime;
  Time2 := DateTimeToTimeStamp(T2);
  Time1 := DateTimeToTimeStamp(T1);
  n:= Time2.Time - Time1.Time;
  MessageDlg('Файл считан и обработан за '+FloatToStr(n/1000)+' секунд',
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
{Открытие файлов}
if OpenDialog1.Execute then
   begin
     FNameInp := OpenDialog1.Filename;
     GlForm.Label1.Enabled := true;
     GlForm.Label2.Visible := true;
     Edit1.Enabled := true;
     Edit1.SetFocus;
     Panel3.Caption := 'Выбран файл: '+FNameInp+'.';
     Button3.Enabled := false;
     btList.Enabled := false;
   end
else
   begin
     MessageBeep(MB_OK);
     MessageDlg('Должен быть выбран файл!', mtInformation,
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
//     MessageDlg('Пароль "'+Edit1.Text+'" принят', mtCustom,
//                      [mbOk], 0);

     Edit1.Enabled := false;
     Button3.Enabled := false;
     btList.Enabled := false;
   end
 else
   begin
     MessageBeep(MB_OK);
     MessageDlg('Должен быть введен пароль!', mtInformation,
                      [mbOk], 0);
   end;
end;


end;

procedure TGlForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var H :HWND;
begin
{надо отcлеживать сочетание клавиш остановки шифровки например - ESC}
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
     Panel3.Caption := 'Надо заново выбрать файл!';

    if Panel2.Visible then
       begin
          case MessageDlg('Прервать выполнение ?', mtCustom,
                  [mbYes, mbNo], 0) of
          mrYes:begin
                CloseFile(FromF);
                CloseFile(ToF);
                H:=FindWindow('TGlForm', 'Шифровальщик');
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
   MessageDlg('Данная версия программы не поддерживает работу со списками шифрования!' +
    'Необходима коммерческая версия! Доступен ознакомительный режим формирования списков.', mtInformation,
                      [mbOk], 0);
   fmSpisok.ShowModal;
end;

end.
