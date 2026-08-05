document.addEventListener('DOMContentLoaded', function () {
    var tabButtons = Array.prototype.slice.call(document.querySelectorAll('[data-tab-target]'));
    var tabPanels = Array.prototype.slice.call(document.querySelectorAll('.tab-panel'));

    function activateTab(panelId, updateHash) {
        var target = document.getElementById(panelId);
        if (!target) return;

        tabButtons.forEach(function (button) {
            var active = button.getAttribute('data-tab-target') === panelId;
            button.classList.toggle('is-active', active);
            button.setAttribute('aria-selected', active ? 'true' : 'false');
            button.setAttribute('tabindex', active ? '0' : '-1');
        });

        tabPanels.forEach(function (panel) {
            var active = panel.id === panelId;
            panel.classList.toggle('is-active', active);
            panel.hidden = !active;
        });

        if (updateHash && window.history && window.history.replaceState) {
            window.history.replaceState(null, '', '#' + panelId.replace('tab-', ''));
        }
    }

    tabButtons.forEach(function (button, index) {
        button.addEventListener('click', function () {
            activateTab(button.getAttribute('data-tab-target'), true);
        });

        button.addEventListener('keydown', function (event) {
            if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
            event.preventDefault();
            var direction = event.key === 'ArrowRight' ? 1 : -1;
            var nextIndex = (index + direction + tabButtons.length) % tabButtons.length;
            tabButtons[nextIndex].focus();
            activateTab(tabButtons[nextIndex].getAttribute('data-tab-target'), true);
        });
    });

    var initialPanel = window.location.hash ? 'tab-' + window.location.hash.substring(1) : 'tab-about';
    activateTab(document.getElementById(initialPanel) ? initialPanel : 'tab-about', false);

    document.querySelectorAll('[data-dialog-target]').forEach(function (button) {
        button.addEventListener('click', function () {
            var dialog = document.getElementById(button.getAttribute('data-dialog-target'));
            if (dialog && typeof dialog.showModal === 'function') dialog.showModal();
        });
    });

    document.querySelectorAll('[data-dialog-close]').forEach(function (button) {
        button.addEventListener('click', function () {
            var dialog = button.closest('dialog');
            if (dialog) dialog.close();
        });
    });

    document.querySelectorAll('dialog').forEach(function (dialog) {
        dialog.addEventListener('click', function (event) {
            if (event.target === dialog) dialog.close();
        });
    });
});
