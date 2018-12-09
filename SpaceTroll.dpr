program SpaceTroll;

uses
  Forms,
  Main in 'Main.pas' {FormTroll},
  Naves in 'Naves.pas',
  DModule in '..\Delphi6_Projetos\ProjetoNave_01\DModule.pas' {Dados: TDataModule},
  Fase1 in 'Fase1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormTroll, FormTroll);
  Application.CreateForm(TDados, Dados);
  Application.Run;
end.
