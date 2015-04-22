program Game;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormGame},
  UnitGame in 'UnitGame.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormGame, FormGame);
  Application.Run;
end.
