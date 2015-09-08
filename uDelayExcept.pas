{ http://blogs.embarcadero.com/abauer/2009/08/29/38896 }
unit uDelayExcept;

interface

uses System.SysUtils;

type
  EDliException = class( Exception )
  private
    class constructor Create;
    class destructor Destroy;
  end;

  EDliLoadLibraryExeception = class( EDliException )
  private
    FDllName : string;
  public
    constructor Create( const ADllName : string ); overload;

    property DllName : string read FDllName;
  end;

  EDliGetProcAddressException = class( EDliException )
  private
    FDllName : string;
    FExportName : string;
  public
    constructor Create( const ADllName, AExportName : string ); overload;
    constructor Create( const ADllName : string; AOrdinal : LongWord );
      overload;

    property DllName : string read FDllName;
    property ExportName : string read FExportName;
  end;

function DliExceptionHandler : boolean;

implementation

uses
  Vcl.Dialogs, Vcl.Forms;

var
  { for storing the old hook pointers }
  LOldNotifyHook, LOldFailureHook : TDelayedLoadHook;

function IsClass( Obj : TObject; Cls : TClass ) : boolean;
var
  Parent : TClass;
begin
  Parent := Obj.ClassType;
  while ( Parent <> nil ) and ( Parent.ClassName <> Cls.ClassName ) do
    Parent := Parent.ClassParent;
  Result := Parent <> nil;
end;

function DliExceptionHandler : boolean;
var
  O : TObject;
begin
  Result := TRUE;
  O := ExceptObject;
  if IsClass( O, EDliLoadLibraryExeception ) or
    IsClass( O, EDliGetProcAddressException ) then
    Application.ShowException( Exception( O ) )
  else
    Result := False;
end;

{ EDliLoadLibraryExeception }

constructor EDliLoadLibraryExeception.Create( const ADllName : string );
begin
  inherited Create( Format( 'Unable to load ''%s''', [ ADllName ] ) );
  FDllName := ADllName;
end;

{ EDliGetProcAddressException }

constructor EDliGetProcAddressException.Create( const ADllName,
  AExportName : string );
begin
  inherited Create( Format( 'Unable to locate export name ''%s'' from ''%s''',
    [ AExportName, ADllName ] ) );
  FDllName := ADllName;
  FExportName := AExportName;
end;

constructor EDliGetProcAddressException.Create( const ADllName : string;
  AOrdinal : LongWord );
begin
  inherited Create
    ( Format( 'Unable to locate export ordinal ''%d'' from ''%s''',
    [ AOrdinal, ADllName ] ) );
  FDllName := ADllName;
  FExportName := IntToStr( AOrdinal );
end;

{ Utility function to retrieve the name of the imported routine or its ordinal }
function ImportName( const AProc : TDelayLoadProc ) : string; inline;
begin
  if AProc.fImportByName then
    Result := AProc.szProcName
  else
    Result := '#' + IntToStr( AProc.dwOrdinal );
end;

function DelayLoadFailureHook( dliNotify : dliNotification;
  pdli : PDelayLoadInfo ) : Pointer; stdcall;
begin
  if TRUE then
    Result := nil;

  case dliNotify of
    dliFailLoadLibrary :
      { WriteLn( 'Failed to load "', pdli.szDll, '" DLL' ); }
      raise EDliLoadLibraryExeception.Create( pdli.szDll );

    dliFailGetProcAddress :
      { WriteLn( 'Failed to get proc address for "', ImportName( pdli.dlp ),
        '" in "', pdli.szDll, '" DLL' ); }
      if pdli.dlp.fImportByName then
        raise EDliGetProcAddressException.Create( pdli.szDll,
          pdli.dlp.szProcName )
      else
        raise EDliGetProcAddressException.Create( pdli.szDll,
          pdli.dlp.dwOrdinal );

    dliNotePreGetProcAddress :
      { WriteLn( 'Want to get address of "', ImportName( pdli.dlp ), '" in "',
        pdli.szDll, '" DLL' ); };

    dliNoteStartProcessing :
      { WriteLn( 'Started the delayed load session for "', pdli.szDll, '" DLL' ); };

    dliNotePreLoadLibrary :
      { WriteLn( 'Starting to load "', pdli.szDll, '" DLL' ); };

    dliNoteEndProcessing :
      { WriteLn( 'Ended the delaay load session for "', pdli.szDll, '" DLL' ); };
  end;

  if False then
  begin
    { Call the old hooks if they are not nil }
    { This is recommended to do in case the old hook do further processing }
    if dliNotify in [ dliFailLoadLibrary, dliFailGetProcAddress ] then
    begin
      if Assigned( LOldNotifyHook ) then
        LOldFailureHook( dliNotify, pdli );
    end else begin
      if Assigned( LOldNotifyHook ) then
        LOldNotifyHook( dliNotify, pdli );
    end;

    Result := nil;
  end;

end;

{ EDliException }

class constructor EDliException.Create;
begin
  // SetDliFailureHook2(DelayLoadFailureHook);

  { Install new delayed loading hooks }
  LOldNotifyHook := SetDliNotifyHook2( DelayLoadFailureHook );
  LOldFailureHook := SetDliFailureHook2( DelayLoadFailureHook );
end;

class destructor EDliException.Destroy;
begin
  SetDliNotifyHook2( LOldNotifyHook );
  SetDliFailureHook2( LOldFailureHook );

  // SetDliFailureHook2( nil );
end;

const
  DllFileName = 'DllFileName.dll';

procedure DllProcedure; stdcall;
  external DllFileName name 'DllProcedure' delayed;

procedure InvokeDllProcedure( );
begin
  try
    DllProcedure( );
  except
    if not DliExceptionHandler( ) then
      raise;
  end;
end;

end.
