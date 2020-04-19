unit process_data;



{$mode objfpc}{$H+}

interface

uses
{$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,             // Can use SendDebug('my debug message') from dbugintf
{$ENDIF}
  Classes, SysUtils,
  Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, CheckLst, regexpr, LazFileUtils, lazlogger, BCMDButton,
  consts_types;

function process_a_podcast(podcast_file: string): integer;
function process_b_all(): integer;
function process_b_none(): integer;
function process_b_choices(index: integer; are_testing: boolean = False): integer;
function process_b_filter(filteredText: string): TCheckedAndTotalSize;
function process_c_episodes(podcast_file, saveDir: string): TFailsAndSuccesses;

implementation

uses
  rss_podcast, selection_mediator,
  dirs_files,
  form_events;

function process_a_podcast(podcast_file: string): integer;
var
  number_episodes: integer;
  totalFileSize: integer;
begin
  with PodcastForm do
  begin
    if fileSelectionMediator <> nil then
      fileSelectionMediator.Free();
    fileSelectionMediator := TSelectionMediator.Create(podcast_file);
    number_episodes := fileSelectionMediator.readRssFile(edtSaveDirectory, podcastForm, lblPodcastDescription,
      @DoOnReadPodcast, @DoOnFailedReadPodcast);
    totalFileSize := fileSelectionMediator.makeCheckList(clbEpisodeFiles, lbEpisodeTitle, lbEpisodeDesc, btnDownloadAll);
  end;
  if totalFileSize > 0 then
    Result := totalFileSize
  else
    Result := number_episodes;         // Since sffAudio PDFs have no file size we must do this hack.
end;

function process_b_all(): integer;
var
  fileSizeChecked: integer;
begin
  with PodcastForm do
  begin
    fileSelectionMediator.checkedAllOfThem(clbEpisodeFiles, lbEpisodeDesc);
    fileSizeChecked := fileSelectionMediator.calcDownload(clbEpisodeFiles, btnDownloadChecked);
  end;
  Result := fileSizeChecked;
end;

function process_b_none(): integer;
var
  fileSizeChecked: integer;
begin
  with PodcastForm do
  begin
    fileSelectionMediator.checkedNoneOfThem(clbEpisodeFiles, lbEpisodeDesc);
    fileSizeChecked := fileSelectionMediator.calcDownload(clbEpisodeFiles, btnDownloadChecked);
  end;
  Result := fileSizeChecked;
end;

function process_b_filter(filteredText: string): TCheckedAndTotalSize;
var
  fileSizeChecked, checkedFileCount: integer;
  checked_and_total_size: TCheckedAndTotalSize;
begin
  with PodcastForm do
  begin
    checkedFileCount := fileSelectionMediator.addFilteredToDownload(filteredText, clbEpisodeFiles);
    fileSizeChecked := fileSelectionMediator.calcDownload(clbEpisodeFiles, btnDownloadChecked);
  end;
  checked_and_total_size.checkedFileCount := checkedFileCount;
  checked_and_total_size.fileSizeChecked := fileSizeChecked;
  Result := checked_and_total_size;
end;

function process_b_choices(index: integer; are_testing: boolean = False): integer;
var
  totalFileSize: integer;
begin
  with PodcastForm do
  begin
    if are_testing then
      clbEpisodeFiles.Checked[Index] := not clbEpisodeFiles.Checked[Index];
    totalFileSize := fileSelectionMediator.clickedBoxNew(clbEpisodeFiles, lbEpisodeDesc, Index, btnDownloadChecked);
  end;
  Result := totalFileSize;
end;

function process_c_episodes(podcast_file, saveDir: string): TFailsAndSuccesses;
var
  failsAndSuccesses: TFailsAndSuccesses;
begin
  if saveDir = '' then
    saveDir := deskDirName(podcast_file);
  with PodcastForm do
  begin
    failsAndSuccesses := fileSelectionMediator.startDownloading(lbEpisodeDesc, @DoOnWriteEpisode, @DoOnFailedReadEpisode, podcast_file, saveDir);
  end;
  Result := failsAndSuccesses;
end;


end.
