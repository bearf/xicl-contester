unit uPrintControl;

interface

uses
  Types,
  Classes,
  Printers,
  Graphics,
  Windows;

const

  // ���������� ����� �������� �� ���������
  _lineMargin = 2;

  // ���� �� ���������
  _margin = 20;

  // ��������� ������ �� ���������
  _fontSize = 10;
  _fontStyle: TFontStyles = [];
  _fontName: TFontName = 'Courier New';
  _fontColor: TColor = clBlack;

  //��������� ������ �������� �����
  _waterMarkFontSize = 72;
  _waterMarkFontStyle: TFontStyles = [fsBold];
  _waterMarkFontName: TFontName = 'Arial';
  _waterMarkFontColor: TColor = $00E0E0E0;

type

  {
    �����: ������ � �������� �� ������ ������ ����������
    ����������:
      ������������ ����������� ������ ������� ��������� ����������
  }
  TPrintControl = class
  private

    // *** FIELDS ***

    // ������������ �������
    fPrinter: TPrinter;

    // ���������� � �������� �� ���� �� �����������
    fPixelsPerInchX: Integer;

    // ���������� � �������� �� ���� �� ���������
    fPixelsPerInchY: Integer;

    // �������������� ������ ������� ������ (� �����������)
    fPageWidth: Integer;

    // ������������ ������ ������� ������ (� �����������)
    fPageHeight: Integer;

    // �������� ������� ������ ����� (� ��������)
    fPhysicalOffsetX: Integer;

    // �������� ������� ������ ������ (� ��������)
    fPhysicalOffsetY: Integer;

    // �������������� ������ ������� ������ (� ��������)
    fPageResolutionX: Integer;

    // ������������ ������ ������� ������ (� ��������)
    fPageResolutionY: Integer;

    // �������������� ���������� ������ ����� (� �����������)
    fPhysicalPageWidth: Integer;

    // ������������ ���������� ������ ����� (� �����������)
    fPhysicalPageHeigth: Integer;

    // ���� ������ � �����������
    fMargins: TRect;

    // ���������� ����� �������� � ��������
    fLineMargin: Integer;

    // �����
    fFont: TFont;

    // ����� �������� �����
    fWaterMarkFont: TFont;

    // ������� ����
    fWaterMark: String;

    // *** METHODS ***

    // �������� ���������� � ��������
    // ����������� ���������� � �������� � ������� �� � ���� ������
    procedure retrievePrinterInfo;

    // ��������� ���������� �� ����������� � �������
    // ���������:
    //   value: �������� � �����������
    // ������������ ��������:
    //   �������� value, ������������ � �������
    function millimetersToPixelsX(value: Integer): Integer;

    // ��������� ���������� �� ��������� � �������
    // ���������:
    //   value: �������� � �����������
    // ������������ ��������:
    //   �������� value, ������������ � �������
    function millimetersToPixelsY(value: Integer): Integer;

    // ��������� ���������� ����� � ����������� � ���������� ����� � ��������
    // �������p
    //    p: ���������� ����� � �����������
    // ������������ ��������:
    //   ���������� ����� p, ������������ � �������
    function millimetersToPixels(p: TPoint): TPoint;

    // ��������� ����� �� ������
    // ��������� ����� �� ������ � ��� ������, ����� ������ �� ��� ����������� � ������� ������
    // ���������:
    //    text: ������� �����
    // ������������ ��������:
    //    �����, �������� �� ������
    // �����:
    //    * ������ ���� �������� ����� Printer.beginDoc
    function breakDownIntoLines(text: TStrings): TStrings;

    // �������� ����� ������ � �������� ��� ������
    // ������������ ��������:
    //    ����� ������ � �������� ��� ������
    function getLineWidth(line: String): Integer;

    // �������� ������ ������ � �������� ��� ������
    // ������������ ��������:
    //    ������ ������ � �������� ��� ������
    function getLineHeight(line: String): Integer;

    // ���������� ��������� ������ ��������
    // ������������� ��������� ������ ��������, �������� �������� ������
    // (�.�. ��� �������� � �������� ������ ���������; ������� ����������)
    // ���������:
    //    font: �����, ��������� �������� ������� ������������
    // ������ �����:
    //    * ������ ���� ���������� �������� fPrinter.Canvas.Font.PixelsPerInch
    procedure assignPrinterFont(font: TFont);

    // ������� ������� ���� �� ��������
    // ������������� ����� �������� �����,
    // ������� ������� ���� � ������������� ����� � �������
    procedure makeWaterMark;

  public

    // *** CONSTRUCTORS ***

    // ����������� �� ���������
    // �������� ���������� � ��������
    constructor create;

    // *** DESTRUCTORS ***

    // ����������
    // ���������� �������
    // �����������
    //    * ������� ������������ ���� ���� �� ��� ���������� ������� setPrinter
    destructor destroy; override;

    // *** METHODS ***

    // ����������� �����
    // ����������� �����, ��������� ��������������� ������ � �������� �����
    // ���������:
    //    text: ������ ����� ��� ������
    procedure printText(text: TStrings);

    // *** GETTERS ***

    // �������� ���������� � �������� �� ���� �� �����������
    // ������������ ��������:
    //
    function getPixelsPerInchX: Integer;

    // �������� ���������� � �������� �� ���� �� ���������
    // ������������ ��������:
    //    ���������� � �������� �� ���� �� �����������
    function getPixelsPerInchY: Integer;

    // �������� �������������� ������ ������� ������ (� �����������)
    // ������������ ��������:
    //    �������������� ������ ������� ������ (� �����������
    function getPageWidth: Integer;

    // �������� ������������ ������ ������� ������ (� �����������)
    // ������������ ��������:
    //    ������������ ������ ������� ������ (� �����������)
    function getPageHeight: Integer;

    // �������� �������� ������� ������ ����� (� ��������)
    // ������������ ��������:
    //    �������� ������� ������ ����� (� ��������)
    function getPhysicalOffsetX: Integer;

    // �������� �������� ������� ������ ������ (� ��������)
    // ������������ ��������:
    //    �������� ������� ������ ������ (� ��������)
    function getPhysicalOffsetY: Integer;

    // �������� �������������� ������ ������� ������ (� ��������)
    // ������������ ��������:
    //    �������������� ������ ������� ������ (� ��������)
    function getPageResolutionX: Integer;

    // �������� ������������ ������ ������� ������ (� ��������)
    // ������������ ��������:
    //    ������������ ������ ������� ������ (� ��������)
    function getPageResolutionY: Integer;

    // �������� �������������� ���������� ������ ����� (� �����������)
    // ������������ ��������:
    //    �������������� ���������� ������ ����� (� �����������)
    function getPhysicalPageWidth: Integer;

    // �������� ������������ ���������� ������ ����� (� �����������)
    // ������������ ��������:
    //    ������������ ���������� ������ ����� (� �����������)
    function getPhysicalPageHeigth: Integer;

    // �������� ���� ������ � �����������
    // ������������ ��������:
    //    ���� ������ � �����������
    function getMargins: TRect;

    // �������� ���������� ����� �������� (� ��������)
    // ������������ ��������:
    //    ���������� ����� �������� (� ��������)
    function getLineMargin: Integer;

    // �������� ������������ �����
    // ������������ ��������:
    //    ������������ �����
    function getFont: TFont;

    // �������� ����� �������� �����
    // ������������ ��������:
    //    ����� �������� �����
    function getWaterMarkFont: TFont;

    // �������� ����� �������� �����
    // ������������ ��������:
    //    ����� �������� �����
    function getWaterMark: String;

    // �������� �������� �������
    // ������������ ��������:
    //    �������� �������
    function getPrinter: TPrinter;

    // *** SETTERS ***

    // ���������� ���������� ����� �������� (� ��������)
    // ���������:
    //    lineMargin: ���������� ����� �������� (� ��������)
    procedure setLineMargin(lineMargin: Integer);

    // ���������� ����� �������� �����
    // ���������:
    //    waterMark: ����� �������� �����
    procedure setWaterMark(waterMark: String);

    // ���������� �������� �������
    // ������������� �������� �������
    // �������� ��������� ���������� ��� ������
    procedure setPrinter(printer: TPrinter);

  end;

