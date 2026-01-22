program saint_auth;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.NetEncoding,
  System.JSON,
  System.Net.HttpClientComponent;

const
  API_URL = 'http://localhost:8080/api/v1';
  API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A';
  API_ID = '1093';
  USER = '001';
  PASSWORD = '12345';

function GetToken(): string;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  RequestBody: TStringStream;
  AuthStr, AuthB64: string;
  JSONBody: TJSONObject;
begin
  Result := '';
  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;

  try
    AuthStr := USER + ':' + PASSWORD;
    AuthB64 := TNetEncoding.Base64.Encode(AuthStr);

    HTTP.CustomHeaders['x-api-key'] := API_KEY;
    HTTP.CustomHeaders['x-api-id'] := API_ID;
    HTTP.CustomHeaders['Authorization'] := 'Basic ' + AuthB64;
    HTTP.ContentType := 'application/json';

    JSONBody.AddPair('terminal', 'dephi');
    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);

    try
      Response := HTTP.Post(API_URL + '/main/login', RequestBody);

      if Response.StatusCode = 200 then
      begin
        Result := Response.HeaderValue['pragma'];
      end
      else
      begin
        Writeln('error de autenticacion: ' + Response.StatusCode.ToString);
        Writeln('respuesta: ' + Response.ContentAsString());
      end;

    finally
      RequestBody.Free;
    end;
  finally
    JSONBody.Free;
    HTTP.Free;
  end;
end;

var
  Token: string;
begin
  try
    Writeln('iniciando sesion');
    Token := GetToken();

    if Token <> '' then begin
      Writeln('token recibido: ' + Token);
    end;

    Writeln('presione enter para salir...');
    Readln;
  except on E: Exception do
    Writeln(E.ClassName, ': ', E.Message);
  end;
end.
