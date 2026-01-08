import { on } from 'delegated-events';

export function setupLinkListeners() {
  on('click', 'a[data-confirm]', handleConfirmLink);

  // We don't want to target links with data-confirm here, as those are handled already.
  on('click', 'a[data-method]:not([data-confirm])', handleMethodLink);

  // We also want to target buttons with data-confirm that are not inside forms.
  on('click', ':not(form) button[data-confirm]:not([form])', handleConfirmLink);
}

function handleConfirmLink(event: MouseEvent) {
  const target = event.currentTarget;
  if (
    !(target instanceof HTMLAnchorElement) &&
    !(target instanceof HTMLButtonElement)
  ) {
    return;
  }
  const message = target.dataset.confirm;
  if (!message || !window.confirm(message)) {
    event.preventDefault();
    return;
  }

  if (target.dataset.method) {
    handleMethodLink(event);
  }
}

function handleMethodLink(event: MouseEvent) {
  const anchor = event.currentTarget;
  if (!(anchor instanceof HTMLAnchorElement)) {
    return;
  }

  const method = anchor.dataset.method?.toLowerCase();
  if (!method) {
    return;
  }
  event.preventDefault();

  // Create and submit a form with the specified method.
  const form = document.createElement('form');
  form.method = 'post';
  form.action = anchor.href;

  // Add the hidden _method input to simulate other HTTP methods.
  const methodInput = document.createElement('input');
  methodInput.type = 'hidden';
  methodInput.name = '_method';
  methodInput.value = method;
  form.appendChild(methodInput);

  // Add CSRF token if available for same-origin requests.
  const csrf = getCSRFToken();
  if (csrf && !isCrossDomain(anchor.href)) {
    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = csrf.param;
    csrfInput.value = csrf.token;
    form.appendChild(csrfInput);
  }

  // The form needs to be in the document to be submitted.
  form.style.display = 'none';
  document.body.appendChild(form);

  // We use requestSubmit to ensure any form submit handlers are properly invoked.
  form.requestSubmit();
}

function getCSRFToken() {
  const param = document.querySelector<HTMLMetaElement>(
    'meta[name="csrf-param"]',
  );
  const token = document.querySelector<HTMLMetaElement>(
    'meta[name="csrf-token"]',
  );
  if (param && token) {
    return { param: param.content, token: token.content };
  }
  return null;
}

function isCrossDomain(href: string) {
  const link = document.createElement('a');
  link.href = href;
  return (
    link.protocol !== window.location.protocol ||
    link.host !== window.location.host
  );
}
