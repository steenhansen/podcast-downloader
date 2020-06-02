unit consts_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

const

    HTTP_RETRIES = 5;       // default is 5, change to 1 if you want lots of failures for testing


 //////////////////////





  HTTP_TIMEOUT = 1001;    //  note has a backoff, 1001,2002,3003,4004,5005 mSec



  GB_DISK_WARN_SIZE = 0.5;          // 0.5 warn once when disk space is below

  NETWORK_MEDIUM_SLEEP = 1;
  NETWORK_LOW_SLEEP = 50;

//// Don't change below ////////////////////////////

  CASE_INSENSITIVE = True;

  DUPLICATE_FNAME_CHECKS = 10;

  DESC_CDATA_REGEX = '<description[^>]*>(.*)</description>';
  TITLE_CDATA_REGEX = '<title[^>]*>(.*)</title>';


   DEFAULT_DIR   = 'C';
   WINDOWS_DRIVE_PATH = '([a-zA-Z])?(:)?(.*)';

   WINDOWS_DRIVE = '[^a-zA-Z]';

   WINDOWS_PATH =   '[^\w\\.-]';


  OUT_OF_SLASH = '/';
  DATE_SLASH = '/';
  HTTP_SLASH = '/';
  LINE_ENDING = LineEnding;

  ARE_TESTING = True;
  RSS_TEMP_FILE = 'RSS_TEMP_FILE_NAME';
  NO_BYTE_SIZE_INDENT = '                     ';
  EPISODE_DESC_INDENT = 20;
  EPISODE_TITLE_INDENT = 4;

  STOP_RED = $000000C0;
  STANDARD_HOVER_EDGE = $00D77800;
  START_GREEN = $00009B00;
  ESCAPE_KEY = #27;

  H_RECT_INDENT = 2;
  V_RECT_INDENT = 2;
  CHECK_RECT_SIZE = 13;


  ONE_GIGABYTE = 1073741824;

  LETTER_A_AS_CHAR = 64;

  COLOR_CHECKBOX_BORDER = TColor($333333);
  COLOR_CHECKBOX_INTERIOR = TColor($FFFFFF);

  COLOR_EVEN_ROW_MATCH = TColor($22FFFF);
  COLOR_EVEN_ROW_NO_MATCH = TColor($ddFFFF);
  COLOR_ODD_ROW_MATCH = TColor($FFFF22);
  COLOR_ODD_ROW_NO_MATCH = TColor($FFFFdd);

  COLOR_CHECKMARK_TOP = TColor($EEEEEE);
  COLOR_CHECKMARK_MIDDLE = TColor($444444);
  COLOR_CHECKMARK_BOTTOM = TColor($666666);

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

    LINE_BREAK_ON_XML_ITEM = '<item';
  END_HTML_COMMENT = '-->';
  START_HTML_COMMENT = '<!--';
  START_CDATA = '<![CDATA[';
  END_CDATA = ']]>';

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

        TNetworkLoad = (High=0, Medium=1, Low=2);

implementation

end.
