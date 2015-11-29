set include=c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\include
set lib=c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib;
set path=c:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\;c:\windows\system32\;
copy %1%2 "C:\tmp\source.cpp" > c:\report\vc11log1.txt
rem cd "C:\tmp"
"c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\cl.exe" /W4 /F268435456 /O2 /Oi /EHsc /MD /Gy /DONLINE_JUDGE /Fe%3%4 "C:\tmp\source.cpp" > c:\report\vc11log2.txt
