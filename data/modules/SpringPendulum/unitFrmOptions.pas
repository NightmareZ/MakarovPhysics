unit unitFrmOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus;

type
  TfrmOptions = class(TForm)
    txtLength: TLabeledEdit;
    txtDX: TLabeledEdit;
    txtMass: TLabeledEdit;
    txtK: TLabeledEdit;
    txtG: TLabeledEdit;
    btnStart: TButton;
    btnStop: TButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    imgT: TImage;
    txtT: TEdit;
    txtResult: TMemo;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    preL: ShortString;
    function TestDelimiters(s: String): String;
  end;

var
  frmOptions: TfrmOptions;

procedure About(prog, date, dateupdate, version: ShortString; parent: TForm); external 'data\engine\MakarovTools.dll';

implementation

uses unitFrmLibMain, unitFrmGraphics;

{$R *.dfm}

function TfrmOptions.TestDelimiters(s: String): String;
var
  i: Integer;
begin
  Result := '';
  if Length(s) > 0 then
    for i := 1 to Length(s) do
      if (s[i] <> '.') and (s[i] <> ',') then
        Result := Result + s[i]
      else
        Result := Result + DecimalSeparator;
end;

procedure TfrmOptions.N7Click(Sender: TObject);
begin
  frmLibMain.Close;
end;

procedure TfrmOptions.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if Visible then Resize := False;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmLibMain.Close;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
begin
  txtG.Text:=FloatToStr(9.81);
end;

procedure TfrmOptions.btnStartClick(Sender: TObject);
var
  i:Integer;
begin
  if frmLibMain.IsRun then
    btnStop.Click;

  txtLength.Text := TestDelimiters(txtLength.Text);
  txtDX.Text := TestDelimiters(txtDX.Text);
  txtMass.Text := TestDelimiters(txtMass.Text);
  txtK.Text := TestDelimiters(txtK.Text);
  txtG.Text := TestDelimiters(txtG.Text);

  try
    with frmLibMain do
      if (StrToFloat(txtLength.Text) >0 ) and
         (StrToFloat(txtDX.Text) > 0) and
         (StrToFloat(txtMass.Text) > 0) and
         (StrToFloat(txtK.Text) > 0) and
         (StrToFloat(txtG.Text) > 0) then
      begin
        defaultLen := StrToFloat(txtLength.Text);
        S := StrToFloat(txtDX.Text);
        m := StrToFloat(txtMass.Text);
        k := StrToFloat(txtK.Text);
        g := StrToFloat(txtG.Text);
        Period := 0;
        Freq := 0;
        currPeriod := 0;
        preL := txtDX.Text;
        for i := 1 to 200 do
        begin
          SArray[i] := S;
          VArray[i] := 0;
          AArray[i] := 0;
        end;
        Speed := 0;
        preSpeed := 0;
        txtT.Text := FloatToStrF(2 * pi * sqrt(m / k), ffFixed, 10, 5);
        IsRun := True;
      end;
  except
    MessageBox(Handle, 'Введы неправильные значения',
               'Ошибка', MB_ICONERROR);
  end;
end;

procedure TfrmOptions.btnStopClick(Sender: TObject);
begin
  frmLibMain.IsRun := False;
  txtDX.Text := preL;
  frmGraphics.chartDX.Title.Text.Text := 'Смещение (м)';
  frmGraphics.chartSpeed.Title.Text.Text := 'Скорость (м/c)';
  frmGraphics.chartAccel.Title.Text.Text := 'Ускорение (м/c^2)';
end;

procedure TfrmOptions.N2Click(Sender: TObject);
begin
  btnStart.Click;
end;

procedure TfrmOptions.N3Click(Sender: TObject);
begin
  btnStop.Click;
end;

procedure TfrmOptions.N5Click(Sender: TObject);
begin
  About('Пружинный маятник',
    'Дата создания: 25 декабря 2004 года',
    'Обновление: 22 декабря 2006 года',
    'Версия: 1.3',
    frmLibMain);
end;

end.
