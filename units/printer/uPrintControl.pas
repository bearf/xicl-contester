unit uPrintControl;

interface

uses
  Types,
  Classes,
  Printers,
  Graphics,
  Windows;

const

  // расстояние между строками по умолчанию
  _lineMargin = 2;

  // поля по умолчанию
  _margin = 20;

  // параметры шрифта по умолчанию
  _fontSize = 10;
  _fontStyle: TFontStyles = [];
  _fontName: TFontName = 'Courier New';
  _fontColor: TColor = clBlack;

  //параметры шрифта водяного знака
  _waterMarkFontSize = 72;
  _waterMarkFontStyle: TFontStyles = [fsBold];
  _waterMarkFontName: TFontName = 'Arial';
  _waterMarkFontColor: TColor = $00E0E0E0;

type

  {
    Класс: доступ к принтеру на уровне печати документов
    Назначение:
      Обеспечивать возможность печати простых текстовых документов
  }
  TPrintControl = class
  private

    // *** FIELDS ***

    // Используемый принтер
    fPrinter: TPrinter;

    // Разрешение в пикселях на дюйм по горизонтали
    fPixelsPerInchX: Integer;

    // Разрешение в пикселях на дюйм по вертикали
    fPixelsPerInchY: Integer;

    // Горизонтальный размер области печати (в миллиметрах)
    fPageWidth: Integer;

    // Вертикальный размер области печати (в миллиметрах)
    fPageHeight: Integer;

    // Смещение области печати слева (в пикселах)
    fPhysicalOffsetX: Integer;

    // Смещение области печати сверху (в пикселах)
    fPhysicalOffsetY: Integer;

    // Горизонтальный размер области печати (в пикселах)
    fPageResolutionX: Integer;

    // Вертикальный размер области печати (в пикселах)
    fPageResolutionY: Integer;

    // Горизонтальный физический размер листа (в миллиметрах)
    fPhysicalPageWidth: Integer;

    // Вертикальный физический размер листа (в миллиметрах)
    fPhysicalPageHeigth: Integer;

    // Поля печати в миллиметрах
    fMargins: TRect;

    // расстояния между строками в пикселах
    fLineMargin: Integer;

    // шрифт
    fFont: TFont;

    // шрифт водяного знака
    fWaterMarkFont: TFont;

    // водяной знак
    fWaterMark: String;

    // *** METHODS ***

    // Получить информацию о принтере
    // Запрашивает информацию о принтере и заносит ее в поля класса
    procedure retrievePrinterInfo;

    // Перевести миллиметры по горизонтали в пикселы
    // Параметры:
    //   value: значение в миллиметрах
    // Возвращаемое значение:
    //   значение value, переведенное в пикселы
    function millimetersToPixelsX(value: Integer): Integer;

    // Перевести миллиметры по вертикали в пикселы
    // Параметры:
    //   value: значение в миллиметрах
    // Возвращаемое значение:
    //   значение value, переведенное в пикселы
    function millimetersToPixelsY(value: Integer): Integer;

    // Перевести координаты точки в миллиметрах в координаты точки в пикселах
    // Параметp
    //    p: координаты точки в миллиметрах
    // Возвращаемое значение:
    //   координаты точки p, переведенные в пикселы
    function millimetersToPixels(p: TPoint): TPoint;

    // Разбивает текст на строки
    // Разбивает текст на строки с тем учетом, чтобы каждая из них поместилась в области печати
    // Параметры:
    //    text: входной текст
    // Возвращаемое значение:
    //    текст, разбитый на строки
    // Перед:
    //    * должен быть выполнен вызов Printer.beginDoc
    function breakDownIntoLines(text: TStrings): TStrings;

    // Получить длину строки в пикселах при печати
    // Возвращаемое значение:
    //    длина строки в пикселах при печати
    function getLineWidth(line: String): Integer;

    // Получить высоту строки в пикселах при печати
    // Возвращаемое значение:
    //    высота строки в пикселах при печати
    function getLineHeight(line: String): Integer;

    // Установить параметры шрифта принтера
    // Устанавливает параметры шрифта принтера, исключая названия шрифта
    // (т.к. это приводит к неполной печати документа; причина неизвестна)
    // Параметры:
    //    font: шрифт, параметры которого следует использовать
    // Вызовы перед:
    //    * должен быть установлен параметр fPrinter.Canvas.Font.PixelsPerInch
    procedure assignPrinterFont(font: TFont);

    // Вывести водяной знак на страницу
    // Устанавливает шрифт водяного знака,
    // выводит водяной знак и устанавливает шрифт в обычный
    procedure makeWaterMark;

  public

    // *** CONSTRUCTORS ***

    // Конструктор по умолчанию
    // Получает информацию о принтере
    constructor create;

    // *** DESTRUCTORS ***

    // деструктор
    // уничтожает принтер
    // комментарии
    //    * принтер уничтожается даже если он был установлен методом setPrinter
    destructor destroy; override;

    // *** METHODS ***

    // Распечатать текст
    // Распечатать текст, используя многостраничную печать и переносы строк
    // Параметры:
    //    text: массив строк для печати
    procedure printText(text: TStrings);

    // *** GETTERS ***

    // Получить разрешение в пикселях на дюйм по горизонтали
    // Возвращаемое значение:
    //
    function getPixelsPerInchX: Integer;

    // Получить разрешение в пикселях на дюйм по вертикали
    // Возвращаемое значение:
    //    разрешение в пикселях на дюйм по горизонтали
    function getPixelsPerInchY: Integer;

    // Получить горизонтальный размер области печати (в миллиметрах)
    // Возвращаемое значение:
    //    горизонтальный размер области печати (в миллиметрах
    function getPageWidth: Integer;

    // Получить вертикальный размер области печати (в миллиметрах)
    // Возвращаемое значение:
    //    вертикальный размер области печати (в миллиметрах)
    function getPageHeight: Integer;

    // Получить смещение области печати слева (в пикселах)
    // Возвращаемое значение:
    //    смещение области печати слева (в пикселах)
    function getPhysicalOffsetX: Integer;

    // Получить смещение области печати сверху (в пикселах)
    // Возвращаемое значение:
    //    смещение области печати сверху (в пикселах)
    function getPhysicalOffsetY: Integer;

    // Получить горизонтальный размер области печати (в пикселах)
    // Возвращаемое значение:
    //    горизонтальный размер области печати (в пикселах)
    function getPageResolutionX: Integer;

    // Получить вертикальный размер области печати (в пикселах)
    // Возвращаемое значение:
    //    вертикальный размер области печати (в пикселах)
    function getPageResolutionY: Integer;

    // Получить горизонтальный физический размер листа (в миллиметрах)
    // Возвращаемое значение:
    //    горизонтальный физический размер листа (в миллиметрах)
    function getPhysicalPageWidth: Integer;

    // Получить вертикальный физический размер листа (в миллиметрах)
    // Возвращаемое значение:
    //    вертикальный физический размер листа (в миллиметрах)
    function getPhysicalPageHeigth: Integer;

    // Получить поля печати в миллиметрах
    // Возвращаемое значение:
    //    поля печати в миллиметрах
    function getMargins: TRect;

    // Получить расстояние между строками (в пикселах)
    // Возвращаемое значение:
    //    расстояние между строками (в пикселах)
    function getLineMargin: Integer;

    // Получить используемый шрифт
    // Возвращаемое значение:
    //    используемый шрифт
    function getFont: TFont;

    // Получить шрифт водяного знака
    // Возвращаемое значение:
    //    шрифт водяного знака
    function getWaterMarkFont: TFont;

    // Получить текст водяного знака
    // Возвращаемое значение:
    //    текст водяного знака
    function getWaterMark: String;

    // Получить активный принтер
    // Возвращаемое значение:
    //    активный принтер
    function getPrinter: TPrinter;

    // *** SETTERS ***

    // Установить расстояние между строками (в пикселах)
    // Параметры:
    //    lineMargin: расстояние между строками (в пикселах)
    procedure setLineMargin(lineMargin: Integer);

    // Установить текст водяного знака
    // Параметры:
    //    waterMark: текст водяного знака
    procedure setWaterMark(waterMark: String);

    // Установить активный принтер
    // Устанавливает активный принтер
    // Вызывает процедуру извлечения его данных
    procedure setPrinter(printer: TPrinter);

  end;

