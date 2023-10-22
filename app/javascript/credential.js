import * as WebAuthnJSON from "@github/webauthn-json/browser-ponyfill"

function getCSRFToken() {
  var CSRFSelector = document.querySelector('meta[name="csrf-token"]')
  if (CSRFSelector) {
    return CSRFSelector.getAttribute("content")
  } else {
    return null
  }
}

function displayError(message) {
  const ele = document.querySelector('#message-box');
  const event = new CustomEvent('msg', { detail: { message: message}});
  ele.dispatchEvent(event);
  console.log("credential: event sent");
}

function callback(original_url, callback_url, body) {
  console.log("credential: in callback", original_url, callback_url, body);
  fetch(encodeURI(callback_url), {
    method: "POST",
    body: JSON.stringify(body),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": getCSRFToken()
    },
    credentials: 'same-origin'
  }).then(function(response) {
    if (response.ok) {
      window.location.replace(encodeURI(original_url))
    } else if (response.status < 500) {
      console.log("credential: response not ok");
      response.text().then((text) => { displayError(text) });
    } else {
      console.log(response);
    }
  });
}

function create(data) {
  const { original_url, callback_url, create_options } = data
  const options = WebAuthnJSON.parseCreationOptionsFromJSON({ "publicKey": create_options })
  WebAuthnJSON.create(options).then((credentials) => {
    callback(original_url, callback_url, credentials);
  }).catch(function(error) {
    console.log("credential: create error", error);
  });

  console.log("credential: Creating new public key credential...");
}

function get(data) {
  const { original_url, callback_url, get_options } = data
  const options = WebAuthnJSON.parseRequestOptionsFromJSON({ "publicKey": get_options })
  WebAuthnJSON.get(options).then((credentials) => {
    callback(original_url, callback_url, credentials);
  }).catch(function(error) {
    console.log("credential: get error", error);
  });

  console.log("credential: Getting public key credential...");
}

export { create, get, displayError }

