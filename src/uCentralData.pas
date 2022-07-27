{
  Regelt die komplette Datenverwaltung

  Projekt:  Armwrestling
  Unit:     uCentralData.pas
  Stand:    19.Januar 2005
  (c) Christian Merz 2005
}

unit uCentralData;

interface

uses
	contnrs, classes, sysutils, forms, math, types, Dib, jpeg, PlusLibrary,dialogs,FileCrypt;

const
	cUCDWochen=5;
  cUCDTage=6;
  cUCDGegner=5;

//  cUCDMinValueL3=100;
//  cUCDMaxValueL3=200;
//  cUCDMinValueL2=200;
//  cUCDMaxValueL2=300;
//  cUCDMinValueL1=300;
//  cUCDMaxValueL1=500;
//  cUCDValuesBigBoss=1000;

  cUCDLevelMin1=15;
  cUCDLevelMax1=25;
  cUCDLevelMin2=10;
  cUCDLevelMax2=15;
  cUCDLevelMin3=6;
  cUCDLevelMax3=10;
  cUCDLevelMin4=3;
  cUCDLevelMax4=6;
  cUCDLevelMin5=1;
  cUCDLevelMax5=3;



  cSponsorLaufzeitMin=1;
  cSponsorLaufzeitMax=4;

  cUCDSponsorenPerWeekMax=7;
  cUCDSponsorenPerWeekMin=3;


  cNeuerSponsor='Sponsor: ';
  cSponsorVertragEnde='Vertragsende: ';

  cNeuesTurnier='Neues Turnier: ';

  cUCDConfigVerz='Config\';
  cUCDVerzVornamen=cUCDConfigVerz+'Vornamen.dat';
  cUCDVerzNachnamen=cUCDConfigVerz+'Nachnamen.dat';
  cUCDVerzStufen=cUCDConfigVerz+'Stufen.dat';
  cUCDVerzSaveGames='Saves';

  //AWE := Armwrestling Editor
  cUCDSponsorenFile=cUCDConfigVerz+'AWESponsorenConf.awe';
  cUCDSpecialMovesFile=cUCDConfigVerz+'AWESpecialMovesConf.awe';
  cUCDAusruestungsFile=cUCDConfigVerz+'AWEAusruestungsConf.awe';
  cUCDTurniereFile=cUCDConfigVerz+'AWETurniereConf.awe';
  cUCDDatenFile=cUCDConfigVerz+'AWEDatenConf.awe'; // Alle Werte, die das Spiel beeinflussen
  cUCDPlayerFile=cUCDConfigVerz+'AWEPlayerConf.awe';

  cUCDNeueAusruestung='Sportshop: ';
  cNeuerKneipenGegner='Kneipe: ';

  cLevelUp='+LEVELAUFSTIEG+';

type
  TPointArray = array of TPoint;
  TSpecialMoves = class;
  TAusruestung = class;
  TSponsor = class;

  TOtherData = class
    fVornamen : TStringList;
    fNachnamen : TStringList;
    fStufen : TStringList;

    function GetStufenString(Stufe:integer):string;

    constructor create;
    destructor destroy;override;
  end;


  TZeit = class
  public
    Woche : integer; // 1-19
    Tag : integer; // 1-7
  	Runde : Integer; // 1 Hinrunde, 2 Rückrunde
    Saison : integer; // Fortschreitender Wert
    NextRound : boolean;
    NextSaison : boolean;
    NextWeek : boolean;

    function VergleicheZeiten(Zeit1,Zeit2:TZeit):integer; // 0 = gleich, 1 = Zeit1 ist größer, 2 = Zeit2 ist größer
    procedure IncDay;
    procedure IncWeek(Count:integer);
    procedure IncRunde;
    function TagString:string;
    function TagStringGanz:string;

    constructor Create(Woche_,Tag_,Runde_:integer; Saison_:integer);
  end;

  TSportler = class
  public
    ID : Integer;
    Vorname : string;
    Name : string;
    Alter : Integer;

    Level : Integer;
    Erfahrung: Integer;
    FitnessMaximum : integer;
    Fitness : Integer;
    Ansehen : Integer;
    Maximalkraft : integer;
    Kraftausdauer : integer;
    Technik : integer;
    Liga : Integer;

    IstSpieler:boolean;

    Siege : Integer; // Diese Saison
    Niederlagen : Integer; // Diese Saison

    function Rang : integer;
  	constructor Create(ID_:Integer;Vorname_:string; Name_:string; Maxkraft_:Integer; Ausdauer_:integer; Technik_:Integer; Liga_:Integer; Siege_:Integer; Niederlagen_:Integer; Alter_:Integer; Level_, Erfahrung_, Fitness_, Ansehen_: integer;FitnessMaximum_:integer);
  end;

  TSpieler = class(TSportler)
  public
    //Image:TImage; // -> Steht in Config Datei !!! ???
    Kapital : integer;
    Siege_Alle : Integer;
    Niederlagen_Alle : Integer;
    Turnierteilnahmen : integer;
    Turniersiege : integer;

    Meisterschaften5 : integer;
    Meisterschaften4 : integer;
    Meisterschaften3 : integer;
    Meisterschaften2 : integer;
    Meisterschaften1 : integer;

    TurnierKneipeSieg : boolean;
    TurnierBeginnersCornerSieg : boolean;
    TurnierProfiturnierSieg : boolean;
    TurnierEuropameisterschaftSieg : boolean;
    TurnierSportCafeTurnierSieg : boolean;
    TurnierRummelRingenSieg : boolean;
    TurnierProletenClubSieg : boolean;
    TurnierSemiProTurnier : boolean;
    TurnierWeltmeisterschaft : boolean;
    TurnierMeisterTurnier : boolean;

    Sponsor : TSponsor;
    fLevelUpValues:TStringList;
    fLevelUp : boolean;
    fLevelUpPoints : integer;

    regenerationsrate : integer; // -> 15,25,35,45,55 (0,30,100,200,300)

    EndeShown : boolean; //Endebildschirm schon gezeigt?

    AusruestungRucksack : TObjectList;
    AusruestungAngezogen : TObjectList;

    function FitnessProzent:integer; //liefert zurück wieviel Prozent Fitness übrig sind

    //Mit Kleidungs Improvements und Fitness % Abzug
//    function GetFitness : integer;


    function GetMaximalkraft : integer;
    function GetKraftausdauer : integer;
    function GetTechnik : integer;

    procedure incFitnessProzent(prozent:integer); //Fitness um "Prozent" Prozent erhöhen

    procedure TurnierGewonnen(bez:string);
    procedure MeisterschaftGewonnen(index:integer);
    procedure MieteZahlen;
    procedure CheckSpieler; // Sponsoren, Levelup
    function GetNextLevelUpExperience:integer;
  	constructor Create(Vorname_:string; Name_:string; Maxkraft_:Integer; Ausdauer_:integer; Technik_:Integer; Liga_:Integer; Siege_:Integer; Niederlagen_:Integer; Alter_:Integer; Siege_Alle_:Integer; Niederlagen_Alle_:Integer; Kampfanzahl_:Integer; Kapital_:Integer; Woche_:Integer; Tag_:Integer; Runde_:Integer; Level_, Erfahrung_, Fitness_, Ansehen_: integer; AusruestungRucksack_:TObjectList;AusruestungAngezogen_:TObjectList;Sponsoren_:TObjectList;Turnierteilnahmen_,Turniersiege_,Meisterschaften3_,Meisterschaften2_,Meisterschaften1_:integer;FitnessMaximum_:integer);
    destructor destroy;override;
  end;

  TEreignisse = class
    Ereignisse:TStringList;
    artliste:TStringList;
    procedure AddEreignis(Bez:string;art:integer=0); //Wird von anderen Objekten aufgerufen, art: 0/1
    procedure DeleteAllEreignisse; //Jeden Tag
    constructor create;
    destructor destroy;override;
    // Meldung: zentriert, genau 30? Zeichen, kleiner: links und rechts mit Leerzeichen auffüllen
  end;

  TSponsor = class
    // Aus Config Datei
    Icon:TDXDib;
    IconPfad:string;
    Name:string;
    ID:integer;//(für Icon)

    //Berechnen
    Laufzeit:integer; //Laufzeit: randomrange(5..38) Wochen
    Geld:integer; //Geld/Woche: randomrange(1+Ansehen+(Laufzeit*Laufzeit)/100 .. 7+Ansehen+(Laufzeit*Laufzeit)/100)
    sieggeld:integer;
    AnzeigeTag:integer; //1..5 -> randomrange(1..5)
    VertragsAbschluss:TZeit;
    VertragsEnde:TZeit;

    procedure SchliesseVertrag;
    Constructor create(Ansehen:integer;Name:string;ID:integer;Pfad:string);
    destructor destroy;override;
  end;

  TSponsoren = class
    Namenliste : TStringList; //-> in Create aus ConfigFile laden, i = ID
    PfadListe : TStringList;
    fSponsoren : array of TSponsor;
    WochenSpons : array of integer;

    procedure ResetSponsoren; //Jede Woche, randomID aus Namenliste, Anzahl randomrange(0..2) erzeugen
    procedure CheckSponsoren; //Jeden Tag aufrufen, Generiert Ereignis

    constructor create;
    destructor destroy;override;
  end;

  TTriple = record
    x : integer;
    y : integer;
    z : integer;
  end;

  TTurnierRunde = class
    Begegnungen : array of TTriple;
    //SiegerIDs : TStringList;
    constructor create;
    destructor destroy;override;
  end;


  TTurnier = class
    //Daten aus Config-File
    Bezeichnung:string;
    Termin:TZeit;
    AnzahlGegner:integer; // 15, 31 oder 63

    lastround:boolean;
    MinLiga:integer; // 1..3
    MinLevel:integer; // 1..20
    MinAnsehen:integer;
    Startgebuehr:integer;
    PreisGeld:integer;
    Beschreibung:string;

    //Daten berechnen
    ID:integer;

    Teilnehmer : array of TSportler;
    Angemeldet:boolean; //Ist Spieler angemeldet?
    AktuelleRunde:integer;

    //Durchführung
    MachEreignis : integer; // 0 - kein Ereignis, 1 - Mach Ereignis, 2 - Ereignis gemacht
    Runden : array of TTurnierRunde; //setLength: 4,5 oder 6 (bei 15, 31 oder 63 Gegnern)
    Show : boolean;

    procedure reset; //Turnier in Ausgangszustand versetzen
    function anmelden:boolean;
    procedure BerechneKaempfe;
    constructor create(ID_:integer;Beschreibung_:string;Bezeichnung_:string;Termin_:TZeit;AnzahlGegner_:integer;MinLiga_:integer;MinLevel_:integer;MinAnsehen_:integer;Startgebuehr_:integer;Preisgeld_:integer);
    destructor destroy;override;
  end;

  //Turniere:TTurniere -> global VAR
  TTurniere = class
    fTurniere : TObjectList;

    //procedure SaveTurnierState;

    procedure LoadTurniereFromFile;
    function HeuteTurnier:integer; // Liefert ID des Turniers das heute ist, prüfen, ob angemeldet
    function MorgenTurnier:integer; // Liefert ID des Turniers das morgen ist, prüfen, ob angemeldet
    procedure CheckTurniere; //Prüft, ob neues Turnier, Generiert Ereignis
    constructor create;
    destructor destroy;override;
  end;

  TKneipenGegner = class(TSportler)
    ErscheinungsTag : integer; // randomrange(1..5)
    WettBetrag:integer;

    constructor create(ID_:Integer;Vorname_:string; Name_:string; Maxkraft_:Integer; Ausdauer_:integer; Technik_:Integer; Liga_:Integer; Siege_:Integer; Niederlagen_:Integer; Alter_:Integer; Level_, Erfahrung_, Fitness_, Ansehen_: integer); // -> inherited create aufrufen
    destructor destroy;override;
  end;

  //Kneipe:TKneipe -> global VAR
  TKneipe = class
    //Jeden Montag kommen 0..3 Kneipengegner rein, nach Kampf: Gegner verschwindet

    Anzahl : integer; // randomrange(0..3)
    GegnerListe : TObjectList; //TKneipenGegner

    procedure ResetKneipe; //Jede Woche, randomID aus Namenliste, Anzahl randomrange(0..2) erzeugen
    procedure CheckKneipe;//Jeden Tag aufrufen, Generiert Ereignis

    constructor create;
    destructor destroy;override;
  end;


  TSpecialMove = class
  public
    //Aus Config
    ID:integer;
    Icon:TDXDib;
    IconGrau:TDXDib;
    IconPfad:string;
    MinLevel:integer;//Minimum Charakterlevel

    Beschreibung:string;

    Level:integer; //1..99
    Bezeichnung:string;
    ErlernungsKosten:integer;

    {Durchführung}
    Koordinaten: TPointArray;
    Reaktionszeit:integer; //Millisekunden
    Reaktionszeit_up:integer;

    TechnikKosten:integer;
    TechnikKosten_up:integer;

    //Wertbeeinflussung mit Prozentangabe, bezieht sich auf Anteil des aktuellen Wertes im Kampf
    SelfMaxStrProzent:integer;
    SelfMaxStrProzent_up:integer;

    SelfStrAusdProzent:integer;
    SelfStrAusdProzent_up:integer;

    GegnerMaxStrProzent:integer;
    GegnerMaxStrProzent_up:integer;

    GegnerStrAusdProzent:integer;
    GegnerStrAusdProzent_up:integer;

    {Sofortige Modifizierung der Kampfposition um den Wert ChangePosition}
    ChangePosition:integer; //Armposition beeinflussen
    ChangePosition_up:integer; //Armposition beeinflussen

    StopGravity_MS:integer;
    StopGravity_MS_up:integer;

    StopGravityMove_MS:integer;
    StopGravityMove_MS_up:integer;

    Erlernt:boolean;

    function GetIncLevelKosten:integer; //Erfahrungskosten, den Level zu erhöhen
    function IncLevel:boolean; //SpecialMove steigt eine Stufe auf
