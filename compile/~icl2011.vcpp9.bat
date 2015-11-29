set include=c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\include
set lib=c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\lib;c:\Program Files (x86)\Microsoft SDKs\Windows\v6.0A\Lib
set path=c:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\;c:\windows\system32\;c:\Program Files (x86)\Microsoft SDKs\Windows\v6.0A\Lib
copy %1%2 "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\source.cpp" > c:\report\vc9log1.txt
rem cd "c:\Program Files\Microsoft Visual Studio 9.0\VC\bin"
"c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\cl.exe" /W4 /F268435456 /O2 /Oi /EHsc /MD /Gy /DONLINE_JUDGE /Fe%3%4 "c:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\source.cpp" > c:\report\vc9log2.txt