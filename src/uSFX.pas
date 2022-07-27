unit uSFX;

{
  Vereinfachter Zugriff auf die Funktionen der Freeware AUDIERE.DLL SFX-Library
  (c) Christian Merz 2005
}


interface

uses
  Windows
  , Classes
  , math
  , SysUtils
  , audiere
  , dialogs

  ;

type

  TMuckeBox = class
  private
    fDevice : TAdrAudioDevice;
    fSound  : TAdrSoundEffect;
    fStream : TAdrOutputStream;
    fsample : TAdrSampleSource;

    fMusicVolume : single;
    fEffectVolume : single;

    procedure SetMusicVolume(volume:single);
    function GetMusicVolume:single;
    procedure SetEffectVolume(volume:single);
    function GetEffectVolume:single;
  public
    procedure PlayEffect(filename:string);
    procedure PlayMusic(filename:string);

    property MusicVolume : single read GetMusicVolume write SetMusicVolume;
    property EffectVolume : single read GetEffectVolume write SetEffectVolume;

    constructor create;
    destructor destroy;override;
  end;


implementation


constructor TMuckeBox.create;
begin
  inherited create;                          
  AdrLoadDLL;
  fdevice := AdrOpenDevice('','');
  fdevice.Ref;

  fMusicVolume := 0.4; // 0.0 bis 1.0
  fEffectVolume := 0.8; // 0.0 bis 1.0
end;

destructor TMuckeBox.destroy;
begin
  if fstream <> nil then fstream.UnRef;
  if fsound <> nil then fsound.UnRef;
  if fsample <> nil then fsample.unref;
  fdevice.UnRef;
  inherited destroy;
end;

procedure TMuckeBox.PlayEffect(filename:string);
begin
  try
    if fsound <> nil then
    begin
      fsound.Stop;
      fsound.UnRef;
      fsample.UnRef;
    end;
    fsample := AdrOpenSampleSource(PChar(filename), FF_OGG);
    fsample.Ref;
    fsound := AdrOpenSoundEffect(fDevice,fsample,Adr_SoundEffectType_Single);
    fsound.Ref;
    fSound.SetVolume(fEffectVolume);
    fsound.Play;
  except
    on e:exception do
    begin
      //showmessage('Error: ' + filename + ' ' + e.message );
    end;
  end;
end;

procedure TMuckeBox.PlayMusic(filename:string);
begin
  try
    if fstream <> nil then
    begin
      if fstream.IsPlaying then
      begin
        fstream.Stop;
        fstream.UnRef;
      end;
    end;
    fsample := AdrOpenSampleSource(PChar(filename), FF_OGG);
    fsample.Ref;
    fstream := AdrOpenSound(fdevice, fsample, true);
    fstream.Ref;
    fstream.SetRepeat(true);
    fstream.SetVolume(fMusicVolume);
    fstream.Play;
  except
    on e:exception do
    begin
      showmessage('Error: ' + filename + ' ' + e.message );
    end;
  end;
end;

procedure TMuckeBox.SetMusicVolume(volume:single);
begin
  fMusicVolume := volume;
  if fstream <> nil then fstream.SetVolume(volume);
end;

function TMuckeBox.GetMusicVolume:single;
begin
  result := fMusicVolume;
end;

procedure TMuckeBox.SetEffectVolume(volume:single);
begin
  fEffectVolume := volume;
  if fsound <> nil then fsound.SetVolume(volume);
end;

function TMuckeBox.GetEffectVolume:single;
begin
  result := fEffectVolume;
end;



end.
