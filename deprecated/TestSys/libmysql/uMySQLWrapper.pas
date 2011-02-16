unit uMySQLWrapper;

interface

uses
  mysql;

function mySQLConnect(host, userName, password, DBName: String): Boolean;
function mySQLSelectDB(DBName: String): Boolean;
function mySQLSelect(query: String): Boolean;
function mySQLInsert(query: String): Boolean;
function mySQLUpdate(query: String): Boolean;
function mySQLFetchRow: PMYSQL_ROW;
procedure mySQLFreeResult;
procedure mySQLClose;

var
  mySQLLengths: PMYSQL_LENGTHS;

implementation

var
  mySQLSocket   : PMYSQL;                     //MySQL sock
  mySQLQueryResult: PMYSQL_RES;

function mySQLConnect(host, userName, password, DBName: String): Boolean;
begin
  mySQLSocket := mysql_init(nil);

  result := mysql_real_connect(mySQLSocket,
    PChar(host),
    PChar(userName),
    PChar(password),
    PChar(DBName),
    0, nil, 0) <> nil
end;

function mySQLSelectDB(DBName: String): Boolean;
begin
  result := mysql_select_db(mySQLSocket, PChar(DBName)) = 0
end;

function mySQLSelect(query: String): Boolean;
begin
  result := mysql_real_query(mySQLSocket, PChar(query), length(query)) = 0;

  if result then begin
    mySQLQueryResult := mysql_store_result(mySQLSocket);

    result := result and (mySQLQueryResult <> nil)
  end
end;

function mySQLInsert(query: String): Boolean;
begin
  result := mysql_real_query(mySQLSocket, PChar(query), length(query)) = 0
end;

function mySQLUpdate(query: String): Boolean;
begin
  result := mysql_real_query(mySQLSocket, PChar(query), length(query)) = 0
end;

function mySQLFetchRow: PMYSQL_ROW;
begin
  result := mysql_fetch_row(mySQLQueryResult);

  mySQLLengths := mysql_fetch_lengths(mySQLQueryResult)
end;

procedure mySQLFreeResult;
begin
  mysql_free_result(mySQLQueryResult)
end;

procedure mySQLClose;
begin
  mysql_close(mySQLSocket)
end;

end.
