# Protocolo de Autenticación y Seguridad

La versión 2.0 del Saint Sync Server utiliza un sistema de autenticación basado en **JSON Web Tokens (JWT)**. Este protocolo desacopla la identificación de la aplicación de la autorización del usuario, optimizando el tamaño de las cabeceras en las operaciones cotidianas.

## 1. Inicio de Sesión (Intercambio de Credenciales)

Esta es la **única** etapa donde se deben presentar las credenciales de la aplicación integradora junto con las credenciales del usuario. El objetivo es obtener un token de acceso firmado.

* **Endpoint:** `POST /api/v1/auth/login`
* **Content-Type:** `application/json`

**Cabeceras Obligatorias (Solo en este endpoint):**
* `x-api-key`: Serial del API (Licencia de desarrollador).
* `x-api-id`: Identificador único de la aplicación.

**Cuerpo de la Solicitud:**
```json
{
    "username": "001",
    "password": "12345",
    "device_id": "MY-PC"
}
```

**Respuesta exitosa:**
```json
{
    "success": true,
    "data": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refresh_token": "301b7ffab774bb8dd2a0db4bd132595f0d3...",
        "token_type": "Bearer",
        "expires_in": 1800,
        "user": {
            "id": 1,
            "username": "001",
            "branch": "00000",
            "role": "Directiva",
            "role_id": 1,
            "device_id": "MY-PC"
        }
    }
}
```

## 2. Peticiones a Recursos Protegidos

Una vez autenticado, las cabeceras `x-api-key` y `x-api-id` ya no son necesarias y deben omitirse. La autorización se realiza exclusivamente mediante el `access_token`.

* Cabecera Requerida: `Authorization`
* Esquema: `Bearer`

**Ejemplo de Petición (Consultar Clientes):**

```http
GET /api/v1/customers HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJhbGciOiJIUzI1NiIsIn...
Content-Type: application/json
```

**Nota Técnica: El servidor rechazará cualquier petición que no incluya un token válido con firma íntegra, retornando HTTP 401 Unauthorized.**

## 3. Renovación de Acceso (Refresh Token)

Cuando el `access_token` expira, se utiliza el endpoint de refrescamiento para obtener uno nuevo. No se requieren las cabeceras de API Key/ID en esta petición, solo el token de refresco en el cuerpo.

- Endpoint: `POST /api/v1/auth/refresh`

**Cuerpo:**
```json
{
    "refresh_token": "301b7ffab774bb8dd2a0db4bd132595f0d3..."
}
```