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
        procedure Test(id: integer);
        procedure ttConVisCB();
        procedure callConVisCB();
//        procedure RecalcMonitor();
//        procedure PrepareMonitor();
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
    TesterMainForm.TesterStarted := false;
end;

procedure TTesterThread.ChangeStatus;
begin
    if TesterStarted then begin
        TesterMainForm.DisableControls();
  		fl := true;
  		testerdir := ExtractFilePath(paramStr(0));

		// Процедура RegCB {tcallback} регистрирует функцию ConVisCB {tconvis} в начало стека
  		RegCB(@ConVisCB);
    end else begin
  		UnregCB(@ConVisCB);
        TesterMainForm.EnableControls();
    end;
end;

procedure TTesterThread.Test(id: integer);
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
        logger.test.print('upload result... ');

        //обновляем информацию в таблице Submit
        if not SetInfo(dbSubmit, SubmitInfo.ID, SubmitInfo)
            then logger.test.append('error')
   		    else logger.test.append('ok');

        //обновляем информацию в таблицах Volume и Monitor
        UpdateVolume(SubmitInfo);

        // эта строка - только ДЛЯ ОЧНОГО ТУРА!!!!!
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
            Test(SubmitInfo.id);
        end; // for
    end; // while
end;

end.
