//  This file will be loaded on public pages, regardless of theme.

const { delegate } = require('rails-ujs');

delegate(document, '.webapp-btn', 'click', ({ target, button }) => {
  if (button !== 0) {
    return true;
  }
  window.location.href = target.href;
  return false;
});

delegate(document, '.status__content__spoiler-link', 'click', ({ target }) => {
  const contentEl = target.parentNode.parentNode.querySelector('.e-content');

  if (contentEl.style.display === 'block') {
    contentEl.style.display = 'none';
    target.parentNode.style.marginBottom = 0;
  } else {
    contentEl.style.display = 'block';
    target.parentNode.style.marginBottom = null;
  }

  return false;
});
