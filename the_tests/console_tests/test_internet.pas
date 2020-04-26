unit test_internet;

{$mode objfpc}{$H+}

interface



///     we need to erase files before tests....

uses

  Classes, SysUtils, fpcunit,  testregistry,
  consts_types;

const

     XML_FILE_H = 'tconsole_h_internet\__screen_h__three_files.xml';
   XML_FILE_I = 'tconsole_i_internet\__directory_i__three_files.xml';
   XML_FILE_J = 'tconsole_j_internet\__screen_j__1_of_3_files_missing.xml';
   XML_FILE_K = 'tconsole_k_internet\__directory_k__1_of_3_files_missing.xml';


  XML_FILE_L = 'tconsole_l_internet\__screen_l__no_new_episodes.xml';
  XML_FILE_M = 'tconsole_m_internet\__screen_m__no_such_file.xml' ;
  XML_FILE_N = 'tconsole_n_internet\__screen_n__not_a_podcast.xml' ;



  FIRST_ERROR_LINE = LINE_ENDING+LINE_ENDING+
                     'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'  +
                    LINE_ENDING+LINE_ENDING;
  SECOND_ERROR_LINE = LINE_ENDING+LINE_ENDING+
                     'SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS'   +
                    LINE_ENDING+LINE_ENDING;
type

  TTestInternet = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure consoleAssert(assert_mess,  expected_short, actual_short:string);
  published

                                                       procedure screen_h__three_files();
                                                        procedure directory_i__three_files();
     procedure screen_j__1_of_3_files_missing();
     procedure directory_k__1_of_3_files_missing();
                                                           procedure screen_l__no_new_episodes();




       procedure screen_m__no_such_file();

       procedure screen_n__not_a_podcast();





  end;

implementation


uses
  //console_routines,
  dirs_files,
  console_backup,

  test_support;

procedure TTestInternet.SetUp;
begin

end;



procedure TTestInternet.TearDown;
begin
  killDirectory(XML_FILE_H);
  killDirectory(XML_FILE_I);
  killDirectory(XML_FILE_J);
  killDirectory(XML_FILE_K);
  killDirectory(XML_FILE_L);
  killDirectory(XML_FILE_M);
end;


procedure TTestInternet.consoleAssert(assert_mess,  expected_short, actual_short:string);
var
     actual_text, expected_text: string;
begin

  expected_text := FIRST_ERROR_LINE+Trim(expected_short)+SECOND_ERROR_LINE;
      actual_text := FIRST_ERROR_LINE+Trim(actual_short)+SECOND_ERROR_LINE;
     AssertEquals(assert_mess, expected_text, actual_text);
end;


procedure TTestInternet.screen_h__three_files();
var
  screen_text, expected_text: string;
begin
  screen_text := readAPodcast(XML_FILE_H);
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_h_internet\__screen_h__three_files.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title : The SFFaudio Public Domain PDF Page' + LINE_ENDING;
  expected_text := expected_text + 'Description : Public domain PDFs.' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 3' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_h__three_files.xml' + LINE_ENDING;
  expected_text := expected_text + '1/3 : 010.88 KB : ToTHEBOWERS1829ByEdgarAllanPoe.pdf' + LINE_ENDING;
  expected_text := expected_text + '2/3 : 011.16 KB : AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf' + LINE_ENDING;
  expected_text := expected_text + '3/3 : 011.97 KB : TheDwellerInTheHillsByAugustDerleth.pdf';
  consoleAssert('Directory files not matching', expected_text, screen_text);
end;



procedure TTestInternet.directory_i__three_files();
var
  directory_text, expected_text: string;
   outputPath: string;
begin
  outputPath := deskDirName(XML_FILE_I);
  clearOutputDir(outputPath);
  readAPodcast(XML_FILE_I);
  directory_text := filesWithSizes(outputPath);
  expected_text := '__directory_i__three_files.xml~~2570' + LINE_ENDING;
  expected_text := expected_text + 'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING;
  expected_text := expected_text + 'TheDwellerInTheHillsByAugustDerleth.pdf~~12261' + LINE_ENDING;
  expected_text := expected_text + 'ToTHEBOWERS1829ByEdgarAllanPoe.pdf~~11140';
  consoleAssert('Directory files not matching', expected_text, directory_text);
