{
  *************************************
  Created by Danilo Lucas
  Github - https://github.com/dliocode
  *************************************
}

unit Validator.IsLength;

interface

uses
  DataValidator.ItemBase,
  System.SysUtils;

type
  TValidatorIsLength = class(TDataValidatorItemBase, IDataValidatorItem)
  private
    FMin: Integer;
    FMax: Integer;
  public
    function Checked: IDataValidatorResult;
    constructor Create(const AMin: Integer; const AMax: Integer; const AMessage: string; const AExecute: TDataValidatorInformationExecute = nil);
  end;

implementation

{ TValidatorIsLength }

constructor TValidatorIsLength.Create(const AMin: Integer; const AMax: Integer; const AMessage: string; const AExecute: TDataValidatorInformationExecute = nil);
begin
  FMin := AMin;
  FMax := AMax;

  FMessage := AMessage;
  FExecute := AExecute;
end;

function TValidatorIsLength.Checked: IDataValidatorResult;
var
  LValue: string;
  R: Boolean;
begin
  LValue := GetValueAsString;
  R := False;

  if not Trim(LValue).IsEmpty then
  begin
    R := Length(LValue) >= FMin;

    if R then
      R := Length(LValue) <= FMax;
  end;

  if FIsNot then
    R := not R;

  Result := TDataValidatorResult.New(R, TDataValidatorInformation.New(LValue, FMessage, FExecute));
end;

end.