implementation

{ TPrintControl }

// ���������� ��������� ������ ��������
procedure TPrintControl.assignPrinterFont(font: TFont);
begin
  fPrinter.Canvas.Font.Size := font.Size;
  fPrinter.Canvas.Font.Style := font.Style;
  fPrinter.Canvas.Font.Color := font.Color;
  fPrinter.Canvas.Font.Name := _fontName;
end;

// ��������� ����� �� ������
function TPrintControl.breakDownIntoLines(text: TStrings): TStrings;

  procedure addLine(text: TStrings; line: String);
  var
    i: Integer;
    left, rest: String;

  begin
    //���� ������ ������, �� ����� �� ���������
    if length(line) = 0 then
      text.Add(line)
    //����� �������� ������� �� ���������
    else
      //���� ���������� ���������� ����� ������ �� �����
      while length(line) > 0 do begin
        //�������� ���������� ��� ���������� �����
        left := line;
        rest := '';
        i := length(line);

        //���� ���������� ����� �� ���������� � ������� ������
        while getLineWidth(left) > getPageResolutionX do begin
          //������� �� ��� �� ������ ������� � ��������� � ���������� ������� ������
          dec(i);
          left := copy(line, 1, i);
          rest := copy(line, i+1, length(line)-i)
        end;

        //��������� ��������� ���������
        text.Add(left);

        //� �������� ������� �������
        line := rest
      end
  end;

  function removeTabs(line: String): String;
  var
    i: Integer;
  begin
    result := '';

    for i := 1 to length(line) do
      if line[i] <> chr(9) then
        result := result + line[i]
      else
        result := result + '  '
  end;

