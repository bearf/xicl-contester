unit UserAddFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TUserAddForm = class(TForm)
    NameEdit: TLabeledEdit;
    LoginEdit: TLabeledEdit;
    PassEdit: TLabeledEdit;
    IPEdit: TLabeledEdit;
    OkButton: TButton;
    CancelButton: TButton;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UserAddForm: TUserAddForm;

implementation

{$R *.dfm}

uses db;

procedure TUserAddForm.OkButtonClick(Sender: TObject);
begin
//    UserAdd(NameEdit.Text, LoginEdit.Text, PassEdit.Text, IPEdit.Text);
    close;
end;

procedure TUserAddForm.CancelButtonClick(Sender: TObject);
begin
    close;
end;

end.









