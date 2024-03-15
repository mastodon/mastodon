export const logOut = () => {
  const form = document.createElement('form');

  const methodInput = document.createElement('input');
  methodInput.setAttribute('name', '_method');
  methodInput.setAttribute('value', 'delete');
  methodInput.setAttribute('type', 'hidden');
  form.appendChild(methodInput);

  const csrfToken = document.querySelector<HTMLMetaElement>(
    'meta[name=csrf-token]',
  );

  const csrfParam = document.querySelector<HTMLMetaElement>(
    'meta[name=csrf-param]',
  );

  if (csrfParam && csrfToken) {
    const csrfInput = document.createElement('input');
    csrfInput.setAttribute('name', csrfParam.content);
    csrfInput.setAttribute('value', csrfToken.content);
    csrfInput.setAttribute('type', 'hidden');
    form.appendChild(csrfInput);
  }

  const submitButton = document.createElement('input');
  submitButton.setAttribute('type', 'submit');
  form.appendChild(submitButton);

  form.method = 'post';
  form.action = '/auth/sign_out';
  form.style.display = 'none';

  document.body.appendChild(form);
  submitButton.click();
};
