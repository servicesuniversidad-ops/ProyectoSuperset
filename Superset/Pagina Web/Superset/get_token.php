<?php
require_once __DIR__ . '/includes/auth.php';
require_login(); 

$uuid = $_GET['uuid'] ?? '';
if (!$uuid) {
    http_response_code(400);
    die("Falta el UUID del dashboard");
}

$superset_url = 'http://172.16.8.45:8088';
$superset_user = 'admin'; 
$superset_pass = 'Sup3rs3t2026!'; // <-- Asegúrate de cambiarla

// 1. Login
$ch = curl_init("$superset_url/api/v1/security/login");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'username' => $superset_user,
    'password' => $superset_pass,
    'provider' => 'db'
]));
$login_resp = json_decode(curl_exec($ch), true);
curl_close($ch);

$access_token = $login_resp['access_token'] ?? null;

// 2. Guest Token
$guest_payload = [
    'user' => [
        'username' => $_SESSION['username'], 
        'first_name' => 'Usuario',
        'last_name' => 'Web'
    ],
    'resources' => [
        ['type' => 'dashboard', 'id' => $uuid]
    ],
    'rls' => [] 
];

$ch2 = curl_init("$superset_url/api/v1/security/guest_token/");
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    "Authorization: Bearer $access_token"
]);
curl_setopt($ch2, CURLOPT_POST, true);
curl_setopt($ch2, CURLOPT_POSTFIELDS, json_encode($guest_payload));
$guest_resp = json_decode(curl_exec($ch2), true);
curl_close($ch2);

// Imprime solo el token puro para que JavaScript lo consuma
echo $guest_resp['token'] ?? "";
?>
