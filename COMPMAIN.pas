unit COMPMAIN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, BZip2,UITypes;

type
  TWinBZ2Form = class(TForm)
    EdUncomp: TEdit;
    EdComp: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ODUncomp: TOpenDialog;
    ODComp: TOpenDialog;
    bbCompress: TBitBtn;
    bbUncompress: TBitBtn;
    ProgressBar1: TProgressBar;
    sbUncomp: TSpeedButton;
    sbComp: TSpeedButton;
    cikis: TButton;
    Label3: TLabel;
    procedure bbCompressClick(Sender: TObject);
    procedure bbUncompressClick(Sender: TObject);
    procedure sbUncompClick(Sender: TObject);
    procedure sbCompClick(Sender: TObject);
    procedure cikisClick(Sender: TObject);
  private
    { Private declarations }
    FSource: TStream;
    procedure DoCompress(const ASource, ADest: TFileName); overload;
    procedure DoCompress(ASource, ADest: TStream); overload;
    procedure DoUncompress(const ASource, ADest: TFileName); overload;
    procedure DoUncompress(ASource, ADest: TStream); overload;
    procedure ProgressBZip2(Sender: TObject);
  public
    { Public declarations }
  end;

var
  WinBZ2Form: TWinBZ2Form;

implementation

{$R *.dfm}

procedure TWinBZ2Form.bbCompressClick(Sender: TObject);
begin
  if FileExists(EdUncomp.Text) then
  begin
    if not FileExists(EdComp.Text)
      or (MessageDlg('Sýkýþtýrýlmýþ Dosya Mevcut...Üzerine Yazýlmasýný Ýstermisiniz?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      DoCompress(EdUncomp.Text, EdComp.Text);
    end;
  end
  else
    MessageDlg('Sýkýþtýrýlmýþ Dosya Mevcut Deðil...', mtError, [mbOk], 0);
end;

procedure TWinBZ2Form.bbUncompressClick(Sender: TObject);
begin
  if FileExists(EdComp.Text) then
  begin
    if not FileExists(EdUncomp.Text)
      or (MessageDlg('Açýlmýþ Dosya Mevcut...Üzerine Yazýlmasýný Ýstermisiniz?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      DoUnCompress(EdComp.Text, EdUncomp.Text);
    end;
  end
  else
    MessageDlg('Açýlmýþ Dosya Mevcut Deðil...', mtError, [mbOk], 0);
end;

procedure TWinBZ2Form.cikisClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TWinBZ2Form.sbUncompClick(Sender: TObject);
begin
  ODUncomp.FileName := EdUncomp.Text;
  if ODUncomp.Execute then
  begin
    EdUncomp.Text := ODUncomp.FileName;
    if EdComp.Text = '' then
      EdComp.Text := ODUncomp.FileName + '.bz2';
  end;
end;

procedure TWinBZ2Form.sbCompClick(Sender: TObject);
begin
  ODComp.FileName := EdComp.Text;
  if ODComp.Execute then
  begin
    EdComp.Text := ODComp.FileName;
    if EdUncomp.Text = '' then
      EdUncomp.Text := ChangeFileExt(ODUncomp.FileName, '');
  end;
end;

procedure TWinBZ2Form.DoCompress(const ASource, ADest: TFileName);
var
  Source, Dest: TStream;
begin
  Source := TFileStream.Create(ASource, fmOpenRead + fmShareDenyWrite);
  try
    Dest := TFileStream.Create(ADest, fmCreate);
    try
      DoCompress(Source, Dest);
    finally
      Dest.Free;
    end;
  finally
    Source.Free;
  end;
end;

procedure TWinBZ2Form.DoCompress(ASource, ADest: TStream);
var
  Comp: TBZCompressionStream;
begin
  FSource := ASource;
  ProgressBar1.Max := FSource.Size;
  Comp := TBZCompressionStream.Create(bs9, ADest);
  try
    Comp.OnProgress := ProgressBZip2;
    Comp.CopyFrom(ASource, 0);
  finally
    Comp.Free;
    FSource := nil;
    Sleep(3);
    MessageDlg('Sýkýþtýrma iþlemi Tamamlandý...', mtConfirmation, [mbClose], 0);
    ProgressBar1.Position:=0;
  end;
end;

procedure TWinBZ2Form.DoUncompress(const ASource, ADest: TFileName);
var
  Source, Dest: TStream;
begin
  Source := TFileStream.Create(ASource, fmOpenRead + fmShareDenyWrite);
  try
    Dest := TFileStream.Create(ADest, fmCreate);
    try
      DoUncompress(Source, Dest);
    finally
      Dest.Free;
    end;
  finally
    Source.Free;
  end;
end;

procedure TWinBZ2Form.DoUncompress(ASource, ADest: TStream);
const
  BufferSize = 65536;
var
  Count: Integer;
  Decomp: TBZDecompressionStream;
  Buffer: array[0..BufferSize - 1] of Byte;
begin
  FSource := ASource;
  ProgressBar1.Max := FSource.Size;
  Decomp := TBZDecompressionStream.Create(ASource);
  try
    Decomp.OnProgress := ProgressBZip2;
    while True do
    begin
      Count := Decomp.Read(Buffer, BufferSize);
      if Count <> 0 then ADest.WriteBuffer(Buffer, Count) else Break;
    end;
  finally
    Decomp.Free;
    FSource := nil;
    Sleep(3);
    MessageDlg('Açma iþlemi Tamamlandý...', mtConfirmation, [mbClose], 0);
    ProgressBar1.Position:=0;
  end;
end;

procedure TWinBZ2Form.ProgressBZip2(Sender: TObject);
begin
  ProgressBar1.Position := FSource.Position;
end;

end.

