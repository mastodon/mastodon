import 'packs/public-path';
import axios from 'axios';
import * as WebAuthnJSON from '@github/webauthn-json';
import ready from '../mastodon/ready';
import 'regenerator-runtime/runtime';

function getCSRFToken() {
  var CSRFSelector = document.querySelector('meta[name="csrf-token"]');
  if (CSRFSelector) {
    return CSRFSelector.getAttribute('content');
  } else {
    return null;
  }
}

function hideFlashMessages() {
  Array.from(document.getElementsByClassName('flash-message')).forEach(function(flashMessage) {
    flashMessage.classList.add('hidden');
  });
}

function callback(url, body) {
  axios.post(url, JSON.stringify(body), {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-CSRF-Token': getCSRFToken(),
    },
    credentials: 'same-origin',
  }).then(function(response) {
    window.location.replace(response.data.redirect_path);
  }).catch(function(error) {
    if (error.response.status === 422) {
      const errorMessage = document.getElementById('security-key-error-message');
      errorMessage.classList.remove('hidden');
      console.error(error.response.data.error);
    } else {
      console.error(error);
    }
  });
}

ready(() => {
  if (!WebAuthnJSON.supported()) {
    const unsupported_browser_message = document.getElementById('unsupported-browser-message');
    if (unsupported_browser_message) {
      unsupported_browser_message.classList.remove('hidden');
      document.querySelector('.btn.js-webauthn').disabled = true;
    }
  }


  const webAuthnCredentialRegistrationForm = document.getElementById('new_webauthn_credential');
  if (webAuthnCredentialRegistrationForm) {
    webAuthnCredentialRegistrationForm.addEventListener('submit', (event) => {
      event.preventDefault();

      var nickname = event.target.querySelector('input[name="new_webauthn_credential[nickname]"]');
      if (nickname.value) {
        axios.get('/settings/security_keys/options')
          .then((response) => {
            const credentialOptions = response.data;

            WebAuthnJSON.create({ 'publicKey': credentialOptions }).then((credential) => {
              var params = { 'credential': credential, 'nickname': nickname.value };
              callback('/settings/security_keys', params);
            }).catch((error) => {
              const errorMessage = document.getElementById('security-key-error-message');
              errorMessage.classList.remove('hidden');
              console.error(error);
            });
          }).catch((error) => {
            console.error(error.response.data.error);
          });
      } else {
        nickname.focus();
      }
    });
  }

  const webAuthnCredentialAuthenticationForm = document.getElementById('webauthn-form');
  if (webAuthnCredentialAuthenticationForm) {
    webAuthnCredentialAuthenticationForm.addEventListener('submit', (event) => {
      event.preventDefault();

      axios.get('sessions/security_key_options')
        .then((response) => {
          const credentialOptions = response.data;

          WebAuthnJSON.get({ 'publicKey': credentialOptions }).then((credential) => {
            var params = { 'user': { 'credential': credential } };
            callback('sign_in', params);
          }).catch((error) => {
            const errorMessage = document.getElementById('security-key-error-message');
            errorMessage.classList.remove('hidden');
            console.error(error);
          });
        }).catch((error) => {
          console.error(error.response.data.error);
        });
    });

    const otpAuthenticationForm = document.getElementById('otp-authentication-form');

    const linkToOtp = document.getElementById('link-to-otp');
    linkToOtp.addEventListener('click', () => {
      webAuthnCredentialAuthenticationForm.classList.add('hidden');
      otpAuthenticationForm.classList.remove('hidden');
      hideFlashMessages();
    });

    const linkToWebAuthn = document.getElementById('link-to-webauthn');
    linkToWebAuthn.addEventListener('click', () => {
      otpAuthenticationForm.classList.add('hidden');
      webAuthnCredentialAuthenticationForm.classList.remove('hidden');
      hideFlashMessages();
    });
  }
});
