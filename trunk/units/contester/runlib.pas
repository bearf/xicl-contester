{$I defines.inc}

unit RunLib;

interface
    Uses SysUtils, Windows, tTypes, tCallBack, psAPI;

//var
    Function RunApp(WorkDir, AppName: String;
                    StdFlag,
                    DosFlag: Boolean;
                    AppType: integer) : integer;
    Function RunAppLim(WorkDir, AppName: String;
                       StdFlag,
                       DosFlag: Boolean;
                       TimeLimit, MemoryLimit: integer;
                       var _TotalTime, _TotalMem: integer): integer;
    Function ExitCode: integer;

implementation

uses tLog;

type
    TRunAppFunc = function(WorkDir, AppName: String;
                           StdFlag,
                           DosFlag: Boolean;
                           AppType: integer) : integer;

const Wait_Interval = 33;
      DL_Count = 30;
      BUF_SIZE      = 4096;

var
    RunAppFunc: TRunAppFunc;
    Term: boolean;
    FExitCode: Cardinal;
    _LimTime, _LimMem: integer;

    //используются для возвращения данных
    //из RunAppNT в RunAppLim 
    __TotalTime, __TotalMem: Integer;

// Функция возвращает значение переменной FExitCode
Function ExitCode: integer;
	begin
		ExitCode := FExitCode;
	end;

// Функция, используемая для обработки сигналов завершения приложения
// Переменной Term присваивает значение True
Function SignalHandler(Signal: longword):BOOL;
	begin
		Term := True;
		SignalHandler := True;
	end;

// Если Term = True, тогда возвращает _BR,
// иначе возвращает _NO
Function BRCB (Msg, ID, iTime, iMem: integer):integer;
	begin
		BRCB := _NO;
		if Term then begin
			Term := False;
			BRCB := _BR;
		end;
	end;

// Запускает приложение без ограничения на время выполнения
// и на используемую память
Function RunApp(WorkDir, AppName: String;
                StdFlag,
                DosFlag: Boolean;
                AppType: integer) : integer;
	begin
		RegCB(@BRCB);
		RunApp := RunAppFunc(WorkDir, AppName,
                         StdFlag,
                         DosFlag,
                         AppType);
		UnregCB(@BRCB);
	end;

// 1. Если превышен лимит времени, то возвращает _TL
// 2. Если превышен лимит памяти, то возвращает _ML
// 3. Если Term = True, то возвращает _BR
// 4. Возвращает _NO
Function LimCB (Msg, ID, iTime, iMem: integer):integer;
	begin
		LimCB := _NO;
		if Term then begin
			LimCB := _BR;
			Term := False;
		end;
		if (_LimMem > 0) and (iMem > _LimMem) Then LimCB := _ML;
		if (_LimTime > 0) and (iTime > _LimTime) Then LimCB := _TL;
	end;

// Запускает приложение с ограничениями на время выполнения
// и на используемую память
Function RunAppLim(WorkDir, AppName: String;
                   StdFlag,
                   DosFlag: Boolean;
                   TimeLimit, MemoryLimit: integer;
                   var _TotalTime, _TotalMem: integer): integer;
	begin
		_LimTime := TimeLimit;
		_LimMem := MemoryLimit;
		RegCB(@LimCB);
		RunAppLim := RunAppFunc(WorkDir, AppName,
                            StdFlag,
                            DosFlag,
                            CB_RUN_TYPE_SOLUTION);
		UnregCB(@LimCB);

    _TotalTime := __TotalTime;
    _TotalMem  := __TotalMem;
	end;

// Запускает приложение
Function RunAppNT(WorkDir, AppName: String; StdFlag, DosFlag: Boolean; AppType: integer) : integer;

