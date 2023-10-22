import { Controller } from "@hotwired/stimulus";
import { supported as WebAuthnSupported } from "@github/webauthn-json/browser-ponyfill";

export default class extends Controller {
  static targets = ["message", "messageArea", "formArea"];

  connect() {
    console.log("feature detection connect");
    if (!WebAuthnSupported()) {
      this.messageTarget.innerHTML = "This browser doesn't support WebAuthn API";
    } else {
      PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().then((available) => {
        if (!available) {
          this.messageTarget.innerHTML = "We couldn't detect a user-verifying platform authenticator";
        } else {
          console.log("we are happy", this.messageAreaTarget, this.formAreaTarget);
          this.messageAreaTarget.classList.add("hidden");
          this.formAreaTarget.classList.remove("hidden");
        }
      })
    }
  }

  msg(event) {
    console.log("in feature-detection#msg", event);
    this.messageTarget.innerHTML = event.detail.message;
    this.messageAreaTarget.classList.remove("hidden");
    this.formAreaTarget.classList.add("hidden");
  }
}

