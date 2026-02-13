# Mejores Prácticas de Integración

Para garantizar una integración estable, segura y de alto rendimiento con el Saint Sync Server, se recomienda adherirse a los siguientes patrones de diseño.

## 1. Gestión Eficiente de Sesiones

**NO realizar Login por cada petición.**
El proceso de inicio de sesión implica validaciones criptográficas y consultas a la base de datos que consumen recursos.

* **Patrón Correcto:**
    1.  Realizar Login (`/auth/login`) una única vez al iniciar la aplicación.
    2.  Almacenar el `access_token` y el `refresh_token` en un lugar seguro (Keychain, Secure Storage, etc.).
    3.  Reutilizar el `access_token` para todas las consultas.
    4.  Implementar una intercepción de errores: Si el servidor retorna `401 Unauthorized`, usar el endpoint `/auth/refresh` silenciosamente y reintentar la operación.

## 2. Optimización de Ancho de Banda

Evita traer datos innecesarios (Over-fetching). El servidor soporta proyección de datos nativa.

* **Mala Práctica:**
    Solicitar el objeto completo de productos (`GET /products`) cuando solo necesitas llenar una lista de precios. Esto transfiere campos pesados como notas largas.

* **Buena Práctica:**
    Utilizar el parámetro `fields`:
    `GET /api/v1/products?fields=codprod,descrip,precio1,existencia`

## 3. Seguridad de Credenciales

* **x-api-key y x-api-id:** Estas credenciales identifican tu licencia de desarrollador.
    * **En Apps Móviles/Escritorio:** Pueden ir embebidas, pero se recomienda ofuscarlas.
    * **En Web (React/Angular/Vue):** **NUNCA** las expongas en el código del frontend. Utiliza un Backend-for-Frontend (BFF) o un Proxy reverso para inyectar estas cabeceras.

## 4. Manejo de Tipos de Datos

El API retorna JSON estándar. Asegúrate de respetar los tipos:
* Precios y Cantidades: Vienen como `number` (float/double). No los trates como strings para evitar errores de cálculo.
* Fechas: Formato ISO 8601 (`YYYY-MM-DDTHH:mm:ss`).

---

## 5. Guía de Implementación para Aplicaciones de Terceros

Esta sección recopila patrones y recomendaciones técnicas para desarrolladores que construyen aplicaciones sobre el Saint Sync Server. Seguir estas prácticas facilita el diagnóstico de problemas, mejora la experiencia del usuario final y asegura un uso eficiente de los recursos del servidor.

### 5.1 Implementar Logging de Operaciones

Un sistema de logs bien estructurado es la primera herramienta de diagnóstico ante cualquier incidencia. Se recomienda registrar cada llamada al API con al menos los siguientes campos:

```
[2026-02-13T14:32:01Z] user=001 method=GET endpoint=/api/v1/products?fields=codprod,precio1 status=200 latency=132ms device=MY-PC
[2026-02-13T14:32:05Z] user=001 method=POST endpoint=/api/v1/orders status=400 latency=45ms device=MY-PC
```

Campos recomendados por entrada de log: timestamp (UTC), usuario autenticado, método HTTP, endpoint, código de respuesta, latencia y device_id. Esto permite reconstruir el flujo de operaciones cuando un usuario reporta un error, sin depender de los logs del servidor.

Se recomienda utilizar niveles de log estándar (`DEBUG`, `INFO`, `WARN`, `ERROR`) y rotar los archivos para evitar consumo excesivo de disco en dispositivos móviles.

### 5.2 Auditoría de Transacciones

A diferencia del logging operativo (sección 5.1), que captura el detalle técnico de cada llamada HTTP, la auditoría de transacciones registra **qué operaciones de negocio se ejecutaron** dentro de la aplicación cliente. Cada aplicación que consuma el Saint Sync Server debe mantener un registro de auditoría local que documente las transacciones realizadas contra el sistema.

**Datos mínimos por registro de auditoría:**

| Campo | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `transaction_id` | Identificador único de la transacción (UUID v4 recomendado). | `a3f8c1e0-7b2d-4e5a-9c1f-0d3b6a8e2f74` |
| `timestamp` | Fecha y hora en UTC (ISO 8601). | `2026-02-13T14:32:01Z` |
| `user_id` | Usuario de Saint que ejecutó la acción. | `001` |
| `device_id` | Identificador del dispositivo origen. | `MY-PC` |
| `operation` | Tipo de operación de negocio ejecutada. | `CREATE_ORDER`, `UPDATE_CUSTOMER`, `DELETE_PRODUCT` |
| `resource` | Endpoint y recurso afectado. | `/api/v1/orders` |
| `request_payload` | Cuerpo de la solicitud enviada (sanitizado, sin tokens). | `{"codclie": "00012", "items": [...]}` |
| `response_status` | Código HTTP de respuesta del servidor. | `200` |
| `response_summary` | Resumen del resultado (ID creado, campos modificados, etc.). | `order_id: 5023` |

