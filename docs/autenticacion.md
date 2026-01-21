# Protocolo de Autenticación y Persistencia de Sesión

El acceso a los recursos del Saint Sync Server se rige por un modelo de autenticación inicial seguido de una persistencia de estado mediante el protocolo de sesión activa.

## 1. Inicialización de Sesión (Handshake)
Para establecer una conexión válida, la primera solicitud dirigida al servidor debe incluir las credenciales de seguridad completas. Estas cabeceras son obligatorias **únicamente** en la petición de inicio de sesión:

- **x-api-id**: Identificador de la aplicación cliente.
- **x-api-key**: Clave de acceso a la interfaz de programación.
- **Authorization**: Credenciales de usuario en formato Base64 (`usuario:password`).

## 2. Identificación mediante Cabecera Pragma
Una vez procesada la solicitud inicial, el servidor genera un identificador de sesión único que es retornado en la cabecera `Pragma` de la respuesta (ejemplo: `dssession=xxxxxxx,dssessionexpires=xxxxxxx`).

A partir de este punto, el flujo de comunicación cambia bajo las siguientes condiciones:

* **Exclusividad**: En todas las solicitudes subsiguientes, el servidor requiere **exclusivamente** la cabecera `Pragma`. 
* **Simplificación**: No es necesario, ni se recomienda, retransmitir las cabeceras `x-api-id`, `x-api-key` ni `Authorization` una vez que la sesión ha sido establecida.
* **Identificación**: El servidor web utiliza el valor contenido en `Pragma` como el único token para identificar al usuario, validar sus permisos y mantener la integridad de la sesión activa.

## 3. Consideraciones de Implementación
* **Captura de Token**: La aplicación cliente debe implementar una lógica de extracción del header `Pragma` tras el primer contacto exitoso.
* **Vigencia**: Si la sesión expira o el servidor retorna un error de autenticación, se deberá repetir el proceso de "Handshake" descrito en el punto 1 para obtener un nuevo token de sesión.
* **Optimización**: El uso de una sesión persistente reduce el overhead de procesamiento en cada petición, permitiendo un intercambio de datos más ágil.