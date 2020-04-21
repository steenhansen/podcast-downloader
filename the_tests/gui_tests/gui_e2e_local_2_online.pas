unit gui_e2e_local_2_online;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, Dialogs, Forms;

type

  T_fast_e2e_local_online = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure process_test_4_e2e_local_to_online_click_3rd();
    procedure process_test_5_e2e_local_to_online_anecdote();
    procedure process_test_6_e2e_local_to_online_all();
    procedure process_test_7_e2e_local_to_online_none();
  end;

implementation

uses
  form_events,
  gui_support,
  test_support,
  process_data,
  consts_types;

procedure T_fast_e2e_local_online.SetUp;
begin
  g_podcast_form.Show();
end;


procedure T_fast_e2e_local_online.Teardown;
begin
  g_podcast_form.Hide();
end;



procedure T_fast_e2e_local_online.process_test_4_e2e_local_to_online_click_3rd();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
begin
  xmlFile := xmlFileName('test_4_e2e_local_to_online_click_3rd');
  outputPath := outputPathName('test_4_e2e_local_to_online_click_3rd');
  clearOutputDir(outputPath);

  allPossibleFileSize := process_a_podcast(xmlFile);
  fileSizeChecked := process_b_choices(2, ARE_TESTING);
  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);

  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;


  memActualText := filesWithSizes(outputPath);

  memExpectedText := '_rss_test_4_e2e_local_to_online_click_3rd.xml~~2645' + LINE_ENDING +
    'TheDwellerInTheHillsByAugustDerleth.pdf~~12261' + LINE_ENDING;

  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 12261, fileSizeChecked);
  AssertEquals('Number successful files', 1, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'T_fast_e2e_local_online.process_test_4_e2e_local_to_online_click_3rd');

end;


procedure T_fast_e2e_local_online.process_test_5_e2e_local_to_online_anecdote();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
  checked_and_total_size: TCheckedAndTotalSize;
begin
  xmlFile := xmlFileName('test_5_e2e_local_to_online_anecdote');
  outputPath := outputPathName('test_5_e2e_local_to_online_anecdote');
  clearOutputDir(outputPath);
  allPossibleFileSize := process_a_podcast(xmlFile);


  checked_and_total_size := process_b_filter('anecdote');
  fileSizeChecked := checked_and_total_size.fileSizeChecked;


  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);
  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;
  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_5_e2e_local_to_online_anecdote.xml~~2646' + LINE_ENDING +
    'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 11431, fileSizeChecked);
  AssertEquals('Number successful files', 1, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_5_e2e_local_to_online_anecdote');
end;




procedure T_fast_e2e_local_online.process_test_6_e2e_local_to_online_all();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
begin
  xmlFile := xmlFileName('test_6_e2e_local_to_online_all');
  outputPath := outputPathName('test_6_e2e_local_to_online_all');
  clearOutputDir(outputPath);

  allPossibleFileSize := process_a_podcast(xmlFile);
  fileSizeChecked := process_b_all();
  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);



  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;
  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_6_e2e_local_to_online_all.xml~~2647' + LINE_ENDING +
    'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING +
    'TheDwellerInTheHillsByAugustDerleth.pdf~~12261' + LINE_ENDING + 'ToTHEBOWERS1829ByEdgarAllanPoe.pdf~~11140' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 34832, fileSizeChecked);
  AssertEquals('Number successful files', 3, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_6_e2e_local_to_online_all');
end;


procedure T_fast_e2e_local_online.process_test_7_e2e_local_to_online_none();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
begin
  xmlFile := xmlFileName('test_7_e2e_local_to_online_none');
  outputPath := outputPathName('test_7_e2e_local_to_online_none');
  clearOutputDir(outputPath);
  allPossibleFileSize := process_a_podcast(xmlFile);

  fileSizeChecked := process_b_none();

  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);
  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;
  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_7_e2e_local_to_online_none.xml~~2645' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 0, fileSizeChecked);
  AssertEquals('Number successful files', 0, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_7_e2e_local_to_online_none');
end;




initialization

  RegisterTest(T_fast_e2e_local_online);
end.









