unit uWorker;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Defaults,
  System.Generics.Collections, Winapi.Windows, Winapi.Messages;

const
  MAX_WORKER_COUNT = 32;

const
  WM_WORKER_MGR_TERMINATE = WM_USER + 100;
  WM_WORKER_QUERY = WM_USER + 101;
  WM_WORKER_FEEDBACK = WM_USER + 102;

type
  TWorker = class;

  TWorkerMgr = class;

  PWorkerQuery = ^TWorkerQuery;

  TWorkerReport = ( wrProgress, wrState, wrData, wrData2, wrData3, wrData4 );

  TWorkerState = ( wsStarted, wsSuspended, wsResumed, wsAborted, wsFailed,
    wsFinished );

  TWorkerProgressEvent = procedure( Sender : TWorker; Progress : integer )
    of object;

  TWorkerStateEvent = procedure( Sender : TWorker; State : TWorkerState )
    of object;

  TWorkerDataEvent = procedure( Sender : TWorker; Count : integer;
    Data0, Data1, Data2, Data3 : TObject ) of object;

  TWorkerQuery = ( wqContinue, wqAbort, wqSuspend );

  TWorkerQueryEvent = procedure( Sender : TWorker; var Query : TWorkerQuery )
    of object;

  TWorkMethod = function( Worker : TWorker; Param : TObject )
    : TWorkerState of object; // wsAborted, wsFailed, wsFinished

  PWorkerReportRec = ^TWorkerReportRec;

  TWorkerReportRec = record
    ReportType : TWorkerReport;
    DataCount : integer;
    Data0 : TObject;
    Data1 : TObject;
    Data2 : TObject;
    Data3 : TObject;
  end;

  TWorker = class( TThread )
  private
    // Access via WorkerMgr
    FName : string;
    FTag : integer;
    FOwner : TWorkerMgr;
    FAlloced : LongBool;
    FAutoFree : LongBool;

    // Set by Start( ... )
    FWorkMethod : TWorkMethod;
    FWorkParam : TObject;
    FOnQuery : TWorkerQueryEvent;
    FOnState : TWorkerStateEvent;
    FOnProgress : TWorkerProgressEvent;
    FOnData : TWorkerDataEvent;

    // Change by Execute()
    FWorking : LongBool;
    FExecuting : LongBool;
    // Wait by Execute()
    FStartEvent : THandle;
    FExitEvent : THandle;

    FWaitAbortedEvent : THandle;
    FWaitSuspendedEvent : THandle;
    FWaitResumedEvent : THandle;

    procedure Execute; override;
    procedure AfterConstruction; override;

    procedure DoQuery( var Result : TWorkerQuery );
    procedure DoFeedback( ReportRec : PWorkerReportRec );

    procedure Query( var Result : TWorkerQuery );
    procedure Report( ReportType : TWorkerReport; Data0 : TObject;
      Data1 : TObject = nil; Data2 : TObject = nil; Data3 : TObject = nil;
      DataCount : integer = 1 );

  public
    // Called by Main Thread
    // Create Thread and Wait until Thread Executed
    constructor Create( Owner : TWorkerMgr; Name : string = 'Worker';
      Tag : integer = 0 );
    // Wait unilt Thread Terminated then Destroy Thread
    destructor Destroy; override;
    // 1. AllocWorker( ... ) < Create and Wait until Thread Executed >
    // 2. Start( ... ) < Wait until Worker Worked >
    procedure Start( WorkMethod : TWorkMethod; WorkParam : TObject = nil;
      OnState : TWorkerStateEvent = nil; OnQuery : TWorkerQueryEvent = nil;
      OnProgress : TWorkerProgressEvent = nil;
      OnData : TWorkerDataEvent = nil );
    procedure Suspend( );
    procedure Resume( );
    procedure Abort( );

    // Called by Worker's Work
    function AbortPending( ) : LongBool;
    procedure FeedbackState( State : TWorkerState );
    procedure FeedbackProgress( Progress : integer );
    procedure FeedbackData( Data : TObject );
    procedure FeedbackData2( Data0, Data1 : TObject );
    procedure FeedbackData3( Data0, Data1, Data2 : TObject );
    procedure FeedbackData4( Data0, Data1, Data2, Data3 : TObject );

    // For Main Thread
    property name : string read FName write FName;
    property Tag : integer read FTag write FTag;
    property Working : LongBool read FWorking;
    property Executing : LongBool read FExecuting;
  end;

  TWorkerMgr = class( TThread )
  private
    FName : string;

    FThreadWindow : HWND;
    FProcessWindow : HWND;
    FReadyEvent : THandle;

    FWorkerList : TThreadList< TWorker >;

    procedure TerminatedSet; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function PostThreadMessage( Msg, WParam, LParam : NativeUInt ) : LongBool;
    function SendThreadMessage( Msg, WParam, LParam : NativeUInt ) : NativeInt;

    function PostProcessMessage( Msg, WParam, LParam : NativeUInt ) : LongBool;
    function SendProcessMessage( Msg, WParam, LParam : NativeUInt ) : NativeInt;

    procedure CreateThreadWindow;
    procedure DeleteThreadWindow;
    procedure ThreadWndMethod( var Msg : TMessage );

    procedure CreateProcessWindow;
    procedure DeleteProcessWindow;
    procedure ProcessWndMethod( var Msg : TMessage );

    procedure Execute; override;
    procedure FreeWorkers( );

  public
    constructor Create( Name : string = 'WorkerMgr' );
    destructor Destroy; override;

    function AllocWorker( Name : string = 'Worker'; Tag : integer = 0;
      AutoFree : LongBool = TRUE ) : TWorker;
    procedure FreeWorker( Worker : TWorker );
  end;

