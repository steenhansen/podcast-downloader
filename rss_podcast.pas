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
  Classes, SysUtils,  RegExpr,  HTTPDefs,



   LazFileUtils,
  xml_episode ,
  progress_stream  ;

const
  LINE_BREAK_ON_XML_ITEM = '<item';
  END_HTML_COMMENT = '-->';
  START_HTML_COMMENT = '<!--';
  START_CDATA = '<![CDATA[';
  END_CDATA = ']]>';


var
  G_start_stop: string;

type
  TBooleanArray = array of boolean;

  TRssPodcast = class(TObject)
  private
    FPodcastXmlText: string;
    FNumberItems: integer;
    FXmlEpisodes: TXmlEpisodes;
    FMediaWillBeDownloaded: TBooleanArray;
    FSuccessfuls: integer;
    FPodcastTitle: string;
    FPodcastDescription: string;
    FSaveDirectory: string;


  protected
    function getOnlinePodcast(episode_index: integer; formCallback: TOnWriteStream;DoOnFailedReadEpisode:TOnFailedReadEpisode): string;
    function readLocalPodcast(episode_index: integer; formCallback: TOnWriteStream;program_path: string): string;




    function numChecked(): integer;





    procedure makeEpisodeDirectory(url_or_file, the_save_directory, xmlData: string);
  public
    constructor Create();
    destructor Destroy; override;
    function getFilenameByIndex(episode_index: integer): string;
    function setCheckClick(itemNumber: integer; isChecked: boolean): int64;
    function filterCheckboxes(theFilter: string; mark_download: boolean): TBooleanArray;
    function amountToDownload(): int64;
    function readPodcast(url_or_file, program_path: string; formCallback: TOnWriteStream; DoOnFailedReadPodcast:TOnFailedReadPodcast):integer;
    function getDescription(): string;
    function getTitle(): string;
    function getSuccesses(): integer;
    function numberEpisodes(): integer;
    function anEpisodeOfPodcast(episode_index: integer): TXmlEpisode;
    function downloadChosen(formCallback: TOnWriteStream; DoOnFailedReadEpisode:TOnFailedReadEpisode; url_or_file, the_save_directory, program_path: string): TStringList;
         procedure markAllDownload();
  end;


function deleteComments(itemNode: string): string;
function lineBreakStringList(line_break: string; xml_text: string = ''): TStringList;



implementation
  uses
     consts_types,
  download_stream,
  dirs_files  ;


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

function TRssPodcast.setCheckClick(itemNumber: integer; isChecked: boolean): int64;
begin
  FMediaWillBeDownloaded[itemNumber] := isChecked;
  Result := amountToDownload();
end;

function TRssPodcast.amountToDownload(): int64;
var
  a, fileSize: integer;
  downloadAmount: int64;
  toDownload: boolean;
  xmlRec: TXmlEpisode;
begin
  downloadAmount := 0;
  for a := 0 to FNumberItems - 1 do
  begin
    toDownload := FMediaWillBeDownloaded[a];
    if toDownload then
    begin
      xmlRec := FXmlEpisodes[a];
      fileSize := xmlRec.bytesInEpisode();
      downloadAmount := downloadAmount + fileSize;
    end;
  end;
  Result := downloadAmount;
end;

function localCopyAnEpisode(local_relative_episode_path, the_save_directory, fileName, program_path: string):Boolean;
var
  app_path, absolute_path, realPathname: string;
  read_episode_file, write_episode_file: TFileStream;
begin
  app_path := program_path;
  absolute_path := app_path + local_relative_episode_path;
  read_episode_file := TFileStream.Create(absolute_path, fmOpenRead);
  Result:=true;
  try
    realPathname := the_save_directory + PathDelim + fileName;
    IF FileExists(realPathname) THEN
      Result:=false
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




function TRssPodcast.filterCheckboxes(theFilter: string; mark_download: boolean): TBooleanArray;
var
  episode_index: integer;
  downloadItem: boolean;
  xmlRec: TXmlEpisode;
  itemStates: TBooleanArray;
