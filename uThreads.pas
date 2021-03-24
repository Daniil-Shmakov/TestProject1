{Задание1. Задание на потоки и объекты
Цель: продемонстрировать опыт разработки многопоточных приложений и владения
объектно-ориентированным программированием.
Для реализации потоков необходимо использовать класс TThread, а не таймер.
Создать несколько потоков-объектов, каждый из них периодически (период должен задаваться)
создает сообщение и пишет в файл.
Для записи в файл нужно использовать общий объект (Logger).
Для записи сообщения ему передается текст сообщения и его статус, а он пишет
в файл сообщение, статус, идентификатор потока и время.
Статусы: Critical, Warning, Info.
Также класс Logger должен:
1)	Хранить в памяти последние 10 сообщений.
2)	Реализовывать удаление из файла старых сообщений
  (старее, чем на данное количество минут). Удаление должно вызываться
  периодически (Период задается).
В приложении д.б. интерфейс отображения 10 сообщений из памяти Logger-а.
Классы логгера и формирования сообщений должны быть реализованы так,
чтобы их можно было использовать в приложении как с графическим интерфейсом, так и без него.
Количество потоков формирования сообщений, время жизни и периодичность
очистки старых сообщений из файла, имя файла лога должны задаваться в константах
(либо читаться из файла настроек – продвинутый уровень)
}

unit uThreads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Generics.Collections, uLogger, uLogThread, SyncObjs,
  Vcl.Grids, IniFiles;


type
  TThreadsForm = class(TForm)
    StartButton: TButton;
    LogFileNameEdit: TEdit;
    StopButton: TButton;
    OptionGrid: TStringGrid;
    LogMemo: TMemo;
    ShowButton: TButton;
    IniFileNameEdit: TEdit;
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ShowButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ThreadList: TList<TLogThread>;
    Logger: TLogger;
    LogCleaner: TLogFileCleaner;
    LogFileName: String;
    ThreadQty: integer;
    Interval: integer;
    OldLogRemovePeriod: integer; // период очищения лог-файла в минутах
    OldLogRemoveTime: integer;
    function NewThreadStart: boolean;
    procedure ShowLog;
    procedure ThreadEnds;
    procedure ReadConfig(Filename: String);
  end;

var
  ThreadsForm: TThreadsForm;

implementation

{$R *.dfm}
const IniFileName = 'Threads.cfg';
      DefaultLogFileName = 'Threads.Log';
      DefaultThreadQty = 10;
      DefaultLogInterval = 1000; // миллисекунды
      DefaultLogLifeTime = 10; // минуты
      DefaultLogCleanPeriod = 2; // минуты


function TThreadsForm.NewThreadStart: boolean;
var
    I: integer;
    Thread : TLogThread;
    ThreadMessage: string;
    ThreadNumber: integer;
begin
    ThreadMessage := 'Some Message from Thread #';
    if not Assigned(ThreadList) then
        ThreadList := TList<TLogThread>.Create;
    ThreadNumber := ThreadList.Count;
    for I := 0 to ThreadQty-1 do
      begin
        Thread := TLogThread.Create(Interval, ThreadMessage +
                                    IntToStr(ThreadNumber+i));
        Thread.FreeOnTerminate := True;
        ThreadList.Add(Thread);
        ThreadList.Last.Start;
    end;
    // поток стартует сразу при создании
    if not Assigned(LogCleaner) then
      LogCleaner := TLogFileCleaner.Create(OldLogRemoveTime, OldLogRemovePeriod);
    Result := true;
end;

procedure TThreadsForm.ThreadEnds;
var Item: TThread;
begin
    if Assigned(ThreadList) then
      for Item in ThreadList do
         Item.Terminate;
    Logger.DestroyInstance;
    LogCleaner.Terminate;
end;

procedure TThreadsForm.StopButtonClick(Sender: TObject);
begin
     ThreadEnds;
end;

procedure TThreadsForm.ShowButtonClick(Sender: TObject);
begin
    ShowLog;
end;

procedure TThreadsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    ThreadEnds;
end;

procedure TThreadsForm.FormShow(Sender: TObject);
begin
    ReadConfig(IniFileName);

    OptionGrid.ColCount := 2;
    OptionGrid.ColWidths[0] := 120;
    OptionGrid.ColWidths[1] := 120;

    OptionGrid.Cells[0,0] := 'Кол-во потоков';
    OptionGrid.Cells[1,0] := 'Интервал, мс';

    OptionGrid.Cells[0,1] := IntToStr(ThreadQty);
    OptionGrid.Cells[1,1] := IntToStr(Interval);

    LogFileNameEdit.Text := 'LogFile: ' + LogFileName;
    IniFileNameEdit.Text := 'Config File: ' + IniFileName;

    Logger := TLogger.GetInstance(LogFileName);

end;

procedure TThreadsForm.ShowLog;
var List: TStringList;
begin
    List := TStringList.Create;
    Logger.GetLastMessages(List);
    LogMemo.Lines.Assign(List);
    List.Free;
end;

procedure TThreadsForm.StartButtonClick(Sender: TObject);
begin
    LogMemo.Lines.Add('Logging Started');
    NewThreadStart;
end;

procedure TThreadsForm.ReadConfig(Filename: String);
var
  IniFile: TIniFile;
begin
    // ищем ини-файл в папке с программой
    // если его нет, то используем значения по умолчанию из констант
    IniFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + Filename);
    LogFileName := IniFile.ReadString('Logging File', 'LogFileName',
                                      DefaultLogFileName);
    OldLogRemovePeriod := IniFile.ReadInteger('Logging File',
                          'LogFileCleanPeriod', DefaultLogCleanPeriod);
    OldLogRemoveTime := IniFile.ReadInteger('Logging File',
                          'LogRecordsLifeTime', DefaultLogLifeTime);
    ThreadQty := IniFile.ReadInteger('Logging Threads', 'ThreadsCount',
                          DefaultThreadQty);
    Interval := IniFile.ReadInteger('Logging Threads', 'LogInterval',
                          DefaultLogInterval);
    IniFile.Destroy;
end;

end.
