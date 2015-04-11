unit unitFrmPhaseTraectory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TeEngine, Series, ExtCtrls, TeeProcs, Chart;

type
  TfrmPhaseTraectory = class(TForm)
    chartPhaseTraectory: TChart;
    Series1: TPointSeries;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  frmPhaseTraectory: TfrmPhaseTraectory;

implementation

uses unitFrmLibMain;

{$R *.dfm}

procedure TfrmPhaseTraectory.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if Visible then Resize := False;
end;

procedure TfrmPhaseTraectory.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmLibMain.Close;
end;

end.
