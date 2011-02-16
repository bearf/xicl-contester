{$O-}
unit TesterThreadUnit;

interface

uses Windows, SysUtils, Classes, WinSock, ttypes, tConfig, tConUtils, db, tCallBack, tConVis, tlog, tsys, tTimes;

type
    TTesterThread = class(TThread)
    private
        FTesterStarted: boolean;
    protected
        procedure Execute; override;
        procedure SetTesterStarted(Value: boolean);
        function GetTesterStarted: boolean;
        procedure OnTerminateThread(Sender: TObject);
    public
        constructor Create();
        procedure Err(msg: String);
        procedure Done();
        procedure Finishing();
        procedure ChangeStatus;
        procedure SetFalseTesterStarted;
        procedure send_message(a: TSockAddr; msg : PChar);
        procedure Test(id: integer);
        procedure ttConVisCB();
        procedure callConVisCB();
//        procedure RecalcMonitor();
//        procedure PrepareMonitor();
        property TesterStarted: boolean read GetTesterStarted write SetTesterStarted;
    end;

const
    port = 8100;
    clport = 8101;
    scantime = 3;

Var
    S: Integer;
    A: Tsockaddr;

    FDS : TFDSet;
    d: TWSAData;
    i: integer;
    j: integer;
    Buf: Array [0..1024] of Char;
    cl : TSockAddr;

    taskcount  : integer;
    SubmitInfo : TSubmitInfo;
    tv         : TimeVal;
    fl         : boolean;
    testerdir  : string;


implementation

uses TesterMainUnit;

{procedure TTesterThread.RecalcMonitor();
begin
    dbRecalcMonitor;
end;

procedure TTesterThread.PrepareMonitor();
begin
    dbPrepareMonitor;
end;}

procedure TTesterThread.callConVisCB();
begin
    Synchronize(ttConVisCB);
end;

procedure TTesterThread.ttConVisCB();
begin
    mConVisCB();
end;

procedure TTesterThread.OnTerminateThread(Sender: TObject);
begin
    TesterMainForm.TerminateThread;
end;

function TTesterThread.GetTesterStarted: boolean;
begin
    result := FTesterStarted;
end;

procedure TTesterThread.SetTesterStarted(Value: boolean);
begin
    FTesterStarted := Value;
end;

// ����� ��������� �� ������
procedure TTesterThread.Err(msg: String);
Begin
    AddLog(LvlError, msg);
End;

// ���������� ������
procedure TTesterThread.Done();
begin
    Err('Exiting...');
    CloseSocket(S);
    Synchronize(SetFalseTesterStarted);
end;

procedure TTesterThread.Finishing();
begin
//
end;

procedure TTesterThread.SetFalseTesterStarted;
begin
    TesterMainForm.TesterStarted := false;
end;

procedure TTesterThread.ChangeStatus;
begin
    if TesterStarted
    	then
            begin
            	TesterMainForm.DisableControls();
            	TesterMainForm.TesterBitBtn.Caption := '����';
  		fl := true;
  		testerdir := ExtractFilePath(paramStr(0));
  		if WSAStartup(MAKEWORD(2, 2), D) <> 0 Then Err('WSA error');

  		S:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  		if S=INVALID_SOCKET Then Err('Socket error');

  		A.sin_family      := AF_INET;
  		A.sin_port        := htons(Port);
  		A.sin_addr.S_addr := INADDR_ANY;

  		if Bind(S, A, SizeOF(A))<>0 Then Err('Bind error');

		// ��������� RegCB {tcallback} ������������ ������� ConVisCB {tconvis} � ������ �����
  		RegCB(@ConVisCB);
            end
        else
            begin
            	TesterMainForm.TesterBitBtn.Caption := '�����';
  		CloseSocket(s);
  		WSACleanup;
  		UnregCB(@ConVisCB);
                TesterMainForm.EnableControls();
            end;
end;

