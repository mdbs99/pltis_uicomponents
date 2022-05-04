// -----------------------------------------------------------------
//    This file is part of Tranquil IT Software
//    Copyright (C) 2012 - 2022  Tranquil IT https://www.tranquil.it
//    All Rights Reserved.
// ------------------------------------------------------------------
unit tis.ui.grid.editor;

{$mode objfpc}{$H+}
{$modeswitch ADVANCEDRECORDS}
{$modeswitch typehelpers}

interface

uses
  Classes,
  SysUtils,
  LCLIntf,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ButtonPanel,
  ExtCtrls,
  StdCtrls,
  ActnList,
  Menus,
  Buttons,
  Messages,
  MaskEdit,
  LCLType,
  EditBtn,
  ComCtrls,
  Spin,
  ComponentEditors,
  VirtualTrees,
  mormot.core.base,
  mormot.core.variants,
  mormot.core.unicode,
  mormot.core.text,
  tis.core.os,
  tis.ui.grid.core;

type
  TTisGridEditor = class(TForm)
    ActAddColumn: TAction;
    ActDelColumn: TAction;
    ActCopySettings: TAction;
    ActAddColumns: TAction;
    ActClearAll: TAction;
    ActRemoveAllColumns: TAction;
    ActPasteCSV: TAction;
    ActUpdateColumn: TAction;
    ActPasteJsonTemplate: TAction;
    ActionList: TActionList;
    DelColumnsButton: TButton;
    MenuItem8: TMenuItem;
    PasteJsonButton: TButton;
    AddColumnButton: TButton;
    Grid: TTisGrid;
    ButtonPanel: TButtonPanel;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    ClearAllButton: TButton;
    PropsPageControl: TPageControl;
    ColumnPropsTab: TTabSheet;
    GridPropsTab: TTabSheet;
    MenuItem11: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    EdColumnTitle: TLabeledEdit;
    EdColumnProperty: TLabeledEdit;
    cbColumnDataType: TComboBox;
    EdDataType: TLabel;
    UpdateColumnButton: TButton;
    EdColumnIndex: TLabeledEdit;
    EdPosition: TEdit;
    DelColumnButton1: TButton;
    Label1: TLabel;
    RequiredCheckBox: TCheckBox;
    AutoSortCheckBox: TCheckBox;
    MultiSelectCheckBox: TCheckBox;
    EditableCheckBox: TCheckBox;
    SortColumnClearLabel: TLabel;
    MultilineCheckBox: TCheckBox;
    MultilineHeightEdit: TSpinEdit;
    Label2: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    VariableNodeHeightCheckBox: TCheckBox;
    Bevel4: TBevel;
    TabSheet1: TTabSheet;
    KeepDataCheckBox: TCheckBox;
    ActClearRows: TAction;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    ActClearSelRows: TAction;
    MenuItem2: TMenuItem;
    ReadOnlyCheckBox: TCheckBox;
    procedure ActAddColumnExecute(Sender: TObject);
    procedure ActAddColumnsExecute(Sender: TObject);
    procedure ActClearAllExecute(Sender: TObject);
    procedure ActDelColumnExecute(Sender: TObject);
    procedure ActPasteCSVExecute(Sender: TObject);
    procedure ActPasteJsonTemplateExecute(Sender: TObject);
    procedure ActRemoveAllColumnsExecute(Sender: TObject);
    procedure ActUpdateColumnExecute(Sender: TObject);
    procedure GridHeaderDragged(Sender: TVTHeader; Column: TColumnIndex;
      OldPosition: Integer);
    procedure Button6Click(Sender: TObject);
    procedure EdColumnPropertyExit(Sender: TObject);
    procedure EdColumnPropertyKeyPress(Sender: TObject; var Key: char);
    procedure EdColumnTitleExit(Sender: TObject);
    procedure EdColumnTitleKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure GridHeaderDragging(Sender: TVTHeader; Column: TColumnIndex;
      var Allowed: Boolean);
    procedure EdColumnIndexChange(Sender: TObject);
    procedure AutoSortCheckBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MultiSelectCheckBoxChange(Sender: TObject);
    procedure EditableCheckBoxChange(Sender: TObject);
    procedure SortColumnClearLabelClick(Sender: TObject);
    procedure GridFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure GridClick(Sender: TObject);
    procedure MultilineCheckBoxChange(Sender: TObject);
    procedure MultilineHeightEditChange(Sender: TObject);
    procedure VariableNodeHeightCheckBoxChange(Sender: TObject);
    procedure ActClearRowsExecute(Sender: TObject);
    procedure ActClearSelRowsExecute(Sender: TObject);
  private
    procedure SetPropertiesPanel(aColIndex, aColTitle, aColProperty,
      aColPosition: string; const aColDataType: TTisColumnDataType;
      aColRequired, aColReadOnly: Boolean);
    procedure ClearPropertiesPanel;
    procedure LoadGridCommonProps;
    procedure AddFakeDataIfNeedIt;
  end;

  TTisGridComponentEditor = class(TComponentEditor)
  private
    fPreviousFilename: String;
  protected
    procedure DoShowColumnsEditor;
    procedure DoShowEditor;
    procedure DoLoadSettingsFromIni;
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

