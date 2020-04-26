unit progress_stream;

{$mode objfpc}{$H+}

interface

uses
   {$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,         // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils,
  LazLoggerBase,
  LazLoggerDummy,
  LazLogger,
  openssl,
  regexpr,
  LazFileUtils;

type
  TOnWriteStream = procedure(Sender: TObject; APos: int64; fileNumber: integer) of object;
  TOnFailedReadEpisode = procedure(Sender: TObject; mediaUrl: string) of object;
  TOnFailedReadPodcast = procedure(Sender: TObject; mediaUrl: string) of object;

  TProgressStream = class(TFileStream)
  private
    FFileNumber: integer;
    FOnWriteStream: TOnWriteStream;
  public
    constructor Create(tempPathname: string; fileNumber: integer; DoOnWriteEpisode_3: TOnWriteStream);
    destructor Destroy; override;
    function Write(const Buffer; Count: longint): longint; override;
    function Read(var Buffer; Count: longint): longint; override;
    function Seek(Offset: longint; Origin: word): longint; override;
    property OnWriteStream: TOnWriteStream read FOnWriteStream write FOnWriteStream;
  published
  end;

implementation

constructor TProgressStream.Create(tempPathname: string; fileNumber: integer; DoOnWriteEpisode_3: TOnWriteStream);
begin
  inherited Create(tempPathname, fmCreate);
  FFileNumber := fileNumber;
  OnWriteStream := DoOnWriteEpisode_3;
end;

destructor TProgressStream.Destroy;
begin
  inherited Destroy;
end;

function TProgressStream.Read(var Buffer; Count: longint): longint;
begin
  Result := inherited Read(Buffer, Count);
end;

function TProgressStream.Write(const Buffer; Count: longint): longint;
begin
  Result := inherited Write(Buffer, Count);
  if Assigned(FOnWriteStream) then
    FOnWriteStream(Self, Self.Position, FFileNumber);
end;

function TProgressStream.Seek(Offset: longint; Origin: word): longint;
begin
  Result := inherited Seek(Offset, Origin);
end;


end.
