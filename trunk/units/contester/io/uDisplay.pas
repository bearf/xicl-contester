unit uDisplay;

interface

    uses
            Graphics, ExtCtrls, Windows, Classes

        ,   tlog
        ;

    const

        MAX_WIDTH           = 1600;
        MAX_HEIGHT          = 1200;
        LINE_HEIGHT         = 10; // px
        FONT_SIZE           = 8; // pt
        FONT_NAME           = 'Arial';
        FONT_STYLE          = [];
        BORDER_COLOR        = clBlack;
        BORDER_WIDTH        = 1;
        BACKGROUND_COLOR    = clWhite;
        PADDING             = 10;
        MARGIN              = 10;
        CONSOLE_HEIGHT      = 32;

    type

        TDisplay = class
        private
            box:        TPaintBox;
            cnv:        TCanvas;
            dc:         HDC;
            bmp:        HBITMAP;
        public
            constructor create(box: TPaintBox);
            destructor  destroy; override;

            function    limit: Integer;
            procedure   show(strings: TStrings);
            procedure   buffer(buffer: TBuffer);
            procedure   resize(rect: TRect);
        end;

implementation

    uses
            Math
        ;

    constructor TDisplay.Create(box: TPaintBox);
    begin
        self.box        := box;

        cnv             := TCanvas.Create;
        dc              := CreateCompatibleDC(box.Canvas.Handle);
        bmp             := CreateCompatibleBitmap(box.Canvas.Handle, MAX_WIDTH, MAX_HEIGHT);

        SelectObject(dc, bmp); cnv.Handle := dc;

        SetBkMode(cnv.Handle, TRANSPARENT);

        cnv.Font.Name   := FONT_NAME;
        cnv.Font.Size   := FONT_SIZE;
        cnv.Font.Style  := FONT_STYLE;
        cnv.Pen.Color   := BORDER_COLOR;
        cnv.Pen.Width   := BORDER_WIDTH;
        cnv.Brush.Color := BACKGROUND_COLOR;
        cnv.Brush.Style := bsSolid;
    end;

    destructor TDisplay.destroy;
    begin
        DeleteDC(dc);
        DeleteObject(bmp);
        cnv.Free;
    end;

    procedure TDisplay.show(strings: TStrings);
    var
        count,
        i:      Integer;
    begin
        count   := strings.count;

        cnv.FillRect(box.ClientRect);
        cnv.Rectangle(box.ClientRect);

        for i := 0 to count-1 do begin
            cnv.Font.Color := logger.color(strings[i]);

            cnv.textOut(
                    PADDING
                ,   PADDING + i * LINE_HEIGHT
                ,   strings[i]
            );
        end;

        box.Canvas.CopyMode := cmSrcCopy;
        box.Canvas.CopyRect(box.ClientRect, cnv, box.ClientRect);
    end;

    procedure TDisplay.buffer(buffer: TBuffer);
    var
        count,
        i:          Integer;
        strings:    TStrings;
    begin
        count   := buffer.count;
        strings := TStringList.create;

        for i := 0 to count-1 do begin
            strings.Add(buffer[i]);
        end;

        show(strings);
    end;

    function TDisplay.limit: Integer;
    begin
        result := Math.floor((self.box.Height - PADDING*2) / LINE_HEIGHT);
    end;

    procedure TDisplay.resize(rect: TRect);
    begin
        self.box.Left   := rect.Left;
        self.box.Top    := rect.Top;
        self.box.Width  := rect.Right - Rect.Left + 1;
        self.box.Height := rect.Bottom - Rect.Top + 1;
    end;

end.
