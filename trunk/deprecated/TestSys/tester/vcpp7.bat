set include=c:\Program Files\Microsoft Visual Studio .NET\VC7\include
set lib=c:\Program Files\Microsoft Visual Studio .NET\VC7\lib
set path=c:\Program Files\Microsoft Visual Studio .NET\Common7\IDE\
copy %1%2 "c:\Program Files\Microsoft Visual Studio .NET\VC7\bin\source.cpp" > c:\report\vc7log1.txt
"c:\Program Files\Microsoft Visual Studio .NET\VC7\bin\cl.exe" /O2 /Oi /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_UNICODE" /D "UNICODE" /EHsc /MD /Gy /Fe%3%4 "c:\Program Files\Microsoft Visual Studio .NET\VC7\bin\source.cpp" > c:\report\vc7log2.txt