unit uPrintThreadUserInterface;

{
  ����������: �������� ��������� ������ ����������� ����� ������� ������ � ������� ������
}

interface

uses
  Classes,
  uPrintJob;

type

  {
    ���: ��������� ������ ������
    �����������:
      * ��� �������� ������ ������ ������ ��������� � ������� �����
      ������ ��������������� � ptsWorking
  }
  TPrintThreadState = (

    // ����� �����������
    ptsTerminating,

    // ����� ��������
    ptsTerminated,

    // ����� ��������
    ptsAsleeping,

    // ����� ������
    ptsSleeping,

    // ����� ������������
    ptsAwakening,

    // ����� ��������
    ptsWorking
  );

  {
    ���: ��������� ������
  }
  TPrintResult = (

    // ������ ������ �������
    prSuccess,

    // ������ �� �������
    prFailed
  );

  {
    ���������: ��������� ��������� � ������ ������ ������ (������� �����)
    ����������:
      ������� ����� ��������� ���� ��������� � �������������
      ������ ������ ������ ��� ���������� � ������ ��� [������] ���������,
      � ����� ��� ������ ������� ������.
      ��� ���������� ������� � ������� ����� ���������� �������� ��������
      �����, ������� ����������� getter'��� ����� ����������
  }
  IPrintThreadMaster = interface

    // *** METHODS ***

    // ��������� ����� ������
    // ������������� ���������� ���� ��������� � �������� ptsAwakening
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure awake;

    // ������� ����� ������
    // ������������� ���������� ���� ��������� � �������� ptsAwakening
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure asleep;

    // ��������� ����� ������
    // ������������� ���������� ���� ��������� � �������� ptsAwakening
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure terminate;

    // ����������� ����������� ������ ������
    // ������������� ���������� ���� ��������� � �������� ptsWorking
    // �������������:
    //    * � ������ callConfirmAwake � ������ ������
    procedure confirmAwake;

    // ����������� ��������� ������ ������
    // ������������� ���������� ���� ��������� � �������� ptsSleeping
    // �������������:
    //    * � ������ callConfirmAsleep � ������ ������
    procedure confirmAsleep;

    // ����������� ���������� ������ ������
    // ������������� ���������� ���� ��������� � �������� ptsTerminated
    // �������������:
    //    * � ������ callConfirmTerminate � ������ ������
    procedure confirmTerminate;

    // �������� ������� ������ � �������
    // �������������:
    //    * � ������������ ����� � ������� ������
    procedure addPrintJob(printJob: TPrintJob);

    // ����������� ������ �������
    // ���������:
    //    printJob: �������, ������ �������� ���������
    //    printResult: ��������� ������
    // �������������:
    //    * � ������ callConfirmPrintJob � ������ ������
    procedure confirmPrintJob(printJob: TPrintJob; result: TPrintResult);

    // *** GETTERS ***

    // �������� ��������� ������ ������
    // ������������ ��������:
    //    ��������� ������ ������
    // �������������:
    //    * ����� ������ ���������� � ������ callGetPrintThreadState
    function getPrintThreadState: TPrintThreadState;

    // �������� ������� ������
    // ���������� ������ ������� ������ �� �������, ���� ��� ���� � ������� ���
    // �� �������
    // ������������ ��������:
    //    * ������� ������, ���� ������� �� �����
    //    * null � ��������������� ������
    // �������������:
    //    * � ������ callGetPrintJob � ������ ������
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
    ���������: ����� ������
    ����������:
      ������������ ��� ����������� �������������� � ������� ������ (��������� ��
      ��� ������ � �������� ��������� �������� ��������� ������)
    �����������:
      ������������������ ������ getter'�� (� �.�. is...)
        get... [
          synchronized call... [
            f... := master.get...
          ]

          result := f...
        ]

      ������������������ ������ setter'��
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

    //todo: ��������, callers ������� ����������� ��������������� � ����������� ������ ������

    procedure callGetPrintThreadState;

    procedure callGetPrintJob;

    procedure callConfirmPrintJob;

    procedure callConfirmAwake;

    procedure callConfirmAsleep;

    procedure callConfirmTerminate;

  end;

implementation

end.
