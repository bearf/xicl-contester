unit uConnectForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrConnect = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edHost: TEdit;
    edUser: TEdit;
    edPassword: TEdit;
    edDataBase: TEdit;
    Bevel1: TBevel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frConnect: TfrConnect;

implementation

uses
  uMain,
  IniFiles;

{$R *.dfm}

procedure TfrConnect.btnCancelClick(Sender: TObject);
begin
  Application.Terminate
end;

procedure TfrConnect.FormCreate(Sender: TObject);
var
  iniFile: TIniFile;
begin
  try
    iniFile := TIniFile.Create(getCurrentDir + '\printer.ini');

    edHost.Text := iniFile.ReadString('database', 'host', 'localhost');
    edUser.Text := iniFile.ReadString('database', 'user', 'contest');
    edPassword.Text := '';
    edDataBase.Text := iniFile.ReadString('database', 'database', 'contest');

    iniFile.Free
  except
  end
end;

procedure TfrConnect.btnOKClick(Sender: TObject);
begin
  hide;

  frMain.execute(edHost.Text,
    edUser.Text,
    edPassword.Text,
    edDataBase.Text)
end;

end.
