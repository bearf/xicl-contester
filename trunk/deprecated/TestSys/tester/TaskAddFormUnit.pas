unit TaskAddFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TTaskAddForm = class(TForm)
    OkButton: TButton;
    CancelButton: TButton;
    TaskEdit: TLabeledEdit;
    AuthorEdit: TLabeledEdit;
    InputEdit: TLabeledEdit;
    OutputEdit: TLabeledEdit;
    RansEdit: TLabeledEdit;
    CheckerEdit: TLabeledEdit;
    TestCountEdit: TLabeledEdit;
    TimeLimitEdit: TLabeledEdit;
    MemLimitEdit: TLabeledEdit;
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TaskAddForm: TTaskAddForm;

implementation

{$R *.dfm}

uses db;

procedure TTaskAddForm.CancelButtonClick(Sender: TObject);
begin
    close;
end;

procedure TTaskAddForm.OkButtonClick(Sender: TObject);
begin
//    TaskAdd(TaskEdit.Text, AuthorEdit.Text, InputEdit.Text, OutputEdit.Text, RAnsEdit.Text, CheckerEdit.Text, TestCountEdit.Text, TimeLimitEdit.Text, MemlimitEdit.Text);
    close;
end;

end.