**Protección del registro:**

El almacenamiento de auditoría debe cumplir con las siguientes características:

* **Cifrado en reposo:** Los registros deben almacenarse cifrados utilizando los mecanismos nativos de la plataforma (SQLCipher para SQLite, cifrado de volumen en servidores, DPAPI en Windows, etc.). Un archivo de texto plano con transacciones no constituye un registro de auditoría válido.
* **Inmutabilidad:** El registro debe ser append-only. La aplicación no debe exponer funcionalidad que permita al usuario final editar o eliminar entradas de auditoría individuales. Si se utiliza una base de datos local, considerar un esquema donde las filas no tengan `UPDATE` ni `DELETE` habilitado a nivel de la capa de acceso a datos.
* **Integridad verificable:** Se recomienda generar un hash (SHA-256) por cada entrada que incluya el hash de la entrada anterior, creando una cadena de integridad similar a un blockchain simplificado. Esto permite detectar si un registro fue manipulado externamente.

```
registro_1: hash = SHA256(data_1)
registro_2: hash = SHA256(data_2 + hash_registro_1)
registro_3: hash = SHA256(data_3 + hash_registro_2)
```

* **Retención:** Se recomienda conservar los registros de auditoría por un mínimo de 12 meses. En dispositivos móviles con restricciones de almacenamiento, implementar un mecanismo de exportación o sincronización a un servidor del desarrollador antes de rotar los registros locales.

**Sanitización:** Nunca incluir tokens (`access_token`, `refresh_token`), contraseñas ni credenciales de API en los registros de auditoría. Si se registra el `request_payload`, eliminar o enmascarar estos campos antes de persistirlos.

> **¿Por qué es importante?** Ante cualquier discrepancia entre los datos del Saint Enterprise y las operaciones realizadas desde la aplicación del tercero, el registro de auditoría es la evidencia técnica que permite determinar el origen del problema. Sin este registro, no es posible diagnosticar si un error fue causado por el servidor, por la aplicación cliente o por una acción del usuario.

### 5.3 Uso Correcto de HTTPS y TLS

Toda comunicación con el Saint Sync Server debe realizarse sobre HTTPS. Las aplicaciones deben:

* **Validar el certificado TLS** del servidor. Nunca deshabilitar la verificación de certificados en producción, ni siquiera como workaround temporal. Si el servidor utiliza un certificado autofirmado, importar el CA en el trust store de la aplicación en lugar de desactivar la validación.
* **No transmitir tokens ni credenciales como query parameters** (`?token=abc123`), ya que estos quedan expuestos en logs del servidor, historial del navegador y proxies intermedios. Siempre usar el header `Authorization: Bearer <token>`.
* **Fijar la versión mínima de TLS a 1.2.** Las versiones anteriores tienen vulnerabilidades conocidas. En la mayoría de los clientes HTTP modernos esto es el comportamiento por defecto, pero conviene verificarlo explícitamente en la configuración del cliente.

### 5.4 Almacenamiento Seguro de Credenciales y Tokens

Los tokens JWT y las credenciales de API son equivalentes a contraseñas de acceso. El estándar de la industria es utilizar los mecanismos de almacenamiento seguro de cada plataforma:

| Plataforma | Mecanismo recomendado |
| :--- | :--- |
| iOS | Keychain Services |
| Android | EncryptedSharedPreferences / Keystore |
| Windows | DPAPI / Credential Manager |
| Web (SPA) | Cookie `HttpOnly` + `Secure` vía BFF |

**Anti-patrones comunes a evitar:**
* Guardar el `access_token` en `localStorage` o `sessionStorage` en aplicaciones web (vulnerable a XSS).
* Hardcodear `x-api-key` o `x-api-id` como strings visibles en el código fuente.
* Escribir tokens en archivos de log.
* Incluir credenciales en repositorios de control de versiones (`.env` sin `.gitignore`, configs commiteados, etc.).

### 5.5 Respetar los Códigos de Estado HTTP

El servidor utiliza códigos de estado estándar (ver [Guía de Diagnóstico](./errores_comunes.md)). La aplicación cliente debe manejarlos correctamente en lugar de tratar todas las respuestas como éxito o fracaso genérico:

