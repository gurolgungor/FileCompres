program FileCompres;

uses
  Forms,
  COMPMAIN in 'COMPMAIN.pas' {WinBZ2Form};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dosya S�k��t�rma Program�';
  Application.CreateForm(TWinBZ2Form, WinBZ2Form);
  Application.Run;
end.