implementation

uses
  PropEdits;

{$R *.lfm}

{ TTisGridEditor }

procedure TTisGridEditor.ActPasteCSVExecute(Sender: TObject);
var
  cb: TClipboardAdapter;
begin
  Grid.Data.InitCsv(cb.AsUtf8, JSON_FAST_FLOAT);
end;

procedure TTisGridEditor.ActAddColumnExecute(Sender: TObject);
var
  col : TTisGridColumn;
begin
  col :=  TTisGridColumn(Grid.Header.Columns.Add);
  col.Text := 'Col ' + IntToStr(col.Index);
  col.PropertyName := 'column' + IntToStr(col.Index);
  Grid.FocusedColumn := col.Index;
  AddFakeDataIfNeedIt;
end;

procedure TTisGridEditor.ActAddColumnsExecute(Sender: TObject);
begin
  Grid.CreateColumnsFromData(False, False);
end;

procedure TTisGridEditor.ActClearAllExecute(Sender: TObject);
begin
  Grid.ClearAll;
  ClearPropertiesPanel;
end;

procedure TTisGridEditor.ActDelColumnExecute(Sender: TObject);
var
  col: TTisGridColumn;
  idx: Integer;
begin
  col := TTisGridColumn(Grid.Header.Columns[StrToInt(EdColumnIndex.Text)]);
  idx := col.Index-1;
  Grid.Header.Columns.Delete(col.Index);
  if not Grid.Header.Columns.IsValidColumn(idx) then
  begin
    if Grid.Header.Columns.GetLastVisibleColumn >= 0 then
      idx := Grid.Header.Columns.GetLastVisibleColumn;
  end;
  if idx > NoColumn then
  begin
    col := TTisGridColumn(Grid.Header.Columns[idx]);
    SetPropertiesPanel(IntToStr(col.Index), col.Text, col.PropertyName,
      IntToStr(col.Position), col.DataType, col.Required, col.ReadOnly);
  end
  else
    ClearPropertiesPanel;
end;

procedure TTisGridEditor.ActPasteJsonTemplateExecute(Sender: TObject);
var
  cb: TClipboardAdapter;
begin
  Grid.TryLoadAllFrom(cb.AsString);
end;

procedure TTisGridEditor.ActRemoveAllColumnsExecute(Sender: TObject);
begin
  Grid.Header.Columns.Clear;
  ClearPropertiesPanel;
end;

procedure TTisGridEditor.ActUpdateColumnExecute(Sender: TObject);
var
  col: TTisGridColumn;
  a: TTisColumnDataTypeAdapter;
begin
  col := TTisGridColumn(Grid.Header.Columns[StrToInt(EdColumnIndex.Text)]);
  if col <> nil then
  begin
    col.Text := EdColumnTitle.Text;
    col.PropertyName := EdColumnProperty.Text;
    col.DataType := a.CaptionToEnum(cbColumnDataType.Text);
    col.Required := RequiredCheckBox.Checked;
    col.ReadOnly := ReadOnlyCheckBox.Checked;
  end;
  Grid.Invalidate;
end;

procedure TTisGridEditor.GridHeaderDragged(Sender: TVTHeader;
  Column: TColumnIndex; OldPosition: Integer);
begin
  Grid.ReorderColumns;
