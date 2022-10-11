import 'packs/public-path';
import loadPolyfills from 'flavours/glitch/load_polyfills';
import ready from 'flavours/glitch/ready';
import loadKeyboardExtensions from 'flavours/glitch/load_keyboard_extensions';
import 'cocoon-js-vanilla';

function main() {
  const { delegate } = require('@rails/ujs');

  delegate(document, '.sidebar__toggle__icon', 'click', () => {
    document.querySelector('.sidebar ul').classList.toggle('visible');
  });
}

loadPolyfills()
  .then(main)
  .then(loadKeyboardExtensions)
  .catch(error => {
    console.error(error);
  });
