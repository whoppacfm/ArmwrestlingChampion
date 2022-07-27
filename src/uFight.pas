unit uFight;

interface

uses
  DXDraws
  , Forms
  , jPeg
  , Types
  , DIB
  , Contnrs
  , classes
  , Math
  , ActnList
  , DXClass
  , Controls
  , windows
  , extctrls
  , Graphics
//  , FXGrafix
  , uCentralData
  , PlusLibrary
  , dialogs
  ;


type
  TPointArray = array of TPoint;

  TPunkt = class
    X : int64;
    Y : int64;
    constructor create(x_,y_:int64);
  end;

  TKampfBereich = class
  private
    fAbstandMin:int64;
    fAbstandMax:int64;
    fHitsToCount:int64; //Anzahl Berührungen für PositionChange
    fHitCount:int64; //Getätigte Berührungen
//    fValue:int64; //Rückgabewert
    fValue:Extended; //Rückgabewert
  public
    function CheckBereich(Abstand:int64):Extended; //Prüft, ob Abstand passt, wenn ja ob HitsToCount erreicht
    constructor create(AbstandMin_,AbstandMax_,HitsToMove_:int64;Value_:extended);
  end;

  TKampfBereiche = class
    fKampfBereiche : TObjectList;
    FAll : extended;
    function CheckBereiche(Abstand:int64):int64;//Geht alle Bereiche durch und gibt den ChangePositionValue zurück
    procedure LoadFromConfig;
    constructor create;
    destructor destroy;override;
  end;


  TKampf = class
  private
    fSMKoords : array[0..9] of TPoint;
    fSMNow : int64; //0..9
    fsurface:TDirectDrawSurface;

    fStopGravityFrames : int64; //Special Move StopGravity
    fStopGravityMFrames : int64; //Special Move StopGravityMove

    fStopMuedeFrames : int64;
    fDoubleMuedeFrames : int64;

    fGravityFramePoint : int64;

    fDecPlayers : int64; //Spielerwerte gehen jede Sekunde zurück

    FrameListe:TDXImageList;
    OtherPics:TDXImageList;
    fDXDraw:TDXDraw;
    fCursorPos:TPoint;
    Kampfbereiche : TKampfBereiche;

    fGegner:TSportler;

    fStartFight:boolean; //Reaktionstest?
    fReaktion_Y:int64; //Y-Position des Balkens
    fReaktion_Run:boolean; //Bewegt sich Balken?
    fReaktion_Step:int64; //Schritt um den Balken nach oben schießt
    fReaktion_Fertig:boolean; //Reaktionsabstand gemessen

    fFightIsRunning : boolean; //Nach Reaktionstest und Fight-Anzeige = true, auch in Pause!
    fFightBreak : boolean; //Kampfpause
    fBreakKoords : TPoint;

    fMaxKraftGegner : int64;
    fMaxKraftSpieler : int64;
    fKraftAusdauerGegner : int64;
    fKraftAusdauerSpieler : int64;
    fTechnikSpieler : int64;
    fTechnikGegner : int64;
    fLevelGegner : int64;
    flevelSpieler : int64;

    //Schwierigkeitsgrad:
    fTischChange : int64;
    fGravMultiply : int64;

    AnimCount : integer; //Fight Anim
    AnimCount2 : integer; //Get Ready


    function DecDoubleString(zahlstring:string):string;
    function IncDoubleString(zahlstring:string):string;

    function GetAbstandLine:TPointArray; // Pixelkoordinaten der Verbindungslinie CursorPos<->GravityPoint
    function GetAbstandToGravityPoint:int64; //Abstand vom Cursor zum Gravity-Point berechnen
    procedure SetNewArmPosition(Value:int64); //Verändert Armposition um Value (+/-)
    procedure DrawAll; // Blittet alles auf fDXDraw.surface
    procedure IncCir;

    procedure SetFistPosByGravity(Kraft:int64;Multiply:int64); //Verändert CursorPos nach der Gravitation


    //Kampfbeeinflussung
    function GetGravityPower(Abstand:int64):int64; // Gibt die Abstoßungskraft anhand des Abstands vom Cursor zum Gravity-Point zurück
    function GetGravityChange:int64;
    function GetMultiplyPower(Abstand:int64):int64;


    function GetReaktionsAbstand:int64;
  public
    fSMOver : boolean; //Special M-Button over?

    FAngle:int64;
    FCir:int64;
    fGravityPoint:TPoint;
    ShowFrame:int64;
    fWeiterleitung:string; //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"

    procedure MouseDown(Button:TMouseButton;x,y:int64);
    procedure DoFight; //Main-Fight-Loop für OnTimer
    constructor create(dxDraw:TDXDraw;Gegner:TSportler;Weiterleitung:string);
    destructor destroy;override;
  end;


implementation

uses
  SysUtils
  , main
  ;

const
  cFightVerz='images\Wrestle\';
  cFightConfig='config\AWEFightConf.awe';

{TPunkt.}
constructor TPunkt.create(x_,y_:int64);
begin
  x := x_;
  y := y_;
end;


{TKampfbereich}

constructor TKampfBereich.create(AbstandMin_,AbstandMax_,HitsToMove_:int64;Value_:extended);
begin
  fAbstandMin := AbstandMin_;
  fAbstandMax := AbstandMax_;
  fHitsToCount := HitsToMove_;
  fHitCount := 0;
  fValue := Value_;
end;

function TKampfbereich.CheckBereich(Abstand:int64):Extended; //Prüft, ob Abstand passt, wenn ja ob HitsToCount erreicht
begin
  Result := 0;
  if (Abstand >= fAbstandMin) and (Abstand <= fAbstandMax) then
  begin
    inc(fHitCount);
    if fHitCount >= fHitsToCount then
    begin
      fHitCount := 0;
      Result := fValue;
    end;
  end;
end;


{TKampfBereiche.}

function TKampfBereiche.CheckBereiche(Abstand:int64):int64;//Geht alle Bereiche durch und gibt den ChangePositionValue zurück
var
  i : integer;
  go:Extended;
begin
  result := 0;
  go := 0;
  for i := 0 to fKampfBereiche.Count - 1 do
  begin
    go := go + (fKampfBereiche[i] as TKampfBereich).CheckBereich(Abstand);
  end;
  fAll := fAll+Go;
  if (FAll > 1) or (FAll < -1) then
  begin
    result := round(fAll);
    fAll :=0;
  end;
