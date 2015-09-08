unit uSeggerRTT;

interface

uses
  Windows, Messages, Classes, SysUtils, StdCtrls, Forms, SyncObjs, uJLinkARM;

const
  WM_SEGGER_RTT_LOG = WM_USER + 0;

const
  // acID[16] + UpNum[4] + DownNum[4] + UpBuffer0[4 * 6 ] + DownBuffer0[4 * 6 ]
  // at least 16 + 4 + 4 + 24 + 24 = SEGGER_RTT_MIN_SIZE Bytes
  SEGGER_RTT_MIN_SIZE = 72;
  SEGGER_RTT_MAX_BUF = 16;

  SEGGER_RTT_READ_FIFO_SIZE = $8000;
  SEGGER_RTT_READ_MAX_SIZE = $8000;
  SEGGER_RTT_READ_CB_SIZE = $400;
  SEGGER_RTT_UP_RETRY = 10;
  SEGGER_RTT_DOWN_RETRY = 10;
  SEGGER_RTT_MARKER : AnsiString = 'SEGGER RTT';

type
  // SEGGER_RTT.c
  PRingBuffer = ^TRingBuffer;

  TRingBuffer = record
    sName : DWORD;
    pBuffer : DWORD;
    SizeOfBuffer : DWORD;
    WrOff : DWORD;
    RdOff : DWORD;
    Flags : DWORD;
  end;

  PRingBufferEx = ^TRingBufferEx;

  TRingBufferEx = record
    // RingBuffer Start
    sName : DWORD;
    pBuffer : DWORD;
    SizeOfBuffer : DWORD;
    WrOff : DWORD;
    RdOff : DWORD;
    Flags : DWORD;
    // RingBuffer End
    WrOffAddr : DWORD;
    RdOffAddr : DWORD;
  end;

  PSeggerFind = ^TSeggerFind;

  TSeggerFind = record
    SramBase : DWORD;
    SramSize : DWORD;
    SramAddr : DWORD; // SRAM Address Reading ....
    SramOffset : DWORD; // Offset from SramBase
    UserAddress : DWORD;
    RealAddress : DWORD;
    Size : DWORD; // FindBuffer[ SEGGER_RTT_MIN_SIZE ] [ Size ]
    Offset : DWORD; // FindBuffer[Offset] : SEGGRE RTT ....
  end;

  // 1. ReadMemory to FindControlBlock "SEGGER RTT" : SRAM_BASE, SRAM_SIZE
  // 2. Read SeggerRTT.FInfo
  // 3. UpBuffers[], DownBuffers[]
  // 4. Read WrOff and RdOff
  PSeggerInfo = ^TSeggerInfo;

  // Read From RTT_Address
  TSeggerInfo = packed record
    // RTT Control Block Start
    acID : array [ 0 .. 15 ] of AnsiChar; // "SEGGER RTT"
    MaxNumUpBuffers : integer; // SEGGER_RTT_MAX_NUM_UP_BUFFERS = 2
    MaxNumDonwBuffers : integer; // SEGGER_RTT_MAX_NUM_DOWN_BUFFERS = 2
    UpDownBuffers : array [ 0 .. SEGGER_RTT_MAX_BUF - 1 ] of TRingBuffer;
    // RTT Control Block End
    Size : integer;
    Addr : integer;
    UpDownBuffersEx : array [ 0 .. SEGGER_RTT_MAX_BUF - 1 ] of TRingBufferEx;
  end;

  TSeggerRTT = class( TJLINKARM )
  private
    function Readable( UpIndex : integer ) : integer;
    function Writable( DownIndex : integer ) : integer;
    function Read( UpIndex : integer; Count : integer; var Buffer ) : integer;
    function Write( DownIndex : integer; Count : integer; const Buffer )
      : integer;
  public
    FFound : Boolean;
    FFind : TSeggerFind;
    FInfo : TSeggerInfo;

    FInfoUpdated : TSeggerInfo;

    procedure FindConfig( );
    function FindControlBlock( ) : integer;

    function ReadControlBlock( ) : integer;

    function UpReadable( UpIndex : integer; var BufferEx : PRingBufferEx )
      : integer;
    function DownWritable( DownIndex : integer; var BufferEx : PRingBufferEx )
      : integer;

    function ReadUpBuffer( UpBuffer : PRingBufferEx; Count : integer;
      var Buffer ) : integer;
    function WriteDownBuffer( DownBuffer : PRingBufferEx; Count : integer;
      const Buffer ) : integer;

  end;

