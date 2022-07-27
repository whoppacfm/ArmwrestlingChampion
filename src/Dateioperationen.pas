{
  Dateioperationen
  ----------------
  Stellt vorhandene Filehandling - Funktionen in vereinfachter Form und
  erweiterter Funktionalität zur Verfügung

  Autor: Christian Merz
  (c) 2004 Prof. A. Krauth Apparatebau GmbH & Co. KG


  Funktionalität:
  ---------------

  ACHTUNG:
  Für KopiereVerzeichnis, KopiereDateiP und KopiereListeP muss die globale Variable "Filemode"
  aus der Unit "System" zeitweise auf "fmOpenRead" gestellt werden. Nach der Kopieraktion
  muss sie wieder auf "fmOpenReadWrite" zurückgestellt werden.


  FindeDateien:       	Sucht Dateien eines bestimmten Typs in einem Verzeichnis
  											ohne Unterverzeichnisse und speichert die Ergebnisse(Dateinamen+Endung,
                        keine Verzeichnisse) in einer TStringList.

  FindeDateienSub:			Sucht Dateien in einem Verzeichnis inklusive Unterverzeichnisse und
  											speichert die vollständigen Dateinamen mit Pfadangabe in einer TStringList.

  KopiereVerzeichnis: 	Kopiert ein Verzeichnis mit komplettem Inhalt und
  											optionaler Windows-Fortschrittsanzeige

  KopiereVerzeichnisP:  Kopiert ein Verzeichnis und liefert Fortschrittswerte im Bereich 0..100

  KopiereDatei:       	Kopiert eine Datei

  KopiereDateiP:				Kopiert eine Datei und liefert Fortschrittswerte im Bereich 0-100

  KopiereListe:       	Kopiert Dateien aus einer TStringList in ein Zielverzeichnis

  KopiereListeP:      	Kopiert Dateien aus einer TStringList in ein Zielverzeichnis
                      	und liefert Fortschrittswerte im Bereich 0-100

  VerzeichnisGroesse:		Gibt die Speichergröße eines Verzeichnisses mit optionaler
  											Addition der Unterverzeichnisse zurück

  LoescheVerzeichnis: 	Löscht ein Verzeichnis komplett


  History:
  --------

  Beginn: Christian Merz: 23.09.2004 09:14:	KopiereVerzeichnis, FindeDateien, KopiereDatei,
  																					KopiereListe, KopiereDateiP, KopiereListeP

  Update: Christian Merz: 27.09.2004-08:44:	Bugfix: Fortschrittsanzeige KopiereListeP
  Update: Christian Merz: 27.09.2004-12:11: Neu: KopiereVerzeichnisP
  Update: Christian Merz: 27.09.2004-14:05: Neu: VerzeichnisGroesse
  Update: Christian Merz: 27.09.2004-16:08: Bugfix: Fortschrittsanzeige KopiereVerzeichnisP
  Update: Christian Merz: 28.09.2004-14:54: Neu: FindeDateienSub
  Update: Christian Merz: 28.09.2004-15:53: Neu: LoescheVerzeichnis
}

unit Dateioperationen;

interface
uses
	shellapi
  , Windows
  , Messages
  , SysUtils
  , Classes
  , Graphics
  , Controls
  , Forms
  , Dialogs
  , Contnrs
  , ExtCtrls
  , stdctrls
  ,	comctrls
  ;


