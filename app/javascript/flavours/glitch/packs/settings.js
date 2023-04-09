import 'packs/public-path';
import loadPolyfills from 'flavours/glitch/load_polyfills';
import loadKeyboardExtensions from 'flavours/glitch/load_keyboard_extensions';
import 'cocoon-js-vanilla';

function main() {
  const { delegate } = require('@rails/ujs');

  const toggleSidebar = () => {
    const sidebar = document.querySelector('.sidebar ul');
    const toggleButton = document.querySelector('.sidebar__toggle__icon');

    if (sidebar.classList.contains('visible')) {
      document.body.style.overflow = null;
      toggleButton.setAttribute('aria-expanded', 'false');
    } else {
      document.body.style.overflow = 'hidden';
      toggleButton.setAttribute('aria-expanded', 'true');
    }

    toggleButton.classList.toggle('active');
    sidebar.classList.toggle('visible');
  };

  delegate(document, '.sidebar__toggle__icon', 'click', () => {
    toggleSidebar();
  });

  delegate(document, '.sidebar__toggle__icon', 'keydown', e => {
    if (e.key === ' ' || e.key === 'Enter') {
      e.preventDefault();
      toggleSidebar();
    }
  });
}

loadPolyfills()
  .then(main)
  .then(loadKeyboardExtensions)
  .catch(error => {
    console.error(error);
  });
