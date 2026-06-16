<?php
require_once __DIR__ . '/includes/auth.php';
require_login();

$activeKey = current_dashboard_key();
$dashboard = config()['dashboards'][$activeKey];

require __DIR__ . '/includes/header.php';
?>
        <section class="content">
            <div class="content__head">
                <div>
                    <h1 class="content__title"><?= e($dashboard['title']) ?></h1>
                    <p class="content__subtitle"><?= e($dashboard['subtitle']) ?></p>
                </div>
                <span class="pill">
                    <?= icon('chevron', 16) ?>
                    Apache Superset
                </span>
            </div>

            <?php if (!empty($dashboard['uuid'])): ?>
                <div id="superset-container" class="embed" style="width: 100%; min-height: 700px; border-radius: 8px; overflow: hidden;"></div>

                <script src="https://unpkg.com/@superset-ui/embedded-sdk"></script>
                <script>
                    document.addEventListener("DOMContentLoaded", function() {
                        const container = document.getElementById("superset-container");
                        
                        supersetEmbeddedSdk.embedDashboard({
                            id: "<?= e($dashboard['uuid']) ?>", 
                            supersetDomain: "http://172.16.8.45:8088",
                            mountPoint: container,
                            // Aquí JavaScript le pide el pase temporal a tu nuevo archivo PHP
                            fetchGuestToken: () => fetch("get_token.php?uuid=<?= e($dashboard['uuid']) ?>").then(res => res.text()),
                            dashboardUiConfig: {
                                hideTitle: true,
                                hideChartControls: false,
                                hideTab: false,
                            }
                        });
                    });
                </script>
            <?php else: ?>
                <div class="embed-placeholder">
                    <span class="embed-placeholder__icon"><?= icon('chart', 30) ?></span>
                    <h3>Contenedor listo para Apache Superset</h3>
                    <p>
                        Pega el UUID de tu dashboard en el
                        archivo <strong>config.php</strong>, en la clave
                        <strong>'<?= e($activeKey) ?>' &rarr; 'uuid'</strong>.
                    </p>
                </div>
            <?php endif; ?>
        </section>
<?php require __DIR__ . '/includes/footer.php'; ?>