end;

function colsort(c1,c2: TCollectionItem): Integer;
begin
  if TTisGridColumn(c1).Position < TTisGridColumn(c2).Position then
    result := -1
  else
  if TTisGridColumn(c1).Position > TTisGridColumn(c2).Position then
    result := 1
  else
    result := 0;
end;

procedure TTisGridEditor.Button6Click(Sender: TObject);
begin
  Grid.ReorderColumns;
end;

procedure TTisGridEditor.EdColumnPropertyExit(Sender: TObject);
begin
  if Grid.FocusedColumnObject <> nil then
  begin
    Grid.FocusedColumnObject.PropertyName := EdColumnProperty.Text;
    Grid.Invalidate;
  end;
end;

procedure TTisGridEditor.EdColumnPropertyKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) and (Grid.FocusedColumnObject <> nil)  then
  begin
    Grid.FocusedColumnObject.PropertyName := EdColumnProperty.Text;
    Grid.Invalidate;
    Key := #0;
  end;
end;

procedure TTisGridEditor.EdColumnTitleExit(Sender: TObject);
begin
  if Grid.FocusedColumnObject <> nil then
  begin
    Grid.FocusedColumnObject.Text := EdColumnTitle.Text;
    Grid.Invalidate;
  end;
end;

procedure TTisGridEditor.EdColumnTitleKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) and (Grid.FocusedColumnObject <> nil)  then
  begin
    Grid.FocusedColumnObject.Text := EdColumnTitle.Text;
    Grid.Invalidate;
    Key := #0;
  end;
end;

procedure TTisGridEditor.FormCreate(Sender: TObject);
var
  a: TTisColumnDataTypeAdapter;
begin
  ButtonPanel.OKButton.Default := False;
  a.EnumsToStrings(cbColumnDataType.Items);
end;

procedure TTisGridEditor.GridHeaderDragging(Sender: TVTHeader;
  Column: TColumnIndex; var Allowed: Boolean);
begin
  Grid.ReorderColumns;
end;

procedure TTisGridEditor.EdColumnIndexChange(Sender: TObject);
begin
  ActUpdateColumn.Enabled := EdColumnIndex.Text <> '';
  ActDelColumn.Enabled := ActUpdateColumn.Enabled;
end;

procedure TTisGridEditor.AutoSortCheckBoxChange(Sender: TObject);
begin
  with Grid.Header do
    if AutoSortCheckBox.Checked then
      Options := Options + [hoHeaderClickAutoSort]
    else
      Options := Options - [hoHeaderClickAutoSort];
end;

procedure TTisGridEditor.FormShow(Sender: TObject);
begin
  LoadGridCommonProps;
end;

procedure TTisGridEditor.MultiSelectCheckBoxChange(Sender: TObject);
begin
  with Grid.TreeOptions do
    if MultiSelectCheckBox.Checked then
      SelectionOptions := SelectionOptions + [toMultiSelect]
    else
      SelectionOptions := SelectionOptions - [toMultiSelect];
end;

procedure TTisGridEditor.EditableCheckBoxChange(Sender: TObject);
begin
  with Grid.TreeOptions do
    if EditableCheckBox.Checked then
      MiscOptions := MiscOptions + [toEditable]
    else
      MiscOptions := MiscOptions - [toEditable];
end;

procedure TTisGridEditor.SortColumnClearLabelClick(Sender: TObject);
begin
  Grid.Header.SortColumn := -1;
end;

procedure TTisGridEditor.GridFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  col: TTisGridColumn;
begin
  col := Grid.FocusedColumnObject;
  if col <> nil then
    SetPropertiesPanel(IntToStr(col.Index), col.Text, col.PropertyName,
      IntToStr(col.Position), col.DataType, col.Required, col.ReadOnly)
  else
    ClearPropertiesPanel;
end;

procedure TTisGridEditor.GridClick(Sender: TObject);
begin
  if Grid.FocusedRow <> nil then
    PropsPageControl.ActivePage := ColumnPropsTab
  else
    PropsPageControl.ActivePage := GridPropsTab;
end;

procedure TTisGridEditor.MultilineCheckBoxChange(Sender: TObject);
begin
  Grid.NodeOptions.MultiLine := MultilineCheckBox.Checked;
