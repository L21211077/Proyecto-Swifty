(() => {
    const root = document.documentElement;
    const settingsPanel = document.getElementById('settings-panel');
    const settingsToggle = document.querySelector('[data-settings-toggle]');
    const scaleSelect = document.querySelector('[data-ui-scale]');
    const accentSelect = document.querySelector('[data-ui-accent]');
    const themeToggle = document.querySelector('[data-theme-toggle]');
    const preferencesKey = 'swift-invoice-preferences';
    const allowedScales = ['90', '100', '110'];

    let preferences = { scale: '100', accent: 'blue', theme: 'default' };
    let storedPreferences = null;
    try {
        storedPreferences = localStorage.getItem(preferencesKey);
    } catch (error) {
        console.error('No se pudieron leer las preferencias de interfaz.', error);
    }

    if (storedPreferences) {
        try {
            const saved = JSON.parse(storedPreferences);
            if (saved && allowedScales.includes(saved.scale)) {
                preferences.scale = saved.scale;
            }
            if (saved && ['blue', 'black'].includes(saved.accent)) {
                preferences.accent = saved.accent;
            }
            if (saved && ['default', 'night'].includes(saved.theme)) {
                preferences.theme = saved.theme;
            }
        } catch (error) {
            console.error('Las preferencias guardadas tienen un formato inválido.', error);
        }
    }

    const applyPreferences = () => {
        root.dataset.uiScale = preferences.scale;
        root.dataset.accent = preferences.accent;
        root.dataset.theme = preferences.theme;
        scaleSelect.value = preferences.scale;
        accentSelect.value = preferences.accent;
        themeToggle.setAttribute('aria-pressed', String(preferences.theme === 'night'));
        themeToggle.textContent = preferences.theme === 'night'
            ? '☀ Desactivar modo nocturno'
            : '☾ Activar modo nocturno';
    };

    const savePreferences = () => {
        applyPreferences();
        try {
            localStorage.setItem(preferencesKey, JSON.stringify(preferences));
        } catch (error) {
            console.error('No se pudieron guardar las preferencias de interfaz.', error);
        }
    };

    applyPreferences();

    settingsToggle.addEventListener('click', () => {
        const isOpen = !settingsPanel.hidden;
        settingsPanel.hidden = isOpen;
        settingsToggle.setAttribute('aria-expanded', String(!isOpen));
    });

    scaleSelect.addEventListener('change', () => {
        preferences.scale = scaleSelect.value;
        savePreferences();
    });

    accentSelect.addEventListener('change', () => {
        preferences.accent = accentSelect.value;
        savePreferences();
    });

    themeToggle.addEventListener('click', () => {
        preferences.theme = preferences.theme === 'night' ? 'default' : 'night';
        savePreferences();
    });

    document.addEventListener('click', (event) => {
        if (!settingsPanel.hidden && !event.target.closest('.app-controls')) {
            settingsPanel.hidden = true;
            settingsToggle.setAttribute('aria-expanded', 'false');
        }
    });

    const modal = document.getElementById('logout-modal');
    if (!modal) {
        return;
    }

    const cancelButton = modal.querySelector('[data-logout-cancel]');
    const confirmButton = modal.querySelector('.logout-modal__button--confirm');
    let triggeringLink = null;

    const closeModal = () => {
        modal.hidden = true;
        document.body.style.overflow = '';
        if (triggeringLink) {
            triggeringLink.focus();
            triggeringLink = null;
        }
    };

    document.addEventListener('click', (event) => {
        const link = event.target.closest('a[href*="/auth/logout.php"]');
        if (!link || event.defaultPrevented || event.button !== 0 ||
            event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
            return;
        }

        event.preventDefault();
        triggeringLink = link;
        modal.hidden = false;
        document.body.style.overflow = 'hidden';
        cancelButton.focus();
    });

    cancelButton.addEventListener('click', closeModal);
    modal.addEventListener('click', (event) => {
        if (event.target === modal) {
            closeModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (modal.hidden) {
            return;
        }

        if (event.key === 'Escape') {
            closeModal();
        } else if (event.key === 'Tab') {
            event.preventDefault();
            (document.activeElement === cancelButton ? confirmButton : cancelButton).focus();
        }
    });
})();
