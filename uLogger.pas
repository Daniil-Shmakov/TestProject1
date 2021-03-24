{��� ������ � ���� ����� ������������ ����� ������ (Logger). ��� ������ ��������� ��� ����������
����� ��������� � ��� ������, � �� ����� � ���� ���������, ������, ������������� ������ � �����.
�������: Critical, Warning, Info.

����� ����� Logger ������:
1)	������� � ������ ��������� 10 ���������.
2)	������������� �������� �� ����� ������ ��������� (������, ��� �� ������ ���������� �����).
�������� ������ ���������� ������������ (������ ��������).
� ���������� �.�. ��������� ����������� 10 ��������� �� ������ Logger-�. }

unit uLogger;

interface
uses Classes, SysUtils, SyncObjs, Generics.Collections,
     WinApi.Windows, DateUtils, uFile;

type TLogFileCleaner = class(TThread)
private
  FLifeTime: integer;
  FPeriod: integer;
public
  constructor Create(LifeTime, RemovePeriod: Integer);
  procedure Execute; override;
end;

type TStatus = (stWarning, stCritical, stInfo);

type TLogWay = (viaConsole, viaFile, viaBoth);

type TLogger = class
  private
    LogFileName: string;
    LogFile: TextFile;
    LogWay : TLogWay;
    Crit: TCriticalSection;
    EventList: TQueue<String>;
    class var Instance: TLogger;
    class var InstCount: integer;
    constructor Create(Filename: string);
    procedure SaveMsgToFile(LogText: string);
    function BuildLogMessage(LogText: string; Status: TStatus): string;
  public
    class function GetInstance(Filename: string): TLogger;
    procedure DestroyInstance;
    procedure SendMessage(LogMessage: string; Status: TStatus);
    procedure GetLastMessages(const List: TStringList);
    procedure ClearLogFileHistory(LifeTime: integer);
end;

implementation

constructor TLogFileCleaner.Create(LifeTime, RemovePeriod: Integer);
begin
    FLifeTime := LifeTime;
    FPeriod := RemovePeriod;
    inherited Create(false);
end;


procedure TLogFileCleaner.Execute;
const MsInMinute = 60000;
var Logger: TLogger;
begin
    Logger := TLogger.GetInstance('');
    while not Terminated do
      begin
        // ��������� ������ � ������������
        Sleep(FPeriod*MsInMinute);
        Logger.ClearLogFileHistory(FLifeTime);
      end;
end;

// ����������� ��� ������ ����� � ����
constructor TLogger.Create(Filename: string);
begin
    if not Assigned(Crit) then
      Crit := TCriticalSection.Create;
    LogFileName := Filename;
    // ��� ���� ��������� �� ������������� � ���� ��� - �������
    try
      AssignFile(LogFile, LogFileName); {Assigns the Filename}
      if FileExists(LogFileName) then
      // ������� ��� ��������������
         Append(LogFile)
      else
      // �������/������������
         ReWrite(LogFile);
    except on E: Exception do
      Exit;
    end;
    CloseFile(LogFile);  // ���������...
    LogWay := viaFile;
    EventList := TQueue<string>.Create;
end;

// �������� ��������� ������� (���� ��� �� ������ - �������)
class function TLogger.GetInstance(Filename: string): TLogger;
begin
    if not Assigned(Instance) then
        begin
          Instance:=TLogger.Create(Filename);
          InstCount:=1;
        end;
     Result:=Instance;
end;

procedure TLogger.DestroyInstance;
begin
    if InstCount > 0 then
      begin
        Instance.Free;
        InstCount := 0;
      end;
end;

// ������� ��������� �������
procedure TLogger.SendMessage(LogMessage: string; Status: TStatus);
var Log: string;
begin
    Crit.Enter;
    Log := BuildLogMessage(LogMessage, Status);
    EventList.Enqueue(Log);
    SaveMsgToFile(Log);
    // ���� ������� ������ 10 ��������� � ������ - ���� �������
    if EventList.Count > 10 then
      EventList.Dequeue;
    Crit.Leave;
end;

// ������ ����� � ����
procedure TLogger.SaveMsgToFile(LogText: string);
begin
    Append(LogFile);
    Writeln(LogFile, LogText);
    CloseFile(LogFile);
end;

// ����������� ��������� ��� ���-�����
function TLogger.BuildLogMessage(LogText: string; Status: TStatus): string;
var ThreadID: cardinal;
    StatusString: string;
begin
    // ID ���������� Logger ������
    ThreadID := GetCurrentThreadId;
    // ������ ���������
    if Status = TStatus.stWarning then
      StatusString := 'WARNING';
    if Status = TStatus.stCritical then
      StatusString := 'CRITICAL';
    if Status = TStatus.stInfo then
      StatusString := 'INFO';
    Result := LogText + ' - ' + StatusString + ' ID: '+
              IntToStr(ThreadID) + ' - ' + DateTimeToStr(Now);
end;

procedure TLogger.GetLastMessages(const List: TStringList);
var Item: string;
begin
    Crit.Enter;
    for Item in EventList do
      List.Add(Item);
    Crit.Leave;
end;

procedure TLogger.ClearLogFileHistory(LifeTime: integer);
var Time: TDateTime;
begin
    Crit.Enter;
    Time := IncMinute(Now, -LifeTime);
    // ��������� �� �����, �������� ����/����� � ������� ������
    DeleteLineWithStringList(LogFileName, Time);
    Crit.Leave;
end;

end.