end;

procedure TKampfBereiche.LoadFromConfig;
var
  Config:TStringList;
  i : integer;
  temp:string;
  Bereich : TKampfBereich;
  Limit:TStringList;
  AbstandMin,AbstandMax,HitsToMove:int64;
  Value:extended;
begin
  Config := TStringList.create;
  Limit := TStringList.create;
  Limit.Delimiter := ';';
  // Value ; HitsToMove ; MinAbstand ; MaxAbstand
  try
    //Config.loadfromfile(extractFilePath(application.ExeName)+cFightConfig);
    Config.loadfromfile(extractFilePath(Application.ExeName) + cFightConfig);
    for i := 0 to Config.Count-1 do
    begin
      if (Config[i] = '') or (Config[i] = ' ') or (Config[i][1] = '/') then continue;
      Limit.Clear;
      Limit.DelimitedText := Config[i];

      AbstandMin := strtoint(Limit[2]);
      AbstandMax := strtoint(Limit[3]);
      HitsToMove := strtoint(Limit[1]);
//      Value := strtoint(Limit[0]);
      Value := StrToFloat(Limit[0]);

      fKampfBereiche.Add(TKampfBereich.create(AbstandMin,AbstandMax,HitsToMove,Value));
    end;
  finally
    freeandnil(Config);
    freeandnil(Limit);
  end;
end;

constructor TKampfBereiche.create;
begin
  fKampfBereiche := TObjectList.Create;
  LoadFromConfig;
end;

destructor TKampfBereiche.destroy;
begin
  freeandnil(fKampfBereiche);
  inherited destroy;
end;


{TKampf}

function TKampf.GetReaktionsAbstand:int64;
var
  Abstand : int64;
begin
  //Panel_Y: 110..(295)..600, Best = 295
  //X: 100..800
  Abstand := Abs(fReaktion_Y - 230);

  Abstand := 100 + Abstand * 4;

  if Abstand > 700 then Abstand := 700;

  result := Abstand;
end;

procedure TKampf.SetNewArmPosition(Value:int64);
begin
  if not fFightBreak then
    if (ShowFrame < FrameListe.Items.count-2) and (ShowFrame > 4) then ShowFrame := ShowFrame - Value;
end;

procedure TKampf.MouseDown(Button:TMouseButton;x,y:int64);
var
  i : integer;
  mx,my : int64;
  cx,cy : int64;
  improve : int64;
begin
  if fFightIsRunning = false then
  begin
    //Reaktionstest
    if fReaktion_Run then
    begin
      fReaktion_Run := false;
      sleep(500);
      fStartFight := false;
      fReaktion_Fertig := true;
    end else
    begin
      //fReaktion_Run := true;
    end;
  end else
  begin
    if Button = mbRight then
    begin
      if fFightBreak = false then
      begin
        fBreakKoords := Mouse.CursorPos;
        fFightBreak := true;
      end else
      begin
        SetCursorPos(fBreakKoords.x, fBreakKoords.y);
        fFightBreak := false;
      end;
    end else if Button = mbLeft then
    begin
      if fFightBreak then
      begin
        //Koordinaten prüfen: Button, SMs
        mx := mouse.CursorPos.x;
        my := mouse.CursorPos.Y;
        for i := 0 to high(fSMKoords) do
        begin
          cx := fSMKoords[i].X;
          cy := fSMKoords[i].Y;
          if (mx >= cx) and (mx <= cx + 80) and (my >= cy) and (my <= cy + 80) then
          begin
            fSMNow := i;
            break;
          end;
        end;

        //Button
        if fSMOver then //Specialmove - Anwendung
        begin
          if (fTechnikSpieler >= (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).technikkosten) and ((cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).Erlernt=true) then
          begin
            fTechnikSpieler := fTechnikSpieler - (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).technikkosten;

            //Sound abspielen
            case fsmnow of
              0:begin //Schlafstellung
                  form1.PlaySchlafstellung;
                end;

              1:begin //Schwitzende Hand
                  form1.playschwitzendehand;
                end;

              2:begin //Kampfgebrüll
                  form1.playkampfgebruell;
                end;

              3:begin //Hölzerne Hand
                  form1.playhoelzernehand;
                end;

              4:begin //Eiserne Hand
                  form1.playeisernehand;
                end;

              5:begin //Brennende Hand
                  form1.playbrennendehand;
                end;

              6:begin //Rüttler
                  form1.playruettler;
                end;

              7:begin //Blitzangriff
                  form1.playblitzangriff;
                end;

              8:begin //Narkose
                  form1.playnarkose;
                end;

              9:begin //Todesgriff
                  form1.playtodesgriff;
                end;
            end;


            // GO ->
            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).SelfMaxStrProzent <> -1 then
            begin
              improve := round((fMaxKraftSpieler / 100) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).SelfMaxStrProzent);
              fMaxKraftSpieler := fMaxKraftSpieler + improve;
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).SelfStrAusdProzent <> -1 then
            begin
              improve := round((fKraftAusdauerSpieler / 100) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).SelfStrAusdProzent);
              fKraftAusdauerSpieler := fKraftAusdauerSpieler + improve;
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).GegnerMaxStrProzent <> - 1 then
            begin
              improve := round((fMaxkraftGegner / 100) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).GegnerMaxStrProzent);
              fMaxKraftGegner := fMaxKraftGegner + improve;
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).GegnerStrAusdProzent <> - 1 then
            begin
              improve := round((fKraftAusdauerGegner / 100) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).GegnerStrAusdProzent);
              fKraftAusdauerGegner := fKraftAusdauerGegner + improve;
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).ChangePosition <> -1 then
            begin
              ShowFrame := ShowFrame - (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).ChangePosition;
              if ShowFrame > FrameListe.Items.count-2 then showframe := FrameListe.Items.count-2;
              if ShowFrame < 3 then showframe := 3;
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).StopGravity_MS <> -1 then
            begin
              fStopGravityFrames := round((30/1000) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).StopGravity_MS);
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).StopGravityMove_MS <> -1 then
            begin
              fStopGravityMFrames := round((30/1000) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).StopGravityMove_MS);
            end;

            if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).Reaktionszeit <> -1 then
            begin
              if (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).Reaktionszeit < 0 then
              begin
                fDoubleMuedeFrames := round((30/1000) * Abs((cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).Reaktionszeit));
              end else
              begin
                fStopMuedeFrames := round((30/1000) * (cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).Reaktionszeit);
              end;
            end;

            if fTechnikSpieler < 0 then fTechnikSpieler := 0;
            if fTechnikGegner < 0 then fTechnikGegner := 0;
            if fMaxKraftGegner < 0 then fMaxKraftGegner := 0;
            if fMaxKraftSpieler < 0 then fMaxKraftSpieler := 0;
            if fKraftAusdauerGegner < 0 then fKraftAusdauerGegner := 0;
            if fKraftAusdauerSpieler < 0 then fKraftAusdauerSpieler := 0;
          end else
          begin
            form1.PlayNo;
            //zu wenig Technik !!!
            //nicht gelernt !!!
          end;
        end;
      end;
    end;
  end;
