unit console_podcast;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  rss_podcast;

const
  NO_FAILED_MEMO_BOX = nil;

type
  TConsolePodcast = class(TObject)
  private
    FNumberEpisodes: integer;
    FFailedFiles: string;
    FAtLeastOneFile: boolean;
    FrssPodcast: TRssPodcast;
    FCurrentRow: integer;
    FDeskDownloadDir: string;
    FConsolLines: array of string;
  protected
    function whichEpisode(file_number: integer): string;
    function getPodcastUrl(test_podcast_url: string): string;
    function getFailed(): string;
    function readTheEpisodes(url_or_file, program_path: string): boolean;
    function getConsolLines(): string;
    procedure DoOnConsoleReadPodcast(Sender: TObject; APosition: int64; fileNumber: integer);
    procedure DoOnFailedConsoleReadPodcast(Sender: TObject; mediaUrl: string);
    procedure DoOnConsoleWriteEpisode(Sender: TObject; APosition: int64; file_number: integer);
    procedure DoOnFailedConsoleReadEpisode(Sender: TObject; mediaUrl: string);
    function parsePodcast(url_or_file, program_path: string): integer;
    procedure processPodcast(url_or_file, program_path: string);
    procedure writeRow(row_y: integer; row_str: string);
    procedure podcastDetails();
  public
    destructor Destroy; override;
    constructor Create();
  end;

function readAPodcast(test_podcast_url: string = ''): string;

implementation

uses
  consts_types,
  dirs_files,
  console_routines;

constructor TConsolePodcast.Create();
var
  row_index: integer;
begin
  inherited Create();
  FAtLeastOneFile := False;
  FFailedFiles := '';
  SetLength(FConsolLines, NUMBER_CONSOL_LINES);
  for row_index := 0 to NUMBER_CONSOL_LINES - 1 do
    FConsolLines[row_index] := '';
end;

destructor TConsolePodcast.Destroy;
begin
  FrssPodcast.Free();
  inherited Destroy;
end;

function TConsolePodcast.getConsolLines(): string;
var
  row_index: integer;
  console_output, trimmed_consol: string;
  doing_end_blanks: boolean;
begin
  console_output := '';
  doing_end_blanks := True;
  for row_index := NUMBER_CONSOL_LINES - 1 downto 0 do
  begin
    if doing_end_blanks then
      if FConsolLines[row_index] <> '' then
        doing_end_blanks := False;
    if not doing_end_blanks then
      console_output := FConsolLines[row_index] + LINE_ENDING + console_output;
  end;
  trimmed_consol := Trim(console_output);
  Result := trimmed_consol;
end;

function TConsolePodcast.whichEpisode(file_number: integer): string;
var
  episode_filename, total_episodes, unpadded_number, padded_number, out_of: string;
  total_chars: integer;
begin
  total_episodes := IntToStr(FNumberEpisodes);
  total_chars := Length(total_episodes);
  unpadded_number := IntToStr(file_number + 1);
  padded_number := unpadded_number.PadLeft(total_chars);
  out_of := padded_number + OUT_OF_SLASH + total_episodes;
  episode_filename := FrssPodcast.getFilenameByIndex(file_number);
  Result := out_of + ' ' + episode_filename + ' ';
end;

function TConsolePodcast.parsePodcast(url_or_file, program_path: string): integer;
var
  number_episodes: integer;
begin
  FrssPodcast := TRssPodcast.Create();
  number_episodes := FrssPodcast.readPodcast(url_or_file, program_path, @DoOnConsoleReadPodcast, @DoOnFailedConsoleReadPodcast);
  FNumberEpisodes := FrssPodcast.numberEpisodes();
  podcastDetails();
  Result := number_episodes;
end;

function TConsolePodcast.getFailed(): string;
begin
  Result := FFailedFiles;
end;

function TConsolePodcast.readTheEpisodes(url_or_file, program_path: string): boolean;
var
  failedFiles: TStringList;
begin
  try
    failedFiles := nil;
    FrssPodcast.markAllDownload();
    failedFiles := FrssPodcast.downloadChosen(@DoOnConsoleWriteEpisode, @DoOnFailedConsoleReadEpisode,
      url_or_file, FDeskDownloadDir, program_path);
    FFailedFiles := consolePrintFailures(failedFiles);
    FreeAndNil(failedFiles);
    Result := FAtLeastOneFile;
  except
    raise;
  end;
end;

procedure TConsolePodcast.processPodcast(url_or_file, program_path: string);
var
  at_least_one_file: boolean;
  failure_list: string;
  number_episodes: integer;
begin
  try
    number_episodes := parsePodcast(url_or_file, program_path);
    if number_episodes = 0 then
    begin
      FCurrentRow := FCurrentRow + 2;
      writeRow(FCurrentRow, 'No podcast episodes found');
    end
    else
    begin
      FCurrentRow := FIRST_EPISODE_CONSOL_ROW;
      at_least_one_file := readTheEpisodes(url_or_file, program_path);
      if not at_least_one_file then
      begin
        FCurrentRow := FCurrentRow + 1;
        writeRow(FCurrentRow, 'No new episodes to download');
      end;
      failure_list := getFailed();
      if failure_list <> '' then
      begin
        FCurrentRow := FCurrentRow + 1;
        writeRow(FCurrentRow, 'Failed Episodes:');
        writeRow(FCurrentRow + 1, failure_list);
        writeRow(FCurrentRow + 3, 'Destination Folder : ' + FDeskDownloadDir);
      end;
    end;
  except
    raise;
  end;
