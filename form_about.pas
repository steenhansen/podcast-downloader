unit form_about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblGitHub: TLabel;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure lblGitHubClick(Sender: TObject);
    procedure lblGitHubDblClick(Sender: TObject);
    procedure lblGitHubMouseEnter(Sender: TObject);
    procedure lblGitHubMouseLeave(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
  private

  public

  end;

var
  AboutForm: TAboutForm;

implementation

uses
  LCLIntf;

{$R *.lfm}

{ TAboutForm }


procedure TAboutForm.Button1Click(Sender: TObject);
begin
        Close();
end;

procedure TAboutForm.lblGitHubClick(Sender: TObject);
begin
             OpenURL('https://github.com/steenhansen/podcast-downloader');
end;

procedure TAboutForm.lblGitHubDblClick(Sender: TObject);
begin
            OpenURL('https://github.com/steenhansen/podcast-downloader');
end;

procedure TAboutForm.lblGitHubMouseLeave(Sender: TObject);
begin
              lblGitHub.Font.Color:=clMenuText;
end;

procedure TAboutForm.StaticText1Click(Sender: TObject);
begin

end;

procedure TAboutForm.lblGitHubMouseEnter(Sender: TObject);
begin
  lblGitHub.Font.Color:=clHighlight;
end;



end.

