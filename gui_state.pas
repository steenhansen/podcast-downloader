unit gui_state;

{$mode objfpc}{$H+}

interface

uses
    {$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,                    // Can use SendDebug('my debug message') from dbugintf
{$ENDIF}

  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, regexpr, LazFileUtils, lazlogger, ComCtrls,

  BCMDButton,
  checks_descriptions  ;

const
  GUI_BEFORE_A_URL_1 = 1;
  GUI_AFTER_A_URL_2 = 2;
  GUI_WHILE_PARSING_RSS_3 = 3;
  GUI_AFTER_RSS_PROCESSED_4 = 4;
  GUI_ONE_CHECKMARK_5 = 5;
  GUI_WHILE_DOWNLOADING_6 = 6;
  GUI_AFTER_FINISHED_7 = 7;

  POINTER_1_HOURGLASS_START_READ_PODCAST = crHourGlass;
  POINTER_2_HOURGLASS_READING_PODCAST = crHourGlass;
  POINTER_3_HOURGLASS_START_PARSE_EPISODES = crHourGlass;
  POINTER_4_DEFAULT_STOP_PARSE_EPISODES =  crDefault;
  POINTER_5_HOURGLASS_START_NEW_SAVE_DIR = crHourGlass;
  POINTER_6_DEFAULT_STOP_CHOOSE_SAVE_DIR =  crDefault;

type

  TGuiState = class(TObject)
  private
    FForm: TForm;
    FState: integer;
    FedRssUrl: TEdit;
    FbtnReadRss: TButton;
    FlblPodcastDescription: TLabel;
    FclbEpisodeFiles: TCheckListBox;
     FlbEpisodeTitle: TListBox;
    FlbEpisodeDesc: TListBox;
    FmemFailedFiles: TMemo;
    FbtnCancel: TBCMDButton;
    FedtTextFilter: TEdit;
    FbtnDownloadFiltered: TButton;
    FupDownFiltered:TUpDown;
    FbtnDownloadAll: TButton;
    FbtnDownloadNone: TButton;
    FedtSaveDirectory: TEdit;
    FbtnDirectoryChange: TButton;
    FrbgSpeed:TRadioGroup;
    FbtnDownloadChecked: TBCMDButton;
    FlblDownloadingXofY: TLabel;
    procedure beforeAUrl_1();
    procedure afterAUrl_2();
    procedure whileParsingRss_3();
    procedure afterRssProcessed_4();
    procedure afterOneCheck_5();
    procedure whileDownloading_6();
    procedure afterFinished_7();
  public
    constructor Create(g_podcast_form: TForm);
    procedure initCaptions();
    destructor Destroy; override;
    procedure setState(the_state_of_gui: integer);
    function getState(): integer;
    procedure enableGui(theControl: TControl);
    procedure disableGui(theControl: TControl);
    procedure beforeAfterUrl(url_value: string);
    function finishedMess(succesfulDownloads, failedCount: integer): string;
    procedure searchButtons();
  end;

procedure mouseConnectToUrl();
procedure mouseReadingUrl();
procedure mouseStartParseEpisodes();
procedure mouseStopParseEpisodes();
 function MessageDlgEx(const AMsg: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; AParent: TForm): TModalResult;

implementation

{$IfDef STOP_GUI_STATE}
   stop_compilation_instruction('A console_podcast_downloader.exe cannot include debug_server.');
   stop_compilation_instruction('B console_test_runner.exe cannot include debug_server.');
   stop_compilation_instruction('Comment out all "use debug_server" to compile A or B.');
{$EndIf}

uses
   consts_types,
  selection_mediator;

procedure mouseConnectToUrl();
begin
  Screen.Cursor :=POINTER_1_HOURGLASS_START_READ_PODCAST;
end;

procedure mouseReadingUrl();
begin
  Screen.Cursor :=  POINTER_2_HOURGLASS_READING_PODCAST;
end;

 procedure mouseStartParseEpisodes();
begin
  Screen.Cursor :=POINTER_3_HOURGLASS_START_PARSE_EPISODES;
end;

  procedure mouseStopParseEpisodes();
begin
  Screen.Cursor :=POINTER_4_DEFAULT_STOP_PARSE_EPISODES;
end;

constructor TGuiState.Create(g_podcast_form: TForm);
begin
  inherited Create;
  FForm := g_podcast_form;
  FState := 0;
  with g_podcast_form do
  begin
    FedRssUrl := TEdit(FindComponent('edRssUrl'));
    FbtnReadRss := TButton(FindComponent('btnReadRss'));
    FlblPodcastDescription := TLabel(FindComponent('lblPodcastDescription'));
    FclbEpisodeFiles := TCheckListBox(FindComponent('clbEpisodeFiles'));
    FlbEpisodeDesc := TListBox(FindComponent('lbEpisodeDesc'));
    FlbEpisodeTitle := TListBox(FindComponent('lbEpisodeTitle'));
    FmemFailedFiles := TMemo(FindComponent('memFailedFiles'));
    FbtnCancel := TBCMDButton(FindComponent('btnCancel'));
    FedtTextFilter := TEdit(FindComponent('edtTextFilter'));
    FbtnDownloadFiltered := TButton(FindComponent('btnDownloadFiltered'));
    FupDownFiltered := TUpDown(FindComponent('upDownFiltered'));
    FbtnDownloadAll := TButton(FindComponent('btnDownloadAll'));
    FbtnDownloadNone := TButton(FindComponent('btnDownloadNone'));
    FedtSaveDirectory := TEdit(FindComponent('edtSaveDirectory'));
    FbtnDirectoryChange := TButton(FindComponent('btnDirectoryChange'));
    FrbgSpeed := TRadioGroup(FindComponent('rbgSpeed'));
    FbtnDownloadChecked := TBCMDButton(FindComponent('btnDownloadChecked'));
    FlblDownloadingXofY := TLabel(FindComponent('lblDownloadingXofY'));
  end;
end;

procedure TGuiState.initCaptions();
begin
  FbtnDownloadFiltered.Caption := 'Add Episodes Matching Search Text';
  FlblPodcastDescription.Caption := '';
  FbtnDownloadAll.Caption := 'Select All Episodes for Download';
  FbtnDownloadChecked.Caption := downloadCaption(0, 0);
  FbtnCancel.Caption := 'Cancel';
end;

destructor TGuiState.Destroy;
begin
  inherited Destroy;
end;

function TGuiState.getState(): integer;
begin
  Result := FState;
end;

procedure TGuiState.enableGui(theControl: TControl);
begin
  theControl.Enabled := True;
end;

procedure TGuiState.disableGui(theControl: TControl);
begin
  theControl.Enabled := False;
end;

procedure TGuiState.beforeAUrl_1();
begin
  enableGui(FedRssUrl);
  disableGui(FbtnReadRss);
  disableGui(FbtnCancel);
  disableGui(FedtTextFilter);
  disableGui(FbtnDownloadFiltered);
  disableGui(FupDownFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FbtnDownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FbtnDirectoryChange);
  disableGui(FbtnDownloadChecked);
  disableGui(FclbEpisodeFiles);
  disableGui(FlbEpisodeDesc);

  FclbEpisodeFiles.Clear;
  FlbEpisodeTitle.Clear;
  FlbEpisodeDesc.Clear;
  FedtTextFilter.Clear;
  FedRssUrl.SetFocus;
  FbtnDownloadChecked.Caption := downloadCaption(0, 0);
    disableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=false;
end;

procedure TGuiState.afterAUrl_2();
begin
  enableGui(FedRssUrl);
  enableGui(FbtnReadRss);
  disableGui(FbtnCancel);
  disableGui(FedtTextFilter);
  disableGui(FbtnDownloadFiltered);
  disableGui(FupDownFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FbtnDownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FbtnDirectoryChange);
  disableGui(FbtnDownloadChecked);
  disableGui(FclbEpisodeFiles);
  disableGui(FlbEpisodeDesc);

  mouseStopParseEpisodes();
    disableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=false;

end;

procedure TGuiState.whileParsingRss_3();
begin
    FedtTextFilter.Text := '';

  disableGui(FedRssUrl);
  disableGui(FbtnReadRss);
  enableGui(FbtnCancel);
  disableGui(FedtTextFilter);
  disableGui(FbtnDownloadFiltered);
  disableGui(FupDownFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FbtnDownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FbtnDirectoryChange);
  disableGui(FbtnDownloadChecked);
  disableGui(FclbEpisodeFiles);
  disableGui(FlbEpisodeDesc);

    disableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=false;
    FmemFailedFiles.Clear();
end;

procedure TGuiState.afterRssProcessed_4();
begin
  disableGui(FedRssUrl);
  disableGui(FbtnReadRss);
  enableGui(FbtnCancel);
  enableGui(FedtTextFilter);


  enableGui(FbtnDownloadFiltered);
  enableGui(FupDownFiltered);

  enableGui(FbtnDownloadAll);
  enableGui(FbtnDownloadNone);
  enableGui(FedtSaveDirectory);
  enableGui(FbtnDirectoryChange);
  disableGui(FbtnDownloadChecked);
  enableGui(FclbEpisodeFiles);
  enableGui(FlbEpisodeDesc);

    disableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=false;
end;

procedure TGuiState.afterOneCheck_5();
begin
  disableGui(FedRssUrl);
  disableGui(FbtnReadRss);
  enableGui(FbtnCancel);
  enableGui(FedtTextFilter);
  enableGui(FbtnDownloadAll);
  enableGui(FbtnDownloadNone);
  enableGui(FedtSaveDirectory);
  enableGui(FbtnDirectoryChange);
  enableGui(FbtnDownloadChecked);
  enableGui(FclbEpisodeFiles);
  enableGui(FlbEpisodeDesc);

    disableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=false;
end;

procedure TGuiState.whileDownloading_6();
begin
  disableGui(FedRssUrl);
  disableGui(FbtnReadRss);
  enableGui(FbtnCancel);
  disableGui(FedtTextFilter);
  disableGui(FbtnDownloadFiltered);
  disableGui(FupDownFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FbtnDownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FbtnDirectoryChange);
  disableGui(FbtnDownloadChecked);
  enableGui(FclbEpisodeFiles);
  enableGui(FlbEpisodeDesc);



  FrbgSpeed.ItemIndex:=0;
  enableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=true;
end;

procedure TGuiState.afterFinished_7();
begin
  disableGui(FedRssUrl);
  enableGui(FbtnReadRss);
  disableGui(FbtnCancel);
  disableGui(FedtTextFilter);
  disableGui(FbtnDownloadFiltered);
  disableGui(FupDownFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FbtnDownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FbtnDirectoryChange);
  disableGui(FbtnDownloadChecked);
  disableGui(FclbEpisodeFiles);
  disableGui(FlbEpisodeDesc);

  disableGui(FrbgSpeed);
  FlblDownloadingXofY.Visible:=false;
  mouseStopParseEpisodes();
end;

procedure TGuiState.setState(the_state_of_gui: integer);
begin
  FState := the_state_of_gui;
  case the_state_of_gui of
    GUI_BEFORE_A_URL_1: beforeAUrl_1();
    GUI_AFTER_A_URL_2: afterAUrl_2();
    GUI_WHILE_PARSING_RSS_3: whileParsingRss_3();
    GUI_AFTER_RSS_PROCESSED_4: afterRssProcessed_4();
    GUI_ONE_CHECKMARK_5: afterOneCheck_5();
    GUI_WHILE_DOWNLOADING_6: whileDownloading_6();
    GUI_AFTER_FINISHED_7: afterFinished_7();
    else
      ShowMessage('state_of_gui unknown' + IntToStr(the_state_of_gui));
  end;
end;

procedure TGuiState.beforeAfterUrl(url_value: string);
var
  rssUrl, trimmedRssUrl: string;
  rssUrlLen: integer;
begin
  rssUrl := url_value;
  trimmedRssUrl := Trim(rssUrl);
  rssUrlLen := Length(trimmedRssUrl);
  if rssUrlLen = 0 then
    setState(GUI_BEFORE_A_URL_1)
  else
    setState(GUI_AFTER_A_URL_2);
end;

function TGuiState.finishedMess(succesfulDownloads, failedCount: integer): string;
var
  successStr, failStr, finishMess: string;
begin
  if (succesfulDownloads=0) AND (failedCount=0) then
       finishMess := 'Podcast downloading Cancelled'
  else
    begin
         successStr := IntToStr(succesfulDownloads);
         failStr := IntToStr(failedCount);
         finishMess := successStr + ' successful downloads, and ' + LINE_ENDING  +
                       failStr + ' failures' + LINE_ENDING  +
                       'in ' + FedtSaveDirectory.Text  + LINE_ENDING ;
     end;
  Result := finishMess;
end;

procedure TGuiState.searchButtons();
var
  filter_text: string;
begin
   filter_text := FedtTextFilter.Text;
  if filter_text.Length =0 then
  begin
     FbtnDownloadFiltered.Enabled := false;
     FupDownFiltered.Enabled := false;
  end
  else
  begin
    FbtnDownloadFiltered.Enabled := true;
    FupDownFiltered.Enabled := true;
  end;
end;

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

end.
























