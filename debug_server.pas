unit debug_server;

{ To use the debug server as a terminal window for debugging
  - Compile /lazarus/tools/debugserver/debugserver.lpi
  - Color icon a new color to distinguish debug server when pinned to taskbar
  - Start /lazarus/tools/debugserver.exe
  - Pin debugserver to taskbar
  - use debug_server
  - SendDebug('my debug message') from dbugintf to log messages in debugserver.exe}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils ;

procedure _d(s1: string; i1: integer; i2: integer; i3: integer);
procedure _d(s1:string; i1: integer; s2,s3,s4: string);

procedure _d(debug_message: string);
procedure _d(debug_message: string; string_value: string);

procedure _d(debug_message: string; integer_value: integer);
procedure _d(integer_value: integer; debug_message: string );

procedure _d(str1: string; int1: integer; int2: integer);
procedure _d(m1: string; i1: integer; m2: string; i2: integer; m3: string; i3: integer);

procedure _sb(debug_message: string; FMediaWillBeDownloaded: array of boolean);

implementation

uses
  dbugintf  ;

{$IfDef STOP_DEBUG_SERVER}
   stop_compilation_instruction('1 console_podcast_downloader.exe cannot include debug_server.');
   stop_compilation_instruction('2 gui_test_runner.exe cannot include debug_server.');
   stop_compilation_instruction('3 console_test_runner.exe cannot include debug_server.');
   stop_compilation_instruction('Comment out all "use debug_server" to compile 1 or 2 or 3.');
{$EndIf}

//  _d('s1', 1, 2, 3);
procedure _d(s1: string; i1: integer; i2: integer; i3: integer);
begin
  SendDebug('[[' +s1 + '::' + IntToStr(i1) + '::' + IntToStr(i2)+ '::' + IntToStr(i3)+ ']]');
end;

procedure _d(s1:string; i1: integer; s2,s3,s4: string );
begin
  try
     SendDebug('[['+s1+'::' +IntToStr(i1) + '::' + s2 + '::' +s3+ '::' + s4 + ']]');
  except
  end;
end;

//  _d('str');
procedure _d(debug_message: string);
begin
  SendDebug(debug_message);
end;

//  _d('str', 'str');
procedure _d(debug_message: string; string_value: string);
begin
  SendDebug( '[[' + debug_message + '::' + string_value+ ']]');
end;

//  _d('str', 17);
procedure _d(debug_message: string; integer_value: integer);
begin
  SendDebug(debug_message + '::' + IntToStr(integer_value));
end;

//  _d(17, 'str');
procedure _d(integer_value: integer; debug_message: string );
begin
  SendDebug(IntToStr(integer_value) + '::' + debug_message);
end;

//  _d('str', 17, 17);
procedure _d(str1: string; int1: integer; int2: integer);
begin
  SendDebug(str1 + '::' + IntToStr(int1) + '::' + IntToStr(int2));
end;

procedure _d(m1: string; i1: integer; m2: string; i2: integer);
begin
  SendDebug(m1 + IntToStr(i1) + '::' + m2 + IntToStr(i2));
end;

//_d('XXXXXXXXnew_name_dot_width', new_name_dot_width,'episode_width', episode_width,'FLastDotCount=', FLastDotCount);
procedure _d(m1: string; i1: integer; m2: string; i2: integer; m3: string; i3: integer);
begin
  SendDebug(m1 + IntToStr(i1) + '::' + m2 + IntToStr(i2) + '::' + m3 + IntToStr(i3));
end;





//  _sb('my_boolean_array, show true indexes', FMediaWillBeDownloaded);
procedure _sb(debug_message: string; FMediaWillBeDownloaded: array of boolean);
var
  arr_len, a:integer;
  true_indexes_str: string;
begin
  true_indexes_str := '';
  arr_len := Length(FMediaWillBeDownloaded);

  for a := 0 to arr_len - 1 do
    if FMediaWillBeDownloaded[a] then
      true_indexes_str := true_indexes_str + ' ' +  IntToStr(a);

  SendDebug(debug_message + '::' + true_indexes_str);
end;



end.


