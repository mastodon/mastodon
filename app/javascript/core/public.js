//  This file will be loaded on public pages, regardless of theme.

import createHistory from 'history/createBrowserHistory';
import ready from '../mastodon/ready';

const { delegate } = require('rails-ujs');
const { length } = require('stringz');

delegate(document, '.webapp-btn', 'click', ({ target, button }) => {
  if (button !== 0) {
    return true;
  }
  window.location.href = target.href;
  return false;
});

delegate(document, '.status__content__spoiler-link', 'click', function() {
  const contentEl = this.parentNode.parentNode.querySelector('.e-content');

  if (contentEl.style.display === 'block') {
    contentEl.style.display = 'none';
    this.parentNode.style.marginBottom = 0;
  } else {
    contentEl.style.display = 'block';
    this.parentNode.style.marginBottom = null;
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

const getProfileAvatarAnimationHandler = (swapTo) => {
  //animate avatar gifs on the profile page when moused over
  return ({ target }) => {
    const swapSrc = target.getAttribute(swapTo);
    //only change the img source if autoplay is off and the image src is actually different
    if(target.getAttribute('data-autoplay') !== 'true' && target.src !== swapSrc) {
      target.src = swapSrc;
    }
  };
};

delegate(document, 'img#profile_page_avatar', 'mouseover', getProfileAvatarAnimationHandler('data-original'));

delegate(document, 'img#profile_page_avatar', 'mouseout', getProfileAvatarAnimationHandler('data-static'));

delegate(document, '#account_header', 'change', ({ target }) => {
  const header = document.querySelector('.card .card__img img');
  const [file] = target.files || [];
  const url = file ? URL.createObjectURL(file) : header.dataset.originalSrc;

  header.src = url;
});
