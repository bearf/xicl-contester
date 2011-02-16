unit uPrintThreadUserInterface;

{
  Назначение: содержит интерфейс обмена информацией между главной формой и потоком печати
}

interface

uses
  Classes,
  uPrintJob;

type

  {
    Тип: состояние потока печати
    Комментарии:
      * при создании нового потока печати состояние в главной форме
      должно устанавливаться в ptsWorking
  }
  TPrintThreadState = (

    // поток завершается
    ptsTerminating,

    // поток завершен
    ptsTerminated,

    // поток засыпает
    ptsAsleeping,

    // поток заснул
    ptsSleeping,

    // поток пробуждается
    ptsAwakening,

    // поток работает
    ptsWorking
  );

  {
    Тип: результат печати
  }
  TPrintResult = (

    // печать прошла успешно
    prSuccess,

    // печать не удалась
    prFailed
  );

  {
    Интерфейс: хранитель состояний и данных потока печати (главная форма)
    Назначение:
      главная форма реализует этот интерфейс и предоставляет
      потоку печати методы для считывания и записи его [потока] состояния,
      а также для чтения заданий печати.
      Для управления потоком в главной форме достаточно изменить значения
      полей, который считываются getter'ами этого интерфейса
  }
  IPrintThreadMaster = interface

    // *** METHODS ***

    // разбудить поток печати
    // устанавливает внутреннее поле состояния в значение ptsAwakening
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure awake;

    // усыпить поток печати
    // устанавливает внутреннее поле состояния в значение ptsAwakening
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure asleep;

    // завершить поток печати
    // устанавливает внутреннее поле состояния в значение ptsAwakening
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure terminate;

    // подтвержить пробуждение потока печати
    // устанавливает внутреннее поле состояния в значение ptsWorking
    // Использование:
    //    * в методе callConfirmAwake в потоке печати
    procedure confirmAwake;

    // подтвержить засыпание потока печати
    // устанавливает внутреннее поле состояния в значение ptsSleeping
    // Использование:
    //    * в методе callConfirmAsleep в потоке печати
    procedure confirmAsleep;

    // подтвержить завершение потока печати
    // устанавливает внутреннее поле состояния в значение ptsTerminated
    // Использование:
    //    * в методе callConfirmTerminate в потоке печати
    procedure confirmTerminate;

    // добавить задание печати в очередь
    // Использование:
    //    * в произвольном месте в главном потоке
    procedure addPrintJob(printJob: TPrintJob);

    // подтвердить печать задания
    // параметры:
    //    printJob: задание, печать которого завершена
    //    printResult: результат печати
    // использование:
    //    * в методе callConfirmPrintJob в потоке печати
    procedure confirmPrintJob(printJob: TPrintJob; result: TPrintResult);

    // *** GETTERS ***

    // Получить состояние потока печати
    // Возвращаемое значение:
    //    состояние потока печати
    // Использование:
    //    * метод должен вызываться в методе callGetPrintThreadState
    function getPrintThreadState: TPrintThreadState;

    // Получить задание печати
    // Возвращает первое задание печати из очереди, если оно есть и удаляет его
    // из очереди
    // Возвращаемое значение:
    //    * задание печати, если очередь не пуста
    //    * null в противоположном случае
    // использование:
    //    * в методе callGetPrintJob в потоке печати
    function getPrintJob: TPrintJob;

    function hasPrintJob: Boolean;

    function isAwakening: Boolean;

    function isAsleeping: Boolean;

    function isTerminating: Boolean;

    function isTerminated: Boolean;

    function isSleeping: Boolean;

    function isWorking: Boolean;

  end;

  {
    Интерфейс: поток печати
    Назначение:
      предназначен для организации взаимодействия с главной формой (получения от
      нее данных и ответной установки текущего состояния потока)
    Комментарии:
      последовательность вызова getter'ов (в т.ч. is...)
        get... [
          synchronized call... [
            f... := master.get...
          ]

          result := f...
        ]

      последовательность вызова setter'ов
        confirm... (X) [
          f... := X

          synchronized call... [
            master.confirm... (f)
          ]
        ]
  }
  IPrintThreadSlave = interface

    // *** METHODS ***

    procedure confirmAwake;

    procedure confirmAsleep;

    procedure confirmTerminate;

    procedure confirmPrintJob(printJob: TPrintJob; result: TPrintResult);

    // *** GETTERS ***

    function getPrintThreadState: TPrintThreadState;

    function getPrintJob: TPrintJob;

    function hasPrintJob: Boolean;

    function isAwakening: Boolean;

    function isAsleeping: Boolean;

    function isTerminating: Boolean;

    function isTerminated: Boolean;

    function isSleeping: Boolean;

    function isWorking: Boolean;

    // *** CALLERS ***

    //todo: возможно, callers следует переместить непосредственно в определение класса потока

    procedure callGetPrintThreadState;

    procedure callGetPrintJob;

    procedure callConfirmPrintJob;

    procedure callConfirmAwake;

    procedure callConfirmAsleep;

    procedure callConfirmTerminate;

  end;

implementation

end.
