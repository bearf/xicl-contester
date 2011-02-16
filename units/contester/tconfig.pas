{$I defines.inc}
unit tConfig;

interface

uses windows, inifiles, sysutils, Forms, Registry;

var
	MainConfig: tinifile;
    MainReg: TRegistryINIFile;

implementation

initialization
    MainReg := TRegistryINIFile.Create('\Software\Contest');
	MainConfig := TIniFile.Create(GetCurrentDir()
        +   '\..\config\contest.inf'
    );
finalization
	MainConfig.free;
    MainReg.Free;
end.
