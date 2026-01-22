program lectura_datos;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.NetEncoding,
  System.Net.HttpClientComponent,
  System.JSON,
  System.Generics.Collections;

const
  API_URL = 'http://localhost:8080/api/v1';
  API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A';
  API_ID = '1093';
  USER = '001';
  PASSWORD = '12345';

function IniciarSesion: string;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  RequestBody: TStringStream;
  AuthB64: string;
  JSONBody: TJSONObject;
begin
  Result := '';
  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;
  try
    AuthB64 := TNetEncoding.Base64.Encode(USER + ':' + PASSWORD);
    HTTP.CustomHeaders['x-api-key'] := API_KEY;
    HTTP.CustomHeaders['x-api-id'] := API_ID;
    HTTP.CustomHeaders['Authorization'] := 'Basic ' + AuthB64;
    HTTP.ContentType := 'application/json';
    JSONBody.AddPair('terminal', 'delphi_listing');
    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);
    try
      Response := HTTP.Post(API_URL + '/main/login', RequestBody);
      if Response.StatusCode = 200 then
        Result := Response.HeaderValue['Pragma'];
    finally
      RequestBody.Free;
    end;
  finally
    JSONBody.Free;
    HTTP.Free;
  end;
end;

procedure ConsultarExistencias(const AToken: string);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSonData: TJSONValue;
  JSONArray: TJSONArray;
  I: Integer;
  Item: TJSONValue;
  Endpoint: string;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Endpoint := API_URL + '/adm/products?existen>0&limit=5';

    HTTP.CustomHeaders['Pragma'] := AToken;

    Response := HTTP.Get(Endpoint);

    if Response.StatusCode = 200 then
    begin
      JSonData := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        if JSonData is TJSONArray then
        begin
          JSONArray := JSonData as TJSONArray;
          WriteLn(Format('Productos encontrados: %d', [JSONArray.Count]));
          WriteLn('----------------------------------------------------');

          for I := 0 to JSONArray.Count - 1 do
          begin
            Item := JSONArray.Items[I];
            WriteLn(Format('Cod: %-10s | Stock: %-6s | Desc: %s',
              [Item.GetValue<string>('codprod'),
              Item.GetValue<string>('existen'),
              Item.GetValue<string>('descrip')]));
          end;
        end;
      finally
        JSonData.Free;
      end;
    end
    else
      WriteLn('Error en consulta: ' + Response.StatusText);
  finally
    HTTP.Free;
  end;
end;

var
  SessionToken: string;

begin
  try
    SessionToken := IniciarSesion;
    if SessionToken <> '' then
      ConsultarExistencias(SessionToken)
    else
      WriteLn('No se pudo establecer sesion.');

    WriteLn('Presione Enter para salir...');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
