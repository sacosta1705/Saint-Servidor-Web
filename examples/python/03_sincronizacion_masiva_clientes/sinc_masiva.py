import requests
import base64

API_URL = 'http://localhost:8080/api/v1'
API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A'
API_ID = '1093'
USER = '001'
PASSWORD = '12345'

def iniciar_sesion():

    endpoint = f"{API_URL}/main/login"
    auth_str = f"{USER}:{PASSWORD}"
    auth_b64 = base64.b64encode(auth_str.encode()).decode()

    headers = {
        'x-api-key': API_KEY,
        'x-api-id': API_ID,
        'Authorization': f'Basic {auth_b64}'
    }

    try:
        response = requests.post(endpoint, headers=headers, json={'terminal': 'python_bulk'})
        response.raise_for_status()
        return response.headers.get('Pragma')
    except requests.exceptions.RequestException:
        return None

def sincronizar_clientes_masivo():
    token = iniciar_sesion()
    
    if not token:
        print("Error: No se pudo establecer la sesión para la carga masiva.")
        return

    endpoint = f"{API_URL}/adm/customer"

    lote_clientes = [
        {
            "codclie": "PY001",
            "descrip": "CLIENTE MASIVO 1",
            "id3": "V10000001",
            "activo": 1
        },
        {
            "codclie": "PY002",
            "descrip": "CLIENTE MASIVO 2",
            "id3": "V10000002",
            "activo": 1
        },
        {
            "codclie": "PY003",
            "descrip": "CLIENTE MASIVO 3",
            "id3": "V10000003",
            "activo": 1
        }
    ]

    headers = {
        'Pragma': token,
        'Content-Type': 'application/json'
    }

    try:
        response = requests.post(endpoint, headers=headers, json=lote_clientes)
        
        if response.status_code in [200, 201]:
            print(f"Sincronización exitosa. Registros procesados: {len(lote_clientes)}")
        else:
            print(f"Fallo en la sincronización: {response.status_code} - {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"Error técnico durante la carga: {e}")

sincronizar_clientes_masivo()