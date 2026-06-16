<?php
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/icons.php';

if (is_logged_in()) {
    header('Location: index.php');
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user = trim($_POST['user'] ?? '');
    $pass = $_POST['pass'] ?? '';
    if (attempt_login($user, $pass)) {
        header('Location: index.php');
        exit;
    }
    $error = 'Usuario o contraseña incorrectos.';
}
?>
<!DOCTYPE html>
<html lang="es" class="bg-background">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión · Panel de Control</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<div class="login">
    <div class="login__card">
        <div class="login__brand">
            <span class="brand__logo"><?= icon('chart', 20) ?></span>
            <span class="brand__name">Panel</span>
        </div>
        <h1>Bienvenido de nuevo</h1>
        <p class="login__sub">Inicia sesión para acceder a tus dashboards</p>

        <?php if ($error): ?>
            <div class="login__error"><?= e($error) ?></div>
        <?php endif; ?>

        <form method="post" novalidate>
            <div class="field">
                <label for="user">Usuario</label>
                <input type="text" id="user" name="user" placeholder="admin" autocomplete="username" required>
            </div>
            <div class="field">
                <label for="pass">Contraseña</label>
                <input type="password" id="pass" name="pass" placeholder="••••••••" autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn-primary">Iniciar sesión</button>
        </form>

        <p class="login__hint">Demo: admin / admin123</p>
    </div>
</div>
</body>
</html>

