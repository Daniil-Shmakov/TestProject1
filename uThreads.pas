{�������1. ������� �� ������ � �������
����: ������������������ ���� ���������� ������������� ���������� � ��������
��������-��������������� �����������������.
��� ���������� ������� ���������� ������������ ����� TThread, � �� ������.
������� ��������� �������-��������, ������ �� ��� ������������ (������ ������ ����������)
������� ��������� � ����� � ����.
��� ������ � ���� ����� ������������ ����� ������ (Logger).
��� ������ ��������� ��� ���������� ����� ��������� � ��� ������, � �� �����
� ���� ���������, ������, ������������� ������ � �����.
�������: Critical, Warning, Info.
����� ����� Logger ������:
1)	������� � ������ ��������� 10 ���������.
2)	������������� �������� �� ����� ������ ���������
  (������, ��� �� ������ ���������� �����). �������� ������ ����������
  ������������ (������ ��������).
� ���������� �.�. ��������� ����������� 10 ��������� �� ������ Logger-�.
������ ������� � ������������ ��������� ������ ���� ����������� ���,
����� �� ����� ���� ������������ � ���������� ��� � ����������� �����������, ��� � ��� ����.
���������� ������� ������������ ���������, ����� ����� � �������������
������� ������ ��������� �� �����, ��� ����� ���� ������ ���������� � ����������
(���� �������� �� ����� �������� � ����������� �������)
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
    OldLogRemovePeriod: integer; // ������ �������� ���-����� � �������
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
      DefaultLogInterval = 1000; // ������������
      DefaultLogLifeTime = 10; // ������
      DefaultLogCleanPeriod = 2; // ������


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
    // ����� �������� ����� ��� ��������
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

    OptionGrid.Cells[0,0] := '���-�� �������';
    OptionGrid.Cells[1,0] := '��������, ��';

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
    // ���� ���-���� � ����� � ����������
    // ���� ��� ���, �� ���������� �������� �� ��������� �� ��������
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
