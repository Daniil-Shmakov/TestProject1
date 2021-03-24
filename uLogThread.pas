unit uLogThread;

interface

uses Classes, SysUtils, SyncObjs, Winapi.Windows, uLogger;

type TLogThread = class(TThread)
private
  FDelay : integer; // delay in milliseconds
  FStatus: TStatus;  // alarm
  FThreadMessage: string;
public
  CritSection: TCriticalSection;
  constructor Create(interval: integer; ThreadMessage: string);
  procedure Execute; override;
  procedure LogEvent;

end;

implementation

constructor TLogThread.Create(interval: integer; ThreadMessage: string);
begin
  FThreadMessage := ThreadMessage;
  if Interval > 0 then
    Fdelay := interval;
//  else
//    raise Exception.Create('������� ������������� �������� � �������������');
// ��������� � suspended, ����� �������� ��� �� �������� ������
  inherited Create(true);
end;

procedure TLogThread.Execute;
begin
    while not Terminated do
      begin
        FStatus := TStatus(Random(3));
        LogEvent;
        // ���, �������, �� ���� ������, ������ ��� Sleep �������� ������
        // � ����� �������� �� ��������� sleep, �.�. ��� ���������� ���������
        // ��� ����� �� ���������, � ����� ����� ���������� ������
        // ��� ���� ����������� �������, ������� ����� � ����� ����������
        // ��������� ������, ������, ������ 100-500 ��, � ��������� ���
        // ��� ������������� ������ ��������� ������� FDelay
        sleep(FDelay);
      end;
end;

procedure TLogThread.LogEvent;
var
    Logger: TLogger;
begin
    Logger := TLogger.GetInstance('');
    Logger.SendMessage(FThreadMessage, FStatus);
end;

end.