end;

function TKampf.DecDoubleString(zahlstring:string):string;
var
  temp : int64;
begin
  temp := strtoint(zahlstring);
  dec(temp);
  if temp < 10 then
    result := '0'+inttostr(temp)
  else
    result := inttostr(temp);
end;

function TKampf.IncDoubleString(zahlstring:string):string;
var
  temp : int64;
begin
  temp := strtoint(zahlstring);
  inc(temp);
  if temp < 10 then
    result := '0'+inttostr(temp)
  else
    result := inttostr(temp);
end;

constructor TKampf.create(dxDraw:TDXDraw;Gegner:TSportler;Weiterleitung:string);
var
  Pfad : string;
  i,j : integer;
  Nummer : string;
  jpegI : TJPEGImage;
begin
  try
    form1.Logger.Add('TKampf.create');

    AnimCount := 1;
    AnimCount := 2;

    fWeiterleitung := Weiterleitung; //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"


    //Schwierigkeitsgrad einstellen
    {
                 fTischChange     fGravMultiply
     - bis 4 :       15-20             1-2
     5 - 30  :       20-25             3-4
     31 - 190:       25-35             3-5
     191 - 650:      40-50             6-10
    }


  //  fTischChange := 15; //Max 20-50
  //  fGravMultiply := 1;  //Max: 1-10

    fDecPlayers := 30;

    fSMNow := 0;
    fFightBreak := false;
    fFightIsRunning := false;


    fStopGravityFrames := 0;
    fStopMuedeFrames := 0;
    fStopMuedeFrames := 0;
    fDoubleMuedeFrames := 0;

    fSMOver := false;
    //Special Move - Koordinaten
  //  fsurface := TDirectDrawSurface.Create(dxDraw.DDraw);
  //  j := 0;
  //  for i := 0 to 9 do
  //  begin
  //    fSMKoords[i].X := 50 + j*100;
  //    if i < 5 then
  //      fSMKoords[i].Y := 400
  //    else
  //      fSMKoords[i].Y := 500;
  //    inc(j);
  //    if i = 4 then j := 0;
  //  end;
    fsurface := TDirectDrawSurface.Create(dxDraw.DDraw);
    fSurface.TransparentColor := $FF00FF;
    j := 0;
    for i := 0 to 9 do
    begin
      fSMKoords[i].Y := 110+j*80;
      if i < 5 then
        fSMKoords[i].X := 50
      else
        fSMKoords[i].X := 130;
      inc(j);
      if i = 4 then j := 0;
    end;


    fGegner := Gegner;

    fMaxKraftGegner := Gegner.Maximalkraft;
    fMaxKraftSpieler := cdSpieler.GetMaximalkraft;
    fKraftAusdauerGegner := Gegner.Kraftausdauer;
    fKraftAusdauerSpieler := cdSpieler.GetKraftausdauer;
    fTechnikSpieler := cdSpieler.GetTechnik;
    fTechnikGegner := Gegner.Technik;
    fLevelGegner := Gegner.Level;
    fLevelSpieler := cdspieler.Level;


  //  fGravityPoint.x := dxDraw.width div 2;
  //  fGravityPoint.y := dxdraw.height div 2;

    fStartFight := true;
    fReaktion_Y := 615;
    fReaktion_Run := false;
    fReaktion_Step := 1;
    fReaktion_Fertig := false;

    fDXDraw := dxDraw;
    FAngle := 1;

    //fxx := TFXGrafix.Create(fdxDraw);

  //  fGravityPoint.x := fdxdraw.Width div 2;
  //  fGravityPoint.y := fdxdraw.Height div 2;
    fGravityPoint.x := fdxdraw.Display.Width div 2;
    fGravityPoint.y := fdxdraw.Display.Height div 2;

    FCir := 1;

    FrameListe := TDXImageList.Create(fDXDraw);
    FrameListe.DXDraw := fDXDraw;
    OtherPics := TDXImageList.Create(fDXDraw);
    OtherPics.DXDraw := fDXDraw;

    form1.Logger.Add('TKampf.create OtherPics.load-Cursor');

    //Cursor
    OtherPics.Items.Add;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'Fight_Cursor2.bmp');
    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
    OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;

    form1.Logger.Add('TKampf.create OtherPics.load-Cursor PASSED');

  //  for i := 1 to 20 do
  //  begin
  //    OtherPics.Items.Add;
  //    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+'cir'+inttostr(i)+'.bmp');
  //    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
  //  //  OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
  //    OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $0;
  //  end;

      form1.Logger.Add('TKampf.create OtherPics.load-BIG');

      //Big = Index 1
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'Big3.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Big';

      form1.Logger.Add('TKampf.create OtherPics.load-BIG PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load-SmallRed');

      //Small-Red Index 2
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'Small_Rot.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Small_Rot';

      form1.Logger.Add('TKampf.create OtherPics.load-SmallRed PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load-SmallBLUE');

      //Small-Blue Index 3
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'Small_Blau.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $0;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Small_Blau';

      form1.Logger.Add('TKampf.create OtherPics.load-SmallBLUE PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load-Reaktion');

      //Reaktionstest: Bild  4
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'reaktion.jpg');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
      //OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Reaktion';
      form1.Logger.Add('TKampf.create OtherPics.load-Reaktion PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load-Reaktion_c');
      //Reaktionstest: Cursor   5
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'reaktion_c.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $0;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Reaktion_C';
      form1.Logger.Add('TKampf.create OtherPics.load-Reaktion_c PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load-Fight.bmp');
      //Reaktionstest: RFight   6
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'Fight.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'RFight';
      form1.Logger.Add('TKampf.create OtherPics.load-Fight.bmp PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load-back.jpg');
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'back.jpg');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
  //    OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'backg';
      form1.Logger.Add('TKampf.create OtherPics.load-back.jpg PASSED');

      //Button laden
      form1.Logger.Add('TKampf.create OtherPics.load - sm1.jpg');
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'sm1.jpg');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'sm1';
      form1.Logger.Add('TKampf.create OtherPics.load-sm1.jpg PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load - sm2.jpg');
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'sm2.jpg');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'sm2';
      form1.Logger.Add('TKampf.create OtherPics.load-sm2.jpg PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load - bCursor.bmp');
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'bCursor.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := clwhite;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'bCursor';
      form1.Logger.Add('TKampf.create OtherPics.load-bCursor.bmp PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load - sm_markierung.bmp');
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'sm_markierung.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'smMarkierung';
      form1.Logger.Add('TKampf.create OtherPics.load-sm_markierung.bmp PASSED');

      form1.Logger.Add('TKampf.create OtherPics.load - getready.bmp');
      OtherPics.Items.Add;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(ExtractFilePath(Application.exename)+cFightVerz+'getready.bmp');
      OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
      OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
      OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'getready';
      form1.Logger.Add('TKampf.create OtherPics.load-getready.bmp PASSED');


    Pfad := ExtractFilePath(Application.exename) + cFightVerz;

    jPegI := TJPEGImage.Create;
  //  FrameListe.Items.Add;
  //  jPegI.LoadFromFile(Pfad+'Kreise.jpg');
  //  FrameListe.Items.Items[FrameListe.Items.Count-1].Picture.Assign(jPegi);
  //  FrameListe.Items.Items[FrameListe.Items.Count-1].Transparent := true;
  //  FrameListe.Items.Items[FrameListe.Items.Count-1].TransparentColor := $FF00FF;

    try
      //Links
      Nummer := '30';
      for i := 30 downto 0 do
      begin
        form1.Logger.Add('TKampf.create Frameliste.add ' + 'links00' + nummer);

        FrameListe.Items.Add;
        jPegI.LoadFromFile(Pfad+'links00'+Nummer+'.jpg');
        FrameListe.Items.Items[FrameListe.Items.Count-1].Transparent := false;
        FrameListe.Items.Items[FrameListe.Items.Count-1].Picture.Assign(jPegi);

        form1.Logger.Add('TKampf.create Frameliste.add ' + 'links00' + nummer + ' PASSED');


        //FrameListe.Items.Items[FrameListe.Items.Count-1].Picture.LoadFromFile(Pfad+'links00'+Nummer+'.jpg');
        Nummer := DecDoubleString(Nummer);
      end;

      //Rechts
      Nummer := '00';
      for i := 0 to 30 do
      begin
        form1.Logger.Add('TKampf.create Frameliste.add ' + 'rechts00' + nummer);

        FrameListe.Items.Add;
        jPegI.LoadFromFile(Pfad+'rechts00'+Nummer+'.jpg');
        FrameListe.Items.Items[FrameListe.Items.Count-1].Transparent := false;
        FrameListe.Items.Items[FrameListe.Items.Count-1].Picture.Assign(jPegi);
  //      FrameListe.Items.Items[FrameListe.Items.Count-1].Picture.LoadFromFile(Pfad+'rechts00'+Nummer+'.jgp');
        Nummer := IncDoubleString(Nummer);

        form1.Logger.Add('TKampf.create Frameliste.add ' + 'rechts00' + nummer + ' PASSED');

      end;

      ShowFrame := FrameListe.items.count div 2 + 1;
      KampfBereiche := TKampfBereiche.create;
    finally
      freeandnil(jPegI);
    end;

    form1.PlayMusicFight;

  except
    on e:exception do
    begin
      showmessage('ERROR: TKampf.create: '+e.message);
    end;
  end;
