unit tConVis;


interface
uses SysUtils, tTypes, db, tTimes, tCallBack, tConUtils, tlog;

	function ConVisCB (Msg, ID, lParam, wParam: integer):integer;
        procedure mConVisCB();

implementation
uses TesterMainUnit;

var
 	Ti: PTaskInfo;
 	curtest: integer;
 	Si: PSubmitInfo;
 	UI: TUserInfo;
        mMsg, mID, mlParam, mwParam, mResult: integer;

function ConVisCB (Msg, ID, lParam, wParam: integer):integer;
begin
    mMsg := Msg;
    mID := ID;
    mlParam := lParam;
    mwParam := wParam;
    TesterThread.callConVisCB();
    result := mResult;
end;

procedure mConVisCB();
    var res, point: integer;
        msgs: string;
        Msg, ID, lParam, wParam: integer;
    begin
//  	ConVisCB:=_NO;
    Msg := mMsg;
    ID := mID;
    lParam := mlParam;
    wParam := mwParam;
  	mResult:=_NO;
  	Case Msg of
   	    CB_TEST_INIT: begin
    			      println('');
    			      integer(Ti):=lParam;
    			      OutText(Format('task        %S (%D)&N', [TI^.name, TI^.ID]));
    			      if length(TI^.author)<>0 then
     				  OutText(Format('author      %S&N', [TI^.author]));
    			      if TI^.TimeLimit<>0 then
     				  OutText(Format('timelimit   %5.3F s&N', [TI^.TimeLimit/1000]));
    			      if TI^.MemoryLimit<>0 then
     				  OutText(Format('memorylimit %D kb&N', [TI^.MemoryLimit]));
    			      if ID=InvalidId then
                            		          begin
      						      Si:=nil;
    						  end
                                              else
                                                  begin
      						      integer(Si):=wParam;
      						      GetInfo(dbUser, Si^.user, Ui);
      						      OutText(Format('&Nsubmit %D&N', [SI^.ID]));
      						      OutText(Format('user   %S (%D)&Ntry    %D&Ntime   %S&N',
              					          [Ui.name,Ui.id,Si^.stry, FormatDateTime(date_time_format, SI^.sTime)]));
    						  end;
    			      println('');
   			  end;
   			CB_TEST_START: 	begin
     					     curtest:=lParam;
    					     OutText(Format('test %2D&F', [curtest]));
   					end;

   			CB_RUN_INIT:
            	        case ID of
     				CB_RUN_TYPE_COMPILE:  OutText('&Ncompile&F');
     				CB_RUN_TYPE_SOLUTION: OutText(Format('test %2D execute&F', [curtest]));
     				CB_RUN_TYPE_CHECKER : OutText(Format('test %2D check&F', [curtest]));
    			end;
   			CB_RUN_INFO:
    			case ID of
     				CB_RUN_TYPE_COMPILE: OutText('compile &P&F');
     				CB_RUN_TYPE_SOLUTION: 	begin
       											if ti<>nil then
        											OutText(Format('test %2D execute &P T:%S M:%S&F', [curtest, gettrack(lParam, TI^.timelimit), gettrack(wParam, TI^.memorylimit)]))
       											else
        											OutText(Format('test %2D execute &P T:%S M:%S&F', [curtest, gettrack(lParam, 0), gettrack(wParam, 0)]));
     									  	end;
     				CB_RUN_TYPE_CHECKER: OutText(Format('test %2D check &P&F', [curtest]));
    			end;

   			CB_RUN_DONE:
    			case ID of
     				CB_RUN_TYPE_COMPILE: OutText('compile done&N');
     				CB_RUN_TYPE_SOLUTION: if ti<>nil
                    						then
      											OutText(Format('test %2D execute done&F', [curtest]));
     				CB_RUN_TYPE_CHECKER : OutText(Format('test %2D check done&F', [curtest]));
    			end;
   			CB_TEST_RESULT: begin
    							res:=ptestresult(wparam)^.result;
    							point:=ptestresult(wparam)^.point;
    							msgs:=ptestresult(wparam)^.msg;
    							OutText(Format('test %2D &C'+Res2Col(res)+'%S&CF %3D  %S&E&N', [curtest, ResultToStr(res), point, msgs]));
   							end;
   			CB_TEST_DONE: 	begin
    							res:=PTestResult(id)^.result;
    							OutText(Format('&Ntask res &C'+Res2Col(res)+'%S&N', [ResultToStr(res)]));
    							OutText(Format('message  %S&N', [PTestResult(id)^.msg]));
    							if PTestResult(id)^.result<>_CE
    								then begin
     									OutText(Format('total    %D = ', [PTestResult(id)^.point]));
//     									for i:=1 to PTaskInfo(lParam)^.TestCount do print(IntToStr(PAllTestResult(wParam)^[i].point) + '+');
//     									if PTestResult(id)^.inf=PTaskInfo(lParam)^.TestCount then
//      										println('bonus ' + IntToStr(PTaskInfo(lParam)^.Bonus))
//     									else
//      										println('bonus 0');
    								end;
    							ti:=nil;
   							end;
  		end;
 	end;

begin
 	Ti:=nil;
end.