//    Constructor create(IconPfad:string;Bezeichnung_:string;Reaktionszeit_:integer;TechnikKosten_:integer;Koordinaten_:TPointArray;Level_,ErlernungsKosten_:integer;selfMaxStr_,selfStrAusd_,GegnerMaxStr_,GegnerStrAusd_,selfMaxStrProzent_,SelfStrAusdProzent_,GegnerMaxStrProzent_,GegnerStrAusdProzent_,ChangePosition_,StopGravity_MS_,StopGravityMove_MS_:integer;MinLevel_:integer);
    constructor create(ID_:integer;IconPfad:string;MinLevel_:integer;Bezeichnung_:string;SelfMaxStrProzent_:integer;SelfMaxStrProzent_up:integer;SelfStrAusdProzent_:integer;SelfStrAusdProzent_up:integer;GegnerMaxStrProzent_:integer;GegnerMaxStrProzent_up:integer;GegnerStrAusdProzent_:integer;GegnerStrAusdProzent_up:integer;ChangePosition_:integer;ChangePosition_up:integer;TechnikKosten_:integer;TechnikKosten_up:integer;Reaktionszeit_:integer;Reaktionszeit_up:integer;StopGravity_MS_:integer;StopGravity_MS_up:integer;StopGravityMove_MS_:integer;StopGravityMove_MS_up:integer;Koordinaten_: TPointArray;Beschreibung_:string);

    destructor destroy;override;
  end;

  TSpecialMoves = class // TSpieler
  	fSpecialMoves : TObjectList;
    Koords:array[0..9] of TPoint; //Darstellungs-Koordinaten
    procedure LoadFromConfig;
    constructor create;
    destructor destroy;override;
  end;

  TAusruestung = class
  public
    fBezeichnung:string;

    //Aus Config
    Icon:TDib;
    IconPfad:string;
    ID:integer;

    Klasse:integer; // 1 = Kopf, 2 = Handschuh, 3 = Schuh, 4 = Hantel
    Stufe:integer; // 1..20

    //Berechnen
    //ErscheinungsTag:integer; //1..5
    Preis:integer;

    AddMaxKr:integer;
    AddAusd:integer;
    AddTechnik:integer;

    //Hantel
    Fitnessverbrauch : integer; //= randomrange(KausdauerW+MaxKw-5 .. KausdauerW+MaxKw + 5)
    Schwierigkeit : integer; // (KausdauerW+MaxKW), if Wert > 20 then Wert = 20   1..20 à schnellere Bewegung
    AnzahlWiederholungen : integer; //randomrange(10 + Schwierigkeit  .. 20 + Schwierigkeit)
    //---


    function PreisBesitz:integer;
    function GetBezeichnung:string;

    property Bezeichnung : string read GetBezeichnung write fBezeichnung;

    Constructor create(id:integer;Klasse:integer;Stufe:integer;IconPfad:string);
    destructor destroy;override;
  end;



  TSportShop = class
    fAusruestungen : TObjectList;
    WochenAusr : array of integer;

    procedure ResetSportShop;//Jede Woche, randomID aus Namenliste, Anzahl randomrange(0..2) erzeugen
    procedure CheckSportShop;//Jeden Tag aufrufen, Generiert Ereignis
    constructor create;
    destructor destroy;override;
  end;

  //alle Ausrüstungsteile in cdAuruestungen -> stellt CreateAusruestung zur Verfügung
  TAusruestungen = class
  private
    fAusruestungen : TObjectList;
    procedure LoadFromConfig; //Ausrüstungen aus Config File laden
  public
    function CreateAusruestung(Stufe:integer):TAusruestung;
    constructor create;
    destructor destroy;override;
  end;


  TKampf = class
  public
  	K1_ID: integer;
    K2_ID: integer;
    SiegerID: Integer;
    procedure Fight;
    constructor Create(ID1,ID2,SiegerID_:integer); // kein Ergebnis: SID = 0
  end;

  TKampfTag = class
  public
  	Kaempfe : array[1..(cUCDGegner+1) div 2] of TKampf;
    constructor Create;
  end;


  //->Erstellung von Begegnungen
  TTeam = Array of Real;
  TGame = Array of Record
                     Team1:Real;
                     Team2:Real;
                   end;
  TWeek = Array of Record
                     Game:TGame;
                   end;
  //<-

  TKampfSaison = Class
  public
    Vorrunde : array[1..cUCDWochen] of TKampftag;
    Rueckrunde : array[1..cUCDWochen] of TKampftag;
  	constructor Create; //-> 1-20, 1=Spieler    -> Funktion die für übergebene ID TSportler-Daten zurückgibt
    function CreateSchedule(Teams:TTeam; Level:integer):TWeek;
  end;

  TGegner = class
  public
  	Gegner : array[1..cUCDGegner] of TSportler;
    procedure ImproveValues; //jede Woche: Werte der Gegner verbessern

    // Liefern Gegner UND Spieler zurück -> ucdGegner+1
    procedure GetListByPoints(var Liste:TObjectList);
    procedure GetListByMaxKraft(var Liste:TObjectList);
    procedure GetListByKrAusd(var Liste:TObjectList);
    procedure GetListByTechnik(var Liste:TObjectList);
    procedure GetListByFitness(var Liste:TObjectList);
    procedure GetListByLevel(var Liste:TObjectList);

    constructor Create(Liga:Integer);
    destructor destroy;override;
  end;


//  //Maximal 5 Savegames
//  TSaveGame = class
//    slot:integer; //1..5
//    Daten:TStringList;
//
//    //function GetFilename:string; //spielername+cdzeit
//    //function Save
//
//    con
//
//  end;


  //-------------------------------------------------


  var
  	cdKampfsaison : TKampfsaison;
    cdSpieler : TSpieler;
    cdGegner : TGegner;
    cdZeit : TZeit;

    cdAusruestungen:TAusruestungen; // Allgemeine Ausrüstungsdaten
    cdSportshop:TSportshop;
    cdSpecialMoves:TSpecialMoves; // Special Moves komplett

    cdSponsoren:TSponsoren; // Sponsoren, die angezeigt werden
    cdKneipe:TKneipe;
    cdTurniere:TTurniere;
    cdEreignisse:TEreignisse;

    cdOtherData : TOtherData;

//  procedure SaveGame(Slot:integer); // Slot = 1..5
//  procedure LoadGame(Slot:integer);



  //---------------------------------------------------------------------


function Savegame(slot:integer):boolean;
function Loadgame(slot:integer):boolean;

function CreateSportlerByLevel(ID, Level:integer):TSportler;

function Summe(Wert:integer):integer; //Implementierung des Summenzeichens

function DeleteMindString(text:string):string; //Ersetzt '-' mit Leerstelle
function AddMindString(text:string):string; //Ersetzt ' ' mit '-'

implementation

uses StrUtils;


//Speichern/Laden/Erzeugen

//    cdZeit : TZeit;.....................................................
//    cdSpieler : TSpieler;...............................................
//  	cdKampfsaison : TKampfsaison;.......................................
//    cdGegner : TGegner;.................................................
//    cdSpecialMoves:TSpecialMoves; // Special Moves komplett.............
//    cdSponsoren:TSponsoren; // Sponsoren, die angezeigt werden..........
//    cdTurniere:TTurniere;    Angemeldet oder nicht......................
//    cdSportshop:TSportshop;.............................................

// -  cdAusruestungen:TAusruestungen; // Allgemeine Ausrüstungsdaten
// -  cdKneipe:TKneipe;
// -  cdEreignisse:TEreignisse;
// -  cdOtherData : TOtherData;



//Spielstand speichern
function Savegame(slot:integer):boolean;
var
  slDaten : TStringList;
  Pfad : string;
  zeile : string;
  crypt : TFileCrypt;
  i,j : integer;
begin
  try
    try
      result := false;
      Pfad := extractfilepath(application.exename) + 'Savegames\' + 'slot' + inttostr(slot);

      slDaten := TStringList.Create;

      zeile := '';

      slDaten.Add(cdspieler.vorname + ' S' + inttostr(cdzeit.Saison) + ' R' + inttostr(cdzeit.Runde) + ' W' + inttostr(cdzeit.Woche) + ' T' + inttostr(cdZeit.Tag));

  //cdZeit
      slDaten.Add('Zeit');
      zeile := zeile + inttostr(cdZeit.woche);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdZeit.Tag);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdZeit.Runde);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdZeit.Saison);
      zeile := zeile + ';';
      zeile := zeile + BoolToStr(cdzeit.nextround,true);
      zeile := zeile + ';';
      zeile := zeile + BoolToStr(cdzeit.nextSaison,true);
      zeile := zeile + ';';
      zeile := zeile + BoolToStr(cdzeit.nextWeek,true);
      slDaten.Add(zeile);

      zeile := '';


  //cdSpieler
      slDaten.Add('Spieler');
      zeile := zeile + inttostr(cdspieler.id);
      zeile := zeile + ';';
      zeile := zeile + cdspieler.Vorname;
      zeile := zeile + ';';
      zeile := zeile + cdspieler.name;
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.alter);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.level);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Erfahrung);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.FitnessMaximum);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Fitness);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Ansehen);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Maximalkraft);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Kraftausdauer);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.technik);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Liga);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Siege);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Niederlagen);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Kapital);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Siege_Alle);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Niederlagen_Alle);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Turnierteilnahmen);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Turniersiege);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Meisterschaften5);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Meisterschaften4);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Meisterschaften3);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Meisterschaften2);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.Meisterschaften1);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierKneipeSieg,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierBeginnersCornerSieg,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierProfiturnierSieg);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierEuropameisterschaftSieg,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierSportCafeTurnierSieg,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierRummelRingenSieg,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierProletenClubSieg,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierSemiProTurnier,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierWeltmeisterschaft,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.TurnierMeisterTurnier,true);
      zeile := zeile + ';';
      zeile := zeile + booltostr(cdspieler.fLevelUp,true);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.fLevelUpPoints);
      zeile := zeile + ';';
      zeile := zeile + inttostr(cdspieler.regenerationsrate);
      zeile := zeile + ';';
      zeile := zeile + BoolToStr(cdspieler.EndeShown,true);

      slDaten.Add(zeile);
      zeile := '';

      if cdspieler.Sponsor <> nil then
      begin
        zeile := zeile + cdspieler.Sponsor.IconPfad;
        zeile := zeile + ';';
        zeile := zeile + AddMindString(cdspieler.Sponsor.name);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.Sponsor.id);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.Sponsor.Laufzeit);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.sponsor.Geld);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.sponsor.sieggeld);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.sponsor.anzeigetag);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.sponsor.VertragsAbschluss.Runde) + ',' + inttostr(cdspieler.sponsor.VertragsAbschluss.woche) + ',' + inttostr(cdspieler.sponsor.VertragsAbschluss.Tag);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdspieler.sponsor.VertragsEnde.Runde) + ',' + inttostr(cdspieler.sponsor.VertragsEnde.woche) + ',' + inttostr(cdspieler.sponsor.VertragsEnde.Tag);

        slDaten.Add(zeile);
      end else
      begin
        slDaten.Add('nix');
      end;

      zeile := '';
      slDaten.Add('AusruestungRucksack');
      for i := 0 to cdspieler.AusruestungRucksack.Count - 1 do
      begin
        zeile := '';
        zeile := zeile + (cdspieler.AusruestungRucksack[i] as TAusruestung).fBezeichnung;
        zeile := zeile + ';';
        zeile := zeile + (cdspieler.AusruestungRucksack[i] as TAusruestung).Iconpfad;
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).ID);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).klasse);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).stufe);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).preis);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).Addmaxkr);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).addausd);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).addtechnik);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).Fitnessverbrauch);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).Schwierigkeit);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungRucksack[i] as TAusruestung).AnzahlWiederholungen);
        slDaten.Add(zeile);
      end;

      zeile := '';
      slDaten.Add('AusruestungAngezogen');
      for i := 0 to cdspieler.AusruestungAngezogen.Count - 1 do
      begin
        zeile := '';
        zeile := zeile + (cdspieler.AusruestungAngezogen[i] as TAusruestung).fBezeichnung;
        zeile := zeile + ';';
        zeile := zeile + (cdspieler.AusruestungAngezogen[i] as TAusruestung).Iconpfad;
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).ID);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).klasse);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).stufe);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).preis);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).Addmaxkr);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).addausd);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).addtechnik);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).Fitnessverbrauch);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).Schwierigkeit);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdspieler.AusruestungAngezogen[i] as TAusruestung).AnzahlWiederholungen);
        slDaten.Add(zeile);
      end;


  //cdKampfsaison
      zeile := '';
      slDaten.Add('Kampfsaison');
      slDaten.Add('Vorrunde');

      for i := 1 to high(cdKampfsaison.vorrunde) do
      begin
        for j := 1 to high(cdKampfsaison.vorrunde[i].kaempfe) do
        begin
          zeile := zeile + inttostr(cdkampfsaison.Vorrunde[i].Kaempfe[j].K1_ID);
          zeile := zeile + ';';
          zeile := zeile + inttostr(cdkampfsaison.Vorrunde[i].Kaempfe[j].K2_ID);
          zeile := zeile + ';';
          zeile := zeile + inttostr(cdkampfsaison.Vorrunde[i].Kaempfe[j].SiegerID);
          if j < high(cdKampfsaison.vorrunde[i].kaempfe) then zeile := zeile + ';';
        end;
        slDaten.Add(zeile);
        zeile := '';
      end;

      zeile := '';
      slDaten.Add('Rueckrunde');
      for i := 1 to high(cdKampfsaison.rueckrunde) do
      begin
        for j := 1 to high(cdKampfsaison.rueckrunde[i].kaempfe) do
        begin
          zeile := zeile + inttostr(cdkampfsaison.rueckrunde[i].Kaempfe[j].K1_ID);
          zeile := zeile + ';';
          zeile := zeile + inttostr(cdkampfsaison.rueckrunde[i].Kaempfe[j].K2_ID);
          zeile := zeile + ';';
          zeile := zeile + inttostr(cdkampfsaison.rueckrunde[i].Kaempfe[j].SiegerID);
          if j < high(cdKampfsaison.rueckrunde[i].kaempfe) then zeile := zeile + ';';
        end;
        slDaten.Add(zeile);
        zeile := '';
      end;



  //cdGegner
      zeile := '';
      slDaten.Add('Gegner');

      for i := low(cdgegner.gegner) to high(cdGegner.gegner) do
      begin
        zeile := '';
        zeile := zeile + inttostr(cdgegner.gegner[i].id);
        zeile := zeile + ';';
        zeile := zeile + cdgegner.gegner[i].vorname;
        zeile := zeile + ';';
        zeile := zeile + cdgegner.gegner[i].name;
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Alter);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].level);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].erfahrung);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].FitnessMaximum);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Fitness);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Ansehen);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Maximalkraft);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Kraftausdauer);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Technik);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Liga);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].Siege);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdgegner.gegner[i].niederlagen);
        slDaten.Add(zeile);
      end;


  //cdSpecialMoves
      slDaten.Add('SpecialMoves');
      zeile := '';
      for i := 0 to cdSpecialMoves.fSpecialMoves.Count-1 do
      begin
        zeile := '';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).Level);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).ErlernungsKosten);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).TechnikKosten);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).TechnikKosten_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).SelfMaxStrProzent);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).SelfMaxStrProzent_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).SelfStrAusdProzent);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).SelfStrAusdProzent_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).GegnerMaxStrProzent);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).GegnerMaxStrProzent_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).GegnerStrAusdProzent);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).GegnerStrAusdProzent_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).ChangePosition);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).ChangePosition_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).StopGravity_MS);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).StopGravity_MS_up);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).StopGravityMove_MS);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).StopGravityMove_MS_up);
        zeile := zeile + ';';
        zeile := zeile + booltostr((cdSpecialMoves.fSpecialMoves[i] as TSpecialMove).erlernt);

        slDaten.Add(zeile);
      end;


  //cdSponsoren

      slDaten.add('Sponsoren');
      //slDaten.Add(inttostr(length(cdsponsoren.fsponsoren)));

      for i := 0 to high(cdsponsoren.fsponsoren) do
      begin
        zeile := '';
        zeile := zeile + cdsponsoren.fsponsoren[i].IconPfad;
        zeile := zeile + ';';
        zeile := zeile + AddMindString(cdsponsoren.fsponsoren[i].name);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].id);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].laufzeit);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].geld);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].sieggeld);
        zeile := zeile + ';';
        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].anzeigetag);
//        zeile := zeile + ';';
//        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].vertragsabschluss.Runde) + ',' + inttostr(cdsponsoren.fsponsoren[i].vertragsabschluss.woche) + ',' + inttostr(cdsponsoren.fsponsoren[i].vertragsabschluss.tag);
//        zeile := zeile + ';';
//        zeile := zeile + inttostr(cdsponsoren.fsponsoren[i].VertragsEnde.Runde) + ',' + inttostr(cdsponsoren.fsponsoren[i].VertragsEnde.woche) + ',' + inttostr(cdsponsoren.fsponsoren[i].VertragsEnde.tag);
        slDaten.Add(zeile);
      end;


  //cdTurniere

      slDaten.Add('Turniere');

      for i := 0 to cdTurniere.fTurniere.Count - 1 do
      begin
        zeile := '';
        zeile := zeile + booltostr((cdturniere.fTurniere[i] as TTurnier).angemeldet);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdturniere.fTurniere[i] as TTurnier).MachEreignis);
        zeile := zeile + ';';
        zeile := zeile + booltostr((cdturniere.fTurniere[i] as TTurnier).Show);
        slDaten.Add(zeile);
      end;


  //cdSportshop
      slDaten.Add('Sportshop');
      slDaten.Add(inttostr(cdsportshop.fAusruestungen.count));

      for i := 0 to cdsportshop.fAusruestungen.Count - 1 do
      begin
        zeile := '';

        zeile := zeile + (cdsportshop.fAusruestungen[i] as TAusruestung).fBezeichnung;
        zeile := zeile + ';';
        zeile := zeile + (cdsportshop.fAusruestungen[i] as TAusruestung).Iconpfad;
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).Id);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).klasse);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).stufe);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).preis);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).addmaxkr);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).addausd);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).addtechnik);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).Fitnessverbrauch);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).Schwierigkeit);
        zeile := zeile + ';';
        zeile := zeile + inttostr((cdsportshop.fAusruestungen[i] as TAusruestung).AnzahlWiederholungen);
        slDaten.add(zeile);
      end;

      //In Datei speichern
      slDaten.SaveToFile(Pfad);
      crypt := TFileCrypt.Create;
      crypt.CryptFile(Pfad,Pfad);
      result := true;
    except
      on e:exception do
      begin
        showmessage('Save-Error: ' +e.message);
      end;
    end;
  finally
    freeandnil(slDaten);
    freeandnil(crypt);
  end;
end;




