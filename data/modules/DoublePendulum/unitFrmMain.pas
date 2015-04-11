unit unitFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, Math;

type
  vector=record{вектор}
    x,y:Extended;
  end;

  Pendulum=record{маятник}
    Len:Extended;{длина нити}
    mass:Extended;{масса груза}
    Position:vector;{координаты}
    FixedPos:vector;{координаты точки крепления}
    Angle:Extended;{угол отклонения}
    Speed:Extended;{скорость}
    Acceleration:Extended;{ускорение}
    preAngle:Extended;{предыдущий угол}
    preSpeed:Extended;{предыдущая скорость}
    preAcceleration:Extended;{предыдущее ускорение}
  end;

  TfrmLibMain = class(TForm)
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    CallerForm: THandle;{вызывающая форма}
    DC: HDC;{контекст устройства}
    HRC: HGLRC;{контекст рендеринга OpenGL}
    nPixelFormat: Integer;
    pfd: TPixelFormatDescriptor;{формат пикселя}
    ps: TPaintStruct;
    quadObj1, quadObj2: GLUquadricObj;{quadric-объекты}
    ArrOfAngle,
    ArrOfSpeed,
    ArrOfAccel: Array[1..2,1..250] of Extended;
    infostep: Integer;{счётчик для вывода инфы}
    procedure SetStandartWindowsPosition;
    procedure SetDCPixelFormat;
    procedure Render;
    procedure DrawGrid;
    procedure CalcPendulums;
    procedure Verlet;
    procedure Accel;
    procedure DrawGraphic;
    procedure DrawPhaseTraectory;
    procedure UpdateArrays;
  public
    Pendulums: Array[1..2] of Pendulum;{маятники}
    IsRun,IsPaused: Boolean;
    procedure ClearArrays;
  end;

var
  frmLibMain: TfrmLibMain;

procedure InitLibrary(App, CallForm:THandle);

implementation

uses unitFrmTools, unitFrmResults, unitFrmGraphics, unitFormPhaseTraectory;

{$R *.dfm}

procedure InitLibrary(App,CallForm:THandle);
{Инициализация библиотеки}
begin
  Application.Handle := App;
  frmLibMain := TfrmLibMain.Create(Application);
  frmLibMain.CallerForm := CallForm;
  {создание дополнительных форм}
  frmTools := TfrmTools.Create(Application);
  frmResults := TfrmResults.Create(Application);
  frmGraphics := TfrmGraphics.Create(Application);
  frmPhaseTraectory := TfrmPhaseTraectory.Create(Application);
  frmLibMain.Show;
end;

procedure TfrmLibMain.UpdateArrays;
{обновление массивов}
var
  i, j: Integer;
begin
  for i := 1 to 2 do
  begin
    for j := 1 to 249 do
    begin
      ArrOfAngle[i, j] := ArrOfAngle[i, j + 1];
      ArrOfSpeed[i, j] := ArrOfSpeed[i, j + 1];
      ArrOfAccel[i, j] := ArrOfAccel[i, j + 1];
    end;
    ArrOfAngle[i, 250] := Pendulums[i].Angle;
    ArrOfSpeed[i, 250] := Pendulums[i].Speed;
    ArrOfAccel[i, 250] := Pendulums[i].Acceleration;
  end;
end;

procedure TfrmLibMain.ClearArrays;
{очистка массивов}
var
  i, j: Integer;
begin
  for i:=1 to 2 do
    for j:=1 to 250 do
    begin
      ArrOfAngle[i,j] := 0;
      ArrOfSpeed[i,j] := 0;
      ArrOfAccel[i,j] := 0;
    end;
end;

procedure TfrmLibMain.DrawGraphic;
{прорисовка графиков}
var
  i:Integer;
