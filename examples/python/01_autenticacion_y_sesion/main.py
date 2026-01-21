import requests
import base64
import json

API_URL = 'http://64.135.37.214:8080/api/v1'
API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A'
API_ID = '1093'
USER = '001'
PASSWORD = '12345'

def iniciar_sesion():
    endpoint = API_URL + '/main/login'
    auth_str = f'{USER}:{PASSWORD}'
    auth =  base64.b64encode(auth_str.encode()).decode()

    headers = {
        'x-api-key': API_KEY,
        'x-api-id': API_ID,
        'Authorization': f'Basic {auth}'
    }

    body = {
        'terminal': 'python'
    }

    try:
        response = requests.post(endpoint, headers=headers, json=body)
        response.raise_for_status()

        session_token = response.headers.get('Pragma')

        if session_token:
            return session_token
        else:
            return None
    except requests.exceptions.RequestException as e:
        return e

if __name__ == "__main__":
    token = iniciar_sesion()
    print(token)