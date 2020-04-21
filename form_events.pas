unit form_events;

{$mode objfpc}{$H+}

interface
uses
  //debug_server,

  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, CheckLst, Menus, ActnList, ComCtrls, regexpr, LazFileUtils, lazlogger, BCMDButton, Types,

  gui_state,
  selection_mediator,
  checks_descriptions;

type

  { TPodcastForm }

  TPodcastForm = class(TForm)
    clbEpisodeFiles: TCheckListBox;
    gbEpisodesToDownload: TGroupBox;
    lblDownloadingXofY: TLabel;
    lbEpisodeDesc: TListBox;
    lbEpisodeTitle: TListBox;
    memFailedFiles: TMemo;
    menuAudio: TMenuItem;
    menuBostonGlobe: TMenuItem;
    menuHeist: TMenuItem;
    MenuItem1: TMenuItem;
    menuSffPodcast: TMenuItem;
    menuRsdClick: TMenuItem;
    menuJoeRogan: TMenuItem;
    menuThisAmericanLife: TMenuItem;
    menuPhpRoundTable: TMenuItem;
    btnDownloadChecked: TBCMDButton;
    btnCancel: TBCMDButton;
    btnReadRss: TButton;
    btnDirectoryChange: TButton;
    btnDownloadAll: TButton;
    btnDownloadFiltered: TButton;
    btnDownloadNone: TButton;
    edtCopyableExample: TEdit;
    edRssUrl: TEdit;
    edtTextFilter: TEdit;
    gbFailedEpisodes: TGroupBox;
    gbPodcastDescription: TGroupBox;
    gbSelectDirectory: TGroupBox;
    gbPodcastFeed: TGroupBox;
    grTextFilter: TGroupBox;
    downloadBtnPanel: TPanel;
    MainMenu1: TMainMenu;
    menuExamples: TMenuItem;
    menuChannel9: TMenuItem;
    menuTedTalk: TMenuItem;
    menuImages: TMenuItem;
    menuNasa: TMenuItem;
    menuPdf: TMenuItem;
    menuVideo: TMenuItem;
    menuSffAudio: TMenuItem;
    cancelBtnPanel: TPanel;
    lblPodcastDescription: TLabel;
    lblExample: TLabel;
    edtSaveDirectory: TEdit;
    pnlCheckEpisodes: TPanel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    splFirst: TSplitter;
    splSecond: TSplitter;
    upDownFiltered: TUpDown;

    procedure btnCancelMouseEnter(Sender: TObject);
    procedure btnCancelMouseLeave(Sender: TObject);
    procedure btnDownloadCheckedMouseEnter(Sender: TObject);
    procedure btnDownloadCheckedMouseLeave(Sender: TObject);
    procedure btnReadRssClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnDownloadAllClick(Sender: TObject);
    procedure clbEpisodeFilesItemClick(Sender: TObject; Index: integer);
    procedure downloadCheckedEpisodes(Sender: TObject);
    procedure btnDownloadFilteredClick(Sender: TObject);
    procedure btnDownloadNoneClick(Sender: TObject);
    procedure edtCopyableExampleClick(Sender: TObject);
    procedure edRssUrlChange(Sender: TObject);
    procedure edtTextFilterChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure lbEpisodeDescClick(Sender: TObject);
    procedure lbEpisodeDescSelectionChange(Sender: TObject; User: boolean);
    procedure channelNineClick(Sender: TObject);
    procedure menuSffPodcastClick(Sender: TObject);
    procedure menuRsdClickClick(Sender: TObject);
    procedure menuSmithsonianPhotosClick(Sender: TObject);
    procedure menuHeistClick(Sender: TObject);
    procedure menuTedTalkClick(Sender: TObject);
    procedure menuJoeRoganClick(Sender: TObject);
    procedure menuThisAmericanLifeClick(Sender: TObject);
    procedure menuPhpRoundTableClick(Sender: TObject);
    procedure menuNasaClick(Sender: TObject);
    procedure menuSffAudioClick(Sender: TObject);
    procedure selectDirBtn(Sender: TObject);
    procedure DoOnWriteEpisode(Sender: TObject; APosition: int64; fileNumber: integer);
    procedure DoOnFailedReadEpisode(Sender: TObject; mediaUrl: string);
    procedure DoOnReadPodcast(Sender: TObject; APosition: int64; fileNumber: integer);
    procedure DoOnFailedReadPodcast(Sender: TObject; mediaUrl: string);
    procedure splFirstMoved(Sender: TObject);
    procedure splSecondMoved(Sender: TObject);
    procedure upDownFilteredClick(Sender: TObject; Button: TUDBtnType);
  private
    FStateOfGui: TGuiState;
      FViewSearchMatch, FViewSearchCount: integer;
        FStartStopIO: string;
  public
    EndProc:
    procedure of object;
    procedure DoScrollclbEpisodeFiles(Sender: TObject);
    procedure DoScrolllbEpisodeTitle(Sender: TObject);
    procedure DoScrolllbEpisodeDesc(Sender: TObject);
    procedure DoDrawItemclbEpisodeFiles(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure DoDrawItemlbEpisodeTitle(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure DoDrawItemlbEpisodeDesc(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
  end;

var
  g_podcast_form: TPodcastForm;
  g_selection_mediator: TSelectionMediator;




implementation

uses
  process_data,
  consts_types;

{$R *.lfm}

function MessageDlgEx(const AMsg: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; AParent: TForm): TModalResult;
var
  MsgFrm: TForm;
begin
  MsgFrm := CreateMessageDialog(AMsg, ADlgType, AButtons);
  try
    MsgFrm.Position := poDefaultSizeOnly;
    MsgFrm.FormStyle := fsSystemStayOnTop;
    MsgFrm.Left := AParent.Left + (AParent.Width - MsgFrm.Width) div 2;
    MsgFrm.Top := AParent.Top + (AParent.Height - MsgFrm.Height) div 2;
    Result := MsgFrm.ShowModal;
  finally
    MsgFrm.Free
  end;
end;

procedure TPodcastForm.edRssUrlChange(Sender: TObject);
begin

  FStateOfGui.beforeAfterUrl(edRssUrl.Text);
end;

procedure TPodcastForm.selectDirBtn(Sender: TObject);
begin
  SelectDirectoryDialog1.InitialDir := AppendPathDelim(GetUserDir + 'Desktop');
  if SelectDirectoryDialog1.Execute then
    edtSaveDirectory.Text := SelectDirectoryDialog1.FileName;
end;

procedure TPodcastForm.channelNineClick(Sender: TObject);
begin
  edRssUrl.Text := 'https://s.ch9.ms/Events/MIX/MIX11/RSS/mp4high';
  btnReadRss.Click();

end;

procedure TPodcastForm.menuSffPodcastClick(Sender: TObject);
begin
           edRssUrl.Text := 'https://sffaudio.herokuapp.com/podcast/rss';
  btnReadRss.Click();


end;

procedure TPodcastForm.menuRsdClickClick(Sender: TObject);
begin


          edRssUrl.Text := 'https://sffaudio.herokuapp.com/rsd/rss';
  btnReadRss.Click();

end;

procedure TPodcastForm.menuSmithsonianPhotosClick(Sender: TObject);
begin
  edRssUrl.Text := 'https://www.smithsonianmag.com/rss/photos/';
  btnReadRss.Click();
end;

procedure TPodcastForm.menuHeistClick(Sender: TObject);
begin
  edRssUrl.Text := 'https://heistpodcast.libsyn.com/rss';
  btnReadRss.Click();
end;

procedure TPodcastForm.menuTedTalkClick(Sender: TObject);
begin
  edRssUrl.Text := 'http://feeds.feedburner.com/TEDTalks_video';
  btnReadRss.Click();
end;

procedure TPodcastForm.menuJoeRoganClick(Sender: TObject);
begin
  edRssUrl.Text := 'http://joeroganexp.joerogan.libsynpro.com/rss';
  btnReadRss.Click();

end;

procedure TPodcastForm.menuThisAmericanLifeClick(Sender: TObject);
begin
  edRssUrl.Text := 'https://ia801605.us.archive.org/25/items/tefc16_gmail_Tal/tal.xml';
  btnReadRss.Click();
end;

procedure TPodcastForm.menuPhpRoundTableClick(Sender: TObject);
begin
  edRssUrl.Text := 'http://feeds.feedburner.com/PhpRoundtable';
  btnReadRss.Click();
end;

procedure TPodcastForm.menuNasaClick(Sender: TObject);
begin
  edRssUrl.Text := 'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss';
  btnReadRss.Click();
end;

procedure TPodcastForm.menuSffAudioClick(Sender: TObject);
begin
  edRssUrl.Text := 'https://sffaudio.herokuapp.com/pdf/rss';
  btnReadRss.Click();
end;

procedure TPodcastForm.DoScrollclbEpisodeFiles(Sender: TObject);
begin
  lbEpisodeDesc.TopIndex := clbEpisodeFiles.TopIndex;
  lbEpisodeTitle.TopIndex := clbEpisodeFiles.TopIndex;
end;

procedure TPodcastForm.DoScrolllbEpisodeTitle(Sender: TObject);
begin
  clbEpisodeFiles.TopIndex := lbEpisodeTitle.TopIndex;
  lbEpisodeDesc.TopIndex := lbEpisodeTitle.TopIndex;
end;

procedure TPodcastForm.DoScrolllbEpisodeDesc(Sender: TObject);
begin
  clbEpisodeFiles.TopIndex := lbEpisodeDesc.TopIndex;
  lbEpisodeTitle.TopIndex := lbEpisodeDesc.TopIndex;
end;

procedure TPodcastForm.btnDownloadAllClick(Sender: TObject);
begin
  process_b_all();
  FStateOfGui.setState(GUI_ONE_CHECKMARK_5);
end;

procedure TPodcastForm.btnDownloadNoneClick(Sender: TObject);
begin

  process_b_none();
  FStateOfGui.setState(GUI_AFTER_RSS_PROCESSED_4);
end;

procedure TPodcastForm.edtCopyableExampleClick(Sender: TObject);
begin
  edtCopyableExample.SelectAll;
end;

procedure TPodcastForm.btnReadRssClick(Sender: TObject);
var
  rss_url_404_mess, not_rss_podcast_file: string;
  number_episodes: integer;
begin
  FStartStopIO := '';
  edtTextFilter.Text := '';
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

procedure TPodcastForm.clbEpisodeFilesItemClick(Sender: TObject; Index: integer);
var
  curState, checkedCount: integer;
begin
  curState := FStateOfGui.getState();
  if curState < GUI_WHILE_DOWNLOADING_6 then
  begin
    process_b_choices(Index);
    checkedCount := g_selection_mediator.checkedCount(clbEpisodeFiles);
    if checkedCount = 0 then
      FStateOfGui.setState(GUI_AFTER_RSS_PROCESSED_4)
    else
      FStateOfGui.setState(GUI_ONE_CHECKMARK_5);
  end
  else
    clbEpisodeFiles.Checked[Index] := not clbEpisodeFiles.Checked[Index];
end;


procedure TPodcastForm.splFirstMoved(Sender: TObject);
var
  middle_of_box, min_split_left, max_split_left: integer;
begin
  middle_of_box := Round(gbEpisodesToDownload.Width / 2);
  max_split_left := gbEpisodesToDownload.Width - 32;
  min_split_left := 32;
  if splFirst.left >= max_split_left then
    splFirst.left := max_split_left
  else if splFirst.left <= min_split_left then
    splFirst.left := min_split_left;
  if splFirst.left >= splSecond.left then
    if splFirst.left > middle_of_box then
      splFirst.left := splFirst.left - 32
    else
      splSecond.left := splSecond.left + 32;
end;

procedure TPodcastForm.splSecondMoved(Sender: TObject);
var
  middle_of_box, min_split_left, max_split_left: integer;
begin
  middle_of_box := Round(gbEpisodesToDownload.Width / 2);
  max_split_left := gbEpisodesToDownload.Width - 32;
  min_split_left := 32;
  if splSecond.left >= max_split_left then
    splSecond.left := max_split_left
  else if splSecond.left <= min_split_left then
    splSecond.left := min_split_left;
  if splFirst.left >= splSecond.left then
    if splFirst.left > middle_of_box then
      splFirst.left := splFirst.left - 32
    else
      splSecond.left := splSecond.left + 32;
end;



procedure TPodcastForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$push}{$warn 5024 off}// CloseAction not used
begin
  FStateOfGui.Free();
  FreeAndNil(g_selection_mediator);
end;

 {$pop}

procedure TPodcastForm.btnCancelMouseEnter(Sender: TObject);
begin
  cancelBtnPanel.BevelColor := STOP_RED;
end;

procedure TPodcastForm.btnCancelMouseLeave(Sender: TObject);
begin
  cancelBtnPanel.BevelColor := STANDARD_HOVER_EDGE;
end;

procedure TPodcastForm.btnDownloadCheckedMouseEnter(Sender: TObject);
begin
  downloadBtnPanel.BevelColor := STANDARD_HOVER_EDGE;
end;

procedure TPodcastForm.btnDownloadCheckedMouseLeave(Sender: TObject);
begin
  downloadBtnPanel.BevelColor := START_GREEN;
end;

procedure TPodcastForm.downloadCheckedEpisodes(Sender: TObject);
var
  urlToRead, saveDir, finishMess: string;
  succesfulDownloads, failedDownloads: integer;
  failsAndSuccesses: TFailsAndSuccesses;
begin
  try
    urlToRead := edRssUrl.Text;
    saveDir := edtSaveDirectory.Text;
    clbEpisodeFiles.ClearSelection();
    FStateOfGui.setState(GUI_WHILE_DOWNLOADING_6);
    failsAndSuccesses := process_c_episodes(urlToRead, saveDir);
    succesfulDownloads := failsAndSuccesses.successCount;
    failedDownloads := failsAndSuccesses.failedCount;
    finishMess := FStateOfGui.finishedMess(succesfulDownloads, failedDownloads);
    FStateOfGui.setState(GUI_AFTER_FINISHED_7);
    MessageDlgEx(finishMess, mtInformation, [mbOK], g_podcast_form);
  finally
    FStateOfGui.setState(GUI_BEFORE_A_URL_1);            //GUI_BEFORE_A_URL_1);
    FStateOfGui.setState(GUI_AFTER_A_URL_2);            //GUI_BEFORE_A_URL_1);
    FreeAndNil(g_selection_mediator);
  end;
end;

procedure TPodcastForm.btnStopClick(Sender: TObject);
var
  gui_state: integer;
begin
  FStartStopIO := GUI_CANCEL_BUTTON_QUIT;
  gui_state := FStateOfGui.getState();
  if (gui_state = GUI_AFTER_RSS_PROCESSED_4) or (gui_state = GUI_ONE_CHECKMARK_5) then
  begin
    FStateOfGui.setState(GUI_BEFORE_A_URL_1);
        FStateOfGui.setState(GUI_AFTER_A_URL_2);            //GUI_BEFORE_A_URL_1);
    FreeAndNil(g_selection_mediator);
  end;
end;

procedure TPodcastForm.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = ESCAPE_KEY then
    FStartStopIO := GUI_ESCAPE_KEY_QUIT;
end;

procedure TPodcastForm.DoDrawItemclbEpisodeFiles(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
 {$push}{$warn 5024 off}// State not used
begin
  checkBoxDrawItem(Control, Index, ARect, lbEpisodeDesc);
end;

 {$pop}

procedure TPodcastForm.DoDrawItemlbEpisodeTitle(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
  {$push}{$warn 5024 off}// State not used
begin
  TitleListBoxDrawItem(Control, Index, ARect, lbEpisodeDesc);
end;
{$pop}

procedure TPodcastForm.DoDrawItemlbEpisodeDesc(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
{$push}{$warn 5024 off}// State not used
begin
  EpisodeListBoxDrawItem(Control, Index, ARect);
end;
{$pop}

procedure TPodcastForm.lbEpisodeDescClick(Sender: TObject);
var
  episode_index, display_number: integer;
begin
  for episode_index := 0 to (lbEpisodeDesc.Items.Count - 1) do
    if lbEpisodeDesc.Selected[episode_index] then
    begin
      display_number := lbEpisodeDesc.Items.Count - episode_index;
      g_selection_mediator.displayDescription(episode_index, display_number);
    end;
end;

{$push}{$warn 5024 off}// User not used
procedure TPodcastForm.lbEpisodeDescSelectionChange(Sender: TObject; User: boolean);
begin
  clbEpisodeFiles.TopIndex := lbEpisodeDesc.TopIndex;
  lbEpisodeTitle.TopIndex := lbEpisodeDesc.TopIndex;
end;
{$pop}

procedure TPodcastForm.DoOnReadPodcast(Sender: TObject; APosition: int64; fileNumber: integer);
{$push}{$warn 5024 off}// fileNumber not used
begin
  if FStartStopIO <> '' then
    raise ECancelException.Create(READ_EXCEPTION_PODCAST + EXCEPTION_SPACE + FStartStopIO);
  g_selection_mediator.readingRss(g_podcast_form, APosition);
  Application.ProcessMessages;
end;
{$pop}

procedure TPodcastForm.DoOnFailedReadPodcast(Sender: TObject; mediaUrl: string);
{$push}{$warn 5024 off}// mediaUrl not used
begin
  //_d('Podcast failed to read, unlike episodes, we don't do anything, this is a place holder to avoid a nil');
end;
{$pop}

procedure TPodcastForm.DoOnWriteEpisode(Sender: TObject; APosition: int64; fileNumber: integer);
var
  num_files: integer;
begin
  if FStartStopIO <> '' then
    raise ECancelException.Create(WRITE_EXCEPTION_EPISODE + EXCEPTION_SPACE + FStartStopIO);
  g_selection_mediator.readingMediaFile(clbEpisodeFiles, lbEpisodeTitle, lbEpisodeDesc, fileNumber, APosition);
  num_files := clbEpisodeFiles.Count;
  lblDownloadingXofY.Caption := 'Downloading ' + IntToStr(fileNumber + 1) + '/' + IntToStr(num_files);
  Application.ProcessMessages;
end;

// We must show failed episodes this way because the Consol app does not have any controls
procedure TPodcastForm.DoOnFailedReadEpisode(Sender: TObject; mediaUrl: string);
begin
  memFailedFiles.Lines.Add(mediaUrl);
end;

procedure TPodcastForm.FormCreate(Sender: TObject);
begin
  KeyPreview := True; // to detect 'esc' key
  clbEpisodeFiles.OnScroll := @DoScrollclbEpisodeFiles;
  lbEpisodeTitle.OnScroll := @DoScrolllbEpisodeTitle;
  lbEpisodeDesc.OnScroll := @DoScrolllbEpisodeDesc;
  clbEpisodeFiles.OnDrawItem := @DoDrawItemclbEpisodeFiles;
  lbEpisodeTitle.OnDrawItem := @DoDrawItemlbEpisodeTitle;
  lbEpisodeDesc.OnDrawItem := @DoDrawItemlbEpisodeDesc;
  FStateOfGui := TGuiState.Create(g_podcast_form);
  FStateOfGui.initCaptions();
  g_selection_mediator.readingRss(g_podcast_form, 0);
  clbEpisodeFiles.Clear;
  lbEpisodeTitle.Clear;
  lbEpisodeDesc.Clear;
end;



procedure TPodcastForm.FormActivate(Sender: TObject);
begin
  g_selection_mediator := nil;
  //  FStateOfGui.setState(GUI_BEFORE_A_URL_1);
  FStateOfGui.setState(GUI_AFTER_A_URL_2);
end;




procedure TPodcastForm.btnDownloadFilteredClick(Sender: TObject);
var
  checkedFileCount: integer;
  checked_and_total_size: TCheckedAndTotalSize;
  search_text: string;
begin
  search_text := edtTextFilter.Text;
  checked_and_total_size := process_b_filter(search_text);
  checkedFileCount := checked_and_total_size.checkedFileCount;
  if checkedFileCount = 0 then
    FStateOfGui.setState(GUI_AFTER_RSS_PROCESSED_4)
  else
    FStateOfGui.setState(GUI_ONE_CHECKMARK_5);
end;

procedure TPodcastForm.upDownFilteredClick(Sender: TObject; Button: TUDBtnType);
var
  search_text: string;
 top_episode_search_index: integer;
begin
   search_text := edtTextFilter.Text;
  top_episode_search_index := process_b_index_of_filter(search_text, FViewSearchMatch);
  clbEpisodeFiles.TopIndex := top_episode_search_index;
  lbEpisodeDesc.TopIndex := top_episode_search_index;
  lbEpisodeTitle.TopIndex := top_episode_search_index;
  if Button =btPrev then
    if FViewSearchMatch = FViewSearchCount then
      FViewSearchMatch := 0
    else
      FViewSearchMatch := FViewSearchMatch + 1
  else
    if FViewSearchMatch = 0 then
      FViewSearchMatch := FViewSearchCount
    else
      FViewSearchMatch := FViewSearchMatch - 1;
end;

 procedure TPodcastForm.edtTextFilterChange(Sender: TObject);
begin
 FViewSearchCount := g_selection_mediator.showFilterMatch(clbEpisodeFiles, lbEpisodeTitle, lbEpisodeDesc, edtTextFilter, btnDownloadFiltered);
 FViewSearchMatch := 0;
 FStateOfGui.searchButtons();
end;

end.