//Spielstand laden
function Loadgame(slot:integer):boolean;
var
  i,j,k,l : integer;
  Pfad : string;
  slDaten : TStringList;
  index : integer;
  limit : TStringList;
  limit2 : TStringList;
  AusruestungRuck,AusruestungAn : TObjectlist;
  crypt : TFileCrypt;
begin
  result := false;
  try
    try

      Pfad := extractfilepath(application.exename) + 'Savegames\slot' + inttostr(slot);

      slDaten := TStringList.Create;
      limit := TStringList.Create;
      limit2 := TStringList.create;

      if FileExists(pfad) then
      begin
        crypt := TFileCrypt.Create;
        crypt.deCryptFile(Pfad,Pfad);
        slDaten.LoadFromFile(Pfad);
      end else
      begin
        exit;
      end;


      //1.Alle Daten resetten
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


      //2.Daten erzeugen
      cdOtherData := TOtherData.create;
      cdKampfsaison := TKampfsaison.Create;

      cdGegner := TGegner.Create(3);
      cdZeit := TZeit.Create(1,1,1,1);
      cdEreignisse := TEreignisse.create;

      cdSponsoren := TSponsoren.create;
      cdKneipe := TKneipe.Create;

      cdSpecialMoves := TSpecialMoves.create;
      cdAusruestungen := TAusruestungen.create;
      cdSportshop := TSportshop.create;

      AusruestungRuck := TObjectList.Create;
      AusruestungAn := TObjectList.create;

      cdSpieler := TSpieler.Create('fff',' ',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,AusruestungRuck,AusruestungAn,nil,0,0,0,0,0,0);
//      cdTurniere := TTurniere.Create; -> am Ende da auf Spielerdaten zugegriffen wird
      cdSponsoren.ResetSponsoren;
      cdSportshop.ResetSportShop;
      cdKneipe.ResetKneipe;


      //3.Daten füllen
      limit.Delimiter := ';';
      slDaten.CaseSensitive := false;

  //Zeit
      index := slDaten.indexof('Zeit');
      limit.delimitedtext :=  slDaten[index+1];
      cdZeit.Woche := strtoint(limit[0]);
      cdZeit.Tag := strtoint(limit[1]);
      cdZeit.runde := strtoint(limit[2]);
      cdZeit.Saison := strtoint(limit[3]);
      cdZeit.NextRound := StrToBool(limit[4]);
      cdZeit.Nextsaison := StrToBool(limit[5]);
      cdZeit.Nextweek := StrToBool(limit[6]);


  //Spieler
      limit.Clear;
      index := slDaten.indexof('Spieler');
      limit.delimitedtext :=  slDaten[index+1];

      cdSpieler.ID := strtoint(limit[0]);
      cdspieler.Vorname := limit[1];
      cdspieler.Name := limit[2];
      cdspieler.Alter := strtoint(limit[3]);
      cdspieler.Level := strtoint(limit[4]);
      cdspieler.Erfahrung := strtoint(limit[5]);
      cdspieler.FitnessMaximum := strtoint(limit[6]);
      cdspieler.Fitness := strtoint(limit[7]);
      cdspieler.ansehen := strtoint(limit[8]);
      cdspieler.Maximalkraft := strtoint(limit[9]);
      cdspieler.Kraftausdauer := strtoint(limit[10]);
      cdspieler.Technik := strtoint(limit[11]);
      cdspieler.Liga := strtoint(limit[12]);
      cdspieler.siege := strtoint(limit[13]);
      cdspieler.Niederlagen := strtoint(limit[14]);
      cdspieler.Kapital := strtoint(limit[15]);
      cdspieler.Siege_Alle := strtoint(limit[16]);
      cdspieler.Niederlagen_Alle := strtoint(limit[17]);
      cdspieler.Turnierteilnahmen := strtoint(limit[18]);
      cdspieler.Turniersiege := strtoint(limit[19]);
      cdspieler.Meisterschaften5 := strtoint(limit[20]);
      cdspieler.Meisterschaften4 := strtoint(limit[21]);
      cdspieler.Meisterschaften3 := strtoint(limit[22]);
      cdspieler.Meisterschaften2 := strtoint(limit[23]);
      cdspieler.Meisterschaften1 := strtoint(limit[24]);
      cdspieler.TurnierKneipeSieg := StrToBool(limit[25]);
      cdspieler.TurnierBeginnersCornerSieg := StrToBool(limit[26]);
      cdspieler.TurnierProfiturnierSieg := StrToBool(limit[27]);
      cdspieler.TurnierEuropameisterschaftSieg := StrToBool(limit[28]);
      cdspieler.TurnierSportCafeTurnierSieg := StrToBool(limit[29]);
      cdspieler.TurnierRummelRingenSieg := StrToBool(limit[30]);
      cdspieler.TurnierProletenClubSieg := StrToBool(limit[31]);
      cdspieler.TurnierSemiProTurnier := StrToBool(limit[32]);
      cdspieler.TurnierWeltmeisterschaft := StrToBool(limit[33]);
      cdspieler.TurnierMeisterTurnier := StrToBool(limit[34]);
      cdspieler.fLevelUp := StrToBool(limit[35]);
      cdspieler.fLevelUpPoints := strtoint(limit[36]);
      cdspieler.regenerationsrate := strtoint(limit[37]);
      cdspieler.EndeShown := StrToBool(limit[38]);


  //Spieler:Zeile2:
      limit.Clear;
      limit.delimitedtext :=  slDaten[index+2];
      limit2.delimiter := ',';
      if limit[0] <> 'nix' then
      begin
        cdspieler.Sponsor := TSponsor.create(0,'a',0,limit[0]);
        cdspieler.Sponsor.IconPfad := limit[0];
        cdspieler.Sponsor.name := DeleteMindString(limit[1]);
        cdspieler.Sponsor.ID := strtoint(limit[2]);
        cdspieler.Sponsor.Laufzeit := strtoint(limit[3]);
        cdspieler.sponsor.geld := strtoint(limit[4]);
        cdspieler.Sponsor.sieggeld := strtoint(limit[5]);
        cdspieler.Sponsor.AnzeigeTag := strtoint(limit[6]);
        limit2.DelimitedText := limit[7];
        cdspieler.Sponsor.VertragsAbschluss := TZeit.Create(0,0,0,0);
        cdspieler.sponsor.VertragsAbschluss.Runde := strtoint(limit2[0]);
        cdspieler.sponsor.VertragsAbschluss.Woche := strtoint(limit2[1]);
        cdspieler.sponsor.VertragsAbschluss.Tag := strtoint(limit2[2]);

        limit2.Clear;
        limit2.DelimitedText := limit[8];
        cdspieler.Sponsor.VertragsEnde := TZeit.Create(0,0,0,0);
        cdspieler.sponsor.VertragsEnde.Runde := strtoint(limit2[0]);
        cdspieler.sponsor.VertragsEnde.Woche := strtoint(limit2[1]);
        cdspieler.sponsor.VertragsEnde.Tag := strtoint(limit2[2]);

        limit2.Clear;
        limit.Clear;
        //Icon laden -> nicht nötig
      end;




  //Spieler:Zeile3:
      limit.Clear;

      limit.delimitedtext :=  slDaten[index+4];
      j := index+4;
      while limit[0] <> 'AusruestungAngezogen' do
      begin
        cdspieler.AusruestungRucksack.Add(TAusruestung.create(strtoint(limit[2]),strtoint(limit[3]),strtoint(limit[4]),limit[1]));
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).preis := strtoint(limit[5]);
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).addmaxkr := strtoint(limit[6]);
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).addAusd := strtoint(limit[7]);
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).addTechnik := strtoint(limit[8]);
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).Fitnessverbrauch := strtoint(limit[9]);
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).Schwierigkeit := strtoint(limit[10]);
        (cdspieler.AusruestungRucksack[cdspieler.AusruestungRucksack.Count-1] as TAusruestung).AnzahlWiederholungen := strtoint(limit[11]);
        inc(j);
        limit.delimitedtext := slDaten[j];
      end;

      inc(j);
      limit.delimitedtext :=  slDaten[j];
      while limit[0] <> 'Kampfsaison' do
      begin
        cdspieler.AusruestungAngezogen.Add(TAusruestung.create(strtoint(limit[2]),strtoint(limit[3]),strtoint(limit[4]),limit[1]));
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).preis := strtoint(limit[5]);
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).addmaxkr := strtoint(limit[6]);
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).addAusd := strtoint(limit[7]);
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).addTechnik := strtoint(limit[8]);
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).Fitnessverbrauch := strtoint(limit[9]);
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).Schwierigkeit := strtoint(limit[10]);
        (cdspieler.AusruestungAngezogen[cdspieler.AusruestungAngezogen.Count-1] as TAusruestung).AnzahlWiederholungen := strtoint(limit[11]);
        inc(j);
        limit.delimitedtext := slDaten[j];
      end;





  //Kampfsaison
      limit.clear;
      limit2.Clear;

      index := slDaten.indexof('Kampfsaison');

      k := index + 2;
      l := 0;
      for i := 1 to high(cdKampfsaison.vorrunde) do
      begin
        limit.DelimitedText := slDaten[k];
        l := 0;
        for j := 1 to high(cdKampfsaison.vorrunde[i].kaempfe) do
        begin
          cdKampfsaison.Vorrunde[i].Kaempfe[j].K1_ID := strtoint(limit[l]);
          cdKampfsaison.Vorrunde[i].Kaempfe[j].K2_ID := strtoint(limit[l+1]);
          cdKampfsaison.Vorrunde[i].Kaempfe[j].SiegerID := strtoint(limit[l+2]);
          inc(l,3);
        end;
        inc(k);
      end;


      k := slDaten.indexof('Rueckrunde');
      inc(k);
      l := 0;
      for i := 1 to high(cdKampfsaison.rueckrunde) do
      begin
        limit.DelimitedText := slDaten[k];
        l := 0;
        for j := 1 to high(cdKampfsaison.rueckrunde[i].kaempfe) do
        begin
          cdKampfsaison.rueckrunde[i].Kaempfe[j].K1_ID := strtoint(limit[l]);
          cdKampfsaison.rueckrunde[i].Kaempfe[j].K2_ID := strtoint(limit[l+1]);
          cdKampfsaison.rueckrunde[i].Kaempfe[j].SiegerID := strtoint(limit[l+2]);
          inc(l,3);
        end;
        inc(k);
      end;




  //Gegner
      limit.clear;
      limit2.Clear;

      index := slDaten.indexof('Gegner');
      limit.DelimitedText := slDaten[index+1];
      k := 1;
      while limit[0] <> 'SpecialMoves' do
      begin
        cdGegner.Gegner[k].ID := strtoint(limit[0]);
        cdGegner.Gegner[k].vorname := limit[1];
        cdGegner.Gegner[k].name := limit[2];
        cdGegner.Gegner[k].alter := strtoint(limit[3]);
        cdGegner.Gegner[k].level := strtoint(limit[4]);
        cdGegner.Gegner[k].erfahrung := strtoint(limit[5]);
        cdGegner.Gegner[k].fitnessmaximum := strtoint(limit[6]);
        cdGegner.Gegner[k].fitness := strtoint(limit[7]);
        cdGegner.Gegner[k].ansehen := strtoint(limit[8]);
        cdGegner.Gegner[k].maximalkraft := strtoint(limit[9]);
        cdGegner.Gegner[k].kraftausdauer := strtoint(limit[10]);
        cdGegner.Gegner[k].technik := strtoint(limit[11]);
        cdGegner.Gegner[k].liga := strtoint(limit[12]);
        cdGegner.Gegner[k].siege := strtoint(limit[13]);
        cdGegner.Gegner[k].niederlagen := strtoint(limit[14]);

        inc(k);
        inc(index);
        limit.DelimitedText := slDaten[index+1];
      end;




  //SpecialMoves
      limit.clear;
      limit2.Clear;

      index := slDaten.indexof('SpecialMoves');

      limit.DelimitedText := slDaten[index+1];
      k := 0;
      while limit[0] <> 'Sponsoren' do
      begin
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).Level := strtoint(limit[0]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).ErlernungsKosten := strtoint(limit[1]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).TechnikKosten := strtoint(limit[2]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).TechnikKosten_up := strtoint(limit[3]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).SelfMaxStrProzent := strtoint(limit[4]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).SelfMaxStrProzent_up := strtoint(limit[5]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).SelfStrAusdProzent := strtoint(limit[6]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).SelfStrAusdProzent_up := strtoint(limit[7]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).GegnerMaxStrProzent := strtoint(limit[8]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).GegnerMaxStrProzent_up := strtoint(limit[9]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).GegnerStrAusdProzent := strtoint(limit[10]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).GegnerStrAusdProzent_up := strtoint(limit[11]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).ChangePosition := strtoint(limit[12]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).ChangePosition_up := strtoint(limit[13]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).StopGravity_MS := strtoint(limit[14]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).StopGravity_MS_up := strtoint(limit[15]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).StopGravityMove_MS := strtoint(limit[16]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).StopGravityMove_MS_up := strtoint(limit[17]);
        (cdSpecialMoves.fSpecialMoves[k] as TSpecialMove).Erlernt := strtobool(limit[18]);
        inc(k);
        inc(index);
        limit.DelimitedText := slDaten[index+1];
      end;



  //Sponsoren
      limit.clear;
      limit2.Clear;

      index := slDaten.indexof('Sponsoren');
      limit.DelimitedText := slDAten[index+1];

      //Mögliche Sponsoren kicken
      for i := low(cdSponsoren.fSponsoren) to high(cdSponsoren.fSponsoren) do
      begin
        freeandnil(cdsponsoren.fsponsoren[i]);
      end;
      setlength(cdsponsoren.fSponsoren,0);
            
      k := index+1;
      l := 0;
      while limit[0] <> 'Turniere' do
      begin
        setlength(cdsponsoren.fSponsoren,length(cdsponsoren.fsponsoren)+1);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)] := TSponsor.create(0,'f',l,limit[0]);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)].Name := DeleteMindString(limit[1]);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)].id := strtoint(limit[2]);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)].laufzeit := strtoint(limit[3]);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)].geld := strtoint(limit[4]);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)].sieggeld := strtoint(limit[5]);
        cdsponsoren.fSponsoren[high(cdsponsoren.fsponsoren)].anzeigetag := strtoint(limit[6]);
        //VertragsAbschluss:TZeit; -> Saison;Runde;Woche;Tag
        //VertragsEnde:TZeit;
        inc(l);
        inc(k);
        limit.DelimitedText := slDAten[k];
      end;

  //Turniere
      cdTurniere := TTurniere.Create;
      limit.clear;
      limit2.Clear;

      index := slDaten.indexof('Turniere');
      limit.DelimitedText := slDAten[index+1];

      j := index+1;
      k := 0;
      while limit[0] <> 'Sportshop' do
      begin
        (cdTurniere.fTurniere[k] as TTurnier).Angemeldet := strtobool(limit[0]);
        (cdTurniere.fTurniere[k] as TTurnier).MachEreignis := strtoint(limit[1]);
        (cdTurniere.fTurniere[k] as TTurnier).show := strtobool(limit[2]);
        inc(k);
        inc(j);
        limit.DelimitedText := slDaten[j];
      end;

  //Sportshop
      limit.clear;
      limit2.Clear;

      index := slDaten.indexof('Sportshop');
      k := strtoint(slDAten[index+1]);
      cdSportshop.fAusruestungen.Clear;

      if k > 0 then
      begin
        limit.DelimitedText := slDAten[index+2];
        l := index+2;
        for i := 0 to k-1 do
        begin
          cdsportshop.fAusruestungen.Add(TAusruestung.create(i,strtoint(limit[3]),strtoint(limit[4]),limit[1]));
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).fBezeichnung := limit[0];
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).preis := strtoint(limit[5]);
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).addmaxkr := strtoint(limit[6]);
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).addausd := strtoint(limit[7]);
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).addtechnik := strtoint(limit[8]);
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).fitnessverbrauch := strtoint(limit[9]);
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).schwierigkeit := strtoint(limit[10]);
          (cdsportshop.fAusruestungen[cdsportshop.fAusruestungen.Count-1] as TAusruestung).anzahlwiederholungen := strtoint(limit[11]);
          inc(l);
          if i < k-1 then limit.DelimitedText := slDAten[l];
        end;
      end;
      crypt.CryptFile(Pfad,Pfad);
      result := true;
    except
      on e:exception do
      begin
        showmessage('Load-Error: ' + e.Message);
      end;
    end;
  finally
    freeandnil(sldaten);
    freeandnil(limit);
    freeandnil(limit2);
    freeandnil(crypt);
  end;
end;


