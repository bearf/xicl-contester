unit uEngine;

interface

    uses

            Classes
        ,   uQueue
        ,   uCmd
        ,   uNotifier
        ;

    type

        TEngine = class(TNotifier)
        private
            queued:     TQueue;
            finished:   TQueue;
            running:    TCmd;
        public
            constructor create;
            destructor  destroy; override;

            procedure   run; 
            procedure   push(cmd: TCmd);
            function    history: TStrings;
            procedure   notify(event: Integer; sender: TObject); override;

            procedure   onrun(cmd: TCmd);
            procedure   onsuccess(cmd: TCmd);
            procedure   onfail(cmd: TCmd);
        end;

    var
        engine:     TEngine;

implementation

    uses
            SysUtils

        ,   tlog
        ,   uUtils
        ;

    constructor TEngine.create;
    begin
        inherited create;

        queued      := TQueue.create;
        finished    := TQueue.create;

        running     := nil;
    end;

    destructor TEngine.destroy;
    begin
        queued.Free;
        finished.Free;
    end;

    procedure TEngine.push(cmd: TCmd);
    begin
        logger.debug.print('command "' + (cmd as TCmd).name() + '" was scheduled to run');

        queued.put(cmd);
        if nil = running then begin
            run;
        end
    end;

    procedure TEngine.run;
    begin
        if nil <> running then begin
            fatal('attempt to run command "' + (queued.get as TCmd).name() + '" while another is running');
        end;

        if queued.empty then begin
            fatal('engine is trying to run next command but queue is empty');
        end;
        
        logger.debug.print('attempt to run command "' + (queued.get as TCmd).name() + '"');

        running := queued.pop as TCmd;

        running.run;
    end;

    function TEngine.history: TStrings;
    begin
        raise Exception.Create('TEngine.history');
    end;

    procedure TEngine.notify(event: Integer; sender: TObject);
    begin
        if (_EVENT_CMD_RUN = event) then begin
            onrun(sender as TCmd);
        end else if (_EVENT_CMD_SUCCESS = event) then begin
            onsuccess(sender as TCmd);
        end else if (_EVENT_CMD_FAIL = event) then begin
            onfail(sender as TCmd);
        end else begin
            logger.warn.print('engine handler: unrecognized event: ' + itos(event))
        end;
    end;

    procedure TEngine.onrun(cmd: TCmd);
    begin
        if running <> cmd then begin
            fatal('engine handler: exception: RUN event for command "' + cmd.name() + '" that it did not run');
        end else begin
            logger.debug.print('engine handler: command "' + cmd.name() + '" was runned');
        end;
    end;

    procedure TEngine.onsuccess(cmd: TCmd);
    begin
        if running <> cmd then begin
            fatal('engine handler: exception: SUCCESS event for command "' + cmd.name() + '" that is not running');
        end else begin
            logger.debug.print('engine handler: command "' + cmd.name() + '" executed successfully');
            // mark current command as "finished"
            finished.put(running);
            // delete running command
            running := nil;
            // try to run next command
            if not queued.empty then begin
                run;
            end;
        end;
    end;

    procedure TEngine.onfail(cmd: TCmd);
    begin
        if running <> cmd then begin
            fatal('engine handler: exception: FAIL event for command "' + cmd.name() + '" that is not running');
        end else begin
            logger.error.print('engine handler: FAIL event for command "' + cmd.name() + '"');
            // delete running command
            running := nil;
            // try to run next command
            if not queued.empty then begin
                run;
            end;
        end;
    end;

initialization

    begin
        engine := TEngine.create;
    end;

finalization

    begin
        engine.Free
    end;

end.
