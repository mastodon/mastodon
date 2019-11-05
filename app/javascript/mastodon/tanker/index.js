import { fromBase64, toBase64, Tanker } from '@tanker/client-browser';
import { VerificationUI } from '@tanker/verification-ui';

export default class TankerService {

  constructor({ email, tankerIdentity, tankerAppId }) {
    this.email = email;
    this.tankerIdentity = tankerIdentity;
    this.tanker = new Tanker({ appId: tankerAppId });
    this.verificationUI = new VerificationUI(this.tanker);
  }

  encrypt = async (clearText, encryptOptions) => {
    await this.lazyStart();

    const encryptedData = await this.tanker.encrypt(clearText, encryptOptions);
    const encryptedText = toBase64(encryptedData);
    return encryptedText;
  }

  decrypt = async (encryptedText) => {
    await this.lazyStart();

    const encryptedData = fromBase64(encryptedText);
    const clearText = await this.tanker.decrypt(encryptedData);
    return clearText;
  }

  stop = async() => {
    await this.tanker.stop();
  }

  lazyStart = async () => {

    if (this.tanker.status !== Tanker.statuses.STOPPED) {
      return;
    }

    if (!this.startPromise) {
      this.startPromise = this.verificationUI.start(this.email, this.tankerIdentity);
    }

    try {
      await this.startPromise;
      delete this.startPromise;
    } catch(e) {
      delete this.startPromise;
      throw e;
    }

  }

}
