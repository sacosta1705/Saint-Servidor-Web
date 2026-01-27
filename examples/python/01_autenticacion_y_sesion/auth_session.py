import requests
import base64
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

if __name__ == "__main__":
    token = iniciar_sesion()
    print(token)