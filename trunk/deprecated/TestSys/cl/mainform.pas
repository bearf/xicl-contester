unit mainform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Shellapi, Buttons, ExtCtrls, ttimes, ttypes, ComCtrls, remoted, Winsock,
  Menus, DateUtils, AppEvnts;

type
	TContestStatus = (csFinish, csContinue, csBefore);

  Tmain = class(TForm)
    Panel: TPanel;
    Label3: TLabel;
    Bevel: TBevel;
    Panel1: TPanel;
    Label1: TLabel;
    FileEdit: TEdit;
    SpeedButton1: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SpeedButton2: TSpeedButton;
    Label7: TLabel;
    TaskComboBox: TComboBox;
    LangComboBox: TComboBox;
    Label9: TLabel;
    Panel2: TPanel;
    Label2: TLabel;
    Bevel1: TBevel;
    Panel3: TPanel;
    Label4: TLabel;
    LastResultEdit: TEdit;
    SpeedButton3: TSpeedButton;
    TaskInfoButton: TSpeedButton;
    DateTimePicker1: TDateTimePicker;
    Label5: TLabel;
    Panel4: TPanel;
    Label6: TLabel;
    Bevel2: TBevel;
    Panel5: TPanel;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    Label10: TLabel;
    Label11: TLabel;
    Timer1: TTimer;
    Label12: TLabel;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Label8: TLabel;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FileEditChange(Sender: TObject);
    procedure TaskInfoButtonClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
  private
    { Private declarations }
    contest_status:	TContestStatus;

    procedure ShowWindow;
    procedure	GetTime;
  public
    procedure TrayIcon(var Msg : TMsg); message WM_USER + 1;
    procedure UpdateAll;
    procedure UpdateTasks;
    procedure UpdateLastResult;
    { Public declarations }
  end;

var
  main: Tmain;
  pnid : TNotifyIconData; //Содержит информацию, которая неободима системе для обработки сообщений области панели задач
//  user, pass : string;
  mystarttime, remaining : TDateTime; // Время начала работы и время завершения турнира
  opened       : boolean;
  udpdaemon    : tudpdaemon;
  updateflag	 : boolean;

implementation

uses LoginDlg, mysqldb, infoform, resform, remote, cp, LoginCDlg, monform;//, Log;

{$R *.dfm}


procedure Tmain.TrayIcon(var Msg : TMsg);
begin
  if msg.wParam = 516 then
  	PopupMenu1.Popup(Mouse.CursorPos.X-128, Mouse.CursorPos.Y-64)
  else if (msg.wParam = 513) then
  	ShowWindow
end;


procedure Tmain.FormCreate(Sender: TObject);
var i: integer;
begin
    opened := false;
    updateflag := False;
    db_set_log_device(0); // Устанавливает устройство вывода сообщений = messagebox

    pnid.cbSize := sizeof(pnid);
    pnid.Wnd := Handle;
    pnid.uCallbackMessage := WM_USER+1;
    pnid.uID := 1;
    pnid.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    pnid.hIcon := LoadIcon(HInstance, 'MAINICON'); // В качестве иконки в панели задач устанавливается иконка программы
    pnid.szTip := 'Тестирующая система';
    Shell_NotifyIcon(NIM_ADD, @pnid); // Передает системе данные об иконке

    LangComboBox.Items.Clear; // Очищает список языков
    for i := low(lngs) to high(lngs) do
        LangComboBox.Items.Append(lngs[i]);
    LangComboBox.ItemIndex := 0;

    udpdaemon := TUDPDaemon.Create(False);
end;

procedure Tmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Shell_NotifyIcon(NIM_DELETE, addr(pnid));
  DestroyIcon(pnid.hIcon);
end;

procedure Tmain.SpeedButton1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    FileEdit.Text := OpenDialog1.FileName;
  end;
  FileEditChange(FileEdit);
end;

procedure Tmain.UpdateTasks;
var i : integer;
    t : TTaskInfo;
begin
  taskcount := db_read_user_tasks(curuser.id);
  TaskComboBox.Items.Clear;
  for i := 0 to taskcount - 1 do begin
    db_get_task_bynum(i, t);
    TaskComboBox.Items.Append(t.name);
  end;
  if TaskComboBox.ItemIndex < 0 then
    TaskComboBox.ItemIndex := 0;
  FileEdit.Text := '';
  if taskcount = 0 then
    SpeedButton2.Enabled := false
  else
    SpeedButton2.Enabled := true;
end;

procedure Tmain.SpeedButton2Click(Sender: TObject);
var a : TFileStream;
    t, t1 : TTaskInfo;
    f : string;
    i : integer;
    fl  : boolean;
    SubmitID : integer;
