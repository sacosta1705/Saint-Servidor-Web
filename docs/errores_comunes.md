# Diagnóstico de Errores y Gestión de Excepciones

A continuación se describen los códigos de estado HTTP comunes y las acciones correctivas recomendadas para la integración con el servidor.

### 401 Unauthorized (No Autorizado)
- **Origen**: Credenciales inválidas o ausencia de codificación Base64 en la cabecera `Authorization`.
- **Resolución**: Verificar la integridad del par `usuario:password` y su correcta conversión al formato requerido.

### 403 Forbidden (Prohibido)
- **Origen**: Inconsistencia en la licencia del Saint Enterprise o falta de ejecución del script de compatibilidad SQL en la base de datos de producción.
- **Resolución**: Validar el estado de la licencia y confirmar la ejecución del query de actualización del servidor web.

### 404 Not Found (No Encontrado)
- **Origen**: El recurso solicitado no existe o el ID proporcionado es incorrecto.
- **Resolución**: Consultar la documentación de endpoints en Postman para validar la ruta y los parámetros de identificación.

### Fallo de Sesión (Ausencia de Pragma)
- **Origen**: El cliente no está transmitiendo el identificador de sesión activo.
- **Resolución**: Implementar una lógica de persistencia para capturar y retransmitir el valor contenido en la cabecera `Pragma` de la respuesta inicial.