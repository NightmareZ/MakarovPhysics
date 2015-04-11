unit unitFrmOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Fields;

type
  TfrmOptions = class(TForm)
    groupForceLine: TGroupBox;
    cbMakeLines: TCheckBox;
    tbLinesPerQ: TTrackBar;
    lblLinesPerQ: TLabel;
    lblLinesPerQCount: TLabel;
    groupQ: TGroupBox;
    lblQCount: TLabel;
    lblQCountValue: TLabel;
    tbQCount: TTrackBar;
    rbSignChange: TRadioButton;
    rbSingNonChange: TRadioButton;
    btnCalc: TButton;
    groupDistance: TGroupBox;
    tbDistance: TTrackBar;
    pbCalc: TProgressBar;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tbLinesPerQChange(Sender: TObject);
    procedure tbQCountChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

uses unitFrmMain;

{$R *.dfm}

procedure TfrmOptions.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if Visible then Resize := False;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmLibMain.Close;
end;

procedure TfrmOptions.tbLinesPerQChange(Sender: TObject);
begin
  lblLinesPerQCount.Caption := IntToStr(tbLinesPerQ.Position);
end;

procedure TfrmOptions.tbQCountChange(Sender: TObject);
begin
  lblQCountValue.Caption := IntToStr(tbQCount.Position);
end;

end.