begin
  SetLength(itemStates, FNumberItems);
  for episode_index := 0 to FNumberItems - 1 do
  begin
    xmlRec := FXmlEpisodes[episode_index];
    downloadItem := xmlRec.containsSearch(theFilter);
    if mark_download then
      FMediaWillBeDownloaded[episode_index] := downloadItem;
    itemStates[episode_index] := downloadItem;
  end;
  Result := itemStates;
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




  // getOnlineEpisode
function TRssPodcast.getOnlinePodcast(episode_index: integer; formCallback: TOnWriteStream; DoOnFailedReadEpisode:TOnFailedReadEpisode): string;
var
  filename, curUrl: string;
  an_episode: TXmlEpisode;
begin
  Result := '';
  an_episode := FXmlEpisodes[episode_index];
  curUrl := an_episode.theEpisodeUrl();
  filename := an_episode.theEpisodeFilename;
  FMediaWillBeDownloaded[episode_index] := False;
  try
    downloadAnEpisode(curUrl, FSaveDirectory, filename, episode_index, formCallback, DoOnFailedReadEpisode);
    FSuccessfuls := FSuccessfuls + 1;
  except
    on E: ECancelException do
      raise;
    else
      Result := curUrl;
  end;
end;

// readLocalEpisode
function TRssPodcast.readLocalPodcast(episode_index: integer; formCallback: TOnWriteStream; program_path: string): string;
var
  filename, curUrl: string;
  an_episode: TXmlEpisode;
  fileSize: integer;
  did_write_to_file:boolean;
begin
  Result := '';
  an_episode := FXmlEpisodes[episode_index];
  filename := an_episode.theEpisodeFilename;
  FMediaWillBeDownloaded[episode_index] := False;
  try
    fileSize := an_episode.bytesInEpisode();
    curUrl := an_episode.theEpisodeUrl();
    did_write_to_file := localCopyAnEpisode(curUrl, FSaveDirectory, fileName, program_path);
    if did_write_to_file then
      begin
         formCallback(nil, fileSize, episode_index);       // THIS WILL SET FAtLeastOneFile    CORRECTLY
         FSuccessfuls := FSuccessfuls + 1;
      end
  except
    Result := curUrl;
  end;
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






 

function TRssPodcast.downloadChosen(formCallback: TOnWriteStream; DoOnFailedReadEpisode:TOnFailedReadEpisode; url_or_file, the_save_directory, program_path: string): TStringList;
var
  episode_index: integer;
  curUrl, failUrl: string;
  an_episode: TXmlEpisode;
  failed_episodes: TStringList;
begin
  //try
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
          failUrl := getOnlinePodcast(episode_index, formCallback,DoOnFailedReadEpisode)
        else
          failUrl := readLocalPodcast(episode_index, formCallback, program_path);
        if failUrl <> '' then
          failed_episodes.Add(curUrl);
      end;
     // podcastForm.Caption := 'Downloading ' + intToStr(episode_index+1) + '/' + intToStr(FNumberItems);
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



     function TRssPodcast.readPodcast(url_or_file, program_path: string; formCallback: TOnWriteStream; DoOnFailedReadPodcast:TOnFailedReadPodcast):integer;
var
  episode_index: integer;
  myXmlRec: TXmlEpisode;
  itemStrs: TStringList;
  podcastIntro, xmlItem, commentedXml: string;
begin
  inherited Create;
  commentedXml := urlOrTestFile(url_or_file, program_path, formCallback, DoOnFailedReadPodcast);
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
  for episode_index := 0 to FNumberItems - 1 do
  begin
    xmlItem := itemStrs[episode_index];
    myXmlRec := TXmlEpisode.Create(xmlItem);
    FXmlEpisodes[episode_index] := myXmlRec;
    FMediaWillBeDownloaded[episode_index] := False;
  end;
  {$IFDEF ALLOW_GUI_STATE}
  mouseStopParseEpisodes();
{$ENDIF}
  itemStrs.Free();
Result:=  FNumberItems;
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


end.
