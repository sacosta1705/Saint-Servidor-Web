const API_URL = 'http://localhost:8080/api/v1'; 
const API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A';
const API_ID = '1093';

const USER = '001';
const PASSWORD = '12345';
const DEVICE_ID = 'NODEJS_CLIENT_01';

async function iniciarSesion() {
    const endpoint = `${API_URL}/auth/login`;

    const headers = {
        'Content-Type': 'application/json',
        'x-api-key': API_KEY,
        'x-api-id': API_ID
    };

    const body = JSON.stringify({
        username: USER,
        password: PASSWORD,
        device_id: DEVICE_ID
    });

    try {
        console.log(`Intentando iniciar sesión en: ${endpoint}`);
        
        const response = await fetch(endpoint, {
            method: "POST",
            headers: headers,
            body: body
        });

        if (!response.ok) {
            const errorTxt = await response.text();
            throw new Error(`Error del servidor (${response.status}): ${errorTxt}`);
        }

        const resultado = await response.json();

        if (resultado.success && resultado.data && resultado.data.access_token) {
            console.log('Sesión establecida exitosamente.');
            return resultado.data.access_token;
            
        } else {
            console.error('Fallo en el login:', resultado.message || 'Respuesta inválida');
            return null;
        }

    } catch (error) {
        console.error('Error de comunicación:', error.message);
        return null;
    }
}

if (require.main === module) {
    iniciarSesion().then(token => {
        if (token) {
            console.log(`Token recibido: ${token}`);
        }
    });
}

module.exports = { iniciarSesion, API_URL };