implementation

{ TPrintControl }

// Установить параметры шрифта принтера
procedure TPrintControl.assignPrinterFont(font: TFont);
begin
  fPrinter.Canvas.Font.Size := font.Size;
  fPrinter.Canvas.Font.Style := font.Style;
  fPrinter.Canvas.Font.Color := font.Color;
  fPrinter.Canvas.Font.Name := _fontName;
end;

// Разбивает текст на строки
function TPrintControl.breakDownIntoLines(text: TStrings): TStrings;

  procedure addLine(text: TStrings; line: String);
  var
    i: Integer;
    left, rest: String;

  begin
    //если строка пустая, то сразу ее добавляем
    if length(line) = 0 then
      text.Add(line)
    //иначе пытаемся разбить на подстроки
    else
      //пока оставшаяся неразбитая часть строки не пуста
      while length(line) > 0 do begin
        //пытаемся напечатать всю оставшуюся часть
        left := line;
        rest := '';
        i := length(line);

        //пока оставшаяся часть не помещается в области печати
        while getLineWidth(left) > getPageResolutionX do begin
          //убираем из нее по одному символу и переносим в неразбитый остаток строки
          dec(i);
          left := copy(line, 1, i);
          rest := copy(line, i+1, length(line)-i)
        end;

        //добавляем найденную подстроку
        text.Add(left);

        //и пытаемся разбить остаток
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

