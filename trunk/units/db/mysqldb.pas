unit mysqldb;

interface
uses
    windows,
    DateUtils,
    sysutils,
    ttimes,
    ttypes,
    tlog,
    mysql,
    mycp;

const
    waiter_port : integer = 8100;
    client_port : integer = 8101;

var
    db_name, db_host, waiter: string;
    curuser    : TUserInfo;
    taskcount  : integer;
    submitcount: integer;

function db_calc_max_stry(UserID, ContestID : integer; ProblemID: String) : integer;
procedure db_error(s : string; ex : boolean);
function ping : boolean;
function db_query(var query : string) : boolean;
function db_use(var query : string) : boolean;
function db_insert(query : ansistring) : boolean;
procedure genpointslist(const TaskInfo: TTaskInfo; var points, flags: AnsiString);
procedure parsepointslist(var TaskInfo: TTaskInfo; const points, flags: AnsiString);
procedure db_set_log_device(logdev : integer);
procedure db_set_server(user, password, host, database : String; cp : integer);
function db_get_max_submit_size : integer;
function db_init : boolean;
procedure db_done;
function db_user_auth(var User : TUserInfo) : boolean;
function db_read_user_tasks(UserID : integer) : integer;
function db_get_task_bynum(num : integer; var Task: TTaskInfo): boolean;
function db_get_submit_bynum(num : integer; var Submit: TSubmitInfo): boolean;
function db_user_submit_file(fname : string; UserID, TaskID : integer; lng : String) : integer;
function db_read_tester_submits: integer;
function db_update_testing(SubmitInfo: TSubmitInfo): Boolean;
function db_lock(table_id : integer; locktype : integer) : boolean;
function db_unlock : boolean;
function db_create_id(table_id : integer) : integer;
function db_get (table_id, field_id: integer; req : TRequest; reread : boolean; var info): boolean;
function db_set (table_id, field_id: integer; req : TRequest; var info): boolean;
function db_get_solve(SubmitID : integer; fname : string) : boolean;
function db_check_update : boolean;
function db_get_config(name: string):string;
procedure db_update_monitor(user, contest, stry, solved, pts: integer; problem: String; stime: TDateTime);
function db_get_id(alias : String; var id: integer): boolean;
procedure save_all_solves;
function db_get_server_time: TDateTime;
function db_get_cur_time(contestId: Integer): TDateTime;
function db_get_time_left(contestId: Integer): TDateTime;
function db_get_seconds_left(contestId: Integer): integer;
function db_get_finish_time(contestId: Integer): TDateTime;
function db_get_contest_length(contestId: Integer): TDateTime;
function db_get_froze_time_sec(contestId: Integer): Integer;
function db_get_allow_froze(contestId: Integer): Boolean;
function db_get_task_id(Problem: String; Contest: Integer): Integer;

implementation

uses
    Math,
    uUtils,
    tConfig
    ;

const
    max_submitfile_size : integer = 51000;
    cpMySQL = cp1251;
    _DEFAULT_PENALTY_MINUTES: Integer = 20;
    _DEFAULT_PENALTY_POINT: Integer = 1;

var
    db       : String;
    dbhost   : String;
    dbuser   : String;
    dbpass   : String;
    dbcp     : integer;

    tasks    : array of TTaskInfo;
    submits  : array of TSubmitInfo;

    mtasks   : array of TTaskInfo;
    musers   : array of TUserInfo;

    updatetime : TDateTime;

    log        : integer;
    //mysql_character_set_name - кодировка у бд

    sock   : PMYSQL;                     //MySQL sock
    recbuf : PMYSQL_RES;                 //MySQL res
    rowbuf : PMYSQL_ROW;                 //MySQL row
    lenbuf : PMYSQL_LENGTHS;

// *** function defs ***

// contest / problem / penalty
function getProblemAdded(contestId: Integer; problemId: String): TDateTime; forward;
function getContestTimePenalty(contestId: Integer): Integer; forward;
function getTimePenalty(contestId: Integer; problemId: String; solveTime: TDateTime; solveTry: Integer; solved: Boolean): int64; forward;
function getContestPointPenalty(contestId: Integer): Integer;  forward;
function getPointPenalty(contestId, solveTry: Integer): Integer;  forward;
function getContestStartTime(contestId: Integer): TDateTime; forward;

// *************  internal functions **************
// Функция, выдающая сообщение об ощибке
procedure db_error(s : string; ex : boolean);
var er : PChar;
begin
  if sock <> nil then
    er := mysql_error(sock)
  else
    er := 'Unknown error';
  if log = 0 then begin
    MessageBox(0, er, PChar(s), MB_OK or MB_SYSTEMMODAL or MB_ICONERROR);
  end else begin
  	logger.error.print('mysqldb: ' + s);
    logger.error.print('mysql  : ' + er);
  end;
  if not ex then
    exit;
  Halt(1);
end;

// Функция, проверяющая соединение с mysql-сервером
function ping : boolean;
begin
  if mysql_ping(sock) <> 0 then begin
    db_error('Connection to MySQL server lost', false);
    result := false;
    exit;
  end else result := true;
end;

// Функция, выполняющая запрос query и помещающая результат запроса
// в глобальную переменную recbuf
function db_query(var query : string) : boolean;
begin
  result := false;
  if (mysql_real_query(sock, PChar(query), length(query)) <> 0) then begin
    db_error('Query failed', false);
    exit;
  end;

  recbuf := mysql_store_result(sock);
  if recbuf = nil then begin
    db_error('Query returned NULL result', false);
    exit;
  end;

  result := true;
end;

// Temporary function to wrap String variable into "var" String variable
// and pass it to qb_query function
function query(query: String): Boolean;
var
    myQuery: String;
begin
    myQuery := query; result := db_query(myQuery)
end;