implementation

{ TWorker }

procedure DeallocateHWnd( Wnd : HWND );
var
  Instance : Pointer;
begin
  Instance := Pointer( GetWindowLong( Wnd, GWL_WNDPROC ) );
  if Instance <> @DefWindowProc then
  begin
    { make sure we restore the default windows procedure before freeing memory }
    SetWindowLong( Wnd, GWL_WNDPROC, Longint( @DefWindowProc ) );
    FreeObjectInstance( Instance );
  end;
  DestroyWindow( Wnd );
end;

// SetEvent()
// Any number of waiting threads, or threads that subsequently
// begin wait operations for the specified event object
// can be released while the object's state is signaled.
procedure WaitForSingleObject( var WaitEvent : THandle );
var
  Msg : TMsg;
begin
  if WaitEvent = 0 then
    WaitEvent := CreateEvent( nil, TRUE, FALSE, '' );

  // Winapi.Windows.WaitForSingleObject( WaitEvent, INFINITE );
  while TRUE do
  begin
    // Application.ProcessMessages( );
    PeekMessage( Msg, 0, 0, 0, PM_NOREMOVE );

    if WAIT_OBJECT_0 = MsgWaitForMultipleObjects( 1, WaitEvent, FALSE, INFINITE,
      QS_ALLINPUT ) then
    begin
      ResetEvent( WaitEvent );
      CloseHandle( WaitEvent );
      WaitEvent := 0;
      Exit;
    end;
  end;
end;

procedure TWorker.DoQuery( var Result : TWorkerQuery );
begin
  if Assigned( FOnQuery ) then
    FOnQuery( Self, Result );
end;

procedure TWorker.DoFeedback( ReportRec : PWorkerReportRec );
begin
  if ReportRec.ReportType = wrProgress then
  begin
    if Assigned( FOnProgress ) then
      FOnProgress( Self, integer( ReportRec.Data0 ) );
  end else if ReportRec.ReportType = wrState then
  begin
    if Assigned( FOnState ) then
      FOnState( Self, TWorkerState( ReportRec.Data0 ) );
  end else if Assigned( FOnData ) then
    FOnData( Self, ReportRec.DataCount, ReportRec.Data0, ReportRec.Data1,
      ReportRec.Data2, ReportRec.Data3 );
