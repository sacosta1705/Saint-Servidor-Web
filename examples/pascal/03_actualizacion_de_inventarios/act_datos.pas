unit act_datos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation,
  Winapi.Windows, Winapi.Messages, System.Net.HttpClientComponent,
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
    USER = '001';
    PASSWORD = '12345';
    DEVICE_ID = 'DELPHI_DESKTOP_CLIENT';
    function IniciarSesion: string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  memoLog.Lines.Clear();
end;

function TForm1.IniciarSesion: string;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONBody: TJSONObject;
  JSONResponse, JSONData: TJSONValue;
  RequestBody: TStringStream;
begin
  Result := '';
  memoLog.Lines.Add('>> AUTH: Iniciando proceso de login V2...');

  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;
  try
    HTTP.CustomHeaders['x-api-key'] := API_KEY;
    HTTP.CustomHeaders['x-api-id'] := API_ID;
    HTTP.ContentType := 'application/json';

    JSONBody.AddPair('username', USER);
    JSONBody.AddPair('password', PASSWORD);
    JSONBody.AddPair('device_id', DEVICE_ID);

    memoLog.Lines.Add('>> AUTH: Enviando credenciales a /auth/login...');

    RequestBody := TStringStream.Create(JSONBody.ToString, TEncoding.UTF8);
    try
      Response := HTTP.Post(API_URL + '/auth/login', RequestBody);

      memoLog.Lines.Add('>> AUTH: Estado HTTP: ' +
        Response.StatusCode.ToString);

      if Response.StatusCode = 200 then
      begin
        JSONResponse := TJSONObject.ParseJSONValue
          (Response.ContentAsString(TEncoding.UTF8));
        try
          if (JSONResponse is TJSONObject) then
          begin
            if (JSONResponse as TJSONObject).GetValue('success').Value.ToBoolean
            then
            begin
              JSONData := (JSONResponse as TJSONObject).GetValue('data');
              if (JSONData is TJSONObject) then
              begin
                Result := (JSONData as TJSONObject)
                  .GetValue('access_token').Value;
                memoLog.Lines.Add('>> AUTH: Token JWT recibido correctamente.');
              end;
            end
            else
              memoLog.Lines.Add('>> AUTH Error Lógico: ' +
                (JSONResponse as TJSONObject).GetValue('message').Value);
          end;
        finally
          JSONResponse.Free;
        end;
      end
      else
        memoLog.Lines.Add('>> AUTH Fallo: ' + Response.ContentAsString);

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
  JSONResp: TJSONValue;

begin
  memoLog.Lines.Clear;

  Token := IniciarSesion;

  if Token = '' then
  begin
    ShowMessage
      ('No se pudo autenticar. Verifique las credenciales y el servidor.');
    Exit;
  end;

  HTTP := TNetHTTPClient.Create(nil);
  JSONData := TJSONObject.Create;
  try
    JSONData.AddPair('existen',
      TJSONNumber.Create(StrToFloatDef(edNuevaExistencia.Text, 0)));
    JsonString := JSONData.ToString;

    Endpoint := API_URL + '/products/' + edCodProd.Text;

    HTTP.CustomHeaders['Authorization'] := 'Bearer ' + Token;
    HTTP.CustomHeaders['Accept'] := 'application/json';
    HTTP.CustomHeaders['Content-Type'] := 'application/json';

    RequestBody := TStringStream.Create(JsonString, TEncoding.UTF8);
    try
      memoLog.Lines.Add('>> UPDATE: Enviando PUT a: ' + Endpoint);
      memoLog.Lines.Add('>> UPDATE: Payload: ' + JsonString);

      Response := HTTP.Put(Endpoint, RequestBody);

      memoLog.Lines.Add('>> UPDATE: Respuesta del servidor...');

      if Response.StatusCode in [200, 201] then
      begin
        memoLog.Lines.Add('✅ ÉXITO: Inventario actualizado.');
        memoLog.Lines.Add(Response.ContentAsString);
      end
      else
      begin
        memoLog.Lines.Add('❌ ERROR (' + Response.StatusCode.ToString + ')');
        JSONResp := TJSONObject.ParseJSONValue(Response.ContentAsString);
        if Assigned(JSONResp) and (JSONResp is TJSONObject) then
          memoLog.Lines.Add('Mensaje API: ' + (JSONResp as TJSONObject)
            .GetValue('message').Value)
        else
          memoLog.Lines.Add(Response.ContentAsString);

        if Assigned(JSONResp) then
          JSONResp.Free;
      end;

    finally
      RequestBody.Free;
    end;
  finally
    JSONData.Free;
    HTTP.Free;
  end;
end;

end.
