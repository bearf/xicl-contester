unit remote;
interface
uses
  Windows,
  winsock,
  sysutils,
  tLog;

procedure send_message(host : string; port : integer; msg : string);

implementation

procedure send_message(host : string; port : integer; msg : string);
const module_log = 'remote::send_message:: ';
Var
 Sock: Integer;
 SocketAddr: TSockAddr;
 WSData: TWSAData;
 buf : PChar;

begin
 fillchar(SocketAddr, sizeof(SocketAddr), 0);

 if WSAStartup(MAKEWORD(2, 2), WSData) <> 0 Then begin
   AddLog(LvlError, module_log+'WSAStartup error');
   exit; //Err('WSA error');
 end;

 Sock:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

 if Sock=INVALID_SOCKET Then begin
   WSACleanup;
   AddLog(LvlError, module_log+'Socket error');
   exit; //Err('Socket error');
 end;

 SocketAddr.sin_family:=AF_INET;
 SocketAddr.sin_port := htons(port);
 SocketAddr.sin_addr.s_addr := inet_addr(PChar(host));

 getmem(buf, length(msg) + 1);
 StrPCopy(buf, msg);
 sendto(Sock, buf^, length(msg), 0, SocketAddr, SizeOf(SocketAddr));
 freemem(buf);
 closesocket(Sock);
 WSACleanup;
end;

end.
