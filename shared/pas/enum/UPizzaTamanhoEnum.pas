unit UPizzaTamanhoEnum;

interface

type
  TPizzaTamanhoEnum = (enPequena, enMedia, enGrande);

  function StrToPizzaTamanhoEnum(Value: string): TPizzaTamanhoEnum;
  function getNomePizzaTamanhoEnum(Value: TPizzaTamanhoEnum): string;

implementation

uses
  System.TypInfo, System.SysUtils;

function StrToPizzaTamanhoEnum(Value: string): TPizzaTamanhoEnum;
begin
  Result := TPizzaTamanhoEnum(GetEnumValue(TypeInfo(TPizzaTamanhoEnum), Value));
end;

function getNomePizzaTamanhoEnum(Value: TPizzaTamanhoEnum): string;
begin
  Result := EmptyStr;
  case Value of
    enPequena : Result := 'Pequena';
    enMedia   : Result := 'Média';
    enGrande  : Result := 'Grande';
  end;
end;

end.
