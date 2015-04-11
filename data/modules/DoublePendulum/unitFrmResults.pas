unit unitFrmResults;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmResults = class(TForm)
    txtResults: TMemo;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  frmResults: TfrmResults;

implementation

uses unitFrmMain;

{$R *.dfm}

procedure TfrmResults.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if Visible then Resize := False;
end;

procedure TfrmResults.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmLibMain.Close;
end;

end.
