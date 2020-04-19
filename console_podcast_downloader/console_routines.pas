unit console_routines;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Windows,
  Keyboard,
  consts_types;

function consolePrintFailures(failed_list: TStringList): string;
function consoleWriteStr(row_y: integer; row_str: string): string;
function consoleProgramPath(): string;
function consoleWaitForUpperKey(show_cancelled: boolean): string;
procedure consoleQuitOnKey(key_quit: char);
procedure consoleClearScreen(fill_char: char);

implementation

function fitScreenWidth(console_handle: THandle; row_str: string): string;
var
  num_cols: integer;
  screen_buf_info: TConsoleScreenBufferInfo;
  extra_blanks, chopped_str: string;
begin
  {$warn 5057 off}  // screen_buf_info not initialized
  GetConsoleScreenBufferInfo(console_handle, screen_buf_info);
  {$warn 5057 on}
  num_cols := screen_buf_info.SRWINDOW.Right;
  extra_blanks := row_str + '  ';
  chopped_str := LeftStr(extra_blanks, num_cols);
  Result := chopped_str;
end;

procedure consoleQuitOnKey(key_quit: char);
var
  key_event: TKeyEvent;
  key_str: string;
begin
  key_event := PollKeyEvent();
  if key_event <> 0 then
  begin
    key_event := GetKeyEvent();
    key_event := TranslateKeyEvent(key_event);
    key_str := KeyEventToString(key_event);
    if key_str = key_quit then
      raise ECancelException.Create(CONSOLE_KEY_QUIT);
  end;
end;

function consoleProgramPath(): string;
var
  abs_exe_file, program_path: string;
begin
  abs_exe_file := ParamStr(0);
  program_path := ExtractFilePath(abs_exe_file);
  Result := program_path;
end;

function consolePrintFailures(failed_list: TStringList): string;
var
  failed_index: integer;
  failed_files: string;
begin
  failed_files := '';
  if Assigned(failed_list) then
  begin
    for failed_index := 0 to failed_list.Count - 1 do
      failed_files := failed_list[failed_index] + LINE_ENDING;
  end;
  Result := failed_files;
end;

procedure consoleClearScreen(fill_char: char);
var
  console_coord: COORD;
  console_handle: THandle;
  row_index, num_cols, num_rows: integer;
  screen_buf_info: TConsoleScreenBufferInfo;
  empty_line: string;
begin
  console_coord.X := 0;
  console_coord.Y := 0;
  console_handle := GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleCursorPosition(console_handle, console_coord);
  if console_handle = INVALID_HANDLE_VALUE then
    RaiseLastOSError();
    {$warn 5057 off}    // screen_buf_info not initialized
  GetConsoleScreenBufferInfo(console_handle, screen_buf_info);
    {$warn 5057 on}
  num_cols := screen_buf_info.SRWINDOW.Right;
  empty_line := StringOfChar(fill_char, num_cols);
  num_rows := screen_buf_info.SRWINDOW.Bottom + 1;
  for row_index := 1 to num_rows do
    WriteLn(empty_line);
  SetConsoleCursorPosition(console_handle, console_coord);
end;


function consoleWriteStr(row_y: integer; row_str: string): string;
var
  console_coord: COORD;
  console_handle: THandle;
  chopped_str, trimmed_str: string;
begin
  console_coord.X := 0;
  console_coord.Y := row_y;
  console_handle := GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleCursorPosition(console_handle, console_coord);
  chopped_str := fitScreenWidth(console_handle, row_str);
  Write(chopped_str);
  trimmed_str:= Trim(chopped_str);
  Result := trimmed_str;
end;

function consoleWaitForUpperKey(show_cancelled: boolean): string;
var
  key_event: TKeyEvent;
  key_str, uppercase_key: string;
begin
  key_str := '';
  repeat
    if show_cancelled then
    begin
      consoleWriteStr(CANCELLED_CONSOL_ROW, '*** Cancelled with escape key or does not exist. Hit any key to continue. ****');
      sleep(200);
      consoleWriteStr(CANCELLED_CONSOL_ROW, '    Cancelled with escape key or does not exist. Hit any key to continue.     ');
      sleep(200);
    end;
    key_event := PollKeyEvent();
    if key_event <> 0 then
    begin
      key_event := GetKeyEvent();
      key_event := TranslateKeyEvent(key_event);
      key_str := KeyEventToString(key_event);
    end;
  until key_str <> '';
  consoleClearScreen(' ');
  uppercase_key := UpperCase(key_str);
  Result := uppercase_key;
end;

end.















