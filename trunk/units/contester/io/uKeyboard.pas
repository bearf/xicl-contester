unit uKeyboard;

interface

    uses

            Classes
        ;

    const

        _KEY_BACKSPACE  = 8;
        _KEY_ENTER      = 13;

    type

        TKeyboard = class
        private
            constructor create; 
        public
            function key(code: Word; shift: TShiftState): String;
        end;

    var

        keyboard:   TKeyboard;

implementation

    uses

            SysUtils
        ;

    const

        _ALLOWED_KEYS       = [32, 48..57, 65..90];
        _ALPHA              = [65..90];
        _LOWERCASE_SHIFT    = 97 - 65;

    constructor TKeyboard.create;
    begin
    end;

    function TKeyboard.key(code: Word; shift: TShiftState): String;
    begin
        if not (code in _ALLOWED_KEYS) then begin
            result := '';
            exit;
        end;

        if (code in _ALPHA) and (ssShift in shift) then begin
            result := chr(code);
        end else if (code in _ALPHA) and not(ssShift in shift) then begin
            result := chr(code + _LOWERCASE_SHIFT);
        end else begin
            result := chr(code);
        end;
    end;

initialization

    begin
        keyboard := TKeyboard.Create
    end;

finalization

    begin
        keyboard.Free
    end;

end.