unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, MyEngine, StdCtrls, XPMan, ComCtrls, ExtCtrls, Math;

type
  TLibProc = procedure (App, CallForm:THandle);
  TfrmMain = class(TForm)
    pnlMain: TPanel;
    imgLoading: TImage;
    pbLoading: TProgressBar;
    XPManifest1: TXPManifest;
    lblLoading: TLabel;
    RenderTimer: TTimer;
    lblVersion: TLabel;
    imgME: TImage;
    lblDesigned1: TLabel;
    lblDesigned2: TLabel;
    lblDesigned3: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RenderTimerTimer(Sender: TObject);
    procedure WMUser(var Msg: TMessage);message WM_USER;
    procedure FormCreate(Sender: TObject);
  private
    DC: HDC;
    HRC: HGLRC;
    Handles: Array[1..10] of LongWord;{хэндлы модулей}
    rotate: Integer;//угол поворота вокруг оси
    rot: Integer;//задание на вращение
    InitLibrary: TLibProc;//процедура, вызывающая модуль
    isloaded: Boolean;//загружена ли уже форма
    procedure LoadModule(number: Integer);
  end;

const
  loadDelay = 100;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.WMUser(var Msg:TMessage);
{процедура, вызываемая модулем}
begin
  Enabled := True;
  ShowCursor(False);
  RenderTimer.Enabled := True;
end;

procedure TfrmMain.LoadModule(number:Integer);
{загрузка модуля}
begin
  wglMakeCurrent(0, 0);
  @InitLibrary := GetProcAddress(Handles[number], 'InitLibrary');
  if @InitLibrary <> nil then
  begin
    RenderTimer.Enabled := False;
    Enabled := False;
    ShowCursor(True);
    InitLibrary(Application.Handle, Handle);
  end else
    MessageBox(Handle, 'Не найдена процедура InitLibrary', 'Ошибка',
      MB_OK or MB_ICONERROR);
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i:Integer;
begin
  case Key of
    27: Close;
    39: begin
          dec(rot);
          if rot < -2 then rot := -2;
        end;
    37: begin
          inc(rot);
          if rot > 2 then rot := 2;
        end;
    13: begin
          i := (Floor(rotate / 36)) + 1;
          if (i > 0) and (i <= 12) then
            if Handles[i] > 0 then
              LoadModule(i);
        end;
  end;
end;

procedure IncProgressBar;
{увеличение позиции ProgressBar}
begin
  frmMain.pbLoading.Position := frmMain.pbLoading.Position + 1;
  if frmMain.pbLoading.Position = 100 then
    frmMain.pbLoading.Position := 0;

  //Sleep(30);
  Application.ProcessMessages;
end;

procedure Loading2;
var
  libarr: Array of ShortString;//массив для названий модулей
  s: String;
  i,j: Integer;
  f: TextFile;
  pc: PChar;
begin
  with frmMain do
  begin

    i := 0;
    //Инициализация списка модулей
    try
      AssignFile(f, 'data\engine\modules.cfg');
      Reset(f);
      lblLoading.Caption := 'Инициализация списка модулей';
      Sleep(loadDelay);
      Application.ProcessMessages;
      IncProgressBar;

      while not EOF(f) do
      begin
        ReadLn(f,s);
        if (Length(s) > 0) and (s[1] <> '/') and (s[2] <> '/') then
        begin
          inc(i);
          SetLength(libarr,i);
          libarr[i - 1] := s;
          IncProgressBar;
        end;
      end;
    except
      MessageBox(Handle, 'Ошибка при чтении файла "data\engine\modules.cfg"',
        'Ошибка', MB_OK or MB_ICONERROR);
      Close;
    end;

    //загрузка библиотек
    if i > 0 then
      for j := 1 to i do
      begin
        lblLoading.Caption := 'Загрузка модуля ' + libarr[j];
        IncProgressBar;
        Sleep(loadDelay);
        Application.ProcessMessages;
        s := libarr[j - 1];
        pc := PAnsiChar(s);
        Handles[j] := LoadLibrary(pc);
      end;
    Finalize(libarr);
    CloseFile(f);

    //создание дисплейных списков
    lblLoading.Caption := 'Создание дисплейных списков';
    frmMain.pbLoading.Position := 80;
    
    Sleep(loadDelay);
    Application.ProcessMessages;
    Sleep(1000);
    Application.ProcessMessages;

    glNewList(1,GL_COMPILE);
      DrawOneSideTexturedBox(-4.5, -4.5, -0.25, 9, 9, 0.5);
    glEndList;

    glNewList(2,GL_COMPILE);
      DrawSkyBox(-80, -80, -80, 160, 160, 160, 1, 2, 3, 4, 5, 6);
    glEndList;
  end;
  frmMain.isloaded := True;

  //Запуск
  frmMain.lblLoading.Caption := 'Запуск....';
  frmMain.pbLoading.Position := 100;
  for i := 0 to 2 do
  begin
    Application.ProcessMessages;
    Sleep(500);
  end;

  with frmMain do
  begin
    imgME.Hide;
    lblDesigned1.Hide;
    lblDesigned2.Hide;
    lblDesigned3.Hide;
  end;
