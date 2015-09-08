unit uUtility;

interface

uses
  Windows, StrUtils, SysUtils, Classes;

function CStrLen( CString : PAnsiChar ) : NativeUInt;
procedure CStrShrink( CString : AnsiString );
procedure CStrCopy( Dest : PAnsiChar; Source : PAnsiChar; MaxLen : integer );
function SplitStrings( const Source : PAnsiChar; Size : NativeUInt;
  const Strings : TStrings ) : NativeUInt;

var
  IsWin64 : boolean;

implementation

function IsWin64Func : boolean;
var
  Kernel32Handle : THandle;
  IsWow64Process : function( Handle : Windows.THandle; var Res : Windows.BOOL )
    : Windows.BOOL; stdcall;
  GetNativeSystemInfo : procedure( var lpSystemInfo : TSystemInfo ); stdcall;
  isWoW64 : BOOL;
  SystemInfo : TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
begin
  Kernel32Handle := GetModuleHandle( 'KERNEL32.DLL' );
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary( 'KERNEL32.DLL' );
  if Kernel32Handle <> 0 then
  begin
    IsWow64Process := GetProcAddress( Kernel32Handle, 'IsWow64Process' );
    GetNativeSystemInfo := GetProcAddress( Kernel32Handle,
      'GetNativeSystemInfo' );
    if Assigned( IsWow64Process ) then
    begin
      IsWow64Process( GetCurrentProcess, isWoW64 );
      Result := isWoW64 and Assigned( GetNativeSystemInfo );
      if Result then
      begin
        GetNativeSystemInfo( SystemInfo );
        Result := ( SystemInfo.wProcessorArchitecture =
          PROCESSOR_ARCHITECTURE_AMD64 ) or
          ( SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64 );
      end;
    end
    else
      Result := FALSE;
  end
  else
    Result := FALSE;
end;

procedure CStrCopy( Dest : PAnsiChar; Source : PAnsiChar; MaxLen : integer );
var
  Count : integer;
begin
  if Source = nil then
  begin
    Dest[ 0 ] := #0;
    Exit;
  end;

  Count := CStrLen( Source );
  if Count < MaxLen then
  begin
    CopyMemory( Dest, Source, Count + 1 ); // include last NULL char
  end else begin
    Count := MaxLen - 1;
    CopyMemory( Dest, Source, Count ); // include last NULL char
    Dest[ MaxLen - 1 ] := #0;
  end;
end;

procedure CStrShrink( CString : AnsiString );
begin
  SetLength( CString, CStrLen( PAnsiChar( @CString[ 1 ] ) ) );
end;

// Return the length of the null-terminated string STR.  Scan for
// the null terminator quickly by testing four bytes at a time.
function CStrLen( CString : PAnsiChar ) : NativeUInt;
var
  AnsiCharPtr : PAnsiChar;
  NativePtr : PNativeUInt;
  Native : NativeUInt;
  HiMagic : NativeUInt;
  LoMagic : NativeUInt;
  MagicBits : NativeUInt;
begin
  if CString = nil then
    Exit( 0 );

  // Handle the first few characters by reading one character at a time.
  // Do this until CStr is aligned on a longword boundary.
  AnsiCharPtr := CString;
  while NativeUInt( AnsiCharPtr ) and ( sizeof( NativeUInt ) - 1 ) <> 0 do
  begin
    Inc( AnsiCharPtr );
    if AnsiCharPtr^ = #0 then
    begin
      Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString );
      Exit;
    end;
  end;

  // All these elucidatory comments refer to 4-byte longwords,
  // but the theory applies equally well to 8-byte longwords.
  NativePtr := PNativeUInt( AnsiCharPtr );

  (* Bits 31, 24, 16, and 8 of this number are zero.  Call these bits
    the "holes."  Note that there is a hole just to the left of
    each byte, with an extra at the end:

    bits:  01111110 11111110 11111110 11111111
    bytes: AAAAAAAA BBBBBBBB CCCCCCCC DDDDDDDD

    The 1-bits make sure that carries propagate to the next 0-bit.
    The 0-bits provide holes for carries to fall into. *)
  // 64-bit version of the magic.
  if sizeof( Native ) > 4 then
  begin
    MagicBits := $7EFEFEFEFEFEFEFF;
    HiMagic := $8080808080808080;
    LoMagic := $0101010101010101;
  end else begin
    MagicBits := $7EFEFEFF;
    HiMagic := $80808080;
    LoMagic := $01010101;
  end;

  (* We tentatively exit the loop if adding MAGIC_BITS to
    LONGWORD fails to change any of the hole bits of LONGWORD.

    1) Is this safe?  Will it catch all the zero bytes?
    Suppose there is a byte with all zeros.  Any carry bits
    propagating from its left will fall into the hole at its
    least significant bit and stop.  Since there will be no
    carry from its most significant bit, the LSB of the
    byte to the left will be unchanged, and the zero will be
    detected.

    2) Is this worthwhile?  Will it ignore everything except
    zero bytes?  Suppose every byte of LONGWORD has a bit set
    somewhere.  There will be a carry into bit 8.  If bit 8
    is set, this will carry into bit 16.  If bit 8 is clear,
    one of bits 9-15 must be set, so there will be a carry
    into bit 16.  Similarly, there will be a carry into bit
    24.  If one of bits 24-30 is set, there will be a carry
    into bit 31, so all of the hole bits will be changed.

    The one misfire occurs when bits 24-30 are clear and bit
    31 is set; in this case, the hole at bit 31 is not
    changed.  If we had access to the processor carry flag,
    we could close this loophole by putting the fourth hole
    at bit 32!

    So it ignores everything except 128's, when they're aligned
    properly. *)

  // Instead of the traditional loop which tests each character,
  // we will test a longword at a time.  The tricky part is testing
  // if *any of the four* bytes in the longword in question are zero.
  while TRUE do
  begin
    Native := NativePtr^;
    Inc( NativePtr );

    // Value = ( Native - LoMagic ) and HiMagic, if Value <> 0 then
    // We have NUL or a non-ASCII char > 127
    // $BABA0042 - #01010101 --> $B9B8FF41 and $80808080 -->
    // $80808000, Value = Value and not Native $80808000 and $4545FFBD -->
    // $00008000
    // **
    if ( ( Native - LoMagic ) and HiMagic and not Native ) <> 0 then
    begin
      Dec( NativePtr );

      // Which of the bytes was the zero?
      AnsiCharPtr := PAnsiChar( NativePtr );
      if AnsiCharPtr[ 0 ] = #0 then
      begin
        Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString );
        Exit;
      end;
      if AnsiCharPtr[ 1 ] = #0 then
      begin
        Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 1;
        Exit;
      end;
      if AnsiCharPtr[ 2 ] = #0 then
      begin
        Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 2;
        Exit;
      end;
      if AnsiCharPtr[ 3 ] = #0 then
      begin
        Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 3;
        Exit;
      end;

      if sizeof( Native ) > 4 then
      begin
        if AnsiCharPtr[ 4 ] = #0 then
        begin
          Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 4;
          Exit;
        end;
        if AnsiCharPtr[ 5 ] = #0 then
        begin
          Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 5;
          Exit;
        end;
        if AnsiCharPtr[ 7 ] = #0 then
        begin
          Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 6;
          Exit;
        end;
        if AnsiCharPtr[ 7 ] = #0 then
        begin
          Result := NativeUInt( AnsiCharPtr ) - NativeUInt( CString ) + 7;
          Exit;
        end;
      end;
    end;
  end;
