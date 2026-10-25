import axios, { AxiosError } from 'axios';

import ready from '../mastodon/ready';

function isWebAuthnSupported() {
  return (
    typeof window.PublicKeyCredential !== 'undefined' &&
    typeof PublicKeyCredential.parseCreationOptionsFromJSON === 'function' &&
    typeof PublicKeyCredential.parseRequestOptionsFromJSON === 'function' &&
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

async function callback(
  url: string,
  body:
    | {
        credential: RegistrationResponseJSON;
        nickname: string;
      }
    | {
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
      const errorMessage = document.getElementById(
        'security-key-error-message',
      );
      errorMessage?.classList.remove('hidden');

      logAxiosResponseError(error);
    } else {
      console.error(error);
    }
  }
}

async function handleWebauthnCredentialRegistration(nickname: string) {
  try {
    const response = await axios.get<PublicKeyCredentialCreationOptionsJSON>(
      '/settings/security_keys/options',
    );

    const credentialOptions = response.data;

    try {
      const options =
        PublicKeyCredential.parseCreationOptionsFromJSON(credentialOptions);
      const credential = await navigator.credentials.create({
        publicKey: options,
      });

      if (!(credential instanceof PublicKeyCredential)) {
        throw new Error('Failed to create public key credential');
      }

      const params = {
        credential: credential.toJSON() as RegistrationResponseJSON,
        nickname: nickname,
      };

      await callback('/settings/security_keys', params);
    } catch (error) {
      const errorMessage = document.getElementById(
        'security-key-error-message',
      );
      errorMessage?.classList.remove('hidden');
      console.error(error);
    }
  } catch (error) {
    logAxiosResponseError(error);
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
      void callback('sign_in', params);
    } catch (error) {
      const errorMessage = document.getElementById(
        'security-key-error-message',
      );
      errorMessage?.classList.remove('hidden');
      console.error(error);
    }
  } catch (error) {
    logAxiosResponseError(error);
  }
}

ready(() => {
  if (!isWebAuthnSupported()) {
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
    webAuthnCredentialRegistrationForm.addEventListener('submit', (event) => {
      event.preventDefault();

      if (!(event.target instanceof HTMLFormElement)) return;

      const nickname = event.target.querySelector<HTMLInputElement>(
        'input[name="new_webauthn_credential[nickname]"]',
      );

      if (nickname?.value) {
        void handleWebauthnCredentialRegistration(nickname.value);
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