implementation

{ TSeggerRTT }

var
  FindBuffer : array [ 0 .. SEGGER_RTT_MIN_SIZE + SEGGER_RTT_READ_CB_SIZE -
    1 ] of Byte;

function TSeggerRTT.Readable( UpIndex : integer ) : integer;
var
  Buf : PRingBuffer;
  RdOff : integer;
  WrOff : integer;
begin
  if not ReadMemory( FInfo.Addr, FInfo, FInfo.Size ) then
    Exit( -1 );

  // RTT Control Block changed ?
  if not CompareMem( @FInfo, @SEGGER_RTT_MARKER[ 1 ], 11 ) then
    Exit( -1 );

  Buf := @FInfo.UpDownBuffers[ UpIndex ];
  RdOff := Buf.RdOff;
  WrOff := Buf.WrOff;

  Result := WrOff - RdOff;
  if Result < 0 then
    Inc( Result, Buf.SizeOfBuffer );

  Exit( Result );
end;

function TSeggerRTT.Writable( DownIndex : integer ) : integer;
var
  Buf : PRingBuffer;
  RdOff : integer;
  WrOff : integer;
begin
  if not ReadMemory( FInfo.Addr, FInfo, FInfo.Size ) then
    Exit( -1 );

  // RTT Control Block changed ?
  if not CompareMem( @FInfo, @SEGGER_RTT_MARKER[ 1 ], 11 ) then
    Exit( -1 );

  Buf := @FInfo.UpDownBuffers[ FInfo.MaxNumUpBuffers + DownIndex ];
  RdOff := Buf.RdOff;
  WrOff := Buf.WrOff;

  Result := Buf.RdOff - Buf.WrOff - 1;
  if Result < 0 then
    Inc( Result, Buf.SizeOfBuffer );

  Exit( Result );
end;

// Read Data and Update FInfo.FindBuffer RdOff
function TSeggerRTT.Read( UpIndex : integer; Count : integer; var Buffer )
  : integer;
var
  Buf : PRingBuffer;
  RdOff : integer;
  WrOff : integer;

  PSource : DWORD;
  PDest : PByte;
  sizeRem : integer;
  sizeRead : integer;
begin
  Result := Readable( UpIndex );
  if Count > Result then
    Count := Result;

  if Count = -1 then
    Exit( Count );

  Buf := @FInfo.UpDownBuffers[ UpIndex ];
  RdOff := Buf.RdOff;
  WrOff := Buf.WrOff;

  PSource := Buf.pBuffer + RdOff;
  PDest := PByte( @Buffer );

  sizeRead := 0;
  // Read tail from current read position to wrap-around of buffer
  if RdOff > WrOff then
  begin
    sizeRem := Buf.SizeOfBuffer - RdOff;
    if sizeRem > Count then
      sizeRem := Count;

    if sizeRem > 0 then
    begin
      if not ReadMemory( PSource, PDest^, sizeRem ) then
        Exit( -1 );

      Dec( Count, sizeRem );
      Inc( PDest, sizeRem );
      Inc( sizeRead, sizeRem );
      Inc( RdOff, sizeRem );

      // Handle wrap-around of buffer
      if RdOff = Buf.SizeOfBuffer then
        RdOff := 0;

      // Update RdOff, MCU can write more ...
      if not WriteDWord( FInfo.Addr + DWORD( @Buf.RdOff ) - DWORD( @FInfo ),
        RdOff ) then
        Exit( -1 );

      PSource := Buf.pBuffer + RdOff;
    end;
  end;

  // Read head for remaining items of buffer
  sizeRem := WrOff - RdOff;
  if sizeRem > Count then
    sizeRem := Count;

  if sizeRem > 0 then
  begin
    if not ReadMemory( PSource, PDest^, sizeRem ) then
      Exit( sizeRead );

    Inc( sizeRead, sizeRem );
    Inc( RdOff, sizeRem );

    // Handle wrap-around of buffer
    if RdOff = Buf.SizeOfBuffer then
      RdOff := 0;

    // Update RdOff, MCU can write more ...
    if not WriteDWord( FInfo.Addr + DWORD( @Buf.RdOff ) - DWORD( @FInfo ), RdOff )
    then
      Exit( sizeRead - sizeRem );
  end;

  Exit( sizeRead );