//Gedankenstriche aus String entfernen
function DeleteMindString(text:string):string;
begin
  result := StringReplace(text,'-',' ',[rfReplaceAll]);
end;

function AddMindString(text:string):string; //Ersetzt ' ' mit '-'
begin
  result := StringReplace(text,' ','-',[rfReplaceAll]);
end;

function CreateSportlerByLevel(ID, Level:integer):TSportler;
var
  i : integer;
  Vorname, Name : string;
  Maximalkraft : integer;
  Kraftausdauer : integer;
  Technik : integer;
  Liga : integer;
  Siege : integer;
  Niederlagen : integer;
  Alter : integer;
  Erfahrung : integer;
  Fitness : integer;
  FitnessMaximum : integer;
  Ansehen : integer;
begin
  randomize;

  Vorname := cdOtherData.fVornamen[randomrange(1,cdOtherData.fVornamen.Count-ID)+ID];
  Name := cdOtherData.fVornamen[randomrange(1,cdOtherData.fNachnamen.Count-ID)+ID];

  Maximalkraft := randomrange(Level*Level*5,(Level*Level)*6);
  Kraftausdauer := randomrange(Level*Level*5,(Level*Level)*6);

  randomize;
  if level = 1 then
  begin
    Maximalkraft := randomrange(19,31);
    Kraftausdauer := randomrange(19,31);
  end;

  randomize;
  if level = 2 then
  begin
    Maximalkraft := randomrange(29,40);
    Kraftausdauer := randomrange(29,40);
  end;

  Technik := randomrange(10+Summe(Level) div 3, 10+Summe(Level));
  FitnessMaximum := randomrange(10+Summe(Level) div 3, 10+Summe(Level));
  Fitness := FitnessMaximum;

  Liga := -1;
  Siege := 0;
  Niederlagen := 0;
	Alter := randomrange(18,59);
  Erfahrung := 0;
  Ansehen := 0;

  result := TSportler.Create(ID,Vorname, Name, Maximalkraft, Kraftausdauer, Technik, Liga, Siege, Niederlagen, Alter, Level, Erfahrung, Fitness, Ansehen, FitnessMaximum);
end;

constructor TOtherData.create;
var
  Datenpfad:string;
begin
  fVornamen := TStringList.create;
  fNachnamen := TStringList.create;
  fStufen := TStringList.create;

  DatenPfad := ExtractFilePath(Application.ExeName);
  fVornamen.LoadFromFile(Datenpfad + cUCDVerzVornamen);
  fNachnamen.LoadFromFile(Datenpfad + cUCDVerzNachnamen);
  fStufen.LoadFromFile(Datenpfad + cUCDVerzStufen);
end;

function TOtherData.GetStufenString(Stufe:integer):string;
begin
  try
    result := fStufen[Stufe-1]; // 0..19
  except
    result := 'Special';
  end;
end;

destructor TOtherData.destroy;
begin
  freeandnil(fVornamen);
  freeandnil(fNachnamen);
  freeandnil(fStufen);
  inherited destroy;
end;


{TSpecialMove.}

function TSpecialMove.GetIncLevelKosten:integer; //Erfahrungskosten, den Level zu erhöhen
begin
  result := 2+Level*3 + (MinLevel div 2);
end;

function TSpecialMove.IncLevel:boolean; //SpecialMove steigt eine Stufe auf
var
  incIt:boolean;
begin
  result := false;
  incIt := false;
  if Level < 10 then
  begin
    //Sicherstellen, dass ein direkter Vorgänger bereits erlernt wurde
    case ID of
      0..3: IncIt := true;
      4: if ((cdSpecialMoves.fSpecialMoves[0] as TSpecialMove).Erlernt = true) or ((cdSpecialMoves.fSpecialMoves[1] as TSpecialMove).Erlernt = true) then IncIt := true;
      5: if ((cdSpecialMoves.fSpecialMoves[2] as TSpecialMove).Erlernt = true) or ((cdSpecialMoves.fSpecialMoves[3] as TSpecialMove).Erlernt = true) then IncIt := true;
      6: if ((cdSpecialMoves.fSpecialMoves[4] as TSpecialMove).Erlernt = true) then IncIt := true;
      7: if ((cdSpecialMoves.fSpecialMoves[5] as TSpecialMove).Erlernt = true) then IncIt := true;
      8: if ((cdSpecialMoves.fSpecialMoves[6] as TSpecialMove).Erlernt = true) or ((cdSpecialMoves.fSpecialMoves[7] as TSpecialMove).Erlernt = true) then IncIt := true;
      9: if ((cdSpecialMoves.fSpecialMoves[8] as TSpecialMove).Erlernt = true) then IncIt := true;
    end;

    if self.MinLevel > cdspieler.Level then incit := false;

    if IncIt then
    begin
      inc(Level);
      if erlernt = true then
      begin
        if Reaktionszeit <> -1 then Reaktionszeit := Reaktionszeit + Reaktionszeit_up;
//        if technikkosten > 5 then
//        begin
          Technikkosten := Technikkosten + Technikkosten_up;
//        end;
        if SelfMaxStrProzent <> -1 then SelfMaxStrProzent := SelfMaxStrProzent + SelfMaxStrProzent_up;
        if SelfStrAusdProzent <> -1 then SelfStrAusdProzent := SelfStrAusdProzent + SelfStrAusdProzent_up;
        if GegnerMaxStrProzent <> -1 then GegnerMaxStrProzent := GegnerMaxStrProzent + GegnerMaxStrProzent_up;
        if GegnerStrAusdProzent <> -1 then GegnerStrAusdProzent := GegnerStrAusdProzent + GegnerStrAusdProzent_up;
        if ChangePosition <> -1 then ChangePosition := ChangePosition + ChangePosition_up;
        if StopGravity_MS <> -1 then StopGravity_MS := StopGravity_MS + StopGravity_MS_up;
        if StopGravityMove_MS <> -1 then StopGravityMove_MS := StopGravityMove_MS + StopGravityMove_MS_up;
      end;
      Erlernt := true;
      result := true;
    end;
  end;
end;

function Summe(Wert:integer):integer;
var
  i : integer;
begin
  result := 0;
  for i := Wert downto 0 do
  begin
    result := result + i;
  end;
end;

Constructor TSpecialMove.create(ID_:integer;IconPfad:string;MinLevel_:integer;Bezeichnung_:string;SelfMaxStrProzent_:integer;SelfMaxStrProzent_up:integer;SelfStrAusdProzent_:integer;SelfStrAusdProzent_up:integer;GegnerMaxStrProzent_:integer;GegnerMaxStrProzent_up:integer;GegnerStrAusdProzent_:integer;GegnerStrAusdProzent_up:integer;ChangePosition_:integer;ChangePosition_up:integer;TechnikKosten_:integer;TechnikKosten_up:integer;Reaktionszeit_:integer;Reaktionszeit_up:integer;StopGravity_MS_:integer;StopGravity_MS_up:integer;StopGravityMove_MS_:integer;StopGravityMove_MS_up:integer;Koordinaten_: TPointArray;Beschreibung_:string);
var
  temp:string;
  jpeg : TJpegimage;
begin
  jPeg := TJPegImage.Create;
  try
    jpeg.Transparent := false;
    jPeg.LoadFromFile(extractFilePath(application.ExeName)+IconPfad);
    Icon := TDXDIB.Create(nil);
    Icon.DIB.Transparent := false;
    Icon.DIB.Assign(jpeg);

    IconGrau := TDXDIB.Create(nil);
    jPeg.LoadFromFile(extractFilePath(application.ExeName)+ copy(IconPfad,1,Pos('.',IconPfad)-1) + '1.jpg');
    IconGrau.DIB.assign(jpeg);

    ID := ID_;
    Beschreibung := Beschreibung_;
    MinLevel := MinLevel_;
    Level:=0;//integer; //0..20
    Bezeichnung:=Bezeichnung_;//string;
    ErlernungsKosten:= MinLevel; //MinLevel Erfahrungspunkte, Update: neue Stufe + MinLevel Erfahrungspunkte div 2

    Koordinaten := Koordinaten_; // array of TPoint;

    Reaktionszeit:=Reaktionszeit_;//integer; //Millisekunden
    self.Reaktionszeit_up:=Reaktionszeit_up;//integer; //Millisekunden

    TechnikKosten:= 9 + Summe(MinLevel) div 6;//TechnikKosten_;
    self.TechnikKosten_up:=TechnikKosten_up;//integer;

    SelfMaxStrProzent:=SelfMaxStrProzent_;//integer;
    self.SelfMaxStrProzent_up:=SelfMaxStrProzent_up;//integer;

    SelfStrAusdProzent:=SelfStrAusdProzent_;//integer;
    self.SelfStrAusdProzent_up:=SelfStrAusdProzent_up;//integer;

    GegnerMaxStrProzent:=GegnerMaxStrProzent_;//integer;
    self.GegnerMaxStrProzent_up:=GegnerMaxStrProzent_up;//integer;

    GegnerStrAusdProzent:=GegnerStrAusdProzent_;//integer;
    self.GegnerStrAusdProzent_up:=GegnerStrAusdProzent_up;//integer;

    StopGravity_MS := StopGravity_MS_;
    self.StopGravity_MS_up := StopGravity_MS_up;

    StopGravityMove_MS := StopGravityMove_MS_;
    self.StopGravityMove_MS_up := StopGravityMove_MS_up;

    ChangePosition:=ChangePosition_;//integer; //Armposition beeinflussen
    self.ChangePosition_up:=ChangePosition_up;//integer; //Armposition beeinflussen

    Erlernt:=false;
  finally
    freeandnil(jpeg);
  end;
end;

destructor TSpecialMove.destroy;
begin
  freeandnil(Icon);
  freeandnil(IconGrau);
  //..
  inherited destroy;
end;


{TSpecialMoves.}

procedure TSpecialMoves.LoadFromConfig;
var
  ConfigFile : TStringList;
  Zeile:TStringList;
  i,j,n:integer;
  temp:string;
  PointArray:TPointArray;
  PointListe:TStringList;
begin
//0    IconPfad:string;
//1    MinLevel:integer
//2    Bezeichnung:string;

//3    SelfMaxStrProzent:integer;
//4 Aufstieg
//5    SelfStrAusdProzent:integer;
//6 Aufstieg
//7    GegnerMaxStrProzent:integer;
//8 Aufstiegswert
//9    GegnerStrAusdProzent:integer;
//10 +Aufstiegswert
//11    ChangePosition:integer; //Armposition beeinflussen
//12 +Aufstiegswert
//13    TechnikKosten:integer;
//14 +Aufstiegswert
//15    Reaktionszeit:integer; //Millisekunden
//16 +Aufstiegswert
//17    StopGravity_MS:integer;
//18 +Aufstiegswert
//19    StopGravityMove_MS:integer;
//20 +Aufstiegswert
//21    Koordinaten: TPointArray; // -> (100-100,200-200,500-500...)


  ConfigFile := TStringList.Create;
  PointListe := TStringList.create;
  Zeile := TStringList.Create;
  Zeile.Delimiter := ';';
  fSpecialMoves := TObjectList.Create;
  try
    ConfigFile.LoadFromFile(ExtractFilePath(application.exename)+cUCDSpecialMovesFile);
    //Jede Zeile verarbeiten
    n := 0;
    for i := 0 to ConfigFile.Count - 1 do
    begin
      if (ConfigFile[i] = '') or (ConfigFile[i] = ' ') or (ConfigFile[i][1] = '/') then continue;
      Zeile.Clear;
      Zeile.DelimitedText := ConfigFile[i];

      //Koordinaten
      temp := Zeile[21]; //Koordinaten
      Delete(temp,1,1); // ( entfernen
      Delete(temp,Length(temp),1); // ) entfernen
      PointListe.Delimiter := ',';
      PointListe.DelimitedText := temp;
      SetLength(PointArray,PointListe.count);
      for j := 0 to High(PointArray) do
      begin
        PointArray[j].X := strtoint(Copy(PointListe[j],1,Pos('-',PointListe[j])-1));
        PointArray[j].Y := strtoint(Copy(PointListe[j],Pos('-',PointListe[j])+1,Length(PointListe[j])));
      end;

      //Leerzeichen entfernen
      for j := 0 to Zeile.Count - 1 do
      begin
        Zeile[j] := trim(Zeile[j]);
      end;
      //Gedankenstriche mit Leerzeichen ersetzen
      Zeile[2] := DeleteMindString(Zeile[2]);
      fSpecialMoves.Add(TSpecialMove.create(n,Zeile[0],strtoint(Zeile[1]),Zeile[2],strtoint(Zeile[3]),strtoint(Zeile[4]),strtoint(Zeile[5]),strtoint(Zeile[6]),strtoint(Zeile[7]),strtoint(Zeile[8]),strtoint(Zeile[9]),strtoint(Zeile[10]),strtoint(Zeile[11]),strtoint(Zeile[12]),strtoint(Zeile[13]),strtoint(Zeile[14]),strtoint(Zeile[15]),strtoint(Zeile[16]),strtoint(Zeile[17]),strtoint(Zeile[18]),strtoint(Zeile[19]),strtoint(Zeile[20]),PointArray,DeleteMindString(Zeile[22])));
      inc(n);
    end;
  finally
    freeandnil(ConfigFile);
    freeandnil(Zeile);
    freeandnil(PointListe);
  end;
end;

constructor TSpecialMoves.create;
begin
  fSpecialMoves := TObjectList.Create;

  Koords[0].X := round(69/1.28);
  Koords[0].Y := round(111/1.28);

  Koords[1].X := round(69/1.28);
  Koords[1].Y := round(230/1.28);

  Koords[2].X := round(68/1.28);
  Koords[2].Y := round(349/1.28);

  Koords[3].X := round(68/1.28);
  Koords[3].Y := round(470/1.28);

  Koords[4].X := round(180/1.28);
  Koords[4].Y := round(172/1.28);

  Koords[5].X := round(180/1.28);
  Koords[5].Y := round(407/1.28);

  Koords[6].X := round(291/1.28);
  Koords[6].Y := round(231/1.28);

  Koords[7].X := round(291/1.28);
  Koords[7].Y := round(346/1.28);

  Koords[8].X := round(402/1.28);
  Koords[8].Y := round(289/1.28);

  Koords[9].X := round(515/1.28);
  Koords[9].Y := round(289/1.28);

  LoadFromConfig;
end;

destructor TSpecialMoves.destroy;
begin
  freeandnil(fSpecialMoves);
  inherited destroy;
end;


{TAusruestung.}

destructor TAusruestung.destroy;
begin
  freeandnil(Icon);
  inherited destroy;
end;

function TAusruestung.PreisBesitz:integer;
begin
  result := (Preis div 2) + 3 + (Preis div 10);
end;

function TAusruestung.GetBezeichnung:string;
begin
  case Klasse of
    1: result := 'Kopfbedeckung';
    2: result := 'Handschuhe';
    3: result := 'Schuhe';
    4: result := 'Hantel';
  end;

  result := cdOtherData.GetStufenString(Stufe) + ' ' + result;

  //aus Klasse und Stufe
end;

Constructor TAusruestung.create(id:integer;Klasse:integer;Stufe:integer;IconPfad:string);
var
  Faehigkeiten : integer;
  jpeg:TJPegImage;
  oder:integer;
begin
  jPeg := TjPegImage.Create;
  try