end;

procedure TTisGridEditor.MultilineHeightEditChange(Sender: TObject);
begin
  Grid.NodeOptions.MultiLineHeight := MultilineHeightEdit.Value;
end;

procedure TTisGridEditor.VariableNodeHeightCheckBoxChange(Sender: TObject);
begin
  with Grid.TreeOptions do
    if MultiSelectCheckBox.Checked then
      MiscOptions := MiscOptions + [toVariableNodeHeight]
    else
      MiscOptions := MiscOptions - [toVariableNodeHeight];
  Grid.LoadData;
end;

procedure TTisGridEditor.ActClearRowsExecute(Sender: TObject);
begin
  Grid.Clear;
  AddFakeDataIfNeedIt;
end;

procedure TTisGridEditor.ActClearSelRowsExecute(Sender: TObject);
begin
  Grid.DeleteSelectedRows;
  AddFakeDataIfNeedIt;
end;

procedure TTisGridEditor.SetPropertiesPanel(aColIndex, aColTitle, aColProperty,
  aColPosition: string; const aColDataType: TTisColumnDataType;
  aColRequired, aColReadOnly: Boolean);
var
  a: TTisColumnDataTypeAdapter;
begin
  EdColumnIndex.Text := aColIndex;
  EdColumnTitle.Text := aColTitle;
  EdColumnProperty.Text := aColProperty;
  cbColumnDataType.ItemIndex := a.EnumToIndex(aColDataType);
  EdPosition.Text := aColPosition;
  RequiredCheckBox.Checked := aColRequired;
  ReadOnlyCheckBox.Checked := aColReadOnly;
end;

procedure TTisGridEditor.ClearPropertiesPanel;
begin
  SetPropertiesPanel('', '', '', '', low(TTisColumnDataType), False, False);
end;

procedure TTisGridEditor.LoadGridCommonProps;
begin
  AutoSortCheckBox.Checked := hoHeaderClickAutoSort in Grid.Header.Options;
  MultiSelectCheckBox.Checked := toMultiSelect in Grid.TreeOptions.SelectionOptions;
  EditableCheckBox.Checked := toEditable in Grid.TreeOptions.MiscOptions;
  MultilineCheckBox.Checked := Grid.NodeOptions.MultiLine;
  MultilineHeightEdit.Value := Grid.NodeOptions.MultiLineHeight;
  VariableNodeHeightCheckBox.Checked := toVariableNodeHeight in Grid.TreeOptions.MiscOptions;
end;

procedure TTisGridEditor.AddFakeDataIfNeedIt;
begin
  if Grid.Data.IsVoid then
    Grid.Data.AddItem(_Json('{"id":null}'));
  Grid.LoadData;
end;

{ TTisGridComponentEditor }

procedure TTisGridComponentEditor.DoShowColumnsEditor;
begin
  EditCollection(Component, (Component as TTisGrid).Header.Columns, 'Header.Columns');
end;

procedure TTisGridComponentEditor.DoShowEditor;
begin
  (Component as TTisGrid).Customize;
end;

procedure TTisGridComponentEditor.DoLoadSettingsFromIni;
var
  od: TOpenDialog;
  target: TTisGrid;
begin
  od := TOpenDialog.Create(Application);
  try
    if fPreviousFilename <> '' then
      od.FileName := fPreviousFilename;
    od.Filter := 'Ini file|*.ini|All files|*.*';
    od.DefaultExt := '.ini';
    if od.Execute then
    begin
      target := (Component as TTisGrid);
      target.LoadSettingsFromIni(od.FileName);
      fPreviousFilename := od.FileName;
    end;
  finally
    od.Free;
  end;
end;

procedure TTisGridComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: DoShowEditor;
    1: DoShowColumnsEditor;
    2: (Component as TTisGrid).CreateColumnsFromData(False, False);
    3: DoLoadSettingsFromIni;
  end;
end;

function TTisGridComponentEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: result := 'Edit grid...';
    1: result := 'Edit columns...';
    2: result := 'Create missing columns from sample data';
    3: result := 'Load grid settings from inifile...';
  else
    result := 'Unknow';
  end;
end;

function TTisGridComponentEditor.GetVerbCount: Integer;
begin
  result := 4;
end;

end.

