# Descripción de la Arquitectura del Sistema

El Saint Sync Server actúa como una capa de abstracción y pasarela de comunicación (Gateway) entre aplicaciones externas y el ecosistema Saint Enterprise Administrativo.

## Componentes del Ecosistema
1. **Cliente Externo**: Aplicación de terceros (Web, Móvil o Desktop) que consume los recursos del API.
2. **Saint Sync Server**: Servidor web encargado de la gestión de peticiones HTTP, validación de esquemas y control de sesiones.
3. **Motor SQL Server**: Repositorio de datos donde reside la base de datos del Saint Enterprise.
4. **Servicio de Licenciamiento**: Componente del servidor que valida la vigencia del contrato de uso para permitir la operatividad del API.

## Flujo de Comunicación
El servidor web procesa las solicitudes entrantes y las traduce en consultas optimizadas hacia el motor de base de datos. Es indispensable que el Saint Sync Server resida en la misma infraestructura de red que el motor SQL o posea una conexión de baja latencia hacia este para garantizar tiempos de respuesta óptimos.

## Requisitos Previos a la Integración
Para que la arquitectura sea funcional, se deben cumplir los siguientes hitos:
- **Validación de Licencia**: La base de datos debe poseer una licencia activa.
- **Preparación de Esquemas**: Se debe ejecutar el script de compatibilidad SQL suministrado en la documentación oficial para habilitar los procedimientos almacenados necesarios.