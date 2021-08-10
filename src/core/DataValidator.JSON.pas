{
  *************************************
  Created by Danilo Lucas
  Github - https://github.com/dliocode
  *************************************
}

unit DataValidator.JSON;

interface

uses
  DataValidator.Intf, DataValidator.Result.Intf,
  System.Generics.Collections, System.Rtti, System.JSON, System.SysUtils;

type
  TDataValidatorJSON = class(TInterfacedObject, IDataValidatorJSON, IDataValidatorJSONResult)
  private
    FJSON: TJSONValue;
    FList: TList<IDataValidatorJSONBaseContext>;

    function CheckArray(const ACheckAll: Boolean): IDataValidatorResult;
    function CheckObject(const ACheckAll: Boolean): IDataValidatorResult;
    function TValueToString(const AValue: TValue): string;
  public
    function Validate(const AName: string): IDataValidatorJSONBaseContext; overload;
    function Validate(const AName: TArray<string>): IDataValidatorJSONBaseContext; overload;

    function Checked: IDataValidatorResult;
    function CheckedAll: IDataValidatorResult;

    constructor Create(const AJSON: TJSONObject); overload;
    constructor Create(const AJSON: TJSONArray); overload;
    destructor Destroy; override;
  end;

implementation

uses
  DataValidator.Information.Intf, DataValidator.ItemBase.Intf, DataValidator.Context.Intf,
  DataValidator.JSON.Base, DataValidator.Information, DataValidator.ItemBase.Sanitizer, DataValidator.ItemBase;

{ TDataValidatorJSON }

