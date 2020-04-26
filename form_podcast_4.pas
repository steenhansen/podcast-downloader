unit form_podcast_4;

{$mode objfpc}{$H+}

interface

uses
  //debug_server,

  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, LCLType,
  Buttons, Menus, ActnList, ComCtrls, regexpr, LazFileUtils, lazlogger, BCMDButton,

  form_events_3, gui_state, selection_mediator;

type
  { TPodcastForm4 }

  TPodcastForm4 = class(TEventsForm3)
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure quitProgram();
  end;

var
  g_podcast_form: TPodcastForm4;
  g_selection_mediator: TSelectionMediator;

implementation

uses
  consts_types;

{$R *.lfm}

procedure TPodcastForm4.FormCreate(Sender: TObject);
begin
  inherited;
  KeyPreview := True; // to detect 'esc' key
  FStateOfGui := TGuiState.Create(g_podcast_form);
  FStateOfGui.initCaptions();
  g_selection_mediator.readingRss(g_podcast_form, 0);
end;

procedure TPodcastForm4.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = ESCAPE_KEY then
    FStartStopIO := GUI_ESCAPE_KEY_QUIT;
end;

procedure TPodcastForm4.FormActivate(Sender: TObject);
begin
  g_selection_mediator := nil;
  FStateOfGui.setState(GUI_AFTER_A_URL_2);
end;

procedure TPodcastForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$push}{$warn 5024 off}// CloseAction not used
begin
  inherited;
  FreeAndNil(FStateOfGui);
  FreeAndNil(g_selection_mediator);
end;
{$pop}

procedure TPodcastForm4.quitProgram();
begin
  Close();
end;

end.
