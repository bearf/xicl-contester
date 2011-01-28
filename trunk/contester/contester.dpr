program contester;

uses
  Forms,
  ttypes in '..\units\contester\ttypes.pas',
  CP in '..\units\contester\cp.pas',
  db in '..\units\contester\db.pas',
  mycp in '..\units\contester\mycp.pas',
  RunLib in '..\units\contester\runlib.pas',
  tCallBack in '..\units\contester\tcallback.pas',
  tCompile in '..\units\contester\tcompile.pas',
  tConfig in '..\units\contester\tconfig.pas',
  tConUtils in '..\units\contester\tconutils.pas',
  tConVis in '..\units\contester\tconvis.pas',
  tfiles in '..\units\contester\tfiles.pas',
  tlog in '..\units\contester\tlog.pas',
  tsys in '..\units\contester\tsys.pas',
  tTimes in '..\units\contester\ttimes.pas',
  mysql in '..\units\db\mysql.pas',
  mysqldb in '..\units\db\mysqldb.pas',
  TesterThreadUnit in '..\units\contester\TesterThreadUnit.pas',
  TesterMainUnit in '..\units\contester\forms\TesterMainUnit.pas' {TesterMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTesterMainForm, TesterMainForm);
  Application.Run;
end.
