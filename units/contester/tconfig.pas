{$I defines.inc}
unit tConfig;

interface

uses windows, inifiles, sysutils, Forms, Registry;

var
	MainConfig: tinifile;
    MainReg: TRegistryINIFile;

function getCompileDir(): String;


implementation

function getCompileDir(): String;
var
  workDir: String;
begin
  workdir := Application.ExeName;
  workdir := ExtractFileDir(workdir);

  result := MainConfig.ReadString('compile', 'compile_batch_dir', workdir + '\');
end;

initialization
    MainReg := TRegistryINIFile.Create('\Software\Contest');
	MainConfig := TIniFile.Create(GetCurrentDir()
        +   '\..\config\contest.inf'
    );
finalization
	MainConfig.free;
    MainReg.Free;
end.
