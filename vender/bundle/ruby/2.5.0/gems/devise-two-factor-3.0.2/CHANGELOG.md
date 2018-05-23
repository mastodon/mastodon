# CHANGELOG

## Unreleased

## 3.0.2
- Add Rails 5.1 support

## 3.0.1
- Qualify call to rspec shared_examples

## 3.0.0
See `UPGRADING.md` for specific help with breaking changes from 2.x to 3.0.0.

- Adds support for Devise 4.
- Relax dependencies to allow attr_encrypted 3.x.
- Blocks the use of attr_encrypted 2.x. There was a significant vulnerability in the encryption implementation in attr_encrypted 2.x, and that version of the gem should not be used.

## 2.2.0
- Use 192 bits, not 1024, as a secret key length. RFC 4226 recommends a minimum length of 128 bits and a recommended length of 160 bits. Google Authenticator doesn't accept 160 bit keys.

## 2.1.0
- Return false if OTP value is nil, instead of an ROTP exception.

## 2.0.1
No user-facing changes.

## 2.0.0
See `UPGRADING.md` for specific help with breaking changes from 1.x to 2.0.0.

- Replace `valid_otp?` method with `validate_and_consume_otp!`.
- Disallow subsequent OTPs once validated via timesteps.

## 1.1.0
- Removes runtimez activemodel dependency.
- Uses `Devise::Encryptor` instead of `Devise.bcrypt`, which is deprecated.
- Bump `rotp` dependency to 2.x.

## 1.0.2
- Makes Railties the only requirement for Rails generators.
- Explicitly check that the `otp_attempt` param is not nil in order to avoid 'ROTP only verifies strings' exceptions.
- Adding warning about recoverable devise strategy and automatic `sign_in` after a password reset.
- Loosen dependency version requirements for rotp, devise, and attr_encrypted.

## 1.0.1
- Add version requirements for dependencies.

## 1.0.0
- Initial release.
