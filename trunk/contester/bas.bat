cd d:\soft\qb
bc.exe %1%2 solve.obj /o;
link.exe solve.obj;
copy solve.exe %3%4