{  procedure Redirect;
  var
    hChildStdinRd, hChildStdinWr, hChildStdinWrDup,
    hChildStdoutRd, hChildStdoutWr, hChildStdoutRdDup,
    hInputFile, hSaveStdin, hSaveStdout:  HANDLE;
  begin
//#define BUFSIZE 4096


BOOL CreateChildProcess(VOID);
VOID WriteToPipe(VOID);
VOID ReadFromPipe(VOID);
VOID ErrorExit(LPTSTR);
VOID ErrMsg(LPTSTR, BOOL);

DWORD main(int argc, char *argv[])
{
   SECURITY_ATTRIBUTES saAttr;
   BOOL fSuccess;

// Set the bInheritHandle flag so pipe handles are inherited.


   saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
   saAttr.bInheritHandle = TRUE;
   saAttr.lpSecurityDescriptor = NULL;

   // The steps for redirecting child process's STDOUT:
   //     1. Save current STDOUT, to be restored later.
   //     2. Create anonymous pipe to be STDOUT for child process.
   //     3. Set STDOUT of the parent process to be write handle of
   //        the pipe, so it is inherited by the child process.
   //     4. Create a noninheritable duplicate of the read handle and

   //        close the inheritable read handle. 
 
// Save the handle to the current STDOUT. 
 
   hSaveStdout = GetStdHandle(STD_OUTPUT_HANDLE);
 
// Create a pipe for the child process's STDOUT. 
 
   if (! CreatePipe(&hChildStdoutRd, &hChildStdoutWr, &saAttr, 0)) 
      ErrorExit("Stdout pipe creation failed\n"); 
 
// Set a write handle to the pipe to be STDOUT. 
 
   if (! SetStdHandle(STD_OUTPUT_HANDLE, hChildStdoutWr)) 
      ErrorExit("Redirecting STDOUT failed"); 


// Create noninheritable read handle and close the inheritable read 
// handle. 

    fSuccess = DuplicateHandle(GetCurrentProcess(), hChildStdoutRd,
        GetCurrentProcess(), &hChildStdoutRdDup , 0,
        FALSE,
        DUPLICATE_SAME_ACCESS);
    if( !fSuccess )
        ErrorExit("DuplicateHandle failed");
    CloseHandle(hChildStdoutRd);

   // The steps for redirecting child process's STDIN: 
   //     1.  Save current STDIN, to be restored later. 

   //     2.  Create anonymous pipe to be STDIN for child process. 
   //     3.  Set STDIN of the parent to be the read handle of the 
   //         pipe, so it is inherited by the child process. 
   //     4.  Create a noninheritable duplicate of the write handle, 
   //         and close the inheritable write handle. 
 
// Save the handle to the current STDIN. 
 
   hSaveStdin = GetStdHandle(STD_INPUT_HANDLE); 
 
// Create a pipe for the child process's STDIN.

 
   if (! CreatePipe(&hChildStdinRd, &hChildStdinWr, &saAttr, 0)) 
      ErrorExit("Stdin pipe creation failed\n"); 
 
// Set a read handle to the pipe to be STDIN. 
 
   if (! SetStdHandle(STD_INPUT_HANDLE, hChildStdinRd))
      ErrorExit("Redirecting Stdin failed"); 
 
// Duplicate the write handle to the pipe so it is not inherited. 
 
   fSuccess = DuplicateHandle(GetCurrentProcess(), hChildStdinWr, 
      GetCurrentProcess(), &hChildStdinWrDup, 0, 
      FALSE,                  // not inherited 

      DUPLICATE_SAME_ACCESS); 
   if (! fSuccess) 
      ErrorExit("DuplicateHandle failed"); 
 
   CloseHandle(hChildStdinWr); 
 
// Now create the child process. 
 
   if (! CreateChildProcess())
      ErrorExit("Create process failed"); 
 
// After process creation, restore the saved STDIN and STDOUT. 
 
   if (! SetStdHandle(STD_INPUT_HANDLE, hSaveStdin)) 
      ErrorExit("Re-redirecting Stdin failed\n"); 
 
   if (! SetStdHandle(STD_OUTPUT_HANDLE, hSaveStdout))

      ErrorExit("Re-redirecting Stdout failed\n"); 
 
// Get a handle to the parent's input file. 
 
   if (argc > 1)
      hInputFile = CreateFile(argv[1], GENERIC_READ, 0, NULL, 
         OPEN_EXISTING, FILE_ATTRIBUTE_READONLY, NULL); 
   else 
      hInputFile = hSaveStdin; 
 
   if (hInputFile == INVALID_HANDLE_VALUE) 
      ErrorExit("no input file\n"); 
 
// Write to pipe that is the standard input for a child process. 
 
   WriteToPipe();

// Read from pipe that is the standard output for child process.


   ReadFromPipe();

   return 0;
} { end;}


	Var
		SI: TStartupInfo;
		PI: TProcessInformation;
		Wt, exCode: Cardinal;
		StartTime, ExitTime, KernelTime, UserTime: TFileTime;
		Er: BOOL;
		App: string;
		MC: PROCESS_MEMORY_COUNTERS;
		rs: integer;
		mem: longword;
		wd: string;
		wdp: pchar;
		flag: integer;
		Tick, PrTick: longword;
		TotalTime, TotalMem: integer;
		AllTime, PrAllTime: longword;
		PrTotalTime, PrTotalMem: integer;
		Counter: integer;
                err: string;

    Bool, Done, Bug: Boolean;
    debug: _DEBUG_EVENT;

    hInputFile, hOutputFile:  Cardinal;
    PA:                       TSecurityAttributes;
	Begin
		RunAppNT := _NO;

    __TotalTime  := 0;
    __TotalMem   := 0;

    App := AppName;

    if DosFlag and StdFlag then begin
      App := App + ' ' +
             '<' + WorkDir + cStdInput + ' ' +
             '>' + WorkDir + cStdOutput + ' ';
    end;

		rs := AllCB(CB_RUN_INIT, AppType, integer(PChar(App)), 0);
		if rs = _BR then begin Result := _BR; Exit; end;

		wd := WorkDir;
		if WorkDir = '' then wdp := nil else wdp := PChar(wd);

        // Устанавливаем параметры запуска приложения:
        // скрыть окно запускаемого приложения

    if StdFlag then begin
      PA.nLength := sizeof(SECURITY_ATTRIBUTES);
      PA.bInheritHandle := TRUE;
      PA.lpSecurityDescriptor := nil;

      hInputFile  := CreateFile(PAnsiChar(wd+cStdInput), GENERIC_READ, 0, @PA,
                                OPEN_EXISTING, FILE_ATTRIBUTE_READONLY, 0);
      hOutputFile := CreateFile(PAnsiChar(wd+cStdOutput), GENERIC_WRITE, 0, @PA,
                                CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
    end;

  	FillChar(SI, SizeOf(SI), 0);
		With Si do Begin
			if (AppType <> CB_RUN_TYPE_NONE) and (AppType <> CB_RUN_TYPE_SHOW) then begin
				dwFlags := STARTF_USESHOWWINDOW;
				wShowWindow := SW_HIDE;
			end;

      if StdFlag then begin
        dwFlags     := dwFlags or STARTF_USESTDHANDLES;
        hStdInput   := hInputFile;
        hStdOutput  := hOutputFile
      end;

			cb := SizeOf(SI);
		End;

        // Отключаем вывод ошибок
		SetErrorMode(SEM_FAILCRITICALERRORS or
						SEM_NOGPFAULTERRORBOX or
						SEM_NOALIGNMENTFAULTEXCEPT or
						SEM_NOOPENFILEERRORBOX);

    Flag := 0;

    //нужно для игнорирования всплывающих Дельфовых окон
    //с сообщениями об ошибках
{    if AppType = CB_RUN_TYPE_SOLUTION then
		  Flag := Flag or DEBUG_PROCESS;}

		if AppType <> CB_RUN_TYPE_NONE then
      Flag := Flag or CREATE_NEW_CONSOLE; // Добавляем флаг: создать новую консоль для нового приложения

        // Создаем процесс (запускаем приложение)
		Er := CreateProcess(Nil, PChar(App), Nil, Nil, True,
							flag, Nil, wdp, SI, PI);
    err := SysErrorMessage(GetLastError());

		if Not Er Then Begin
			logger.error.print('cant execute ' + AppName);
            logger.error.print(err);
			RunAppNT := _FL;
			Exit;
		End;

    if StdFlag then begin
      CloseHandle(hInputFile);
      CloseHandle(hOutputFile)
    end;

		MC.cb := sizeof(MC);
		PrTotalTime := 0;
		PrTotalMem := 0;
		PrAllTime := 0;
		PrTick := GetTickCount;
		Counter := 0;

//    SetDebugErrorLevel(SLE_ERROR);

		Repeat
			Inc(Counter);

{      if (AppType = CB_RUN_TYPE_SOLUTION) then begin
        if (Counter > 1) then
          ContinueDebugEvent(debug.dwProcessId, debug.dwThreadId, DBG_CONTINUE);
        Bool  := WaitForDebugEvent(debug, Wait_Interval);
        Done  := debug.dwDebugEventCode = EXIT_PROCESS_DEBUG_EVENT;
        Bug   := debug.dwDebugEventCode = EXCEPTION_DEBUG_EVENT
      end
      else}
        Wt := WaitForSingleObject(PI.hProcess, Wait_Interval);

      // Получаем информацию о времени выполнения приложения
			GetProcessTimes(Pi.hProcess, StartTime, ExitTime, KernelTime, UserTime);
			TotalTime := Int64(UserTime) div 10000;
			AllTime := TotalTime + (Int64(KernelTime) div 10000);

      // Получаем информацию о количестве памяти, потребляемой приложением
			GetProcessMemoryInfo(Pi.hProcess, @MC, sizeof(MC));
			mem := MC.PeakPagefileUsage;               //И3врат конечно, но если
			{if mem < MC.PeakWorkingSetSize then        //процесс откушавет больше
				mem := MC.PeakWorkingSetSize;}          //памяти, чем система может ему
			TotalMem := mem div 1024;                  //дать физической, начинаются проблемы
			                                           //WorkingSize уменьшается, а PageFileUsage
			                                           //наоборот сильно растёт - всё в свап

      // Проверяем ограничения
			rs := AllCB(CB_RUN_INFO, AppType, TotalTime, TotalMem);

			if (AppType = CB_RUN_TYPE_SOLUTION) and (rs = _NO) AND (Counter = dl_count) then begin
				Tick := GetTickCount;
				if (Tick - PrTick) > 100 * (AllTime - PrAllTime)  then
					rs := _DL; //немножко туповатая защита от Тормозов :)
					           //если процесс в течении wait_interval*dl_count мс
					           //скушал процессора меньше 1% то считается, что он
					           //работать не собирается, и поэтому _DL
					           //это произойдёт если он чего-то ждёт, например
					           //ввода с клавиатуры....

                PrTotalTime := TotalTime;
				PrAllTime := AllTime;
				PrTotalMem := TotalMem;
				PrTick := Tick;
				Counter := 0;
			end
		Until {((AppType <> CB_RUN_TYPE_SOLUTION) and (Wt = WAIT_OBJECT_0)) or
          ((AppType = CB_RUN_TYPE_SOLUTION) and (Done))
          or (rs <> _NO);}

          (Wt = WAIT_OBJECT_0) or (rs <> _NO);

    __TotalTime  := TotalTime;
    __TotalMem   := TotalMem;

    // Если приложение не завршило работу, то его надо убить
		if {((AppType = CB_RUN_TYPE_SOLUTION) and Bug)
       or (rs <> _NO)}
      (rs <> _NO) then
			TerminateProcess(PI.hProcess, 0);

    // Получить код завершения приложения
		AllCB(CB_RUN_DONE, AppType, TotalTime, TotalMem);

		if rs <> _NO then begin
			RunAppNT := rs;
			Exit;
    end;

		Er := GetExitCodeProcess(PI.hProcess, exCode);

		FExitCode := exCode;

		if Not Er Then Begin
			logger.error.print('cant get exitcode');
			RunAppNT := _FL;
			Exit;
		End;

		if {((AppType = CB_RUN_TYPE_SOLUTION) and Bug) or
       (exCode <> 0)}

       (AppType <> CB_RUN_TYPE_CHECKER) and (exCode <> 0) Then Begin
			RunAppNT := _RE;
			Exit;
		End;

	End;

initialization

	Term := False;
	FExitCode := 0;

	// Установка функции SignalHandler в качестве функции, обрабатывающей такие сигналы,
	// как ctrl+c, ctrl+break
	SetConsoleCtrlHandler(@SignalHandler, True);
	RunAppFunc := @RunAppNT;

finalization

end.
