{
  Ver - und Entschlüsselung beliebiger Dateien

  Projekt:  Allgemein
  Unit:     FileCrypt.pas
  Stand:    31.Januar 2005
  (c) Christian Merz 2005
}


unit FileCrypt;

interface

uses
	classes
  , sysutils
  , Dateioperationen
  ;


type
	TFileCrypt = class
  	procedure CryptFile(Source:TFilename; Dest:TFilename);
    procedure DeCryptFile(Source:TFilename; Dest:TFilename);
    procedure CryptDir(Dir:string);
    procedure DecryptDir(Dir:string);
  end;

implementation

procedure TFileCrypt.CryptDir(Dir:string);
var
	DatOp : TDateioperationen;
  Liste : TStringList;
  i : Integer;
begin
	Liste := TStringList.Create;
	DatOp.FindeDateien(Dir,'*.*',Liste,false);
  try
  	for	i := 0 to Liste.Count - 1 do
    begin
    	if dir[Length(dir)]<> '\' then dir := dir + '\';
      if (Liste[i] <> '.') and (Liste[i] <> '..') then
      begin
    		CryptFile(Dir+Liste[i],Dir+Liste[i]);
      end;
    end;
  finally
  	freeandnil(Liste);
  end;
end;

procedure TFileCrypt.DecryptDir(Dir:string);
var
	DatOp : TDateioperationen;
  Liste : TStringList;
  i : Integer;
begin
	Liste := TStringList.Create;
	DatOp.FindeDateien(Dir,'*.*',Liste,false);
  try
  	for	i := 0 to Liste.Count - 1 do
    begin
	   	if dir[Length(dir)] <> '\' then dir := dir + '\';
      if (Liste[i] <> '.') and (Liste[i] <> '..') then
      begin
      	DeCryptFile(Dir+Liste[i],Dir+Liste[i]);
      end;
    end;
  finally
  	freeandnil(Liste);
  end;
end;

procedure TFileCrypt.CryptFile(Source:TFilename;Dest:TFilename);
var
	Fromf, Tof:File;
  i : longint;
  Buf : array[1..1024] of char;
  numread,numwritten : longInt;
begin

  AssignFile(FromF,Source);
  AssignFile(ToF,Dest);
	reset(Fromf,1);
  if not FileExists(Dest) then
  begin
		rewrite(ToF,1)
  end else
  begin
		reset(ToF,1)
  end;
  try
    repeat
      BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
      for i := 1 to SizeOf(buf) do
      begin
        buf[i] := succ(buf[i]);
      end;
      BlockWrite(ToF, Buf, NumRead, NumWritten);
    until (NumRead = 0) or (NumWritten <> NumRead);
	finally
    CloseFile(FromF);
    CloseFile(ToF);
  end;
end;

procedure TFileCrypt.DeCryptFile(Source:TFilename; Dest:TFilename);
var
	Fromf, Tof:File;
  i : longint;
  Buf : array[1..1024] of char;
  numread,numwritten : longInt;
  ugh:integer;
begin
  AssignFile(FromF,Source);
  AssignFile(ToF,Dest);
	reset(Fromf,1);
  if not FileExists(Dest) then
  begin
		rewrite(ToF,1)
  end else
  begin
		reset(ToF,1)
  end;
  try
    repeat
      BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
      for i := 1 to SizeOf(buf) do
      begin
        buf[i] := pred(buf[i]);
      end;
      BlockWrite(ToF, Buf, NumRead, NumWritten);
    until (NumRead = 0) or (NumWritten <> NumRead);
	finally
    CloseFile(FromF);
    CloseFile(ToF);
  end;
end;


end.