end;

procedure TWorker.Query( var Result : TWorkerQuery );
begin
  Result := wqContinue;
  if Assigned( FOnQuery ) then
    FOwner.SendProcessMessage( WM_WORKER_QUERY, NativeUInt( Self ),
      NativeUInt( @Result ) );
end;

procedure TWorker.Report( ReportType : TWorkerReport;
  Data0, Data1, Data2, Data3 : TObject; DataCount : integer );
var
  ReportRec : PWorkerReportRec;
begin
  if ReportType = wrProgress then
  begin
    if not Assigned( FOnProgress ) then
      Exit;
  end else if ReportType = wrState then
  begin
    if not Assigned( FOnState ) then
      Exit;
  end else if not Assigned( FOnData ) then
    Exit;

  New( ReportRec );

  ReportRec.ReportType := ReportType;
  ReportRec.DataCount := DataCount;
  ReportRec.Data0 := Data0;
  ReportRec.Data1 := Data1;
  ReportRec.Data2 := Data2;
  ReportRec.Data3 := Data3;
  FOwner.SendProcessMessage( WM_WORKER_FEEDBACK, NativeUInt( Self ),
    NativeUInt( ReportRec ) );

  Dispose( ReportRec );

end;

procedure TWorker.FeedbackState( State : TWorkerState );
begin
  Report( wrState, TObject( State ) );
  if State > wsResumed then
  begin
    if FAutoFree then
      FAlloced := FALSE;
  end;
end;

procedure TWorker.FeedbackProgress( Progress : integer );
begin
  Report( wrProgress, TObject( Progress ) );
end;

procedure TWorker.FeedbackData( Data : TObject );
begin
  Report( wrData, Data );
end;

procedure TWorker.FeedbackData2( Data0, Data1 : TObject );
begin
  Report( wrData2, Data0, Data1, nil, nil, 2 );
end;

procedure TWorker.FeedbackData3( Data0, Data1, Data2 : TObject );
begin
  Report( wrData3, Data0, Data1, Data2, nil, 3 );
end;

procedure TWorker.FeedbackData4( Data0, Data1, Data2, Data3 : TObject );
begin
  Report( wrData4, Data0, Data1, Data2, Data3, 4 );
end;

function TWorker.AbortPending : LongBool;
var
  QueryResult : TWorkerQuery;
  SuspendNeed : LongBool;
  AbortNeed : LongBool;
begin
  AbortNeed := FALSE;
  if FWaitAbortedEvent <> 0 then
    AbortNeed := TRUE;
  SuspendNeed := FWaitSuspendedEvent <> 0;
  if not AbortNeed and not SuspendNeed then
    Query( QueryResult );

  if not AbortNeed then
    AbortNeed := QueryResult = wqAbort;

  if not SuspendNeed then
    SuspendNeed := QueryResult = wqSuspend;

  if AbortNeed then
    Exit( TRUE );

  // FOnQuery() set Query = wpSuspend or Suspend() has been called
  if SuspendNeed then
  begin
    // Suspend() has been called and waiting FWaitSuspendedEvent
    if FWaitSuspendedEvent <> 0 then
      SetEvent( FWaitSuspendedEvent );

    if Assigned( FOnData ) then
      FeedbackState( wsSuspended );

    // FWaitResumedEvent will be set after Resume() or Abort() called
    WaitForSingleObject( FWaitResumedEvent ); // Suspend at here

    if Assigned( FOnData ) then
      FeedbackState( wsResumed );
  end;

  Exit( FALSE );
end;

procedure TWorker.Suspend( );
begin
  if FWorking then
    WaitForSingleObject( FWaitSuspendedEvent );
end;

procedure TWorker.Resume( );
begin
  if FWorking then
  begin
    // WaitForSingleObject( FWaitResumedEvent ) in AbortPending()
    if ( FWaitResumedEvent <> 0 ) then
    begin
      SetEvent( FWaitResumedEvent );
      while FWaitResumedEvent <> 0 do // AbortPending() will clear FSuspended
        Yield;
    end;
  end;
