unit Fields;

interface

uses
  FieldElements;

type
  IFields = interface
  ['{EE32AD4C-F3C6-463B-A75B-BD0933DDE586}']
    procedure Calc;
    procedure Render;
    procedure AddElement(x,y:Extended; sign:Integer);
  end;

  TFields = class(TInterfacedObject, IFields)
  private
    ArrOfElements:Array of record
      x, y: Extended;
      sign: Integer;
    end;
    HowManyLines: Integer;
    ArrOfFields: Array of IFieldElements;
    NumbOfElements: Integer;
  public
    procedure Calc;
    procedure Render;
    procedure AddElement(x, y: Extended; sign: Integer);
    constructor Create(HowManyFieldLines: Integer);
    destructor Destroy; override;
  end;

implementation

procedure TFields.Calc;
var
  i, j: Integer;
begin
  SetLength(ArrOfFields, NumbOfElements);
  for i := 0 to NumbOfElements - 1 do
  begin
    ArrOfFields[i] := TFieldElements.Create(i, HowManyLines);
    for j := 0 to NumbOfElements - 1 do
      ArrOfFields[i].AddElement(ArrOfElements[j].x,
                                ArrOfElements[j].y,
                                ArrOfElements[j].sign);
    ArrOfFields[i].Calc;
  end;
end;

procedure TFields.Render;
var
  i: Integer;
begin
  for i := 0 to NumbOfElements - 1 do
    ArrOfFields[i].Render;
end;

procedure TFields.AddElement(x, y: Extended; sign: Integer);
begin
  inc(NumbOfElements);
  SetLength(ArrOfElements,NumbOfElements);
  ArrOfElements[NumbOfElements-1].x := x;
  ArrOfElements[NumbOfElements-1].y := y;
  ArrOfElements[NumbOfElements-1].sign := sign;
end;

constructor TFields.Create(HowManyFieldLines: Integer);
begin
  Finalize(ArrOfFields);
  Finalize(ArrOfElements);
  HowManyLines := 0;
  NumbOfElements := 0;
  HowManyLines := HowManyFieldLines;
end;

destructor TFields.Destroy;
var
  i:Integer;
begin
  if NumbOfElements > 0 then
    for i := 0 to NumbOfElements - 1 do
      ArrOfFields[i] := nil;

  HowManyLines := 0;
  NumbOfElements := 0;
  SetLength(ArrOfFields, 0);
  SetLength(ArrOfElements, 0);
  Finalize(ArrOfFields);
  Finalize(ArrOfElements);

  Inherited Destroy;
end;

end.
