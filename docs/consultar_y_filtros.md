# Consultas, Filtrado y Optimización de Datos

La versión 2.0 del Saint Sync Server optimiza la recuperación de información mediante dos nuevos mecanismos: la **Proyección de Campos** (para reducir el ancho de banda) y las **Consultas Inteligentes** (para simplificar el filtrado mediante lenguaje natural).

## 1. Selección de Campos (Proyección)

Por defecto, los endpoints de tipo lista retornan todas las columnas disponibles de la tabla. Para optimizar la transferencia de datos, especialmente en redes móviles, se recomienda solicitar únicamente los campos necesarios.

### Parámetro: `fields`
Recibe una lista de nombres de columnas separados por comas.

**Ejemplo de Solicitud:**
Obtener solo el código, descripción y precio de los productos, ignorando costos e inventarios.

`GET /api/v1/products?fields=codprod,descrip,precio1`

**Encabezados:**
`Authorization: Bearer <ACCESS_TOKEN>`

**Respuesta Optimizada:**
```json
{
    "success": true,
    "data": [
        {
            "codprod": "11001",
            "descrip": "VENTILADOR DE PISO",
            "precio1": 1714.29
        },
        {
            "codprod": "12001",
            "descrip": "KILO DE CEMENTO",
            "precio1": 720
        }
    ],
    "meta": {
        "page": 1,
        "page_size": 20,
        "total_items": 1,
        "total_pages": 1,
        "message": "List of Productos fetched successfully"
    }
}
```

## 2. Consultas Inteligentes (AI Querying)

En esta versión se ha reemplazado la construcción manual de sentencias SQL en el cliente por un intérprete de intenciones basado en IA.

**Parametro:** `q`

Acepta una frase en lenguaje natural que describe el filtro o la búsqueda deseada. El servidor procesa esta frase y la convierte en la consulta SQL correspondiente. Teniendo en cuenta que se debe indicar explicitamente los campos a analizar y retornar:

**Ejemplos de uso:**
* Búsqueda Simple: `GET /api/v1/customers?q=clientes de la zona norte`
* Filtrado Numérico: `GET /api/v1/products?q=productos con existencia mayor a 50 y precio menor a 20`
* Búsqueda Compleja: `GET /api/v1/services?q=servicios relacionados con mantenimiento que cuesten menos de 100`

**Nota: La efectividad de este filtro depende del motor de IA configurado en el servidor.**

## 3. Paginación y Metadatos

Para manejar grandes volúmenes de datos, el servidor implementa paginación automática.

**Parámetros:**
* `page`: Número de página a consultar.

**Estructura de Respuesta**: Toda respuesta de colección incluye un objeto meta con la información de navegación.
```json
{
    "success": true,
    "data": [ ... ],
    "meta": {
        "page": 1,          // Página actual
        "limit": 10,        // Items por página
        "total_items": 450, // Total de registros en la BD
        "total_pages": 45   // Total de páginas disponibles
    }
}
```

## 4. Consideraciones de Seguridad
* Autorización: Todas las consultas a estos endpoints requieren un `access_token` válido enviado en el header `Authorization`.

* Identificación: No se deben enviar los headers `x-api-key` ni `x-api-id` en estas peticiones; estos solo se utilizan durante el `login`.