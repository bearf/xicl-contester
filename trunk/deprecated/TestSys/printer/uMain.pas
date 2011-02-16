unit uMain;

interface

uses
  Menus, ExtCtrls, Classes, Controls, StdCtrls,
  Windows, Messages, SysUtils, Variants, Graphics, Forms,
  Dialogs, Shellapi, Buttons, ComCtrls, 
  DateUtils, AppEvnts,
  uMySQLWrapper,
  uPrintThread,
  uPrintJob,
  uLogger,
  uPrintThreadUserInterface;

const

  // размер очереди
  _queueSize = 1000;

type
  TfrMain = class(TForm, IPrintThreadMaster)
    mySQLTimer: TTimer;
    mainMenu: TMainMenu;
    itmPrint: TMenuItem;
    itmAwake: TMenuItem;
    itmPause: TMenuItem;
    N1: TMenuItem;
    itmExit: TMenuItem;
    meLog: TMemo;
    ApplicationEvents1: TApplicationEvents;
    procedure FormDestroy(Sender: TObject);
    procedure mySQLTimerTimer(Sender: TObject);
    procedure itmAwakeClick(Sender: TObject);
    procedure itmPauseClick(Sender: TObject);
    procedure itmExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

    // ** FIELDS ***

    fLogger: TLogger;

    fQueueBegins: Integer;

    fQueueEnds: Integer;

    fQueue: array[1.._queueSize] of TPrintJob;

    fPrintThread: TPrintThread;

    fPrintThreadState: TPrintThreadState;

    // *** METHODS ***

    // разбудить поток печати
    // устанавливает внутреннее поле состояния в значение ptsAwakening
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure awake;

    // усыпить поток печати
    // устанавливает внутреннее поле состояния в значение ptsAwakening
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure asleep;

    // завершить поток печати
    // устанавливает внутреннее поле состояния в значение ptsAwakening
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure terminate;

    // добавить задание печати в очередь
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure addPrintJob(printJob: TPrintJob);

    procedure initQueue;

    procedure destroyQueue;

    function isQueueFull: Boolean;

    procedure loadPrintJob;

    function initMySQL(host, user, password, database: String): Boolean;

    procedure doneMySQL;

  public

    // *** METHODS ***

    procedure TrayIcon(var Msg : TMsg); message WM_USER + 1;

    procedure execute(host, user, password, database: String);

    // подтвержить пробуждение потока печати
    // устанавливает внутреннее поле состояния в значение ptsWorking
    // Использование:
    //    * в методе callConfirmAwake в потоке печати
    procedure confirmAwake;

    // подтвержить засыпание потока печати
    // устанавливает внутреннее поле состояния в значение ptsSleeping
    // Использование:
    //    * в методе callConfirmAsleep в потоке печати
    procedure confirmAsleep;

    // подтвержить завершение потока печати
    // устанавливает внутреннее поле состояния в значение ptsTerminated
    // Использование:
    //    * в методе callConfirmTerminate в потоке печати
    procedure confirmTerminate;

    // подтвердить печать задания
    // параметры:
    //    printJob: задание, печать которого завершена
    //    result: результат печати
    // использование:
    //    * в методе callConfirmPrintJob в потоке печати
    procedure confirmPrintJob(printJob: TPrintJob; result: TPrintResult);

    // *** GETTERS ***

    // Получить состояние потока печати
    // Возвращаемое значение:
    //    состояние потока печати
    // Использование:
    //    * метод должен вызываться в методе callGetPrintThreadState
    function getPrintThreadState: TPrintThreadState;

    // Получить задание печати
    // Возвращает первое задание печати из очереди, если оно есть и удаляет его
    // из очереди
    // Возвращаемое значение:
    //    * задание печати, если очередь не пуста
    //    * null в противоположном случае
    // использование:
    //    * в методе callGetPrintJob в потоке печати
    function getPrintJob: TPrintJob;

    function hasPrintJob: Boolean;

    function isAwakening: Boolean;

    function isAsleeping: Boolean;

    function isTerminating: Boolean;

    function isTerminated: Boolean;

    function isSleeping: Boolean;

    function isWorking: Boolean;

  end;

var
  frMain: TfrMain;

implementation

{$R *.dfm}

uses
  mysql;

//var
  //pnid : TNotifyIconData; //Содержит информацию, которая неободима системе для обработки сообщений области панели задач

procedure TfrMain.addPrintJob(printJob: TPrintJob);
begin
  fQueue[fQueueEnds] := printJob;

  //todo: ошибки!!!
  inc(fQueueEnds);
  if fQueueEnds > _queueSize then
    fQueueEnds := 1
end;

procedure TfrMain.asleep;
begin
  mySQLTimer.Enabled := false;
  fPrintThreadState := ptsAsleeping;

  fLogger.log('останов печати');
end;

