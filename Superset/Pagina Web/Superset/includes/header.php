<?php
/** @var string $activeKey  clave del dashboard activo */
/** @var array  $dashboard  datos del dashboard activo */
require_once __DIR__ . '/icons.php';

$dashboards = config()['dashboards'];
$userName   = $_SESSION['user'] ?? 'Usuario';
$initial    = strtoupper(substr($userName, 0, 1));
$iconMap    = ['monitoreo' => 'pulse', 'historico' => 'history'];
?>
<!DOCTYPE html>
<html lang="es" class="bg-background">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($dashboard['title']) ?> · Panel de Control</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<div class="app">
    <!-- ===== Barra lateral ===== -->
    <aside class="sidebar">
        <div class="brand">
            <span class="brand__logo"><?= icon('chart', 20) ?></span>
            <span class="brand__name">Panel</span>
        </div>

        <p class="nav-label">Dashboards</p>
        <nav class="nav">
            <?php foreach ($dashboards as $key => $item): ?>
                <a
                    href="?view=<?= e($key) ?>"
                    class="nav__item <?= $key === $activeKey ? 'is-active' : '' ?>"
                >
                    <?= icon($iconMap[$key] ?? 'chart', 20) ?>
                    <span><?= e($item['title']) ?></span>
                </a>
            <?php endforeach; ?>
        </nav>

        <div class="sidebar__footer">
            <a href="logout.php" class="logout">
                <?= icon('logout', 20) ?>
                <span>Cerrar sesión</span>
            </a>
        </div>
    </aside>

    <!-- ===== Contenido principal ===== -->
    <main class="main">
        <!-- Barra superior -->
        <header class="topbar">
            <div class="search">
                <?= icon('search', 18) ?>
                <input type="text" placeholder="Buscar…" aria-label="Buscar">
            </div>
            <div class="topbar__spacer"></div>
            <button class="icon-btn icon-btn--primary" aria-label="Nuevo">
                <?= icon('plus', 20) ?>
            </button>
            <button class="icon-btn" aria-label="Notificaciones">
                <?= icon('bell', 20) ?>
                <span class="badge">2</span>
            </button>
            <button class="icon-btn" aria-label="Mensajes">
                <?= icon('mail', 20) ?>
            </button>
            <div class="user">
                <span class="user__avatar"><?= e($initial) ?></span>
                <span class="user__name"><?= e($userName) ?></span>
            </div>
        </header>