begin
  frmGraphics.chartPendulum1.Series[0].Clear;
  frmGraphics.chartPendulum2.Series[0].Clear;
  case frmGraphics.tabs.TabIndex of
    0: begin
         frmGraphics.chartPendulum1.Title.Text.Text:='Угол (Маятник 1) [град]';
         frmGraphics.chartPendulum2.Title.Text.Text:='Угол (Маятник 2) [град]';
         for i:=1 to 250 do
         begin
           frmGraphics.chartPendulum1.Series[0].Add(ArrOfAngle[1,i]);
           frmGraphics.chartPendulum2.Series[0].Add(ArrOfAngle[2,i]);
         end;
       end;
    1: begin
         frmGraphics.chartPendulum1.Title.Text.Text:='Угловая скорость (Маятник 1) [град/с]';
         frmGraphics.chartPendulum2.Title.Text.Text:='Угловая скорость (Маятник 2) [град/с]';
         for i:=1 to 250 do
         begin
           frmGraphics.chartPendulum1.Series[0].Add(ArrOfSpeed[1,i]);
           frmGraphics.chartPendulum2.Series[0].Add(ArrOfSpeed[2,i]);
         end;
       end;
    2: begin
         frmGraphics.chartPendulum1.Title.Text.Text:='Угловое ускорение (Маятник 1) [град/с^2]';
         frmGraphics.chartPendulum2.Title.Text.Text:='Угловое ускорение (Маятник 2) [град/с^2]';
         for i:=1 to 250 do
         begin
           frmGraphics.chartPendulum1.Series[0].Add(ArrOfAccel[1,i]);
           frmGraphics.chartPendulum2.Series[0].Add(ArrOfAccel[2,i]);
         end;
       end;
  end;
end;

procedure TfrmLibMain.DrawPhaseTraectory;
{прорисовка фазовых траеторий}
var
  i: Integer;
begin
  frmPhaseTraectory.chartPhase1.Series[0].Clear;
  frmPhaseTraectory.chartPhase2.Series[0].Clear;
  for i := 1 to 250 do
  begin
    frmPhaseTraectory.chartPhase1.Series[0].AddXY(ArrOfAngle[1, i],ArrOfSpeed[1, i]);
    frmPhaseTraectory.chartPhase2.Series[0].AddXY(ArrOfAngle[2, i],ArrOfSpeed[2, i]);
  end;
end;


procedure TfrmLibMain.Verlet;
var
  tf: Array[1..2] of Extended;
  i,k: Integer;
  dt: Double;

  procedure put;
  var
    j: Integer;
  begin
    for j := 1 to 2 do
    begin
      Pendulums[j].preSpeed := Pendulums[j].Speed;
      Pendulums[j].preAngle := Pendulums[j].Angle;
    end;
  end;

begin
  dt := 1 / 4000;
  for k := 1 to 160 do
  begin
    put;
    Accel;

    for i := 1 to 2 do
      tf[i] := Pendulums[i].preAcceleration;

    for i := 1 to 2 do
    begin
      Pendulums[i].Angle :=
        Pendulums[i].preAngle +
        Pendulums[i].preSpeed * dt+
        Pendulums[i].Acceleration * sqr(dt) / 2;
      Pendulums[i].Speed :=
        Pendulums[i].preSpeed +
        Pendulums[i].Acceleration * dt;
    end;

    put;
    Accel;

    for i := 1 to 2 do
    begin
      tf[i] := (tf[i] + Pendulums[i].Acceleration) / 2;
      Pendulums[i].Speed :=
        Pendulums[i].Speed +
        tf[i] * dt;
      Pendulums[i].Angle :=
        Pendulums[i].Angle +
        Pendulums[i].Speed * dt +
        tf[i] * sqr(dt) / 2;
      if Pendulums[i].Angle > 360 then
        Pendulums[i].Angle :=
          Frac(Pendulums[i].Angle / 360) * 360;
      if Pendulums[i].Angle < -360 then
        Pendulums[i].Angle :=
          Frac(Pendulums[i].Angle / (-360)) * (-360);
    end;
  end;

  {обновление массивов}
  UpdateArrays;
end;

procedure TfrmLibMain.Accel;
const
  g = 9.81;
var
  t, ts, t2: Extended;
begin
  t := cos(DegToRad(Pendulums[1].preAngle) -
    DegToRad(Pendulums[2].preAngle));
  ts := sin(DegToRad(Pendulums[1].preAngle) -
    DegToRad(Pendulums[2].preAngle));
  t2 := sin(DegToRad(Pendulums[2].preAngle) -
    DegToRad(Pendulums[1].preAngle));

  Pendulums[1].Acceleration := RadToDeg(
    -(Pendulums[2].mass / Pendulums[1].mass) * t *
    (Pendulums[2].Len / Pendulums[1].Len) *
    DegToRad(Pendulums[2].preAcceleration) -
    (Pendulums[2].mass / Pendulums[1].mass) *
    sqr(DegToRad(Pendulums[2].preSpeed)) *
    (Pendulums[2].Len/Pendulums[1].Len) * ts-
    (g/Pendulums[1].Len) * sin(DegToRad(Pendulums[1].preAngle)) );

  Pendulums[2].Acceleration := RadToDeg(
    -(Pendulums[1].Len / Pendulums[2].Len) *
    DegToRad(Pendulums[1].preAcceleration) * t -
    sqr(DegToRad(Pendulums[1].preSpeed)) *
    (Pendulums[1].Len/Pendulums[2].Len) * t2-
    (g/Pendulums[2].Len) * sin(DegToRad(Pendulums[2].preAngle)) );
