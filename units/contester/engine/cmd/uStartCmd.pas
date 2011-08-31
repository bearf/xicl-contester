unit uStartCmd;

interface

    uses
            uCmd
        ;

    type

        TStartCmd = class(TCmd)
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
        _START_CMD  = 'start';

    class function TStartCmd.name: String;
    begin
        result := _START_CMD
    end;

    procedure TStartCmd.run;
    begin
        inherited run;

        logger.debug.print('trying to start server');

        if TesterMainForm.start() then begin
            logger.info.print('server was successfully started');
            success();
        end else begin
            logger.error.print('attempt to start server was failed');
            fail();
        end;
    end;

end.
