program lectura_datos;

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
  DEVICE_ID = 'DELPHI_APP_02'; // Requerido en v2

function IniciarSesion: string;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  RequestBody: TStringStream;
  JSONBody: TJSONObject;
  JSONResponse, JSONData: TJSONValue;
begin
  Result := '';
  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;
  try
    // 1. Headers de Identificacion (Solo para Login)
    HTTP.CustomHeaders['x-api-key'] := API_KEY;
    HTTP.CustomHeaders['x-api-id'] := API_ID;
    HTTP.ContentType := 'application/json';

    // 2. Body JSON con credenciales
    JSONBody.AddPair('username', USER);
    JSONBody.AddPair('password', PASSWORD);
    JSONBody.AddPair('device_id', DEVICE_ID);

    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);
    try
      // 3. Endpoint actualizado /auth/login
      Response := HTTP.Post(API_URL + '/auth/login', RequestBody);

      if Response.StatusCode = 200 then
      begin
        // 4. Parsear JSON para sacar el Token
        JSONResponse := TJSONObject.ParseJSONValue
          (Response.ContentAsString(TEncoding.UTF8));
        try
          if Assigned(JSONResponse) and (JSONResponse is TJSONObject) then
          begin
            JSONData := (JSONResponse as TJSONObject).GetValue('data');
            if Assigned(JSONData) and (JSONData is TJSONObject) then
              Result := (JSONData as TJSONObject)
                .GetValue('access_token').Value;
          end;
        finally
          JSONResponse.Free;
        end;
      end
      else
        Writeln('Error Login: ' + Response.StatusText);
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
  JSONRoot, JSONData: TJSONValue;
  JSONArray: TJSONArray;
  I: Integer;
  Item: TJSONObject;
  Endpoint: string;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    // 1. Endpoint actualizado (sin /adm) y filtros en URL
    // Nota: 'existen' debe ser un campo valido en tu BD o View
    Endpoint := API_URL + '/products?existen>0&limit=5';

    // 2. Header Authorization Bearer
    HTTP.CustomHeaders['Authorization'] := 'Bearer ' + AToken;

    Response := HTTP.Get(Endpoint);

    if Response.StatusCode = 200 then
    begin
      JSONRoot := TJSONObject.ParseJSONValue
        (Response.ContentAsString(TEncoding.UTF8));
      try
        // 3. Validar estructura v2 { success: true, data: [...] }
        if (JSONRoot is TJSONObject) and (JSONRoot as TJSONObject)
          .GetValue('success').Value.ToBoolean then
        begin
          // Extraer el array de la propiedad 'data'
          JSONData := (JSONRoot as TJSONObject).GetValue('data');

          if JSONData is TJSONArray then
          begin
            JSONArray := JSONData as TJSONArray;
            Writeln(Format('Productos encontrados: %d', [JSONArray.Count]));
            Writeln('----------------------------------------------------');

            for I := 0 to JSONArray.Count - 1 do
            begin
              Item := JSONArray.Items[I] as TJSONObject;
              // 4. Usar .GetValue().Value para compatibilidad
              Writeln(Format('Cod: %-10s | Stock: %-6s | Desc: %s',
                [Item.GetValue('codprod').Value, Item.GetValue('existen').Value,
                Item.GetValue('descrip').Value]));
            end;
          end;
        end
        else
          Writeln('Error logico o sin datos: ' + Response.ContentAsString);
      finally
        JSONRoot.Free;
      end;
    end
    else
      Writeln('Error HTTP en consulta: ' + Response.StatusText);
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
      Writeln('No se pudo establecer sesion.');

    Writeln('Presione Enter para salir...');
    ReadLn;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ReadLn; // Pausa para ver el error
    end;
  end;

end.
