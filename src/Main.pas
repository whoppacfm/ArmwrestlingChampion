{
  Projekt:  Armwrestling
  Unit:     Main.pas
  Beginn:   18.Januar 2005
  Stand:    09.März 2005
  (c) Christian Merz 2005
}

unit Main;

interface
                
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs
  , DXClass
  , DXDraws
  , ContNrs
  , DXSprite
  , jpeg
  , uStandardMenu
  , stdctrls
  , DXSounds
  , DIB
//  , JvExControls
//  , JvComponent
//  , JvLabel
  , ExtCtrls
//  , DXPowerFont
//  , DXFusion
  , uCentralData
  , uFight
  , uTrain
  , AsphyreTimers
  , ActnList
  , PlusLibrary
  , math, PowerGfx
  , uLog
  , turbopixels
  , Dateioperationen
  , FileCrypt
  , uSFX
  , ComCtrls
  , inifiles
   
//  , FXGrafix
//  , dxEffectLibrary
  ;

const
  cRelease = '1.0';


Type
  TSpark = Record
    X, Y, SX, SY, Age, Aging: real;
  End;

type
  {Formular}
  TForm1 = class(TDXForm)
    DXDraw1: TDXDraw;
    dxs1: TDXSpriteEngine;
    DXTimer1: TDXTimer;
    Image1: TImage;
    dxBasic: TDXImageList;
    DXPowerFont1: TDXPowerFont;
    DXFontList: TDXImageList;
    DXImageList1: TDXImageList;
    DXDIB1: TDXDIB;
    FBackBuffer: TDXDIB;
    FightTimer: TAsphyreTimer;
    ActionList1: TActionList;
    Action1: TAction;
    Action2: TAction;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DXTimer1Timer(Sender: TObject; LagCount: Integer);
    procedure DXDraw1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure FightTimerProcess(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure DXDraw1MouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure FightTimerRealTime(Sender: TObject; Delta: Real);
    procedure DXTimer2Timer(Sender: TObject; LagCount: Integer);
    procedure FormShow(Sender: TObject);

    procedure PlayBeforeFight;

    procedure PlayMouseOver;
    procedure PlayMouseDown;

    procedure PlayTreffer;

    procedure PlayUpDown;
    procedure PlayNo;
    procedure PlayKalender;
    procedure PlayItem;
    procedure PlayMenuChange;
    procedure PlayBuy;

    procedure PlayGetReady;
    procedure PlayFight;
            
    procedure PlayMusic1;
    procedure PlayMusicFight;
    procedure PlayMusicTrain;

    procedure PlaySchlafstellung;
    procedure playschwitzendehand;
    procedure playkampfgebruell;
    procedure playhoelzernehand;
    procedure playeisernehand;
    procedure playbrennendehand;
    procedure playruettler;
    procedure playblitzangriff;
    procedure playnarkose;
    procedure playtodesgriff;


    //Lautstärke-Konfiguration in Config-Datei speichern
    procedure SaveEffectVolume;
    procedure SaveMusicVolume;
    procedure LoadVolumes;

  private
    fSoundOn : boolean;
    FrameRate : integer;
    MSStart : DWORD;
    fFrameCounter : integer;
    fSleepValue : integer;

//    fAngemeldeteTurniere : array of integer;

    FCursor : TDXDib;
    fActiveMenu : TMenuClass;

    //Fight
    fFight : TKampf;

    //Training
    fTrain : TTrain;

    //Fire
    FSparks: Array[0..10] Of TSpark;
    FX, FY: integer;
    fDoFire:boolean;
    closing:boolean;

    procedure TurnierVorbei;

    procedure SetupSpark;
    procedure PaintFire;
//    Ffire:TFireSpark;

    procedure FadeIn(DIB1,DIB2: TDIB; Step: Byte);
    procedure FadeOut(DIB1,DIB2: TDIB; Step: Byte);

    procedure FadeIt(Picture:TPicture);
    procedure FadeItOut(Picture:TPicture);

    function MakeStringRight(text:string;laenge:integer):string;
    function MakeStringLeft(text:string;laenge:integer):string;
    function StringToDoppel(Zahl:string):string;
    function CenterString(text:string;MaxLength:integer):string;
    function GetTripleString(Zahl:string):string;
    function IncString(temp:string):string;
    function DecString(temp:string):string;
    function GetVerzImages:string;
    procedure CheckEreignisse;
    procedure NewMenu;
    procedure PaintIt;
  public
    fMuckebox : TMuckebox;
    Logger : TLog;

    //Fading
    GoIn:boolean;
    GoOut:boolean;
    FadeSpeed : integer;

    fac: Integer;
    fadxdib1:TDXDIB;
    faBackground:TDXDIB;
    faSStart : DWORD;
    faSEnd : DWORD;
    fasAll : DWORD;



//    fShowEdit : boolean;
//    FEdit:TEdit;

    fSpielerKampfIndex : integer; //von vorsaisonkampf zu vorKampfallgemein -> gegen wen kämpft Spieler?

    procedure FillDIB8(DIB: TDIB; Color: Byte); //Fürs Faden

    procedure NewGameData; // Central Data für neues Spiel initialisieren
    procedure ResetGameData; // Central Data freigeben

    function IncLabelValue(Lab:TLabel):boolean;
    function DecLabelValue(Lab:TLabel):boolean;
    property verzImages : string read GetVerzImages;

    procedure AfterFight(weiterleitung:string;sieger:string;gegner:TSportler);
    procedure AfterTrain(Treffer,MaxTreffer,MaxKraft,KraftAusd:integer);
    procedure TurnierPlayerFight;

    procedure FightDay; //Saison-Kampftag
  end;

  {TOptionsMenuClass}
  TOptionsMenuClass = class(TMenuClass)
    fweiterleitung:string;
	 	procedure ButtonPress(bIndex:integer);override;
    procedure fAktualisieren;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
  public
    Koords : array[0..4] of TPoint;
    slotNow : integer;
    procedure MouseDown(x,y:integer);override;
  end;


  {Pokale}
  TPokaleMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
    destructor destroy;override;
  public
    Koords : array[0..14] of TPoint;
    texte : TStringList;
    fsurfaces : array[0..14] of TDirectDrawSurface;

    //fsurfaceRahmen : TDirectDrawSurface;
    rahmen : TDXImageList;

    ItemNow : integer;

    procedure DrawMenuSpecific;override;
    procedure MouseDown(x,y:integer);override;
//    procedure MouseOver(x,y:integer);override;
  end;

  {Spielende}
  TSpielendeMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
//    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {NachSaison}
	TNachSaisonMenuClass = class(TMenuClass)
    goPokal : boolean;
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {NachRunde}
	TNachRundeMenuClass = class(TMenuClass)
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {Hauptmenü}
	TMainMenuClass = class(TMenuClass)
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    procedure DrawMenuSpecific;override;
  end;

	TVorKampfAllgemeinMenuClass = class(TMenuClass)
  public
    fGegner:TSportler;
    fWeiterleitung:string;
    fsurface:TDirectDrawSurface;
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TSportler;Weiterleitung:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
    destructor destroy;override;
  public
    procedure DrawMenuSpecific;override;
  end;

	TNachKneipenKampfMenuClass = class(TMenuClass)
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TKneipengegner;Sieger:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
  end;

	TNachTurnierKampfMenuClass = class(TMenuClass)
    goPokal : boolean;
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;gegner:TSportler;Sieger:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
  end;

	TVorSaisonKampfMenuClass = class(TMenuClass)
//    fSpielerKampfIndex : integer;
  private
    fWoche : integer;
    frunde:integer;
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Weiterleitung:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
  end;

	TNachSaisonKampf1MenuClass = class(TMenuClass)
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TSportler;sieger:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
  end;

	TNachSaisonKampf2MenuClass = class(TMenuClass)
  	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
  end;

  {Fitness auffüllen}
  TErholungsParkClass = class(TMenuClass)
    fKosten : array[1..5] of integer;
    fweiterleitung : string;
    procedure ButtonPress(bIndex:integer);override;
    procedure MouseButtonOver(bIndex:integer);override;

    procedure Erholen(index:integer);
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
  end;

  {Nach Training}
  TNachTrainingMenuClass = class(TMenuClass)
    procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Treffer,MaxTreffer,MaxKraft,KraftAusd:integer);
  end;


  {Spieler kreieren}
  TCreatePlayerClass = class(TMenuClass)
//    fsurface:TDirectDrawSurface;
    fShowblinker:integer;
    fInfoText:integer;
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
    destructor destroy;override;
  public
    CPSpielerName : string;
    procedure DrawMenuSpecific;override;
  end;

  TCreatePlayerSMClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    CPNow : integer;
    koords : array[0..3] of TPoint;
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    procedure MouseDown(x,y:integer);override;
    procedure DrawMenuSpecific;override;
  end;

  {Spielmenü}
  TGameMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
    procedure MouseButtonOver(bIndex:integer);override;
    procedure UpdateGameMenu;
    procedure SetInfoText(Info:string); //MouseOver Infos über Menüs
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {Spiel laden}
//  TLoadGameMenuClass = class(TMenuClass)
//	 	procedure ButtonPress(bIndex:integer);override;
//  protected
//    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
//  public
//    Koords : array[0..4] of TPoint;
//    slotNow : integer;
//    procedure MouseDown(x,y:integer);override;
//  end;




  {Personal}
  TInfoMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  end;

  {Optionsmenü}
//  TOptionsMenuClass = class(TMenuClass)
//	 	procedure ButtonPress(bIndex:integer);override;
//  end;

  {Ranglistenmenü}
  TRanglistenMenuClass = class(TMenuClass)
    Liste : TObjectList;
    Liste2 : TObjectList;
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
    destructor destroy;override;
  end;

  {Trainingsmenü}
  TTrainingMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
    destructor destroy;override;
  public
    fAktuelleHantel : TAusruestung;
    Koords : array[0..15] of TPoint;
    ItemNow : integer; //Position auf Rucksack, die markiert ist
    fIndices : TStringList; //Hantel-Indices in Ausrüstungsliste
    showMinusFitness : boolean;
    procedure DrawMenuSpecific;override;
    procedure MouseDown(x,y:integer);override;
    procedure MouseOver(x,y:integer);override;
  end;

  {Sponsorenmenü}
  TSponsorenMenuClass = class(TMenuClass)
    fFirstArrayIndex : integer; //Array Item das an erster Position angezeigt wird
    fMarkedIndex : integer; // 1..6
    fXKoords : array[1..6] of integer;
    fY : integer;
    AbschlussOver : boolean;
	 	procedure ButtonPress(bIndex:integer);override;
    procedure DrawMenuSpecific;override;
    procedure MouseDown(x,y:integer);override;
    procedure MouseOver(x,y:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {Kampflistenmenü}
  TKampflistenMenuClass = class(TMenuClass)
    fRunde : integer; //1,2
    fWoche : integer; //1..19
	 	procedure ButtonPress(bIndex:integer);override;
    procedure DrawMenuSpecific;override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {Vor Kampf-Menü}
  TBeforeFightMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  end;

  {Einkaufenmenü}
  TEinkaufenMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    KoordsShop : array[0..15] of TPoint;
    KoordsBesitz : array[0..15] of TPoint;

    ItemNow : integer;
    ShopOrBesitz : integer; // 0 = Shop, 1 = Besitz

    procedure DrawMenuSpecific;override;
    procedure MouseDown(x,y:integer);override;
  end;

  {Kneipe}
  TKneipenMenuClass = class(TMenuClass)
  public
    fAktuellerGegner : TKneipenGegner;
    fAktuellerIndex : integer;
    fAktuellerGegnerIndex : integer;
    fMinus : boolean;
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    procedure MouseDown(x,y:integer);override;
    procedure MouseButtonOver(bIndex:integer);override;
    procedure DrawMenuSpecific;override;
  end;

  {Tabelle}
  TTabellenMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  TVorTurnierStartMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {Turnier}
  TTurnierMenuClass = class(TMenuClass)
    fAktuellesTurnier : TTurnier;
    fAktuellerIndex : integer;
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    procedure MouseDown(x,y:integer);override;
    procedure MouseOver(x,y:integer);override;
  end;

  {Turnier-Durchführung}
  TTurnierStartMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    fAbstand : integer;
    gX,gY : integer;
    fsurfaceUnten : TDirectDrawSurface;
    fsurfaceAbbrechen1 : TDirectDrawSurface;
    fSurfaceAbbrechen2 : TDirectDrawSurface;
    fSurfaceNext1 : TDirectDrawSurface;
    fSurfaceNext2 : TDirectDrawSurface;
    fsurfaceScroller_normal : TDirectDrawSurface;
    fsurfaceScroller_links : TDirectDrawSurface;
    fsurfaceScroller_rechts : TDirectDrawSurface;
    fsurfaceScroller_hoch : TDirectDrawSurface;
    fsurfaceScroller_runter : TDirectDrawSurface;

    fSurfaceRahmen : TDirectDrawSurface;

    abbrechenOver : boolean;
    nextroundOver : boolean;
    Scroller : integer;

    ImageList : TDXImageList;
    fPosition : integer; //ungewünschte Verbindungslinien entfernen

    procedure DrawMenuSpecific;override;
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
    destructor destroy;override;
  public
    procedure MouseDown(x,y:integer);override;
    procedure MouseUp;override;
    procedure MouseOver(x,y:integer);override;
  end;


  {PSEigenschaften}
  TPSEigenschaftenMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {PSAusrüstung}
  TPSAusruestungsMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    Koords : array[0..18] of TPoint; //0..15, 16-18
    ItemNow : integer;
    procedure DrawMenuSpecific;override;
    procedure MouseDown(x,y:integer);override;
  end;

  {PSSpecialMoves}
  TPSSpecialMovesMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  public
    SMNow : integer;
    fUpgradeOver:boolean;
    procedure DrawMenuSpecific;override;
    procedure MouseDown(x,y:integer);override;
    procedure MouseOver(x,y:integer);override;
  end;

  {PSStatistik}
  TPSStatistikMenuClass = class(TMenuClass)
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
  end;

  {MuckeMenu}
  TMuckeMenuClass = class(TMenuClass)
    fweiterleitung:string;
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
  end;

  {HilfeMenu}
  THilfeMenuClass = class(TMenuClass)
    fweiterleitung:string;

    //Für Untermenü-Pfeil-Navigation
    factive:integer; //Aktuelles Hilfemenü
    factiveSub:integer; //Aktuelle Unterseite von fActive
    factiveSubMax:integer; //MaxAnzahl Unterseiten von factive

    fsurface:TDirectDrawSurface;
    fHilfeText:TStringList;
    procedure DrawMenuSpecific;override;
	 	procedure ButtonPress(bIndex:integer);override;
  protected
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
    destructor destroy;override;
  end;

  {TWohnungsMenuClass}
  TWohnungsMenuClass = class(TMenuClass)
    fover:integer;
    fweiterleitung : string;
	  procedure ButtonPress(bIndex:integer);override;
    procedure aktualisiereDaten;
  protected
    procedure DrawMenuSpecific;override;
    procedure MouseButtonOver(bIndex:integer);override;
    constructor create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
  end;


  {Testmenü}
	TTestMenuClass = class(TMenuClass)
	  procedure ButtonPress(bIndex:integer);override;
  end;

var
  Form1: TForm1;

const
  cFont1 = '!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\_abcdefghijklmnopqrstuvwxyz';
  cFont2 = '_!"# %___()*+,-./0123456789:;<=>?_ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]___abcdefghijklmnobpqrstuvwxyz{|}';

  cMyFont = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ___abcdefghijklmnopqrstuvwxyzäöü___0123456789______+-.:?!&(),/"''%ß';


  function GetSoundPath:string;

implementation

uses StrUtils, DateUtils;

{$R *.dfm}

const
//  cOptionen               = '      Optionen      ';
//  cKalender               = '    Nächster Tag    ';
//  cKampfListe             = ' Saisonbegegnungen  ';
//  cKneipe                 = '       Kneipe       ';
//  cPersonal               = '     Charakter      ';
//  cSportshop              = '     Sportshop      ';
//  cSponsor                = '     Sponsoren      ';
//  cTabelle                = '      Tabelle       ';
//  cTraining               = '     Training       ';
//  cTurniere               = '     Turniere       ';
//  cFaehigkeitenvergleich  = 'Fähigkeitenvergleich';

  cMucke                  = 'Soundoptionen';
  cOptionen               = 'Spieloptionen';
  cKalender               = 'Nächster Tag';
  cKampfListe             = 'Saisonbegegnungen';
  cKneipe                 = 'Kneipe';
  cPersonal               = 'Charakter';
  cSportshop              = 'Sportshop';
  cSponsor                = 'Sponsoren';
  cTabelle                = 'Tabellen';
  cWohnung                = 'Unterkunft';
  cTraining               = 'Training';
  cTurniere               = 'Turniere';
  cFaehigkeitenvergleich  = 'Fähigkeitenvergleich';
  cPokale                 = 'Pokale';
  cHelp                   = 'Hilfe';

function GetSoundPath:string;
begin
  result := extractfilepath(application.ExeName) + 'Sounds\';
end;


procedure TWohnungsMenuClass.ButtonPress(bIndex:integer);
begin
  case bIndex of
    0:  begin
          if fweiterleitung = 'personal' then
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TPSEigenschaftenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end else
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end;
        end;

    1:  begin
          form1.PlayUpDown;
          cdspieler.regenerationsrate := 15;
          aktualisiereDaten;
        end;

    2:  begin
          if cdspieler.Kapital >= 30 then
          begin
            form1.PlayUpDown;
            cdspieler.Kapital := cdspieler.Kapital - 30;
            cdspieler.regenerationsrate := 25;
            aktualisiereDaten;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    3:  begin
          if cdspieler.Kapital >= 100 then
          begin
            form1.PlayUpDown;
            cdspieler.Kapital := cdspieler.Kapital - 100;
            cdspieler.regenerationsrate := 35;
            aktualisiereDaten;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    4:  begin
          if cdspieler.Kapital >= 200 then
          begin
            form1.PlayUpDown;
            cdspieler.Kapital := cdspieler.Kapital - 200;
            cdspieler.regenerationsrate := 45;
            aktualisiereDaten;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    5:  begin
          if cdspieler.Kapital >= 300 then
          begin
            form1.PlayUpDown;
            cdspieler.Kapital := cdspieler.Kapital - 300;
            cdspieler.regenerationsrate := 55;
            aktualisiereDaten;
          end else
          begin
            form1.PlayNo;
          end;
        end;

  end;
end;


procedure TWohnungsMenuClass.MouseButtonOver(bIndex:integer);
begin
  fover := -1;
  case bindex of
    2: fover:=2;
    3: fover:=3;
    4: fover:=4;
    5: fover:=5;
  end;
end;

procedure TWohnungsMenuClass.DrawMenuSpecific;
var
  geld:integer;
begin
  if fover <> -1 then
  begin
    case fover of
      2: geld := 30;
      3: geld := 100;
      4: geld := 200;
      5: geld := 300;
    end;
    (self.LabelConfigList[11] as TLabelConfig).fLabel := 'Kapital: ' + inttostr(cdSpieler.Kapital-geld);
    (ImageConfigList[1] as TImageConfig).X := (LabelConfigList[11] as TLabelConfig).X + length((self.LabelConfigList[11] as TLabelConfig).fLabel)*11;
    (ImageConfigList[1] as TImageConfig).Y := (LabelConfigList[11] as TLabelConfig).y-15;
  end else
  begin
    (self.LabelConfigList[11] as TLabelConfig).fLabel := 'Kapital: ' + inttostr(cdSpieler.Kapital);
    (ImageConfigList[1] as TImageConfig).X := (LabelConfigList[11] as TLabelConfig).X + length((self.LabelConfigList[11] as TLabelConfig).fLabel)*11;
    (ImageConfigList[1] as TImageConfig).Y := (LabelConfigList[11] as TLabelConfig).y-15;
  end;
end;

constructor TWohnungsMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
var
  i : integer;
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  fweiterleitung := weiterleitung;

//  		-> Auf der Strasse 15%   Miete: 0/Woche
//		   Notunterkunft +25%   Miete: 30/Woche
//		   kleines Häuschen +35%   Miete: 100/Woche
//		   Haus +45%   Miete: 200/Woche
//  		   Villa +55%   Miete: 300/Woche
  (LabelConfigList[0] as TLabelConfig).fLabel := ' Unterkunft   Regeneration   Miete';
  (LabelConfigList[1] as TLabelConfig).fLabel := '                  15%       0/Woche';
  (LabelConfigList[2] as TLabelConfig).fLabel := '                  25%      30/Woche';
  (LabelConfigList[3] as TLabelConfig).fLabel := '                  35%      100/Woche';
  (LabelConfigList[4] as TLabelConfig).fLabel := '                  45%      200/Woche';
  (LabelConfigList[5] as TLabelConfig).fLabel := '                  55%      300/Woche';

  (self.LabelConfigList[11] as TLabelConfig).fLabel := 'Kapital: ' + inttostr(cdSpieler.Kapital);
  (ImageConfigList[1] as TImageConfig).X := (LabelConfigList[11] as TLabelConfig).X + length((self.LabelConfigList[11] as TLabelConfig).fLabel)*11;
  (ImageConfigList[1] as TImageConfig).Y := (LabelConfigList[11] as TLabelConfig).y-15;

  aktualisiereDaten;
end;

procedure TWohnungsMenuClass.aktualisiereDaten;
begin
  (LabelConfigList[6] as TLabelConfig).fLabel := '  mieten';
  (LabelConfigList[7] as TLabelConfig).fLabel := '  mieten';
  (LabelConfigList[8] as TLabelConfig).fLabel := '  mieten';
  (LabelConfigList[9] as TLabelConfig).fLabel := '  mieten';
  (LabelConfigList[10] as TLabelConfig).fLabel := '  mieten';

  (ButtonConfigList[1] as TButtonConfig).x := round(710/1.28);
  (ButtonConfigList[2] as TButtonConfig).x := round(710/1.28);
  (ButtonConfigList[3] as TButtonConfig).x := round(710/1.28);
  (ButtonConfigList[4] as TButtonConfig).x := round(710/1.28);
  (ButtonConfigList[5] as TButtonConfig).x := round(710/1.28);

  case cdspieler.regenerationsrate of
    15: begin
          (LabelConfigList[6] as TLabelConfig).fLabel := 'angemietet';
          (ImageConfigList[0] as TImageConfig).X := (ButtonConfigList[1] as TButtonConfig).X;
          (ImageConfigList[0] as TImageConfig).Y := (ButtonConfigList[1] as TButtonConfig).Y;
          (ButtonConfigList[1] as TButtonConfig).x := 2000;
        end;
    25: begin
          (LabelConfigList[7] as TLabelConfig).fLabel := 'angemietet';
          (ImageConfigList[0] as TImageConfig).X := (ButtonConfigList[2] as TButtonConfig).X;
          (ImageConfigList[0] as TImageConfig).Y := (ButtonConfigList[2] as TButtonConfig).Y;
          (ButtonConfigList[2] as TButtonConfig).x := 2000;
        end;
    35: begin
          (LabelConfigList[8] as TLabelConfig).fLabel := 'angemietet';
          (ImageConfigList[0] as TImageConfig).X := (ButtonConfigList[3] as TButtonConfig).X;
          (ImageConfigList[0] as TImageConfig).Y := (ButtonConfigList[3] as TButtonConfig).Y;
          (ButtonConfigList[3] as TButtonConfig).x := 2000;
        end;
    45: begin
          (LabelConfigList[9] as TLabelConfig).fLabel := 'angemietet';
          (ImageConfigList[0] as TImageConfig).X := (ButtonConfigList[4] as TButtonConfig).X;
          (ImageConfigList[0] as TImageConfig).Y := (ButtonConfigList[4] as TButtonConfig).Y;
          (ButtonConfigList[4] as TButtonConfig).x := 2000;
        end;
    55: begin
          (LabelConfigList[10] as TLabelConfig).fLabel := 'angemietet';
          (ImageConfigList[0] as TImageConfig).X := (ButtonConfigList[5] as TButtonConfig).X;
          (ImageConfigList[0] as TImageConfig).Y := (ButtonConfigList[5] as TButtonConfig).Y;
          (ButtonConfigList[5] as TButtonConfig).x := 2000;
        end;
  end;
end;

procedure TForm1.SaveEffectVolume;
var
  ini: TIniFile;
begin
  ini:=TIniFile.Create(extractfilepath(application.exename) + 'Soundconf.ini');
  try
    ini.WriteInteger('Effects','Volume',round(form1.fMuckebox.EffectVolume*10));
    ini.UpdateFile;
  finally
    ini.free;
  end;
end;

procedure TForm1.SaveMusicVolume;
var
  ini: TIniFile;
begin
  ini:=TIniFile.Create(extractfilepath(application.exename) + 'Soundconf.ini');
  try
    ini.WriteInteger('Music','Volume',round(form1.fMuckebox.MusicVolume*10));
    ini.UpdateFile;
  finally
    ini.free;
  end;
end;

procedure TForm1.LoadVolumes;
var
  ini: TIniFile;
begin
  ini:=TIniFile.Create(extractfilepath(application.exename) + 'Soundconf.ini');
  try
    form1.fMuckebox.MusicVolume := ini.ReadInteger('Music','Volume',4) / 10;
    form1.fMuckebox.EffectVolume := ini.ReadInteger('Effects','Volume',8) / 10;

    if form1.fMuckebox.MusicVolume > 1 then form1.fMuckebox.MusicVolume := 1;
    if form1.fMuckebox.EffectVolume > 1 then form1.fMuckebox.EffectVolume := 1;
    if form1.fMuckebox.MusicVolume < 0 then form1.fMuckebox.MusicVolume := 0;
    if form1.fMuckebox.EffectVolume < 0 then form1.fMuckebox.EffectVolume := 0;
  finally
    ini.free;
  end;
end;



{Soundplayer}

procedure TForm1.PlayMusic1;
begin
  if fsoundon then fMuckebox.PlayMusic(extractfilepath(application.exename) + 'Sounds\back2.ogg');
//  AudioOut1.Stop;
//  AudioOut1.abort;
//  while form1.AudioOut1.Status <> tosIdle do;
//  AudioOut1.Input := Inmusic1;
//  AudioOut1.Run;
end;

procedure TForm1.PlayMusicTrain;
begin
  fMuckebox.PlayMusic(extractfilepath(application.exename) + 'Sounds\train.ogg');
end;

procedure TForm1.PlayMusicFight;
begin
  if fsoundon then fMuckebox.PlayMusic(extractfilepath(application.exename) + 'Sounds\fightback.ogg');
//  AudioOut1.Stop;
//  AudioOut1.abort;
//  while form1.AudioOut1.Status <> tosIdle do;
//  AudioOut1.Input := Inmusicfight;
//  AudioOut1.Run;
end;

procedure TForm1.PlaySchlafstellung;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_schlafstellung.ogg');
end;

procedure TForm1.playschwitzendehand;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_schwitzendehand.ogg');
end;

procedure TForm1.playkampfgebruell;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_kampfgebruell.ogg');
end;

procedure TForm1.playhoelzernehand;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_hoelzernehand.ogg');
end;

procedure TForm1.playeisernehand;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_eisernehand.ogg');
end;

procedure TForm1.playbrennendehand;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_brennendehand.ogg');
end;

procedure TForm1.playruettler;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_ruettler.ogg');
end;

procedure TForm1.playblitzangriff;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_blitzangriff.ogg');
end;

procedure TForm1.playnarkose;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_narkose.ogg');
end;

procedure TForm1.playtodesgriff;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'sm_todesgriff.ogg');
end;


procedure TForm1.PlayBuy;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'buy.ogg');
//  form1.DXWaveList1.Items.Find('getready').Play(false);
end;

procedure TForm1.PlayGetReady;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'getready.ogg');
//  form1.DXWaveList1.Items.Find('getready').Play(false);
end;

procedure TForm1.PlayFight;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'fight.ogg');
//  form1.DXWaveList1.Items.Find('fight').Play(false);
end;

procedure TForm1.PlayMenuChange;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'down_menuchange.ogg');

//  form1.DXWaveList1.Items.Find('items').Play(false);
end;

procedure TForm1.PlayItem;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'items.ogg');

//  form1.DXWaveList1.Items.Find('items').Play(false);
end;

procedure TForm1.PlayKalender;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'kalender.ogg');
//  form1.DXWaveList1.Items.Find('kalender').Play(false);
end;

procedure TForm1.PlayNo;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'nein.ogg');
//  form1.DXWaveList1.Items.Find('nein').Play(false);
end;

procedure TForm1.PlayTreffer;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'treffer.ogg');
//  form1.DXWaveList1.Items.Find('over').Play(false);
end;

procedure TForm1.PlayBeforeFight;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'beforefight.ogg');
//  form1.DXWaveList1.Items.Find('over').Play(false);
end;

procedure TForm1.PlayMouseOver;
begin
  if fsoundon then fMuckebox.PlayEffect(GetSoundPath + 'over.ogg');
//  form1.DXWaveList1.Items.Find('over').Play(false);
end;

procedure TForm1.PlayMouseDown;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'down.ogg');
//  form1.DXWaveList1.Items.Find('down').Play(false);
end;

procedure TForm1.PlayUpDown;
begin
  if fsoundon then  fMuckebox.PlayEffect(GetSoundPath + 'updown.ogg');
//  form1.DXWaveList1.Items.Find('updown').Play(false);
end;



{HilfeMenu}
procedure THilfeMenuClass.DrawMenuSpecific;
var
  i,k : integer;
  pX : integer;
  yP : integer;
  pfad:string;
  temp : string;

  procedure SetFontByString(var text:string);
  begin
    if length(Text) > 1 then
    begin
      if Text[1] = '0' then
      begin
        form1.DXPowerFont1.Font := 'FontN2';
        Text := copy(Text,2,length(text)-1);
      end else
      begin
        form1.DXPowerFont1.Font := 'FontN';
      end;
    end;
  end;

begin
  //Zeilelänge: 63
  //Anzahl Zeile: 25

  (self.LabelConfigList[10] as TLabelConfig).fLabel := inttostr(factiveSub) + '/' + inttostr(factiveSubMax);

  pfad := extractfilepath(application.exename) + 'Config\Help\';
  pX := 150;
  yP := 15;
  form1.DXPowerFont1.Font := 'FontN';
//  form1.DXPowerFont1.Font := 'Font2';
  case factive of
    //Einführung
    1:  begin
          fHilfeText.LoadFromFile(pfad+'Einfuehrung.awe');
