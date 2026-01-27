# Guía de Configuración del Servidor (`config.json`)

El comportamiento del Saint Sync Server se define a través del archivo `config.json` ubicado en la raíz del ejecutable. Este archivo permite ajustar la conexión a la base de datos, los proveedores de IA, la seguridad y los webhooks sin necesidad de recompilar la aplicación.

> **Importante:** Después de realizar cambios en este archivo, es necesario reiniciar el servicio para que surtan efecto.

## 1. Servidor Web (`server`)
Controla los parámetros de red y rendimiento del servidor HTTP.

| Parámetro | Descripción | Valor por Defecto |
| :--- | :--- | :--- |
| `port` | Puerto TCP donde escuchará el servidor. | `8080` |
| `max_connections` | Número máximo de conexiones simultáneas permitidas. | `1000` |
| `rate_limit_count` | Límite de peticiones por minuto por IP para evitar abusos. | `200` |

```json
"server": {
    "port": 8080,
    "max_connections": 1000,
    ...
}
```

## 2. Base de Datos (`database`)
Configuración de la conexión con Microsoft SQL Server (Saint Enterprise).
| Parámetro | Descripción |
| :--- | :--- |
| `server` | Dirección IP o nombre de host de la instancia SQL (ej. `LOCALHOST`). |
| `database` | Nombre de la base de datos administrativa (ej. `SAINT_ADMIN`). |
| `username` | Usuario SQL |
| `password` | Contraseña del usuario SQL. |

## 3. Seguridad y Tokens (`security`)
Parámetros críticos para la generación y validación de JSON Web Tokens (JWT).

* `jwt_secret`: Cadena alfanumérica larga utilizada para firmar los tokens. Debe cambiarse en producción por una cadena aleatoria segura.
* `jwt_expiry_minutes`: Tiempo de vida del `access_token` (recomendado: 30 a 60 min).
* `refresh_expiry_days`: Tiempo de vida del `refresh_token` (recomendado: 7 a 30 días).

## 4. Inteligencia Artificial (`ai`)
Define los proveedores de LLM disponibles para las Consultas Inteligentes (`q`) y el Chat (`/ai/chat`). El servidor intentará usar el primer proveedor de la lista que esté activo.
El archivo soporta múltiples proveedores. Para activar uno, debes colocar su `api_key`.

## 5. Webhooks y Mensajería (`messaging`)
Configuración para la integración con WhatsApp Business API o Telegram.
* `verify_token`: Token de verificación que debes configurar en el panel de desarrollador de Meta (Facebook) para validar el webhook.
* `api_token`: Token de acceso permanente para enviar mensajes (WhatsApp Cloud API).

## 6. Sincronización (`sync`)
Ajustes para la carga y descarga de datos masivos.
* `max_changes_per_pull`: Cantidad máxima de registros a entregar en una sola petición de sincronización.
* `enable_compression`: true para comprimir las respuestas GZIP (ahorra ancho de banda).