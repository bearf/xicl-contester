{$I defines.inc}
unit tlog;

interface

const
        LvlDebug = 'DEBUG';
        LvlError = 'ERROR';
        LvlFatal = 'FATAL';

type
    TWriterMode = (wmFatal, wmError, wmWarn, wmDebug, wmInfo, wmTest);

    TWriter = class
    private
        mode:       TWriterMode;
        dir:        String;
        fileName:   String;
        endline:    Boolean;
        handle:     textFile;

        function break: TWriter;
        function section: String;
        function now: String;
    public
        constructor create(dir, fileName: String);

        function error: TWriter;
        function test: TWriter;
        function fatal: TWriter;
        function info: TWriter;
        function debug: TWriter;
        function warn: TWriter;

        function separate: TWriter;
        function print(message: String): TWriter;
        function append(message: String): TWriter;
    end;

    TLogger = class
    private
        logWriter:  TWriter;
        testWriter: TWriter;
    public
        constructor create(dir, logFile, testFile: String);

        function error: TWriter;
        function test: TWriter;
        function fatal: TWriter;
        function info: TWriter;
        function debug: TWriter;
        function warn: TWriter;
    end;

var
	mainlog: text;
	logdir: string;
	logfile: string;
    logger: TLogger;

    procedure fatal(message: String);

implementation

uses
        uUtils
    ,   sysutils
    ,   ttypes
    ,   tconfig
    ;

//*** COMMON ***

procedure fatal(message: String);
begin
    logger.fatal.print(message);
    halt(1)
end;

// *** LOGGER ***

constructor TLogger.create(dir, logFile, testFile: String);
begin
    self.logWriter  := TWriter.create(dir, logFile);
    self.testWriter := TWriter.create(dir, testFile);
end;

function TLogger.error: TWriter;
begin
    result := self.logWriter.error;
end;

function TLogger.test: TWriter;
begin
    result := self.testWriter.test;
end;

function TLogger.fatal: TWriter;
begin
    result := self.logWriter.fatal;
end;

function TLogger.warn: TWriter;
begin
    result := self.logWriter.warn;
end;

function TLogger.debug: TWriter;
begin
    result := self.logWriter.debug;
end;

function TLogger.info: TWriter;
begin
    result := self.logWriter.info;
end;

// *** WRITER ***

constructor TWriter.create(dir, fileName: String);
begin
    self.mode       := wmInfo;
    self.dir        := _dir(dir);
    self.fileName   := fileName;
    self.endline    := true;

    self.append(#13#10#13#10)
end;

function TWriter.print(message: String): TWriter;
begin
    self.break;

    self.append(self.now() + ' ' + self.section + ' ' + message);

    result := self;
end;

function TWriter.append(message: String): TWriter;
begin
    if (not DirectoryExists(self.dir)) then begin
        raise Exception.Create('Cannot create logger: directory ' + self.dir + ' does not exist');
    end;

    assignFile(self.handle, _file(self.fileName, self.dir));

    if (not FileExists(_file(self.fileName, self.dir)))
        then System.rewrite(self.handle)
        else System.append(self.handle);

    write(self.handle, message);

    closeFile(self.handle);

    self.endline := false;

    result := self;
end;

function TWriter.break: TWriter;
begin
    if (not self.endline) then begin
        self.append(#13#10);
        self.endline := true;
    end;

    result := self;
end;

function TWriter.separate: TWriter;
begin
    self.break; self.append(' '); self.break;

    result := self;
end;

function TWriter.section: String;
begin
    case mode of
        wmFatal:    result := '[FATAL] ';
        wmError:    result := '[ERROR] ';
        wmWarn:     result := '[WARN]  ';
        wmDebug:    result := '[DEBUG] ';
        wmInfo:     result := '[INFO]  ';
        wmTest:     result := '[TEST]  ';
    end;
end;

function TWriter.now: String;
begin
    result := dtos(Date() + Time())
end;

function TWriter.error: TWriter;
begin
    self.mode := wmError;
    result := self;
end;

function TWriter.test: TWriter;
begin
    self.mode := wmTest;
    result := self;
end;

function TWriter.fatal: TWriter;
begin
    self.mode := wmFatal;
    result := self;
end;

function TWriter.warn: TWriter;
begin
    self.mode := wmWarn;
    result := self;
end;

function TWriter.debug: TWriter;
begin
    self.mode := wmDebug;
    result := self;
end;

function TWriter.info: TWriter;
begin
    self.mode := wmInfo;
    result := self;
end;

begin
    logger := TLogger.create(
            mainconfig.readstring('log', 'logdir', '..\log\')
        ,   mainconfig.readstring('log', 'logfile', 'contester.log')
        ,   mainconfig.readstring('log', 'testfile', 'contester.test')
    );
end.
