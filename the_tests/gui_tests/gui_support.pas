unit gui_support;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, Forms, Dialogs, RegExpr;

function xmlFileName(testNumber: string): string;
function outputPathName(testNumber: string): string;
procedure guiDirectory(expected_text, actual_text, which_test: string);

implementation

uses
  dir_list_differences;

procedure guiDirectory(expected_text, actual_text, which_test: string);
var
  expected_trim, actual_trim: string;
begin
  expected_trim := Trim(expected_text);
  actual_trim := Trim(actual_text);
  if expected_trim <> actual_trim then
  begin
    with frmTestDirListDifference do
    begin
      lblTestMessage.Caption := which_test;
      memExpectedDirListing.Text := expected_trim;
      memActualDirListing.Text := actual_trim;
      showModal();
    end;
    TAssert.AssertEquals(which_test, expected_trim, actual_trim);
  end;
end;

function guiExePath(): string;
var
  abs_gui_exe, gui_path: string;
begin
  abs_gui_exe := Application.ExeName;
  gui_path := ExtractFilePath(abs_gui_exe);
  Result := gui_path;
end;

function xmlFileName(testNumber: string): string;
var
  xmlFile: string;
begin
  xmlFile := testNumber + PathDelim + '_rss_' + testNumber + '.xml';
  Result := xmlFile;
end;

function outputPathName(testNumber: string): string;
var
  outputPath, applicationPath: string;
begin
  applicationPath := ExtractFilePath(Application.ExeName);
  outputPath := applicationPath + testNumber + PathDelim + 'output' + PathDelim;
  Result := outputPath;
end;

























end.
