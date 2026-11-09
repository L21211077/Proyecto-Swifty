</main>

<footer>
    <div class="container">
        <!-- Aquí puedes agregar información de pie de página, copyright, etc. -->
    </div>
</footer>

<aside class="app-controls" aria-label="Controles de la aplicación">
    <section class="settings-panel" id="settings-panel" aria-labelledby="settings-title" hidden>
        <h2 class="settings-panel__title" id="settings-title">Configuración</h2>

        <label class="settings-panel__label" for="ui-scale">Tamaño de la interfaz</label>
        <select class="settings-panel__select" id="ui-scale" data-ui-scale>
            <option value="90">Compacta (90%)</option>
            <option value="100">Normal (100%)</option>
            <option value="110">Grande (110%)</option>
        </select>

        <label class="settings-panel__label" for="ui-accent">Color de la interfaz</label>
        <select class="settings-panel__select" id="ui-accent" data-ui-accent>
            <option value="blue">Azul</option>
            <option value="black">Negro</option>
        </select>

        <button class="app-control-button settings-panel__theme" type="button" data-theme-toggle aria-pressed="false">
            ☾ Activar modo nocturno
        </button>
    </section>

    <button class="app-control-button app-control-button--settings" type="button" data-settings-toggle aria-expanded="false" aria-controls="settings-panel">
        <span aria-hidden="true">⚙</span>
        <span>Configuración</span>
    </button>
    <a href="/swift_invoice/auth/logout.php" class="app-control-button app-control-button--logout">
        <span aria-hidden="true">↪</span>
        <span>Cerrar sesión</span>
    </a>
</aside>

<div class="logout-modal" id="logout-modal" role="dialog" aria-modal="true" aria-labelledby="logout-modal-title" aria-describedby="logout-modal-description" hidden>
    <div class="logout-modal__card">
        <div class="logout-modal__icon" aria-hidden="true">↪</div>
        <h2 class="logout-modal__title" id="logout-modal-title">¿Cerrar sesión?</h2>
        <p class="logout-modal__description" id="logout-modal-description">Tu sesión se cerrará y volverás a la pantalla de inicio de sesión.</p>
        <div class="logout-modal__actions">
            <button class="logout-modal__button logout-modal__button--cancel" type="button" data-logout-cancel>Cancelar</button>
            <form method="POST" action="/swift_invoice/auth/logout.php">
                <input type="hidden" name="csrf_token" value="<?php echo e(csrfToken()); ?>">
                <button class="logout-modal__button logout-modal__button--confirm" type="submit">Cerrar sesión</button>
            </form>
        </div>
    </div>
</div>

<!-- Carga el JS principal global del sistema -->
<script src="/swift_invoice/assets/js/main.js?v=<?php echo filemtime(__DIR__ . '/../assets/js/main.js'); ?>"></script>

<!-- Si la vista define $custom_js, lo carga aquí (por ejemplo, para JS exclusivo de ventas o clientes) -->
<?php if (isset($custom_js)): ?>
    <script src="<?php echo $custom_js; ?>"></script>
<?php endif; ?>

</body>
</html>
