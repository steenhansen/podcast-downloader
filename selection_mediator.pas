unit selection_mediator;

{$mode objfpc}{$H+}

//   https://sourcemaking.com/design_patterns/mediator/php

interface

uses
  {$IFDEF ALLOW_GUI_STATE}
  gui_state,
  {$ENDIF}
  {$IfDef ALLOW_DEBUG_SERVER}
  // debug_server,             // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils,
  Forms,
  Graphics,
  Dialogs,
  StdCtrls,
  CheckLst,
  FileUtil, LCLIntf,
  Buttons,
  regexpr, LazFileUtils,
  BCMDButton,
  progress_stream, consts_types,
  rss_podcast, checks_descriptions;

type

  TSelectionMediator = class(TObject)
  private
    FTextFilter: string;
    Furl_or_file: string;
    FNumItems: integer;
    FrssPodcast: TRssPodcast;

    FcaptionSpacer:Double;
  public
    constructor Create(url_or_file: string);
    destructor Destroy; override;
    procedure checkedAllOfThem(clbEpisodeFiles: TCheckListBox; lbEpisodeDesc: TListBox);
    function clickedBoxNew(fileList: TCheckListBox; lbEpisodeDesc: TListBox; itemNumber: integer;
      btnDownloadChecked: TBCMDButton): integer;
    procedure checkedNoneOfThem(clbEpisodeFiles: TCheckListBox; lbEpisodeDesc: TListBox);
    function startDownloading(lbEpisodeDesc: TListBox; DoOnWriteEpisode_3: TOnWriteStream;
      DoOnFailedReadEpisode_2: TOnFailedReadEpisode; urlToRead, saveDir: string): TFailsAndSuccesses;
    function checkedCount(clbEpisodeFiles: TCheckListBox): integer;
    function addFilteredToDownload(filteredText: string; clbEpisodeFiles: TCheckListBox; lbEpisodeDesc: TListBox): integer;
    function showFilterMatch(clbEpisodeFiles: TCheckListBox; lbEpisodeTitle: TListBox; lbEpisodeDesc: TListBox;
      TEDITtextFilter: TEdit; downloadFiltered: TButton): integer;
    procedure readingMediaFile(clbEpisodeFiles: TCheckListBox; lbEpisodeTitle: TListBox; lbEpisodeDesc: TListBox;
      itemNumber: integer; fileSize: int64);
    procedure readingRss(g_podcast_form: TForm; fileSize: int64);
    function readRssFile(edtSaveDirectory: TEdit; g_podcast_form: TForm; lblPodcastDescription: TLabel;
      DoOnWriteEpisode_3: TOnWriteStream; DoOnFailedReadPodcast_2: TOnFailedReadPodcast): integer;
    function calcDownload(fileList: TCheckListBox; btnDownloadChecked: TBCMDButton): integer;
    function makeCheckList(clbEpisodeFiles: TCheckListBox; lbEpisodeTitle: TListBox; lbEpisodeDesc: TListBox;
      btnDownloadAll: TButton): integer;
    procedure displayDescription(episode_index, display_number: integer);
    function getSearchIndex(search_text: string; ith_search_index: integer): integer;
    function getSuccesses(): integer;
    function getWantedDownloads(): integer;
  published
  end;

function downloadCaption(checkedCount, totalFileSize: int64): string;

implementation

uses
  episode_bits,
  xml_episode,
  dirs_files;

function TSelectionMediator.checkedCount(clbEpisodeFiles: TCheckListBox): integer;
var
  a, checkedFileCount: integer;
begin
  checkedFileCount := 0;
  for a := 0 to FNumItems - 1 do
    if clbEpisodeFiles.Checked[a] then
      checkedFileCount := checkedFileCount + 1;
  Result := checkedFileCount;
end;

destructor TSelectionMediator.Destroy;
begin
  FreeAndNil(FrssPodcast);
  inherited Destroy;
end;

function downloadCaption(checkedCount, totalFileSize: int64): string;
var
  checkedCountStr, totalSizeStr, countedCaption: string;
begin
  if checkedCount = 0 then
    checkedCountStr := ''
  else
    checkedCountStr := IntToStr(checkedCount);
  if totalFileSize = 0 then
    totalSizeStr := ''
  else
    totalSizeStr := mbFileSize(totalFileSize);
  countedCaption := 'Download' + LINE_ENDING + checkedCountStr + ' Checked' + LINE_ENDING + 'Episodes' +
    LINE_ENDING + totalSizeStr + ' ';
  Result := countedCaption;
end;

