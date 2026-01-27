import requests
import json

API_URL = 'http://localhost:8080/api/v1'
API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A'
API_ID = '1093'
USER = '001'
PASSWORD = '12345'

def iniciar_sesion():
    endpoint = API_URL + '/auth/login'

    headers = {
        'x-api-key': API_KEY,
        'x-api-id': API_ID
    }

    body = {
        "username": USER,
        "password": PASSWORD,
        "device_id":"Python",
    }

    try:
        response = requests.post(endpoint, headers=headers, json=body)
        response.raise_for_status()
        jsonResonse = response.json()

        if jsonResonse.get('success') and 'data' in jsonResonse:
            return jsonResonse['data']['access_token']
        else:
            return None
    except requests.exceptions.RequestException as e:
        return e

def sincronizar_clientes_masivo():
    token = iniciar_sesion()
    
    if not token:
        print("Error: No se pudo establecer la sesión para la carga masiva.")
        return

    endpoint = f"{API_URL}/customers"

    cliente = {
            "codclie": "PY001",
            "descrip": "CLIENTE MASIVO 1",
            "id3": "V10000001",
            "activo": 1
        }

    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }

    try:
        response = requests.post(endpoint, headers=headers, json=cliente)
        
        if response.status_code in [200, 201]:
            print(f"Sincronización exitosa. Registros procesados.")
        else:
            print(f"Fallo en la sincronización: {response.status_code} - {response.text}")

    except requests.exceptions.RequestException as e:
        print(f"Error técnico durante la carga: {e}")

sincronizar_clientes_masivo()