end;

destructor TKampf.destroy;
begin
  freeandnil(fSurface);
  freeandnil(FrameListe);
  freeandnil(OtherPics);
//  freeandnil(fxx);
  form1.PlayMusic1;
  inherited destroy;
end;

procedure TKampf.DrawAll;
var
  Rechteck:TRect;
  Abstand:int64;
  fx : int64;
  fy : int64;
  fKraft : int64;
  dd : TDXDIB;
  dd2 : TDXDib;
  pp : HPen;
  i : integer;
  Arr : TPointArray;
  ix,iy : int64;
  w : integer;
begin
  //fdxdraw.Surface.Fill($0);
  OtherPics.Items.Find('backg').Draw(fdxDraw.Surface,0,0,0);

  //Special Moves malen
  for i := 0 to high(fSMKoords) do
  begin
    if (cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Erlernt then
    begin
      fsurface.LoadFromDIB((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Icon.DIB);
      //fsurface.Assign((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Icon.DIB);
    end else
    begin
      fsurface.Assign((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).IconGrau.DIB);
    end;
    fDXDraw.Surface.Draw(fSMKoords[i].X, fSMKoords[i].Y, fsurface,false);
  end;
  OtherPics.Items.Find('smMarkierung').Draw(fdxDraw.Surface,fSMKoords[fSMNow].X-4,fSMKoords[fsmnow].Y-4,0);

  //SM-Button
  fSMOver := false;
  if fFightBreak then
  begin
    if (Mouse.CursorPos.X > 55) and (Mouse.CursorPos.x < 55+Otherpics.items.Find('sm1').Width) and (Mouse.CursorPos.Y > 515) and (Mouse.CursorPos.Y < 515 + Otherpics.items.Find('sm1').height) then
    begin
      fSMOver := true;
    end;
  end;
  form1.DXPowerFont1.Font := 'FontN';
  case fSMOver of
    true: OtherPics.Items.Find('sm2').Draw(fdxdraw.Surface, 55, 515, 0);
    false: OtherPics.Items.Find('sm1').Draw(fdxdraw.Surface, 55, 515, 0);
  end;
  form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, 79, 526,  'anwenden');

  //Kampf-Animation blitten
  Rechteck.Left := 0;
  Rechteck.Top := 0;
  Rechteck.Right := fDXDraw.Width;
  Rechteck.Bottom := fDXDraw.Height;
  FrameListe.Items.items[ShowFrame].Draw(fdxdraw.Surface,269,129,0);
  //FrameListe.Items.items[ShowFrame].StretchDraw(fdxdraw.Surface,Rechteck,0);
  //FrameListe.Items.items[ShowFrame].DrawAlpha(fdxdraw1.Surface,Rechteck,0,220);

  if fStartFight then
  begin
    OtherPics.Items.Find('Reaktion').Draw(fdxDraw.Surface,250,0,0);
    OtherPics.Items.Find('Reaktion_c').Draw(fdxDraw.Surface,370,fReaktion_Y,0);

    if not fReaktion_run then
    begin
//      Rechteck.Left := 200;
//      Rechteck.Top := 200;
//      Rechteck.Right := 600;
//      Rechteck.Bottom := 400;

      Rechteck.Left := 230+AnimCount2*10;
      Rechteck.Top := 200+AnimCount2*10;
      Rechteck.Right := 560-AnimCount2*10;
      Rechteck.Bottom := 300-AnimCount2*10;

//      OtherPics.Items.Find('getready').DrawAdd(fdxDraw.Surface,Rechteck,0,255);
//      OtherPics.Items.Find('getready').Draw(fdxDraw.Surface,Rechteck.Left,Rechteck.top,0);
      OtherPics.Items.Find('getready').DrawAlpha(fdxDraw.Surface, Rechteck, 0, 255);
      if animcount2 = 0 then form1.PlayGetReady;

//      OtherPics.Items.Find('getready').Draw(fdxDraw.Surface,200,200,0);

      if animcount2 = 1 then sleep(800);

      if animcount2 = 20 then
      begin
        fDXDraw.Update;
        fDXDraw.Flip;
//        sleep(1500);
        fReaktion_Run := true;
      end else
      begin
        inc(Animcount2);
      end;
    end;

   // fReaktion_Run := true;
  end else
  begin
    //FightCursor anzeigen
    //OtherPics.Items.items[0].Draw(fdxdraw1.Surface,Mouse.CursorPos.X, Mouse.CursorPos.Y,0);
    if fFightBreak then
    begin
      Rechteck.Left := fBreakKoords.X;
      Rechteck.Top := fBreakKoords.Y;
      Rechteck.Right := fBreakKoords.X+OtherPics.Items.items[0].Width;
      Rechteck.Bottom := fBreakKoords.Y+OtherPics.Items.items[0].Height;
    end else
    begin
      Rechteck.Left := Mouse.CursorPos.X;
      Rechteck.Top := Mouse.CursorPos.Y;
      Rechteck.Right := Mouse.CursorPos.X+OtherPics.Items.items[0].Width;
      Rechteck.Bottom := Mouse.CursorPos.Y+OtherPics.Items.items[0].Height;
    end;
    //FightCursor
    OtherPics.Items.items[0].DrawAdd(fdxdraw.Surface,Rechteck,0,150);

  //  OtherPics.Items.items[1].Draw(fdxdraw.Surface,(fdxdraw.Display.Width div 2)-100,(fdxdraw.Display.height div 2)-100,0);

    //Kreise anzeigen
    Arr := GetAbstandLine;
    for i := 0 to High(Arr) do
    begin
      Rechteck.Left := Arr[i].X-8;
      Rechteck.Top := Arr[i].Y-8;
      Rechteck.Right := Arr[i].X-8+OtherPics.Items.items[2].Width;
      Rechteck.Bottom := Arr[i].Y-8+OtherPics.Items.items[2].Height;
      OtherPics.Items.items[2].DrawAlpha(fdxdraw.Surface,rechteck,0,120);
  //    OtherPics.Items.items[2].Draw(fdxdraw.Surface,rechteck.Left,rechteck.Top,0);
    end;

   //Gravity Point
  //  Rechteck.Left := (fdxdraw.Display.Width div 2)-100;
  //  Rechteck.Top := (fdxdraw.Display.Height div 2)-100;
  //  Rechteck.Right := (fdxdraw.Display.Width div 2)+100;
  //  Rechteck.Bottom := (fdxdraw.Display.Height div 2)+100;
    Rechteck.Left := fGravityPoint.X - OtherPics.Items.items[1].Width div 2;
    Rechteck.Top := fGravityPoint.y - OtherPics.Items.items[1].Height div 2;
    Rechteck.Right := Rechteck.Left + OtherPics.Items.items[1].Width;
    Rechteck.Bottom := Rechteck.top + OtherPics.Items.items[1].Height;
    //OtherPics.Items.items[1].Draw(fdxdraw.Surface,(fdxdraw.Display.Width div 2)-100,(fdxdraw.Display.Height div 2)-100,0);
    //Tisch
    OtherPics.Items.items[1].DrawAdd(fdxdraw.Surface,rechteck,0,120);
  //  OtherPics.Items.items[1].Draw(fdxdraw.Surface,rechteck.left,rechteck.top,0);


    //keine negativen Beträge anzeigen
    if fMaxKraftSpieler < 0 then fMaxKraftSpieler := 0;
    if fMaxkraftGegner < 0 then fMaxKraftGegner := 0;
    if fKraftAusdauerSpieler < 0 then fKraftAusdauerSpieler := 0;
    if fKraftAusdauerGegner < 0 then fKraftAusdauerGegner := 0;



    //Infos
    form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,250,15, CenterString('Maximalkraft',15) + CenterString('Kraftausdauer',15) + CenterString('Technik',12));

    if fSMOver then
    begin
      form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,50,40, CenterString(cdSpieler.Vorname + ' ' + cdSpieler.Name,20) + CenterString(inttostr(fMaxKraftSpieler),15) +  CenterString(inttostr(fKraftAusdauerSpieler ),15) + CenterString(inttostr(fTechnikSpieler-(cdSpecialMoves.fSpecialMoves[fsmnow] as TSpecialMove).technikkosten) ,11));
    end else
    begin
      form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,50,40, CenterString(cdSpieler.Vorname + ' ' + cdSpieler.Name,20) + CenterString(inttostr(fMaxKraftSpieler),15) +  CenterString(inttostr(fKraftAusdauerSpieler ),15) + CenterString(inttostr(fTechnikSpieler),11));
    end;
    form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,50,70, CenterString(fGegner.Vorname + ' ' + fGegner.Name,20) + CenterString(inttostr(fMaxKraftGegner),15) +  CenterString(inttostr(fKraftAusdauerGegner),15) + CenterString(inttostr(fTechnikGegner),11));

    //SM-Infos
    form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, 230, 455,  (cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).Bezeichnung);
    form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, 230, 485,  'Stufe: ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).Level));
    form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, 230, 515,  'Technikkosten: ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).TechnikKosten));

    ix := 460;
    iy := 460;
    case fSMNow of
      0:begin //Schlafstellung
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Kraftausdauer +' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).SelfStrAusdProzent) + '%');
        end;

      1:begin //Schwitzende Hand
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Gegner Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).GegnerStrAusdProzent) + '%');
        end;

      2:begin //Kampfgebrüll
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).SelfMaxStrProzent) + '%');
        end;

      3:begin //Hölzerne Hand
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Gegner Maximalkraft ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).GegnerMaxStrProzent) + '%');
        end;

      4:begin //Eiserne Hand
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Ermüdung einfrieren ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).Reaktionszeit) + ' ms');
        end;

      5:begin //Brennende Hand
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix-40, iy,  'Gegner Ermüdung verdreifachen ');
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix-40, iy+20,  'für ' + inttostr(Abs((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).Reaktionszeit)) + ' ms');
        end;

      6:begin //Rüttler
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix-20, iy,  'Gegner Balanceverlust ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).StopGravityMove_MS) + ' ms');
        end;

      7:begin //Blitzangriff
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).SelfStrAusdProzent) + '%');
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy+20,  'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).SelfMaxStrProzent) + '%');
        end;

      8:begin //Narkose
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Gegner wehrlos ' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).StopGravity_MS) + ' ms');
        end;

      9:begin //Todesgriff
          form1.DXPowerFont1.TextOutFast(fDXDraw.Surface, ix, iy,  'Kampfposition +' + inttostr((cdSpecialMoves.fSpecialMoves[fSMNow] as TSpecialMove).ChangePosition));
        end;
    end;

    //Break-Cursor anzeigen
    if fFightBreak then
    begin
      OtherPics.Items.Find('BCursor').Draw(fdxdraw.Surface,Mouse.CursorPos.x,Mouse.CursorPos.y,0);
    end;

    if (fReaktion_Fertig) and (fFightIsRunning = false) then
    begin
      //Schrift: Go
      Rechteck.Left := 240+AnimCount*10;
      Rechteck.Top := 120+AnimCount*10;
      Rechteck.Right := 600-AnimCount*10;
      Rechteck.Bottom := 350-AnimCount*10;
      //OtherPics.Items.Find('RFight').DrawAdd(fdxdraw.Surface,rechteck,0,255);