function db_use(var query : string) : boolean;
begin
  result := false;
  if (mysql_real_query(sock, PChar(query), length(query)) <> 0) then begin
    db_error('Query failed', false);
    exit;
  end;

  recbuf := mysql_use_result(sock);
  if recbuf = nil then begin
    db_error('Query returned NULL result', false);
    exit;
  end;

  result := true;
end;

// Функция применяется для добавления записи в БД
function db_insert(query : ansistring) : boolean;
begin
  result := false;
  if (mysql_real_query(sock, PChar(query), length(query)) <> 0) then begin
    db_error('Query failed', false);
    exit;
  end;
  result := true;
end;

// Функция генерирует строку баллов из структуры TTaskInfo
procedure genpointslist(const TaskInfo: TTaskInfo; var points, flags: AnsiString);
 	var i, j: integer;
 	begin
  		points := '';
   		for j := 1 to TaskInfo.TestCount do
    		if j <> TaskInfo.TestCount then
     			points := points + IntToStr(TaskInfo.Point[j]) + ','
        	else
     			points := points + IntToStr(TaskInfo.Point[j]);
  		flags := '';
  		for i := 1 to TaskInfo.TestCount do begin
   			if i <> TaskInfo.TestCount then
    			flags := flags + IntToStr(TaskInfo.Flag[i]) + ','
   			else
    			flags := flags + IntToStr(TaskInfo.Flag[i]);
  		end;
 	end;

// Функция обрабатывает строку баллов в структуру TTaskInfo
procedure parsepointslist(var TaskInfo: TTaskInfo; const points, flags: AnsiString);
 	var i, j, q, p: integer;
 	begin
  		j := 1;
  		q := 0;
  		p := 1;
  		fillchar(TaskInfo.point, sizeof(TaskInfo.point), 0);
  		while (p <= length(points) + 1) do begin
   			if (p <= length(points)) and (points[p] in ['0'..'9']) then
    			q := q * 10 + ord(points[p]) - ord('0')
   			else
            	begin
    				TaskInfo.point[j] := q;
    				q := 0;
    				inc(j);
   				end;
   			inc(p);
  		end;
  		i := 1;
  		q := 0;
  		p := 1;
  		fillchar(TaskInfo.flag, sizeof(TaskInfo.flag), 0);
  		while (p <= length(flags)) and (i <= TaskInfo.testcount) do begin
   			if flags[p] in ['0'..'9'] then
    			q := q * 10 + ord(points[p]) - ord('0')
   			else
            	begin
    				TaskInfo.flag[i] := q;
    				q := 0;
    				inc(i);
    				while (p <= length(flags)) and (flags[p] <> ',') do inc(p);
   				end;
            inc(p);
  		end;
  		TaskInfo.flag[i] := q;
 	end;



// *************  init/deinit functions **************
//set log device. 0 - messagebox, 1 - console
procedure db_set_log_device(logdev : integer);
begin
  log := logdev;
end;

//устанавливает аттрибуты сервера, должна вызыатьдся до db_init()
procedure db_set_server(user, password, host, database : String; cp : integer);
begin
  dbuser := user;
  dbpass := password;
  dbhost := host;
  db     := database;
  case cp of
    0 : dbcp := koi8r;
    1 : dbcp := cp1251;
    2 : dbcp := cp866;
  end;
end;

//возвращает значение константы max_submit_size
function db_get_max_submit_size : integer;
begin
  result := max_submitfile_size;
end;

//подключается к серверу MySQL и выбирает БД
function db_init : boolean;
begin
    updatetime := 0;
    sock := mysql_init(nil);
    if mysql_real_connect(sock, PChar(dbhost), PChar(dbuser), PChar(dbpass), PChar(db), 0, nil, 0) = nil then begin
        db_error('Could not connect to MySQL server', true);
        result := false;
        exit;
    end else
        result := true;
    if mysql_select_db(sock, PChar(db)) <> 0 then
        db_error('Could not select database ' + db, true);
end;

//отключается от сервера MySQL, очищает кэш
procedure db_done;
begin
  mysql_close(sock);
  setlength(tasks, 0);
  setlength(submits, 0);
end;


// *************  client-purpose functions **************

function db_get_server_time: TDateTime;
var
	q: String;
begin
    result := 0;

    if not ping then exit;

    q := 'SELECT NOW();';

    if not db_query(q) then exit;

    rowbuf := mysql_fetch_row(recbuf);
    if rowbuf = nil then
        result := 0
    else
        result := StrToDateTimeS(rowbuf[0]);

    mysql_free_result(recbuf);
end;

//определяет количество попыток, сделанное пользователем и увеличивает его на 1
function db_calc_max_stry(UserID, ContestID : integer; ProblemID: String) : integer;
var q : string;
begin
  result := 0;

  if not ping then exit;

  q := 'SELECT MAX(Attempt) FROM submit' +
       '  WHERE userID=' + inttostr(UserID) +
       '  AND ProblemID="' + ProblemID +
       '  AND ContestID="' + inttostr(ContestID);

  if not db_query(q) then exit;

  rowbuf := mysql_fetch_row(recbuf);
  if rowbuf = nil then
    result := 0
  else
    result := strtointdef(rowbuf[0], 0);
  inc(result);
  mysql_free_result (recbuf);
end;

//аутентификация пользователя в БД, возвращает user.id=InvalidID в случае ошибки
function db_user_auth(var User : TUserInfo) : boolean; 
var q : string;
    t : String;
begin
  User.id := InvalidID;
  result := false;

  if not ping then exit;

  ConvertStr(dbcp, cpMySQL, User.login, t);

  q := 'SELECT id,name FROM user WHERE login="'+t+'" AND password="'+User.password+'";';

  if not db_query(q) then exit;

  rowbuf := mysql_fetch_row(recbuf);
  if (rowbuf <> nil) and (mysql_num_rows (recbuf) = 1) then with User do begin
    id     := StrToInt(rowbuf[0]);
    name := StrPas(rowbuf[1]);
    ConvertStr(cpMySQL, dbcp, name, name);
    result := true;
  end;
  mysql_free_result (recbuf);
end;

