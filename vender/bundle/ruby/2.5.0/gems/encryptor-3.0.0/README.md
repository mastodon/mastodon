# Encryptor

[![Build Status](https://secure.travis-ci.org/attr-encrypted/encryptor.svg)](https://travis-ci.org/attr-encrypted/encryptor) [![Code Climate](https://codeclimate.com/github/attr-encrypted/encryptor/badges/gpa.svg)](https://codeclimate.com/github/attr-encrypted/encryptor) [![Coverage](https://codeclimate.com/github/attr-encrypted/encryptor/badges/coverage.svg)](https://codeclimate.com/github/attr-encrypted/encryptor) [![Gem Version](https://badge.fury.io/rb/encryptor.svg)](http://badge.fury.io/rb/encryptor) [![security](https://hakiri.io/github/attr-encrypted/encryptor/master.svg)](https://hakiri.io/github/attr-encrypted/encryptor/master)

A simple wrapper for the standard Ruby OpenSSL library

## Upgrading from v2.0.0 to v3.0.0 ##
A bug was discovered in Encryptor 2.0.0 wherein the IV was not being used when using an AES-\*-GCM algorithm. Unfornately fixing this major security issue results in the inability to decrypt records encrypted using an AES-\*-GCM algorithm from Encryptor v2.0.0. While the behavior change is minimal between v2.0.0 and v3.0.0, the change has a significant impact on users that used v2.0.0 and encrypted data using an AES-\*-GCM algorithm, which is the default algorithm for v2.0.0. Consequently, we decided to increment the version with a major bump to help people avoid a confusing situation where some of their data will not decrypt. A new option is available in Encryptor 3.0.0 that allows decryption of data encrypted using an AES-\*-GCM algorithm from Encryptor v2.0.0.

### Installation

```bash
gem install encryptor
```

### Usage

#### Basic

Encryptor uses the AES-256-GCM algorithm by default to encrypt strings securely.

The best example is:

```ruby
cipher = OpenSSL::Cipher.new('aes-256-gcm')
cipher.encrypt # Required before '#random_key' or '#random_iv' can be called. http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-encrypt
secret_key = cipher.random_key # Insures that the key is the correct length respective to the algorithm used.
iv = cipher.random_iv # Insures that the IV is the correct length respective to the algorithm used.
salt = SecureRandom.random_bytes(16)
encrypted_value = Encryptor.encrypt(value: 'some string to encrypt', key: secret_key, iv: iv, salt: salt)
decrypted_value = Encryptor.decrypt(value: encrypted_value, key: secret_key, iv: iv, salt: salt)
```

A slightly easier example is:

```ruby
require 'securerandom'
secret_key = SecureRandom.random_bytes(32) # The length in bytes must be equal to or greater than the algorithm bit length.
iv = SecureRandom.random_bytes(12) # Recomended length for AES-###-GCM algorithm. https://tools.ietf.org/html/rfc5084#section-3.2
encrypted_value = Encryptor.encrypt(value: 'some string to encrypt', key: secret_key, iv: iv)
decrypted_value = Encryptor.decrypt(value: encrypted_value, key: secret_key, iv: iv)
```

**NOTE: It is imperative that you use a unique IV per each string and encryption key combo; a nonce as the IV.**
See [RFC 5084](https://tools.ietf.org/html/rfc5084#section-1.5) for more details.

The value to encrypt or decrypt may also be passed as the first option if you'd prefer.

```ruby
encrypted_value = Encryptor.encrypt('some string to encrypt', key: secret_key, iv: iv)
decrypted_value = Encryptor.decrypt(encrypted_value, key: secret_key, iv: iv)
```

#### Options

**Defaults:**

```ruby
    { algorithm: 'aes-256-gcm',
      auth_data: '',
      insecure_mode: false,
      hmac_iterations: 2000,
      v2_gcm_iv: false }
```

Older versions of Encryptor allowed you to use it in a less secure way. Namely, you were allowed to run Encryptor without an IV, or with a key of insufficient length. Encryptor now requires a key and IV of the correct length respective to the algorithm that you use. However, to maintain backwards compatibility you can run Encryptor with the `:insecure_mode` option. Additionally, when using AES-\*-GCM algorithms in Encryptor v2.0.0, the IV was set incorrectly and was not used. The `:v2_gcm_iv` option is available to allow Encryptor to set the IV as it was set in Encryptor v2.0.0. This is provided to assist with migrating data that unsafely encrypted using an AES-\*-GCM algorithm from Encryptor v2.0.0.

You may also pass an `:algorithm`,`:salt`, and `hmac_iterations` option, however none of these options are required. If you pass the `:salt` option, a new unique key will be derived from the key that you passed in using PKCS5 with a default of 2000 iterations. You can change the number of PKCS5 iterations with the `hmac_iterations` option. As PKCS5 is slow, it is optional behavior, but it does provide more security to use a unique IV and key for every encryption operation.

```ruby
Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: 'some default secret key', iv: iv, salt: salt)
```

#### Strings

Older versions of Encryptor added `encrypt` and `decrypt` methods to `String` objects for your convenience. However, this behavior has been removed to avoid polluting Ruby's core `String` class. The `Encryptor::String` module remains within this gem to allow users of this feature to implement it themselves. These `encrypt` and `decrypt` methods accept the same arguments as the associated ones in the `Encryptor` module. They're nice when you set the default options in the `Encryptor.default_options attribute.` For example:

```ruby
require 'encryptor/string'
String.include Encryptor::String
Encryptor.default_options.merge!(key: 'some default secret key', iv: iv)
credit_card = 'xxxx xxxx xxxx 1234'
encrypted_credit_card = credit_card.encrypt
```

There's also `encrypt!` and `decrypt!` methods that replace the contents of a string with the encrypted or decrypted version of itself.

#### Algorithms

To view a list of all cipher algorithms that are supported on your platform, run the following code in your favorite Ruby REPL:

```ruby
require 'openssl'
puts OpenSSL::Cipher.ciphers
```

The supported ciphers will vary depending on the version of OpenSSL that was used to compile your version of Ruby. However, the following ciphers are typically supported:

Cipher Name|Key size in bytes|IV size in bytes
---|---|---
aes-128-cbc|16|16
aes-128-cbc-hmac-sha1|16|16
aes-128-cbc-hmac-sha256|16|16
aes-128-ccm|16|12
aes-128-cfb|16|16
aes-128-cfb1|16|16
aes-128-cfb8|16|16
aes-128-ctr|16|16
aes-128-ecb|16|0
aes-128-gcm|16|12
aes-128-ofb|16|16
aes-128-xts|32|16
aes-192-cbc|24|16
aes-192-ccm|24|12
aes-192-cfb|24|16
aes-192-cfb1|24|16
aes-192-cfb8|24|16
aes-192-ctr|24|16
aes-192-ecb|24|0
aes-192-gcm|24|12
aes-192-ofb|24|16
aes-256-cbc|32|16
aes-256-cbc-hmac-sha1|32|16
aes-256-cbc-hmac-sha256|32|16
aes-256-ccm|32|12
aes-256-cfb|32|16
aes-256-cfb1|32|16
aes-256-cfb8|32|16
aes-256-ctr|32|16
aes-256-ecb|32|0
aes-256-gcm|32|12
aes-256-ofb|32|16
aes-256-xts|64|16
aes128|16|16
aes192|24|16
aes256|32|16
bf|16|8
bf-cbc|16|8
bf-cfb|16|8
bf-ecb|16|0
bf-ofb|16|8
blowfish|16|8
camellia-128-cbc|16|16
camellia-128-cfb|16|16
camellia-128-cfb1|16|16
camellia-128-cfb8|16|16
camellia-128-ecb|16|0
camellia-128-ofb|16|16
camellia-192-cbc|24|16
camellia-192-cfb|24|16
camellia-192-cfb1|24|16
camellia-192-cfb8|24|16
camellia-192-ecb|24|0
camellia-192-ofb|24|16
camellia-256-cbc|32|16
camellia-256-cfb|32|16
camellia-256-cfb1|32|16
camellia-256-cfb8|32|16
camellia-256-ecb|32|0
camellia-256-ofb|32|16
camellia128|16|16
camellia192|24|16
camellia256|32|16
cast|16|8
cast-cbc|16|8
cast5-cbc|16|8
cast5-cfb|16|8
cast5-ecb|16|0
cast5-ofb|16|8
des|8|8
des-cbc|8|8
des-cfb|8|8
des-cfb1|8|8
des-cfb8|8|8
des-ecb|8|0
des-ede|16|0
des-ede-cbc|16|8
des-ede-cfb|16|8
des-ede-ofb|16|8
des-ede3|24|0
des-ede3-cbc|24|8
des-ede3-cfb|24|8
des-ede3-cfb1|24|8
des-ede3-cfb8|24|8
des-ede3-ofb|24|8
des-ofb|8|8
des3|24|8
desx|24|8
desx-cbc|24|8
idea|16|8
idea-cbc|16|8
idea-cfb|16|8
idea-ecb|16|0
idea-ofb|16|8
rc2|16|8
rc2-40-cbc|5|8
rc2-64-cbc|8|8
rc2-cbc|16|8
rc2-cfb|16|8
rc2-ecb|16|0
rc2-ofb|16|8
rc4|16|0
rc4-40|5|0
rc4-hmac-md5|16|0
seed|16|16
seed-cbc|16|16
seed-cfb|16|16
seed-ecb|16|0
seed-ofb|16|16

**NOTE: Some ciphers may not be supported by Ruby. Additionally, Ruby compiled with OpenSSL >= v1.0.1 will include AEAD ciphers, ie., aes-256-gcm.**

#### Notes on patches/pull requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it: this is important so I don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile, version, or history: if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull).
* Send me a pull request: bonus points for topic branches.

