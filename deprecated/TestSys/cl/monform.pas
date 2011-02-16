unit monform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ttypes, ExtCtrls, Menus, ttimes, tConfig, DateUtils;

const minFirstColWidth = 64;

type
  tmyuser = record
    id    : integer;
    point : integer;
  end;

  TUserType = (utClient, utServer);

  Tmon = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;
    SpeedButton4: TSpeedButton;
    DrawGrid1: TDrawGrid;
    PopupMenu1: TPopupMenu;
    RefreshItem: TMenuItem;
    N2: TMenuItem;
    SaveHTMLItem: TMenuItem;
    SaveTextItem: TMenuItem;
    N4: TMenuItem;
    CloseItem: TMenuItem;
    SaveDialog1: TSaveDialog;
    N1: TMenuItem;
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CloseItemClick(Sender: TObject);
    procedure RefreshItemClick(Sender: TObject);
    procedure SaveHTMLItemClick(Sender: TObject);
    procedure SaveTextItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    mtaskcount, musercount : integer;
    fullpoint              : array of integer;
    users                  : array of tmyuser;
    grid									 : array of array of String;
//    frozen								 : Boolean;
    userType               : TUserType;
	  ptr										 : array of Integer;

//    procedure Refresh;
    procedure CloseMonitor;
//    procedure SaveAsHTML;
//    procedure SaveAsText;
    procedure GetGrid;
    procedure ReCalcSize;

//    function		GetCaption:	String;
  public
    { Public declarations }
    Procedure   ShowMonitor(AUserType: TUserType);
  end;

var
  mon: Tmon;
  TaskResults: TTaskResults;
  Teams: TTeams;

implementation

uses mysqldb, Types;

{$R *.dfm}

procedure Tmon.SpeedButton4Click(Sender: TObject);
begin
	Close
end;

function iif (exp : boolean; a, b : integer) : integer;
begin
  if exp then
    result := a
  else
    result := b;
end;

function mon_calc(mon : TMonCell) : integer;
begin
//  result := iif(mon.point - mon.stry*3 > 0, mon.point - mon.stry*3, 0);
  result := iif (mon.point > 0 , mon.point, 0);
end;

procedure Tmon.FormShow(Sender: TObject);
begin
  Timer1Timer(nil);
  Timer1.Enabled := true;
end;

procedure Tmon.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := false;
//  db_free_monitor;
  setlength(fullpoint, 0);
  setlength(taskresults, 0, 0);
  setLength(teams, 0);
  SetLength(grid, 0);
  SetLength(ptr, 0);
end;

procedure Tmon.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var s : string;
    flag : integer;
    r   : TRect;
    spaces: String;
begin
	flag := DT_CENTER;
	s := grid[ARow, ACol];

  r.Left   := Rect.Left + 2;
  r.Top    := Rect.Top + 2;
  r.Right  := Rect.Right - 2;
  r.Bottom := Rect.Bottom - 2;

  spaces := '';
  if (ACol > 1)or((ACol=0)and(ARow>0)) then
  	while DrawGrid1.Canvas.TextWidth(spaces) < (DrawGrid1.ColWidths[ACol] - DrawGrid1.Canvas.TextWidth(s)) div 2 do
    	spaces := spaces + ' ';
  s := spaces + s;
  while DrawGrid1.Canvas.TextWidth(s) < DrawGrid1.ColWidths[ACol] do
  	s := s + ' ';

  if (ARow = 0) then
  	DrawGrid1.Canvas.Font.Color := clWhite
  else
  	DrawGrid1.Canvas.Font.Color := clBlack;

	if (ARow > 0) and (Teams[ptr[ARow-1]] = curuser.name) then
  	DrawGrid1.Canvas.Brush.Color := RGB(192, 192, 255)
  else if (ARow = 0) then
  	DrawGrid1.Canvas.Brush.Color := clActiveCaption
  else
  	DrawGrid1.Canvas.Brush.Color := clWhite;

	DrawGrid1.Canvas.FillRect(DrawGrid1.CellRect(ACol, ARow));
  DrawGrid1.Canvas.Pen.Color := clWhite;
  DrawGrid1.Canvas.Rectangle(DrawGrid1.CellRect(ACol, ARow));
  DrawText(DrawGrid1.Canvas.Handle, PChar(s), length(s), r, flag);
end;

procedure Tmon.Timer1Timer(Sender: TObject);
begin
	Refresh
end;

procedure Tmon.FormResize(Sender: TObject);
begin
	ReCalcSize
end;

