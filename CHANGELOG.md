# Registro de Cambios (Changelog)

Todos los cambios notables en este proyecto serán documentados en este archivo.

## [2.0.0] - 2026-01-27

### Añadido (Nuevas Funcionalidades)

#### Inteligencia Artificial
- **Filtrado Semántico (`q`)**: Se introdujo el parámetro `q` en los endpoints de listado (ej. `/customers?q=...`, `/products?q=...`). Este parámetro permite realizar consultas en lenguaje natural que se procesan **exclusivamente dentro del contexto del servicio solicitado**.
- **Chat Conversacional (`/ai/chat`)**: Nuevo endpoint `POST` que acepta un cuerpo JSON para interacciones conversacionales generales, separado de la lógica de filtrado de datos.

#### Nuevos Módulos de Negocio
- **Operaciones**: Endpoints `/operations` para la gestión de transacciones de Ventas y Compras.
- **Ofertas y Promociones**: Endpoints `/offers` para consultar y gestionar esquemas de ofertas.
- **Convenios**: Endpoints `/agreements` para la gestión de contratos comerciales especiales.
- **Instrumentos de Pago**: Endpoints `/payinstruments` para la administración de métodos de pago.

#### Nuevos Datos Maestros
- **Proveedores**: Endpoints `/providers`.
- **Vendedores**: Endpoints `/sellers`.
- **Depósitos**: Endpoints `/warehouses`.
- **Zonas**: Endpoints `/zones`.
- **Categorías e Instancias**: Endpoints `/categories`.

#### Administración y Sistema
- **Salud del Sistema**: Endpoints `/health` y `/status` para monitoreo de disponibilidad.
- **Gestión de Base de Datos**: Endpoint `/system/database` para diagnósticos de conexión SQL.
- **Seguridad y Usuarios**:
  - `/system/users`: Gestión de usuarios del servidor.
  - `/system/login-attempts`: Auditoría de intentos de acceso.

#### Autenticación V2
- Nuevo endpoint `/auth/login`: Sustituye el handshake antiguo; requiere `device_id` en el cuerpo JSON.
- Nuevo endpoint `/auth/refresh`: Permite renovar el `access_token` sin requerir credenciales nuevamente.
- Nuevo endpoint `/auth/validate`: Para verificar la vigencia de un token.

### Cambiado
- **Estandarización RESTful**: Se ha reescrito la estructura de URL para eliminar prefijos redundantes (`/adm`, `/main`). Ahora todos los recursos residen en la raíz de la versión (ej. `/api/v1/customers`).
- **Autenticación Bearer**: Se reemplaza la autenticación `Basic Auth` y la cabecera `Pragma` por el estándar **JWT (Bearer Token)**.
- **Formato de Respuesta**: Todas las respuestas JSON ahora siguen estrictamente la estructura `{ "success": boolean, "data": any, "meta": object }`.

### Eliminado
- Soporte para cabeceras `Pragma` (Manejo de sesiones legacy).
- Autenticación `Basic Auth` (Base64).
- Endpoints antiguos bajo los prefijos `/main/*` y `/adm/*`.

## [1.0.0] - 2024-11-26
### Añadido
- Versión inicial del repositorio de ejemplos y documentación técnica del Saint Sync Server.
- Soporte básico para consulta de Clientes y Productos.
- Autenticación mediante Handshake y persistencia de sesión en cabecera.