constructor TSelectionMediator.Create(url_or_file: string);
begin
  inherited Create;
  FrssPodcast := nil;
  Furl_or_file := url_or_file;
  FcaptionSpacer :=0;
end;

procedure TSelectionMediator.checkedAllOfThem(clbEpisodeFiles: TCheckListBox; lbEpisodeDesc: TListBox);
var
  a: integer;
  myobj, newObj: TObject;
begin
  for a := 0 to FNumItems - 1 do
  begin
    clbEpisodeFiles.Checked[a] := True;
    FrssPodcast.setCheckClick(a, True);
    myobj := lbEpisodeDesc.items.Objects[a];
    newObj := encodeWillDownload(myobj);
    lbEpisodeDesc.items.Objects[a] := newObj;
  end;
end;





function TSelectionMediator.clickedBoxNew(fileList: TCheckListBox; lbEpisodeDesc: TListBox; itemNumber: integer;
  btnDownloadChecked: TBCMDButton): integer;
var
  isChecked: boolean;
  totalFileSize: int64;
  checkedFileCount: integer;
  a: integer;
  myobj: TObject;
  newObj: TObject;
begin
  isChecked := fileList.Checked[itemNumber];
  totalFileSize := FrssPodcast.setCheckClick(itemNumber, isChecked);
  checkedFileCount := 0;
  for a := 0 to FNumItems - 1 do
    if fileList.Checked[a] then
      checkedFileCount := checkedFileCount + 1;
  btnDownloadChecked.Caption := downloadCaption(checkedFileCount, totalFileSize);
  myobj := lbEpisodeDesc.items.Objects[itemNumber];
  newObj := encodeWillDownload(myobj);
  lbEpisodeDesc.items.Objects[itemNumber] := newObj;
  Result := totalFileSize;
end;

procedure TSelectionMediator.readingMediaFile(clbEpisodeFiles: TCheckListBox; lbEpisodeTitle: TListBox;
  lbEpisodeDesc: TListBox; itemNumber: integer; fileSize: int64);
var
  myobj: TObject;
  newObj, byteSizeObj: TObject;
begin
  myobj := lbEpisodeDesc.items.Objects[itemNumber];
  byteSizeObj := encodeFileByteSize(myobj, fileSize);
  newObj := encodeIsDownloading(byteSizeObj);
  lbEpisodeDesc.items.Objects[itemNumber] := newObj;
  lbEpisodeDesc.Invalidate;
  lbEpisodeDesc.TopIndex := itemNumber;
  clbEpisodeFiles.TopIndex := itemNumber;
  lbEpisodeTitle.TopIndex := itemNumber;
  lbEpisodeDesc.Invalidate;
  Application.ProcessMessages;
end;

function fileSizeAndDesc(theLength: integer; theDesc: string): string;
var
  lengthAndDesc, lengthSize: string;
begin
  lengthSize := mbFileSize(theLength);
  if lengthSize = '' then
    lengthAndDesc := NO_BYTE_SIZE_INDENT + theDesc
  else
    lengthAndDesc := lengthSize + ' - ' + theDesc;
  Result := lengthAndDesc;
end;

function TSelectionMediator.makeCheckList(clbEpisodeFiles: TCheckListBox; lbEpisodeTitle: TListBox;
  lbEpisodeDesc: TListBox; btnDownloadAll: TButton): integer;
var
  a, theLength: integer;
  theFile, theDescription, lengthAndDesc, episode_title: string;
  allFilesSize: integer;
  anEpisode: TXmlEpisode;
begin
  allFilesSize := 0;
  FNumItems := FrssPodcast.numberEpisodes();
  clbEpisodeFiles.Clear;
  lbEpisodeTitle.Clear;
  lbEpisodeDesc.Clear;
  clbEpisodeFiles.Items.BeginUpdate;
  lbEpisodeTitle.Items.BeginUpdate;
  lbEpisodeDesc.Items.BeginUpdate;
  for a := 0 to FNumItems - 1 do
  begin
    anEpisode := FrssPodcast.anEpisodeOfPodcast(a);
    episode_title := anEpisode.theEpisodeTitle();
    theLength := anEpisode.bytesInEpisode();
    theFile := anEpisode.theEpisodeFilename();
    theDescription := anEpisode.theEpisodeDescription();
    lengthAndDesc := fileSizeAndDesc(theLength, theDescription);
    clbEpisodeFiles.AddItem(theFile, nil);
    lbEpisodeTitle.Items.AddObject(episode_title, nil);
    lbEpisodeDesc.Items.AddObject(lengthAndDesc, TObject(IGNORE_FILE));
    allFilesSize := allFilesSize + theLength;
  end;
  clbEpisodeFiles.Items.EndUpdate;
  lbEpisodeTitle.Items.EndUpdate;
  lbEpisodeDesc.Items.EndUpdate;
  btnDownloadAll.Caption := 'Select All ' + IntToStr(FNumItems) + ' Episodes for Download';
  Result := allFilesSize;
