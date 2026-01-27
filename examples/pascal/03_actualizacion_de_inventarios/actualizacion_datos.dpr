program actualizacion_datos;

uses
  System.StartUpCopy,
  FMX.Forms,
  act_datos in 'act_datos.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
