{$I defines.inc}
unit ttypes;

interface

uses tTimes, SysUtils;

type
  	TRequest = (rqClient, rqTester, rqWaiter, rqAdmin);

const
//Под этим именем в записи хранится решение
  	dbSolveFile = 'solve.src';

//файлы для стандартных потоков
  cStdInput = 'in718456.txt';
  cStdOutput = 'ou718456.txt';

//Идентификаторы таблиц
  	dbSubmit  = 0;
  	dbTask    = 1;
	dbUser    = 2;

  	InvalidID = -1;   //Неправильный идентификатор

//Старые
	_OK     = 0;    // OK
	_WA     = 1;    // Wrong Answer - Неправильный ответ
	_PE     = 2;    // Ошибка формата вывода
	_TL     = 3;    // Time Limit - превышение ограничения по времени
	_RE     = 4;    // Runtime Error - ошибка времени исполнения
	_FL     = 5;    // Failure - когда всё плохо

	_PC0    = 6;    //
	_PC     = _PC0; //
	_PC1    = 7;    //    частично верно
	_PC2    = 8;    //
	_PC3    = 9;    //
	_PC4    = 10;   //
//	_PCMAX  = _PC4;

	_ML     = 20;   // Memory Limit - превышение лимита по памяти
	_CE     = 21;   // Compilation Error - ошибка компиляции
	_BR     = 22;   // Break - В работу вмешался оператор
	_DL     = 23;   // Dead lock - если процесс ничего не делает, a чего-то очень долго ждёт

	_NO     = 33;   // Ничего :)

//	PCount = _PCMAX - _PC + 1;

//Lo(TSubmitInfo.Status) - not implemented (waiter?)
	SUBMIT_WAIT = 0; //не тестируется и не протестирована
	SUBMIT_TEST = 1; //тестируется
	SUBMIT_DONE = 2; //протестирована
	SUBMIT_SEND = 3; //результат уже у отправителя
	SUBMIT_FROZEN = 4; //заморожена, автоматическому тестированию не подлежит
//Hi(TSubmitInfo.Status) = tester

	ltRead = 0;
	ltWrite = 1;

	slash = '\';

	MAXTEST = 500;

TYPE
	PTaskInfo = ^TTaskInfo;
	TTaskInfo = record
                    ID      : integer;    //Уникальный номер задачи в БД
                    Name    : String;     //Название задачи
                    Author  : String;     //Автор(ы) задачи
                    TimeLimit: integer;   //Ограничение по времени
                    MemoryLimit: integer; //Органичение по памяти
                    TestCount: integer;   //Количество тестов
                    Input   : string;     //Имена входных файлов, отделенные запятыми
                    Output  : string;     //Имена выходных файлов, отделенные запятыми
                    point   : array [1..maxtest] of integer; //очки на все тесты
                    flag    : array [1..maxtest] of integer; //hz
	end;

//Результат теста задачи
	PTestResult = ^TTestResult;
	TTestResult = record
                      result: integer; //Результат
                      point : integer; //Балл
                      msg   : String;  //Описание результата
                      inf   : integer; //ok count
                      time  : integer; //время работы в ms
                      mem   : integer; //память в KB
	end;

//Результат всех тестов задачи
	PAllTestResult = ^TAllTestResult;
	TAllTestResult = array [1..maxtest] of TTestResult;

// polia s ID po starus pishutsia SetSubmitInfo
// polia s status po result pishutsia SetSubmitResult
	PSubmitInfo = ^TSubmitInfo;
	TSubmitInfo = record
                      isTaskSolved: boolean; //решена ли задача к настоящему моменту
                      successfulAttemptNum: Integer; //номер успешной попытки
                      ID    : integer;     //ID посылки
                      user  : integer;     //ID пославшего
                      problem: String;
                      contest: Integer;
                      stry  : integer;     //Попытка
                      stime : TDateTime;   //дата-время посылки
//                      lng   : String;      //язык = компилятор
                      DOS:    Boolean;
                      bat:    String;
                      TimeMul: Integer;
                      MemoryBuf: Integer;
                      {-}
                      status: integer;     //статус посылки
                                             //см костанты SUBMIT_XXXX
                      {-}
                      result: TTestResult; //результат тестирования
                      testingId: Integer; // ID тестирования
//  	                rtest   : TAllTestResult;//результат по тестам
	end;

	TUserInfo = record
                    id      : integer;
                    name    : String;
                    login   : String;
                    password: String;
	end;

    TTaskResults = array of array of Integer;
    TTeams = array of string;

	Function ResultToStr(cResult: integer): string;

implementation

Function ResultToStr(cResult: integer): string;
 	begin
  		Case cResult mod 100 of
   			_OK: Result := 'OK';
//   			_PC: Result := 'PC';
//  			_PC1.._PC4: Result := 'PC';
//   			_PC1.._PCMAX: Result := 'PC' + Chr(Ord(cResult) - Ord(_PC1) + Ord('1'));
   			_WA: begin Result := 'Неправильный ответ на тесте ' + IntToStr(cResult div 100); end;
   			_RE: begin Result := 'Ошибка времени выполнения на тесте ' + IntToStr(cResult div 100); end;
   			_TL: begin Result := 'Превышение ограничения по времени на тесте ' + IntToStr(cResult div 100); end;
   			_ML: begin Result := 'Превышение ограничения по памяти на тесте ' + IntToStr(cResult div 100); end;
   			_DL: begin Result := 'Программа находится в режиме ожидания на тесте ' + IntToStr(cResult div 100); end;
   			_CE: Result := 'Ошибка компиляции';
   			_PE: begin Result := 'Ошибка формата вывода на тесте ' + IntToStr(cResult div 100); end;
   			_FL: Result := 'Failure';
   			_BR: Result := 'В работу вмешался оператор';
   			_NO: Result := 'Ничего :)';
  		else Result := '??'; end;
 	end;

end.
