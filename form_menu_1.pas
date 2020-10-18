unit form_menu_1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ComCtrls, ExtCtrls, Buttons,
  gui_state;

type

  { TMenuForm1 }

  TMenuForm1 = class(TForm)
    btnReadRss: TButton;
    edRssUrl: TEdit;
    edtCopyableExample: TEdit;
    gbPodcastDescription: TGroupBox;
    gbPodcastFeed: TGroupBox;
    ImageList1: TImageList;
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
    menuHardcoreHistory: TMenuItem;
    menuLispCast: TMenuItem;
    N3: TMenuItem;
    menuInstructions: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    menuNews: TMenuItem;
    menuQuit: TMenuItem;
    menuAbout: TMenuItem;
    menuJoeRogan: TMenuItem;
    menuNasa: TMenuItem;
    menuNHK: TMenuItem;
    menuPdf: TMenuItem;
    menuPhpRoundTable: TMenuItem;
    menuRsd: TMenuItem;
    menuSffAudio: TMenuItem;
    menuSffPodcast: TMenuItem;
    menuSiberian: TMenuItem;
    menuTedTalk: TMenuItem;
    menuThisAmericanLife: TMenuItem;
    menuVideo: TMenuItem;
    SpeedButton1: TSpeedButton;

    procedure edRssUrlKeyDown_1(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1Click(Sender: TObject);
    procedure menuAboutClick(Sender: TObject);
    procedure menuInstructionsClick(Sender: TObject);
    procedure menuHardcoreHistoryClick(Sender: TObject);
    procedure menuLispCastClick(Sender: TObject);
    procedure menuQuitClick(Sender: TObject);
    procedure menuChannelNineClick(Sender: TObject);
    procedure menuAljazeeraClick(Sender: TObject);
    procedure menuBBCClick(Sender: TObject);
    procedure menuCbcBCClick(Sender: TObject);
    procedure menuNHKClick(Sender: TObject);
    procedure menuSffPodcastClick(Sender: TObject);
    procedure menuRsdClick(Sender: TObject);
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
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton1DblClick(Sender: TObject);
  protected
    FStateOfGui: TGuiState;
    FStartStopIO: string;
  end;

var
  menu_form: TMenuForm1;

implementation

uses
  LCLIntf,
  process_data,
  form_about,
  form_instructions,
  form_cancel_2,
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

procedure TMenuForm1.menuRsdClick(Sender: TObject);
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


procedure TMenuForm1.Image1Click(Sender: TObject);
begin

end;

procedure TMenuForm1.menuAboutClick(Sender: TObject);
begin
  AboutForm.ShowModal();
end;

procedure TMenuForm1.menuInstructionsClick(Sender: TObject);
begin
        InstructionsForm.ShowModal();
end;

procedure TMenuForm1.menuHardcoreHistoryClick(Sender: TObject);
begin
      translateUrl('http://feeds.feedburner.com/dancarlin/history');
end;

procedure TMenuForm1.menuLispCastClick(Sender: TObject);
begin
      translateUrl('https://feeds.transistor.fm/thoughts-on-functional-programming-podcast-by-eric-normand');
end;




procedure TMenuForm1.edtCopyableExampleClick_1(Sender: TObject);
begin
  edtCopyableExample.SelectAll;
end;

procedure TMenuForm1.SpeedButton1Click(Sender: TObject);
begin
    OpenURL('https://www.listennotes.com/search/?q=mark%20blyth&sort_by_date=0');
end;

procedure TMenuForm1.SpeedButton1DblClick(Sender: TObject);
begin
       OpenURL('https://www.listennotes.com/search/?q=mark%20blyth&sort_by_date=0');
end;



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


     on E : Exception do
     begin

           ShowMessage(e.ClassName + 'error raised with message : ' + E.Message);

          FreeAndNil(g_selection_mediator);
          FStateOfGui.setState(GUI_AFTER_A_URL_2);
          if  FStartStopIO = '' then
          begin
               rss_url_404_mess := 'The URL ' + edRssUrl.Text + ' is not an RSS file.';
               MessageDlgEx(rss_url_404_mess, mtInformation, [mbOK], g_podcast_form);
          end;
     end;







  end;
end;


procedure TMenuForm1.edRssUrlChange_1(Sender: TObject);
begin
  g_podcast_form.btnStopClick_2(nil);
  FStateOfGui.beforeOrAfterUrl(edRssUrl.Text);
end;



end.
