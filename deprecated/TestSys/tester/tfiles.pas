{$I defines.inc}
unit tfiles;

interface

//имнена каталогов с '/' на конце

uses Windows, SysUtils, ttypes, tlog;

const copy_buf_size = 1024 * 64;

	// Копирует файл Src в файл Dest, если скопировать не удалось или Dest уже существует,
	// то возвращает false
	function CopyFile(Src, Dest: String): boolean; overload;
	function CopyFile(Src, Dest: PChar): boolean; overload;

	// Копирует файлы списком
	// Передаются две строки - списки исходных и конечных файлов (файлы в списке разделяются запятыми)
	function CopyFileList(Srcs, Dests: PChar): boolean; overload;
 	function CopyFileList(Srcs, Dests: String): boolean; overload;

	// Удаляет файл
 	function DelFile(Name : PChar): boolean; overload;
  	function DelFile(Name : string): boolean; overload;

	// Удаляет файлы, передаваемые списком (единой строкой, через запятую)
 	function DelFileList(Dir, Names : PChar): boolean; overload;
 	function DelFileList(Dir, Names : String): boolean; overload;

    // Проверяет, существует ли файл
 	function FileExists(name: String): boolean; overload;
 	function FileExists(name: PChar): boolean; overload;

    // Проверяет, существует ли директория
 	function DirExists(name: String): boolean; overload;
 	function DirExists(name: PChar): boolean; overload;
    // Создает временную директорию и возвращает ее имя
 	function CreateTempDir(curdir: String): string;
	// Удаляет директорию
 	function DelDir(dir: string): boolean;
	// Удаляет директорию (вместе со всем содержимым)
  	function DelDirForce(dir: string): boolean;
	// Нормализация пути к директории (замена косых и добавление слэша в конце, если его нет)
 	procedure NormDir(var dir: String);

implementation

// Проверяет, существует ли файл
function FileExists(name: String): boolean;
  	begin
   		FileExists := SysUtils.FileExists(name);
  	end;

// Проверяет, существует ли файл
function FileExists(name: PChar): boolean;
	begin
   		FileExists := SysUtils.FileExists(StrPas(name));
  	end;

// Создает временную директорию и возвращает ее имя
function CreateTempDir(curdir: String): string;
  	var i: integer;
      	dir: String;
  	begin
   		Dir := CurDir + 'tmp';
   		i := 0;
   		while DirExists(Dir + IntToStr(i)) do inc(i);
   		dir := dir + IntToStr(i);
   		result := dir + slash;
   		CreateDir(dir);
  	end;

// Удаляет директорию (вместе со всем содержимым)
function DelDirForce(dir: string): boolean;
  	var sr: TSearchRec;
      	ok: boolean;
  	begin
   		ok := true;
   		if FindFirst(dir + '*', faDirectory, sr) = 0 then
        	repeat
     			if (sr.attr = faDirectory) and (sr.name <> '.') and (sr.name <> '..') then
      			ok := DelDirForce(dir + sr.name + slash) and ok;
    		until FindNext(sr) <> 0;
   		FindClose(sr);
   		if FindFirst(dir + '*', faAnyFile - faDirectory, sr) = 0 then
    		repeat
     			ok := DeleteFile(string(dir + sr.name)) and ok;
    		until FindNext(sr) <> 0;
   		FindClose(sr);
   		ok := DelDir(dir) and ok;
   		Result := ok;
  	end;

// Удаляет директорию
function DelDir(dir: string): boolean;
  	begin
   		Result := true;
   		if not RemoveDir(dir) then begin
    		AddLog(LvlError, 'cant delete dir ' + dir);
    		Result := false;
   		end;
  	end;