procedure TTesterThread.send_message(a: TSockAddr; msg : PChar);
Var S: Integer;
begin
    S := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if S = INVALID_SOCKET Then
   	exit; //Err('Socket error');
    sendto(s, msg, strlen(msg), 0, A, SizeOf(A));
    closesocket(s);
end;

procedure TTesterThread.Test(id: integer);
var SubmitInfo: TSubmitInfo;
    ec: integer;
begin
    if not GetInfo(dbSubmit, ID, SubmitInfo)
    	then
            begin
    		AddLog(LvlError, 'submit ' + IntToStr(id) + ' not found');
    		exit;
  	    end;
    ec := TestSubmit(SubmitInfo);

    if (SubmitInfo.result.result <> _FL)
    	then SubmitInfo.status := SUBMIT_DONE
  	else
            begin
    		SubmitInfo.Status := Submit_Frozen;
    		AddLog(LvlError, 'FAAAAAAATTTAAAALLLLLL EEEEERRROOOORRR !!!!! - core dumped '#2);
  	    end;

    //Upload ���������� ������ ���� �� ������ ������...
    if SubmitInfo.result.result<>_BR
    	then
            begin
   		        tConUtils.print('upload result... ');

                //��������� ���������� � ������� Submit
                if not SetInfo(dbSubmit, SubmitInfo.ID, SubmitInfo)
                    then tConUtils.println('error')
   		            else tConUtils.println('ok');

                //��������� ���������� � �������� Volume � Monitor
                UpdateVolume(SubmitInfo);  

                // ��� ������ - ������ ��� ������ ����!!!!!
                //if not isMonitorFrozen(SubmitInfo) then
                  UpdateMonitor(SubmitInfo);
            end
        else tConUtils.println('result not uploaded - BR ');
end;

constructor TTesterThread.Create();
begin
    inherited Create(False);
    self.OnTerminate := OnTerminateThread;
end;

procedure TTesterThread.Execute;
var i: integer;
begin
    FreeOnTerminate := true;
    while not Terminated and TesterStarted do
        begin
        	    // ����������� ������� ������
            	    FD_Zero (FDS);
            	    FD_Set (s,FDS);
            	    tv.tv_sec := scantime;
            	    j := WinSock.Select (1,@FDS,nil,nil,@tv);
        	    // ���� ����� s ����������� ��������� FDS
            	    if FD_ISSET(s,FDS) then begin
              		fl := true;
        		// ���������� ������ ��� ������ ��������� �� ������
              		FillChar(Buf, SizeOF(Buf), 0);
              		j := sizeof(cl);
        		// ������ ��������� �� ������ s � ����� buf � ������ ���������� �� ����������� � ����� cl
              		i := recvfrom(s, buf, 1024, 0, cl, j);
              		if (TesterStarted) and (i=SOCKET_ERROR) Then
                	    Err('Recv error');
        		// � ��������� ������ ���� ������ �����,
        		// ������� ������������� �� ���������� ���� � �����,
        		// ���� ��� �������������� ��������� ������, �� �� ��������� ������� ��������, ������ 0
              		j := StrToIntDef(buf, 0);

        		// ���� ������� ���������� �������������
              		if j > 0 then begin
        		    // ������������ submit'� � ��������������� j
                	    Test(j);
        		    // ����������� ����� cl � ����������� �� �����������
                	    cl.sin_family      := AF_INET;
                	    cl.sin_port        := htons(clport);
        		    // ������������ ��������� ����������� ������������� ??? ��� �������� buf ???
                	    send_message(cl, buf);
              		end;

                    end else begin
              		taskcount := ReadTesterSubmits;
              		if taskcount = 0 then
                	    fl := false
              		else
                	    fl := true;
              		for i := 0 to taskcount - 1 do if GetSubmitBynum(i, SubmitInfo) then begin
        		    if not TesterStarted then begin
                 		done();
                 		break;
                	    end;
                	    j := SubmitInfo.id;
                	    Test(j);
              		end;
            	    end;
        end;
end;

end.
