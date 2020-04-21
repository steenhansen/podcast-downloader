program console_podcast_downloader;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces,
  Classes,
  SysUtils,
  Windows,
  Keyboard,
  download_stream,
  consts_types,
  dirs_files,
  console_routines,
  console_backup,
  rss_podcast;

var
  quit_character, console_lines: string;
begin
  InitKeyBoard();
  repeat
    try
      console_lines := readAPodcast();
    except
      quit_character := consoleWaitForUpperKey(SHOW_CANCELLED_CONSOL);
    end;
    WriteLn('');
    Write('Type Q to quit, any other key to continue');
    quit_character := consoleWaitForUpperKey(HIDE_CANCELLED_CONSOL);
  until quit_character = 'Q';
end.







































































































