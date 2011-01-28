set include=c:\Program Files\Microsoft Visual Studio 9.0\VC\include
set lib=c:\Program Files\Microsoft Visual Studio 9.0\VC\lib
copy %1%2 "c:\Program Files\Microsoft Visual Studio 9.0\VC\bin\source.cpp" > c:\contester\report\vc9log1.txt
"c:\Program Files\Microsoft Visual Studio 9.0\VC\bin\cl.exe" /O2 /Oi /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_UNICODE" /D "UNICODE" /EHsc /MD /Gy /Fe%3%4 "c:\Program Files\Microsoft Visual Studio 9.0\VC\bin\source.cpp" > c:\contester\report\vc9log2.txt