end;

procedure TWorker.Abort( );
begin
  if FWorking then
  begin
    FWaitAbortedEvent := CreateEvent( nil, TRUE, FALSE, '' );

    // WaitForSingleObject( FWaitResumedEvent ) in AbortPending()
    if ( FWaitResumedEvent <> 0 ) then
    begin
      SetEvent( FWaitResumedEvent );
      while FWaitResumedEvent <> 0 do // AbortPending() will clear FSuspended
        Yield;
    end;

    // Wait until Aborted() be called in Execute() after Work() Exit
    WaitForSingleObject( FWaitAbortedEvent );
  end;
end;

procedure TWorker.Start( WorkMethod : TWorkMethod; WorkParam : TObject = nil;
  OnState : TWorkerStateEvent = nil; OnQuery : TWorkerQueryEvent = nil;
  OnProgress : TWorkerProgressEvent = nil; OnData : TWorkerDataEvent = nil );
begin
  FOnQuery := OnQuery;
  FOnState := OnState;
  FOnProgress := OnProgress;
  FOnData := OnData;
  FWorkMethod := WorkMethod;
  FWorkParam := WorkParam;

  // wait until FExecuting = TRUE in AfterConstruction()
  // FStartEvent has been created
  SetEvent( Self.FStartEvent );
  while not FWorking do
    Yield;
end;

constructor TWorker.Create( Owner : TWorkerMgr; Name : string; Tag : integer );
begin
  FName := name;
  FTag := Tag;
  FOwner := Owner;

  inherited Create( FALSE );
end;

procedure TWorker.AfterConstruction;
begin
  inherited AfterConstruction; // ResumeThread

  while not FExecuting do // Wait for thread execute
    Yield; // Suspend Caller's Thread, to start Worker's Thread
end;

destructor TWorker.Destroy;
begin
  if FExecuting then
  begin
    if not FWorking then
    begin
      // WaitForMultipleObjects( StartEvent or TerminateEvent )
      SetEvent( FExitEvent );
    end else begin
      Abort( );
    end;
  end;

  inherited Destroy;
end;

procedure TWorker.Execute;
var
  Wait : DWORD;
  State : TWorkerState;
  FEvents : array [ 0 .. 1 ] of THandle;
begin
  FExitEvent := CreateEvent( nil, TRUE, FALSE, '' );
  FStartEvent := CreateEvent( nil, TRUE, FALSE, '' );
  FEvents[ 0 ] := FExitEvent;
  FEvents[ 1 ] := FStartEvent;

  FExecuting := TRUE;
  try
    while not Terminated do
    begin
      FWorking := FALSE;
      Wait := WaitForMultipleObjects( 2, @FEvents, FALSE, INFINITE );
      // If more than one object became signaled during the call,
      // this is the array index of the signaled object
      // with the smallest index value of all the signaled objects.
      case Wait of
        WAIT_OBJECT_0 .. WAIT_OBJECT_0 + 1 :
          if WAIT_OBJECT_0 = Wait then // weTerminate
          begin
            ResetEvent( FExitEvent );
            Exit;
          end else begin
            NameThreadForDebugging( FName );

            ResetEvent( FStartEvent );

            FWorking := TRUE;
            State := FWorkMethod( Self, FWorkParam );
            FWorking := FALSE;

            if State = wsAborted then
              SetEvent( FWaitAbortedEvent );

            if Assigned( FOnState ) then
              FeedbackState( State );
          end;

        WAIT_ABANDONED_0 .. WAIT_ABANDONED_0 + 1 :
          begin
            // mutex object abandoned
          end;

        WAIT_FAILED :
          begin
            if GetLastError <> ERROR_INVALID_HANDLE then
            begin
              // the wait failed because of something other than an invalid handle
              RaiseLastOSError;
            end else begin
              // at least one handle has become invalid outside the wait call
            end;
          end;

        WAIT_TIMEOUT :
          begin
            // Never because dwMilliseconds is INFINITE
          end;
      else
        begin

        end;
      end;
    end;

  finally
    if FExitEvent <> 0 then
      CloseHandle( FExitEvent );

    if FStartEvent <> 0 then
      CloseHandle( FStartEvent );

    FExecuting := FALSE;
  end;
