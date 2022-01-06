program Model10;

uses
  DataValidator,
  Horse, Horse.Jhonson, System.JSON, System.SysUtils, System.DateUtils;

procedure DataValidatorMiddleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LBody: System.JSON.TJSONObject;
  LValid: IDataValidatorResult;
begin
  // GetBody
  try
    LBody := Req.Body<System.JSON.TJSONObject>;

    if not Assigned(LBody) then
    begin
      Res.Status(THTTPStatus.BadRequest).Send('JSON body inv�lido!');
      raise EHorseCallbackInterrupted.Create;
    end;
  except
    on E: Exception do
    begin
      Res.Status(THTTPStatus.BadRequest).Send('JSON body inv�lido! Message: ' + E.Message);
      raise EHorseCallbackInterrupted.Create;
    end;
  end;

  // Validation
  LValid :=

    TDataValidator.JSON(LBody)
    .Validate('nome')
      .Key
        .IsRequired.WithMessage('Key "nome" n�o informado!')
      .&End

      .Value
        .Trim
        .&Not.IsEmpty.WithMessage('O campo nome n�o foi preenchido!')
        .IsAlpha(TDataValidatorLocaleLanguage.tl_pt_BR).WithMessage('O campo nome n�o pode possuir caracters especiais!')
        .IsLength(3, 100).WithMessage('O campo nome deve ter no m�nimo 3 caracters e no m�zimo 100')
      .&End
    .&End

    .Validate('email')
      .Key
        .IsRequired.WithMessage('Key "email" n�o informado!')
      .&End

      .Value
        .Trim
        .&Not.IsEmpty.WithMessage('Informe o e-mail!')
        .IsLength(6, 100).WithMessage('Informe um e-mail maior que 5 caracteres!')
        .NormalizeEmail(True, False).IsEmail.WithMessage('E-mail inv�lido!')
        .CustomValue(
        function(const AValue: string): Boolean
        begin
          // Recebe o valor no AValue para analisar e fazer o que for necess�rio
          //
          // Ex:
          // Consulta no banco verifica se esse email j� existe;
          //
          // Result -> True = significa tudo certo! - False = significa que tem algum problema

          Result := AValue = 'developer.dlio@gmail.com';

        end).WithMessage('E-mail j� cadastrado!')
      .&End
    .&End

    .Validate('data_nascimento')
      .Key
        .IsRequired.WithMessage('Key "data_nascimento" n�o informado!')
      .&End

      .Value
        .Trim
        .&Not.IsEmpty.WithMessage('Informe a data de nascimento!')
        .IsDate.WithMessage('Data de nascimento inv�lida!')
        .IsDateLessThan(Now).WithMessage('A data de nascimento n�o pode ser maior que a data atual!')
        .IsDateGreaterThan(IncYear(Now, -100)).WithMessage('A data de nascimento n�o pode ser menor que 100 anos atr�s!')
      .&End
    .&End

    .Validate('telefone')
      .Key
        .IsRequired.WithMessage('Key "telefone" n�o informado!')
      .&End

      .Value
        .Trim
        .&Not.IsEmpty.WithMessage('Informe o telefone!')
        .IsPhoneNumber(TDataValidatorLocaleLanguage.tl_pt_BR).WithMessage('N�mero de telefone inv�lido!')
      .&End
    .&End

    .Validate('cpf')
      .Key
        .IsRequired.WithMessage('Key "cpf" n�o informado!')
      .&End

      .Value
        .Trim
        .&Not.IsEmpty.WithMessage('Informe o CPF!')
        .IsLength(14, 14).WithMessage('Informe corretamente todos os d�gitos do CPF!')
        .OnlyNumbers.IsCPF.WithMessage('CPF inv�lido!')
      .&End
    .&End

    .Check;

  if LValid.OK then
    Next
  else
  begin
    Res.Status(THTTPStatus.BadRequest).Send(LValid.Informations.Message);
    raise EHorseCallbackInterrupted.Create;
  end;
end;

procedure ControllerRegister(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LBody: TJSONObject;
begin
  LBody := Req.Body<TJSONObject>;

  // FAz o que quiser, pois foi validado no middleware desta rota
  // se chegou at� aqui, significa que est� tudo certo

  Res.Send<TJSONObject>(LBody);
end;

begin
// Router:
// POST http://localhost:9000/register

// Body
// JSON Test
{
    "nome":"Danilo Lucas",
    "email":"developer.dlio@gmail.com",
    "data_nascimento":"23/08/1994",
    "telefone":"48999999999",
    "cpf":"012.345.678-90"
}

  THorse.Use(Jhonson());

  THorse.Post('/register', DataValidatorMiddleware, ControllerRegister);

  THorse.Listen(9000);

end.
