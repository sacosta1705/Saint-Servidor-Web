# Guía de Diagnóstico y Errores (v2.0)

El Saint Sync Server utiliza códigos de estado HTTP estándar para indicar el éxito o fracaso de una operación. A continuación se detallan los escenarios más comunes y cómo resolverlos.

## Códigos de Estado HTTP

### 401 Unauthorized
**Causa:** El `access_token` ha expirado, no existe o su firma es inválida.
**Solución:**
1.  Verificar si el token se está enviando en el header `Authorization: Bearer <token>`.
2.  Si el token expiró (tiempo de vida > 30 min), utilizar el endpoint `/auth/refresh` enviando el `refresh_token` para obtener uno nuevo.
3.  Si el refresh también falla, redirigir al usuario al Login.

### 403 Forbidden
**Causa:** El token es válido, pero el usuario no tiene permisos para realizar la acción, o la Licencia de Saint Enterprise ha caducado.
**Solución:**
1.  Verificar en el servidor administrativo que la licencia esté activa.
2.  Verificar los permisos del usuario "001" (o el usado) en el Saint Administrativo.

### 400 Bad Request
**Causa:** La solicitud está mal formada.
* JSON inválido en el cuerpo.
* Parámetro `fields` con nombres de columnas inexistentes.
* Parámetro `q` vacío.
**Solución:** Revisar la sintaxis del JSON y los nombres de los campos contra la documentación.

### 404 Not Found
**Causa:** El recurso solicitado no existe.
* Endpoint mal escrito.
* ID de cliente o producto no encontrado en operaciones específicas (ej. `GET /products/CODIGO_INEXISTENTE`).

### 500 Internal Server Error
**Causa:** Error no controlado en el servidor o fallo en la base de datos SQL.
**Solución:**
1.  Verificar que el servicio SQL Server esté corriendo.
2.  Revisar que se haya ejecutado el script `SQL_Admin_Web_Server.sql` en la base de datos.
3.  Consultar los logs del servidor para el detalle del error SQL.

## Estructura de Error JSON

Cuando ocurre un error lógico (incluso con status 200 o 400), el servidor suele responder con:

```json
{
    "success": false,
    "message": "Descripción legible del error",
    "error_code": "DB_CONNECTION_ERROR", // Código interno para programadores
    "data": null
}