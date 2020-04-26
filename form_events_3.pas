unit form_events_3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, StdCtrls, Menus, ExtCtrls, CheckLst,
  checks_descriptions, BCMDButton, ComCtrls,
  form_moves_2;

type

  { TEventsForm3 }

  TEventsForm3 = class(TMovesForm2)
    btnDownloadAll: TButton;
    btnDownloadFiltered: TButton;
    btnDownloadNone: TButton;
    clbEpisodeFiles: TCheckListBox;
    edtTextFilter: TEdit;
    gbEpisodesToDownload: TGroupBox;
    grTextFilter: TGroupBox;
    lbEpisodeDesc: TListBox;
    lbEpisodeTitle: TListBox;
    splFirst: TSplitter;
    splSecond: TSplitter;
    upDownFiltered: TUpDown;
    procedure FormCreate(Sender: TObject);

    procedure DoDrawItemlbEpisodeDesc_3(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure clbEpisodeFilesItemClick_3(Sender: TObject; Index: integer);
    procedure splFirstMoved_3(Sender: TObject);
    procedure splSecondMoved_3(Sender: TObject);
    procedure lbEpisodeDescClick_3(Sender: TObject);
    procedure lbEpisodeDescSelectionChange_3(Sender: TObject; User: boolean);
    procedure edtTextFilterChange_3(Sender: TObject);
    procedure upDownFilteredClick_3(Sender: TObject; Button: TUDBtnType);
    procedure btnDownloadFilteredClick_3(Sender: TObject);
    procedure btnDownloadAllClick_3(Sender: TObject);
    procedure btnDownloadNoneClick_3(Sender: TObject);
    procedure DoScrollclbEpisodeFiles_3(Sender: TObject);
    procedure DoScrolllbEpisodeTitle_3(Sender: TObject);
    procedure DoScrolllbEpisodeDesc_3(Sender: TObject);
    procedure DoDrawItemclbEpisodeFiles_3(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure DoDrawItemlbEpisodeTitle_3(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure DoOnWriteEpisode_3(Sender: TObject; APosition: int64; fileNumber: integer);
  protected
    FViewSearchMatch, FViewSearchCount: integer;
  end;

var
  unused_event_form: TEventsForm3;

implementation

{$R *.lfm}

uses
  process_data, form_podcast_4, gui_state, consts_types;

procedure TEventsForm3.FormCreate(Sender: TObject);
begin
  inherited;
  clbEpisodeFiles.OnScroll := @DoScrollclbEpisodeFiles_3;
  lbEpisodeTitle.OnScroll := @DoScrolllbEpisodeTitle_3;
  lbEpisodeDesc.OnScroll := @DoScrolllbEpisodeDesc_3;

  clbEpisodeFiles.OnDrawItem := @DoDrawItemclbEpisodeFiles_3;
  lbEpisodeTitle.OnDrawItem := @DoDrawItemlbEpisodeTitle_3;
  lbEpisodeDesc.OnDrawItem := @DoDrawItemlbEpisodeDesc_3;

  clbEpisodeFiles.Clear;
  lbEpisodeTitle.Clear;
  lbEpisodeDesc.Clear;
end;

procedure TEventsForm3.DoDrawItemlbEpisodeDesc_3(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
{$push}{$warn 5024 off}// State not used
begin
  EpisodeListBoxDrawItem(Control, Index, ARect);
end;
{$pop}

procedure TEventsForm3.clbEpisodeFilesItemClick_3(Sender: TObject; Index: integer);
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

procedure TEventsForm3.splFirstMoved_3(Sender: TObject);
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

procedure TEventsForm3.splSecondMoved_3(Sender: TObject);
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

procedure TEventsForm3.lbEpisodeDescClick_3(Sender: TObject);
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
procedure TEventsForm3.lbEpisodeDescSelectionChange_3(Sender: TObject; User: boolean);
begin
  clbEpisodeFiles.TopIndex := lbEpisodeDesc.TopIndex;
  lbEpisodeTitle.TopIndex := lbEpisodeDesc.TopIndex;
end;
{$pop}

procedure TEventsForm3.edtTextFilterChange_3(Sender: TObject);
begin
  FViewSearchCount := g_selection_mediator.showFilterMatch(clbEpisodeFiles, lbEpisodeTitle, lbEpisodeDesc,
    g_podcast_form.edtTextFilter, g_podcast_form.btnDownloadFiltered);
  FViewSearchMatch := 0;
  FStateOfGui.searchButtons();
end;

procedure TEventsForm3.upDownFilteredClick_3(Sender: TObject; Button: TUDBtnType);
var
  search_text: string;
  top_episode_search_index: integer;
begin
  search_text := g_podcast_form.edtTextFilter.Text;
  top_episode_search_index := process_b_index_of_filter(search_text, FViewSearchMatch);
  clbEpisodeFiles.TopIndex := top_episode_search_index;
  lbEpisodeDesc.TopIndex := top_episode_search_index;
  lbEpisodeTitle.TopIndex := top_episode_search_index;
  if Button = btPrev then
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

procedure TEventsForm3.btnDownloadFilteredClick_3(Sender: TObject);
var
  checkedFileCount: integer;
  checked_and_total_size: TCheckedAndTotalSize;
  search_text: string;
begin
  search_text := g_podcast_form.edtTextFilter.Text;
  checked_and_total_size := process_b_filter(search_text);
  checkedFileCount := checked_and_total_size.checkedFileCount;
  if checkedFileCount = 0 then
    FStateOfGui.setState(GUI_AFTER_RSS_PROCESSED_4)
  else
    FStateOfGui.setState(GUI_ONE_CHECKMARK_5);
end;

procedure TEventsForm3.btnDownloadAllClick_3(Sender: TObject);
begin
  process_b_all();
  FStateOfGui.setState(GUI_ONE_CHECKMARK_5);
end;

procedure TEventsForm3.btnDownloadNoneClick_3(Sender: TObject);
begin
  process_b_none();
  FStateOfGui.setState(GUI_AFTER_RSS_PROCESSED_4);
end;

procedure TEventsForm3.DoScrollclbEpisodeFiles_3(Sender: TObject);
begin
  lbEpisodeDesc.TopIndex := clbEpisodeFiles.TopIndex;
  lbEpisodeTitle.TopIndex := clbEpisodeFiles.TopIndex;
end;

procedure TEventsForm3.DoScrolllbEpisodeTitle_3(Sender: TObject);
begin
  clbEpisodeFiles.TopIndex := lbEpisodeTitle.TopIndex;
  lbEpisodeDesc.TopIndex := lbEpisodeTitle.TopIndex;
end;

procedure TEventsForm3.DoScrolllbEpisodeDesc_3(Sender: TObject);
begin
  clbEpisodeFiles.TopIndex := lbEpisodeDesc.TopIndex;
  lbEpisodeTitle.TopIndex := lbEpisodeDesc.TopIndex;
end;

procedure TEventsForm3.DoDrawItemclbEpisodeFiles_3(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
{$push}{$warn 5024 off}// State not used
begin
  checkBoxDrawItem(Control, Index, ARect, lbEpisodeDesc);
end;
{$pop}

procedure TEventsForm3.DoDrawItemlbEpisodeTitle_3(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
{$push}{$warn 5024 off}// State not used
begin
  TitleListBoxDrawItem(Control, Index, ARect, lbEpisodeDesc);
end;
{$pop}

procedure TEventsForm3.DoOnWriteEpisode_3(Sender: TObject; APosition: int64; fileNumber: integer);
var
  num_success, num_wanted: integer;
begin
  if FStartStopIO <> '' then
    raise ECancelException.Create(WRITE_EXCEPTION_EPISODE + EXCEPTION_SPACE + FStartStopIO);
  g_selection_mediator.readingMediaFile(clbEpisodeFiles, lbEpisodeTitle, lbEpisodeDesc, fileNumber, APosition);
  num_success := g_selection_mediator.getSuccesses() + 1;
  num_wanted := g_selection_mediator.getWantedDownloads();
  lblDownloadingXofY.Caption := 'Downloading ' + IntToStr(num_success) + '/' + IntToStr(num_wanted);
  Application.ProcessMessages;
end;

end.
