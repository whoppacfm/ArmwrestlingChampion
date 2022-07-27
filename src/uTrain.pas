unit uTrain;

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
  , FXGrafix
  , uCentralData
  ;


type


  TTrain = class
  private
    FrameListe : TDXImageList;
    OtherPics : TDXImageList;

    fBlinkerCount : integer; //Start Text blinkt
    fGestartet : boolean;
    fSkill : integer; //hin und her bewegung
    fSkillGo : integer; // = randomrange -+fskill
    fSkillFrames : integer; //Dauer in Frames für eine Abweichung
    fDXDraw:TDXDraw;

    fWiederholungen_All : integer; //Anzahl Wiederholungen die abzuleisten sind
    fWiederholungen : integer; //Wird runtergezählt
    fTreffer : integer;

    fTrain_X:integer; //X-Position des Balkens
    fTrain_Y:integer; //Y-Position des Balkens
    fTrain_Step:integer; //Schritt um den Balken nach oben schießt
    fTrain_Up:boolean; //hoch oder runter ?
    fTrain_Run:boolean; //Training läuft

    fOverCount : integer;
    fObenOver : boolean;
    fUntenOver : boolean;

    fGoUp : integer;
    fGoDown : integer;

    fHantel : TAusruestung;

    procedure DrawAll; // Blittet alles auf fDXDraw.surface
    function IncDoubleString(zahlstring:string):string;
  public
    ShowFrame:integer;
    procedure MouseDown(Button:TMouseButton);
    procedure MouseUp(Button:TMouseButton);
    procedure DoTrain; //Main-Fight-Loop für OnTimer
    constructor create(dxDraw:TDXDraw;Hantel:TAusruestung);
    destructor destroy;override;
  end;


implementation

uses
  SysUtils
  , Main

  ;

const
  cTrainVerz='images\Training\';
  cTrainConfig='config\AWETrainConf.awe';


{TKampf}

function TTrain.IncDoubleString(zahlstring:string):string;
var
  temp : integer;
begin
  temp := strtoint(zahlstring);
  inc(temp);
  if temp < 10 then
    result := '0'+inttostr(temp)
  else
    result := inttostr(temp);
end;

procedure TTrain.MouseUp(Button:TMouseButton);
begin
  //Im Bereich ?
  if fObenOver = false then
  begin
    if (fTrain_X > round(581/1.28)) and (fTrain_X < round(581/1.28)+round(119/1.28)) and (fTrain_Y > round(200/1.28)) and (fTrain_Y < round(200/1.28) + round(41/1.28)) then
    begin
      fOverCount := 10;
      fObenOver := true;
      if fWiederholungen > 0 then inc(fTreffer);
      form1.PlayTreffer;
    end;
  end;

  fTrain_Up := false;

  if fGestartet then
  begin
    if fWiederholungen > 1 then
    begin
      dec(fWiederholungen);
    end else
    begin
      //Training beendet
      form1.PlayMusic1;
      Form1.AfterTrain(fTreffer,fWiederholungen_All*2,fHantel.AddMaxKr, fHantel.AddAusd);
    end;
  end;
end;

procedure TTrain.MouseDown(Button:TMouseButton);
begin
  if fGestartet = false then
  begin
    SetCursorPos(fTrain_X, fTrain_Y);
  end;

  //Im Bereich ?
  if fUntenOver = false then
  begin
    if (fTrain_X > round(581/1.28)) and (fTrain_X < round(581/1.28)+round(119/1.28)) and (fTrain_Y > round(576/1.28)) and (fTrain_Y < round(576/1.28) + round(41/1.28)) then
    begin
      fOverCount := 10;
      fUntenOver := true;
      if fWiederholungen > 0 then inc(fTreffer);
      form1.PlayTreffer;
    end;
  end;

  fGestartet := true;
  fTrain_Up := true;
  fTrain_Run := true;
end;

constructor TTrain.create(dxDraw:TDXDraw;Hantel:TAusruestung);
var
  Pfad : string;
  i,j : integer;
  Nummer : string;
  jpegI : TJPEGImage;
