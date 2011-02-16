program printer;

uses
  Forms,
  Windows,
  uMain in 'uMain.pas' {frMain},
  uPrintControl in '..\units\printer\uPrintControl.pas',
  uPrintThread in '..\units\threads\uPrintThread.pas',
  uPrintThreadUserInterface in '..\units\printer\uPrintThreadUserInterface.pas',
  uPrintJob in '..\units\printer\uPrintJob.pas',
  mysql in '..\libmysql\mysql.pas',
  uMySQLWrapper in '..\libmysql\uMySQLWrapper.pas',
  uConnectForm in 'uConnectForm.pas' {frConnect},
  uLogger in '..\units\common\uLogger.pas';

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