{procedure	TMon.Refresh;
var
	deadline:	TDateTime;
begin
{	if (db_get_seconds_left <= 3600)and(frozen) then
    	deadline := IncHour(db_get_finish_time, -1)
    else
    	deadline := db_get_finish_time;}

{    deadline := db_get_finish_time;
    if userType = utServer then
      db_get_full_monitor_s(TaskResults, Teams, mtaskcount, musercount, deadline)
    else
      db_get_full_monitor(TaskResults, Teams, mtaskcount, musercount);
    setlength(fullpoint, mtaskcount);
    setlength(users, musercount);
    DrawGrid1.RowCount := musercount + 1;
    DrawGrid1.ColCount := mtaskcount + 4;

    GetGrid;
    DrawGrid1.Invalidate;
//    ReCalcSize;

    Caption := GetCaption
end;}


procedure Tmon.CloseItemClick(Sender: TObject);
begin
	Close
end;

procedure	TMon.CloseMonitor;
begin
	Timer1.Enabled := False;
    close
end;

procedure Tmon.RefreshItemClick(Sender: TObject);
begin
	Refresh
end;

{procedure Tmon.SaveAsHTML;
var
	i, j:	Integer;
  f:		TextFile;
begin
  if not SaveDialog1.Execute then
  	exit;

  SaveDialog1.FilterIndex := 2;
  assignfile(f, SaveDialog1.FileName);
  rewrite(f);

  writeln(f, '<HTML><BODY><font face="Tahoma">');
  writeln(f, '<table width=100%><tr><td align=center>'+GetCaption+'</td></tr></table>');
  writeln(f, '<table align=center border=1 cellpadding=4 cellspacing=0><tr>');
  writeln(f, '</tr>');
  writeln(f, '<hr><br>');

  for i := 0 to musercount do begin
  	if i<=0 then
	  	write(f, '<tr bgcolor=#2020ff>')
    else
	  	write(f, '<tr bgcolor=#ffffff>');
  	for j := 0 to mtaskcount+3 do begin
    	if (i=0)or(j<>1) then
        if (j>1)and(j<mtaskcount+3) then
  	    	write(f, '<td align=center width=32>')
        else
          write(f, '<td align=center>')
      else
        write(f, '<td>');
      if i>0 then
        write(f, '<font color=#000000>')
      else
        write(f, '<font color=#ffffff>');
      write(f, grid[i,j]+'</font></td>');
    end;
    writeln(f, '</tr>');
  end;

	writeln(f, '</table>');
  writeln(f, '</font></BODY></HTML>');
  closefile(f);
end;}

{procedure	Tmon.SaveAsText;
var
	max:	array of integer;
  f:		TextFile;

function space(N: Integer): String;
var
	i:	Integer;
begin
	Result := '';
  for i := 1 to N do Result := Result + ' ';
end;

var
	i, j:	Integer;
  sum:	Integer;
  cap:	String;
  N:		Integer;
begin
  if not SaveDialog1.Execute then
  	exit;

  SaveDialog1.FilterIndex := 0;
  assignfile(f, SaveDialog1.FileName);
  rewrite(f);

  SetLength(max, Length(grid[0]));
  sum := 0;
  for j := 0 to high(grid[0]) do begin
  	max[j] := 4;
    for i := 0 to High(grid) do
    	if Length(grid[i][j])>max[j] then max[j] := Length(grid[i][j]);
    inc(max[j]);
    sum := sum + max[j];
  end;

  cap := GetCaption;
  writeln(f, space((sum-Length(cap))div 2), cap);
  for i := 0 to High(grid) do begin
  	for j := 0 to High(grid[i]) do begin
    	if j<=1 then
      	write(f, grid[i][j], space(max[j]-Length(grid[i][j])))
      else begin
      	N := (max[j]-Length(grid[i][j])) div 2;
      	write(f, space(N), grid[i][j], space(N), space(max[j]-Length(grid[i][j])-N-N))
      end
    end;
    writeln(f);
  end;

  closefile(f);
end;}

{procedure Tmon.SaveHTMLItemClick(Sender: TObject);
begin
	SaveAsHTML
end;}

{procedure Tmon.SaveTextItemClick(Sender: TObject);
begin
	SaveAsText
end;}

procedure tmon.GetGrid;
var
	ACol, ARow:	Integer;
  s:					String;
  res:				Integer;
  i, j, t, p:	Integer;
begin
	SetLength(grid, 0);
  SetLength(grid, musercount+1, mtaskcount+4);
  SetLength(ptr, 0);
  SetLength(ptr, musercount);

  for i := 0 to musercount-1 do ptr[i] := i;
  for i := 0 to musercount-1 do begin
  	p := i;
    for j := i+1 to musercount-1 do
    	if (taskresults[ptr[j], mtaskcount]>taskresults[ptr[p], mtaskcount])or
         ((taskresults[ptr[j], mtaskcount]=taskresults[ptr[p], mtaskcount])and
					(taskresults[ptr[j], mtaskcount+1]<taskresults[ptr[p], mtaskcount+1]))or
         ((taskresults[ptr[j], mtaskcount]=taskresults[ptr[p], mtaskcount])and
					(taskresults[ptr[j], mtaskcount+1]<taskresults[ptr[p], mtaskcount+1])and
          (teams[ptr[j]]<teams[ptr[p]]))  then
          	p := j;
   	t := ptr[p]; ptr[p] := ptr[i]; ptr[i] := t;
  end;

  for ARow := 0 to musercount do
  	for ACol := 0 to mtaskcount+3 do begin
		  if (ARow = 0) and (ACol = 0) then
      	s := ' Место'
      else if (ARow = 0) and (ACol = 1) then
		  	s := ' Команда'
      else if (ARow = 0) And (ACol > 1) And (ACol <= mtaskcount+1) then
		    s := chr(ord('A')+ACol-2)
      else if (ARow = 0) And (ACol = mtaskcount + 2) then
		    s := ' ='
      else if (ARow = 0) And (ACol = mtaskcount + 3) then
		    s := ' Время'
      else if (ACol = 0) And (ARow > 0) then
		    s := ' '+IntToStr(ARow)
			else if (ACol = 1) And (ARow > 0) then
		    s := ' '+Teams[ptr[ARow-1]]
			else if (ARow > 0) And (ACol > 1) then begin
		    if ACol<=mtaskcount+1 then begin
	        res := TaskResults[ptr[ARow-1],ACol-2];
          if res=0 then
          	s:='.'
          else
						if res mod 10 = 1 then begin
							s:='+';
              if res div 10 <> 1 then s:=s+IntToStr(res div 10 - 1);
            end
            else
            	s:='-'+IntToStr(res div 10)
        end
		    else s:=IntToStr(TaskResults[ptr[ARow-1],ACol-2]);
		  end;
      grid[ARow, ACol] := s
    end;
end;

procedure tMon.ReCalcSize;
var FirstColWidth: integer;
begin
    FirstColWidth := DrawGrid1.Width - DrawGrid1.DefaultColWidth * (DrawGrid1.ColCount - 2) - minFirstColWidth;
    if FirstColWidth < minFirstColWidth then
        begin
            mon.Width := mon.Width + minFirstColWidth - FirstColWidth;
            FirstColWidth := minFirstColWidth;
        end;
    DrawGrid1.ColWidths[0] := minFirstColWidth;
    DrawGrid1.ColWidths[1] := FirstColWidth;
    DrawGrid1.Invalidate
end;

{function TMon.GetCaption: String;
var sHour, sMin, sSec: String;
    time, left, len: TDateTime;
    Hour, Min, Sec, MSec: Word;
    seconds_left: integer;
    allow_froze:  Boolean;
    froze_time:   Integer;
begin
    time := db_get_cur_time;
    left := db_get_time_left;
    seconds_left := db_get_seconds_left;
    allow_froze  := db_get_allow_froze;
    froze_time   := db_get_froze_time;

    if time<0 then
    	Result := 'Монитор: 0:00:00 [тур не начат]'
    else if (left<0)and((not allow_froze)or(usertype=utServer)) then begin
    	len := db_get_contest_length;
      DecodeTime(len, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
	    if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
	    Result := 'Монитор: '+sHour+':'+sMin+':'+sSec+' [Тур завершен]';
    end
    else if ((seconds_left<=froze_time)or(left<0))and(allow_froze)and(usertype=utClient) then begin
    	len := IncSecond(db_get_contest_length, -froze_time);
      DecodeTime(len, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
	    if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
	    Result := 'Монитор: '+sHour+':'+sMin+':'+sSec+' [Заморожен]';
    end
    else begin
      DecodeTime(time, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
	    if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
	    Result := 'Монитор: '+sHour+':'+sMin+':'+sSec;
    end
end;}

Procedure TMon.ShowMonitor(AUserType: TUserType);
begin
  UserType := AUserType;
  ShowModal
end;

procedure Tmon.FormCreate(Sender: TObject);
begin
  UserType := utClient
end;

procedure Tmon.N1Click(Sender: TObject);
begin
  ReCalcSize
end;

end.
