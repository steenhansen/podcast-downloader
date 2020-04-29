unit download_stream;

{$mode objfpc}{$H+}

interface

uses

  {$IFDEF ALLOW_GUI_STATE}
  gui_state,
  {$ENDIF}
  {$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,           // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils, openssl,
  fphttpclient, regexpr, LazFileUtils,
  progress_stream;

const
  HTTP_TIMEOUT = 1000;    //  note has a backoff, 1000,2000,3000,4000,5000mSec
  HTTP_RETRIES = 5;
  DOWNLOAD_BUFFER_SIZE = fphttpclient.ReadBufLen;

type

  TDownloadStream = class(TProgressStream)
  private
  public
    constructor Create(tempPathname: string; fileNumber: integer; DoOnWriteEpisode_3: TOnWriteStream);
    destructor Destroy; override;
  published
  end;

procedure downloadAnEpisode(mediaUrl, the_save_directory, fileName: string; fileNumber: integer;
  DoOnWriteEpisode_3: TOnWriteStream; DoOnFailedReadEpisode_2: TOnFailedReadEpisode);
function urlOrTestFile(url_or_file, program_path: string; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadPodcast_2: TOnFailedReadPodcast): string;
procedure downloadThePodcast(mediaUrl, the_save_directory, filename: string; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadPodcast_2: TOnFailedReadPodcast);
function getInternetEpisode(mediaUrl, tempPathname: string; fileNumber: integer; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadEpisode_2: TOnFailedReadEpisode): boolean;

implementation

uses
  dirs_files,
  consts_types;

constructor TDownloadStream.Create(tempPathname: string; fileNumber: integer; DoOnWriteEpisode_3: TOnWriteStream);
begin
  inherited Create(tempPathname, fileNumber, DoOnWriteEpisode_3);
end;

destructor TDownloadStream.Destroy;
begin
  inherited Destroy;
end;

function MemoryStreamToString2(M: TMemoryStream): ansistring;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

function makeHttpConnection(): TFPHTTPClient;
var
  mediaHttp: TFPHTTPClient;
begin
  mediaHttp := TFPHTTPClient.Create(nil);
  mediaHttp.AddHeader('User-Agent', 'Mozilla/5.0');
  mediaHttp.AllowRedirect := True;
  mediaHttp.IOTimeout := HTTP_TIMEOUT;
  Result := mediaHttp;
end;

function nowAsFileNamable(): string;
var
  today: TDateTime;
  todayStr, timeStr, todayDash, timeDash: string;
begin
  today := Now;
  todayStr := DateToStr(today);
  timeStr := TimeToStr(today);
  todayDash := StringReplace(todayStr, DATE_SLASH, '-', [rfReplaceAll, rfIgnoreCase]);
  timeDash := StringReplace(timeStr, ':', '-', [rfReplaceAll, rfIgnoreCase]);
  Result := todayDash + '_' + timeDash;
end;

procedure downloadThePodcast(mediaUrl, the_save_directory, filename: string; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadPodcast_2: TOnFailedReadPodcast);
var
  real_name: string;
  downloaded_fine: boolean;
begin
  {$IFDEF ALLOW_GUI_STATE}
  mouseConnectToUrl();
  {$ENDIF}
  real_name := the_save_directory + PathDelim + filename;
  downloaded_fine := getInternetEpisode(mediaUrl, real_name, 49, DoOnWriteEpisode_3, DoOnFailedReadPodcast_2);
  if not downloaded_fine then
    raise Exception.Create(fileName);
end;

function readTextFile(real_name: string): string;
var
  txt: string;
  strm: TFileStream;
  n: longint;
begin
  txt := '';
  strm := TFileStream.Create(real_name, fmOpenRead);
  try
    n := strm.Size;
    SetLength(txt, n);
    strm.Read(txt[1], n);
  finally
    strm.Free;
  end;
  Result := txt;
end;

function getInternetEpisode(mediaUrl, tempPathname: string; fileNumber: integer; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadEpisode_2: TOnFailedReadEpisode): boolean;
var
  urlStream: TDownloadStream;
  isDone: boolean;
  numTrys: integer;
  mediaHttp: TFPHTTPClient;

  procedure startConnect();
  begin
    InitSSLInterface();
    urlStream := TDownloadStream.Create(tempPathname, fileNumber, DoOnWriteEpisode_3);
    mediaHttp := makeHttpConnection();
    numTrys := 0;
    isDone := False;
  end;

  procedure finishFile();
  begin
    mediaHttp.Free;
    urlStream.Free;
  end;

  function readTheFile(): boolean;
  var
    io_time_out: integer;
  begin
    io_time_out := (numTrys + 1) * HTTP_TIMEOUT;             // 1000mSec, 2000mSec, 3000mSec
    mediaHttp.IOTimeout := io_time_out;
    mediaHttp.HTTPMethod('GET', mediaUrl, urlStream, [200]);
    isDone := True;
    Result := isDone;
  end;

  function giveUpOnFile(): boolean;
  begin
    numTrys := numTrys + 1;
    if numTrys = HTTP_RETRIES then
    begin
      if Assigned(DoOnFailedReadEpisode_2) then
        DoOnFailedReadEpisode_2(nil, mediaUrl);
      isDone := True;
    end
    else
      isDone := False;
    Result := isDone;
  end;

  function multipleReadAttempts(): boolean;
  begin
    repeat
      try
        isDone := readTheFile();
        Result := True;
      except
        on E: ECancelException do
          raise;
        on E: Exception do
        begin
          isDone := giveUpOnFile();
          Result := False;
        end;
      end;
    until isDone;
  end;

begin
  try
    try
      startConnect();
      Result := multipleReadAttempts();
    except
      on E: ECancelException do
        raise;
    end;
  finally
    finishFile();
  end;
end;



function readToFile(episodeUrl, filename: string; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadPodcast_2: TOnFailedReadPodcast): string;
var
  temp_folder, real_name, txt, protocoledUrl: string;
begin
  temp_folder := GetTempDir(True);
  protocoledUrl := getUrlProtocol(episodeUrl);
  downloadThePodcast(protocoledUrl, temp_folder, filename, DoOnWriteEpisode_3, DoOnFailedReadPodcast_2);
  real_name := temp_folder + PathDelim + filename;
  txt := readTextFile(real_name);
  deletefile(real_name);
  Result := txt;
end;

function readToMemory(trimmedPath, program_path: string): string;
var
  stream: TMemoryStream;
  xmlData, all_path: string;
begin
  try
    stream := TMemoryStream.Create;
    all_path := program_path + trimmedPath;
    stream.LoadFromFile(all_path);
    xmlData := MemoryStreamToString2(stream);
    Result := xmlData;
  finally
    FreeAndNil(stream);
  end;
end;

function urlOrTestFile(url_or_file, program_path: string; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadPodcast_2: TOnFailedReadPodcast): string;
var
  trimmedPath, filename: string;
  dateTimeStr: string;
begin
  trimmedPath := Trim(url_or_file);
  if isOnlinePodcast(trimmedPath) then
  begin
    dateTimeStr := nowAsFileNamable();
    filename := RSS_TEMP_FILE + dateTimeStr;
    Result := readToFile(trimmedPath, filename, DoOnWriteEpisode_3, DoOnFailedReadPodcast_2);
  end
  else
    Result := readToMemory(trimmedPath, program_path);
end;


procedure downloadAnEpisode(mediaUrl, the_save_directory, fileName: string; fileNumber: integer;
  DoOnWriteEpisode_3: TOnWriteStream; DoOnFailedReadEpisode_2: TOnFailedReadEpisode);
var
  tempPathname: string;
  realPathname: string;
  download_fine: boolean;
begin
  try
    {$IFDEF ALLOW_GUI_STATE}
        mouseReadingUrl();   // so get flicker of business when a bunch of files already exist, when checking
    {$ENDIF}
    realPathname := the_save_directory + PathDelim + fileName;
    if not FileExists(realPathname) then
    begin
      tempPathname := the_save_directory + PathDelim + '_partial_' + fileName;
      download_fine := False;
      try
      {$IFDEF ALLOW_GUI_STATE}
        mouseConnectToUrl();
      {$ENDIF}
        download_fine := getInternetEpisode(mediaUrl, tempPathname, fileNumber, DoOnWriteEpisode_3, DoOnFailedReadEpisode_2);
      except
        on E: ECancelException do
          raise;
      end;
      if not download_fine then
        raise Exception.Create(fileName);
    end
    else
    begin
      {$IFDEF ALLOW_GUI_STATE}
        mouseConnectToUrl();
      {$ENDIF}
    end;
  finally
    if download_fine then
      if not RenameFile(tempPathname, realPathname) then
      begin
        DeleteFile(tempPathname);
        RenameFile(tempPathname, realPathname);
      end;
    {$IFDEF ALLOW_GUI_STATE}
            mouseReadingUrl();
    {$ENDIF}
  end;
end;

end.
