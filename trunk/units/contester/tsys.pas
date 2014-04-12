{$I defines.inc}
unit tsys;

interface
	uses runlib, sysutils, ttypes, ttimes, CP, tConfig, tCallBack;

 //result _FL - всё плохо или резалт теста
	function TestTest(const WorkDir, AppName: string; DosFlag: Boolean; const timeMul, memoryBound: Integer; const TaskInfo: TTaskInfo; Test: integer; var TestResult: TTestResult): integer;

 // результат задачи
 //       _OK - полное решение
 //       _WA - ниодного ОК
 //       _PC - частичное решение - хотябы один ОК
 //       _CE - compilation error
 //       _BR - кто-то что-то брейкнул
 //       _FL - что-то неладно

	function TestTask(const WorkDir, AppName: string; DosFlag: Boolean; const timeMul, memoryBound: Integer; const TaskInfo: TTaskInfo; var TaskResult: TTestResult): integer;

	function TestSubmit(var SubmitInfo: TSubmitInfo):integer;

implementation

	uses  tFiles, udb, tLog, tCompile;

	const
		CheckExeFile = '__check.exe';
		CheckResultFile = '__check.res';
		SolveExeFile = 'solve.exe';
		SolveSrcFile = 'solve.src';

	var
		WorkDir: string;
		_submit: integer;
		_submitinfo: PSubmitInfo;


function TestTest(const WorkDir, AppName: string; DosFlag: Boolean; const timeMul, memoryBound: Integer; const TaskInfo: TTaskInfo; Test: integer; var TestResult: TTestResult): integer;
	Var Res, Res2 : integer;
		resc: integer;
		desc, comm: string;
		wd, tmp: string;
    function AnalyseCheckOut: boolean;
		var tx: text;
			tmp, p, v: string;
			i,j: integer;
		begin
			Result := false;
			assign(tx, WorkDir + CheckResultFile);
			desc := '';
			comm := '';
      resc := 999;
			reset(tx);
			while not seekeof(tx) do begin
				readln(tx, tmp);
				i := pos('=', tmp);
	   			if i <> 0 then begin
					p := trim(copy(tmp, 1, i - 1));
					v := trim(copy(tmp, i + 1, maxint));
					if (p = '.Testlib Result Number') or (p = '.Result Number') then begin
						val(v, i, j);
						if j <> 0 then begin
							close(tx);
							exit;
						end;
						resc := i;
					end;
					if (p = '.Result name (optional)') or (p = '.Result Description') then desc := v;
					if (p = '.Check Comments') or (p = '.Check Comments') then comm := v;
				end else begin
          result:=true;desc:='';comm:='';
					close(tx);
					exit;
				end;
			end;
			desc := ConvertStr(cpWin, cpDef, desc);
			comm := ConvertStr(cpWin, cpDef, comm);
			Result := true;
			close(tx);
		end;

  var
    inp, outp:  String;
    cmdLine:    String;
    f:          TextFile;
    TotalTime,
    TotalMem:   Integer;
    checkerName:String;
    javaCheck:Boolean;
    cmd:String;
	begin
		wd := WorkDir;
		Result := _NO;
		TestResult.Result := _NO;
		TestResult.Point := 0;
		TestResult.msg := '';

    if TaskInfo.input = '' then
      inp := cStdInput
    else
      inp := TaskInfo.Input;
    if TaskInfo.output = '' then
      outp := cStdOutput
    else
      outp := TaskInfo.Output;

		//Download input files
		if not GetTestFiles(TaskInfo.id, test, 'Input.txt', Inp, wd) then begin
			TestResult.Result := _FL;
			TestResult.msg := 'can not download input file[s]';
			Result := _FL;
			exit;
		end;

		//Delete old output files
		if not DelFileList(wd, Outp) then begin
			TestResult.Result := _FL;
			TestResult.msg := 'can not delete old output file[s]';
			Result := _FL;
			exit;
		end;

		//execute solution
    if (TaskInfo.input='')or(TaskInfo.output='') then
   		Res := RunAppLim(WorkDir, AppName,
                       True,
                       DosFlag,
                       TaskInfo.TimeLimit*timeMul div 100,  // умножаем на коэффициент
                       TaskInfo.MemoryLimit + memoryBound,  // прибавляем "лишнюю" память
                       TotalTime, TotalMem)
    else
   		Res := RunAppLim(WorkDir, AppName,
                       False,
                       DosFlag,
                       TaskInfo.TimeLimit*timeMul div 100,
                       TaskInfo.MemoryLimit + memoryBound,
                       TotalTime, TotalMem);

    //копируем результаты работы в TestResult
    TestResult.time := TotalTime;
    TestResult.mem  := TotalMem - memoryBound; // вычитаем "лишнюю" память

		if Res = _DL Then
			TestResult.msg := 'deadlock';

		if Res = _TL Then
			TestResult.msg := 'time limit';

		if Res = _ML Then
			TestResult.msg := 'memory limit';

		if Res = _BR Then
			TestResult.msg := 'breaked';

		if Res = _FL Then
			TestResult.msg := 'failure';

		if Res = _RE Then
			TestResult.msg := 'runtime error';

		if Res = _NO then begin
			//Download Checker
      checkerName := CheckExeFile;
			tmp := wd + checkerName;
      javaCheck := false;
			if not GetApp(TaskInfo.id, IntToStr(TaskInfo.ID)+'.exe', tmp) then begin
        checkerName := 'Check.jar';
        tmp := wd + checkerName;
        javaCheck := true;
        if not GetApp(TaskInfo.id, checkerName, tmp) then begin
				  Result := _FL;
				  TestResult.Result := _FL;
				  TestResult.msg := 'cant download checker';
				  exit;
        end;
			end;

 			//Download input files
			if not GetTestFiles(TaskInfo.id, test, 'Input.txt', Inp, wd) then begin
				TestResult.Result := _FL;
				TestResult.msg := 'cant download input file[s]';
				Result := _FL;
				exit;
			end;

			//Download answer files
			if not GetTestFiles(TaskInfo.id, test, 'rans.txt', 'rans.txt', wd) then begin
				Result := _FL;
				TestResult.Result := _FL;
				TestResult.msg := 'cant download answer file[s]';
				exit;
			end;

