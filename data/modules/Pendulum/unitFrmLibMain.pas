{
Программа: Математический маятник
Разработчик: Макаров М.М.
Дата создания: 25 ноября 2004
Среда разработки: Delphi7
}
unit unitFrmLibMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, unitFrmOptions, unitFrmResults, unitFrmGraph, OpenGL, Math;

type
  TfrmLibMain = class(TForm)
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    CallerForm: THandle;{вызывающая форма}
    DC: HDC;{контекст устройства}
    HRC: HGLRC;{контекст воспроизведения OpenGL}
    ps: TPaintStruct;
    pfd: TPixelFormatDescriptor;
    QuadObj: GLUquadricObj;{quadric-Объект}
    procedure SetDefaultWindowPosition;
    procedure SetDCPixelFormat;
    procedure DrawGrid;
    procedure Calculate;
    procedure DrawGraphic;
  public
    IsRun: Boolean;{ведутся ли расчёты}
    Angle,{угол}
    preSpeed,Speed,{угловая скорость}
    Accel,{угловое ускорение}
    Len,{длина}
    g: Extended;{ускорение свободного падения}
    AngleArray,{массив углов}
    SpeedArray,{массив скоростей}
    AccelArray: Array[1..250] of Extended;{массив ускорений}
    MyTime: Integer;{милисекунды в нашем времени}
    Period: Extended;{период колебаний}
    infotimer: Integer;
  end;

var
  frmLibMain: TfrmLibMain;

procedure InitLibrary(App,CallForm:THandle);

implementation

uses unitFrmPhaseTraectory;

{$R *.dfm}

procedure InitLibrary(App,CallForm:THandle);
{Инициализация библиотеки}
begin
  Application.Handle := App;
  frmLibMain := TfrmLibMain.Create(Application);
  frmLibMain.CallerForm := CallForm;

  frmOptions := TfrmOptions.Create(Application);
  frmResults := TfrmResults.Create(Application);
  frmGraph := TfrmGraph.Create(Application);
  frmPhaseTraectory := TfrmPhaseTraectory.Create(Application);

  frmLibMain.Show;
  frmOptions.Show;
  frmResults.Show;
  frmGraph.Show;
end;

procedure TfrmLibMain.DrawGraphic;
{расчёт и прорисовка графиков}
var
  i: Integer;
begin
  {обновление массивов углов, скоростей и ускорений}
  for i := 1 to 249 do
  begin
    AngleArray[i] := AngleArray[i+1];
    SpeedArray[i] := SpeedArray[i+1];
    AccelArray[i] := AccelArray[i+1];
  end;

  AngleArray[250] := Angle;
  SpeedArray[250] := Speed;
  AccelArray[250] := Accel;

  {прорисовка графиков}
  frmGraph.Chart.Series[0].Clear;
  case frmGraph.tabs.TabIndex of
    0: begin
         frmGraph.Chart.Title.Text.Text := 'Угол (град)';
         for i := 1 to 250 do
           frmGraph.Chart.Series[0].Add(AngleArray[i]);
       end;

    1: begin
         frmGraph.Chart.Title.Text.Text := 'Угловая скорость (град/с)';
         for i := 1 to 250 do
           frmGraph.Chart.Series[0].Add(SpeedArray[i]);
       end;

    2: begin
         frmGraph.Chart.Title.Text.Text := 'Угловое ускорение (град/с^2)';
         for i := 1 to 250 do
           frmGraph.Chart.Series[0].Add(AccelArray[i]);
       end;
  end;

  frmPhaseTraectory.chartPhaseTraectory.Series[0].Clear;
  for i := 1 to 250 do
    frmPhaseTraectory.chartPhaseTraectory.Series[0].AddXY(AngleArray[i], SpeedArray[i]);
end;

procedure ShowInfo;
begin
  frmResults.txtResult.Text :=
    'Угол: ' + FloatToStr(frmLibMain.Angle) + ' (град)' + #13#10 +
    'Угловая скорость: ' + FloatToStr(frmLibMain.Speed) + ' (град/с)' + #13#10 +
    'Угловое ускорение: ' + FloatToStr(frmLibMain.Accel) + ' (град/с^2)' + #13#10 +
    'Период колебаний: ' + FloatToStr(frmLibMain.Period / 1000) + ' (с)' + #13#10 +
    'Частота колебаний: ' + FloatToStr(1 / (frmLibMain.Period / 1000)) + ' (Гц)';
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
  begin
    glVertex3f(i / 5, -10, 0);
    glVertex3f(i / 5, 10, 0);
    glVertex3f(-10, i / 5, 0);
    glVertex3f(10, i / 5, 0);
  end;
  glEnd;

  glEnable(GL_LIGHTING);
end;

procedure TfrmLibMain.SetDCPixelFormat;
{настройка формата пикселя}
var
  nPixelFormat: Integer;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  pfd.dwFlags := PFD_SUPPORT_OPENGL or
                 PFD_DRAW_TO_WINDOW or
                 PFD_DOUBLEBUFFER;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

procedure TfrmLibMain.SetDefaultWindowPosition;
{настройка расположения окон}
const
  w = 209;
  h = 0.7;
