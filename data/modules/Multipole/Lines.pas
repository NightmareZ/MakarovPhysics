unit Lines;

interface

uses
  OpenGL, Windows;

type
  ILines = interface
  ['{C3745698-2116-4001-A161-9B861CBB8B45}']
    procedure AddVertex(x, y: Single);
    procedure Render;
  end;

  TLines = class(TInterfacedObject, ILines)
  private
    NumbOfVx:Integer;
    Vertexes:Array of Array[1..2] of Single;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddVertex(x, y: Single);
    procedure Render;
  end;

implementation

constructor TLines.Create;
begin
  SetLength(Vertexes, 0);
  NumbOfVx := 0;
end;

destructor TLines.Destroy;
begin
  NumbOfVx := 0;
  SetLength(Vertexes, 0);
  Finalize(Vertexes);
  Inherited Destroy;
end;

procedure TLines.AddVertex(x, y: Single);
begin
  inc(NumbOfVx);
  SetLength(Vertexes, NumbOfVx);
  Vertexes[NumbOfVx - 1, 1] := x;
  Vertexes[NumbOfVx - 1, 2] := y;
end;

procedure TLines.Render;
var
  i: Integer;
begin
  glColor3f(1, 1, 1);
  if NumbOfVx > 1 then
  begin
    glDisable(GL_LIGHTING);
    glBegin(GL_LINE_STRIP);
    for i := 0 to NumbOfVx - 1 do
      glVertex2f(Vertexes[i, 1],Vertexes[i, 2]);
    glEnd;
  end;
end;

end.
