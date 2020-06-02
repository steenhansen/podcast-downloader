program gui_podcast_downloader;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces,    // NB - Bug Fix - https://forum.lazarus.freepascal.org/index.php?topic=7143.0
  Forms,

  form_podcast_4,
  download_stream,
  rss_podcast,
  checks_descriptions,
  episode_bits,
  process_data,
  consts_types,
  progress_stream,
  form_menu_1,
  form_cancel_2,
  form_events_3, xml_episode, form_about, form_instructions;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='Podcast-Downloader';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TPodcastForm4, g_podcast_form);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TInstructionsForm, InstructionsForm);
  Application.Run;
end.
