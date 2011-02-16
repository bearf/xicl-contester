unit StartTournamentUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TStartTournamentForm = class(TForm)
    StartDatePicker: TDateTimePicker;
    StartTimePicker: TDateTimePicker;
    Label1: TLabel;
    StartTimeSetButton: TButton;
    Label2: TLabel;
    ContinueTimeSetButton: TButton;
    FinishDatePicker: TDateTimePicker;
    FinishTimePicker: TDateTimePicker;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Edit1: TEdit;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure StartTimeSetButtonClick(Sender: TObject);
    procedure ContinueTimeSetButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StartTournamentForm: TStartTournamentForm;

implementation
uses db, ttimes, ttypes;
{$R *.dfm}

procedure TStartTournamentForm.FormCreate(Sender: TObject);
begin
    StartDatePicker.Date := Date;
    StartTimePicker.Time := Time;
    FinishDatePicker.Date := Date;
    FinishTimePicker.Time := Time;
end;

procedure TStartTournamentForm.StartTimeSetButtonClick(Sender: TObject);
begin
    StartDatePicker.Time := StartTimePicker.Time;
//    SetConfig('starttime', FormatDateTime(date_time_format, StartDatePicker.DateTime));
end;

procedure TStartTournamentForm.ContinueTimeSetButtonClick(Sender: TObject);
begin
    FinishDatePicker.Time := FinishTimePicker.Time;
//    SetConfig('finishtime', FormatDateTime(date_time_format, FinishDatePicker.DateTime));
end;

procedure TStartTournamentForm.FormShow(Sender: TObject);
begin
{//  CheckBox1.Checked := GetConfig('allowfroze')='1';
  Edit1.Enabled     := CheckBox1.Checked;
  Edit1.Text        := GetConfig('frozetime');}
end;

procedure TStartTournamentForm.CheckBox1Click(Sender: TObject);
begin
  Edit1.Enabled := CheckBox1.Checked
end;

procedure TStartTournamentForm.Button1Click(Sender: TObject);
begin
{  SetConfig('frozetime', Edit1.Text);
  if CheckBox1.Checked then
    SetConfig('allowfroze', '1')
  else
    SetConfig('allowfroze', '0')}
end;

end.
