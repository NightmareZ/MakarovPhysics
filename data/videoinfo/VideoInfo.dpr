program VideoInfo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmVideoInfo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmVideoInfo, frmVideoInfo);
  Application.Run;
end.
