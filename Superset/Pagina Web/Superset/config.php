<?php

/**
 * Configuración central del panel.
 *
 * Para incrustar un dashboard de Apache Superset, pega la URL "standalone"
 * de cada dashboard en la clave 'src'. Ejemplo:
 *
 *   'src' => 'https://tu-superset.com/superset/dashboard/1/?standalone=2'
 *
 * Mientras 'src' sea null, se mostrará un marcador en su lugar.
 */

return [
    // Credenciales de acceso (demo). Cámbialas o conéctalas a tu base de datos.
    'users' => [
        'admin' => 'admin123',
    ],

    // Dashboards que aparecen en la barra lateral.
    'dashboards' => [
        'monitoreo' => [
            'title'    => 'Monitoreo',
            'subtitle' => 'Visualización de datos en tiempo real',
            'uuid'      => '8132611a-9998-402b-8dcd-5c58fbb73337', // <-- URL del dashboard de Superset
        ],
        'historico' => [
            'title'    => 'Histórico',
            'subtitle' => 'Análisis de tendencias y datos históricos',
            'uuid'      => 'b1e93604-ba1f-4bca-9d69-0e78dec9beb8', // <-- URL del dashboard de Superset
        ],
    ],
];

