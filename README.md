# Swift Invoice

**Swift Invoice** es una aplicación web para la gestión integral de ventas y facturación, enfocada en la administración eficiente y digital de clientes (personas y empresas), productos y comprobantes fiscales.  
Funciona en cualquier servidor local o web con PHP y utiliza MySQL para el almacenamiento seguro de la información.

---

## 🧩 **Características**

- Administración de clientes: personas físicas y empresas, con información fiscal.
- Registro y edición de ventas, asignando cliente y productos.
- Generación de facturas o comprobantes en PDF con diseño profesional.
- Control y configuración de impuestos por producto o venta.
- Catálogo de productos y servicios con precios y descripciones.
- Historial y búsqueda de ventas, clientes y productos.
- Reportes básicos para consulta y análisis.
- Enfoque **paperless**: reduce uso de papel y facilita la digitalización de procesos.
- Estructura modular, fácil de mantener y expandir.
- Compatible con cualquier entorno PHP/MySQL (XAMPP, WAMP, servidores en la nube).

---

## ⚙️ **Requisitos**

- PHP 7.4 o superior
- MySQL o MariaDB
- Servidor web (Apache, Nginx, etc.)

---

## 🚀 **Instalación**

1. Clona el repositorio o descarga el proyecto.
2. Crea una base de datos MySQL. Para desarrollo local, la conexión usa por defecto `localhost:3306`, la base `swift_invoice_db` y el usuario `root` sin contraseña.
3. Importa `script.sql`; contiene el esquema y los catálogos, no cuentas ni transacciones de ejemplo.
4. Accede desde tu navegador a la ruta donde instalaste Swift Invoice.
5. ¡Listo! Comienza a administrar tus ventas y clientes de manera digital.

## API REST

La especificación OpenAPI está en [`openapi.yaml`](./openapi.yaml). En el XAMPP local con el proyecto en `htdocs\Proyecto-Swifty` y `mod_rewrite` activo, la API se sirve bajo `/Proyecto-Swifty/api/v1`; sustituye `Proyecto-Swifty` por el nombre/ruta pública usada al desplegar:

- `GET /auth/csrf` entrega un token CSRF y establece la cookie de sesión.
- `POST /auth/login` inicia sesión; envía JSON y el token en `X-CSRF-Token`.
- `POST /auth/logout` cierra la sesión; requiere cookie y token CSRF.
- `/clients`, `/companies` y `/products` tienen operaciones de lectura y CRUD protegidas por sesión; las mutaciones requieren CSRF.
- `/sales` permite listar, consultar, crear y eliminar ventas. Los precios se obtienen del catálogo del servidor.
- `/invoices` permite listar y consultar facturas.
- `/catalogs/business-types` y `/catalogs/tax-regimes` exponen catálogos de solo lectura.

Las listas aceptan `limit` (1–100, predeterminado 20) y `offset` (predeterminado 0). La paginación se informa en `X-Total-Count`, `X-Limit` y `X-Offset`. Los errores usan una respuesta JSON común y códigos HTTP específicos.

La autenticación de la API utiliza la sesión PHP de la aplicación; no es una API de tokens para clientes externos. No se habilita CORS. Las peticiones de escritura deben conservar la cookie y enviar el token CSRF recibido para esa sesión. Las sesiones vencen tras 30 minutos de inactividad y los cuerpos JSON están limitados a 1 MiB.

## Respaldos completos en MongoDB Atlas

La conexión reutilizable [`getMongoDatabase`](./config/mongodb.php) usa la librería oficial `mongodb/mongodb`. La base de datos de Atlas predeterminada es `swift_invoice` y puede cambiarse con `MONGODB_DATABASE`. Para respaldar la base MySQL completa, el script CLI [`create_mongodb_backup.php`](./scripts/create_mongodb_backup.php) ejecuta `mysqldump` incluyendo estructura, datos, rutinas, triggers y eventos, y almacena el archivo `.sql` en MongoDB GridFS (`database_backups`, configurable con `MONGODB_BACKUP_BUCKET`). GridFS permite guardar respaldos mayores que el límite de 16 MB de un documento BSON. Es un respaldo manual puntual, no una réplica ni espejo en tiempo real: los cambios realizados después del respaldo no se reflejan en Atlas hasta la siguiente ejecución. El snapshot anterior de solo usuarios sigue disponible por separado en [`create_mongodb_snapshot.php`](./scripts/create_mongodb_snapshot.php); no lo uses como respaldo completo.

Habilita la extensión PHP `mongodb` compatible con tu versión de PHP e instala `mysqldump` (XAMPP incluye `C:\xampp\mysql\bin\mysqldump.exe`; el script lo detecta automáticamente en la instalación estándar). Configura las variables de MongoDB en el entorno de PHP o en el archivo `.env` de la raíz, y las variables de MySQL en el entorno del proceso PHP:

