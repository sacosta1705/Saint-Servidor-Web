# Referencia Completa de Configuración (`config.json`)

Este documento detalla cada uno de los parámetros disponibles en el archivo `config.json`. Este archivo es el centro de control del servidor y permite ajustar desde el comportamiento de red hasta la integración con IA y bases de datos.

> **Nota:** Cualquier cambio realizado en este archivo requiere un reinicio del servicio `SaintSyncServer` para surtir efecto.

## 1. Configuración del Servidor Web (`server`)
Define cómo el servidor acepta y maneja las conexiones HTTP entrantes.

| Parámetro | Tipo | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| `port` | Entero | El puerto TCP donde el servidor escuchará peticiones. | `8080` |
| `pool_max_threads` | Entero | Número máximo de hilos de ejecución simultáneos para procesar solicitudes. Afecta el rendimiento en cargas altas. | `100` |
| `rate_limit_count` | Entero | Cantidad máxima de peticiones permitidas por IP en un minuto (Protección DDoS básica). | `200` |
| `max_connections` | Entero | Número máximo de conexiones TCP simultáneas que el servidor aceptará antes de rechazar nuevas. | `1000` |
| `listen_queue` | Entero | Tamaño de la cola de espera para conexiones entrantes pendientes de ser aceptadas (Backlog). | `200` |
| `keep_alive` | Booleano | Mantiene las conexiones HTTP abiertas para múltiples peticiones, mejorando el rendimiento. | `true` |

## 2. Base de Datos (`database`)
Configura la conexión obligatoria con la base de datos de Saint Enterprise Administrativo.

| Parámetro | Descripción |
| :--- | :--- |
| `driver` | Tipo de motor de base de datos. Actualmente soporta soloo `MSSQL`. |
| `server` | Dirección IP o Hostname del servidor SQL. Use `localhost` si está en la misma máquina. |
| `port` | Puerto del motor SQL (Por defecto MSSQL usa `1433`). |
| `default_database` | Base de datos inicial para la conexión (generalmente `master`). |
| `database` | Nombre de la base de datos administrativa de Saint (ej. `enterpriseadmindb`). |
| `branch` | Código de la sucursal de Saint Enterprise que gestionará este nodo (ej. `00000`). |
| `username` | Usuario de autenticación SQL (ej. `sa`). |
| `password` | Contraseña del usuario SQL. |
| `pool_max_items` | Tamaño máximo del pool de conexiones a la BD. Evita saturar el servidor SQL. |

## 3. Seguridad (`security`)
Parámetros críticos para la generación, firma y ciclo de vida de los tokens de sesión (JWT).

| Parámetro | Descripción |
| :--- | :--- |
| `jwt_secret` | Cadena alfanumérica larga utilizada para firmar criptográficamente los tokens. **Debe ser única y secreta**. |
| `jwt_expiry_minutes` | Tiempo de vida (en minutos) del `access_token`. Al expirar, el usuario debe renovarlo. |
| `refresh_expiry_days` | Tiempo de vida (en días) del `refresh_token`. Determina cuánto tiempo puede estar un usuario sin hacer login manual. |

## 4. Encriptación SSL/TLS (`ssl`)
Configuración para activar HTTPS directamente en el servidor.

| Parámetro | Descripción |
| :--- | :--- |
| `enabled` | `true` para activar HTTPS, `false` para HTTP plano. |

<!-- > *(Nota: Si se activa, el servidor buscará los certificados `cert.pem` y `key.pem` en la carpeta raíz).* -->

## 5. Mensajería (`messaging`)
Credenciales para la integración con plataformas de chat externas (WhatsApp y Telegram).

| Parámetro | Descripción |
| :--- | :--- |
| `verify_token` | Token personalizado para validar el Webhook de WhatsApp en el panel de Meta. |
| `api_token` | Token de acceso (Bearer) de la API de WhatsApp Cloud (Meta). |
| `phone_number_id` | ID numérico del teléfono emisor en WhatsApp Business API. |
| `api_version` | Versión de la API de Graph de Facebook a utilizar (ej. `v19.0`). |
| `telegram_api_token` | Token del Bot de Telegram obtenido vía BotFather. |

## 6. Inteligencia Artificial (`ai`)
Configura el motor de IA generativa. Permite definir múltiples proveedores y seleccionar cuál está activo.

### Configuración Global
* `active_provider`: Define cuál de los proveedores listados en el array `providers` se usará para procesar las consultas. Debe coincidir con el campo `name` de uno de los objetos.

### Lista de Proveedores (`providers`)
Cada objeto en este array representa un servicio de LLM configurado (Gemini, OpenAI, Anthropic, etc.).

| Campo | Descripción |
| :--- | :--- |
| `name` | Identificador único interno (ej. `gemini`, `openai`, `ollama`). |
| `api_key` | Clave de API proporcionada por el proveedor del servicio. |
| `url` | Endpoint completo para realizar la petición de chat/completions. |
| `model` | Nombre técnico del modelo a usar (ej. `gpt-4-turbo`, `gemini-1.5-flash`). |
| `payload_format` | Define el formato del JSON que el servidor enviará. Valores soportados: `openai_chat`, `gemini`, `anthropic_messages`, `ollama`. |
| `auth_scheme` | Método de autenticación HTTP. Valores: `bearer`, `x-api-key`, `gemini_key`, `none`. |

## 7. Sincronización (`sync`)
Controla el comportamiento de los endpoints de descarga masiva de datos.

| Parámetro | Descripción |
| :--- | :--- |
| `max_changes_per_pull` | Cantidad máxima de registros que se envían en una sola página de sincronización. |
| `enable_compression` | `true` para comprimir las respuestas, reduce el consumo de ancho de banda. |

## 8. Logs y Auditoría (`logging`)
Configuración del sistema de registro de eventos.

| Parámetro | Descripción |
| :--- | :--- |
| `level` | Nivel de detalle del log. Opciones comunes: `debug`, `info`, `warning`, `error`. |
| `log_to_file` | `true` para guardar los logs en archivos de texto en la carpeta `/logs`. |
| `log_to_console` | `true` para mostrar los logs en la ventana de comandos (stdout). |

## 9. CORS (`cors`)
Cross-Origin Resource Sharing. Define qué dominios web pueden consumir la API desde un navegador.

| Parámetro | Descripción |
| :--- | :--- |
| `allowed_origins` | Array de cadenas con los dominios permitidos. Usar `["*"]` permite acceso desde cualquier lugar (inseguro para producción). |

## 10. Mantenimiento (`maintenance`)
Permite bloquear el acceso público al API temporalmente.

| Parámetro | Descripción |
| :--- | :--- |
| `enabled` | `true` activa el modo mantenimiento. Todas las peticiones externas recibirán un error 503. |
| `allowed_ips` | Array de direcciones IP que **sí** tendrán acceso al servidor aunque el modo mantenimiento esté activo (whitelist para administradores). |