end;

function TSeggerRTT.Write( DownIndex, Count : integer; const Buffer ) : integer;
var
  Buf : PRingBuffer;
  sizeToWrite : integer;
  headWritten : integer;
  tailCanWrite : integer;
  tailWritten : integer;
  PSource : PByte;
  PDest : DWORD;
  RdOff : integer;
  WrOff : integer;
  DownWritable : integer;
begin
  if not ReadMemory( FInfo.Addr, FInfo, FInfo.Size ) then
    Exit( -1 );

  Buf := @FInfo.UpDownBuffers[ FInfo.MaxNumUpBuffers + DownIndex ];
  RdOff := Buf.RdOff;
  WrOff := Buf.WrOff;

  DownWritable := Buf.RdOff - Buf.WrOff - 1;
  if DownWritable < 0 then
    Inc( DownWritable, Buf.SizeOfBuffer );

  PSource := PByte( @Buffer );
  headWritten := 0;
  tailWritten := 0;
  // Write data to buffer and handle wrap-around if necessary
  if Count > 0 then
  begin
    sizeToWrite := DownWritable;
    tailCanWrite := Buf.SizeOfBuffer - WrOff - 1;
    if sizeToWrite > tailCanWrite then
      sizeToWrite := tailCanWrite;
    if sizeToWrite > Count then
      sizeToWrite := Count;

    if sizeToWrite > 0 then
    begin
      PDest := Buf.pBuffer + WrOff;
      tailWritten := WriteMemory( PDest, sizeToWrite, PSource^ );
      if tailWritten = -1 then
        Exit( tailWritten );

      Inc( PSource, tailWritten );
      Dec( Count, tailWritten );
      Dec( DownWritable, tailWritten );

      // Handle wrap-around of buffer
      Inc( WrOff, tailWritten );
      if WrOff = Buf.SizeOfBuffer then
        WrOff := 0;

      // Update WrOff, MCU can read now ...
      if not WriteDWord( FInfo.Addr + DWORD( @Buf.WrOff ) - DWORD( @FInfo ),
        WrOff ) then
        Exit( 0 );
    end;

  end;

  if Count > 0 then
  begin
    PDest := Buf.pBuffer; // WrOff must be 0 because wrap-around

    sizeToWrite := Count;
    if sizeToWrite > DownWritable then
      sizeToWrite := DownWritable;

    if sizeToWrite > 0 then
    begin
      headWritten := WriteMemory( PDest, sizeToWrite, PSource^ );
      if headWritten = -1 then
        Exit( tailWritten );

      // Handle wrap-around of buffer
      Inc( WrOff, headWritten );
      if WrOff = Buf.SizeOfBuffer then
        WrOff := 0;

      if not WriteDWord( FInfo.Addr + DWORD( @Buf.WrOff ) - DWORD( @FInfo ),
        WrOff ) then
        Exit( tailWritten );
    end;
  end;

  Result := tailWritten + headWritten;
end;

procedure TSeggerRTT.FindConfig;
var
  Buf : PRingBuffer;
  IsOK : Boolean;
  IsValidRTT : Boolean;
  Num : integer;
  InfoSize : DWORD;
  BufferSize : DWORD;
  RealAddress : DWORD;
  SeggerRTT_Info : PSeggerInfo;
  I : integer;
begin
  if FFind.SramOffset >= FFind.SramSize then
    FFind.SramOffset := 0;
  FFind.SramAddr := FFind.SramBase + FFind.SramOffset;
  if ReadMemory( FFind.SramAddr, FindBuffer[ 0 ], SEGGER_RTT_MIN_SIZE ) then
    FFind.SramOffset := FFind.SramOffset + SEGGER_RTT_MIN_SIZE;
