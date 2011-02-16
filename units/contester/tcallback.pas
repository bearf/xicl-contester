{$I defines.inc}
unit tCallBack;

interface

uses tTypes;

CONST

 	CB_RUN_INIT=5;
 	//ID=тип запускаемого обьекта CB_RUN_TYPE_XXXX
 	//lParam=адрес string c именем экзешника
 	//wParam=0
 	//result по _BR отменяется

   	CB_RUN_TYPE_NONE=0;     //запустить в этой консоли
   	CB_RUN_TYPE_COMPILE=1;  //compillator - запустить в скрытой консоли
   	CB_RUN_TYPE_SOLUTION=2; //solution - запустить в скрытой консоли
   	CB_RUN_TYPE_CHECKER=3;  //checker - запустить в скрытой консоли
   	CB_RUN_TYPE_SHOW=4;     //запустить в другой консоли

 	CB_RUN_INFO=0;
 	//ID=тип запускаемого обьекта
 	//lParam=TimeUsage
 	//wParam=MemoryUsage
 	//result run прерывается если callback функция возврашает не _NO

 	CB_RUN_DONE=6;
 	//ID=тип запускаемого обьекта
 	//lParam=TimeUsage
 	//wParam=MemoryUsage
 	//result = none

 	CB_TEST_INIT=1;   //инициализация тестирования задачи
 	//id=submitid или InvalidID если неизвесно
 	//lParam=@TaskInfo
 	//wParam=@SubmitInfo or nil
 	//result по _BR тестирование отменяется

 	CB_TEST_START=2;  //запуск теста
 	//id=submitid или InvalidID если неизвесно
 	//lParam=testid
 	//wparam=адресс string c именем экзешника
 	//result по _BR тест пропускается

 	CB_TEST_RESULT=3;
 	//id=submitid или InvalidID если неизвесно
 	//lParam=testid
 	//wParam=@TTestResult
 	//result ни что

 	CB_TEST_DONE=7; //результат тестирования задачи
 	//id=@TaskResult
 	//lParam=@TaskInfo
 	//wParam=@AllTestResult - размер определяет кол-во тестов
 	//       может быть nil только если TaskResult.result=_CE


type
	TCBFunc = function (Msg, ID, lParam, wParam: integer):integer;
	//Единая CallBack функция

	//пробегает по стеку функций из подножья в вершину и вызывет их
	//если функция возвращает не _NO то ответ меняется
	function AllCB(Msg, ID, lParam, wParam: integer):integer;

	//регистрирует функцию в вершину стека
	procedure RegCB(cb: TCBFunc);

	//отменяет регистрацию функции в вершине стека
	//если в ввершине не она, или совсем нет вершины - Fatal "cb async"
	procedure UnregCB(cb: TCBFunc);

	//отменяет регистрацию всех функций
	procedure UnregAllCB;

implementation

uses tLog;

type
 	PCBList = ^TCBList;
 	TCBList = record
		      prev, next: PCBList;
		      cb: TCBFunc;
		  end;

var
 	CBListFirst: PCBList;
 	CBListLast: PCBList;


//пробегает по стеку функций из подножья в вершину и вызывет их
//если функция возвращает не _NO то ответ меняется
function AllCB(Msg, ID, lParam, wParam: integer):integer;
 	var cur: PCBList;
     	ret: integer;
 	begin
    	cur:=CBListFirst;
  		AllCB := _NO;
  		while cur <> nil do begin
   			ret := cur^.cb(Msg, ID, lParam, wParam);
   			if ret <> _NO Then AllCB := Ret;
   			cur := cur^.next;
  		end;
    end;

procedure RegCB(cb: TCBFunc);
 	var x: PCBList;
 	begin
// Создать новый элемент списка
  		new(x);
// Если список не пуст, то у последнего элемента указателю на следующий элемент
// присвоить ссылку на новый элемент
  		if CBListLast <> nil then CBListLast^.next := x;
// Если список пуст, то указателю на первый элемент присвоить ссылку на новый элемент
  		if CBListFirst = nil then CBListFirst := x;
// Записать в новый элемент списка добавляемую функцию
  		x^.cb := cb;
  		x^.next := nil;
  		x^.prev := CBListLast;
// Передвинуть указатель на последний элемент на новый
  		CBListLast := x;
 	end;

procedure UnregCB(cb: TCBFunc);
 	var x: PCBList;
 	begin
// Если список пуст или функция последнего элемента списка не равна функции, которую надо удалить,
// то удаляются все функции
  		if (CBListLast = nil) or (@TCBFunc(CBListLast^.cb) <> @TCBFunc(cb)) then begin
   			UnregAllCB;
   			fatal('cb async');
  		end;
// Удалить последний элемент списка
  		x := CBListLast;
  		CBListLast := x^.prev;
  		if CBListLast <> nil then CBListLast^.next := nil;
  		if CBListFirst = x then CBListFirst := nil;
// Удалить из памяти последний элемент
                freemem(x);
//  		dispose(x);
 	end;

procedure UnregAllCB;
 	var x: PCBList;
 	begin
  		while CBListLast <> nil do begin
   			x := CBListLast;
   			CBListLast := x^.prev;
   			if CBListLast <> nil then CBListLast^.next := nil;
   			if CBListFirst = x then CBListFirst := nil;
   			dispose(x);
  		end;
 	end;

initialization
 	CBListFirst := nil;
 	CBListLast := nil;
finalization
 	if CBListFirst <> nil then begin
  		UnregAllCB;
  		fatal('cb async');
 	end else
  		UnregAllCB;
end.
