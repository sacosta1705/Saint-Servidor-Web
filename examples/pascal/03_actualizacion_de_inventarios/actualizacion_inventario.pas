unit actualizacion_inventario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Net.HttpClientComponent,
  System.Net.HttpClient, System.Net.URLClient, System.NetEncoding, System.JSON;

type
  TForm1 = class(TForm)
    edCodProd: TEdit;
    edNuevaExistencia: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    memoLog: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private const
    API_URL = 'http://localhost:8080/api/v1';
    API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A';
    API_ID = '1093';
    function IniciarSesion: string;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.IniciarSesion: string;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONBody: TJSONObject;
  RequestBody: TStringStream;
  AuthB64: string;
begin
  Result := '';
  memoLog.Lines.Add('>> INICIO SESION: Creando cliente HTTP...');
  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;
  try
    memoLog.Lines.Add
      ('>> INICIO SESION: Codificando credenciales Basic Auth...');
    AuthB64 := TNetEncoding.Base64.Encode('001:12345').Replace(#13, '')
      .Replace(#10, '');

    HTTP.CustomHeaders['x-api-key'] := API_KEY;
    HTTP.CustomHeaders['x-api-id'] := API_ID;
    HTTP.CustomHeaders['Authorization'] := 'Basic ' + AuthB64;
    HTTP.ContentType := 'application/json';

    JSONBody.AddPair('terminal', 'delphi');
    memoLog.Lines.Add('>> INICIO SESION: Cuerpo login: ' + JSONBody.ToString);

    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);
    try
      Response := HTTP.Post(API_URL + '/main/login', RequestBody);
      memoLog.Lines.Add('>> INICIO SESION: Respuesta Status: ' +
        Response.StatusCode.ToString);

      if Response.StatusCode = 200 then
      begin
        Result := Response.HeaderValue['Pragma'];
        memoLog.Lines.Add('>> INICIO SESION: Token Pragma recibido con Exito: '
          + Result);
      end;
    finally
      RequestBody.Free;
    end;
  finally
    JSONBody.Free;
    HTTP.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  HTTP: TNetHTTPClient;
  Token: string;
  RequestBody: TStringStream;
  JSONData: TJSONObject;
  Response: IHTTPResponse;
  Endpoint: string;
  JsonString: string;
begin
  memoLog.Lines.Clear;
  memoLog.Lines.Add('1. Solicitando sesion...');
  Token := IniciarSesion;

  if Token = '' then Exit;

  HTTP := TNetHTTPClient.Create(nil);
  JSONData := TJSONObject.Create;
  try
    // Mantenemos el flotante como en tu prueba de Postman
    JSONData.AddPair('existen', TJSONNumber.Create(StrToFloatDef(edNuevaExistencia.Text, 0)));
    JsonString := JSONData.ToString;

    Endpoint := API_URL + '/adm/product/' + edCodProd.Text;

    HTTP.CustomHeaders['Pragma'] := Token;
    // Eliminamos cualquier header previo para evitar conflictos
    HTTP.CustomHeaders['Accept'] := 'application/json';

    // IMPORTANTE: UTF8 sin BOM (Byte Order Mark)
    // Delphi por defecto añade bytes de control al inicio del stream que Postman NO envía.
    // El servidor puede estar fallando al intentar castear esos bytes.
    RequestBody := TStringStream.Create(JsonString, TEncoding.UTF8, False);
    try
      memoLog.Lines.Add('5. Enviando JSON (Sin BOM): ' + JsonString);

      // Enviamos usando el arreglo de headers para asegurar el Content-Type correcto
      Response := HTTP.Put(Endpoint, RequestBody, nil,
        [TNetHeader.Create('Content-Type', 'application/json')]);

      memoLog.Lines.Add('6. Respuesta del servidor...');
      if Response.StatusCode in [200, 201] then
        memoLog.Lines.Add('Éxito: Producto actualizado correctamente.')
      else
        memoLog.Lines.Add('Fallo: ' + Response.StatusCode.ToString + ' - ' + Response.ContentAsString);

    finally
      RequestBody.Free;
    end;
  finally
    JSONData.Free;
    HTTP.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  memoLog.Lines.Clear;
end;

end.
