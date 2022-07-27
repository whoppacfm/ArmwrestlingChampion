unit uLog;


{
  Logging-Unit für Debug-Tätigkeiten
  (c) Christian Merz 2005
}

interface

uses
  classes
  ,sysutils
  , Forms

  ;


type
  TLog = class
    LogFile : TStringList;
    procedure Add(Text:string);
    constructor create;
    destructor destroy;
  end;


implementation

procedure TLog.Add(Text:string);
begin
  LogFile.Add(Text);
  LogFile.SaveToFile(extractFilePath(application.exename) + 'Log.txt');
end;

constructor TLog.create;
begin
  LogFile := TStringList.create;
end;

destructor TLog.destroy;
begin
  freeandnil(LogFile);
end;

end.