end;






procedure TTestInternet.screen_j__1_of_3_files_missing();
var
   screen_text, expected_text: string;
begin
  screen_text := readAPodcast(XML_FILE_J);
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_j_internet\__screen_j__1_of_3_files_missing.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title : The SFFaudio Public Domain PDF Page' + LINE_ENDING;
  expected_text := expected_text + 'Description : Public domain PDFs.' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 3' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_j__1_of_3_files_missing.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + '2/3 : 011.16 KB : AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf' + LINE_ENDING;
  expected_text := expected_text + '3/3 : 011.97 KB : TheDwellerInTheHillsByAugustDerleth.pdf'+ LINE_ENDING;
  expected_text := expected_text + 'Failed Episodes:'+ LINE_ENDING;
  expected_text := expected_text + 'http://www.sffaudio.com/podcasts/XToTHEBOWERS1829ByEdgarAllanPoe.pdf'+ LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : C:\Users\steen\Desktop\__screen_j__1_of_3_files_missing.xml\';
  consoleAssert('Screen files not matching', expected_text, screen_text);
end;





procedure TTestInternet.directory_k__1_of_3_files_missing();
var
  directory_text, expected_text: string;
   outputPath: string;
begin
  outputPath := deskDirName(XML_FILE_K);
  clearOutputDir(outputPath);
  readAPodcast(XML_FILE_K);
  directory_text :=filesWithSizes(outputPath);
  expected_text := '__directory_k__1_of_3_files_missing.xml~~2571' + LINE_ENDING;
  expected_text := expected_text + '_partial_XToTHEBOWERS1829ByEdgarAllanPoe.pdf~~0' + LINE_ENDING;
  expected_text := expected_text + 'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING;
  expected_text := expected_text + 'TheDwellerInTheHillsByAugustDerleth.pdf~~12261';
  consoleAssert('Directory One file is missing',  expected_text, directory_text);
end;








procedure TTestInternet.screen_l__no_new_episodes();
var
  screen_text, outputPath, expected_text: string;
begin
  outputPath := deskDirName(XML_FILE_L);
  clearOutputDir(outputPath);
  readAPodcast(XML_FILE_L);
  screen_text := readAPodcast(XML_FILE_L);     //read again, for no new episodes
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_l_internet\__screen_l__no_new_episodes.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title : The SFFaudio Public Domain PDF Page' + LINE_ENDING;
  expected_text := expected_text + 'Description : Public domain PDFs.' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 3' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_l__no_new_episodes.xml' + LINE_ENDING;
  expected_text := expected_text +  LINE_ENDING;
  expected_text := expected_text + 'No new episodes to download' + LINE_ENDING;
  consoleAssert('Have all episodes in dir', expected_text, screen_text);
end;


procedure TTestInternet.screen_m__no_such_file();
begin
     try
        readAPodcast(XML_FILE_M);
     except
          on E: Exception do
         AssertEquals('bail on file does not exist', E.ClassName, 'EFOpenError');
     end;
end;




procedure TTestInternet.screen_n__not_a_podcast();
var
  screen_text, expected_text: string;
begin
  screen_text := readAPodcast(XML_FILE_N);
  expected_text := 'Download all episodes of a podcast, only downloads needed files. Hit Escape key to stop program.' + LINE_ENDING;
  expected_text := expected_text + 'e.g.  https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Enter Podcast URL : tconsole_n_internet\__screen_n__not_a_podcast.xml' + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + LINE_ENDING;
  expected_text := expected_text + 'Podcast Title :' + LINE_ENDING;
  expected_text := expected_text + 'Description :' + LINE_ENDING;
  expected_text := expected_text + 'Episodes : 0' + LINE_ENDING;
  expected_text := expected_text + 'Destination Folder : THE_DESKTOP--__screen_n__not_a_podcast.xml' + LINE_ENDING;
  expected_text := expected_text +  LINE_ENDING;
  expected_text := expected_text + 'No podcast episodes found' + LINE_ENDING;
  consoleAssert('Have all episodes in dir', expected_text, screen_text);
end;






initialization

  RegisterTest(TTestInternet);
end.