procedure TfrMain.awake;
begin
  fPrintThreadState := ptsAwakening;

  fLogger.log('запуск печати')
end;

procedure TfrMain.confirmAsleep;
begin
  fPrintThreadState := ptsSleeping;

  itmAwake.Enabled := true;

  fLogger.log('печать остановлена')
end;

procedure TfrMain.confirmAwake;
begin
  fPrintThreadState := ptsWorking;
  mySQLTimer.Enabled := true;

  itmPause.Enabled := true;

  fLogger.log('печать запущена')
end;

procedure TfrMain.confirmPrintJob(printJob: TPrintJob; result: TPrintResult);
var
  query: String;
  value: String;
  status: String;
begin
  case result of
    prSuccess: begin
      value := '3';
      status := 'выполнено'
    end;
    prFailed: begin
      value := '4';
      status := 'не удалось'
    end
  end;

  if result = prSuccess then
    fLogger.log('выполнено успешно: задание #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
  else
    fLogger.log('ОШИБКА при выполнении: задание #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

  fLogger.log('обновление статуса: задание #' +
    printJob.getPrintID +
    '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

  query := 'update print set isPrinted=' + value + ' where printId=' + printJob.getPrintID;

  if mySQLUpdate(query) then
    fLogger.log('статус {' + status + '}: задание #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
  else
    fLogger.log('ОШИБКА при обновлении статуса {' + status + '}: задание #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');
end;

procedure TfrMain.confirmTerminate;
begin
  fPrintThreadState := ptsTerminated;

  fLogger.log('печать закрыта');

  Application.Terminate
end;

procedure TfrMain.destroyQueue;
var
  p: Integer;
begin
  p := fQueueBegins;

  while p <> fQueueEnds do begin
    fQueue[p].Free;

    inc(p);
    if p > _queueSize then
      p := 1
  end
end;

function TfrMain.getPrintJob: TPrintJob;
begin
  result := fQueue[fQueueBegins];

  fLogger.log('извлечение из очереди: задание #' +
    result.getPrintID +
    '[' + result.getUserName + '/' + result.getTaskName + ']');

  inc(fQueueBegins);
  if fQueueBegins > _queueSize then
    fQueueBegins := 1;

  fLogger.log('печать: задание #' +
    result.getPrintID +
    '[' + result.getUserName + '/' + result.getTaskName + ']')
end;

function TfrMain.getPrintThreadState: TPrintThreadState;
begin
  result := fPrintThreadState
end;

function TfrMain.hasPrintJob: Boolean;
begin
  result := fQueueBegins <> fQueueEnds
end;

procedure TfrMain.initQueue;
begin
  fQueueBegins := 1;
  fQueueEnds := 1;

  fLogger.log('очередь проинициализирована');
end;

function TfrMain.isAsleeping: Boolean;
begin
  result := fPrintThreadState = ptsAsleeping
end;

function TfrMain.isAwakening: Boolean;
begin
  result := fPrintThreadState = ptsAwakening
end;

function TfrMain.isSleeping: Boolean;
begin
  result := fPrintThreadState = ptsSleeping
end;

function TfrMain.isTerminated: Boolean;
begin
  result := fPrintThreadState = ptsTerminated
end;

function TfrMain.isTerminating: Boolean;
begin
  result := fPrintThreadState = ptsTerminating
end;

function TfrMain.isWorking: Boolean;
begin
  result := fPrintThreadState = ptsWorking
end;

procedure TfrMain.terminate;
begin
  fLogger.log('закрытие печати');

  fPrintThreadState := ptsTerminating
end;

procedure TfrMain.FormDestroy(Sender: TObject);
begin
  fLogger.log('закрытие соединения с базой данных');

  doneMySQL;

  fLogger.log('соединение с базой данных закрыто');

  destroyQueue;

  fLogger.log('завершение работы приложения');

  fLogger.Free;
  
{  Shell_NotifyIcon(NIM_DELETE, addr(pnid));
  DestroyIcon(pnid.hIcon);}
end;

function TfrMain.isQueueFull: Boolean;
begin
  result := (fQueueBegins = 1) and (fQueueEnds = _queueSize) or
    (fQueueEnds = fQueueBegins - 1)
end;

procedure TfrMain.loadPrintJob;
var
  row: PMYSQL_ROW;
var
  query: String;
  printId: String;
  dateTime: String;
  userName: String;
  classRoom: String;
  PC: String;
  contestName: String;
  taskName: String;
  source: TStringList;
  printJob: TPrintJob;

  f: file;
begin
  //fLogger.log('поиск заданий для постановки в очередь');

  query := 'select ' +
    'P.printId as `printId`, ' +
    'P.dateTime as `dateTime`, ' +
    'U.nickName as `userNickName`, ' +
    'U.classRoom, ' +
    'U.pc, ' +
    'C.Name as `contestName`, ' +
    'T.Name as `taskName`, ' +
    'P.source ' +
  'from ' +
    '(' +
      '(' +
        '(' +
          'print P INNER join cntest C on P.contestId=C.contestId' +
        ') inner join volume V on P.problemId=V.problemId and P.contestId=V.contestId' +
      ') inner join Task T on V.taskId=T.taskId' +
    ') INNER join `user` U on P.userId=U.ID ' +
  'where ' +
    'P.isPrinted=0 ' +
  'order by ' +
    'P.printId asc ' +
  'LIMIT 1';

  if mySQLSelect(query) then begin
    row := mySQLFetchRow;

    if nil <> row then begin
      fLogger.log('найдено задание для постановки в очередь');

      printId := row[0];
      dateTime := row[1];
      userName := row[2];
      classRoom := row[3];
      pc := row[4];
      contestName := row[5];
      taskName := row[6];

      assignFile(f, 'source.txt'); rewrite(f, 1);
      blockWrite(f, row[7][0], mySQLLengths[7]);
      closeFile(f);

      source := TStringList.Create;
      source.LoadFromFile('source.txt');

      source.Insert(0, '{');
      source.Insert(1, '  * ID: ' + printId);
      source.Insert(2, '  * Дата/время: ' + dateTime);
      source.Insert(3, '  * Команда: ' + userName);
      source.Insert(4, '  * Задача: ' + taskName);
      source.Insert(5, '}');
      source.Insert(6, '');

      printJob := TPrintJob.create(classRoom + '#' + PC,
        source,
        printID,
        userName,
        taskName);

      fLogger.log('загружено: задание #' +
        printJob.getPrintID +
        '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

      addPrintJob(printJob);

      fLogger.log('поставлено в очередь: задание #' +
        printJob.getPrintID +
        '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

      mySQLFreeResult;

      query := 'update print set isPrinted=1 where printId=' + printJob.getPrintID;

      if mySQLUpdate(query) then
        fLogger.log('статус {в очереди}: задание #' +
          printJob.getPrintID +
          '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
      else
        fLogger.log('ОШИБКА при установке статуса {в очереди}: задание #' +
          printJob.getPrintID +
          '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
    end
    else
      mySQLFreeResult
      //fLogger.log('заданий для постановки в очередь печати не найдено');
  end
  else
    fLogger.log('ОШИБКА при поиске заданий для постановки в очередь');
end;

procedure TfrMain.doneMySQL;
begin
  mySQLClose
end;

function TfrMain.initMySQL(host, user, password, database: String): Boolean;
begin
  result := mySQLConnect(host, user, password, database) and
    mySQLSelectDB(database)
end;

procedure TfrMain.mySQLTimerTimer(Sender: TObject);
begin
  if not isQueueFull then
    loadPrintJob
end;

procedure TfrMain.itmAwakeClick(Sender: TObject);
begin
  itmAwake.Enabled := false;

  awake
end;

procedure TfrMain.itmPauseClick(Sender: TObject);
begin
  itmPause.Enabled := false;

  asleep
end;

procedure TfrMain.itmExitClick(Sender: TObject);
begin
  mySQLTimer.Enabled := false;

  itmAwake.Enabled := false;
  itmPause.Enabled := false;
  itmExit.Enabled := false;

  terminate
end;

procedure TfrMain.execute(host, user, password, database: String);
begin
  fLogger.log('устанавливается соединение с базой данных');

  if not initMySQL(host, user, password, database) then begin
    fLogger.log('соединение с базой данных НЕ установлено');

    application.Terminate
  end
  else begin
    fLogger.log('соединение с базой данных установлено');

    initQueue;

    fPrintThreadState := ptsSleeping;

    fPrintThread := TPrintThread.create(self,
      false);

    fLogger.log('создан поток печати');

    show
  end
end;

procedure TfrMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caNone;

  terminate
end;

procedure TfrMain.FormCreate(Sender: TObject);
begin
  fLogger := TLogger.create(getCurrentDir + '\printer.log', meLog.Lines);

  fLogger.log('запуск приложения');

{  pnid.cbSize := sizeof(pnid);
  pnid.Wnd := Handle;
  pnid.uCallbackMessage := WM_USER+1;
  pnid.uID := 1;
  pnid.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  pnid.hIcon := LoadIcon(HInstance, 'MAINICON'); // В качестве иконки в панели задач устанавливается иконка программы
  pnid.szTip := 'printer';
  Shell_NotifyIcon(NIM_ADD, @pnid); // Передает системе данные об иконке}
end;

procedure TfrMain.ApplicationEvents1Minimize(Sender: TObject);
begin
  hide
end;

procedure TfrMain.FormShow(Sender: TObject);
begin
  Application.Restore
end;

procedure TfrMain.TrayIcon(var Msg: TMsg);
begin
  if (msg.wParam = 513) then
  	Show
end;

end.
