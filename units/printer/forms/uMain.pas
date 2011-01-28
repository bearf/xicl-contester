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

  // ������ �������
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

    // ��������� ����� ������
    // ������������� ���������� ���� ��������� � �������� ptsAwakening
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure awake;

    // ������� ����� ������
    // ������������� ���������� ���� ��������� � �������� ptsAwakening
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure asleep;

    // ��������� ����� ������
    // ������������� ���������� ���� ��������� � �������� ptsAwakening
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure terminate;

    // �������� ������� ������ � �������
    // �������������:
    //    * � ������������ ����� � ������� ������
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

    // ����������� ����������� ������ ������
    // ������������� ���������� ���� ��������� � �������� ptsWorking
    // �������������:
    //    * � ������ callConfirmAwake � ������ ������
    procedure confirmAwake;

    // ����������� ��������� ������ ������
    // ������������� ���������� ���� ��������� � �������� ptsSleeping
    // �������������:
    //    * � ������ callConfirmAsleep � ������ ������
    procedure confirmAsleep;

    // ����������� ���������� ������ ������
    // ������������� ���������� ���� ��������� � �������� ptsTerminated
    // �������������:
    //    * � ������ callConfirmTerminate � ������ ������
    procedure confirmTerminate;

    // ����������� ������ �������
    // ���������:
    //    printJob: �������, ������ �������� ���������
    //    result: ��������� ������
    // �������������:
    //    * � ������ callConfirmPrintJob � ������ ������
    procedure confirmPrintJob(printJob: TPrintJob; result: TPrintResult);

    // *** GETTERS ***

    // �������� ��������� ������ ������
    // ������������ ��������:
    //    ��������� ������ ������
    // �������������:
    //    * ����� ������ ���������� � ������ callGetPrintThreadState
    function getPrintThreadState: TPrintThreadState;

    // �������� ������� ������
    // ���������� ������ ������� ������ �� �������, ���� ��� ���� � ������� ���
    // �� �������
    // ������������ ��������:
    //    * ������� ������, ���� ������� �� �����
    //    * null � ��������������� ������
    // �������������:
    //    * � ������ callGetPrintJob � ������ ������
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
  //pnid : TNotifyIconData; //�������� ����������, ������� ��������� ������� ��� ��������� ��������� ������� ������ �����

procedure TfrMain.addPrintJob(printJob: TPrintJob);
begin
  fQueue[fQueueEnds] := printJob;

  //todo: ������!!!
  inc(fQueueEnds);
  if fQueueEnds > _queueSize then
    fQueueEnds := 1
end;

procedure TfrMain.asleep;
begin
  mySQLTimer.Enabled := false;
  fPrintThreadState := ptsAsleeping;

  fLogger.log('������� ������');
end;

procedure TfrMain.awake;
begin
  fPrintThreadState := ptsAwakening;

  fLogger.log('������ ������')
end;

procedure TfrMain.confirmAsleep;
begin
  fPrintThreadState := ptsSleeping;

  itmAwake.Enabled := true;

  fLogger.log('������ �����������')
end;

procedure TfrMain.confirmAwake;
begin
  fPrintThreadState := ptsWorking;
  mySQLTimer.Enabled := true;

  itmPause.Enabled := true;

  fLogger.log('������ ��������')
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
      status := '���������'
    end;
    prFailed: begin
      value := '4';
      status := '�� �������'
    end
  end;

  if result = prSuccess then
    fLogger.log('��������� �������: ������� #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
  else
    fLogger.log('������ ��� ����������: ������� #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

  fLogger.log('���������� �������: ������� #' +
    printJob.getPrintID +
    '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

  query := 'update print set isPrinted=' + value + ' where printId=' + printJob.getPrintID;

  if mySQLUpdate(query) then
    fLogger.log('������ {' + status + '}: ������� #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
  else
    fLogger.log('������ ��� ���������� ������� {' + status + '}: ������� #' +
      printJob.getPrintID +
      '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');
end;

procedure TfrMain.confirmTerminate;
begin
  fPrintThreadState := ptsTerminated;

  fLogger.log('������ �������');

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

  fLogger.log('���������� �� �������: ������� #' +
    result.getPrintID +
    '[' + result.getUserName + '/' + result.getTaskName + ']');

  inc(fQueueBegins);
  if fQueueBegins > _queueSize then
    fQueueBegins := 1;

  fLogger.log('������: ������� #' +
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

  fLogger.log('������� �������������������');
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
  fLogger.log('�������� ������');

  fPrintThreadState := ptsTerminating
end;

procedure TfrMain.FormDestroy(Sender: TObject);
begin
  fLogger.log('�������� ���������� � ����� ������');

  doneMySQL;

  fLogger.log('���������� � ����� ������ �������');

  destroyQueue;

  fLogger.log('���������� ������ ����������');

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
  //fLogger.log('����� ������� ��� ���������� � �������');

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
      fLogger.log('������� ������� ��� ���������� � �������');

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
      source.Insert(2, '  * ����/�����: ' + dateTime);
      source.Insert(3, '  * �������: ' + userName);
      source.Insert(4, '  * ������: ' + taskName);
      source.Insert(5, '}');
      source.Insert(6, '');

      printJob := TPrintJob.create(classRoom + '#' + PC,
        source,
        printID,
        userName,
        taskName);

      fLogger.log('���������: ������� #' +
        printJob.getPrintID +
        '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

      addPrintJob(printJob);

      fLogger.log('���������� � �������: ������� #' +
        printJob.getPrintID +
        '[' + printJob.getUserName + '/' + printJob.getTaskName + ']');

      mySQLFreeResult;

      query := 'update print set isPrinted=1 where printId=' + printJob.getPrintID;

      if mySQLUpdate(query) then
        fLogger.log('������ {� �������}: ������� #' +
          printJob.getPrintID +
          '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
      else
        fLogger.log('������ ��� ��������� ������� {� �������}: ������� #' +
          printJob.getPrintID +
          '[' + printJob.getUserName + '/' + printJob.getTaskName + ']')
    end
    else
      mySQLFreeResult
      //fLogger.log('������� ��� ���������� � ������� ������ �� �������');
  end
  else
    fLogger.log('������ ��� ������ ������� ��� ���������� � �������');
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
  fLogger.log('��������������� ���������� � ����� ������');

  if not initMySQL(host, user, password, database) then begin
    fLogger.log('���������� � ����� ������ �� �����������');

    application.Terminate
  end
  else begin
    fLogger.log('���������� � ����� ������ �����������');

    initQueue;

    fPrintThreadState := ptsSleeping;

    fPrintThread := TPrintThread.create(self,
      false);

    fLogger.log('������ ����� ������');

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

  fLogger.log('������ ����������');

{  pnid.cbSize := sizeof(pnid);
  pnid.Wnd := Handle;
  pnid.uCallbackMessage := WM_USER+1;
  pnid.uID := 1;
  pnid.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  pnid.hIcon := LoadIcon(HInstance, 'MAINICON'); // � �������� ������ � ������ ����� ��������������� ������ ���������
  pnid.szTip := 'printer';
  Shell_NotifyIcon(NIM_ADD, @pnid); // �������� ������� ������ �� ������}
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