//читает информацию и задачах в кэш для user.id = UserID, возвращает количество записей
function db_read_user_tasks(UserID : integer) : integer; 
var q : string;
    i : integer;
begin
  	result := 0;
  	setlength(tasks, 0);
  	if (UserID = InvalidID) then begin
    	db_error('Invalid UserID: ' + inttostr(UserID), false);
    	exit;
  	end;
  	if not ping then exit;

  	q := 	'SELECT DISTINCT task.id,task.name,task.complex,task.timelimit,task.memorylimit,task.author,task.input,task.output' +
       		'   FROM task' +
       		'   ORDER BY task.id;';

  	if not db_query(q) then exit;

  	result := mysql_num_rows (recbuf);
  	setlength(tasks, result);
  	rowbuf := mysql_fetch_row(recbuf);
  	i := 0;
  	while (rowbuf <> nil) and (i < length(tasks)) do
  		with tasks[i] do begin
    		id := StrToIntDef(rowbuf[0], 0);
    		name := StrPas(rowbuf[1]);
    		timelimit := StrToIntDef(rowbuf[3], 0);
    		memorylimit := StrToIntDef(rowbuf[4], 0);
    		author := StrPas(rowbuf[5]);
    		input := StrPas(rowbuf[6]);
    		output := StrPas(rowbuf[7]);
    		ConvertStr(cpMySQL, dbcp, name, name);
    		ConvertStr(cpMySQL, dbcp, author, author);
    		inc(i);
    		rowbuf := mysql_fetch_row(recbuf);
  		end;

  	mysql_free_result (recbuf);
end;

//вытаскивает информацию о задании из кэша по номеру
function db_get_task_bynum(num : integer; var Task: TTaskInfo): boolean; 
begin
  	if (num < 0) or (num > high(tasks)) then
    	result := false
  	else begin
    	result := true;
    	Task := tasks[num];
    end;
end;

function db_update_testing(SubmitInfo: TSubmitInfo): Boolean;
var
    q: String;
begin
    result := true;

  q := 'UPDATE testing SET finished=NOW(), result="0" WHERE testingId="' + inttostr(SubmitInfo.testingId) + '" AND contesterId="' + MainConfig.ReadString('tsys', 'id', '1') + '"';
  if not db_insert(q) or (0 = mysql_affected_rows(sock)) then
    result := false;

end;

//получить посылку из кэша по номеру
function db_get_submit_bynum(num : integer; var Submit: TSubmitInfo): boolean;
begin
  	if (num < 0) or (num > high(submits)) then
    	result := false
  	else begin
    	result := true;
    	Submit := submits[num];
  	end;
end;

//посылает файл fname для UserID и TaskID
function db_user_submit_file(fname : string; UserID, TaskID : integer; lng : String) : integer; 
var q     : string;
    sfile : string;
    qfile : PChar;
    t     : integer;
    f     : file;
    stime:  String;
begin
  	result := InvalidID;

  	if not ping then exit;

  	assignfile(f, fname);
  	reset(f, 1);
  	SetLength(sfile, filesize(f){ + 1});
  	BlockRead(f, sfile[1], filesize(f));
  	closefile(f);
  	q := 	'SELECT MAX(stry) FROM submit' +
       		'  WHERE user="' + inttostr(UserID) + '" AND task="' + inttostr(TaskID) + '";';

  	if not db_query(q) then exit;

  	rowbuf := mysql_fetch_row(recbuf);
  	if rowbuf = nil then
    	t := 0
  	else
    	t := strtointdef(rowbuf[0], 0);
  	mysql_free_result (recbuf);
  	inc(t);

  	GetMem(qfile, length(sfile)*2+1);
  	mysql_real_escape_string(sock, qfile, PChar(sfile), length(sfile));

  	q := 'SELECT NOW();';
  	if not db_query(q) then exit;
  	rowbuf := mysql_fetch_row(recbuf);
  	if rowbuf = nil then
    	stime := '0'
  	else
    	stime := rowbuf[0];
  	mysql_free_result (recbuf);

  	q := 	'INSERT INTO `submit` (`user`, `task`, `stry`, `stime`, `status`, `solve`, `lng`)' +
       		'   VALUES ("' + inttostr(UserID) + '", "'+inttostr(TaskID)+'", "' + inttostr(t) + '", "'+stime+'", "0", "' + qfile + '", "' + lng + '");';

  	FreeMem(qfile);

  	if (mysql_real_query(sock, PChar(q), length(q)) <> 0) then
    	db_error('Query failed', false)
  	else
    	result := mysql_insert_id(sock);

end;

// *************  tester-purpose funcions  ***************

//читает информацию о посылках в кэш для тестера, возвращает количество записей
function db_read_tester_submits: integer;
var
    q        : string;
    i        : integer;
    testingId: integer;
begin
  	result := 0;
  	setlength(submits, 0);

  	if not ping then exit;

  	q := 	'SELECT S.SubmitID,S.UserID,S.ProblemID,S.ContestID,S.Attempt,S.SubmitTime,S.StatusID,L.Batch,L.TimeMul,L.MemoryBuf,T.testingId '+
          'FROM ' +
            '(testing T INNER JOIN (submit S INNER JOIN lang L ON S.LangID=L.LangID) ON T.submitId = S.SubmitId)' +
            'inner join cntest C on S.contestId=C.contestId ' +
       		'WHERE T.result="1" and T.contesterId="0"' +
            ' and S.SubmitTime < C.finish ' +
          'ORDER BY S.SubmitID LIMIT 1';

    if not db_query(q) then exit;

  	result := mysql_num_rows (recbuf);
    if result > 1 then result := 1;
  	setlength(submits, result);

  	rowbuf := mysql_fetch_row(recbuf);
  	i := 0;
  	while (rowbuf <> nil) and (i < length(submits)) do begin
    	with submits[i] do begin
    		id            := StrToIntDef(rowbuf[0], 0);
    		user          := StrToIntDef(rowbuf[1], 0);
    		problem       := rowbuf[2];
    		contest       := StrToIntDef(rowbuf[3], 0);
    		stry          := StrToIntDef(rowbuf[4], 0);
    		stime         := StrToDateTimeS(rowbuf[5]);
    		status        := StrToIntDef(rowbuf[6], 0);
    		bat           := rowbuf[7];
        timemul       := StrToIntDef(rowbuf[8], 100);
        MemoryBuf     := StrToIntDef(rowbuf[9], 0);
            testingId := StrToIntDef(rowbuf[10], 0);
    		rowbuf := mysql_fetch_row(recbuf);
 		end;
        testingId := submits[i].testingId;
  		inc(i);
    end;

  mysql_free_result (recbuf);

  if result > 0 then begin
      q := 'UPDATE testing SET started=NOW(), result="2", contesterId="' + MainConfig.ReadString('tsys', 'id', '1') + '" WHERE testingId="' + inttostr(testingId) + '" AND result="1" AND contesterId="0"';
      if not db_insert(q) or (0 = mysql_affected_rows(sock)) then begin
        setlength(submits, 0); result := 0;
      end;
  end;
