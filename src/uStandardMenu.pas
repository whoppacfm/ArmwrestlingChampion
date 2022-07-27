{
  Basisklassen für In-Game-Menüverwaltung

  Projekt:  Armwrestling
  Unit:     uStandardMenu.pas
  Stand:    19.Januar 2005
  (c) Christian Merz 2005
}

unit uStandardMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXClass, DXDraws, ContNrs, DXSprite, jpeg, stdctrls, DIB, ExtCtrls;//, DXPowerFont;

type
  TStandardConfig = class
  protected
    fTransparentColor : string;
    fX:integer;
    fY:integer;
    fW:integer;
    fH:integer;
    fListIndex:integer;
  public
    constructor create(x,y,w,h,listindex:integer);
    property ListIndex : integer read fListIndex;
    property X : integer read fX write fX;
    property Y : integer read fY write fY;
    property W : integer read fW write fW;
    property H : integer read fH write fH;
  end;

  TImageConfig = class(TStandardConfig)
  public
    visible : boolean;
    alpha : integer;
    constructor create(Pfad:string;Transparenz:string;X,Y:integer;DXList:TDXImageList);
  end;

  TBackConfig = class(TStandardConfig)
  public
    fAnzahl:integer;
    fIndex:integer;
    constructor create(Pfade:TStringList;DXList:TDXImageList);
  end;

  TButtonConfig = class(TStandardConfig)
  public
    fStyle : integer; // 0,1,2 (standard, over, down) -> DrawIndex + fStyle
    constructor create(P1,P2,P3:string;Transparenz:string;X,Y:integer;DXList:TDXImageList);
  end;

  TLabelConfig = class(TStandardConfig)
  public
    fLabel:string;
    fVisible:boolean;
    FontStyle:string;
    fAlpha:integer;
    constructor create(FontStyle_:string;Text:string;X,Y:integer);
  end;

  {
  Verwaltet ein Menü
  Use: Klasse von TMenuClass ableiten und ButtonPress implementieren
       Config-Datei erstellen
  }
  TMenuClass = class
  private
    fImageConfigList : TObjectList;
    fButtonConfigList : TObjectList;
    fLabelConfigList : TObjectList;
    fBackConfig : TBackConfig;
    //fDXList:TDXImageList;
    procedure NewImage(Pfad:string;Transparenz:string;X,Y:integer);
    procedure NewButton(P1,P2,P3:string;Transparenz:string;X,Y:integer);
    procedure NewLabel(FontStyle:string;Text:string;X,Y:integer);
    procedure NewBackground(Pfade:TStringList);
    function GetConfigFile:string;
	public
    fDXList:TDXImageList;
    fDXDraw:TDXDraw;

    //Für Over-Sound
    notover : boolean;
    oldBIndex : integer;
    //---

    //Meldungen anzeigen
    fShowMeldung:boolean;
    fMeldungsText:string;
    procedure ShowMeldung(index:integer);

    constructor Create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
    procedure AfterAltTab;
    destructor destroy;override;

    procedure ButtonPress(bIndex:integer);virtual;
    procedure MouseButtonOver(bIndex:integer);virtual;
    procedure DrawMenuSpecific;virtual;
    procedure MouseDown(x,y:integer);virtual;
    procedure MouseOver(x,y:integer);virtual;
    procedure MouseUp;virtual;

    procedure SetButtonsStandard;
    function CheckButtonsOver(CursorPo:TPoint):integer; //Index
    procedure SetButtonDown(Index:integer);
    procedure DrawAll;

    property ImageConfigList : TObjectList read fImageConfigList write fImageConfigList;
    property ButtonConfigList : TObjectList read fButtonConfigList write fButtonConfigList;
    property LabelConfigList : TObjectList read fLabelConfigList write fLabelConfigList;
    property BackConfig : TBackConfig read fBackConfig write fBackConfig;
  end;

  procedure Antialiasing(Image: TBitmap; Percent: Integer;Ausschluss:TColor);


implementation

uses StrUtils,Main;


procedure Antialiasing(Image: TBitmap; Percent: Integer;Ausschluss:TColor);
type
  TRGBTripleArray = array[0..32767] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
var
  SL, SL2: PRGBTripleArray;
  l, m, p: Integer;
  R, G, B: TColor;
  R1, R2, G1, G2, B1, B2: Byte;
begin
  with Image.Canvas do
  begin
    Brush.Style  := bsClear;
    Pixels[1, 1] := Pixels[1, 1];
    for l := 0 to Image.Height - 1 do
    begin
      SL := Image.ScanLine[l];
      for p := 1 to Image.Width - 1 do
      begin
        R1 := SL[p].rgbtRed;
        G1 := SL[p].rgbtGreen;
        B1 := SL[p].rgbtBlue;


//        if RGB(SL[p].rgbtRed,SL[p].rgbtGreen,SL[p].rgbtBlue) <> Ausschluss then
        //if (SL[p].rgbtRed <> 255) and (SL[p].rgbtGreen <> 0) and (SL[p].rgbtBlue <> 255) then
