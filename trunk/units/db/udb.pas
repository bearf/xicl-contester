{$I defines.inc}
unit udb;

interface
uses windows, SysUtils, tTypes, ttimes, inifiles, tLog, tFiles, tConfig, mycp, mysqldb, Forms;


        function ReadTesterSubmits: integer;
        function GetSubmitBynum(num : integer; var Submit: TSubmitInfo): boolean;


  function GetTaskID(SubmitInfo: TSubmitInfo): Integer;
  
	function GetId (Alias: String; var ID: integer): boolean;

//создает уникальный ID
	function CreateId(IdType: integer):integer;

	function GetInfo (table_id, field_id: integer; var Info): boolean;

	function SetInfo (table_id, field_id: integer; var Info): boolean;

	function GetSolve (SubmitID : integer; fname : string): boolean;

//        function dbRecalcMonitor(): boolean;
//        function dbPrepareMonitor(): boolean;

function UpdateVolume(SubmitInfo: TSubmitInfo): Boolean;
function UpdateMonitor(SubmitInfo: TSubmitInfo): boolean;
function isMonitorFrozen(SubmitInfo: TSubmitInfo): Boolean;

{        function SetConfig(Name, Value: string):boolean;
        function GetConfig(Name: string):string;}

{------local db -----}
	function GetTestFiles(TaskID, Testnum : integer; SrcNames, DestNames : string; Destdir : string) : boolean;

	function GetApp(TaskID : integer; Name : string; Destdir : string) : boolean;
//function UserAdd(name, login, pass, ip: string): boolean;
//function TaskAdd(task, author, input, output, rans, checker, testcount, timelimit, memlimit: string): boolean;

var dbSolveFile : String;

implementation

uses
  DateUtils;

var testdir : string;
    db_name, db_host, db_user, db_pass : String;

{function UserAdd(name, login, pass, ip: string): boolean;
begin
    result := db_user_add(name, login, pass, ip);
end;}

{function TaskAdd(task, author, input, output, rans, checker, testcount, timelimit, memlimit: string): boolean;
begin
    result := db_task_add(task, author, input, output, rans, checker, testcount, timelimit, memlimit);
end;}

function ReadTesterSubmits: integer;
begin
  result := db_read_tester_submits;
end;

function GetSubmitBynum(num : integer; var Submit: TSubmitInfo): boolean;
begin
  result := db_get_submit_bynum(num,Submit);
end;

{function SetConfig(Name, Value: string):boolean;
var q: string;
begin
    q := 'UPDATE `config` SET value='''+value+''' WHERE name ='''+name+''';';
    db_insert(q);
    result := true;
end;}

{function GetConfig(Name: string):string;
begin
    result := db_get_config(name);
end;}

{function dbPrepareMonitor(): boolean;
begin
    db_prepare_monitor;
    result := true;
end;}

{function dbRecalcMonitor(): boolean;
begin
    db_recalc_monitor;
    result := true;
end;}

function UpdateVolume(SubmitInfo: TSubmitInfo): Boolean;
var
  return: Boolean;
begin
  with SubmitInfo do
    return := db_update_volume(Contest,
                               Problem,
                               Result.result = 0);

  Result := return
end;

function UpdateMonitor(SubmitInfo: TSubmitInfo): boolean;
begin
  if SubmitInfo.Result.Result=0 then
    db_update_monitor(SubmitInfo.User,
                    SubmitInfo.Contest,
                    SubmitInfo.stry,
                    1,
                    SubmitInfo.result.point,
                    SubmitInfo.Problem,
                    SubmitInfo.sTime)
  else
    db_update_monitor(SubmitInfo.User,
                    SubmitInfo.Contest,
                    SubmitInfo.stry,
                    0,
                    SubmitInfo.result.point,
                    SubmitInfo.Problem,
                    SubmitInfo.sTime)
end;

function GetId(Alias: String; var ID: integer): boolean;
	var Alias1: String;
	begin
  		Alias1 := Alias;
  		GetId := db_get_id(Alias1, id);
	end;

function CreateId(IdType: integer): integer;
	begin
  		CreateID := db_create_id(idtype);
	end;

function GetTaskID(SubmitInfo: TSubmitInfo): Integer;
begin
  result := db_get_task_id(SubmitInfo.Problem, SubmitInfo.Contest);
end;

function GetInfo (table_id, field_id: integer; var Info): boolean;
	begin
  		GetInfo := db_get(table_id, field_id, rqTester, true, info);
	end;

function SetInfo (table_id, field_id: integer; var Info): boolean;
	begin
  		SetInfo := db_set(table_id, field_id, rqTester, info);
	end;

function GetSolve (SubmitID : integer; fname : string): boolean;
	begin
  		GetSolve := db_get_solve(SubmitID, fname);
	end;

function GetApp(TaskID : integer; Name : string; Destdir : string) : boolean;
	begin
  		GetApp := copyfile(testdir + inttostr(TaskID) + '\' + Name, DestDir);
	end;

function GetTestFiles(TaskID, Testnum : integer; SrcNames, DestNames : string; Destdir : string) : boolean;
var si, sj, sl: integer;
    di, dj, dl: integer;
    ok: boolean;
    snames, dnames: string;
    sname, dname:   string;
begin
    Result := false;
    ok := true;

    snames := SrcNames;
    dnames := DestNames;
    if snames <> '' then snames := snames + ',';
    if dnames <> '' then dnames := dnames + ',';

    si := 1;
    sj := si;
    sl := length(snames);
    di := 1;
    dj := di;
    dl := length(dnames);
    while (sj <= sl) do begin
        if snames[sj] = ',' then begin
            while (dj<=dl)and(dnames[dj]<>',') do inc(dj);
            sname := copy(snames, si, sj-si);
            dname := copy(dnames, di, dj-di);
            ok := tfiles.copyfile(testdir + inttostr(TaskID) + '\' + inttostr(Testnum) + '_' + sname, Destdir + dname) and ok;
            si := sj + 1;
            di := dj + 1;
        end;
        inc(sj);
    end;
    Result := ok;
end;

procedure init;
	begin
  		testdir := MainConfig.ReadString('db', 'testsdir', '');
  		if testdir[length(testdir)] <> '\' then
    		testdir := testdir + '\';
  		if not direxists(testdir) then begin
            fatal('Directory with tests not exists');
        end;
  		dbSolveFile := MainConfig.ReadString('db', 'dbsolvefile', '');
  		db_name := MainConfig.ReadString('db', 'dbname', '');
  		db_host := MainConfig.ReadString('db', 'dbhost', '');
  		db_user := MainConfig.ReadString('db', 'dbuser', '');
  		db_pass := MainConfig.ReadString('db', 'dbpass', '');

  		db_set_log_device(1);
  		db_set_server(db_user, db_pass, db_host, db_name, 1);
  		if not db_init then Halt(1);
	end;

procedure done;
	begin
  		db_done;
	end;

function isMonitorFrozen(SubmitInfo: TSubmitInfo): Boolean;
var
  finishTime: TDateTime;
  timeLeft: TDateTime;
begin
  if not db_get_allow_froze(SubmitInfo.contest) then
    result := false
  else begin
    finishTime := db_get_finish_time(SubmitInfo.contest);
    timeLeft := finishTime - SubmitInfo.stime;

    if timeLeft < 0 then
      result := true
    else
      result := secondsBetween(db_get_server_time, db_get_finish_time(SubmitInfo.contest))
        < db_get_froze_time_sec(SubmitInfo.contest)
  end
end;

initialization
 	init;
finalization
 	done;
end.

