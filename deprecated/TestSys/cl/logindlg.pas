unit LoginDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  Tlogin = class(TForm)
    OKButton: TButton;
    CancelButton: TButton;
    Panel: TPanel;
    Label3: TLabel;
    DatabaseName: TLabel;
    Bevel: TBevel;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    UserName: TEdit;
    Password: TEdit;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  login: Tlogin;

implementation

{$R *.dfm}

procedure Tlogin.FormShow(Sender: TObject);
begin
  UserName.Text := '';
  Password.Text := '';
  SetFocus;
  UserName.SetFocus;
end;

end.
