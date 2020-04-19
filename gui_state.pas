unit gui_state;

{$mode objfpc}{$H+}

interface

uses
    {$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,                    // Can use SendDebug('my debug message') from dbugintf
{$ENDIF}

  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, regexpr, LazFileUtils, lazlogger,

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
   POINTER_2_DEFAULT_READING_PODCAST =  crDefault;

   POINTER_3_HOURGLASS_START_PARSE_EPISODES = crHourGlass;
   POINTER_4_DEFAULT_STOP_PARSE_EPISODES =  crDefault;

type


  TGuiState = class(TObject)
  private
    FForm: TForm;
    FState: integer;
    FEdURL: TEdit;
    FBtnReadRss: TButton;
    FlblPodcastDescription: TLabel;
    FEpisodeFiles: TCheckListBox;
     FEpisodeTitle: TListBox;
    FEpisodeDesc: TListBox;
    FFailedFiles: TMemo;
    FbtnStop: TBCMDButton;
    Ffilter1: TEdit;
    FdownloadFiltered: TButton;
    FbtnDownloadAll: TButton;
    FdownloadNone: TButton;
    FedtSaveDirectory: TEdit;
    FButton2: TButton;
    FdownloadBtn: TBCMDButton;
       FlblDownloadingXofY: TLabel;
    procedure beforeAUrl_1();
    procedure afterAUrl_2();
    procedure whileParsingRss_3();
    procedure afterRssProcessed_4();
    procedure afterOneCheck_5();
    procedure whileDownloading_6();
    procedure afterFinished_7();
  public
    constructor Create(podcastForm: TForm);
    procedure initCaptions();
    destructor Destroy; override;
    procedure setState(the_guiState: integer);
    function getState(): integer;
     procedure enableGui(theControl: TControl);
    procedure disableGui(theControl: TControl);
     procedure beforeAfterUrl(url_value: string);
    function finishedMess(succesfulDownloads, failedCount: integer): string;
  published
  end;

procedure mouseConnectToUrl();
procedure mouseReadingUrl();
procedure mouseStartParseEpisodes();
procedure mouseStopParseEpisodes();

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
  Screen.Cursor :=POINTER_2_DEFAULT_READING_PODCAST;
end;

 procedure mouseStartParseEpisodes();
begin
  Screen.Cursor :=POINTER_3_HOURGLASS_START_PARSE_EPISODES;
end;

  procedure mouseStopParseEpisodes();
begin
  Screen.Cursor :=POINTER_4_DEFAULT_STOP_PARSE_EPISODES;
end;

constructor TGuiState.Create(podcastForm: TForm);
begin
  inherited Create;
  FForm := podcastForm;
  FState := 0;
    with PodcastForm do
  begin
    FEdURL := TEdit(FindComponent('edRssUrl'));
    FBtnReadRss := TButton(FindComponent('BtnReadRss'));
    FlblPodcastDescription := TLabel(FindComponent('lblPodcastDescription'));
    FEpisodeFiles := TCheckListBox(FindComponent('clbEpisodeFiles'));
         FEpisodeDesc := TListBox(FindComponent('lbEpisodeDesc'));
    FEpisodeTitle := TListBox(FindComponent('lbEpisodeTitle'));
      FFailedFiles := TMemo(FindComponent('memFailedFiles'));
    FbtnStop := TBCMDButton(FindComponent('btnCancel'));
    Ffilter1 := TEdit(FindComponent('edtTextFilter'));
    FdownloadFiltered := TButton(FindComponent('btnDownloadFiltered'));
    FbtnDownloadAll := TButton(FindComponent('btnDownloadAll'));
    FdownloadNone := TButton(FindComponent('btnDownloadNone'));
    FedtSaveDirectory := TEdit(FindComponent('edtSaveDirectory'));
    FButton2 := TButton(FindComponent('btnDirectoryChange'));
    FdownloadBtn := TBCMDButton(FindComponent('btnDownloadChecked'));
         FlblDownloadingXofY := TLabel(FindComponent('lblDownloadingXofY'));
  end;
end;

procedure TGuiState.initCaptions();
begin
  FdownloadFiltered.Caption := 'Add Episodes Matching Search Text';
  FlblPodcastDescription.Caption := '';
  FbtnDownloadAll.Caption := 'Select All Episodes for Download';
  FdownloadBtn.Caption := downloadCaption(0, 0);
  FbtnStop.Caption := 'Cancel';
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
  FEpisodeFiles.Clear;
  FEpisodeTitle.Clear;
  FEpisodeDesc.Clear;
   Ffilter1.Clear;
     enableGui(FEdURL);
  FEdURL.SetFocus;
     FdownloadBtn.Caption := downloadCaption(0, 0);
   disableGui(FBtnReadRss);
  disableGui(FbtnStop);
  disableGui(Ffilter1);
  disableGui(FdownloadFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FdownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FButton2);
  disableGui(FdownloadBtn);
   disableGui(FEpisodeFiles);
  disableGui(FEpisodeDesc);
  enableGui(FFailedFiles);
    FlblDownloadingXofY.Visible:=false;
end;

procedure TGuiState.afterAUrl_2();
begin
             mouseStopParseEpisodes();
  enableGui(FEdURL);
  enableGui(FBtnReadRss);
  disableGui(FbtnStop);
  disableGui(Ffilter1);
  disableGui(FdownloadFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FdownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FButton2);
  disableGui(FdownloadBtn);
   disableGui(FEpisodeFiles);
  disableGui(FEpisodeDesc);
  disableGui(FFailedFiles);
    FlblDownloadingXofY.Visible:=false;
    FFailedFiles.Clear();
end;

procedure TGuiState.whileParsingRss_3();
begin
   disableGui(FEdURL);
  disableGui(FBtnReadRss);
  enableGui(FbtnStop);
  disableGui(Ffilter1);
  disableGui(FdownloadFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FdownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FButton2);
  disableGui(FdownloadBtn);
   disableGui(FEpisodeFiles);
  disableGui(FEpisodeDesc);
  disableGui(FFailedFiles);
    FlblDownloadingXofY.Visible:=false;
end;

procedure TGuiState.afterRssProcessed_4();
begin
  disableGui(FEdURL);
  disableGui(FBtnReadRss);
  enableGui(FbtnStop);
   enableGui(Ffilter1);
  enableGui(FdownloadFiltered);
  enableGui(FbtnDownloadAll);
  enableGui(FdownloadNone);
  enableGui(FedtSaveDirectory);
  enableGui(FButton2);
  disableGui(FdownloadBtn);
  enableGui(FEpisodeFiles);
  enableGui(FEpisodeDesc);
  disableGui(FFailedFiles);
    FlblDownloadingXofY.Visible:=false;
end;


procedure TGuiState.afterOneCheck_5();
begin

  disableGui(FEdURL);
  disableGui(FBtnReadRss);
  enableGui(FbtnStop);
  enableGui(Ffilter1);
  enableGui(FdownloadFiltered);
  enableGui(FbtnDownloadAll);
  enableGui(FdownloadNone);
  enableGui(FedtSaveDirectory);
  enableGui(FButton2);
  enableGui(FdownloadBtn);
   enableGui(FEpisodeFiles);
  enableGui(FEpisodeDesc);
  disableGui(FFailedFiles);
    FlblDownloadingXofY.Visible:=false;
end;

procedure TGuiState.whileDownloading_6();
begin
  disableGui(FEdURL);
  disableGui(FBtnReadRss);
  enableGui(FbtnStop);
  disableGui(Ffilter1);
  disableGui(FdownloadFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FdownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FButton2);
  disableGui(FdownloadBtn);
   enableGui(FEpisodeFiles);
  enableGui(FEpisodeDesc);
  disableGui(FFailedFiles);
    FlblDownloadingXofY.Visible:=true;
end;

procedure TGuiState.afterFinished_7();
begin
  disableGui(FEdURL);
  disableGui(FBtnReadRss);
  disableGui(FbtnStop);
  disableGui(Ffilter1);
  disableGui(FdownloadFiltered);
  disableGui(FbtnDownloadAll);
  disableGui(FdownloadNone);
  disableGui(FedtSaveDirectory);
  disableGui(FButton2);
  disableGui(FdownloadBtn);
   disableGui(FEpisodeFiles);
  disableGui(FEpisodeDesc);
  disableGui(FFailedFiles);
     FlblDownloadingXofY.Visible:=false;
     mouseStopParseEpisodes();
end;

procedure TGuiState.setState(the_guiState: integer);
begin
  FState := the_guiState;
  case the_guiState of
    GUI_BEFORE_A_URL_1: beforeAUrl_1();
    GUI_AFTER_A_URL_2: afterAUrl_2();
    GUI_WHILE_PARSING_RSS_3: whileParsingRss_3();
    GUI_AFTER_RSS_PROCESSED_4: afterRssProcessed_4();
    GUI_ONE_CHECKMARK_5: afterOneCheck_5();
    GUI_WHILE_DOWNLOADING_6: whileDownloading_6();
    GUI_AFTER_FINISHED_7: afterFinished_7();
    else
      ShowMessage('guiState unknown' + IntToStr(the_guiState));
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

end.
