//      OtherPics.Items.Find('RFight').Draw(fdxdraw.surface, rechteck.Left,rechteck.top,0);

      //OtherPics.Items.Find('RFight').Draw(fdxdraw.surface, 269, 129, 0);

//      fDXDraw.Flip;
//      sleep(1000);


//  TEST------------>
//      fdxdraw.Surface.Fill(0);

//      Rechteck.Left := 100;
//      Rechteck.Top := 100;
//      Rechteck.Right := 700;
//      Rechteck.Bottom := 500;

      OtherPics.Items.Find('RFight').DrawAlpha(fdxdraw.surface, Rechteck, 0, 255);

//      fDXDraw.Flip;

//     sleep(1000);
// <--------------TEST

      if animcount = 3 then sleep(800);
      if animcount = 2 then form1.PlayFight;

      if AnimCount = 20 then
      begin
//        sleep(200);
        SetCursorPos(50,380);
        fReaktion_Fertig := false;
        fFightIsRunning := true;
      end else
      begin
        inc(AnimCount);
      end;
    end;
  end;
end;

function TKampf.GetAbstandToGravityPoint:int64;
begin
  if fFightBreak then
  begin
    result := round(sqrt( Power((fGravityPoint.x - fBreakKoords.X),2) + Power((fGravityPoint.y - fBreakKoords.Y),2)));
  end else
  begin
    result := round(sqrt( Power((fGravityPoint.x - Mouse.CursorPos.X),2) + Power((fGravityPoint.y - Mouse.CursorPos.Y),2)));
  end;
