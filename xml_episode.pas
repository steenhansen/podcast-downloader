unit xml_episode;

{$mode objfpc}{$H+}

///  https://regex.sorokin.engineer/en/latest/regular_expressions.html

interface

uses

  {$IfDef ALLOW_DEBUG_SERVER}
   //debug_server,                     // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  strUtils, HTTPDefs, Classes, SysUtils, regexpr,
  consts_types;

const

  DESC_CDATA_REGEX = '<description[^>]*>(.*)</description>';
  TITLE_CDATA_REGEX = '<title[^>]*>(.*)</title>';

function eraseStr(mainStr, strToErase: string): string;
function removeCDataHtmlElem(cdata_string: string): string;
function getTheDesc(descriptionElement: string): string;
function getPodcastTitle(descriptionElement: string): string;
function urlOfEpisode(enclosureElement: string): string;
function filenameOfEpisode(enclosureElement: string): string;
function bytesOfEpisode(enclosureElement: string): integer;
function enclosureOfEpisode(itemNode: string): string;

type

  TXmlEpisode = class(TObject)
  private
    FEpisodeTitle: string;
    FDescEpisode: string;
    FUrlEpisode: string;
    FFilenameEpisode: string;
    FBytesEpisode: int64;
    FSearchTextEpisode: string;
    FValidDownload: boolean;
  public
    constructor Create(itemString: string);
    function filenameAndUrl(): TUrlAndFilename;
    function theEpisodeUrl(): string;
    function containsSearch(searchStr: string): boolean;
    function bytesInEpisode(): integer;
    function isValidDownload(): boolean;
    function theEpisodeFilename(): string;
    function theEpisodeTitle(): string;
    function theEpisodeDescription(): string;
  published

  end;

  TXmlEpisodes = array of TXmlEpisode;

function htmlCharEntities(no_html: string): string;

const
  CASE_INSENSITIVE = True;

implementation

function eraseStr(mainStr, strToErase: string): string;
var
  smallerStr: string;
begin
  smallerStr := StringReplace(mainStr, strToErase, '', [rfReplaceAll, rfIgnoreCase]);
  Result := smallerStr;
end;

function removeCDataHtmlElem(cdata_string: string): string;
var
  s1, s2, s3, s4, s5, s6, s7, s8: string;
begin
  s1 := eraseStr(cdata_string, '<![CDATA[');
  s2 := eraseStr(s1, ']]>');
  s3 := AdjustLineBreaks(s2, tlbsCRLF);
  s4 := StringReplace(s3, LINE_ENDING, ' ', [rfReplaceAll]);
  s5 := ReplaceRegExpr('<[^>]*>', s4, '', False);
  s6 := StringReplace(s5, '&lt;', '<', [rfReplaceAll]);        // Coding Blocks issue
  s7 := StringReplace(s6, '&gt;', '>', [rfReplaceAll]);        // https://www.codingblocks.net/podcast-feed.xml
  s8 := ReplaceRegExpr('<[^>]*>', s7, '', False);
//  _d('s5', s5);
//  _d('s6', s6);
//  _d('s7', s7);
//  _d('s8', s8);
  Result := s8;
end;

function getNoHtml(descriptionElement, title_desc_regex: string): string;
var
  just_desc, no_entities, no_html_desc: string;
  RegexObj: TRegExpr;
begin
  try
    RegexObj := TRegExpr.Create(title_desc_regex);
    RegExprModifierI := CASE_INSENSITIVE;
    RegexObj.Exec(descriptionElement);
    just_desc := RegexObj.Match[1];
    no_html_desc := removeCDataHtmlElem(just_desc);
    no_entities := htmlCharEntities(no_html_desc);
    Result := no_entities;
  finally
    RegexObj.Free
  end;

end;

function getTheDesc(descriptionElement: string): string;
var
  desc_episode: string;
begin
  desc_episode := getNoHtml(descriptionElement, DESC_CDATA_REGEX);
  Result := desc_episode;
end;

function getPodcastTitle(descriptionElement: string): string;
var
  desc_episode: string;
begin
  desc_episode := getNoHtml(descriptionElement, TITLE_CDATA_REGEX);
  Result := desc_episode;
end;

constructor TXmlEpisode.Create(itemString: string);
var
  enclosureParts: string;
begin
  FEpisodeTitle := getPodcastTitle(itemString);
  FDescEpisode := getTheDesc(itemString);
  enclosureParts := enclosureOfEpisode(itemString);
  FValidDownload := False;
  FBytesEpisode := 0;
  FUrlEpisode := urlOfEpisode(enclosureParts);
  FFilenameEpisode := filenameOfEpisode(enclosureParts);
  if FFilenameEpisode <> '' then
  begin
    FBytesEpisode := bytesOfEpisode(enclosureParts);
    FSearchTextEpisode := FFilenameEpisode + ' ' + FEpisodeTitle + ' ' + FDescEpisode;
    FValidDownload := True;
  end;
end;

function TXmlEpisode.containsSearch(searchStr: string): boolean;
var
  hasStr: boolean;
begin
  if not isValidDownload() then
    hasStr := False
  else if '' = searchStr then
    hasStr := False
  else if AnsiContainsText(FSearchTextEpisode, searchStr) then
    hasStr := True
  else
    hasStr := False;
  Result := hasStr;
end;

function filenameOfEpisode(enclosureElement: string): string;
var
  MyStringList: TStringList;
  fileName, itemUrlzz: string;
  RegexObj: TRegExpr;
  lastIndex: integer;
