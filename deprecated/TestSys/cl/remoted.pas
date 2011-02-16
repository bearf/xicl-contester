unit remoted;

interface

uses
  Windows, Classes, WinSock;

type
  TUDPDaemon = class(TThread)
  private
     Sock: Integer;
     SocketAddr: Tsockaddr;
     WSData: TWSAData;
     i: Integer;
     Buf: Array [0..1024] of Char;
    procedure MyTerminate(Sender: TObject);
  protected
    procedure Execute; override;
  end;

implementation

uses mysqldb, mainform, tLog;

{ Important: Methods and properties of objects in VCL or CLX can only be used
  in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TUDPDaemon.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TUDPDaemon }

procedure TUDPDaemon.Execute;
const module_log = 'remoted::TUDPDaemon.Execute:: ';
begin
  OnTerminate := MyTerminate;

 if WSAStartup(MAKEWORD(2, 2), WSData) <> 0 Then begin
   AddLog(LvlError, module_log+'WSAStartup error');
   exit; //Err('WSA error');
 end;

 Sock := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
 if INVALID_SOCKET = Sock Then begin
   WSACleanup;
   AddLog(LvlError, module_log+'Socket error');
   exit; //Err('Socket error');
 end;

 SocketAddr.sin_family := AF_INET;
 SocketAddr.sin_port := htons(client_port);
 SocketAddr.sin_addr.S_addr := INADDR_ANY;
 SocketAddr.sin_addr.S_addr := inet_addr('0.0.0.0');

 if 0 <> Bind(Sock, SocketAddr, SizeOF(SocketAddr)) Then begin
   WSACleanup;
   AddLog(LvlError, module_log+'Bind error');
   exit; //Err('Bind error');
 end;

 while not Terminated do begin
  FillChar(Buf, SizeOF(Buf), 0);
  i := recv(Sock, buf, 1024, 0);
  if i <> SOCKET_ERROR then begin
  	updateflag := True;
    if buf = 'updateall' then
      Synchronize(main.UpdateAll)
    else
      Synchronize(main.UpdateLastResult);
  end;
 end;

end;

procedure TUDPDaemon.MyTerminate(Sender: TObject);
begin
 CloseSocket(Sock);
 WSACleanup;
end;

end.