| Código | Acción esperada en el cliente |
| :--- | :--- |
| `200` | Procesar la respuesta normalmente. |
| `400` | Error en la solicitud. Revisar el cuerpo del request (JSON malformado, campos inválidos). No reintentar sin corregir. |
| `401` | Token expirado o inválido. Ejecutar el flujo de refresh y reintentar la petición original una sola vez. |
| `403` | Sin permisos. Informar al usuario. No reintentar. |
| `404` | Recurso no encontrado. Verificar el endpoint y el ID solicitado. |
| `429` | Rate limit alcanzado. Implementar **exponential backoff** antes de reintentar (esperar 1s, 2s, 4s, 8s...). |
| `500` | Error del servidor. Registrar el incidente en los logs locales. Se puede reintentar con backoff, pero si persiste, escalar al administrador del servidor. |

Un patrón robusto es implementar un interceptor HTTP centralizado (middleware) que maneje automáticamente el refresh de tokens en `401` y el backoff en `429`, evitando duplicar esta lógica en cada llamada al API.

### 5.6 Paginación y Consumo Eficiente de Recursos

Para endpoints que retornan colecciones, el servidor implementa paginación automática. Las aplicaciones deben:

* **Nunca asumir que una sola petición retorna todos los registros.** Siempre leer el objeto `meta` de la respuesta y usar `total_pages` para determinar si hay más datos.
* **Evitar descargar todas las páginas en un solo ciclo** si solo se necesita mostrar una pantalla de resultados. Implementar carga bajo demanda (lazy loading / infinite scroll).
* **No hacer polling agresivo** para detectar cambios. Un intervalo mínimo razonable entre consultas de sincronización es de 30 segundos. Si la arquitectura lo requiere, evaluar el uso de los webhooks del servidor como alternativa event-driven.

### 5.7 Manejo de Datos en el Cliente

Los datos obtenidos del API representan información comercial en tiempo real. Algunas consideraciones técnicas:

* **Caché con invalidación:** Si la aplicación implementa caché local de productos, precios o existencias, definir un TTL (Time-To-Live) razonable. Mostrar precios desactualizados puede generar discrepancias operativas para el usuario final. Un TTL de 5-15 minutos es un punto de partida sensato para datos de catálogo.
* **No transformar tipos:** Respetar los tipos de datos del API. Tratar un `precio1` (number) como string y luego concatenarlo lleva a errores silenciosos de cálculo. Parsear siempre como `float`/`double`/`decimal` según el lenguaje.
* **Datos personales:** Si la aplicación almacena localmente datos de clientes (nombre, teléfono, dirección), considerar las regulaciones de protección de datos aplicables en la jurisdicción del usuario. Como mínimo, cifrar estos datos en reposo y eliminarlos si el usuario desinstala la aplicación.

### 5.8 Identificación de la Aplicación

Los Canales Integradores autorizados pueden utilizar la marca Saint en sus aplicaciones, materiales promocionales y publicidad. Para mantener una identidad unificada dentro del ecosistema, se recomienda que cada aplicación de tercero:

* Se identifique visiblemente como **"Canal Integrador"** de Saint, de forma que el usuario final entienda que se trata de una solución desarrollada por un tercero autorizado dentro del ecosistema.
* Incluya una referencia visible (por ejemplo en la sección "Acerca de") que indique: *"[Nombre de la empresa] — Canal Integrador de Saint."* o similares.
* Gestione su propio canal de soporte técnico. Los usuarios finales de aplicaciones de terceros deben dirigir sus consultas al desarrollador de la aplicación, no al soporte de Saint.

### 5.9 Reporte de Incidentes y Vulnerabilidades

Si durante el desarrollo o uso de la aplicación se detecta un comportamiento inesperado del API que pueda indicar una vulnerabilidad de seguridad:

* Reportar al equipo técnico de Saint a través del canal oficial antes de divulgar públicamente. Esto sigue el estándar de **responsible disclosure** y permite corregir el problema sin exponer a otros integradores.
* Si la aplicación del tercero sufre una brecha que comprometa las credenciales del API, revocar los tokens inmediatamente mediante un nuevo login y notificar al administrador del servidor para que evalúe si se requieren acciones adicionales.

### 5.10 Compatibilidad y Actualización

El API puede incorporar nuevos endpoints, campos o deprecar funcionalidades existentes entre versiones. Para minimizar el impacto:

* No depender de campos no documentados que puedan aparecer en las respuestas JSON. Parsear únicamente los campos especificados en la documentación.
* Diseñar el cliente para tolerar campos desconocidos en las respuestas (ignorarlos en lugar de fallar). Esto hace la integración resiliente ante actualizaciones del servidor que agreguen nuevos campos.
* Implementar un chequeo de versión o health check al iniciar la aplicación (`GET /api/v1/`) para detectar incompatibilidades tempranas.
