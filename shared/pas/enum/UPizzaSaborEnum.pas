unit UPizzaSaborEnum;

interface

type
  TPizzaSaborEnum = (enCalabresa, enMarguerita, enPortuguesa);

  function StrToPizzaSaborEnum(Value: string): TPizzaSaborEnum;
  function getNomePizzaSaborEnum(Value: TPizzaSaborEnum): string;

implementation

uses
  System.TypInfo, System.SysUtils;

function StrToPizzaSaborEnum(Value: string): TPizzaSaborEnum;
begin
  Result := TPizzaSaborEnum(GetEnumValue(TypeInfo(TPizzaSaborEnum), Value));
end;

function getNomePizzaSaborEnum(Value: TPizzaSaborEnum): string;
begin
  Result := EmptyStr;
  case Value of
    enCalabresa  : Result := 'Calabresa';
    enMarguerita : Result := 'Marguerita';
    enPortuguesa : Result := 'Portuguesa';
  end;
end;

end.
