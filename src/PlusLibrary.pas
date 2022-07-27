{
    PlusLibrary
    Library die Zusatzfunktionen für alle möglichen Themen bereitstellt
    (c) Christian Merz 2005
}




unit PlusLibrary;

interface

uses
  sysutils,
  classes

  ;





//String-Funktionen
function CenterString(text:string;MaxLength:integer):string; // Setzt String in Mitte und cuttet ihn auf MaxLength
function MakeStringRight(text:string;laenge:integer):string; // Setzt String nach rechts und cuttet ihn auf laenge
function MakeStringLeft(text:string;laenge:integer):string;  // Setzt String nach links und cuttet ihn auf laenge
function DeleteMindString(text:string):string; //Ersetzt '-' mit Leerstelle
function CopyAtSpace(text:string;anzahl:integer;var schnittindex:integer):string; //kopiert anzahl chars aus text, trennt aber an leerstelle und nicht mitten im wort
function StringToDoppel(Zahl:string):string;
procedure SetzeZeilenLaenge(var liste:tStringList;laenge:integer); //Setzt die Zeilenlänge aller Strings auf Länge, trennt nur an space


//Mathe-Funktionen
function GetProzent(Prozent,Zahl:integer):integer; //Gibt Zahl zurück die Prozent von Zahl ist
function Summe(Wert:integer):integer; //Implementierung des Summenzeichens




//////////////////
implementation //
////////////////

procedure SetzeZeilenLaenge(var liste:TStringList;laenge:integer); //Setzt die Zeilenlänge aller Strings auf Länge, trennt nur an space
var
  i,j : integer;
  zeile : string;
  laenge2 : integer;
  liste2 : TStringList;
begin
  liste2 := TStringList.create;
  for i := 0 to liste.count - 1 do
  begin
    zeile := liste[i];
    while length(zeile) > laenge do
    begin
      laenge2 := laenge;
      while zeile[laenge2] <> ' ' do
      begin
        dec(laenge2);
        if laenge2 < 1 then break;
      end;
      liste2.add(copy(zeile,1,laenge2));
      Delete(Zeile,1,laenge2);
    end;
    liste2.Add(zeile);
  end;
  liste.Free;
  liste := liste2;
end;

function StringToDoppel(Zahl:string):string;
var
  temp : integer;
begin
  temp := strtoint(zahl);
  if temp < 10 then
    result := '0' + inttostr(temp)
  else
    result := inttostr(temp);
end;

function CopyAtSpace(text:string;anzahl:integer;var schnittindex:integer):string; //kopiert anzahl chars aus text, trennt aber an leerstelle und nicht mitten im wort
var
  i : integer;
begin
  i := anzahl;
  while true do
  begin
    if text[i] = ' ' then
    begin
      schnittindex := i;
      result := copy(text,1,i);
      break;
    end;

    dec(i);
    if i = 1 then
    begin
      result := copy(text,1,anzahl);
      schnittindex := anzahl;
      break;
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

function DeleteMindString(text:string):string;
begin
  result := StringReplace(text,'-',' ',[rfReplaceAll]);
end;

function GetProzent(Prozent,Zahl:integer):integer; //wieviel ist "Prozent" von "Zahl" ?
begin
  result := round((Zahl/100) * Prozent);
end;

function CenterString(text:string;MaxLength:integer):string;
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

function MakeStringLeft(text:string;laenge:integer):string;
begin
  while length(text) < laenge do
  begin
    text := text + ' ';
  end;
  if length(text) > laenge then text := copy(text,1,laenge);
  result := text;
end;

function MakeStringRight(text:string;laenge:integer):string;
begin
  while length(text) < laenge do
  begin
    text := ' ' + text;
  end;
  if length(text) > laenge then text := copy(text,1,laenge);
  result := text;
end;


end.