begin
	if db_get_server_time<db_get_start_time then begin
  	MessageBox(0, 'Вы не можете послать решение, так как тур еще не начался.', 'Внимание', MB_OK or MB_ICONWARNING);
  	exit
  end
  else if db_get_time_left<0 then begin
  	MessageBox(0, 'Вы не можете послать решение, так как тур уже завершен.', 'Внимание', MB_OK or MB_ICONWARNING);
  	exit
  end;

  if not FileExists(FileEdit.Text) then begin
    MessageBox(0, PChar('Файл "' + FileEdit.Text + '" не найден!'), 'Ошибка', MB_OK or MB_SYSTEMMODAL or MB_ICONERROR);
    exit;
  end;
  a := TFileStream.Create(FileEdit.Text, fmOpenRead);
  if a.Size > db_get_max_submit_size then begin
    a.Free;
    MessageBox(0, PChar('Превышено ограничение на размер файла: ' + inttostr(db_get_max_submit_size div 1024) + 'Кб'), 'Ошибка', MB_OK or MB_SYSTEMMODAL or MB_ICONERROR);
    exit;
  end;
  a.free;
  db_get_task_bynum(TaskComboBox.ItemIndex, t);
  f := FileEdit.Text;
  if db_check_update then begin
    UpdateAll;
    fl := false;
    for i := 0 to taskcount - 1 do begin
      db_get_task_bynum(TaskComboBox.ItemIndex, t1);
      if t1.id = t.id then begin
        fl := true;
        break;
      end;
    end;
    if not fl then begin
      MessageBox(0, 'В базе данных проводятся изменения, поэтому Ваше решение не послано', 'Информация', MB_OK or MB_SYSTEMMODAL or MB_ICONINFORMATION);
//      visible := false;
//      opened := false;
//      db_done;
      exit;
    end else t := t1;
  end;

  if MessageBox(0, 'Вы действительно хотите послать решение на проверку?', 'Внимание', MB_YESNOCANCEL or MB_ICONQUESTION) = ID_YES then begin
	  SubmitID := db_user_submit_file(f, curuser.id, t.id, dblng[LangComboBox.ItemIndex + Low(dblng)]);
	//  Application.MessageBox(PChar('SubmitID = ' + inttostr(SubmitID)), '', 0);
  	if SubmitID <> InvalidID then begin
	    send_message(waiter, waiter_port, inttostr(submitid));
//	    send_message('127.0.0.1', waiter_port, inttostr(submitid));
  	  MessageBox(0, PChar('Файл "' + FileEdit.Text + '" успешно отправлен на проверку!'), 'Информация', MB_OK or MB_SYSTEMMODAL or MB_ICONINFORMATION);
	  end else
  	  MessageBox(0, PChar('Файл "' + FileEdit.Text + '" не удалось послать на проверку!'), 'Ошибка', MB_OK or MB_SYSTEMMODAL or MB_ICONERROR);
  end
end;

procedure Tmain.FileEditChange(Sender: TObject);
var i : integer;
    ext : string;
begin
  ext := lowercase(ExtractFileExt(FileEdit.Text));
  ext := copy(ext, 2, length(ext) - 1);
  for i := Low(exts) to High(exts) do
    if exts[i]=ext then begin
      LangComboBox.ItemIndex := i - Low(exts);
      exit;
    end;
end;

procedure Tmain.TaskInfoButtonClick(Sender: TObject);
var TaskInfo : TTaskInfo;
begin
  db_get_task_bynum(TaskComboBox.ItemIndex, TaskInfo);
//  db_get(dbTask, TaskInfo.ID,rqTester,true,TaskInfo);

  with info.TaskInfoMemo.Lines do begin
    Clear;
    Append('Задача               : ' + TaskInfo.Name);
    Append('Автор                : ' + TaskInfo.Author);
    Append('Входной файл         : ' + TaskInfo.Input);
    Append('Выходной файл        : ' + TaskInfo.Output);
//    Append('Difficulty  : ' + IntToStr(TaskInfo.Complex) + '%');
//    Append('Bonus       : ' + IntToStr(TaskInfo.Bonus));
		if TaskInfo.TimeLimit>0 then
	    Append('Ограничение времени  : ' + IntToStr(TaskInfo.TimeLimit))
    else
	    Append('Ограничение времени  : -');
		if TaskInfo.MemoryLimit>0 then
	    Append('Ограничение памяти   : ' + IntToStr(TaskInfo.MemoryLimit))
    else
	    Append('Ограничение памяти   : -')
  end;

  info.ShowModal;
end;

procedure Tmain.UpdateLastResult;
var SubmitInfo : TSubmitInfo;
    TaskInfo : TTaskInfo;