begin
  with frmLibMain do
  begin
    Left := w;
    Top := 0;
    Width := Screen.Width - w;
    Height := Round(Screen.Height * h);
  end;

  with frmOptions do
  begin
    Left := 0;
    Top := 0;
    Width := w;
    Height := Round(Screen.Height * h);
    Show;
  end;

  with frmResults do
  begin
    Left := 0;
    Top := frmLibMain.Height;
    Width := Round(Screen.Width / 3);
    Height := Screen.Height - frmLibMain.Height;
    Show;
  end;

  with frmGraph do
  begin
    Left := frmResults.Width;
    Top := frmLibMain.Height;
    Width := Round(Screen.Width / 3);
    Height := Screen.Height - frmLibMain.Height;
    Show;
  end;

  with frmPhaseTraectory do
  begin
    Left := frmGraph.Left + frmGraph.Width;
    Top := frmGraph.Top;
    Width := Screen.Width - frmResults.Width - frmGraph.Width;
    Height := frmGraph.Height;
    Show;
  end;
end;

procedure TfrmLibMain.FormShow(Sender: TObject);
begin
  SetDefaultWindowPosition;
end;

procedure TfrmLibMain.FormDestroy(Sender: TObject);
begin
  frmOptions.Destroy;
  frmResults.Destroy;
  frmGraph.Destroy;
  frmPhaseTraectory.Destroy;
end;

procedure TfrmLibMain.Calculate;
{расчёт движения маятника}
const
  dt = 0.00025;
  interval = 160;
var
  i: Integer;
  preAccel: Extended;
begin
  preSpeed := Speed;
  MyTime := MyTime + interval;

  for i := 1 to interval do
  begin
    preAccel := Accel;
    Accel := sin(DegToRad(Angle)) * g * (180 / (pi * Len));
    Angle := Angle + Speed * dt + preAccel * sqr(dt) / 2;
    Speed := Speed - (Accel + preAccel) * dt / 2;
  end;

  if (preSpeed * Speed <= 0) then
  begin
    Period := MyTime / 2;
    MyTime := 0;
  end;

  DrawGraphic;
end;

procedure Render;
{рендеринг}
begin
  wglMakeCurrent(frmLibMain.DC,frmLibMain.HRC);

  with frmLibMain do
  begin
    BeginPaint(Handle, ps);
    glClear(GL_COLOR_BUFFER_BIT or
            GL_DEPTH_BUFFER_BIT);
    glLoadIdentity;
    glTranslatef(0, 0, -10);

    {прорисовка сетки}
    if frmOptions.cbShowGrid.Checked then
      DrawGrid;

    {расчёт движения}
    if IsRun then
      frmLibMain.Calculate;

    {прорисовка сферы в месте крепления маятника}
    glPushMatrix;
    glTranslatef(0, 2.2, 0);
    gluSphere(QuadObj, 0.1, 20, 20);
    glPopMatrix;

    {прорисовка груза маятника}
    glPushMatrix;
    glTranslatef(Len * sin(DegToRad(Angle)),
                 -Len * cos(DegToRad(Angle)) + 2.2, 0);
    gluSphere(QuadObj, 0.1, 20, 20);
    glPopMatrix;

    {прорисовка нити подвеса}
    glDisable(GL_LIGHTING);
    glColor3f(1, 1, 1);
    glBegin(GL_LINES);
      glVertex3f(0, 2.2, 0.05);
      glVertex3f(Len * sin(DegToRad(Angle)), -Len * cos(DegToRad(Angle)) + 2.2, 0.05);
    glEnd;
    glEnable(GL_LIGHTING);

    {вывод информации}
    inc(infotimer);
    if infotimer > 5 then
    begin
      infotimer := 0;
      ShowInfo;
    end;

    EndPaint(Handle, ps);
    SwapBuffers(DC);
  end;
end;

procedure TfrmLibMain.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if frmOptions.Visible then Resize := False;
end;

procedure TfrmLibMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  wglMakeCurrent(DC,HRC);

  {останов таймера}
  KillTimer(Handle, 100);

  {удаление quadric-объектов}
  gluDeleteQuadric(QuadObj);

  {завершение работы с OpenGL}
  wglMakeCurrent(0, 0);
  wglDeleteContext(HRC);
  ReleaseDC(Handle, DC);
  DeleteDC(DC);
  SendMessage(CallerForm, WM_USER, 0, 0);
  Destroy;
end;

procedure TfrmLibMain.FormCreate(Sender: TObject);
begin
  IsRun := False;
  Len := 3;
  Angle := 30;
  MyTime := 0;
  Period := 1;

  {инициализация OpenGL}
  DC := GetDC(Handle);
  SetDCPixelFormat;
  HRC := wglCreateContext(DC);
  wglMakeCurrent(DC, HRC);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);

  {создание quadric-объектов}
  QuadObj := gluNewQuadric;
  gluQuadricDrawStyle(QuadObj, GLU_FILL);
  gluQuadricOrientation(QuadObj, GLU_OUTSIDE);

  {запуск таймера}
  SetTimer(Handle, 100, 40, @Render);
end;

procedure TfrmLibMain.FormResize(Sender: TObject);
begin
  wglMakeCurrent(DC, HRC);
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30, ClientWidth / ClientHeight, 1, 1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

end.