//        begin

          // Left
          if (p < 1) then m := Image.Width
          else
            m := p - 1;
          R2 := SL[m].rgbtRed;
          G2 := SL[m].rgbtGreen;
          B2 := SL[m].rgbtBlue;
          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
            G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
            B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
            SL[m].rgbtRed := R;
            SL[m].rgbtGreen := G;
            SL[m].rgbtBlue := B;
          end;

          //Right
          if (p > Image.Width - 2) then m := 0
          else
            m := p + 1;
          R2 := SL[m].rgbtRed;
          G2 := SL[m].rgbtGreen;
          B2 := SL[m].rgbtBlue;
          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
            G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
            B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
            SL[m].rgbtRed := R;
            SL[m].rgbtGreen := G;
            SL[m].rgbtBlue := B;
          end;

          if (l < 1) then m := Image.Height - 1
          else
            m := l - 1;
          //Over
          SL2 := Image.ScanLine[m];
          R2  := SL2[p].rgbtRed;
          G2  := SL2[p].rgbtGreen;
          B2  := SL2[p].rgbtBlue;
          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
            G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
            B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
            SL2[p].rgbtRed := R;
            SL2[p].rgbtGreen := G;
            SL2[p].rgbtBlue := B;
          end;

          if (l > Image.Height - 2) then m := 0
          else
            m := l + 1;
          //Under
          SL2 := Image.ScanLine[m];
          R2  := SL2[p].rgbtRed;
          G2  := SL2[p].rgbtGreen;
          B2  := SL2[p].rgbtBlue;
          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
            G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
            B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
            SL2[p].rgbtRed := R;
            SL2[p].rgbtGreen := G;
            SL2[p].rgbtBlue := B;
          end;

        //end;
      end;
    end;
  end;
end;

procedure  TMenuClass.MouseDown(x,y:integer);
begin
  //..
end;

procedure TMenuClass.MouseUp;
begin
  //..
end;

procedure  TMenuClass.MouseOver(x,y:integer);
begin
  //..
end;

procedure TMenuClass.DrawMenuSpecific;
begin
//  sleep(100);
  //..überschreiben, wird in dieser Unit aufgerufen, daher nicht abstrakt deklariert
end;

procedure TMenuClass.NewImage(Pfad:string;Transparenz:string;X,Y:integer);
begin
  try
    fImageConfigList.Add(TImageConfig.create(Pfad,Transparenz,x,y,fDXList));
  except
    on e:exception do
      showmessage('uStandardMenu->TMenuClass->NewImage: '+e.message);
  end;
end;

procedure TMenuClass.NewButton(P1,P2,P3:string;Transparenz:string;X,Y:integer);
begin
  try
    fButtonConfigList.Add(TButtonConfig.create(P1,P2,P3,Transparenz,x,y,fDXList));
  except
    on e:exception do
      showmessage('uStandardMenu->TMenuClass->NewButton: '+e.message);
  end;
end;

procedure TMenuClass.NewLabel(FontStyle:string;Text:string;X,Y:integer);
begin
  try
    fLabelConfigList.add(TLabelConfig.create(FontStyle,Text,x,y));
  except
    on e:exception do
      showmessage('uStandardMenu->TMenuClass->NewLabel: '+e.message);
  end;
end;

procedure TMenuClass.NewBackground(Pfade:TStringList);
begin
  try
    fBackConfig := TBackConfig.create(Pfade,fDXList);
  except
    on e:exception do
      showmessage('uStandardMenu->TMenuClass->NewBackground: '+e.message);
  end;
end;

constructor TStandardConfig.create(x,y,w,h,listindex:integer);
begin
  fX := round(x/1.28);
  fY := round(y/1.28);
  fW := w;//round(w/1.28);
  fH := h;//round(h/1.28);
  fListIndex := listindex;
end;

constructor TLabelConfig.create(FontStyle_:string;Text:string;X,Y:integer);
begin
  //fLabel := TLabel.Create(dxDraw);
  fLabel := Text;
  fVisible := true;
  FontStyle := FontStyle_;
//  fAlpha := -1;
//
//  if LowerCase(Fontstyle) = 'big' then Fontstyle := 'Font1';
//  if LowerCase(Fontstyle) = 'small' then Fontstyle := 'Font2';
//  if LowerCase(Fontstyle) = 'mittel' then Fontstyle := 'Font3';
//
//  if LowerCase(Fontstyle) = 'bw' then
//  begin
//    Fontstyle := 'FontN';
//    fAlpha := 140;
//  end;
//
//  if LowerCase(Fontstyle) = 'news' then
//  begin
//    Fontstyle := 'FontN';
//    fAlpha := 255;
//  end;




//  with fLabel do
//  begin
//    Parent := dxdraw;
//    Left := x;
//    Top := y;
//    Transparent := true;
//    autosize := true;
////    Font.Size := 20;
//    Font.Color := clWhite;
//    Font.Name := '04b 30';
//  end;
  inherited Create(x,y,0,0,-1);
