{
  2D Grafik Effekte auf Basis von unDelphiX
  (c) Christian Merz 2005
}


unit dxEffectLibrary;

interface

uses
  DXFusion
  , DIB
  , DXDraws
  , DXClass
  , Graphics
  , sysutils
  , Forms
  , Types
  , windows

  ;

Const
  SP_AMOUNT = 1000;

Type
  TSpark = Record
    X, Y, SX, SY, Age, Aging: real;
  End;

Type
  TFireSpark = Class
  private
    fDXImageList1: TDXImageList;
    fDXDraw1: TDXDraw;

    fBackBuffer: TDXDIB;
    fDXDIB1: TDXDIB;

    FSparks : Array[0..SP_AMOUNT] Of TSpark;
    FX, FY: integer;

//    procedure MakeFire2;
  Public
    constructor Create(dxdraw:TDXDraw);
    destructor destroy;override;
    procedure MakeFire1; {onTimer}
  End;

Implementation

destructor TFireSpark.destroy;
begin
  freeandnil(fDXImageList1);
  freeandnil(fBackBuffer);
  freeandnil(fDXDIB1);

  inherited destroy;
end;

constructor TFireSpark.Create(dxdraw:TDXDraw);
Var
  i: integer;
Begin
  inherited create;

  fDXDraw1 := dxdraw;
  fDXImageList1:=TDXImageList.Create(fdxdraw1);
  fDxImageList1.DXDraw := dxDraw;
  fDXImageList1.Items.Add;
  fDXImageList1.Items.Items[fdxImageList1.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.exename)+'images\fire.bmp');
  fdxImageList1.Items.Add;

  fBackBuffer:=TDXDIB.Create(fDXDraw1);
  fDXDIB1:=TDXDIB.create(fDXDraw1);

  //fDXDraw1.Cursor := crNone;

  For i := 0 To SP_AMOUNT Do
    With FSparks[i] Do
    Begin
      X := dxdraw.Width / 2;
      Y := dxdraw.Width / 2;
      SX := (random(11) - 5) / 5;
      SY := (random(11) - 5) / 5;
      Age := 0;
      Aging := (random(15) + 2) / 150;
    End;
End;

procedure TFireSpark.MakeFire1;
Var
  i: integer;
  fBitmap:TBitmap;
  dxdc:hdc;
Begin
  If NOT fDXDraw1.CanDraw Then Exit;
  fDXDIB1.DIB.Assign(fDXImageList1.Items.Items[0].picture); //Fire


//  fbackbuffer.DIB.Canvas.Draw(0,0,);
//  fbackbuffer.DIB.Canvas.Pixels := fdxdraw1.Surface.Pixels;
//  FBackbuffer.DIB.Assign(CreateDIBFromBitmap(fBitmap));


//  FBackBuffer.DIB.Assign(Dest);

  For i := 0 To SP_AMOUNT Do
    With FSparks[i] Do
    Begin
      Age := Age + Aging;
      X := X + SX;
      Y := Y + SY;

      If (Age > 1) Or (X < 0) Or (X + fDXImageList1.Items.items[0].Height > fDXDraw1.Width) Or (Y < 0) Or (Y + fDXImageList1.Items.items[0].Height > fDXDraw1.Height) Then
      Begin
        X := FX;
        Y := FY;
        SX := (random(21) - 10) / 5;
        SY := (random(21) - 10) / 5;
        Age := 0;
        Aging := (random(10) + 3) / 100;
      End;

      DrawAdditive(FBackBuffer.DIB, fDXDIB1.DIB, round(X), round(Y), fDXImageList1.Items.items[0].Height, fDXImageList1.Items.Items[0].Height, 255,ROUND(Age * 4));
    End;

//    CopyRect(fdxdraw1.clientrect,FBackbuffer.DIB.Canvas.ClipRect);


//  dxdc := GetDC(fdxdraw1.Handle);
//  BitBlt(dxdc,0,0,fdxdraw1.Width,fdxdraw1.Height,fBackbuffer.DIB.Canvas.Handle,0,0,SRCCOPY);
  //  BitBlt( DestCanvas.Handle, Dest.Left, Dest.Top, Dest.Right, Dest.Bottom, SrcCanvas.Handle, Xsrc, Ysrc, SRCCOPY);
  //DrawOn(FBackBuffer.DIB.Canvas,fDXDraw1.ClientRect, fDXDraw1.Surface.Canvas, 0, 0);
//  ReleaseDC(fdxdraw1.Handle, dxdc);



  //DrawOn(FBackBuffer.DIB.Canvas, fdximagelist1.Items.items[1].PatternRects[0],  fdximagelist1.Items.items[1].Picture.Bitmap.Canvas, 0, 0);

   fdxImageList1.Items.Items[1].Picture.Assign(FBackbuffer.DIB);

   fdximagelist1.Items.items[0].Draw(fdxdraw1.Surface,0,0,0);


//  with fDXDraw1.Surface.Canvas do
//  begin
//    try
//      Brush.Style := bsClear;
//      Font.Color := clWhite;
//      Font.Size := 12;
//      Textout(0, 0, 'FPS: '+inttostr(DXTimer1.FrameRate));
//      if doHardware in DXDraw1.NowOptions then
//        Textout(0, 14, 'Device: Hardware')
//      else
//        Textout(0, 14, 'Device: Software');
//    finally
//      Release; {  Indispensability  }
//    end;
//  end;

  //DXDraw1.Flip;
end;


{
procedure TFireSpark.MakeFire2;
Var
  i: integer;
  R: TRect;
Begin
  If NOT DXDraw1.CanDraw Then Exit;

  DXDraw1.Surface.Fill(0);

  For i := 0 To SP_AMOUNT Do
    With FSparks[i] Do
    Begin
      Age := Age + Aging;
      X := X + SX;
      Y := Y + SY;

      If (Age > 1) Or (X < 0) Or (X + DXImageList1.Items.Find('Sparks').Height > Width) Or (Y < 0) Or (Y + DXImageList1.Items.Find('Sparks').Height > Height) Then
      Begin
        X := FX;
        Y := FY;
        SX := (random(21) - 10) / 5;
        SY := (random(21) - 10) / 5;
        Age := 0;
        Aging := (random(10) + 3) / 100;
      End;
      //jako Rect() ale zadava se sirka,vyska
      R := Bounds(round(X), round(Y), DXImageList1.Items.Find('Sparks').Height, DXImageList1.Items.Find('Sparks').Height);
      DXImageList1.Items.Find('Sparks').DrawAdd(DXDraw1.Surface,R,ROUND(Age * 4))
    End;

  with DXDraw1.Surface.Canvas do
  begin
    try
      Brush.Style := bsClear;
      Font.Color := clWhite;
      Font.Size := 12;
      Textout(0, 0, 'FPS: '+inttostr(DXTimer1.FrameRate));
      if doHardware in DXDraw1.NowOptions then
        Textout(0, 14, 'Device: Hardware')
      else
        Textout(0, 14, 'Device: Software');
    finally
      Release;
    end;
  end;

  DXDraw1.Flip;
end;
}
End.

