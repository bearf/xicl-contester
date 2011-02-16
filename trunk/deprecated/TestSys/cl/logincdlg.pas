unit LoginCDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TloginC = class(TForm)
    OKButton: TButton;
    CancelButton: TButton;
    Panel: TPanel;
    Label3: TLabel;
    Bevel: TBevel;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edit1: TEdit;
    edit2: TEdit;
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    mresult : integer;
  end;

var
  loginC: TloginC;

implementation

{$R *.dfm}

procedure TloginC.FormShow(Sender: TObject);
begin
  edit1.Text := '';
  edit2.Text := '';
end;

procedure TloginC.OKButtonClick(Sender: TObject);
begin
  if edit1.Text <> edit2.Text then begin
    MessageBox(handle, 'Пароли не совпадают!', 'Ошибка', MB_OK or MB_SYSTEMMODAL or MB_ICONWARNING);
    MResult := IDCANCEL;
  end else begin
    MResult := IDOK;
    Close;
  end;

end;

procedure TloginC.CancelButtonClick(Sender: TObject);
begin
  MResult := IDCANCEL;
  Close;
end;

end.
