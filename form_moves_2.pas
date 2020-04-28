unit form_moves_2;        // form_cancel_2 more better

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, ExtCtrls,
  LazFileUtils,
  form_menu_1, BCMDButton;

type
  { TMovesForm2 }

  TMovesForm2 = class(TMenuForm1)
    btnCancel: TBCMDButton;
    btnDirectoryChange: TButton;
    btnDownloadChecked: TBCMDButton;
    cancelBtnPanel: TPanel;
    downloadBtnPanel: TPanel;
    edtSaveDirectory: TEdit;
    gbFailedEpisodes: TGroupBox;
    gbSelectDirectory: TGroupBox;
    lblDownloadingXofY: TLabel;
    memFailedFiles: TMemo;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnDownloadCheckedMouseLeave_2(Sender: TObject);
    procedure btnDownloadCheckedMouseEnter_2(Sender: TObject);
    procedure downloadCheckedEpisodes_2(Sender: TObject);
    procedure btnCancelMouseEnter_2(Sender: TObject);
    procedure btnCancelMouseLeave_2(Sender: TObject);
    procedure btnStopClick_2(Sender: TObject);
    procedure gbSelectDirectoryClick(Sender: TObject);
    procedure selectDirBtn_2(Sender: TObject);
    procedure DoOnFailedReadEpisode_2(Sender: TObject; mediaUrl: string);
    procedure DoOnReadPodcast_2(Sender: TObject; APosition: int64; fileNumber: integer);
    procedure DoOnFailedReadPodcast_2(Sender: TObject; mediaUrl: string);
  end;

var
  unused_move_form: TMovesForm2;

implementation

{$R *.lfm}

uses
  form_podcast_4, consts_types, process_data, gui_state;

procedure TMovesForm2.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TMovesForm2.btnDownloadCheckedMouseLeave_2(Sender: TObject);
begin
  with g_podcast_form do
  begin
    downloadBtnPanel.BevelColor := START_GREEN;
  end;
end;

procedure TMovesForm2.btnDownloadCheckedMouseEnter_2(Sender: TObject);
begin
  downloadBtnPanel.BevelColor := STANDARD_HOVER_EDGE;
end;

procedure TMovesForm2.btnCancelMouseEnter_2(Sender: TObject);
begin
  cancelBtnPanel.BevelColor := STOP_RED;
end;

procedure TMovesForm2.btnCancelMouseLeave_2(Sender: TObject);
begin
  cancelBtnPanel.BevelColor := STANDARD_HOVER_EDGE;
end;

procedure TMovesForm2.btnStopClick_2(Sender: TObject);
var
  gui_state: integer;
begin
  FStartStopIO := GUI_CANCEL_BUTTON_QUIT;
  gui_state := FStateOfGui.getState();
  if (gui_state = GUI_AFTER_RSS_PROCESSED_4) or (gui_state = GUI_ONE_CHECKMARK_5) then
  begin
    FStateOfGui.setState(GUI_BEFORE_A_URL_1);
    FStateOfGui.setState(GUI_AFTER_A_URL_2);
    FreeAndNil(g_selection_mediator);
  end;
end;

procedure TMovesForm2.gbSelectDirectoryClick(Sender: TObject);
begin

end;

procedure TMovesForm2.selectDirBtn_2(Sender: TObject);
begin
  Screen.Cursor := POINTER_5_HOURGLASS_START_NEW_SAVE_DIR;
  SelectDirectoryDialog1.InitialDir := AppendPathDelim(GetUserDir + 'Desktop');
  Screen.Cursor := POINTER_5_HOURGLASS_START_NEW_SAVE_DIR;
  if SelectDirectoryDialog1.Execute then
    edtSaveDirectory.Text := SelectDirectoryDialog1.FileName;
  Screen.Cursor := POINTER_6_DEFAULT_STOP_CHOOSE_SAVE_DIR;
end;

procedure TMovesForm2.DoOnReadPodcast_2(Sender: TObject; APosition: int64; fileNumber: integer);
{$push}{$warn 5024 off}// fileNumber not used
begin
  if FStartStopIO <> '' then
    raise ECancelException.Create(READ_EXCEPTION_PODCAST + EXCEPTION_SPACE + FStartStopIO);
  g_selection_mediator.readingRss(g_podcast_form, APosition);
  Application.ProcessMessages;
end;
{$pop}

procedure TMovesForm2.DoOnFailedReadPodcast_2(Sender: TObject; mediaUrl: string);
{$push}{$warn 5024 off}// mediaUrl not used
begin
  //_d('Podcast failed to read, unlike episodes, we don't do anything, this is a place holder to avoid a nil');
end;
{$pop}

// We must show failed episodes this way because the Consol app does not have any controls
procedure TMovesForm2.DoOnFailedReadEpisode_2(Sender: TObject; mediaUrl: string);
begin
  memFailedFiles.Lines.Add(mediaUrl);
end;

procedure TMovesForm2.downloadCheckedEpisodes_2(Sender: TObject);
var
  urlToRead, saveDir, finishMess: string;
  succesfulDownloads, failedDownloads: integer;
  failsAndSuccesses: TFailsAndSuccesses;
begin
  try
    urlToRead := edRssUrl.Text;
    saveDir := g_podcast_form.edtSaveDirectory.Text;
    g_podcast_form.clbEpisodeFiles.ClearSelection();
    FStateOfGui.setState(GUI_WHILE_DOWNLOADING_6);
    failsAndSuccesses := process_c_episodes(urlToRead, saveDir);
    succesfulDownloads := failsAndSuccesses.successCount;
    failedDownloads := failsAndSuccesses.failedCount;
    finishMess := FStateOfGui.finishedMess(succesfulDownloads, failedDownloads);
    FStateOfGui.setState(GUI_AFTER_FINISHED_7);
    MessageDlgEx(finishMess, mtInformation, [mbOK], g_podcast_form);
  finally
    FStateOfGui.setState(GUI_BEFORE_A_URL_1);
    FStateOfGui.setState(GUI_AFTER_A_URL_2);
    FreeAndNil(g_selection_mediator);
  end;
end;


end.