//			GetTestFiles(TaskInfo.id, test, TaskInfo.Ans, wd);


      if javaCheck then begin
        cmd := 'java -Xmx256M -Xss64M -jar Check.jar ' + Inp + ' ' + Outp + ' rans.txt';
      end else begin
        cmd := WorkDir + checkerName + ' ' +
							Inp + ' ' +
							Outp + ' ' +
							'rans.txt' //+ ' ' +
							//CheckResultFile
              ;
      end;
			Res2 := RunApp(WorkDir,
							cmd,
              False,
              False,
							CB_RUN_TYPE_CHECKER);

			if Res2 = _FL then begin
				Result := _FL;
				TestResult.Result := _FL;
				TestResult.msg := 'cant execute checker';
				exit;
			end;
      if Res2 = _RE then begin
				Result := _FL;
				TestResult.Result := _FL;
				TestResult.msg := 'checker fails';
				exit;
      end;

			Res := ExitCode;
			if ResultToStr(res) = '??' then begin
				Result := _FL;
				TestResult.Result := _FL;
				TestResult.msg := 'invalid checker exit code';
				exit;
			end;
			if not ({FileExists(WorkDir + CheckResultFile) and }(res in [_OK, _WA, _PE]){ and AnalyseCheckOut}) then
				fatal('Testlib compatible checker? I think not.')
      else if (res in [_WA, _PE]) then begin
        TestResult.msg := 'res in [_WA, _PE]';
        ;//
			end else if resc = 999 then begin
        TestResult.msg := 'resc==999';
        res := _OK;
      end else begin
				TestResult.msg := desc + ', ' + comm;
				res := resc;
			end;
		end;
		Result := res;
		TestResult.Result := res;
		if (res = _OK) or ((res >= _PC) and (res <= _PC4)) then TestResult.Point := TaskInfo.Point[test];
	end;