//          SetzeZeilenLaenge(fHilfeText,63);
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to 24 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          2:  begin
                for i := 25 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Training
    2:  begin
          fHilfeText.LoadFromFile(pfad+'Training.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to 24 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          2:  begin
                for i := 25 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Kampf
    3:  begin
          fHilfeText.LoadFromFile(pfad+'Kampf.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to 24 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          2:  begin
                for i := 25 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Charakter
    4:  begin
          fHilfeText.LoadFromFile(pfad+'Charaktereigenschaften.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to 24 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          2:  begin
                for i := 25 to 49 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          3:  begin
                for i := 50 to 74 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          4:  begin
                for i := 75 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Spezialbewegungen
    5:  begin
          fHilfeText.LoadFromFile(pfad+'Spezialbewegungen.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Ausrüstung
    6:  begin
          fHilfeText.LoadFromFile(pfad+'Ausruestung.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Kneipe
    7:  begin
          fHilfeText.LoadFromFile(pfad+'Kneipe.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Sponsoren
    8:  begin
          fHilfeText.LoadFromFile(pfad+'Sponsoren.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Turniere
    9:  begin
          fHilfeText.LoadFromFile(pfad+'Turniere.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to 24 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          2:  begin
                for i := 25 to fHilfetext.count - 1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;

                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Spielstände
    10:  begin
          fHilfeText.LoadFromFile(pfad+'Spielstand.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to fHilfetext.count-1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;
                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

    //Schnellstart
    11:  begin
          fHilfeText.LoadFromFile(pfad+'Schnellstart.awe');
          SetzeZeilenLaenge(fHilfeText,63);
          case factiveSub of
          1:  begin
                for i := 0 to fHilfetext.count-1 do
                begin
                  temp := fHilfeText[i];
                  SetFontByString(temp);
                  fHilfeText[i] := temp;
                  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, px, yp, CenterString(fHilfeText[i],63));
                  inc(yp,20);
                end;
              end;
          end;
        end;

  end;
end;

procedure THilfeMenuClass.ButtonPress(bIndex:integer);
begin
  if bindex > -1 then form1.PlayUpDown;

  case bIndex of
    0:  begin
          factive := 1;
          factiveSub := 1;
          factiveSubMax := 2;
        end;

    1:  begin
          factive := 2;
          factiveSub := 1;
          factiveSubMax := 2;
        end;

    2:  begin
          factive := 3;
          factiveSub := 1;
          factiveSubMax := 2;
        end;

    3:  begin
          factive := 4;
          factiveSub := 1;
          factiveSubMax := 4;
        end;

    4:  begin //SMs
          factive := 5;
          factiveSub := 1;
          factiveSubMax := 1;
        end;

    5:  begin //Ausrüstung
          factive := 6;
          factiveSub := 1;
          factiveSubMax := 1;
        end;

    6:  begin //Kneipe
          factive := 7;
          factiveSub := 1;
          factiveSubMax := 1;
        end;

    7:  begin //Sponsoren
          factive := 8;
          factiveSub := 1;
          factiveSubMax := 1;
        end;

    8:  begin //Turniere
          factive := 9;
          factiveSub := 1;
          factiveSubMax := 2;
        end;

    9:  begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
        end;

    10: begin //links
          if factiveSub > 1 then
          begin
            dec(factivesub);
          end else
          begin
            factivesub := factivesubmax;
          end;
        end;

    11: begin //rechts
          if factiveSub < factiveSubMax then
          begin
            inc(factivesub);
          end else
          begin
            factivesub := 1;
          end;
        end;

    12:  begin //Spielstände
          factive := 10;
          factiveSub := 1;
          factiveSubMax := 1;
        end;

    13:  begin //Schnellstart
          factive := 11;
          factiveSub := 1;
          factiveSubMax := 1;
        end;

  end;
end;

destructor THilfeMenuClass.destroy;
begin
  freeandnil(fsurface);
  freeandnil(fHilfetext);
  inherited destroy;
end;

constructor THilfeMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
var
  i : integer;
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  fHilfeText := TStringList.create;
  fweiterleitung := weiterleitung;
  fsurface := TDirectDrawSurface.Create(form1.DXDraw1.DDraw);

  for i := 0 to 9 do
  begin
    (self.ButtonConfigList[i] as TButtonConfig).Y := 180 + i*32;
    (self.LabelConfigList[i] as TLabelConfig).Y := 187 + i*32;
    (self.LabelConfigList[i] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[i] as TLabelConfig).fLabel,12);
  end;
  //Spielstand
  (self.ButtonConfigList[12] as TButtonConfig).Y := 180 + 9*32;
  (self.LabelConfigList[11] as TLabelConfig).Y := 187 + 9*32;
  (self.LabelConfigList[11] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[11] as TLabelConfig).fLabel,12);

  //Schnellstart
  (self.ButtonConfigList[13] as TButtonConfig).Y := 100 + 32;
  (self.LabelConfigList[12] as TLabelConfig).Y := 107 + 32;
  (self.LabelConfigList[12] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[12] as TLabelConfig).fLabel,12);


  (self.ButtonConfigList[9] as TButtonConfig).Y := 556;
  (self.LabelConfigList[9] as TLabelConfig).Y := 563;
  (self.LabelConfigList[9] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[9] as TLabelConfig).fLabel,12);

  factive := 11;
  factiveSub := 1;
  factiveSubMax := 1;
end;

procedure TMuckeMenuClass.ButtonPress(bIndex:integer);
begin
  case bindex of
    0:begin
        if fweiterleitung = 'mainmenu' then
        begin
          Form1.NewMenu;
          Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
        end else if fweiterleitung = 'gamemenu' then
        begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
        end;
      end;

    //Musik L2
    1:begin
        if form1.fMuckebox.MusicVolume < 1 then
        begin
          form1.PlayUpDown;
          form1.fMuckebox.MusicVolume := form1.fMuckebox.MusicVolume + 0.1;
          form1.fMuckebox.MusicVolume := roundto(form1.fMuckebox.MusicVolume,-1);
          if form1.fMuckebox.MusicVolume > 1 then form1.fMuckebox.MusicVolume := 1;
          form1.SaveMusicVolume;
        end else
        begin
          form1.PlayNo;
        end;
        (self.LabelConfigList[2] as TLabelconfig).fLabel := stringtodoppel(inttostr(round(10*form1.fMuckebox.MusicVolume)));
      end;
    2:begin
        if form1.fMuckebox.MusicVolume > 0 then
        begin
          form1.PlayUpDown;
          form1.fMuckebox.MusicVolume := form1.fMuckebox.MusicVolume - 0.1;
          form1.fMuckebox.MusicVolume := roundto(form1.fMuckebox.MusicVolume,-1);
          if form1.fMuckebox.MusicVolume < 0 then form1.fMuckebox.MusicVolume := 0;
          form1.SaveMusicVolume;
        end else
        begin
          form1.PlayNo;
        end;
        (self.LabelConfigList[2] as TLabelconfig).fLabel := stringtodoppel(inttostr(round(10*form1.fMuckebox.MusicVolume)));
      end;

    //Effekte L4
    3:begin
        if form1.fMuckebox.EffectVolume < 1 then
        begin
          form1.PlayUpDown;
          form1.fMuckebox.EffectVolume := form1.fMuckebox.EffectVolume + 0.1;
          form1.fMuckebox.EffectVolume := roundto(form1.fMuckebox.EffectVolume,-1);
          if form1.fMuckebox.EffectVolume > 1 then form1.fMuckebox.EffectVolume := 1;
          form1.SaveEffectVolume;
        end else
        begin
          form1.playno;
        end;
        (self.LabelConfigList[4] as TLabelconfig).fLabel := stringtodoppel(inttostr(round(10*form1.fMuckebox.EffectVolume)));
      end;
    4:begin
        if form1.fMuckebox.EffectVolume > 0 then
        begin
          form1.PlayUpDown;
          form1.fMuckebox.EffectVolume := form1.fMuckebox.EffectVolume - 0.1;
          form1.fMuckebox.EffectVolume := roundto(form1.fMuckebox.EffectVolume,-1);
          if form1.fMuckebox.EffectVolume < 0 then form1.fMuckebox.EffectVolume := 0;
          form1.SaveEffectVolume;
        end else
        begin
          form1.PlayNo;
        end;
        (self.LabelConfigList[4] as TLabelconfig).fLabel := stringtodoppel(inttostr(round(10*form1.fMuckebox.EffectVolume)));
      end;
  end;
end;

constructor TMuckeMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  fweiterleitung := weiterleitung;

  (self.LabelConfigList[2] as TLabelconfig).fLabel := stringtodoppel(inttostr(round(10*form1.fMuckebox.MusicVolume)));
  (self.LabelConfigList[4] as TLabelconfig).fLabel := stringtodoppel(inttostr(round(10*form1.fMuckebox.EffectVolume)));
end;


{Spielende}

procedure TSpielendeMenuClass.ButtonPress(bIndex:integer);
begin
  case bIndex of
    //Spiel beenden
    0:  begin
          freeandnil(Form1.factivemenu);
          form1.ResetGameData;
          form1.Close;
        end;
    //weiterspielen
    1:  begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
        end;
  end;
end;

{TPokaleMenuClass}
//Koords : array[0..12] of TPoint;
//ItemNow : integer;

procedure TPokaleMenuClass.ButtonPress(bIndex:integer);
var
  allePokale:boolean;
begin
  allePokale := true;
  case bIndex of
    0:  begin
          if not cdspieler.TurnierKneipeSieg then
            allePokale := false;
          if not cdspieler.TurnierBeginnersCornerSieg then
            allePokale := false;
          if not cdspieler.TurnierRummelRingenSieg then
            allePokale := false;
          if not cdspieler.TurnierSportCafeTurnierSieg then
            allePokale := false;
          if not cdspieler.TurnierProletenClubSieg then
            allePokale := false;
          if not cdspieler.TurnierSemiProTurnier then
            allePokale := false;
          if not cdspieler.TurnierProfiturnierSieg then
            allePokale := false;
          if not cdspieler.TurnierEuropameisterschaftSieg then
            allePokale := false;
          if not cdspieler.TurnierWeltmeisterschaft then
            allePokale := false;
          if not cdspieler.TurnierMeisterTurnier then
            allePokale := false;
          if not cdspieler.Meisterschaften1>0 then
            allePokale := false;
          if not cdspieler.Meisterschaften2>0 then
            allePokale := false;
          if not cdspieler.Meisterschaften3>0 then
            allePokale := false;

          if (allePokale) and (cdSpieler.EndeShown=false) then
          begin
            cdspieler.endeshown := true;
            Form1.NewMenu;
            Form1.fActiveMenu := TSpielendeMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end else
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end;
        end;
  end;
end;

constructor TPokaleMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
  pfad : string;
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  itemnow := 0;

  //Koords : array[0..12] of TPoint;
  //ItemNow : integer;

  //Koordinaten festlegen
//  y oben: 120
//  y unten: 300
//
//  X: 26, 145, 270, 391, 511,
//
//
//  die rechten:
//  x: 651
//
//  y: 29, 209, 391

  //oberste Reihe
  Koords[0].x := 25;
  Koords[0].y := 28;

  Koords[1].x := 147;
  Koords[1].y := 28;

  Koords[2].x := 270;
  Koords[2].y := 28;

  Koords[3].x := 391;
  Koords[3].y := 28;

  Koords[4].x := 511;
  Koords[4].y := 28;

  Koords[5].x := 633;
  Koords[5].y := 28;

  //mittlere Reihe
  Koords[6].x := 25;
  Koords[6].y := 208;

  Koords[7].x := 147;
  Koords[7].y := 208;

  Koords[8].x := 270;
  Koords[8].y := 208;

  Koords[9].x := 391;
  Koords[9].y := 208;

  Koords[10].x := 511;
  Koords[10].y := 208;

  Koords[11].x := 633;
  Koords[11].y := 208;

  //untere Reihe
  Koords[12].x := 25;
  Koords[12].y := 392;

  Koords[13].x := 147;
  Koords[13].y := 392;

  Koords[14].x := 270;
  Koords[14].y := 392;




  //Pokalgrafiken einlesen

  for i := 0 to 14 do
  begin
    fSurfaces[i] := TDirectDrawSurface.Create(form1.DXDraw1.DDraw);
  end;

  pfad := extractfilepath(application.exename)+'Images\Items\pokale\';

  rahmen := TDXImageList.Create(form1.dxdraw1);
  rahmen.DXDraw := form1.DXDraw1;
  rahmen.Items := TPictureCollection.Create(form1.DXDraw1);
  rahmen.Items.Add;
  rahmen.Items.Items[rahmen.Items.Count-1].Picture.LoadFromFile(pfad + 'pokale_markierung.bmp');
  rahmen.Items[0].Transparent := true;
  rahmen.Items[0].TransparentColor := $FF00FF;
//  fSurfaceRahmen := TDirectDrawSurface.Create(form1.DXDraw1.DDraw);
//  fsurfaceRahmen.LoadFromFile(pfad + 'pokale_markierung.bmp');
//  fsurfaceRahmen.TransparentColor := $FF00FF;

  fsurfaces[0].LoadFromFile(pfad + 'kneipe.jpg');
  fsurfaces[1].LoadFromFile(pfad + 'beginnerscorner.jpg');
  fsurfaces[2].LoadFromFile(pfad + 'rummelringen.jpg');
  fsurfaces[3].LoadFromFile(pfad + 'sportcafe.jpg');
  fsurfaces[4].LoadFromFile(pfad + 'proletenclub.jpg');
  fsurfaces[5].LoadFromFile(pfad + 'semipro.jpg');
  fsurfaces[6].LoadFromFile(pfad + 'profiturnier.jpg');
  fsurfaces[7].LoadFromFile(pfad + 'europameister.jpg');
  fsurfaces[8].LoadFromFile(pfad + 'weltmeister.jpg');
  fsurfaces[9].LoadFromFile(pfad + 'meisterturnier.jpg');
  fsurfaces[10].LoadFromFile(pfad + 'meisterschaft1.jpg');
  fsurfaces[11].LoadFromFile(pfad + 'meisterschaft2.jpg');
  fsurfaces[12].LoadFromFile(pfad + 'meisterschaft3.jpg');
  fsurfaces[13].LoadFromFile(pfad + 'meisterschaft4.jpg');
  fsurfaces[14].LoadFromFile(pfad + 'meisterschaft5.jpg');


  texte := TStringList.create;
  texte.Add('Kneipenturnier');
  texte.Add('Anfängerturnier');
  texte.Add('Rummelringen');
  texte.Add('Sportcafeturnier');
  texte.Add('Proletenturnier');
  texte.Add('Semiproturnier');
  texte.Add('Profiturnier');
  texte.Add('Europameisterschaft');
  texte.Add('Weltmeisterschaft');
  texte.Add('Großmeisterturnier');
  texte.Add('Meisterschaft 1.Liga');
  texte.Add('Meisterschaft 2.Liga');
  texte.Add('Meisterschaft 3.Liga');
  texte.Add('Meisterschaft 4.Liga');
  texte.Add('Meisterschaft 5.Liga');
end;

destructor TPokaleMenuClass.destroy;
var
  i : integer;
begin
  for i := 0 to high(fsurfaces) do
  begin
    freeandnil(fsurfaces);
  end;
  freeandnil(rahmen);
  freeandnil(texte);
  inherited destroy;
end;

procedure TPokaleMenuClass.DrawMenuSpecific;
begin
  if cdspieler.TurnierKneipeSieg then
    fDXDraw.Surface.Draw(Koords[0].x,Koords[0].y,fsurfaces[0],false);
  if cdspieler.TurnierBeginnersCornerSieg then
    fDXDraw.Surface.Draw(Koords[1].x,Koords[1].y,fsurfaces[1],false);
  if cdspieler.TurnierRummelRingenSieg then
    fDXDraw.Surface.Draw(Koords[2].x,Koords[2].y,fsurfaces[2],false);
  if cdspieler.TurnierSportCafeTurnierSieg then
    fDXDraw.Surface.Draw(Koords[3].x,Koords[3].y,fsurfaces[3],false);
  if cdspieler.TurnierProletenClubSieg then
    fDXDraw.Surface.Draw(Koords[4].x,Koords[4].y,fsurfaces[4],false);
  if cdspieler.TurnierSemiProTurnier then
    fDXDraw.Surface.Draw(Koords[5].x,Koords[5].y,fsurfaces[5],false);
  if cdspieler.TurnierProfiturnierSieg then
    fDXDraw.Surface.Draw(Koords[6].x,Koords[6].y,fsurfaces[6],false);
  if cdspieler.TurnierEuropameisterschaftSieg then
    fDXDraw.Surface.Draw(Koords[7].x,Koords[7].y,fsurfaces[7],false);
  if cdspieler.TurnierWeltmeisterschaft then
    fDXDraw.Surface.Draw(Koords[8].x,Koords[8].y,fsurfaces[8],false);
  if cdspieler.TurnierMeisterTurnier then
    fDXDraw.Surface.Draw(Koords[9].x,Koords[9].y,fsurfaces[9],false);
  if cdspieler.Meisterschaften1>0 then
    fDXDraw.Surface.Draw(Koords[10].x,Koords[10].y,fsurfaces[10],false);
  if cdspieler.Meisterschaften2>0 then
    fDXDraw.Surface.Draw(Koords[11].x,Koords[11].y,fsurfaces[11],false);
  if cdspieler.Meisterschaften3>0 then
    fDXDraw.Surface.Draw(Koords[12].x,Koords[12].y,fsurfaces[12],false);
  if cdspieler.Meisterschaften4>0 then
    fDXDraw.Surface.Draw(Koords[13].x,Koords[13].y,fsurfaces[13],false);
  if cdspieler.Meisterschaften5>0 then
    fDXDraw.Surface.Draw(Koords[14].x,Koords[14].y,fsurfaces[14],false);

//  fDXDraw.Surface.Draw(Koords[itemnow].x-5,Koords[itemnow].y-5,fsurfaceRahmen);
  rahmen.Items[0].Draw(form1.DXDraw1.Surface,Koords[itemnow].x-5,Koords[itemnow].y-5,0);

  form1.DXPowerFont1.Font := 'Font1';
  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,370,440,centerstring(texte[itemnow],22));
end;

procedure TPokaleMenuClass.MouseDown(x,y:integer);
var
  i : integer;
begin
  for i := 0 to high(Koords) do
  begin
    if (x > Koords[i].x) and (x < Koords[i].X + fsurfaces[0].Width) and (y > Koords[i].y) and (y < Koords[i].Y+fsurfaces[0].height) then
    begin
      itemnow := i;
      break;
    end;
  end;
end;

{TNachSaisonMenuClass}
procedure TNachSaisonMenuClass.ButtonPress(bIndex:integer);
begin
  case bindex of
    0:  begin
          if goPokal then
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TPokaleMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end else
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end;
        end;
  end;
end;
               
constructor TNachSaisonMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  rang : integer;
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  rang := cdspieler.Rang;
  (Self.LabelConfigList[0] as TLabelConfig).fLabel := 'weiter';
  goPokal := false;
  (Self.LabelConfigList[4] as TLabelConfig).fLabel := ' ';
  (Self.LabelConfigList[5] as TLabelConfig).fLabel := ' ';

  if rang = 1 then
  begin
    goPokal := true;

    //Aufgestiegen
    (Self.LabelConfigList[1] as TLabelConfig).fLabel := centerstring('Sie haben die Meisterschaft in der ' + inttostr(cdspieler.liga) + '. Liga gewonnen.',52);

    (Self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
    (Self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';

    cdspieler.MeisterschaftGewonnen(cdspieler.Liga);

    if cdSpieler.liga > 1 then
    begin
      cdspieler.liga := cdspieler.Liga - 1;
      (Self.LabelConfigList[2] as TLabelConfig).y := (Self.LabelConfigList[2] as TLabelConfig).y + 50;
      (Self.LabelConfigList[3] as TLabelConfig).y := (Self.LabelConfigList[3] as TLabelConfig).y + 50;
      (Self.LabelConfigList[2] as TLabelConfig).fLabel := CenterString('Aufstieg',52);
      (Self.LabelConfigList[3] as TLabelConfig).fLabel := CenterString('Sie steigen damit in die ' + inttostr(cdspieler.liga) + '. Liga auf.' ,52);
    end;

  end else if (rang = 6) and (cdspieler.Liga < 5) then
  begin
    //Abgestiegen
    (Self.LabelConfigList[1] as TLabelConfig).fLabel := centerstring('Sie haben die Saison in der ' + inttostr(cdspieler.liga) + '. Liga mit dem',52);
    (Self.LabelConfigList[2] as TLabelConfig).fLabel := centerstring(inttostr(rang) + '. Platz' ,52);
    (Self.LabelConfigList[3] as TLabelConfig).fLabel := centerstring('abgeschlossen.',52);

    (Self.LabelConfigList[4] as TLabelConfig).fLabel := centerstring('Abstieg',52);
    (Self.LabelConfigList[5] as TLabelConfig).fLabel := centerstring('Als Letzter steigen Sie in die ' + inttostr(cdSpieler.Liga+1) + '. Liga ab.',52);
    cdSpieler.liga := cdspieler.liga+1;
  end else
  begin
    //Nix verändert
    (Self.LabelConfigList[1] as TLabelConfig).fLabel := centerstring('Sie haben die Saison in der ' + inttostr(cdspieler.liga) + '. Liga mit dem',52);
    (Self.LabelConfigList[2] as TLabelConfig).fLabel := centerstring(inttostr(rang) + '. Platz' ,52);
    (Self.LabelConfigList[3] as TLabelConfig).fLabel := centerstring('abgeschlossen.',52);

  end;


  //Neue Gegner erzeugen
  freeandnil(cdGegner);
  cdGegner := TGegner.Create(cdspieler.Liga);

  freeandnil(cdKampfsaison);
  cdKampfsaison := TKampfSaison.Create;

  cdspieler.Siege := 0;
  cdspieler.Niederlagen := 0;

  // Ende Saison
  // Abschlussbericht:
  //    Saisonende
  //    Sie haben den 4.Rang in der 3.Liga erreicht
  //    Sie haben die Meisterschaft in der 3.Liga gewonnen -> Pokal
  //
  //
  //Aufgestiegen/Abgestiegen/Nix ?
  //1.,2. aufsteigen
  //19.,20. absteigen nur in Liga 1 und 2
  //		Meisterschaften 1,2 oder 3 eventuell hochzählen
end;



{TNachRundeMenuClass}

procedure TNachRundeMenuClass.ButtonPress(bIndex:integer);
begin
  case bindex of
    0:  begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
        end;
  end;
end;


constructor TNachRundeMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  (Self.LabelConfigList[0] as TLabelConfig).fLabel := 'Rückrunde';
  (Self.LabelConfigList[1] as TLabelConfig).fLabel := centerstring('Sie haben die Hinrunde mit dem',52);
  (Self.LabelConfigList[2] as TLabelConfig).fLabel := centerstring(inttostr(cdspieler.Rang) + '. Rang' ,52);
  (Self.LabelConfigList[3] as TLabelConfig).fLabel := centerstring('abgeschlossen.',52);
end;


{TForm1}

procedure TForm1.FightDay; //Saison-Kampftag
begin
  Form1.NewMenu;
  Form1.fActiveMenu := TVorSaisonKampfMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'nachsaisonkampf'); {Neues Menüobjekt erzeugen}
  Form1.DXDraw1.restore; {Darstellung aktualisieren}
end;

procedure TForm1.AfterFight(weiterleitung:string;sieger:string;Gegner:TSportler);
var
  runde : integer;
  frunde,fwoche:integer;
begin
//"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
  FreeAndNil(fFight);

  //Weiterleitung
  if LowerCase(weiterleitung) = 'nachkneipenkampf' then
  begin
    Form1.NewMenu;
    Form1.fActiveMenu := TNachKneipenKampfMenuClass.Create(Form1.DXDraw1,Form1.dxs1,Gegner as TKneipengegner,sieger); {Neues Menüobjekt erzeugen}
    Form1.DXDraw1.restore; {Darstellung aktualisieren}
    exit;
  end else if LowerCase(weiterleitung) = 'nachturnierkampf' then
  begin
    Form1.NewMenu;
    Form1.fActiveMenu := TNachTurnierKampfMenuClass.Create(Form1.DXDraw1,Form1.dxs1,gegner,sieger); {Neues Menüobjekt erzeugen}
//    Form1.fActiveMenu := TTurnierStartMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}

    Form1.DXDraw1.restore; {Darstellung aktualisieren}
    exit;
  end else if LowerCase(weiterleitung) = 'nachsaisonkampf1' then
  begin
    if cdspieler.sponsor <> nil then
    begin
      cdSpieler.Kapital := cdspieler.Kapital + cdspieler.Sponsor.Geld;
    end;
    if (sieger = 'spieler') and (cdspieler.Sponsor <> nil)  then
    begin
      cdSpieler.Kapital := cdspieler.Kapital + cdspieler.Sponsor.sieggeld;
    end;


    fWoche := cdZeit.Woche-1;
    frunde := cdZeit.runde;

    if cdZeit.NextRound then
    begin
      fWoche := 5;
      if frunde = 1 then
        frunde := 2
      else frunde := 1;
    end;

    if sieger = 'spieler' then
    begin
      inc(cdSpieler.Siege);
      inc(cdSpieler.Siege_Alle);
      inc(gegner.Niederlagen);

      case frunde of
        1: begin//'Hinrunde';
              if cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K1_ID = 6 then
                cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := 6
              else
                cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K2_ID;
           end;
        2: begin//'Rückrunde';
              if cdKampfsaison.Rueckrunde[fwoche].Kaempfe[fSpielerKampfIndex].K1_ID = 6 then
                cdKampfsaison.Rueckrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := 6
              else
                cdKampfsaison.Rueckrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K2_ID;
           end;
      end;

    end else
    begin
      inc(cdSpieler.Niederlagen);
      inc(cdSpieler.Niederlagen_Alle);
      inc(gegner.siege);

      case frunde of
        1: begin//'Hinrunde';
              if cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K1_ID = 6 then
                cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K2_ID
              else
                cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K1_ID;
           end;
        2: begin//'Rückrunde';
              if cdKampfsaison.Rueckrunde[fwoche].Kaempfe[fSpielerKampfIndex].K1_ID = 6 then
                cdKampfsaison.Rueckrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K2_ID
              else
                cdKampfsaison.Rueckrunde[fwoche].Kaempfe[fSpielerKampfIndex].SiegerID := cdKampfsaison.Vorrunde[fwoche].Kaempfe[fSpielerKampfIndex].K1_ID;
           end;
      end;

    end;

    cdspieler.MieteZahlen;


    Form1.NewMenu;
    Form1.fActiveMenu := TNachSaisonKampf1MenuClass.Create(Form1.DXDraw1,Form1.dxs1,gegner, sieger); {Neues Menüobjekt erzeugen}
    Form1.DXDraw1.restore; {Darstellung aktualisieren}
    exit;
  end;
end;

procedure TForm1.AfterTrain(Treffer,MaxTreffer,MaxKraft,KraftAusd:integer);
begin
  FreeAndNil(fTrain);
  Form1.NewMenu;
  Form1.fActiveMenu := TNachTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1,Treffer,MaxTreffer,MaxKraft,Kraftausd); {Neues Menüobjekt erzeugen}
  Form1.DXDraw1.restore; {Darstellung aktualisieren}
end;

procedure TForm1.CheckEreignisse; // Alle Szenen auf Ereignisse prüfen und Meldungen abgeben
begin
  cdEreignisse.DeleteAllEreignisse;

  //Findet morgen ein Turnier statt?
  if (cdTurniere.MorgenTurnier <> -1) and ((cdTurniere.fTurniere[cdTurniere.MorgenTurnier] as TTurnier).Angemeldet=true) then
  begin
    cdEreignisse.AddEreignis('''' + (cdTurniere.fTurniere[cdTurniere.MorgenTurnier] as TTurnier).Bezeichnung + '''' +  ' findet morgen statt.',1);
  end;

  cdSponsoren.CheckSponsoren;
  cdSpieler.CheckSpieler;
  cdSportshop.CheckSportShop;
  cdKneipe.CheckKneipe;
  cdTurniere.CheckTurniere;
end;

function TForm1.CenterString(text:string;MaxLength:integer):string;
var
  nameCount : integer;
  diff : integer;
  i : integer;
begin
  result := text;
  nameCount := length(Text);
  if nameCount < MaxLength then
  begin
    diff := (MaxLength - nameCount) div 2;
    for i := 1 to diff do
    begin
      result := ' ' + result + ' ';
    end;
  end;
  if length(result) > MaxLength then result := copy(result,1,MaxLength);
  if length(result) < MaxLength then result := result + ' ';
end;

function TForm1.GetTripleString(Zahl:string):string;
var
  temp : integer;
begin
  temp := strtoint(zahl);
  result := inttostr(temp);

  if temp > -1 then
  begin
    if length(zahl) < 2 then result := '0' + result;
    if length(Zahl) < 3 then result := '0' + result;
  end else
  begin
    if length(Zahl) = 2 then result := '-0'+copy(result,2,1);
  end;
//  if temp < 10 then result := '0' + result;
//  if temp < 100 then result := '0' + result;
end;

function TForm1.MakeStringLeft(text:string;laenge:integer):string;
begin
  while length(text) < laenge do
  begin
    text := text + ' ';
  end;
  if length(text) > laenge then text := copy(text,1,laenge);
  result := text;
end;

function TForm1.MakeStringRight(text:string;laenge:integer):string;
begin
  while length(text) < laenge do
  begin
    text := ' ' + text;
  end;
  if length(text) > laenge then text := copy(text,1,laenge);
  result := text;
end;

function TForm1.StringToDoppel(Zahl:string):string;
var
  temp : integer;
begin
  temp := strtoint(zahl);
  if temp < 10 then
    result := '0' + inttostr(temp)
  else
    result := inttostr(temp);
end;

function TForm1.IncString(temp:string):string;
var
  zahl : integer;
begin
  zahl := strtoint(temp);
  inc(zahl);
  if zahl < 10 then
    result := '0' + inttostr(zahl)
  else
    result := inttostr(zahl);
end;

function TForm1.DecString(temp:string):string;
var
  zahl : integer;
begin
  zahl := strtoint(temp);
  dec(zahl);
  if zahl < 10 then
    result := '0' + inttostr(zahl)
  else
    result := inttostr(zahl);
end;

procedure TForm1.fadeit(Picture:TPicture);
var
  c: Integer;
  dxdib1:TDXDIB;
  Background:TDXDIB;
  SStart : DWORD;
  SEnd : DWORD;
  sAll : DWORD;
begin
  // Geschwindigkeit ändern mit Form1.FadeSpeed
  dxDIB1 := TDXDib.Create(dxdraw1);
  Background := TDXDIB.Create(dxdraw1);
  Background.DIB.Assign(Picture);
  try
    Closing := True;
    Application.ProcessMessages;
    Closing := False;

    DXDIB1.DIB.SetSize(Background.DIB.Width,Background.DIB.Height,Background.DIB.BitCount);
    FillDIB8(DXDIB1.DIB,255);
    c:=0;
    while c < 255-fadespeed do begin
      sStart := GetTickCount;
      FadeIn(BackGround.DIB,DXDIB1.DIB,c);
      if DXDraw1.CanDraw then begin
        DXDraw1.Surface.Assign(DXDIB1.DIB);
//        dxdraw.release;
        DXDraw1.Flip;
      end;
      Application.ProcessMessages;
      if Closing then Exit;

//      sEnd := GetTickCount;
//      sAll := sEnd - sStart;
//      if SAll*30 < 500 then
//      begin
//        sleep(500 - sAll*30);
////        if fadespeed > 4 then dec(FadeSpeed,3);
//      end else
//      begin
//        if fadespeed < 200 then inc(FadeSpeed,3);
//      end;

      inc(c,FadeSpeed);
      //sleep(fSleepValue);
    end;
  finally
    freeandnil(Background);
    freeandnil(dxdib1);
  end;
end;

procedure TForm1.fadeItOut(Picture:TPicture);
var
  c: Integer;
  dxdib1:TDXDIB;
  Background:TDXDIB;
  SStart : DWORD;
  SEnd : DWORD;
  sAll : DWORD;
begin
  dxDIB1 := TDXDib.Create(dxdraw1);
  Background := TDXDIB.Create(dxdraw1);
  Background.DIB.Assign(Picture);
  try
    Closing := True;
    Application.ProcessMessages;
    Closing := False;

    DXDIB1.DIB.SetSize(Background.DIB.Width,Background.DIB.Height,Background.DIB.BitCount);
    FillDIB8(DXDIB1.DIB,0);
    c:=255;
    while c > FadeSpeed do begin
      sStart := GetTickCount;

      FadeOut(BackGround.DIB,DXDIB1.DIB,c);
      if DXDraw1.CanDraw then begin
        DXDraw1.Surface.Assign(DXDIB1.DIB);
//        dxdraw.release;
        DXDraw1.Flip;
      end;
      Application.ProcessMessages;
      if Closing then Exit;

//      sEnd := GetTickCount;
//      sAll := sEnd - sStart;
//      if SAll*30 < 500 then
//      begin
//        sleep(500 - sAll*30);
//      end else
//      begin
//        if fadespeed < 200 then inc(FadeSpeed,3);
//      end;

      dec(c,FadeSpeed);

    end;
  finally
    freeandnil(Background);
    freeandnil(dxdib1);
  end;
end;

procedure TForm1.FadeOut(DIB1,DIB2: TDIB; Step: Byte);
var
  P1,P2: PByteArray;
  W,H: Integer;
begin
  P1 := DIB1.ScanLine[DIB2.Height-1];
  P2 := DIB2.ScanLine[DIB2.Height-1];
  W := DIB1.WidthBytes;
  H := DIB1.Height;
  asm
    PUSH ESI
    PUSH EDI
    MOV ESI, P1
    MOV EDI, P2
    MOV EDX, W
    MOV EAX, H
    IMUL EDX
    MOV ECX, EAX
    @@1:
    MOV AL, Step
    MOV AH, [ESI]
    CMP AL, AH
    JA @@2
    MOV AL, AH
@@2:
    MOV [EDI], AL
    INC ESI
    INC EDI
    DEC ECX
    JNZ @@1
    POP EDI
    POP ESI
  end;
end;

procedure TForm1.FadeIn(DIB1,DIB2: TDIB; Step: Byte);
var
  P1,P2: PByteArray;
  W,H: Integer;
begin
  P1 := DIB1.ScanLine[DIB2.Height-1];
  P2 := DIB2.ScanLine[DIB2.Height-1];
  W := DIB1.WidthBytes;
  H := DIB1.Height;
  asm
    PUSH ESI
    PUSH EDI
    MOV ESI, P1
    MOV EDI, P2
    MOV EDX, W
    MOV EAX, H
    IMUL EDX
    MOV ECX, EAX
    @@1:
    MOV AL, Step
    MOV AH, [ESI]
    CMP AL, AH
    JB @@2
    MOV AL, AH
@@2:
    MOV [EDI], AL
    INC ESI
    INC EDI
    DEC ECX
    JNZ @@1
    POP EDI
    POP ESI
  end;
end;

procedure TForm1.FillDIB8(DIB: TDIB; Color: Byte);
var
  P: PByteArray;
  W,H: Integer;
begin
  P := DIB.ScanLine[DIB.Height-1];
  W := DIB.WidthBytes;
  H := DIB.Height;
  asm
    PUSH ESI
    MOV ESI, P
    MOV EDX, W
    MOV EAX, H
    IMUL EDX
    MOV ECX, EAX
    MOV AL, Color
    @@1:
    MOV [ESI], AL
    INC ESI
    DEC ECX
    JNZ @@1
    POP ESI
  end;
end;



function TForm1.GetVerzImages;
begin
  result := extractfilepath(application.exename) + '\images\'
end;


{ Menü-Funktionalität }

procedure TForm1.NewMenu;
var
	i : Integer;
begin
  try
//    FShowEdit := false;
    //FEdit.Visible := false;
  //  for i := Low(Form1.fActiveMenu.fAnims) to High(Form1.fActiveMenu.fAnims) do
  //  begin
  //    Form1.fActiveMenu.fAnims[i].Dead; {Speicherfreigabe für Menü-Animationen}
  //  end;

    if not (factivemenu is TMainMenuClass) then PlayMenuChange;

    if form1.fActiveMenu <> nil then
    begin
      freeandnil(Form1.fActiveMenu); {Hauptmenüobjekt freigeben}
    end;
    
    FDoFire := false;
  except
    on e:exception do
      showmessage('Main->NewMenu: ' + e.message);
  end;
end;


procedure TTurnierStartMenuClass.ButtonPress(bIndex:integer);
var
  i : integer;
begin
//  case bIndex of
//    0: begin
//          for i := 0 to self.LabelConfigList.Count - 1 do
//          begin
//            (self.LabelConfigList[i] as TLabelConfig).Y := (self.LabelConfigList[i] as TLabelConfig).Y - 10;
//          end;
//       end;
//  end;
end;

procedure TTurnierStartMenuClass.DrawMenuSpecific;
var
  i : integer;
  destRect : TRect;
  sourceRect : TRect;
  counter : integer;
  lx1,lx2,lx3 : integer;
  ly1,ly2,ly3 : integer;
begin
{
  tud_unten.jpg 0,600
  tud_scroller_normal, hoch, runter, links, rechts   30,630         w=140, h=108

  tud_abbrechen1/2 250, 650     w=308  h=70
  tud_nextRound1/2 610, 650
}

  //Label-Kästchen malen
  case scroller of
    1:if (self.LabelConfigList[0] as TLabelConfig).X > round(100/1.28) then gx := 0; //links
    2:if (self.LabelConfigList[labelconfiglist.Count-1] as TLabelConfig).X < round(600/1.28) then gx := 0; //rechts
    3:if (self.LabelConfigList[0] as TLabelConfig).y > round(100/1.28) then gy := 0; //oben
    4:if (self.LabelConfigList[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AnzahlGegner -1] as TLabelConfig).Y < round(400/1.28) then gy := 0; //unten
  end;

  for i := 0 to self.LabelConfigList.count - 1 do
  begin
    fposition := fposition + gx; //Fehlerbeseitígung ungewünschte Verbindungslinie
    (self.LabelConfigList[i] as TLabelConfig).X := (self.LabelConfigList[i] as TLabelConfig).X + gx;
    (self.LabelConfigList[i] as TLabelConfig).y := (self.LabelConfigList[i] as TLabelConfig).y + gy;

    destRect.Left := (self.LabelConfigList[i] as TLabelConfig).X - 5;
    destRect.Top := (self.LabelConfigList[i] as TLabelConfig).Y - 7;
    destRect.Right :=(self.LabelConfigList[i] as TLabelConfig).X - 5 + round(420/1.28);
    destRect.Bottom := (self.LabelConfigList[i] as TLabelConfig).Y + round(45/1.28);

    sourceRect.Left := 0;
    sourceRect.Top := 0;
    sourceRect.Right := fsurfacerahmen.Width;
    sourceRect.Bottom := fsurfacerahmen.height;

    //fdxdraw.Surface.DrawAlpha(destRect,sourceRect,fsurfacerahmen,true,250);
    //fdxdraw.Surface.Draw(destrect.left,destrect.Top,fsurfacerahmen,true);
    ImageList.Items[0].Draw(fDXDraw.surface,destrect.Left,destrect.top,0);
  end;

  //form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,10,10,inttostr(fposition));

  //Verbindungen zeichnen
  counter := 0;
  turboLock(form1.DXDraw1.Surface);

  for i := 0 to ((self.LabelConfigList.count-1) div 2)-1 do
  begin
    //Unerwünschte Verbindungen ausblenden
    if (i >= ((self.LabelConfigList.count-1) div 2)-1) and (fposition > -3500) then continue;

    if (cdTurniere.fTurniere[cdTurniere.heuteturnier] as TTurnier).AnzahlGegner = 31 then
    begin
      if (i >= ((self.LabelConfigList.count-1) div 2)-3) and (fposition > -7700) then continue;
      if (i >= ((self.LabelConfigList.count-1) div 2)-1) and (fposition > -20000) then continue;
    end;
    //----------------------------------




    //vertikale Verbindungen
    lx1 := (((self.LabelConfigList[counter+1] as TLabelConfig).X))+160;
    ly1 := (self.LabelConfigList[counter] as TLabelConfig).Y+30;
    ly2 := (self.LabelConfigList[counter+1] as TLabelConfig).Y-10;
    turboLine16(lx1,ly1,lx1,ly2,20,20,200);

    //horizontale Verbindungen
    if i = ((self.LabelConfigList.count-1) div 2)-1 then
    begin
      lx1 := (((self.LabelConfigList[counter+1] as TLabelConfig).X)+160);
      lx2 := lx1 + 35;
      ly1 := (ly1+ly2) div 2 + 17; //(self.LabelConfigList[counter] as TLabelConfig).Y+130;
    end else
    begin
      lx1 := (((self.LabelConfigList[counter+1] as TLabelConfig).X)+160);
      lx2 := lx1 + 80;
      ly1 := (ly1+ly2) div 2; //(self.LabelConfigList[counter] as TLabelConfig).Y+130;
    end;
    turboLine16(lx1,ly1,lx2,ly1,20,20,200);

    inc(counter,2);
  end;
  turbounlock;


  //Interface malen
  fDXDraw.Surface.Draw(0,round(720/1.28),fsurfaceUnten);
  fDXDraw.Surface.Draw(0,round(600/1.28),fsurfaceUnten);

  //Buttons malen
  if not abbrechenOver then
    fDXDraw.Surface.Draw(round(250/1.28),round(650/1.28),fsurfaceAbbrechen1)
  else
    fDXDraw.Surface.Draw(round(250/1.28),round(650/1.28),fsurfaceAbbrechen2);

  if not nextRoundOver then
    fDXDraw.Surface.Draw(round(610/1.28),round(650/1.28),fsurfacenext1)
  else
    fDXDraw.Surface.Draw(round(610/1.28),round(650/1.28),fsurfacenext2);

  //Scroller malen
  case scroller of
    0:fDXDraw.Surface.Draw(round(30/1.28),round(635/1.28),fsurfaceScroller_normal);
    1:fDXDraw.Surface.Draw(round(30/1.28),round(635/1.28),fsurfaceScroller_links);
    2:fDXDraw.Surface.Draw(round(30/1.28),round(635/1.28),fsurfaceScroller_rechts);
    3:fDXDraw.Surface.Draw(round(30/1.28),round(635/1.28),fsurfaceScroller_hoch);
    4:fDXDraw.Surface.Draw(round(30/1.28),round(635/1.28),fsurfaceScroller_runter);
  end;

end;

procedure TForm1.TurnierVorbei;
var
  test : integer;
begin
//    fAngemeldeteTurniere
//  test := (cdTurniere.fTurniere[1] as TTurnier).ID;

//  cdTurniere.fTurniere.Extract(cdTurniere.fTurniere[1]);
//  freeandnil(cdTurniere);
//  cdTurniere := TTurniere.create;

  (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).reset;

  Form1.NewMenu;
  Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
  Form1.DXDraw1.restore; {Darstellung aktualisieren}
end;

procedure TTurnierStartMenuClass.MouseDown(x,y:integer);
var
  i,j : integer;
  scroll : integer;
  Counter : integer;
  GegnerID1, GegnerID2 : integer;
  Name1, Name2 : string;
  test : integer;
begin //nachTurnierkampf
    //Scrolling
  scroll := 10;
  gx := 0;
  gy := 0;
  case scroller of
    1:  begin //links
          gx := scroll;
        end;

    2:  begin //rechts
          gx := -scroll;
        end;

    3:  begin //hoch
          //if (self.LabelConfigList[0] as TLabelConfig).Y < fdxdraw.Display.Height-100 then
          gy := scroll;
        end;

    4:  begin //runter
          //if (self.LabelConfigList[0] as TLabelConfig).Y > 50
          gy := -scroll;
        end;
  end;

  //Mouse Over Abbrechen
  if abbrechenOver then
  begin
    //freeandnil(cdTurniere.fturniere);
    //cdTurniere := TTurniere.create;
//    cdTurniere.fTurniere.Delete(1);

    form1.PlayUpDown;
    form1.TurnierVorbei;
    exit;
  end;

  //Mouse Over NextRound
  if nextRoundOver then
  begin
    form1.PlayUpDown;
    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde > high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) then
    begin
      //exit;
    end;

//    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde = high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) then
//    begin // Letzte Runde
//     //
//    end else
//    begin

      if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde = high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) then
      begin
       (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).lastround := true;
      end;

      (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).BerechneKaempfe;

      Counter := 0;
      for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) do
      begin
        for j := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen) do
        begin
          //Daten holen
          GegnerID1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen[j].X;
          GegnerID2 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen[j].Y;

