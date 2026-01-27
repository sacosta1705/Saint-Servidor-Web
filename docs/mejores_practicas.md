# Mejores Prácticas de Integración (v2.0)

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

## 3. Delegación de Lógica a la IA

En lugar de descargar miles de registros para filtrarlos en la memoria del dispositivo cliente, utiliza el motor de Inteligencia Artificial del servidor.

* **Escenario:** Filtrar clientes de una zona específica con deuda vencida.
* **Enfoque v2:**
    `GET /api/v1/customers?q=`
    
    El servidor traducirá esto a SQL optimizado, reduciendo la carga de procesamiento en tu aplicación.

## 4. Seguridad de Credenciales

* **x-api-key y x-api-id:** Estas credenciales identifican tu licencia de desarrollador.
    * **En Apps Móviles/Escritorio:** Pueden ir embebidas, pero se recomienda ofuscarlas.
    * **En Web (React/Angular/Vue):** **NUNCA** las expongas en el código del frontend. Utiliza un Backend-for-Frontend (BFF) o un Proxy reverso para inyectar estas cabeceras.

## 5. Manejo de Tipos de Datos

El API retorna JSON estándar. Asegúrate de respetar los tipos:
* Precios y Cantidades: Vienen como `number` (float/double). No los trates como strings para evitar errores de cálculo.
* Fechas: Formato ISO 8601 (`YYYY-MM-DDTHH:mm:ss`).