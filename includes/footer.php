</main>

<footer>
    <div class="container">
        <!-- Aquí puedes agregar información de pie de página, copyright, etc. -->
    </div>
</footer>

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
