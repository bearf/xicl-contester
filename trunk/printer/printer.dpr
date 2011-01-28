program printer;

uses
  Forms,
  Windows,
  uPrintControl in '..\units\printer\uPrintControl.pas',
  uPrintThread in '..\units\threads\uPrintThread.pas',
  uPrintThreadUserInterface in '..\units\printer\uPrintThreadUserInterface.pas',
  uPrintJob in '..\units\printer\uPrintJob.pas',
  mysql in '..\units\db\mysql.pas',
  uLogger in '..\units\common\uLogger.pas',
  uMySQLWrapper in '..\units\db\uMySQLWrapper.pas',
  uConnectForm in '..\units\printer\forms\uConnectForm.pas' {frConnect},
  uMain in '..\units\printer\forms\uMain.pas' {frMain};

{$R *.res}

var
 	hMutex : integer;
begin
  hMutex := CreateMutex(nil,TRUE,'printer/teddybear');       // Создаем семафор

  if GetLastError=0 then begin
    Application.Initialize;

    Application.CreateForm(TfrConnect, frConnect);
  Application.CreateForm(TfrMain, frMain);
  Application.Run
  end
  else
    MessageBox(0,'Нельзя запустить две копии программы','Внимание!',MB_OK or MB_SYSTEMMODAL or MB_ICONWARNING);
end.

