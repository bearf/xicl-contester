{$I defines.inc}
unit ttypes;

interface

uses tTimes, SysUtils;

type
  	TRequest = (rqClient, rqTester, rqWaiter, rqAdmin);

const
//��� ���� ������ � ������ �������� �������
  	dbSolveFile = 'solve.src';

//����� ��� ����������� �������
  cStdInput = 'in718456.txt';
  cStdOutput = 'ou718456.txt';

//�������������� ������
  	dbSubmit  = 0;
  	dbTask    = 1;
	dbUser    = 2;

  	InvalidID = -1;   //������������ �������������

//������
	_OK     = 0;    // OK
	_WA     = 1;    // Wrong Answer - ������������ �����
	_PE     = 2;    // ������ ������� ������
	_TL     = 3;    // Time Limit - ���������� ����������� �� �������
	_RE     = 4;    // Runtime Error - ������ ������� ����������
	_FL     = 5;    // Failure - ����� �� �����

	_PC0    = 6;    //
	_PC     = _PC0; //
	_PC1    = 7;    //    �������� �����
	_PC2    = 8;    //
	_PC3    = 9;    //
	_PC4    = 10;   //
//	_PCMAX  = _PC4;

	_ML     = 20;   // Memory Limit - ���������� ������ �� ������
	_CE     = 21;   // Compilation Error - ������ ����������
	_BR     = 22;   // Break - � ������ �������� ��������
	_DL     = 23;   // Dead lock - ���� ������� ������ �� ������, a ����-�� ����� ����� ���

	_NO     = 33;   // ������ :)

//	PCount = _PCMAX - _PC + 1;

//Lo(TSubmitInfo.Status) - not implemented (waiter?)
	SUBMIT_WAIT = 0; //�� ����������� � �� ��������������
	SUBMIT_TEST = 1; //�����������
	SUBMIT_DONE = 2; //��������������
	SUBMIT_SEND = 3; //��������� ��� � �����������
	SUBMIT_FROZEN = 4; //����������, ��������������� ������������ �� ��������
//Hi(TSubmitInfo.Status) = tester

	ltRead = 0;
	ltWrite = 1;

	slash = '\';

	MAXTEST = 500;

TYPE
	PTaskInfo = ^TTaskInfo;
	TTaskInfo = record
                    ID      : integer;    //���������� ����� ������ � ��
                    Name    : String;     //�������� ������
                    Author  : String;     //�����(�) ������
                    TimeLimit: integer;   //����������� �� �������
                    MemoryLimit: integer; //����������� �� ������
                    TestCount: integer;   //���������� ������
                    Input   : string;     //����� ������� ������, ���������� ��������
                    Output  : string;     //����� �������� ������, ���������� ��������
                    point   : array [1..maxtest] of integer; //���� �� ��� �����
                    flag    : array [1..maxtest] of integer; //hz
	end;

//��������� ����� ������
	PTestResult = ^TTestResult;
	TTestResult = record
                      result: integer; //���������
                      point : integer; //����
                      msg   : String;  //�������� ����������
                      inf   : integer; //ok count
                      time  : integer; //����� ������ � ms
                      mem   : integer; //������ � KB
	end;

//��������� ���� ������ ������
	PAllTestResult = ^TAllTestResult;
	TAllTestResult = array [1..maxtest] of TTestResult;

// polia s ID po starus pishutsia SetSubmitInfo
// polia s status po result pishutsia SetSubmitResult
	PSubmitInfo = ^TSubmitInfo;
	TSubmitInfo = record
                      isTaskSolved: boolean; //������ �� ������ � ���������� �������
                      successfulAttemptNum: Integer; //����� �������� �������
                      ID    : integer;     //ID �������
                      user  : integer;     //ID ����������
                      problem: String;
                      contest: Integer;
                      stry  : integer;     //�������
                      stime : TDateTime;   //����-����� �������
//                      lng   : String;      //���� = ����������
                      DOS:    Boolean;
                      bat:    String;
                      TimeMul: Integer;
                      MemoryBuf: Integer;
                      {-}
                      status: integer;     //������ �������
                                             //�� �������� SUBMIT_XXXX
                      {-}
                      result: TTestResult; //��������� ������������
                      testingId: Integer; // ID ������������
//  	                rtest   : TAllTestResult;//��������� �� ������
	end;

	TUserInfo = record
                    id      : integer;
                    name    : String;
                    login   : String;
                    password: String;
	end;

    TTaskResults = array of array of Integer;
    TTeams = array of string;

	Function ResultToStr(cResult: integer): string;

implementation

Function ResultToStr(cResult: integer): string;
 	begin
  		Case cResult mod 100 of
   			_OK: Result := 'OK';
//   			_PC: Result := 'PC';
//  			_PC1.._PC4: Result := 'PC';
//   			_PC1.._PCMAX: Result := 'PC' + Chr(Ord(cResult) - Ord(_PC1) + Ord('1'));
   			_WA: begin Result := '������������ ����� �� ����� ' + IntToStr(cResult div 100); end;
   			_RE: begin Result := '������ ������� ���������� �� ����� ' + IntToStr(cResult div 100); end;
   			_TL: begin Result := '���������� ����������� �� ������� �� ����� ' + IntToStr(cResult div 100); end;
   			_ML: begin Result := '���������� ����������� �� ������ �� ����� ' + IntToStr(cResult div 100); end;
   			_DL: begin Result := '��������� ��������� � ������ �������� �� ����� ' + IntToStr(cResult div 100); end;
   			_CE: Result := '������ ����������';
   			_PE: begin Result := '������ ������� ������ �� ����� ' + IntToStr(cResult div 100); end;
   			_FL: Result := 'Failure';
   			_BR: Result := '� ������ �������� ��������';
   			_NO: Result := '������ :)';
  		else Result := '??'; end;
 	end;

end.
