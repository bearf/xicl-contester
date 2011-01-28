{$I defines.inc}
unit CP;

interface

uses SysUtils, tTypes;

type
	tCodePage=(cpKOI, cpWIN, cpDOS);

const
//«а основу вз€та кодировка ƒос
//	cpDef:tCodePage=cpDOS;  //та кодировка что нужна везде внутри системы
	cpDef:tCodePage=cpWIN;  //та кодировка что нужна везде внутри системы
	cpSys:tCodePage=cpWIN;  //кодировка ќ—


	function ConvertChar (SrcCP, DestCP: tCodePage; var Ch: Char): Char;

	procedure ConvertBuf (SrcCP, DestCP: tCodePage; var Buf; Size:integer);

	function ConvertStr (SrcCP, DestCP: tCodePage; Str: String): String; overload;

	procedure ConvertStr (SrcCP, DestCP: tCodePage; Str, Out: String); overload;

	function CodePageToStr(CodePage: TCodePage):String;

	function StrToCodePage(Str: string):TCodePage;

	function LoCase(SrcCP: TCodePage; Str: String): String;
	//возвращает строку конвертированую в cpDef и маленькими буквами

	function UpCase(SrcCP: TCodePage; Str: String): String;
	//возвращает строку конвертированую в cpDef и большиим буквами

implementation