- `MONGODB_URI`: cadena de conexión de Atlas, incluyendo usuario y contraseña.
- `MONGODB_DATABASE`: base de datos de destino (opcional; predeterminada `swift_invoice`).
- `MONGODB_BACKUP_BUCKET`: bucket GridFS de respaldos (opcional; predeterminado `database_backups`).
- `MYSQLDUMP_BIN`: ruta al ejecutable `mysqldump` si no está en `PATH` (por ejemplo, `C:\xampp\mysql\bin\mysqldump.exe` en XAMPP).
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASSWORD`: configuración de la base MySQL que se respaldará.

La conexión MySQL usa `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASSWORD`; en desarrollo, si no se configuran, usa `localhost:3306`, `swift_invoice_db`, usuario `root` y contraseña vacía. Ejecuta el respaldo manual desde la raíz del proyecto:

```sh
php scripts/create_mongodb_backup.php
```

Cada ejecución agrega un respaldo nuevo e imprime su ID de GridFS. Descárgalo sustituyendo `<ID>` por ese identificador:

```sh
php scripts/download_mongodb_backup.php <ID> respaldo.sql
```

Para restaurarlo, usa una instancia MySQL/MariaDB de recuperación y el cliente de la misma instalación (por ejemplo, en `cmd.exe`):

```cmd
C:\xampp\mysql\bin\mysql.exe --user=USUARIO --password < respaldo.sql
```

El dump contiene la estructura, datos y rutinas de esa base; no incluye usuarios/permisos globales del servidor MySQL. Protege los permisos de Atlas: los respaldos contienen todos los datos, incluidas credenciales y hashes almacenados en MySQL. No publiques el `.env` ni la URI/contraseñas. El script usa un archivo temporal de credenciales para `mysqldump` y lo elimina al terminar. Ejecuta periódicamente el comando según la frecuencia de respaldo que necesites; no se configura ni ejecuta automáticamente.

## Configuración de producción y seguridad

- Configura `APP_ENV=production`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASSWORD` en el entorno de Apache/PHP. En producción, la aplicación no acepta las credenciales locales predeterminadas.
- Usa un usuario MySQL dedicado con los permisos mínimos necesarios; no uses `root`.
- Publica el sitio solo por HTTPS. Configura PHP para `display_errors=Off` y `log_errors=On`, y protege los archivos de log.
- Las cookies de sesión usan `HttpOnly` y `SameSite=Lax`; se marcan `Secure` y se envía HSTS cuando PHP detecta una conexión HTTPS.
- El registro público se desactiva por defecto cuando `APP_ENV=production`. Para crear la primera cuenta, habilita `ALLOW_REGISTRATION=true` solo durante una ventana controlada y vuelve a desactivarlo al terminar.
- El formulario de registro está en [`auth/register.php`](./auth/register.php) y solicita correo electrónico, contraseña, confirmación de contraseña y aceptación explícita del aviso. Valida el formato y la disponibilidad del correo, exige una contraseña de al menos 8 caracteres con mayúsculas, minúsculas, números y símbolos, y muestra un indicador de fuerza (débil, media o segura). La contraseña permanece oculta mientras se escribe. La casilla de privacidad está desmarcada por defecto y es obligatoria; enlaza al [`Aviso de Privacidad`](./auth/privacy.php), que se abre en otra pestaña. Configura `PRIVACY_CONTROLLER_NAME` y `PRIVACY_CONTACT_EMAIL` con la identidad y el contacto reales de quien administra cada instalación. Las obligaciones y los plazos de conservación deben ajustarse a la jurisdicción aplicable.
- El límite de intentos de inicio de sesión usa la tabla `auth_login_attempts`. En instalaciones existentes ejecuta una vez [`20261104_auth_login_attempts.sql`](./database/migrations/20261104_auth_login_attempts.sql); las instalaciones nuevas la crean al importar `script.sql`.
- Los archivos `.htaccess` protegen rutas y archivos en Apache. Si se usa Nginx u otro servidor, aplica reglas equivalentes y habilita el enrutamiento de `/api/v1`.
- Los usuarios autenticados comparten los mismos permisos; el esquema actual no implementa roles. Antes de ofrecer acceso a varios perfiles, agrega autorización por rol y propiedad de datos.
- El volcado ya no incluye registros de usuarios, clientes o transacciones, pero borrar esos registros del archivo actual no los elimina de commits anteriores. Si el repositorio estuvo compartido, limpia el historial de forma coordinada y gestiona las credenciales/datos expuestos.

Estas medidas reducen riesgos comunes, pero no permiten garantizar que una aplicación sea “inhackeable”. Mantén PHP, dependencias y servidor actualizados, y realiza pruebas de seguridad antes de publicar el sistema.
