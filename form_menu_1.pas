unit form_menu_1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ComCtrls,
  gui_state;

type

  { TMenuForm1 }

  TMenuForm1 = class(TForm)
    btnReadRss: TButton;
    edRssUrl: TEdit;
    edtCopyableExample: TEdit;
    gbPodcastDescription: TGroupBox;
    gbPodcastFeed: TGroupBox;
    lblExample: TLabel;
    lblPodcastDescription: TLabel;
    MainMenu1: TMainMenu;

    menuAljazeera: TMenuItem;
    menuAudio: TMenuItem;
    menuBBC: TMenuItem;
    menuBostonGlobe: TMenuItem;
    menuCbcBC: TMenuItem;
    menuChannel9: TMenuItem;
    menuExamples: TMenuItem;
    menuHeist: TMenuItem;
    menuImages: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    menuJoeRogan: TMenuItem;
    menuNasa: TMenuItem;
    menuNHK: TMenuItem;
    menuPdf: TMenuItem;
    menuPhpRoundTable: TMenuItem;
    menuRsdClick: TMenuItem;
    menuSffAudio: TMenuItem;
    menuSffPodcast: TMenuItem;
    menuSiberian: TMenuItem;
    menuTedTalk: TMenuItem;
    menuThisAmericanLife: TMenuItem;
    menuVideo: TMenuItem;

    procedure edRssUrlKeyDown_1(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure menuQuitClick(Sender: TObject);
    procedure menuChannelNineClick(Sender: TObject);
    procedure menuAljazeeraClick(Sender: TObject);
    procedure menuBBCClick(Sender: TObject);
    procedure menuCbcBCClick(Sender: TObject);
    procedure menuNHKClick(Sender: TObject);
    procedure menuSffPodcastClick(Sender: TObject);
    procedure menuRsdClickClick(Sender: TObject);
    procedure menuSiberianClick(Sender: TObject);
    procedure menuSmithsonianPhotosClick(Sender: TObject);
    procedure menuHeistClick(Sender: TObject);
    procedure menuTedTalkClick(Sender: TObject);
    procedure menuJoeRoganClick(Sender: TObject);
    procedure menuThisAmericanLifeClick(Sender: TObject);
    procedure menuPhpRoundTableClick(Sender: TObject);
    procedure menuNasaClick(Sender: TObject);
    procedure menuSffPDFClick(Sender: TObject);

    procedure edRssUrlChange_1(Sender: TObject);
    procedure btnReadRssClick_1(Sender: TObject);
    procedure edtCopyableExampleClick_1(Sender: TObject);
  protected
    FStateOfGui: TGuiState;
    FStartStopIO: string;
  end;

var
  menu_form: TMenuForm1;

implementation

uses
  process_data,
  form_podcast_4;

{$R *.lfm}
procedure translateUrl(podcast_url: string);
begin
  with g_podcast_form do
  begin
    edRssUrl.Text := podcast_url;
  end;
end;

procedure TMenuForm1.menuQuitClick(Sender: TObject);
begin
  g_podcast_form.quitProgram();
end;



procedure TMenuForm1.menuChannelNineClick(Sender: TObject);
begin
  translateUrl('https://s.ch9.ms/Events/MIX/MIX11/RSS/mp4high');
end;

procedure TMenuForm1.menuAljazeeraClick(Sender: TObject);
begin
  translateUrl('http://feeds.aljazeera.net/podcasts/featureddocumentariesHD');
end;

procedure TMenuForm1.menuBBCClick(Sender: TObject);
begin
  translateUrl('https://podcasts.files.bbci.co.uk/p02nq0gn.rss');
end;

procedure TMenuForm1.menuCbcBCClick(Sender: TObject);
begin
  translateUrl('https://www.cbc.ca/podcasting/includes/bcalmanac.xml');
end;

procedure TMenuForm1.menuNHKClick(Sender: TObject);
begin
  translateUrl('https://www3.nhk.or.jp/rj/podcast/rss/english.xml');
end;

procedure TMenuForm1.menuSffPodcastClick(Sender: TObject);
begin
  translateUrl('https://sffaudio.herokuapp.com/podcast/rss');
end;

procedure TMenuForm1.menuRsdClickClick(Sender: TObject);
begin
  translateUrl('https://sffaudio.herokuapp.com/rsd/rss');
end;

procedure TMenuForm1.menuSiberianClick(Sender: TObject);
begin
  translateUrl('https://siberiantimes.com/ecology/rss/');
end;

procedure TMenuForm1.menuSmithsonianPhotosClick(Sender: TObject);
begin
  translateUrl('https://www.smithsonianmag.com/rss/photos/');
end;

procedure TMenuForm1.menuHeistClick(Sender: TObject);
begin
  translateUrl('https://heistpodcast.libsyn.com/rss');
end;

procedure TMenuForm1.menuTedTalkClick(Sender: TObject);
begin
  translateUrl('http://feeds.feedburner.com/TEDTalks_video');
end;

procedure TMenuForm1.menuJoeRoganClick(Sender: TObject);
begin
  translateUrl('http://joeroganexp.joerogan.libsynpro.com/rss');
end;

procedure TMenuForm1.menuThisAmericanLifeClick(Sender: TObject);
begin
  translateUrl('https://ia801605.us.archive.org/25/items/tefc16_gmail_Tal/tal.xml');
end;

procedure TMenuForm1.menuPhpRoundTableClick(Sender: TObject);
begin
  translateUrl('http://feeds.feedburner.com/PhpRoundtable');
end;

procedure TMenuForm1.menuNasaClick(Sender: TObject);
begin
  translateUrl('https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss');
end;

procedure TMenuForm1.menuSffPDFClick(Sender: TObject);
begin
  translateUrl('https://sffaudio.herokuapp.com/pdf/rss');
end;

procedure TMenuForm1.edRssUrlChange_1(Sender: TObject);
begin
  FStateOfGui.beforeAfterUrl(edRssUrl.Text);
end;

procedure TMenuForm1.edRssUrlKeyDown_1(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  text_length:integer;
{$push}{$warn 5024 off}// Shift not used
begin
  text_length := length(edRssUrl.Text);
  if (Key=13) AND (text_length>8) then
    btnReadRssClick_1(nil);
end;
{$pop}

procedure TMenuForm1.btnReadRssClick_1(Sender: TObject);
var
  rss_url_404_mess, not_rss_podcast_file: string;
  number_episodes: integer;
begin
  FStartStopIO := '';
  FStateOfGui.setState(GUI_WHILE_PARSING_RSS_3);
  try
    number_episodes := process_a_podcast(edRssUrl.Text);
    if number_episodes = 0 then
    begin
      not_rss_podcast_file := 'The URL ' + edRssUrl.Text + ' has no podcast episodes.';
      MessageDlgEx(not_rss_podcast_file, mtInformation, [mbOK], g_podcast_form);
      FStateOfGui.setState(GUI_AFTER_A_URL_2);
    end
    else
      FStateOfGui.setState(GUI_AFTER_RSS_PROCESSED_4);
  except
    FreeAndNil(g_selection_mediator);
    FStateOfGui.setState(GUI_AFTER_A_URL_2);
    rss_url_404_mess := 'The URL ' + edRssUrl.Text + ' doesn''t respond.';
    MessageDlgEx(rss_url_404_mess, mtInformation, [mbOK], g_podcast_form);
  end;
end;

procedure TMenuForm1.edtCopyableExampleClick_1(Sender: TObject);
begin
  edtCopyableExample.SelectAll;
end;

end.