const
 	ToUnicode: Array[tCodePage, byte] of word =
      (({ $00} {KOI}
        $0000, $0001, $0002, $0003,
        $0004, $0005, $0006, $0007,
        $0008, $0009, $000a, $000b,
        $000c, $000d, $000e, $000f,
        { $10}
        $0010, $0011, $0012, $0013,
        $0014, $0015, $0016, $0017,
        $0018, $0019, $001a, $001b,
        $001c, $001d, $001e, $001f,
        { $20}
        $0020, $0021, $0022, $0023,
        $0024, $0025, $0026, $0027,
        $0028, $0029, $002a, $002b,
        $002c, $002d, $002e, $002f,
        { $30}
        $0030, $0031, $0032, $0033,
        $0034, $0035, $0036, $0037,
        $0038, $0039, $003a, $003b,
        $003c, $003d, $003e, $003f,
        { $40}
        $0040, $0041, $0042, $0043,
        $0044, $0045, $0046, $0047,
        $0048, $0049, $004a, $004b,
        $004c, $004d, $004e, $004f,
        { $50}
        $0050, $0051, $0052, $0053,
        $0054, $0055, $0056, $0057,
        $0058, $0059, $005a, $005b,
        $005c, $005d, $005e, $005f,
        { $60}
        $0060, $0061, $0062, $0063,
        $0064, $0065, $0066, $0067,
        $0068, $0069, $006a, $006b,
        $006c, $006d, $006e, $006f,
        { $70}
        $0070, $0071, $0072, $0073,
        $0074, $0075, $0076, $0077,
        $0078, $0079, $007a, $007b,
        $007c, $007d, $007e, $007f,
        { $80}
        $2500, $2502, $250c, $2510,
        $2514, $2518, $251c, $2524,
        $252c, $2534, $253c, $2580,
        $2584, $2588, $258c, $2590,
        { $90}
        $2591, $2592, $2593, $2320,
        $25a0, $2219, $221a, $2248,
        $2264, $2265, $00a0, $2321,
        $00b0, $00b2, $00b7, $00f7,
        { $a0}
        $2550, $2551, $2552, $0451,
        $2553, $2554, $2555, $2556,
        $2557, $2558, $2559, $255a,
        $255b, $255c, $255d, $255e,
        { $b0}
        $255f, $2560, $2561, $0401,
        $2562, $2563, $2564, $2565,
        $2566, $2567, $2568, $2569,
        $256a, $256b, $256c, $00a9,
        { $c0}
        $044e, $0430, $0431, $0446,
        $0434, $0435, $0444, $0433,
        $0445, $0438, $0439, $043a,
        $043b, $043c, $043d, $043e,
        { $d0}
        $043f, $044f, $0440, $0441,
        $0442, $0443, $0436, $0432,
        $044c, $044b, $0437, $0448,
        $044d, $0449, $0447, $044a,
        { $e0}
        $042e, $0410, $0411, $0426,
        $0414, $0415, $0424, $0413,
        $0425, $0418, $0419, $041a,
        $041b, $041c, $041d, $041e,
        { $f0}
        $041f, $042f, $0420, $0421,
        $0422, $0423, $0416, $0412,
        $042c, $042b, $0417, $0428,
        $042d, $0429, $0427, $042a),

       ({ $00}  {WIN}
        $0000, $0001, $0002, $0003,
        $0004, $0005, $0006, $0007,
        $0008, $0009, $000a, $000b,
        $000c, $000d, $000e, $000f,
        { $10}
        $0010, $0011, $0012, $0013,
        $0014, $0015, $0016, $0017,
        $0018, $0019, $001a, $001b,
        $001c, $001d, $001e, $001f,
        { $20}
        $0020, $0021, $0022, $0023,
        $0024, $0025, $0026, $0027,
        $0028, $0029, $002a, $002b,
        $002c, $002d, $002e, $002f,
        { $30}
        $0030, $0031, $0032, $0033,
        $0034, $0035, $0036, $0037,
        $0038, $0039, $003a, $003b,
        $003c, $003d, $003e, $003f,
        { $40}
        $0040, $0041, $0042, $0043,
        $0044, $0045, $0046, $0047,
        $0048, $0049, $004a, $004b,
        $004c, $004d, $004e, $004f,
        { $50}
        $0050, $0051, $0052, $0053,
        $0054, $0055, $0056, $0057,
        $0058, $0059, $005a, $005b,
        $005c, $005d, $005e, $005f,
        { $60}
        $0060, $0061, $0062, $0063,
        $0064, $0065, $0066, $0067,
        $0068, $0069, $006a, $006b,
        $006c, $006d, $006e, $006f,
        { $70}
        $0070, $0071, $0072, $0073,
        $0074, $0075, $0076, $0077,
        $0078, $0079, $007a, $007b,
        $007c, $007d, $007e, $007f,
        { $80}
        $0402, $0403, $201a, $0453,
        $201e, $2026, $2020, $2021,
        $20ac, $2030, $0409, $2039,
        $040a, $040c, $040b, $040f,
        { $90}
        $0452, $2018, $2019, $201c,
        $201d, $2022, $2013, $2014,
        $0000, $2122, $0459, $203a,
        $045a, $045c, $045b, $045f,
        { $a0}
        $00a0, $040e, $045e, $0408,
        $00a4, $0490, $00a6, $00a7,
        $0401, $00a9, $0404, $00ab,
        $00ac, $00ad, $00ae, $0407,
        { $b0}
        $00b0, $00b1, $0406, $0456,
        $0491, $00b5, $00b6, $00b7,
        $0451, $2116, $0454, $00bb,
        $0458, $0405, $0455, $0457,
        { $c0}
        $0410, $0411, $0412, $0413,
        $0414, $0415, $0416, $0417,
        $0418, $0419, $041a, $041b,
        $041c, $041d, $041e, $041f,
        { $d0}
        $0420, $0421, $0422, $0423,
        $0424, $0425, $0426, $0427,
        $0428, $0429, $042a, $042b,
        $042c, $042d, $042e, $042f,
        { $e0}
        $0430, $0431, $0432, $0433,
        $0434, $0435, $0436, $0437,
        $0438, $0439, $043a, $043b,
        $043c, $043d, $043e, $043f,
        { $f0}
        $0440, $0441, $0442, $0443,
        $0444, $0445, $0446, $0447,
        $0448, $0449, $044a, $044b,
        $044c, $044d, $044e, $044f),

       ({ $00} {DOS}
        $0000, $0001, $0002, $0003,
        $0004, $0005, $0006, $0007,
        $0008, $0009, $000a, $000b,
        $000c, $000d, $000e, $000f,
        { $10}
        $0010, $0011, $0012, $0013,
        $0014, $0015, $0016, $0017,
        $0018, $0019, $001a, $001b,
        $001c, $001d, $001e, $001f,
        { $20}
        $0020, $0021, $0022, $0023,
        $0024, $0025, $0026, $0027,
        $0028, $0029, $002a, $002b,
        $002c, $002d, $002e, $002f,
        { $30}
        $0030, $0031, $0032, $0033,
        $0034, $0035, $0036, $0037,
        $0038, $0039, $003a, $003b,
        $003c, $003d, $003e, $003f,
        { $40}
        $0040, $0041, $0042, $0043,
        $0044, $0045, $0046, $0047,
        $0048, $0049, $004a, $004b,
        $004c, $004d, $004e, $004f,
        { $50}
        $0050, $0051, $0052, $0053,
        $0054, $0055, $0056, $0057,
        $0058, $0059, $005a, $005b,
        $005c, $005d, $005e, $005f,
        { $60}
        $0060, $0061, $0062, $0063,
        $0064, $0065, $0066, $0067,
        $0068, $0069, $006a, $006b,
        $006c, $006d, $006e, $006f,
        { $70}
        $0070, $0071, $0072, $0073,
        $0074, $0075, $0076, $0077,
        $0078, $0079, $007a, $007b,
        $007c, $007d, $007e, $007f,
        { $80}
        $0410, $0411, $0412, $0413,
        $0414, $0415, $0416, $0417,
        $0418, $0419, $041a, $041b,
        $041c, $041d, $041e, $041f,
        { $90}
        $0420, $0421, $0422, $0423,
        $0424, $0425, $0426, $0427,
        $0428, $0429, $042a, $042b,
        $042c, $042d, $042e, $042f,
        { $a0}
        $0430, $0431, $0432, $0433,
        $0434, $0435, $0436, $0437,
        $0438, $0439, $043a, $043b,
        $043c, $043d, $043e, $043f,
        { $b0}
        $2591, $2592, $2593, $2502,
        $2524, $2561, $2562, $2556,
        $2555, $2563, $2551, $2557,
        $255d, $255c, $255b, $2510,
        { $c0}
        $2514, $2534, $252c, $251c,
        $2500, $253c, $255e, $255f,
        $255a, $2554, $2569, $2566,
        $2560, $2550, $256c, $2567,
        { $d0}
        $2568, $2564, $2565, $2559,
        $2558, $2552, $2553, $256b,
        $256a, $2518, $250c, $2588,
        $2584, $258c, $2590, $2580,
        { $e0}
        $0440, $0441, $0442, $0443,
        $0444, $0445, $0446, $0447,
        $0448, $0449, $044a, $044b,
        $044c, $044d, $044e, $044f,
        { $f0}
        $0401, $0451, $0404, $0454,
        $0407, $0457, $040e, $045e,
        $00b0, $2219, $00b7, $221a,
        $2116, $00a4, $25a0, $00a0));

