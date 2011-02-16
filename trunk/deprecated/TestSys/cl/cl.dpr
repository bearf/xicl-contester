program cl;

//{%File 'mysqldb.inc'}

{%ToDo 'cl.todo'}

{$DEFINE CLIENT}

uses
  windows,
  Forms,
  SysUtils,
  IniFiles,
  mainform in 'mainform.pas' {main},
  LoginCDlg in 'LoginCDlg.pas' {loginC},
  resform in 'resform.pas' {res},
  monform in 'monform.pas' {mon},
  mysqldb in '..\libmysql\mysqldb.pas',
  mysql in '..\libmysql\mysql.pas',
  ttypes in '..\tester\ttypes.pas',
  tTimes in '..\tester\ttimes.pas',
  tlog in '..\tester\tlog.pas',
  tConfig in '..\tester\tConfig.pas',
  mycp in '..\tester\mycp.pas',
  remoted in 'remoted.pas',
  remote in 'remote.pas',
  LoginDlg in 'logindlg.pas' {login},
  infoform in 'infoform.pas' {info};

{$R *.res}

const
  AtStr = 'TSYS online-contest system v.MYSQL';

var
//	IniFile: TIniFile;
 	hMutex : integer;
begin
  hMutex:=CreateMutex(nil,TRUE,'BelAZNavigator');       // Создаем семафор
  if GetLastError=0 then begin
    Application.Initialize;
    db_name := MainReg.ReadString('DataBase', 'db_name', '');
    db_host := MainReg.ReadString('DataBase', 'db_host', '');
    waiter := MainReg.ReadString('DataBase', 'waiter', '');
//    IniFile := TIniFile.Create(GetCurrentDir + '\cl.ini');
//    db_name := IniFile.ReadString('DataBase', 'db_name', '');
//    db_host := IniFile.ReadString('DataBase', 'db_host', '');
//    waiter := IniFile.ReadString('DataBase', 'waiter', '');
//    IniFile.Free;
    Application.CreateForm(Tmain, main);
  Application.CreateForm(TloginC, loginC);
  Application.CreateForm(Tres, res);
  Application.CreateForm(Tmon, mon);
  Application.CreateForm(Tlogin, login);
  Application.CreateForm(Tinfo, info);
  Application.ShowMainForm := False;
	  Application.Run;
	  ReleaseMutex(hMutex)
  end
  else
    MessageBox(0,'Нельзя запустить две копии программы','Внимание!',MB_OK or MB_SYSTEMMODAL or MB_ICONERROR);
end.