end;

constructor TImageConfig.create(Pfad:string;Transparenz:string;X,Y:integer;DXList:TDXImageList);
var
  i,j,k : integer;
  Color: Longint;
  r, g, b: Byte;
  l  :TStringList;
begin
  visible := true;
  dxList.Items.Add;

  form1.Logger.Add('TImageConfig.create->dxlist.items.loadfromfile' + Pfad);
  dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+Pfad);
  form1.Logger.Add('TImageConfig.create->dxlist.items.loadfromfile' + Pfad + 'PASSED');

  fListIndex := dxList.Items.Count-1;
  alpha := -1;

  if Transparenz <> 'x' then
  begin


      // Transparent Mode
    // MaskHandle
    // fDXList.Items.Items[(fImageConfigList[i] as TImageConfig).fListIndex].Picture.Bitmap
    //Blau, Grün, Rot


//    for j := 0 to dxList.Items.Items[dxList.Items.Count-1].width do
//    begin
//      for k := 0 to dxList.Items.Items[dxList.Items.Count-1].height do
//      begin
//        //Blau,Rot = FF
//        Color := ColorToRGB(ColorToRGB(dxList.Items.Items[dxList.Items.Count-1].Picture.Bitmap.Canvas.Pixels[j,k]));
//        r     := Color;
//        g     := Color shr 8;
//        b     := Color shr 16;

//        if ((g < 170) and (b < 170) and (r < 170)) then
//        if (r+g+b > 450) and (r+g+b < 550) then
//        begin
//          dxList.Items.Items[dxList.Items.Count-1].Picture.Bitmap.Canvas.Pixels[j,k] := clwhite;
//        end;
       //dxList.Items.Items[dxList.Items.Count-1].Picture.Bitmap.Canvas.Pixels[j,k] := clBlue;
//      end
//    end;

    //Antialiasing(dxList.Items.Items[dxList.Items.Count-1].Picture.Bitmap,80,$FF00FF);

    delete(Transparenz,1,1); //$-Zeichen löschen
    Transparenz := '02'+Transparenz; //02 = ähnlichste Farbe im Gerätekontext
    dxList.Items.Items[dxList.Items.Count-1].Transparent := true;
    dxList.Items.Items[dxList.Items.Count-1].TransparentColor := $FF00FF;//clblack;//TColor(strtohex(Transparenz));//StrtoHex(transparenz); //$02+
  end;

  inherited Create(x,y,dxList.Items.Items[dxList.Items.Count-1].width, dxlist.Items.Items[dxList.Items.Count-1].height,fListIndex);
end;

constructor TButtonConfig.create(P1,P2,P3:string;Transparenz:string;X,Y:integer;DXList:TDXImageList);
begin
  form1.Logger.Add('TButtonConfig.create->dxlist.items.loadfromfile' + P1);

  dxList.Items.Add;
  dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+P1);
  fListIndex := dxList.Items.Count-1;
//  Antialiasing(dxList.Items.Items[dxList.Items.Count-1].Picture.Bitmap,20,clWhite);

  form1.Logger.Add('TButtonConfig.create->dxlist.items.loadfromfile' + P1 + '  PASSED');


  form1.Logger.Add('TButtonConfig.create->dxlist.items.loadfromfile' + P2);

  dxList.Items.Add;
  dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+P2);

  form1.Logger.Add('TButtonConfig.create->dxlist.items.loadfromfile' + P2 + '  PASSED');


  form1.Logger.Add('TButtonConfig.create->dxlist.items.loadfromfile' + P3);

  dxList.Items.Add;
  dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+P3);

  form1.Logger.Add('TButtonConfig.create->dxlist.items.loadfromfile' + P3 + '  PASSED');

  form1.Logger.Add('TButtonConfig.create->SetTransparent-Colors');

  dxList.Items.Items[dxList.Items.Count-1].Transparent := false;
  dxList.Items.Items[dxList.Items.Count-2].Transparent := false;
  dxList.Items.Items[dxList.Items.Count-3].Transparent := false;

  fTransparentColor := Transparenz;
  if Transparenz <> 'x' then
  begin
    dxList.Items.Items[dxList.Items.Count-1].Transparent := true;
    dxList.Items.Items[dxList.Items.Count-2].Transparent := true;
    dxList.Items.Items[dxList.Items.Count-3].Transparent := true;

    if Transparenz = 'black' then
    begin
      dxList.Items.Items[dxList.Items.Count-1].TransparentColor := clBlack;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
      dxList.Items.Items[dxList.Items.Count-2].TransparentColor := clBlack;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
      dxList.Items.Items[dxList.Items.Count-3].TransparentColor := clBlack;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
    end else
    begin
      dxList.Items.Items[dxList.Items.Count-1].TransparentColor := $FF00FF;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
      dxList.Items.Items[dxList.Items.Count-2].TransparentColor := $FF00FF;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
      dxList.Items.Items[dxList.Items.Count-3].TransparentColor := $FF00FF;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
    end;

