unit checks_descriptions;

{$mode objfpc}{$H+}

interface

uses

{$IfDef ALLOW_DEBUG_SERVER}
  //debug_server,         // Can use SendDebug('my debug message') from dbugintf
{$ENDIF}

  Types, Messages, Controls, StdCtrls, SysUtils,
  Classes, Graphics, CheckLst;

type

  TFourPoints = array[0..3] of TPoint;
  TFourXs = array[0..3] of integer;
  TFourYs = array[0..3] of integer;

  TCheckListBox = class(checklst.TCheckListBox)
  private
    FOnScroll: TNotifyEvent;
  protected
    procedure CheckListBoxScroll(var Message: TMessage); message WM_VSCROLL;
  public
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
  end;

  TListBox = class(StdCtrls.TListBox)
  private
    FOnScroll: TNotifyEvent;
  protected
    procedure ListBoxScroll(var Message: TMessage); message WM_VSCROLL;
  public
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
  end;

procedure checkBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect; lbEpisodeDesc: TListBox);
procedure TitleListBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect; lbEpisodeDesc: TListBox);
procedure EpisodeListBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect);

implementation

uses
  episode_bits, consts_types,
  dirs_files;

procedure TListBox.ListBoxScroll(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

procedure TCheckListBox.CheckListBoxScroll(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

function listBoxBackGround(row_index: integer; filter_match: boolean): TColor;
begin
  if row_index mod 2 = 0 then
    if filter_match then
      Result := COLOR_EVEN_ROW_MATCH
    else
      Result := COLOR_EVEN_ROW_NO_MATCH
  else
  if filter_match then
    Result := COLOR_ODD_ROW_MATCH
  else
    Result := COLOR_ODD_ROW_NO_MATCH;
end;

procedure checkBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect; lbEpisodeDesc: TListBox);
var
  theListBox: TCheckListBox;
  left_x2, top_y2: integer;
  myobj: TObject;
  filterMatch: boolean;
  myXCoords, myYCoords: TIntegerDynArray;
  background_color: TColor;

  procedure drawCheckBox(outside_box_color, inside_fill_color: TColor);
  var
    right_x2, bot_y2: integer;
    rectangle22: trect;
  begin
    with theListBox.Canvas do
    begin
      right_x2 := left_x2 + CHECK_RECT_SIZE;
      bot_y2 := top_y2 + CHECK_RECT_SIZE;
      rectangle22 := Rect(left_x2, top_y2, right_x2, bot_y2);
      Brush.Color := outside_box_color;
      FillRect(rectangle22);
      rectangle22 := Rect(left_x2 + 1, top_y2 + 1, right_x2 - 1, bot_y2 - 1);
      Brush.Color := inside_fill_color;
      FillRect(rectangle22);
    end;
  end;

  procedure drawText(text_color, background_color: TColor);
  var
    theItem: ansistring;
  begin
    theItem := theListBox.Items[Index];
    with theListBox.Canvas do
    begin
      Brush.Color := background_color;
      Font.Color := text_color;
      TextOut(ARect.Left + EPISODE_DESC_INDENT, ARect.Top, theItem);
    end;
  end;

  function colorBackGround(filter_match: boolean): TColor;
  begin
    with theListBox.Canvas do
    begin
      Brush.Color := listBoxBackGround(index, filter_match);
      FillRect(ARect);
      Result := Brush.Color;
    end;
  end;

  function fourPointPoly(x_offsets, y_offsets: TIntegerDynArray): TFourPoints;
  var
    cPoints: array[0..3] of TPoint;
  begin
    cPoints[0].x := left_x2 + x_offsets[0];
    cPoints[0].y := top_y2 + y_offsets[0];
    cPoints[1].x := left_x2 + x_offsets[1];
    cPoints[1].y := top_y2 + y_offsets[1];
    cPoints[2].x := left_x2 + x_offsets[2];
    cPoints[2].y := top_y2 + y_offsets[2];
    cPoints[3].x := left_x2 + x_offsets[3];
    cPoints[3].y := top_y2 + y_offsets[3];
    Result := cPoints;
  end;

  procedure drawACheckline(myXCoords2, myYCoords2: TIntegerDynArray; the_color: TColor);
  var
    check_mark_line: TFourPoints;
  begin
    check_mark_line := fourPointPoly(myXCoords2, myYCoords2);
    with theListBox.Canvas do
    begin
      Pen.Color := the_color;
      Polyline(check_mark_line);
    end;
  end;

  procedure drawCheckMark(top_line_color, mid_line_color, bot_line_color: TColor);
  begin
    myXCoords := TIntegerDynArray.Create(3, 4, 5, 10);
    myYCoords := TIntegerDynArray.Create(6, 7, 7, 2);
    drawACheckline(myXCoords, myYCoords, top_line_color);

    myXCoords := TIntegerDynArray.Create(2, 4, 5, 11);
    myYCoords := TIntegerDynArray.Create(6, 8, 8, 2);
    drawACheckline(myXCoords, myYCoords, mid_line_color);

    myXCoords := TIntegerDynArray.Create(1, 4, 5, 12);
    myYCoords := TIntegerDynArray.Create(6, 9, 9, 2);
    drawACheckline(myXCoords, myYCoords, bot_line_color);
  end;

begin
  myobj := lbEpisodeDesc.Items.Objects[Index];
  filterMatch := decodeFilterMatch(myobj);
  theListBox := (Control as TCheckListBox);
  left_x2 := ARect.Left + H_RECT_INDENT;
  top_y2 := ARect.Top + V_RECT_INDENT;
  background_color := colorBackGround(filterMatch);
  drawCheckBox(COLOR_CHECKBOX_BORDER, COLOR_CHECKBOX_INTERIOR);
  drawText(clBlack, background_color);
  if theListBox.Checked[Index] then
    drawCheckMark(COLOR_CHECKMARK_TOP, COLOR_CHECKMARK_MIDDLE, COLOR_CHECKMARK_BOTTOM);
end;

procedure TitleListBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect; lbEpisodeDesc: TListBox);
var
  theListBox: TListBox;
  theItem: ansistring;
  myobj: TObject;
  filterMatch: boolean;
