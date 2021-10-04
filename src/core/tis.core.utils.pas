// -----------------------------------------------------------------
//    This file is part of Tranquil IT Software
//    Copyright (C) 2012 - 2021  Tranquil IT https://www.tranquil.it
//    All Rights Reserved.
// ------------------------------------------------------------------
unit tis.core.utils;

{$i mormot.defines.inc}

interface

uses
  classes,
  sysutils,
  controls,
  ComCtrls,
  forms,
  mormot.core.base,
  mormot.core.unicode,
  mormot.core.text;

type
  TWidgetHelper = class helper for TWinControl
  public
    procedure SetFocusSafe;
  end;

implementation

{ TWidgetHelper }

procedure TWidgetHelper.SetFocusSafe;
var
  p: TWinControl;
begin
  try
    if Visible and Enabled then
    begin
      p := Parent;
      if p.InheritsFrom(TFrame) then
        p.SetFocusSafe;
      while Assigned(p) and p.Enabled do
      begin
        if p.InheritsFrom(TTabSheet) then
          TPageControl(p.Parent).ActivePage := TTabSheet(p);
        p := p.Parent;
      end;
      SetFocus;
    end;
  except
  end;
end;

end.
