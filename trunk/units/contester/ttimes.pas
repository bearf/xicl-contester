{$I defines.inc}
unit tTimes;

interface

uses SysUtils;

const
    date_time_format: string = 'YYYY-MM-DD HH:NN:SS';

    function StrToDateTimeFormat(StrDate: string; DateSep, TimeSep: char; DateFormat, TimeFormat: string): TDateTime;
    function StrToDateTimeS(StrDate: string): TDateTime;

implementation

function StrToDateTimeFormat(StrDate: string; DateSep, TimeSep: char; DateFormat, TimeFormat: string): TDateTime;
var tDateSeparator, tTimeSeparator: char;
    tLongDateFormat, tLongTimeFormat: string;
begin
    tDateSeparator := DateSeparator;
    tTimeSeparator := TimeSeparator;
    tLongDateFormat := LongDateFormat;
    tLongTimeFormat := LongTimeFormat;

    DateSeparator := DateSep;
    TimeSeparator := TimeSep;
    ShortDateFormat := DateFormat;
    ShortTimeFormat := TimeFormat;
    try
        if StrDate = '' then result := 0
                        else result := StrToDateTime(StrDate);
    except
        on E: EConvertError do
            result := 0;
    end;

    DateSeparator := tDateSeparator;
    TimeSeparator := tTimeSeparator;
    LongDateFormat := tLongDateFormat;
    LongTimeFormat := tLongTimeFormat;
end;

function StrToDateTimeS(StrDate: string): TDateTime;
begin
    Result := StrToDateTimeFormat(StrDate, '-', ':', 'YYYY/MM/DD', 'HH/NN/SS');
end;

end.