end;


// *************  general-purpose functions **************

//заблокировать таблицу
function db_lock(table_id : integer; locktype : integer) : boolean;  
var q, s : string;
begin
  	result := false;

  	if not ping then exit;

  	q := '';
  	if locktype = ltRead then
    	q := 'READ';
  	if locktype = ltRead then
    	q := 'WRITE';

  	case table_id of
    	dbTask : begin
      		s := 'task';
    	end;

   		dbSubmit : begin
      		s := 'submit';
    	end;

    	ttypes.dbUser : begin
      		s := 'user';
    	end;
  	end;

  	q := 'LOCK TABLES ' + s + ' ' + q;
  	//real query from MySQL server
  	if not db_insert(q) then exit;
  	result := true;
end;

//разблокировать таблицу
function db_unlock : boolean;  
var q : string;
begin
  	result := false;

  	if not ping then exit;

  	q := 'UNLOCK TABLES';
  	//real query from MySQL server
  	if not db_insert(q) then exit;
  	result := true;
end;

//create id in table_id (dbTask,dbSubmit,dbUser)
function db_create_id(table_id : integer) : integer; 
var q, s : string;
begin
  	result := InvalidID;

  	if not ping then exit;

  	case table_id of
    	dbTask : begin
      		s := 'task';
    	end;

    	dbSubmit : begin
      		s := 'submit';
    	end;

    	ttypes.dbUser : begin
      		s := 'user';
    	end;
  	end;

  	q := 'INSERT INTO ' + s + ' () VALUES ();';
  	//real query from MySQL server
  	if not db_insert(q) then exit;
  	result := mysql_insert_id(sock);
end;

//get info from table_id (dbTask,dbSubmit,dbUser)
//with id=field_id, filter fields by req, read from cache if reread is false,
//read into info
function db_get (table_id, field_id: integer; req : TRequest; reread : boolean; var info): boolean; 
var
    q, s, fld : string;
    i         : integer;
begin
  	result := false;

  	if not ping then exit;

  	//send query or look into local cache
  	case table_id of
    	dbTask : begin
      		if not reread then
        		for i := low(tasks) to high(tasks) do
          			if tasks[i].id = field_id then begin
            			TTaskInfo(info) := tasks[i];
            			result := true;
            			exit;
          			end;
      		case req of
        		rqClient : fld := 'name,complex,timelimit,memorylimit,author,input,output,testcount';
        		rqTester : fld := 'name,timelimit,memorylimit,testcount,input,output,pts';
        		rqWaiter : fld := '';
      		end;
      		q := 	'SELECT ' + fld + ' FROM Task' +
           			'  WHERE TaskID="'+IntToStr(field_id)+'";';
     		s := 'task';
    	end;

    	dbSubmit : begin
      		if not reread then
        		for i := low(submits) to high(submits) do
          			if submits[i].id = field_id then begin
            			TSubmitInfo(info) := submits[i];
            			result := true;
            			exit;
          			end;
      		case req of
        		rqClient : fld := 'task,stry,stime,ttime,status,point,result,inf,msg';
        		rqTester : fld := 'S.UserID,S.ProblemID,S.ContestID,S.Attempt,S.SubmitTime,S.StatusID,L.Batch,L.DOS,L.TimeMul,L.MemoryBuf ';
        		rqWaiter : fld := '';
      		end;
      		q := 	'SELECT ' + fld + ' FROM submit S INNER JOIN Lang L ON S.LangID=L.LangID' +
           			'  WHERE SubmitID="' + IntToStr(field_id) + '"';
      		s := 'submit';
    	end;

    	ttypes.dbUser : begin
      		q := 	'SELECT name,login,password FROM user' +
           			'  WHERE id="'+IntToStr(field_id)+'";';
      		s := 'user';
    	end;
   	end;

  	//real query from MySQL server
  	if not db_query(q) then exit;

  	//check some bugs
  	if mysql_num_rows (recbuf) = 0 then begin
    	mysql_free_result (recbuf);
    	db_error(s + ' ' + IntToStr(field_id) + ' not found', false);
    	exit
  	end;
  	if mysql_num_rows (recbuf) > 1 then begin
    	mysql_free_result (recbuf);
    	db_error('more than one ' + s + ' ' + IntToStr(field_id) + ' not found', false);
    	exit
  	end;
  	rowbuf := mysql_fetch_row(recbuf);

  	//set info
  case table_id of
    dbTask : case req of
      rqClient : with TTaskInfo(info) do begin
        id := field_id;
        name := StrPas(rowbuf[0]);
//        complex := StrToIntDef(rowbuf[1], 0);
        timelimit   := StrToIntDef(rowbuf[2], 0);
        memorylimit   := StrToIntDef(rowbuf[3], 0);
        author := StrPas(rowbuf[4]);
        input := StrPas(rowbuf[5]);
        output := StrPas(rowbuf[6]);
        ConvertStr(cpMySQL, dbcp, name, name);
        ConvertStr(cpMySQL, dbcp, author, author);
        testcount   := StrToIntDef(rowbuf[7], 0);
      end;
      rqTester : with TTaskInfo(info) do begin
