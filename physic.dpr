program physic;

uses
  Forms,
  unitMain in 'unitMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Комплекс Физических Программ';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
