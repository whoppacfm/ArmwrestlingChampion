unit AlphaBlend;

interface

uses Windows, Classes, Graphics, DXDraws, DirectX, math, SysUtils;

type TBlendColor = Cardinal;

procedure BlendRectangle(Rect: TRect; Alpha: Cardinal; Color: TBlendColor;Surface: TDirectDrawSurface);
procedure DrawShadow(Surface: TDirectDrawSurface;X,Y: Integer;SrcRect: TRect;Source: TDirectDrawSurface;TransparentColor: TBlendColor);

implementation

procedure BlendRectangle(Rect: TRect; Alpha: Cardinal; Color: TBlendColor;Surface: TDirectDrawSurface);
var
  RMask,BMask,GMask    : Cardinal;
  Invert               : Cardinal;
  Mem                  : TDDSurfaceDesc;
  Pointer              : Cardinal;
  ColR,ColB,ColG       : Cardinal;
  Pixels               : Cardinal;
  RValue               : Cardinal;
  BValue               : Cardinal;
  GValue               : Cardinal;
  Weite,Spalte,Zeile   : Integer;
begin
  if IsRectEmpty(Rect) then exit;
  Surface.Canvas.Release;
  Surface.Lock(PRect(nil)^,Mem);
  RMask:=Mem.ddpfPixelFormat.dwRBitMask;
  BMask:=Mem.ddpfPixelFormat.dwBBitMask;
  GMask:=Mem.ddpfPixelFormat.dwGBitMask;
  ColR:=(Color and RMask)*Alpha;
  ColG:=(Color and GMask)*Alpha;
  ColB:=(Color and BMask)*Alpha;
  Invert:=255-Alpha;
  Weite:=(Rect.Right-Rect.Left);
  Pixels:=Weite*((Rect.Bottom-Rect.Top)+1);
  Spalte:=1;
  Zeile:=Rect.Top;
  Pointer:=Integer(Mem.lpSurface)+(Zeile*Mem.lPitch)+(Rect.Left shl 1);
  while (Pixels>0) do
  begin
    if Spalte>Weite then
    begin
      inc(Zeile);
      if Zeile>767 then break;
      Pointer:=Integer(Mem.lpSurface)+(Zeile*Mem.lPitch)+(Rect.Left shl 1);
      Spalte:=1;
    end;
    RValue:=(RMask and ((ColR+(PInteger(Pointer)^ and RMask)*Invert) shr 16));
    GValue:=(GMask and ((ColG+(PInteger(Pointer)^ and GMask)*Invert) shr 16));
    BValue:=(BMask and ((ColB+(PInteger(Pointer)^ and BMask)*Invert) shr 16));
    PWord(Pointer)^:=RValue or GValue or BValue;
    inc(Pointer,2);
    inc(Spalte);
    dec(Pixels);
  end;
  Surface.UnLock;
end;

procedure DrawShadow(Surface: TDirectDrawSurface;X,Y: Integer;SrcRect: TRect;Source: TDirectDrawSurface;TransparentColor: TBlendColor);
var
  MemSur            : TDDSurfaceDesc;
  MemSource         : TDDSurfaceDesc;
  PoiSur            : Cardinal;
  PoiSource         : Cardinal;
  relX,relY         : Integer;
  absX,absY         : Integer;
  CurX,CurY         : Integer;
  Height,Width      : Integer;
  Mask              : Cardinal;
  RMask,BMask,GMask : Cardinal;
begin
  Surface.Canvas.Release;
  Source.Lock(PRect(nil)^,MemSource);
  Surface.Lock(PRect(nil)^,MemSur);
  RMask:=MemSur.ddpfPixelFormat.dwRBitMask;
  BMask:=MemSur.ddpfPixelFormat.dwBBitMask;
  GMask:=MemSur.ddpfPixelFormat.dwGBitMask;
  RMask:=RMask and (RMask shl 1);
  BMask:=BMask and (BMask shl 1);
  GMask:=GMask and (GMask shl 1);
  Mask:=RMask or BMask or GMask;
  AbsY:=Y;
  CurY:=SrcRect.Top;
  Height:=SrcRect.Bottom-SrcRect.Top;
  Width:=SrcRect.Right-SrcRect.Left;
  relY:=0;
  while (AbsY<480) and (relY<Height) do
  begin
    relX:=0;
    AbsX:=X;
    CurX:=SrcRect.Left;
    PoiSource:=Integer(MemSource.lpSurface)+(CurY*MemSource.lPitch)+(CurX shl 1);
    PoiSur:=Integer(MemSur.lpSurface)+(AbsY*MemSur.lPitch)+(AbsX shl 1);
    while (AbsX<640) and (relX<Width) do
    begin
      if PWord(PoiSource)^<>TransparentColor then
      begin
        PWord(PoiSur)^:=(PWord(PoiSur)^ and Mask) shr 1;
      end;
      inc(PoiSur,2);
      inc(PoiSource,2);
      inc(relX);
      inc(absX);
    end;
    inc(relY);
    inc(AbsY);
    inc(CurY);
  end;
  Source.UnLock;
  Surface.UnLock;
end;

end.