end;

function TKampf.GetAbstandLine:TPointArray;
var
  x,y,i:integer;
  P:TPoint;
  Q:TPoint;
  error, delta, schwelle, dx, dy, inc_x, inc_y:int64; //Bresenham
  Anzahl : int64;
  Teilung : int64;
  bb : TPointArray;
  j:integer;
  Liste : TObjectList;
begin
//  setLength(result,GetAbstandToGravityPoint);
//  x := Mouse.CursorPos.X;
//  y := Mouse.CursorPos.y;
//  if x < fGravityPoint.X then x := x + OtherPics.Items.Items[0].Width+50 else x := x - OtherPics.Items.Items[0].Width-50;
//  if y < fGravityPoint.y then x := y + OtherPics.Items.Items[0].Height+50 else y := y - OtherPics.Items.Items[0].Height-50;
//
//  for i := 0 to High(Result) do
//  begin
//    if x > fGravityPoint.X then dec(x) else inc(x);
//    if y > fGravityPoint.y then dec(y) else inc(y);
//    result[i].X := X;
//    result[i].Y := Y;
//  end;

  Liste := TObjectList.Create;
  try

    P := fGravityPoint;
    if fFightBreak then
    begin
      Q := fBreakKoords;
    end else
    begin
      Q := Mouse.CursorPos;
    end;

    dx := q.X - fGravityPoint.X;
    dy := q.Y - fGravityPoint.Y;

    if dx>0 then inc_x := 1 else inc_x := -1;
    if dy>0 then inc_y := 1 else inc_y := -1;

    if abs(dy) < abs(dx) then
    begin
      error := -abs(dx);
      delta := 2*abs(dy);
      schwelle := 2*error;
      while P.x <> Q.x do
      begin
        //SetPixel P
        //SetLength(bb, Length(bb)+1);
        //bb[High(bb)] := P;
        Liste.Add(TPunkt.create(P.x,P.y));

        p.x := p.x +  inc_x;
        error := error + delta;
        if error > 0 then
        begin
          p.y := p.y + inc_y;
          error := error + schwelle;
        end;
      end;
    end else
    begin
      error := -abs(dy);
      delta := 2*abs(dx);
      schwelle := 2*error;
      while p.y <> q.y do
      begin
//        SetLength(bb, Length(bb)+1);
//        bb[High(bb)] := P;
        Liste.Add(TPunkt.create(P.x,P.y));

        p.y := p.y + inc_y;
        error := error + delta;
        if error > 0 then
        begin
          p.x := p.X + inc_x;
          error := error + schwelle;
        end;
      end;
    end;
