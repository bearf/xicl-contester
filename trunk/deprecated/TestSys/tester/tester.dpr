program Tester;

uses
  Forms,
  tConfig in 'tconfig.pas',
  TesterMainUnit in 'TesterMainUnit.pas' {TesterMainForm},
  CP in 'cp.pas',
  db in 'db.pas',
  mysqldb in '..\libmysql\mysqldb.pas',
  mysql in '..\libmysql\mysql.pas',
  mycp in 'mycp.pas',
  RunLib in 'runlib.pas',
  tCallBack in 'tcallback.pas',
  tCompile in 'tcompile.pas',
  tConUtils in 'tconutils.pas',
  tConVis in 'tconvis.pas',
  tfiles in 'tfiles.pas',
  tlog in 'tlog.pas',
  tsys in 'tsys.pas',
  tTimes in 'ttimes.pas',
  ttypes in 'ttypes.pas',
  TesterThreadUnit in 'TesterThreadUnit.pas',
  StartTournamentUnit in 'StartTournamentUnit.pas' {StartTournamentForm},
  monform in '..\cl\monform.pas' {mon},
  UserAddFormUnit in 'UserAddFormUnit.pas' {UserAddForm},
  TaskAddFormUnit in 'TaskAddFormUnit.pas' {TaskAddForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTesterMainForm, TesterMainForm);
  Application.CreateForm(TStartTournamentForm, StartTournamentForm);
  Application.CreateForm(Tmon, mon);
  Application.CreateForm(TUserAddForm, UserAddForm);
  Application.CreateForm(TTaskAddForm, TaskAddForm);
  Application.Run;
end.
