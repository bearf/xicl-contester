{$O-}
unit TesterThreadUnit;

interface

uses
    Windows, SysUtils, Classes, WinSock,

    ttypes,
    udb,
    tConfig,
    tCallBack,
    tConVis,
    tlog,
    tsys,
    tTimes

    ;


type
    TTesterThread = class(TThread)
    private
        FTesterStarted: boolean;
    protected
        procedure Execute; override;
        procedure SetTesterStarted(Value: boolean);
        function GetTesterStarted: boolean;
        procedure OnTerminateThread(Sender: TObject);
    public
        constructor Create();
        procedure Done();
        procedure Finishing();
        procedure ChangeStatus;
        procedure SetFalseTesterStarted;
        procedure Test(id, testingId: integer);
        procedure ttConVisCB();
        procedure callConVisCB();
        property TesterStarted: boolean read GetTesterStarted write SetTesterStarted;
    end;

Var
    taskcount  : integer;
    SubmitInfo : TSubmitInfo;
    tv         : TimeVal;
    fl         : boolean;
    testerdir  : string;


implementation

uses TesterMainUnit;

procedure TTesterThread.callConVisCB();
begin
    Synchronize(ttConVisCB);
end;

procedure TTesterThread.ttConVisCB();
begin
    mConVisCB();
end;

procedure TTesterThread.OnTerminateThread(Sender: TObject);
begin
    TesterMainForm.TerminateThread;
end;

function TTesterThread.GetTesterStarted: boolean;
begin
    result := FTesterStarted;
end;

procedure TTesterThread.SetTesterStarted(Value: boolean);
begin
    FTesterStarted := Value;
end;

// Завершение работы
procedure TTesterThread.Done();
begin
    logger.info.print('Exiting...');
    Synchronize(SetFalseTesterStarted);
end;

procedure TTesterThread.Finishing();
begin
//
end;

procedure TTesterThread.SetFalseTesterStarted;
begin
    TesterMainForm.stop;
end;

procedure TTesterThread.ChangeStatus;
begin
    if TesterStarted then begin
  		fl := true;
  		testerdir := ExtractFilePath(paramStr(0));

		// Процедура RegCB {tcallback} регистрирует функцию ConVisCB {tconvis} в начало стека
  		RegCB(@ConVisCB);
    end else begin
  		UnregCB(@ConVisCB);
    end;
end;

procedure TTesterThread.Test(id, testingId: integer);
var
    SubmitInfo: TSubmitInfo;
    ec:         integer;
begin
    if not GetInfo(dbSubmit, ID, SubmitInfo) then begin
        fatal('submit ' + IntToStr(id) + ' not found');
    end;

    ec := TestSubmit(SubmitInfo);

    if (SubmitInfo.result.result <> _FL) then begin
        SubmitInfo.status := SUBMIT_DONE
  	end else begin
        SubmitInfo.Status := Submit_Frozen;
    	fatal('FAAAAAAATTTAAAALLLLLL EEEEERRROOOORRR !!!!! - core dumped '#2);
    end;

    //Upload результата только если всё прошло гладко...
    if SubmitInfo.result.result <> _BR then begin
        logger.test.print('upload result ');

        //обновляем информацию в таблице Submit
        if not SetInfo(dbSubmit, SubmitInfo.ID, SubmitInfo)
            then logger.test.print('upload FAILED')
   		    else logger.test.print('upload OK');

        SubmitInfo.testingId := testingId;
        UpdateTesting(SubmitInfo);

        //обновляем информацию в таблице Monitor
        if not isMonitorFrozen(SubmitInfo) then begin
            UpdateMonitor(SubmitInfo);
        end
    end else begin
        logger.test.print('result not uploaded - BR ');
    end
end;

constructor TTesterThread.Create();
begin
    inherited Create(False);
    self.OnTerminate := OnTerminateThread;
end;

procedure TTesterThread.Execute;
var
    i:  Integer;
begin
    FreeOnTerminate := true;
    while not Terminated and TesterStarted do begin
        taskcount := ReadTesterSubmits;
        if taskcount = 0 then fl := false else fl := true;
        for i := 0 to taskcount - 1 do if GetSubmitBynum(i, SubmitInfo) then begin
            if not TesterStarted then begin
                done();
                break;
            end;
            Test(SubmitInfo.id, SubmitInfo.testingId);
        end; // for
        sleep(200);
    end; // while
end;

end.