//    ErscheinungsTag := randomrange(1,5);
    Icon := TDIB.Create;
    Icon.Transparent := false;

    jpeg.Transparent := false;
    jpeg.LoadFromFile(ExtractFilePath(application.ExeName)+IconPfad);

    Icon.Assign(jpeg);

    self.IconPfad := IconPfad;
    self.ID := ID;
    self.Klasse := Klasse;
    self.Stufe := Stufe;

    //Klasse:integer; // 1 = Kopf, 2 = Handschuh, 3 = Schuh, 4 = Hantel
    AddMaxKr := -1;
    AddAusd := -1;
    AddTechnik := -1;
    Fitnessverbrauch := -1;// integer; //= randomrange(KausdauerW+MaxKw-5 .. KausdauerW+MaxKw + 5)
    Schwierigkeit := -1;// integer; // (KausdauerW+MaxKW), if Wert > 20 then Wert = 20   1..20 à schnellere Bewegung
    AnzahlWiederholungen := -1;// integer; //randomrange(10 + Schwierigkeit  .. 20 + Schwierigkeit)

    case Klasse of
      1:  begin
            AddAusd := Randomrange(8+Stufe*8, 10+Stufe*10);
            Faehigkeiten := AddMaxKr+AddAusd+AddTechnik;
            Preis := Randomrange(Stufe*6+Faehigkeiten*6, Stufe*12+Faehigkeiten*8);
          end;

      2:  begin
            AddMaxKr := Randomrange(8+Stufe*8, 10+Stufe*10);
            Faehigkeiten := AddMaxKr+AddAusd+AddTechnik;
            Preis := Randomrange(Stufe*6+Faehigkeiten*6, Stufe*12+Faehigkeiten*8);
          end;

      3:  begin
            AddTechnik := Randomrange(8+Stufe*8, 10+Stufe*10);
            Faehigkeiten := AddMaxKr+AddAusd+AddTechnik;
            Preis := Randomrange(Stufe*6+Faehigkeiten*6, Stufe*12+Faehigkeiten*8);
          end;

      4:  begin
            randomize;
            oder := randomrange(0,2);
            AddMaxKr := randomrange(0,stufe div 3);
            AddAusd := randomrange(0,stufe div 3);
            case oder of
              0:AddMaxKr := Randomrange(Stufe, Stufe*2);
              1:AddAusd := Randomrange(Stufe, Stufe*2);
              2:AddAusd := Randomrange(Stufe, Stufe*2);
            end;

//            if (AddMaxKr=0) and (AddAusd=0) then
//            begin
//              AddMaxKr := Stufe*2+1;
//            end;

            Fitnessverbrauch := randomrange((10+Stufe) div 2, (20+Stufe) div 2);
            if Fitnessverbrauch < 1 then Fitnessverbrauch := 1;

            Schwierigkeit := randomrange(1,10);        //(AddAusd+AddMaxKr) div 2;//, if Wert > 20 then Wert = 20   1..20 à schnellere Bewegung
            if Schwierigkeit > 10 then Schwierigkeit := 10;
            if Schwierigkeit < 1 then Schwierigkeit := 1;

            AnzahlWiederholungen := randomrange(7, 15);
            Faehigkeiten := AddMaxKr+AddAusd;
            Preis := Randomrange(Stufe*10+Faehigkeiten*14-Schwierigkeit*2-Fitnessverbrauch, Stufe*15+Faehigkeiten*24-SChwierigkeit-Fitnessverbrauch);
            if Preis < 10 then Preis := 10;
          end;
    end;

  finally
    freeandnil(jpeg);
  end;
end;


{TAusruestungen.}

constructor TAusruestungen.create;
begin
  fAusruestungen := TObjectlist.create;
  LoadFromConfig;
end;

destructor TAusruestungen.destroy;
begin
  freeandnil(fAusruestungen);
  inherited destroy;
end;

procedure TAusruestungen.LoadFromConfig;
var
  ConfigFile:TStringList;
  Zeile:TStringList;
  i,j:integer;
  temp:string;
begin
//    IconPfad:string;
//    Klasse:integer; // 1 = Kopf, 2 = Handschuh, 3 = Schuh, 4 = Hantel
//    Stufe:integer; // 1..20

  ConfigFile := TStringList.Create;
  Zeile := TStringList.Create;
  Zeile.Delimiter := ';';
  fAusruestungen := TObjectList.Create;
  try
    ConfigFile.LoadFromFile(ExtractFilePath(application.exename)+cUCDAusruestungsFile);
    for i := 0 to ConfigFile.Count - 1 do
    begin
      if (ConfigFile[i] = '') or (ConfigFile[i] = ' ') or (ConfigFile[i][1] = '/') then continue;
      Zeile.Clear;
      Zeile.DelimitedText := ConfigFile[i];
      fAusruestungen.Add(TAusruestung.create(i,strtoint(Zeile[1]),strtoint(Zeile[2]), Zeile[0]));
    end;
  finally
    freeandnil(ConfigFile);
    freeandnil(Zeile);
  end;
end;

function TAusruestungen.CreateAusruestung(Stufe:integer):TAusruestung;
var
  st : integer;
  klasse : integer;
  i : integer;
  Pfad : string;
begin
  randomize;
  st := -1;
  i := 0;
  randomize;
  while (st < 1) or (st>20) do
  begin
    st := randomrange(Stufe-2,Stufe+2);
    inc(i);
    if i > 100 then
    begin
      st := 20;
      break;
    end;
  end;
                          
  klasse := randomrange(0,4);
  if klasse = 0 then klasse := 4;

  Pfad := '';
  for i := 0 to fAusruestungen.Count - 1 do
  begin
    if ((fAusruestungen[i] as TAusruestung).Stufe = St) and ((fAusruestungen[i] as TAusruestung).Klasse = klasse) then
    begin
      Pfad := (fAusruestungen[i] as TAusruestung).IconPfad;
      break;
    end;
  end;

  result := TAusruestung.create(0,klasse,st,Pfad);
end;

{TSportShop.}

//-> Reset: erst freigeben
procedure TSportShop.ResetSportShop; //Jede Woche, randomID aus Namenliste, Anzahl randomrange(0..2) erzeugen
var
  i : integer;
  Anzahl : integer;
  m:integer;
begin
  // Ausrüstungen beibehalten nur adden und bei >= 20, die ersten 10 löschen
  if fAusruestungen.Count > 10 then
  begin
    while fAusruestungen.Count > 7 do
    begin
      fAusruestungen.Delete(0);
    end;
  end;

  Anzahl := randomrange(6,10);
  setLength(WochenAusr,Anzahl);

  randomize;
  for i := 0 to Anzahl-1 do
  begin
    m :=randomrange(1,6);
    if m = 6 then m := 5;
    WochenAusr[i] := m;
  end;
end;

procedure TSportShop.CheckSportShop;//Jeden Tag aufrufen, Generiert Ereignis
var
  i : integer;
begin
//  Erscheinungstag checken
// -> dann auf -1 setzen wenn zutrifft
//  for i := 0 to fAusruestungen.count - 1 do
//  begin
//    if (fAusruestungen[i] as TAusruestung).ErscheinungsTag = cdZeit.Tag then
//    begin
//      cdEreignisse.AddEreignis(cUCDNeueAusruestung + (fAusruestungen[i] as TAusruestung).Bezeichnung);
//      (fAusruestungen[i] as TAusruestung).ErscheinungsTag := -1;
//    end;
//  end;

  for i := 0 to High(WochenAusr) do
  begin
    if WochenAusr[i] = cdZeit.Tag then
    begin
      self.fAusruestungen.Add(cdAusruestungen.CreateAusruestung(cdSpieler.Level));
      cdEreignisse.AddEreignis(cUCDNeueAusruestung + (fAusruestungen[fAusruestungen.count-1] as TAusruestung).Bezeichnung);
    end;
  end;
end;

constructor TSportShop.create;
begin
  fAusruestungen := TObjectList.Create;
end;

destructor TSportShop.destroy;
begin
  freeandnil(fAusruestungen);
  inherited destroy;
end;



{TKneipe.}

procedure TKneipe.ResetKneipe; //Jede Woche, randomID aus Namenliste, Anzahl randomrange(0..3) erzeugen
var
  i  : integer;
  Vornamen:TStringList;
  Nachnamen:TStringList;
  vor,nach:integer;
  Datenpfad:string;
  Level:integer;

  Fit : integer;
  Tech : integer;
  Ausd : integer;
  MaxKr :integer;
begin
  GegnerListe.Clear;
  Anzahl := RandomRange(1,4);

  //Test
  //Anzahl := 10;

  //Namen laden
  DatenPfad := ExtractFilePath(Application.ExeName);
  Vornamen := TStringList.Create;
  Nachnamen := TStringList.Create;

  try
    Vornamen.LoadFromFile(Datenpfad + cUCDVerzVornamen);
    Nachnamen.LoadFromFile(Datenpfad + cUCDVerzNachnamen);

    Randomize;
    for i := 0 to Anzahl-1 do
    begin
      repeat
        Level := randomrange(cdSpieler.Level - 3, cdSpieler.Level + 3);
      until Level > 0;

      vor := randomrange(1+i,vornamen.count-2);
      nach := randomrange(1+i,nachnamen.count-2);

      Fit := randomrange(10+Summe(Level) div 3, 10+Summe(Level))+i;
      Tech := randomrange(10+Summe(Level) div 3, 10+Summe(Level))+i;



//      Ausd := randomrange(10+Level*Level,(10+Level*Level)*2)+i;
//      MaxKr := randomrange(10+Level*Level,(10+Level*Level)*2)+i;
        MaxKr := randomrange(Level*Level*5,(Level*Level)*6);
        Ausd := randomrange(Level*Level*5,(Level*Level)*6);

        randomize;
        if level = 1 then
        begin
          MaxKr := randomrange(19,31);
          Ausd := randomrange(19,31);
        end;

        randomize;
        if level = 2 then
        begin
          MaxKr := randomrange(29,40);
          Ausd := randomrange(29,40);
        end;


      GegnerListe.Add(TKneipenGegner.create(i,vornamen[vor],nachnamen[nach],MaxKr,Ausd,Tech,0,0,0,randomrange(18,66),Level,0,Fit,0));
    end;
  finally
    freeandnil(vornamen);
    freeandnil(nachnamen);
  end;
end;

procedure TKneipe.CheckKneipe;//Jeden Tag aufrufen, Generiert Ereignis
var
  i : integer;
begin
  for i := 0 to GegnerListe.count - 1 do
  begin
    if (GegnerListe[i] as TKneipenGegner).ErscheinungsTag = cdZeit.Tag then
    begin
      cdEreignisse.AddEreignis(cNeuerKneipenGegner + (GegnerListe[i] as TKneipenGegner).Vorname + ' ' + (GegnerListe[i] as TKneipenGegner).Name + ' Level ' + inttostr((GegnerListe[i] as TKneipenGegner).Level));
    end;
  end;
end;

constructor TKneipe.create;
begin
  GegnerListe := TObjectList.Create;
end;

destructor TKneipe.destroy;
begin
  freeandnil(GegnerListe);
  inherited destroy;
end;


{TKneipenGegner}

constructor TKneipenGegner.create(ID_:Integer;Vorname_:string; Name_:string; Maxkraft_:Integer; Ausdauer_:integer; Technik_:Integer; Liga_:Integer; Siege_:Integer; Niederlagen_:Integer; Alter_:Integer; Level_, Erfahrung_, Fitness_, Ansehen_: integer); // -> inherited create aufrufen
var
  a : integer;
begin
  inherited create(ID_, Vorname_, Name_, Maxkraft_, Ausdauer_, Technik_, Liga_, Siege_, Niederlagen_, Alter_, Level_, Erfahrung_, Fitness_, Ansehen_,Fitness_);

  randomize;
  a := randomrange(1,6);
  if a = 6 then a := 5;
  ErscheinungsTag := a;
  WettBetrag := Randomrange(Self.Level*10, Self.Level*20);
end;

destructor TKneipenGegner.destroy;
begin
  inherited destroy;
end;


{TTurnierRunde}

constructor TTurnierRunde.create;
var
  i : integer;
begin
//  SiegerIDs := TStringList.Create;
  for i := 0 to high(Begegnungen) do
  begin
    Begegnungen[i].z := -1;
    //SiegerIDs.Add('-1');
  end;
end;

destructor TTurnierRunde.destroy;
var
  i : integer;
begin
//  freeandnil(SiegerIDs);
  inherited destroy;
end;


{TTurniere}

procedure TTurniere.LoadTurniereFromFile;
var
  ConfigFile : TStringList;
  Limit : TStringList;
  i : integer;
  test : integer;
//  Term:TZeit;
  a:integer;
begin
//0    Bezeichnung:string;
//1,2,3    Termin:TZeit; -> Runde;Woche;Tag
//4    AnzahlGegner:integer; // 15, 31 oder 63

//5    MinLiga:integer; // 1..3
//6    MinLevel:integer; // 1..20
//7    MinAnsehen:integer;
//8    Startgebuehr:integer;
//9   Preisgeld
  ConfigFile := TStringList.Create;
//  Term := TZeit.Create(0,0,0,0);
  Limit := TStringList.create;
  Limit.Delimiter := ';';
  try
    ConfigFile.LoadFromFile(ExtractFilePath(application.ExeName)+cUCDTurniereFile);
    a:=0;
    for i := 0 to ConfigFile.Count - 1 do
    begin
      if (ConfigFile[i] = '') or (ConfigFile[i] = ' ') or (ConfigFile[i][1] = '/') then continue;
      Limit.Clear;
      Limit.DelimitedText := ConfigFile[i];
//      Term.Woche := strtoint(Limit[2]);
//      Term.Runde := strtoint(Limit[1]);
//      Term.Tag := strtoint(Limit[3]);

      Limit[0] := DeleteMindString(Limit[0]);
      Limit[10] := DeleteMindString(Limit[10]);
      fTurniere.Add(TTurnier.create(a,Limit[10],Limit[0],TZeit.Create(strtoint(Limit[2]),strtoint(Limit[3]),strtoint(Limit[1]),0),strtoint(Limit[4]),strtoint(Limit[5]),strtoint(Limit[6]),strtoint(Limit[7]),strtoint(Limit[8]),strtoint(Limit[9])));
      inc(a);
    end;

  finally
    freeandnil(ConfigFile);
    freeandnil(Limit);
  end;
end;

function TTurniere.MorgenTurnier:integer; // Liefert ID des Turniers das morgen ist, prüfen, ob angemeldet
var
  i : integer;
  t : TZeit;
begin
  result := -1;
  for i := 0 to fTurniere.Count - 1 do
  begin
    (fTurniere[i] as TTurnier).Termin.Saison := cdZeit.Saison;
    if cdZeit.runde = (fTurniere[i] as TTurnier).Termin.runde then
    begin
      if cdZeit.Woche = (fTurniere[i] as TTurnier).Termin.woche then
      begin
        if cdZeit.Tag = (fTurniere[i] as TTurnier).Termin.tag-1 then
        begin
          result := (fTurniere[i] as TTurnier).ID;
          exit;
        end;
      end;
    end;
  end;
end;

function TTurniere.HeuteTurnier:integer; // Liefert ID des Turniers das heute ist, prüfen, ob angemeldet
var
  i : integer;
  t : TZeit;
begin
  result := -1;
  for i := 0 to fTurniere.Count - 1 do
  begin
    (fTurniere[i] as TTurnier).Termin.Saison := cdZeit.Saison;
    if (fTurniere[i] as TTurnier).Termin.VergleicheZeiten((fTurniere[i] as TTurnier).Termin, cdZeit) = 0 then
    begin
      //result := i;
      result := (fTurniere[i] as TTurnier).ID;
      exit;
    end;
  end;
end;

procedure TTurniere.CheckTurniere; //Prüft, ob neues Turnier, Generiert Ereignis
var
  i : integer;
  temp:TZeit;
  test:TZeit;
begin
  for i := 0 to fTurniere.Count - 1 do
  begin
    temp := TZeit.Create(cdzeit.Woche,cdzeit.Tag,cdzeit.Runde,cdzeit.Saison);
    if (cdzeit.VergleicheZeiten((fTurniere[i] as TTurnier).termin,temp) <> 1) then
    begin
      (fTurniere[i] as TTurnier).Show := false;
      continue;
    end;

    try
      temp.IncWeek(2);
      test := (fTurniere[i] as TTurnier).termin;
      if cdzeit.VergleicheZeiten((fTurniere[i] as TTurnier).termin,temp) = 2 then
      begin
        (fTurniere[i] as TTurnier).Show := true;
        if (fTurniere[i] as TTurnier).MachEreignis = 0 then (fTurniere[i] as TTurnier).MachEreignis := 1;
      end else
      begin
        (fTurniere[i] as TTurnier).Show := false;
        (fTurniere[i] as TTurnier).machereignis := 0;
      end;
    finally
      freeandnil(temp);
    end;

    if (fTurniere[i] as TTurnier).MachEreignis = 1 then
    begin
      cdEreignisse.AddEreignis(cNeuesTurnier + (fTurniere[i] as TTurnier).Bezeichnung,1);
      (fTurniere[i] as TTurnier).MachEreignis := 2;
    end;
  end;
end;

constructor TTurniere.create;
begin
  fTurniere := TObjectList.Create;
  LoadTurniereFromFile;
end;

destructor TTurniere.destroy;
begin
  freeandnil(fTurniere);
  inherited destroy;
end;

{TTurnier}

procedure TTurnier.reset; //Turnier in Ausgangszustand versetzen
var
  i,j : integer;
