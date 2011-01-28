{$I defines.inc}
unit tConfig;

interface

uses windows, inifiles, sysutils, Forms, Registry;

var
	MainConfig: tinifile;
    MainReg: TRegistryINIFile;

implementation

var fn: string;

initialization
    MainReg := TRegistryINIFile.Create('\Software\Contest');
	fn := GetCurrentDir + '\contest.inf';
	MainConfig := TIniFile.Create(fn);
finalization
	MainConfig.free;
    MainReg.Free;
end.