//          if ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].ID = 99) or ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].ID = 99) then
//          begin
//            inc(counter,2);
//            continue;
//          end;

          if (GegnerID1 <> -1) then
            Name1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].Vorname + ' ' + (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].Name + ' Lv' + inttostr((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].level)
          else
            name1 := '?';

          if (GegnerID2 <> -1) then
            Name2 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].Vorname + ' ' + (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].Name + ' Lv' + inttostr((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].level)
          else
            name2 := '?';

          (self.LabelConfigList[Counter] as TLabelConfig).fLabel := form1.CenterString(Name1,30);
          (self.LabelConfigList[Counter+1] as TLabelConfig).fLabel := form1.CenterString(Name2,30);

          inc(Counter,2);
        end;
//      end;

      //Spielerkampf beginnt
      //-> Turnierdaten speichern -> centraldata -> TTurnierStartDaten = class
      //-> FormFunktion aufrufen
      //Spielerkampf
      //nachkampf
      //turnierweiter
//      Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].X].ID = 99

    end;

    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde = high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) then
    begin

      GegnerID1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden)].Begegnungen[0].z;
      if GegnerID1 <> -1 then
      begin
        Name1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].Vorname + ' ' + (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].Name;
        (self.LabelConfigList[labelconfiglist.Count-2] as TLabelConfig).fLabel := CenterString(Name1,21);
      end;
      //Turnier zu Ende
    end;

    form1.TurnierPlayerFight;
  end;

end;

procedure TForm1.TurnierPlayerFight;
var
  i : integer;
  aktuellerunde : integer;
  id1,id2 : integer;
  gegner:TSportler;
begin
  //cdTurniere.saveTurnierState;
  if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).lastround then
  begin
    aktuelleRunde := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).aktuellerunde;
  end else
  begin
    aktuelleRunde := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).aktuellerunde-1;
  end;

  gegner := nil;
  for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[aktuelleRunde].Begegnungen) do
  begin
    id1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[aktuelleRunde].Begegnungen[i].x;
    id2 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[aktuelleRunde].Begegnungen[i].y;

    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[ID1].IstSpieler then
    begin
      gegner := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[ID2];
      break;
    end;

    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[ID2].istspieler then
    begin
      gegner := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[ID1];
      break;
    end;
  end;

  if gegner = nil then exit;

  form1.NewMenu;
  form1.fActiveMenu := TVorKampfAllgemeinMenuClass.create(form1.DXDraw1,form1.dxs1, gegner,'nachturnierkampf');
  //form1.fFight := TKampf.create(form1.DXDraw1, gegner,'nachturnierkampf');
  form1.DXDraw1.Restore;
end;

procedure TTurnierStartMenuClass.MouseUp;
begin
  gx := 0;
  gy := 0;
end;

procedure TTurnierStartMenuClass.MouseOver(x,y:integer);
begin
{
  tud_unten.jpg 0,600
  tud_scroller_normal, hoch, runter, links, rechts   30,630         w=40, h=30

  tud_abbrechen1/2 250, 650     w=308  h=70
  tud_nextRound1/2 610, 650
}

  abbrechenOver := false;
  nextroundOver := false;
  Scroller := 0;


  //Buttons
  if (x > round(250/1.28)) and (x < round(250/1.28) + round(308/1.28)) and (y > round(650/1.28)) and (y < round(650/1.28)+round(70/1.28)) then
  begin
    abbrechenOver := true;
    //fDXDraw.Surface.Draw(250,650,fsurfaceAbbrechen2);
  end;

  if (x > round(610/1.28)) and (x < round(610/1.28) + round(308/1.28)) and (y > round(650/1.28)) and (y < round(650/1.28)+round(70/1.28)) then
  begin
    nextroundOver := true;
    //fDXDraw.Surface.Draw(610,650,fsurfacenext2);
  end;

  //Scroller
  //links
  if (x > round(40/1.28)) and (x < round(40/1.28)+round(40/1.28)) and (y > round(670/1.28)) and (y < round(670/1.28)+round(30/1.28)) then
  begin
    Scroller := 1;
    //fDXDraw.Surface.Draw(30,630,fsurfaceScroller_links);
  end;

  //rechts
  if (x > round(120/1.28)) and (x < round(120/1.28)+round(40/1.28)) and (y > round(670/1.28)) and (y < round(670/1.28)+round(30/1.28)) then
  begin
    Scroller := 2;
//    fDXDraw.Surface.Draw(30,630,fsurfaceScroller_rechts);
  end;

  //hoch
  if (x > round(80/1.28)) and (x < round(80/1.28)+round(30/1.28)) and (y > round(640/1.28)) and (y < round(640/1.28)+round(40/1.28)) then
  begin
    Scroller := 3;
//    fDXDraw.Surface.Draw(30,630,fsurfaceScroller_hoch);
  end;

  //runter
  if (x > round(80/1.28)) and (x < round(80/1.28)+round(30/1.28)) and (y > round(690/1.28)) and (y < round(690/1.28)+round(40/1.28)) then
  begin
    Scroller := 4;
//    fDXDraw.Surface.Draw(30,630,fsurfaceScroller_runter);
  end;

end;

destructor TTurnierStartMenuClass.destroy;
begin
  freeandnil(fsurfaceUnten);// : TDirectDrawSurface;
  freeandnil(fsurfaceAbbrechen1);// : TDirectDrawSurface;
  freeandnil(fSurfaceAbbrechen2);// : TDirectDrawSurface;
  freeandnil(fSurfaceNext1);// : TDirectDrawSurface;
  freeandnil(fSurfaceNext2);// : TDirectDrawSurface;
  freeandnil(fsurfaceScroller_normal);// : TDirectDrawSurface;
  freeandnil(fsurfaceScroller_links);// : TDirectDrawSurface;
  freeandnil(fsurfaceScroller_rechts);// : TDirectDrawSurface;
  freeandnil(fsurfaceScroller_hoch);// : TDirectDrawSurface;
  freeandnil(fsurfaceScroller_runter);// : TDirectDrawSurface;
  freeandnil(fSurfaceRahmen); // ist obsolet
  freeandnil(ImageList); // Momentag nur für SurfaceRahmen
end;

constructor TTurnierStartMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
  j : integer;
  AktuelleRunde : integer;
  GegnerID1,GegnerID2 : integer;
  Name1, Name2 : string;
  siegerID : integer;
  siegername : string;
  dynamisch : integer;
  go : integer;
  YAb : array of array of integer;
  dyn1,dyn2 : integer;
  dyn1Go : integer;
  lastX, lastY : integer;
begin
{
  tud_unten.jpg 0,600
  tud_scroller_normal, hoch, runter, links, rechts   30,630         w=140, h=108

  tud_abbrechen1/2 250, 650     w=308  h=70
  tud_nextRound1/2 610, 650
}

  inherited create(form1.DXDraw1,form1.dxs1);

  fPosition := 0;

  fAbstand := round(100/1.28);
  gX := 0;
  gY := 0;

  ImageList := TDXImageList.Create(form1.dxdraw1);

  fsurfaceUnten := TDirectDrawSurface.Create(form1.DXDraw1.DDraw);
  fsurfaceAbbrechen1 := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fSurfaceAbbrechen2 := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fSurfaceNext1 := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fSurfaceNext2 := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fsurfaceScroller_normal := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fsurfaceScroller_links := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fsurfaceScroller_rechts := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fsurfaceScroller_hoch := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fsurfaceScroller_runter := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fSurfaceRahmen := TDirectDrawSurface.Create(form1.dxdraw1.DDraw);
  fSurfaceRahmen.TransparentColor := $FF00FF;

  fsurfaceUnten.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_unten.jpg');
  fsurfaceAbbrechen1.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_abbrechen1.jpg');
  fSurfaceAbbrechen2.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_abbrechen2.jpg');
  fSurfaceNext1.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_nextround1.jpg');
  fSurfaceNext2.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_nextround2.jpg');
  fsurfaceScroller_normal.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_scroller_normal.jpg');
  fsurfaceScroller_links.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_scroller_links.jpg');
  fsurfaceScroller_rechts.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_scroller_rechts.jpg');
  fsurfaceScroller_hoch.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_scroller_hoch.jpg');
  fsurfaceScroller_runter.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_scroller_runter.jpg');
  fSurfaceRahmen.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_auswahl_rahmen.bmp');

  ImageList.DXDraw := form1.dxdraw1;
  ImageList.Items := TPictureCollection.Create(form1.dxdraw1);
  ImageList.Items.Add;
  ImageList.Items[0].Picture.LoadFromFile(ExtractFilePath(Application.exename)+ 'images\tud_auswahl_rahmen.bmp');
  ImageList.Items[0].Transparent := true;
  ImageList.Items[0].TransparentColor := $FF00FF;

//  // Y-Positionen berechnen
//  setLength(YAb,length((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden));
//  dyn1 := 0;
//  dyn2 := round(100/1.28);
//  dyn1Go := 0;
//  for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) do
//  begin
//    setLength(YAb[i],length((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen) * 2);
//    for j := 0 to high(YAb[i]) do
//    begin
//      YAb[i][j] := round(50/1.28) + dyn1 + j*dyn2;
//    end;
//
//    dyn1Go := dyn1Go * 2;
//    dyn1 := dyn1 + dyn1Go;
//    dyn2 := dyn2 * 2;
//    if i = 0 then
//    begin
//      dyn1 := round(50/1.28);
//      dyn1Go := round(50/1.28);
//    end;
//  end;


  // Y-Positionen berechnen
  setLength(YAb,length((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden));
  dyn1 := 0;
  dyn2 := round(200/1.28);
  dyn1Go := 0;
  for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) do
  begin
    setLength(YAb[i],length((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen) * 2);
    for j := 0 to high(YAb[i]) do
    begin
      YAb[i][j] := round(50/1.28) + dyn1 + j*dyn2;
    end;

    dyn1Go := dyn1Go * 2;
    dyn1 := dyn1 + dyn1Go;
    dyn2 := dyn2 * 2;
    if i = 0 then
    begin
      dyn1 := round(100/1.28);
      dyn1Go := round(100/1.28);
    end;
  end;

//(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde].Begegnungen
  AktuelleRunde := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde;
  go := 100;
  for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden) do
  begin
    dynamisch := 0;
    for j := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen) do
    begin
      //Daten holen
      GegnerID1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen[j].X;
      GegnerID2 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[i].Begegnungen[j].Y;

      if (GegnerID1 <> -1) and (GegnerID2 <> -1) then
      begin
        Name1 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].Vorname + ' ' + (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].Name + ' Lv' + inttostr((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID1].level);
        Name2 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].Vorname + ' ' + (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].Name + ' Lv' + inttostr((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[GegnerID2].level);
      end else
      begin
        name1 := '?';
        name2 := '?';
      end;

      //Daten malen
      self.LabelConfigList.Add(TLabelConfig.create('news',form1.CenterString(Name1,30),round(50/1.28)+i*round(400/1.28),Yab[i][dynamisch]));
      self.LabelConfigList.Add(TLabelConfig.create('news',form1.CenterString(Name2,30),round(50/1.28)+i*round(400/1.28),Yab[i][dynamisch+1]));
      inc(dynamisch,2);
    end;
    go := go * 2;
  end;

  lastX := (self.labelConfiglist[labelconfiglist.count-1] as TLabelConfig).X + round(600/1.28);
  lastY := round((((self.labelConfiglist[labelconfiglist.count-1] as TLabelConfig).Y + (self.labelConfiglist[labelconfiglist.count-2] as TLabelConfig).Y) / 2) * 1.28);

//  lastY := round((self.labelConfiglist[self.labelconfiglist.count-1] as TLabelConfig).Y * 1.28);


  self.LabelConfigList.Add(TLabelConfig.create('mittel',form1.CenterString('?',22),lastX,lastY+20));
  self.LabelConfigList.Add(TLabelConfig.create('mittel',form1.CenterString('Turniersieger',21),lastX,lastY-45));

  //Positionen anpassen
  if (cdTurniere.fTurniere[cdTurniere.heuteturnier] as TTurnier).AnzahlGegner = 31 then
  begin
    (self.LabelConfigList[labelconfiglist.Count-1] as TLabelConfig).X := (self.LabelConfigList[labelconfiglist.Count-1] as TLabelConfig).X + 52;
    (self.LabelConfigList[labelconfiglist.Count-2] as TLabelConfig).X := (self.LabelConfigList[labelconfiglist.Count-2] as TLabelConfig).X + 52;
  end;



//  for i := 0 to 31 do
//  begin
//    self.LabelConfigList.Add(TLabelConfig.create('big','Sportler'+inttostr(i),100,10+i*fAbstand,dxdraw));
//    (self.LabelConfigList[i] as TLabelConfig).fLabel := form1.CenterString((self.LabelConfigList[i] as TLabelConfig).fLabel,21);
//  end;
//
//  for i := 0 to 15 do
//  begin
//    self.LabelConfigList.Add(TLabelConfig.create('big','Sportleraaaaaaaaaaaavvbnpoiuzt'+inttostr(i),400,60+i*fAbstand,dxdraw));
//  end;

end;


constructor TPSEigenschaftenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
begin
  try
    inherited create(dxdraw,engine);
    for i := 1 to 5 do
    begin
      (self.LabelConfigList[i] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[i] as TLabelConfig).fLabel,17);
    end;
    (self.LabelConfigList[18] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[18] as TLabelConfig).fLabel,17);
    (self.LabelConfigList[19] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[19] as TLabelConfig).fLabel,17);
    (self.LabelConfigList[21] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[21] as TLabelConfig).fLabel,17);
    (self.LabelConfigList[20] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[20] as TLabelConfig).fLabel,17);
    (self.LabelConfigList[6] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[6] as TLabelConfig).fLabel,17);
    (self.LabelConfigList[7] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[7] as TLabelConfig).fLabel,17);


    (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.GetTripleString(inttostr(cdSpieler.fLevelupPoints));
    (self.LabelConfigList[8] as TLabelConfig).fLabel := inttostr(cdSpieler.level);
    (self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.Alter);
    (self.LabelConfigList[10] as TLabelConfig).fLabel := inttostr(cdSpieler.GetMaximalkraft) + '/' + inttostr(cdSpieler.Maximalkraft);
    (self.LabelConfigList[11] as TLabelConfig).fLabel := inttostr(cdSpieler.GetKraftausdauer) + '/' + inttostr(cdSpieler.Kraftausdauer);
    (self.LabelConfigList[12] as TLabelConfig).fLabel := inttostr(cdSpieler.Fitness) + '/'+inttostr(cdSpieler.FitnessMaximum);
//    (self.LabelConfigList[21] as TLabelConfig).fLabel := 'Regenerationsrate: ';
    (self.LabelConfigList[22] as TLabelConfig).fLabel := inttostr(cdspieler.regenerationsrate) + '%';

    //(self.LabelConfigList[21] as TLabelConfig).fLabel := '/'+inttostr(cdSpieler.FitnessMaximum);
    //(self.LabelConfigList[21] as TLabelConfig).X := length((self.LabelConfigList[12] as TLabelConfig).fLabel)*14 + (self.LabelConfigList[12] as TLabelConfig).x;
    //(self.LabelConfigList[21] as TLabelConfig).y := (self.LabelConfigList[12] as TLabelConfig).y;

    (self.LabelConfigList[13] as TLabelConfig).fLabel := inttostr(cdSpieler.GetTechnik);

    if cdspieler.Level = 30 then
    begin
      (self.LabelConfigList[14] as TLabelConfig).fLabel := 'Großmeister'; //inttostr(cdSpieler.Erfahrung); //Erfahrung
      (self.LabelConfigList[15] as TLabelConfig).fLabel := 'Großmeister'; //inttostr(cdSpieler.GetNextLevelUpExperience); //Erfahrung für nächsten LevelUp
    end else
    begin
      (self.LabelConfigList[14] as TLabelConfig).fLabel := inttostr(cdSpieler.Erfahrung); //Erfahrung
      (self.LabelConfigList[15] as TLabelConfig).fLabel := inttostr(cdSpieler.GetNextLevelUpExperience); //Erfahrung für nächsten LevelUp
    end;

    (self.LabelConfigList[16] as TLabelConfig).fLabel := inttostr(cdSpieler.Ansehen); //Ansehen
    (self.LabelConfigList[17] as TLabelConfig).fLabel := MakeStringRight(cdSpieler.Vorname,20); //Name
  except
    on e:exception do
      showmessage('Main->TPSEigenschaftenMenuClass->Create: ' + e.message);
  end;
end;

procedure TPSEigenschaftenMenuClass.ButtonPress(bIndex:integer);
begin
  case bIndex of
    0: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSSpecialMovesMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    1: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSAusruestungsMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    2: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSStatistikMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    3: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;

    4: begin //hoch
          if strtoint((self.LabelConfigList[0] as TLabelConfig).fLabel) > 0 then
          begin
            form1.PlayUpDown;
            inc(cdSpieler.FitnessMaximum);
            dec(cdSpieler.fLevelUpPoints);
            cdspieler.Fitness := cdspieler.FitnessMaximum;


//            (self.LabelConfigList[21] as TLabelConfig).fLabel := '/'+inttostr(cdSpieler.FitnessMaximum);

            (self.LabelConfigList[12] as TLabelConfig).fLabel := inttostr(cdSpieler.Fitness) + '/'+inttostr(cdSpieler.FitnessMaximum);
            (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.GetTripleString(inttostr(cdSpieler.fLevelUpPoints));
//            (self.LabelConfigList[16] as TLabelConfig).X := length((self.LabelConfigList[12] as TLabelConfig).fLabel)*18;
          end else
          begin
            form1.PlayNo;
          end;
       end;
//    5: begin //runter
//          if strtoint((self.LabelConfigList[12] as TLabelConfig).fLabel) > 0 then
//          begin
//            (self.LabelConfigList[12] as TLabelConfig).fLabel := form1.DecString((self.LabelConfigList[12] as TLabelConfig).fLabel);
//            (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.IncString((self.LabelConfigList[0] as TLabelConfig).fLabel);
//          end;
//       end;
    5: begin //hoch
          if strtoint((self.LabelConfigList[0] as TLabelConfig).fLabel) > 0 then
          begin
            form1.PlayUpDown;
            inc(cdSpieler.Technik);
            dec(cdSpieler.fLevelUpPoints);
            (self.LabelConfigList[13] as TLabelConfig).fLabel := inttostr(cdSpieler.GetTechnik);
            (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.GetTripleString(inttostr(cdSpieler.fLevelUpPoints));
          end else
          begin
            form1.PlayNo;
          end;
       end;
    6: begin //Erholung
          Form1.NewMenu;
          Form1.fActiveMenu := TErholungsParkClass.Create(Form1.DXDraw1,Form1.dxs1,'personal'); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    7: begin //Erholung
          Form1.NewMenu;
          Form1.fActiveMenu := TWohnungsMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'personal'); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
  end;
end;

constructor TPSAusruestungsMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
 i, j : integer;
 sx,sy : integer;
 lauf : integer;
begin
  inherited create(dxdraw,engine);
  ItemNow := 0;

  //0..15
  sx := round(110/1.28);
  sy := round(120/1.28);
  lauf := 0;
  for i := 0 to 3 do //Zeilen
  begin
    for j := 0 to 3 do //Spalten
    begin
      Koords[lauf].X := sx;
      Koords[lauf].y := sy;
      inc(sx,round(105/1.28));
      inc(lauf);
    end;
    sx := round(110/1.28);
    inc(sy,round(105/1.28));
  end;

  //Ausrüstung auf Figur  16-18
  Koords[16].x := round(758/1.28);
  Koords[16].Y := round(114/1.28);

  Koords[17].x := round(759/1.28);
  Koords[17].Y := round(255/1.28);

  Koords[18].x := round(760/1.28);
  Koords[18].Y := round(425/1.28);

  MouseDown(Koords[0].X, Koords[0].Y);
end;

procedure TPSAusruestungsMenuClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  tt : TDIB;
  i : integer;
  Besch : string;
  klasse : integer;
begin
  try
    //Markierung malen
    (self.ImageConfigList[0] as TImageConfig).X := self.Koords[ItemNow].X-4;
    (self.ImageConfigList[0] as TImageConfig).Y := self.Koords[ItemNow].Y-4;

    //Icons malen
    surface := TDirectDrawSurface.Create(fdxDraw.DDraw);

    //Rucksack Ausrüstung malen
    for i := 0 to cdSpieler.AusruestungRucksack.Count - 1 do
    begin
      //Icon malen
      surface.LoadFromDIB((cdSpieler.AusruestungRucksack[i] as TAusruestung).Icon);
      fDXDraw.Surface.Draw(self.Koords[i].X,self.Koords[i].y,surface,false);
    end;

    //Angezogene Ausrüstung malen
    for i := 0 to cdSpieler.AusruestungAngezogen.Count - 1 do
    begin
      //Icon malen
      surface.LoadFromDIB((cdSpieler.AusruestungAngezogen[i] as TAusruestung).Icon);
      klasse := (cdSpieler.AusruestungAngezogen[i] as TAusruestung).Klasse;
      fDXDraw.Surface.Draw(self.Koords[15+klasse].X,self.Koords[15+klasse].y,surface,false);
    end;

//    //Infos anzeigen
//    (self.LabelConfigList[0] as TLabelConfig).fLabel := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Bezeichnung ;
//
//    //Beschreibung korrekt anzeigen
//    (self.LabelConfigList[8] as TLabelConfig).fLabel := ' ';
//    (self.LabelConfigList[14] as TLabelConfig).fLabel := ' ';
//
//    Besch := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung;
//    if length(Besch) > 45 then
//    begin
//      (self.LabelConfigList[8] as TLabelConfig).fLabel := copy(DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung),1,45);
//      (self.LabelConfigList[14] as TLabelConfig).fLabel := copy(DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung),46,Length(Besch)-45);
//    end else
//    begin
//      (self.LabelConfigList[8] as TLabelConfig).fLabel := DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung);
//    end;

  finally
    freeandnil(surface);
  end;
end;

procedure TPSAusruestungsMenuClass.MouseDown(x,y:integer);
var
  Index : integer;
  i : integer;
  kx,ky : integer;
  ItemNo : integeR;
begin
  Index := -1;

  for i := 0 to high(Koords) do
  begin
    kx := Koords[i].X;
    ky := Koords[i].Y;

    if (x >= kx) and (x <= kx+round(100/1.28)) and (y >= ky) and (y <= ky+round(100/1.28)) then
    begin
      Index := i;
      break;
    end;
  end;

  if Index <> -1 then
  begin
    ItemNow := Index;
  end;

  //Infos malen
  //Kopf, Handschuh, Schuh
  if ItemNow < 16 then
  begin
    (self.LabelConfigList[1] as TLabelConfig).fLabel := 'Stufe:';
    if  cdSpieler.AusruestungRucksack.count > ItemNow then//assigned(cdSpieler.AusruestungRucksack[ItemNow]) then
    begin
      (self.LabelConfigList[0] as TLabelConfig).fLabel := (cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).Bezeichnung;
      (self.LabelConfigList[4] as TLabelConfig).fLabel := inttostr((cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).Stufe);
      (self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
      case (cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).Klasse of
        1:(self.LabelConfigList[3] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).AddAusd) + '%';
        2:(self.LabelConfigList[3] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).AddMaxKr) + '%';
        3:(self.LabelConfigList[3] as TLabelConfig).fLabel := 'Technik +' + inttostr((cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).AddTechnik) + '%';
        4:begin
            (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).AddMaxKr);
            (self.LabelConfigList[3] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).AddAusd);
          end;
      end;
    end else
    begin
      (self.LabelConfigList[0] as TLabelConfig).fLabel := '-';
      (self.LabelConfigList[1] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[4] as TLabelConfig).fLabel := ' ';
    end;
  end else
  begin

    ItemNo := 1;
    case ItemNow of
      16:ItemNo := 1;
      17:ItemNo := 2;
      18:ItemNo := 3;
    end;

    (self.LabelConfigList[0] as TLabelConfig).fLabel := '-';
    (self.LabelConfigList[1] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[4] as TLabelConfig).fLabel := ' ';

    for i := 0 to cdSpieler.AusruestungAngezogen.Count - 1 do
    begin
      if (cdSpieler.AusruestungAngezogen[i] as TAusruestung).Klasse = ItemNo then
      begin
        (self.LabelConfigList[1] as TLabelConfig).fLabel := 'Stufe:';
        (self.LabelConfigList[0] as TLabelConfig).fLabel := (cdSpieler.AusruestungAngezogen[i] as TAusruestung).Bezeichnung;
        (self.LabelConfigList[4] as TLabelConfig).fLabel := inttostr((cdSpieler.AusruestungAngezogen[i] as TAusruestung).Stufe);
        (self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
        case (cdSpieler.AusruestungAngezogen[i] as TAusruestung).Klasse of
          1:(self.LabelConfigList[3] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpieler.AusruestungAngezogen[i] as TAusruestung).AddAusd) + '%';
          2:(self.LabelConfigList[3] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpieler.AusruestungAngezogen[i] as TAusruestung).AddMaxKr) + '%';
          3:(self.LabelConfigList[3] as TLabelConfig).fLabel := 'Technik +' + inttostr((cdSpieler.AusruestungAngezogen[i] as TAusruestung).AddTechnik) + '%';
          4:begin
              (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpieler.AusruestungAngezogen[i] as TAusruestung).AddMaxKr) + '%';
              (self.LabelConfigList[3] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpieler.AusruestungAngezogen[i] as TAusruestung).AddAusd) + '%';
            end;
        end;
        break;
      end;
    end;
  end;
end;


procedure TPSAusruestungsMenuClass.ButtonPress(bIndex:integer);
var
  Speicher : TAusruestung;
  i,j:integer;
  temp : integer;
