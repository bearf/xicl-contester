unit uStopCmd;

interface

    uses
            uCmd
        ;

    type

        TStopCmd = class(TCmd)
        public
            class function  name: String; override;

            procedure       run; override;
        end;

implementation

    uses
            TesterMainUnit
        ,   tlog
        ;

    const
        _STOP_CMD  = 'stop';

    class function TStopCmd.name: String;
    begin
        result := _STOP_CMD
    end;

    procedure TStopCmd.run;
    begin
        inherited run;

        logger.debug.print('trying to stop server');

        if TesterMainForm.stop() then begin
            logger.info.print('server was successfully stopped');
            success();
        end else begin
            logger.error.print('attempt to stop server was failed');
            fail();
        end;
    end;

end.
