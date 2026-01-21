# Especificaciones de Tipos de Datos y Formatos

Para asegurar la integridad de la información procesada, el cliente debe adherirse a los siguientes formatos de representación de datos.

## Representación de Valores
- **Numéricos**: Los valores decimales utilizan el punto (`.`) como separador. No se deben incluir separadores de miles en las peticiones POST/PUT.
- **Booleanos**: El API representa valores lógicos mediante enteros (0 para falso, 1 para verdadero).

## Formato de Temporales
- **Fechas**: Se utiliza el formato estándar `YYYY-MM-DD`.
- **Horas**: Se utiliza el formato de 24 horas `HH:mm:ss`.

## Codificación de Caracteres
- El servidor opera bajo el estándar **UTF-8**. Es responsabilidad del cliente asegurar que los strings enviados (especialmente aquellos con caracteres especiales como `ñ` o acentos) estén correctamente codificados para evitar inconsistencias en la base de datos SQL.