unit dir_list_differences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
 {$IfDef ALLOW_DEBUG_SERVER}
  debug_server,                    // Can use SendDebug('my debug message') from dbugintf
  {$ENDIF}

  Controls, Graphics, Dialogs, StdCtrls;

type

  TfrmTestDirListDifference = class(TForm)
    btnDirListOK: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    lblTestMessage: TLabel;
    memExpectedDirListing: TMemo;
    memActualDirListing: TMemo;
  private

  public

  end;

var
  frmTestDirListDifference: TfrmTestDirListDifference;

implementation

{$R *.lfm}

end.