end;

function TConsolePodcast.getPodcastUrl(test_podcast_url: string): string;
var
  url_or_file: string;
begin
  if test_podcast_url = '' then
  begin
    writeRow(ENTER_POD_URL_CONSOL_ROW, 'Enter Podcast URL : ');
    readln(url_or_file);
  end
  else
  begin
    url_or_file := test_podcast_url;
    writeRow(ENTER_POD_URL_CONSOL_ROW, 'Enter Podcast URL : ' + url_or_file);
  end;
  FDeskDownloadDir := deskDirName(url_or_file);
  Result := url_or_file;
end;

function readAPodcast(test_podcast_url: string = ''): string;
var
  podcast_backup: TConsolePodcast;
  url_or_file, program_path, console_lines: string;
begin
  try
    console_lines := '';
    podcast_backup := TConsolePodcast.Create();
    consoleClearScreen(' ');
    podcast_backup.writeRow(INTRODUCTION_CONSOL_ROW,
      'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.');
    podcast_backup.writeRow(EG_NASA_CONSOL_ROW, '  e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss');
    url_or_file := podcast_backup.getPodcastUrl(test_podcast_url);
    program_path := consoleProgramPath();
    podcast_backup.processPodcast(url_or_file, program_path);
    console_lines := podcast_backup.getConsolLines();
  finally
    FreeAndNil(podcast_backup);
  end;
  Result := Trim(console_lines);
end;

procedure TConsolePodcast.writeRow(row_y: integer; row_str: string);
var
  chopped_str: string;
begin
  chopped_str := consoleWriteStr(row_y, row_str);
  FConsolLines[row_y] := chopped_str;
end;

procedure TConsolePodcast.DoOnConsoleWriteEpisode(Sender: TObject; APosition: int64; file_number: integer);
var
  file_size, my_line: string;
  episode_filename, total_episodes, unpadded_number, padded_number, out_of: string;
  total_chars: integer;
begin
  file_size := mbFileSize(APosition);

  FAtLeastOneFile := True;

  consoleQuitOnKey(ESCAPE_KEY);
  total_episodes := IntToStr(FNumberEpisodes);
  total_chars := Length(total_episodes);
  unpadded_number := IntToStr(file_number + 1);
  padded_number := unpadded_number.PadLeft(total_chars);
  out_of := padded_number + OUT_OF_SLASH + total_episodes;
  episode_filename := FrssPodcast.getFilenameByIndex(file_number);
  my_line := out_of + ' : ' + file_size + ' : ' + episode_filename + '   ';
  FCurrentRow := FIRST_EPISODE_CONSOL_ROW + file_number;
  writeRow(FCurrentRow, my_line);
end;

procedure TConsolePodcast.DoOnConsoleReadPodcast(Sender: TObject; APosition: int64; fileNumber: integer);
var
  file_size, size_line: string;
  {$push}{$warn 5024 off}// fileNumber not used
begin
  consoleQuitOnKey(ESCAPE_KEY);
  file_size := mbFileSize(APosition);
  size_line := ' Podcast File Size : ' + file_size + '   ';
  writeRow(PODCAST_BYTES_CONSOL_ROW, size_line);

end;

  {$pop}

procedure TConsolePodcast.DoOnFailedConsoleReadPodcast(Sender: TObject; mediaUrl: string);
    {$push}{$warn 5024 off}// mediaUrl not used
begin
  // no memFailedFiles.Lines.Add(e_message + ' ' + mediaUrl);
end;

  {$pop}

procedure TConsolePodcast.DoOnFailedConsoleReadEpisode(Sender: TObject; mediaUrl: string);
    {$push}{$warn 5024 off}// mediaUrl not used
begin
  // no memFailedFiles.Lines.Add(e_message + ' ' + mediaUrl);
end;

  {$pop}

procedure TConsolePodcast.podcastDetails();
var
  podcast_title, podcast_description, number_episodes: string;
  desk_top_fname, the_desktop: string;
begin
  podcast_title := FrssPodcast.getTitle();
  podcast_description := FrssPodcast.getDescription();
  number_episodes := IntToStr(FrssPodcast.numberEpisodes());
  desk_top_fname := ExcludeTrailingBackslash(FDeskDownloadDir);
  the_desktop := 'THE_DESKTOP--' + ExtractFileName(desk_top_fname);
  writeRow(PODCAST_TITLE_CONSOL_ROW, '     Podcast Title : ' + podcast_title);
  writeRow(PODCAST_DESC_CONSOL_ROW, '       Description : ' + podcast_description);
  writeRow(NUM_EPISODES_CONSOL_ROW, '          Episodes : ' + number_episodes);
  writeRow(DEST_FOLDER_CONSOL_ROW, 'Destination Folder : ' + the_desktop);
  FCurrentRow := DEST_FOLDER_CONSOL_ROW;
end;

end.
