(() => {
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