begin
  Angemeldet := false;
  lastround := false;
  AktuelleRunde := 0;
  Show := false;
  MachEreignis := 0;

  //Sieger Runde 0 zurücksetzen
  for j := 0 to high(runden[0].begegnungen) do
  begin
    Runden[0].Begegnungen[j].Z := -1;
  end;

  //Paarungen und Sieger ab Runde 1 zurücksetzen
  for i := 1 to high(Runden) do
  begin
    for j := 0 to high(runden[i].begegnungen) do
    begin
      Runden[i].Begegnungen[j].X := -1;
      Runden[i].Begegnungen[j].Y := -1;
      Runden[i].Begegnungen[j].Z := -1;
    end;
  end;

end;

function TTurnier.anmelden:boolean;
begin
  result := false;
  if (cdSpieler.Liga <= MinLiga) and (cdSpieler.Level >= MinLevel)
  and (cdSpieler.Ansehen >= MinAnsehen) and (cdSpieler.Kapital >= Startgebuehr) then
  begin
    cdSpieler.Kapital := cdSpieler.Kapital - Startgebuehr;
    Angemeldet := true;
    result := true;
  end;
end;

procedure TTurnier.BerechneKaempfe;
var
  i : integer;
  count : integer;
  siegerid : integer;

  MaxKraft1,Maxkraft2:integer;
  KraftAusd1,KraftAusd2:integer;
  Technik1,Technik2:integer;
  k1All,k2All:integer;
begin
  //Kämpfe austragen
  //.. Fight Funktion implementieren

  //Sieger berechnen
  if AktuelleRunde <= high(runden) then
  begin

    for i := 0 to high(Runden[AktuelleRunde].Begegnungen) do
    begin
      if (self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].X].istspieler) or (self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].Y].istspieler) then
      begin
        Runden[AktuelleRunde].Begegnungen[i].z := -1;
        continue;
      end;

      MaxKraft1 := self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].X].Maximalkraft;
      MaxKraft2 := self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].Y].Maximalkraft;

      Technik1 := self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].X].Technik;
      Technik2 := self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].Y].Technik;

      KraftAusd1 := self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].X].Kraftausdauer;
      KraftAusd2 := self.Teilnehmer[Runden[AktuelleRunde].Begegnungen[i].Y].Kraftausdauer;

      randomize;
      k1All := randomrange((MaxKraft1+KraftAusd1+Technik1 div 2)-10,(MaxKraft1+KraftAusd1+Technik1 div 2)+10);
      k2All := randomrange((MaxKraft2+KraftAusd2+Technik2 div 2)-10,(MaxKraft2+KraftAusd2+Technik2 div 2)+10);

      if k1All > k2All then
      begin
        SiegerID := Runden[AktuelleRunde].Begegnungen[i].X;
      end else if k2All > k1All then
      begin
        SiegerID := Runden[AktuelleRunde].Begegnungen[i].Y;
      end else
      begin
        SiegerID := randomrange(1,2);
        case SiegerID of
          1:  begin
                SiegerID := Runden[AktuelleRunde].Begegnungen[i].X;
              end;
          2:  begin
                SiegerID := Runden[AktuelleRunde].Begegnungen[i].Y;
              end;
        end;
      end;

      //self.Teilnehmer[inttostr(Runden[AktuelleRunde].Begegnungen[i].X].
      //self.Teilnehmer[inttostr(Runden[AktuelleRunde].Begegnungen[i].Y]

      //    Runden[AktuelleRunde].SiegerIDs.Add(inttostr(Runden[AktuelleRunde].Begegnungen[i].X));

      //if Runden[AktuelleRunde].Begegnungen[i].z = -1 then
      //begin

      if (Runden[AktuelleRunde].Begegnungen[i].z <> Runden[AktuelleRunde].Begegnungen[i].X) and (Runden[AktuelleRunde].Begegnungen[i].z <> Runden[AktuelleRunde].Begegnungen[i].Y) then
      begin
        Runden[AktuelleRunde].Begegnungen[i].z:= siegerid;
      end;
    end;
  end;

  //Begegnungen für die nächste Runde berechnen
  if AktuelleRunde < high(runden) then
  begin
    count := 0;
    for i := 0 to high(Runden[AktuelleRunde+1].begegnungen) do// ((Runden[AktuelleRunde].  SiegerIDs.count) div 2)-1 do
    begin
      Runden[AktuelleRunde+1].Begegnungen[i].X := Runden[AktuelleRunde].begegnungen[count].z;  //SiegerIDs[Count]);
      Runden[AktuelleRunde+1].Begegnungen[i].Y := Runden[AktuelleRunde].begegnungen[count+1].z;  //SiegerIDs[Count+1]);
      inc(count,2);
    end;
    inc(self.AktuelleRunde);
  end;
end;

constructor TTurnier.create(ID_:integer;Beschreibung_:string;Bezeichnung_:string;Termin_:TZeit;AnzahlGegner_:integer;MinLiga_:integer;MinLevel_:integer;MinAnsehen_:integer;Startgebuehr_:integer;Preisgeld_:integer);
var
  i,j:integer;
  sp : integer;
begin
  ID:=ID_;
  AktuelleRunde := 0;
  Beschreibung := Beschreibung_;

  lastround := false;
  Bezeichnung:=Bezeichnung_;
  Termin:=Termin_;
  AnzahlGegner:=AnzahlGegner_;//integer; // 15, 31 oder 63

  MinLiga:=MinLiga_; // 1..5
  MinLevel:=MinLevel_;//integer; // 1..20
  MinAnsehen:=MinAnsehen_;//integer;
  Startgebuehr:=Startgebuehr_;//integer;
  Preisgeld:=Preisgeld_;

  //Erstellen:
  setLength(Teilnehmer,AnzahlGegner+1);
  for i := 0 to high(Teilnehmer) do
  begin
    case MinLiga of // -> Nach Level !!!
      1:Teilnehmer[i] := CreateSportlerByLevel(i,randomrange(MinLevel,randomrange(MinLevel,MinLevel+10)));
      2:Teilnehmer[i] := CreateSportlerByLevel(i,randomrange(MinLevel,randomrange(MinLevel,MinLevel+8)));
      3:Teilnehmer[i] := CreateSportlerByLevel(i,randomrange(MinLevel,randomrange(MinLevel,MinLevel+6)));
      4:Teilnehmer[i] := CreateSportlerByLevel(i,randomrange(MinLevel,randomrange(MinLevel,MinLevel+3)));
      5:Teilnehmer[i] := CreateSportlerByLevel(i,randomrange(MinLevel,randomrange(MinLevel,MinLevel+2)));
    end;
  end;

  randomize;
  sp := randomrange(0,high(Teilnehmer));
  Teilnehmer[sp].Vorname := cdSpieler.Vorname;
  Teilnehmer[sp].Name := ' ';
  Teilnehmer[sp].Level := cdspieler.Level;
  Teilnehmer[sp].IstSpieler := true;
  //Teilnehmer[sp].ID := 99;

  //Anzahl Runden nach Anzahl Gegner festlegen
  case AnzahlGegner of
    15: begin
          setLength(Runden,4);
        end;
    31: begin
          setLength(Runden,5);
        end;
    63: begin
          setLength(Runden,6);
        end;
  end;

  //Runden erstellen
  for i := 0 to high(Runden) do
  begin
    Runden[i] := TTurnierRunde.Create;
  end;

  //1.Runde Anzahl Begegnungen festlegen
  setLength(Runden[0].Begegnungen,(AnzahlGegner+1) div 2);

  //Restliche Runden Anzahl Begegnungen festlegen
  for i := 1 to high(Runden) do
  begin
    setLength(Runden[i].Begegnungen, Length(Runden[i-1].Begegnungen) div 2);
    for j := 0 to high(Runden[i].Begegnungen) do
    begin
      Runden[i].Begegnungen[j].X := -1;
      Runden[i].Begegnungen[j].Y := -1;
      Runden[i].Begegnungen[j].Z := -1;
    end;
  end;

  //1.Runde Begegnungen initialisieren
  //Spieler hat ID: High(Teilnehmer)
  i := 0;
  j := 0;
  while j < (AnzahlGegner+1) div 2 do
  begin
    Runden[0].Begegnungen[j].X := i;
    Runden[0].Begegnungen[j].Y := i+1;
    inc(i,2);
    inc(j);
  end;

  //Show := true;
  MachEreignis := 0;


  // TEST
  //Angemeldet:=true; //Ist Spieler angemeldet?


end;

destructor TTurnier.destroy;
var
  i : integer;
begin
  for i := 0 to high(Teilnehmer) do
  begin
    freeandnil(Teilnehmer[i]);
  end;
  inherited destroy;
end;


function TZeit.VergleicheZeiten(Zeit1,Zeit2:TZeit):integer; // 0 = gleich, 1 = Zeit1 ist größer, 2 = Zeit2 ist größer
begin
  // Saison, Runde, Woche, Tag

  //Saison erst mal nicht prüfen
//  if zeit1.Saison > zeit2.Saison then
//  begin
//    result := 1;
//    exit;
//  end else if zeit2.Saison > zeit1.Saison then
//  begin
//    result := 2;
//    exit;
//  end else
//  begin


    //Runde
    if zeit1.Runde > zeit2.Runde then
    begin
      result := 1;
      exit;
    end else if zeit2.Runde > zeit1.Runde then
    begin
      result := 2;
      exit;
    end else
    begin
      //Woche
      if zeit1.Woche > zeit2.Woche then
      begin
        result := 1;
        exit;
      end else if zeit2.Woche > zeit1.Woche then
      begin
        result := 2;
        exit;
      end else
      begin
        //Tag
        if zeit1.Tag > zeit2.Tag then
        begin
          result := 1;
          exit;
        end else if zeit2.Tag > zeit1.Tag then
        begin
          result := 2;
          exit;
        end else
        begin
          //Beide gleich
          result := 0;
        end;
      end;
    end;
  //end;
end;


{TSponsor}

destructor TSponsor.destroy;
begin
  freeandnil(Icon);
  inherited destroy;
end;

Constructor TSponsor.create(Ansehen:integer;Name:string;ID:integer;Pfad:string);
var
  jpeg : TJPegImage;
begin
  jPeg := TJPegImage.create;
  try
    Icon := TDXDIB.Create(nil);
    jPeg.LoadFromFile(extractFilePath(application.exename)+Pfad);
    Icon.DIB.Assign(jpeg);
    self.IconPfad := pfad;
    Laufzeit := randomrange(cSponsorLaufzeitMin,cSponsorLaufzeitMax);
    sieggeld := randomrange(round(cdspieler.Meisterschaften3 + cdspieler.Meisterschaften2*2 + cdspieler.Meisterschaften1*3 +  cdspieler.Turniersiege * 3 + cdspieler.Level * 2 + 30 +Ansehen*2+(Laufzeit*Laufzeit)/100)-cdspieler.Rang*2, round(cdSpieler.Level*2 + 100 + Ansehen*2+(Laufzeit*Laufzeit)/100) - cdspieler.Rang*2 + cdspieler.Meisterschaften3 + cdspieler.Meisterschaften2*2 + cdspieler.Meisterschaften1*3 +  cdspieler.Turniersiege);
    Geld :=  sieggeld div 3;
    if Geld < 10 then Geld := 10;
    if sieggeld < 30 then sieggeld := randomrange(30,40);
    AnzeigeTag := randomrange(1,5);  //1..5 -> randomrange(1..5)
    self.ID := ID;
    self.name := name;
  finally
    freeandnil(jPeg);
  end;
end;

procedure TSponsor.SchliesseVertrag; //Im Sponsorenmenü Handschlag
begin
  VertragsAbschluss := TZeit.Create(cdZeit.Woche,cdZeit.Tag,cdZeit.Runde,cdZeit.Saison);
  VertragsEnde := TZeit.Create(cdZeit.Woche,cdZeit.Tag,cdZeit.Runde,cdZeit.Saison);
  VertragsEnde.IncWeek(Laufzeit);

  if (vertragsende.Saison > vertragsabschluss.Saison) or (vertragsende.runde > vertragsabschluss.runde) then
  begin
    vertragsende.Runde := cdzeit.runde;
    vertragsende.Woche := 5;
    vertragsende.Tag := 5;
  end;

//  if vertragsende.Saison > vertragsabschluss.Saison then
//  begin
//    vertragsende.Runde := 2;
//    vertragsende.Woche := 18;
//    vertragsende.Tag := 5;
//  end;
end;


{TSponsoren}

procedure TSponsoren.ResetSponsoren; //Jede Woche, randomID aus Namenliste, Anzahl randomrange(0..3) erzeugen
var
  Anzahl : integer;
  i : integer;
  cID : integer;
  NeueIDGefunden : boolean;
  oldLength : integer;
  k : integer;
begin
  if (NamenListe.Count < 1) or (PfadListe.Count < 1) then exit;

  if length(fSponsoren) > 20 then
  begin
//    for i := high(fSponsoren) downto high(fSponsoren)-5 do
//    begin
//      freeandnil(fSponsoren[i]);
//    end;
      for i := 0 to high(fSponsoren) do
      begin
        freeandnil(fSponsoren[i]);
      end;
//      setLength(fSponsoren,high(fSponsoren)-6);
      setLength(fSponsoren,0);
  end;

  Anzahl := randomrange(cUCDSponsorenPerWeekMin,cUCDSponsorenPerWeekMax);
  setLength(WochenSpons,Anzahl);

  randomize;
  for i := 0 to Anzahl-1 do
  begin
    k := randomrange(1,6);
    if k = 6 then k := 5;
    WochenSpons[i] := k;
  end;

//  repeat
//    NeueIDGefunden := true;
//    cID := randomrange(0,Namenliste.Count-1);
//    for i := 0 to high(fSponsoren) do
//    begin
//      if fSponsoren[i].ID = cID then
//      begin
//        NeueIDGefunden := false;
//      end;
//    end;
//  until NeueIDGefunden;

//  for i := oldLength to oldLength+Anzahl-1 do
//  begin
//    cID := randomrange(0,Namenliste.Count-1);
//    fSponsoren[i] := TSponsor.create(cdSpieler.Ansehen,Namenliste[cID],cID,Pfadliste[cID]);
//  end;
end;

procedure TSponsoren.CheckSponsoren;//Jeden Tag aufrufen
var
  i : integer;
  cID : integer;
begin
  //Sponsoren werden für jede Woche erzeugt -> Daher jeden Tag prüfen, ob Neues Sponsorenangebot
//  for i := 0 to high(fSponsoren) do
//  begin
//    if fSponsoren[i].AnzeigeTag = cdZeit.Tag then
//    begin
//      cdEreignisse.AddEreignis(cNeuerSponsor + fSponsoren[i].Name);
//    end;
//  end;

  for i := 0 to High(WochenSpons) do
  begin
    if WochenSpons[i] = cdZeit.Tag then
    begin
      setLength(fSponsoren,length(fSponsoren)+1);
      cID := randomrange(0,Namenliste.Count-1);
      self.fSponsoren[high(fSponsoren)] := TSponsor.create(cdSpieler.Ansehen,Namenliste[cID],cID,Pfadliste[cID]);
      cdEreignisse.AddEreignis(cNeuerSponsor + fSponsoren[high(fSponsoren)].Name);
    end;
  end;
end;

constructor TSponsoren.create;
var
  ConfigFile : TStringList;
  Limit : TStringList;
  i : integer;
begin
  Namenliste := TStringList.Create;
  PfadListe := TStringList.create;
  try
    ConfigFile := TStringList.Create;
    Limit := TStringList.create;
    Limit.Delimiter := ';';
    ConfigFile.LoadFromFile(ExtractFilePath(Application.ExeName)+cUCDSponsorenFile);
    for i := 0 to ConfigFile.Count - 1 do
    begin
      if (ConfigFile[i] = '') or (ConfigFile[i] = ' ') or (ConfigFile[i][1] = '/') then continue;
      Limit.Clear;
      Limit.DelimitedText := ConfigFile[i];
      PfadListe.Add(Limit[0]);
      Limit[1] := DeleteMindString(Limit[1]);
      NamenListe.Add(Limit[1]);
    end;
  finally
    freeandnil(ConfigFile);
    freeandnil(Limit);
  end;
end;

destructor TSponsoren.destroy;
var
  i : integer;
begin
  freeandnil(Namenliste);
  freeandnil(PfadListe);
  for i := 0 to High(fSponsoren) do
  begin
    freeandnil(fSponsoren[i] as TSponsor);
  end;
  inherited destroy;
end;
     