//    SetLength(BB, Length(bb)+1);
//    bb[High(bb)] := Q;
    Liste.Add(TPunkt.create(Q.x,Q.y));

    if Liste.Count > 51 then
    begin
      for i := 0 to 50 do
      begin
        Liste.Delete(0);
      end;
    end;

    Anzahl := GetAbstandToGravityPoint div (OtherPics.Items.items[2].Width + 12);
    if Anzahl = 0 then Anzahl := 1;
    SetLength(result,Anzahl);
    Teilung := Liste.count div Anzahl;
    i := 0;
    j := 0;

    while j < Anzahl do
    begin
      result[j].x := (Liste[i] as TPunkt).x;
      result[j].y := (Liste[i] as TPunkt).y;
      inc(j);
      inc(i,Teilung);
    end;
  finally
    freeandnil(Liste);
  end;
end;

function TKampf.GetGravityChange:int64;
begin
  randomize;
  result := randomrange(-fTischChange,fTischChange);
end;

function TKampf.GetMultiplyPower(Abstand:int64):int64;
begin
  // ToDo Beeinflussung von Differenz: fMaxKraftGegner-fMaxKraftSpieler
  result := fGravMultiply;
end;

function TKampf.GetGravityPower(Abstand:int64):int64;
begin
  // ToDo Beeinflussung von Differenz: fMaxKraftGegner-fMaxKraftSpieler

  //Deadline = 350
  result := 1;
  // Fordernd !!!
  case Abstand of
    0..10: result := 18;
    11..20: result := 18;
    21..30: result := 17;
    31..40:result := 17;
    41..50:result := 16;
    51..60:result := 16;
    61..70:result := 15;
    71..80:result := 15;
    81..90:result := 14;
    91..100:result := 14;
    101..110:result := 13;
    111..120:result := 13;
    121..130:result := 12;
    131..140:result := 12;
    141..150:result := 11;
    151..160:result := 11;
    161..170:result := 10;
    171..180:result := 10;
    181..190:result := 9;
    191..200:result := 9;
    201..210:result := 8;
    211..220:result := 8;
    221..230:result := 7;
    231..240:result := 6;
    241..250:result := 5;
  end;

//  case Abstand of
//    0..25: result := 25;
//    26..50: result := 22;
//    51..75: result := 21;
//    76..100:result := 19;
//    101..125:result := 15;
//    126..150:result := 12;
//    151..175:result := 9;
//    176..200:result := 5;
//    201..225:result := 3;
//    226..250:result := 1;
//  end;

end;

procedure TKampf.SetFistPosByGravity(Kraft:int64;Multiply:int64);
var
  fx,fy:int64;
begin
    //-x-y
    if (Mouse.CursorPos.x - fGravityPoint.x <= 0) and (Mouse.CursorPos.Y - fGravityPoint.y <= 0) then
    begin
      fx := Mouse.CursorPos.x - Kraft;
      fy := Mouse.CursorPos.y - Kraft;
  //    SetCursorPos(fx,fy);

  //    SetCursorPos(fx+randomrange(-10,0),fy+randomrange(-10,0));
    end;

    //+x-y
    if (Mouse.CursorPos.x - fGravityPoint.x >= 0) and (Mouse.CursorPos.Y - fGravityPoint.y <= 0) then
    begin
      fx := Mouse.CursorPos.x +Kraft;
      fy := Mouse.CursorPos.y -Kraft;
  //    SetCursorPos(fx,fy);
  //    SetCursorPos(fx+randomrange(0,10),fy+randomrange(-10,0));
    end;

    //-x+y
    if (Mouse.CursorPos.x - fGravityPoint.x <= 0) and (Mouse.CursorPos.Y - fGravityPoint.y >= 0) then
    begin
      fx := Mouse.CursorPos.x -Kraft;
      fy := Mouse.CursorPos.y +Kraft;
  //    SetCursorPos(fx,fy);
  //    SetCursorPos(fx+randomrange(-10,0),fy+randomrange(0,10));
    end;

    //+x+y
    if (Mouse.CursorPos.x - fGravityPoint.x >= 0) and (Mouse.CursorPos.Y - fGravityPoint.y >= 0) then
    begin
      fx := Mouse.CursorPos.x +Kraft;
      fy := Mouse.CursorPos.y +Kraft;
  //    SetCursorPos(fx,fy);
  //    SetCursorPos(fx+randomrange(0,10),fy+randomrange(0,10));
    end;

    fx := Mouse.CursorPos.x + randomrange(-Multiply*Kraft,Multiply*Kraft);
    //Zufallsfaktor einfliessen lassen

    if not fFightBreak then
      SetCursorPos(fx+randomrange(-5,5),fy+randomrange(-5,5));
end;

procedure TKampf.DoFight;
var
  Kraft : int64;
  Abstand : int64;
  Multiply : int64;
  GravityChange:int64;
  Differenz : int64;
