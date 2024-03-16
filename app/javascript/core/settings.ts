//  This file will be loaded on settings pages, regardless of theme.

import 'packs/public-path';
import Rails from '@rails/ujs';

Rails.delegate(
  document,
  '#edit_profile input[type=file]',
  'change',
  ({ target }) => {
    if (!(target instanceof HTMLInputElement)) return;

    const avatar = document.querySelector<HTMLImageElement>(
      `img#${target.id}-preview`,
    );

    if (!avatar) return;

    let file: File | undefined;
    if (target.files) file = target.files[0];

    const url = file ? URL.createObjectURL(file) : avatar.dataset.originalSrc;

    if (url) avatar.src = url;
  },
);

Rails.delegate(document, '.input-copy input', 'click', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  target.focus();
  target.select();
  target.setSelectionRange(0, target.value.length);
});

Rails.delegate(document, '.input-copy button', 'click', ({ target }) => {
  if (!(target instanceof HTMLButtonElement)) return;

  const input = target.parentNode?.querySelector<HTMLInputElement>(
    '.input-copy__wrapper input',
  );

  if (!input) return;

  const oldReadOnly = input.readOnly;

  input.readOnly = false;
  input.focus();
  input.select();
  input.setSelectionRange(0, input.value.length);

  try {
    if (document.execCommand('copy')) {
      input.blur();

      const parent = target.parentElement;

      if (!parent) return;
      parent.classList.add('copied');

      setTimeout(() => {
        parent.classList.remove('copied');
      }, 700);
    }
  } catch (err) {
    console.error(err);
  }

  input.readOnly = oldReadOnly;
});
