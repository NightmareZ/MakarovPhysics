unit unitFrmOptions;
{
программа: колебания водной поверхности
разработчик: Макаров М.М.
дата создания: 2 марта 2005
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus;

type
  TfrmOptions = class(TForm)
    txtVyaz: TLabeledEdit;
    btnStart: TButton;
    cbDy: TLabeledEdit;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    groupTex: TGroupBox;
    cbTexturing: TCheckBox;
    groupTexNumb: TGroupBox;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rb3: TRadioButton;
    rb4: TRadioButton;
    rb5: TRadioButton;
    rb6: TRadioButton;
    rb7: TRadioButton;
    rb8: TRadioButton;
    rb9: TRadioButton;
    rb10: TRadioButton;
    rb11: TRadioButton;
    rb12: TRadioButton;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    function TestDelimiters(s: String): String;
  end;

var
  frmOptions: TfrmOptions;

implementation

uses unitFrmLibMain;

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
  txtVyaz.Text := FloatToStr(0.005);
end;

procedure TfrmOptions.btnStartClick(Sender: TObject);
var
  i, j: Integer;
begin
  txtVyaz.Text := TestDelimiters(txtVyaz.Text);
  cbDy.Text := TestDelimiters(cbDy.Text);

  try
    frmLibMain.vis := StrToFloat(txtVyaz.Text);
    frmLibMain.Ydef := StrToFloat(cbDy.Text);
    for i := -50 to 50 do
      for j := -50 to 50 do
      begin
        frmLibMain.A[i, j] := 0;
        frmLibMain.B[i, j] := 0;
      end;
  except
    MessageBox(Handle, 'Введены неправильные значения',
                       'Ошибка', MB_OK or MB_ICONERROR);
  end;
  frmLibMain.RenderTimer.Enabled:=True;
  //возмущаем поверхность
  for i := -5 to 5 do
    for j := -5 to 5 do
      frmLibMain.A[i, j] := frmLibMain.Ydef;
end;

procedure TfrmOptions.N5Click(Sender: TObject);
begin
  frmLibMain.Close;
end;

procedure TfrmOptions.N3Click(Sender: TObject);
begin
  MessageBox(frmLibMain.Handle,
             'Колебания водной поверхности'#13#10+
             'Разработчик: Макаров М.М.'#13#10+
             'Дата создания: 2 марта 2005','О программе', MB_OK);
end;

end.