begin
  if not opened then
    exit;
  db_get_last_submit(curuser.id, InvalidID, InvalidID, SubmitInfo);
  if SubmitInfo.id = InvalidID then begin
    LastResultEdit.Text := '';
  end else begin
    db_get(dbTask, SubmitInfo.task, rqClient, false, TaskInfo);
    LastResultEdit.Text := TaskInfo.Name + ' ' + inttostr(SubmitInfo.stry) + ' поп, ' +{ inttostr(SubmitInfo.result.point) + ' балл(ов), рез ' +} ResultToStr(SubmitInfo.result.result);

    if updateflag then
    	MessageBox(0, PChar('Результат по задаче ' + TaskInfo.Name + ', попытка ' + inttostr(SubmitInfo.stry) +
      					 ': ' + SubmitInfo.result.msg), 'Информация', MB_OK or MB_ICONINFORMATION)
  end;

  updateflag := False
end;

procedure Tmain.SpeedButton3Click(Sender: TObject);
begin
//  messagebox(0, PChar(datetimetostr(DateTimePicker1.Date)), '', 0);
  DateTimePicker1.DateTime := RecodeTime(DateTimePicker1.DateTime, 0, 0, 0, 0);
  res.d_from := DateTimePicker1.DateTime;
  res.d_to   := IncDay(DateTimePicker1.DateTime, 1);
  res.ShowModal;
  
end;

procedure Tmain.FormShow(Sender: TObject);
begin
  DateTimePicker1.DateTime := Date;
  Application.Restore
end;

procedure Tmain.SpeedButton5Click(Sender: TObject);
begin
  visible := false;
  opened  := false;
  db_done;

  Timer1.Enabled := False;
end;

procedure Tmain.SpeedButton6Click(Sender: TObject);
begin
  close;
end;

procedure Tmain.Timer1Timer(Sender: TObject);
begin
	GetTime
end;

procedure Tmain.UpdateAll;
begin
  UpdateTasks;
  UpdateLastResult;
end;

procedure Tmain.SpeedButton8Click(Sender: TObject);
begin
  UpdateLastResult;
end;

procedure Tmain.SpeedButton9Click(Sender: TObject);
begin
  loginc.ShowModal;
  if loginC.MResult = idOK then begin
    curuser.password := loginC.edit1.text;
    db_set(dbUser, curuser.id, rqTester, curuser);
    MessageBox(0, PChar('Password was succesfully changed!'), 'Info', MB_OK or MB_SYSTEMMODAL or MB_ICONINFORMATION);
  end;
end;

procedure Tmain.SpeedButton7Click(Sender: TObject);
begin
  mon.ShowMonitor(utClient);
end;

procedure Tmain.N3Click(Sender: TObject);
begin
	Close
end;

procedure TMain.ShowWindow;
begin
    if not opened then begin
        opened := true;
        login.ShowModal;
        curuser.login:=login.UserName.Text;
        curuser.password:=login.Password.Text;
        if (login.ModalResult = idOK) then begin
            db_set_server(curuser.login, curuser.password, db_host, db_name, 1); // Устаначливает параметры сервера
//            db_set_server('root', '', '127.0.0.1', 'tsys'{db_host, db_name, }, 1); // Устаначливает параметры сервера
            if db_init then begin
                if db_user_auth(curuser) then begin
                    Left := Screen.Width - Width;
                    Top  := Screen.WorkAreaHeight - Height;
                    Label11.Caption := curuser.name;
                    db_check_update;

                    UpdateAll;

                    main.Visible := true;
                    Timer1.Enabled := True;
                    GetTime
                end else begin
                    MessageBox(0, 'Неверный пароль или login', 'Ошибка', MB_OK or MB_SYSTEMMODAL or MB_ICONERROR);
                    db_done;
                    opened := false;
                end;
            end else opened := false;
        end else opened := false;
    end else Show;
end;

procedure Tmain.N1Click(Sender: TObject);
begin
	ShowWindow
end;

procedure	TMain.GetTime;
var sHour, sMin, sSec: String;
    cur, lft, len: TDateTime;
    Hour, Min, Sec, MSec: Word;
begin
    cur := db_get_cur_time;
    lft := db_get_time_left;
    if cur<0 then
    	contest_status := csBefore
    else if lft<0 then
    	contest_status := csFinish
    else
    	contest_status := csContinue;

    if contest_status = csContinue then begin
      DecodeTime(cur, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
      if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
      Label8.Caption := 'Время: '+sHour+':'+sMin+':'+sSec;
      Timer1.Interval := 10000;
    end
    else if contest_status = csFinish then begin
    	len := db_get_contest_length;
      DecodeTime(len, Hour, Min, Sec, MSec);
      sHour := IntToStr(Hour);
      sMin := IntToStr(Min);
      sSec := IntToStr(Sec);
	    if Length(sMin)<2 then sMin := '0'+sMin;
    	if Length(sSec)<2 then sSec := '0'+sSec;
      Label8.Caption := 'Время: '+sHour+':'+sMin+':'+sSec+' [Тур завершен]';
      Timer1.Interval := 10000;
    end
    else begin
    	Label8.Caption := '0:00:00 [Тур не начат]';
      Timer1.Interval := 1000;
    end
end;

procedure Tmain.ApplicationEvents1Minimize(Sender: TObject);
begin
  Hide
end;

end.
