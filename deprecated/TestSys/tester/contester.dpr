program contester;

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
  TesterThreadUnit in 'TesterThreadUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTesterMainForm, TesterMainForm);
  Application.Run;
end.
