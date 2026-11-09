<?php
require_once '../config/setup.php';

if (!registrationEnabled()) {
    http_response_code(403);
    exit('El registro de cuentas está deshabilitado.');
}

$db = new Database();
$conn = $db->connect();
$errors = [];
$email = '';
$emailAvailabilityMessage = '';
$emailAvailabilityStatus = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireCsrf();

    $action = postedString('action');
    $email = strtolower(trim(postedString('email')));

    if ($action === 'check_email') {
        header('Content-Type: application/json; charset=utf-8');
        if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 100) {
            echo json_encode(['available' => false, 'message' => 'Formato de correo inválido.']);
            exit;
        }

        $statement = $conn->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
        $statement->execute([':email' => $email]);
        $exists = (bool) $statement->fetchColumn();
        echo json_encode([
            'available' => !$exists,
            'message' => $exists ? 'Este correo ya está registrado.' : 'Correo disponible.'
        ]);
        exit;
    }

    $password = postedString('password');
    $confirmPassword = postedString('confirm_password');
    $acceptedPrivacy = postedString('accept_privacy') === '1';

    if ($email === '') {
        $errors['email'] = 'El correo electrónico es requerido.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 100) {
        $errors['email'] = 'Formato de correo inválido.';
    } else {
        $statement = $conn->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
        $statement->execute([':email' => $email]);
        if ($statement->fetchColumn()) {
            $errors['email'] = 'Este correo ya está registrado.';
        }
    }

    if (mb_strlen($password, 'UTF-8') < 8 || strlen($password) > 72 ||
        !preg_match('/[A-Z]/', $password) ||
        !preg_match('/[a-z]/', $password) ||
        !preg_match('/[0-9]/', $password) ||
        !preg_match('/[^A-Za-z0-9]/', $password)) {
        $errors['password'] = 'Usa al menos 8 caracteres e incluye mayúsculas, minúsculas, números y un carácter especial.';
    }

    if ($confirmPassword === '' || $password !== $confirmPassword) {
        $errors['confirm_password'] = 'Las contraseñas no coinciden.';
    }

    if (!$acceptedPrivacy) {
        $errors['privacy'] = 'Debes aceptar el Aviso de Privacidad para continuar.';
    }

    if (empty($errors)) {
        $username = 'u_' . bin2hex(random_bytes(16));
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $firstName = 'Usuario';
        $lastName = '';
        $phone = null;

        $statement = $conn->prepare(
            'INSERT INTO users (username, password, first_name, last_name, phone, email)
             VALUES (:username, :password, :first_name, :last_name, :phone, :email)'
        );

        try {
            $statement->execute([
                ':username' => $username,
                ':password' => $hashedPassword,
                ':first_name' => $firstName,
                ':last_name' => $lastName,
                ':phone' => $phone,
                ':email' => $email
            ]);
            $_SESSION['success_message'] = 'Registro exitoso. Por favor inicia sesión.';
            redirect('login.php');
        } catch (PDOException $exception) {
            if ($exception->getCode() === '23000') {
                $emailStatement = $conn->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
                $emailStatement->execute([':email' => $email]);
                if ($emailStatement->fetchColumn()) {
                    $errors['email'] = 'Este correo ya está registrado.';
                } else {
                    throw $exception;
                }
            } else {
                throw $exception;
            }
        }
    }

    if (isset($errors['email'])) {
        $emailAvailabilityMessage = $errors['email'];
        $emailAvailabilityStatus = 'error';
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Swift Invoice - Registro</title>
    <link rel="stylesheet" href="../assets/css/auth.css">
</head>
<body class="auth-register-page">
    <main class="auth-container register-container">
        <header class="register-header">
            <a class="register-brand" href="../index.php">SWIFT INVOICE</a>
        </header>
        <h1 class="register-title">Registro de usuario</h1>

        <form method="POST" id="register-form" novalidate>
            <input type="hidden" name="csrf_token" value="<?php echo e(csrfToken()); ?>">
            <div class="form-group">
                <label for="email">Correo electrónico:</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    maxlength="100"
                    autocomplete="email"
                    required
                    value="<?php echo e($email); ?>"
                    aria-describedby="email-message"
                >
                <span class="form-message<?php echo $emailAvailabilityStatus ? ' ' . e($emailAvailabilityStatus) : ''; ?>"
                      id="email-message" aria-live="polite"><?php echo e($emailAvailabilityMessage); ?></span>
            </div>

            <div class="form-group">
                <label for="password">Contraseña:</label>
                <div class="password-field">
                    <input
                        type="password"
                        id="password"
                        name="password"
                        autocomplete="new-password"
                        minlength="8"
                        maxlength="72"
                        required
                        aria-describedby="password-hint password-strength-label password-message"
                    >
                </div>
                <span class="field-hint" id="password-hint">Mínimo 8 caracteres, con mayúscula, minúscula, número y símbolo.</span>
                <div class="password-strength" id="password-strength" aria-hidden="true">
                    <span></span><span></span><span></span>
                </div>
                <span class="form-message" id="password-strength-label" aria-live="polite">Fuerza de la contraseña: sin evaluar</span>
                <span class="form-message error" id="password-message" aria-live="polite"></span>
                <?php if (isset($errors['password'])): ?>
                    <span class="error-text"><?php echo e($errors['password']); ?></span>
                <?php endif; ?>
            </div>

            <div class="form-group">
                <label for="confirm_password">Confirmar contraseña:</label>
                <input
                    type="password"
                    id="confirm_password"
                    name="confirm_password"
                    autocomplete="new-password"
                    maxlength="72"
                    required
                    aria-describedby="confirm-password-message"
                >
                <span class="form-message error" id="confirm-password-message" aria-live="polite"><?php
                    echo isset($errors['confirm_password']) ? e($errors['confirm_password']) : '';
                ?></span>
            </div>

            <div class="form-group privacy-group">
                <label class="checkbox-label" for="accept_privacy">
                    <input type="checkbox" id="accept_privacy" name="accept_privacy" value="1"
                        aria-describedby="privacy-message"
                        required<?php echo postedString('accept_privacy') === '1' ? ' checked' : ''; ?>>
                    <span>He leído y acepto el <a href="privacy.php" target="_blank" rel="noopener noreferrer">Aviso de Privacidad</a>.</span>
                </label>
                <span class="form-message error" id="privacy-message" aria-live="polite"><?php
                    echo isset($errors['privacy']) ? e($errors['privacy']) : '';
                ?></span>
            </div>

            <button type="submit" class="btn">Crear cuenta</button>
        </form>

        <div class="auth-links">
            <span>¿Ya tienes cuenta? <a href="login.php">Inicia sesión</a></span>
        </div>
    </main>

    <script>
        const registerForm = document.getElementById('register-form');
        const emailInput = document.getElementById('email');
        const emailMessage = document.getElementById('email-message');
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirm_password');
        const confirmPasswordMessage = document.getElementById('confirm-password-message');
        const passwordMessage = document.getElementById('password-message');
        const passwordStrengthLabel = document.getElementById('password-strength-label');
        const passwordStrength = document.getElementById('password-strength');
        const privacyInput = document.getElementById('accept_privacy');
        const privacyMessage = document.getElementById('privacy-message');
        const strengthBars = document.querySelectorAll('.password-strength span');
        const csrfToken = registerForm.elements.csrf_token.value;
        let emailCheckTimer;
        let emailCheckRequest = 0;
        let emailIsUnavailable = false;

        function validEmail(value) {
            return emailInput.validity.valid && value.length <= 100;
        }

        function checkEmail() {
            const value = emailInput.value.trim().toLowerCase();
            const requestId = ++emailCheckRequest;
            emailIsUnavailable = false;
            emailMessage.className = 'form-message';
            emailMessage.textContent = '';

            if (!value) {
                return;
            }
            if (!validEmail(value)) {
                emailMessage.textContent = 'Formato de correo inválido.';
                emailMessage.classList.add('error');
                return;
            }

            emailMessage.textContent = 'Verificando correo…';
            clearTimeout(emailCheckTimer);
            emailCheckTimer = setTimeout(async () => {
                const body = new URLSearchParams({
                    csrf_token: csrfToken,
                    action: 'check_email',
                    email: value
                });
                try {
                    const response = await fetch('register.php', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                        body
                    });
                    if (!response.ok) {
                        throw new Error('No fue posible verificar el correo.');
                    }
                    const result = await response.json();
                    if (requestId !== emailCheckRequest || value !== emailInput.value.trim().toLowerCase()) {
                        return;
                    }
                    emailIsUnavailable = !result.available;
                    emailMessage.textContent = result.message;
                    emailMessage.classList.add(result.available ? 'success' : 'error');
                } catch (error) {
                    if (requestId === emailCheckRequest) {
                        emailMessage.textContent = error.message;
                        emailMessage.classList.add('error');
                    }
                }
            }, 350);
        }

        emailInput.addEventListener('input', checkEmail);
        emailInput.addEventListener('blur', checkEmail);
        privacyInput.addEventListener('change', () => {
            privacyMessage.textContent = '';
        });

        function validatePasswordConfirmation() {
            const mismatch = confirmPasswordInput.value !== '' &&
                confirmPasswordInput.value !== passwordInput.value;
            confirmPasswordMessage.textContent = mismatch ? 'Las contraseñas no coinciden.' : '';
            return confirmPasswordInput.value !== '' && !mismatch;
        }

        confirmPasswordInput.addEventListener('input', validatePasswordConfirmation);
        passwordInput.addEventListener('input', validatePasswordConfirmation);

        passwordInput.addEventListener('input', () => {
            const password = passwordInput.value;
            const checks = [
                [...password].length >= 8 && new TextEncoder().encode(password).length <= 72,
                /[A-Z]/.test(password) && /[a-z]/.test(password),
                /[0-9]/.test(password),
                /[^A-Za-z0-9]/.test(password)
            ];
            const strength = checks.filter(Boolean).length;
            const rating = strength === 4 ? 'secure' : strength >= 2 ? 'medium' : 'weak';
            const filledBars = strength === 0 ? 0 : strength === 4 ? 3 : strength >= 2 ? 2 : 1;
            strengthBars.forEach((bar, index) => {
                bar.classList.toggle('filled', index < filledBars);
            });
            passwordStrength.className = `password-strength${password ? ` strength-${rating}` : ''}`;
            const ratingLabel = rating === 'secure' ? 'segura' : rating === 'medium' ? 'media' : 'débil';
            passwordStrengthLabel.textContent = `Fuerza de la contraseña: ${password ? ratingLabel : 'sin evaluar'}`;
            const policyMet = checks.every(Boolean);
            passwordMessage.textContent = password && !policyMet
                ? 'Aún no cumple todos los requisitos de seguridad.'
                : '';
        });

        registerForm.addEventListener('submit', (event) => {
            const emailValue = emailInput.value.trim();
            const emailIsValid = emailValue !== '' && validEmail(emailValue);
            const passwordIsValid = passwordInput.value !== '' && passwordMessage.textContent === '';
            const passwordsMatch = validatePasswordConfirmation();

            if (!emailIsValid || emailIsUnavailable || !passwordIsValid || !passwordsMatch || !privacyInput.checked) {
                event.preventDefault();
                if (!emailValue) {
                    emailMessage.textContent = 'El correo electrónico es requerido.';
                    emailMessage.classList.add('error');
                    emailInput.focus();
                } else if (!emailIsValid) {
                    emailMessage.textContent = 'Formato de correo inválido.';
                    emailMessage.classList.add('error');
                    emailInput.focus();
                } else if (emailIsUnavailable) {
                    emailInput.focus();
                } else if (!passwordIsValid) {
                    passwordMessage.textContent = passwordInput.value
                        ? 'Aún no cumple todos los requisitos de seguridad.'
                        : 'La contraseña es requerida.';
                    passwordInput.focus();
                } else if (!passwordsMatch) {
                    if (!confirmPasswordInput.value) {
                        confirmPasswordMessage.textContent = 'Confirma tu contraseña.';
                    }
                    confirmPasswordInput.focus();
                } else {
                    privacyMessage.textContent = 'Debes aceptar el Aviso de Privacidad para continuar.';
                    privacyInput.focus();
                }
            }
        });
    </script>
</body>
</html>