type
  {TProzent-Prozedur muss bei Nutzung von KopiereDateiP oder KopiereListeP implementiert werden}
	TProzent = procedure(Proz:Double) of object;

  TDateiOperationen = class
  private
    {KopiereVerzeichnisP}
    FSize : Integer;

    {KopiereListeP / KopiereVerzeichnisP}
		FDateiOperationenStatus : Double; //Kopierstatus der aktuellen Datei
    FCompleteFileSize : Integer; //Größe aller zu kopierenden Dateien
    FDateiFileSize : Integer; //Größe der aktuellen Datei
    FProzent : TProzent; //Prozent-Prozedur (Zeiger, der an KopiereListeP übergeben wird,
    										 //wird dieser Prozedur zugewiesen, damit auch aus dem Prozent-Ereignis
                         //von KopiereDateiP das User-Ereignis von KopiereListeP aufgerufen werden
                         //kann)
    procedure KopiereListePProz(Proz:double); //TProzent-Prozedur, die von KopiereListeP und
    																					//KopiereVerzeichnisP an KopiereDateiP übergeben wird
  public
  	constructor Create;

    procedure LoescheVerzeichnis(Verzeichnis: string);
    {
      Funktion: 	Löscht ein Verzeichnis

      Parameter:  Verzeichnis				Verzeichnis, das gelöscht wird
    }

		function VerzeichnisGroesse(dir: string; subdir: Boolean): Longint;
    {
      Funktion: 	Gibt die Speichergröße eines Verzeichnisses zurück

      Parameter:  dir   						Verzeichnis
      						subdir            Speicherplatz der Unterverzeichnisse aufaddieren
    }

    procedure KopiereVerzeichnis(VonVerz,NachVerz:string;HandleException:Boolean;ProgressBar:Boolean);
    {
      Funktion: 	Kopiert ein Verzeichnis mit komplettem Inhalt und optionaler Windows-Fortschrittsanzeige

      Parameter:  VonVerz 					Quellverzeichnis
                  NachVerz					Zielverzeichnis
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben
                  ProgressBar				Windows-Fortschrittsanzeige anzeigen oder nicht
    }

    procedure KopiereVerzeichnisP(VonVerz,NachVerz:string;Ask:Boolean;Overwrite:Boolean;HandleException:Boolean;Prozent:TProzent);
    {
      Funktion: 	Kopiert ein Verzeichnis mit komplettem Inhalt und informiert über den Fortschritt

      Parameter:  VonVerz 					Quellverzeichnis
                  NachVerz					Zielverzeichnis
                  Ask								Wenn Zieldatei existiert wird nachgefragt, ob überschrieben werden soll
                  Overwrite					Wenn Ask = False und Overwrite = True: Datei wird ohne Nachfrage überschrieben
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben
                  Prozent						Es muss eine TProzent - Prozedur implementiert werden, von der aus eine Fortschrittsanzeige gesteuert wird.
                  									Es wird ein Prozentstand übergeben, der im Bereich von 0-100 liegt.
    }

    procedure FindeDateien(Verzeichnis:string;Erweiterung:string;var Liste:TStringList;HandleException:Boolean);
    {
      Funktion:		Sucht Dateien eines bestimmten Typs in einem Verzeichnis und
                  speichert die Ergebnisse(Dateinamen+Endung, keine Verzeichnisse)
                  in einer TStringList.

      Parameter:	Verzeichnis				In diesem Verzeichnis wird gesucht
                  Erweiterung				Dateiendung, nach der gesucht werden soll z.B. '*.exe'
                  Liste           	StringList, in der die Dateinamen gespeichert werden, ohne Pfadangabe
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben
    }

    procedure FindeDateienSub(const Verzeichnis: string; var Files: TStringList;
    										  const Maske: string = '*.*';  const Unterverzeichnisse: Boolean = False);
	  {
      Funktion:		Sucht Dateien eines bestimmten Typs in einem Verzeichnis inklusive
      						Unterverzeichnisse und speichert die Ergebnisse in einer TStringList.

      Parameter:	Verzeichnis					Verzeichnis, in dem gesucht werden soll
      						Files             	TStringList, in der die Ergebnisse gespeichert werden
                  Maske             	Dateityp, nach dem gesucht werden soll z.B. '*.exe'
                  Unterverzeichnisse  Sollen auch die Unterverzeichnisse durchsucht werden?
    }

    procedure KopiereDateiP(Quelldatei,Zieldatei:string;Ask:Boolean;Overwrite:Boolean;HandleException:Boolean;Prozent:TProzent);
    {
      Funktion: 	Kopiert eine Datei und liefert Fortschrittswerte im Bereich 0-100

      Parameter:  Quelldatei 				Zu kopierende Datei mit Verzeichnis
                  Zieldatei					Zielverzeichnis der zu kopierenden Datei + Dateiname
                  Ask								Wenn Zieldatei existiert wird nachgefragt, ob überschrieben werden soll
                  Overwrite					Wenn Ask = False und Overwrite = True: Datei wird ohne Nachfrage überschrieben
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben
                  Prozent						Es muss eine TProzent - Prozedur implementiert werden, von der aus eine Fortschrittsanzeige gesteuert wird.
                  									Es wird ein Prozentstand übergeben, der darauf basiert dass der Maximalwert der Anzeige = 100 ist.
    }

    procedure KopiereListeP(Quelle,Ziel:string;Liste:TStringList;Ask:Boolean;Overwrite:boolean;HandleException:Boolean;Prozent:TProzent);
    {
      Funktion: 	Kopiert Dateiliste und liefert Fortschrittswerte im Bereich 0-100

      Parameter:  Quelle		 				Quellverzeichnis
                  Ziel							Zielverzeichnis
                  Liste							TStringlist mit den Dateinamen (Lässt sich mit "FindeDatien" füllen)
                  Ask								Wenn Zieldatei existiert wird nachgefragt, ob überschrieben werden soll
                  Overwrite					Wenn Ask = False und Overwrite = True: Datei wird ohne Nachfrage überschrieben
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben
                  Prozent						TProzent - Prozedur muss implementiert werden, von der aus die Progressbar gesteuert wird.
                  									Es wird ein Prozentstand übergeben, der darauf basiert dass das Max-Value der Anzeige = 100 ist.
    }

    procedure KopiereListe(Quelle,Ziel:string;Liste:TStringList;Ask:Boolean;Overwrite:boolean;HandleException:Boolean);
    {

      Funktion:		Kopiert Dateien aus einer TStringList in ein Zielverzeichnis

      Parameter:	Quelle						Quellverzeichnis
                  Ziel        			Zielverzeichniss
                  Liste       			StringList die zu kopierende Dateinamen enthält
                  Ask      					Wenn eine Datei im Zielverzeichnis existiert wird bei true nachgefragt,
                                    ob überschrieben werden soll
                  Overwrite   			Wird nur beachtet, wenn Ask = False.
                                    Bei Overwrite = True werden bestehende Dateien überschrieben
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben

    }

    procedure KopiereDatei(Quelle,Ziel,Datei:string;Ask:Boolean;Overwrite:Boolean;HandleException:Boolean);
    {

      Funktion:		Kopiert eine einzelne Datei

      Parameter:	Quelle						Quellverzeichnis
                  Ziel							Zielverzeichnis
                  Datei							Dateiname
                  Ask      					Wenn eine Datei im Zielverzeichnis existiert wird bei true nachgefragt,
                                    ob überschrieben werden soll
                  Overwrite   			Wird nur beachtet, wenn Ask = False.
                                    Bei Overwrite = True werden bestehende Dateien überschrieben
                  HandleException   Bei True wird eine eventuell auftretende
                                    Exception behandelt und eine Meldung ausgegeben
    }

  end;

