{$I defines.inc}
unit tCallBack;

interface

uses tTypes;

CONST

 	CB_RUN_INIT=5;
 	//ID=��� ������������ ������� CB_RUN_TYPE_XXXX
 	//lParam=����� string c ������ ���������
 	//wParam=0
 	//result �� _BR ����������

   	CB_RUN_TYPE_NONE=0;     //��������� � ���� �������
   	CB_RUN_TYPE_COMPILE=1;  //compillator - ��������� � ������� �������
   	CB_RUN_TYPE_SOLUTION=2; //solution - ��������� � ������� �������
   	CB_RUN_TYPE_CHECKER=3;  //checker - ��������� � ������� �������
   	CB_RUN_TYPE_SHOW=4;     //��������� � ������ �������

 	CB_RUN_INFO=0;
 	//ID=��� ������������ �������
 	//lParam=TimeUsage
 	//wParam=MemoryUsage
 	//result run ����������� ���� callback ������� ���������� �� _NO

 	CB_RUN_DONE=6;
 	//ID=��� ������������ �������
 	//lParam=TimeUsage
 	//wParam=MemoryUsage
 	//result = none

 	CB_TEST_INIT=1;   //������������� ������������ ������
 	//id=submitid ��� InvalidID ���� ���������
 	//lParam=@TaskInfo
 	//wParam=@SubmitInfo or nil
 	//result �� _BR ������������ ����������

 	CB_TEST_START=2;  //������ �����
 	//id=submitid ��� InvalidID ���� ���������
 	//lParam=testid
 	//wparam=������ string c ������ ���������
 	//result �� _BR ���� ������������

 	CB_TEST_RESULT=3;
 	//id=submitid ��� InvalidID ���� ���������
 	//lParam=testid
 	//wParam=@TTestResult
 	//result �� ���

 	CB_TEST_DONE=7; //��������� ������������ ������
 	//id=@TaskResult
 	//lParam=@TaskInfo
 	//wParam=@AllTestResult - ������ ���������� ���-�� ������
 	//       ����� ���� nil ������ ���� TaskResult.result=_CE


type
	TCBFunc = function (Msg, ID, lParam, wParam: integer):integer;
	//������ CallBack �������

	//��������� �� ����� ������� �� �������� � ������� � ������� ��
	//���� ������� ���������� �� _NO �� ����� ��������
	function AllCB(Msg, ID, lParam, wParam: integer):integer;

	//������������ ������� � ������� �����
	procedure RegCB(cb: TCBFunc);

	//�������� ����������� ������� � ������� �����
	//���� � �������� �� ���, ��� ������ ��� ������� - Fatal "cb async"
	procedure UnregCB(cb: TCBFunc);

	//�������� ����������� ���� �������
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


//��������� �� ����� ������� �� �������� � ������� � ������� ��
//���� ������� ���������� �� _NO �� ����� ��������
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
// ������� ����� ������� ������
  		new(x);
// ���� ������ �� ����, �� � ���������� �������� ��������� �� ��������� �������
// ��������� ������ �� ����� �������
  		if CBListLast <> nil then CBListLast^.next := x;
// ���� ������ ����, �� ��������� �� ������ ������� ��������� ������ �� ����� �������
  		if CBListFirst = nil then CBListFirst := x;
// �������� � ����� ������� ������ ����������� �������
  		x^.cb := cb;
  		x^.next := nil;
  		x^.prev := CBListLast;
// ����������� ��������� �� ��������� ������� �� �����
  		CBListLast := x;
 	end;

procedure UnregCB(cb: TCBFunc);
 	var x: PCBList;
 	begin
// ���� ������ ���� ��� ������� ���������� �������� ������ �� ����� �������, ������� ���� �������,
// �� ��������� ��� �������
  		if (CBListLast = nil) or (@TCBFunc(CBListLast^.cb) <> @TCBFunc(cb)) then begin
   			UnregAllCB;
   			fatal('cb async');
  		end;
// ������� ��������� ������� ������
  		x := CBListLast;
  		CBListLast := x^.prev;
  		if CBListLast <> nil then CBListLast^.next := nil;
  		if CBListFirst = x then CBListFirst := nil;
// ������� �� ������ ��������� �������
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
