//  This file will be loaded on public pages, regardless of theme.

import 'packs/public-path';

const { delegate } = require('@rails/ujs');

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
