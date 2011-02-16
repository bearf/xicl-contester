{$I defines.inc}
unit tlog;

interface

const
        LvlDebug = 'DEBUG';
        LvlError = 'ERROR';
        LvlFatal = 'FATAL';
var
	mainlog: text;
	logdir: string;
	logfile: string;

	procedure AddLog(level, msg : string);
	procedure FatalError(msg: String);

implementation
	uses sysutils, ttypes, tconfig;

procedure AddLog(level, msg : string);
begin
    If DirectoryExists(LogDir) then
        begin
  	    	{$IFNDEF NO_LOG}
      		assign(mainlog, logdir+logfile);
      		{$I-}
            If FileExists(logdir+logfile) then append(mainlog)
                                          else rewrite(mainlog);
      		{$I+}
      		if ioresult <> 0 then rewrite(mainlog);
     		{$ELSE}
      		assign(mainlog, '');
      		rewrite(mainlog);
      		{$ENDIF}
  		    writeln(mainlog, FormatDateTime('yyyy.mm.dd hh:nn:ss: ',Now), level, ': ', msg);
            close(mainlog);
        end;
end;

procedure FatalError(msg: String);
 	begin
  		{$IFNDEF NO_LOG}
//  		Writeln(Str);
  		{$ENDIF}
  		AddLog(LvlFatal, msg);
  		Halt(_FL);
 	end;

begin
{$IFNDEF CLIENT}
 	logdir := mainconfig.readstring('log', 'logdir', '..\..\log\');
 	logfile := mainconfig.readstring('log', 'logfile', 'log.log');
{$ELSE}
 	logdir := MainReg.readstring('log', 'logdir', '..\..\log\');
 	logfile := MainReg.readstring('log', 'logfile', 'log.log');
{$ENDIF}
end.
