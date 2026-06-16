<?php
session_start();

// 1. Conexión a la base de datos PostgreSQL en el servidor
function get_db_connection() {
    $host = '172.16.8.45';
    $db   = 'usuarios_web';
    $user = 'superset';
    $pass = 'superset'; // Cambia esto si la contraseña en tu Docker es diferente

    $dsn = "pgsql:host=$host;port=5432;dbname=$db";
    
    try {
        return new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]);
    } catch (PDOException $e) {
        die("Error de conexión a la BD: " . $e->getMessage());
    }
}

// 2. Verificar si el usuario tiene sesión activa
function is_logged_in() {
    return isset($_SESSION['usuario_id']);
}

// 3. Validar credenciales contra la base de datos
function attempt_login($username, $password) {
    $pdo = get_db_connection();
    
    $stmt = $pdo->prepare("SELECT id, password_hash FROM usuarios_web WHERE username = :username");
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password_hash'])) {
        $_SESSION['usuario_id'] = $user['id'];
        $_SESSION['username']   = $username;
        return true;
    }
    
    return false;
}

// 4. Proteger rutas privadas (redirige si no hay sesión)
function require_login() {
    if (!is_logged_in()) {
        header('Location: login.php');
        exit;
    }
}

// 5. Cargar el archivo de configuración principal (config.php)
function config() {
    // Asegúrate de que la ruta apunte correctamente a tu config.php
    return require __DIR__ . '/../config.php'; 
}

// 6. Obtener la clave del dashboard actual desde la URL
function current_dashboard_key(): string {
    $cfg = config();
    $dashboards = $cfg['dashboards'] ?? [];
    
    // Dashboard por defecto (el primero de la lista)
    $default = array_key_first($dashboards) ?: 'monitoreo';
    
    $view = $_GET['view'] ?? $default;
    
    // Validación de seguridad: ¿existe este dashboard en config?
    if (!isset($dashboards[$view])) {
        return $default;
    }
    
    return $view;
}


// 7. Función de seguridad para escapar HTML (Usada en login.php e index.php)
function e($string) {
    return htmlspecialchars($string ?? '', ENT_QUOTES, 'UTF-8');
}
?>
