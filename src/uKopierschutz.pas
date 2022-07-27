{
  Kopierschutz

  Projekt:  Allgemein
  Unit:     uKopierschutz.pas
  Stand:    26.Januar 2005              
  (c) Christian Merz 2005

  Routinen zum Schutz von Sharewareprogrammen
	Kunde generiert mit Shareware einen Schlüssel der auf der aktuellen
  Systemkonfiguration basiert. Dieser Schlüssel wird an den Hersteller
  gesendet, der daraus einen Freischaltcode generiert und ihn, nach
  Bezahlung, zum Kunden schickt, der damit die Shareware-Version in eine
  Vollversion verwandeln kann.

  ToDo:
  	- Aufbau der Datei ändern
    - Datei verstecken?, Registry?
    - Fake-Jumps? 

}

unit uKopierschutz;

interface

uses
	JvComponent
  , JvComputerInfo
  , sysutils
  , classes;

type

	TKopierschutz = class
  private
    ComputerInfo: TJvComputerInfo;
    function IsFullVersion : Boolean; //Bei jedem Programmstart prüfen: Vollversion?
    																//Wenn ja: Korrekte Rechnerkonfiguration?
                                    // -> Nein: Sharewareversion starten
		fFullVersion : Boolean;
  public
    property FullVersion : Boolean read fFullVersion;
  	function GenerateKey:string; //Schlüssel aus Rechnerkonfiguration
    function GenerateCode(Key:string):string; //Freischaltcode aus Konfig-Schlüssel
    function Freischalten(Code:string):Boolean; //Software als Vollversion freischalten
    constructor Create;
  end;

const
	cConfigFile = 'config\TConfigMenu.dat';
	c1 = 7;
  c2 = 9;
  c3 = 4;

implementation

constructor TKopierschutz.Create;
begin
	fFullVersion = IsFullVersion;
end;

function TKopierschutz.GenerateCode(Key:string):string;
var
	 i: Integer;
   a: Integer;
begin
	for i := 1 to Length(key) do
  begin
    if Ord(key[i]) < 122-i then
    begin
      key[i] := chr(ord(key[i])+i);
    end else if Ord(key[i]) < 122 then
    begin
			key[i] := chr(Ord(key[i])+1);
    end;
  end;
  key := key + Copy(key,4,2);
  Insert('t',key,Length(key)div 2);
  Insert(IntToStr(c1),key,Length(key)div 2);
  Insert(IntToStr(c2),key,Length(key)div 2);
  Insert(IntToStr(c3),key,Length(key)div 2);
  Result := key;
end;


function TKopierschutz.GenerateKey:string;
var
	Key:string;
  i : Integer;
begin
	ComputerInfo := TJvComputerInfo.Create(nil);
	try
  	with ComputerInfo do
    begin
	    key := key + VersionNumber + Version + RealComputerName + ProductID
      					 + ProductKey + ProductName + Company + Computername + '2A0B0C5D91827364';
    end;

    for i := 1 to length(key) do
    begin
    	if Ord(key[i]) < 245 then
      begin
	    	key[i] := chr(ord(key[i])+5);
  		end;
    end;

    Result := key;
  finally
  	freeandnil(ComputerInfo);
  end;
end;

function TKopierschutz.Freischalten(Code:string):Boolean;
var
	SaveFile : TStringList;
begin
	Result := False;
	SaveFile := TStringList.Create;
  try
    try
      if Code = GenerateCode(GenerateKey) then
      begin
        if FileExists(extractfilepath(Application.exename) + cConfigFile) then
        begin
          DeleteFile(extractfilepath(Application.exename) + cConfigFile);
        end;
        SaveFile.Add('1');
        SaveFile.Add(GenerateKey);
        SaveFile.Add(Code);
        SaveFile.SaveToFile(extractfilepath(Application.exename) + cConfigFile);
        Result := true;
      end;
		except
    	on e:Exception do
      begin
      	ShowMessage('Fehler beim Freischalten der Sharewareversion: '+e.Message);
      end;
    end;
	finally
  	freeandnil(SaveFile);
  end;
end;

function TKopierschutz.IsFullVersion : Boolean;
var
	LoadFile : TStringList;
begin
	Result := False;
  LoadFile := TStringList.Create;
  try
  	try
      if FileExists(extractfilepath(Application.exename) + cConfigFile) then
      begin
        if LoadFile.Count = 3 then
        begin
          LoadFile.LoadFromFile(extractfilepath(Application.exename) + cConfigFile);
          if (LoadFile[1] = GenerateKey) and (LoadFile[2] = GenerateCode(GenerateKey)) then
          begin
            Result = true;
          end;
        end;
      end;
		except
    	on e:Exception do
      begin
      	ShowMessage('Fehler in der Kopierschutzprüfung: '+e.Message);
      end;
    end;
	finally
  	freeandnil(LoadFile);
  end;
end;


end.
