//  This file will be loaded on settings pages, regardless of theme.

const { length } = require('stringz');
const { delegate } = require('rails-ujs');

import { processBio } from 'flavours/glitch/util/bio_metadata';

delegate(document, '.account_display_name', 'input', ({ target }) => {
  const nameCounter = document.querySelector('.name-counter');

  if (nameCounter) {
    nameCounter.textContent = 30 - length(target.value);
  }
});

delegate(document, '.account_note', 'input', ({ target }) => {
  const noteCounter = document.querySelector('.note-counter');

  if (noteCounter) {
    const noteWithoutMetadata = processBio(target.value).text;
    noteCounter.textContent = 500 - length(noteWithoutMetadata);
  }
});

delegate(document, '#account_avatar', 'change', ({ target }) => {
  const avatar = document.querySelector('.card.compact .avatar img');
  const [file] = target.files || [];
  const url = file ? URL.createObjectURL(file) : avatar.dataset.originalSrc;

  avatar.src = url;
});

delegate(document, '#account_header', 'change', ({ target }) => {
  const header = document.querySelector('.card.compact');
  const [file] = target.files || [];
  const url = file ? URL.createObjectURL(file) : header.dataset.originalSrc;

  header.style.backgroundImage = `url(${url})`;
});
