//  This file will be loaded on public pages, regardless of theme.

import createHistory from 'history/createBrowserHistory';
import ready from '../mastodon/ready';

const { delegate } = require('rails-ujs');
const { length } = require('stringz');

ready(() => {
  const history = createHistory();
  const detailedStatuses = document.querySelectorAll('.public-layout .detailed-status');
  const location = history.location;
  if (detailedStatuses.length == 1 && (!location.state || !location.state.scrolledToDetailedStatus)) {
    detailedStatuses[0].scrollIntoView();
    history.replace(location.pathname, {...location.state, scrolledToDetailedStatus: true});
  }
});

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

delegate(document, '.modal-button', 'click', e => {
  e.preventDefault();

  let href;

  if (e.target.nodeName !== 'A') {
    href = e.target.parentNode.href;
  } else {
    href = e.target.href;
  }

  window.open(href, 'mastodon-intent', 'width=445,height=600,resizable=no,menubar=no,status=no,scrollbars=yes');
});
