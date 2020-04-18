program gui_podcast_downloader;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces,    // NB - Bug Fix - https://forum.lazarus.freepascal.org/index.php?topic=7143.0
  Forms,

  form_events,
  download_stream,
  xml_episode,
  rss_podcast,
  checks_descriptions,
  episode_bits,
  process_data,
  consts_types,
  progress_stream;

{$R *.res}



begin
  RequireDerivedFormResource := True;
  Application.Title:='Podcast-Downloader';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TPodcastForm, podcastForm);
  Application.Run;
end.
