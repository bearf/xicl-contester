unit uQueue;

interface

    const

        _QUEUE_SIZE  = 1000;

    type

        TQueue = class
        private
            queue:  array[0.._QUEUE_SIZE-1] of TObject;
            pb, pe,
            stored: Integer;
        public
            constructor create;
            destructor  destroy; override;

            procedure   put(item: TObject);
            function    get: TObject;
            function    pop: TObject;
            function    element(index: Integer): TObject;
            function    count: Integer;
            function    empty: Boolean;
        end;

implementation

    uses
            SysUtils

        ,   tlog
        ,   uUtils
        ;

    procedure incr(var x: Integer);
    begin
        inc(x); x := x mod _QUEUE_SIZE;
    end;

    constructor TQueue.create;
    begin
        inherited create;

        pb      := 0;
        pe      := 0;
        stored  := 0;
    end;

    destructor TQueue.destroy;
    begin
        inherited destroy;
    end;

    procedure TQueue.put(item: TObject);
    begin
        if stored = _QUEUE_SIZE then begin
            fatal('queue: attempt to put item in queue but it''s already reached its maximum length');
        end;

        queue[pe] := item;
        incr(pe);
        inc(stored);
    end;

    function TQueue.get: TObject;
    begin
        result := element(0); // raises FATAL if no such element
    end;

    function TQueue.pop: TObject;
    begin
        result := element(0); // raises FATAL if no such element

        incr(pb);
        dec(stored);
    end;

    function TQueue.element(index: Integer): TObject;
    begin
        if index >= stored then begin
            fatal('queue: attepmt to reach element ' + itos(index) + ', but queue has only [0..' + itos(stored-1) + '] elements');
        end;
        
        result := queue[(pb + index) mod _QUEUE_SIZE];
    end;

    function TQueue.count: Integer;
    begin
        result := self.stored;
    end;

    function TQueue.empty: Boolean;
    begin
        result := 0 = self.count
    end;

end.
