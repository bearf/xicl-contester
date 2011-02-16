unit infoform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  Tinfo = class(TForm)
    TaskInfoMemo: TMemo;
    CloseButton: TSpeedButton;
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  info: Tinfo;

implementation

{$R *.dfm}

procedure Tinfo.CloseButtonClick(Sender: TObject);
begin
  close;
end;

end.
 