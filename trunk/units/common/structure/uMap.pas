unit uMap;

interface

    type

        TMapKeys = array of Integer;

        TMap = class
        private
            map:        array of TObject;
            index:      array of Integer;
            count:      Integer;

            function    indexOf(key: Integer): Integer;
        public
            constructor create;
            destructor  destroy; override;

            procedure   put(key: Integer; value: TObject);
            function    get(key: Integer): TObject;
            function    has(key: Integer): Boolean;
            function    remove(key: Integer): TObject;
            function    keys: TMapKeys;
        end;

implementation

    uses
            SysUtils

        ,   tlog
        ,   uUtils
        ;

    const
        _MAP_BUFFER_SIZE    = 100;
        _MAP_KEY_NOT_FOUND  = -1;

    constructor TMap.create;
    begin
        inherited create;

        count   := 0;
    end;

    destructor TMap.destroy;
    begin
        setLength(map, 0);
        setLength(index, 0);

        inherited destroy;
    end;

    procedure TMap.put(key: Integer; value: TObject);
    begin
        if count = length(index) then begin
            setLength(index, length(index) + _MAP_BUFFER_SIZE);
            setLength(map, length(map) + _MAP_BUFFER_SIZE);
        end;

        index[count]    := key;
        map[count]      := value;

        inc(count);
    end;

    function TMap.get(key: Integer): TObject;
    begin
        result := nil;
        if not has(key) then begin
            fatal('map: cannot object for key=' + itos(key));
        end else begin
            result := map[indexOf(key)]
        end;
    end;

    function TMap.has(key: Integer): Boolean;
    begin
        result := _MAP_KEY_NOT_FOUND <> indexOf(key)
    end;

    function TMap.remove(key: Integer): TObject;
    var
        i: Integer;
    begin
        result := get(key); // if no object then fatal

        i           := indexOf(key);
        index[i]    := index[count-1];
        map[i]      := map[count-1];

        dec(count);

        if 0 = (count mod _MAP_BUFFER_SIZE) then begin
            setLength(index, length(index) - _MAP_BUFFER_SIZE);
            setLength(map, length(map) - _MAP_BUFFER_SIZE);
        end;
    end;

    function TMap.indexOf(key: Integer): Integer;
    var
        i: Integer;
    begin;
        result := _MAP_KEY_NOT_FOUND;
        for i := 0 to count-1 do if index[i] = key then begin
            result := i;
        end;
    end;

    function TMap.keys: TMapKeys;
    var
        i: Integer;
    begin
        setLength(result, count);
        for i := 0 to count-1 do begin
            result[i] := index[i];
        end;
    end;

end.
