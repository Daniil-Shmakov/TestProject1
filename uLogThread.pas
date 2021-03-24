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
//    raise Exception.Create('Задайте положительный интервал в миллисекундах');
// запускаем в suspended, потом стартуем его из главного потока
  inherited Create(true);
end;

procedure TLogThread.Execute;
begin
    while not Terminated do
      begin
        FStatus := TStatus(Random(3));
        LogEvent;
        // так, конечно, не надо делать, потому что Sleep прервать нельзя
        // и поток зависнет до окончания sleep, т.е. при завершении программы
        // она сразу не закроется, а будет ждать завершения потока
        // тут надо реализовать функцию, которая будет в цикле опрашивать
        // состояние потока, скажем, каждые 100-500 мс, и закрывать его
        // при необходимости раньше окончания периода FDelay
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
