unit FieldElements;

interface

uses
  Lines, Math;

type
  IFieldElements = interface
  ['{830D512D-7CEA-4AED-BFEB-E7EFAEDCAE0A}']
    procedure AddElement(x, y: Single; sign: Integer);
    procedure Calc;
    procedure Render;
  end;

  TFieldElements = class(TInterfacedObject, IFieldElements)
  private
    NumbOfElements: Integer;
    Curr: Integer;
    HMLines: Integer;
    LineArr: Array of ILines;
    ArrOfElements: Array of record
      x, y: Single;
      sign: Integer;
    end;
  public
    constructor Create(NumberOfCurrentElement: Integer;
                       HowManyLines: Integer);
    destructor Destroy; override;
    procedure AddElement(x, y: Single; sign: Integer);
    procedure Calc;
    procedure Render;
  end;

implementation

constructor TFieldElements.Create(NumberOfCurrentElement: Integer;
                                  HowManyLines: Integer);
var
  i:Integer;
begin
  Finalize(ArrOfElements);
  Finalize(LineArr);
  NumbOfElements := 0;
  Curr:=NumberOfCurrentElement;
  HMLines:=HowManyLines;
  SetLength(LineArr,HMLines);
  for i := 0 to HMLines - 1 do
    LineArr[i] := TLines.Create;
end;

procedure TFieldElements.AddElement(x, y: Single; sign: Integer);
begin
  inc(NumbOfElements);
  SetLength(ArrOfElements, NumbOfElements);
  ArrOfElements[NumbOfElements-1].x := x;
  ArrOfElements[NumbOfElements-1].y := y;
  ArrOfElements[NumbOfElements-1].sign := Round(sign / abs(sign));
end;

destructor TFieldElements.Destroy;
var
  i: Integer;
begin
  for i:=0 to HMLines - 1 do
    LineArr[i] := nil;

  Curr := 0;
  HMLines := 0;
  NumbOfElements := 0;
  SetLength(ArrOfElements, 0);
  SetLength(LineArr, 0);
  Finalize(ArrOfElements);
  Finalize(LineArr);
  Inherited Destroy;
end;

procedure TFieldElements.Calc;
const
  maxdist = 10E9;
  maxvalue = 10000;
  dL = 0.005;
var
  i, j, m: Integer;
  x, y, x0, y0: Extended;
  E, Ey, Ex, r, s: Extended;
begin
  if not (ArrOfElements[Curr].sign <= 0) then
  begin
    for i := 0 to HMLines - 1 do
    begin
      j := 0;
      E := 1;
      x := ArrOfElements[Curr].x + cos(DegToRad((360 / HMLines) * i)) * 0.1;
      y := ArrOfElements[Curr].y + sin(DegToRad((360 / HMLines) * i)) * 0.1;
      x0 := x;
      y0 := y;
      LineArr[i].AddVertex(x, y);
      while (j < maxvalue) and (x < maxdist) and
            (x > -maxdist) and (y < maxdist) and
            (y > -maxdist) and (E > -0.995) do
      begin
        inc(j);
        E := 0;
        Ex := 0;
        Ey := 0;
        s := 0;
        for m := 0 to NumbOfElements - 1 do
        begin
          r := sqrt(sqr(ArrOfElements[m].x - x) + sqr(ArrOfElements[m].y - y));
          E := 1 / sqr(r);
          s := s + E;
          Ex := Ex - ArrOfElements[m].sign * E * ((ArrOfElements[m].x - x) / r);
          Ey := Ey - ArrOfElements[m].sign * E * ((ArrOfElements[m].y - y) / r);
        end;
        r := sqrt(sqr(x - x0) + sqr(y - y0));
        if r > 1 then
        begin
          if r > 100 then
          begin
            y := y + sqr(sqr(r)) * dL * Ey / s;
            x := x + sqr(sqr(r)) * dL * Ex / s;
          end else begin
            y := y + sqr(r) * dL * Ey / s;
            x := x + sqr(r) * dL * Ex / s;
          end;
        end else begin
          y := y + dL * Ey / s;
          x := x + dL * Ex / s;
        end;
        LineArr[i].AddVertex(x, y);
      end;
    end;
  end;
end;

procedure TFieldElements.Render;
var
  i:Integer;
begin
  for i := 0 to HMLines - 1 do
    LineArr[i].Render;
end;

end.