{TEreignisse}
procedure TEreignisse.AddEreignis(Bez:string;art:integer); //Wird von anderen Objekten aufgerufen
begin
  if art = 1 then
  begin
    Ereignisse.Insert(0,CenterString(Bez,46));
    artliste.insert(0,inttostr(art));
  end else
  begin
    Ereignisse.Add(CenterString(Bez,46));
    artliste.Add(inttostr(art));
  end;
end;

procedure TEreignisse.DeleteAllEreignisse; //Jeden Tag
begin
  Ereignisse.Clear;
  artliste.Clear;
end;

constructor TEreignisse.create;
begin
  Ereignisse := TStringList.Create;
  artliste := TStringList.create;
end;

destructor TEreignisse.destroy;
begin
  freeandnil(Ereignisse);
  freeandnil(artliste);
  inherited destroy;
end;

constructor TKampfSaison.Create;
var
  Team : TTeam;
  Week : TWeek;
  i,j : integer;
begin
  setlength(Team,cUCDGegner+1);
  for i := 0 to high(Team) do
  begin
    Team[i] := i+1;
  end;
  Week := CreateSchedule(Team,0);

  for i := 0 to high(week) do
  begin
    self.Vorrunde[i+1] := TKampfTag.Create;
    self.Rueckrunde[i+1] := TKampfTag.Create;
    for j := 0 to high(week[i].game) do
    begin
      self.vorrunde[i+1].Kaempfe[j+1] := TKampf.Create(round(week[i].Game[j].Team1),round(week[i].Game[j].Team2),0);
      self.Rueckrunde[i+1].Kaempfe[j+1] := TKampf.Create(round(week[i].Game[j].Team1),round(week[i].Game[j].Team2),0);
    end;
  end;
end;

constructor TKampfTag.Create;
begin
  inherited create;
  //Zuweisungen in TKampfsaison.create implementiert
end;

procedure TKampf.Fight;
var
  i : integer;
  MaxKraft1 : integer;
  MAxKraft2 : integer;
  KraftAusd1 : integer;
  KraftAusd2 : integer;
  weiter : boolean;
  k1All : integer;
  k2All : integer;
  Technik1 : integer;
  Technik2 : integer;
begin
  MaxKraft1 := (cdGegner.gegner[K1_ID] as TSportler).Maximalkraft;
  MaxKraft2 := (cdGegner.gegner[K2_ID] as TSportler).Maximalkraft;

  Technik1 := (cdGegner.gegner[K1_ID] as TSportler).Technik;
  Technik2 := (cdGegner.gegner[K2_ID] as TSportler).Technik;

  KraftAusd1 := (cdGegner.gegner[K1_ID] as TSportler).Kraftausdauer;
  KraftAusd2 := (cdGegner.gegner[K2_ID] as TSportler).Kraftausdauer;

  randomize;
  k1All := randomrange(MaxKraft1+KraftAusd1+Technik1, MaxKraft1+KraftAusd1+Technik1+(MaxKraft1+KraftAusd1+Technik1 div 2));
  k2All := randomrange(MaxKraft2+KraftAusd2+Technik2, MaxKraft2+KraftAusd2+Technik2+(MaxKraft2+KraftAusd2+Technik2 div 2));

  if k1All > k2All then
  begin
    SiegerID := K1_ID;
    inc((cdGegner.gegner[K1_ID] as TSportler).Siege);
    inc((cdGegner.gegner[K2_ID] as TSportler).Niederlagen);
  end else if k2All > k1All then
  begin
    SiegerID := K2_ID;
    inc((cdGegner.gegner[K2_ID] as TSportler).Siege);
    inc((cdGegner.gegner[K1_ID] as TSportler).Niederlagen);
  end else
  begin
    SiegerID := randomrange(1,2);
    case SiegerID of
      1:  begin
            SiegerID := k1_ID;
            inc((cdGegner.gegner[K1_ID] as TSportler).Siege);
            inc((cdGegner.gegner[K2_ID] as TSportler).Niederlagen);
          end;
      2:  begin
            SiegerID := k2_ID;
            inc((cdGegner.gegner[K2_ID] as TSportler).Siege);
            inc((cdGegner.gegner[K1_ID] as TSportler).Niederlagen);
          end;
    end;
  end;

end;

constructor TKampf.Create(ID1,ID2,SiegerID_:integer);
begin
  inherited create;
  K1_ID := ID1;
  K2_ID := ID2;
  SiegerID := SiegerID_;
end;

constructor TZeit.Create(Woche_,Tag_,Runde_:integer;Saison_:integer);
begin
  inherited create;
	Woche := Woche_;
  Tag := Tag_;
  Runde := Runde_;
  Saison := Saison_;
end;

procedure TZeit.IncWeek(Count:integer);
begin
  repeat
    if Woche < cUCDWochen then
    begin
      inc(Woche);
    end else
    begin
      Woche := 1;
      IncRunde;
    end;

    dec(Count);
  until Count = 0;
end;

procedure TZeit.IncRunde;
begin
  if Runde = 1 then
  begin
    NextRound := true;
    Runde := 2;
  end else
  begin
    NextRound := true;
    NextSaison := true;
    inc(Saison);
    Runde := 1;
  end;
end;

procedure TZeit.IncDay;
begin
  if Tag < 5 then
  begin
    inc(Tag);
  end else
  begin
    Tag := 1;
    NextWeek := true;
    IncWeek(1);
  end;
end;

function TZeit.TagString:string;
begin
  result := '';
  case Tag of
    1: result := 'Mo';
    2: result := 'Di';
    3: result := 'Mi';
    4: result := 'Do';
    5: result := 'Fr';
  end;
end;

function TZeit.TagStringGanz:string;
begin
  result := '';
  case Tag of
    1: result := 'Montag';
    2: result := 'Dienstag';
    3: result := 'Mittwoch';
    4: result := 'Donnerstag';
    5: result := 'Freitag';
  end;
end;

function TSportler.Rang : integer;
var
  Liste : TObjectList;
  i,j : integer;
  rang : integer;
  a : integer;
  u:integeR;
begin
  Liste := TObjectList.create;
  try
    cdGegner.getlistbyPoints(Liste);
    result := 0;
    rang := 0;
    for i := 0 to liste.Count-1 do
    begin
      if (liste[i] as TSportler).ID = self.ID then
      begin
        rang := i+1;

        j := i;

        if j > 0 then
        begin
          while (self.Siege = (liste[j] as TSportler).Siege) do
          begin
            rang := j+1;
            j := j - 1;
            if j < 0 then break;
          end;
        end;

        break;
      end;
    end;
    result := rang;
    if result < 1 then result := 1;
  finally
 // result := 20;
    freeandnil(liste);
  end;
end;


constructor TSportler.Create(ID_:Integer;Vorname_:string; Name_:string; Maxkraft_:Integer; Ausdauer_:integer; Technik_:Integer; Liga_:Integer; Siege_:Integer; Niederlagen_:Integer; Alter_:Integer;Level_, Erfahrung_, Fitness_, Ansehen_: integer; FitnessMaximum_:integer);
begin
  ID := ID_;
  if (trim(Vorname_) <> '') and (trim(Vorname_) <> ' ') then
  begin
    Vorname := AddMindString(Vorname_);
  end;
  if (trim(name_) <> '') and (trim(name_) <> ' ') then
  begin
    Name := AddMindString(Name_);
  end;

  Maximalkraft := Maxkraft_;
  Kraftausdauer := Ausdauer_;
  Technik := Technik_;
  Liga := Liga_;
  Siege := Siege_;
  Niederlagen := Niederlagen_;
	Alter := Alter_;
  Level := Level_;
  Erfahrung := Erfahrung_;
  Fitness := Fitness_;
  FitnessMaximum := FitnessMaximum_;
  Ansehen := Ansehen_;
  IstSpieler := false;
end;

destructor TSpieler.destroy;
begin
  freeandnil(AusruestungRucksack);
  freeandnil(AusruestungAngezogen);
//  freeandnil(fSponsoren);
  freeandnil(fLevelUpValues);
  inherited destroy;
end;

constructor TSpieler.Create(Vorname_:string; Name_:string; Maxkraft_:Integer; Ausdauer_:integer; Technik_:Integer; Liga_:Integer; Siege_:Integer; Niederlagen_:Integer; Alter_:Integer; Siege_Alle_:Integer; Niederlagen_Alle_:Integer; Kampfanzahl_:Integer; Kapital_:Integer; Woche_:Integer; Tag_:Integer; Runde_:Integer; Level_, Erfahrung_, Fitness_, Ansehen_: integer;AusruestungRucksack_:TObjectList;AusruestungAngezogen_:TObjectList;Sponsoren_:TObjectList;Turnierteilnahmen_,Turniersiege_,Meisterschaften3_,Meisterschaften2_,Meisterschaften1_:integer;FitnessMaximum_:integer);
begin
	inherited Create(cUCDGegner+1,Vorname_,Name_,Maxkraft_,Ausdauer_,TEchnik_,Liga_,Siege_,Niederlagen_,Alter_,Level_, Erfahrung_, Fitness_, Ansehen_, FitnessMaximum_);
  EndeShown := false;

  TurnierKneipeSieg := false;
  TurnierBeginnersCornerSieg := false;
  TurnierProfiturnierSieg := false;
  TurnierEuropameisterschaftSieg := false;
  TurnierSportCafeTurnierSieg := false;
  TurnierRummelRingenSieg := false;
  TurnierProletenClubSieg := false;
  TurnierSemiProTurnier := false;
  TurnierWeltmeisterschaft := false;
  TurnierMeisterTurnier := false;

  regenerationsrate := 20;
  IstSpieler := true;
  fLevelUpPoints := 0;
  Kapital := Kapital_;
//  Kampfanzahl := Kampfanzahl_;
  Siege_Alle := Siege_Alle_;
  Niederlagen_Alle := Niederlagen_Alle_;

  Turnierteilnahmen := Turnierteilnahmen_;
  Turniersiege := Turniersiege_;
  Meisterschaften5 := 0;
  Meisterschaften4 := 0;
  Meisterschaften3 := Meisterschaften3_;
  Meisterschaften2 := Meisterschaften2_;
  Meisterschaften1 := Meisterschaften1_;

  AusruestungRucksack := AusruestungRucksack_;
  AusruestungAngezogen := AusruestungAngezogen_;
//  fSponsoren := Sponsoren_;

  if AusruestungRucksack = nil then AusruestungRucksack := TObjectList.create;
  if AusruestungAngezogen = nil then AusruestungAngezogen := TObjectList.create;
//  if fSponsoren = nil then fSponsoren := TObjectList.create;

  fLevelUp := false;

  fLevelUpValues := TStringList.create;
  fLevelUpValues.LoadFromFile(ExtractFilePath(application.exename)+cUCDPlayerFile);

  Sponsor := nil;
end;

procedure TSpieler.TurnierGewonnen(bez:string);
begin
  if lowercase(bez) = 'kneipenturnier' then
    TurnierKneipeSieg := true;
  if lowercase(bez) = 'beginners corner' then
    TurnierBeginnersCornerSieg := true;
  if lowercase(bez) = 'profiturnier' then
    TurnierProfiturnierSieg := true;
  if lowercase(bez) = 'europameisterschaft' then
    TurnierEuropameisterschaftSieg := true;
  if lowercase(bez) = 'sportcafe turnier' then
    TurnierSportCafeTurnierSieg := true;
  if lowercase(bez) = 'rummel ringen' then
    TurnierRummelRingenSieg := true;
  if lowercase(bez) = 'proleten club' then
    TurnierProletenClubSieg := true;
  if lowercase(bez) = 'semipro turnier' then
    TurnierSemiProTurnier := true;
  if lowercase(bez) = 'weltmeisterschaft' then
    TurnierWeltmeisterschaft := true;
  if lowercase(bez) = 'meisterturnier' then
    TurnierMeisterTurnier := true;
end;

procedure TSpieler.MeisterschaftGewonnen(index:integer);
begin
  case index of
    1: inc(Meisterschaften1);
    2: inc(Meisterschaften2);
    3: inc(Meisterschaften3);
    4: inc(Meisterschaften4);
    5: inc(Meisterschaften5);
  end;
end;


function TSpieler.GetNextLevelUpExperience:integer;
var
  i : integer;
begin
  result := strtoint(fLevelUpValues[self.Level+1]);
end;

function TSpieler.FitnessProzent:integer; //liefert zurück wieviel Prozent Fitness übrig sind
begin
  result := round((100 / cdspieler.fitnessMaximum)*cdSpieler.fitness);
end;

//function TSpieler.GetFitness : integer;
//begin
//      AusruestungAngezogen : TObjectList;
//    Klasse:integer; // 1 = Kopf, 2 = Handschuh, 3 = Schuh, 4 = Hantel

//  result := 0;
//end;

function TSpieler.GetMaximalkraft : integer;
var
  i : integer;
  prozentFitness : integer;
begin
  result := cdSpieler.Maximalkraft;
  //Ausrüstungswerte dazu
  for i := 0 to AusruestungAngezogen.count - 1 do
  begin
    if (AusruestungAngezogen[i] as TAusruestung).Klasse = 2 then
    begin
      result := cdSpieler.Maximalkraft + round((cdSpieler.Maximalkraft / 100) * (AusruestungAngezogen[i] as TAusruestung).AddMaxKr);
    end;
  end;
  //% Fitness einbeziehen
  result := round((result/100)*cdSpieler.FitnessProzent);
end;

function TSpieler.GetKraftausdauer : integer;
var
  i : integer;
begin
  result := cdSpieler.Kraftausdauer;
  for i := 0 to AusruestungAngezogen.count - 1 do
  begin                          
    if (AusruestungAngezogen[i] as TAusruestung).Klasse = 1 then
    begin
      result := cdSpieler.Kraftausdauer + round((cdSpieler.Kraftausdauer / 100) * (AusruestungAngezogen[i] as TAusruestung).AddAusd);
    end;
  end;
  //% Fitness einbeziehen
  result := round((result/100)*cdSpieler.FitnessProzent);
end;

function TSpieler.GetTechnik : integer;
var
  i : integer;
begin
  result := cdSpieler.Technik;
  for i := 0 to AusruestungAngezogen.count - 1 do
  begin
    if (AusruestungAngezogen[i] as TAusruestung).Klasse = 3 then
    begin
      result := cdSpieler.Technik + round((cdSpieler.Technik / 100) * (AusruestungAngezogen[i] as TAusruestung).AddTechnik);
    end;
  end;
end;

procedure TSpieler.incFitnessProzent(prozent:integer);
var
  improve : integer;
begin
  improve := round((fitnessmaximum/100)*regenerationsrate);
  Fitness := Fitness + improve;
  if fitness > FitnessMaximum then fitness := fitnessmaximum;
end;

procedure TSpieler.MieteZahlen;
var
  miete:integer;
begin
  case cdspieler.regenerationsrate of
    15: miete := 0;
    25: miete := 30;
    35: miete := 100;
    45: miete := 200;
    55: miete := 300;
  end;

  if cdspieler.Kapital < miete then
  begin
    cdspieler.regenerationsrate := 15;
    cdereignisse.AddEreignis('Sie wurden aus Ihrer Wohnung geschmissen',1);
  end else
  begin
    cdspieler.Kapital := cdspieler.Kapital - miete;
  end;
end;

procedure TSpieler.CheckSpieler;
var
  i : integer;
begin
  //Sponsoren
  if Sponsor <> nil then
  begin
    if cdzeit.NextWeek then
    begin
//      cdspieler.Kapital := cdspieler.Kapital + cdspieler.Sponsor.Geld; <- schon in afterfight
    end;

    if cdzeit.VergleicheZeiten(Sponsor.VertragsEnde,cdZeit) = 2 then
    begin
      cdEreignisse.AddEreignis(cSponsorVertragEnde + Sponsor.Name,1);
      freeandnil(cdspieler.sponsor);
    end;
  end;

  //Fitness auffüllen
  cdSpieler.incFitnessProzent(cdSpieler.regenerationsrate);
                                                      
  //LevelUp
  if self.level < 30 then
  begin
    if self.Erfahrung >= GetNextLevelUpExperience then
    begin
      fLevelUpPoints := fLevelUpPoints + Level + 5;
      fLevelUp := true;
      //inc(cdSpieler.regenerationsrate);
      cdEreignisse.AddEreignis(cLevelUp,1);
      inc(Level);
    end;
  end;
end;

procedure TGegner.ImproveValues; //jede Woche
var
  i : integer;
  aufsteiger:integer;
begin
  randomize;
