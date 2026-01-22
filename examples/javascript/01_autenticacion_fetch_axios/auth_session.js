const API_URL = 'http://localhost:8080/api/v1';
const API_KEY = 'B5D31933-C996-476C-B116-EF212A41479A';
const API_ID = '1093';
const USER = '001';
const PASSWORD = '12345';

async function iniciarSesion() {
    const endpoint = `${API_URL}/main/login`;
    const authStr = `${USER}:${PASSWORD}`;
    const auth = Buffer.from(authStr).toString('base64');

    const headers = {
        'Content-Type': 'application/json',
        'x-api-key': API_KEY,
        'x-api-id': API_ID,
        'Authorization': `Basic ${auth}`
    };

    const body = JSON.stringify({
        terminal: "njs"
    });

    try {
        const response = await fetch(endpoint, {
            method: "POST",
            headers: headers,
            body: body
        });

        if (!response.ok) {
            const errorTxt = await response.text();
            throw new Error(`error ${response.status}: ${errorTxt}`);
        }

        const sessionToken = response.headers.get('pragma');
        if (sessionToken) {
            console.log('sesion establecida');
            return sessionToken;
            
        } else {
            console.error('pragma no encontrado');
            return null;
            
        }
    } catch (error) {
        console.error('fallo en la comunicacion con el servidor: ', error.message);
        return null;
        
    }
}

if (require.main === module) {
    iniciarSesion().then(token => {
        if (token) console.log(`token recibido: ${token}`);
    });
}

module.exports = {iniciarSesion, API_URL};