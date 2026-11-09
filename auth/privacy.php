<?php
require_once '../config/setup.php';

$controllerName = getenv('PRIVACY_CONTROLLER_NAME') ?: 'la persona o entidad que administra esta instancia de Swift Invoice';
$contactEmail = getenv('PRIVACY_CONTACT_EMAIL') ?: '';
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Swift Invoice - Aviso de Privacidad</title>
    <link rel="stylesheet" href="../assets/css/auth.css">
</head>
<body>
    <main class="auth-container privacy-container">
        <h1>Swift Invoice</h1>
        <h2>Aviso de Privacidad</h2>
        <p><strong>Última actualización: 9 de noviembre de 2026</strong></p>

        <h3>Responsable del tratamiento</h3>
        <p>
            El responsable de los datos personales tratados en esta instalación es
            <?php echo e($controllerName); ?>, quien opera y administra el servicio.
            Este aviso se aplica a la instalación concreta desde la que te registras;
            Swift Invoice puede ser instalado y administrado por entidades distintas.
        </p>
        <?php if ($contactEmail !== '' && filter_var($contactEmail, FILTER_VALIDATE_EMAIL)): ?>
            <p>Para consultas o solicitudes sobre privacidad, escribe a
                <a href="mailto:<?php echo e($contactEmail); ?>"><?php echo e($contactEmail); ?></a>.
            </p>
        <?php else: ?>
            <p>Para ejercer tus derechos o realizar consultas, contacta al administrador
                de la instancia por el canal de soporte que te haya proporcionado.</p>
        <?php endif; ?>

        <h3>Datos que tratamos</h3>
        <ul>
            <li>Al crear una cuenta: correo electrónico y contraseña, que se almacena como un hash y no en texto legible. El sistema también genera un identificador interno.</li>
            <li>Al utilizar la aplicación: los datos de clientes, empresas, productos, ventas y facturación que el usuario decida incorporar.</li>
            <li>Datos técnicos necesarios para la seguridad y operación, como la sesión autenticada y los intentos fallidos de inicio de sesión asociados a una dirección IP transformada mediante hash.</li>
        </ul>

        <h3>Finalidades y fundamento</h3>
        <p>
            Usamos estos datos para crear y proteger cuentas, autenticar usuarios, ofrecer
            las funciones de gestión de la aplicación, mantener la seguridad y atender
            obligaciones legales que correspondan al administrador. La base jurídica
            aplicable depende de la jurisdicción y del uso concreto de esta instalación;
            puede incluir la ejecución del servicio solicitado, el consentimiento cuando
            sea exigible y el cumplimiento de obligaciones legales.
        </p>

        <h3>Carácter obligatorio</h3>
        <p>
            El correo y la contraseña son necesarios para crear una cuenta. Si no
            proporcionas esos datos o no aceptas este aviso, no podrás registrarte.
            El formulario no solicita nombre, apellido ni teléfono.
        </p>

        <h3>Conservación</h3>
        <p>
            Los datos de la cuenta se conservan mientras esta exista y durante el tiempo
            adicional necesario para atender responsabilidades legales o resolver
            controversias. Los datos operativos se conservan según las necesidades del
            servicio y las obligaciones aplicables. El administrador de esta instancia
            determina y aplica los periodos concretos de conservación y eliminación.
        </p>

        <h3>Destinatarios y alojamiento</h3>
        <p>
            Swift Invoice no envía los datos de registro a un servicio externo por sí
            mismo. Los datos se almacenan en la base de datos configurada por el
            administrador; el proveedor de alojamiento o infraestructura podría tener
            acceso técnico conforme a sus funciones y condiciones. El administrador
            debe informar sobre cualquier otro destinatario o transferencia
            internacional que aplique a su instalación.
        </p>

        <h3>Cookies y seguridad</h3>
        <p>
            La aplicación utiliza una cookie de sesión necesaria para mantener el inicio
            de sesión y proteger las solicitudes. No se utilizan cookies publicitarias en
            el flujo de registro. Se aplican controles técnicos como protección CSRF,
            hash de contraseñas y limitación de intentos de inicio de sesión; el
            administrador también debe proteger el servidor, las copias de seguridad y
            la base de datos.
        </p>

        <h3>Tus derechos y cambios</h3>
        <p>
            Puedes solicitar acceso, rectificación, eliminación u oponerte al tratamiento
            cuando esos derechos estén reconocidos por la legislación aplicable.
            Contacta al responsable mediante el canal indicado arriba. También puedes
            acudir a la autoridad de protección de datos competente en tu jurisdicción.
            El responsable puede actualizar este aviso; la versión vigente estará
            disponible desde el formulario de registro.
        </p>

        <div class="auth-links">
            <a href="register.php">Volver al registro</a>
        </div>
    </main>
</body>
</html>
