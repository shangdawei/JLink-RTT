unit uJtagTap;

interface

uses
  SysUtils, Windows, Classes;

const
  JTAG_MAX_BIT_STREAM_LENGTH = 1024;

type
  { TAP Controller State Transitions }

  TJTAG_TAP_State = ( TAP_INVALID = -1, TAP_DREXIT2 = $00, TAP_DREXIT1 = $01,
    TAP_DRSHIFT = $02, TAP_DRPAUSE = $03, TAP_IRSELECT = $04,
    TAP_DRUPDATE = $05, TAP_DRCAPTURE = $06, TAP_DRSELECT = $07,
    TAP_IREXIT2 = $08, TAP_IREXIT1 = $09, TAP_IRSHIFT = $0A, TAP_IRPAUSE = $0B,
    TAP_IDLE = $0C, TAP_IRUPDATE = $0D, TAP_IRCAPTURE = $0E, TAP_RESET = $0F );

  TJTAG_DeviceConfig = record
    IRLen : integer;
    DRLen : integer;
    TRSTTime : integer;
    RSTTime : integer;
  end;

implementation

end.
