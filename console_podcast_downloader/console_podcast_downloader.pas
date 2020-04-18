program console_podcast_downloader;




// after 60/60 nasa downloads it said error



{$mode objfpc}{$H+}

//  url_or_file := 'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss';
//url_or_file := '\test\sffaudio.herokuapp.com-pdf-rss1.xml';




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
  rss_podcast

  ;

var
  quit_character, console_lines: string;
begin
  InitKeyBoard();

  repeat
    try
       console_lines := readAPodcast();                                                      // not a test
       //   console_lines :=readAPodcast('https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss');  // a test
    except
      quit_character := consoleWaitForUpperKey(SHOW_CANCELLED_CONSOL);
    end;
    WriteLn('');
    Write('Type Q to quit, any other key to continue');

    quit_character := consoleWaitForUpperKey(HIDE_CANCELLED_CONSOL);
  until quit_character = 'Q';
end.







































































































