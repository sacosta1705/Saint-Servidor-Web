# Especificaciones de Consulta, Filtrado y Paginación

Saint Sync Server permite la ejecución de consultas parametrizadas sobre los recursos disponibles para optimizar la transferencia de datos y la carga en el servidor.

## Operadores Relacionales
Es posible aplicar filtros de selección mediante la inclusión de parámetros en la cadena de consulta (query string). Se admiten los siguientes operadores:

- **Igualdad (`=`)**: Filtrado por coincidencia exacta (ej. `/customers?activo=1`).
- **Mayor que (`>`)**: Filtrado de rangos superiores (ej. `/stocks?existencia>100`).
- **Menor que (`<`)**: Filtrado de rangos inferiores (ej. `/adm/service?precio<50.5`).

## Paginación de Resultados
Para el manejo eficiente de grandes volúmenes de datos, se dispone del parámetro `limit`. Este restringe la cantidad de registros retornados en un solo cuerpo de respuesta, facilitando la implementación de paginación en el cliente:

`GET /products?limit=50`

## Selección Selectiva de Campos (Data Projection)
A fin de reducir la latencia y el consumo de ancho de banda, se permite la solicitud de campos específicos de un recurso, separando los identificadores por comas en la URL:

`GET /adm/config/1/codsucu,descrip`