function TestTask(const WorkDir, AppName: string; DosFlag: Boolean; const timeMul, memoryBound: Integer; const TaskInfo: TTaskInfo; var TaskResult: TTestResult): integer;
	var     i: integer;
		res: integer;
		isObligate: boolean;
		ObligateCount: integer;
		ec: integer;
		TestResult: TTestResult;
		brcount: integer;
		flcount: integer;
		msg: string;
		rs : string;
		AllTest: TAllTestResult;
	begin
		Result := _NO;
		isObligate := false;
		ObligateCount := 0;
		TaskResult.point := 0;
		TaskResult.Result := _NO;
		TaskResult.msg := '';
		msg := '';
                TaskResult.inf := 0;

		brcount := 0;
   		flcount := 0;

   		ec := AllCB(CB_TEST_INIT, _submit, integer(@TaskInfo), integer(_submitinfo));

   		if ec = _BR then begin
    		    Result := _BR;
    		    TaskResult.Result := _BR;
    		    TaskResult.msg := 'BR';
    		    for i := 1 to TaskInfo.TestCount do begin
     			AllTest[i].point := 0;
     			AllTest[i].result := _BR;
     			AllTest[i].msg := '';
    		    end;
    		    AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), integer(@AllTest));
    		    exit;
   		end;

   		for i := 1 to TaskInfo.TestCount do begin
        ec := AllCB(CB_TEST_START, _submit, i, integer(PChar(AppName)));

    		TestResult.msg    := '';
    		TestResult.Point  := 0;
        TestResult.time   := 0;
        TestResult.mem    := 0;

    		if ec = _BR then begin
     			TestResult.result := _BR;
     			TestResult.msg := 'skipped';
     			AllCB(CB_TEST_RESULT, _submit, i, integer(@TestResult));
     			inc(brcount);
     			AllTest[i] := TestResult;
          break;
 		    end;

 		    if TaskInfo.flag[i] = 1 then
     			isObligate := true;

   		  Res := TestTest(WorkDir, AppName, DosFlag, timeMul, memoryBound, TaskInfo, i, TestResult);

        //в TaskResult копируются память и время последнего теста
        TaskResult.time := TestResult.time;
        TaskResult.mem  := TestResult.mem;

        TestResult.result := (TestResult.result mod 100) + i*100;
  		  rs := ResultToStr(TestResult.result);
        if Res=_OK then begin
          inc(TaskResult.inf);
          msg := rs;
        end
        else begin
          msg := rs;
          break;
        end;

  		  AllCB(CB_TEST_RESULT, _submit, i, integer(@TestResult));

  		  AllTest[i] := TestResult;

   		  inc(TaskResult.point, TestResult.point);
      end;

   		TaskResult.msg := msg;
   		if flcount <> 0 then begin
    		    Result := _FL + (TaskResult.inf+1)*100;
    		    TaskResult.Result := _FL + (TaskResult.inf+1)*100;
    		    AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), integer(@AllTest));
    		    exit;
   		end;

   		if brcount <> 0 then begin
    		    Result := _BR + (TaskResult.inf+1)*100;
    		    TaskResult.Result := _BR + (TaskResult.inf+1)*100;
    		    AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), integer(@AllTest));
    		    exit;
   		end;

   		if TaskResult.inf = taskInfo.testcount then begin
    		    Result := _OK;
    		    TaskResult.Result := _OK;
    		    AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), integer(@AllTest));
    		    exit;
   		end;

{   		if TaskResult.inf = 0 then begin
    		    Result := _WA;
    		    TaskResult.Result := _WA;
    		    AllCB(CB_TEST_DONE, Int(@TaskResult), Int(@TaskInfo), Int(@AllTest));
    		    exit;
   		end;}

   		begin
    		    Result := TestResult.result;
    		    TaskResult.Result := Result;
    		    AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), integer(@AllTest));
    		    exit;
   		end;
   		AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), integer(@AllTest));
  	end;

