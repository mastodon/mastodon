//  This file will be loaded on settings pages, regardless of theme.

import 'packs/public-path';
import escapeTextContentForBrowser from 'escape-html';

import { delegate } from '@rails/ujs';

import emojify from '../mastodon/features/emoji/emoji';

delegate(document, '#account_display_name', 'input', ({ target }) => {
  const name = document.querySelector('.card .display-name strong');
  if (name) {
    if (target.value) {
      name.innerHTML = emojify(escapeTextContentForBrowser(target.value));
    } else {
      name.textContent = name.textContent = target.dataset.default;
    }
  }
});

delegate(document, '#account_avatar', 'change', ({ target }) => {
  const avatar = document.querySelector('.card .avatar img');
  const [file] = target.files || [];
  const url = file ? URL.createObjectURL(file) : avatar.dataset.originalSrc;

  avatar.src = url;
});

delegate(document, '#account_header', 'change', ({ target }) => {
  const header = document.querySelector('.card .card__img img');
  const [file] = target.files || [];
  const url = file ? URL.createObjectURL(file) : header.dataset.originalSrc;

  header.src = url;
});

delegate(document, '#account_locked', 'change', ({ target }) => {
  const lock = document.querySelector('.card .display-name i');

  if (lock) {
    if (target.checked) {
      delete lock.dataset.hidden;
    } else {
      lock.dataset.hidden = 'true';
    }
  }
});

delegate(document, '.input-copy input', 'click', ({ target }) => {
  target.focus();
  target.select();
  target.setSelectionRange(0, target.value.length);
});

delegate(document, '.input-copy button', 'click', ({ target }) => {
  const input = target.parentNode.querySelector('.input-copy__wrapper input');

  const oldReadOnly = input.readonly;

  input.readonly = false;
  input.focus();
  input.select();
  input.setSelectionRange(0, input.value.length);

  try {
    if (document.execCommand('copy')) {
      input.blur();
      target.parentNode.classList.add('copied');

      setTimeout(() => {
        target.parentNode.classList.remove('copied');
      }, 700);
    }
  } catch (err) {
    console.error(err);
  }

  input.readonly = oldReadOnly;
});