begin
  fileName := '';
  itemUrlzz := urlOfEpisode(enclosureElement);
  if itemUrlzz <> '' then
    try
      MyStringList := TStringList.Create;
      RegexObj := TRegExpr.Create('(/|\\)');          // windows paths or urls
      RegexObj.Split(itemUrlzz, MyStringList);
      lastIndex := MyStringList.Count - 1;
      fileName := MyStringList[lastIndex];
    finally
      MyStringList.Free();
      RegexObj.Free();
    end;
  Result := fileName;
end;

function urlOfEpisode(enclosureElement: string): string;
var
  urlWithParameter, plainUrl: string;
  RegexObj: TRegExpr;
begin
  try
    RegexObj := TRegExpr.Create(' url="([^"]*)"');
    try
      RegExprModifierI := CASE_INSENSITIVE;
      RegexObj.Exec(enclosureElement);
      urlWithParameter := RegexObj.Match[1];
      RegexObj.Expression := '([^?]*)';
      RegexObj.Exec(urlWithParameter);
      plainUrl := RegexObj.Match[1];
      Result := plainUrl;
    except
      Result := '';
    end;
  finally
    RegexObj.Free
  end;
end;

function bytesOfEpisode(enclosureElement: string): integer;
var
  RegexObj: TRegExpr;
  byteLength: string;
  numberBytes: integer;
begin
  try
    RegexObj := TRegExpr.Create(' length="([^"]*)"');
    try
      RegExprModifierI := CASE_INSENSITIVE;
      RegexObj.Exec(enclosureElement);
      byteLength := RegexObj.Match[1];
      if byteLength = '' then
        numberBytes := 0
      else
        numberBytes := StrToInt(byteLength);
      Result := numberBytes;
    except
      Result := 0;
    end;
  finally
    RegexObj.Free();
  end;
end;

function enclosureOfEpisode(itemNode: string): string;
var
  RegexObj: TRegExpr;
  enclosureParts: string;
begin
  try
    RegexObj := TRegExpr.Create('<enclosure([^>]*)');
    try
      RegExprModifierI := CASE_INSENSITIVE;
      RegexObj.Exec(itemNode);
      enclosureParts := RegexObj.Match[1];
      Result := enclosureParts;
    except
      Result := '';
    end;
  finally
    RegexObj.Free
  end;
end;

function htmlCharEntities(no_html: string): string;

  procedure replaceAll(html_text, normal_text: string);
  begin
    no_html := StringReplace(no_html, html_text, normal_text, [rfReplaceAll, rfIgnoreCase]);
  end;

begin
  replaceAll('&amp;nbsp;', ' ');
  replaceAll('&amp;ldquo;', '''');    // https://feeds.feedwrench.com/js-jabber.rss
  replaceAll('&amp;rdquo;', '''');
  replaceAll('&amp;quot;', '''');
  replaceAll('&amp;#39;', '''');
  replaceAll('&amp;rsquo;', '''');
  replaceAll('&amp;lsquo;', '''');
  replaceAll('&amp;ndash;', '-');
  replaceAll('&amp;mdash;', '-');

  replaceAll('&nbsp;', ' ');
  replaceAll('&#160;', ' ');

  replaceAll('&ndash;', '-');
  replaceAll('&#8211;', '-');
  replaceAll('&mdash;', '-');
  replaceAll('&#8212;', '-');

  replaceAll('&lt;', '<');
  replaceAll('&#60;', '<');
  replaceAll('&#060;', '<');

  replaceAll('&gt;', '>');
  replaceAll('&#62;', '>');
  replaceAll('&#062;', '>');


  replaceAll('&#38;', '&');
  replaceAll('&#038;', '&');

  replaceAll('&quot;', '"');
  replaceAll('&#34;', '"');
  replaceAll('&#034;', '"');
  replaceAll('&#8220;', '"');
  replaceAll('&#8221;', '"');

  replaceAll('&apos;', '''');
  replaceAll('&#39;', '''');
  replaceAll('&#039;', '''');   // Nasa Pictures need this
  replaceAll('&#8217;', '''');
  replaceAll('&#8216;', '''');
  replaceAll('&lsquo;', '''');
  replaceAll('&rsquo;', '''');

  replaceAll('&cent;', '¢');
  replaceAll('&#162;', '¢');

  replaceAll('&pound;', '£');
  replaceAll('&#163;', '£');

  replaceAll('&yen;', '¥');
  replaceAll('&#165;', '¥');

  replaceAll('&euro;', '€');
  replaceAll('&#8364;', '€');

  replaceAll('&copy;', '©');
  replaceAll('&#169;', '©');

  replaceAll('&reg;', '®');
  replaceAll('&#174;', '®');

  replaceAll('&amp;', '&');  // NB, keep last

  Result := no_html;
end;


function TXmlEpisode.filenameAndUrl(): TUrlAndFilename;
var
  url_and_filename: TUrlAndFilename;
begin
  url_and_filename.EpisodeUrl := FUrlEpisode;
  url_and_filename.EpisodeFilename := FFilenameEpisode;
  Result := url_and_filename;
end;

function TXmlEpisode.isValidDownload(): boolean;
begin
  Result := FValidDownload;
end;

function TXmlEpisode.bytesInEpisode(): integer;
begin
  Result := FBytesEpisode;
end;

function TXmlEpisode.theEpisodeTitle(): string;
begin
  Result := FEpisodeTitle;
end;

function TXmlEpisode.theEpisodeFilename(): string;
begin
  Result := FFilenameEpisode;
end;

function TXmlEpisode.theEpisodeDescription(): string;
begin
  Result := FDescEpisode;
end;

function TXmlEpisode.theEpisodeUrl(): string;
begin
  Result := FUrlEpisode;
end;


end.