function TestSubmit(var SubmitInfo: TSubmitInfo):integer;
  	var TaskInfo: TTaskInfo;
      	fname: string;
      	ec: integer;
      	TaskResult: TTestResult;
      	TmpDir: String;
        TaskID: Integer;
        f: TextFile;
        i, j: integer;
        fileName: String;
        line: String;
  	begin
   		SubmitInfo.result.Result := _NO;
   		Result := _NO;
   		SubmitInfo.result.point := 0;
   		SubmitInfo.result.inf := 0;
   		SubmitInfo.result.msg := '';

      TaskID := GetTaskID(SubmitInfo);
   		if not GetInfo(dbTask, TaskID, TaskInfo) then begin
    		fatal('Task ' + IntToStr(TaskID) + ' not found');
    		SubmitInfo.result.Result := _FL;
    		Result := _FL;
    		SubmitInfo.result.msg := 'cant get TaskInfo';
    		exit;
   		end;

   		TmpDir := CreateTempDir(WorkDir);

                fname := TmpDir + SolveSrcFile;
   		if not GetSolve(SubmitInfo.ID, fname) then begin
    		SubmitInfo.result.Result := _FL;
    		Result := _FL;
    		SubmitInfo.result.msg := 'cant download solution';
    		exit;
   		end;

      if (SubmitInfo.bat = 'java.bat') then begin
        assignFile( f, tmpDir + solveSrcFile ); reset( f );
        while not eof( f ) do begin
          readln( f, line );
          i := pos( 'class', line );
          if (i > 0) then begin
            i := i + 6;
            j := i;
            fileName := '';
            while (j < length( line )+1) and (line[j] <> ' ') and (line[j] <> '{') do
              inc( j );
            fileName := copy( line, i, j-i );
   		      ec := CompileApp(TmpDir, SolveSrcFile, TmpDir, fileName + '.java', fileName + '.class', SubmitInfo.bat);
            break;
          end;
        end;
        closeFile( f );
      end else
   		  ec := CompileApp(TmpDir, SolveSrcFile, TmpDir, SolveExeFile, SolveExeFile, SubmitInfo.bat);

   		if ec <> _OK then begin
    		    Result := ec;
    		    SubmitInfo.result.msg := ResultToStr(ec);
//    		    SubmitInfo.ttime := now;
    		    SubmitInfo.result.Result := ec;

            SubmitInfo.result.time := 0;
            SubmitInfo.result.mem  := 0;

    		    TaskResult.result := ec;
    		    TaskResult.msg := SubmitInfo.result.msg;
    		    TaskResult.point := 0;
    		    TaskResult.inf := 0;

    		    AllCB(CB_TEST_INIT, SubmitInfo.id, integer(@TaskInfo), integer(@SubmitInfo));
    		    AllCB(CB_TEST_DONE, integer(@TaskResult), integer(@TaskInfo), 0);
    		    DelDirForce(TmpDir);
    		    exit;
   		end;

   		_submit := SubmitInfo.id;
   		_submitinfo := @SubmitInfo;
      if (SubmitInfo.bat = 'java.bat') then
     		ec := TestTask(TmpDir, 'java -cp . -Xmx512M -Xss128M -DONLINE_JUDGE=true -Duser.language=en -Duser.region=US -Duser.variant=US ' + fileName, SubmitInfo.DOS, SubmitInfo.TimeMul, SubmitInfo.MemoryBuf, TaskInfo, TaskResult)
      else
     		ec := TestTask(TmpDir, TmpDir + SolveExeFile, SubmitInfo.DOS, SubmitInfo.TimeMul, SubmitInfo.MemoryBuf, TaskInfo, TaskResult);
   		_submit := -1;
   		_submitinfo := nil;

   		SubmitInfo.result := TaskResult;
//   		SubmitInfo.ttime := now;

   		Result := TaskResult.Result;

   		//delete all temporary files
   		DelDirForce(TmpDir);
  	end;

begin
 	_submit := -1;
 	_submitinfo := nil;
 	WorkDir := MainConfig.Readstring('tsys', 'workdir', '');
 	NormDir(WorkDir);
end.