//        		rqTester : fld := 'name,timelimit,memorylimit,testcount,input,output,pts';
        id := field_id;
        name := rowbuf[0];
//        bonus := StrToIntDef(rowbuf[1], 0);
        timelimit   := StrToIntDef(rowbuf[1], 0);
        memorylimit   := StrToIntDef(rowbuf[2], 0);
//        author := rowbuf[4];
        testcount   := StrToIntDef(rowbuf[3], 0);
//        checker := rowbuf[6];
//        summator := rowbuf[7];
        input := rowbuf[4];
        output := rowbuf[5];
//        ans := rowbuf[10];
        parsepointslist(TTaskInfo(info), rowbuf[6], '');
        ConvertStr(cpMySQL, dbcp, name, name);
//        ConvertStr(cpMySQL, dbcp, author, author);
      end;
      rqWaiter : ;
    end;

    dbSubmit : case req of
      rqClient : with TSubmitInfo(info) do begin
        id            := field_id;
//        task          := StrToIntDef(rowbuf[0], 0);
        User          := StrToIntDef(rowbuf[1], 0);
        stry          := StrToIntDef(rowbuf[4], 0);
        stime         := StrToDateTimeS(rowbuf[5]);
        status        := StrToIntDef(rowbuf[4], 0);
        result.point  := StrToIntDef(rowbuf[5], 0);
        result.result := StrToIntDef(rowbuf[6], 0);
        result.inf    := StrToIntDef(rowbuf[7], 0);
        result.msg := rowbuf[8];
        ConvertStr(cpMySQL, dbcp, result.msg, result.msg);
      end;
      rqTester : with TSubmitInfo(info) do begin
        id            := field_id;
        user          := StrToIntDef(rowbuf[0], 0);
        problem       := rowbuf[1];
        Contest       := StrToIntDef(rowbuf[2], 0);
        stry          := StrToIntDef(rowbuf[3], 0);
        stime         := StrToDateTimeS(rowbuf[4]);
        status        := StrToIntDef(rowbuf[5], 0);
        Bat           := rowbuf[6];
        DOS           := StrToIntDef(rowbuf[7], 0) = 1;
        TimeMul       := StrToIntDef(rowbuf[8], 100);
        MemoryBuf     := StrToIntDef(rowbuf[9], 0);
      end;
      rqWaiter : ;
    end;

    ttypes.dbUser : with TUserInfo(info) do begin
      id            := field_id;
      name := rowbuf[0];
      login := rowbuf[1];
      password := rowbuf[2];
      ConvertStr(cpMySQL, dbcp, name, name);
      ConvertStr(cpMySQL, dbcp, login, login);
    end;

  end;


  result := true;
  mysql_free_result (recbuf);
end;


//обновить информацию в таблице table_id (dbTask,dbSubmit,dbUser)
//где id=field_id, установить поля по req
function db_set (table_id, field_id: integer; req : TRequest; var info): boolean;
var
    q         : string;
    values    : string;
    p1, p2    : string;
    t         : String;

    function getTimePenaltyLocal: String;
    begin
        result := itos(
            getTimePenalty(
                    TSubmitInfo(info).contest
                ,   TSubmitInfo(info).problem
                ,   TSubmitInfo(info).stime
                ,   TSubmitInfo(info).stry
                ,   TSubmitInfo(info).result.result = 0
            ) // getPenalty
        ) // result
    end;

  function escape(v : string) : string;
  var t : PChar;
  begin
    GetMem(t, length(v)*2+1);
    mysql_real_escape_string(sock, t, PChar(v), length(v));
    result := t;
    FreeMem(t);
  end;

  procedure append(sfld, svalue : string);
  begin
    if values <> '' then
      values := values + ',';
    values := values + sfld + '="' + svalue + '"';
  end;
begin
  result := false;

  if field_id < 0 then begin
    db_error('invalid id in db_set(): ' + inttostr(field_id), false);
    exit;
  end;

  if not ping then exit;

  //послать запрос или посмотреть в локальном кэше
  values := '';
  case table_id of
    dbTask : begin
      case req of
        rqTester : with TTaskInfo(info) do begin
          ConvertStr(dbcp, cpMySQL, name, t);
          append('name', escape(t));
//          append('complex', inttostr(complex));
//          append('bonus', inttostr(bonus));
          append('timelimit', inttostr(timelimit));
          append('memorylimit', inttostr(memorylimit));
          ConvertStr(dbcp, cpMySQL, author, t);
          append('author', escape(t));
          append('testcount', inttostr(testcount));
//          append('checker', escape(checker));
//          append('summator', escape(summator));
          append('input', escape(input));
          append('output', escape(output));
//          append('ans', escape(ans));
          genpointslist(TTaskInfo(info), p1, p2);
          append('point', escape(p1));
        end;
      end;
      q := 'task';
    end;

    dbSubmit : begin
      case req of
        rqTester : with TSubmitInfo(info) do begin
          append('UserID', inttostr(user));
//          append('task', inttostr(task));
          append('ProblemID',escape(Problem));
          append('ContestID',inttostr(contest));
          append('Attempt', inttostr(stry));
          append('SubmitTime', FormatDateTime(date_time_format, stime));
//          append('ttime', FormatDateTime(date_time_format, ttime));
          append('StatusID', '0');
//          append('lng', escape(lng));
          append('ResultID', inttostr(result.result));
          append('Pts', inttostr(result.point));
