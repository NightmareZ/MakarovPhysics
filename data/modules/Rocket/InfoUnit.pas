{
Программа: Полёт ракеты
Разработчик: Макаров М.М.
Дата создания: Ноябрь 2004 года
Среда разработки: Delphi 7
}
unit InfoUnit;

interface

uses
  unitFrmResults, Classes, SysUtils, RocketUnit;

type
  TMyThread = class(TThread)
    MyRocket: TRocket;{объект класса Ракета}
    procedure Execute;override;
    procedure ShowInfo;
  private
    i, j, k: Extended;
  end;

implementation

procedure TMyThread.ShowInfo;
{вывод информации о ракете в frmResults.RichEdit1}
begin
  i := MyRocket.fuel[1].mass;
  j := MyRocket.fuel[2].mass;
  k := MyRocket.fuel[3].mass;

  if i < 0 then i := 0;
  if j < 0 then j := 0;
  if k < 0 then k := 0;

  frmResults.txtResult.Text :=
    'Время полёта: ' + IntToStr(Round(MyRocket.FlyTime / 1000)) + ' (с)' + #13#10 +
    'Высота: ' + FloatToStr(MyRocket.H - 32) + ' (м)' + #13#10 +
    'Скорость: ' + FloatToStr(MyRocket.Speed) + ' (м/c)' + #13#10 +
    'Ускорение: ' + FloatToStr(MyRocket.Acceleration) + ' (м/c^2)' + #13#10 +
    'Масса топлива первой ступени: ' + FloatToStr(i) + ' (кг)' + #13#10 +
    'Масса топлива второй ступени: ' + FloatToStr(j) + ' (кг)' + #13#10 +
    'Масса топлива третьей ступени: ' + FloatToStr(k) + ' (кг)';
end;

procedure TMyThread.Execute;
{основной цикл потока}
begin
  repeat
    Synchronize(ShowInfo);
  until Terminated;
end;

end.
