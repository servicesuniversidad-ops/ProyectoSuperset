<?php

/**
 * Iconos SVG inline (estilo line, 1.6 stroke). Uso: icon('nombre').
 */
function icon(string $name, int $size = 20): string
{
    $icons = [
        'pulse'   => '<path d="M22 12h-4l-3 9L9 3l-3 9H2"/>',
        'history' => '<path d="M3 3v5h5"/><path d="M3.05 13A9 9 0 1 0 6 5.3L3 8"/><path d="M12 7v5l4 2"/>',
        'logout'  => '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>',
        'search'  => '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
        'bell'    => '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
        'mail'    => '<rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>',
        'plus'    => '<path d="M5 12h14"/><path d="M12 5v14"/>',
        'chart'   => '<path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/>',
        'chevron' => '<path d="m6 9 6 6 6-6"/>',
        'lock'    => '<rect width="18" height="11" x="3" y="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
    ];

    $path = $icons[$name] ?? '';

    return sprintf(
        '<svg xmlns="http://www.w3.org/2000/svg" width="%1$d" height="%1$d" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">%2$s</svg>',
        $size,
        $path
    );
}

