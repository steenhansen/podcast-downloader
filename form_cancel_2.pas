unit form_cancel_2;

{$mode objfpc}{$H+}

interface

uses
   {$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,                     // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, ExtCtrls, Buttons,
  LazFileUtils, regexpr,
  form_menu_1, BCMDButton;

type
  { TCancelForm2 }

  TCancelForm2 = class(TMenuForm1)
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
    procedure selectDirBtn_2(Sender: TObject);
    procedure DoOnFailedReadEpisode_2(Sender: TObject; mediaUrl: string);
    procedure DoOnReadPodcast_2(Sender: TObject; APosition: int64; fileNumber: integer);
    procedure DoOnFailedReadPodcast_2(Sender: TObject; mediaUrl: string);
    function fixSaveDirectory(save_directory: string): string;
  end;

var
  unused_cancel_form: TCancelForm2;

implementation

{$R *.lfm}

uses
  form_podcast_4, consts_types, process_data, gui_state, lclintf;

procedure TCancelForm2.FormCreate(Sender: TObject);
begin
  inherited;
end;



procedure TCancelForm2.btnDownloadCheckedMouseLeave_2(Sender: TObject);
begin
  with g_podcast_form do
  begin
    downloadBtnPanel.BevelColor := START_GREEN;
  end;
end;

procedure TCancelForm2.btnDownloadCheckedMouseEnter_2(Sender: TObject);
begin
  downloadBtnPanel.BevelColor := STANDARD_HOVER_EDGE;
end;

procedure TCancelForm2.btnCancelMouseEnter_2(Sender: TObject);
begin
  cancelBtnPanel.BevelColor := STANDARD_HOVER_EDGE;
end;

procedure TCancelForm2.btnCancelMouseLeave_2(Sender: TObject);
begin
  cancelBtnPanel.BevelColor := STOP_RED;
end;

procedure TCancelForm2.btnStopClick_2(Sender: TObject);
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



procedure TCancelForm2.selectDirBtn_2(Sender: TObject);
begin
  Screen.Cursor := POINTER_5_HOURGLASS_START_NEW_SAVE_DIR;
  SelectDirectoryDialog1.InitialDir := AppendPathDelim(GetUserDir + 'Desktop');
  Screen.Cursor := POINTER_5_HOURGLASS_START_NEW_SAVE_DIR;
  if SelectDirectoryDialog1.Execute then
    edtSaveDirectory.Text := SelectDirectoryDialog1.FileName;
  Screen.Cursor := POINTER_6_DEFAULT_STOP_CHOOSE_SAVE_DIR;
end;

procedure TCancelForm2.DoOnReadPodcast_2(Sender: TObject; APosition: int64; fileNumber: integer);
{$push}{$warn 5024 off}// fileNumber not used
begin
  if FStartStopIO <> '' then
    raise ECancelException.Create(READ_EXCEPTION_PODCAST + EXCEPTION_SPACE + FStartStopIO);
  g_selection_mediator.readingRss(g_podcast_form, APosition);
  Application.ProcessMessages;
end;

{$pop}

procedure TCancelForm2.DoOnFailedReadPodcast_2(Sender: TObject; mediaUrl: string);
{$push}{$warn 5024 off}// mediaUrl not used
begin
  //_d('Podcast failed to read, unlike episodes, we don't do anything, this is a place holder to avoid a nil');
end;

{$pop}

// We must show failed episodes this way because the Consol app does not have any controls
procedure TCancelForm2.DoOnFailedReadEpisode_2(Sender: TObject; mediaUrl: string);
begin
  memFailedFiles.Lines.Add(mediaUrl);
end;

procedure TCancelForm2.downloadCheckedEpisodes_2(Sender: TObject);
var
  urlToRead, saveDir, finishMess: string;
  succesfulDownloads, failedDownloads: integer;
  failsAndSuccesses: TFailsAndSuccesses;
  dialog_reply: integer;
begin
  try
    urlToRead := edRssUrl.Text;

    g_podcast_form.edtSaveDirectory.Text := fixSaveDirectory(g_podcast_form.edtSaveDirectory.Text);

    saveDir := g_podcast_form.edtSaveDirectory.Text;
    g_podcast_form.clbEpisodeFiles.ClearSelection();
    FStateOfGui.setState(GUI_WHILE_DOWNLOADING_6);
    failsAndSuccesses := process_c_episodes(urlToRead, saveDir);
    succesfulDownloads := failsAndSuccesses.successCount;
    failedDownloads := failsAndSuccesses.failedCount;
    finishMess := FStateOfGui.finishedMess(succesfulDownloads, failedDownloads);
    FStateOfGui.setState(GUI_AFTER_FINISHED_7);
    dialog_reply := MessageDlgEx(finishMess, mtConfirmation, mbYesNo, g_podcast_form);
    if dialog_reply = mrYes then
      OpenDocument(saveDir);
  finally
    FStateOfGui.setState(GUI_BEFORE_A_URL_1);
    FStateOfGui.setState(GUI_AFTER_A_URL_2);
    FreeAndNil(g_selection_mediator);
  end;
end;


function TCancelForm2.fixSaveDirectory(save_directory: string): string;
var
  dir_part, path_part, dir_fix, path_fix, fixed_path: string;
  RegexObj: TRegExpr;
begin
  try
    RegexObj := TRegExpr.Create(WINDOWS_DRIVE_PATH);
    RegExprModifierI := CASE_INSENSITIVE;
    RegexObj.Exec(save_directory);
    dir_part := RegexObj.Match[1];   // Match[2] matches :
    path_part := RegexObj.Match[3];
    dir_fix := ReplaceRegExpr(WINDOWS_DRIVE, dir_part, '', False);
    if dir_fix = '' then
      dir_fix := DEFAULT_DIR;
    path_fix := ReplaceRegExpr(WINDOWS_PATH, path_part, '_', False);
    fixed_path := dir_fix + ':' + path_fix;
    Result := fixed_path;
  finally
    RegexObj.Free
  end;
end;



end.