//    delete(Transparenz,1,1); //$-Zeichen löschen
//    Transparenz := '$02'+Transparenz; //02 = ähnlichste Farbe im Gerätekontext
//    dxList.Items.Items[dxList.Items.Count-1].Transparent := true;
//    dxList.Items.Items[dxList.Items.Count-2].Transparent := true;
//    dxList.Items.Items[dxList.Items.Count-3].Transparent := true;
//    dxList.Items.Items[dxList.Items.Count-1].TransparentColor := clBlack;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
//    dxList.Items.Items[dxList.Items.Count-2].TransparentColor := clBlack;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
//    dxList.Items.Items[dxList.Items.Count-3].TransparentColor := clBlack;//TColor(Transparenz);//StrtoHex(transparenz); //$02+
  end;

  inherited Create(x,y,dxList.Items.Items[dxList.Items.Count-1].width, dxlist.Items.Items[dxList.Items.Count-1].height,fListIndex);
end;


constructor TBackConfig.create(Pfade:TStringList;DXList:TDXImageList);
begin
  fAnzahl := Pfade.count;

  form1.Logger.Add('TBackConfig.create LoadFromFile'  + Pfade[0]);

  dxList.Items.Add;
  dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+Pfade[0]);
  dxList.Items.Items[dxList.Items.Count-1].Transparent := false;
  fListIndex := dxList.Items.Count-1;
  fIndex := 0;

  form1.Logger.Add('TBackConfig.create LoadFromFile'  + Pfade[0] + ' PASSED');



  if fAnzahl > 1 then
  begin
    form1.Logger.Add('TBackConfig.create LoadFromFile'  + Pfade[1]);

    dxList.Items.Add;
    dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+Pfade[1]);
    dxList.Items.Items[dxList.Items.Count-1].Transparent := false;
    form1.Logger.Add('TBackConfig.create LoadFromFile'  + Pfade[1] + ' PASSED');

  end;
  if fAnzahl > 2 then
  begin
    form1.Logger.Add('TBackConfig.create LoadFromFile'  + Pfade[2]);

    dxList.Items.Add;
    dxList.Items.Items[dxList.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+Pfade[2]);
    dxList.Items.Items[dxList.Items.Count-1].Transparent := false;
    form1.Logger.Add('TBackConfig.create LoadFromFile'  + Pfade[2] + ' PASSED');

  end;
end;

procedure TMenuClass.ButtonPress(bIndex:integer);
begin
  if fshowmeldung then exit;
//  fBackgroundIndex := 2;
  if self is TMainmenuclass then if fBackConfig.fAnzahl > 2 then fBackConfig.fIndex := 2;
end;

procedure TMenuClass.MouseButtonOver(bIndex:integer);
begin
  if fshowmeldung then exit;
  //..
end;


procedure TMenuClass.SetButtonsStandard;
var
  i : integer;
begin
  for i := 0 to fButtonConfigList.Count - 1 do
  begin
    //if (fButtonConfigList[i] as TButtonConfig).fStyle <> 2 then
      (fButtonConfigList[i] as TButtonConfig).fStyle := 0;
  end;

//	for i := 0 to fActiveMenu.ConfigPosList.Count - 1 do
//  begin
//    if ((fActiveMenu.ConfigPosList[i] as TMenuConfig).fStyle = 2) then
//    begin
//      (fActiveMenu.ConfigPosList[i] as TMenuConfig).fActive := false;
//      (fActiveMenu.ConfigPosList[i-1] as TMenuConfig).fActive := true;
//    end;
//    if ((fActiveMenu.ConfigPosList[i] as TMenuConfig).fStyle = 3) then
//    begin
//      (fActiveMenu.ConfigPosList[i] as TMenuConfig).fActive := false;
//      (fActiveMenu.ConfigPosList[i-2] as TMenuConfig).fActive := true;
//    end;
//	end;
end;

function TMenuClass.CheckButtonsOver(CursorPo:TPoint):integer; //Index
var
  i : integer;
begin
  result := -1;

  if fBackConfig.fIndex = 1 then fBackConfig.fIndex := 0;
	for i := 0 to fButtonConfigList.Count - 1 do
  begin
  	if (CursorPo.x > (fButtonConfigList[i] as TButtonConfig).fX) and (CursorPo.x < (fButtonConfigList[i] as TButtonConfig).fX + (fButtonConfigList[i] as TButtonConfig).fW)
		and (CursorPo.y > (fButtonConfigList[i] as TButtonConfig).fY) and (CursorPo.y < (fButtonConfigList[i] as TButtonConfig).fY + (fButtonConfigList[i] as TButtonConfig).fH) then
    begin
      if (fButtonConfigList[i] as TButtonConfig).fStyle <> 2 then
        (fButtonConfigList[i] as TButtonConfig).fStyle := 1;
      MouseButtonOver(i);
      if (notover) and (self is TMainMenuClass) then
      begin
        Form1.PlayMouseOver;
        notover := false;
      end;
      result := i;
      if (fBackConfig.fAnzahl > 1) and (fBackConfig.findex=0) then fBackConfig.fIndex := 1;
      exit;
    end else
    begin
      MouseButtonOver(-1); // Kein Button-Over
    end;
  end;

  notover := true;
