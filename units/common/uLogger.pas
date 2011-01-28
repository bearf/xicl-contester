unit uLogger;

interface

uses
  Classes;

type

  TLogger = class
  private

    fLogFile: textFile;

    fLogWindow: TStrings;

  public

    constructor create(logFileName: String; logWindow: TStrings);

    destructor destroy; override;

    procedure log(line: String);
     
  end;

implementation

uses
  SysUtils;

{ TLogger }

constructor TLogger.create(logFileName: String; logWindow: TStrings);
begin
  inherited create;

  fLogWindow := logWindow;

  assignFile(fLogFile, logFileName);

  if fileExists(logFileName) then
    append(fLogFile)
  else
    rewrite(fLogFile);

  writeln(fLogFile);

  log('создание логгера')
end;

destructor TLogger.destroy;
begin
  log('закрытие логгера');

  closeFile(fLogFile);

  inherited destroy
end;

procedure TLogger.log(line: String);
var
  dt: TDateTime;
  dtstr: String;
begin
  dt := Date + Time;
  dtStr := DateTimeToStr(dt);

  try
    writeln(fLogFile, dtStr, ' > ', line)
  except
  end;

  try
    fLogWindow.Add(line)
  except
  end
end;

end.
