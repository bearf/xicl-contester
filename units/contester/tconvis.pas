unit tConVis;


interface
uses SysUtils, tTypes, udb, tTimes, tCallBack, tlog;

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
    			      integer(Ti):=lParam;
    			      logger.test.print(Format('task        %S (%D)', [TI^.name, TI^.ID]));
    			      if length(TI^.author)<>0 then
     				  logger.test.print(Format('author      %S', [TI^.author]));
    			      if TI^.TimeLimit<>0 then
     				  logger.test.print(Format('timelimit   %5.3F s', [TI^.TimeLimit/1000]));
    			      if TI^.MemoryLimit<>0 then
     				  logger.test.print(Format('memorylimit %D kb', [TI^.MemoryLimit]));
    			      if ID=InvalidId then
                            		          begin
      						      Si:=nil;
    						  end
                                              else
                                                  begin
      						      integer(Si):=wParam;
      						      GetInfo(dbUser, Si^.user, Ui);
      						      logger.test.print(Format('submit %D', [SI^.ID]));
      						      logger.test.print(Format('user   %S (%D)',
              					          [Ui.name,Ui.id]));
      						      logger.test.print(Format('try    %D',
              					          [Si^.stry]));
      						      logger.test.print(Format('time   %S',
              					          [FormatDateTime(date_time_format, SI^.sTime)]));
    						  end;
   			  end;
   			CB_TEST_START: 	begin
     					     curtest:=lParam;
    					     //logger.test.print(Format('test %2D', [curtest]));
   					end;

   			CB_RUN_INIT:
            	        case ID of
     				CB_RUN_TYPE_COMPILE:  begin
                        logger.test.print('compile');
                    end;
     				CB_RUN_TYPE_SOLUTION: logger.test.print(Format('test %2D execute', [curtest]));
     				CB_RUN_TYPE_CHECKER : logger.test.print(Format('test %2D check', [curtest]));
    			end;
   			CB_RUN_INFO:
    			case ID of
     				CB_RUN_TYPE_COMPILE: ;
     				CB_RUN_TYPE_SOLUTION: ;
     				CB_RUN_TYPE_CHECKER: ;
    			end;

   			CB_RUN_DONE:
    			case ID of
     				CB_RUN_TYPE_COMPILE: logger.test.print('compile DONE');
     				CB_RUN_TYPE_SOLUTION: logger.test.print('run DONE');
     				CB_RUN_TYPE_CHECKER : ;//logger.test.append('done');
    			end;
   			CB_TEST_RESULT: begin
    							res:=ptestresult(wparam)^.result;
    							point:=ptestresult(wparam)^.point;
    							msgs:=ptestresult(wparam)^.msg;
    							logger.test.print(Format('%S =%D / %S', [ResultToStr(res), point, msgs]));
   							end;
   			CB_TEST_DONE: 	begin
    							res:=PTestResult(id)^.result;
    							logger.test.print(Format('task res %S', [ResultToStr(res)]));
    							logger.test.print(Format('message  %S', [PTestResult(id)^.msg]));
    							if PTestResult(id)^.result<>_CE
    								then begin
     									logger.test.print(Format('total    %D ', [PTestResult(id)^.point]));
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
