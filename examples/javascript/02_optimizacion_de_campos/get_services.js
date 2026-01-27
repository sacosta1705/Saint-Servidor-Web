const { iniciarSesion, API_URL } = require('../01_autenticacion_fetch_axios/auth_session');

async function consultarServiciosFiltrados() {
    const token = await iniciarSesion();

    if (!token) {
        console.error('Inicio de sesión fallido');
        return;
    }

    const filtros = "precio1>100"; 
    const limite = 5;
    
    const endpoint = `${API_URL}/services?${filtros}&limit=${limite}`;

    const headers = {
        'Authorization': `Bearer ${token}`, 
        'Content-Type': 'application/json'
    };

    try {
        console.log(`Consultando: ${endpoint}`);
        const response = await fetch(endpoint, {
            method: "GET",
            headers: headers
        });

        if (response.status === 401) {
            console.error('Error: Sesión expirada o token inválido.');
            return;            
        }

        if (!response.ok) {
            console.error(`Error HTTP: ${response.status}`);
            return;
        }

        const respuesta = await response.json();

        if (respuesta.success && Array.isArray(respuesta.data)) {
            const servicios = respuesta.data;
            
            if (servicios.length === 0) {
                console.log("No se encontraron servicios con el filtro especificado.");
            } else {
                console.log(`\n--- Servicios Encontrados (${servicios.length}) ---`);
                servicios.forEach(servicio => {
                    console.log(`Código: ${servicio.codserv} | Nombre: ${servicio.descrip} | Precio: ${servicio.precio1}`);
                });
            }
        } else {
            console.error('Respuesta inesperada del servidor:', respuesta);
        }

    } catch (error) {
        console.error('Error de conexión:', error.message);
    }
}

if (require.main === module) {
    consultarServiciosFiltrados();
}