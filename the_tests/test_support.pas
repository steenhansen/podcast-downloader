unit test_support;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, RegExpr, consts_types;

const
  FIRST_ERROR_LINE_xx = LINE_ENDING + LINE_ENDING + 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF' +
    LINE_ENDING + LINE_ENDING;
  SECOND_ERROR_LINE_xx = LINE_ENDING + LINE_ENDING + 'SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS' +
    LINE_ENDING + LINE_ENDING;

procedure clearOutputDir(testPath: string);
function filesWithSizes(testPath: string): string;
procedure killDirectory(xml_file: string);

implementation

uses
  rss_podcast,
  dirs_files;

procedure killDirectory(xml_file: string);
var
  outputPath: string;
begin
  outputPath := deskDirName(xml_file);
  clearOutputDir(outputPath);
  RemoveDir(outputPath);
end;

function filesWithSizes(testPath: string): string;
var
  testOutputPath, fileSizes: string;
  foundFiles: TStringList;
  fileNameSize: string;
  copySearch: TSearchRec;
begin
  testOutputPath := testPath + '*.*';
  foundFiles := lineBreakStringList(LINE_ENDING);
  foundFiles.sorted := True;
  if FindFirst(testOutputPath, faAnyFile + faReadOnly, copySearch) = 0 then
    repeat
      fileNameSize := copySearch.Name + '~~' + IntToStr(copySearch.Size);
      foundFiles.Add(fileNameSize);
    until FindNext(copySearch) <> 0;
  FindClose(copySearch);
  fileSizes := foundFiles.Text;
  foundFiles.Free();
  Result := Trim(fileSizes);
end;

procedure clearOutputDir(testPath: string);
var
  testOutputPath, fileToDel: string;
  copySearch: TSearchRec;
begin
  testOutputPath := testPath + '*.*';
  if FindFirst(testOutputPath, faAnyFile + faReadOnly, copySearch) = 0 then
    repeat
      fileToDel := testPath + copySearch.Name;
      DeleteFile(fileToDel);
    until FindNext(copySearch) <> 0;
  FindClose(copySearch);
end;

end.