begin
  form1.Logger.Add('TTrain.create');

  fGoUp := 0;
  fGoDown := 0;

  fBlinkerCount := 0;
  fWiederholungen_All := Hantel.AnzahlWiederholungen;

  fHantel := Hantel;

  fWiederholungen := fWiederholungen_All;
  fTreffer := 0;

  fOverCount := 0;
  fObenOver := false;
  fUntenOver := false;


  fSkill := 2; //1..10 -> auf fTrain_Step übertragen
  fTrain_Step := Hantel.Schwierigkeit+4; //5..15
  fSkillFrames := 0;

  Screen.Cursor := crNone;
  fGestartet := false;

  fTrain_Y := round(588/1.28);
  fTrain_X := round(628/1.28);


  fTrain_Up := true;
  fTrain_Run := false;

  fDXDraw := dxDraw;


  FrameListe := TDXImageList.Create(fDXDraw);
  FrameListe.DXDraw := fDXDraw;
  OtherPics := TDXImageList.Create(fDXDraw);
  OtherPics.DXDraw := fDXDraw;

  Pfad := ExtractFilePath(Application.exename) + cTrainVerz;
  jPegI := TJPEGImage.Create;

  try
    form1.Logger.Add('TTrain.create OtherPics-Load anzeige.jpg');

    //Anzeige -> 0
    jPegI.LoadFromFile(Pfad+'anzeige.jpg');
    OtherPics.Items.Add;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.Assign(jpegi);
    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Anzeige';
    form1.Logger.Add('TTrain.create OtherPics-Load anzeige.jpg PASSED');


    form1.Logger.Add('TTrain.create OtherPics-Load FC.bmp');
    //Panel -> 1
    //jPegI.LoadFromFile(Pfad+'FC.BMP');
    OtherPics.Items.Add;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.LoadFromFile(Pfad+'FC.BMP');
    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := true;
    OtherPics.Items.Items[OtherPics.Items.Count-1].TransparentColor := $FF00FF;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'Panel';
    form1.Logger.Add('TTrain.create OtherPics-Load FC.bmp PASSED');

    //Hintergrund -> 2
    form1.Logger.Add('TTrain.create OtherPics-Load ugh1.jpg');

    jPegI.LoadFromFile(Pfad+'ugh1.jpg');
    OtherPics.Items.Add;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.Assign(jpegi);
    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'back';
    form1.Logger.Add('TTrain.create OtherPics-Load ugh1.jpg PASSED');

    form1.Logger.Add('TTrain.create OtherPics-Load Treffer_Oben.jpg');
    //Trefferzone Normal -> 3
    jPegI.LoadFromFile(Pfad+'Treffer_Oben.jpg');
    OtherPics.Items.Add;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.Assign(jpegi);
    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'TrefferNormal';
    form1.Logger.Add('TTrain.create OtherPics-Load Treffer_Oben.jpg PASSED');


    form1.Logger.Add('TTrain.create OtherPics-Load Treffer_Over.jpg');
    //Trefferzone Over -> 4
    jPegI.LoadFromFile(Pfad+'Treffer_Over.jpg');
    OtherPics.Items.Add;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.Assign(jpegi);
    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
    OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'TrefferOver';
    form1.Logger.Add('TTrain.create OtherPics-Load Treffer_Over.jpg PASSED');





    //Bank-> 3
//    jPegI.LoadFromFile(Pfad+'bank.jpg');
//    OtherPics.Items.Add;
//    OtherPics.Items.Items[OtherPics.Items.Count-1].Picture.Assign(jpegi);
//    OtherPics.Items.Items[OtherPics.Items.Count-1].Transparent := false;
//    OtherPics.Items.Items[OtherPics.Items.Count-1].Name := 'bank';

    //Frames
    Nummer := '00';
    for i := 0 to 30 do
    begin
      form1.Logger.Add('TTrain.create FrameListe-Load training00' + nummer);

      FrameListe.Items.Add;
      jPegI.LoadFromFile(Pfad+'training00'+Nummer+'.jpg');
      FrameListe.Items.Items[FrameListe.Items.Count-1].Picture.Assign(jPegi);
      FrameListe.Items.Items[FrameListe.Items.Count-1].Transparent := false;
//      FrameListe.Items.Items[FrameListe.Items.Count-1].TransparentColor := clBlack;
      form1.Logger.Add('TTrain.create FrameListe-Load training00' + nummer + ' PASSED');

      Nummer := IncDoubleString(Nummer);

    end;

    ShowFrame := 5;

    form1.PlayMusicTrain;

  finally
    freeandnil(jPegI);
  end;
end;

destructor TTrain.destroy;
begin
  freeandnil(FrameListe);
  freeandnil(OtherPics);
  inherited destroy;
end;

procedure TTrain.DrawAll;
var
  Rechteck:TRect;
  Abstand:integer;
  fx : integer;
  fy : integer;
  fKraft : integer;
  dd : TDXDIB;
  dd2 : TDXDib;
  pp : HPen;
  i : integer;
  Arr : TPointArray;
