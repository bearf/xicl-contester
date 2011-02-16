unit resform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ttimes, ttypes;

type
  Tres = class(TForm)
    SpeedButton4: TSpeedButton;
    DrawGrid1: TDrawGrid;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SaveDialog1: TSaveDialog;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    tasks   : array of TTaskInfo;
    submits : array of TSubmitInfo;
    function lookup_task_name(taskid: integer): string;
  public
    { Public declarations }
    d_from, d_to : TDateTime;
  end;

var
  res: Tres;

implementation

uses mysqldb;

{$R *.dfm}

procedure Tres.SpeedButton4Click(Sender: TObject);
begin
  close;
end;

procedure Tres.FormShow(Sender: TObject);
var i : integer;
    t : boolean;
begin
  submitcount := db_read_submits(curuser.id, d_from, d_to);
  Caption := 'Результаты с ' + FormatDateTime('DD.MM.YYYY', d_from) + ' по ' + FormatDateTime('DD.MM.YYYY', d_to);
//  messagebox(0, PChar(FormatDateTime(date_time_format, d_from) + '-' + FormatDateTime(date_time_format, d_to)), '', 0);
  if submitcount = 0 then begin
    DrawGrid1.RowCount := 2;
    SpeedButton2.Enabled := false;
  end else begin
    DrawGrid1.RowCount := submitcount + 1;
    SpeedButton2.Enabled := true;
  end;
  setlength(tasks, taskcount);
  for i := 0 to taskcount - 1 do
    db_get_task_bynum(i, tasks[i]);
  setlength(submits, submitcount);
  for i := 0 to submitcount - 1 do
    db_get_submit_bynum(i, submits[i]);
  if submitcount <> 0 then begin
    DrawGrid1.Row := DrawGrid1.RowCount - 1;
  end;
  DrawGrid1SelectCell(nil, 0, DrawGrid1.Row, t);
end;

procedure Tres.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var flag   : integer;
    s      : string;
    status : integer;
begin
  if Arow = 0 then begin
    case ACol of
      0  : s := 'Задача';
      1  : s := 'Поп.';
      2  : s := 'Время посылки';
    end;
    flag := DT_CENTER or DT_VCENTER;
  end else begin
    if ARow > high(submits)+1 then
      exit;
    flag := DT_VCENTER;
    status := Lo(submits[Arow - 1].status);
    case ACol of
      0  : s := lookup_task_name(submits[Arow - 1].task);
      1  : s := inttostr(submits[Arow - 1].stry);
      2  : s := FormatDateTime(date_time_format, submits[Arow - 1].stime);
    end;
  end;
  DrawText(DrawGrid1.Canvas.Handle, PChar(s), length(s), Rect, flag);
end;

procedure Tres.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  setlength(submits, 0);
  setlength(tasks, 0);
end;

function Tres.lookup_task_name(taskid: integer): string;
var i : integer;
    t : TTaskInfo;
begin
  for i := low(tasks) to high(tasks) do
    if tasks[i].id = taskid then begin
      result := tasks[i].Name;
      exit;
    end;
  if db_get(dbTask, taskid, rqClient, false, t) then
    result := t.name
  else
    result := '';  
end;

procedure Tres.SpeedButton1Click(Sender: TObject);
var i : integer;
    t : boolean;
begin
  for i := low(submits) to high(submits) do
    if (lo(submits[i].status) = SUBMIT_WAIT) or (lo(submits[i].status) = SUBMIT_TEST) then begin
      db_get(dbSubmit, submits[i].id, rqClient, true, submits[i]);
    end;
  DrawGrid1.Refresh;  
  DrawGrid1SelectCell(nil, 0, DrawGrid1.Row, t);
end;

procedure Tres.SpeedButton2Click(Sender: TObject);
var t : string;
begin
  if SaveDialog1.Execute then begin
    StrCopy(PChar(t), PChar(SaveDialog1.filename));
    db_get_solve(submits[DrawGrid1.Row-1].id, t);
  end;
end;

procedure Tres.DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if ARow > high(submits)+1 then begin
    Label2.Caption  := '';
    Label4.Caption  := '';
    Label6.Caption  := '';
    Label8.Caption  := '';
    Label10.Caption := '';
    Label12.Caption := '';
    Label14.Caption := '';
    Label16.Caption := '';
    Label18.Caption := '';
    exit;
  end;
  with submits[Arow-1] do begin
    Label2.Caption := lookup_task_name(task);
    Label4.Caption := inttostr(stry);
    Label6.Caption := FormatDateTime(date_time_format, stime);
    if (status = SUBMIT_WAIT) or (status = SUBMIT_TEST) then
      Label8.Caption  := ''
    else
      Label8.Caption  := FormatDateTime(date_time_format, ttime);
    case status of
      SUBMIT_WAIT   : Label10.Caption := 'послана на тестирование';
      SUBMIT_TEST   : Label10.Caption := 'тестируется';
      SUBMIT_DONE   : Label10.Caption := 'протестирована';
      SUBMIT_SEND   : Label10.Caption := 'протестирована';
      SUBMIT_FROZEN : Label10.Caption := 'заморожена';
    end;
    if (status = SUBMIT_WAIT) or (status = SUBMIT_TEST) then
      Label12.Caption := ''
    else
      Label12.Caption := inttostr(result.point);
    if (status = SUBMIT_WAIT) or (status = SUBMIT_TEST) then
      Label14.Caption := ''
    else
      Label14.Caption := ResultToStr(result.result);
    Label16.Caption := inttostr(result.inf);
    if (status = SUBMIT_WAIT) or (status = SUBMIT_TEST) then
      Label18.Caption  := ''
    else
      Label18.Caption  := result.msg;
  end;
end;

end.
