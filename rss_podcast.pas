unit rss_podcast;

{$mode objfpc}{$H+}

interface

uses

 {$IFDEF ALLOW_GUI_STATE}
  gui_state,
 {$ENDIF}
  {$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,                  // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils, RegExpr, HTTPDefs, lazstringutils,
  LazFileUtils,
  xml_episode,
 fgl,
  progress_stream;


type
  Tfilename_to_count = specialize TFPGmap<string, integer>;

  TBooleanArray = array of boolean;

  TRssPodcast = class(TObject)
  private
    FPodcastXmlText: string;
    FNumberItems: integer;
    FXmlEpisodes: TXmlEpisodes;
    FMediaWillBeDownloaded: TBooleanArray;
    FSuccessfuls: integer;
    FNumToDownload: integer;
    FPodcastTitle: string;
    FPodcastDescription: string;
    FSaveDirectory: string;
    FDuplicateFilenames: boolean;
  protected
    function getOnlinePodcast(episode_index: integer; DoOnWriteEpisode_3: TOnWriteStream;
      DoOnFailedReadEpisode_2: TOnFailedReadEpisode): string;
    function readLocalPodcast(episode_index: integer; DoOnWriteEpisode_3: TOnWriteStream; program_path: string): string;
    function numChecked(): integer;
    procedure makeEpisodeDirectory(url_or_file, the_save_directory, xmlData: string);
  public
    constructor Create();
    destructor Destroy; override;
    function getFilenameByIndex(episode_index: integer): string;
    function setCheckClick(itemNumber: integer; isChecked: boolean): int64;
    function filterCheckboxes(theFilter: string; mark_download: boolean): TBooleanArray;
    function amountToDownload(): int64;
    function readPodcast(url_or_file, program_path: string; DoOnWriteEpisode_3: TOnWriteStream;
      DoOnFailedReadPodcast_2: TOnFailedReadPodcast): integer;
    function getDescription(): string;
    function getTitle(): string;
    function getSuccesses(): integer;
    function numberEpisodes(): integer;
    function anEpisodeOfPodcast(episode_index: integer): TXmlEpisode;
    function downloadChosen(DoOnWriteEpisode_3: TOnWriteStream; DoOnFailedReadEpisode_2: TOnFailedReadEpisode;
      url_or_file, the_save_directory, program_path: string): TStringList;
    procedure markAllDownload();
    function identicalNamesFix(filename: string; episode_index: integer): string;
    function getIthOfSearch(search_text: string; ith_search_index: integer): integer;
    function getWantedDownloads(): integer;
  end;

function deleteComments(itemNode: string): string;
function lineBreakStringList(line_break: string; xml_text: string = ''): TStringList;

implementation

uses
 Forms,
  consts_types,
  download_stream,
  dirs_files;

function TRssPodcast.getFilenameByIndex(episode_index: integer): string;
var
  episode_filename: string;
  myXmlRec: TXmlEpisode;
begin
  myXmlRec := FXmlEpisodes[episode_index];
  episode_filename := myXmlRec.theEpisodeFilename();
  Result := episode_filename;
end;

function lineBreakStringList(line_break: string; xml_text: string = ''): TStringList;
var
  MyStringList: TStringList;
begin
  MyStringList := TStringList.Create();
  MyStringList.LineBreak := line_break;
  MyStringList.StrictDelimiter := True;
  if xml_text <> '' then
    MyStringList.Text := xml_text;
  Result := MyStringList;
end;

constructor TRssPodcast.Create();
begin
  inherited Create;
end;

function getEpisodeItems(xmlFile: string): TStringList;
var
  MyStringList: TStringList;
begin
  MyStringList := lineBreakStringList(LINE_BREAK_ON_XML_ITEM, xmlFile);
  MyStringList.Delete(0);
  Result := MyStringList;
end;

function getRssTitleDesc(xmlFile: string): string;
var
  MyStringList: TStringList;
  podcastIntro: string;
begin
  try
    MyStringList := lineBreakStringList(LINE_BREAK_ON_XML_ITEM, xmlFile);
    podcastIntro := MyStringList[0];
    Result := podcastIntro;
  finally
    MyStringList.Free;
  end;
end;

function TRssPodcast.getTitle(): string;
begin
  Result := FPodcastTitle;
end;

function TRssPodcast.getDescription(): string;
begin
  Result := FPodcastDescription;
end;

procedure TRssPodcast.makeEpisodeDirectory(url_or_file, the_save_directory, xmlData: string);
var
  xml_copy: string;
  F: TextFile;
begin
  CreateDir(the_save_directory);
  FSaveDirectory := the_save_directory;
  xml_copy := the_save_directory + fileDirName(url_or_file);
  AssignFile(F, xml_copy);
  Rewrite(F);
  WriteLn(F, xmlData);
  CloseFile(F);
end;

function TRssPodcast.numChecked(): integer;
var
  episode_index, checkCount: integer;
  isChecked: boolean;
begin
  checkCount := 0;
  for episode_index := 0 to FNumberItems - 1 do
  begin
    isChecked := FMediaWillBeDownloaded[episode_index];
    if isChecked then
      checkCount := checkCount + 1;
  end;
  Result := checkCount;
end;

function TRssPodcast.getSuccesses(): integer;
begin
  Result := FSuccessfuls;
end;


function localCopyAnEpisode(local_relative_episode_path, the_save_directory, fileName, program_path: string): boolean;
var
  app_path, absolute_path, realPathname: string;
  read_episode_file, write_episode_file: TFileStream;
begin
  app_path := program_path;
  absolute_path := app_path + local_relative_episode_path;
  read_episode_file := TFileStream.Create(absolute_path, fmOpenRead);
  Result := True;
  try
    realPathname := the_save_directory + PathDelim + fileName;
    if FileExists(realPathname) then
      Result := False
    else
      try
        write_episode_file := TFileStream.Create(realPathname, fmOpenWrite or fmCreate);
        write_episode_file.CopyFrom(read_episode_file, read_episode_file.Size);
      finally
        write_episode_file.Free;
      end
  finally
    read_episode_file.Free;
  end;
end;

function TRssPodcast.anEpisodeOfPodcast(episode_index: integer): TXmlEpisode;
var
  the_episode: TXmlEpisode;
begin
  the_episode := FXmlEpisodes[episode_index];
  Result := the_episode;
end;

function TRssPodcast.numberEpisodes(): integer;
begin
  Result := FNumberItems;
end;



{
 </image>
<!--

     <item>
        <title>#xxx: Title</title>
        <link>http://www.thisamericanlife.org/radio-archives/episode/xxx</link>
        <author>Chicago Public Media</author>
        <enclosure type="audio/mpeg" length="nnnn" url="http://audio.thisamericanlife.org/jomamashouse/ismymamashouse/xxx.mp3" />
        <guid isPermaLink="true">http://www.thisamericanlife.org/radio-archives/episode/xxx</guid>
        <pubDate>Fri, dd mmm yyyy 00:00:00 GMT</pubDate>
        <description>Description</description>
     </item>
-->
<item>
}

function deleteComments(itemNode: string): string;
var
  MyStringList, str2: TStringList;
  accum, Next, good: string;
  episode_index: integer;
begin
  str2 := lineBreakStringList(END_HTML_COMMENT);
  MyStringList := lineBreakStringList(START_HTML_COMMENT);
  MyStringList.Text := itemNode;
  accum := MyStringList[0];
  for episode_index := 1 to MyStringList.Count - 1 do
  begin
    Next := MyStringList[episode_index];
    str2.Text := Next;
    good := str2[1];
    accum := accum + good;
  end;
  MyStringList.Free();
  str2.Free();
  Result := accum;
end;

procedure TRssPodcast.markAllDownload();
var
  episode_index: integer;
begin
  for episode_index := 0 to FNumberItems - 1 do
  begin
    FMediaWillBeDownloaded[episode_index] := True;
  end;
end;


destructor TRssPodcast.Destroy;
var
  episode_index: integer;
  myXmlRec: TXmlEpisode;
begin
  for episode_index := 0 to FNumberItems - 1 do
  begin
    myXmlRec := FXmlEpisodes[episode_index];
    myXmlRec.Free();
  end;
  inherited Destroy;
end;

function TRssPodcast.getIthOfSearch(search_text: string; ith_search_index: integer): integer;
var
  episode_index, ith_scan_index: integer;
  myXmlRec: TXmlEpisode;
begin
  Result := 0;
  ith_scan_index := 0;
  for episode_index := 0 to FNumberItems - 1 do
  begin
    myXmlRec := FXmlEpisodes[episode_index];
    if myXmlRec.containsSearch(search_text) then
    begin
      if ith_scan_index = ith_search_index then
        Result := episode_index;
      ith_scan_index := ith_scan_index + 1;
    end;
  end;
end;



function TRssPodcast.downloadChosen(DoOnWriteEpisode_3: TOnWriteStream; DoOnFailedReadEpisode_2: TOnFailedReadEpisode;
  url_or_file, the_save_directory, program_path: string): TStringList;
var
  episode_index: integer;
  curUrl, failUrl: string;
  an_episode: TXmlEpisode;
  failed_episodes: TStringList;
begin
  failed_episodes := TStringList.Create();
  try
    makeEpisodeDirectory(url_or_file, the_save_directory, FPodcastXmlText);
    FSuccessfuls := 0;
    for episode_index := 0 to FNumberItems - 1 do
    begin
      an_episode := FXmlEpisodes[episode_index];
      if an_episode.isValidDownload() and FMediaWillBeDownloaded[episode_index] then
      begin
        curUrl := an_episode.theEpisodeUrl();
        if isOnlinePodcast(curUrl) then
          failUrl := getOnlinePodcast(episode_index, DoOnWriteEpisode_3, DoOnFailedReadEpisode_2)
        else
          failUrl := readLocalPodcast(episode_index, DoOnWriteEpisode_3, program_path);
        if failUrl <> '' then
          failed_episodes.Add(curUrl);
      end;
    end;
  except
    on E: ECancelException do
    begin
      failed_episodes.Free();
      raise;
    end;
  end;
  Result := failed_episodes;
end;



function TRssPodcast.getWantedDownloads(): integer;
begin
  Result := FNumToDownload;
end;

function TRssPodcast.getOnlinePodcast(episode_index: integer; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadEpisode_2: TOnFailedReadEpisode): string;
var
  filename, non_dup_filename, curUrl: string;
  an_episode: TXmlEpisode;
begin
  Result := '';
  an_episode := FXmlEpisodes[episode_index];
  curUrl := an_episode.theEpisodeUrl();
  filename := an_episode.theEpisodeFilename;
  non_dup_filename := identicalNamesFix(filename, episode_index);
  FMediaWillBeDownloaded[episode_index] := False;
  try
    downloadAnEpisode(curUrl, FSaveDirectory, non_dup_filename, episode_index, DoOnWriteEpisode_3, DoOnFailedReadEpisode_2);
    FSuccessfuls := FSuccessfuls + 1;
  except
    on E: ECancelException do
      raise;
    else
      Result := curUrl;
  end;
end;

function TRssPodcast.readLocalPodcast(episode_index: integer; DoOnWriteEpisode_3: TOnWriteStream; program_path: string): string;
var
  filename, non_dup_filename, curUrl: string;
  an_episode: TXmlEpisode;
  fileSize: integer;
  did_write_to_file: boolean;
begin
  Result := '';
  an_episode := FXmlEpisodes[episode_index];
  filename := an_episode.theEpisodeFilename;
  non_dup_filename := identicalNamesFix(filename, episode_index);
  FMediaWillBeDownloaded[episode_index] := False;
  try
    fileSize := an_episode.bytesInEpisode();
    curUrl := an_episode.theEpisodeUrl();
    did_write_to_file := localCopyAnEpisode(curUrl, FSaveDirectory, non_dup_filename, program_path);
    if did_write_to_file then
    begin
      DoOnWriteEpisode_3(nil, fileSize, episode_index);       // THIS WILL SET FAtLeastOneFile    CORRECTLY
      FSuccessfuls := FSuccessfuls + 1;
    end
  except
    Result := curUrl;
  end;
end;


function TRssPodcast.amountToDownload(): int64;
var
  a, fileSize: integer;
  downloadAmount: int64;
  toDownload: boolean;
  xmlRec: TXmlEpisode;
begin
   //_d('TRssPodcast.amountToDownload STAET FNumToDownload=', FNumToDownload);
  downloadAmount := 0;
  FNumToDownload := 0;
  for a := 0 to FNumberItems - 1 do
  begin
    // q*bert
    toDownload := FMediaWillBeDownloaded[a];
    if toDownload then
    begin
      xmlRec := FXmlEpisodes[a];
      fileSize := xmlRec.bytesInEpisode();
      downloadAmount := downloadAmount + fileSize;
      FNumToDownload := FNumToDownload + 1;
    end;
  end;
    // _d('TRssPodcast.amountToDownload END FNumToDownload=', FNumToDownload);
  Result := downloadAmount;
end;


function TRssPodcast.setCheckClick(itemNumber: integer; isChecked: boolean): int64;
begin
  FMediaWillBeDownloaded[itemNumber] := isChecked;
  Result := amountToDownload();
end;

function TRssPodcast.filterCheckboxes(theFilter: string; mark_download: boolean): TBooleanArray;
var
  episode_index: integer;
  downloadItem: boolean;
  already_downloading:boolean;
  xmlRec: TXmlEpisode;
 color_text_matches: TBooleanArray;
begin
  // _sb('TRssPodcast.filterCheckboxes START FNumToDownload=', FMediaWillBeDownloaded);
  SetLength(color_text_matches, FNumberItems);
  for episode_index := 0 to FNumberItems - 1 do
  begin
    xmlRec := FXmlEpisodes[episode_index];
    downloadItem := xmlRec.containsSearch(theFilter);
    color_text_matches[episode_index] := downloadItem;
    already_downloading :=  FMediaWillBeDownloaded[episode_index];
    if mark_download AND NOT already_downloading then
      FMediaWillBeDownloaded[episode_index] := downloadItem;
    end;
   //  _sb('TRssPodcast.filterCheckboxes END FNumToDownload=', FMediaWillBeDownloaded);
  Result := color_text_matches;
end;


function TRssPodcast.identicalNamesFix(filename: string; episode_index: integer): string;
var
  filename_pieces: TStrings;
  add_number_pos: integer;
  extra_extension_num, non_dup_filename: string;
begin
  non_dup_filename := filename;
  filename_pieces := nil;
  try
    if FDuplicateFilenames then
    begin
      filename_pieces := SplitString(filename, '.');
      filename_pieces.LineBreak := '.';
      add_number_pos := filename_pieces.Count - 1;
      extra_extension_num := IntToStr(episode_index);
      filename_pieces.insert(add_number_pos, extra_extension_num);
      non_dup_filename := filename_pieces.Text;
    end;
  finally
    Result := non_dup_filename;
    filename_pieces.Free();
  end;
end;


function TRssPodcast.readPodcast(url_or_file, program_path: string; DoOnWriteEpisode_3: TOnWriteStream;
  DoOnFailedReadPodcast_2: TOnFailedReadPodcast): integer;
var
  episode_index, distinct_count: integer;
  myXmlRec: TXmlEpisode;
  itemStrs: TStringList;
  podcastIntro, xmlItem, commentedXml, episode_filename: string;
  file_names: TStringList;
begin
  inherited Create;
  commentedXml := urlOrTestFile(url_or_file, program_path, DoOnWriteEpisode_3, DoOnFailedReadPodcast_2);
  FPodcastXmlText := deleteComments(commentedXml);
  podcastIntro := getRssTitleDesc(FPodcastXmlText);
  ItemStrs := getEpisodeItems(FPodcastXmlText);
  FPodcastTitle := getPodcastTitle(podcastIntro);
  FPodcastDescription := getTheDesc(podcastIntro);
  FNumberItems := ItemStrs.Count;
  SetLength(FXmlEpisodes, FNumberItems);
  SetLength(FMediaWillBeDownloaded, FNumberItems);
  {$IFDEF ALLOW_GUI_STATE}
  mouseStartParseEpisodes();
  {$ENDIF}
  file_names := TStringList.Create();
  distinct_count :=0;
  for episode_index := 0 to FNumberItems - 1 do
  begin
    xmlItem := itemStrs[episode_index];
    myXmlRec := TXmlEpisode.Create(xmlItem);
    FXmlEpisodes[episode_index] := myXmlRec;
    FMediaWillBeDownloaded[episode_index] := False;
    episode_filename := myXmlRec.theEpisodeFilename();
    if episode_index < DUPLICATE_FNAME_CHECKS then
    begin
       distinct_count := distinct_count+1;
       if file_names.IndexOf(episode_filename) = -1 then
          file_names.Add(episode_filename);
    end;
    Application.ProcessMessages;
  end;
  if file_names.Count<>distinct_count then
     FDuplicateFilenames := true
  else
     FDuplicateFilenames := false;

  {$IFDEF ALLOW_GUI_STATE}
  mouseStopParseEpisodes();
  {$ENDIF}
  file_names.Free();
  itemStrs.Free();
  Result := FNumberItems;
end;




end.