//          append('inf', inttostr(result.inf));
          append('TotalTime', IntToStr(result.time));
          append('TotalMemory', IntToStr(result.mem));
          append('penalty', getTimePenaltyLocal);
          ConvertStr(dbcp, cpMySQL, result.msg, t);
          append('Message', escape(t));
        end;
      end;
      q := 'submit';
    end;

    ttypes.dbUser : begin
      case req of
        rqTester : with TUserInfo(info) do begin
          ConvertStr(dbcp, cpMySQL, name, t);
          append('name', escape(t));
          ConvertStr(dbcp, cpMySQL, login, t);
          append('login', escape(t));
          append('password', escape(password));
        end;
      end;
      q := 'user';
    end;

  end;

  q := 'UPDATE ' + q + ' SET ' + values + ' WHERE SubmitID="' + inttostr(field_id) + '" LIMIT 1';
  //real query to MySQL server
  if not db_insert(q) then exit;

  result := true;
end;

//сохранит решение в файл fname для SubmitID
function db_get_solve(SubmitID : integer; fname : string) : boolean; 
var q : string;
    f : file;
begin
  result := false;

  if not ping then exit;

  q := 'SELECT Source FROM Submit WHERE SubmitID="'+IntToStr(SubmitID)+'";';

  if not db_query(q) then exit;

  rowbuf := mysql_fetch_row(recbuf);
  lenbuf := mysql_fetch_lengths(recbuf);

  assignfile(f, fname);
  rewrite(f, 1);
  if (rowbuf <> nil) then begin
      BlockWrite(f, rowbuf[0][0], lenbuf[0]);
    result := true;
  end;
  closefile(f);

  mysql_free_result (recbuf);
end;


//if updatetime is changed, return true
function db_check_update : boolean; 
var q : string;
    t : TDateTime;
    bl : integer;
begin
    result := false;

    if not ping then exit;

    repeat
        q := 'SELECT value FROM config WHERE name="clientblock";';
        if not db_query(q) then exit;
        rowbuf := mysql_fetch_row(recbuf);
        bl := 1;
        if (rowbuf <> nil) and (mysql_num_rows (recbuf) = 1) then begin
            bl := StrToIntDef(rowbuf[0], 1);
        end;
        mysql_free_result (recbuf);
        if bl=1 then begin
            MessageBox(0, 'TSys block all clients. Wait a few seconds and restart app.', 'Lock', MB_SYSTEMMODAL);
            db_done;
            halt(0);
            exit;
        end;
    until bl = 0;

    q := 'SELECT value FROM config WHERE name="updatetime";';
    if not db_query(q) then exit;
    rowbuf := mysql_fetch_row(recbuf);
    if (rowbuf <> nil) and (mysql_num_rows (recbuf) = 1) then begin
        t := StrToDateTimeS(rowbuf[0]);
        if t <> updatetime then begin
            result := true;
            updatetime := t;
        end;
    end;
    mysql_free_result (recbuf);
end;

// *************  monitor function  ********************

