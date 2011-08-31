{$I defines.inc}
unit tlog;

interface

uses
        classes
    ,   graphics;

const
        BUFFER_SIZE         = 10000;

type
    TLoggerMode = (wmAll, wmNoTest, wmFatal, wmError, wmWarn, wmDebug, wmInfo, wmTest);

    TLoggerCallback = procedure;

    TBuffer = class
    private
        buffer:     array[0..BUFFER_SIZE-1] of String;
        subscribers:array of TLoggerCallback;
        pb, pe,
        size :      Integer;
        capacity:   Integer;

        function    get(index: Integer): String;
    public
        constructor create;
        procedure   push(message: String);
        function    full: TBuffer;
        function    last(capacity: Integer): TBuffer;
        procedure   subscribe(callback: TLoggerCallback);

        property    strings[index: integer]: String read get; default;
        function    count: Integer;
    end;

    TLogger = class
    private
        _mode:      TLoggerMode;
        _dir:       String;
        _fileName:  String;
        _endline:   Boolean;
        _handle:    textFile;
        _buffer:    array[TLoggerMode] of TBuffer;

        function    break: TLogger;
        function    section: String;
        function    now: String;
        function    append(message: String): TLogger;
    public
        constructor create(dir, fileName: String);

        function    error: TLogger;
        function    test: TLogger;
        function    fatal: TLogger;
        function    info: TLogger;
        function    debug: TLogger;
        function    warn: TLogger;

        function    print(message: String): TLogger;

        procedure   subscribe(mode: TLoggerMode; callback: TLoggerCallback);
        function    filter(mode: TLoggerMode): TBuffer;

        function    color(message: String): TColor;
        function    mode(message: String): TLoggerMode;
    end;

var
    logger: TLogger;
	mainlog: text;
	logdir: string;
	logfile: string;

    procedure fatal(message: String);

implementation

uses
        uUtils
    ,   sysutils
    ,   math
    ,   ttypes
    ,   tconfig
    ;

const
        COLORS: array[TLoggerMode] of TColor = (
                clBlack // wmAll
            ,   clBlack // wmNoTest
            ,   clRed   // wmFatal
            ,   clRed   // wmError
            ,   clOlive // wmWarn
            ,   clGray  // wmDebug
            ,   clBlack // wmInfo
            ,   clAqua // wmTest
        );

//*** COMMON ***

procedure fatal(message: String);
begin
    logger.fatal.print(message);
    halt(1)
end;

// *** BUFFER ***

constructor TBuffer.create;
begin
    self.size       := 0;
    self.pb         := 0;
    self.pe         := 0;
    self.capacity   := BUFFER_SIZE;
end;

procedure TBuffer.push(message: String);
var
    i:          Integer;
begin
    inc(size); if (size > BUFFER_SIZE) then begin inc(pb); pb := pb mod BUFFER_SIZE; end;
    buffer[pe] := message;
    inc(pe); pe := pe mod BUFFER_SIZE;

    for i := low(subscribers) to high(subscribers) do begin
        TLoggerCallback(subscribers[i])();
    end
end;

function TBuffer.count: Integer;
begin
    if size < capacity then begin
        result := size
    end else begin
        result := capacity
    end
end;

function TBuffer.get(index: Integer): String;
begin
    if (index < 0) or (index+1 > count) then begin
        raise Exception.Create('buffer index out of bound');
    end;

    index := pb + index;
    index := index + size - min(size, capacity);
    index := index mod BUFFER_SIZE;

    result := buffer[index]
end;

function TBuffer.last(capacity: Integer): TBuffer;
begin
    self.capacity := capacity;
    result := self;
end;

function TBuffer.full: TBuffer;
begin
    result := last(BUFFER_SIZE)
end;

procedure TBuffer.subscribe(callback: TLoggerCallback);
begin
    setLength(subscribers, length(subscribers) + 1);
    subscribers[high(subscribers)] := callback
end;

// *** WRITER ***

