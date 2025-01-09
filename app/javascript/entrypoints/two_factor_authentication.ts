import * as WebAuthnJSON from '@github/webauthn-json';
import axios, { AxiosError } from 'axios';

import ready from '../mastodon/ready';

import 'regenerator-runtime/runtime';

type PublicKeyCredentialCreationOptionsJSON =
  WebAuthnJSON.CredentialCreationOptionsJSON['publicKey'];

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
        credential: WebAuthnJSON.PublicKeyCredentialWithAttestationJSON;
        nickname: string;
      }
    | {
        user: { credential: WebAuthnJSON.PublicKeyCredentialWithAssertionJSON };
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
      const credential = await WebAuthnJSON.create({
        publicKey: credentialOptions,
      });

      const params = {
        credential: credential,
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
    const response = await axios.get<PublicKeyCredentialCreationOptionsJSON>(
      'sessions/security_key_options',
    );

    const credentialOptions = response.data;

    try {
      const credential = await WebAuthnJSON.get({
        publicKey: credentialOptions,
      });

      const params = { user: { credential: credential } };
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
  if (!WebAuthnJSON.supported()) {
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