// Конструктор по умолчанию
constructor TPrintControl.create;
begin
  inherited create;

  //инициализация
  fLineMargin := _lineMargin;

  //принтер
  //fPrinter := TPrinter.Create;
  fPrinter := Printer;

  //шрифт
  fFont := TFont.Create;
  fFont.Size := _fontSize;
  fFont.Style := _fontStyle;
  fFont.Name := _fontName;
  fFont.Color := _fontColor;

  //шрифт водяного знака
  fWaterMarkFont := TFont.Create;
  fWaterMarkFont.Size := _waterMarkFontSize;
  fWaterMarkFont.Style := _waterMarkFontStyle;
  fWaterMarkFont.Name := _waterMarkFontName;
  fWaterMarkFont.Color := _waterMarkFontColor;

  //поля
  fMargins.Top := _margin;
  fMargins.Left := _margin;

  fMargins.Bottom := _margin;
  fMargins.Right := _margin;

  //запрашиваем информацию о принтере
  retrievePrinterInfo
end;

// деструктор
destructor TPrintControl.destroy;
begin
  //fPrinter.Free;

  fWaterMarkFont.Free;

  fFont.Free;

  inherited
end;

// Получить используемый шрифт
function TPrintControl.getFont: TFont;
begin
  result := fFont
end;

// Получить высоту строки в пикселах при печати
function TPrintControl.getLineHeight(line: String): Integer;
begin
  if line = '' then
    result := fPrinter.Canvas.TextHeight('#')
  else
    result := fPrinter.Canvas.TextHeight(line)
end;

// Получить расстояние между строками (в пикселах)
function TPrintControl.getLineMargin: Integer;
begin
  result := fLineMargin
end;

// Получить длину строки в пикселах при печати
function TPrintControl.getLineWidth(line: String): Integer;
begin
  result := fPrinter.Canvas.TextWidth(line)
end;

// Получить поля печати в миллиметрах
function TPrintControl.getMargins: TRect;
begin
  result := fMargins
end;

// Получить вертикальный размер области печати (в миллиметрах)
function TPrintControl.getPageHeight: Integer;
begin
  result := fPageHeight
end;

// Получить горизонтальный размер области печати (в пикселах)
function TPrintControl.getPageResolutionX: Integer;
begin
  result := fPageResolutionX
end;

// Получить вертикальный размер области печати (в пикселах)
function TPrintControl.getPageResolutionY: Integer;
begin
  result := fPageResolutionY
end;

// Получить горизонтальный размер области печати (в миллиметрах)
function TPrintControl.getPageWidth: Integer;
begin
  result := fPageWidth
end;

// Получить смещение области печати слева (в пикселах)
function TPrintControl.getPhysicalOffsetX: Integer;
begin
  result := fPhysicalOffsetX
end;

// Получить смещение области печати сверху (в пикселах)
function TPrintControl.getPhysicalOffsetY: Integer;
begin
  result := fPhysicalOffsetY
end;

// Получить вертикальный физический размер листа (в миллиметрах)
function TPrintControl.getPhysicalPageHeigth: Integer;
begin
  result := fPhysicalPageHeigth
end;

// Получить горизонтальный физический размер листа (в миллиметрах)
function TPrintControl.getPhysicalPageWidth: Integer;
begin
  result := fPhysicalPageWidth
