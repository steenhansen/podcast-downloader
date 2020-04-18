unit test_local;

{$mode objfpc}{$H+}
















interface

uses

  Classes, SysUtils, fpcunit,  testregistry,
  consts_types;

const
   XML_FILE_A = 'tconsole_a_local\__screen_a__three_files.xml';
   XML_FILE_B = 'tconsole_b_local\__directory_b__three_files.xml';
   XML_FILE_C = 'tconsole_c_local\__screen_c__1_of_3_files_missing.xml';
   XML_FILE_D = 'tconsole_d_local\__directory_d__1_of_3_files_missing.xml';


  XML_FILE_E = 'tconsole_e_local\__screen_e__no_new_episodes.xml';
  XML_FILE_F = 'tconsole_f_local\__screen_f__no_such_file.xml' ;
  XML_FILE_G = 'tconsole_g_local\__screen_g__not_a_podcast.xml' ;


  FIRST_ERROR_LINE = LINE_ENDING+LINE_ENDING+
                     'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'  +
                    LINE_ENDING+LINE_ENDING;
  SECOND_ERROR_LINE = LINE_ENDING+LINE_ENDING+
                     'SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS'   +
                    LINE_ENDING+LINE_ENDING;
type

  TTestLocal = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure consoleAssert(assert_mess,  expected_short, actual_short:string);
  published

     procedure screen_a__three_files();
    procedure directory_b__three_files();

     procedure screen_c__1_of_3_files_missing();
     procedure directory_d__1_of_3_files_missing();


    procedure screen_e__no_new_episodes();



       procedure screen_f__no_such_file();
      procedure screen_g__not_a_podcast();




  end;


implementation




uses
  console_routines,
  dirs_files,
  console_backup,

  test_support;



procedure TTestLocal.SetUp;
begin

end;

procedure TTestLocal.TearDown;
begin
  killDirectory(XML_FILE_A);
  killDirectory(XML_FILE_B);
  killDirectory(XML_FILE_C);
  killDirectory(XML_FILE_D);
  killDirectory(XML_FILE_E);
  killDirectory(XML_FILE_F);
end;

 
procedure TTestLocal.consoleAssert(assert_mess,  expected_short, actual_short:string);
var
     actual_text, expected_text: string;
begin

  expected_text := FIRST_ERROR_LINE+Trim(expected_short)+SECOND_ERROR_LINE;
      actual_text := FIRST_ERROR_LINE+Trim(actual_short)+SECOND_ERROR_LINE;
     AssertEquals(assert_mess, expected_text, actual_text);
end;


procedure TTestLocal.screen_a__three_files();
var
  screen_text, expected_text: string;
begin
  screen_text := readAPodcast(XML_FILE_A);
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_a_local\__screen_a__three_files.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title : The SFFaudio Public Domain PDF Page' + LINE_ENDING;
  expected_text := expected_text + 'Description : Public domain PDFs.' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 3' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_a__three_files.xml' + LINE_ENDING;
  expected_text := expected_text + '1/3 : 010.88 KB : ToTHEBOWERS1829ByEdgarAllanPoe.pdf' + LINE_ENDING;
  expected_text := expected_text + '2/3 : 011.16 KB : AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf' + LINE_ENDING;
  expected_text := expected_text + '3/3 : 011.97 KB : TheDwellerInTheHillsByAugustDerleth.pdf';
  consoleAssert('Directory files not matching', expected_text, screen_text);
end;



procedure TTestLocal.directory_b__three_files();
var
  directory_text, expected_text: string;
   outputPath: string;
begin
  outputPath := deskDirName(XML_FILE_B);
  clearOutputDir(outputPath);
  readAPodcast(XML_FILE_B);
  directory_text := filesWithSizes(outputPath);
  expected_text := '__directory_b__three_files.xml~~2543' + LINE_ENDING;
  expected_text := expected_text + 'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING;
  expected_text := expected_text + 'TheDwellerInTheHillsByAugustDerleth.pdf~~12261' + LINE_ENDING;
  expected_text := expected_text + 'ToTHEBOWERS1829ByEdgarAllanPoe.pdf~~11140';
  consoleAssert('Directory files not matching', expected_text, directory_text);
end;






procedure TTestLocal.screen_c__1_of_3_files_missing();
var
   screen_text, expected_text: string;
begin
  screen_text := readAPodcast(XML_FILE_C);
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_c_local\__screen_c__1_of_3_files_missing.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title : The SFFaudio Public Domain PDF Page' + LINE_ENDING;
  expected_text := expected_text + 'Description : Public domain PDFs.' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 3' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_c__1_of_3_files_missing.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + '2/3 : 011.16 KB : AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf' + LINE_ENDING;
  expected_text := expected_text + '3/3 : 011.97 KB : TheDwellerInTheHillsByAugustDerleth.pdf'+ LINE_ENDING;
  expected_text := expected_text + 'Failed Episodes:'+ LINE_ENDING;
  expected_text := expected_text + '\tconsole_a_local\files\XToTHEBOWERS1829ByEdgarAllanPoe.pdf'+ LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : C:\Users\steen\Desktop\__screen_c__1_of_3_files_missing.xml\';
  consoleAssert('Screen files not matching', expected_text, screen_text);
end;





procedure TTestLocal.directory_d__1_of_3_files_missing();
var
  directory_text, expected_text: string;
   outputPath: string;
begin
  outputPath := deskDirName(XML_FILE_D);
  clearOutputDir(outputPath);
  readAPodcast(XML_FILE_D);
  directory_text :=filesWithSizes(outputPath);
  expected_text := '__directory_d__1_of_3_files_missing.xml~~2544' + LINE_ENDING;
  expected_text := expected_text + 'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING;
  expected_text := expected_text + 'TheDwellerInTheHillsByAugustDerleth.pdf~~12261';
  consoleAssert('Directory One file is missing',  expected_text, directory_text);
end;








procedure TTestLocal.screen_e__no_new_episodes();
var
  screen_text, outputPath, expected_text: string;
begin
  outputPath := deskDirName(XML_FILE_E);
  clearOutputDir(outputPath);
  readAPodcast(XML_FILE_E);
  screen_text := readAPodcast(XML_FILE_E);     //read again, for no new episodes
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_e_local\__screen_e__no_new_episodes.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title : The SFFaudio Public Domain PDF Page' + LINE_ENDING;
  expected_text := expected_text + 'Description : Public domain PDFs.' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 3' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_e__no_new_episodes.xml' + LINE_ENDING;
  expected_text := expected_text +  LINE_ENDING;
  expected_text := expected_text + 'No new episodes to download' + LINE_ENDING;
  consoleAssert('Have all episodes in dir', expected_text, screen_text);
end;


procedure TTestLocal.screen_f__no_such_file();
begin
     try
        readAPodcast(XML_FILE_F);
     except
          on E: Exception do
         AssertEquals('bail on file does not exist', E.ClassName, 'EFOpenError');
     end;
end;




procedure TTestLocal.screen_g__not_a_podcast();
var
  screen_text, expected_text: string;
begin
  screen_text := readAPodcast(XML_FILE_G);
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_g_local\__screen_g__not_a_podcast.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title :' + LINE_ENDING;
  expected_text := expected_text + 'Description :' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 0' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_g__not_a_podcast.xml' + LINE_ENDING;
  expected_text := expected_text +  LINE_ENDING;
  expected_text := expected_text + 'No podcast episodes found' + LINE_ENDING;
  consoleAssert('Have all episodes in dir', expected_text, screen_text);
end;

initialization






  RegisterTest(TTestLocal);
end.






