# Pin npm packages by running ./bin/importmap

pin "application", to: "https://ga.jspm.io/npm:application@0.1.4/index.js"
pin "registration_form", preload: true
pin "conditional_mediation_available", preload: true
pin "session_form", preload: true
pin "passkey_reauthentication_handler", preload: true
pin "@github/webauthn-json/browser-ponyfill", to: "https://ga.jspm.io/npm:@github/webauthn-json@2.1.0/dist/esm/webauthn-json.browser-ponyfill.js"


