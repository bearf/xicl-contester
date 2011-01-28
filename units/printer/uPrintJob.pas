unit uPrintJob;

interface

uses
  Classes;

type

  TPrintJob = class
  private

    fPrintID: String;

    fText: TStrings;

    fUserName: String;

    fTaskName: String;

    fWaterMark: String;

  public

    constructor create(waterMark: String;
      text: TStrings;
      printID: String;
      userName: String;
      taskName: String);

    destructor destroy; override;

    // *** GETTERS ***

    function getText: TStrings;

    function getWaterMark: String;

    function getPrintID: String;

    function getUserName: String;

    function getTaskName: String;
    
  end;

implementation

{ TPrintJob }

constructor TPrintJob.create(waterMark: String;
  text: TStrings;
  printID: String;
  userName: String;
  taskName: String);
begin
  inherited create;

  fPrintID := printID;
  fUserName := userName;
  fTaskName := taskName;
  fText := text;
  fWaterMark := waterMark
end;

destructor TPrintJob.destroy;
begin
  fText.Free;

  inherited;
end;

function TPrintJob.getPrintID: String;
begin
  result := fPrintID
end;

function TPrintJob.getTaskName: String;
begin
  result := fTaskName
end;

function TPrintJob.getText: TStrings;
begin
  result := fText
end;

function TPrintJob.getUserName: String;
begin
  result := fUserName
end;

function TPrintJob.getWaterMark: String;
begin
  result := fWaterMark
end;

end.
