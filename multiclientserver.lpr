program multiclientserver;
{$IFDEF UNIX}
{$DEFINE USECTHREADS}
{$ENDIF}
uses
    {$IFDEF UNIX}
    cthreads,
    {$ENDIF}
    blcksock,classes,sysutils,Contnrs;

var
  ClientList:TFPObjectList;
  ClientListBouncer:TRTLCriticalSection;
  listener:TTCPBlockSocket;
  clientid:integer;

type

  { TClient }

  TClient = class(TThread)
    public
      tcpconnection:TTCPBlockSocket;
      myclientid:integer;
      username:string;
      constructor Create(CreateSuspended:boolean;socket:LongInt);
      procedure BroadcastToAll(msg:String);
      procedure RemoveFromList(idclient:integer);
    protected
      procedure Execute; override;
  end;


procedure TClient.BroadcastToAll(msg:String);
var
  i,counts:integer;
begin
  EnterCriticalSection(ClientListBouncer);
  for i := 0 to ClientList.Count - 1 do
  begin
    TClient(ClientList.Items[i]).tcpconnection.SendString(msg+crlf);
  end;
  LeaveCriticalSection(ClientListBouncer);
end;

procedure TClient.RemoveFromList(idclient:integer);
var
  tempid:integer;
begin

  BroadcastToAll('!!! <'+username+'> has left the chat!');


  EnterCriticalSection(ClientListBouncer);

  //writeln('Clients before remove: '+inttostr(ClientList.Count));
  ClientList.Remove(self);
  //writeln('Clients after remove: '+inttostr(ClientList.Count));
  writeln('Clients: '+inttostr(ClientList.Count));

  LeaveCriticalSection(ClientListBouncer);

  //writeln('Client ********'+inttostr(tempid)+'********* removed from list!');
end;

{ TClient }

constructor TClient.Create(CreateSuspended: boolean; socket: LongInt);
begin
  FreeOnTerminate:=true;
  tcpconnection:=TTCPBlockSocket.Create;
  username:='user'+inttostr(round(GetTickCount));
  tcpconnection.Socket:=socket;
  inherited Create(CreateSuspended);
end;

procedure TClient.Execute;
var
  msg,oldusername:string;
begin
  tcpconnection.SendString('Hello and welcome to my server!'+crlf);
  tcpconnection.SendString('Your current username is: '+username+CRLF);

  BroadcastToAll('!!! <'+username+'> has joined the chat!');

  while not(Terminated) do
  begin
    msg:=tcpconnection.RecvString(1000);

    if tcpconnection.LastError <> 0 then
    begin
      //writeln(tcpconnection.GetErrorDescEx);
      if lowercase(tcpconnection.GetErrorDescEx) = 'connection reset by peer' then
      begin
        //writeln('removing '+inttostr(myclientid));
        RemoveFromList(myclientid);
        tcpconnection.CloseSocket;
        tcpconnection.Free;
        Terminate;
      end;
    end;

    if trim(msg) <> '' then
    begin
      if not(lowercase(copy(trim(msg),1,5)) = '/nick') then
      begin
        BroadcastToAll('<'+username+'>: '+msg);
        msg:='';
      end
      else
      begin
        oldusername:=username;
        username:=copy(trim(msg),7);
        BroadcastToAll(oldusername+' changed their name to '+username);
      end;
    end;
  end;
end;

var
  aclientlist:array of TClient;

begin
  writeln('Allocating memory...');
  clientlist:=TFPObjectList.Create(false);
  listener:=TTCPBlockSocket.Create;
  writeln('Binding to 0.0.0.0:1234');
  listener.Bind('0.0.0.0','1234');
  listener.Listen;
  writeln('Listening');
  InitCriticalSection(ClientListBouncer);
  while true do
  begin
    clientid:=ClientList.Add(TClient.Create(true,listener.Accept));
    TClient(ClientList.Items[clientid]).myclientid:=clientid;
    TClient(ClientList.Items[clientid]).Start;
    //writeln('Client ********'+inttostr(clientid)+'********* added to list!');
    //writeln('Client Connected!');
    writeln('Clients: '+inttostr(ClientList.Count));
  end;
  DoneCriticalSection(ClientListBouncer);
end.