end;

{ TWorkerMgr }

procedure TWorkerMgr.CreateProcessWindow;
begin
  FProcessWindow := AllocateHWnd( ProcessWndMethod );
end;

procedure TWorkerMgr.CreateThreadWindow;
begin
  FThreadWindow := AllocateHWnd( ThreadWndMethod );
end;

function TWorkerMgr.AllocWorker( Name : string; Tag : integer;
  AutoFree : LongBool ) : TWorker;
var
  I : integer;
  CreateWorker : LongBool;
begin
  CreateWorker := TRUE;
  for I := 0 to FWorkerList.LockList.Count - 1 do
  begin
    Result := FWorkerList.LockList[ I ];
    if not Result.FAlloced then
    begin
      CreateWorker := FALSE;
      Break;
    end;
  end;

  if CreateWorker then
  begin
    if FWorkerList.LockList.Count = MAX_WORKER_COUNT then
      Exit( nil );

    Result := TWorker.Create( Self, name );

    FWorkerList.Add( Result );
  end;

  Result.FName := name;
  Result.FTag := Tag;
  Result.FAutoFree := AutoFree;
  Result.FAlloced := TRUE;
end;

procedure TWorkerMgr.FreeWorker( Worker : TWorker );
begin
  if Worker.FWorking then
    Worker.Abort;

  Worker.FAlloced := FALSE;
end;

procedure TWorkerMgr.FreeWorkers;
var
  I : integer;
begin
  for I := 0 to FWorkerList.LockList.Count - 1 do
    FreeWorker( FWorkerList.LockList[ I ] );
end;

procedure TWorkerMgr.AfterConstruction;
begin
  inherited AfterConstruction;
  WaitForSingleObject( FReadyEvent );
end;

procedure TWorkerMgr.BeforeDestruction;
begin
  if Assigned( FWorkerList ) then
  begin
    while FWorkerList.LockList.Count > 0 do
    begin
      FreeWorker( FWorkerList.LockList[ 0 ] );
      FWorkerList.LockList[ 0 ].Destroy;
      FWorkerList.Remove( FWorkerList.LockList[ 0 ] );
    end;

    FWorkerList.Free;
  end;

  inherited BeforeDestruction;
end;

constructor TWorkerMgr.Create( Name : string );
begin
  FName := name;
  FReadyEvent := CreateEvent( nil, TRUE, FALSE, '' );
  FWorkerList := TThreadList< TWorker >.Create;

  inherited Create( FALSE );

  { Create hidden window here: store handle in FProcessWindow
    this must by synchonized because of ProcessThread Context }
  Synchronize( CreateProcessWindow );
end;

procedure TWorkerMgr.DeleteProcessWindow;
begin
  if FProcessWindow <> 0 then
  begin
    DeallocateHWnd( FProcessWindow );
    FProcessWindow := 0;
  end;
end;

procedure TWorkerMgr.DeleteThreadWindow;
begin
  if FThreadWindow > 0 then
  begin
    DeallocateHWnd( FThreadWindow );
    FThreadWindow := 0;
  end;
end;

destructor TWorkerMgr.Destroy;
begin
  Terminate; // FTerminated := True;

  inherited Destroy; // WaitFor(), Destroy()

  { Destroy hidden window }
  DeleteProcessWindow( );
end;

procedure TWorkerMgr.Execute;
var
  Msg : TMsg;
