unit unitFrmAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TfrmAbout = class(TForm)
    imgME: TImage;
    lblProg: TLabel;
    lblDesigner: TLabel;
    lblDate: TLabel;
    lblDateUpdate: TLabel;
    lblVersion: TLabel;
    lblLink: TLabel;
    btnClose: TSpeedButton;
    procedure lblLinkClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lblLinkMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblLinkMouseLeave(Sender: TObject);
    procedure lblLinkMouseEnter(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  lblLink.Font.Color := clBlue;
  lblLink.Font.Style := [fsBold, fsUnderline];
  Cursor := crDefault;
end;

procedure TfrmAbout.lblLinkClick(Sender: TObject);
begin
  WinExec('explorer.exe http://systemhalt.org', SW_SHOWMAXIMIZED);
end;

procedure TfrmAbout.lblLinkMouseEnter(Sender: TObject);
begin
  lblLink.Font.Color := clRed;
  lblLink.Font.Style := [fsBold];
  Cursor := crHandPoint;
end;

procedure TfrmAbout.lblLinkMouseLeave(Sender: TObject);
begin
  lblLink.Font.Color := clBlue;
  lblLink.Font.Style := [fsBold, fsUnderline];
  Cursor := crDefault;
end;

procedure TfrmAbout.lblLinkMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  lblLink.Font.Color := clRed;
  lblLink.Font.Style := [fsBold];
  Cursor := crHandPoint;
end;

end.