end;

procedure reDrawEpisodeDescriptions(lbEpisodeDesc: TCustomListBox; topItem: integer);
begin
  lbEpisodeDesc.Visible := False;
  lbEpisodeDesc.Visible := True;
  lbEpisodeDesc.TopIndex := topItem;
end;

function TSelectionMediator.showFilterMatch(clbEpisodeFiles: TCheckListBox; lbEpisodeTitle: TListBox;
  lbEpisodeDesc: TListBox; TEDITtextFilter: TEdit; downloadFiltered: TButton): integer;
var
  a: integer;
  itemStates: TBooleanArray;
  textMatches: boolean;
  topItem: integer;
  filter_matches_count: integer;
  old_episode_object, new_episode_object: TObject;
begin
  FTextFilter := TEDITtextFilter.Text;
  itemStates := FrssPodcast.filterCheckboxes(FTextFilter, False);
  topItem := -1;
  filter_matches_count := 0;
  for a := 0 to FNumItems - 1 do
  begin
    textMatches := itemStates[a];
    if textMatches then
    begin
      filter_matches_count := filter_matches_count + 1;
      if topItem = -1 then
        topItem := a;
    end;
    old_episode_object := lbEpisodeDesc.items.Objects[a];
    new_episode_object := encodeFilterMatch(old_episode_object, textMatches);
    lbEpisodeDesc.items.Objects[a] := new_episode_object;
  end;
  downloadFiltered.Caption := 'Add ' + IntToStr(filter_matches_count) + ' Episodes Matching Search Text';
  reDrawEpisodeDescriptions(lbEpisodeDesc, topItem);
  reDrawEpisodeDescriptions(lbEpisodeTitle, topItem);
  reDrawEpisodeDescriptions(clbEpisodeFiles, topItem);
  clbEpisodeFiles.TopIndex := topItem;
  lbEpisodeTitle.TopIndex := topItem;
  Result := filter_matches_count;
end;

procedure TSelectionMediator.displayDescription(episode_index, display_number: integer);
var
  episode_desc, episode_filename, entire_message: string;
  index_str, filter_upper, filter_lower, episode_lower: string;
  podcast_episode: TXmlEpisode;
begin
  podcast_episode := FrssPodcast.anEpisodeOfPodcast(episode_index);
  episode_desc := podcast_episode.theEpisodeDescription();
  if podcast_episode.containsSearch(FTextFilter) then
  begin
    episode_lower := LowerCase(episode_desc);
    filter_lower := LowerCase(FTextFilter);
    filter_upper := UpperCase(FTextFilter);
    episode_desc := StringReplace(episode_lower, filter_lower, filter_upper, [rfReplaceAll, rfIgnoreCase]);
  end;
  episode_filename := podcast_episode.theEpisodeFilename();
  index_str := IntToStr(display_number);
  entire_message := '#' + index_str + ' - ' + episode_filename + LINE_ENDING + LINE_ENDING + episode_desc;
  ShowMessage(entire_message);
end;

function TSelectionMediator.startDownloading(lbEpisodeDesc: TListBox; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadEpisode_2: TOnFailedReadEpisode; urlToRead, saveDir: string): TFailsAndSuccesses;
var
  a: integer;
  failedFiles: TStringList;
  myobj, newObj: TObject;
  failsAndSuccesses: TFailsAndSuccesses;
  program_path: string;
begin
  failedFiles := nil;
  try
    try
      for a := 0 to FNumItems - 1 do
      begin
        myobj := lbEpisodeDesc.items.Objects[a];
        newObj := encodeDownloadingSelected(myobj);
        lbEpisodeDesc.items.Objects[a] := newObj;
      end;
      program_path := ExtractFilePath(Application.ExeName);
      failedFiles := FrssPodcast.downloadChosen(DoOnWriteEpisode_3, DoOnFailedReadEpisode_2, urlToRead, saveDir, program_path);
      failsAndSuccesses.failedCount := failedFiles.Count;
      failsAndSuccesses.successCount := FrssPodcast.getSuccesses();
    except
      failsAndSuccesses.failedCount := 0;
      failsAndSuccesses.successCount := 0;
    end;
    Result := failsAndSuccesses;
  finally
    FreeAndNil(failedFiles);
  end;
end;

