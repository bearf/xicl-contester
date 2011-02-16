unit uUtils;

interface

uses
    SysUtils;

function itos(x: Int64): String;
function sfri(x: Int64): String;
function stoi(x: String): Int64; overload;
function stoi(x: String; default: Int64): Int64; overload;
function ifrs(x: String): Int64; overload;
function ifrs(x: String; default: Int64): Int64; overload;
function dtos(x: TDateTime): String;
function stod(x: String): TDateTime;
function nulldt: String;
function localeFS: TFormatSettings;

function eq(a, b: real): Boolean;

function _dir(dir: String): String;
function _file(fileName, dir: String): String;

implementation

const
    eps = 1e-7;

function itos(x: Int64): String;
begin
    result := IntToStr(x);
end;

function sfri(x: Int64): String;
begin
    result := itos(x);
end;

function stoi(x: String): Int64;
begin
    result := StrToInt(x)
end;

function ifrs(x: String): Int64;
begin
    result := stoi(x)
end;

function stoi(x: String; default: Int64): Int64;
begin
    result := StrToIntDef(x, default);
end;

function ifrs(x: String; default: Int64): Int64;
begin
    result := stoi(x, default);
end;

function localeFS: TFormatSettings;
begin
    GetLocaleFormatSettings(0, result);
    result.DateSeparator    := '-';
    result.TimeSeparator    := ':';
    result.LongDateFormat   := 'yyyy-mm-dd';
    result.ShortDateFormat  := 'yyyy-mm-dd';
    result.LongTimeFormat   := 'hh:nn:ss';
    result.ShortTimeFormat  := 'hh:nn:ss';
end;

function dtos(x: TDateTime): String;
begin
    result := DateTimeToStr(x, localeFS())
end;

function stod(x: String): TDateTime;
begin
    result := StrToDateTime(x, localeFS());
end;

function nulldt: String;
begin
    result := '0000-00-00 00:00:00'
end;

function eq(a, b: real): Boolean;
begin
    result := abs(a - b) < eps
end;

function _dir(dir: String): String;
begin
    if (length(dir) < 2) then begin
        raise Exception.Create('Invalid directory name: ' + dir);
    end else if not (dir[1] in ['.', '/', '\', ':']) and (dir[2] <> ':') then begin
        raise Exception.Create('Invalid directory name: ' + dir);
    end else if dir[length(dir)] = '\' then begin
        result := dir
    end else begin
        result := dir + '\' 
    end
end;

function _file(fileName, dir: String): String;
begin
    if (length(fileName) < 1) then begin
        raise Exception.Create('Invalid file name: ' + fileName);
    end;

    if (fileName[1] = '\') then begin
        fileName := copy(fileName, 2, length(fileName) - 1)
    end;

    result := _dir(dir) + fileName
end;

end.
