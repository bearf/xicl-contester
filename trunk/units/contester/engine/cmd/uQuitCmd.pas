unit uQuitCmd;

interface

    uses
            uCmd
        ;

    type

        TQuitCmd = class(TCmd)
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
        _QUIT_CMD  = 'quit';

    class function TQuitCmd.name: String;
    begin
        result := _QUIT_CMD
    end;

    procedure TQuitCmd.run;
    begin
        inherited run;

        logger.debug.print('trying to terminate application');

        if TesterMainForm.quit() then begin
            logger.info.print('application successfully terminated');
            success();
        end else begin
            logger.error.print('attempt to terminate application was failed');
            fail();
        end;
    end;

end.