var
 	FromUnicode: Array [tCodepage, Word] of byte;

const
 	UnicodeLower: array[word] of word=({$I UnicodeLower.inc});

var
 	UnicodeUpper: array[word] of word;

function ConvertChar (SrcCP, DestCP: tCodePage; var Ch: Char): Char;
 	begin
  		Ch := Chr(FromUnicode[DestCP, ToUnicode[SrcCP, Ord(ch)]]);
  		ConvertChar := Ch;
 	end;

procedure ConvertBuf (SrcCP, DestCP: tCodePage; var Buf; Size: integer);
 	var i: integer;
 	begin
  		for i := 0 to Size - 1 do
   			PChar(@Buf)[i] := Chr(FromUnicode[DestCP, ToUnicode[SrcCP, Ord(PChar(@Buf)[i])]]);
 	end;


function ConvertStr (SrcCP, DestCP: tCodePage; Str: String): String;
 	var i: integer;
 	begin
  		ConvertStr := str;
  		for i := 1 to Length(Str) do
   			ConvertStr[i] := Chr(FromUnicode[DestCP, ToUnicode[SrcCP, Ord(Str[i])]]);
    end;

procedure ConvertStr (SrcCP, DestCP: tCodePage; Str, Out: String);
 	var p, s: pchar;
 	begin
  		p := PChar(Str);
  		s := PChar(Out);
  		while p <> '' do begin
   			s[0] := Chr(FromUnicode[DestCP, ToUnicode[SrcCP, Ord(p[0])]]);
   			inc(p);
   			inc(s);
  		end;
  		s := '';
    end;

function CodePageToStr(CodePage: TCodePage): String;
 	begin
  		case CodePage of
   			cpDOS: CodePageToStr := 'dos';
   			cpKOI: CodePageToStr := 'koi';
   			cpWIN: CodePageToStr := 'win';
   			else CodePageToStr := '???';
  		end;
 	end;

function StrToCodePage(Str: string): TCodePage;
 	begin
  		StrToCodePage := cpWIN;
  		if Str = 'dos' then begin StrToCodePage := cpDOS; exit; end;
  		if Str = 'koi' then begin StrToCodePage := cpKOI; exit; end;
  		if Str = 'win' then begin StrToCodePage := cpWIN; exit; end;
 	end;


function LoCase(SrcCP: TCodePage; Str: String): String;
 	var i: integer;
 	begin
  		LoCase := Str;
  		for i := 1 to length(Str) do
   			LoCase[i] := Chr(FromUnicode[cpDef, UnicodeLower[ToUnicode[SrcCP, Ord(Str[i])]]]);
 	end;

function UpCase(SrcCP: TCodePage; Str: String): String;
 	var i: integer;
 	begin
  		UpCase := Str;
  		for i := 1 to length(Str) do
   			UpCase[i] := Chr(FromUnicode[cpDef, UnicodeUpper[ToUnicode[SrcCP, Ord(Str[i])]]]);
 	end;

procedure init;
	var c: TCodepage;
    	i: integer;
 	begin
  		fillchar(FromUnicode, SizeoF(FromUnicode), Ord('?'));
  		for c := Low(TCodePage) to High(TCodePage) do
   		for i := 0 to $FF do FromUnicode[c, ToUnicode[c, i]] := i;
//		for i := 0 to $FFFF do UnicodeUpper[i] := i;
  		for i := 0 to $FFFF do UnicodeUpper[UnicodeLower[i]] := i;
 	end;

begin
 	init;
end.
