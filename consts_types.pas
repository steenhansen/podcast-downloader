unit consts_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  OUT_OF_SLASH = '/';
  DATE_SLASH = '/';
  HTTP_SLASH = '/';
  LINE_ENDING = LineEnding;

  ARE_TESTING = True;
  RSS_TEMP_FILE = 'RSS_TEMP_FILE_NAME';
  NO_BYTE_SIZE_INDENT = '                     ';
  EPISODE_DESC_INDENT = 16;

  STOP_RED = $000000C0;
  STANDARD_HOVER_EDGE = $00D77800;
  START_GREEN = $00009B00;
  ESCAPE_KEY = #27;

  CONSOLE_KEY_QUIT = 'console_escape_key_quit';
  GUI_CANCEL_BUTTON_QUIT = 'gui_cancel_button_quit';
  GUI_ESCAPE_KEY_QUIT = 'gui_escape_key_quit';
  WRITE_EXCEPTION_EPISODE = 'write_exception_episode';
  READ_EXCEPTION_PODCAST = 'read_exception_podcast';
  EXCEPTION_SPACE = '::';

  NUMBER_CONSOL_LINES = 100;
  SHOW_CANCELLED_CONSOL = True;
  HIDE_CANCELLED_CONSOL = False;

  CANCELLED_CONSOL_ROW = 0;
  //BLANK_CONSOL_ROW_1=1;
  INTRODUCTION_CONSOL_ROW = 2;
  EG_NASA_CONSOL_ROW = 3;
  //BLANK_CONSOL_ROW_4=4;
  // BLANK_CONSOL_ROW_5=5;
  ENTER_POD_URL_CONSOL_ROW = 6;
  // BLANK_CONSOL_ROW_7=7;
  PODCAST_BYTES_CONSOL_ROW = 8;
  PODCAST_TITLE_CONSOL_ROW = 9;
  PODCAST_DESC_CONSOL_ROW = 10;
  NUM_EPISODES_CONSOL_ROW = 11;
  DEST_FOLDER_CONSOL_ROW = 12;
  FIRST_EPISODE_CONSOL_ROW = 13;

type
  // hitting 'Esc' key in consol app stops program
  // clicking 'Cancel' button in gui app stops program
  ECancelException = class(Exception);

  TUrlAndFilename = record
    EpisodeUrl: string;
    EpisodeFilename: string;
  end;

  TFailsAndSuccesses = record
    failedCount: integer;
    successCount: integer;
  end;

  TCheckedAndTotalSize = record
    checkedFileCount: integer;
    fileSizeChecked: integer;
  end;

implementation

end.