begin
  case bIndex of
    0: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSEigenschaftenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    1: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSSpecialMovesMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    2: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSStatistikMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    3: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;

    //an/ausziehen
    4: begin
          if ItemNow < 16 then
          //-----------------
          //Rucksack (= 0..15)     Anziehen
          //-----------------
          begin
            if cdSpieler.AusruestungRucksack.Count > ItemNow then //Liegt da was?
            begin
              form1.PlayItem;
              //Hanteln ausschließen
              if (cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).Klasse <> 4 then
              begin
                //Liegt was auf jeweiligem Figur-Feld?
                Speicher := nil;
                for i := 0 to cdSpieler.AusruestungAngezogen.Count - 1 do
                begin
                  if (cdSpieler.AusruestungAngezogen[i] as TAusruestung).Klasse = (cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).Klasse then
                  begin
                    Speicher := cdSpieler.AusruestungAngezogen[i] as TAusruestung;
                    temp := i;
                    break;
                  end;
                end;
                if Speicher=nil then  //liegt nix drauf
                begin
                  Speicher :=cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung;
                  cdSpieler.AusruestungAngezogen.Add(Speicher);
                  cdSpieler.AusruestungRucksack.Extract(Speicher); //Aus Index entfernen aber nicht freigeben
                  ItemNow := (Speicher as TAusruestung).Klasse + 15;
                end else //liegt was drauf
                begin
                  //Objekte austauschen
                  cdSpieler.AusruestungAngezogen.Extract(Speicher); //Objekt aus Figurliste entfernen
                  cdSpieler.AusruestungAngezogen.add(cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung); //NeuesObjekt hinzufügen
                  cdSpieler.AusruestungRucksack.Extract(cdSpieler.AusruestungRucksack[ItemNow]); //Objekt aus Rucksackliste entfernen
                  cdSpieler.AusruestungRucksack.Add(Speicher); //Neues Objekt hinzufügen
                  ItemNow := (Speicher as TAusruestung).Klasse + 15;
                end;

              end else
              begin
                form1.PlayNo;
              end;
            end else
            begin
              form1.PlayNo;
            end;
          end else
          //----------------
          // Ausziehen
          //----------------
          begin
            case ItemNow of
              16:temp := 0;
              17:temp := 1;
              18:temp := 2;
            end;

            //Klasse temp+1 finden
            if cdSpieler.AusruestungAngezogen.Count = 0 then form1.playno;
            for i := 0 to cdSpieler.AusruestungAngezogen.Count - 1 do
            begin
              if (cdSpieler.AusruestungAngezogen[i] as TAusruestung).Klasse = temp+1 then
              begin
                if cdSpieler.AusruestungRucksack.Count <= 16 then //Rucksack nicht überfüllen
                begin
                  form1.PlayItem;
                  Speicher := cdSpieler.AusruestungAngezogen[i] as TAusruestung;
                  cdSpieler.AusruestungAngezogen.Extract(Speicher);
                  cdSpieler.AusruestungRucksack.Add(Speicher);
                  ItemNow := cdSpieler.AusruestungRucksack.Count - 1;
                  break;
                end else
                begin
                  form1.PlayNo;
                end;
              end else
              begin
                form1.PlayNo;
              end;
            end;
          end;
       end;
  end;
end;

procedure TPSSpecialMovesMenuClass.MouseOver(x,y:integer);
begin
  //x,y: 710;540
  //w,h: 125;30
  fUpgradeOver := false;
  //if (x >= round(320/1.28)) and (x <= round(320/1.28)+round(50/1.28)) and (y >= round(480/1.28)) and (y <= round(480/1.28)+round(50/1.28)) then
  if (x >= round(500/1.28)) and (x <= round(500/1.28)+round(50/1.28)) and (y >= round(220/1.28)) and (y <= round(220/1.28)+round(50/1.28)) then
  begin
    fUpgradeOver := true;
  end;
end;

procedure TPSSpecialMovesMenuClass.MouseDown(x,y:integer);
var
  Index : integer;
  i : integer;
  kx,ky : integer;
begin
  Index := -1;

  for i := 0 to high(cdSpecialMoves.Koords) do
  begin
    kx := cdSpecialMoves.Koords[i].X;
    ky := cdSpecialMoves.Koords[i].Y;

    if (x >= kx) and (x <= kx+round(100/1.28)) and (y >= ky) and (y <= ky+round(100/1.28)) then
    begin
      Index := i;
      break;
    end;
  end;

  if Index <> -1 then
  begin
    SMNow := Index;
  end;
end;

constructor TPSSpecialMovesMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
begin
  inherited create(DXDraw,Engine);
  SMNow := 0;
  fUpgradeOver := false;

  (self.LabelConfigList[1] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[1] as TLabelConfig).fLabel,15);
  (self.LabelConfigList[2] as TLabelConfig).fLabel := MakeStringRight((self.LabelConfigList[2] as TLabelConfig).fLabel,15);

end;

procedure TPSSpecialMovesMenuClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  tt : TDIB;
  i : integer;
  Besch : string;
begin
  try
    //Markierung malen
    (self.ImageConfigList[0] as TImageConfig).X := cdSpecialMoves.Koords[SMNow].X-4;
    (self.ImageConfigList[0] as TImageConfig).Y := cdSpecialMoves.Koords[SMNow].Y-4;

    //Icons malen
    surface := TDirectDrawSurface.Create(fdxDraw.DDraw);

    for i := 0 to cdSpecialMoves.fSpecialMoves.Count - 1 do
    begin
      //Icon malen
      if (cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Erlernt then
      begin
        surface.LoadFromDIB((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Icon.DIB);
      end else
      begin
        surface.LoadFromDIB((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).IconGrau.DIB);
      end;
      fDXDraw.Surface.Draw(cdSpecialMoves.Koords[i].X,cdSpecialMoves.Koords[i].y,surface,false);
    end;

    //Infos anzeigen
    (self.LabelConfigList[0] as TLabelConfig).fLabel := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Bezeichnung ;

    //Beschreibung korrekt anzeigen
    (self.LabelConfigList[8] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[14] as TLabelConfig).fLabel := ' ';

    Besch := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung;
    if length(Besch) > 45 then
    begin
      (self.LabelConfigList[8] as TLabelConfig).fLabel := copy(DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung),1,45);
      (self.LabelConfigList[14] as TLabelConfig).fLabel := copy(DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung),46,Length(Besch)-45);
    end else
    begin
      (self.LabelConfigList[8] as TLabelConfig).fLabel := DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung);
    end;


    //Werte
    if not fUpgradeOver then
    begin
      (self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).MinLevel);
      if (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level = 10 then
      begin
        (self.LabelConfigList[10] as TLabelConfig).fLabel := 'MASTER';
        (self.LabelConfigList[11] as TLabelConfig).fLabel := '-';
      end else
      begin
        (self.LabelConfigList[10] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level);
        (self.LabelConfigList[11] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GetIncLevelKosten);
      end;

      (self.LabelConfigList[12] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).TechnikKosten);

      //Fähigkeiten der SMs anzeigen
      case SMNow of
        0:begin //Schlafstellung
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfStrAusdProzent) + '%';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        1:begin //Schwitzende Hand
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Gegner Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GegnerStrAusdProzent) + '%';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        2:begin //Kampfgebrüll
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfMaxStrProzent) + '%';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        3:begin //Hölzerne Hand
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Gegner Maximalkraft ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GegnerMaxStrProzent) + '%';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        4:begin //Eiserne Hand
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Reaktionszeit) + 'ms';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        5:begin //Brennende Hand
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr(Abs((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Reaktionszeit)) + 'ms';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        6:begin //Rüttler
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).StopGravityMove_MS) + 'ms';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        7:begin //Blitzangriff
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfStrAusdProzent) + '%';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfMaxStrProzent) + '%';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        8:begin //Narkose
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).StopGravity_MS) + 'ms';
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;

        9:begin //Todesgriff
            (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Kampfposition +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).ChangePosition);
            (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
            (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
          end;
      end;

      //Verteilungs-Punkte
      (self.LabelConfigList[13] as TLabelConfig).fLabel := form1.GetTripleString((inttostr(cdSpieler.fLevelupPoints)));
    end else
    begin
      if ((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level < 10) then
      begin
        (self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).MinLevel);
        (self.LabelConfigList[10] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level+1);

        (self.LabelConfigList[11] as TLabelConfig).fLabel := inttostr( ((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level+1)*3 + 2 + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Minlevel div 2);

        (self.LabelConfigList[12] as TLabelConfig).fLabel := inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).TechnikKosten + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).TechnikKosten_up);

        //Fähigkeiten der SMs anzeigen
        if ((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level > 0) and ((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Level < 10) then
        begin
          case SMNow of
            0:begin //Schlafstellung
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfStrAusdProzent + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfStrAusdProzent_up) + '%';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            1:begin //Schwitzende Hand
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Gegner Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GegnerStrAusdProzent + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GegnerStrAusdProzent_up) + '%';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            2:begin //Kampfgebrüll
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfMaxStrProzent + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfMaxStrProzent_up) + '%';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            3:begin //Hölzerne Hand
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Gegner Maximalkraft ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GegnerMaxStrProzent + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GegnerMaxStrProzent_up) + '%';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            4:begin //Eiserne Hand
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Reaktionszeit + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Reaktionszeit_up) + 'ms';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            5:begin //Brennende Hand
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr(Abs((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Reaktionszeit + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Reaktionszeit_up)) + 'ms';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            6:begin //Rüttler
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).StopGravityMove_MS + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).StopGravityMove_MS_up) + 'ms';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            7:begin //Blitzangriff
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfStrAusdProzent + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfStrAusdProzent_up) + '%';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfMaxStrProzent + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).SelfMaxStrProzent_up) + '%';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            8:begin //Narkose
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Dauer: ' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).StopGravity_MS + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).StopGravity_MS_up) + 'ms';
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;

            9:begin //Todesgriff
                (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Kampfposition +' + inttostr((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).ChangePosition + (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).ChangePosition_up);
                (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
                (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
              end;
          end;
        end;
        //Verteilungs-Punkte
        (self.LabelConfigList[13] as TLabelConfig).fLabel := form1.GetTripleString((inttostr(cdSpieler.fLevelupPoints - (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).GetIncLevelKosten)));
      end;
    end;
  finally
    freeandnil(surface);
  end;
end;


procedure TPSSpecialMovesMenuClass.ButtonPress(bIndex:integer);
var
  kosten : integer;
begin

  //Erlernt auf true setzen
  //GetIncLevelValues
  //spieler.specialmoves.fspecialmoves

  case bIndex of
    0: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSEigenschaftenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    1: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSAusruestungsMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    2: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSStatistikMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    3: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    4: begin // Upgrade
          if (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).getinclevelkosten > cdSpieler.fLevelupPoints then
          begin
            form1.PlayNo;
          end else
          begin
            kosten := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).getinclevelkosten;
            if (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).IncLevel then
            begin
              //Sound abspielen
              case smnow of
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

              dec(cdSpieler.fLevelUpPoints,kosten);
              if cdspieler.fleveluppoints < 0 then cdspieler.fleveluppoints := 0;
            end else
            begin
              form1.PlayNo;
            end;
          end;
       end;
  end;
end;

constructor TPSStatistikMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
begin
  inherited create(dxdraw,engine);

  {
  /8
  Label;300;150;big;Kämpfe:
  /9
  Label;300;200;big;Siege:
  /10
  Label;300;250;big;Niederlagen:

  /11
  Label;300;300;big;Turnierteilnahmen:
  /12
  Label;300;350;big;Turniersiege:

  /13
  Label;300;400;big;Meisterschaften 3.Liga:
  /14
  Label;300;450;big;Meisterschaften 2.Liga:
  /15
  Label;300;500;big;Meisterschaften 1.Liga:
  }
  (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[0] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[1] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[1] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[2] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[2] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[3] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[3] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[4] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[4] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[5] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[5] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[6] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[6] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[7] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[7] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[16] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[16] as TLabelConfig).fLabel,23);
  (self.LabelConfigList[17] as TLabelConfig).fLabel := form1.MakeStringRight((self.LabelConfigList[17] as TLabelConfig).fLabel,23);


  (self.LabelConfigList[8] as TLabelConfig).fLabel := inttostr(cdSpieler.Siege_Alle + cdSpieler.Niederlagen_Alle);
  (self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.Siege_Alle);
  (self.LabelConfigList[10] as TLabelConfig).fLabel := inttostr(cdSpieler.Niederlagen_Alle);
  (self.LabelConfigList[11] as TLabelConfig).fLabel := inttostr(cdSpieler.Turnierteilnahmen);
  (self.LabelConfigList[12] as TLabelConfig).fLabel := inttostr(cdSpieler.Turniersiege);
  (self.LabelConfigList[13] as TLabelConfig).fLabel := inttostr(cdSpieler.Meisterschaften3);
  (self.LabelConfigList[14] as TLabelConfig).fLabel := inttostr(cdSpieler.Meisterschaften2);
  (self.LabelConfigList[15] as TLabelConfig).fLabel := inttostr(cdSpieler.Meisterschaften1);

  (self.LabelConfigList[18] as TLabelConfig).fLabel := inttostr(cdSpieler.Meisterschaften5);
  (self.LabelConfigList[19] as TLabelConfig).fLabel := inttostr(cdSpieler.Meisterschaften4);

end;

procedure TPSStatistikMenuClass.ButtonPress(bIndex:integer);
begin
  case bIndex of
    0: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSEigenschaftenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    1: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSSpecialMovesMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    2: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TPSAusruestungsMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
    3: begin
          Form1.NewMenu;
          Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
       end;
  end;
end;

procedure TMainMenuClass.ButtonPress(bIndex:integer);
var
	i : Integer;
begin
  Form1.PlayMouseDown;

  try
    inherited buttonpress(0);
    form1.paintIt;
    case bIndex of
      3: begin
            Form1.NewMenu;
            Form1.fActiveMenu := TCreatePlayerClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;
      2: begin //laden
            Form1.NewMenu;
            Form1.fActiveMenu := TOptionsMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'mainmenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;
      0: begin
//           form1.AudioOut1.Stop;
           form1.Close;
         end;
      1: begin //Infos
            Form1.NewMenu;
            Form1.fActiveMenu := TInfoMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;
      4: begin
            Form1.NewMenu; //Menu kicken
            Form1.fActiveMenu := TMuckeMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'mainmenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
         end;
//
//      5: begin
//            Form1.NewMenu; //Menu kicken
//            form1.fTrain := TTrain.create(form1.DXDraw1);
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
//         end;

    end;
  except
    on e:exception do
      showmessage('Main->TMainMenuClass->ButtonPress: ' + e.message);
  end;
end;

constructor TMainMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
begin

  form1.Logger.Add('TMainMenuClass.create');

  inherited create(dxdraw,Engine);
  Form1.FadeSpeed := 3;
  //orm1.fDoFire := true;
  form1.Logger.Add('TMainMenuClass.create PASSED');

end;


procedure TMainMenuClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  tt : TDIB;
begin
  form1.DXPowerFont1.Font := 'FontN';
  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, 3, 575, 'v'+cRelease);
//  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, 540, 575, 'www.workisover.de');
//  form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface, 5, 590, 'http:\\www.armwrestling-champion.de');

//  surface := TDirectDrawSurface.Create(fdxDraw.DDraw);
//  surface.Fill(0);
//  surface.LoadFromFile('c:\test.jpg');
//  fDXDraw.Surface.Draw(100,100,surface);
end;


procedure TErholungsParkClass.Erholen(index:integer);
var
  Prozent : integer;
begin
  form1.Logger.Add('TErholungsParkClass.Erholen');

  randomize;
  case index of
    1: Prozent := randomrange(10,20);
    2: Prozent := randomrange(15,35);
    3: Prozent := randomrange(30,55);
    4: Prozent := randomrange(50,80);
    5: Prozent := randomrange(75,100);
  end;
  cdSpieler.Fitness := cdSpieler.Fitness + GetProzent(Prozent,cdSpieler.FitnessMaximum);
  if cdSpieler.Fitness > cdSpieler.FitnessMaximum then cdSpieler.Fitness := cdSpieler.FitnessMaximum;
  form1.Logger.Add('TErholungsParkClass.Erholen PASSED');
end;

procedure TErholungsParkClass.MouseButtonOver(bIndex:integer);
begin
  (self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.kapital);
  case bIndex of
    1:(self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.kapital-fKosten[1]);
    2:(self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.kapital-fKosten[2]);
    3:(self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.kapital-fKosten[3]);
    4:(self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.kapital-fKosten[4]);
    5:(self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.kapital-fKosten[5]);
  end;
  (ImageConfigList[0] as TImageConfig).X := (LabelConfigList[9] as TLabelConfig).X + length((LabelConfigList[9] as TLabelConfig).flabel)*18+5;
  (ImageConfigList[0] as TImageConfig).Y := (LabelConfigList[9] as TLabelConfig).y-12;
end;

procedure TErholungsParkClass.ButtonPress(bIndex:integer);
begin
  case bIndex of
    0:  begin
          if fweiterleitung = 'training' then
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end else if fweiterleitung = 'personal' then
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TPSEigenschaftenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end else if fweiterleitung = 'gamemenu' then
          begin
            Form1.NewMenu;
            Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end;
        end;

    1:  begin
          if cdSpieler.Kapital >= fKosten[1] then
          begin
            form1.playupdown;
            dec(cdSpieler.Kapital,fKosten[1]);
            Erholen(1);
            (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.fitness) + '/' + inttostr(cdspieler.FitnessMaximum);

//            Form1.NewMenu;
//            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
//            exit;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    2:  begin
          if cdSpieler.Kapital >= fKosten[2] then
          begin
            form1.playupdown;
            dec(cdSpieler.Kapital,fKosten[2]);
            Erholen(2);
            (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.fitness) + '/' + inttostr(cdspieler.FitnessMaximum);

//            Form1.NewMenu;
//            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
//            exit;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    3:  begin
          if cdSpieler.Kapital >= fKosten[3] then
          begin
            form1.playupdown;
            dec(cdSpieler.Kapital,fKosten[3]);
            Erholen(3);
            (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.fitness) + '/' + inttostr(cdspieler.FitnessMaximum);

//            Form1.NewMenu;
//            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
//            exit;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    4:  begin
          if cdSpieler.Kapital >= fKosten[4] then
          begin
            form1.playupdown;
            dec(cdSpieler.Kapital,fKosten[4]);
            Erholen(4);
            (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.fitness) + '/' + inttostr(cdspieler.FitnessMaximum);

//            Form1.NewMenu;
//            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
//            exit;
          end else
          begin
            form1.PlayNo;
          end;
        end;

    5:  begin
          if cdSpieler.Kapital >= fKosten[5] then
          begin
            form1.playupdown;
            dec(cdSpieler.Kapital,fKosten[5]);
            Erholen(5);
            (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.fitness) + '/' + inttostr(cdspieler.FitnessMaximum);

//            Form1.NewMenu;
//            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
//            exit;
          end else
          begin
            form1.PlayNo;
          end;
        end;
  end;
end;

procedure TNachTurnierKampfMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0:  begin
            if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).lastround then
            begin
              if goPokal then
              begin
                cdSpieler.turniergewonnen((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Bezeichnung);
                (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).reset;
                Form1.NewMenu;
                Form1.fActiveMenu := TPokaleMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
                Form1.DXDraw1.restore; {Darstellung aktualisieren}
                exit;
              end else
              begin
                form1.turniervorbei;
                exit;
              end;
            end else
            begin
              form1.NewMenu;
              form1.fActiveMenu := TTurnierStartMenuClass.create(fDXDraw,Form1.dxs1);
              Form1.DXDraw1.restore;
              exit;
            end;
          end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TNachTurnierKampfMenuClass.ButtonPress: ' + e.message);
    end;
  end;
end;

constructor TNachTurnierKampfMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TSportler;Sieger:string);
var
  i,j,count : integer;
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  goPokal := false;

  if Sieger = 'spieler' then
  begin
    self.BackConfig.fIndex := 0;

    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).lastround then
    begin
      goPokal := true;
      (LabelConfigList[0] as TLabelConfig).fLabel := 'Sie haben ' + copy(Gegner.vorname + ' ' + gegner.name,1,17) + ' besiegt.';
      (LabelConfigList[1] as TLabelConfig).fLabel := 'Sie haben das Turnier gewonnen und';
      (LabelConfigList[5] as TLabelConfig).fLabel := 'bekommen ' + inttostr((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).PreisGeld);
      (LabelConfigList[2] as TLabelConfig).fLabel := 'Erfahrungspunkte: +' + inttostr((10*Gegner.level)*4);
      (LabelConfigList[3] as TLabelConfig).fLabel := 'Ansehen: +' + inttostr((Gegner.level)*4);

      (imageconfiglist[0] as TImageConfig).X :=  (LabelConfigList[5] as TLabelConfig).x + length((LabelConfigList[5] as TLabelConfig).flabel)*15 + 5;
      (imageconfiglist[0] as TImageConfig).Y :=  (LabelConfigList[5] as TLabelConfig).y-10;
          
      cdspieler.Kapital := cdspieler.Kapital + (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).PreisGeld;
      cdSpieler.Erfahrung := cdSpieler.Erfahrung + 10*Gegner.level;
      cdSpieler.Ansehen := cdSpieler.Ansehen + gegner.level;
      inc(cdSpieler.Siege_Alle);
      inc(cdSpieler.Turniersiege);
    end else
    begin
      (LabelConfigList[0] as TLabelConfig).fLabel := 'Sie haben ' + copy(Gegner.vorname + ' ' + gegner.name,1,17) + ' besiegt.';
      (LabelConfigList[1] as TLabelConfig).fLabel := 'Sie sind eine Runde weiter.';
      (LabelConfigList[2] as TLabelConfig).fLabel := 'Erfahrungspunkte: +' + inttostr(10*Gegner.level);
      (LabelConfigList[3] as TLabelConfig).fLabel := 'Ansehen: +' + inttostr(Gegner.level*2);

      cdSpieler.Erfahrung := cdSpieler.Erfahrung + 10*Gegner.level;
      cdSpieler.Ansehen := cdSpieler.Ansehen + gegner.level*2;
      inc(cdSpieler.Siege_Alle);

      //Sieger eintragen
      for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen) do
      begin
        if ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].istspieler) or ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].Y].istspieler) then
        begin
          if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].istspieler then
          begin
            (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].z := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].ID;
          end else
          begin
            (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].z := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].Y].ID;
          end;
          break;
        end;
  //      if ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].ID = 99)
  //      or ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].Y].ID = 99) then
  //      begin
  //        (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].z := 99;
  //        break;
  //      end;
      end;
    end;

  end else if sieger = 'gegner' then
  begin
    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).lastround then
    begin
      self.BackConfig.fIndex := -1;

      (LabelConfigList[0] as TLabelConfig).fLabel := 'Sie haben gegen ' + copy(Gegner.vorname + ' ' + gegner.name,1,17);
      (LabelConfigList[1] as TLabelConfig).flabel := 'das Finale verloren';
      (LabelConfigList[2] as TLabelConfig).fLabel := 'Erfahrungspunkte: ' + inttostr(Gegner.level);
      (LabelConfigList[3] as TLabelConfig).fLabel := 'Ansehen: -' + inttostr(cdSpieler.level+gegner.level);

      cdSpieler.Erfahrung := cdSpieler.Erfahrung + Gegner.level;
      cdSpieler.Ansehen := cdSpieler.Ansehen - cdspieler.level - gegner.level;
      inc(cdSpieler.Niederlagen_Alle);
    end else
    begin
      self.BackConfig.fIndex := -1;

      (LabelConfigList[0] as TLabelConfig).fLabel := 'Sie sind gegen ' + copy(Gegner.vorname + ' ' + gegner.name,1,18);
      (LabelConfigList[1] as TLabelConfig).flabel := 'aus dem Turnier ausgeschieden';
      (LabelConfigList[2] as TLabelConfig).fLabel := 'Erfahrungspunkte: ' + inttostr(Gegner.level);
      (LabelConfigList[3] as TLabelConfig).fLabel := 'Ansehen: -' + inttostr(cdSpieler.level+gegner.level);

      cdSpieler.Erfahrung := cdSpieler.Erfahrung + Gegner.level;
      cdSpieler.Ansehen := cdSpieler.Ansehen - cdspieler.level - gegner.level;
      inc(cdSpieler.Niederlagen_Alle);


      //Sieger eintragen
      for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen) do
      begin
        if ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].istspieler) or ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].Y].istspieler) then
        begin
          if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].istspieler then
          begin
            (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].z := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].Y].ID;
          end else
          begin
            (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].z := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].Begegnungen[i].X].ID;
          end;
          break;
        end;
      end;
    end;
  end;

  //Turnierdaten zurücksetzen / weiterführen
  if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).lastround then
  begin
    //(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).reset;
  end else
  begin
    //Paarungen neue Runde eintragen
    count := 0;
    for j := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde].Begegnungen) do// ((Runden[AktuelleRunde].  SiegerIDs.count) div 2)-1 do
    begin
      (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde].Begegnungen[j].X := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].begegnungen[count].z;  //SiegerIDs[Count]);
      (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde].Begegnungen[j].Y := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Runden[(cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).AktuelleRunde-1].begegnungen[count+1].z;  //SiegerIDs[Count+1]);
      inc(count,2);
    end;
  end;
end;


//  //Begegnungen für die nächste Runde berechnen
//  if AktuelleRunde < high(runden) then
//  begin
//    count := 0;
//    for i := 0 to high(Runden[AktuelleRunde+1].begegnungen) do// ((Runden[AktuelleRunde].  SiegerIDs.count) div 2)-1 do
//    begin
//      Runden[AktuelleRunde+1].Begegnungen[i].X := Runden[AktuelleRunde].begegnungen[count].z;  //SiegerIDs[Count]);
//      Runden[AktuelleRunde+1].Begegnungen[i].Y := Runden[AktuelleRunde].begegnungen[count+1].z;  //SiegerIDs[Count+1]);
//      inc(count,2);
//    end;


procedure TNachKneipenKampfMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0:  begin
            form1.NewMenu;
            form1.fActiveMenu := TKneipenMenuClass.create(form1.DXDraw1,Form1.dxs1);
            Form1.DXDraw1.restore;
            exit;
          end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TNachKneipenKampfMenuClass.ButtonPress: ' + e.message);
    end;
  end;
end;

constructor TNachKneipenKampfMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TKneipengegner;Sieger:string);
var
  i : integer;
begin
//  if sieger = 'spieler' then self.BackConfig.fIndex := 1 else self.BackConfig.fIndex := 0;

  inherited create(dxdraw,engine);

  if (Sieger = 'spieler') then
  begin
    self.BackConfig.fIndex := 0;
    (LabelConfigList[0] as TLabelConfig).fLabel := 'Sie haben ' + copy(Gegner.vorname + ' ' + gegner.name,1,17) + ' besiegt.';
    (LabelConfigList[1] as TLabelConfig).fLabel := 'Siegprämie: ' + inttostr(Gegner.WettBetrag*2);
    (LabelConfigList[2] as TLabelConfig).fLabel := 'Erfahrungspunkte: +' + inttostr(10*Gegner.level);
    (LabelConfigList[3] as TLabelConfig).fLabel := 'Ansehen: +' + inttostr(Gegner.level*2);

    (ImageConfigList[0] as TImageConfig).X := (LabelConfigList[1] as TLabelConfig).X + length('Siegprämie: ' + inttostr(Gegner.Wettbetrag*2))*15;
    (ImageConfigList[0] as TImageConfig).Y := (LabelConfigList[1] as TLabelConfig).y-10;

    cdspieler.Kapital := cdspieler.Kapital + Gegner.WettBetrag*2;
    cdSpieler.Erfahrung := cdSpieler.Erfahrung + 10*Gegner.level;
    cdSpieler.Ansehen := cdSpieler.Ansehen + gegner.level*2;
    inc(cdSpieler.Siege_Alle);
  end else if sieger = 'gegner' then
  begin
    self.BackConfig.fIndex := -1;
    (LabelConfigList[0] as TLabelConfig).fLabel := copy(Gegner.vorname + ' ' + gegner.name,1,18) + ' hat Sie besiegt.';
    (LabelConfigList[1] as TLabelConfig).fLabel := 'Erfahrungspunkte: ' + inttostr(Gegner.level);
    (LabelConfigList[2] as TLabelConfig).fLabel := 'Ansehen: -' + inttostr(cdSpieler.level+gegner.level);
    (LabelConfigList[3] as TLabelConfig).flabel := ' ';
    cdSpieler.Erfahrung := cdSpieler.Erfahrung + Gegner.level;
    cdSpieler.Ansehen := cdSpieler.Ansehen - cdspieler.level - gegner.level;
    inc(cdSpieler.Niederlagen_Alle);
  end;

  //Bekämpfter Gegner verlässt Kneipe
  for i := 0 to cdKneipe.GegnerListe.Count-1 do
  begin
    if (cdKneipe.GegnerListe[i] as TKneipengegner).ID = Gegner.ID then
    begin
      cdKneipe.GegnerListe.Delete(i);
      break;
    end;
  end;

end;

procedure TVorKampfAllgemeinMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0:  begin
            form1.playBeforeFight;
            sleep(1500);
            form1.fFight := TKampf.create(form1.dxdraw1,fGegner,fWeiterleitung);
            form1.NewMenu;
            Form1.DXDraw1.restore;
            exit;
          end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TVorKampfAllgemeinMenuClass.ButtonPress: ' + e.message);
    end;
  end;
end;

destructor TVorKampfAllgemeinMenuClass.destroy;
begin
//  freeandnil(fsurface);
  inherited destroy;
end;

procedure TVorKampfAllgemeinMenuClass.DrawMenuSpecific;
begin
//  form1.ShowGeld(fsurface,100,100);
end;

constructor TVorKampfAllgemeinMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TSportler;Weiterleitung:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
begin
  inherited create(dxdraw,engine);

//  fsurface := TDirectDrawSurface.Create(form1.DXDraw1.DDraw);

  fGegner := Gegner;
  fWeiterleitung := Weiterleitung;

  (LabelConfigList[0] as TLabelConfig).fLabel := CenterString(cdSpieler.Vorname + ' ' + cdSpieler.name,20) + CenterString(' vs ',14) + CenterString(Gegner.Vorname + ' ' +Gegner.name,20);
  (LabelConfigList[1] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Level),20) + CenterString('Level',14) +  CenterString(inttostr(Gegner.Level),20);
  (LabelConfigList[2] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.GetMaximalkraft) + '/' + inttostr(cdSpieler.Maximalkraft),20) + CenterString('Maximalkraft',14) +  CenterString(inttostr(Gegner.Maximalkraft) + '/' +inttostr(gegner.Maximalkraft - randomrange(gegner.maximalkraft div 3,gegner.maximalkraft div 4)),20);
  (LabelConfigList[3] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.GetKraftausdauer) + '/' + inttostr(cdSpieler.Kraftausdauer ),20) + CenterString('Kraftausdauer',14) +  CenterString(inttostr(Gegner.Kraftausdauer) + '/' +inttostr(gegner.kraftausdauer - randomrange(gegner.Maximalkraft div 3, gegner.Maximalkraft div 4)),20);
  (LabelConfigList[4] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Technik),20) + CenterString('Technik',14) +  CenterString(inttostr(Gegner.Technik),20);

  (LabelConfigList[0] as TLabelConfig).y := (LabelConfigList[0] as TLabelConfig).y + 10;

  if lowercase(weiterleitung) = 'nachsaisonkampf1' then
  begin
    //Tabellenrang
    (LabelConfigList[5] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Siege),20) + CenterString('Siege',14) +  CenterString(inttostr(Gegner.Siege),20); ;//CenterString(inttostr(cdSpieler.),20) + '  Technik' +  CenterString(inttostr(Gegner.Technik),20);
    //siege
    //niederlagen
  end else if lowercase(weiterleitung) = 'nachkneipenkampf' then
  begin
    (ImageConfigList[0] as TImageConfig).X := (LabelConfigList[5] as TLabelConfig).X + 22*17 + (length('Siegprämie: ' + inttostr((Gegner as TKneipengegner).Wettbetrag*2))*18) div 2;
    (ImageConfigList[0] as TImageConfig).Y := (LabelConfigList[5] as TLabelConfig).y-10;

    //(LabelConfigList[5] as TLabelConfig).Y := 370;
    (LabelConfigList[5] as TLabelConfig).fLabel := centerstring('Siegprämie: ' + inttostr((Gegner as TKneipengegner).Wettbetrag*2),55);
  end else if lowercase(weiterleitung) = 'nachturnierkampf' then
  begin
    (LabelConfigList[5] as TLabelConfig).fLabel := ' ';
    (LabelConfigList[1] as TLabelConfig).y := (LabelConfigList[1] as TLabelConfig).y + 18;
    (LabelConfigList[2] as TLabelConfig).y := (LabelConfigList[2] as TLabelConfig).y + 18;
    (LabelConfigList[3] as TLabelConfig).y := (LabelConfigList[3] as TLabelConfig).y + 18;
    (LabelConfigList[4] as TLabelConfig).y := (LabelConfigList[4] as TLabelConfig).y + 18;
  end else
  begin
    (LabelConfigList[5] as TLabelConfig).fLabel := ' ';
  end;
end;

procedure TVorSaisonKampfMenuClass.ButtonPress(bIndex:integer);
var
  weiterleitung:string;
  rrunde:integer;
  rwoche:integer;
begin
  rrunde := frunde;
  rwoche := fwoche;
  try
    case bIndex of
      0:  begin
            form1.NewMenu;
            case rrunde of
              1:  begin
                  if cdKampfsaison.Vorrunde[rwoche].Kaempfe[form1.fSpielerKampfIndex].K1_ID = 6 then
                  begin
                    form1.fActiveMenu := TVorKampfAllgemeinMenuClass.create(form1.DXDraw1,form1.dxs1,cdGegner.Gegner[cdKampfsaison.Vorrunde[rwoche].Kaempfe[form1.fSpielerKampfIndex].K2_ID],  'nachsaisonkampf1');
                  end else
                  begin
                    form1.fActiveMenu := TVorKampfAllgemeinMenuClass.create(form1.DXDraw1,form1.dxs1,cdGegner.Gegner[cdKampfsaison.Vorrunde[rwoche].Kaempfe[form1.fSpielerKampfIndex].K1_ID],  'nachsaisonkampf1');
                  end;
                end;
              2:  begin
                  if cdKampfsaison.rueckrunde[rwoche].Kaempfe[form1.fSpielerKampfIndex].K1_ID = 6 then
                  begin
                    form1.fActiveMenu := TVorKampfAllgemeinMenuClass.create(form1.DXDraw1,form1.dxs1,cdGegner.Gegner[cdKampfsaison.rueckrunde[rwoche].Kaempfe[form1.fSpielerKampfIndex].K2_ID],  'nachsaisonkampf1');
                  end else
                  begin
                    form1.fActiveMenu := TVorKampfAllgemeinMenuClass.create(form1.DXDraw1,form1.dxs1,cdGegner.Gegner[cdKampfsaison.rueckrunde[rwoche].Kaempfe[form1.fSpielerKampfIndex].K1_ID],  'nachsaisonkampf1');
                  end;
                end;
            end;
            Form1.DXDraw1.restore;
            exit;
          end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TVorSaisonKampfMenuClass.ButtonPress: ' + e.message);
    end;
  end;
