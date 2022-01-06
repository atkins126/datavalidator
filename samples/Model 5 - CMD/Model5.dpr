program Model5;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  DataValidator;

function Valid(const AApelido: string; const AEmail: string): IDataValidatorResult;
begin
  Result :=

    TDataValidator.Values

    .Validate(AApelido)
      .Trim
      .&Not.IsEmpty.WithMessage('Voc� n�o informou o seu apelido!')
      .IsAlpha(TDataValidatorLocaleLanguage.tl_pt_BR).WithMessage('Seu apelido deve conter apenas letras!')
      .IsLength(1, 10).WithMessage('O apelido deve ter no m�ximo 10 caracteres!')
    .&End

    .Validate(AEmail)
      .Trim
      .&Not.IsEmpty.WithMessage('Voc� n�o informou o seu e-mail!')
      .IsEmail.WithMessage('N�o � um e-mail v�lido!')
      .NormalizeEmail
    .&End

    .CheckAll;
end;

var
  LApelido: string;
  LEmail: string;
  LResult: IDataValidatorResult;

begin
  repeat
    Writeln;
    Write(' Digite seu apelido: ');
    Readln(LApelido);

    Write(' Digite seu e-mail: ');
    Readln(LEmail);

    Writeln;
    LResult := Valid(LApelido, LEmail);

    if not LResult.OK then
    begin
      Writeln('-------------------------------------');
      Writeln;
      Write(LResult.Informations.Message);
      Writeln;
      Writeln(' Tente novamente!');
      Writeln;
      Writeln('-------------------------------------');
    end;

  until LResult.OK;

  Writeln('Parab�ns: tudo certo por aqui!');

  Readln;
end.