begin
  NameThreadForDebugging( FName );

  // Force system alloc a Message Queue for thread
  // PeekMessage( Msg, 0, WM_USER, WM_USER, PM_NOREMOVE );
  CreateThreadWindow( );
  SetEvent( FReadyEvent );
  if FThreadWindow = 0 then
    Exit;

  try
    while not Terminated do
    begin
      if FALSE then
      begin
        if Longint( PeekMessage( Msg, 0, 0, 0, PM_REMOVE ) ) > 0 then
        begin
          // WM_QUIT Message sent by Destroy()
          if Msg.message = WM_QUIT then
            Exit;

          TranslateMessage( Msg );
          DispatchMessage( Msg );
        end;
      end else begin
        while Longint( GetMessage( Msg, 0, 0, 0 ) ) > 0 do
        begin
          TranslateMessage( Msg );
          DispatchMessage( Msg );
        end;
        // WM_QUIT Message sent by Destroy()
      end;
    end;
  finally
    DeleteThreadWindow( );
  end;
end;

// Destroy() :: Terminate() : TerminatedSet
procedure TWorkerMgr.TerminatedSet;
begin
  FreeWorkers( );
  PostThreadMessage( WM_WORKER_MGR_TERMINATE, 0, 0 );
  // PostQuitMessage( 0 ) will be executed in ThreadWndMethod()
  // Message Loop will be broken in Execute() because WM_QUIT message
end;

procedure TWorkerMgr.ThreadWndMethod( var Msg : TMessage );
var
  Handled : Boolean;
  Worker : TWorker;
begin
  Handled := TRUE; // Assume we handle message

  Worker := TWorker( Msg.WParam );

  case Msg.Msg of

    WM_WORKER_MGR_TERMINATE :
      PostQuitMessage( 0 );

  else
    Handled := FALSE; // We didn't handle message
  end;

  if Handled then // We handled message - record in message result
    Msg.Result := 0
  else // We didn't handle message, pass to DefWindowProc and record result
    Msg.Result := DefWindowProc( FProcessWindow, Msg.Msg, Msg.WParam,
      Msg.LParam );
end;

function TWorkerMgr.PostThreadMessage( Msg, WParam, LParam : NativeUInt )
  : LongBool;
begin
  while FThreadWindow = 0 do
    SwitchToThread;

  Result := Winapi.Windows.PostMessage( FThreadWindow, Msg, WParam, LParam );
end;

function TWorkerMgr.SendThreadMessage( Msg, WParam, LParam : NativeUInt )
  : NativeInt;
begin
  while FThreadWindow = 0 do
    SwitchToThread;

  Result := Winapi.Windows.SendMessage( FThreadWindow, Msg, WParam, LParam );
end;

function TWorkerMgr.PostProcessMessage( Msg, WParam, LParam : NativeUInt )
  : LongBool;
begin
  Result := Winapi.Windows.PostMessage( FProcessWindow, Msg, WParam, LParam );
end;

function TWorkerMgr.SendProcessMessage( Msg, WParam, LParam : NativeUInt )
  : NativeInt;
begin
  Result := Winapi.Windows.SendMessage( FProcessWindow, Msg, WParam, LParam );
end;

procedure TWorkerMgr.ProcessWndMethod( var Msg : TMessage );
var
  Handled : Boolean;
  Worker : TWorker;
begin
  Handled := TRUE; // Assume we handle message

  Worker := TWorker( Msg.WParam );

  case Msg.Msg of

    WM_WORKER_QUERY :
      begin
        Worker.DoQuery( PWorkerQuery( Msg.LParam )^ );
      end;

    WM_WORKER_FEEDBACK :
      begin
        Worker.DoFeedback( PWorkerReportRec( Msg.LParam ) );
      end;
  else
    Handled := FALSE; // We didn't handle message
  end;

  if Handled then // We handled message - record in message result
    Msg.Result := 0
  else // We didn't handle message, pass to DefWindowProc and record result
    Msg.Result := DefWindowProc( FProcessWindow, Msg.Msg, Msg.WParam,
      Msg.LParam );
end;

end.
