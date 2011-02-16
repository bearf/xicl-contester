unit uPrintThread;

{
  Ќазначение: определ€ет поток дл€ печати заданий
}

interface

uses
  Classes,
  uPrintControl,
  uPrintJob,
  uPrintThreadUserInterface;

type

  {
     ласс: поток печати заданий
    Ќазначение:
      * инкапсулирует логику по
        > извлечению заданий из очереди
        > печати заданий
        > обмена данными с главной формой
     омментарии:
      * обмен данными осуществл€етс€ на synchronize-вызовов методов главной формы,
      реализующей интерфейс IPrintThreadUser
  }
  TPrintThread = class(TThread, IPrintThreadSlave)
  protected

    // *** INTERFACE ***

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;

    function _AddRef: Integer; stdcall;

    function _Release: Integer; stdcall;

  private

    // *** FIELDS ***

    // состо€ние потока печати
    fPrintThreadState: TPrintThreadState;

    // текущее задание печати
    fPrintJob: TPrintJob;

    // главна€ форма
    fMaster: IPrintThreadMaster;

    // есть ли свободное задание печати
    fHasPrintJob: Boolean;

    // результат печати
    fPrintResult: TPrintResult;

    // *** METHODS ***

    procedure confirmAwake;

    procedure confirmAsleep;

    procedure confirmTerminate;

    procedure confirmPrintJob(printJob: TPrintJob; result: TPrintResult);

    procedure sleep;

    procedure work;

    function print(printJob: TPrintJob): Boolean;

    // *** GETTERS ***

    function getPrintThreadState: TPrintThreadState;

    function getPrintJob: TPrintJob;

    function hasPrintJob: Boolean;

    function isAwakening: Boolean;

    function isAsleeping: Boolean;

    function isTerminating: Boolean;

    function isTerminated: Boolean;

    function isSleeping: Boolean;

    function isWorking: Boolean;

    // *** CALLERS ***

    procedure callHasPrintJob;

    procedure callGetPrintJob;

    procedure callConfirmPrintJob;

    procedure callConfirmAwake;

    procedure callConfirmAsleep;

    procedure callConfirmTerminate;

    procedure callGetPrintThreadState;

  public

    // *** CONSTRUCTORS ***

    // конструктор с параметрами
    // запоминает главную форму, с которой должен осуществл€тьс€ обмен данными
    // и создает поток
    constructor create(master: IPrintThreadMaster;
      createSuspended: Boolean);

    // *** DESTRUCTORS ***

    destructor destroy; override; 

    // *** METHODS ***

    // основной рабочий метод
    // осуществл€ет:
    //    * извлечение заданий из очереди
    //    * печать заданий
    //    * обмен информаций с главной формой
    procedure execute; override;

  end;

implementation

uses
  SysUtils;

{ TPrintThread }

procedure TPrintThread.callConfirmAsleep;
begin
  fMaster.confirmAsleep
end;

procedure TPrintThread.callConfirmAwake;
begin
  fMaster.confirmAwake
end;

procedure TPrintThread.callConfirmPrintJob;
begin
  fMaster.confirmPrintJob(fPrintJob, fPrintResult)
end;

procedure TPrintThread.callConfirmTerminate;
begin
  fMaster.confirmTerminate
end;

procedure TPrintThread.callGetPrintJob;
begin
  fPrintJob := fMaster.getPrintJob
end;

procedure TPrintThread.callGetPrintThreadState;
begin
  fPrintThreadState := fMaster.getPrintThreadState
end;

procedure TPrintThread.callHasPrintJob;
begin
  fHasPrintJob := fMaster.hasPrintJob
end;

procedure TPrintThread.confirmAsleep;
begin
  Synchronize(callConfirmAsleep)
end;

procedure TPrintThread.confirmAwake;
begin
  synchronize(callConfirmAwake)
end;

procedure TPrintThread.confirmPrintJob(printJob: TPrintJob; result: TPrintResult);
begin
  fPrintJob := printJob;
  fPrintResult := result;

  synchronize(callConfirmPrintJob)
end;

procedure TPrintThread.confirmTerminate;
begin
  synchronize(callConfirmTerminate)
end;

constructor TPrintThread.create(master: IPrintThreadMaster;
  createSuspended: Boolean);
begin
  inherited create(true);

  fMaster := master;

  if not createSuspended then
    resume
end;

// основной рабочий метод
procedure TPrintThread.execute;
begin
  while not terminated do
    case getPrintThreadState of
      ptsTerminating: terminate;
      ptsAsleeping: confirmAsleep;
      ptsSleeping: sleep;
      ptsAwakening: confirmAwake;
      ptsWorking: work 
    end;

  confirmTerminate
end;

function TPrintThread.getPrintJob: TPrintJob;
begin
  synchronize(callGetPrintJob);

  result := fPrintJob
end;

function TPrintThread.getPrintThreadState: TPrintThreadState;
begin
  Synchronize(callGetPrintThreadState);

  result := fPrintThreadState
end;

function TPrintThread._AddRef: Integer;
begin

end;

function TPrintThread._Release: Integer;
begin

end;

function TPrintThread.hasPrintJob: Boolean;
begin
  synchronize(callHasPrintJob);

  result := fHasPrintJob
end;

function TPrintThread.isAsleeping: Boolean;
begin
  synchronize(callGetPrintThreadState);

  result := fPrintThreadState = ptsAsleeping
end;

function TPrintThread.isAwakening: Boolean;
begin
  synchronize(callGetPrintThreadState);

  result := fPrintThreadState = ptsAwakening
end;

function TPrintThread.isSleeping: Boolean;
begin
  synchronize(callGetPrintThreadState);

  result := fPrintThreadState = ptsSleeping
end;

function TPrintThread.isTerminated: Boolean;
begin
  synchronize(callGetPrintThreadState);

  result := fPrintThreadState = ptsTerminated
end;

function TPrintThread.isTerminating: Boolean;
begin
  synchronize(callGetPrintThreadState);

  result := fPrintThreadState = ptsTerminating
end;

function TPrintThread.isWorking: Boolean;
begin
  synchronize(callGetPrintThreadState);

  result := fPrintThreadState = ptsWorking
end;

function TPrintThread.QueryInterface(const IID: TGUID; out Obj): HResult;
begin

end;

procedure TPrintThread.sleep;
begin
  SysUtils.sleep(1000)
end;

procedure TPrintThread.work;
var
  printJob: TPrintJob;
  printResult: Boolean;
begin
  if hasPrintJob then begin
    printJob := getPrintJob;

    if print(printJob) then
      confirmPrintJob(printJob, prSuccess)
    else
      confirmPrintJob(printJob, prFailed);

    printJob.Free
  end;

  SysUtils.sleep(1000)
end;

function TPrintThread.print(printJob: TPrintJob): Boolean;
var
  printControl: TPrintControl;
begin
  result := true;

  printControl := TPrintControl.create;

  try
    printControl.setWaterMark(printJob.getWaterMark);

    printControl.printText(printJob.getText)
  except
    result := false
  end;

  printControl.Free
end;

destructor TPrintThread.destroy;
begin
  inherited;
end;

end.