begin
  if fFightBreak = false then
  begin
    if fStartFight then
    begin
      if fReaktion_Run then
      begin
        dec(fReaktion_Y,fReaktion_Step);
        inc(fReaktion_Step,2);
        if fReaktion_Y < 0 then
        begin
          fReaktion_Run := false;
          sleep(500);
          fStartFight := false;
          fReaktion_Fertig := true;
          DoFight;
        end;
      end;
    end else
    begin
        //Schwierigkeitsgrad einstellen
        {
                     fTischChange     fGravMultiply
         - bis 4 :       15-20             1-2
         5 - 30  :       20-25             3-4
         31 - 190:       25-35             3-5
         191 - 650:      40-50             6-10
        }

        Differenz := fMaxKraftGegner - fMaxKraftSpieler;
        if differenz >= -99999 then
        begin
          case Differenz of
            //Alle Ligen
            -99999..-10: begin
                        fTischChange := 20; //Max 20-50
                        fGravMultiply := 3;  //Max: 1-10
                      end;
            -9..0: begin
                        fTischChange := 23; //Max 20-50
                        fGravMultiply := 3;  //Max: 1-10
                      end;
            1..2: begin
                        fTischChange := 26; //Max 20-50
                        fGravMultiply := 3;  //Max: 1-10
                      end;
            3..4: begin
                        fTischChange := 30; //Max 20-50
                        fGravMultiply := 3;  //Max: 1-10
                      end;

            //Liga 3
            5..10: begin
                        fTischChange := 34; //Max 20-50
                        fGravMultiply := 3;  //Max: 1-10
                      end;
            11..20: begin
                        fTischChange := 38; //Max 20-50
                        fGravMultiply := 4;  //Max: 1-10
                      end;
            21..30: begin
                        fTischChange := 42; //Max 20-50
                        fGravMultiply := 4;  //Max: 1-10
                      end;

            //Liga 2
            31..50: begin
                        fTischChange := 45; //Max 20-50
                        fGravMultiply := 4;  //Max: 1-10
                      end;
            51..70: begin
                        fTischChange := 46; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;
            71..90: begin
                        fTischChange := 47; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;
            91..110: begin
                        fTischChange := 48; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;
            111..130: begin
                        fTischChange := 49; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;
            131..150: begin
                        fTischChange := 50; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;
            151..170: begin
                        fTischChange := 51; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;
            171..190: begin
                        fTischChange := 52; //Max 20-50
                        fGravMultiply := 5;  //Max: 1-10
                      end;


            //Liga 1
            191..220: begin
                        fTischChange := 55; //Max 20-50
                        fGravMultiply := 6;  //Max: 1-10
                      end;
            221..300: begin
                        fTischChange := 57; //Max 20-50
                        fGravMultiply := 7;  //Max: 1-10
                      end;
            301..380: begin
                        fTischChange := 60; //Max 20-50
                        fGravMultiply := 8;  //Max: 1-10
                      end;
            381..450: begin
                        fTischChange := 70; //Max 20-50
                        fGravMultiply := 8;  //Max: 1-10
                      end;
            451..99999: begin
                        fTischChange := 80; //Max 20-50
                        fGravMultiply := 9;  //Max: 1-10
                      end;

          end;
      end else
      begin
        fTischChange := 16; //Max 20-50
        fGravMultiply := 3;  //Max: 1-10
      end;


      //Test
      //fTischChange := 25; //Max 20-50
      //fGravMultiply := 4;  //Max: 1-10


      randomize;

      //Tisch muss sich länger in eine Richtung bewegen
//      if fGravityFramePoint = 0 then
//      begin
        GravityChange := GetGravityChange;
//        fGravityFramePoint := 10;
//      end;
//      dec(fGravityFramePoint);


      //Tisch bewegen
      if fStopGravityMFrames < 1 then
      begin
        fGravityPoint.X := fGravityPoint.x + GravityChange;
        fGravityPoint.y := fGravityPoint.y + GravityChange;

        while fGravityPoint.x > 824 do
        begin
          fGravityPoint.x := fGravityPoint.x - 50;
        end;

        while fGravityPoint.y > 568 do
        begin
          fGravityPoint.y := fGravityPoint.y - 50;
        end;

        while fGravityPoint.x < 200 do
        begin
          fGravityPoint.x := fGravityPoint.x + 50;
        end;

        while fGravityPoint.y < 200 do
        begin
          fGravityPoint.y := fGravityPoint.y + 50;
        end;
      end else
      begin
        dec(fStopGravityMFrames);
      end;



      //Abstand vom Cursor zum Gravity-Point ermitteln
      Abstand := GetAbstandToGravityPoint;

      //Anziehungskraft aus Abstand ermitteln
      Kraft := 1;
      Multiply := 1;
      Kraft := GetGravityPower(Abstand);
      Multiply := GetMultiplyPower(Abstand);

      //CursorPosition angleichen
      if fStopGravityFrames < 1 then
      begin
        SetFistPosByGravity(Kraft,Multiply);
      end else
      begin
        dec(fStopGravityFrames);
      end;

      //Neue Kampfposition setzen
      SetNewArmPosition(Kampfbereiche.CheckBereiche(Abstand));


      // STARTPOSITIONEN SETZEN Kampfstart
      if fReaktion_Fertig then
      begin
        SetCursorPos(50,380);

        fGravityPoint.y := 355;
        fGravityPoint.X := GetReaktionsAbstand;

        ShowFrame := 30;
      end;
    end;


    //Werte der Sportler verabschieden sich

    if fStopMuedeFrames > 0 then dec(fstopmuedeFrames);
//    if fDoubleMuedeFrames > 0 then dec(fKraftAusdauerGegner,3);
    if fDoubleMuedeFrames > 0 then dec(fDoubleMuedeFrames);

    if fDecPlayers < 1 then
    begin
      if fKraftAusdauerSpieler > 0 then
      begin
        if fStopMuedeFrames>0 then
        begin
//          dec(fstopmuedeFrames);
        end else
        begin
          dec(fKraftAusdauerSpieler, fLevelSpieler*2)
        end;
      end else
      begin
        dec(fMaxKraftSpieler,fLevelSpieler*4);
        if fMaxKraftSpieler < 0 then fMaxKraftSpieler := 0;
      end;

      if fKraftAusdauerGegner > 0 then
      begin
        if fDoubleMuedeFrames > 0 then
        begin
//          dec(fKraftAusdauerGegner,3);
          dec(fKraftAusdauerGegner,fLevelGegner*2*3);
          if fKraftAusdauerGegner < 0 then fKraftAusdauerGegner := 0;
        end else
        begin
          dec(fKraftAusdauerGegner,fLevelGegner*2);
        end;
      end else
      begin
        dec(fMaxKraftGegner,fLevelGegner*4);
        if fMaxKraftGegner < 0 then fMaxKraftGegner := 0;
      end;

      fDecPlayers := 30;
    end else
    begin
      dec(fDecPlayers);
    end;
  end;

  //Kampf zu Ende, Sieger steht fest
  if ShowFrame >= FrameListe.Items.count-2 then
  begin
    //Sieger = Computer
    form1.AfterFight(fweiterleitung,'gegner',fgegner);
    exit;
  end;

  if ShowFrame <= 4 then
  begin
    //Sieger = Spieler
    form1.afterFight(fweiterleitung,'spieler',fgegner);
    exit;
  end;

  //Anzeigen
  DrawAll;
end;

procedure TKampf.IncCir;
var
  temp:int64;
begin
  //FCir := FCir + randomrange(-GetGravityPower(GetAbstandToGravityPoint),GetGravityPower(GetAbstandToGravityPoint));
  randomize;
  FCir := FCir + randomrange(-1,2);
  if FCir > 20 then fCir := 1;
  if FCir < 1 then FCir := 20;
end;

end.
