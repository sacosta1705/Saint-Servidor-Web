const {iniciarSesion, API_URL} = require('../01_autenticacion_fetch_axios/auth_session');

async function publicarCliente() {
    const token = await iniciarSesion();

    if(!token) {
        console.log('no fue posible realizar el inicio de sesion');
        return;
    }

    const endpoint = `${API_URL}/customers`;

    const cliente = 
        {
            "codclie": "JS-999",
            "descrip": "DESARROLLOS JS LIMITADA",
            "id3": "V10203040",
            "activo": 1
        };

    const headers = {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    };

    try {
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(cliente)
        });

        if (response.ok) {
            const respuesta = await response.json();
            console.log('respuesta del servidor: ', respuesta);
        } else {
            const error = await response.text();
            console.error(`error en la carga: ${response.status} - ${error}`);
        }
    } catch (error) {
        console.error(error);
    }
}

if(require.main === module){
    publicarCliente();
}