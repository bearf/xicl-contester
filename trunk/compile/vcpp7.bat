set include=c:\Program Files\Microsoft Visual Studio .NET\VC7\include
set lib=c:\Program Files\Microsoft Visual Studio .NET\VC7\lib
set path=c:\Program Files\Microsoft Visual Studio .NET\Common7\IDE\
copy %1%2 "c:\Program Files\Microsoft Visual Studio .NET\VC7\bin\source.cpp" > c:\report\vc7log1.txt
"c:\Program Files\Microsoft Visual Studio .NET\VC7\bin\cl.exe" /W4 /F268435456 /O2 /Oi /EHsc /MD /Gy /DONLINE_JUDGE /Fe%3%4 "c:\Program Files\Microsoft Visual Studio .NET\VC7\bin\source.cpp" > c:\report\vc7log2.txt