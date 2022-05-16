// -----------------------------------------------------------------
//    This file is part of Tranquil IT Software
//    Copyright (C) 2012 - 2022  Tranquil IT https://www.tranquil.it
//    All Rights Reserved.
// ------------------------------------------------------------------
unit tis.ui.toolbar.core;

{$mode objfpc}{$H+}
{$modeswitch ADVANCEDRECORDS}
{$modeswitch typehelpers}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Buttons,
  Variants,
  ComCtrls,
  ActnList,
  mormot.core.base,
  mormot.core.variants,
  mormot.core.unicode,
  mormot.core.rtti;

type
  /// define a item for the collection
  TActionsItem = class(TCollectionItem)
  private
    fList: TActionList;
  protected
    const DefaultReadOnly = False;
  public
    constructor Create(aCollection: TCollection); override;
    procedure Assign(aSource: TPersistent); override;
  published
    property List: TActionList read fList write fList;
  end;

  /// actions collection
  TActionsCollection = class(TCollection)
  private
    fControl: TWinControl;
    function GetItems(aIndex: Integer): TActionsItem;
    procedure SetItems(aIndex: Integer; aValue: TActionsItem);
  protected
    // ------------------------------- inherited methods ----------------------------------
    function GetOwner: TPersistent; override;
  public
    constructor Create(aControl: TWinControl); reintroduce;
    function LocateAction(const aListOwnerName, aListName, aActionName: string): TAction;
    /// items of the collection
    property Items[aIndex: Integer]: TActionsItem read GetItems write SetItems; default;
  end;

  TTisToolBar = class(TToolBar)
  private
    fActions: TActionsCollection;
    fDefaultSessionValues: string;
  protected
    // ------------------------------- inherited methods ----------------------------------
    procedure Loaded; override;
    // ------------------------------- new methods ----------------------------------
    function GetSessionValues: string; virtual;
    procedure SetSessionValues(const aValue: string); virtual;
    /// default implementation for OnDblClick event
    // - it will call ShowEditor
    procedure ShowEditorOnDblClick({%H-}sender: TObject); virtual;
  public
    // ------------------------------- inherited methods ----------------------------------
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(aSource: TPersistent); override;
    // ------------------------------- new methods ----------------------------------
    /// add a new button related to an action
    procedure AddButton(aStyle: TToolButtonStyle; aAction: TAction); overload;
    /// remove all buttons
    procedure RemoveButtons;
    /// it shows the Editor to manage buttons vs. actions
    procedure ShowEditor;
    /// it resets SessionValues to the original design
    procedure RestoreSession;
  published
    // ------------------------------- new properties ----------------------------------
    property Actions: TActionsCollection read fActions write fActions;
    property SessionValues: string read GetSessionValues write SetSessionValues stored False;
  end;

implementation

uses
  tis.ui.toolbar.editor;

{ TActionsItem }

constructor TActionsItem.Create(aCollection: TCollection);
begin
  inherited Create(aCollection);
end;

procedure TActionsItem.Assign(aSource: TPersistent);
begin
  if aSource is TActionsItem then
    with aSource as TActionsItem do
    begin
      self.List := List;
    end
  else
    inherited Assign(aSource);
end;

{ TActionsCollection }

function TActionsCollection.GetItems(aIndex: Integer): TActionsItem;
begin
  result := TActionsItem(inherited Items[aIndex]);
end;

procedure TActionsCollection.SetItems(aIndex: Integer; aValue: TActionsItem);
begin
  Items[aIndex].Assign(aValue);
end;

function TActionsCollection.GetOwner: TPersistent;
begin
  result := fControl;
end;

constructor TActionsCollection.Create(aControl: TWinControl);
begin
  inherited Create(TActionsItem);
  fControl := aControl;
end;

function TActionsCollection.LocateAction(const aListOwnerName, aListName,
  aActionName: string): TAction;
var
  i: Integer;
  l: TActionList;
begin
  result := nil;
  for i := 0 to Count -1 do
  begin
    l := Items[i].List;
    if (l.Owner.Name = aListOwnerName) and (l.Name = aListName) then
    begin
      result := l.ActionByName(aActionName) as TAction;
      exit;
    end;
  end;
end;

{ TTisToolBar }

procedure TTisToolBar.Loaded;
begin
  inherited Loaded;
  fDefaultSessionValues := SessionValues; // save default values
end;

function TTisToolBar.GetSessionValues: string;
var
  d: TDocVariantData;
  i: Integer;
  a: TAction;
  b: TToolButton;
  o: Variant;
begin
  d.InitArray([], JSON_FAST_FLOAT);
  for i := 0 to ButtonCount -1 do
  begin
    b := Buttons[i];
    o := _ObjFast([
      'left', b.Left,
      'style', b.Style
    ]);
    a := b.Action as TAction;
    if a <> nil then
    begin
      o.action := _ObjFast([
        'owner', a.ActionList.Owner.Name,
        'list', a.ActionList.Name,
        'name', a.Name
      ]);
    end;
    d.AddItem(o);
  end;
  // by default, the original list order is by instance added, not by design order
  // - session needs to save the buttons design order
  d.SortArrayByField('left');
  result := Utf8ToString(d.ToJson);
end;

procedure TTisToolBar.SetSessionValues(const aValue: string);
var
  d: TDocVariantData;
  o, a: PDocVariantData;
begin
  if (csDesigning in ComponentState) or
   (GetSessionValues = aValue) or
   (Actions.Count = 0) then
    exit;
  RemoveButtons;
  if not d.InitJson(StringToUtf8(aValue), JSON_FAST_FLOAT) then
    d.InitJson(StringToUtf8(fDefaultSessionValues), JSON_FAST_FLOAT); // use default values, if it is invalid
  for o in d.Objects do
  begin
    a := o^.O_['action'];
    AddButton(
      TToolButtonStyle(o^.I['style']),
      Actions.LocateAction(a^.S['owner'], a^.S['list'], a^.S['name'])
    );
  end;
end;

procedure TTisToolBar.ShowEditorOnDblClick(sender: TObject);
begin
  ShowEditor;
end;

procedure TTisToolBar.AddButton(aStyle: TToolButtonStyle;
  aAction: TAction);
begin
  with TToolButton.Create(self) do
  begin
    Parent := self;
    Action := aAction;
    Style := aStyle;
    AutoSize := True;
    Left := Parent.Width;
  end;
end;

procedure TTisToolBar.RemoveButtons;
var
  i: Integer;
begin
  for i := ButtonCount-1 downto 0 do
    RemoveControl(Buttons[i]);
  ButtonList.Clear;
end;

constructor TTisToolBar.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  fActions := TActionsCollection.Create(self);
  OnDblClick := @ShowEditorOnDblClick;
end;

destructor TTisToolBar.Destroy;
begin
  fActions.Free;
  inherited Destroy;
end;

procedure TTisToolBar.Assign(aSource: TPersistent);
begin
  if aSource is TTisToolBar then
    with aSource as TTisToolBar do
    begin
      self.Actions.Assign(Actions);
      self.SessionValues := SessionValues;
    end
  else
    inherited Assign(aSource);
end;

procedure TTisToolBar.ShowEditor;
begin
  with TTisToolBarEditor.Create(Application) do
  try
    Target := self;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TTisToolBar.RestoreSession;
begin
  SessionValues := fDefaultSessionValues;
end;

end.
