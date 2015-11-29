call "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
copy %1%2 "C:\tmp1\source.cpp" > C:\report\vc11log1.txt
cl /W4 /F268435456 /O2 /Oi /EHsc /MD /Gy /DONLINE_JUDGE /Fe%3%4 C:\tmp1\source.cpp > C:\report\vc11log2.txt
