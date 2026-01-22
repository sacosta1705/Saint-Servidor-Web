const { iniciarSesion, API_URL } = require('../01_autenticacion_fetch_axios/auth_session');

async function consultarServiciosFiltrados() {
    const token = await iniciarSesion();

    if (!token) {
        console.error('Inicio de sesión fallido');
        return;
    }

    const filtros = "precio1>100";
    const limite = 5;
    const endpoint = `${API_URL}/adm/services?${filtros}&limit=${limite}`;

    const headers = {
        'Pragma': token
    };

    try {
        const response = await fetch(endpoint, {
            method: "GET",
            headers: headers
        });

        if (response.status === 401) {
            console.error('Sesión expirada');
            return;            
        }

        const servicios = await response.json();

        servicios.forEach(servicio => {
            console.log(`Código: ${servicio.codserv} | Nombre: ${servicio.descrip} | Precio: ${servicio.precio1}`);
        });

    } catch (error) {
        console.error('Error en la consulta:', error.message);
    }
}

if (require.main === module) {
    consultarServiciosFiltrados();
}