end;

// 0 -- Not Found
// -1 -- Failed to Read Memory
function TSeggerRTT.FindControlBlock : integer;
var
  Buf : PRingBuffer;
  IsOK : Boolean;
  IsValidRTT : Boolean;
  BufferNum : integer;
  InfoSize : DWORD;
  BufferSize : DWORD;
  RealAddress : DWORD;
  SeggerRTT_Info : PSeggerInfo;
  I : integer;
begin
  if FFind.SramOffset >= FFind.SramSize then
    FFind.SramOffset := 0;

  FFind.Size := SEGGER_RTT_READ_CB_SIZE;
  if FFind.SramOffset + FFind.Size > FFind.SramSize then
    FFind.Size := FFind.SramSize - FFind.SramOffset;

  FFind.SramAddr := FFind.SramBase + FFind.SramOffset;

  // FindBuffer[ 0..71 ] is previous read
  // Read to FindBuffer[ SEGGER_RTT_MIN_SIZE ],
  IsOK := ReadMemory( FFind.SramAddr, FindBuffer[ SEGGER_RTT_MIN_SIZE ],
    FFind.Size );

  // Read Memory Fialed
  if not IsOK then
    Exit( -1 );

  // Read Memory Success, FindControlBlock RTT Magic String : SEGGER RTT
  // PreviousRead[ SEGGER_RTT_MIN_SIZE ] : CurrentRead[ Size ]

  // [ SEGGER_RTT_MIN_SIZE Bytes ] [ Size Bytes ]
  IsValidRTT := False;
  FFind.Offset := 0;
  while ( FFind.Offset + 11 ) < ( SEGGER_RTT_MIN_SIZE + FFind.Size ) do
  begin
    IsOK := CompareMem( @FindBuffer[ FFind.Offset ], @SEGGER_RTT_MARKER[ 1 ],
      11 ); // 'SEGGER RTT'#0
    if IsOK then
    begin
      SeggerRTT_Info := PSeggerInfo( @FindBuffer[ FFind.Offset ] );
      BufferNum := SeggerRTT_Info^.MaxNumUpBuffers +
        SeggerRTT_Info^.MaxNumDonwBuffers;

      if BufferNum <= SEGGER_RTT_MAX_BUF then
      begin
        for I := 0 to BufferNum - 1 do
        begin
          Buf := @SeggerRTT_Info^.UpDownBuffers[ I ];
          if Buf.WrOff > Buf.SizeOfBuffer then
            break;
          if Buf.RdOff > Buf.SizeOfBuffer then
            break;
          if Buf.pBuffer = 0 then // to be configured
            break;
        end;

        if I = BufferNum then
        begin
          IsValidRTT := True;
          break;
        end;
      end;
    end;

    Inc( FFind.Offset );
  end;

  // Invalid RTT Control Block
  if not IsValidRTT then
  begin
    // Read Next Memory Block
    Inc( FFind.SramOffset, FFind.Size );

    // FindControlBlock Failed, Copy Last Data to Head
    if FFind.Size < SEGGER_RTT_MIN_SIZE then
    begin
      FillChar( FindBuffer[ 0 ], 0, SEGGER_RTT_MIN_SIZE - FFind.Size );
      CopyMemory( @FindBuffer[ SEGGER_RTT_MIN_SIZE - FFind.Size ],
        @FindBuffer[ SEGGER_RTT_MIN_SIZE ], FFind.Size );
    end else begin
      CopyMemory( @FindBuffer[ 0 ], @FindBuffer[ FFind.Size ],
        SEGGER_RTT_MIN_SIZE );
    end;

    Exit( 0 );
  end;

  // RTT Control Block is valid
  // acID[16] + UpNum[4] + DownNum[4] + UpBuffer0[4 * 6 ] + DownBuffer0[4 * 6 ]
  // at least 16 + 4 + 4 + 24 + 24 = SEGGER_RTT_MIN_SIZE Bytes
  //
  // FindBuffer[ SEGGER_RTT_MIN_SIZE ] [ Size ]
  // SEGGER RTT#0
  // Offset
  SeggerRTT_Info := PSeggerInfo( @FindBuffer[ FFind.Offset ] );
  RealAddress := FFind.SramAddr - SEGGER_RTT_MIN_SIZE + FFind.Offset;

  InfoSize := SEGGER_RTT_MIN_SIZE;
  if BufferNum > 2 then
    Inc( InfoSize, ( BufferNum - 2 ) * 24 );

  BufferSize := SEGGER_RTT_MIN_SIZE + FFind.Size;

  if FFind.Offset + InfoSize <= BufferSize then
    CopyMemory( @FInfo, @FindBuffer[ FFind.Offset ], InfoSize )
  else if not ReadMemory( RealAddress, FInfo, InfoSize ) then
    Exit( -1 ); // Read Memory Fialed

  FInfo.Size := InfoSize;
  FInfo.Addr := RealAddress;
  FFind.RealAddress := RealAddress;

  Exit( RealAddress );
