program saint_auth;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON,
  System.Net.HttpClientComponent;

const
  API_URL = 'http://localhost:8080/api/v1';
  API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A';
  API_ID = '1093';
  USER = '001';
  PASSWORD = '12345';
  DEVICE_ID = 'DELPHI_CONSOLE_APP';

function GetToken(): string;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  RequestBody: TStringStream;
  JSONBody: TJSONObject;
  JSONResponse, JSONData: TJSONValue;
  SuccessVal: TJSONValue;
begin
  Result := '';
  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;

  try
    // 1. Configurar Headers
    HTTP.CustomHeaders['x-api-key'] := API_KEY;
    HTTP.CustomHeaders['x-api-id'] := API_ID;
    HTTP.ContentType := 'application/json';

    // 2. Construir Body
    JSONBody.AddPair('username', USER);
    JSONBody.AddPair('password', PASSWORD);
    JSONBody.AddPair('device_id', DEVICE_ID);

    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);

    try
      Writeln('Conectando a: ' + API_URL + '/auth/login');

      Response := HTTP.Post(API_URL + '/auth/login', RequestBody);

      if Response.StatusCode = 200 then
      begin
        // 3. Parsear Respuesta (Metodo compatible sin Generics)
        JSONResponse := TJSONObject.ParseJSONValue
          (Response.ContentAsString(TEncoding.UTF8));
        try
          if Assigned(JSONResponse) and (JSONResponse is TJSONObject) then
          begin
            // Verificar "success" obteniendo el valor como string y comparando
            SuccessVal := (JSONResponse as TJSONObject).GetValue('success');

            if Assigned(SuccessVal) and (LowerCase(SuccessVal.Value) = 'true')
            then
            begin
              // Extraer 'data'
              JSONData := (JSONResponse as TJSONObject).GetValue('data');

              if Assigned(JSONData) and (JSONData is TJSONObject) then
              begin
                // Extraer 'access_token'
                Result := (JSONData as TJSONObject)
                  .GetValue('access_token').Value;
              end;
            end
            else
            begin
              Writeln('Error logico en respuesta: ' +
                (JSONResponse as TJSONObject).GetValue('message').Value);
            end;
          end;
        finally
          JSONResponse.Free;
        end;
      end
      else
      begin
        Writeln('Error HTTP: ' + Response.StatusCode.ToString);
        Writeln('Respuesta: ' + Response.ContentAsString());
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
    Writeln('Iniciando proceso de autenticacion V2...');
    Token := GetToken();

    if Token <> '' then
    begin
      Writeln('');
      Writeln('--------------------------------------------------');
      Writeln('AUTENTICACION EXITOSA');
      Writeln('--------------------------------------------------');
      Writeln('Access Token (JWT):');
      Writeln(Token);
      Writeln('--------------------------------------------------');
    end
    else
    begin
      Writeln('No se pudo obtener el token.');
    end;

    Writeln('');
    Writeln('Presione ENTER para salir...');
    Readln;

  except
    on E: Exception do
    begin
      // AQUI ESTABA EL ERROR: Se requiere begin/end para multiples lineas
      Writeln('Excepcion critica: ', E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;

end.