end;

procedure Loading;
var
  texarr: Array of Array[1..3] of ShortString;//массив для названий текстур
  s: ShortString;//строка для считывания из cfg-файла
  i, j, k: Integer;
  x: Boolean;
  f: TextFile;//cfg-файл
begin
  with frmMain do
  begin
    KillTimer(Handle, 1);

    //подготовка к загрузке
    with pnlMain do
    begin
      Left:=Round((frmMain.ClientWidth - Width) / 2);
      Top:=Round((frmMain.ClientHeight - Height) / 2);
      Show;
    end;

    //инициализация списка текстур
    lblLoading.Caption := 'Инициализация списка текстур';
    IncProgressBar;
    Sleep(loadDelay);
    Application.ProcessMessages;

    i:=0;
    try
      AssignFile(f, 'data\engine\maintex.cfg');
      Reset(f);
      while not EOF(f) do
      begin
        ReadLn(f,s);
        if (Length(s) > 0) and (s[1] <> '/') and (s[2] <> '/') then
        begin
          inc(i);
          SetLength(texarr, i);
          j := 1;
          k := 1;
          x := False;
          IncProgressBar;
          while (j <= Length(s)) do
          begin
            if (s[j] = ' ') and (x = False) then
            begin
              x := True;
              inc(k);
            end;
            if s[j] <> ' ' then x := False;
            texarr[i-1,k] := texarr[i-1,k] + s[j];
            inc(j);
          end;
        end;
      end;
      CloseFile(f);
    except
      MessageBox(Handle, 'Ошибка при чтении файла "data\engine\maintex.cfg"',
        'Ошибка', MB_OK or MB_ICONERROR);
      Close;
    end;

    //инициализация OpenGL
    lblLoading.Caption := 'Инициализация OpenGL';
    Sleep(loadDelay);
    Application.ProcessMessages;

    DC := GetDC(Handle);
    SetDCPixelFormat(DC);
    HRC := wglCreateContext(DC);
    wglMakeCurrent(DC, HRC);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);

    //Загрузка текстур
    if i > 0 then
      for j := 0 to i - 1 do
      begin
        Application.ProcessMessages;
        lblLoading.Caption := 'Загрузка текстуры: ' +
          texarr[j,1] + '  ' + texarr[j,2];
        IncProgressBar;
        Sleep(loadDelay);
        Application.ProcessMessages;

        if j < 6 then
          LoadTexture(texarr[j,1], StrToInt(texarr[j,2]), StrToInt(texarr[j,3]))
        else
          LoadTexture512(texarr[j,1], StrToInt(texarr[j,2]), StrToInt(texarr[j,3]));
      end;
    Finalize(texarr);

    //второй этап загрузки
    Loading2;
    pnlMain.Hide;
    FormResize(nil);
    RenderTimer.Enabled := True;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  WindowState := wsMaximized;
  ShowCursor(False);
  if not frmMain.isloaded then
    SetTimer(Handle, 1, 300, @Loading);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  glDeleteLists(1,2);
  wglMakeCurrent(0,0);
  wglDeleteContext(HRC);
  ReleaseDC(Handle,DC);
  DeleteDC(DC);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30, ClientWidth / ClientHeight, 1, 200);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TfrmMain.RenderTimerTimer(Sender: TObject);
var
  ps: TPaintStruct;
  i: Integer;
begin
  BeginPaint(Handle, ps);
  wglMakeCurrent(DC, HRC);
  frmMain.Resize;
  glClearColor(0, 1, 0, 1);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;

  //расчёт вращения
  rotate := rotate + Round(rot / Abs(rot));
  if rotate >= 360 then rotate := 0;
  if rotate < 0 then rotate := 359;
  if rotate mod 36 = 0 then
  begin
    if rot > 0 then
      dec(rot);
    if rot < 0 then
      inc(rot);
  end;

  //прорисовка скайбокса
  glTranslatef(0, 0, -70);
  glRotatef(rotate, 0, 1, 0);
  glCallList(2);

  for i:=1 to 10 do
  begin
    glPushMatrix;
    glRotatef(i * 36, 0, 1, 0);
    glTranslatef(0, 0, 20);
    glBindTexture(GL_TEXTURE_2D, i + 6);
    glCallList(1);
    glPopMatrix;
  end;

  EndPaint(Handle, ps);
  SwapBuffers(DC);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  SetCurrentDir(ExtractFilePath(Application.GetNamePath));
  isloaded := False;
end;

end.
