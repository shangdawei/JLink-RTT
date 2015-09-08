unit uAsyncIo;

interface

uses
  Windows, Messages, Classes, SysUtils;

type
  PAsync = ^TAsync;

  TAsync = record
    AsyncEvents : array [ 0 .. 1 ] of THandle;
    Overlapped : TOverlapped;
  end;

  EAsync = class( Exception )
  private
    FWinCode : Integer;
  public
    constructor Create( AWinCode : Integer );
    property WinCode : Integer read FWinCode write FWinCode;
  end;

  TOpAsync = ( opAsyncRead, opAsyncWrite, opAsyncIo );

function WriteAsync( hWrite : THandle; const Buffer; Count : Integer;
  TimeOut : DWord; AsyncEvent : THandle = 0 ) : Integer;

function ReadAsync( hRead : THandle; var Buffer; Count : Integer;
  TimeOut : DWord; AsyncEvent : THandle = 0 ) : Integer;

function DeviceIoControlAsync( hDevice : THandle; dwIoControlCode : DWord;
  const lpInBuffer; nInBufferSize : DWord; var lpOutBuffer;
  nOutBufferSize : DWord; TimeOut : DWord; AsyncEvent : THandle = 0 ) : Integer;

implementation

{ EAsync }

// raise EAsync.Create( GetLastError() );
constructor EAsync.Create( AWinCode : Integer );
begin
  FWinCode := AWinCode;
  inherited CreateFmt( ' (Windows Error Code: %d)', [ AWinCode ] );
end;

// -----------------------------------------------------------------------------
// initialization of PAsync variables used in Asynchronous calls
// -----------------------------------------------------------------------------
procedure InitAsync( var AsyncPtr : PAsync );
begin
  New( AsyncPtr ); // Dispose(AsyncPtr) in DoneAsync()

  with AsyncPtr^ do
  begin
    FillChar( Overlapped, SizeOf( TOverlapped ), 0 );

    // the function creates a manual-reset event object,
    // which requires the use of the ResetEvent function
    // to set the event state to nonsignaled.
    Overlapped.hEvent := CreateEvent( nil, True, FALSE, nil );
    // IoCompleteRequest() set the event state to signaled.
    // After Asynchronous IoComplete

    AsyncEvents[ 0 ] := Overlapped.hEvent;
    // CloseHandle(Overlapped.hEvent) in DoneAsync()
  end;
end;

// -----------------------------------------------------------------------------
// clean-up of PAsync variable
// -----------------------------------------------------------------------------
procedure DoneAsync( var AsyncPtr : PAsync );
begin
  CloseHandle( AsyncPtr^.Overlapped.hEvent );
  Dispose( AsyncPtr );
  AsyncPtr := nil;
end;

// -----------------------------------------------------------------------------
// perform Asynchronous io operation
// -----------------------------------------------------------------------------
function DoAsync( OpAsync : TOpAsync; hAsync : THandle; TimeOut : DWord;
  dwIoControlCode : DWord; const lpInBuffer; nInBufferSize : DWord;
  var lpOutBuffer; nOutBufferSize : DWord; AsyncEvent : THandle ) : Integer;
var
  dwWait : DWord;
  dwError : DWord;
  Async : TAsync;
  AsyncPtr : PAsync;
  BytesTrans : DWord;
  AsyncResult : Boolean;
  OverLappedResult : Boolean;
  DoCancelIo : Boolean;
