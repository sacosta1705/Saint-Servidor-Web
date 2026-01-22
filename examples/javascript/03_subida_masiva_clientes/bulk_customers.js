const {iniciarSesion, API_URL} = require('../01_autenticacion_fetch_axios/auth_session');

async function publicarClientes() {
    const token = await iniciarSesion();

    if(!token) {
        console.log('no fue posible realizar el inicio de sesion');
        return;
    }

    const endpoint = `${API_URL}/adm/customer`;

    const clientes = [
        {
            "codclie": "JS-001",
            "descrip": "DESARROLLOS JS LIMITADA",
            "id3": "V10203040",
            "activo": 1
        },
        {
            "codclie": "JS-002",
            "descrip": "SISTEMAS INTEGRADOS NODE",
            "id3": "V50607080",
            "activo": 1
        }
    ];

    const headers = {
        'Pragma': token,
        'Content-Type': 'application/json'
    };

    try {
        console.log(`enviando lote de ${clientes.length} clientes...`);
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(clientes)
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
    publicarClientes();
}