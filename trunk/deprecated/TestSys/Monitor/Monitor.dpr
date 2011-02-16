program Monitor;

uses
  Forms,
  db in '..\tester\db.pas',
  monform in '..\cl\monform.pas' {mon},
  ttypes in '..\tester\ttypes.pas',
  tTimes in '..\tester\ttimes.pas',
  tlog in '..\tester\tlog.pas',
  tConfig in '..\tester\tconfig.pas',
  tfiles in '..\tester\tfiles.pas',
  mycp in '..\tester\mycp.pas',
  mysqldb in '..\libmysql\mysqldb.pas',
  mysql in '..\libmysql\mysql.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmon, mon);
  Application.Run;
end.