constructor TLogger.create(dir, fileName: String);
var
    loggerMode: TLoggerMode;
begin
    self._mode       := wmInfo;
    self._dir        := uUtils._dir(dir);
    self._fileName   := fileName;
    self._endline    := true;
    for loggerMode := low(_buffer) to high(_buffer) do begin
        _buffer[loggerMode] := TBuffer.create
    end
end;

function TLogger.print(message: String): TLogger;
begin
    message := self.now() + ' ' + self.section + ' ' + message;

    self.break;
    self.append(message);

    _buffer[wmAll].push(message);
    if (wmTest <> _mode) then begin
        _buffer[wmNoTest].push(message);
    end;
    _buffer[_mode].push(message);

    result := self;
end;

function TLogger.append(message: String): TLogger;
begin
    if (not DirectoryExists(self._dir)) then begin
        raise Exception.Create('Cannot create logger: directory ' + self._dir + ' does not exist');
    end;

    assignFile(self._handle, _file(self._fileName, self._dir));

    if (not FileExists(_file(self._fileName, self._dir)))
        then System.rewrite(self._handle)
        else System.append(self._handle);

    write(self._handle, message);

    closeFile(self._handle);

    self._endline := false;

    result := self;
end;

function TLogger.break: TLogger;
begin
    if (not self._endline) then begin
        self.append(#13#10);
        self._endline := true;
    end;

    result := self;
end;

function TLogger.section: String;
begin
    case _mode of
        wmFatal:    result := '[FATAL] ';
        wmError:    result := '[ERROR] ';
        wmWarn:     result := '[WARN]  ';
        wmDebug:    result := '[DEBUG] ';
        wmInfo:     result := '[INFO]  ';
        wmTest:     result := '[TEST]  ';
    end;
end;

function TLogger.now: String;
begin
    result := dtos(Date() + Time())
end;

function TLogger.error: TLogger;
begin
    self._mode := wmError;
    result := self;
end;

function TLogger.test: TLogger;
begin
    self._mode := wmTest;
    result := self;
end;

function TLogger.fatal: TLogger;
begin
    self._mode := wmFatal;
    result := self;
end;

function TLogger.warn: TLogger;
begin
    self._mode := wmWarn;
    result := self;
end;

function TLogger.debug: TLogger;
begin
    self._mode := wmDebug;
    result := self;
end;

function TLogger.info: TLogger;
begin
    self._mode := wmInfo;
    result := self;
end;

procedure TLogger.subscribe(mode: TLoggerMode; callback: TLoggerCallback);
begin
    _buffer[mode].subscribe(callback);
end;

function TLogger.filter(mode: TLoggerMode): TBuffer;
begin
    result := _buffer[mode]
end;

function TLogger.mode(message: String): TLoggerMode;
begin
    if (pos('FATAL', message) > 0) then begin
        result := wmFatal;
    end else if (pos('ERROR', message) > 0) then begin
        result := wmError;
    end else if (pos('WARN', message) > 0) then begin
        result := wmWarn;
    end else if (pos('DEBUG', message) > 0) then begin
        result := wmDebug;
    end else if (pos('INFO', message) > 0) then begin
        result := wmInfo;
    end else if (pos('TEST', message) > 0) then begin
        result := wmTest;
    end else begin
        result := wmInfo;
        //raise Exception.Create('cannot determine logger mode for message: ' + message)
    end
end;

function TLogger.color(message: String): TColor;
begin
    if (wmTest = mode(message)) then begin
        if (pos('task res OK', message) > 0) then begin
            result := clGreen
        end else if (pos('task res', message) > 0) then begin
            result := clRed
        end else begin
            result := clBlack;
        end;
    end else begin
        result := COLORS[mode(message)]
    end;
end;

begin
    logger := TLogger.create(
            mainconfig.readstring('log', 'logdir', '..\log\')
        ,   mainconfig.readstring('log', 'logfile', 'contester.log')
    );
end.
