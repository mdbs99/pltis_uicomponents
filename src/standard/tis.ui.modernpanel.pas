// -----------------------------------------------------------------
//    This file is part of Tranquil IT Software
//    Copyright (C) 2012 - 2026  Tranquil IT https://www.tranquil.it
//    All Rights Reserved.
// ------------------------------------------------------------------
unit tis.ui.modernpanel;

{$i tis.ui.defines.inc}

interface

uses
  Classes,
  Controls,
  Graphics,
  ExtCtrls,
  StdCtrls;

type

  { TTisModernPanel }

  TTisModernPanel = class(TPanel)
  private
    FRadius: Integer;
    FShadowSize: Integer;
    FFillColor: TColor;
    FBorderColor: TColor;
    FShadowColor: TColor;
    FShowShadow: Boolean;
    procedure SetBorderColor(AValue: TColor);
    procedure SetFillColor(AValue: TColor);
    procedure SetRadius(AValue: Integer);
    procedure SetShadowColor(AValue: TColor);
    procedure SetShadowSize(AValue: Integer);
    procedure SetShowShadow(AValue: Boolean);
  protected
    const DefaultRadius = 16;
    const DefaultShadowSize = 4;
    const DefaultFillColor = clWhite;
    const DefaultBorderColor = $00F0ECE9;
    const DefaultShadowColor = $00E8E3DF;
    const DefaultShowShadow = True;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Radius: Integer read FRadius write SetRadius default DefaultRadius;
    property ShadowSize: Integer read FShadowSize write SetShadowSize default DefaultShadowSize;
    property FillColor: TColor read FFillColor write SetFillColor default DefaultFillColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor default DefaultBorderColor;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default DefaultShadowColor;
    property ShowShadow: Boolean read FShowShadow write SetShowShadow default DefaultShowShadow;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

  { TTisModernButton }

  TTisModernButton = class(TCustomControl)
  private
    FRadius: Integer;
    FHover: Boolean;
    FPressed: Boolean;
    FNormalColor: TColor;
    FOnClick: TNotifyEvent;
    function GetTextColor: TColor;
    procedure SetNormalColor(AValue: TColor);
    procedure SetRadius(AValue: Integer);
    procedure SetTextColor(AValue: TColor);
  protected
    const DefaultRadius = 6;
    const DefaultNormalColor = $00BD9E00;
    const DefaultTextColor = clWhite;
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  published
    property Radius: Integer read FRadius write SetRadius default DefaultRadius;
    property NormalColor: TColor read FNormalColor write SetNormalColor default DefaultNormalColor;
    property TextColor: TColor read GetTextColor write SetTextColor stored False default DefaultTextColor;
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property Caption;
    property Enabled;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  procedure DrawRoundedRect(ACanvas: TCanvas; const R: TRect; ARadius: Integer;
    AFillColor, ABorderColor: TColor; ABorderWidth: Integer = 1);
  function BlendColor(C1, C2: TColor; Pct: Byte): TColor;

implementation

uses
  Types,
  Math,
  LCLIntf;

procedure DrawRoundedRect(ACanvas: TCanvas; const R: TRect; ARadius: Integer;
  AFillColor, ABorderColor: TColor; ABorderWidth: Integer);
begin
  ACanvas.AntialiasingMode := amOn;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := AFillColor;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Color := ABorderColor;
  ACanvas.Pen.Width := ABorderWidth;
  ACanvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, ARadius, ARadius);
end;

function BlendColor(C1, C2: TColor; Pct: Byte): TColor;
var
  r1, g1, b1, r2, g2, b2: Byte;
  r, g, b: Integer;
begin
  C1 := ColorToRGB(C1);
  C2 := ColorToRGB(C2);

  r1 := Red(C1);
  g1 := Green(C1);
  b1 := Blue(C1);
  r2 := Red(C2);
  g2 := Green(C2);
  b2 := Blue(C2);

  r := (r1 * (100 - Pct) + r2 * Pct) div 100;
  g := (g1 * (100 - Pct) + g2 * Pct) div 100;
  b := (b1 * (100 - Pct) + b2 * Pct) div 100;

  Result := RGBToColor(r, g, b);
end;

{ TTisModernPanel }

procedure TTisModernPanel.SetRadius(AValue: Integer);
begin
  if FRadius = AValue then
    Exit;
  FRadius := AValue;
  Invalidate;
end;

procedure TTisModernPanel.SetBorderColor(AValue: TColor);
begin
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Invalidate;
end;