end;

// 1 --- OK, No Channged
// 0 --- Failed, Changed
// -1 -- Failed, Read Memory
function TSeggerRTT.ReadControlBlock( ) : integer;
var
  I : integer;
  IsOK : Boolean;
  Source, Dest : PByte;
begin
  if not ReadMemory( FInfo.Addr, FInfoUpdated, FInfo.Size ) then
    Exit( -1 );

  IsOK := CompareMem( @FInfo, @FInfoUpdated, sizeof( FInfoUpdated.acID ) +
    sizeof( FInfoUpdated.MaxNumUpBuffers ) +
    sizeof( FInfoUpdated.MaxNumDonwBuffers ) );

  if not IsOK then
    Exit( 0 );

  Source := PByte( @FInfo.UpDownBuffers[ 0 ] );
  Dest := PByte( @FInfoUpdated.UpDownBuffers[ 0 ] );
  for I := 0 to FInfoUpdated.MaxNumUpBuffers +
    FInfoUpdated.MaxNumDonwBuffers - 1 do
  begin
    IsOK := CompareMem( Source, Dest, 12 );
    if not IsOK then
      Exit( 0 );
    Inc( Source, sizeof( TRingBuffer ) );
    Inc( Dest, sizeof( TRingBuffer ) );
  end;

  FInfoUpdated.Addr := FInfo.Addr;
  FInfoUpdated.Size := FInfo.Size;
  Exit( 1 );
end;

function TSeggerRTT.UpReadable( UpIndex : integer;
  var BufferEx : PRingBufferEx ) : integer;
var
  Buffer : PRingBuffer;
begin
  Buffer := @FInfoUpdated.UpDownBuffers[ UpIndex ];
  BufferEx := @FInfoUpdated.UpDownBuffersEx[ UpIndex ];
  CopyMemory( BufferEx, Buffer, sizeof( TRingBuffer ) );
  Result := BufferEx.WrOff - BufferEx.RdOff;
  if Result < 0 then
    Inc( Result, BufferEx.SizeOfBuffer );

  BufferEx.RdOffAddr := FInfoUpdated.Addr + DWORD( @Buffer.RdOff ) -
    DWORD( @FInfoUpdated );
  BufferEx.WrOffAddr := FInfoUpdated.Addr + DWORD( @Buffer.WrOff ) -
    DWORD( @FInfoUpdated );
  Exit( Result );
end;

function TSeggerRTT.DownWritable( DownIndex : integer;
  var BufferEx : PRingBufferEx ) : integer;
var
  Buffer : PRingBuffer;
begin
  Buffer := @FInfoUpdated.UpDownBuffers[ FInfoUpdated.MaxNumUpBuffers +
    DownIndex ];
  BufferEx := @FInfoUpdated.UpDownBuffersEx[ FInfoUpdated.MaxNumUpBuffers +
    DownIndex ];
  CopyMemory( BufferEx, Buffer, sizeof( TRingBuffer ) );
  Result := BufferEx.RdOff - BufferEx.WrOff - 1;
  if Result < 0 then
    Inc( Result, BufferEx.SizeOfBuffer );

  BufferEx.RdOffAddr := FInfoUpdated.Addr + DWORD( @Buffer.RdOff ) -
    DWORD( @FInfoUpdated );
  BufferEx.WrOffAddr := FInfoUpdated.Addr + DWORD( @Buffer.WrOff ) -
    DWORD( @FInfoUpdated );
  Exit( Result );