end;

procedure TMenuClass.SetButtonDown(Index:integer);
begin
  (fButtonConfigList[Index] as TButtonConfig).fStyle := 2;
end;

procedure TMenuClass.ShowMeldung(index:integer);
begin
//  fShowMeldung := true;
//  case index of
//  0:fMeldungsText := 'Spielstand wirklich überschreiben?';
//  1:fMeldungsText := 'Spielstand erfolgreich gespeichert.';
//  2:fMeldungsText := 'Spielstand erfolgreich geladen.';
//  3:fMeldungsText := 'Spiel wirklich beenden?';
//  end;
end;

procedure TMenuClass.DrawAll;
var
  i,j,k : integer;
  dxDC : hdc;
  //f : TFont;
  rect:TRect;
begin
  //f := TFont.Create;

  {Hintergrund}
  fDXList.Items.Items[FBackConfig.fListIndex + fBackConfig.fIndex].Draw(fdxdraw.Surface,0,0,0);

  {Images}
  for i := 0 to fImageConfigList.Count - 1 do
  begin
    if (fImageConfigList[i] as TImageConfig).visible then
    begin
      if (fImageConfigList[i] as TImageConfig).alpha <> -1 then
      begin
        rect.Left := (fImageConfigList[i] as TImageConfig).X;
        rect.Top := (fImageConfigList[i] as TImageConfig).Y;
        rect.Right := (fImageConfigList[i] as TImageConfig).X + (fImageConfigList[i] as TImageConfig).W;
        rect.Bottom := (fImageConfigList[i] as TImageConfig).y + (fImageConfigList[i] as TImageConfig).h;
        fDXList.Items.Items[(fImageConfigList[i] as TImageConfig).fListIndex].DrawAlpha(fdxdraw.Surface,rect,0,(fImageConfigList[i] as TImageConfig).alpha);
      end else
      begin
        fDXList.Items.Items[(fImageConfigList[i] as TImageConfig).fListIndex].Draw(fdxdraw.Surface,(fImageConfigList[i] as TImageConfig).X,(fImageConfigList[i] as TImageConfig).Y,0);
      end;
    end;
  end;

  {Buttons}
  for i := 0 to fButtonConfigList.Count - 1 do
  begin
//    if (self is TGameMenuClass) then
//    begin
//      rect.Left := (fButtonConfigList[i] as TButtonConfig).X;
//      rect.Top := (fButtonConfigList[i] as TButtonConfig).y;
//      rect.Right := (fButtonConfigList[i] as TButtonConfig).X + (fButtonConfigList[i] as TButtonConfig).W;
//      rect.Bottom := (fButtonConfigList[i] as TButtonConfig).y+(fButtonConfigList[i] as TButtonConfig).H;
//      fDXList.Items.Items[(fButtonConfigList[i] as TButtonConfig).fListIndex+(fButtonConfigList[i] as TButtonConfig).fStyle].DrawAlpha(fdxdraw.Surface,rect,0,180);
//    end else
//    begin
      fDXList.Items.Items[(fButtonConfigList[i] as TButtonConfig).fListIndex+(fButtonConfigList[i] as TButtonConfig).fStyle].Draw(fdxdraw.Surface,(fButtonConfigList[i] as TButtonConfig).X,(fButtonConfigList[i] as TButtonConfig).Y,0);
//    end;
  end;

  {Labels}

  for i := 0 to fLabelConfigList.count - 1 do
  begin

//    form1.DXPowerFont1.TextOutEffect := teAlphaBlend;
//    form1.DXPowerFont1.EffectsParameters.AlphaValue := 180;

    if (self.LabelConfigList[i] as TLabelConfig).fvisible then
    begin
//      if (self.LabelConfigList[i] as TLabelConfig).fAlpha <> -1 then
//      begin
//        form1.DXPowerFont1.TextOutEffect := teAlphaBlend;
//        form1.DXPowerFont1.EffectsParameters.AlphaValue := (self.LabelConfigList[i] as TLabelConfig).fAlpha;
//        form1.DXPowerFont1.TextOut(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);
//      end else
//      begin
//        form1.DXPowerFont1.Font := (self.LabelConfigList[i] as TLabelConfig).FontStyle;
//        form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);
//      end;
//
//
//    end;

      if (self.LabelConfigList[i] as TLabelConfig).FontStyle = 'big' then
      begin
        form1.DXPowerFont1.Font := 'Font1';
        form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);

      end else if (self.LabelConfigList[i] as TLabelConfig).FontStyle = 'small' then
      begin
        form1.DXPowerFont1.Font := 'Font2';
        form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);

      end else if (self.LabelConfigList[i] as TLabelConfig).FontStyle = 'mittel' then
      begin
        form1.DXPowerFont1.Font := 'Font3';
        form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);

      end else if (self.LabelConfigList[i] as TLabelConfig).FontStyle = 'bw' then
      begin
        form1.DXPowerFont1.Font := 'FontN';
        form1.DXPowerFont1.TextOutEffect := teAlphaBlend;
        form1.DXPowerFont1.EffectsParameters.AlphaValue := 140;
        form1.DXPowerFont1.TextOut(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);

      end else if (self.LabelConfigList[i] as TLabelConfig).FontStyle = 'news' then
      begin
        form1.DXPowerFont1.Font := 'FontN';
