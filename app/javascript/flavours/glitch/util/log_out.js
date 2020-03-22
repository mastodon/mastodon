import Rails from '@rails/ujs';
import { signOutLink } from 'flavours/glitch/util/backend_links';

export const logOut = () => {
  const form = document.createElement('form');

  const methodInput = document.createElement('input');
  methodInput.setAttribute('name', '_method');
  methodInput.setAttribute('value', 'delete');
  methodInput.setAttribute('type', 'hidden');
  form.appendChild(methodInput);

  const csrfToken = Rails.csrfToken();
  const csrfParam = Rails.csrfParam();

  if (csrfParam && csrfToken) {
    const csrfInput = document.createElement('input');
    csrfInput.setAttribute('name', csrfParam);
    csrfInput.setAttribute('value', csrfToken);
    csrfInput.setAttribute('type', 'hidden');
    form.appendChild(csrfInput);
  }

  const submitButton = document.createElement('input');
  submitButton.setAttribute('type', 'submit');
  form.appendChild(submitButton);

  form.method = 'post';
  form.action = signOutLink;
  form.style.display = 'none';

  document.body.appendChild(form);
  submitButton.click();
};
