unit episode_bits;

{$mode objfpc}{$H+}

interface

uses
  {$IfDef ALLOW_DEBUG_SERVER}
    //debug_server,           // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils;

{
 A bit 31 on/off in filter match
 B bit 30 on/off was downloaded
 C bit 29 on/off downloading this one exact episode

 X bit 28 on/off will download
 Y bit 27 on/off file not checked
 Z bit 26 on/off currently downloading all checked episodes

 %ABCXYZ00000000000000000000000000000

 %11111111111111111111111111000000 largest number without loss   4294967232
 %ABCXYZ11111111111111111111111111 67108863 compressed form of lossless largest

 %00000000000000000000000001000000 smallest number without loss 64
  00000000000000000000000000000001 1 compressed form

  https://www.calculator.net/binary-calculator.html
 }

const
  FILTER_MATCH = %10000000000000000000000000000000;
  FILTER_MASK = %01111111111111111111111111111111;

  HAS_DOWNLOADED_FILE = %01000000000000000000000000000000;
  HAS_DOWNLOADED_MASK = %10110111111111111111111111111111;

  IS_DOWNLOADING_FILE = %00100000000000000000000000000000;
  IS_DOWNLOADING_MASK = %11010111111111111111111111111111;

  WILL_DOWNLOAD_FILE = %00010000000000000000000000000000;
  WILL_DOWNLOAD_MASK = %11100111111111111111111111111111;

  IGNORE_FILE = %00001000000000000000000000000000;

  DOWNLOADING_SELECTED = %00000100000000000000000000000000;

  INFO_STORE = %11111100000000000000000000000000;
  BYTES_STORE = %00000011111111111111111111111111;    // 67108863

  BYTES_SHIFT = 6;
  LARGEST_BITS_NO_LOSS = 4294967232;   // = 67108863 * 64
  SMALLEST_BITS_NO_LOSS = 64;

function encodeFilterMatch(old_episode_object: TObject; match_filter: boolean): TObject;
function decodeFilterMatch(episode_object: TObject): boolean;
function decodeFileByteSize(episode_object: TObject): int64;
function encodeFileByteSize(episode_object: TObject; file_byte_size: int64): TObject;
function encodeIsDownloading(episode_object: TObject): TObject;
function decodeWillDownload(episode_object: TObject): boolean;
function encodeWillDownload(episode_object: TObject): TObject;
function encodeDownloadingSelected(episode_object: TObject): TObject;
function decodeDownloadingSelected(episode_object: TObject): boolean;

implementation

function encodeFilterMatch(old_episode_object: TObject; match_filter: boolean): TObject;
var
  old_episode_bits, new_episode_bits: cardinal;
  new_episode_object: TObject;
begin
  old_episode_bits := cardinal(old_episode_object);
  if match_filter then
    new_episode_bits := old_episode_bits or FILTER_MATCH
  else
    new_episode_bits := old_episode_bits and FILTER_MASK;
  new_episode_object := TObject(new_episode_bits);
  Result := new_episode_object;
end;

function decodeFilterMatch(episode_object: TObject): boolean;
var
  episode_bits, filter_bit: cardinal;
  match_filter: boolean;
begin
  episode_bits := cardinal(episode_object);
  filter_bit := FILTER_MATCH and episode_bits;
  match_filter := filter_bit <> 0;
  Result := match_filter;
end;

function decodeFileByteSize(episode_object: TObject): int64;
var
  episode_bits: cardinal;
  shrunk_26_bits: cardinal;
  file_byte_size: int64;
begin
  episode_bits := cardinal(episode_object);
  shrunk_26_bits := episode_bits and BYTES_STORE;
  file_byte_size := shrunk_26_bits shl BYTES_SHIFT;
  Result := file_byte_size;
end;

function encodeFileByteSize(episode_object: TObject; file_byte_size: int64): TObject;
var
  episode_bits: cardinal;
  info_data, shrunk_26_bits, new_episode_bits: cardinal;
  new_episode_object: TObject;
begin
  episode_bits := cardinal(episode_object);
  info_data := episode_bits and INFO_STORE;
  shrunk_26_bits := file_byte_size shr BYTES_SHIFT;
  new_episode_bits := info_data or shrunk_26_bits;
  new_episode_object := TObject(new_episode_bits);
  Result := new_episode_object;
end;

function encodeIsDownloading(episode_object: TObject): TObject;
var
  old_episode_bits: cardinal;
  new_episode_bits: cardinal;
  new_episode_object: TObject;
begin
  old_episode_bits := cardinal(episode_object);
  new_episode_bits := old_episode_bits or IS_DOWNLOADING_FILE;
  new_episode_object := TObject(new_episode_bits);
  Result := new_episode_object;
end;

function decodeWillDownload(episode_object: TObject): boolean;
var
  will_download, old_episode_bits: cardinal;
  selected_for_downloading: boolean;
begin
  old_episode_bits := cardinal(episode_object);
  will_download := WILL_DOWNLOAD_FILE and old_episode_bits;
  selected_for_downloading := will_download <> 0;
  Result := selected_for_downloading;
end;

function encodeWillDownload(episode_object: TObject): TObject;
var
  episode_bits: cardinal;
  new_episode_bits: cardinal;
  new_episode_object: TObject;
begin
  episode_bits := cardinal(episode_object);
  new_episode_bits := episode_bits and WILL_DOWNLOAD_MASK;
  new_episode_bits := WILL_DOWNLOAD_FILE or new_episode_bits;
  new_episode_object := TObject(new_episode_bits);
  Result := new_episode_object;
end;

function encodeDownloadingSelected(episode_object: TObject): TObject;
var
  episode_bits: cardinal;
  shrunk_bytes_32: cardinal;
  new_episode_object: TObject;
begin
  episode_bits := cardinal(episode_object);
  shrunk_bytes_32 := episode_bits or DOWNLOADING_SELECTED;
  new_episode_object := TObject(shrunk_bytes_32);
  Result := new_episode_object;
end;

function decodeDownloadingSelected(episode_object: TObject): boolean;
var
  episode_bits: integer;
  after_and: cardinal;
  selected_for_downloading: boolean;
begin
  episode_bits := cardinal(episode_object);
  after_and := DOWNLOADING_SELECTED and episode_bits;
  selected_for_downloading := after_and <> 0;
  Result := selected_for_downloading;
end;

end.







