procedure TTisModernPanel.SetFillColor(AValue: TColor);
begin
  if FFillColor = AValue then
    Exit;
  FFillColor := AValue;
  Invalidate;
end;

procedure TTisModernPanel.SetShadowColor(AValue: TColor);
begin
  if FShadowColor = AValue then
    Exit;
  FShadowColor := AValue;
  Invalidate;
end;

procedure TTisModernPanel.SetShadowSize(AValue: Integer);
begin
  if FShadowSize = AValue then
    Exit;
  FShadowSize := AValue;
  Invalidate;
end;

procedure TTisModernPanel.SetShowShadow(AValue: Boolean);
begin
  if FShowShadow = AValue then
    Exit;
  FShowShadow := AValue;
  Invalidate;
end;

procedure TTisModernPanel.Paint;
var
  ShadowRect: TRect;
  MainRect: TRect;
begin
  Canvas.Brush.Style := bsSolid;
  if Parent <> nil then
  begin
    Canvas.Brush.Color := Parent.Color;
    Color := Parent.Color;
  end;
  Canvas.Pen.Style := psClear;
  Canvas.Rectangle(ClientRect);

  if FShowShadow then
  begin
    ShadowRect := Rect(4, 6, Width - 1, Height - 1);
    DrawRoundedRect(Canvas, ShadowRect, FRadius, FShadowColor, FShadowColor, 1);
  end;

  MainRect := Rect(0, 0, Width - FShadowSize, Height - FShadowSize - 2);
  DrawRoundedRect(Canvas, MainRect, FRadius, FFillColor, FBorderColor, 1);
end;

constructor TTisModernPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  FRadius := DefaultRadius;
  FShadowSize := DefaultShadowSize;
  FFillColor := DefaultFillColor;
  FBorderColor := DefaultBorderColor;
  FShadowColor := DefaultShadowColor;
  FShowShadow := DefaultShowShadow;
end;

{ TTisModernButton }

constructor TTisModernButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 75;
  Height := 25;
  FRadius := DefaultRadius;
  Color := clNone;
  FNormalColor := DefaultNormalColor;
  Font.Color := DefaultTextColor;
  TabStop := True;
end;

function TTisModernButton.GetTextColor: TColor;
begin
  Result := Font.Color;
end;

procedure TTisModernButton.SetNormalColor(AValue: TColor);
begin
  if FNormalColor = AValue then
    Exit;
  FNormalColor := AValue;
  Invalidate;
end;

procedure TTisModernButton.SetRadius(AValue: Integer);
begin
  if FRadius = AValue then
    Exit;
  FRadius := AValue;
  Invalidate;
end;

procedure TTisModernButton.SetTextColor(AValue: TColor);
begin
  if Font.Color = AValue then
    Exit;
  Font.Color := AValue;
  Invalidate;
end;

procedure TTisModernButton.MouseEnter;
begin
  inherited MouseEnter;
  FHover := True;
  Invalidate;
end;

procedure TTisModernButton.MouseLeave;
begin
  inherited MouseLeave;
  FHover := False;
  FPressed := False;
  Invalidate;
end;

procedure TTisModernButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FPressed := True;
    Invalidate;
  end;
end;

procedure TTisModernButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FPressed := False;
    Invalidate;
    if PtInRect(ClientRect, Point(X, Y)) then
      Click;
  end;
end;

procedure TTisModernButton.Click;
begin
  inherited Click;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TTisModernButton.Paint;
var
  R: TRect;
  FillCol, BorderCol, BackCol: TColor;
begin
  if Parent <> nil then
    BackCol := Parent.Color
  else
    BackCol := clWhite;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := BackCol;
  Canvas.Pen.Style := psClear;
  Canvas.Rectangle(ClientRect);

  R := Rect(0, 0, Width - 1, Height - 1);

  FillCol := FNormalColor;
  BorderCol := FillCol;
  if FHover then
    FillCol := BlendColor(FillCol, clWhite, 10);
  if FPressed then
    FillCol := BlendColor(FillCol, clBlack, 12);
  BorderCol := FillCol;

  DrawRoundedRect(Canvas, R, FRadius, FillCol, BorderCol, 1);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := Font.Color;
  Canvas.TextOut(Max(0, (Width - Canvas.TextWidth(Caption)) div 2),
                 Max(0, (Height - Canvas.TextHeight(Caption)) div 2 - 1),
                 Caption
                 );
end;

end.
