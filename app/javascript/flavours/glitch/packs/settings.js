import loadPolyfills from 'flavours/glitch/util/load_polyfills';
import ready from 'flavours/glitch/util/ready';

function main() {
  const { delegate } = require('rails-ujs');

  delegate(document, '.sidebar__toggle__icon', 'click', () => {
    const target = document.querySelector('.sidebar ul');

    if (target.style.display === 'block') {
      target.style.display = 'none';
    } else {
      target.style.display = 'block';
    }
  });
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
