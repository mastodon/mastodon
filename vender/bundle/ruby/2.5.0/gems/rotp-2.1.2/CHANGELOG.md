### Changelog

#### 2.1.2

- Remove string literals to prepare immutable strings in Ruby 3.0

#### 2.1.1

- Reorder the params for Windows Phone Authenticator - #43

#### 2.1.0

- Add a CLI for generating OTP's mdp/rotp/pull/35

#### 2.0.0

- Move to only comparing string OTP's.

#### 1.7.0

- Move to only comparing string OTP's. See mdp/rotp/issues/32 - Moved to 2.0.0 - yanked from RubyGems

#### 1.6.1

- Remove deprecation warning in Ruby 2.1.0 (@ylansegal)
- Add Ruby 2.0 and 2.1 to Travis

#### 1.6.0

- Add verify_with_retries to HOTP
- Fix 'cgi' require and global DEFAULT_INTERVAL

#### 1.5.0

- Add support for "issuer" parameter on provisioning url
- Add support for "period/interval" parameter on provisioning url

#### 1.4.6

- Revert to previous Base32

#### 1.4.5

- Fix and test correct implementation of Base32

#### 1.4.4

- Fix issue with base32 decoding of strings in a length that's not a multiple of 8

#### 1.4.3

- Bugfix on padding

#### 1.4.2

- Better padding options (Pad the output with leading 0's)

#### 1.4.1

- Clean up drift logic

#### 1.4.0

- Added clock drift support via 'verify_with_drift' for TOTP

####1.3.0

- Added support for Ruby 1.9.x
- Removed dependency on Base32