end;

// Получить разрешение в пикселях на дюйм по горизонтали
function TPrintControl.getPixelsPerInchX: Integer;
begin
  result := fPixelsPerInchX
end;

// Получить разрешение в пикселях на дюйм по вертикали
function TPrintControl.getPixelsPerInchY: Integer;
begin
  result := fPixelsPerInchY
end;

// Получить активный принтер
function TPrintControl.getPrinter: TPrinter;
begin
  result := fPrinter
end;

// Получить текст водяного знака
function TPrintControl.getWaterMark: String;
begin
  result := fWaterMark
end;

// Получить шрифт водяного знака
function TPrintControl.getWaterMarkFont: TFont;
begin
  result := fWaterMarkFont
end;

// Вывести водяной знак на страницу
procedure TPrintControl.makeWaterMark;
var
  width, height: Integer;
  xpos, ypos: Integer;
begin
  //устанавливаем шрифт водяного знака
  assignPrinterFont(fWaterMarkFont);

  //устанавливаем режим вывода с поддержкой прозрачности
  setBkMode(fPrinter.Canvas.Handle, TRANSPARENT);

  //вычисляем размер водяного знака
  width := getLineWidth(fWaterMark);
  height := getLineHeight(fWaterMark);

  //вычисляем позицию
  xpos := //fPhysicalOffsetX +
    (fPageResolutionX - width) div 2;
  ypos := //fPhysicalOffsetY +
    (fPageResolutionY - height) div 2;

  //выводим водяной знак
  fPrinter.Canvas.TextOut(xpos, ypos, fWaterMark);

  //возвращаем нормальный шрифт
  assignPrinterFont(fFont)
end;

// Перевести координаты точки в миллиметрах в координаты точки в пикселах
function TPrintControl.millimetersToPixels(p: TPoint): TPoint;
begin
  result := point(millimetersToPixelsX(p.x),
    millimetersToPixelsY(p.y))
end;

// Перевести миллиметры по горизонтали в пикселы
function TPrintControl.millimetersToPixelsX(value: Integer): Integer;
begin
  result := round(value/25.4*fPixelsPerInchX)
end;

// Перевести миллиметры по вертикали в пикселы
function TPrintControl.millimetersToPixelsY(value: Integer): Integer;
begin
  result := round(value/25.4*fPixelsPerInchY)
end;

// Распечатать текст
procedure TPrintControl.printText(text: TStrings);
var
  brokenText: TStrings;
  positionX, positionY: Integer;
  line: Integer;

  procedure nextPage;
  begin
    //устанавливаем текущую позицию
    positionX := 0;//getPhysicalOffsetX;
    positionY := 0;//getPhysicalOffsetY;

    //и запускаем новую страницу
    fPrinter.NewPage;

    //и не забываем вывести водяной знак на нее
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
  //устанавливаем разрешение шрифта
  fPrinter.Canvas.Font.PixelsPerInch := fPixelsPerInchX;

  //устанавливаем параметры шрифта
  assignPrinterFont(fFont);

  //разбиваем текст на строки
  brokenText := breakDownIntoLines(text);

  //устанавливаем текущую позицию
  positionX := 0;//getPhysicalOffsetX;
  positionY := 0;//getPhysicalOffsetY;

  //начать печать документа
  fPrinter.BeginDoc;

  //выводим водяной знак
  makeWaterMark;

  //с первой строки
  line := 0;

  //печатаем построчно
  while line < brokenText.Count do begin
    //если мы вылезли за область печати, то переходим на новую страницу
    if positionY + getLineHeight(brokenText[line]) > getPageResolutionY then
      nextPage;

    //печатаем строку
    printLine;

    //переходим к следующей
    nextLine
  end;

  //закончить печать документа
  fPrinter.EndDoc;

  //уничтожаем созданный текст
  brokenText.Free
end;

// Получить информацию о принтере
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

// Установить расстояние между строками (в пикселах)
procedure TPrintControl.setLineMargin(lineMargin: Integer);
begin
  fLineMargin := lineMargin
end;

// Установить активный принтер
procedure TPrintControl.setPrinter(printer: TPrinter);
begin
  fPrinter := printer;

  retrievePrinterInfo
end;

// Установить текст водяного знака
procedure TPrintControl.setWaterMark(waterMark: String);
begin
  fWaterMark := waterMark
end;

end.