function db_get_config(name: string):string;
var q: string;
begin
    if not ping then exit;

    q := 'SELECT value from `config` where `name`='''+name+''';';
    if not db_query(q) then exit;
    rowbuf := mysql_fetch_row(recbuf);
    if rowbuf <> nil then
        result := rowbuf[0];

    mysql_free_result(recbuf)
end;

function  db_update_volume(contest: Integer;
                           problem: String;
                           solved:  Boolean): Boolean;
var
  q:          String;
  d_solved:   Integer;
begin
  Result := False;
  if not ping then
    exit;

  q :=  'SELECT ' +
          'Solved ' +
        'FROM ' +
          'volume ' +
        'WHERE ' +
          '(ContestID=' + IntToStr(contest) + ') AND (ProblemID="' + problem + '")';
  if not db_query(q) then
    exit;

  rowbuf := mysql_fetch_row(recbuf);
  if rowbuf <> nil then begin
      d_solved  := StrToIntDef(rowbuf[0], 0);

      mysql_free_result(recbuf);

      if Solved then
        inc(d_solved);

      q :=  'UPDATE ' +
              'volume ' +
            'SET ' +
              'solved=' + IntToStr(d_solved) + ' ' +
            'WHERE ' +
              '(ContestID=' + IntToStr(contest) + ') AND (ProblemID="' + problem + '")';
      if not db_insert(q) then
        exit
    end
  else begin
    mysql_free_result(recbuf);

    exit
  end;

  Result := True
end;

function getProblemAdded(contestId: Integer; problemId: String): TDateTime;
var
    problemAddTime: String;
begin
    if not query('SELECT added FROM Volume WHERE ContestID=' + itos(contestId) + ' and problemId="' + problemId + '"') then begin
        raise Exception.Create('Unable to get problem add time for contest with id=' + itos(contestId) + ' and problem with id=' + problemId);
    end;

    rowbuf := mysql_fetch_row(recbuf); if (rowbuf = nil) then begin
        raise Exception.Create('Problem with id=' + problemId + ' not found in contest with id=' + itos(contestId));
    end;

    problemAddTime := rowbuf[0];

    mysql_free_result(recbuf);

    if (nulldt() = problemAddTime) then begin
        result := getContestStartTime(contestId);
    end else begin
        result := stod(problemAddTime)
    end;
end;

function getContestTimePenalty(contestId: Integer): Integer;
begin
    if not query('SELECT timePenalty FROM Cntest WHERE ContestID=' + itos(contestId)) then begin
        raise Exception.Create('Unable to get default penalty minutes value for contest with id=' + itos(contestId));
    end;

    rowbuf := mysql_fetch_row(recbuf); if (rowbuf = nil) then begin
        raise Exception.Create('Contest with id=' + itos(contestId) + ' not found');
    end;

    result := stoi(rowbuf[0], _DEFAULT_PENALTY_MINUTES);

    mysql_free_result(recbuf);
end;

function getTimePenalty(contestId: Integer; problemId: String; solveTime: TDateTime; solveTry: Integer; solved: Boolean): int64;
begin
    result := 0;
    if solved then begin
        result := SecondsBetween(getProblemAdded(contestId, problemId), solveTime);
        result := result + (solveTry - 1) * getContestTimePenalty(contestId) * 60;
    end;
end;

function getContestPointPenalty(contestId: Integer): Integer;
begin
    if not query('SELECT pointPenalty FROM Cntest WHERE ContestID=' + itos(contestId)) then begin
        raise Exception.Create('Unable to get default penalty point value for contest with id=' + itos(contestId));
    end;

    rowbuf := mysql_fetch_row(recbuf); if (rowbuf = nil) then begin
        raise Exception.Create('Contest with id=' + itos(contestId) + ' not found');
    end;

    result := stoi(rowbuf[0], _DEFAULT_PENALTY_POINT);

    mysql_free_result(recbuf);
end;

function getPointPenalty(contestId, solveTry: Integer): Integer;
begin
    if 1 >= solveTry then begin
        result := 0;
    end else begin
        result := (solveTry - 1) * getContestPointPenalty(contestId);
    end
end;

procedure db_update_monitor(user, contest, stry, solved, pts: integer; problem: String; stime: TDateTime);
var q: string;
    mstime: integer;
    pen:    Int64;
    RealPts:Integer;
    rowFound:Boolean;
    rowPts: Integer;
    rowSolved: Boolean;
begin
    if not ping then exit;

    pen := getTimePenalty(contest, problem, stime, stry, solved=1);

    q := 'SELECT Solved, Penalty, MaxPts FROM Monitor WHERE UserID=' + IntToStr(user) + ' AND ProblemID="' + problem + '" AND ContestID=' + IntToStr(contest);
    if not db_query(q) then exit;
    rowbuf := mysql_fetch_row(recbuf); rowFound := rowbuf <> nil;
    if (rowFound) then begin
      rowPts := StrToIntDef(rowbuf[2], 0);
      rowSolved := rowbuf[0] <> '1';
    end;
    mysql_free_result(recbuf);

    if rowFound then begin
      Pts := max(Pts, rowPts);
      RealPts := max(Pts - getPointPenalty(contest, stry), 0);
//      pen := pen + StrToIntDef(rowbuf[1], 0);

      if rowSolved then begin
        if solved=1
          then
            q := 'UPDATE ' +
                    '`monitor` ' +
                 'SET ' +
                    'Attempt='+IntToStr(stry)+', ' +
                    'Solved=1, ' +
                    'Penalty='+IntToStr(pen)+', ' +
                    'Date="'+DateTimeToStr(stime, localeFS()) +'", ' +
                    'MaxPts='+IntToStr(Pts)+ ', '+
                    'RealPts='+IntToStr(RealPts)+ ' '+
                 'WHERE ' +
                    'UserID='+IntToStr(user)+' ' +
                    'AND ProblemID="'+problem+'" ' +
                    'AND ContestID='+IntToStr(contest)+' ' +
                    'AND solved<>1'
          else
            q := 'UPDATE ' +
                    '`monitor` ' +
                 'SET ' +
                    'Attempt='+IntToStr(stry)+', ' +
                    'MaxPts=' + IntToStr(Pts) + ', ' +
                    'RealPts='+IntToStr(RealPts)+ ' '+
                 'WHERE ' +
                  'UserID='+IntToStr(user)+' ' +
                  'AND ProblemID="'+problem+'" ' +
                  'AND ContestID='+IntToStr(contest)+' ' +
                  'AND solved<>1';
        db_insert(q)
      end
    end
    else begin
      q :=  'INSERT INTO Monitor'+
              '(UserID, ' +
              'ProblemID, ' +
              'ContestID, ' +
              'Attempt, ' +
              'Solved, ';

      if solved=1 then
        q := q +
              'Date, ';

      q := q +
              'Penalty, ' +
              'MaxPts, ' +
              'RealPts) ' +
            'VALUES' +
              '('+IntToStr(user)+',' +
              '"'+problem+'", '+
              IntToStr(contest)+','+
              IntToStr(stry)+','+
              IntToStr(solved)+',';

      if solved=1 then
        q := q +
              '"'+DateTimeToStr(stime, localeFS()) +'", ';

      q := q + 
              IntToStr(pen)+','+
              IntToStr(Pts) + ',' +
              IntToStr(Pts) + ')';
      db_insert(q);
    end;
end;

// *************  compatibility functions **************

//check id
function db_get_id(alias : String; var id: integer): boolean;
var
    q        : string;
    t        : String;
begin
  result := false;

  if not ping then exit;

  ConvertStr(dbcp, cpMySQL, alias, t);
    mysql_free_result (recbuf);

    q := 'SELECT id FROM task WHERE id="'+t+'"';
    if (mysql_query(sock, PChar(q)) <> 0) then begin
      db_error('Query failed', false);
      exit;
    end;
    recbuf := mysql_store_result(sock);
    if recbuf = nil then begin
      db_error('Query returned NULL result', false);
      exit;
    end;

  if mysql_num_rows (recbuf) <> 1 then begin
    mysql_free_result (recbuf);
    db_error('More than one task by alias: "' + alias + '"', false);
    exit;
  end;
  rowbuf := mysql_fetch_row(recbuf);
  id     := StrToIntDef(rowbuf[0], 0);
  result := true;
  mysql_free_result (recbuf);
end;

function db_user_add(name, login, pass, ip: string): boolean;
var
  musercount:             Integer;
  q:                      String;
begin
    result := false;
    if not ping then exit;

    musercount := 0;

    q := 'select count(id) from `user`;';
    if not db_query(q) then exit;
    rowbuf := mysql_fetch_row(recbuf);
    if rowbuf <> nil then
        musercount := StrToIntDef(rowbuf[0], 0);
    mysql_free_result(recbuf);

    result := true;
    result := result and db_insert('INSERT INTO `user` (`id`, `name`, `login`, `password`) VALUES (' + IntToStr(musercount+1) + ',''' + name + ''', ''' + login + ''', ''' + pass + ''');');
    if mysql_select_db(sock, 'mysql') <> 0 then result := false;
    if result then
        begin
            result := result and db_insert('INSERT INTO `user` (`host`, `user`, `password`) VALUES (''' + ip + ''', ''' + login + ''', PASSWORD(''' + pass + '''));');
            result := result and db_insert('INSERT INTO `db` (`host`, `db`, `user`, select_priv, insert_priv, update_priv) VALUES (''' + ip + ''', ''' + LowerCase(db) + ''', ''' + login + ''', ''Y'', ''Y'', ''Y'');');
        end;
    if mysql_select_db(sock, PChar(db)) <> 0 then result := false;
    result := result and db_insert('FLUSH PRIVILEGES;');
end;

function db_task_add(task, author, input, output, rans, checker, testcount, timelimit, memlimit: string): boolean;
var
  mtaskcount:             Integer;
  q:                      String;
begin
    result := false;
    if not ping then exit;

    q := 'select count(id) from `task`;';
    if not db_query(q) then exit;
    rowbuf := mysql_fetch_row(recbuf);
    if rowbuf <> nil then
        mtaskcount := StrToIntDef(rowbuf[0], 0);
    mysql_free_result(recbuf);

    result := db_insert('INSERT INTO `task` (id,name,author,input,output,ans,checker,testcount,timelimit,memorylimit) VALUES ('+IntToStr(mtaskcount+1)+','''+task+''','''+author+''','''+input+''','''+output+''','''+rans+''','''+checker+''','+testcount+','+timelimit+','+memlimit+');');
end;

procedure save_all_solves;
var q : string;
    f : file;
    user, task, stry, lng: String;
    x:  array[1..38, 1..10] of Boolean;
    res: Integer;
begin
  if not ping then exit;
  fillchar(x, sizeof(x), False);

  q := 'SELECT id, user, task, stry, lng, solve, result FROM submit ORDER BY stime;';

  if not db_query(q) then exit;
  rowbuf := mysql_fetch_row(recbuf);

  while rowbuf<>nil do begin
    lenbuf := mysql_fetch_lengths(recbuf);
    user := rowbuf[1];
    task := rowbuf[2];
    stry := rowbuf[3];
    lng  := rowbuf[4];
    res  := StrToIntDef(rowbuf[6], 0);

    if not x[StrToIntDef(user, 0), StrToIntDef(task, 0)] then begin
      assignfile(f, 'solves\'+user+'_'+task+'_'+stry+'.'+lng);
      rewrite(f, 1);
      BlockWrite(f, rowbuf[5][0], lenbuf[5]);
      closefile(f);
      if res=0 then
        x[StrToIntDef(user, 0), StrToIntDef(task, 0)] := True
    end;

    rowbuf := mysql_fetch_row(recbuf);
  end;

  mysql_free_result (recbuf);
end;

function db_get_task_id(Problem: String; Contest: Integer): Integer;
var q : string;
begin
  if not ping then exit;

  q :=  'SELECT V.TaskID '+
        'FROM Volume V '+
        'WHERE V.ProblemID="'+Problem+'" AND V.ContestID='+IntToStr(Contest);

  if not db_query(q) then exit;
  rowbuf := mysql_fetch_row(recbuf);

  result := StrToIntDef(rowbuf[0], 0);

  mysql_free_result (recbuf);
end;

function getContestStartTime(contestId: Integer): TDateTime;
begin
    result := 0;

    if not ping then exit;

    if not query('SELECT start from cntest where contestId=' + itos(contestId)) then begin
        raise Exception.Create('Unable to get start time contest with id=' + itos(contestId));
    end;

    rowbuf := mysql_fetch_row(recbuf);

    if rowbuf = nil then begin
        raise Exception.Create('Contest with id=' + itos(contestId) + ' not found');
    end;

    result := StrToDateTime(rowbuf[0], localeFS());

    mysql_free_result(recbuf);
end;

function db_get_cur_time(contestId: Integer): TDateTime;
begin
  result := db_get_server_time - getContestStartTime(contestId)
end;

function db_get_time_left(contestId: Integer): TDateTime;
begin
  result := db_get_finish_time(contestId) - db_get_server_time
end;

function db_get_seconds_left(contestId: Integer): integer;
var
  time: TDateTime;
  hour, min, sec, msec: word;
begin
  time := db_get_time_left(contestId);

  decodeTime(time, hour, min, sec, msec);

  result := sec
end;

function db_get_finish_time(contestId: Integer): TDateTime;
var
	q: String;
begin
  result := 0;

  if not ping then exit;

  q := 'SELECT finish from cntest where contestId=' + intToStr(contestId);

  if not db_query(q) then exit;

  rowbuf := mysql_fetch_row(recbuf);
  if rowbuf = nil then
    result := 0
  else
    result := StrToDateTimeS(rowbuf[0]);

  mysql_free_result(recbuf);
end;

function db_get_contest_length(contestId: Integer): TDateTime;
begin
  result := db_get_finish_time(contestId) - getContestStartTime(contestId)
end;

function db_get_froze_time_sec(contestId: Integer): Integer;
var
	q: String;
begin
  result := 0;

  if not ping then exit;

  q := 'SELECT frozetime from cntest where contestId=' + intToStr(contestId);

  if not db_query(q) then exit;

  rowbuf := mysql_fetch_row(recbuf);
  if rowbuf = nil then
    result := 0
  else
    result := StrToIntDef(rowbuf[0], 0);

  mysql_free_result(recbuf);
end;

function db_get_allow_froze(contestId: Integer): Boolean;
var
	q: String;
begin
  result := false;

  if not ping then exit;

  q := 'SELECT isneedfreeze from cntest where contestId=' + intToStr(contestId);

  if not db_query(q) then exit;

  rowbuf := mysql_fetch_row(recbuf);
  if rowbuf = nil then
    result := false
  else
    result := StrToIntDef(rowbuf[0], 0) = 1;

  mysql_free_result(recbuf);
end;

initialization
begin
  curuser.id := -1;
  taskcount  := 0;
  submitcount  := 0;
end;


end.
