# 📄 Guía de Despliegue: Pagina web

Este documento detalla los pasos necesarios para configurar el entorno local, conectar con los servicios remotos y levantar la interfaz web del sistema de monitoreo.

## 1. Requisitos Previos (Dependencias Locales)
Para que la página web pueda procesar el código y comunicarse correctamente con las bases de datos, es obligatorio tener instalados los paquetes de PHP y su extensión para PostgreSQL.

Abre tu terminal y ejecuta el siguiente comando para instalar estas dependencias:

```bash
sudo dnf install php php-pgsql
```

## 2. Establecer Conexión con el Servidor
La arquitectura del proyecto requiere acceso al servidor central (Ubuntu) donde se aloja **Apache Superset** y la base de datos de autenticación (`usuarios_web`).

* **Acción requerida:** Antes de levantar el proyecto, asegúrate de encender la conexión VPN (OpenVPN) desde tu menú superior de red. 
* *Nota:* Sin esta conexión activa, la página web no podrá renderizar los gráficos del dashboard ni validar los inicios de sesión de los usuarios.

## 3. Levantar la Página Web
El proyecto utiliza el servidor de desarrollo integrado de PHP para pruebas locales.

1. Abre la terminal.
2. Navega hasta el directorio raíz del proyecto web (asegúrate de usar la ruta correcta donde clonaste el repositorio):
   ``
   cd "Pagina web/Superset"
   ```
3. Ejecuta el servidor local por el puerto 8000:
   ```bash
   php -S localhost:8000
   ```
4. Abre tu navegador web e ingresa a `http://localhost:8000`.

## 4. Acceso al Sistema (Login)
Una vez en la pantalla de inicio de sesión de la página web, puedes ingresar con la cuenta de administrador:

* **Usuario:** `admin`
* **Contraseña:** `Sup3rs3t2026!`

> **⚠️ Nota de Administración de Usuarios:**
> La interfaz web actual no está diseñada para el registro público. La tabla de la base de datos ya es completamente funcional, por lo que la creación o gestión de nuevos clientes para el monitoreo debe realizarse directamente insertando los registros a través de un gestor de base de datos, no desde la página web.