end;

constructor TVorSaisonKampfMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Weiterleitung:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
var
  id1,id2 : integer;
  name1,name2 : string;
  runde : string;
  i : integer;
begin
  inherited create(dxdraw,engine);

  fWoche := cdZeit.Woche-1;
  frunde := cdZeit.runde;

  if cdZeit.NextRound then
  begin
    fWoche := 5;
    if frunde = 1 then
      frunde := 2
    else frunde := 1;
  end;

  case frunde of
    1: runde := 'Hinrunde';
    2: runde := 'Rückrunde';
  end;


  (LabelConfigList[0] as TLabelConfig).fLabel := runde + ',  ' + 'Kampftag ' + inttostr(fwoche) + '/5';

  //Spieler ID = 6
  for i := 1 to high(cdKampfsaison.Vorrunde[fwoche].Kaempfe) do
  begin
    case frunde of
      1:  begin
            ID1 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K1_ID;
            ID2 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K2_ID;
//            IDSieger := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].SiegerID;
          end;

      2:  begin

            ID1 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K1_ID;
            ID2 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K2_ID;
//            IDSieger := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].SiegerID;
          end;
    end;

    if ID1 <> 6 then
    begin
      name1 := (cdGegner.gegner[ID1] as TSportler).Vorname +' '+ (cdGegner.gegner[ID1] as TSportler).Name + ' Lv' +  inttostr((cdGegner.gegner[ID1] as TSportler).level) + '/R' + inttostr((cdGegner.gegner[ID1] as TSportler).rang);
    end else
    begin
      form1.fSpielerKampfIndex := i;
      name1 := cdSpieler.Vorname + ' Lv' +  inttostr(cdspieler.level) + '/R' + inttostr(cdSpieler.rang);
    end;

    if ID2 <> 6 then
    begin
      name2 := (cdGegner.gegner[ID2] as TSportler).Vorname +' '+ (cdGegner.gegner[ID2] as TSportler).Name+ ' Lv' +  inttostr((cdGegner.gegner[ID2] as TSportler).level) + '/R' + inttostr((cdGegner.gegner[ID2] as TSportler).rang);
    end else
    begin
      form1.fSpielerKampfIndex := i;
      name2 := cdSpieler.Vorname + ' Lv' +  inttostr(cdspieler.level) + '/R' + inttostr(cdSpieler.rang);
    end;


//    if (IDSieger <> 20) and (IDSieger <> 0) then
//    begin
//      siegername := (cdGegner.gegner[IDSieger] as TSportler).Vorname +' '+ (cdGegner.gegner[IDSieger] as TSportler).Name;
//    end else if idsieger = 20 then
//    begin
//      siegername := cdSpieler.Vorname;
//    end else if idsieger = 0 then
//    begin
//      siegername := '?';
//    end;

    (self.LabelConfigList[i] as TLabelConfig).fLabel := CenterString(name1,30) + ' vs ' + CenterString(name2,30); //+ '  Sieger: ' + Form1.CenterString(siegername,20);
    (self.LabelConfigList[i] as TLabelConfig).y := (self.LabelConfigList[i] as TLabelConfig).y + 4;
  end;

  //Kämpfe berechnen
  for i := 1 to high(cdKampfsaison.Vorrunde[fWoche].Kaempfe) do
  begin
      case frunde of
        1:  begin
              ID1 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K1_ID;
              ID2 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K2_ID;
              if (ID1 <> 6) and (ID2 <> 6) then
              begin
                cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].Fight;
              end;
            end;

        2:  begin
              ID1 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K1_ID;
              ID2 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K2_ID;
              if (ID1 <> 6) and (ID2 <> 6) then
              begin
                cdKampfsaison.Rueckrunde[fWoche].Kaempfe[i].Fight;
              end;
            end;
       end;

    end;

end;


procedure TNachSaisonKampf1MenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0:  begin
            form1.NewMenu;
            form1.fActiveMenu := TNachSaisonKampf2MenuClass.create(fDXDraw,form1.dxs1);
            Form1.DXDraw1.restore;
            exit;
          end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TNachSaisonKampf1MenuClass.ButtonPress: ' + e.message);
    end;
  end;
end;

constructor TNachSaisonKampf1MenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Gegner:TSportler;sieger:string); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
begin
  inherited create(dxdraw,engine);

  if Sieger = 'spieler' then
  begin
    self.BackConfig.fIndex := 0;
    (LabelConfigList[0] as TLabelConfig).fLabel := 'Sie haben ' + copy(Gegner.vorname + ' ' + gegner.name,1,17) + ' besiegt.';
    if cdspieler.sponsor <> nil then
    begin
      (LabelConfigList[1] as TLabelConfig).fLabel := 'Sponsor: +' + inttostr(cdspieler.Sponsor.sieggeld);
      (imageconfiglist[0] as TImageConfig).X := (LabelConfigList[1] as TLabelConfig).x + length((LabelConfigList[1] as TLabelConfig).flabel)*15 + 5;
      (imageconfiglist[0] as TImageConfig).Y := (LabelConfigList[1] as TLabelConfig).y-10;
    end else
    begin
      (LabelConfigList[1] as TLabelConfig).fLabel := ' ';
    end;

    (LabelConfigList[2] as TLabelConfig).fLabel := 'Erfahrungspunkte: +' + inttostr(10*Gegner.level);
    (LabelConfigList[3] as TLabelConfig).fLabel := 'Ansehen: +' + inttostr(Gegner.level*2);

//    cdspieler.Kapital := cdspieler.Kapital + Gegner.WettBetrag*2;
    cdSpieler.Erfahrung := cdSpieler.Erfahrung + 10*Gegner.level;
    cdSpieler.Ansehen := cdSpieler.Ansehen + gegner.level*2;
  end else if sieger = 'gegner' then
  begin
    self.BackConfig.fIndex := -1;
    (LabelConfigList[0] as TLabelConfig).fLabel := copy(Gegner.vorname + ' ' + gegner.name,1,18) + ' hat Sie besiegt.';
    (LabelConfigList[1] as TLabelConfig).fLabel := 'Erfahrungspunkte: ' + inttostr(Gegner.level);
    (LabelConfigList[2] as TLabelConfig).fLabel := 'Ansehen: -' + inttostr(cdSpieler.level+gegner.level);
    (LabelConfigList[3] as TLabelConfig).flabel := ' ';
    cdSpieler.Erfahrung := cdSpieler.Erfahrung + Gegner.level;
    cdSpieler.Ansehen := cdSpieler.Ansehen - cdspieler.level - gegner.level;
  end;

//  (LabelConfigList[0] as TLabelConfig).fLabel := CenterString(cdSpieler.Vorname + ' ' + cdSpieler.name,20) + CenterString(' vs ',13) + CenterString(Gegner.Vorname + ' ' +Gegner.name,20);
//  (LabelConfigList[1] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Maximalkraft),20) + 'Maximalkraft' +  CenterString(inttostr(Gegner.Maximalkraft),20);
//  (LabelConfigList[2] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Kraftausdauer),20) + 'Kraftausdauer' +  CenterString(inttostr(Gegner.Kraftausdauer),20);
//  (LabelConfigList[3] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Technik),20) + '  Technik' +  CenterString(inttostr(Gegner.Technik),20);
//  (LabelConfigList[4] as TLabelConfig).fLabel :=
  //(LabelConfigList[5] as TLabelConfig).fLabel :=
end;


procedure TNachSaisonKampf2MenuClass.ButtonPress(bIndex:integer);
var
  Gegner:TSportler;
  weiterleitung:string;
begin
  try
    case bIndex of
      0:  begin
            if cdZeit.NextRound then
            begin
              cdZeit.NextRound := false;
              if cdspieler.Sponsor <> nil then
              begin
                freeandnil(cdspieler.sponsor);
              end;

              if cdZeit.NextSaison then
              begin
                cdZeit.NextSaison := false;
                inc(cdSpieler.Alter);

                Form1.NewMenu;
                Form1.fActiveMenu := TNachSaisonMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
                Form1.DXDraw1.restore; {Darstellung aktualisieren}
                exit;
              end else
              begin
                Form1.NewMenu;
                Form1.fActiveMenu := TNachRundeMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
                Form1.DXDraw1.restore; {Darstellung aktualisieren}
                exit;
              end;
            end else
            begin
              form1.NewMenu;
              form1.fActiveMenu := TGameMenuClass.create(form1.DXDraw1,form1.dxs1);
              Form1.DXDraw1.restore;
              exit;
            end;
          end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TNachSaisonKampf2MenuClass.ButtonPress: ' + e.message);
    end;
  end;
end;

constructor TNachSaisonKampf2MenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine); //"nachKneipenkampf"/"nachTurnierkampf"/"nachSaisonKampf1"
var
  id1,id2 : integer;
  name1,name2 : string;
  runde : string;
  i : integer;
  fWoche : integer;
  idsieger:integer;
  siegername:string;
  frunde:integer;
begin
  inherited create(form1.dxdraw1,form1.dxs1);

  fWoche := cdZeit.Woche-1;
  frunde := cdZeit.runde;

  if cdZeit.NextRound then
  begin
    fWoche := 5;
    if frunde = 1 then
      frunde := 2
    else frunde := 1;
  end;

  case frunde of
    1: runde := 'Hinrunde';
    2: runde := 'Rückrunde';
  end;


  (LabelConfigList[0] as TLabelConfig).fLabel := runde + ',  ' + 'Kampftag ' + inttostr(fWoche) + '/5';

  //Spieler ID = 6
  for i := 1 to high(cdKampfsaison.Vorrunde[fwoche].Kaempfe) do
  begin
    case frunde of
      1:  begin
            ID1 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K1_ID;
            ID2 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K2_ID;
            IDSieger := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].SiegerID;
          end;

      2:  begin
            ID1 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K1_ID;
            ID2 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K2_ID;
            IDSieger := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].SiegerID;
          end;
    end;

    if ID1 <> 6 then
    begin
      name1 := (cdGegner.gegner[ID1] as TSportler).Vorname +' '+ (cdGegner.gegner[ID1] as TSportler).Name;// + '(' + inttostr((cdGegner.gegner[ID1] as TSportler). )+ '.)';
    end else
    begin
      name1 := cdSpieler.Vorname;
    end;

    if ID2 <> 6 then
    begin
      name2 := (cdGegner.gegner[ID2] as TSportler).Vorname +' '+ (cdGegner.gegner[ID2] as TSportler).Name;
    end else
    begin
      name2 := cdSpieler.Vorname;
    end;

//    if ID1 <> 6 then
//    begin
//      name1 := (cdGegner.gegner[ID1] as TSportler).Vorname +' '+ (cdGegner.gegner[ID1] as TSportler).Name + ' Lv' +  inttostr((cdGegner.gegner[ID1] as TSportler).level) + '/R' + inttostr((cdGegner.gegner[ID1] as TSportler).rang);
//    end else
//    begin
//      form1.fSpielerKampfIndex := i;
//      name1 := cdSpieler.Vorname + ' Lv' +  inttostr(cdspieler.level) + '/R' + inttostr(cdSpieler.rang);
//    end;
//
//    if ID2 <> 6 then
//    begin
//      name2 := (cdGegner.gegner[ID2] as TSportler).Vorname +' '+ (cdGegner.gegner[ID2] as TSportler).Name+ ' Lv' +  inttostr((cdGegner.gegner[ID2] as TSportler).level) + '/R' + inttostr((cdGegner.gegner[ID2] as TSportler).rang);
//    end else
//    begin
//      form1.fSpielerKampfIndex := i;
//      name2 := cdSpieler.Vorname + ' Lv' +  inttostr(cdspieler.level) + '/R' + inttostr(cdSpieler.rang);
//    end;



    if (IDSieger <> 6) and (IDSieger <> 0) then
    begin
      siegername := (cdGegner.gegner[IDSieger] as TSportler).Vorname +' '+ (cdGegner.gegner[IDSieger] as TSportler).Name;
    end else if idsieger = 6 then
    begin
      siegername := cdSpieler.Vorname;
    end else if idsieger = 0 then
    begin
      siegername := '?';
    end;

    (self.LabelConfigList[i] as TLabelConfig).fLabel := Form1.CenterString(name1,20) + ' vs ' + Form1.CenterString(name2,20) + '  Sieger: ' + Form1.CenterString(siegername,20);
    (self.LabelConfigList[i] as TLabelConfig).y := (self.LabelConfigList[i] as TLabelConfig).y + 4;
  end;


  //  fGegner := Gegner;
//  fWeiterleitung := Weiterleitung;

//  (LabelConfigList[0] as TLabelConfig).fLabel := CenterString(cdSpieler.Vorname + ' ' + cdSpieler.name,20) + CenterString(' vs ',13) + CenterString(Gegner.Vorname + ' ' +Gegner.name,20);
//  (LabelConfigList[1] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Maximalkraft),20) + 'Maximalkraft' +  CenterString(inttostr(Gegner.Maximalkraft),20);
//  (LabelConfigList[2] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Kraftausdauer),20) + 'Kraftausdauer' +  CenterString(inttostr(Gegner.Kraftausdauer),20);
//  (LabelConfigList[3] as TLabelConfig).fLabel := CenterString(inttostr(cdSpieler.Technik),20) + '  Technik' +  CenterString(inttostr(Gegner.Technik),20);
//  (LabelConfigList[4] as TLabelConfig).fLabel :=
//  (LabelConfigList[5] as TLabelConfig).fLabel :=
end;

constructor TErholungsParkClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
var
  i : integer;
begin
  inherited create(dxdraw,engine);
  fweiterleitung := weiterleitung;
  (self.LabelConfigList[9] as TLabelConfig).fLabel := inttostr(cdSpieler.Kapital);

  (ImageConfigList[0] as TImageConfig).X := (LabelConfigList[9] as TLabelConfig).X + length((LabelConfigList[9] as TLabelConfig).flabel)*18+5;
  (ImageConfigList[0] as TImageConfig).Y := (LabelConfigList[9] as TLabelConfig).y-12;

  for i := 1 to 5 do
  begin
    fKosten[i] := i * 95;
    (self.LabelConfigList[2+i] as TLabelConfig).fLabel := inttostr(fKosten[i]);
  end;
  (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.fitness) + '/' + inttostr(cdspieler.FitnessMaximum);
end;

procedure TGameMenuClass.SetInfoText(Info:string); //MouseOver Ifos über Menüs
begin
  (self.LabelConfigList[9] as TLabelConfig).fLabel := Info;
end;

procedure TGameMenuClass.UpdateGameMenu;
var
  Runde : string;
  Woche:string;
  i : integer;
begin
  form1.Logger.Add('TGameMenuClass.UpdateGameMenu ' + cdZeit.TagString);

  // Liga-Runde
  case cdZeit.Runde of
    1:Runde := 'Hinrunde';
    2:Runde := 'Rückrunde';
  end;
  (self.LabelConfigList[0] as TLabelConfig).fLabel := inttostr(cdSpieler.Liga)+'.Liga - ' + Runde;

  //Kalender
//  if cdZeit.Woche < 10 then
//  begin
//    Woche := '0'+inttostr(cdZeit.Woche);
//  end else
//  begin
    Woche := inttostr(cdZeit.Woche);
//  end;
  (self.LabelConfigList[2] as TLabelConfig).fLabel := Woche+'/'+IntToStr(cUCDWochen);
  (self.LabelConfigList[3] as TLabelConfig).fLabel := cdZeit.TagString;

  //Nachrichten
  for i := 4 to 8 do
  begin
    (self.LabelConfigList[i] as TLabelConfig).fLabel := ' ';
  end;

  for i := 0 to cdEreignisse.Ereignisse.Count - 1 do
  begin
    if i > 4 then break;

    case strtoint(cdereignisse.artliste[i]) of
      0:(self.LabelConfigList[i+4] as TLabelConfig).FontStyle := 'news';
      1:(self.LabelConfigList[i+4] as TLabelConfig).FontStyle := 'news2';
    end;
   (self.LabelConfigList[i+4] as TLabelConfig).fLabel := cdEreignisse.Ereignisse[i];

  end;


  (labelconfiglist[10] as TLabelConfig).fLabel := 'Kapital: ' + inttostr(cdspieler.kapital);
  (labelconfiglist[11] as TLabelConfig).fLabel := 'Fitness: ' + inttostr(cdspieler.Fitness) + '/' + inttostr(cdspieler.FitnessMaximum);
  (imageconfiglist[1] as TImageConfig).x := (labelconfiglist[10] as TLabelConfig).X + length((labelconfiglist[10] as TLabelConfig).flabel)*11;
  (ButtonConfigList[14] as TButtonConfig).X := (labelconfiglist[11] as TLabelConfig).X + length((labelconfiglist[11] as TLabelConfig).flabel)*11 + 5;


  form1.Logger.Add('TGameMenuClass.UpdateGameMenu PASSED');
end;

constructor TGameMenuClass.Create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  Runde : string;
begin
  form1.Logger.Add('TGameMenuClass.create');

  try
    inherited create(form1.DXDraw1,form1.dxs1);

//    if not ((cdzeit.saison = 1) and (cdzeit.Woche = 1) and (cdzeit.Runde = 1) and (cdzeit.Tag = 1)) then
//    begin
//      Form1.CheckEreignisse; // Meldungen generieren
//    end;

    UpdateGameMenu;
    form1.Logger.Add('TGameMenuClass.create PASSED');
  except
    on e:exception do
    begin
      form1.Logger.Add('TGameMenuClass.create' + e.message);
      showmessage('Main->TGameMenuClass->Create: ' + e.message);
    end;
  end;
end;


procedure TCreatePlayerSMClass.ButtonPress(bIndex:integer);
begin
  form1.Logger.Add('TCreatePlayerSMClass.ButtonPress');

  case bIndex of
    0: begin
         (cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).IncLevel;
         Form1.NewMenu;
         Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
         Form1.DXDraw1.restore; {Darstellung aktualisieren}
         form1.Logger.Add('TCreatePlayerSMClass.ButtonPress PASSED');
         exit;
       end;
  end;
end;

constructor TCreatePlayerSMClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
begin
  form1.Logger.Add('TCreatePlayerSMClass.create');

  inherited create(dxdraw,engine);
  CPNow := 0;
  for i := 0 to 3 do
  begin
    koords[i].y := round(300/1.28);
    koords[i].x := round(190/1.28) + round(180/1.28) * i;
  end;
  form1.Logger.Add('TCreatePlayerSMClass.create PASSED');

end;

procedure TCreatePlayerSMClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  tt : TDIB;
  i : integer;
  Besch : string;
