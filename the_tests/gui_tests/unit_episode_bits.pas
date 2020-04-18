unit unit_episode_bits;







{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,  Forms,   Dialogs;


type
  TTestCaseItemBits = class(TTestCase)
  protected

  published
    procedure encode_filter_match;


  end;

implementation

uses
  episode_bits;



procedure TTestCaseItemBits.encode_filter_match;
var
   before_object, after_object: TObject;
   value_0:cardinal;
begin

    before_object := TObject(0);
    after_object := encodeFilterMatch(before_object, false);
    value_0 := cardinal(after_object);

  AssertEquals('item_bits - Largest number without loss', value_0, 0);

end;






initialization

  RegisterTest(TTestCaseItemBits);
end.