var
  i: Integer;
  line: String;
begin
  result := TStringList.Create;

  for i := 0 to text.Count-1 do begin
    line := removeTabs(text[i]);
    addLine(result, line)
  end
end;

// ����������� �� ���������
constructor TPrintControl.create;
begin
  inherited create;

  //�������������
  fLineMargin := _lineMargin;

  //�������
  //fPrinter := TPrinter.Create;
  fPrinter := Printer;

  //�����
  fFont := TFont.Create;
  fFont.Size := _fontSize;
  fFont.Style := _fontStyle;
  fFont.Name := _fontName;
  fFont.Color := _fontColor;

  //����� �������� �����
  fWaterMarkFont := TFont.Create;
  fWaterMarkFont.Size := _waterMarkFontSize;
  fWaterMarkFont.Style := _waterMarkFontStyle;
  fWaterMarkFont.Name := _waterMarkFontName;
  fWaterMarkFont.Color := _waterMarkFontColor;

  //����
  fMargins.Top := _margin;
  fMargins.Left := _margin;

  fMargins.Bottom := _margin;
  fMargins.Right := _margin;

  //����������� ���������� � ��������
  retrievePrinterInfo
end;

// ����������
destructor TPrintControl.destroy;
begin
  //fPrinter.Free;

  fWaterMarkFont.Free;

  fFont.Free;

  inherited
end;

// �������� ������������ �����
function TPrintControl.getFont: TFont;
begin
  result := fFont
end;

// �������� ������ ������ � �������� ��� ������
function TPrintControl.getLineHeight(line: String): Integer;
begin
  if line = '' then
    result := fPrinter.Canvas.TextHeight('#')
  else
    result := fPrinter.Canvas.TextHeight(line)
end;

// �������� ���������� ����� �������� (� ��������)
function TPrintControl.getLineMargin: Integer;
begin
  result := fLineMargin
end;

// �������� ����� ������ � �������� ��� ������
function TPrintControl.getLineWidth(line: String): Integer;
begin
  result := fPrinter.Canvas.TextWidth(line)
end;

// �������� ���� ������ � �����������
function TPrintControl.getMargins: TRect;
begin
  result := fMargins
end;

// �������� ������������ ������ ������� ������ (� �����������)
function TPrintControl.getPageHeight: Integer;
begin
  result := fPageHeight
end;

// �������� �������������� ������ ������� ������ (� ��������)
function TPrintControl.getPageResolutionX: Integer;
begin
  result := fPageResolutionX
end;

// �������� ������������ ������ ������� ������ (� ��������)
function TPrintControl.getPageResolutionY: Integer;
begin
  result := fPageResolutionY
end;

// �������� �������������� ������ ������� ������ (� �����������)
function TPrintControl.getPageWidth: Integer;
begin
  result := fPageWidth
end;

// �������� �������� ������� ������ ����� (� ��������)
function TPrintControl.getPhysicalOffsetX: Integer;
begin
  result := fPhysicalOffsetX
end;

// �������� �������� ������� ������ ������ (� ��������)
function TPrintControl.getPhysicalOffsetY: Integer;
begin
  result := fPhysicalOffsetY
end;

// �������� ������������ ���������� ������ ����� (� �����������)
function TPrintControl.getPhysicalPageHeigth: Integer;
begin
  result := fPhysicalPageHeigth
end;

// �������� �������������� ���������� ������ ����� (� �����������)
function TPrintControl.getPhysicalPageWidth: Integer;
begin
  result := fPhysicalPageWidth
end;

// �������� ���������� � �������� �� ���� �� �����������
function TPrintControl.getPixelsPerInchX: Integer;
begin
  result := fPixelsPerInchX
end;

// �������� ���������� � �������� �� ���� �� ���������
function TPrintControl.getPixelsPerInchY: Integer;
begin
  result := fPixelsPerInchY
end;

// �������� �������� �������
function TPrintControl.getPrinter: TPrinter;
begin
  result := fPrinter
end;

// �������� ����� �������� �����
function TPrintControl.getWaterMark: String;
begin
  result := fWaterMark
end;

// �������� ����� �������� �����
function TPrintControl.getWaterMarkFont: TFont;
begin
  result := fWaterMarkFont
end;

// ������� ������� ���� �� ��������
procedure TPrintControl.makeWaterMark;
var
  width, height: Integer;
  xpos, ypos: Integer;
