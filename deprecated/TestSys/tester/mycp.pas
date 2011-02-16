unit mycp;

interface
uses
  	ttypes, SysUtils;
const
	cp1251   = 1;
	cp866    = 2;
	koi8r    = 3;

	procedure ConvertStr(icp, ocp : integer; s : String; var t : String);
	function locase(cp : integer; t : ansistring) : ansistring;

implementation

const
	s_cp1251 = 'ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÜÚÛŞİßàáâãäå¸æçèéêëìíîïğñòóôõö÷øùüúûşıÿ';
	s_cp866  = '€‚ƒ„…ğ†‡ˆ‰Š‹Œ‘’“”•–—˜™œš›Ÿ ¡¢£¤¥ñ¦§¨©ª«¬­®¯àáâãäåæçèéìêëîíï';
	s_koi8r  = 'áâ÷çäå³öúéêëìíîïğòóôõæèãşûıøÿùàüñÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİØßÙÀÜÑ';

function locase(cp : integer; t : ansistring) : ansistring;
	var s1, s2 : string;
	    i, j   : integer;
	begin
  		case cp of
    		cp1251 : begin
    		           s1 := copy(s_cp1251, 1, length(s_cp1251) div 2);
    		           s2 := s_cp1251;
    		         end;
    		cp866  : begin
    		           s1 := copy(s_cp866, 1,  length(s_cp866) div 2);
    		           s2 := s_cp866;
    		         end;
    		koi8r  : begin
    		           s1 := copy(s_koi8r, 1,  length(s_koi8r) div 2);
    		           s2 := s_koi8r;
    		         end;
  		end;
  		for i := 1 to length(t) do begin
    		j := pos(t[i], s1);
    		if j > 0 then
    	  		t[i] := s2[j + length(s1)];
    		if t[i] in ['A'..'Z'] then
    	  		t[i] := chr(ord(t[i])+32);
  		end;
  		locase := t;
	end;

procedure ConvertStr(icp, ocp : integer; s : String; var t : String);
	var s1, s2 : string;
	    i, j   : integer;
	begin
  		if icp = ocp then begin
    		t := s;
    		exit;
  		end;
  		case icp of
    		cp1251 : s1 := s_cp1251;
    		cp866  : s1 := s_cp866;
    		koi8r  : s1 := s_koi8r;
  		end;
  		case ocp of
    		cp1251 : s2 := s_cp1251;
    		cp866  : s2 := s_cp866;
    		koi8r  : s2 := s_koi8r;
  		end;
  		t := s;
  		for i := 0 to 255 do begin
    		j := pos(t[i], s1);
    		if j > 0 then
      			t[i] := s2[j];
  		end;
	end;

end.
