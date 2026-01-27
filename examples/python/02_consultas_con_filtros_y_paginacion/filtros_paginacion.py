import requests
import json

# Configuración
API_URL = 'http://localhost:8080/api/v1'
API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A'
API_ID = '1093'
USER = '001'
PASSWORD = '12345'

def iniciar_sesion():
    endpoint = API_URL + '/auth/login'

    headers = {
        'x-api-key': API_KEY,
        'x-api-id': API_ID,
        'Content-Type': 'application/json'
    }

    body = {
        'username': USER,
        'password': PASSWORD,
        'device_id': 'python_script_v2'
    }

    try:
        response = requests.post(endpoint, headers=headers, json=body)
        response.raise_for_status()

        data = response.json()
        
        if data.get('success') and 'data' in data:
            return data['data']['access_token']
        else:
            print(f"Error en login: {data.get('message')}")
            return None
            
    except requests.exceptions.RequestException as e:
        print(f"Error de conexión: {e}")
        return None

def consultar_clientes():
    token = iniciar_sesion()

    if not token: 
        print('No se pudo iniciar sesión.')
        return

    filtros = 'saldo>2000'
    
    endpoint = f'{API_URL}/customers?{filtros}'

    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }

    try:
        response = requests.get(endpoint, headers=headers)
        response.raise_for_status()
        
        resultado = response.json()

        if resultado.get('success') and 'data' in resultado:
            clientes = resultado['data']
            print(f"\n--- Clientes encontrados: {len(clientes)} ---")
            
            for cliente in clientes:
                cod = cliente.get("codclie", "N/A")
                nom = cliente.get("descrip", "Sin Nombre")
                sal = cliente.get("saldo", 0)
                print(f'Codigo: {cod} | Nombre: {nom} | Saldo: {sal}')
        else:
            print(f"Error lógico en API: {resultado.get('message')}")

    except requests.exceptions.RequestException as e:
        print(f'Fallo en la consulta: {e}')

if __name__ == "__main__":
    consultar_clientes()