end;

procedure TfrmLibMain.DrawGrid;
{прорисовка сетки}
var
  i: Integer;
begin
  glDisable(GL_LIGHTING);
  glColor3f(0.3, 0.3, 0.3);
  glBegin(GL_LINES);
  for i := -50 to 50 do
    if i <> 0 then
    begin
      glVertex3f(i / 2, -50, 0);
      glVertex3f(i / 2, 50, 0);
      glVertex3f(-50, i / 2, 0);
      glVertex3f(50, i / 2, 0);
    end;
  glColor3f(0.3, 1, 0.3);
  glVertex3f(0, -50, 0);
  glVertex3f(0, 50, 0);
  glColor3f(1, 0.3, 0.3);
  glVertex3f(-50, 0, 0);
  glVertex3f(50, 0, 0);
  glEnd;
  glEnable(GL_LIGHTING);
end;

procedure TfrmLibMain.SetStandartWindowsPosition;
{настройка расположения окон}
const
  dw = 209;
  dh1 = 0.25;
  dh2 = 0.25;
begin
  with frmLibMain do
  begin
    Left := dw;
    Top := 0;
    Height := Round(Screen.Height * (1 - (dh1 + dh2)));
    Width := Screen.Width - dw;
  end;

  with frmTools do
  begin
    Left := 0;
    Top := 0;
    Height := Screen.Height;
    Width := dw;
    Show;
  end;

  with frmGraphics do
  begin
    Left := frmTools.Width;
    Top := frmLibMain.Height;
    Width := frmLibMain.Width;
    Height := Round(Screen.Height*dh1);
    Show;
  end;

  with frmResults do
  begin
    Left := dw;
    Top := frmGraphics.Height + frmLibMain.Height;
    Width := Round((Screen.Width - dw) / 2);
    Height := Screen.Height - frmLibMain.Height - frmGraphics.Height;
    Show;
  end;

  with frmPhaseTraectory do
  begin
    Left := dw + frmResults.Width;
    Top := frmResults.Top;
    Width := Screen.Width - dw - frmResults.Width;
    Height := frmResults.Height;
    Show;
  end;
end;

procedure TfrmLibMain.SetDCPixelFormat;
{настройка формата пикселя}
begin
  FillChar(pfd,SizeOf(pfd), 0);
  pfd.dwFlags := PFD_SUPPORT_OPENGL or
                 PFD_DRAW_TO_WINDOW or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

procedure TfrmLibMain.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if frmResults.Visible then Resize := False;
end;

procedure TfrmLibMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {удаление таймера рендеринга}
  KillTimer(Handle, 456);

  {удаление Quadric-объектов}
  gluDeleteQuadric(quadObj1);
  gluDeleteQuadric(quadObj2);

  {завершение работы с OpenGL}
  wglMakeCurrent(0, 0);
  wglDeleteContext(HRC);
  ReleaseDC(Handle,DC);
  DeleteDC(DC);

  {удаление окон}
  frmTools.Destroy;
  frmResults.Destroy;
  frmGraphics.Destroy;
  frmPhaseTraectory.Destroy;

  {завершение работы модуля}
  SendMessage(CallerForm, WM_USER, 0, 0);
  Destroy;
end;

procedure TfrmLibMain.CalcPendulums;
{расчёт координат из углов отклонения}
begin
  if IsRun and not IsPaused then Verlet;
  with Pendulums[1] do
  begin
    Position.x := Len * sin(DegToRad(Angle));
    Position.y := Len * cos(DegToRad(Angle));
  end;
  Pendulums[2].FixedPos.x := Pendulums[1].Position.x;
  Pendulums[2].FixedPos.y := Pendulums[1].Position.y;
  with Pendulums[2] do
  begin
    Position.x := FixedPos.x + Len * sin(DegToRad(Angle));
    Position.y := FixedPos.y + Len * cos(DegToRad(Angle));
  end;
end;

procedure TfrmLibMain.Render;
const
  qw = 5;{смещение по оси Y}
  infolimit = 5;{момент вывода инфы}
