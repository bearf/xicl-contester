{$I defines.inc}
unit tConUtils;


interface

uses SysUtils, tTypes, ComCtrls, Graphics, tLog;

{const
 	TrackLength = 12;
 	ScreenWidth = 80;
var
    LineNum, PosNum: integer;

	function gettrack(cur, max:integer):string;

	procedure cleartail(); //заполняет пробелами остаток строки
	                     //и возвращается на место

	procedure cleartailf();//заполняет пробелами остаток строки
	                     //и переходит на начало строки

	procedure OutText(text:string);}

	function Res2Col(Res:integer):char; //цвет результата

{    procedure PrintLN(WriteStr: string);
    procedure Print(WriteStr: string);
    procedure ClearScreen();}

implementation

uses TesterMainUnit;

const
 	TrackCount = 10;
 	UncTrack = '[??????????]';
 	TrackStr: array[0..TrackCount] of string = (
 		'[----------]',
 		'[*---------]',
 		'[**--------]',
 		'[***-------]',
 		'[****------]',
 		'[*****-----]',
 		'[******----]',
 		'[*******---]',
 		'[********--]',
 		'[*********-]',
 		'[**********]');

 	flipcount = 4;
        flip: array[0..flipcount-1] of char = ('-','/','|','\');
{var
    flipidx:integer;

    procedure ClearScreen();
	begin
    	    LineNum := 0;
    	    PosNum := 1;
        end;

    procedure PrintLN(WriteStr: string);
    	begin
            cleartail();
            with TesterMainForm do
            	begin
                    RichEdit.Lines.Strings[LineNum] := RichEdit.Lines.Strings[LineNum] + WriteStr;
                    RichEdit.Lines.Add('');
                end;
            inc(LineNum);
            PosNum := 1;
        end;

    procedure Print(WriteStr: string);
//    	var OldString, AddStr: String;
    	begin
//            OldString := TesterMainForm.RichEdit.Lines.Strings[LineNum];
//            AddStr := '';
//            if PosNum-1 + length(WriteStr) >= length(OldString)
//                then cleartail(LineNum, PosNum)
//                else
//                    begin
//                        StrCopy(PChar(AddStr),PChar(OldString) + PosNum + length(WriteStr));
                        cleartail();
//                    end;
            with TesterMainForm do
            	begin
                    RichEdit.Lines.Strings[LineNum] := RichEdit.Lines.Strings[LineNum] + WriteStr;// + AddStr;
                end;
            PosNum := PosNum + length(WriteStr);
        end;

 	function gettrack(cur, max:integer):string;
  	    begin
   		if cur = -1 then
    		    gettrack := UncTrack
   		else
    		    if max > 0 then begin
                	if cur > max then cur := max;
     			gettrack := TrackStr[cur * TrackCount div max]
    		    end else
     			gettrack:=Format('[%8D]',[cur]);
  	    end;

	procedure cleartail();
 	    var //i: int;
        	NewString: string;
 	    begin
        	with TesterMainForm do
            	begin
//                    NewString := '';
//            	      SetLength(NewString,length(RichEdit.Lines.Strings[LineNum]));
//                    if length(NewString) = 0
//                        then SetLength(NewString,1);
//                    FillChar(NewString, SizeOf(NewString), #0);
//                    if PosNum > 1 then
//            	          StrLCopy(PChar(NewString), PChar(RichEdit.Lines.Strings[LineNum]), PosNum-1);
                    if LineNum<Richedit.Lines.Count then
		    if length(RichEdit.Lines.Strings[LineNum]) >= PosNum then
                    	begin
			    NewString := RichEdit.Lines.Strings[LineNum];
            		    NewString[PosNum] := #0;
            		    RichEdit.Lines.Strings[LineNum] := NewString;
                    	end;
                end
//  		  x := WhereX;
//  		  for i := x to ScreenWidth - 1 do write(#32);
//  		  for i := x to ScreenWidth - 1 do write(#08);
 	    end;

	procedure cleartailf();
 	    var //i: int;
        	NewString: string;
 	    begin
        	with TesterMainForm do
            	    begin
//                        NewString := '';
//            		  SetLength(NewString,length(RichEdit.Lines.Strings[LineNum]));
//                        if length(NewString) = 0
//                    	      then SetLength(NewString,1);
//                        FillChar(NewString, SizeOf(NewString), #0);
//                	  if PosNum > 1
//                    	      then StrLCopy(PChar(NewString), PChar(RichEdit.Lines.Strings[LineNum]), PosNum-1);
			if length(RichEdit.Lines.Strings[LineNum]) >= PosNum then
                    	    begin
				NewString := RichEdit.Lines.Strings[LineNum];
            			NewString[PosNum] := #0;
            			RichEdit.Lines.Strings[LineNum] := NewString;
                    	    end;
            	    end;
                PosNum := 1;
 	    end;      }

	{function Res2Col(Res: integer): char;
 	    begin
  		case Res of
   				_OK: Result := 'A';
   				_PC.._PC4: Result := 'B';
   				_WA: Result := 'C';
   				_RE: Result := 'D';
   				_TL: Result := '9';
   				_DL: Result := '1';
   				_ML: Result := '6';
   				_CE: Result := '4';
   				_PE: Result := 'E';
   				_FL: Result := '8';
   				_BR: Result := '5';
   				_NO: Result := 'F';
  				else Result := 'F';
                end;
 	    end; }

    {procedure OutText(Text: string);
 	var i, c: integer;
            buff: string;
 	begin
            buff := '';
  	    i := 1;
  	    while i <= Length(text) do
   		if text[i] <> '&'
                    then
                    	begin
//                            print(text[i]);
			    buff := buff + text[i];
                            inc(i)
                        end
   		    else
                    	begin
    			    inc(i);
                            print(buff);
                            buff := '';
    			    case text[i] of
                            	'&': print('&');
                                'h','H': begin end;
//     				  'h','H': HighVideo;
                                'l','L': begin end;
//     				  'l','L': LowVideo;
                                'd','D': begin end;
//     				  'd','D': NormVideo;
     				'n','N': println('');
     				'c','C','b','B': begin
       						     inc(i);
       						     case text[i] of
        						 '0': c := clBlack;
        						 '1': c := clNavy;
        						 '2': c := clGreen;
        						 '3': c := clSkyBlue;
        						 '4': c := clRed;
        						 '5': c := clPurple;
        						 '6': c := clMaroon;
        						 '7': c := clLtGray;
        						 '8': c := clDkGray;
        						 '9': c := clBlue;
        						 'a','A': c := clGreen;
        						 'b','B': c := clSkyBlue;
        						 'c','C': c := clRed;
        						 'd','D': c := clPurple;
        						 'e','E': c := clYellow;
        						 'f','F': c := clWhite;
       						     end;
       						     case text[i-1] of
        						 'c','C': begin end;
//        						   'c','C': TesterMainForm.CurrText.Color := c;
        						 'b','B': begin end;
//        						   'b','B': TextBackground(c);
       						     end;
     						 end;
     				's','S': TesterMainForm.ClearBitBtn.Click;
     				'f','F': cleartailf();
     				'e','E': cleartail();
     				'g','G': println('');
     				'p','P': begin
                                	     flipidx := (flipidx + 1) mod flipcount;
                                             print(flip[flipidx]);
                                         end;
                            end;
    			    inc(i);
   			end;
//		  TesterMainForm.RichEdit.Refresh;
		TesterMainForm.Repaint;
 	    end; }

begin
// 	flipidx := 0;
end.