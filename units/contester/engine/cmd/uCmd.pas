unit uCmd;

interface

    uses
            uNotifier
        ;

    const
        _EVENT_CMD_RUN      = 100;
        _EVENT_CMD_SUCCESS  = 101;
        _EVENT_CMD_FAIL     = 102;

    type

        TCmd = class(TNotifier)
        public
            constructor     create;
            destructor      destroy; override;

            procedure       run; virtual;
            procedure       success; virtual;
            procedure       fail; virtual;

            class function  name: String; virtual; abstract;
        end;

implementation

    uses
            SysUtils
        ;

    constructor TCmd.create;
    begin
        inherited create;
    end;

    destructor TCmd.destroy;
    begin
        inherited destroy;
    end;

    procedure TCmd.run;
    begin
        send(_EVENT_CMD_RUN, self);
    end;

    procedure TCmd.success;
    begin
        send(_EVENT_CMD_SUCCESS, self);
    end;

    procedure TCmd.fail;
    begin
        send(_EVENT_CMD_FAIL, self);
    end;

end.
