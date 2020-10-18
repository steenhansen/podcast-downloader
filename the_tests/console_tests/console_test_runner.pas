program console_test_runner;

{$mode objfpc}{$H+}

// NB run parameter of
//     -a --format=plain

uses
  Classes, consoletestrunner,
  test_local,
  test_internet, console_podcast,
  Keyboard


  , interfaces


  ;

type


  TMyTestRunner = class(TTestRunner)
  protected
  // override the protected methods of TTestRunner to customize its behavior
  end;

var
  Application: TMyTestRunner;
  end_enter:string;

begin
  InitKeyBoard();
  Application := TMyTestRunner.Create(nil);
  Application.Initialize;
  Application.Title:='fpcunitproject1';
  Application.Run;

  writeln('');
  write(' **** Hit enter to quit');
  read(end_enter);

  Application.Free;
end.
