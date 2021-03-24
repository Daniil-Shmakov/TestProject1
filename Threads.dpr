program Threads;

uses
  Vcl.Forms,
  uThreads in 'uThreads.pas' {ThreadsForm},
  uLogThread in 'uLogThread.pas',
  uLogger in 'uLogger.pas',
  uFile in 'uFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TThreadsForm, ThreadsForm);
  Application.Run;
end.