begin
  wglMakeCurrent(DC, HRC);
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or
          GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glTranslatef(0, -3, -frmTools.tbDistance.Position);

  {расчёт маятников}
  CalcPendulums;

  {прорисовка графиков}
  DrawGraphic;

  {прорисовка фазовых траеторий}
  DrawPhaseTraectory;

  {прорисовка сетки}
  if frmTools.cbGrid.Checked then
    DrawGrid;

  {вывод информации}
  inc(infostep);
  if infostep > infolimit then
  begin
    infostep := 0;
    frmResults.txtResults.Text := 'Маятник 1' + #13#10 +
      'Угол: ' + FloatToStr(Pendulums[1].Angle) + ' (град)' + #13#10 +
      'Угловая скорость: ' + FloatToStr(Pendulums[1].Speed) + ' (град/с)' + #13#10+
      'Угловое ускорение: ' + FloatToStr(Pendulums[1].Acceleration) + ' (град/с^2)'
      + #13#10#13#10 +
      'Маятник 2' + #13#10 +
      'Угол: ' + FloatToStr(Pendulums[2].Angle) + ' (град)' + #13#10 +
      'Угловая скорость: ' + FloatToStr(Pendulums[2].Speed) + ' (град/с)' + #13#10 +
      'Угловое ускорение: ' + FloatToStr(Pendulums[2].Acceleration) + ' (град/с^2)';
  end;

  {прорисовка нитей подвесов маятников}
  glColor3f(1, 1, 1);
  if frmTools.cbViewPend.Checked then
  begin
    glDisable(GL_LIGHTING);
    glBegin(GL_LINES);
      glVertex3f(0, 0 + qw, 0.1);
      glVertex3f(Pendulums[1].Position.x,
                 -Pendulums[1].Position.y + qw,
                 0.2);
      glVertex3f(Pendulums[2].FixedPos.x,
                 -Pendulums[2].FixedPos.y + qw,
                 0.2);
      glVertex3f(Pendulums[2].Position.x,
                 -Pendulums[2].Position.y + qw,
                 0.2);
    glEnd;
    glEnable(GL_LIGHTING);
  end;

  {прорисовка грузов}
  if frmTools.cbViewMass.Checked then
  begin
    glPushMatrix;
    glTranslatef(Pendulums[1].FixedPos.x,
                 -Pendulums[1].FixedPos.y + qw,
                 0.1);
    gluSphere(quadObj1,frmTools.tbMassSize.Position/50, 25, 25);
    glPopMatrix;
    glPushMatrix;
    glTranslatef(Pendulums[1].Position.x,
                 -Pendulums[1].Position.y+qw,
                 0.1);
    gluSphere(quadObj1,frmTools.tbMassSize.Position / 40, 25, 25);
    glPopMatrix;
    glPushMatrix;
    glTranslatef(Pendulums[2].Position.x,
                 -Pendulums[2].Position.y + qw,
                 0.1);
    gluSphere(quadObj2,frmTools.tbMassSize.Position / 40, 25, 25);
    glPopMatrix;
  end;


  EndPaint(Handle,ps);
  SwapBuffers(DC);
end;

procedure RenderTimerTick;
begin
  frmLibMain.Render;
end;

procedure TfrmLibMain.FormShow(Sender: TObject);
var
  material: Array[0..3] of GLfloat;
  i: Integer;
begin
  IsRun := False;
  IsPaused := False;
  for i := 1 to 2 do
    with Pendulums[i] do
    begin
      Len := 2;
      mass := 1;
      Angle := 30;
      Speed := 0;
    end;
  Pendulums[2].Angle := 75;

  {инициализация OpenGL}
  DC := GetDC(Handle);
  SetDCPixelFormat;
  HRC := wglCreateContext(DC);
  wglMakeCurrent(DC,HRC);
  {настройка OpenGL}

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  material[0] := 0.1;
  material[1] := 0.1;
  material[2] := 0.1;
  material[3] := 1;
  glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, @material);

  {создание Quadric-объектов}
  quadObj1:=gluNewQuadric;
  gluQuadricDrawStyle(quadObj1, GLU_FILL);
  gluQuadricOrientation(quadObj1, GLU_OUTSIDE);
  quadObj2:=gluNewQuadric;
  gluQuadricDrawStyle(quadObj2, GLU_FILL);
  gluQuadricOrientation(quadObj2, GLU_OUTSIDE);

  {настройка расположения окон}
  SetStandartWindowsPosition;

  {инициализация таймера рендеринга}
  SetTimer(Handle, 456, 40, @RenderTimerTick);
end;

procedure TfrmLibMain.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30, ClientWidth / ClientHeight, 1, 100);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

end.
 