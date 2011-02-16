c:
cd "c:\Program Files\Microsoft Visual Studio 9.0\VC\bin"
copy %1%2 source.cpp > d:\vc9log1.txt
cl.exe /Fe%3%4 source.cpp > d:\vc9log2.txt