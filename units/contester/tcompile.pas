{$I defines.inc}
unit tCompile;

interface
 	uses tTypes, tCallBack, SysUtils;

 	function CompileApp(SrcDir, SrcName, OutDir, OutName, checkName: String; Bat: String): integer;
 	//return value:
 	//_OK - ok
 	//_BR - отменено
 	//_FL - ошибка запуска компиллятора
 	//_CE - compilation error

implementation

uses
    tFiles, runlib, tLog,
    tConfig,


  Forms;

function CompileApp(SrcDir, SrcName, OutDir, OutName, checkName: String; Bat: String): integer;
var
  ec:       integer;
  workdir:  String;
begin
    if not DelFile(OutDir + OutName) then
        CompileApp := _FL
    else begin
        workdir := Application.ExeName;
        workdir := ExtractFileDir(workdir);

        ec := RunApp('',
                     MainConfig.ReadString('compile', 'compile_batch_dir', workdir + '\') + Bat + ' ' +
                     SrcDir + ' ' +
                     SrcName + ' ' +
                     OutDir + ' ' +
                     OutName,
                     False,
                     False,
                     CB_RUN_TYPE_COMPILE);
        case ec of
            _BR: CompileApp := _BR;
            _FL: CompileApp := _CE;
        else if FileExists(OutDir + checkName) then CompileApp := _OK
                                             else CompileApp := _CE;
        end;
    end;
end;

end.