begin
  OtherPics.Items.Find('back').Draw(fDXDraw.Surface,0,0,0);

  //Anzeige blitten
  //OtherPics.Items.Find('anzeige').Draw(fDXDraw.Surface, 150,50,0);

  //Kampf-Animation blitten
  Rechteck.Left := round(350/1.28);
  Rechteck.Top := round(200/1.28);
  Rechteck.Right := fDXDraw.Width;
  Rechteck.Bottom := fDXDraw.Height;
  FrameListe.Items.items[ShowFrame].Draw(fdxdraw.Surface,round(562/1.28),round(301/1.28),0);
  //FrameListe.Items.items[ShowFrame].StretchDraw(fdxdraw.Surface,Rechteck,0);
  //FrameListe.Items.items[ShowFrame].DrawAlpha(fdxdraw1.Surface,Rechteck,0,220);

  //OtherPics.Items.Find('bank').Draw(fDXDraw.Surface,0,545,0);

  //Trefferzonen
  if fObenOver then
    OtherPics.Items.Find('TrefferOver').Draw(fDXDraw.Surface,round(581/1.28),round(200/1.28),0)
  else
    OtherPics.Items.Find('TrefferNormal').Draw(fDXDraw.Surface,round(581/1.28),round(200/1.28),0);

  if fUntenOver then
    OtherPics.Items.Find('TrefferOver').Draw(fDXDraw.Surface,round(581/1.28),round(576/1.28),0)
  else
    OtherPics.Items.Find('TrefferNormal').Draw(fDXDraw.Surface,round(581/1.28),round(576/1.28),0);

  if fOverCount > 0 then dec(fOverCount) else
  begin
    fObenOver := false;
    fUntenOver := false;
  end;

  //Panel blitten
  Rechteck.Left := fTrain_X;
  Rechteck.Top := fTrain_Y;
  Rechteck.Right := fTrain_X + OtherPics.Items.Find('panel').Width;
  Rechteck.Bottom := fTrain_Y + OtherPics.Items.Find('panel').height;
  OtherPics.Items.Find('panel').DrawAlpha(fDXDraw.Surface, Rechteck, 0, round(170/1.28));
  //  OtherPics.Items.Find('panel').Draw(fDXDraw.Surface, fTrain_X,fTrain_Y,0);


  //Infos anzeigen
  form1.DXPowerFont1.Font := 'Font3';
//  form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,70,100,'Halte optimale Muskelspannung');
  form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,round(35/1.28),round(125/1.28), 'Wiederholungen: ' + inttostr(fWiederholungen));
  form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,round(35/1.28),round(175/1.28), '       Treffer: ' + inttostr(fTreffer) + '/' + inttostr(fWiederholungen_All * 2));

  if not fGestartet then
  begin
    if fBlinkerCount < 20 then
    begin
      form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,round(375/1.28),round(395/1.28), 'Linke Maustaste zum Starten');
    end;
  end;

//  form1.DXPowerFont1.TextOutFast(fDXDraw.Surface,10,10, 'FPS: ' + inttostr(form1.FightTimer.Speed));

  inc(fBlinkerCount);
  if fBlinkerCount > 40 then fBlinkerCount := 0;
end;

procedure TTrain.DoTrain;
var
  Kraft : integer;
  Abstand : integer;
  Multiply : integer;
  GravityChange:integer;
begin
  {
  100

  170..210

  570..610

  700

  Hantelbewegung unabhängig von Panelbewegung
  }
   
  if fTrain_Run then
  begin
    if fTrain_Up then
    begin
      if (ShowFrame < 30) and (fGoUp >= 2) then
      begin
        inc(ShowFrame);
        fGoUp := 0;
      end;
      inc(fGoUp);
      if fTrain_Y > round(100/1.28) + fTrain_Step then dec(fTrain_Y,fTrain_Step);
    end else
    begin
      if (ShowFrame > 0) and (fGoDown >= 2) then
      begin
        dec(ShowFrame);
        fGoDown := 0;
      end;
      inc(fGoDown);
      if fTrain_Y < round(700/1.28) - fTrain_Step then inc(fTrain_Y,fTrain_Step);
    end;
  end;

  //Schwierigkeit und Korrektur
  if fGestartet then
  begin
    if Mouse.CursorPos.x > fTrain_X then fTrain_X := fTrain_X + (Mouse.CursorPos.x - fTrain_X) div 30;
    if Mouse.CursorPos.x < fTrain_X then fTrain_X := fTrain_X - (fTrain_X - Mouse.CursorPos.x) div 30;
    //SetCursorPos(fTrain_X, fTrain_Y);
    randomize;
    if fSkillFrames = 0 then
    begin
      fskillGo := randomrange(-fSkill+5, fSkill+5);
//      if (fSkill > -5) and (fSkill <= 0) then fSkill := -5;
//      if (fSkill < 5) and (fSkill >= 0) then fSkill := 5;
      fSkillFrames := 20;
    end;
    dec(fSkillFrames);

    fTrain_X := fTrain_x + fskillGo;
  end;

  DrawAll;
end;


end.