function TSelectionMediator.readRssFile(edtSaveDirectory: TEdit; g_podcast_form: TForm; lblPodcastDescription: TLabel;
  DoOnWriteEpisode_3: TOnWriteStream; DoOnFailedReadPodcast_2: TOnFailedReadPodcast): integer;
var
  desktopDirPath: string;
  podcastTitle, podcastDescription: string;
  program_path: string;
  number_episodes: integer;
begin
  program_path := ExtractFilePath(Application.ExeName);
  FrssPodcast := TRssPodcast.Create();
  number_episodes := FrssPodcast.readPodcast(Furl_or_file, program_path, DoOnWriteEpisode_3, DoOnFailedReadPodcast_2);
  podcastDescription := FrssPodcast.getDescription();
  desktopDirPath := deskDirName(Furl_or_file);
  edtSaveDirectory.Text := desktopDirPath;
  podcastTitle := FrssPodcast.getTitle();
  g_podcast_form.Caption := podcastTitle;
  lblPodcastDescription.Caption := podcastDescription;
  Result := number_episodes;
end;

function TSelectionMediator.getSearchIndex(search_text: string; ith_search_index: integer): integer;
var
  ith_searched: integer;
begin
  ith_searched := FrssPodcast.getIthOfSearch(search_text, ith_search_index);
  Result := ith_searched;
end;

function TSelectionMediator.calcDownload(fileList: TCheckListBox; btnDownloadChecked: TBCMDButton): integer;
var
  totalFileSize: int64;
  checkedFileCount: integer;
  a: integer;
begin
  totalFileSize := FrssPodcast.amountToDownload();
  checkedFileCount := 0;
  for a := 0 to FNumItems - 1 do
    if fileList.Checked[a] then
      checkedFileCount := checkedFileCount + 1;
  btnDownloadChecked.Caption := downloadCaption(checkedFileCount, totalFileSize);
  Result := totalFileSize;
end;

procedure TSelectionMediator.checkedNoneOfThem(clbEpisodeFiles: TCheckListBox; lbEpisodeDesc: TListBox);
var
  i: integer;
  old_bits, new_bits: TObject;
begin
  for i := 0 to FNumItems - 1 do
  begin
    clbEpisodeFiles.Checked[i] := False;
    FrssPodcast.setCheckClick(i, False);
    old_bits := lbEpisodeDesc.Items.Objects[i];
    new_bits := encodeWillDownload(old_bits);
    lbEpisodeDesc.items.Objects[i] := new_bits;
  end;
end;

function TSelectionMediator.getSuccesses(): integer;
begin
  Result := FrssPodcast.getSuccesses();
end;

function TSelectionMediator.getWantedDownloads(): integer;
begin
  Result := FrssPodcast.getWantedDownloads();
end;





procedure TSelectionMediator.readingRss(g_podcast_form: TForm; fileSize: int64);
var
  file_str, size_indent, byte_part: string;
begin
  if fileSize <> 0 then
  begin
    file_str := IntToStr(fileSize);
    FcaptionSpacer := FcaptionSpacer+0.1;
    if FcaptionSpacer>200 then
       FcaptionSpacer :=0;
    size_indent := StringOfChar(' ', trunc(FcaptionSpacer));
    byte_part := size_indent + file_str + ' bytes read';
    {$IFDEF  ALLOW_GUI_STATE}
    mouseReadingUrl();
    {$ENDIF}
  end
  else
  begin
    byte_part := '';
  end;
  g_podcast_form.Caption := 'Podcast Downloader' + byte_part;
  Application.ProcessMessages;
end;

function TSelectionMediator.addFilteredToDownload(filteredText: string; clbEpisodeFiles: TCheckListBox; lbEpisodeDesc: TListBox): integer;
var
  itemStates: TBooleanArray;
  textMatches, already_downloading: boolean;
  a, checkedFileCount: integer;
  textFilter: string;
    myobj, newObj: TObject;
begin
  textFilter := filteredText;
  itemStates := FrssPodcast.filterCheckboxes(textFilter, True);
  checkedFileCount := 0;
  for a := 0 to FNumItems - 1 do
  begin
    textMatches := itemStates[a];
    myobj := lbEpisodeDesc.items.Objects[a];
    if textMatches then
    begin
      clbEpisodeFiles.Checked[a] := True;
      FrssPodcast.setCheckClick(a, True);
      newObj := encodeWillDownload(myobj);
      lbEpisodeDesc.items.Objects[a] := newObj;
      checkedFileCount := checkedFileCount + 1;
    end
    else
    begin
      already_downloading := decodeWillDownload(myobj);
      if already_downloading then
         checkedFileCount := checkedFileCount + 1;
    end
  end;
  Result := checkedFileCount;
end;


end.