begin
  try
    //Markierung malen
    (self.ImageConfigList[0] as TImageConfig).X := Koords[CPNow].X-4;
    (self.ImageConfigList[0] as TImageConfig).Y := Koords[CPNow].Y-4;

    //Icons malen
    surface := TDirectDrawSurface.Create(fdxDraw.DDraw);

    for i := 0 to 3 do
    begin
      surface.LoadFromDIB((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Icon.DIB);
      fDXDraw.Surface.Draw(Koords[i].X,Koords[i].y,surface,false);
    end;

    //Infos anzeigen
    (self.LabelConfigList[1] as TLabelConfig).fLabel := (cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).Bezeichnung ;


    Besch := (cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).Beschreibung;
    (self.LabelConfigList[3] as TLabelConfig).fLabel := DeleteMindString((cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).Beschreibung);

    //Fähigkeiten der SMs anzeigen
    case CPNow of
      0:begin //Schlafstellung
          (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Kraftausdauer +' + inttostr((cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).SelfStrAusdProzent) + '%';
        end;

      1:begin //Schwitzende Hand
          (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Gegner Kraftausdauer ' + inttostr((cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).GegnerStrAusdProzent) + '%';
        end;

      2:begin //Kampfgebrüll
          (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Maximalkraft +' + inttostr((cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).SelfMaxStrProzent) + '%';
        end;

      3:begin //Hölzerne Hand
          (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Gegner Maximalkraft ' + inttostr((cdSpecialMoves.fSpecialMoves[CPNow] as TSpecialMove).GegnerMaxStrProzent) + '%';
        end;
    end;

    (self.LabelConfigList[1] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[1] as TLabelConfig).fLabel,45);
    (self.LabelConfigList[2] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[2] as TLabelConfig).fLabel,45);
    (self.LabelConfigList[3] as TLabelConfig).fLabel := CenterString((self.LabelConfigList[3] as TLabelConfig).fLabel,45);

  finally
    freeandnil(surface);
  end;
end;

procedure TCreatePlayerSMClass.MouseDown(x,y:integer);
var
  i : integer;
  kx,ky : integer;
begin
  for i := 0 to high(Koords) do
  begin
    kx := Koords[i].X;
    ky := Koords[i].Y;

    if (x >= kx) and (x <= kx+round(100/1.28)) and (y >= ky) and (y <= ky+round(100/1.28)) then
    begin
      CPNow := i;
      case CPNow of
        0:form1.PlaySchlafstellung;
        1:form1.playschwitzendehand;
        2:form1.playkampfgebruell;
        3:form1.playhoelzernehand;
      end;

      break;
    end;
  end;
end;

procedure TCreatePlayerClass.DrawMenuSpecific;
begin
  //Label 38
  if fshowBlinker > 10 then
  begin
    (self.ImageConfigList[1] as TImageConfig).X := round(220/1.28) + 14*Length(CPSpielerName);
    (self.ImageConfigList[1] as TImageConfig).Y := round(302/1.28);
    (self.ImageConfigList[1] as TImageConfig).visible := true;
    if fShowBlinker > 20 then fShowBlinker := 0;
  end else
  begin
    (self.ImageConfigList[1] as TImageConfig).visible := false;
  end;
  inc(fShowBlinker);

  (self.LabelConfigList[39] as TLabelConfig).fLabel := CPSpielerName;
end;

destructor TCreatePlayerClass.destroy;
begin
//  freeandnil(fsurface);
  inherited destroy;
end;

constructor TCreatePlayerClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
begin
  form1.Logger.Add('TCreatePlayerClass.create');


  CPSpielerName := 'BOMBER';
  fShowblinker := 0;
  fInfoText := 1;
  try
    inherited create(dxdraw,engine);

    form1.Logger.Add('TCreatePlayerClass.create -> inherited create passed');

    for i := 0 to self.LabelConfigList.Count - 1 do
    begin
      case i of
        12..19: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
        20..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
      end;
    end;

    (self.LabelConfigList[6] as TLabelConfig).fLabel := '21';
    (self.LabelConfigList[11] as TLabelConfig).fLabel := '15';

//    form1.FEdit.left := 220;
//    form1.FEdit.Top := 280;
//    form1.FEdit.Width := 210;
//    form1.FEdit.Font.Size := 18;
//    form1.FEdit.Color := clBlack;
//    form1.FEdit.Font.Color := clwhite;
//    form1.FEdit.Text := 'Bomber';
//    form1.fShowEdit := true;

  except
    on e:exception do
    begin
      form1.Logger.Add('TCreatePlayerClass.create ' + e.message);
      showmessage('Main->TCreatePlayerClass->Create: ' + e.message);
    end;
  end;
end;

procedure TForm1.ResetGameData;
begin
  form1.Logger.Add('TForm1.ResetGameData');

  freeandnil(cdOtherData);
  freeandnil(cdKampfsaison);
  freeandnil(cdSpieler);
  freeandnil(cdGegner);
  freeandnil(cdZeit);
  freeandnil(cdEreignisse);
  freeandnil(cdSponsoren);
  freeandnil(cdTurniere);
  freeandnil(cdAusruestungen);
  freeandnil(cdSportshop);
  freeandnil(cdSpecialMoves);

  form1.Logger.Add('TForm1.ResetGameData PASSED');

end;

procedure TForm1.NewGameData;
begin
//  cdOtherData := TOtherData.create;
//  cdKampfsaison := TKampfsaison.Create;
//
//  if length(form1.FEdit.text) > 21 then
//    form1.FEdit.Text := copy(form1.FEdit.Text,1,20);
//
//  cdSpieler := TSpieler.Create(form1.FEdit.Text,' ',strtoint((self.LabelConfigList[7] as TLabelConfig).fLabel), strtoint((self.LabelConfigList[8] as TLabelConfig).fLabel),strtoint((self.LabelConfigList[10] as TLabelConfig).fLabel),3,0,0,strtoint((self.LabelConfigList[6] as TLabelConfig).fLabel),0,0,0,100,1,1,1,1,0,strtoint((self.LabelConfigList[9] as TLabelConfig).fLabel),0,nil,nil);
//  cdGegner := TGegner.Create(3);
//  cdZeit := TZeit.Create(1,1,1,1);
//  cdEreignisse := TEreignisse.create;
//
//  cdSponsoren := TSponsoren.create;
//  cdKneipe := TKneipe.Create;
//  cdTurniere := TTurniere.Create;
//
//  cdAusruestungen := TAusruestungen.create;
//  cdSportshop := TSportshop.create;
end;

procedure TCreatePlayerClass.ButtonPress(bIndex:integer);
var
  zahl:integer;
  temp:string;
  i : integeR;
  AusruestungRuck : TObjectList;
  AusruestungAn : TObjectList;
  Sponsoren : TObjectList;
  test : integer;
  spielername : string;
begin
  form1.Logger.Add('TCreatePlayerClass.buttonpress');

  try
    case bIndex of
      13: begin
            form1.ResetGameData;
            Form1.NewMenu;
            Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end;

      12: begin
            // Neues Spiel
//            Form1.NewGameData;
            cdOtherData := TOtherData.create;
            cdKampfsaison := TKampfsaison.Create;

            //spielername := 'Bomber';
//            if length(form1.FEdit.text) > 25 then
//              form1.FEdit.Text := copy(form1.FEdit.Text,1,25);

            cdGegner := TGegner.Create(5);
            cdZeit := TZeit.Create(1,1,1,1);

            cdEreignisse := TEreignisse.create;
            //Starttext anzeigen:

            cdEreignisse.AddEreignis('Willkommen bei Armwrestling Champion',1);
            cdEreignisse.AddEreignis('Treten Sie zum ersten Mal in die Fußstapfen');
            cdEreignisse.AddEreignis('eines Armwrestlers ? Mit einem Mausklick auf');
            cdEreignisse.AddEreignis('das Fragezeichen am unteren Bildschirmrand');
            cdEreignisse.AddEreignis('bringen Sie Ihre Karriere in Schwung.');


            cdSponsoren := TSponsoren.create;
            cdKneipe := TKneipe.Create;

            cdSpecialMoves := TSpecialMoves.create;
            cdAusruestungen := TAusruestungen.create;
            cdSportshop := TSportshop.create;

            //Test
            AusruestungRuck := TObjectList.Create;
            AusruestungAn := TObjectList.create;
            Sponsoren := TObjectList.create;

//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(0));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(1));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(2));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(3));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(4));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(5));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(6));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(7));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(8));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(9));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(10));

//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(11));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(12));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(13));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(14));
//            AusruestungRuck.Add(cdAusruestungen.CreateAusruestung(15));

            //AusruestungAn.Add(cdAusruestungen.CreateAusruestung(18));
            //AusruestungAn.Add(cdAusruestungen.CreateAusruestung(19));
//            AusruestungAn.Add(cdAusruestungen.CreateAusruestung(20));

            //---
            cdSpieler := TSpieler.Create(cpspielername,' ',strtoint((self.LabelConfigList[7] as TLabelConfig).fLabel), strtoint((self.LabelConfigList[8] as TLabelConfig).fLabel),strtoint((self.LabelConfigList[10] as TLabelConfig).fLabel),5,0,0,strtoint((self.LabelConfigList[6] as TLabelConfig).fLabel),0,0,0,100,1,1,1,1,0,strtoint((self.LabelConfigList[9] as TLabelConfig).fLabel),0,AusruestungRuck,AusruestungAn,Sponsoren,0,0,0,0,0,strtoint((self.LabelConfigList[9] as TLabelConfig).fLabel));
            cdspieler.regenerationsrate := 15;

            cdspieler.fLevelUpPoints := 100;
            //            cdspieler.Kapital := 4000;
            //cdspieler.fLevelUpPoints := 100;

            //cdSpieler.fLevelUpPoints := 500;
            //cdSpieler.Technik := 500;
            //cdspieler.Erfahrung := 200;

//              cdspieler.Level := 1;
//              cdspieler.Kapital := 20000;
//              cdSpieler.fLevelUpPoints := 100;
//              cdspieler.Fitness := 44;
//              cdspieler.Maximalkraft := 5000;
//              cdspieler.Ansehen := 5000;
//              cdspieler.Liga := 1;
//              cdspieler.Level := 21;
//              cdspieler.Technik := 1000;
//              cdspieler.Kraftausdauer := 1000;
//              cdspieler.fLevelUpPoints := 999;
//                cdspieler.Maximalkraft := 12000;
//                cdspieler.Kraftausdauer := 5400;

            //TEST
            with cdspieler do
            begin
//              TurnierKneipeSieg := true;
//              TurnierBeginnersCornerSieg := true;
//              TurnierProfiturnierSieg := true;
//              TurnierEuropameisterschaftSieg := true;
//              TurnierSportCafeTurnierSieg := true;
//              TurnierRummelRingenSieg := true;
//              TurnierProletenClubSieg := true;
//              TurnierSemiProTurnier := true;
//              TurnierWeltmeisterschaft := true;
//              TurnierMeisterTurnier := true;
//              meisterschaften5 := 1;
//              meisterschaften4 := 1;
//              meisterschaften3 := 1;
//              meisterschaften2 := 1;
//              meisterschaften1 := 1;
            end;
            //TEST

            //cdspieler.Kapital := 2000;
//            cdSpieler.Level := 25;

            cdTurniere := TTurniere.Create;

            cdSponsoren.ResetSponsoren;
            cdSportshop.ResetSportShop;
            cdKneipe.ResetKneipe;

            Form1.NewMenu;
            Form1.fActiveMenu := TCreatePlayerSMClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end;

      {MaxKraft}
      4:  begin //hoch
            if strtoint((self.LabelConfigList[11] as TLabelConfig).fLabel) > 0 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[7] as TLabelConfig).fLabel := form1.IncString((self.LabelConfigList[7] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.DecString((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      5: begin //runter
            if strtoint((self.LabelConfigList[7] as TLabelConfig).fLabel) > 10 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[7] as TLabelConfig).fLabel := form1.DecString((self.LabelConfigList[7] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
         end;

      {Kraftausdauer}
      6: begin //hoch
            if strtoint((self.LabelConfigList[11] as TLabelConfig).fLabel) > 0 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[8] as TLabelConfig).fLabel := form1.IncString((self.LabelConfigList[8] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.DecString((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      7: begin //runter
            if strtoint((self.LabelConfigList[8] as TLabelConfig).fLabel) > 10 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[8] as TLabelConfig).fLabel := form1.decstring((self.LabelConfigList[8] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      {Alter}
      2: begin //hoch
            if strtoint((self.LabelConfigList[6] as TLabelConfig).fLabel) < 66 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[6] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[6] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      3: begin //runter
            if strtoint((self.LabelConfigList[6] as TLabelConfig).fLabel) > 18 then
            begin
             form1.PlayUpDown;
             (self.LabelConfigList[6] as TLabelConfig).fLabel := form1.decstring((self.LabelConfigList[6] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      {Fitness}
      8: begin //hoch
            if strtoint((self.LabelConfigList[11] as TLabelConfig).fLabel) > 0 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[9] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[9] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.decstring((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      9: begin //runter
            if strtoint((self.LabelConfigList[9] as TLabelConfig).fLabel) > 10 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[9] as TLabelConfig).fLabel := form1.decstring((self.LabelConfigList[9] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      {Technik}
      10: begin //hoch
            if strtoint((self.LabelConfigList[11] as TLabelConfig).fLabel) > 0 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[10] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[10] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.decstring((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      11: begin //runter
            if strtoint((self.LabelConfigList[10] as TLabelConfig).fLabel) > 10 then
            begin
              form1.PlayUpDown;
              (self.LabelConfigList[10] as TLabelConfig).fLabel := form1.DecString((self.LabelConfigList[10] as TLabelConfig).fLabel);
              (self.LabelConfigList[11] as TLabelConfig).fLabel := form1.incstring((self.LabelConfigList[11] as TLabelConfig).fLabel);
            end else
            begin
              form1.PlayNo;
            end;
          end;

      {Info-Text}
      0: begin //hoch
            form1.PlayUpDown;
            inc(fInfoText);
            if fInfoText > 4 then fInfoText := 1;
            case fInfoText of
              1:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..19: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                      20..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                    end;
                  end;
                end;
              2:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..19: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                      20..24: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                      25..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                    end;
                  end;
                end;
              3:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..24: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                      25..31: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                      32..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                    end;
                  end;
                end;
              4:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..31: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                      32..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                    end;
                  end;
                end;
            end;
         end;

      1: begin //runter
            form1.PlayUpDown;
            dec(fInfoText);
            if fInfoText < 1 then fInfoText := 4;
            case fInfoText of
              1:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..19: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                      20..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                    end;
                  end;
                end;
              2:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..19: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                      20..24: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                      25..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                    end;
                  end;
                end;
              3:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..24: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                      25..31: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                      32..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                    end;
                  end;
                end;
              4:begin
                  for i := 12 to 38 do
                  begin
                    case i of
                      12..31: (self.LabelConfigList[i] as TLabelConfig).fVisible := false;
                      32..38: (self.LabelConfigList[i] as TLabelConfig).fVisible := true;
                    end;
                  end;
                end;
              end;
            end;
         end;
  form1.Logger.Add('TCreatePlayerClass.buttonpress PASSED');

  except
    on e:exception do
    begin
      form1.Logger.Add('TCreatePlayerClass.buttonpress ' + e.message);
      showmessage('Main->TCreatePlayerClass->ButtonPress: ' + e.message);
    end;
  end;

end;

function TForm1.IncLabelValue(Lab:TLabel):boolean;
var
  zahl : integer;
begin
  try
    zahl := strtoint(lab.Caption);
    inc(zahl);

    if zahl < 10 then
    begin
      lab.Caption := '0'+inttostr(zahl);
    end else
    begin
      lab.Caption := inttostr(zahl);
    end;
  except
    on e:exception do
      showmessage('Main->IncLabelValue: ' + e.message);
  end;
end;

function TForm1.DecLabelValue(Lab:TLabel):boolean;
var
  zahl : integer;
begin
  try
    result := false;
    zahl := strtoint(lab.Caption);
    if zahl>0 then
    begin
      dec(zahl);
      result := true;
    end;

    if zahl < 10 then
    begin
      lab.Caption := '0'+inttostr(zahl);
    end else
    begin
      lab.Caption := inttostr(zahl);
    end;
  except
    on e:exception do
      showmessage('Main->DecLabelValue: ' + e.message);
  end;
end;

procedure TGameMenuClass.MouseButtonOver(bIndex:integer);
begin
  try
    case bIndex of
      -1: SetInfoText(' ');
      0:  begin // Optionen
            SetInfoText(cOptionen);
          end;

      1: begin // Kalender
            SetInfoText(cKalender);
         end;

      2: begin // Kampfliste
           SetInfoText(cKampfliste);
         end;

      3: begin // Kneipe
            SetInfoText(cKneipe);
         end;

      4: begin // Personal
            SetInfoText(cPersonal);
         end;

      5: begin // Shop
            SetInfoText(cSportshop);
         end;

      6: begin // Sponsoren
            SetInfoText(cSponsor);
         end;

      7: begin // Tabelle
            SetInfoText(cTabelle);
         end;

      8: begin // Training
            SetInfoText(cTraining);
         end;

      9: begin // Turniere
            SetInfoText(cTurniere);
         end;

      10: begin // Vergleich
            SetInfoText(cWohnung);
         end;

      11: begin // Pokale
            SetInfoText(cPokale);
         end;

      12: begin // Mucke
            SetInfoText(cMucke);
         end;

      13: begin // Hilfe
            SetInfoText(cHelp);
         end;
    end;
  except
    on e:exception do
      showmessage('Main->TGameMenuClass->MouseButtonOver: ' + e.message);
  end;
end;

procedure TGameMenuClass.ButtonPress(bIndex:integer);
begin
  //-> Zufallsereignisse, Datum, ... : DrawMenuSpecific implementieren
 form1.Logger.Add('TGameMenuClass.buttonpress');

  try
    case bIndex of
      0: begin // Optionen
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TOptionsMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'gamemenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      1: begin // Kalender
            form1.PlayKalender;
            cdZeit.IncDay;

            //-> CheckEreignisse muss immer vor NextWeek kommen !!! spieler-Sponsoren Test

            if cdzeit.Tag <> 1 then
            begin
              Form1.CheckEreignisse; // Meldungen generieren
            end;

            UpdateGameMenu; // SpielMenü - Anzeigen aktualisieren
            if cdZeit.NextWeek then
            begin
              cdGegner.ImproveValues;
              cdZeit.NextWeek := false;
              cdSponsoren.ResetSponsoren;
              cdSportshop.ResetSportShop;
              cdKneipe.ResetKneipe;
              form1.CheckEreignisse;
              form1.FightDay;

              //Test
              //cdZeit.NextRound := true;
              //cdZeit.NextSaison := true;
              //Test

              exit;
            end;

            //Findet heute ein Turnier statt?
            if (cdTurniere.HeuteTurnier <> -1) and ((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Angemeldet=true) then
            begin
              inc(cdSpieler.Turnierteilnahmen);
              Form1.NewMenu;
              //Form1.fActiveMenu := TTurnierStartMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.fActiveMenu := TVorTurnierStartMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;

            {
              Prüfen:
              - Tag = Samstag ?
              - Woche = 19 ?
              - Runde = 2 ?
              - Woche/Tag := Turnier Termin
              - Sponsor abgelaufen ? -> Meldung
            }

//            Form1.NewMenu;
//            Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//            Form1.DXDraw1.restore; {Darstellung aktualisieren}
         end;

      2: begin // Kampfliste
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TKampflistenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      3: begin // Kneipe
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TKneipenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      4: begin // Personal
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TPSEigenschaftenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      5: begin // Shop
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TEinkaufenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      6: begin // Sponsoren
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TSponsorenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      7: begin // Tabelle
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TRanglistenMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      8: begin // Training
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      9: begin // Turniere
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TTurnierMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      10: begin // Vergleich
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TWohnungsMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'gamemenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      11: begin // Pokale
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu;
            Form1.fActiveMenu := TPokaleMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;

      12: begin // Mucke
            cdereignisse.DeleteAllEreignisse;
            Form1.NewMenu; //Menu kicken
            Form1.fActiveMenu := TMuckeMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'gamemenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
         end;

      13: begin // Hilfe
            Form1.NewMenu; //Menu kicken
            Form1.fActiveMenu := THilfeMenuClass.Create(Form1.DXDraw1,Form1.dxs1,'gamemenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
         end;

      14: begin // Erholung
            Form1.NewMenu; //Menu kicken
            Form1.fActiveMenu := TErholungsParkClass.Create(Form1.DXDraw1,Form1.dxs1,'gamemenu'); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
         end;


    end;
    form1.Logger.Add('TGameMenuClass.buttonpress PASSED');

  except
    on e:exception do
    begin
      form1.Logger.Add('TGameMenuClass.buttonpress ' + e.message);
      showmessage('Main->TGameMenuClass->ButtonPress: ' + e.message);
    end;
  end;
end;


procedure TKneipenMenuClass.MouseDown(x,y:integer);
var
  i : integer;
  LabelCount : integer;
  GegnerIndex : integer;
  lX,lY,lW,lH : integer;
  GegnerWahl : TKneipenGegner;
begin
//  for i := 5 to self.LabelConfigList.Count - 1 do
//  begin
//    (self.LabelConfigList[i] as TLabelConfig).fLabel := ' ';
//  end;

  LabelCount := 0;
  GegnerWahl := nil;
  for i := 0 to cdKneipe.GegnerListe.Count - 1 do
  begin
    if (cdKneipe.GegnerListe[i] as TKneipenGegner).ErscheinungsTag = cdZeit.Tag then
    begin
      lX := (LabelConfigList[LabelCount] as TLabelConfig).X;
      lY := (LabelConfigList[LabelCount] as TLabelConfig).Y;
      lW := 360;//(LabelConfigList[LabelCount] as TLabelConfig).W;
      lH := 40;//(LabelConfigList[LabelCount] as TLabelConfig).H;
      if (x > lX) and (x < lX+lW) and (y > lY) and (y < lY + lH) then
      begin
        GegnerWahl := cdKneipe.GegnerListe[i] as TKneipenGegner;
        fAktuellerGegnerIndex := i;
        fAktuellerIndex := LabelCount;
        break;
      end;
      inc(LabelCount);
    end;
  end;

  if GegnerWahl <> nil then
  begin
    fAktuellerGegner := GegnerWahl;
    (self.LabelConfigList[5] as TLabelConfig).fLabel := form1.centerstring('       Level: ' + inttostr((fAktuellerGegner as TKneipenGegner).level), 18);
    (self.LabelConfigList[6] as TLabelConfig).fLabel := form1.centerstring(' Maximalkraft: ' + inttostr((fAktuellerGegner as TKneipenGegner).Maximalkraft), 18);
    (self.LabelConfigList[7] as TLabelConfig).fLabel := form1.centerstring('Kraftausdauer: ' + inttostr((fAktuellerGegner as TKneipenGegner).Kraftausdauer), 18);
    (self.LabelConfigList[8] as TLabelConfig).fLabel := form1.centerstring('      Technik: ' + inttostr((fAktuellerGegner as TKneipenGegner).Technik), 18);
    (self.LabelConfigList[9] as TLabelConfig).fLabel := form1.centerstring('      Fitness: ' + inttostr((fAktuellerGegner as TKneipenGegner).Fitness), 18);
    (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Wetteinsatz: ' + inttostr((fAktuellerGegner as TKneipenGegner).WettBetrag);
    //(self.LabelConfigList[11] as TLabelConfig).fLabel := inttostr((cdKneipe.GegnerListe[i] as TKneipenGegner);

    (ImageConfigList[1] as TImageConfig).X := (LabelConfigList[10] as TLabelConfig).X + length((self.LabelConfigList[10] as TLabelConfig).fLabel)*15;
    (ImageConfigList[1] as TImageConfig).Y := (LabelConfigList[10] as TLabelConfig).y-10;
  end;

 (self.ImageConfigList[0] as TImageConfig).X := -10;//(self.LabelConfigList[fAktuellerIndex] as TLabelConfig).X;
 (self.ImageConfigList[0] as TImageConfig).Y := (self.LabelConfigList[fAktuellerIndex] as TLabelConfig).Y-4;
end;


procedure TKneipenMenuClass.MouseButtonOver(bIndex:integer);
begin
  case bindex of
    1 : fMinus := true;
  end;
end;

procedure TKneipenMenuClass.DrawMenuSpecific;
var
  laenge : integer;
begin
  laenge := -5;
  form1.DXPowerFont1.Font := 'Font3';
  if not fMinus then
  begin
    laenge := length('Kapital: ' + inttostr(cdSpieler.Kapital));
    form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,1,570,'Kapital: ' + inttostr(cdSpieler.Kapital))
  end else
  begin
    if fAktuellerGegnerIndex <> -1 then
    begin
      laenge := length('Kapital: ' + inttostr(cdSpieler.Kapital-(cdKneipe.GegnerListe[fAktuellerGegnerIndex] as TKneipengegner).WettBetrag));
      form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,1,570,'Kapital: ' + inttostr(cdSpieler.Kapital-(cdKneipe.GegnerListe[fAktuellerGegnerIndex] as TKneipengegner).WettBetrag));
    end else
    begin
      laenge := length('Kapital: ' + inttostr(cdSpieler.Kapital));
      form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,1,570,'Kapital: ' + inttostr(cdSpieler.Kapital))
    end;
  end;
  fMinus := false;

  (ImageConfigList[2] as TImageConfig).X := 1 + laenge*15+5;
  (ImageConfigList[2] as TImageConfig).Y := 560;
end;


constructor TKneipenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
  LabelCount : integer;
  ETag : integer;
begin
  form1.Logger.Add('TKneipenMenuClass.create');

  inherited create(dxdraw,engine);
  fMinus := false; //Kapital minus Wetteinsatz anzeigen?
  fAktuellerIndex := 0;
  fAktuellerGegnerIndex := -1;

  for i := 0 to self.LabelConfigList.Count - 2 do
  begin
    (self.LabelConfigList[i] as TLabelConfig).fLabel := ' ';
  end;

//  (self.LabelConfigList[5] as TLabelConfig).fLabel := form1.centerstring('       Level: ',18);
//  (self.LabelConfigList[6] as TLabelConfig).fLabel := form1.centerstring(' Maximalkraft: ',18);
//  (self.LabelConfigList[7] as TLabelConfig).fLabel := form1.centerstring('Kraftausdauer: ',18);
//  (self.LabelConfigList[8] as TLabelConfig).fLabel := form1.centerstring('      Technik: ',18);
//  (self.LabelConfigList[9] as TLabelConfig).fLabel := form1.centerstring('      Fitness: ',18);
//  (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Wetteinsatz: ';

  LabelCount := 0;
  fAktuellerGegner := nil;
  for i := 0 to cdKneipe.GegnerListe.Count - 1 do
  begin
    eTag := (cdKneipe.GegnerListe[i] as TKneipenGegner).ErscheinungsTag;
    if (cdKneipe.GegnerListe[i] as TKneipenGegner).ErscheinungsTag = cdZeit.Tag then
    begin
      if fAktuellerGegner = nil then
      begin
        fAktuellerGegner := cdKneipe.GegnerListe[i] as TKneipenGegner;
        fAktuellerGegnerIndex := i;
      end;
      (self.LabelConfigList[LabelCount] as TLabelConfig).fLabel := Form1.CenterString((cdKneipe.GegnerListe[i] as TKneipenGegner).Vorname + ' ' + (cdKneipe.GegnerListe[i] as TKneipenGegner).Name,18);
      inc(LabelCount);

      if trim((self.LabelConfigList[5] as TLabelConfig).fLabel) = '' then
      begin
        (self.LabelConfigList[5] as TLabelConfig).fLabel := form1.centerstring('       Level: ' + inttostr((fAktuellerGegner as TKneipenGegner).level), 18);
        (self.LabelConfigList[6] as TLabelConfig).fLabel := form1.centerstring(' Maximalkraft: ' + inttostr((fAktuellerGegner as TKneipenGegner).Maximalkraft), 18);
        (self.LabelConfigList[7] as TLabelConfig).fLabel := form1.centerstring('Kraftausdauer: ' + inttostr((fAktuellerGegner as TKneipenGegner).Kraftausdauer), 18);
        (self.LabelConfigList[8] as TLabelConfig).fLabel := form1.centerstring('      Technik: ' + inttostr((fAktuellerGegner as TKneipenGegner).Technik), 18);
        (self.LabelConfigList[9] as TLabelConfig).fLabel := form1.centerstring('      Fitness: ' + inttostr((fAktuellerGegner as TKneipenGegner).Fitness), 18);
        (self.LabelConfigList[10] as TLabelConfig).fLabel := 'Wetteinsatz: ' + inttostr((fAktuellerGegner as TKneipenGegner).WettBetrag);

        (ImageConfigList[1] as TImageConfig).X := (LabelConfigList[10] as TLabelConfig).X + length((self.LabelConfigList[10] as TLabelConfig).fLabel)*15;
        (ImageConfigList[1] as TImageConfig).Y := (LabelConfigList[10] as TLabelConfig).y-10;

        //(self.LabelConfigList[11] as TLabelConfig).fLabel := inttostr((cdKneipe.GegnerListe[i] as TKneipenGegner);
      end;
    end;
  end;
  (self.ImageConfigList[0] as TImageConfig).X := -10;//(self.LabelConfigList[fAktuellerIndex] as TLabelConfig).X;
  (self.ImageConfigList[0] as TImageConfig).Y := (self.LabelConfigList[fAktuellerIndex] as TLabelConfig).Y-4;

  //(self.ImageConfigList[0] as TImageConfig).alpha := 50;
  form1.Logger.Add('TKneipenMenuClass.create PASSED');

end;

procedure TKneipenMenuClass.ButtonPress(bIndex:integer);
var
  AktuellerGegnerIndex:integer;
begin
  try
    case bIndex of
      0 : begin // Back
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;

      1 : begin // Challenge
              if fAktuellerGegnerIndex <> -1 then
              begin
                //Geld weg
                if cdSpieler.Kapital >= (cdKneipe.GegnerListe[fAktuellerGegnerIndex] as TKneipengegner).WettBetrag then
                begin
                  cdSpieler.Kapital := cdSpieler.Kapital - (cdKneipe.GegnerListe[fAktuellerGegnerIndex] as TKneipengegner).WettBetrag;
                  aktuellerGegnerIndex := fAktuellerGegnerIndex;
                  Form1.NewMenu;
                  Form1.fActiveMenu := TVorKampfAllgemeinMenuClass.Create(Form1.DXDraw1,Form1.dxs1,cdKneipe.GegnerListe[AktuellerGegnerIndex] as TKneipenGegner,'nachKneipenkampf'); {Neues Menüobjekt erzeugen}
                  Form1.DXDraw1.restore; {Darstellung aktualisieren}
                  exit;
                end else
                begin
                  form1.PlayNo;
                end;
              end else
              begin
                form1.PlayNo;
              end;
                //    fAktuellerGegner : TKneipenGegner;
//    fAktuellerIndex : integer;

//              Form1.NewMenu;
//              Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//              Form1.DXDraw1.restore; {Darstellung aktualisieren}
            end;
    end;
  except
    on e:exception do
      showmessage('Main->TKneipenMenuClass->ButtonPress: ' + e.message);
  end;
end;

constructor TTabellenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  Liste : TObjectList;
  i : integer;
  n : string;
  rang : integer;
  rangs : integer;
begin
  form1.Logger.Add('TTabellenMenuClass.create');

  inherited create(dxdraw,engine);

//  (ImageConfigList[0] as TImageConfig).alpha := 100;

  Liste := TObjectList.Create;
  try
    //Liste sortiert nach Punkten holen
    cdGegner.GetListByPoints(Liste);

    //Liste an die Wand klatschen
    (self.LabelConfigList[0] as TLabelConfig).fLabel := ' Rang   Name          Siege  Niederlagen';
    rangs := 1;
    for i := 0 to Liste.count - 1 do
    begin
      if i > 0 then
      begin
        if (Liste[i] as TSportler).Siege < (Liste[i-1] as TSportler).Siege then
        begin
          rang := i+1;
          rangs := i+1;
        end else
        begin
          rang := rangs;
        end;
      end else
      begin
        rang := i+1;
      end;

      (self.LabelConfigList[i+1] as TLabelConfig).fLabel :=  form1.MakeStringLeft(inttostr(rang) + '.',4) + form1.MakeStringLeft(trim((Liste[i] as TSportler).Vorname + ' ' + (Liste[i] as TSportler).Name),22) + '  '  + form1.MakeStringLeft(inttostr((Liste[i] as TSportler).Siege),8) + '  ' + form1.MakeStringLeft(inttostr((Liste[i] as TSportler).Niederlagen),12);
      if (Liste[i] as TSportler).Name = cdSpieler.Vorname then
      begin
        (ImageConfigList[0] as TImageConfig).y := (self.LabelConfigList[i+1] as TLabelConfig).Y - 5;
      end;
    end;
    form1.Logger.Add('TTabellenMenuClass.create PASSED');

  finally
    freeandnil(Liste);
  end;
end;
                             

procedure TVorTurnierStartMenuClass.ButtonPress(bIndex:integer);
begin
  case bindex of
    0:  begin
          Form1.NewMenu;
          Form1.fActiveMenu := TTurnierStartMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
          Form1.DXDraw1.restore; {Darstellung aktualisieren}
          exit;
        end;
  end;
end;

constructor TVorTurnierStartMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  bez : string;
  anzahl : integer;
  beschreibung : string;
  beschreibung2 : string;
  beschreibung0 : string;
  preis : integer;
  schnitt : integer;
  i : integer;
begin
  inherited create(form1.DXDraw1,form1.dxs1);

  //Level des Spielers aktualisieren
  for i := 0 to high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer) do
  begin
    if (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[i].IstSpieler then
    begin
      (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer[i].level := cdspieler.level;
    end;
  end;

  bez := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Bezeichnung;
  anzahl := high((cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Teilnehmer);
  preis := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).PreisGeld;
  beschreibung0 := (cdTurniere.fTurniere[cdTurniere.HeuteTurnier] as TTurnier).Beschreibung;

  Beschreibung := '';
  beschreibung2 := '';
  if length(beschreibung0) > 53 then
  begin
    beschreibung := copyAtSpace(beschreibung0,53,schnitt);
    beschreibung2 := copy(beschreibung0,schnitt+1,Length(beschreibung0)-schnitt);
  end else
  begin
    beschreibung := beschreibung0;
  end;

  (LabelConfigList[0] as TLabelConfig).fLabel := CenterString(bez,53);
  (LabelConfigList[1] as TLabelConfig).fLabel := CenterString(beschreibung,53);
  (LabelConfigList[2] as TLabelConfig).fLabel := CenterString(beschreibung2,53);

  (LabelConfigList[3] as TLabelConfig).fLabel := CenterString('Es sind ' + inttostr(anzahl+1) + ' Teilnehmer gemeldet.',53);
  (LabelConfigList[4] as TLabelConfig).fLabel := CenterString('Der Turniersieger erhält neben Ruhm und Ehre',53);
  (LabelConfigList[5] as TLabelConfig).fLabel := CenterString('zusätzlich eine Siegprämie von ' + inttostr(preis),53);
  (LabelConfigList[6] as TLabelConfig).fLabel := ' ';

  (ImageConfigList[0] as TImageConfig).X := (LabelConfigList[5] as TLabelConfig).X + 26*15 + 6 + (length(trim((self.LabelConfigList[5] as TLabelConfig).fLabel))*13) div 2;
  (ImageConfigList[0] as TImageConfig).Y := (LabelConfigList[5] as TLabelConfig).y-7;
end;

procedure TTabellenMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0 : begin
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;
    end;
  except
    on e:exception do
      showmessage('Main->TTabellenMenuClass->ButtonPress: ' + e.message);
  end;
end;

procedure TTurnierMenuClass.MouseOver(x,y:integer);
begin
  if (fAktuellesTurnier <> nil) then
  begin
    if not (fAktuellesTurnier as TTurnier).Angemeldet then
    begin
      if (x > round(550/1.28)) and (x < round(550/1.28) + round(260/1.28)) and (y > round(550/1.28)) and (y < round(550/1.28) + round(75/1.28)) then
      begin
        (self.ImageConfigList[0] as TImageConfig).visible := false;
        (self.ImageConfigList[1] as TImageConfig).visible := true;
        (self.ImageConfigList[2] as TImageConfig).visible := false;
      end else
      begin
        (self.ImageConfigList[0] as TImageConfig).visible := false;
        (self.ImageConfigList[1] as TImageConfig).visible := false;
        (self.ImageConfigList[2] as TImageConfig).visible := true;
      end;
    end;
  end;
end;

procedure TTurnierMenuClass.MouseDown(x,y:integer);
var
  i : integer;
  LabelCount : integer;
  GegnerIndex : integer;
  lX,lY,lW,lH : integer;
  TurnierWahl : TTurnier;
begin
  if not ((x > round(550/1.28)) and (x < round(550/1.28) + round(260/1.28)) and (y > round(550/1.28)) and (y < round(550/1.28) + round(75/1.28))) then
  begin
//    (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.centerstring('Woche ',22) ;
//    (self.LabelConfigList[1] as TLabelConfig).fLabel := form1.centerstring('Teilnehmer: ',22);
//    (self.LabelConfigList[2] as TLabelConfig).fLabel := form1.centerstring('Ab Liga: ',22);
//    (self.LabelConfigList[3] as TLabelConfig).fLabel := form1.centerstring('Ab Level: ',22);
//    (self.LabelConfigList[4] as TLabelConfig).fLabel := form1.centerstring('Ab Ansehen: ',22);
//    (self.LabelConfigList[5]  as TLabelConfig).fLabel := 'Startgebühr: ';
//    (self.LabelConfigList[6]  as TLabelConfig).fLabel := ' Siegprämie: ';
  end;

  LabelCount := 7;
  TurnierWahl := nil;
  for i := 0 to cdTurniere.fTurniere.Count - 1 do
  begin
    if LabelCount > 13 then break;

    if (cdTurniere.fTurniere[i] as TTurnier).show then
    begin
      lX := (LabelConfigList[LabelCount] as TLabelConfig).X;
      lY := (LabelConfigList[LabelCount] as TLabelConfig).Y;
      lW := 420;//(LabelConfigList[LabelCount] as TLabelConfig).W;
      lH := 45;//(LabelConfigList[LabelCount] as TLabelConfig).H;
      if (x > lX) and (x < lX+lW) and (y > lY) and (y < lY + lH) then
      begin
        TurnierWahl := cdTurniere.fTurniere[i] as TTurnier;
        fAktuellerIndex := LabelCount;
        break;
      end;
      inc(LabelCount);
    end;
  end;

  if TurnierWahl <> nil then
  begin
    fAktuellesTurnier := TurnierWahl;
    (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.centerstring('Woche '+inttostr((cdTurniere.fTurniere[i] as TTurnier).Termin.Woche) +'/5' + ' ' + (cdTurniere.fTurniere[i] as TTurnier).Termin.TagstringGanz,22) ;
    (self.LabelConfigList[1] as TLabelConfig).fLabel := form1.centerstring('Teilnehmer: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).AnzahlGegner+1),22);
    (self.LabelConfigList[2] as TLabelConfig).fLabel := form1.centerstring('Ab Liga: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).MinLiga),22);
    (self.LabelConfigList[3] as TLabelConfig).fLabel := form1.centerstring('Ab Level: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).MinLevel),22);
    (self.LabelConfigList[4] as TLabelConfig).fLabel := form1.centerstring('Ab Ansehen: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).MinAnsehen),22);
    (self.LabelConfigList[5]  as TLabelConfig).fLabel := 'Startgebühr: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).Startgebuehr);
    (self.LabelConfigList[6]  as TLabelConfig).fLabel := ' Siegprämie: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).PreisGeld);

    (ImageConfigList[4] as TImageConfig).X := (LabelConfigList[5] as TLabelConfig).X + length((self.LabelConfigList[5]  as TLabelConfig).fLabel)*15;
    (ImageConfigList[4] as TImageConfig).Y := (LabelConfigList[5] as TLabelConfig).y-12;

    (ImageConfigList[5] as TImageConfig).X := (LabelConfigList[6] as TLabelConfig).X + length((self.LabelConfigList[6]  as TLabelConfig).fLabel)*15;
    (ImageConfigList[5] as TImageConfig).Y := (LabelConfigList[6] as TLabelConfig).y-12;
  end;


//  	- prüfen ist zu Turnier angemeldet ?
//         JA
//	  -> angemeldet Button anzeigen
//          -> anmelden nicht mehr möglich(Mouse Down reagiert nicht auf anmelden)
//         NEIN
//          -> anmelden Button anzeigen
//          -> anmelden möglich wenn alle Voraussetzungen erfüllt sind (Nachricht welche nicht)


  //Anmelden Handler
  if faktuellesTurnier <> nil then
  begin
    if not (fAktuellesTurnier as TTurnier).Angemeldet then
    begin
      if (x > round(550/1.28)) and (x < round(550/1.28) + round(260/1.28)) and (y > round(550/1.28)) and (y < round(550/1.28) + round(75/1.28)) then
      begin
        if (fAktuellesTurnier as TTurnier).Anmelden then
        begin
          form1.playupdown;
        end else
        begin
          form1.PlayNo;
        end;
      end;
    end;
  end;

  if (fAktuellesTurnier <> nil) then
  begin
    if (fAktuellesTurnier as TTurnier).Angemeldet then
    begin
      (self.ImageConfigList[0] as TImageConfig).visible := true;
      (self.ImageConfigList[1] as TImageConfig).visible := false;
      (self.ImageConfigList[2] as TImageConfig).visible := false;
    end else
    begin
      (self.ImageConfigList[0] as TImageConfig).visible := false;
      (self.ImageConfigList[1] as TImageConfig).visible := true;
      (self.ImageConfigList[2] as TImageConfig).visible := false;
    end;
  end;

 (self.ImageConfigList[3] as TImageConfig).X := (self.LabelConfigList[fAktuellerIndex] as TLabelConfig).X+12;
 (self.ImageConfigList[3] as TImageConfig).Y := (self.LabelConfigList[fAktuellerIndex] as TLabelConfig).Y-5;
end;

constructor TTurnierMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
  LabelCount : integer;
  test : integer;
  test2 : string;
begin
  form1.Logger.Add('TTurnierMenuClass.create');
  inherited create(form1.DXDraw1,form1.dxs1);

  fAktuellerIndex := 7;

  for i := 0 to self.LabelConfigList.Count - 1 do
  begin
    (self.LabelConfigList[i] as TLabelConfig).fLabel := ' ';
  end;

//  (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.centerstring('Woche ',22) ;
//  (self.LabelConfigList[1] as TLabelConfig).fLabel := form1.centerstring('Teilnehmer: ',22);
//  (self.LabelConfigList[2] as TLabelConfig).fLabel := form1.centerstring('Ab Liga: ',22);
//  (self.LabelConfigList[3] as TLabelConfig).fLabel := form1.centerstring('Ab Level: ',22);
//  (self.LabelConfigList[4] as TLabelConfig).fLabel := form1.centerstring('Ab Ansehen: ',22);
//  (self.LabelConfigList[5]  as TLabelConfig).fLabel := 'Startgebühr: ';
//  (self.LabelConfigList[6]  as TLabelConfig).fLabel := ' Siegprämie: ';

  LabelCount := 7;
  fAktuellesTurnier := nil;
  for i := 0 to cdTurniere.fTurniere.Count - 1 do
  begin

    // TEST
    if LabelCount > 13 then break;
    // TEST

    if (cdTurniere.fTurniere[i] as TTurnier).show then
    begin
      if fAktuellesTurnier = nil then fAktuellesTurnier := cdTurniere.fTurniere[i] as TTurnier;

      //Turnierbezeichnung malen
      (self.LabelConfigList[LabelCount] as TLabelConfig).fLabel := form1.CenterString((cdTurniere.fTurniere[i] as TTurnier).Bezeichnung,23);
      inc(LabelCount);

      //Infos malen
      if trim((self.LabelConfigList[0] as TLabelConfig).fLabel) = '' then
      begin
        (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.centerstring('Woche '+inttostr((cdTurniere.fTurniere[i] as TTurnier).Termin.Woche) +'/5' + ' ' + (cdTurniere.fTurniere[i] as TTurnier).Termin.TagstringGanz,22) ;
        (self.LabelConfigList[1] as TLabelConfig).fLabel := form1.centerstring('Teilnehmer: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).AnzahlGegner+1),22);
        (self.LabelConfigList[2] as TLabelConfig).fLabel := form1.centerstring('Ab Liga: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).MinLiga),22);
        (self.LabelConfigList[3] as TLabelConfig).fLabel := form1.centerstring('Ab Level: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).MinLevel),22);
        (self.LabelConfigList[4] as TLabelConfig).fLabel := form1.centerstring('Ab Ansehen: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).MinAnsehen),22);
        (self.LabelConfigList[5]  as TLabelConfig).fLabel := 'Startgebühr: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).Startgebuehr);
        (self.LabelConfigList[6]  as TLabelConfig).fLabel := ' Siegprämie: ' + inttostr((cdTurniere.fTurniere[i] as TTurnier).PreisGeld);

        (ImageConfigList[4] as TImageConfig).X := (LabelConfigList[5] as TLabelConfig).X + length((self.LabelConfigList[5]  as TLabelConfig).fLabel)*15;
        (ImageConfigList[4] as TImageConfig).Y := (LabelConfigList[5] as TLabelConfig).y-12;

        (ImageConfigList[5] as TImageConfig).X := (LabelConfigList[6] as TLabelConfig).X + length((self.LabelConfigList[6]  as TLabelConfig).fLabel)*15;
        (ImageConfigList[5] as TImageConfig).Y := (LabelConfigList[6] as TLabelConfig).y-12;
      end;
    end;
  end;

  if (fAktuellesTurnier <> nil) then
  begin
    if (fAktuellesTurnier as TTurnier).Angemeldet then
    begin
      (self.ImageConfigList[0] as TImageConfig).visible := true;
      (self.ImageConfigList[1] as TImageConfig).visible := false;
      (self.ImageConfigList[2] as TImageConfig).visible := false;
    end else
    begin
      (self.ImageConfigList[0] as TImageConfig).visible := false;
      (self.ImageConfigList[1] as TImageConfig).visible := true;
      (self.ImageConfigList[2] as TImageConfig).visible := false;
    end;
  end;

  //Rahmen malen
  (self.ImageConfigList[3] as TImageConfig).alpha := 100;
  (self.ImageConfigList[3] as TImageConfig).X := (self.LabelConfigList[fAktuellerIndex] as TLabelConfig).X+12;
  (self.ImageConfigList[3] as TImageConfig).Y := (self.LabelConfigList[fAktuellerIndex] as TLabelConfig).Y-5;
  form1.Logger.Add('TTurnierMenuClass.create PASSED');

end;



procedure TTurnierMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0 : begin
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;
    end;

  except
    on e:exception do
      showmessage('Main->TTurnierMenuClass->ButtonPress: ' + e.message);
  end;

end;

//constructor TLoadGameMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
//var
//  i : integer;
//  savegame : TStringList;
//  pfad : string;
//  crypt :  TFileCrypt;
//begin
//  inherited create(form1.DXDraw1,form1.dxs1);
//  savegame := TStringList.Create;
//  pfad := extractfilepath(application.exename) + 'Savegames\';
//  try
//    try
//      //Koordinaten füllen
//      for i := 0 to 4 do
//      begin
//        Koords[i].X := (self.LabelConfigList[i] as TLabelConfig).X;
//        Koords[i].Y := (self.LabelConfigList[i] as TLabelConfig).Y-5;
//
//        //Vorhandene Savegames anzeigen
//        if FileExists(Pfad+'slot'+inttostr(i+1)) then
//        begin
//          savegame.Clear;
//          crypt := TFileCrypt.Create;
//          crypt.DeCryptFile(Pfad+'slot'+inttostr(i+1),Pfad+'slot'+inttostr(i+1));
//          savegame.LoadFromFile(Pfad + 'slot'+inttostr(i+1));
//          crypt.CryptFile(Pfad+'slot'+inttostr(i+1),Pfad+'slot'+inttostr(i+1));
//          freeandnil(crypt);
//          (self.LabelConfigList[i] as TLabelConfig).fLabel := CenterString(Trim(savegame[0]),32);
//        end;
//
//        (self.LabelConfigList[i] as TLabelConfig).fLabel := CenterString(Trim((self.LabelConfigList[i] as TLabelConfig).fLabel),33);
//      end;
//
//      //Startposition setzen
//      slotNow := 1;
//      (self.ImageConfigList[0] as TImageConfig).Y := Koords[slotnow-1].Y;
//
//      //33*10
//
//    except
//      on e:exception do
//      begin
//        showmessage('Error: TLoadGameMenuClass.create ' + e.Message);
//      end;
//    end;
//  finally
//    freeandnil(savegame);
//  end;
//end;


//procedure TLoadGameMenuClass.MouseDown(x,y:integer);
//var
//  i : integer;
//begin
//  try
//    //Koordinaten prüfen und neuen Slot setzen
//    for i := 0 to 4 do
//    begin
//      if (x>Koords[i].x) and (x<Koords[i].X + 33*10) and (y>Koords[i].y) and (y<Koords[i].Y+29) then
//      begin
//        SlotNow := i+1;
//        (self.ImageConfigList[0] as TImageConfig).Y := Koords[slotnow-1].Y;
//        break;
//      end;
//    end;
//  except
//    on e:exception do
//    begin
//      showmessage('Error: TOptionsMenuClass.MouseDown ' + e.Message);
//    end;
//  end;
//end;


//procedure TLoadGameMenuClass.ButtonPress(bIndex:integer);
//begin
//  try
//    case bIndex of
//      0 : begin
//              Form1.NewMenu;
//              Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//              Form1.DXDraw1.restore; {Darstellung aktualisieren}
//              exit;
//            end;
//
//      1 : begin
//            //Spiel laden
//            if Loadgame(slotnow) then
//            begin
//              Form1.NewMenu;
//              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//              Form1.DXDraw1.restore; {Darstellung aktualisieren}
//            end else
//            begin
//              form1.playNo;
//            end;
//            exit;
//          end;
//
//    end;
//  except
//    on e:exception do
//      showmessage('Main->TLoadGameMenuClass->ButtonPress: ' + e.message);
//  end;
//end;

procedure TInfoMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0: begin
              Form1.NewMenu;
              Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;
    end;
  except
    on e:exception do
      showmessage('Main->TInfoMenuClass->ButtonPress: ' + e.message);
  end;
end;

{TOptionsmenu}

//    Koords : array[0..4] of TPoint;
//    slotNow : integer;


procedure TOptionsMenuClass.fAktualisieren;
var
  savegame:TSTringList;
  pfad:string;
  crypt:TFilecrypt;
begin
  pfad := extractfilepath(application.exename) + 'Savegames\';
  savegame := TStringList.create;
  try
    if FileExists(Pfad+'slot'+inttostr(slotnow)) then
    begin
      savegame.Clear;
      crypt := TFileCrypt.Create;
      crypt.DeCryptFile(Pfad + 'slot'+inttostr(slotnow),Pfad + 'slot'+inttostr(slotnow));
      savegame.LoadFromFile(Pfad + 'slot'+inttostr(slotnow));
      crypt.CryptFile(Pfad + 'slot'+inttostr(slotnow),Pfad + 'slot'+inttostr(slotnow));
      (self.LabelConfigList[slotnow+1] as TLabelConfig).fLabel := CenterString(Trim(savegame[0]),32);
    end;
  finally
    freeandnil(savegame);
  end;
end;


constructor TOptionsMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;weiterleitung:string);
var
  i : integer;
  savegame : TStringList;
  pfad : string;
  crypt:TFileCrypt;
begin
  inherited create(form1.DXDraw1,form1.dxs1);
  fweiterleitung := weiterleitung;

  if fweiterleitung = 'mainmenu' then
  begin
    //button2, label1, button3, label7
    (self.ButtonConfigList[2] as TButtonConfig).X := 5000;
    (self.ButtonConfigList[3] as TButtonConfig).X := 5000;
    (self.LabelConfigList[1] as TLabelConfig).X := 5000;
    (self.LabelConfigList[7] as TLabelConfig).X := 5000;

    (self.ButtonConfigList[0] as TButtonConfig).X := 472;
    (self.ButtonConfigList[0] as TButtonConfig).Y := 250;
  end;

  savegame := TStringList.Create;
  pfad := extractfilepath(application.exename) + 'Savegames\';
  try
    try
      //Koordinaten füllen
      for i := 0 to 4 do
      begin
        Koords[i].X := (self.LabelConfigList[i+2] as TLabelConfig).X;
        Koords[i].Y := (self.LabelConfigList[i+2] as TLabelConfig).Y-5;

        //Vorhandene Savegames anzeigen
        if FileExists(Pfad+'slot'+inttostr(i+1)) then
        begin
          savegame.Clear;
          crypt := TFileCrypt.Create;
          crypt.DeCryptFile(Pfad+'slot'+inttostr(i+1),Pfad+'slot'+inttostr(i+1));
          savegame.LoadFromFile(Pfad + 'slot'+inttostr(i+1));
          crypt.CryptFile(Pfad+'slot'+inttostr(i+1),Pfad+'slot'+inttostr(i+1));
          freeandnil(crypt);
          (self.LabelConfigList[i+2] as TLabelConfig).fLabel := CenterString(Trim(savegame[0]),32);
        end;

        (self.LabelConfigList[i+2] as TLabelConfig).fLabel := CenterString(Trim((self.LabelConfigList[i+2] as TLabelConfig).fLabel),33);
      end;

      //Startposition setzen
      slotNow := 1;
      (self.ImageConfigList[0] as TImageConfig).Y := Koords[slotnow-1].Y;

      //33*10

    except
      on e:exception do
      begin
        showmessage('Error: TOptionsMenuClass.create ' + e.Message);
      end;
    end;
  finally
    freeandnil(savegame);
  end;
end;


procedure TOptionsMenuClass.MouseDown(x,y:integer);
var
  i : integer;
begin
  try
    //Koordinaten prüfen und neuen Slot setzen
    for i := 0 to 4 do
    begin
      if (x>Koords[i].x) and (x<Koords[i].X + 33*10) and (y>Koords[i].y) and (y<Koords[i].Y+29) then
      begin
        SlotNow := i+1;
        (self.ImageConfigList[0] as TImageConfig).Y := Koords[slotnow-1].Y;
        break;
      end;
    end;
  except
    on e:exception do
    begin
      showmessage('Error: TOptionsMenuClass.MouseDown ' + e.Message);
    end;
  end;
end;


procedure TOptionsMenuClass.ButtonPress(bIndex:integer);
begin
  inherited ButtonPress(bindex);
  try
    case bIndex of
      0:  begin
            if fweiterleitung = 'gamemenu' then
            begin
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end else if fweiterleitung = 'mainmenu' then
            begin
              Form1.NewMenu;
              Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;
          end;
      1:  begin
            //Spiel laden
            if Loadgame(slotnow) then
            begin
//              Form1.PlayUpDown;
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
            end else
            begin
              form1.PlayNo;
            end;
            exit;
          end;
      2:  begin
            if fweiterleitung = 'gamemenu' then
            begin
              Form1.PlayUpDown;
              Savegame(slotnow);
              fAktualisieren;
            end;
          end;
      3:  begin
            if fweiterleitung = 'gamemenu' then
            begin
              Form1.NewMenu;
              Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
            end;
          end;
    end;
  except
    on e:exception do
      showmessage('Main->TOptionsMenuClass->ButtonPress: ' + e.message);
  end;
end;

constructor TRanglistenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
begin
  form1.Logger.Add('TRanglistenMenuClass.create');

  inherited create(dxdraw,engine);
  Liste := TObjectList.Create;
  Liste2 := TObjectList.Create;
  //  (ImageConfigList[0] as TImageConfig).alpha := 100;
  ButtonPress(1);
  form1.Logger.Add('TRanglistenMenuClass.create PASSED');
end;

destructor TRanglistenMenuClass.destroy;
begin
  freeandnil(Liste);
  freeandnil(Liste2);
  inherited destroy;
end;

procedure TRanglistenMenuClass.ButtonPress(bIndex:integer);
var
  i : integer;
  n : string;
  rang : integer;
  rangs : integer;

begin
  try
    case bIndex of
      0: begin
            Form1.NewMenu;
            Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
         end;
      1: begin // Level
            form1.playupdown;
            Liste.Clear;
            cdGegner.GetListByLevel(Liste);
         end;
      2: begin // Maxkraft
            form1.playupdown;
            Liste.Clear;
            cdGegner.GetListByMaxKraft(Liste);
         end;
      3: begin // Kraftausdauer
            form1.playupdown;
            Liste.Clear;
            cdGegner.GetListByKrAusd(Liste);
         end;
      4: begin // Technik
            form1.playupdown;
            Liste.Clear;
            cdGegner.GetListByTechnik(Liste);
         end;
      5: begin // Fitness
            form1.playupdown;
            Liste.Clear;
            cdGegner.GetListByFitness(Liste);
         end;
    end;

    //Liste an die Wand klatschen
    //Level,MaxKraft,KraftAusdauer,Technik,Fitness : string;
    for i := 0 to Liste.count - 1 do
    begin
//      (self.LabelConfigList[i] as TLabelConfig).Y := 90 + i*50;
      (self.LabelConfigList[i] as TLabelConfig).FontStyle := 'news';
      (self.LabelConfigList[i] as TLabelConfig).fLabel :=  form1.MakeStringLeft(inttostr(i+1) + '.',4) + form1.MakeStringLeft(trim((Liste[i] as TSportler).Vorname + ' ' + (Liste[i] as TSportler).Name),20) + ' ' + form1.CenterString(inttostr((Liste[i] as TSportler).Level),3) + '  ' + form1.CenterString(inttostr((Liste[i] as TSportler).Maximalkraft),8) + '    ' + form1.CenterString(inttostr((Liste[i] as TSportler).Kraftausdauer),9) + '   ' + form1.CenterString(inttostr((Liste[i] as TSportler).Technik),8) + '  ' + form1.CenterString(inttostr((Liste[i] as TSportler).Fitness),7);
      if (Liste[i] as TSportler).Name = cdSpieler.Vorname then
      begin
        (ImageConfigList[0] as TImageConfig).y := (self.LabelConfigList[i] as TLabelConfig).Y - 5;
      end;
    end;



  //Tabelle anzeigen
  Liste2.clear;
    //Liste sortiert nach Punkten holen
    cdGegner.GetListByPoints(Liste2);

    //Liste an die Wand klatschen
    (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ' + inttostr(cdspieler.Liga) + '.' + ' LIGA';
    (self.LabelConfigList[7] as TLabelConfig).fLabel := 'Rang   Name         Siege  Niederlagen';
    rangs := 1;
    for i := 0 to Liste2.count - 1 do
    begin
      if i > 0 then
      begin
        if (Liste2[i] as TSportler).Siege < (Liste2[i-1] as TSportler).Siege then
        begin
          rang := i+1;
          rangs := i+1;
        end else
        begin
          rang := rangs;
        end;
      end else
      begin
        rang := i+1;
      end;

      (self.LabelConfigList[7+i+1] as TLabelConfig).fLabel :=  form1.MakeStringLeft(inttostr(rang) + '.',4) + form1.MakeStringLeft(trim((Liste2[i] as TSportler).Vorname + ' ' + (Liste2[i] as TSportler).Name),22) + '  '  + form1.MakeStringLeft(inttostr((Liste2[i] as TSportler).Siege),8) + '  ' + form1.MakeStringLeft(inttostr((Liste2[i] as TSportler).Niederlagen),12);
      if (Liste2[i] as TSportler).Name = cdSpieler.Vorname then
      begin
        (ImageConfigList[1] as TImageConfig).y := (self.LabelConfigList[7+i+1] as TLabelConfig).Y - 5;
      end;
    end;

  except
    on e:exception do
      showmessage('Main->TTrainingMenu->ButtonPress: ' + e.message);
  end;
end;




{Nach Training}
procedure TNachTrainingMenuClass.ButtonPress(bIndex:integer);
begin
  case bIndex of
    0:   begin
            Form1.NewMenu;
            Form1.fActiveMenu := TTrainingMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end;
  end;
end;


constructor TNachTrainingMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine;Treffer,MaxTreffer,MaxKraft,KraftAusd:integer);
var
  Prozent:integer;
  MaxKraftP:integer;
  KraftAusdP:integer;
  Bewertung:string;
begin
  inherited create(dxdraw,engine);

  Prozent := round((100/MaxTreffer)*Treffer);

  MaxKraftP := round((MaxKraft/100)*Prozent);
  KraftAusdP := round((KraftAusd/100)*Prozent);

  Bewertung := 'Training';
  case Prozent of
    100    : Bewertung := 'PERFEKTES TRAINING';
    90..99 : Bewertung := 'Sensationelles Training';
    80..89 : Bewertung := 'Sehr Gutes Training';
    70..79 : Bewertung := 'Gutes Training';
    60..69 : Bewertung := 'Befriedigendes Training';
    50..59 : Bewertung := 'Mittelmäßiges Training';
    40..49 : Bewertung := 'Mittelmäßiges Training';
    30..39 : Bewertung := 'Schlechtes Training';
    20..29 : Bewertung := 'Sehr schlechtes Training';
    10..19 : Bewertung := 'Mieses Training';
    0..9   : Bewertung := 'Das war wohl nix';
  end;

  (LabelConfigList[0] as TLabelConfig).fLabel := Bewertung;
  (LabelConfigList[1] as TLabelConfig).fLabel := '      Treffer: ' + inttostr(Prozent) + '%';
  (LabelConfigList[2] as TLabelConfig).fLabel := ' Maximalkraft: ' + inttostr(cdspieler.Maximalkraft) + ' +' + inttostr(MaxKraftP);
  (LabelConfigList[3] as TLabelConfig).fLabel := 'Kraftausdauer: ' + inttostr(cdspieler.Kraftausdauer) + ' +' + inttostr(KraftAusdP);

  cdSpieler.Maximalkraft := cdSpieler.Maximalkraft + MaxKraftP;
  cdSpieler.Kraftausdauer := cdSpieler.Kraftausdauer + KraftAusdP;
end;



procedure TTrainingMenuClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  i,c : integer;
begin
  try
    //Markierung malen
    (self.ImageConfigList[0] as TImageConfig).X := self.Koords[ItemNow].X-4;
    (self.ImageConfigList[0] as TImageConfig).Y := self.Koords[ItemNow].Y-4;

    //Icons malen
    surface := TDirectDrawSurface.Create(fdxDraw.DDraw);

    //Rucksack Ausrüstung malen
    c := 0;
    for i := 0 to cdSpieler.AusruestungRucksack.Count - 1 do
    begin
      //Icon malen
      if (cdSpieler.AusruestungRucksack[i] as TAusruestung).Klasse = 4 then
      begin
        surface.LoadFromDIB((cdSpieler.AusruestungRucksack[i] as TAusruestung).Icon);
        fDXDraw.Surface.Draw(self.Koords[c].X,self.Koords[c].y,surface,false);
        inc(c);
      end;
    end;

    if (showMinusFitness) and (fAktuelleHantel <> nil) then
    begin
      (self.LabelConfigList[0] as TLabelConfig).fLabel := 'Fitness: '+inttostr(cdSpieler.Fitness - (fAktuelleHantel as TAusruestung).Fitnessverbrauch);
    end else
    begin
      (self.LabelConfigList[0] as TLabelConfig).fLabel := 'Fitness: '+inttostr(cdSpieler.Fitness);
    end;

    showMinusFitness := false;

    (self.LabelConfigList[8] as TLabelConfig).fLabel := '/' + inttostr(cdSpieler.FitnessMaximum);
    (self.LabelConfigList[8] as TLabelConfig).x := (self.LabelConfigList[0] as TLabelConfig).X + length((self.LabelConfigList[0] as TLabelConfig).flabel)*14;

    (self.ButtonConfigList[2] as TButtonConfig).X := (self.LabelConfigList[8] as TLabelConfig).x + length((self.LabelConfigList[8] as TLabelConfig).flabel)*14 + 30;

  finally
    freeandnil(surface);
  end;
end;

procedure TTrainingMenuClass.MouseOver(x,y:integer);
begin
  if (x > (self.ButtonConfigList[1] as TButtonConfig).X) and (x < (self.ButtonConfigList[1] as TButtonConfig).X + (self.ButtonConfigList[1] as TButtonConfig).W) and (y > (self.ButtonConfigList[1] as TButtonConfig).Y) and (y < (self.ButtonConfigList[1] as TButtonConfig).y + (self.ButtonConfigList[1] as TButtonConfig).h) then
  begin
    showminusfitness := true;
  end;
end;

procedure TTrainingMenuClass.MouseDown(x,y:integer);
var
  Index : integer;
  i : integer;
  kx,ky : integer;
  ItemNo : integeR;
  Speicher : TAusruestung;
begin
  Index := -1;

  //ItemNow
  for i := 0 to high(Koords) do
  begin
    kx := Koords[i].X;
    ky := Koords[i].Y;
    if (x >= kx) and (x <= kx+round(100/1.28)) and (y >= ky) and (y <= ky+round(100/1.28)) then
    begin
      Index := i;
      break;
    end;
  end;

  if Index <> -1 then
  begin
    ItemNow := Index;
    if Index <= fIndices.Count - 1 then
    begin
      Index := strtoint(fIndices[Index]);
    end;
  end;

  //Fitness malen
  (self.LabelConfigList[0] as TLabelConfig).fLabel := 'Fitness: '+inttostr(cdSpieler.Fitness);

  //Aktuelle Hantel holen
  Speicher := nil;

  if (Index <> -1) and (Itemnow < fIndices.count) then
  begin
    fAktuelleHantel := cdSpieler.AusruestungRucksack[Index] as TAusruestung;
    Speicher := cdSpieler.AusruestungRucksack[Index] as TAusruestung;
  end;

  //Wenn Hantel markiert
  if index <> -1 then
  begin
    if Speicher <> nil then
    begin
      (self.LabelConfigList[1] as TLabelConfig).fLabel := (Speicher as TAusruestung).Bezeichnung;
      (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Stufe: '+inttostr((Speicher as TAusruestung).Stufe);
      (self.LabelConfigList[3] as TLabelConfig).fLabel := 'Maximalkraft +'+inttostr((Speicher as TAusruestung).AddMaxKr);
      (self.LabelConfigList[4] as TLabelConfig).fLabel := 'Kraftausdauer +'+inttostr((Speicher as TAusruestung).AddAusd);
      (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Fitnessverbrauch: '+inttostr((Speicher as TAusruestung).Fitnessverbrauch);
      (self.LabelConfigList[6] as TLabelConfig).fLabel := 'Schwierigkeit: '+inttostr((Speicher as TAusruestung).Schwierigkeit)+'/10';
      (self.LabelConfigList[7] as TLabelConfig).fLabel := 'Wiederholungen: '+inttostr((Speicher as TAusruestung).AnzahlWiederholungen);
    end else
    begin
      (self.LabelConfigList[1] as TLabelConfig).fLabel := '-';
      (self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[4] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[5] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
      (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
    end;
  end;
end;

destructor TTrainingMenuClass.destroy;
begin
  freeandnil(fIndices);
end;

constructor TTrainingMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i, j : integer;
  sx,sy : integer;
  lauf : integer;
begin
  form1.Logger.Add('TTrainingMenuClass.create');

  inherited create(dxdraw,engine);
  fAktuelleHantel := nil;
  ItemNow := 0;
  fIndices := TStringList.Create;

  //Koordinaten festlegen
  sx := round(110/1.28);
  sy := round(123/1.28);
  lauf := 0;
  for i := 0 to 3 do //Zeilen
  begin
    for j := 0 to 3 do //Spalten
    begin
      Koords[lauf].X := sx;
      Koords[lauf].y := sy;
      inc(sx,round(105/1.28));
      inc(lauf);
    end;
    sx := round(110/1.28);
    inc(sy,round(105/1.28));
  end;

  //Rucksack Ausrüstung malen
  for i := 0 to cdSpieler.AusruestungRucksack.Count - 1 do
  begin
    //Icon malen
    if (cdSpieler.AusruestungRucksack[i] as TAusruestung).Klasse = 4 then
    begin
      fIndices.add(inttostr(i));
      fAktuelleHantel :=(cdSpieler.AusruestungRucksack[i] as TAusruestung);
    end;
  end;
  MouseDown(Koords[0].X,Koords[0].Y);
  form1.Logger.Add('TTrainingMenuClass.create PASSED');

end;


procedure TTrainingMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0:  begin
            Form1.NewMenu;
            Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
            Form1.DXDraw1.restore; {Darstellung aktualisieren}
            exit;
          end;

      1:  begin
            //form1.DXTimer1.Enabled := false; //Menu-Timer abstellen
            if fAktuelleHantel <> nil then
            begin
              if (cdSpieler.Fitness >= fAktuelleHantel.Fitnessverbrauch) then
              begin
                cdSpieler.Fitness := cdSpieler.Fitness - fAktuelleHantel.Fitnessverbrauch;
                Form1.NewMenu; //Menu kicken
                form1.fTrain := TTrain.create(form1.DXDraw1,fAktuelleHantel);
                Form1.DXDraw1.restore; {Darstellung aktualisieren}
                exit;
              end else
              begin
                form1.PlayNo;
              end;
            end else
            begin
              form1.PlayNo;
            end;
          end;

      2:   begin
              Form1.NewMenu;
              Form1.fActiveMenu := TErholungsParkClass.Create(Form1.DXDraw1,Form1.dxs1,'training'); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
           end;
    end;
  except
    on e:exception do
      showmessage('Main->TTrainingMenuClass->ButtonPress: ' + e.message);
  end;
end;

procedure TSponsorenMenuClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  i : integer;
  Besch : string;
  klasse : integer;
  koordindex : integer;
  maximum : integer;
  wochenstring : string;
begin
  try
    //Icons malen
    surface := TDirectDrawSurface.Create(fdxDraw.DDraw);

//    fFirstArrayIndex : integer; //Array Item das an erster Position angezeigt wird
//    fMarkedIndex : integer; // 1..6

    maximum := fFirstArrayIndex + 5;
    if high(cdSponsoren.fSponsoren) < maximum then maximum := high(cdSponsoren.fSponsoren);

    koordindex := 1;
    for i := fFirstArrayIndex to maximum do
    begin
      surface.Fill(0);
      surface.LoadFromDIB(cdSponsoren.fSponsoren[i].Icon.DIB);
      fDXDraw.Surface.Draw(fXKoords[koordindex],fY,surface,false);
      inc(koordIndex,1);
    end;

    (self.ImageConfigList[0] as TImageConfig).X := fXKoords[fMarkedIndex] - 5;
    (self.ImageConfigList[0] as TImageConfig).Y := fY - 5;

    //Infos malen
    (self.LabelConfigList[0] as TLabelConfig).fLabel := '-';
    (self.LabelConfigList[1] as TLabelConfig).fLabel := ' Laufzeit:';
    (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Vergütung:';
    (self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';

    if Length(cdSponsoren.fSponsoren) >= fMarkedIndex then
    begin
      if cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Laufzeit > 1 then
        wochenstring := 'Wochen'
      else
        wochenstring := 'Woche';

      (self.LabelConfigList[0] as TLabelConfig).fLabel := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Name;
      (self.LabelConfigList[1] as TLabelConfig).fLabel := ' Laufzeit: ' + inttostr(cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Laufzeit) + ' ' + wochenstring;
      (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Vergütung:    ' + inttostr(cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Geld) + '/Woche';
      (self.LabelConfigList[3] as TLabelConfig).fLabel := '              ' + inttostr(cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].sieggeld) + '/Saisonsieg';
    end;

    //Hände malen
    if AbschlussOver then
    begin
      (self.ImageConfigList[1] as TImageConfig).visible := false;
      (self.ImageConfigList[2] as TImageConfig).visible := true;
      (self.ImageConfigList[3] as TImageConfig).visible := false;
    end else
    begin
      (self.ImageConfigList[1] as TImageConfig).visible := true;
      (self.ImageConfigList[2] as TImageConfig).visible := false;
      (self.ImageConfigList[3] as TImageConfig).visible := false;
    end;

    AbschlussOver := false;

    if cdSpieler.Sponsor <> nil then
    begin
      (self.ImageConfigList[1] as TImageConfig).visible := false;
      (self.ImageConfigList[2] as TImageConfig).visible := false;
      (self.ImageConfigList[3] as TImageConfig).visible := true;

      form1.DXPowerFont1.Font := 'FontN';
      form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,540,350,'Vertrag bis');
//      form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,540,370,' Runde ' + inttostr(cdspieler.Sponsor.VertragsEnde.Runde));
      form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,540,370,' Woche ' + inttostr(cdspieler.Sponsor.VertragsEnde.woche));
      form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,540,390,'   Tag ' + inttostr(cdspieler.Sponsor.VertragsEnde.tag));
    end;

  finally
    freeandnil(surface);
  end;

end;

procedure TSponsorenMenuClass.MouseOver(x,y:integer);
begin
  if (x > (ImageConfigList[1] as TImageConfig).X) and (x < (ImageConfigList[1] as TImageConfig).X + (ImageConfigList[1] as TImageConfig).W) and (y > (ImageConfigList[1] as TImageConfig).y) and (y < (ImageConfigList[1] as TImageConfig).y + (ImageConfigList[1] as TImageConfig).h) then
  begin
    if cdSpieler.Sponsor = nil then
    begin
      AbschlussOver := true;
    end;
  end;
end;

procedure TSponsorenMenuClass.MouseDown(x,y:integer);
var
  i : integer;
  test : string;
  test2 : integer;
begin
//    fFirstArrayIndex : integer; //Array Item das an erster Position angezeigt wird
//    fMarkedIndex : integer; // 1..6
//    fXKoords : array[1..6] of integer;
//    fY : integer;

  for i := 1 to 6 do
  begin
    if (x > fxKoords[i]) and (x < fXKoords[i]+100) and (y > fY) and (y < fY+round(100/1.28)) then
    begin
      fMarkedIndex := i;
      break;
    end;
  end;

  //Vertrag schließen
  if (x > (ImageConfigList[1] as TImageConfig).X) and (x < (ImageConfigList[1] as TImageConfig).X + (ImageConfigList[1] as TImageConfig).W) and (y > (ImageConfigList[1] as TImageConfig).y) and (y < (ImageConfigList[1] as TImageConfig).y + (ImageConfigList[1] as TImageConfig).h) then
  //if abschlussover then //geht nicht da abschlussover in drawmenusp. auf false gesetzt wird
  begin
    if cdspieler.Sponsor = nil then
    begin
      if Length(cdSponsoren.fSponsoren) >= fMarkedIndex then
      begin

//        test := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].IconPfad;
//        test2 := ffirstarrayindex;
//        test2 := fmarkedindex;
//        test := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Name;
//        test2 := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Geld;

        form1.playupdown;


        cdSpieler.Sponsor := TSponsor.create(0,'test',0, cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].IconPfad);
        cdSpieler.Sponsor.Name := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Name;
        cdSpieler.Sponsor.ID := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].id;
        cdSpieler.Sponsor.Laufzeit := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Laufzeit;
        cdSpieler.Sponsor.Geld := cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].Geld;
        cdSpieler.Sponsor.sieggeld :=cdSponsoren.fSponsoren[fFirstArrayIndex+fMarkedIndex-1].sieggeld;
        cdSpieler.Sponsor.SchliesseVertrag;

      end else
      begin
        form1.PlayNo;
      end;
    end;
  end;

end;

constructor TSponsorenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
  i : integer;
  startx,starty : integer;
  next : integer;
begin
  form1.Logger.Add('TSponsorenMenuClass.create');

  inherited create(dxdraw,engine);
  fFirstArrayIndex := 0; //integer; //Array Item das an erster Position angezeigt wird
  fMarkedIndex := 1; // integer; // 1..6

  startx := round(203/1.28);
  fY := round(78/1.28);
  next := 0;

  for i := 1 to 6 do
  begin
    fXKoords[i] := startx + next;
    inc(next,round(105/1.28));
  end;

  (self.ImageConfigList[0] as TImageConfig).alpha := 180;

  (self.ImageConfigList[2] as TImageConfig).visible := false;
  (self.ImageConfigList[3] as TImageConfig).visible := false;


  MouseDown(fXKoords[1],fY);

  //..
  form1.Logger.Add('TSponsorenMenuClass.create PASSED');

end;

procedure TSponsorenMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0:  begin // zurück
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
          end;

//    fFirstArrayIndex : integer; //Array Item das an erster Position angezeigt wird
//    fMarkedIndex : integer; // 1..6
//    fXKoords : array[1..6] of integer;


      1:  begin // links
            if length(cdSponsoren.fSponsoren) > 6 then
            begin
              if fFirstArrayIndex > 0 then
              begin
                dec(fFirstArrayIndex);
              end;
            end;
          end;

      2:  begin // rechts
            if length(cdSponsoren.fSponsoren) > 6 then
            begin
              if fFirstArrayIndex+5 < high(cdSponsoren.fSponsoren) then inc(fFirstArrayIndex);
            end;
          end;

      3:  begin // Handschlag

      //          procedure TSponsor.SchliesseVertrag;


      //              Form1.NewMenu;
//              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
//              Form1.DXDraw1.restore; {Darstellung aktualisieren}
          end;
    end;
  except
    on e:exception do
      showmessage('Main->TSponsorenMenuClass->ButtonPress: ' + e.message);
  end;
end;

procedure TKampflistenMenuClass.DrawMenuSpecific;
var
  i : integer;
  ID1, ID2, IDSieger : integer;
  name1, name2, siegername : string;
  zahl : string;
begin
  zahl := '';
//  if fWoche < 10 then
//  begin
//    zahl := '0' + inttostr(fWoche);
//  end else
//  begin
    zahl := inttostr(fWoche);
//  end;
  (self.LabelConfigList[1] as TLabelConfig).fLabel := zahl + '/5';

  //Spieler ID = 6
  for i := 1 to high(cdKampfsaison.Vorrunde[fWoche].Kaempfe) do
  begin
    case fRunde of
      1:  begin
            ID1 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K1_ID;
            ID2 := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].K2_ID;
            IDSieger := cdKampfsaison.Vorrunde[fWoche].Kaempfe[i].SiegerID;
            (self.LabelConfigList[0] as TLabelConfig).fLabel := form1.CenterString('Hinrunde',9);
          end;

      2:  begin
            ID1 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K1_ID;
            ID2 := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].K2_ID;
            IDSieger := cdKampfsaison.rueckrunde[fWoche].Kaempfe[i].SiegerID;
            (self.LabelConfigList[0] as TLabelConfig).fLabel := 'Rückrunde';
          end;
    end;

    if ID1 <> 6 then
    begin
      name1 := (cdGegner.gegner[ID1] as TSportler).Vorname +' '+ (cdGegner.gegner[ID1] as TSportler).Name;
    end else
    begin
      name1 := cdSpieler.Vorname;
    end;

    if ID2 <> 6 then
    begin
      name2 := (cdGegner.gegner[ID2] as TSportler).Vorname +' '+ (cdGegner.gegner[ID2] as TSportler).Name;
    end else
    begin
      name2 := cdSpieler.Vorname;
    end;

    if (IDSieger <> 6) and (IDSieger <> 0) then
    begin
      siegername := (cdGegner.gegner[IDSieger] as TSportler).Vorname +' '+ (cdGegner.gegner[IDSieger] as TSportler).Name;
    end else if idsieger = 6 then
    begin
      siegername := cdSpieler.Vorname;
    end else if idsieger = 0 then
    begin
      siegername := '?';
    end;
    (self.LabelConfigList[i+1] as TLabelConfig).fLabel := Form1.CenterString(name1,18) + ' vs ' + Form1.CenterString(name2,18) + '  Sieger: ' + Form1.CenterString(siegername,18);
  end;


  (self.LabelConfigList[5] as TLabelConfig).fLabel := inttostr(cdspieler.liga) + '. Liga, Saisonbegegnungen';
end;

constructor TKampflistenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
begin
  form1.Logger.Add('TKampflistenMenuClass.create');

  inherited create(dxdraw,engine);
  fRunde := cdZeit.Runde;
  fWoche := cdZeit.Woche;

  form1.Logger.Add('TKampflistenMenuClass.create PASSED');

end;

procedure TKampflistenMenuClass.ButtonPress(bIndex:integer);
begin
  // 0 zurück
  // 1,2 runde
  // 3,4 woche

  try
    case bIndex of
      0 : begin
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
          end;

      1..2 : begin
               form1.playupdown;
               case fRunde of
                  1: begin
                       fRunde := 2;
                       (self.ButtonConfigList[2] as TButtonConfig).X := round(450/1.28);
                     end;
                  2: begin
                       fRunde := 1;
                       (self.ButtonConfigList[2] as TButtonConfig).X := round(430/1.28);
                     end;
               end;
             end;

      3 : begin
            form1.playupdown;
            if fWoche = 1 then
            begin
              fWoche := 5;
            end else if fWoche > 1 then
            begin
              dec(fWoche);
            end;
          end;

      4 : begin
            form1.playupdown;
            if fWoche = 5 then
            begin
              fWoche := 1;
            end else if fWoche < 5 then
            begin
              inc(fWoche);
            end;
          end;
    end;

  except
    on e:exception do
      showmessage('Main->TKampflistenMenuClass->ButtonPress: ' + e.message);
  end;
end;

procedure TBeforeFightMenuClass.ButtonPress(bIndex:integer);
begin
  try
    case bIndex of
      0..2: begin
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;              
            end;
    end;
  except
    on e:exception do
      showmessage('Main->TBeforeFightMenuClass->ButtonPress: ' + e.message);
  end;
end;


procedure TEinkaufenMenuClass.MouseDown(x,y:integer);
var
  Index : integer;
  i : integer;
  kx,ky : integer;
  ItemNo : integeR;
  Speicher : TAusruestung;
begin
  Index := -1;

  //ItemNow und ShopOrBesitz setzen
  for i := 0 to high(KoordsShop) do
  begin
    kx := KoordsShop[i].X;
    ky := Koordsshop[i].Y;
    if (x >= kx) and (x <= kx+round(100/1.28)) and (y >= ky) and (y <= ky+round(100/1.28)) then
    begin
      Index := i;
      ShopOrBesitz := 0;
      break;
    end;
  end;

  for i := 0 to high(KoordsBesitz) do
  begin
    kx := KoordsBesitz[i].X;
    ky := KoordsBesitz[i].Y;
    if (x >= kx) and (x <= kx+round(100/1.28)) and (y >= ky) and (y <= ky+round(100/1.28)) then
    begin
      Index := i;
      ShopOrBesitz := 1;
      break;
    end;
  end;

  if Index <> -1 then
  begin
    ItemNow := Index;
  end;

//----LABEL-Belegung-----------------
  ///Kapital 0
  //Label;580;715;big;0
  //
  /// 1
  //Label;100;540;big;Bezeichnung
  /// 2
  //Label;100;590;big;Stufe:
  /// 3
  //Label;500;570;big;Improve1
  /// 4
  //Label;500;620;big;Improve2
  //
  /// 5
  //Label;100;640;big;Preis:
  //
  //
  ///Stufe, 6
  //Label;260;590;big;0
  //
  ///Preis 7
  //Label;260;640;big;0
//-----------------------------------


  //Infos malen
  (self.LabelConfigList[0] as TLabelConfig).fLabel := 'Kapital: ' + inttostr(cdSpieler.Kapital);
  (self.LabelConfigList[2] as TLabelConfig).fLabel := 'Stufe:';
  (self.LabelConfigList[5] as TLabelConfig).fLabel := 'Preis:';
  (self.LabelConfigList[4] as TLabelConfig).fLabel := ' ';
  (self.LabelConfigList[8] as TLabelConfig).fLabel := ' ';
  (self.LabelConfigList[9] as TLabelConfig).fLabel := ' ';
  (self.LabelConfigList[10] as TLabelConfig).fLabel := ' ';

  (ImageConfigList[1] as TImageConfig).X := (LabelConfigList[0] as TLabelConfig).X + length((self.LabelConfigList[0] as TLabelConfig).fLabel)*15;
  (ImageConfigList[1] as TImageConfig).Y := (LabelConfigList[0] as TLabelConfig).y-10;


  Speicher := nil;
  case ShopOrBesitz of
    0:begin
        if cdSportshop.fAusruestungen.count > ItemNow then
        begin
          Speicher := cdSportshop.fAusruestungen[ItemNow] as TAusruestung;
        end;
      end;
    1:begin
        if cdSpieler.AusruestungRucksack.count > ItemNow then
        begin
          Speicher := cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung;
        end;
      end;
  end;



  if Speicher <> nil then
  begin
    (self.LabelConfigList[1] as TLabelConfig).fLabel := (Speicher as TAusruestung).Bezeichnung;
    (self.LabelConfigList[6] as TLabelConfig).fLabel := inttostr((Speicher as TAusruestung).Stufe);
    case ShopOrBesitz of
      0:(self.LabelConfigList[7] as TLabelConfig).fLabel := inttostr((Speicher as TAusruestung).Preis);
      1:(self.LabelConfigList[7] as TLabelConfig).fLabel := inttostr((Speicher as TAusruestung).PreisBesitz);
    end;

    (ImageConfigList[2] as TImageConfig).X := (LabelConfigList[7] as TLabelConfig).X + length((self.LabelConfigList[7] as TLabelConfig).fLabel)*15+10;
    (ImageConfigList[2] as TImageConfig).Y := (LabelConfigList[7] as TLabelConfig).y-10;


    //(self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';
    case (Speicher as TAusruestung).Klasse of
      1:(self.LabelConfigList[3] as TLabelConfig).fLabel :=   'Kraftausdauer: +' + inttostr((Speicher as TAusruestung).AddAusd) + '%';
      2:(self.LabelConfigList[3] as TLabelConfig).fLabel :=   'Maximalkraft: +' + inttostr((Speicher as TAusruestung).AddMaxKr) + '%';
      3:(self.LabelConfigList[3] as TLabelConfig).fLabel :=   'Technik: +' + inttostr((Speicher as TAusruestung).AddTechnik) + '%';
      4:begin
          (self.LabelConfigList[3] as TLabelConfig).fLabel := '    Maximalkraft: +' + inttostr((Speicher as TAusruestung).AddMaxKr);
          (self.LabelConfigList[4] as TLabelConfig).fLabel := '   Kraftausdauer: +' + inttostr((Speicher as TAusruestung).AddAusd);
          (self.LabelConfigList[8] as TLabelConfig).fLabel := 'Fitnessverbrauch: ' + inttostr((Speicher as TAusruestung).Fitnessverbrauch);
          (self.LabelConfigList[9] as TLabelConfig).fLabel := '  Wiederholungen: ' + inttostr((Speicher as TAusruestung).AnzahlWiederholungen);
          (self.LabelConfigList[10] as TLabelConfig).fLabel :='   Schwierigkeit: ' + inttostr((Speicher as TAusruestung).Schwierigkeit)+'/10';
        end;
    end;
  end else
  begin
    (self.LabelConfigList[1] as TLabelConfig).fLabel := '-';
    //(self.LabelConfigList[2] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[3] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[4] as TLabelConfig).fLabel := ' ';
    //(self.LabelConfigList[5] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[6] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[7] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[8] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[9] as TLabelConfig).fLabel := ' ';
    (self.LabelConfigList[10] as TLabelConfig).fLabel := ' ';
  end;

end;



procedure TEinkaufenMenuClass.DrawMenuSpecific;
var
  surface:TDirectDrawSurface;
  tt : TDIB;
  i : integer;
  Besch : string;
  klasse : integer;
begin
  try
    form1.DXPowerFont1.Font := 'Font1';
    form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,80,20,'SPORTSHOP');
    form1.DXPowerFont1.TextOutFast(form1.DXDraw1.Surface,525,20,'EIGENTUM');

    //Markierung malen
    case ShopOrBesitz of
      0:begin
          (self.ImageConfigList[0] as TImageConfig).X := self.KoordsShop[ItemNow].X-4;
          (self.ImageConfigList[0] as TImageConfig).Y := self.KoordsShop[ItemNow].Y-4;
        end;
      1:begin
          (self.ImageConfigList[0] as TImageConfig).X := self.KoordsBesitz[ItemNow].X-4;
          (self.ImageConfigList[0] as TImageConfig).Y := self.KoordsBesitz[ItemNow].Y-4;
        end;
    end;


    //Icons malen
    surface := TDirectDrawSurface.Create(fdxDraw.DDraw);

    //Rucksack Ausrüstung malen
    for i := 0 to cdSpieler.AusruestungRucksack.Count - 1 do
    begin
      //Icon malen
      surface.LoadFromDIB((cdSpieler.AusruestungRucksack[i] as TAusruestung).Icon);
      fDXDraw.Surface.Draw(self.KoordsBesitz[i].X,self.KoordsBesitz[i].y,surface,false);
    end;

    //Sportshop Ausrüstung malen
    for i := 0 to cdSportshop.fAusruestungen.Count - 1 do
    begin
      //Icon malen
      surface.LoadFromDIB((cdSportshop.fAusruestungen[i] as TAusruestung).Icon);
      fDXDraw.Surface.Draw(self.KoordsShop[i].X,self.KoordsShop[i].y,surface,false);
    end;


//    //Infos anzeigen
//    (self.LabelConfigList[0] as TLabelConfig).fLabel := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Bezeichnung ;
//
//    //Beschreibung korrekt anzeigen
//    (self.LabelConfigList[8] as TLabelConfig).fLabel := ' ';
//    (self.LabelConfigList[14] as TLabelConfig).fLabel := ' ';
//
//    Besch := (cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung;
//    if length(Besch) > 45 then
//    begin
//      (self.LabelConfigList[8] as TLabelConfig).fLabel := copy(DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung),1,45);
//      (self.LabelConfigList[14] as TLabelConfig).fLabel := copy(DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung),46,Length(Besch)-45);
//    end else
//    begin
//      (self.LabelConfigList[8] as TLabelConfig).fLabel := DeleteMindString((cdSpecialMoves.fSpecialMoves[SMNow] as TSpecialMove).Beschreibung);
//    end;

  finally
    freeandnil(surface);
  end;
end;


constructor TEinkaufenMenuClass.create(DXDraw:TDXDraw;Engine:TDXSpriteEngine);
var
 i, j : integer;
 sx,sy : integer;
 lauf : integer;
begin
  form1.Logger.Add('TEinkaufenMenuClass.create');

  inherited create(dxdraw,engine);
  ItemNow := 0;
  ShopOrBesitz := 0;

  //Koordinaten festlegen

  //Ausrüstung Sportshop
  sx := round(24/1.28);
  sy := round(77/1.28);
  lauf := 0;
  for i := 0 to 3 do //Zeilen
  begin
    for j := 0 to 3 do //Spalten
    begin
      KoordsShop[lauf].X := sx;
      KoordsShop[lauf].y := sy;
      inc(sx,round(105/1.28));
      inc(lauf);
    end;
    sx := round(24/1.28);
    inc(sy,round(105/1.28));
  end;


  //Ausrüstung Besitz
  sx := round(584/1.28);
  sy := round(77/1.28);
  lauf := 0;
  for i := 0 to 3 do //Zeilen
  begin
    for j := 0 to 3 do //Spalten
    begin
      KoordsBesitz[lauf].X := sx;
      KoordsBesitz[lauf].y := sy;
      inc(sx,round(105/1.28));
      inc(lauf);
    end;
    sx := round(584/1.28);
    inc(sy,round(105/1.28));
  end;
  MouseDown(KoordsShop[0].X,KoordsShop[0].Y);
  form1.Logger.Add('TEinkaufenMenuClass.create PASSED');

end;

procedure TEinkaufenMenuClass.ButtonPress(bIndex:integer);
var
  Speicher : TAusruestung;
begin
  try
    Speicher := nil;
    case bIndex of
      1 : begin
              Form1.NewMenu;
              Form1.fActiveMenu := TGameMenuClass.Create(Form1.DXDraw1,Form1.dxs1); {Neues Menüobjekt erzeugen}
              Form1.DXDraw1.restore; {Darstellung aktualisieren}
              exit;
          end;

      0 : begin
            case ShopOrBesitz of
              0 : begin //Kaufen
                    // Prüfungen: Liegt was auf Feld? Genug Kapital? Genug Platz?
                    if ItemNow < cdSportShop.fAusruestungen.Count then
                    begin
                      if cdSpieler.Kapital >= (cdSportshop.fAusruestungen[ItemNow] as TAusruestung).Preis then
                      begin
                        if cdSpieler.AusruestungRucksack.Count < 16 then
                        begin
                          form1.PlayBuy;

                          //Bezahlen
                          cdSpieler.Kapital := cdSpieler.Kapital - (cdSportshop.fAusruestungen[ItemNow] as TAusruestung).Preis;

                          //Übergabe
                          Speicher := cdSportshop.fAusruestungen[ItemNow] as TAusruestung;
                          cdSportshop.fAusruestungen.Extract(cdSportshop.fAusruestungen[ItemNow]);
                          cdSpieler.AusruestungRucksack.Add(Speicher);

                          //Markierung setzen
                          MouseDown(KoordsBesitz[cdSpieler.AusruestungRucksack.Count-1].X, KoordsBesitz[cdSpieler.AusruestungRucksack.Count-1].Y);
                        end else
                        begin
                          form1.PlayNo;
                        end;
                      end else
                      begin
                        form1.PlayNo;
                      end;
                    end else
                    begin
                      form1.PlayNo;
                    end;
                  end;

              1 : begin //Verkaufen
                    // Prüfungen: Liegt was auf Feld? Genug Kapital? Genug Platz?
                    if ItemNow < cdSpieler.AusruestungRucksack.Count then
                    begin
                      form1.PlayBuy;

                      //Bezahlen
                      cdSpieler.Kapital := cdSpieler.Kapital + (cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung).PreisBesitz;

                      if cdSportshop.fAusruestungen.Count < 16 then
                      begin
                        //Übergabe
                        Speicher := cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung;
                        cdSpieler.AusruestungRucksack.Extract(cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung);
                        cdSportshop.fAusruestungen.Add(Speicher);

                        //Markierung setzen
                        MouseDown(KoordsShop[cdSportshop.fAusruestungen.Count-1].X, KoordsShop[cdSportShop.fAusruestungen.Count-1].Y);
                      end else
                      begin
                        cdSpieler.AusruestungRucksack.Extract(cdSpieler.AusruestungRucksack[ItemNow] as TAusruestung);
                      end;
                    end else
                    begin
                      form1.PlayNo;
                    end;

                  end;
            end;
          end;
    end;
  except
    on e:exception do
      showmessage('Main->TEinkaufenMenuClass->ButtonPress: ' + e.message);
  end;
end;

procedure TTestMenuClass.ButtonPress(bIndex:integer);
begin
//  freeandnil(Form1.fActiveMenu);
//  Form1.fActiveMenu := TMainMenuClass.Create(Form1.DXDraw1);
//  Form1.DXDraw1.restore;
end;


{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  crMyCursor: TCursor;
  i : integer;
begin

  fMuckebox := TMuckeBox.create;

  fSoundOn := true;

  //Savegamesordner erzeugen
  if not DirectoryExists(extractfilepath(application.exename) + 'Savegames') then
  begin
    ForceDirectories(extractfilepath(application.exename) + 'Savegames');
  end;

  //Sound

  //AudioOut1.run;
  //AudioOut1.Volume := 220;

  //  DXWaveList1.Items[0].Volume -2000 bis 6000
  //--


  logger := TLog.create;
  logger.Add('Armwrestling Champion');
  logger.add('Version ' + cRelease);

  form1.Logger.Add('TForm1.create');

  fSleepValue := 0;
  fFrameCounter := -1;
  try

  //    fFire := TFireSpark.Create(DXDraw1);
    FDoFire := true;
    SetupSpark;

    //dxdraw1.Display.BitCount := 16;

    {Schrift}
//    AddFontResource(PChar(ExtractFilePath(ParamStr(0) + 'images\AWF.TTF')));
//    SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
    DXPowerFont1.Alphabets := cMyFont;


    {Universales TEdit initialisieren}
//    FEdit := TEdit.Create(form1.dxdraw1);
//    FEdit.Parent := form1.dxdraw1;
//    FEdit.Left := round(100/1.28);
//    FEdit.Top := round(100/1.28);
//    FEdit.Width := round(200/1.28);
//    FEdit.Font.Size := 12;
//    FEdit.Font.Style := [fsBold];
//    FEdit.Color := clwhite;
//    FEdit.text := 'Bomber';
//    FEdit.Visible := false;

    {Cursor}
//    Screen.Cursors[crMyCursor]:=LoadCursorFromFile(PChar(GetVerzImages+'Cursor.ico'));
//    Screen.Cursor := crMyCursor;
    Screen.Cursor := crNone;
    DXBasic.Items.Clear;
    dxBasic.items.Add;
    DXBasic.Items.Items[0].Picture.LoadFromFile(GetVerzImages+'Cursor.bmp');
    DXBasic.Items.items[0].Transparent := true;
    DXBasic.Items.items[0].TransparentColor := clWhite;

    {Objekt für Hauptmenü erzeugen}
    fActiveMenu := TMainMenuClass.Create(DXDraw1,dxs1);

    //Fade-Daten
    fadxDIB1 := TDXDib.Create(dxdraw1);
    faBackground := TDXDIB.Create(dxdraw1);
    faBackground.DIB.Assign(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
    faDXDIB1.DIB.SetSize(faBackground.DIB.Width,faBackground.DIB.Height,faBackground.DIB.BitCount);
    FillDIB8(faDXDIB1.DIB,255);
    fac:=0;

    //fMuckebox.PlayMusic(extractfilepath(application.exename) + 'Sounds\back2.ogg');
    LoadVolumes;
    PlayMusic1;

    form1.Logger.Add('TForm1.create PASSED');
//    AudioOut1.run;

  except
    on e:exception do
    begin
      form1.Logger.Add('TForm1.create ' + e.message);
       showmessage('Main->FormCreate: '+e.Message);
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
	i : Integer;
begin
  try
  //  for i := low(Form1.fActiveMenu.fAnims) to high(Form1.fActiveMenu.fAnims) do
  //  begin
  //    Form1.fActiveMenu.fAnims[i].Dead;
  //  end;

//    RemoveFontResource(PChar(ExtractFilePath(ParamStr(0) + 'image\AWF.TTF')));
//    SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);

//    freeandnil(FEdit);
    freeandnil(fActiveMenu);
    freeandnil(Logger);

    //fade-daten
    freeandnil(fadxDIB1);
    freeandnil(faBackground);

    freeandnil(fMuckebox);

    //AudioOut1.Stop;
    //while AudioOut1.Status <> tosIdle do;

  except
    on e:exception do
      showmessage('Main->FormClose: ' + e.message);
  end;
end;

procedure TForm1.SetupSpark;
var
  i : integer;
begin
  For i := 0 To high(FSparks) Do
    With FSparks[i] Do
    Begin
      X := Width / 2;
      Y := Width / 2;
      SX := (random(11) - 5) / 5;
      SY := (random(11) - 5) / 5;
      Age := 0;
      Aging := (random(15) + 2) / 150;
    End;
end;

procedure TForm1.PaintFire;
var
  i : integer;
  rect:TRect;
begin
  if not fDoFire then exit;
  If NOT DXDraw1.CanDraw Then Exit;

  //200-300
  //250-350
  //FBackBuffer.DIB.Assign(fActiveMenu.fDXList.Items.Items[fActiveMenu.BackConfig.ListIndex+fActiveMenu.BackConfig.fIndex].Picture);
  //FBackBuffer.DIB.

  FBackBuffer.DIB.Assign(DXImageList1.Items.Find('Background').Picture);
  DXDIB1.DIB.Assign(DXImageList1.Items.Find('Sparks').Picture);

  For i := 0 To High(FSparks) Do
    With FSparks[i] Do
    Begin
      Age := Age + Aging+0.05;
      X := X + SX;
      Y := Y + SY;

      If (Age > 1) Or (X < 0) Or (X + DXImageList1.Items.Find('Sparks').Height > DXDraw1.Width) Or (Y < 0) Or (Y + DXImageList1.Items.Find('Sparks').Height > DXDraw1.Height) Then
      Begin
        X := 25;  //FX;
        Y := 38;  //FY;
        SX := (random(21) - 10) / 5;
        SY := (random(21) - 10) / 5;
        Age := 0;
        Aging := (random(10) + 3) / 100;
      End;

      DrawAdditive(FBackBuffer.DIB, DXDIB1.DIB, round(X), round(Y), DXImageList1.Items.Find('Sparks').Height, DXImageList1.Items.Find('Sparks').Height, 255,ROUND(Age * 4));
    End;

    rect.Left := 208;
    rect.Top := 264;
    rect.Right := FBackBuffer.DIB.Width;
    rect.Bottom := FBackBuffer.DIB.height;
    DrawOn(FBackBuffer.DIB.Canvas,Rect, DXDraw1.Surface.Canvas, 0, 0);


//  with DXDraw1.Surface.Canvas do
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
  //dxdraw1.Surface.Canvas.Release;
  //DXDraw1.Flip;
end;

procedure TForm1.PaintIt;
var
  i : integer;
  CPos:TPoint;
  dcc : HDC;
  dxdc:hdc;
  pp : HPen;
begin
  if (not GoIn) or (not GoOut) then exit;
  try
    dxs1.Engine.Dead; {"Tote" Menü-Animationen entfernen}

    if not DXDraw1.CanDraw then exit;
    DXDraw1.Surface.Fill(0);

//    dxdc := GetDC(dxdraw1.Handle);
//    SetBkColor(dxdc,clBlack);
//    SetTextColor(dxdc,clWhite);
//    TextOut(dxdc,200,200,PChar('Test'),4);
//    SetText
//    ReleaseDC(dxdraw1.Handle, dxdc);


    {Standard Menü-Items zeichnen}
    GetCursorPos(CPos);
    if factivemenu <> nil then
    begin
      factivemenu.MouseOver(cpos.x,cpos.y); //Menu Specific
      fActiveMenu.CheckButtonsOver(CPos); //Menu Standard
      fActiveMenu.DrawAll; //Menu Standard
      fActiveMenu.SetButtonsStandard; //Menu Standard
    end;

    {Text - Test}
//    DXPowerFont1.TextOutEffect := teAlphaBlend;
//    DXPowerFont1.EffectsParameters.AlphaValue := 140;
//    DXPowerFont1.TextOut(dxdraw1.Surface,100,300,'AaBbCcDd0123456789');


    {Cursor zeichnen}
    DXBasic.Items.Items[0].Draw(dxdraw1.Surface,CPos.X,CPos.Y,0);

//    FFire.MakeFire1;

  //  {Hintergrund zeichnen}
  //  fActiveMenu.backgrounds.Items.Items[fActiveMenu.fBackgroundIndex].Draw(dxdraw1.Surface,0,0,0); {Hintergrundbild zeichnen}
  //
  //  {Restliche Bilder zeichnen}
  //  for i := 0 to fActiveMenu.Images.Items.Count - 1 do
  //  begin
  //    case (fActiveMenu.ConfigPosList [i] as TMenuConfig).fStyle of
  //    	1..3 : if (fActiveMenu.ConfigPosList [i] as TMenuConfig).fActive then
  //                fActiveMenu.Images.Items.Items[i].Draw(dxdraw1.Surface,(factivemenu.configposlist[i] as TMenuConfig).fleft ,(factivemenu.configposlist[i] as TMenuConfig).ftop,0);
  //
  //      4 : ;//fActiveMenu.Images.Items.Items[i].Draw(dxdraw1.Surface,(factivemenu.configposlist[i-1] as TMenuConfig).fleft ,(factivemenu.configposlist[i-1] as TMenuConfig).ftop,0);
  //
  //      5 : if (fActiveMenu.ConfigPosList [i] as TMenuConfig).fActive then
  ////                fActiveMenu.Images.Items.Items[i].DrawAlpha(dxdraw1.Surface,rect,0,255);
  //      					fActiveMenu.Images.Items.Items[i].Draw(dxdraw1.Surface,(factivemenu.configposlist[i] as TMenuConfig).fleft ,(factivemenu.configposlist[i] as TMenuConfig).ftop,0);
  //    end;
  //  end;
  //
  //
  //

//    PaintFire;


    dxs1.Move(0);
    dxs1.Draw;
  //
  //  //Komponenten aktualisieren
  //  for i := 0 to factiveMenu.Labels.Count - 1 do
  //  begin
  //    (factiveMenu.Labels[i] as TLabel).invalidate;
  //  end;




    dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
    dxdraw1.Flip;

//    if assigned(ffight) then
//    begin
//      PP := CreatePen(PS_SOLID, 5, RGB(255, 0, 255));
//      dcc := GetWindowDC(dxDraw1.Handle);
//      SelectObject(dcc, PP);
//
//      MoveToEx(dcc,Mouse.CursorPos.X, Mouse.CursorPos.Y,nil);
//      LineTo(dcc,fFight.fGravityPoint.X,fFight.fGravityPoint.y);
//
//      DeleteObject(PP);
//      ReleaseDC(dxDraw1.Handle, dcc);
//    end;



//    FEdit.invalidate;
//    FEdit.SendToBack;

    //HintergrundAnim anzeigen
    if factivemenu <> nil then
    begin
      if fActiveMenu.BackConfig.fIndex = 2 then
      begin
        sleep(300);
        fActiveMenu.BackConfig.fIndex := 0;
      end;
    end;
    
//    if fShowEdit then
//    begin
//      if form1.FEdit.Visible = false then
//      begin
//        form1.FEdit.Visible := true;
//        form1.FEdit.SetFocus;
//      end else
//      begin
//        form1.FEdit.Visible := true;
//      end;
//    end else
//      form1.FEdit.Visible := false;

  except
    on e:exception do
      showmessage('Main->PaintIt: ' + e.message);
  end;
end;

{Main-Loop}
procedure TForm1.DXTimer1Timer(Sender: TObject; LagCount: Integer);
var
  i : integer;
begin
  // -> "Primary" = Primary Surface
  // -> "Surface" = Secondary Surface

  //FadeOut
  If not GoOut then
  begin
    FadeItOut(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
    GoOut := true;
  end;

  //FadeIn
  if not GoIn then
  begin
    FadeIt(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
    GoIn := true;
  end;

  PaintIt;

  //30 Frames / Sekunde
  if dxtimer1.FrameRate > 30 then
  begin
    dxtimer1.Interval := dxtimer1.Interval + 1;
  end else
  begin
    if dxtimer1.Interval > 0 then dxtimer1.Interval := dxtimer1.Interval - 1;
  end;

end;

procedure TForm1.DXDraw1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var
	i : Integer;
begin

end;

{Zentrale Routine für alle Menüs um Mausklick-Aktivitäten zu verarbeiten}
procedure TForm1.DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
	overIndex : integer;
  Point:TPoint;
begin
  //Fight
  if assigned(fFight) then
  begin
    fFight.MouseDown(Button,x,y);
  //Train
  end else if assigned(fTrain) then
  begin
    fTrain.MouseDown(Button);
  //Menus
  end else if factivemenu <> nil then
  begin
    try
      Point.x := x;
      Point.Y := y;
      overIndex :=fActiveMenu.CheckButtonsOver(Point);
      if overIndex <> -1 then
      begin
        fActiveMenu.SetButtonDown(overIndex);
        fActiveMenu.ButtonPress(overIndex);
        exit;
      end;
      factivemenu.MouseDown(x,y);
    except
      on e:exception do
        showmessage('Main->DXDraw1MouseDown: ' + e.message);
    end;
  end;
end;

procedure TForm1.FightTimerProcess(Sender: TObject);
var
  MSEnd : DWORD;
  MSAll : DWORD;
  FrameRate : integer;
begin
  FrameRate := 30;

  if fFrameCounter = -1 then
  begin
    MSStart := GetTickCount;
  end;

  if fFrameCounter = 0 then
  begin
    MSEnd := GetTickCount;
    MSALL := MSEnd - MSStart;

    if MSAll*FrameRate < 1000 then
    begin
      fSleepValue := (1000 - MSAll * FrameRate) div FrameRate;
    end else
    begin
      fSleepValue := 0;
    end;

    MSStart := GetTickCount;
    fFrameCounter := -1;
  end;

  inc(fFrameCounter);

  sleep(fSleepValue);


  
  try
    if assigned(fActiveMenu) then
    begin
      // -> "Primary" = Primary Surface
      // -> "Surface" = Secondary Surface

      //FadeOut
      If not GoOut then
      begin
        FadeItOut(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
        GoOut := true;
      end;

      //FadeIn
      if not GoIn then
      begin
        FadeIt(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
        GoIn := true;
      end;

      PaintIt;

{FIGHT}
    end else if assigned(fFight) then
    begin
      if not DXDraw1.CanDraw then exit;
      DXDraw1.Surface.Fill(0);

      fFight.DoFight;
      DXPowerFont1.TextOutFast(DXDraw1.Surface,10,10,'Framerate: ' + inttostr(FightTimer.FrameRate));

      dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
      dxdraw1.Flip;
{TRAIN}
    end else if assigned(fTrain) then
    begin
      if not DXDraw1.CanDraw then exit;
      DXDraw1.Surface.Fill(0);

      fTrain.DoTrain;

      DXPowerFont1.TextOutFast(DXDraw1.Surface,10,10,'Framerate: ' + inttostr(FightTimer.FrameRate));
      dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
      dxdraw1.Flip;
    end;



    if FightTimer.FrameRate < 10 then FightTimer.Speed := FightTimer.Speed + 1;
    if FightTimer.FrameRate > 10 then FightTimer.Speed := FightTimer.Speed - 1;

  except
    on e:exception do
    begin
      ShowMessage('Main->FightTimerProcess: ' + e.Message);
    end;
  end;
end;

procedure TForm1.Action1Execute(Sender: TObject);
begin
  close;
end;

procedure TForm1.Action2Execute(Sender: TObject);
begin
  if assigned(fFight) then
  begin
    fFight.ShowFrame := 2;
  end else if assigned(form1.factivemenu) then
  begin
    cdzeit.Woche := 4;
  end;
end;

procedure TForm1.DXDraw1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if assigned(fTrain) then fTrain.MouseUp(button);
  if assigned(factiveMenu) then factiveMenu.mouseUp;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
  if assigned(fActiveMenu) then
  begin
    if fActiveMenu is TCreatePlayerClass then
    begin

      //Key = backspace?
      if key = VK_BACK then
      begin
        if length((fActiveMenu as TCreatePlayerClass).CPSpielerName) > 0 then
        begin
          (fActiveMenu as TCreatePlayerClass).CPSpielerName := copy((fActiveMenu as TCreatePlayerClass).CPSpielerName,1,length((fActiveMenu as TCreatePlayerClass).CPSpielerName)-1 );
        end;
      end;

      //Key = zwischen 0-9 oder a-z oder A-Z ? 32 - 126
      if ((key >= 48) and (key <= 57)) or ((key >= 65) and (key <= 90)) or ((key >= 97) and (key <= 122))then
      begin
        if length((fActiveMenu as TCreatePlayerClass).CPSpielerName) < 13 then
        begin
          (fActiveMenu as TCreatePlayerClass).CPSpielerName := (fActiveMenu as TCreatePlayerClass).CPSpielerName + char(key);
        end;
      end;

      if key = VK_SPACE then
      begin
        if length((fActiveMenu as TCreatePlayerClass).CPSpielerName) < 13 then
        begin
          (fActiveMenu as TCreatePlayerClass).CPSpielerName := (fActiveMenu as TCreatePlayerClass).CPSpielerName + ' ';
        end;
      end;
    end;
  end;
end;

procedure TForm1.FightTimerRealTime(Sender: TObject; Delta: Real);
var
  MSEnd : DWORD;
  MSAll : DWORD;
  FrameRate : integer;
begin
  FrameRate := 30;

  //--Framerate einstellen---
  if fFrameCounter = -1 then
  begin
    MSStart := GetTickCount;
  end;

  if fFrameCounter = 0 then
  begin
    MSEnd := GetTickCount;
    MSALL := MSEnd - MSStart;

    if MSAll*FrameRate < 1000 then
    begin
      fSleepValue := (1000 - MSAll * FrameRate) div FrameRate;
    end else
    begin
      fSleepValue := 0;
    end;

    MSStart := GetTickCount;
    fFrameCounter := -1;
  end;

  inc(fFrameCounter);

  sleep(fSleepValue);
  //--Framerate einstellen---





  // delta = 1.0 -> speed, delta = 2.0 -> 1/2 speed
  try
    if assigned(fActiveMenu) then
    begin
      // -> "Primary" = Primary Surface
      // -> "Surface" = Secondary Surface

      //FadeOut
      If not GoOut then
      begin
//        FadeItOut(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
//        GoOut := true;
      end;

      //FadeIn
      if not GoIn then
      begin
//        FadeIt(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
//        GoIn := true;
      end;


      //Fade By Timer - TEST ->
          if fac < 140-fadespeed then
          begin
            fasStart := GetTickCount;
            FadeIn(faBackGround.DIB,faDXDIB1.DIB,fac);
            if DXDraw1.CanDraw then begin
              DXDraw1.Surface.Assign(faDXDIB1.DIB);
              dxdraw1.Flip;
              //dxdraw1.
            end;
            Application.ProcessMessages;
            inc(fac,FadeSpeed);
          end else
          begin
            GoIn := true;
            if factivemenu is TMainMenuClass then
            begin
//              form1.faBackground.DIB.Assign(factivemenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
//              form1.faDXDIB1.DIB.SetSize(form1.faBackground.DIB.Width,form1.faBackground.DIB.Height,form1.faBackground.DIB.BitCount);
//              form1.FillDIB8(form1.faDXDIB1.DIB,255);
//              Form1.FadeSpeed := 2;
//              form1.fac:=0;
            end;
          end;
      //FADE By Timer TEST <-

      PaintIt;

{FIGHT}
    end else if assigned(fFight) then
    begin
      if not DXDraw1.CanDraw then exit;
      DXDraw1.Surface.Fill(0);

      fFight.DoFight;

      dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
      dxdraw1.Flip;
{TRAIN}
    end else if assigned(fTrain) then
    begin
      if not DXDraw1.CanDraw then exit;
      DXDraw1.Surface.Fill(0);

      fTrain.DoTrain;

      dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
      dxdraw1.Flip;
    end;

//    if FightTimer.FrameRate < 20 then FightTimer.Speed := FightTimer.Speed + 1;
//    if FightTimer.FrameRate > 20 then FightTimer.Speed := FightTimer.Speed - 1;


  except
    on e:exception do
    begin
      ShowMessage('Main->FightTimerProcess: ' + e.Message);
    end;
  end;
end;

procedure TForm1.DXTimer2Timer(Sender: TObject; LagCount: Integer);
var
  MSEnd : DWORD;
  MSAll : DWORD;
  FrameRate : integer;
begin
  FrameRate := 30;

  //--Framerate einstellen---
  if fFrameCounter = -1 then
  begin
    MSStart := GetTickCount;
  end;

  if fFrameCounter = 0 then
  begin
    MSEnd := GetTickCount;
    MSALL := MSEnd - MSStart;

    if MSAll*FrameRate < 1000 then
    begin
      fSleepValue := (1000 - MSAll * FrameRate) div FrameRate;
    end else
    begin
      fSleepValue := 0;
    end;

    MSStart := GetTickCount;
    fFrameCounter := -1;
  end;

  inc(fFrameCounter);

  sleep(fSleepValue);
  //--Framerate einstellen---





  // delta = 1.0 -> speed, delta = 2.0 -> 1/2 speed
  try
    if assigned(fActiveMenu) then
    begin
      // -> "Primary" = Primary Surface
      // -> "Surface" = Secondary Surface

      //FadeOut
      If not GoOut then
      begin
        FadeItOut(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
        GoOut := true;
      end;

      //FadeIn
      if not GoIn then
      begin
        FadeIt(fActiveMenu.fDXList.Items.Items[factivemenu.BackConfig.ListIndex].Picture);
        GoIn := true;
      end;

      PaintIt;

{FIGHT}
    end else if assigned(fFight) then
    begin
      if not DXDraw1.CanDraw then exit;
      DXDraw1.Surface.Fill(0);

      fFight.DoFight;

      dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
      dxdraw1.Flip;
{TRAIN}
    end else if assigned(fTrain) then
    begin
      if not DXDraw1.CanDraw then exit;
      DXDraw1.Surface.Fill(0);

      fTrain.DoTrain;

      dxdraw1.Surface.Canvas.Release; {Vor Surface-Wechsel muss die Zeichenfläche freigegeben werden}
      dxdraw1.Flip;
    end;

    if FightTimer.FrameRate < 20 then FightTimer.Speed := FightTimer.Speed + 1;
    if FightTimer.FrameRate > 20 then FightTimer.Speed := FightTimer.Speed - 1;


  except
    on e:exception do
    begin
      ShowMessage('Main->FightTimerProcess: ' + e.Message);
    end;
  end;


end;

procedure TForm1.FormShow(Sender: TObject);
begin
  //fActiveMenu.AfterAltTab;
//  dxdraw1.Restore;
  //DXDraw1.Finalize;
//  DXDraw1.Options := DXDraw1.Options + [doFullScreen];
  //DXDraw1.Initialize;
end;

end.