implementation

uses StrUtils;

resourcestring
	DOFehlerBeimLoeschen = 'Fehler beim Löschen';
  DOFehler = 'Fehler:';
  DOVerzErw = 'Verzeichnis oder Erweiterung ungültig';
  DOSollDatei = 'Soll die Datei';
  DOUeberschreiben  = 'überschrieben werden?';
  DOQuelleZiel = 'Quelle oder Ziel ungültig';

constructor TDateioperationen.Create;
begin
	FDateioperationenStatus := 0;
	FCompleteFileSize := 0;
  FDateiFileSize := 0;
  FSize := 0;
end;

procedure TDateioperationen.LoescheVerzeichnis(Verzeichnis: string);
var
	fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do begin
    wFunc := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(Verzeichnis+#0);
  end;
  if (SHFileOperation(fos)<>0) then
    MessageBox(0, PChar(DOFehlerBeimLoeschen), nil, MB_ICONERROR);
end;

procedure TDateioperationen.KopiereVerzeichnisP(VonVerz,NachVerz:string;Ask:Boolean;Overwrite:boolean;HandleException:Boolean;Prozent:TProzent);
var
	SearchRec : TSearchRec;
	VerzeichnisListe : TStringList;
  Size : integer;
  Files : integer;
  FSrc : string;
  FDes : string;
  ok : boolean;
begin
	FProzent := Prozent;
  try
    if FSize = 0 then
    begin
      FSize := VerzeichnisGroesse(VonVerz, true);
      FCompleteFileSize := FSize;
    end;
    if VonVerz[Length(VonVerz)] <> '\' then VonVerz := VonVerz + '\';
    if NachVerz[Length(NachVerz)] <> '\' then NachVerz := NachVerz + '\';
    Files := FindFirst(VonVerz + '*.*', faAnyFile, SearchRec);

    while Files = 0 do
    begin
      if SearchRec.Attr <> faDirectory then
      begin
        FSrc := VonVerz + SearchRec.Name;
        FDes := NachVerz + SearchRec.Name;

        //Prozent((100/FSize)*SearchRec.Size);
        if not DirectoryExists(nachverz) then
        begin
        	if not CreateDir(nachverz) then ShowMessage(DOFehler + ' ' + NachVerz);
        end;
        FDateiFileSize := SearchRec.Size;
      	KopiereDateiP(PChar(FSrc),PChar(FDes),Ask,Overwrite,HandleException,KopiereListePProz);
      end else
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          ok := CreateDir(NachVerz + '\' + SearchRec.Name);
          if not ok then ShowMessage(DOFehler+' '+SearchRec.Name)
          else KopiereVerzeichnisP(VonVerz+SearchRec.Name, NachVerz+SearchRec.Name,Ask,Overwrite,HandleException,Prozent);
        end;
      end;
      Files := FindNext(SearchRec);
    	Application.ProcessMessages;
    end;
    FindClose(SearchRec);
    //if (100/Size)*SearchRec.Size >= 100 then FSize := 0;
	except
    on e:Exception do
    begin
      if handleexception = true then
      begin
      	Application.ShowException(e);
      end else
      begin
        raise;
      end;
		end;
  end;
end;

function TDateioperationen.VerzeichnisGroesse(dir: string; subdir: Boolean): Longint;
var
  rec: TSearchRec;
  found: Integer;
begin
  Result := 0;
  if dir[Length(dir)] <> '\' then dir := dir + '\';
  found := FindFirst(dir + '*.*', faAnyFile, rec);
  while found = 0 do
  begin
    Inc(Result, rec.Size);
    if (rec.Attr and faDirectory > 0) and (rec.Name[1] <> '.') and (subdir = True) then
      Inc(Result, VerzeichnisGroesse(dir + rec.Name, True));
    found := FindNext(rec);
  end;
  FindClose(rec);
end;

procedure TDateioperationen.KopiereVerzeichnis(VonVerz, NachVerz : string; HandleException: Boolean;ProgressBar:Boolean);
var
 FOS : tSHFileOpStruct;
begin
  //FileMode := fmOpenRead;
  try
    VonVerz := Trim(VonVerz);
    if VonVerz[Length(VonVerz)] <> '\' then VonVerz := VonVerz + '\';
    NachVerz := Trim(NachVerz);
    with FOS do
    begin
      Wnd := 0;
      wFunc := FO_COPY;
      pFrom := PChar(VonVerz + '*.*' + #0);
      pTo := PChar(NachVerz + #0);
      fFlags := FOF_ALLOWUNDO or FOF_MULTIDESTFILES or FOF_NOCONFIRMMKDIR;
    end;
    if not ProgressBar then
    	FOS.fFlags := FOF_ALLOWUNDO or FOF_MULTIDESTFILES or FOF_NOCONFIRMMKDIR or FOF_SILENT;
    SHFileOperation(FOS);
  except
  	on e:Exception do
    begin
			//FileMode := fmOpenReadWrite;
      if HandleException then
      begin
         Application.ShowException(e);
      end else
      begin
        raise;
      end;
    end;
  end;
	//FileMode := fmOpenReadWrite;
end;

procedure TDateioperationen.FindeDateien(Verzeichnis:string;Erweiterung:string;var Liste:TStringList;HandleException: Boolean);
var
	SearchRec: TSearchRec;
begin
  try
    if (Verzeichnis <> '') and (Erweiterung <> '') then
    begin
      if Verzeichnis[Length(Verzeichnis)] <> '\' then Verzeichnis := Verzeichnis + '\';
      if FindFirst(Verzeichnis + Erweiterung, faAnyFile-faVolumeID-faReadOnly,SearchRec) = 0 then
      begin
        try
          repeat
            Liste.Add(SearchRec.Name);
          until FindNext(SearchRec) <> 0;
        finally
          SysUtils.FindClose(SearchRec);
        end;
      end;
    end else
    begin
      ShowMessage(DOVerzErw);
    end;
  except
  	on e:Exception do
    begin
      if HandleException then
      begin
         Application.ShowException(e);
      end else
      begin
        raise;
      end;
    end;
  end;
end;

procedure TDateioperationen.FindeDateienSub(const Verzeichnis: string; var Files: TStringList;
  const Maske: string = '*.*';  const Unterverzeichnisse: Boolean = False);
  //Hilfsfunktion, um Schrägstriche hinzuzfügen, wenn nötig
  function SlashSep(const Path, S: string): string;
  begin
    if AnsiLastChar(Path)^ <> '\' then  Result := Path + '\' + S
    else Result := Path + S;
  end;

var SearchRec: TSearchRec;
    nStatus: Integer;
begin
  //Zuerst alle Dateien im aktuelle Verzeichnis finden
  if FindFirst(SlashSep(Verzeichnis, Maske), faAnyFile-faDirectory-faVolumeID,SearchRec) = 0 then
  begin
    try
      repeat
        Files.Add(SlashSep(Verzeichnis, SearchRec.Name));
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;

  //Als nächstes nach Unterverzeichnissen suchen und, wenn benötigt, durchsuchen
  if Unterverzeichnisse then
  begin
    if FindFirst(SlashSep(Verzeichnis,'*.*'), faAnyFile,  SearchRec) = 0 then
    begin
      try
        repeat
          //Wenn es ein Verzeichnis ist, Rekursion verwenden
          if (SearchRec.Attr and faDirectory) <> 0 then
          begin
            if ((SearchRec.Name <> '.') and (SearchRec.Name <> '..')) then
              FindeDateienSub(SlashSep(Verzeichnis, SearchRec.Name), Files, Maske, Unterverzeichnisse);
          end;
        until FindNext(SearchRec) <> 0;
      finally
        SysUtils.FindClose(SearchRec);
      end;
    end;
  end;
end;


procedure TDateioperationen.KopiereListe(Quelle,Ziel:string;Liste:TStringList; Ask:Boolean; Overwrite:Boolean;HandleException: Boolean);
var
	i:Integer;
begin
  try
    if (Quelle <> '') and (Ziel <> '') then
    begin
      if Ziel[Length(Ziel)] <> '\' then Ziel := Ziel + '\';
      if Quelle[Length(Ziel)] <> '\' then Quelle := Quelle + '\';
      for i := 0 to Liste.Count - 1 do
      begin
        if Ask then
        begin
          if fileexists(Ziel + Liste[i]) then
          begin
            if MessageDlg(DOSollDatei +' '+ Ziel + Liste[i] +' '+DOUeberschreiben, mtConfirmation, [mbyes,mbno],0)=mryes then
            begin
              CopyFile(PChar(Quelle + Liste[i]), PChar(Ziel + Liste[i]),false);
            end;
          end else
          begin
            CopyFile(PChar(Quelle + Liste[i]),PChar(Ziel+Liste[i]),false);
          end;
				end else
        begin
          if Overwrite then
          begin
	        	CopyFile(PChar(Quelle + Liste[i]),PChar(Ziel+Liste[i]),false);
					end else
          begin
          	if not fileexists(Ziel + Liste[i]) then
	            CopyFile(PChar(Quelle + Liste[i]),PChar(Ziel+Liste[i]),false);
          end;
        end;
      end;
		end else
    begin
    	ShowMessage(DOQuelleZiel);
    end;
  except
  	on e:Exception do
    begin
      if HandleException then
      begin
         Application.ShowException(e);
      end else
      begin
        raise;
      end;
    end;
  end;
end;

procedure TDateioperationen.KopiereDatei(Quelle,Ziel,Datei:string; Ask:Boolean; Overwrite:Boolean;HandleException: Boolean);
begin
	try
  	if Ziel[Length(Ziel)] <> '\' then Ziel := Ziel + '\';
		if Quelle[Length(Ziel)] <> '\' then Quelle := Quelle + '\';
    if Ask then
    begin
      if fileexists(Ziel+Datei) then
      begin
        if MessageDlg(DOSollDatei +' '+ Ziel+Datei + ' '+DOUeberschreiben, mtConfirmation, [mbyes,mbno],0)=mryes then
        begin
          CopyFile(PChar(Quelle+Datei), PChar(Ziel+Datei),false);
        end;
      end else
      begin
        CopyFile(PChar(Quelle+Datei), PChar(Ziel+Datei),false);
      end;
    end else
    begin
    	if Overwrite then
      begin
      	CopyFile(PChar(Quelle+Datei), PChar(Ziel+Datei),false);
      end else
      begin
      	if not fileexists(Ziel+Datei) then
        	CopyFile(PChar(Quelle+Datei), PChar(Ziel+Datei),false);
      end;
    end;
  except
  	on e:Exception do
    begin
      if HandleException then
      begin
         Application.ShowException(e);
      end else
      begin
        raise;
      end;
    end;
  end;
end;

procedure TDateioperationen.KopiereDateiP(Quelldatei, Zieldatei: string; Ask:Boolean; Overwrite:Boolean; HandleException:Boolean; Prozent:TProzent);
var
  FromF, ToF: file of byte;
  Buffer: array[0..4096] of char;
  NumRead: integer;
  FileLength: longint;
  Copied:Longint;
  doit:Boolean;
begin
  //FileMode := fmOpenRead;
	doit := true;
  if Ask then
  begin
    if fileexists(Zieldatei) then
    begin
      if MessageDlg(DOSollDatei +' '+ Zieldatei + ' '+DOUeberschreiben, mtConfirmation, [mbyes,mbno],0)=mrno then
      begin
      	doit := False;
      end;
    end;
  end else
  begin
  	if (fileexists(Zieldatei)) and (not overwrite) then
    begin
    	doit := False;
    end;
  end;

	try
    if doit then
    begin
      AssignFile(FromF, Quelldatei);
      reset(FromF);
      AssignFile(ToF, Zieldatei);
      rewrite(ToF);
      FileLength := FileSize(FromF);
      Copied:=0;
      while Copied < FileLength do
      begin
        BlockRead(FromF, Buffer, SizeOf(Buffer), NumRead);
        BlockWrite(ToF, Buffer, NumRead);
        Copied := Copied + NumRead;
        if FileLength > 0 then
	        Prozent((100/FileLength) * Copied);
        Application.ProcessMessages;
      end;
      CloseFile(FromF);
      CloseFile(ToF);
    end;
	except
  	on e:Exception do
    begin
			//FileMode := fmOpenReadWrite;
  		if HandleException then
      begin
      	Application.ShowException(e);
      end else
      begin
    		raise;
      end;
    end;
  end;
	//FileMode := fmOpenReadWrite;
end;

procedure TDateioperationen.KopiereListePProz(Proz:Double);
begin
	if FCompleteFileSize > 0 then
		FDateioperationenstatus := (((100/FCompleteFileSize)*FDateiFileSize)*Proz)/100;
  FProzent(FDateioperationenstatus);
  Application.ProcessMessages;
end;

procedure TDateioperationen.KopiereListeP(Quelle,Ziel:string;Liste:TStringList;Ask:Boolean;Overwrite:Boolean;HandleException:Boolean;Prozent:TProzent);
var
	i:Integer;
  Datei : File;
begin
  //FileMode := fmOpenRead;
	FProzent := Prozent;
  try
    if (Quelle <> '') and (Ziel <> '') then
    begin
      //Verzeichnisse vervollständigen
      if Ziel[Length(Ziel)] <> '\' then Ziel := Ziel + '\';
      if Quelle[Length(Ziel)] <> '\' then Quelle := Quelle + '\';

      //Speichergröße der zu kopierenden Dateien für Progressbar berechnen
      for i := 0 to liste.Count - 1 do
      begin
				AssignFile(Datei,PChar(Quelle + liste[i]));
        Reset(Datei,1);
        FCompleteFileSize := FCompleteFileSize + filesize(Datei);
				CloseFile(Datei);
      end;

      //Dateien kopieren
      for i := 0 to Liste.Count - 1 do
      begin
        //Größe der aktuellen Datei erfragen
        assignfile(Datei,PChar(quelle+liste[i]));
        reset(Datei,1);
        FDateiFileSize := FileSize(Datei);
        closefile(Datei);

        if Ask then
        begin
          if fileexists(Ziel + Liste[i]) then
          begin
            if MessageDlg(DOSollDatei +' '+ Ziel + Liste[i] +' '+DOUeberschreiben, mtConfirmation, [mbyes,mbno],0)=mryes then
            begin
              KopiereDateiP(PChar(Quelle + Liste[i]), PChar(Ziel + Liste[i]), Ask,Overwrite,HandleException,KopiereListePProz);
            end;
          end else
          begin
            KopiereDateiP(PChar(Quelle + Liste[i]), PChar(Ziel + Liste[i]), Ask,Overwrite,HandleException,KopiereListePProz);
          end;
        end else
        begin
          if Overwrite then
          begin
            KopiereDateiP(PChar(Quelle + Liste[i]), PChar(Ziel + Liste[i]), Ask,Overwrite,HandleException,KopiereListePProz);
          end else
          begin
            if not fileexists(Ziel + Liste[i]) then
              KopiereDateiP(PChar(Quelle + Liste[i]), PChar(Ziel + Liste[i]), Ask,Overwrite,HandleException,KopiereListePProz);
          end;
        end;
      end;
    end else
    begin
      ShowMessage(DOQuelleZiel);
    end;
  except
    on e:Exception do
    begin
			//FileMode := fmOpenReadWrite;
      if HandleException then
      begin
         Application.ShowException(e);
      end else
      begin
        raise;
      end;
    end;
  end;
	//FileMode := fmOpenReadWrite;
end;

end.
