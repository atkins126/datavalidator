{
  *************************************
  Created by Danilo Lucas
  Github - https://github.com/dliocode
  *************************************
}

unit Validator.IsTimeEquals;

interface

uses
  DataValidator.ItemBase,
  System.SysUtils, System.DateUtils, System.Types;

type
  TValidatorIsTimeEquals = class(TDataValidatorItemBase, IDataValidatorItem)
  private
    FCompareTime: TTime;
  public
    function Checked: IDataValidatorResult;
    constructor Create(const ACompareTime: TTime; const AMessage: string; const AExecute: TDataValidatorInformationExecute = nil);
  end;

implementation

{ TValidatorIsTimeEquals }

constructor TValidatorIsTimeEquals.Create(const ACompareTime: TTime; const AMessage: string; const AExecute: TDataValidatorInformationExecute = nil);
begin
  FCompareTime := ACompareTime;
  FMessage := AMessage;
  FExecute := AExecute;
end;

function TValidatorIsTimeEquals.Checked: IDataValidatorResult;
var
  LValue: string;
  R: Boolean;
  LTime: TDateTime;
begin
  LValue := GetValueAsString;
  R := False;

  if TryStrToTime(LValue, LTime) then
    R := CompareTime(LTime, FCompareTime) = EqualsValue;

  if FIsNot then
    R := not R;

  Result := TDataValidatorResult.New(R, TDataValidatorInformation.New(LValue, FMessage, FExecute));
end;

end.