end;

{ *
  * ReadUpBuffer
  * Function description
  *     Reads characters from SEGGER real-time-terminal control block
  *     which have been previously stored by the MCU.
  *
  * Parameters
  *     UpBuffer  Up-buffer to be used. (e.g. 0 for "Terminal")
  *     Buffer    Pointer to buffer provided by target application,
  *               to copy characters from RTT-up-buffer to.
  *     Count     Size of the target application buffer
  *
  * Return values
  *     Number of bytes that have been read
}
function TSeggerRTT.ReadUpBuffer( UpBuffer : PRingBufferEx; Count : integer;
  var Buffer ) : integer;
var
  SizeOfBuffer : DWORD;
  RdOff : DWORD;
  WrOff : DWORD;
  RdOffAddr : DWORD;
  WrOffAddr : DWORD;

  NumBytesCanRead : integer;
  NumBytesHasRead : DWORD;
  PSource : DWORD;
  PDest : PByte;
begin
  RdOff := UpBuffer.RdOff;
  WrOff := UpBuffer.WrOff;
  RdOffAddr := UpBuffer.RdOffAddr;
  WrOffAddr := UpBuffer.WrOffAddr;
  SizeOfBuffer := UpBuffer.SizeOfBuffer;

  PSource := UpBuffer.pBuffer + RdOff;
  PDest := PByte( @Buffer );

  NumBytesHasRead := 0;

  // Read from current read position to wrap-around of buffer, first
  if ( RdOff > WrOff ) then
  begin
    NumBytesCanRead := SizeOfBuffer - RdOff;
    if NumBytesCanRead > Count then
      NumBytesCanRead := Count;

    if NumBytesCanRead > 0 then
    begin
      if not ReadMemory( PSource, PDest^, NumBytesCanRead ) then
        Exit( -1 );

      NumBytesHasRead := NumBytesHasRead + NumBytesCanRead;
      Count := Count - NumBytesCanRead;
      PDest := PDest + NumBytesCanRead;
      RdOff := RdOff + NumBytesCanRead;

      // Handle wrap-around of buffer
      if ( RdOff = SizeOfBuffer ) then
        RdOff := 0;

      // Update RdOff, MCU can write more ...
      if not WriteDWord( RdOffAddr, RdOff ) then
        Exit( -1 );

      PSource := UpBuffer.pBuffer + RdOff;
    end;
  end;

  // Read remaining items of buffer
  NumBytesCanRead := WrOff - RdOff;
  if NumBytesCanRead > Count then
    NumBytesCanRead := Count;

  if NumBytesCanRead > 0 then
  begin
    if not ReadMemory( PSource, PDest^, NumBytesCanRead ) then
      Exit( NumBytesHasRead ); // Tail

    // Update RdOff, MCU can write more ...
    RdOff := RdOff + NumBytesCanRead;
    if not WriteDWord( RdOffAddr, RdOff ) then
      Exit( NumBytesHasRead ); // Tail

    NumBytesHasRead := NumBytesHasRead + NumBytesCanRead; // Tail + Head
  end;

  Exit( NumBytesHasRead );
end;

{ * WriteDownBuffer
  * Function description
  *     Stores a specified number of characters in SEGGER RTT
  *     control block which is then read by the MCU.
  *
  * Parameters
  *     DownBuffer  Donw"-buffer to be used. (e.g. 0 for "Terminal")
  *     Buffer      Pointer to character array.
  *                 Does not need to point to a \0 terminated string.
  *     Count       Number of bytes to be stored in the SEGGER RTT control block.
  *
  * Return values
  *     Number of bytes which have been stored in the "Down"-buffer.
  *
  * Notes
  *     (1) Flags = SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL
  *           If there is not enough space in the "Down"-buffer,
  *           Try until the "Down"-buffer is available to write
  *     (2) Flags <> SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL
  *           If there is not enough space in the "Down"-buffer,
  *           remaining characters of pBuffer are dropped.
  *
  *           (1) Flags == SEGGER_RTT_MODE_NO_BLOCK_TRIM
  *           (2) Flags == SEGGER_RTT_MODE_NO_BLOCK_SKIP
  * }
