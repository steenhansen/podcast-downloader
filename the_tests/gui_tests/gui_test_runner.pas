program gui_test_runner;

uses
  Forms,
  Interfaces,
  GuiTestRunner,
  form_podcast_4,
  unit_episode_bits,
  unit_xml_episode,
  gui_e2e_local_2_local,
  dir_list_differences,
  gui_e2e_local_2_online,
  gui_support,
  test_support,
  episode_bits;

{$R *.res}

begin
  Application.Title := 'gui_test_runner';
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.CreateForm(TPodcastForm4, g_podcast_form);
  Application.CreateForm(TfrmTestDirListDifference, frmTestDirListDifference);
  Application.Run;
end.
.