//        form1.DXPowerFont1.TextOutEffect := teAlphaBlend;
//        form1.DXPowerFont1.EffectsParameters.AlphaValue := 255;
//        form1.DXPowerFont1.TextOut(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);
        form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);

      end else if (self.LabelConfigList[i] as TLabelConfig).FontStyle = 'news2' then
      begin
        form1.DXPowerFont1.Font := 'FontN2';
//        form1.DXPowerFont1.TextOutEffect := teAlphaBlend;
//        form1.DXPowerFont1.EffectsParameters.AlphaValue := 255;
//        form1.DXPowerFont1.TextOut(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);
        form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,(self.LabelConfigList[i] as TLabelConfig).X, (self.LabelConfigList[i] as TLabelConfig).Y,(self.LabelConfigList[i] as TLabelConfig).fLabel);
      end;
    end;
//    //(self.LabelConfigList[i] as TLabelConfig).fLabel.Invalidate;
  end;


  DrawMenuSpecific;
end;

function TMenuClass.GetConfigFile:string;
begin
	Result := ExtractFilePath(application.ExeName)+'\config\'+Self.ClassName+'.mmf';
end;

destructor TMenuClass.destroy;
var
  i : integer;
begin
  freeandnil(fImageConfigList);
  freeandnil(fButtonConfigList);
  freeandnil(fBackConfig);
  freeandnil(fLabelConfigList);
  freeandnil(fDXList);

  form1.Logger.LogFile.Clear;

  inherited destroy;
end;

procedure TMenuClass.AfterAltTab;
var
  MenuConfig : TStringList;
  i,j : integer;
  temp, temp2 : string;
  bez,pfad : string;
  left1,top1,width,height,style : integer;
  Active:Boolean;
  tempLabel : TLabel;
  Limit:TStringList;
  Item,Rest:string;
begin
    fShowMeldung := false;
    oldbIndex := -5;
    form1.Logger.Add('TMenuClass.create');

    Form1.goOut := true; //FadeOut
    Form1.goIn := false; //FadeIn



//    fDXList := TDXImageList.Create(DXDraw);
//    fDXList.DXDraw := DXDraw;
//    fDXList.Items := TPictureCollection.Create(dxdraw);

//    fImageConfigList := TObjectList.create;
//    fButtonConfigList := TObjectList.create;
//    fLabelConfigList := TObjectList.Create;

      fdxlist.Items.Clear;
      fimageConfigList.Clear;
      fbuttonConfiglist.Clear;
      flabelconfiglist.Clear;


  try

  MenuConfig := TStringList.Create;
  MenuConfig.LoadFromFile(GetConfigFile);

  Limit := TStringList.Create;
  Limit.Delimiter := ';';
  try
    for i := 0 to MenuConfig.Count - 1 do
    begin
      Item := '';
      if (pos(';',MenuConfig[i]) = 0) or (MenuConfig[i][1]='/') then continue;
      Item := copy(MenuConfig[i],1,Pos(';',MenuConfig[i])-1);
      Rest := copy(MenuConfig[i],Pos(';',MenuConfig[i])+1,Length(MenuConfig[i]));

      if Item = 'Image' then
      begin
        form1.Logger.Add('TMenuClass.create->NewImage ' + Limit.Text);

        Limit.DelimitedText := Rest;
        NewImage(Limit[0],Limit[3],strtoint(Limit[1]),strtoint(Limit[2]));
        Limit.Clear;
        form1.Logger.Add('TMenuClass.create->NewImage ' + Limit.Text + ' PASSED');

      end else if Item = 'Button' then
      begin
        form1.Logger.Add('TMenuClass.create->NewButton ' + Limit.Text);

        Limit.DelimitedText := Rest;
        NewButton(Limit[0],Limit[1],Limit[2],Limit[5],strtoint(Limit[3]),strtoint(Limit[4]));
        Limit.clear;

        form1.Logger.Add('TMenuClass.create->NewButton ' + Limit.text + ' PASSED');

      end else if Item = 'Background' then
      begin
        form1.Logger.Add('TMenuClass.create->NewBackground ' + Limit.text);

        Limit.DelimitedText := Rest;
        Limit.Delete(0);
        NewBackground(Limit);
        Limit.Clear;
        form1.Logger.Add('TMenuClass.create->NewBackground ' + Limit.Text + ' PASSED');

      end else if Item = 'Label' then
      begin
        form1.Logger.Add('TMenuClass.create->NewLabel ' + Limit.text);

        Limit.DelimitedText := Rest;
        Limit.Add(' ');
        for j := 4 to Limit.Count - 1 do
        begin
          Limit[3] := Limit[3] + ' ' + Limit[j];
        end;
        NewLabel(Limit[2],trim(Limit[3]),strtoint(Limit[0]),strtoint(Limit[1]));
        Limit.Clear;
        form1.Logger.Add('TMenuClass.create->NewLabel ' + Limit.text + ' PASSED');

      end else if Item = 'Animation' then
      begin
        //..
      end;
    end;
  finally
    freeandnil(Limit);
  end;

