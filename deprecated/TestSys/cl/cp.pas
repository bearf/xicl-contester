unit cp;

interface
uses
  ttypes;
const
      cp1251   = 1;
      cp866    = 2;
      koi8r    = 3;

procedure ConvertStr(icp, ocp : integer; s : String; var t : String);

implementation

const
      s_cp1251 = 'ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäå¸æçèéêëìíîïğñòóôõö÷øùúûüışÿ';
      s_cp866  = '€‚ƒ„…ğ†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥ñ¦§¨©ª«¬­®¯àáâãäåæçèéêëìíîï';
      s_koi8r  = 'áâ÷çäå³öúéêëìíîïğòóôõæèãşûıÿùøüàñÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏĞÒÓÔÕÆÈÃŞÛİßÙØÜÀÑ';

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