//  aufsteiger := randomrange(1,cUCDGegner);
//  Gegner[aufsteiger].Level := Gegner[aufsteiger].level + 1;
//  Gegner[aufsteiger].Maximalkraft := Gegner[aufsteiger].Maximalkraft + Gegner[aufsteiger].level;
//  Gegner[aufsteiger].kraftausdauer := Gegner[aufsteiger].kraftausdauer + Gegner[aufsteiger].level;
//  Gegner[aufsteiger].Technik := Gegner[aufsteiger].Technik + 3;
  for i := 1 to cUCDGegner do
  begin
    Gegner[i].Maximalkraft := Gegner[i].Maximalkraft + randomrange(1+Gegner[i].Level div 2, 1+Gegner[i].level);
    Gegner[i].Kraftausdauer := Gegner[i].Kraftausdauer + randomrange(1+Gegner[i].Level div 2, 1+Gegner[i].level);
    Gegner[i].Technik := Gegner[i].Technik + randomrange(0,1);
    Gegner[i].Fitness := Gegner[i].Fitness + randomrange(0,1);
  end;
end;

procedure TGegner.GetListByPoints(var Liste:TObjectList);
var
  i,j : integer;
  temp : TSportler;
begin
  for i := 1 to cUCDGegner do
  begin
    Liste.Add(TSportler.Create(gegner[i].ID ,Gegner[i].vorName,Gegner[i].Name,Gegner[i].Maximalkraft,Gegner[i].Kraftausdauer,Gegner[i].Technik,Gegner[i].Liga,Gegner[i].Siege,Gegner[i].Niederlagen,Gegner[i].Alter,Gegner[i].Level,Gegner[i].Erfahrung,Gegner[i].Fitness,Gegner[i].Ansehen,Gegner[i].FitnessMaximum));
  end;
  Liste.Add(TSportler.Create(6,'',cdSpieler.vorName,cdSpieler.GetMaximalkraft,cdSpieler.GetKraftausdauer,cdSpieler.GetTechnik,cdSpieler.Liga,cdSpieler.Siege,cdSpieler.Niederlagen,cdSpieler.Alter,cdSpieler.Level,cdSpieler.Erfahrung,cdSpieler.Fitness,cdSpieler.Ansehen, cdSpieler.FitnessMaximum));

  //Sortieren
  for i := 0 to Liste.Count - 1 do
  begin
    for j := 0 to Liste.Count - 2 do
    begin
      if (Liste[j] as TSportler).Siege < (Liste[j+1] as TSportler).Siege then
      begin
        Liste.Exchange(j,j+1);
      end;
    end;
  end;
end;


procedure TGegner.GetListByMaxKraft(var Liste:TObjectList);
var
  i,j : integer;
  temp : TSportler;
begin
  for i := 1 to cUCDGegner do
  begin
    Liste.Add(TSportler.Create(i,Gegner[i].vorName,Gegner[i].Name,Gegner[i].Maximalkraft,Gegner[i].Kraftausdauer,Gegner[i].Technik,Gegner[i].Liga,Gegner[i].Siege,Gegner[i].Niederlagen,Gegner[i].Alter,Gegner[i].Level,Gegner[i].Erfahrung,Gegner[i].Fitness,Gegner[i].Ansehen, Gegner[i].FitnessMaximum));
  end;
  Liste.Add(TSportler.Create(6,'',cdSpieler.vorName,cdSpieler.GetMaximalkraft,cdSpieler.GetKraftausdauer,cdSpieler.GetTechnik,cdSpieler.Liga,cdSpieler.Siege,cdSpieler.Niederlagen,cdSpieler.Alter,cdSpieler.Level,cdSpieler.Erfahrung,cdSpieler.Fitness,cdSpieler.Ansehen,cdSpieler.FitnessMaximum));

  //Sortieren
  for i := 0 to Liste.Count - 1 do
  begin
    for j := 0 to Liste.Count - 2 do
    begin
      if (Liste[j] as TSportler).Maximalkraft < (Liste[j+1] as TSportler).Maximalkraft then
      begin
        Liste.Exchange(j,j+1);
      end;
    end;
  end;
end;

procedure TGegner.GetListByKrAusd(var Liste:TObjectList);
var
  i,j : integer;
  temp : TSportler;
begin
  for i := 1 to cUCDGegner do
  begin
    Liste.Add(TSportler.Create(i,Gegner[i].vorName,Gegner[i].Name,Gegner[i].Maximalkraft,Gegner[i].Kraftausdauer,Gegner[i].Technik,Gegner[i].Liga,Gegner[i].Siege,Gegner[i].Niederlagen,Gegner[i].Alter,Gegner[i].Level,Gegner[i].Erfahrung,Gegner[i].Fitness,Gegner[i].Ansehen,Gegner[i].FitnessMaximum));
  end;
  Liste.Add(TSportler.Create(6,'',cdSpieler.vorName,cdSpieler.GetMaximalkraft,cdSpieler.GetKraftausdauer,cdSpieler.GetTechnik,cdSpieler.Liga,cdSpieler.Siege,cdSpieler.Niederlagen,cdSpieler.Alter,cdSpieler.Level,cdSpieler.Erfahrung,cdSpieler.Fitness,cdSpieler.Ansehen, cdSpieler.FitnessMaximum));

  //Sortieren
  for i := 0 to Liste.Count - 1 do
  begin
    for j := 0 to Liste.Count - 2 do
    begin
      if (Liste[j] as TSportler).Kraftausdauer < (Liste[j+1] as TSportler).Kraftausdauer then
      begin
        Liste.Exchange(j,j+1);
      end;
    end;
  end;
end;

procedure TGegner.GetListByTechnik(var Liste:TObjectList);
var
  i,j : integer;
  temp : TSportler;
begin
  for i := 1 to cUCDGegner do
  begin
    Liste.Add(TSportler.Create(i,Gegner[i].vorName,Gegner[i].Name,Gegner[i].Maximalkraft,Gegner[i].Kraftausdauer,Gegner[i].Technik,Gegner[i].Liga,Gegner[i].Siege,Gegner[i].Niederlagen,Gegner[i].Alter,Gegner[i].Level,Gegner[i].Erfahrung,Gegner[i].Fitness,Gegner[i].Ansehen, Gegner[i].FitnessMaximum));
  end;
  Liste.Add(TSportler.Create(6,'',cdSpieler.vorName,cdSpieler.GetMaximalkraft,cdSpieler.GetKraftausdauer,cdSpieler.GetTechnik,cdSpieler.Liga,cdSpieler.Siege,cdSpieler.Niederlagen,cdSpieler.Alter,cdSpieler.Level,cdSpieler.Erfahrung,cdSpieler.Fitness,cdSpieler.Ansehen,cdSpieler.FitnessMaximum));

  //Sortieren
  for i := 0 to Liste.Count - 1 do
  begin
    for j := 0 to Liste.Count - 2 do
    begin
      if (Liste[j] as TSportler).Technik < (Liste[j+1] as TSportler).Technik then
      begin
        Liste.Exchange(j,j+1);
      end;
    end;
  end;
end;

procedure TGegner.GetListByFitness(var Liste:TObjectList);
var
  i,j : integer;
  temp : TSportler;
begin
  for i := 1 to cUCDGegner do
  begin
    Liste.Add(TSportler.Create(i,Gegner[i].vorName,Gegner[i].Name,Gegner[i].Maximalkraft,Gegner[i].Kraftausdauer,Gegner[i].Technik,Gegner[i].Liga,Gegner[i].Siege,Gegner[i].Niederlagen,Gegner[i].Alter,Gegner[i].Level,Gegner[i].Erfahrung,Gegner[i].Fitness,Gegner[i].Ansehen, Gegner[i].FitnessMaximum));
  end;
  Liste.Add(TSportler.Create(6,'',cdSpieler.vorName,cdSpieler.GetMaximalkraft,cdSpieler.GetKraftausdauer,cdSpieler.GetTechnik,cdSpieler.Liga,cdSpieler.Siege,cdSpieler.Niederlagen,cdSpieler.Alter,cdSpieler.Level,cdSpieler.Erfahrung,cdSpieler.Fitness,cdSpieler.Ansehen,cdSpieler.FitnessMaximum));

  //Sortieren
  for i := 0 to Liste.Count - 1 do
  begin
    for j := 0 to Liste.Count - 2 do
    begin
      if (Liste[j] as TSportler).Fitness < (Liste[j+1] as TSportler).Fitness then
      begin
        Liste.Exchange(j,j+1);
      end;
    end;
  end;
end;

procedure TGegner.GetListByLevel(var Liste:TObjectList);
var
  i,j : integer;
  temp : TSportler;
begin
  for i := 1 to cUCDGegner do
  begin
    Liste.Add(TSportler.Create(i,Gegner[i].vorName,Gegner[i].Name,Gegner[i].Maximalkraft,Gegner[i].Kraftausdauer,Gegner[i].Technik,Gegner[i].Liga,Gegner[i].Siege,Gegner[i].Niederlagen,Gegner[i].Alter,Gegner[i].Level,Gegner[i].Erfahrung,Gegner[i].Fitness,Gegner[i].Ansehen, Gegner[i].FitnessMaximum));
  end;
  Liste.Add(TSportler.Create(6,'',cdSpieler.vorName,cdSpieler.getMaximalkraft,cdSpieler.getKraftausdauer,cdSpieler.getTechnik,cdSpieler.Liga,cdSpieler.Siege,cdSpieler.Niederlagen,cdSpieler.Alter,cdSpieler.Level,cdSpieler.Erfahrung,cdSpieler.Fitness,cdSpieler.Ansehen,cdSpieler.FitnessMaximum));

  //Sortieren
  for i := 0 to Liste.Count - 1 do
  begin
    for j := 0 to Liste.Count - 2 do
    begin
      if (Liste[j] as TSportler).Level < (Liste[j+1] as TSportler).Level then
      begin
        Liste.Exchange(j,j+1);
      end;
    end;
  end;
end;

destructor TGegner.destroy;
var
  i : integer;
begin
  for i := 1 to cUCDGegner do
  begin
    freeandnil(Gegner[i]);
  end;
  inherited destroy;
end;

constructor TGegner.Create(Liga:Integer);
var
	Vornamen : TStringList;
	Nachnamen : TStringList;
  vor : Integer;
  nach : Integer;
  i : Integer;
	Datenpfad : string;
begin
  inherited create;
  for i := 1 to cUCDGegner do
  begin
    case liga of
    	1:Gegner[i] := CreateSportlerByLevel(i,randomrange(cUCDLevelMin1, cUCDLevelMax1));
      2:Gegner[i] := CreateSportlerByLevel(i,randomrange(cUCDLevelMin2, cUCDLevelMax2));
      3:Gegner[i] := CreateSportlerByLevel(i,randomrange(cUCDLevelMin3, cUCDLevelMax3));
      4:Gegner[i] := CreateSportlerByLevel(i,randomrange(cUCDLevelMin4, cUCDLevelMax4));
      5:Gegner[i] := CreateSportlerByLevel(i,randomrange(cUCDLevelMin5, cUCDLevelMax5));
    end;
  end;
end;

function TKampfSaison.CreateSchedule(Teams:TTeam; Level:integer):TWeek;
var Week:TWeek;
    Sub1,Sub2:TWeek;
    Teams1,Teams2:TTeam;
    i,j:integer;
    T1,T2:Real;
begin
  if (Length(Teams)<4)or(Length(Teams)mod 2=1) then begin
    Week:=nil;
  end else begin
    if Length(Teams)=4 then begin
      //wenn Teams =4 dann direkt aufteilen
      SetLength(Week,3);
      with Week[0] do begin
        SetLength(Game,2);
        Game[0].Team1:=Teams[0];
        Game[0].Team2:=Teams[2];
        Game[1].Team1:=Teams[1];
        Game[1].Team2:=Teams[3];
      end;
      with Week[1] do begin
        SetLength(Game,2);
        Game[0].Team1:=Teams[0];
        Game[0].Team2:=Teams[3];
        Game[1].Team1:=Teams[1];
        Game[1].Team2:=Teams[2];
      end;
      with Week[2] do begin
        SetLength(Game,2);
        Game[0].Team1:=Teams[0];
        Game[0].Team2:=Teams[1];
        Game[1].Team1:=Teams[2];
        Game[1].Team2:=Teams[3];
      end;
    end else begin
      //wenn Teams >4 dann aufteilen in zwei Gruppen
      j:=0;
      SetLength(Teams1,Length(Teams)div 2);
      SetLength(Teams2,Length(Teams)div 2);
      for i:=0 to Length(Teams1)-1 do begin
        Teams1[i]:=Teams[j];
        inc(j);
      end;
      for i:=0 to Length(Teams2)-1 do begin
        Teams2[i]:=Teams[j];
        inc(j);
      end;

      //Erzeugen der Spieltage, wenn beide Gruppen gegeneinander spielen
      //der erste Spieltag wird garnicht erst erzeugt, wenn in den Gruppen
      //eine ungerade Anzahl Teams ist
      SetLength(Week,Length(Teams1)-(Length(Teams1)mod 2));
      for i:=(Length(Teams1)mod 2) to Length(Teams1)-1 do begin
        SetLength(Week[i-(Length(Teams1)mod 2)].Game,Length(Teams1));
        for j:=0 to Length(Teams1)-1 do begin
          Week[i-(Length(Teams1)mod 2)].Game[j].Team1:=Teams1[j];
          Week[i-(Length(Teams1)mod 2)].Game[j].Team2:=Teams2[(j+i) mod Length(Teams1)];
        end;
      end;

      //wenn Teams1 oder Teams2 ungerade dann
      //  Freispiel einfügen [ -Level ]
      if Length(Teams1) mod 2 = 1 then begin
        SetLength(Teams1,Length(Teams1)+1);
        Teams1[Length(Teams1)-1]:=-Level;
        SetLength(Teams2,Length(Teams2)+1);
        Teams2[Length(Teams2)-1]:=-Level;
      end;

      //Übergabe jeder Gruppe an CREATESCHEDULE mit Level:=Level+1
      Sub1:=CreateSchedule(Teams1,Level+1);
      Sub2:=CreateSchedule(Teams2,Level+1);

      //Sub1 und Sub2 zusammenführen und in Week eintragen
      //dabei: Löschen der zusätzlich Eingeführten Freispiele (-Level)
      for i:=0 to Length(Sub1)-1 do begin
        SetLength(Week,Length(Week)+1);
        T1:=0;
        T2:=0;
        for j:=0 to Length(Sub1[i].Game)-1 do begin
          if (Sub1[i].Game[j].Team1<>-Level) and (Sub1[i].Game[j].Team2<>-Level) then begin
            SetLength(Week[Length(Week)-1].Game,Length(Week[Length(Week)-1].Game)+1);
            Week[Length(Week)-1].Game[Length(Week[Length(Week)-1].Game)-1].Team1:= Sub1[i].Game[j].Team1;
            Week[Length(Week)-1].Game[Length(Week[Length(Week)-1].Game)-1].Team2:= Sub1[i].Game[j].Team2;
          end else begin
            if Sub1[i].Game[j].Team1=-Level then
              T1:=Sub1[i].Game[j].Team2
            else
              T1:=Sub1[i].Game[j].Team1;
          end;
          if (Sub2[i].Game[j].Team1<>-Level) and (Sub2[i].Game[j].Team2<>-Level) then begin
            SetLength(Week[Length(Week)-1].Game,Length(Week[Length(Week)-1].Game)+1);
            Week[Length(Week)-1].Game[Length(Week[Length(Week)-1].Game)-1].Team1:=
              Sub2[i].Game[j].Team1;
            Week[Length(Week)-1].Game[Length(Week[Length(Week)-1].Game)-1].Team2:=
              Sub2[i].Game[j].Team2;
          end else begin
            if Sub2[i].Game[j].Team1=-Level then
              T2:=Sub2[i].Game[j].Team2
            else
              T2:=Sub2[i].Game[j].Team1;
          end;
        end;
        if (T1<>0) and (T2<>0) then begin
          SetLength(Week[Length(Week)-1].Game,Length(Week[Length(Week)-1].Game)+1);
          Week[Length(Week)-1].Game[Length(Week[Length(Week)-1].Game)-1].Team1:=T1;
          Week[Length(Week)-1].Game[Length(Week[Length(Week)-1].Game)-1].Team2:=T2;
        end;
      end;
      Finalize(Sub1);
      Finalize(Sub2);
      Finalize(Teams1);
      Finalize(Teams2);
    end;
  end;
  CreateSchedule:=Week;
end;



end.

