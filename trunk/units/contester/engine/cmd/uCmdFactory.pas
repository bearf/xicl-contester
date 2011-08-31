unit uCmdFactory;

interface

    uses
            SysUtils

        ,   uEngine
        ,   uCmd
        ;

    type

        TCmdFactory = class
        private
            constructor create(engine: TEngine);
        public
            function    instance(cmdName: String): TCmd;
        end;

    var
            cmdFactory:     TCmdFactory
        ;

implementation

    uses
            tlog
        ,   uStartCmd
        ,   uStopCmd
        ,   uQuitCmd
        ;

    constructor TCmdFactory.create;
    begin
        inherited create;
    end;

    function TCmdFactory.instance(cmdName: String): TCmd;
    begin
        result := nil;

        if (TStartCmd.name() = cmdName) then begin
            result := TStartCmd.create;
        end else if (TStopCmd.name() = cmdName) then begin
            result := TStopCmd.create;
        end else if (TQuitCmd.name() = cmdName) then begin
            result := TQuitCmd.create;
        end else begin
            logger.debug.print('Cannot recognize command: ' + cmdName)
        end;

        // подписываем движок на все события команды
        if (nil <> result) then begin
            result.subscribe(_EVENT_CMD_RUN, engine);
            result.subscribe(_EVENT_CMD_SUCCESS, engine);
            result.subscribe(_EVENT_CMD_FAIL, engine);
        end;
    end;

initialization

    begin
        cmdFactory := TCmdFactory.create(engine);
    end;

finalization

    begin
        cmdFactory.Free
    end;

end.
