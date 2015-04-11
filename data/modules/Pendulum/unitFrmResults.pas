{
Программа: Математический маятник
Разработчик: Макаров М.М.
Дата создания: 25 ноября 2004
Среда разработки: Delphi7
}
unit unitFrmResults;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmResults = class(TForm)
    txtResult: TMemo;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  frmResults: TfrmResults;

implementation

uses unitFrmLibMain;

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
