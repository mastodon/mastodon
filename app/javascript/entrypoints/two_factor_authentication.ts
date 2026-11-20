import axios, { AxiosError } from 'axios';

import ready from '../mastodon/ready';

function isWebAuthnSupported() {
  return (
    typeof window.PublicKeyCredential !== 'undefined' &&
    typeof PublicKeyCredential.parseCreationOptionsFromJSON === 'function' &&
    typeof PublicKeyCredential.parseRequestOptionsFromJSON === 'function' &&
    typeof PublicKeyCredential.prototype.toJSON === 'function' &&
    typeof navigator.credentials.create === 'function' &&
    typeof navigator.credentials.get === 'function'
  );
}

function exceptionHasAxiosError(
  error: unknown,
): error is AxiosError<{ error: unknown }> {
  return (
    error instanceof AxiosError &&
    typeof error.response?.data === 'object' &&
    'error' in error.response.data
  );
}

function logAxiosResponseError(error: unknown) {
  if (exceptionHasAxiosError(error)) console.error(error);
}

function getCSRFToken() {
  return document
    .querySelector<HTMLMetaElement>('meta[name="csrf-token"]')
    ?.getAttribute('content');
}

function hideFlashMessages() {
  document.querySelectorAll('.flash-message').forEach((flashMessage) => {
    flashMessage.classList.add('hidden');
  });
}

function showSecurityKeyError() {
  document
    .getElementById('security-key-error-message')
    ?.classList.remove('hidden');
}

async function submitWebauthnAuthentication(
  url: string,
  body: {
    user: { credential: AuthenticationResponseJSON };
  },
) {
  try {
    const response = await axios.post<{ redirect_path: string }>(
      url,
      JSON.stringify(body),
      {
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'X-CSRF-Token': getCSRFToken(),
        },
      },
    );

    window.location.replace(response.data.redirect_path);
  } catch (error) {
    if (error instanceof AxiosError && error.response?.status === 422) {
      showSecurityKeyError();

      logAxiosResponseError(error);
    } else {
      console.error(error);
    }
  }
}

async function fetchWebauthnCredentialCreationOptions() {
  try {
    const response = await axios.get<PublicKeyCredentialCreationOptionsJSON>(
      '/settings/security_keys/options',
    );

    return response.data;
  } catch (error) {
    logAxiosResponseError(error);
    return undefined;
  }
}

async function handleWebauthnCredentialRegistration(
  form: HTMLFormElement,
  credentialOptions: PublicKeyCredentialCreationOptionsJSON,
) {
  try {
    const options =
      PublicKeyCredential.parseCreationOptionsFromJSON(credentialOptions);
    const credential = await navigator.credentials.create({
      publicKey: options,
    });

    if (!(credential instanceof PublicKeyCredential)) {
      throw new Error('Failed to create public key credential');
    }

    const credentialInput = form.querySelector<HTMLInputElement>(
      'input[name="credential"]',
    );
    if (!credentialInput) return;

    credentialInput.value = JSON.stringify(credential.toJSON());
    form.submit();
  } catch (error) {
    showSecurityKeyError();
    console.error(error);
  }
}

async function handleWebauthnCredentialAuthentication() {
  try {
    const response = await axios.get<PublicKeyCredentialRequestOptionsJSON>(
      'sessions/security_key_options',
    );

    const credentialOptions = response.data;

    try {
      const options =
        PublicKeyCredential.parseRequestOptionsFromJSON(credentialOptions);
      const credential = await navigator.credentials.get({
        publicKey: options,
      });

      if (!(credential instanceof PublicKeyCredential)) {
        throw new Error('Failed to get public key credential');
      }

      const params = {
        user: { credential: credential.toJSON() as AuthenticationResponseJSON },
      };
      void submitWebauthnAuthentication('sign_in', params);
    } catch (error) {
      showSecurityKeyError();
      console.error(error);
    }
  } catch (error) {
    logAxiosResponseError(error);
  }
}

ready(() => {
  const webAuthnSupported = isWebAuthnSupported();

  if (!webAuthnSupported) {
    const unsupported_browser_message = document.getElementById(
      'unsupported-browser-message',
    );
    if (unsupported_browser_message) {
      unsupported_browser_message.classList.remove('hidden');
      const button = document.querySelector<HTMLButtonElement>(
        'button.btn.js-webauthn',
      );
      if (button) button.disabled = true;
    }
  }

  const webAuthnCredentialRegistrationForm =
    document.querySelector<HTMLFormElement>('form#new_webauthn_credential');
  if (webAuthnCredentialRegistrationForm) {
    const registrationButton =
      webAuthnCredentialRegistrationForm.querySelector<HTMLButtonElement>(
        'button.js-webauthn',
      );
    let credentialOptions: PublicKeyCredentialCreationOptionsJSON | undefined;

    if (webAuthnSupported) {
      void fetchWebauthnCredentialCreationOptions().then((options) => {
        credentialOptions = options;
        if (options && registrationButton) registrationButton.disabled = false;
      });
    }

    webAuthnCredentialRegistrationForm.addEventListener('submit', (event) => {
      event.preventDefault();

      if (!(event.target instanceof HTMLFormElement) || !credentialOptions)
        return;

      const nickname = event.target.querySelector<HTMLInputElement>(
        'input[name="nickname"]',
      );

      if (nickname?.value) {
        void handleWebauthnCredentialRegistration(
          event.target,
          credentialOptions,
        );
      } else {
        nickname?.focus();
      }
    });
  }

  const webAuthnCredentialAuthenticationForm =
    document.getElementById('webauthn-form');
  if (webAuthnCredentialAuthenticationForm) {
    webAuthnCredentialAuthenticationForm.addEventListener('submit', (event) => {
      event.preventDefault();
      void handleWebauthnCredentialAuthentication();
    });

    const otpAuthenticationForm = document.getElementById(
      'otp-authentication-form',
    );

    const linkToOtp = document.getElementById('link-to-otp');

    linkToOtp?.addEventListener('click', () => {
      webAuthnCredentialAuthenticationForm.classList.add('hidden');
      otpAuthenticationForm?.classList.remove('hidden');
      hideFlashMessages();
    });

    const linkToWebAuthn = document.getElementById('link-to-webauthn');
    linkToWebAuthn?.addEventListener('click', () => {
      otpAuthenticationForm?.classList.add('hidden');
      webAuthnCredentialAuthenticationForm.classList.remove('hidden');
      hideFlashMessages();
    });
  }
}).catch((e: unknown) => {
  throw e;
});