begin
  Result := -1;
  if hAsync <> INVALID_HANDLE_VALUE then
  begin

    AsyncPtr := @Async;
    with AsyncPtr^ do
    begin
      FillChar( Overlapped, SizeOf( TOverlapped ), 0 );

      // the function creates a manual-reset event object,
      // which requires the use of the ResetEvent function
      // to set the event state to nonsignaled.
      Overlapped.hEvent := CreateEvent( nil, True, FALSE, nil );
      // IoCompleteRequest() set the event state to signaled.
      // After Asynchronous IoComplete

      AsyncEvents[ 0 ] := Overlapped.hEvent;
      // CloseHandle(Overlapped.hEvent) in DoneAsync()

      AsyncEvents[ 1 ] := AsyncEvent;
    end;

    DoCancelIo := FALSE;
    BytesTrans := 0;
    try
      AsyncResult := FALSE;
      // Sends a control code directly to a specified device driver,
      // causing the corresponding device to perform the corresponding operation.
      // If the operation completes successfully, the return value is nonzero.
      // For overlapped operations, DeviceIoControl returns immediately,
      // and the event object is signaled when the operation has been completed.
      // If the operation fails or is pending, the return value is zero.
      if OpAsync = opAsyncIo then
        AsyncResult := DeviceIoControl( hAsync, dwIoControlCode, @lpInBuffer,
          nInBufferSize, @lpOutBuffer, nOutBufferSize, BytesTrans,
          @AsyncPtr^.Overlapped )
      else if OpAsync = opAsyncRead then
        AsyncResult := ReadFile( hAsync, lpOutBuffer, nOutBufferSize,
          BytesTrans, @AsyncPtr^.Overlapped )
      else if OpAsync = opAsyncWrite then
        AsyncResult := WriteFile( hAsync, lpInBuffer, nInBufferSize, BytesTrans,
          @AsyncPtr^.Overlapped );

      // Io/Read/Write from/to device completed, done.
      if AsyncResult then
        Exit( BytesTrans );

      dwError := GetLastError( );
      // ERROR_ACCESS_DENIED :
      // if a device is disconnected while you still have the handle open
      //
      // ERROR_BAD_COMMAND :
      // if a device is connected but command is not supported
      //
      // ERROR_HANDLE_EOF :
      // we're reached the end of the file
      // during the call to ReadFile
      // code to handle that
      if dwError <> ERROR_IO_PENDING then
        Exit( -1 );

      // Retrieves the results of an overlapped operation on the specified file,
      // named pipe, or communications device. To specify a timeout interval or
      // wait on an alertable thread, use GetOverlappedResultEx.
      // lpNumberOfBytesTransferred A pointer to a variable that receives the number
      // of bytes that were actually transferred by a read or write operation.
      // bWait : TRUE, and the Internal member of the lpOverlapped structure is
      // STATUS_PENDING, the function does not return until
      // the operation has been completed.
      // bWait : FALSE and the operation is still pending, the function returns FALSE
      // and the GetLastError function returns ERROR_IO_INCOMPLETE.
      // If the function succeeds, the return value is nonzero.
      // If the function fails, the return value is zero.
      // To get extended error information, call GetLastError.
      // A pending operation is indicated when the function that started the operation
      // returns FALSE, and the GetLastError function returns ERROR_IO_PENDING.
      // When an I/O operation is pending, the function that started the operation
      // resets the hEvent member of the OVERLAPPED structure to the nonsignaled state.
      // Then when the pending operation has been completed,
      // the system sets the event object to the signaled state.
      //
      // Waits until one or all of the specified objects are
      // in the signaled state or the time-out interval elapses.
      // DWORD WINAPI WaitForMultipleObjects(
      // __in  DWORD nCount,
      // __in  const HANDLE *lpHandles,
      // __in  BOOL bWaitAll,
      // __in  DWORD dwMilliseconds);
      //
      // Retrieves the results of an overlapped operation on the specified file,
      // named pipe, or communications device.
      // BOOL WINAPI GetOverlappedResult(
      // __in   HANDLE hFile,
      // __in   LPOVERLAPPED lpOverlapped,
      // __out  LPDWORD lpNumberOfBytesTransferred,
      // __in   BOOL bWait);
      //
      // asynchronous i/o is still in progress, do something else for a while
      // IoCompleteRequest() set the event state to signaled After IoComplete
      if AsyncEvent <> 0 then
        dwWait := WaitForMultipleObjects( 2, @AsyncPtr^.AsyncEvents[ 0 ],
          FALSE, TimeOut )
      else
        dwWait := WaitForSingleObject( AsyncPtr^.AsyncEvents[ 0 ], TimeOut );

      // Closing a handle while the handle is being waited on can cause undefined behaviour.
      // INVALID_HANDLE_VALUE
      // If you lack the SYNCHRONIZE privilege on the object, then you cannot wait.
      if dwWait = WAIT_FAILED then
      begin
        Exit( -1 );
      end;

      if dwWait = WAIT_TIMEOUT then
      begin
        DoCancelIo := True;
        Exit( -1 );
      end;

      // Only when AsyncEvent <> 0
      if dwWait = ( WAIT_OBJECT_0 + 1 ) then
      begin
        ResetEvent( AsyncPtr^.AsyncEvents[ 1 ] );
        DoCancelIo := True;
        Exit( -1 );
      end;

      if dwWait = ( WAIT_OBJECT_0 + 0 ) then
      begin
        GetOverlappedResult( hAsync, AsyncPtr^.Overlapped, BytesTrans, FALSE );

        // the manual-reset event object, which requires the use of
        // the ResetEvent function to set the event state to nonsignaled.
        ResetEvent( AsyncPtr^.AsyncEvents[ 0 ] );

        Exit( BytesTrans ); // has read/written from/to device
      end;

    finally
      { http://blogs.msdn.com/b/oldnewthing/archive/2011/02/02/10123392.aspx }
      if DoCancelIo then
      begin
        { One of the cardinal rules of the OVERLAPPED structure is the OVERLAPPED
          structure must remain valid until the I/O completes.
          The reason is that the OVERLAPPED structure is manipulated by address
          rather than by value.

          The word complete here has a specific technical meaning.
          It doesn't mean "must remain valid until you are no longer interested
          in the result of the I/O."
          It means that the structure must remain valid until the I/O subsystem
          has signaled that the I/O operation is finally over, that there
          is nothing left to do, it has passed on: You have an ex-I/O operation.

          Note that an I/O operation can complete successfully,
          or it can complete unsuccessfully.
          Completion is not the same as success.
        }

        { Submit I/O cancellation to device driver }
        CancelIo( hAsync );

        { when an I/O operation completes : It updates the OVERLAPPED structure
          with the results of the I/O operation, and notifies whoever wanted
          to be notified that the I/O is finished. }

        { I/O cancellation submitted to device driver,
          Wait IO Canceled before CloseHandle }
        WaitForSingleObject( AsyncPtr^.AsyncEvents[ 0 ], INFINITE );
        ResetEvent( AsyncPtr^.AsyncEvents[ 0 ] );
      end;

      CloseHandle( AsyncPtr^.AsyncEvents[ 0 ] );
      AsyncPtr := nil;
    end;
  end;
end;

function ReadAsync( hRead : THandle; var Buffer; Count : Integer;
  TimeOut : DWord; AsyncEvent : THandle ) : Integer;
var
  LBuffer : Integer;
  LCount : Integer;
begin
  Result := DoAsync( opAsyncRead, hRead, TimeOut, 0, LBuffer, LCount, Buffer,
    Count, AsyncEvent );
end;

function WriteAsync( hWrite : THandle; const Buffer; Count : Integer;
  TimeOut : DWord; AsyncEvent : THandle ) : Integer;
var
  LBuffer : Integer;
  LCount : Integer;
begin
  Result := DoAsync( opAsyncWrite, hWrite, TimeOut, 0, Buffer, Count, LBuffer,
    LCount, AsyncEvent );
end;

(*
  BOOL WINAPI DeviceIoControl(
  _In_         HANDLE hDevice,
  _In_         DWORD dwIoControlCode,
  _In_opt_     LPVOID lpInBuffer,
  _In_         DWORD nInBufferSize,
  _Out_opt_    LPVOID lpOutBuffer,
  _In_         DWORD nOutBufferSize,
  _Out_opt_    LPDWORD lpBytesReturned,
  _Inout_opt_  LPOVERLAPPED lpOverlapped );
*)
function DeviceIoControlAsync( hDevice : THandle; dwIoControlCode : DWord;
  const lpInBuffer; nInBufferSize : DWord; var lpOutBuffer;
  nOutBufferSize : DWord; TimeOut : DWord; AsyncEvent : THandle ) : Integer;
begin
  Result := DoAsync( opAsyncWrite, hDevice, TimeOut, dwIoControlCode,
    lpInBuffer, nInBufferSize, lpOutBuffer, nOutBufferSize, AsyncEvent );
end;

end.