//    if form1.faBackground <> nil then
//    begin
//      if (not (self is TNachKneipenkampfMenuClass)) and (not (self is TNachSaisonkampf1MenuClass)) and (not (self is TNachTurnierKampfMenuClass)) then
//      begin
//        form1.faBackground.DIB.Assign(self.fDXList.Items.Items[self.BackConfig.ListIndex].Picture);
//        form1.faDXDIB1.DIB.SetSize(form1.faBackground.DIB.Width,form1.faBackground.DIB.Height,form1.faBackground.DIB.BitCount);
//        form1.FillDIB8(form1.faDXDIB1.DIB,255);
//        Form1.FadeSpeed := 8;
//        form1.fac:=0;
//      end;
//    end;

  finally
    freeandnil(MenuConfig);
  end;
end;


constructor TMenuClass.Create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  MenuConfig : TStringList;
  i,j : integer;
  temp, temp2 : string;
  bez,pfad : string;
  left1,top1,width,height,style : integer;
  Active:Boolean;
  tempLabel : TLabel;
  Limit:TStringList;
  Item,Rest:string;
begin
    fShowMeldung := false;
    oldbIndex := -5;
    form1.Logger.Add('TMenuClass.create');

//    Form1.FadeSpeed := 255;
    Form1.goOut := true; //FadeOut
    Form1.goIn := false; //FadeIn

    fDXDraw := DXDraw;

    fDXList := TDXImageList.Create(DXDraw);
    fDXList.DXDraw := DXDraw;
    fDXList.Items := TPictureCollection.Create(dxdraw);

    fImageConfigList := TObjectList.create;
    fButtonConfigList := TObjectList.create;
    fLabelConfigList := TObjectList.Create;

  try
//    fBackgroundIndex := 0;
//    MenuConfig := TStringList.Create;
//    MenuConfig.LoadFromFile(GetConfigFile);
//
//    fImages := TDXImageList.Create(nil);
//    fimages.DXDraw := dxDraw;
//    fimages.Items := TPictureCollection.Create(dxdraw);
//    //fimages.Items.Add;
//    //fImages.Items.Items[0].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+MenuConfig[0]); //Hintergrundbild laden
//
//    fBackgrounds := TDXImageList.Create(nil);
//    fBackgrounds.DXDraw := dxDraw;
//    fBackgrounds.Items := TPictureCollection.Create(dxdraw);
//
//    fLabels := TObjectList.Create;
//
//    fConfigPosList := TObjectList.Create;

  MenuConfig := TStringList.Create;
  MenuConfig.LoadFromFile(GetConfigFile);

  Limit := TStringList.Create;
  Limit.Delimiter := ';';
  try
    for i := 0 to MenuConfig.Count - 1 do
    begin
      Item := '';
      if (pos(';',MenuConfig[i]) = 0) or (MenuConfig[i][1]='/') then continue;
      Item := copy(MenuConfig[i],1,Pos(';',MenuConfig[i])-1);
      Rest := copy(MenuConfig[i],Pos(';',MenuConfig[i])+1,Length(MenuConfig[i]));

      if Item = 'Image' then
      begin
        form1.Logger.Add('TMenuClass.create->NewImage ' + Limit.Text);

        Limit.DelimitedText := Rest;
        NewImage(Limit[0],Limit[3],strtoint(Limit[1]),strtoint(Limit[2]));
        Limit.Clear;
        form1.Logger.Add('TMenuClass.create->NewImage ' + Limit.Text + ' PASSED');

      end else if Item = 'Button' then
      begin
        form1.Logger.Add('TMenuClass.create->NewButton ' + Limit.Text);

        Limit.DelimitedText := Rest;
        NewButton(Limit[0],Limit[1],Limit[2],Limit[5],strtoint(Limit[3]),strtoint(Limit[4]));
        Limit.clear;

        form1.Logger.Add('TMenuClass.create->NewButton ' + Limit.text + ' PASSED');

      end else if Item = 'Background' then
      begin
        form1.Logger.Add('TMenuClass.create->NewBackground ' + Limit.text);

        Limit.DelimitedText := Rest;
        Limit.Delete(0);
        NewBackground(Limit);
        Limit.Clear;
        form1.Logger.Add('TMenuClass.create->NewBackground ' + Limit.Text + ' PASSED');

      end else if Item = 'Label' then
      begin
        form1.Logger.Add('TMenuClass.create->NewLabel ' + Limit.text);

        Limit.DelimitedText := Rest;
        Limit.Add(' ');
        for j := 4 to Limit.Count - 1 do
        begin
          Limit[3] := Limit[3] + ' ' + Limit[j];
        end;
        NewLabel(Limit[2],trim(Limit[3]),strtoint(Limit[0]),strtoint(Limit[1]));
        Limit.Clear;
        form1.Logger.Add('TMenuClass.create->NewLabel ' + Limit.text + ' PASSED');

      end else if Item = 'Animation' then
      begin
        //..
      end;
    end;
  finally
    freeandnil(Limit);
  end;