// Нормализация пути к директории (замена косых и добавление слэша в конце, если его нет)
procedure NormDir(var dir: String);
 	var i: integer;
 	begin
  		for i := 1 to length(dir) do
   			if (dir[i] = '\') or (dir[i] = '/') then dir[i] := slash;
  		if dir[length(dir)] <> slash then dir := dir + slash;
 	end;

// Проверяет, существует ли директория
function DirExists(name: String): boolean;
 	begin
		Result := SysUtils.DirectoryExists(name);
 	end;

// Проверяет, существует ли директория
function DirExists(name: PChar): boolean;
 	begin
		Result := SysUtils.DirectoryExists(StrPas(name));
 	end;

// Удаляет файл
function DelFile(Name : string): boolean;
	begin
  		Result := true;
  		if FileExists(name) and (not SysUtils.DeleteFile(Name)) then begin
   			AddLog(LvlError, 'cant delete ' + Name);
   			Result := false;
  		end;
 	end;

// Удаляет файл
function DelFile(Name : PChar): boolean;
 	begin
  		Result := true;
  		if FileExists(name) and (not SysUtils.DeleteFile(strpas(Name))) then begin
   			AddLog(LvlError, 'cant delete ' + strpas(Name));
   			Result := false;
  		end;
 	end;

// Удаляет файлы, передаваемые списком (единой строкой, через запятую)
function DelFileList(Dir, Names: PChar): boolean;
var name,sdir,snames: string;
    z: integer;
    ok: boolean;
begin
    if (Names='') then Names := 'output.txt';

    sdir := StrPas(dir);
    snames := StrPas(names);
    ok := true;
    z := Pos(',',snames);
    while (z<>0) and (length(snames)>0) do
        begin
            name := sdir + Copy(snames, 1, z-1);
            ok := DelFile(name) and ok;
            Delete(snames, 1, z);
            z := Pos(',',snames);
        end;
    if (length(snames)>0) then
        begin
            name := sdir + snames;
            ok := DelFile(name) and ok;
        end;
    Result := ok;
end;

// Удаляет файлы, передаваемые списком (единой строкой, через запятую)
function DelFileList(Dir, Names: String): boolean;
var tmp, tmp2: string;
begin
   	tmp := Names;
    tmp2 := Dir;
    Result := DelFileList(PChar(tmp2), PChar(tmp));
end;

// Копирует файл Src в файл Dest, если скопировать не удалось или Dest уже существует,
// то возвращает false
function CopyFile(Src, Dest: String): boolean;
begin
    Result := Windows.CopyFile(PChar(Src), PChar(Dest), false);
end;

// Копирует файл Src в файл Dest, если скопировать не удалось или Dest уже существует,
// то возвращает false
function CopyFile(Src, Dest: PChar): boolean;
begin
    Result := Windows.CopyFile(Src, Dest, false);
end;

// Копирует файлы списком
// Передаются две строки - списки исходных и конечных файлов (файлы в списке разделяются запятыми)
function CopyFileList(Srcs, Dests: PChar): boolean;
var src,dest,sdests,ssrcs: string;
    i,j: integer;
    ok: boolean;
begin
    ssrcs := StrPas(srcs);
    sdests := StrPas(dests);
    ok := true;
    i := Pos(',',ssrcs);
    j := Pos(',',sdests);
    while (i<>0) and (length(ssrcs)>0) and (j<>0) and (length(sdests)>0) do
        begin
            src := Copy(ssrcs, 1, i-1);
            dest := Copy(sdests, 1, j-1);
            ok := CopyFile(src, dest) and ok;
            Delete(ssrcs, 1, i);
            Delete(sdests, 1, j);
            i := Pos(',',ssrcs);
            j := Pos(',',sdests);
        end;
    if (length(ssrcs)>0) and (length(sdests)>0) then
        if (Pos(',',ssrcs)=0) and (Pos(',',sdests)=0) then
            begin
                src := ssrcs;
                dest := sdests;
                ok := CopyFile(src, dest) and ok;
            end;
    Result := ok;
end;

// Копирует файлы списком
// Передаются две строки - списки исходных и конечных файлов (файлы в списке разделяются запятыми)
function CopyFileList(Srcs, Dests: String): boolean;
begin
    Result := CopyFileList(PChar(Srcs), PChar(Dests));
end;

end.
