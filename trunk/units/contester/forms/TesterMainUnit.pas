unit TesterMainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, AppEvnts, Buttons, WinSock, ttypes, tConfig, 
  ExtCtrls, Menus, TesterThreadUnit, mysqldb;

type
  TTesterMainForm = class(TForm)
    ApplicationEvents: TApplicationEvents;
    MainMenu: TMainMenu;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    StartTournamentMenu: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TesterBitBtnClick(Sender: TObject);
    function CurrText: TTextAttributes;
    procedure EnableControls();
    procedure DisableControls();
    procedure ExitBitBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StartTournamentMenuClick(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N20Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
  protected
    procedure SetTesterStarted(Value: boolean);
    function GetTesterStarted: boolean;
  private
    tstart, tlen:   TDateTime;
    tfinish:        TDateTime;
    tflag:          Boolean;
    FTesterStarted: boolean;
    { Private declarations }
  public
    { Public declarations }
    property TesterStarted: boolean read GetTesterStarted write SetTesterStarted;
    procedure TerminateThread;
  end;

Var
    TesterMainForm: TTesterMainForm;
    TesterThread: TTesterThread;

implementation

uses udb, tCallBack, tConVis, tlog, tsys, tTimes{,
  UserAddFormUnit, TaskAddFormUnit};

{$R *.dfm}

procedure TTesterMainForm.TerminateThread;
begin
    TesterThread := nil;
end;

function TTesterMainForm.GetTesterStarted: boolean;
begin
    result := FTesterStarted;
end;

procedure TTesterMainForm.SetTesterStarted(Value: boolean);
begin
    FTesterStarted := Value;
    if (Value = True) AND (TesterThread=nil) then TesterThread := TTesterThread.Create;
    if TesterThread<>nil then TesterThread.TesterStarted := Value;
    if TesterThread<>nil then TesterThread.ChangeStatus;
end;

procedure TTesterMainForm.FormCreate(Sender: TObject);
begin
    TesterStarted := false;
    tflag := False;
end;

procedure TTesterMainForm.EnableControls();
begin
  StartTournamentMenu.Enabled := True;
  N17.Enabled                 := True;
  N20.Enabled                 := True;
  N13.Enabled                 := True;
  N14.Enabled                 := True;
  N8.Enabled                  := True;
  N10.Enabled                 := True;
  N18.Enabled                 := False;
end;

procedure TTesterMainForm.DisableControls();
begin
  StartTournamentMenu.Enabled := False;
  N17.Enabled                 := False;
  N20.Enabled                 := False;
  N13.Enabled                 := False;
  N14.Enabled                 := False;
  N8.Enabled                  := False;
  N10.Enabled                 := False;
  N18.Enabled                 := True;
end;

function TTesterMainForm.CurrText: TTextAttributes;
begin
//  if RichEdit.SelLength > 0 then Result := RichEdit.SelAttributes
//  else Result := RichEdit.DefAttributes;
end;

procedure TTesterMainForm.TesterBitBtnClick(Sender: TObject);
begin
    TesterStarted := not TesterStarted;
end;

procedure TTesterMainForm.ExitBitBtnClick(Sender: TObject);
begin
    TesterMainForm.Close;
end;

procedure TTesterMainForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    while TesterThread <> nil do begin sleep(100); end;
end;

procedure TTesterMainForm.StartTournamentMenuClick(Sender: TObject);
begin
    //StartTournamentForm.ShowModal;
    tflag := False
end;

procedure TTesterMainForm.N14Click(Sender: TObject);
begin
{    if TesterThread <> nil
        then TesterThread.RecalcMonitor
        else dbRecalcMonitor;}
end;

procedure TTesterMainForm.N13Click(Sender: TObject);
begin
{    if TesterThread <> nil
        then TesterThread.PrepareMonitor
        else dbPrepareMonitor;}
end;

procedure TTesterMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    if TesterStarted then CanClose:=false;
end;

procedure TTesterMainForm.N20Click(Sender: TObject);
begin
  TesterMainForm.Close
end;

procedure TTesterMainForm.N17Click(Sender: TObject);
begin
  TesterStarted := True;
//  tlen := db_get_contest_length;
//  tstart := db_get_start_time;
//  tfinish := db_get_finish_time;
end;

procedure TTesterMainForm.N18Click(Sender: TObject);
begin
  TesterStarted := False
end;

procedure TTesterMainForm.N15Click(Sender: TObject);
begin
//  mon.ShowMonitor(utServer)
end;

procedure TTesterMainForm.Timer1Timer(Sender: TObject);
var sHour, sMin, sSec: String;
    Hour, Min, Sec, MSec: Word;
    s:                    String;
begin
{    if not tflag then begin
      tlen := db_get_contest_length;
      tstart := db_get_start_time;
      tfinish := db_get_finish_time;
      tflag := True;
    end;

    if Date+Time>tfinish then begin
      DecodeTime(tlen, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
      if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
      s := 'Тестирующая система: тур завершен - '+sHour+':'+sMin+':'+sSec;
      //Timer1.Interval := 30000;
    end
    else if Date+Time<tstart then begin
      DecodeTime(tstart-Date-Time, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
      if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
      s := 'Тестирующая система: до начала турнира '+sHour+':'+sMin+':'+sSec;
      //Timer1.Interval := 1000;
    end
    else begin
      DecodeTime(Date+Time-tstart, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
      if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
      s := 'Тестирующая система: '+sHour+':'+sMin+':'+sSec;
    end;

    if Assigned(TesterThread) then
      Caption := s + ' - [Тестер запущен]'
    else
      Caption := s + ' - [Тестер остановлен]'}
end;

procedure TTesterMainForm.N10Click(Sender: TObject);
begin
//    UserAddForm.ShowModal;
end;

procedure TTesterMainForm.N8Click(Sender: TObject);
begin
//    TaskAddForm.ShowModal;
end;

end.
