unit uNotifier;

interface

    uses
            uMap
        ;

    type

        TCallback = procedure(sender: TObject);

        TNotifier = class
        private
            subscribers:    TMap;
        public
            constructor     create;
            destructor      destroy; override;

            procedure       subscribe(event: Integer; subscriber: TNotifier); virtual;
            procedure       send(event: Integer; sender: TObject); virtual;
            procedure       notify(event: Integer; sender: TObject); virtual;
        end;

implementation

    uses
            SysUtils

        ,   uQueue
        ,   tlog
        ,   uUtils
        ;

    constructor TNotifier.create;
    begin
        inherited create;

        subscribers := TMap.create;
    end;

    destructor TNotifier.destroy;
    var
        keys:   TMapKeys;
        i:      Integer;
        queue:  TQueue;
    begin
        keys := subscribers.keys();
        for i := 0 to high(keys) do begin
            queue := subscribers.remove(keys[i]) as TQueue;
            queue.Free;
        end;

        subscribers.Free;

        inherited destroy
    end;

    procedure TNotifier.subscribe(event: Integer; subscriber: TNotifier);
    var
        queue: TQueue;
    begin
        if not subscribers.has(event) then begin
            subscribers.put(event, TQueue.create);
        end;

        queue := subscribers.get(event) as TQueue;

        queue.put(subscriber);
    end;

    procedure TNotifier.send(event: Integer; sender: TObject);
    var
        queue:  TQueue;
        i:      Integer;
    begin
        if subscribers.has(event) then begin
            queue := subscribers.get(event) as TQueue;
            for i := 0 to queue.count-1 do begin
                (queue.element(i) as TNotifier).notify(event, sender);
            end;
        end else begin
            logger.warn.print('TNotifier: attempt to send ' + itos(event) + ' event, but no subscribers found');
        end;
    end;

    procedure TNotifier.notify(event: Integer; sender: TObject);
    begin
        logger.debug.print('TNotifier: notify invoked');
    end;

end.
