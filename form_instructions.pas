unit form_instructions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TInstructionsForm }

  TInstructionsForm = class(TForm)
    Button1: TButton;
    StaticText1: TStaticText;
    UpDown1: TUpDown;
    procedure Button1Click(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
  private

  public

  end;

var
  InstructionsForm: TInstructionsForm;

implementation

{$R *.lfm}

{ TInstructionsForm }

procedure TInstructionsForm.Button1Click(Sender: TObject);
begin
  InstructionsForm.Close();
end;

procedure TInstructionsForm.StaticText1Click(Sender: TObject);
begin

end;



end.