begin
  //������������� ����� �������� �����
  assignPrinterFont(fWaterMarkFont);

  //������������� ����� ������ � ���������� ������������
  setBkMode(fPrinter.Canvas.Handle, TRANSPARENT);

  //��������� ������ �������� �����
  width := getLineWidth(fWaterMark);
  height := getLineHeight(fWaterMark);

  //��������� �������
  xpos := //fPhysicalOffsetX +
    (fPageResolutionX - width) div 2;
  ypos := //fPhysicalOffsetY +
    (fPageResolutionY - height) div 2;

  //������� ������� ����
  fPrinter.Canvas.TextOut(xpos, ypos, fWaterMark);

  //���������� ���������� �����
  assignPrinterFont(fFont)
end;

// ��������� ���������� ����� � ����������� � ���������� ����� � ��������
function TPrintControl.millimetersToPixels(p: TPoint): TPoint;
begin
  result := point(millimetersToPixelsX(p.x),
    millimetersToPixelsY(p.y))
end;

// ��������� ���������� �� ����������� � �������
function TPrintControl.millimetersToPixelsX(value: Integer): Integer;
begin
  result := round(value/25.4*fPixelsPerInchX)
end;

// ��������� ���������� �� ��������� � �������
function TPrintControl.millimetersToPixelsY(value: Integer): Integer;
begin
  result := round(value/25.4*fPixelsPerInchY)
end;

// ����������� �����
procedure TPrintControl.printText(text: TStrings);
var
  brokenText: TStrings;
  positionX, positionY: Integer;
  line: Integer;

  procedure nextPage;
  begin
    //������������� ������� �������
    positionX := 0;//getPhysicalOffsetX;
    positionY := 0;//getPhysicalOffsetY;

    //� ��������� ����� ��������
    fPrinter.NewPage;

    //� �� �������� ������� ������� ���� �� ���
    makeWaterMark
  end;

  procedure printLine;
  begin
    fPrinter.Canvas.TextOut(positionX,
      positionY,
      brokenText[line])
  end;

  procedure nextLine;
  begin
    inc(positionY,
      getLineHeight(brokenText[line]) + getLineMargin);
      
    inc(line)
  end;

begin
  //������������� ���������� ������
  fPrinter.Canvas.Font.PixelsPerInch := fPixelsPerInchX;

  //������������� ��������� ������
  assignPrinterFont(fFont);

  //��������� ����� �� ������
  brokenText := breakDownIntoLines(text);

  //������������� ������� �������
  positionX := 0;//getPhysicalOffsetX;
  positionY := 0;//getPhysicalOffsetY;

  //������ ������ ���������
  fPrinter.BeginDoc;

  //������� ������� ����
  makeWaterMark;

  //� ������ ������
  line := 0;

  //�������� ���������
  while line < brokenText.Count do begin
    //���� �� ������� �� ������� ������, �� ��������� �� ����� ��������
    if positionY + getLineHeight(brokenText[line]) > getPageResolutionY then
      nextPage;

    //�������� ������
    printLine;

    //��������� � ���������
    nextLine
  end;

  //��������� ������ ���������
  fPrinter.EndDoc;

  //���������� ��������� �����
  brokenText.Free
end;

// �������� ���������� � ��������
procedure TPrintControl.retrievePrinterInfo;
var
  DC: HDC;
begin
  DC := fPrinter.Handle;

  fPixelsPerInchX:=GetDeviceCaps(DC,LOGPIXELSX);
  fPixelsPerInchY:=GetDeviceCaps(DC,LOGPIXELSY);
  fPageWidth:=GetDeviceCaps(DC,HORZSIZE);
  fPageHeight:=GetDeviceCaps(DC,VERTSIZE);

  fPhysicalOffsetX:=GetDeviceCaps(DC,PHYSICALOFFSETX);
  fPhysicalOffsetY:=GetDeviceCaps(DC,PHYSICALOFFSETY);

  fPhysicalPageWidth:=GetDeviceCaps(DC,PHYSICALWIDTH);
  fPhysicalPageHeigth:=GetDeviceCaps(DC,PHYSICALHEIGHT);

  fPageResolutionX:=GetDeviceCaps(DC,HORZRES);
  fPageResolutionY:=GetDeviceCaps(DC,VERTRES)
end;

// ���������� ���������� ����� �������� (� ��������)
procedure TPrintControl.setLineMargin(lineMargin: Integer);
begin
  fLineMargin := lineMargin
end;

// ���������� �������� �������
procedure TPrintControl.setPrinter(printer: TPrinter);
begin
  fPrinter := printer;

  retrievePrinterInfo
end;

// ���������� ����� �������� �����
procedure TPrintControl.setWaterMark(waterMark: String);
begin
  fWaterMark := waterMark
end;

end.
