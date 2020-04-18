unit gui_e2e_local_2_local;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,  Dialogs,  Forms;
type

  TTestCaseE2ELocal2Local = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published


        procedure process_test_0_e2e_local_to_local_click_3rd;
    procedure process_test_1_e2e_local_to_local_anecdote;
    procedure process_test_2_e2e_local_to_local_all();
    procedure process_test_3_e2e_local_to_local_none();
  end;

implementation
uses
  gui_support,
 test_support,
  form_events,
  process_data,
  consts_types;


procedure TTestCaseE2ELocal2Local.SetUp;
begin
  podcastForm.Show();
end;


procedure TTestCaseE2ELocal2Local.Teardown;
begin
  podcastForm.Hide();
end;



procedure TTestCaseE2ELocal2Local.process_test_0_e2e_local_to_local_click_3rd;
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
begin
  xmlFile := xmlFileName('test_0_e2e_local_to_local_click_3rd');
  outputPath := outputPathName('test_0_e2e_local_to_local_click_3rd');
  clearOutputDir(outputPath);
  allPossibleFileSize := process_a_podcast(xmlFile);

  fileSizeChecked := process_b_choices(2, ARE_TESTING);

  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);
  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;


  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_0_e2e_local_to_local_click_3rd.xml~~2600' + LINE_ENDING +
    'TheDwellerInTheHillsByAugustDerleth.pdf~~12261' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize );
  AssertEquals('Bytes of checked files', 12261, fileSizeChecked);
  AssertEquals('Number successful files', 1, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_0_e2e_local_to_local_click_3rd');
end;

procedure TTestCaseE2ELocal2Local.process_test_1_e2e_local_to_local_anecdote();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
      checked_and_total_size:   TCheckedAndTotalSize ;
begin
  xmlFile := xmlFileName('test_1_e2e_local_to_local_anecdote');
  outputPath := outputPathName('test_1_e2e_local_to_local_anecdote');
  clearOutputDir(outputPath);
  allPossibleFileSize := process_a_podcast(xmlFile);

  checked_and_total_size := process_b_filter('anecdote');
         fileSizeChecked:=           checked_and_total_size.fileSizeChecked;
  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);
  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;
  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_1_e2e_local_to_local_anecdote.xml~~2597' + LINE_ENDING +
    'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 11431, fileSizeChecked);
  AssertEquals('Number successful files', 1, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_1_e2e_local_to_local_anecdote');
end;





procedure TTestCaseE2ELocal2Local.process_test_2_e2e_local_to_local_all();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
begin
  xmlFile := xmlFileName('test_2_e2e_local_to_local_all');
  outputPath := outputPathName('test_2_e2e_local_to_local_all');
  clearOutputDir(outputPath);
  allPossibleFileSize := process_a_podcast(xmlFile);

  fileSizeChecked := process_b_all();

  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);
  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;
  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_2_e2e_local_to_local_all.xml~~2582' + LINE_ENDING +
    'AnecdoteOfTheJarByWallaceStevensPoetryMagazineOctober1919.pdf~~11431' + LINE_ENDING +
    'TheDwellerInTheHillsByAugustDerleth.pdf~~12261' + LINE_ENDING +
    'ToTHEBOWERS1829ByEdgarAllanPoe.pdf~~11140' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 34832, fileSizeChecked);
  AssertEquals('Number successful files', 3, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_2_e2e_local_to_local_all');
end;



procedure TTestCaseE2ELocal2Local.process_test_3_e2e_local_to_local_none();
var
  xmlFile, outputPath, memActualText, memExpectedText: string;
  failsAndSuccesses: TFailsAndSuccesses;
  allPossibleFileSize, fileSizeChecked, numberSuccess, numberFailed: integer;
begin
  xmlFile := xmlFileName('test_3_e2e_local_to_local_none');
  outputPath := outputPathName('test_3_e2e_local_to_local_none');
  clearOutputDir(outputPath);
  allPossibleFileSize := process_a_podcast(xmlFile);

  fileSizeChecked := process_b_none();

  failsAndSuccesses := process_c_episodes(xmlFile, outputPath);
  numberSuccess := failsAndSuccesses.successCount;
  numberFailed := failsAndSuccesses.failedCount;
  memActualText := filesWithSizes(outputPath);
  memExpectedText := '_rss_test_3_e2e_local_to_local_none.xml~~2585' + LINE_ENDING;
  AssertEquals('Bytes of all files', 34832, allPossibleFileSize);
  AssertEquals('Bytes of checked files', 0, fileSizeChecked);
  AssertEquals('Number successful files', 0, numberSuccess);
  AssertEquals('Number failed files', 0, numberFailed);
  guiDirectory(memExpectedText, memActualText, 'TTestCaseE2ELocal.process_test_3_e2e_local_to_local_none');
end;



initialization

  RegisterTest(TTestCaseE2ELocal2Local);
end.







