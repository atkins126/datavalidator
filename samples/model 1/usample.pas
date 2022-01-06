unit usample;

interface

uses
  DataValidator,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    LabeledEditNome: TLabeledEdit;
    LabeledEditIdade: TLabeledEdit;
    LabeledEditDataNascimento: TLabeledEdit;
    LabeledEditResultado: TLabeledEdit;
    LabelMatematica: TLabel;
    btnValidarTodos: TButton;
    LabeledEditCNPJ: TLabeledEdit;
    LabeledEditCPF: TLabeledEdit;
    LabeledEditEmail: TLabeledEdit;
    LabeledEditCPFCNPJ: TLabeledEdit;
    Memo1: TMemo;
    btnValidar: TButton;
    procedure btnValidarTodosClick(Sender: TObject);
    procedure btnValidarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Valid: IDataValidatorValueResult;
    procedure ShowResult(const AResult: IDataValidatorResult);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnValidarClick(Sender: TObject);
begin
  ShowResult(Valid.Check);
end;

procedure TForm1.btnValidarTodosClick(Sender: TObject);
begin
  ShowResult(Valid.CheckAll);
end;

procedure TForm1.ShowResult(const AResult: IDataValidatorResult);
begin
  Memo1.Clear;

  if AResult.OK then
    Exit;

  Memo1.Text := AResult.Informations.Message;
  Memo1.Lines.Add(Format('Value validate: %s',[AResult.Informations.GetItem(0).Value]));
  Memo1.Lines.Add(Format('Total errors: %d',[AResult.Informations.Count]));

  AResult.Informations.GetItem(0).OnExecute;
end;

function TForm1.Valid: IDataValidatorValueResult;
begin
  Result :=

  TDataValidator.Values

  .Validate(LabeledEditNome.Text).Execute(LabeledEditNome.SetFocus)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe um nome!') // N�o pode ser vazio
    .IsLength(0,10).WithMessage('O nome deve conter no m�ximo 10 caracteres!')
    .IsAlpha(TDataValidatorLocaleLanguage.tl_pt_BR).WithMessage('Nome com caracteres inv�lidos!')
  .&End

  .Validate(LabeledEditIdade.Text)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe a idade!') // N�o pode ser vazio
    .IsNumeric.WithMessage('Deve ser n�merico!')
    .&Not.IsNegative.WithMessage('A idade n�o pode ser negativo!')
    .&Not.IsZero.WithMessage('A idade n�o pode ser zero!')
    .&Not.IsLessThan(18).WithMessage('N�o � permitido idade menor que 18!')
    .&Not.IsGreaterThan(64).WithMessage('N�o � permitido idade maior que 64!')
  .&End

  .Validate(LabeledEditDataNascimento.Text)
    .IsDate.WithMessage('Data de Nascimento inv�lida!')
    .&Not.IsDateGreaterThan(Now).WithMessage('Data de Nascimento n�o pode ser maior que e a data atual!')
  .&End

  .Validate(LabeledEditResultado.Text)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe o resultado!') // N�o pode ser vazio
    .IsEquals('1').WithMessage('Resultado inv�lido!')
  .&End

  .Validate(LabeledEditCNPJ.Text)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe o CNPJ!') // N�o pode ser vazio
    .IsCNPJ.WithMessage('CNPJ inv�lido!')
  .&End

  .Validate(LabeledEditCPF.Text)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe o CPF!') // N�o pode ser vazio
    .IsCPF.WithMessage('CPF inv�lido!')
  .&End

  .Validate(LabeledEditCPFCNPJ.Text)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe o CPF ou CNPJ!') // N�o pode ser vazio
    .IsCPFCNPJ.WithMessage('CPF/CNPJ inv�lido!')
  .&End

  .Validate(LabeledEditEmail.Text)
    .Trim
    .&Not.IsEmpty.WithMessage('Informe o Email!') // N�o pode ser vazi
    .IsEmail.WithMessage('Email inv�lido!')
  .&End
end;

end.
