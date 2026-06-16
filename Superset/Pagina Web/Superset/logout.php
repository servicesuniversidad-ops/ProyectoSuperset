<?php
require_once __DIR__ . '/includes/auth.php';

// 1. Vaciamos todas las variables de sesión activas
session_unset();

// 2. Destruimos la sesión en el servidor
session_destroy();

// 3. Redirigimos al usuario a la pantalla de login
header('Location: login.php');
exit;
