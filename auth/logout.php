<?php
require_once '../config/setup.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireCsrf();

    destroySession();

    redirect('/swift_invoice/auth/login.php');
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    header('Allow: GET, POST');
    exit('Método no permitido.');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerrar sesión - Swift Invoice</title>
    <link rel="stylesheet" href="../assets/css/auth.css">
</head>
<body>
    <main class="auth-container logout-confirmation">
        <h1>SWIFT INVOICE</h1>
        <h2>Confirmación</h2>
        <p>Tu sesión se cerrará y volverás a la pantalla de inicio de sesión.</p>
        <form method="POST">
            <input type="hidden" name="csrf_token" value="<?php echo e(csrfToken()); ?>">
            <div class="logout-confirmation__actions">
                <button class="btn" type="submit">Cerrar sesión</button>
                <a class="logout-confirmation__cancel" href="/swift_invoice/">Cancelar</a>
            </div>
        </form>
    </main>
</body>
</html>
