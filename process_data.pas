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
function process_b_index_of_filter(search_text: string; ith_search_index: integer): integer;
function process_c_episodes(podcast_file, saveDir: string): TFailsAndSuccesses;

implementation

uses
  selection_mediator,
  dirs_files,
  form_podcast_4;

function process_a_podcast(podcast_file: string): integer;
var
  number_episodes: integer;
  totalFileSize: integer;
begin
  with g_podcast_form do
  begin
    if g_selection_mediator <> nil then
      g_selection_mediator.Free();
    g_selection_mediator := TSelectionMediator.Create(podcast_file);
    number_episodes := g_selection_mediator.readRssFile(edtSaveDirectory, g_podcast_form, lblPodcastDescription,
      @DoOnReadPodcast_2, @DoOnFailedReadPodcast_2);
    totalFileSize := g_selection_mediator.makeCheckList(clbEpisodeFiles, lbEpisodeTitle, lbEpisodeDesc, btnDownloadAll);
  end;
  if totalFileSize > 0 then
    Result := totalFileSize
  else
    Result := number_episodes;         // Since sffAudio PDFs have no file size we must do this hack.
end;

function process_b_none(): integer;
var
  fileSizeChecked: integer;
begin
  with g_podcast_form do
  begin
    g_selection_mediator.checkedNoneOfThem(clbEpisodeFiles, lbEpisodeDesc);
    fileSizeChecked := g_selection_mediator.calcDownload(clbEpisodeFiles, btnDownloadChecked);
  end;
  Result := fileSizeChecked;
end;

function process_b_choices(index: integer; are_testing: boolean = False): integer;
var
  totalFileSize: integer;
begin
  with g_podcast_form do
  begin
    if are_testing then
      clbEpisodeFiles.Checked[Index] := not clbEpisodeFiles.Checked[Index];
    totalFileSize := g_selection_mediator.clickedBoxNew(clbEpisodeFiles, lbEpisodeDesc, Index, btnDownloadChecked);
  end;
  Result := totalFileSize;
end;

function process_c_episodes(podcast_file, saveDir: string): TFailsAndSuccesses;
var
  failsAndSuccesses: TFailsAndSuccesses;
begin
  if saveDir = '' then
    saveDir := deskDirName(podcast_file);
  with g_podcast_form do
  begin
    failsAndSuccesses := g_selection_mediator.startDownloading(lbEpisodeDesc, @DoOnWriteEpisode_3,
      @DoOnFailedReadEpisode_2, podcast_file, saveDir);
  end;
  Result := failsAndSuccesses;
end;

function process_b_filter(filteredText: string): TCheckedAndTotalSize;
var
  fileSizeChecked, checkedFileCount: integer;
  checked_and_total_size: TCheckedAndTotalSize;
begin
  with g_podcast_form do
  begin
    checkedFileCount := g_selection_mediator.addFilteredToDownload(filteredText, clbEpisodeFiles, lbEpisodeDesc);
    fileSizeChecked := g_selection_mediator.calcDownload(clbEpisodeFiles, btnDownloadChecked);
  end;
  checked_and_total_size.checkedFileCount := checkedFileCount;
  checked_and_total_size.fileSizeChecked := fileSizeChecked;
  Result := checked_and_total_size;
end;

function process_b_index_of_filter(search_text: string; ith_search_index: integer): integer;
var
  index_of_filter: integer;
begin
  index_of_filter := g_selection_mediator.getSearchIndex(search_text, ith_search_index);
  Result := index_of_filter;
end;

function process_b_all(): integer;
var
  fileSizeChecked: integer;
begin
  with g_podcast_form do
  begin
    g_selection_mediator.checkedAllOfThem(clbEpisodeFiles, lbEpisodeDesc);
    fileSizeChecked := g_selection_mediator.calcDownload(clbEpisodeFiles, btnDownloadChecked);
  end;
  Result := fileSizeChecked;
end;

end.
