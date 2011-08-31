unit TesterMainUnit;

interface

    uses
            Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
            Dialogs, StdCtrls, ComCtrls, AppEvnts, Buttons, WinSock, ttypes, tConfig,
            ExtCtrls, Menus,

            TesterThreadUnit
        ,   mysqldb
        ,   tlog
        ,   uEngine
        ,   uDisplay
        ;

type
    TTesterMainForm = class(TForm)
        ApplicationEvents: TApplicationEvents;
        Panel2: TPanel;
        pbTest: TPaintBox;
        pbLog: TPaintBox;
        pbConsole: TPaintBox;

        procedure FormCreate(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure pbLogPaint(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure pbTestPaint(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
        procedure pbConsolePaint(Sender: TObject);
    protected
    private
        tstart, tlen:   TDateTime;
        tfinish:        TDateTime;
        FTesterStarted: boolean;
        typing:         String;

        log,
        test,
        console:        TDisplay;

        procedure       SetTesterStarted(Value: boolean);
    public
        procedure       TerminateThread;
        function        started: boolean;

        function        start: Boolean;
        function        stop: Boolean;
        function        quit: Boolean;
    end;

Var
    TesterMainForm: TTesterMainForm;
    TesterThread: TTesterThread;

implementation

    uses
            udb
        ,   tCallBack
        ,   tConVis
        ,   tsys
        ,   tTimes
        ,   uKeyboard
        ,   uCmdFactory
        ,   uCmd
        ;

{$R *.dfm}


    procedure logfunc;
    begin
        with TesterMainForm.log do
            buffer(logger.filter(wmNoTest).last(limit()));
    end;

    procedure testfunc;
    begin
        with TesterMainForm.test do
            buffer(logger.filter(wmTest).last(limit()));
    end;

    procedure consolefunc;
    var
        strings: TStrings;
    begin
        strings := TStringList.create;
        strings.add('> ' + TesterMainForm.typing + '_');

        with TesterMainForm.console do
            show(strings);
    end;

procedure TTesterMainForm.TerminateThread;
begin
    TesterThread := nil;
end;

function TTesterMainForm.started: boolean;
begin
    result := FTesterStarted;
end;

procedure TTesterMainForm.SetTesterStarted(Value: boolean);
begin
    FTesterStarted := Value;
    if (Value = True) AND (TesterThread=nil) then TesterThread := TTesterThread.Create;
    if TesterThread<>nil then TesterThread.TesterStarted := Value;
    if TesterThread<>nil then TesterThread.ChangeStatus;
end;

procedure TTesterMainForm.FormCreate(Sender: TObject);
begin
    setTesterStarted(false);

    // subscribe to display all log messages in paintbox
    log := TDisplay.Create(pbLog);
    logger.subscribe(wmAll, @logfunc);

    // subscribe to display all test messages in paintbox
    test := TDisplay.Create(pbTest);
    logger.subscribe(wmTest, @testfunc);

    // console
    console := TDisplay.Create(pbConsole);
end;

procedure TTesterMainForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    while TesterThread <> nil do begin sleep(100); end;

    engine.Free;

    log.Free; log := nil;
    test.Free; test := nil;
end;

procedure TTesterMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    if started() then CanClose:=false;
end;

procedure TTesterMainForm.pbLogPaint(Sender: TObject);
begin
    logfunc
end;

procedure TTesterMainForm.FormResize(Sender: TObject);
begin
    if (test = nil) or (log = nil) or (console = nil) then begin
        exit;
    end;

    test.resize(Rect(
            uDisplay.MARGIN
        ,   uDisplay.MARGIN + uDisplay.CONSOLE_HEIGHT + uDisplay.MARGIN
        ,   uDisplay.MARGIN + (testerMainForm.Width div 2 - uDisplay.MARGIN - uDisplay.MARGIN div 2)
        ,   testerMainForm.Height - uDisplay.MARGIN
    ));

    log.resize(Rect(
            uDisplay.MARGIN + testerMainForm.Width div 2 - uDisplay.MARGIN - uDisplay.MARGIN div 2 + uDisplay.MARGIN
        ,   uDisplay.MARGIN + uDisplay.CONSOLE_HEIGHT + uDisplay.MARGIN
        ,   testerMainForm.Width - uDisplay.MARGIN
        ,   testerMainForm.Height - uDisplay.MARGIN
    ));

    console.resize(Rect(
            uDisplay.MARGIN
        ,   uDisplay.MARGIN
        ,   testerMainForm.Width - uDisplay.MARGIN
        ,   uDisplay.MARGIN + uDisplay.CONSOLE_HEIGHT
    ));
end;

procedure TTesterMainForm.pbTestPaint(Sender: TObject);
begin
    testfunc
end;

    procedure TTesterMainForm.FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    var
        cmd:    TCmd;
    begin
        if (_KEY_BACKSPACE = key) then begin
            typing := copy(typing, 1, length(typing) - 1);
        end else if (_KEY_ENTER = key) then begin
            cmd := cmdFactory.instance(typing);
            if nil <> cmd then begin
                engine.push(cmd);
            end;
            typing := '';
        end else begin
            typing := typing + keyboard.key(key, shift);
        end;
        pbConsole.Invalidate;
    end;

    procedure TTesterMainForm.pbConsolePaint(Sender: TObject);
    begin
        consolefunc
    end;

    function TTesterMainForm.start: Boolean;
    begin
        if not started then begin
            logger.debug.print('attempt to start tester');
            SetTesterStarted(true);
            logger.debug.print('attempt to start tester was successful');
            result := true;
        end else begin
            logger.warn.print('attempt to start tester was dropped: tester is already started');
            result := false;
        end;
    end;

    function TTesterMainForm.stop: Boolean;
    begin
        if not started then begin
            logger.warn.print('attempt to stop tester was dropped: tester is already stopped');
            result := false;
        end else begin
            logger.debug.print('attempt to stop tester');
            SetTesterStarted(false);
            logger.debug.print('attempt to stop tester was successful');
            result := true;
        end;
    end;

    function TTesterMainForm.quit: Boolean;
    begin
        if not started then begin
            logger.debug.print('attempt to quit application');
            Application.Terminate;
            logger.debug.print('attempt to quit application: successful');
            result := true;
        end else begin
            logger.warn.print('attempt to quit application was dropped: tester is started');
            result := false;
        end;
    end;

end.
