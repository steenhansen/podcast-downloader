unit dirs_files;

{$mode objfpc}{$H+}

interface

uses

  {$IfDef ALLOW_DEBUG_SERVER}
    //debug_server,                       // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils, RegExpr, strUtils, LazFileUtils, Math;



function isOnlinePodcast(url_or_file: string): boolean;
function fileDirName(url_or_file: string): string;
function deskDirName(rssUrl: string): string;
function xmlPathName(rssUrl, chosenDir: string): string;
function getUrlProtocol(url: string): string;

function mbFileSize(fileByteSize: integer): string;

implementation

uses
   consts_types;





function getUrlProtocol(url: string): string;
var
  addHttp: string;
begin
  if AnsiStartsStr('//', url) then
  begin
    addHttp := 'http:' + url;
    Result := addHttp;
  end
  else
    Result := url;

end;

function isOnlinePodcast(url_or_file: string): boolean;
begin
  if AnsiStartsStr('//', url_or_file) then
    Result := True
  else if AnsiStartsStr('http://', url_or_file) then
    Result := True
  else if AnsiStartsStr('https://', url_or_file) then
    Result := True
  else
    Result := False;

end;

function fileDirName(url_or_file: string): string;
var
  rssUrlHttp, rssUrlPlain, dirFileName: string;
  //RegexObj: TRegExpr;
begin
  if isOnlinePodcast(url_or_file) then
  begin
    rssUrlHttp := StringReplace(url_or_file, 'https://', '', [rfReplaceAll, rfIgnoreCase]);
    rssUrlPlain := StringReplace(rssUrlHttp, 'http://', '', [rfReplaceAll, rfIgnoreCase]);
    dirFileName := StringReplace(rssUrlPlain, HTTP_SLASH, '-', [rfReplaceAll, rfIgnoreCase]);
  end
  else
  begin
    dirFileName := ExtractFileName(url_or_file);
  end;
  Result := dirFileName;
end;


function deskDirName(rssUrl: string): string;
var
  urlNoQuest: string;
  trimmedPath, dirFileName, desktopPath, dirName: string;
begin
  urlNoQuest := ReplaceRegExpr('\?.*', rssUrl, '', False);
  //  https://s.ch9.ms/Events/MIX/MIX11/RSS/mp4high?WT.mc_id=-blog-scottha
  trimmedPath := Trim(urlNoQuest);
  dirFileName := fileDirName(trimmedPath);
  desktopPath := AppendPathDelim(GetUserDir + 'Desktop');                                                //   qu*bert AppendPathDelim(GetUserDir + 'Desktop');
  dirName := desktopPath + dirFileName + PathDelim;
  Result := dirName;
end;

function xmlPathName(rssUrl, chosenDir: string): string;
var
  filePath, xmlFileName: string;
begin
  xmlFileName := '_' + fileDirName(rssUrl) + '.xml';
  filePath := chosenDir + PathDelim  + xmlFileName;
  Result := filePath;
end;

function mbFileSize(fileByteSize: integer): string;
const
  Description: array [0 .. 8] of string =
    ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
  //  010.88 KB
  //  1023Bytes
var
  i: integer;
  mbSize: string;
begin
  if fileByteSize = 0 then
    Result := ''
  else if fileByteSize < 1024 then
    Result := FormatFloat('0000', fileByteSize) + 'Bytes'
  else
  begin
    i := 0;
    while fileByteSize > Power(1024, i + 1) do
      Inc(i);
    mbSize := FormatFloat('000.00', fileByteSize / IntPower(1024, i)) +
      ' ' + Description[i];
    Result := mbSize;
  end;
end;

end.
