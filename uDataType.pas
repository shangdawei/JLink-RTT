unit uDataType;

(*
  Type        Description                             Pointer     Record
  ------------------------------------------------------------------------------
  Boolean     A logical value (true or false).	      PBoolean
  ByteBool	  An 8-bit logical value. (Boolean).
  WordBool	  An 16-bit logical value.	              PWordBool
  LongBool	  An 32-bit logical value.	              PLongBool
  ------------------------------------------------------------------------------
  Byte        8-bit unsigned integer                  PByte
  ShortInt    8-bit signed integer                    PShortInt
  Word        16-bit unsigned integer                 PWord
  SmallInt    16-bit signed integer                   PSmallInt
  Cardinal    32-bit unsigned integer                 PCardinal
  LongWord    32-bit unsigned integer                 PLongWord
  DWord       32-bit unsigned integer                 PLongWord
  Integer     32-bit signed integer                   PInteger
  LongInt     32-bit signed integer                   PLongint
  UInt64      64-bit unsigned integer                 PUInt64
  Int64       64-bit signed integer                   PInt64
  ------------------------------------------------------------------------------
  Single      Single precision (4 bytes)              PSingle     TSingleRec
  Double      Double precision (8 bytes)              PDouble     TDoubleRec
  Extended    Extended precision (10 bytes on Win32)  PExtended   TExtended80Rec
  Extended    Extended precision ( 8 bytes on Win64)  PExtended   TExtended80Rec
  Real        Alias of Double                         N/A         N/A
  ------------------------------------------------------------------------------
  AnsiChar    ANSI character (8-bit)                  PAnsiChar
  WideChar    Wide character (16-bit)                 PWideChar
  AnsiString  Dynamically allocated ANSI string       PAnsiString
  WideString  A string of 16-bit characters           PWideString
  RawByteString A variable type to store BLOB data    PRawByteString
  UnicodeString Unicode string                        pUnicodeString
  ------------------------------------------------------------------------------
  NativeUInt  32-bit unsigned integer on Win32        PNativeUInt
  NativeUInt  64-bit unsigned integer on Win64        PNativeUInt
  NativeInt   32-bit signed integer on Win32          PNativeInt
  NativeInt   64-bit signed integer on Win64          PNativeInt
  ------------------------------------------------------------------------------
  Char        Wide character ( 8-bit) >> Delphi 2007  PChar
  Char        Wide character (16-bit) Delphi 2008 >>  PChar
  String      Alias for AnsiString >> Delphi 2007     PString
  String      Alias for UnicodeString Delphi 2008 >>  PString
  ------------------------------------------------------------------------------
*)


interface

implementation

end.