//    //----------------------------------------------------------
//    for i := 0 to MenuConfig.Count - 1 do
//    begin
//      temp := MenuConfig[i];
//      if AnsiContainsText(temp,';') then
//      begin
//
//        for j := 0 to 6 do
//        begin
//          if length(temp) = 1 then
//          begin
//            temp2 := temp;
//          end else
//          begin
//            temp2 := copy(temp,1,Pos(';',temp)-1);
//          end;
//          temp := copy(temp,Pos(';',temp)+1,length(temp)-Pos(';',temp)+1);
//
//          case j of
//            0 : pfad := temp2;
//            1 : begin
//                  bez := temp2;
//                  if bez = 'z' then break;
//                end;
//            2 : left1 := strtoint(temp2);
//            3 : begin
//                  top1 := strtoint(temp2);
//                  if pfad = 'label' then break;
//                end;
//            4 : width := strtoint(temp2);
//            5 : height := strtoint(temp2);
//            6 : style := strtoint(temp2);
//          end;
//        end;
//        if (bez <> 'z') and (pfad <> 'label') then
//        begin
//          case Style of
//            1:	Active := true;
//            2:	Active := false;
//            3:	Active := false;
//            4:	Active := true;
//            5:  Active := true;
//          end;
//
//          ConfigPosList.Add(TMenuConfig.create(Bez,left1,top1,width,height,Style,Active));
//          images.Items.Add;
//          Images.Items.Items[images.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+pfad);
//          images.Items.Items[images.Items.Count-1].TransparentColor := $FF00FF;
//          images.Items.Items[images.Items.Count-1].Transparent := true;
//
//          if Style = 4 then
//          begin
//            setLength(fAnims,length(fAnims)+1);
//            fAnims[High(fAnims)] := TImageSprite.Create(Engine.Engine);
//            fAnims[High(fAnims)].image := Images.Items.Items[images.Items.Count-1];
//            fAnims[High(fAnims)].AnimLooped := true;
//            fAnims[High(fAnims)].AnimSpeed := 0.5;
//            fAnims[High(fAnims)].height := height;
//            fAnims[High(fAnims)].X := left1;
//            fAnims[High(fAnims)].Y := top1;
//            fAnims[High(fAnims)].AnimCount := 4;
//            //fAnims[High(fAnims)].AnimStart := 0;
//            Images.Items.Items[images.Items.Count-1].PatternWidth := width;
//          end;
//        end else
//        begin
//          if bez = 'z' then
//          begin
//            backgrounds.Items.Add;
//            backgrounds.Items.Items[backgrounds.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(application.ExeName)+pfad); //Hintergrundbild laden
//          end;
//
//          if pfad = 'label' then
//          begin
//            Labels.Add(TLabel.Create(dxdraw));
//            with (Labels[Labels.count-1] as TLabel) do
//            begin
//              Parent := dxdraw;
//              Left := left1;
//              Top := top1;
//              Transparent := true;
//              Caption := bez;
//              autosize := true;
//              Font.Size := 20;
//              Font.Color := clWhite;
//              name := 'label'+inttostr(labels.Count-1);
//            end;
//          end;
//        end;
//      end else
//      begin
//        continue;
//      end;
//    end;
//    //-----------------------------------------------------


    if form1.faBackground <> nil then
    begin
      if (not (self is TNachKneipenkampfMenuClass)) and (not (self is TNachSaisonkampf1MenuClass)) and (not (self is TNachTurnierKampfMenuClass)) then
      begin
        form1.faBackground.DIB.Assign(self.fDXList.Items.Items[self.BackConfig.ListIndex].Picture);
        form1.faDXDIB1.DIB.SetSize(form1.faBackground.DIB.Width,form1.faBackground.DIB.Height,form1.faBackground.DIB.BitCount);
        form1.FillDIB8(form1.faDXDIB1.DIB,255);
        Form1.FadeSpeed := 8;
        form1.fac:=0;
      end;
    end;

  finally
    freeandnil(MenuConfig);
  end;
end;


end.
