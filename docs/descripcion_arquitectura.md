# Descripción de la Arquitectura del Sistema

El Saint Sync Server actúa como una capa de abstracción y pasarela de comunicación (Gateway) entre aplicaciones externas y el ecosistema Saint Enterprise Administrativo.

## Componentes del Ecosistema
1. **Cliente Externo**: Aplicación de terceros (Web, Móvil o Desktop) que consume los recursos del API.
2. **Saint Sync Server**: Servidor web encargado de la gestión de peticiones HTTP, validación de esquemas y control de sesiones.
3. **Motor SQL Server**: Repositorio de datos donde reside la base de datos del Saint Enterprise.
4. **Servicio de Licenciamiento**: Componente del servidor que valida la vigencia del contrato de uso para permitir la operatividad del API.

## Diagrama de Componentes

```mermaid
graph TD
    Client[Aplicaciones Cliente] -->|JSON / HTTPS| SyncServer(Saint Sync Server)
    
    subgraph "Núcleo del Servidor"
        SyncServer -->|Auth (JWT)| Security[Módulo de Seguridad]
        SyncServer -->|Procesamiento de Lenguaje| AI[Motor de IA (Gemini/OpenAI)]
        SyncServer -->|Eventos| Webhooks[Gestor de Webhooks]
    end

    Webhooks -->|Notificaciones| Messaging[WhatsApp / Telegram]
```

## Motor de Inteligencia Artificial (AI Engine)
Este nuevo componente intercepta las consultas que utilizan el parámetro q (Query).

## Gestor de Webhooks (Event-Driven Architecture)
Permite la comunicación asíncrona y bidireccional con plataformas externas.

* Entrada: Recibe eventos desde proveedores de mensajería (como WhatsApp Business API) para procesar comandos enviados por chat.

* Salida: Dispara notificaciones automáticas ante eventos del ERP hacia URLs configuradas.

## Flujo de Comunicación

1. Solicitud: El cliente envía una petición con su Access Token.

2. Validación: El servidor verifica la firma criptográfica del token y los permisos (Scopes).

3. Interpretación: 
* Si es una consulta directa, pasa al adaptador SQL.

* Si es una consulta de lenguaje natural (q), pasa al Motor de IA para ser traducida.

4. Ejecución: Se ejecuta la operación en la base de datos Saint Enterprise.

5. Transformación: Los resultados crudos (RowSets) se serializan a JSON, aplicando filtros de campos (fields) si fueron solicitados.

6. Respuesta: Se entrega el payload final al cliente.

## Requisitos Previos a la Integración
Para que la arquitectura sea funcional, se deben cumplir los siguientes hitos:
- **Validación de Licencia**: La base de datos debe poseer una licencia activa.
- **Preparación de Esquemas**: Se debe ejecutar el script de compatibilidad SQL suministrado en la documentación oficial para habilitar los procedimientos almacenados necesarios.