begin
  myobj := lbEpisodeDesc.Items.Objects[Index];
  filterMatch := decodeFilterMatch(myobj);
  theListBox := (Control as TListBox);
  theItem := theListBox.Items[Index];
  with theListBox.Canvas do
  begin
    Font.Color := clBlack;
    Brush.Color := listBoxBackGround(index, filterMatch);
    FillRect(ARect);
    TextOut(ARect.Left +EPISODE_TITLE_INDENT, ARect.Top, theItem);
  end;
end;

procedure EpisodeListBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect);
var
  theListBox: TListBox;
  theItem, fileSize: ansistring;
  myobj: TObject;
  filterMatch: boolean;
  willDownload: boolean;
  downloadingSelected: boolean;
  theFileSize: int64;
begin
  theListBox := (Control as TListBox);
  theItem := theListBox.Items[Index];
  myobj := theListBox.Items.Objects[Index];
  filterMatch := decodeFilterMatch(myobj);
  theFileSize := decodeFileByteSize(myobj);
  willDownload := decodeWillDownload(myobj);
  downloadingSelected := decodeDownloadingSelected(myobj);
  fileSize := mbFileSize(theFileSize);
  with theListBox.Canvas do
  begin
    Font.Color := clBlack;
    Brush.Color := listBoxBackGround(index, filterMatch);
    FillRect(ARect);
    if downloadingSelected then
    begin
      if willDownload and (theFileSize <> 0) then
        TextOut(ARect.Left + EPISODE_DESC_INDENT, ARect.Top, fileSize);
    end
    else
      TextOut(ARect.Left + EPISODE_DESC_INDENT, ARect.Top, theItem);
  end;
end;



end.