end;

// On Windows, the default LineBreak value is
// a carriage return and line feed combination (#13#10)
// whereas on Mac OS X, it is just a line feed (#10).
function SplitStrings( const Source : PAnsiChar; Size : NativeUInt;
  const Strings : TStrings ) : NativeUInt;
var
  AString : AnsiString;
  FirstCharIndex : NativeUInt;
  LineBreakIndex : NativeUInt;
begin
  LineBreakIndex := 0;
  FirstCharIndex := 0;
  while TRUE do
  begin
    // -----------| --------- Size -------- | Dummy |
    // -------- LineBreakIndex|             |       |
    // [ ------- ][ ABCD#1x#1x][00][ ...... ][00][xx] : return LineBreakIndex
    // [ ------- ][ ABCDEFG#1x][00][ ...... ][00][xx] : return LineBreakIndex
    // [ ------- ][ ABCDEFGHIJ][00][ ...... ][00][xx] : return LineBreakIndex
    // [ ------- ][ --------------ABCD#1x#1x][00][xx] : return LineBreakIndex
    // [ ------- ][ --------------ABCDEFG#1x][00][xx] : return LineBreakIndex
    // -----------------------|FirstCharIndex
    // [ ------- ][ ABCD#1x#1xABCDEFGHIJKLMN][00][xx] : return FirstCharIndex
    // -----------| --------- size -------- |
    // --------------------- LineBreakIndex |
    if Source[ LineBreakIndex ] = #00 then
    begin
      Result := LineBreakIndex; // assume all chars are handled
      if ( FirstCharIndex < LineBreakIndex ) then // remaining some chars
      begin
        if ( LineBreakIndex = Size ) then
          Result := FirstCharIndex // to be buffered < Size - FirstCharIndex >
        else
        begin
          // Incomplete string, Append $13#10 for Last String
          SetString( AString, Source + FirstCharIndex,
            LineBreakIndex - FirstCharIndex );
          Strings.Add( AString );
        end;
      end;

      Exit;

      if ( FirstCharIndex < LineBreakIndex ) and ( LineBreakIndex < Size ) then
      begin
        SetString( AString, Source + FirstCharIndex,
          LineBreakIndex - FirstCharIndex );
        Strings.Add( AString );
      end;

      if ( FirstCharIndex < LineBreakIndex ) and ( LineBreakIndex = Size ) then
        Result := FirstCharIndex // to be buffered
      else
        Result := LineBreakIndex;

      Exit;
    end;

    // #10 : #XX
    if Source[ LineBreakIndex ] = #10 then
    begin
      SetString( AString, Source + FirstCharIndex,
        LineBreakIndex - FirstCharIndex );
      Strings.Add( AString );

      Inc( LineBreakIndex );
      if Source[ LineBreakIndex ] = #13 then
        Inc( LineBreakIndex );

      FirstCharIndex := LineBreakIndex;
      continue;
    end;

    // #13 : #XX
    if Source[ LineBreakIndex ] = #13 then
    begin
      SetString( AString, Source + FirstCharIndex,
        LineBreakIndex - FirstCharIndex );
      Strings.Add( AString );

      Inc( LineBreakIndex );
      if Source[ LineBreakIndex ] = #10 then
        Inc( LineBreakIndex );

      FirstCharIndex := LineBreakIndex;
      continue;
    end;

    Inc( LineBreakIndex );
  end;
end;

initialization

IsWin64 := IsWin64Func( );

end.