function TSeggerRTT.WriteDownBuffer( DownBuffer : PRingBufferEx;
  Count : integer; const Buffer ) : integer;
const
  SEGGER_RTT_MODE_MASK = 3;
  SEGGER_RTT_MODE_NO_BLOCK_SKIP = 0;
  SEGGER_RTT_MODE_NO_BLOCK_TRIM = 1;
  SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL = 2;
var
  SizeOfBuffer : DWORD;
  Flags : DWORD;
  RdOff : DWORD;
  WrOff : DWORD;
  RdOffAddr : DWORD;
  WrOffAddr : DWORD;

  NumBytesCurrentWritten : integer;
  NumBytesCanWrite : integer;
  NumBytesHasWritten : DWORD;
  PSource : PByte;
  PDest : DWORD;
begin
  Flags := DownBuffer.Flags;
  RdOff := DownBuffer.RdOff;
  WrOff := DownBuffer.WrOff;
  RdOffAddr := DownBuffer.RdOffAddr;
  WrOffAddr := DownBuffer.WrOffAddr;
  SizeOfBuffer := DownBuffer.SizeOfBuffer;

  PSource := PByte( @Buffer );
  PDest := DownBuffer.pBuffer + WrOff;

  // In case we are not in blocking mode,
  // we need to calculate, how many bytes we can put into the buffer at all.
  if ( Flags and SEGGER_RTT_MODE_MASK ) <> SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL
  then
  begin
    // RdOff May be changed by MCU in the meantime
    NumBytesCanWrite := RdOff - WrOff - 1;
    if NumBytesCanWrite < 0 then
      NumBytesCanWrite := NumBytesCanWrite + SizeOfBuffer;

    // If the complete data does not fit in the buffer,
    // check if we have to skip it completely or trim the data
    if Count > NumBytesCanWrite then
    begin
      // SEGGER_RTT_MODE_NO_BLOCK_SKIP : [ -------------------------- ]
      if ( Flags and SEGGER_RTT_MODE_MASK ) <> SEGGER_RTT_MODE_NO_BLOCK_SKIP
      then
        Exit( 0 );

      // SEGGER_RTT_MODE_NO_BLOCK_TRIM : [ ********** ] [ ----------- ]
      Count := NumBytesCanWrite; // NumBytesCanWrite >= 0
    end;
  end;

  // Write data to buffer and handle wrap-around if necessary
  NumBytesHasWritten := 0;
  while ( Count > 0 ) and ( NumBytesCanWrite > 0 ) do
  begin
    // RdOff May be changed by MCU in the meantime
    if not ReadDWord( RdOffAddr, RdOff ) then
      Exit( NumBytesHasWritten );

    NumBytesCanWrite := RdOff - WrOff - 1;
    if NumBytesCanWrite < 0 then
      NumBytesCanWrite := NumBytesCanWrite + SizeOfBuffer;

    if NumBytesCanWrite > SizeOfBuffer - WrOff then
      NumBytesCanWrite := SizeOfBuffer - WrOff;

    if NumBytesCanWrite > Count then
      NumBytesCanWrite := Count;

    NumBytesCurrentWritten := WriteMemory( PDest, NumBytesCanWrite, PSource^ );
    if NumBytesCurrentWritten = -1 then
      Exit( NumBytesHasWritten );

    Count := Count - NumBytesCurrentWritten;
    NumBytesCanWrite := NumBytesCanWrite - NumBytesCurrentWritten;
    PSource := PSource + NumBytesCurrentWritten;
    WrOff := WrOff + NumBytesCurrentWritten;

    // Handle wrap-around of buffer
    if ( WrOff = SizeOfBuffer ) then
      WrOff := 0;

    if not WriteDWord( WrOffAddr, WrOff ) then
      break;

    NumBytesHasWritten := NumBytesHasWritten + NumBytesCurrentWritten;
  end;

  Exit( NumBytesHasWritten );
end;

end.