constructor TDataValidatorJSON.Create(const AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    raise Exception.Create('JSON is nil');

  FJSON := AJSON;
  FList := TList<IDataValidatorJSONBaseContext>.Create();
end;

constructor TDataValidatorJSON.Create(const AJSON: TJSONArray);
begin
  if not Assigned(AJSON) then
    raise Exception.Create('JSON is nil');

  FJSON := AJSON;
  FList := TList<IDataValidatorJSONBaseContext>.Create();
end;

destructor TDataValidatorJSON.Destroy;
begin
  FList.Clear;
  FList.DisposeOf;

  inherited;
end;

function TDataValidatorJSON.Validate(const AName: string): IDataValidatorJSONBaseContext;
begin
  Result := Validate([AName]);
end;

function TDataValidatorJSON.Validate(const AName: TArray<string>): IDataValidatorJSONBaseContext;
begin
  FList.Add(TDataValidatorJSONBase.Create(Self, AName, nil));
  Result := FList.Last;
end;

function TDataValidatorJSON.Checked: IDataValidatorResult;
begin
  if FJSON is TJSONObject then
    Result := CheckObject(False)
  else
    if FJSON is TJSONArray then
      Result := CheckArray(False);
end;

function TDataValidatorJSON.CheckedAll: IDataValidatorResult;
begin
  if FJSON is TJSONObject then
    Result := CheckObject(True)
  else
    if FJSON is TJSONArray then
      Result := CheckArray(True);
end;

function TDataValidatorJSON.CheckObject(const ACheckAll: Boolean): IDataValidatorResult;
var
  LOK: Boolean;
  LInfo: IDataValidatorInformations;
  I: Integer;
  LListValidatorItem: TList<IDataValidatorItem>;
  LName: TArray<string>;
  J: Integer;
  LValueSanitizer: TValue;
  LValidatorItem: IDataValidatorItem;
  K: Integer;
  LValidatorResult: IDataValidatorResult;
  LValues: TArray<string>;
begin
  LOK := True;
  LInfo := TDataValidatorInformations.Create;

  for I := 0 to Pred(FList.Count) do
  begin
    LListValidatorItem := (FList.Items[I] as IDataValidatorContextBase<IDataValidatorItem>).GetItem;
    LName := (FList.Items[I] as IDataValidatorJSONValueName).GetName;

    for J := 0 to Pred(Length(LName)) do
    begin
      LValueSanitizer := TValue.From<TJSONPair>((FJSON as TJSONObject).Get(LName[J]));

      for K := 0 to Pred(LListValidatorItem.Count) do
      begin
        LValidatorItem := LListValidatorItem.Items[K];

        if (LValidatorItem is TDataValidatorItemBaseSanitizer) then
        begin
          LValidatorItem.SetValue(LValueSanitizer);
          LValueSanitizer := (LValidatorItem as TDataValidatorItemBaseSanitizer).Sanitize;
          Continue;
        end;

        LValidatorItem.SetValue(LValueSanitizer);

        LValidatorResult := LValidatorItem.Checked;

        if not LValidatorResult.OK then
        begin
          LOK := False;
          LInfo.Add(LValidatorResult.Informations as IDataValidatorInformations);

          if not ACheckAll then
            Break;
        end;
      end;

      LValues := Concat(LValues, [TValueToString(LValueSanitizer)]);
    end;

    if not LOK then
      if not ACheckAll then
        Break;
  end;

  Result := TDataValidatorResult.Create(LOK, LInfo, LValues);
end;

function TDataValidatorJSON.CheckArray(const ACheckAll: Boolean): IDataValidatorResult;
var
  LOK: Boolean;
  LInfo: IDataValidatorInformations;
  I: Integer;
  LListValidatorItem: TList<IDataValidatorItem>;
  LName: TArray<string>;
  J: Integer;
  K: Integer;
  LValueSanitizer: TValue;
  L: Integer;
  LValidatorItem: IDataValidatorItem;
  LValidatorResult: IDataValidatorResult;
  LValues: TArray<string>;
begin
  LOK := True;
  LInfo := TDataValidatorInformations.Create;

  for I := 0 to Pred(FList.Count) do
  begin
    LListValidatorItem := (FList.Items[I] as IDataValidatorContextBase<IDataValidatorItem>).GetItem;
    LName := (FList.Items[I] as IDataValidatorJSONValueName).GetName;

    for J := 0 to Pred((FJSON as TJSONArray).Count) do
    begin
      if not((FJSON as TJSONArray).Items[J] is TJSONObject) then
        Continue;

      for K := 0 to Pred(Length(LName)) do
      begin
        LValueSanitizer := TValue.From<TJSONPair>(((FJSON as TJSONArray).Items[J] as TJSONObject).Get(LName[K]));

        for L := 0 to Pred(LListValidatorItem.Count) do
        begin
          LValidatorItem := LListValidatorItem.Items[L];

          if (LValidatorItem is TDataValidatorItemBaseSanitizer) then
          begin
            LValidatorItem.SetValue(LValueSanitizer);
            LValueSanitizer := (LValidatorItem as TDataValidatorItemBaseSanitizer).Sanitize;
            Continue;
          end;

          LValidatorItem.SetValue(LValueSanitizer);

          LValidatorResult := LValidatorItem.Checked;

          if not LValidatorResult.OK then
          begin
            LOK := False;
            LInfo.Add(LValidatorResult.Informations as IDataValidatorInformations);

            if not ACheckAll then
              Break;
          end;
        end;

        LValues := Concat(LValues, [TValueToString(LValueSanitizer)]);
      end;
    end;

    if not LOK then
      if not ACheckAll then
        Break;
  end;

  Result := TDataValidatorResult.Create(LOK, LInfo, LValues);
end;

function TDataValidatorJSON.TValueToString(const AValue: TValue): string;
var
  LJSONPair: TJSONPair;
begin
  Result := '';

  if AValue.IsType<TJSONPair> then
  begin
    LJSONPair := AValue.AsType<TJSONPair>;
    if Assigned(LJSONPair) then
      Result := LJSONPair.JsonValue.Value;
  end
  else
    Result := AValue.AsString;
end;

end.
