# attr_encrypted
[![Build Status](https://secure.travis-ci.org/attr-encrypted/attr_encrypted.svg)](https://travis-ci.org/attr-encrypted/attr_encrypted) [![Test Coverage](https://codeclimate.com/github/attr-encrypted/attr_encrypted/badges/coverage.svg)](https://codeclimate.com/github/attr-encrypted/attr_encrypted/coverage) [![Code Climate](https://codeclimate.com/github/attr-encrypted/attr_encrypted/badges/gpa.svg)](https://codeclimate.com/github/attr-encrypted/attr_encrypted) [![Gem Version](https://badge.fury.io/rb/attr_encrypted.svg)](https://badge.fury.io/rb/attr_encrypted) [![security](https://hakiri.io/github/attr-encrypted/attr_encrypted/master.svg)](https://hakiri.io/github/attr-encrypted/attr_encrypted/master)

Generates attr_accessors that transparently encrypt and decrypt attributes.

It works with ANY class, however, you get a few extra features when you're using it with `ActiveRecord`, `DataMapper`, or `Sequel`.


## Installation

Add attr_encrypted to your gemfile:

```ruby
  gem "attr_encrypted", "~> 3.0.0"
```

Then install the gem:

```bash
  bundle install
```

## Usage

If you're using an ORM like `ActiveRecord`, `DataMapper`, or `Sequel`, using attr_encrypted is easy:

```ruby
  class User
    attr_encrypted :ssn, key: 'This is a key that is 256 bits!!'
  end
```

If you're using a PORO, you have to do a little bit more work by extending the class:

```ruby
  class User
    extend AttrEncrypted
    attr_accessor :name
    attr_encrypted :ssn, key: 'This is a key that is 256 bits!!'

    def load
      # loads the stored data
    end

    def save
      # saves the :name and :encrypted_ssn attributes somewhere (e.g. filesystem, database, etc)
    end
  end

  user = User.new
  user.ssn = '123-45-6789'
  user.ssn # returns the unencrypted object ie. '123-45-6789'
  user.encrypted_ssn # returns the encrypted version of :ssn
  user.save

  user = User.load
  user.ssn # decrypts :encrypted_ssn and returns '123-45-6789'
```

### Encrypt/decrypt attribute class methods

Two class methods are available for each attribute: `User.encrypt_email` and `User.decrypt_email`. They accept as arguments the same options that the `attr_encrypted` class method accepts. For example:

```ruby
  key = SecureRandom.random_bytes(32)
  iv = SecureRandom.random_bytes(12)
  encrypted_email = User.encrypt_email('test@test.com', iv: iv, key: key)
  email = User.decrypt_email(encrypted_email, iv: iv, key: key)
```

The `attr_encrypted` class method is also aliased as `attr_encryptor` to conform to Ruby's `attr_` naming conventions. I should have called this project `attr_encryptor` but it was too late when I realized it ='(.

### attr_encrypted with database persistence

By default, `attr_encrypted` uses the `:per_attribute_iv` encryption mode. This mode requires a column to store your cipher text and a column to store your IV (initialization vector).

Create or modify the table that your model uses to add a column with the `encrypted_` prefix (which can be modified, see below), e.g. `encrypted_ssn` via a migration like the following:

```ruby
  create_table :users do |t|
    t.string :name
    t.string :encrypted_ssn
    t.string :encrypted_ssn_iv
    t.timestamps
  end
```

You can use a string or binary column type. (See the encode option section below for more info)

### Specifying the encrypted attribute name

By default, the encrypted attribute name is `encrypted_#{attribute}` (e.g. `attr_encrypted :email` would create an attribute named `encrypted_email`). So, if you're storing the encrypted attribute in the database, you need to make sure the `encrypted_#{attribute}` field exists in your table. You have a couple of options if you want to name your attribute or db column something else, see below for more details.


## attr_encrypted options

#### Options are evaluated
All options will be evaluated at the instance level. If you pass in a symbol it will be passed as a message to the instance of your class. If you pass a proc or any object that responds to `:call` it will be called. You can pass in the instance of your class as an argument to the proc. Anything else will be returned. For example:

##### Symbols representing instance methods

Here is an example class that uses an instance method to determines the encryption key to use.

```ruby
  class User
    attr_encrypted :email, key: :encryption_key

    def encryption_key
      # does some fancy logic and returns an encryption key
    end
  end
```


##### Procs

Here is an example of passing a proc/lambda object as the `:key` option as well:

```ruby
  class User
    attr_encrypted :email, key: proc { |user| user.key }
  end
```


### Default options

The following are the default options used by `attr_encrypted`:

```ruby
  prefix:            'encrypted_',
  suffix:            '',
  if:                true,
  unless:            false,
  encode:            false,
  encode_iv:         true,
  encode_salt:       true,
  default_encoding:  'm',
  marshal:           false,
  marshaler:         Marshal,
  dump_method:       'dump',
  load_method:       'load',
  encryptor:         Encryptor,
  encrypt_method:    'encrypt',
  decrypt_method:    'decrypt',
  mode:              :per_attribute_iv,
  algorithm:         'aes-256-gcm',
  allow_empty_value: false
```

All of the aforementioned options are explained in depth below.

Additionally, you can specify default options for all encrypted attributes in your class. Instead of having to define your class like this:

```ruby
  class User
    attr_encrypted :email, key: 'This is a key that is 256 bits!!', prefix: '', suffix: '_crypted'
    attr_encrypted :ssn, key: 'a different secret key', prefix: '', suffix: '_crypted'
    attr_encrypted :credit_card, key: 'another secret key', prefix: '', suffix: '_crypted'
  end
```

You can simply define some default options like so:

```ruby
  class User
    attr_encrypted_options.merge!(prefix: '', :suffix => '_crypted')
    attr_encrypted :email, key: 'This is a key that is 256 bits!!'
    attr_encrypted :ssn, key: 'a different secret key'
    attr_encrypted :credit_card, key: 'another secret key'
  end
```

This should help keep your classes clean and DRY.

### The `:attribute` option

You can simply pass the name of the encrypted attribute as the `:attribute` option:

```ruby
  class User
    attr_encrypted :email, key: 'This is a key that is 256 bits!!', attribute: 'email_encrypted'
  end
```

This would generate an attribute named `email_encrypted`


### The `:prefix` and `:suffix` options

If you don't like the `encrypted_#{attribute}` naming convention then you can specify your own:

```ruby
  class User
    attr_encrypted :email, key: 'This is a key that is 256 bits!!', prefix: 'secret_', suffix: '_crypted'
  end
```

This would generate the following attribute: `secret_email_crypted`.


### The `:key` option

The `:key` option is used to pass in a data encryption key to be used with whatever encryption class you use. If you're using `Encryptor`, the key must meet minimum length requirements respective to the algorithm that you use; aes-256 requires a 256 bit key, etc. The `:key` option is not required (see custom encryptor below).


##### Unique keys for each attribute

You can specify unique keys for each attribute if you'd like:

```ruby
  class User
    attr_encrypted :email, key: 'This is a key that is 256 bits!!'
    attr_encrypted :ssn, key: 'a different secret key'
  end
```

It is recommended to use a symbol or a proc for the key and to store information regarding what key was used to encrypt your data. (See below for more details.)


### The `:if` and `:unless` options

There may be times that you want to only encrypt when certain conditions are met. For example maybe you're using rails and you don't want to encrypt attributes when you're in development mode. You can specify conditions like this:

```ruby
  class User < ActiveRecord::Base
    attr_encrypted :email, key: 'This is a key that is 256 bits!!', unless: Rails.env.development?
    attr_encrypted :ssn, key: 'This is a key that is 256 bits!!', if: Rails.env.development?
  end
```

You can specify both `:if` and `:unless` options.


### The `:encryptor`, `:encrypt_method`, and `:decrypt_method` options

The `Encryptor` class is used by default. You may use your own custom encryptor by specifying the `:encryptor`, `:encrypt_method`, and `:decrypt_method` options.

Lets suppose you'd like to use this custom encryptor class:

```ruby
  class SillyEncryptor
    def self.silly_encrypt(options)
      (options[:value] + options[:secret_key]).reverse
    end

    def self.silly_decrypt(options)
      options[:value].reverse.gsub(/#{options[:secret_key]}$/, '')
    end
  end
```

Simply set up your class like so:

```ruby
  class User
    attr_encrypted :email, secret_key: 'This is a key that is 256 bits!!', encryptor: SillyEncryptor, encrypt_method: :silly_encrypt, decrypt_method: :silly_decrypt
  end
```

Any options that you pass to `attr_encrypted` will be passed to the encryptor class along with the `:value` option which contains the string to encrypt/decrypt. Notice that the above example uses `:secret_key` instead of `:key`. See [encryptor](https://github.com/attr-encrypted/encryptor) for more info regarding the default encryptor class.


### The `:mode` option

The mode options allows you to specify in what mode your data will be encrypted. There are currently three modes: `:per_attribute_iv`, `:per_attribute_iv_and_salt`, and `:single_iv_and_salt`.

__NOTE: `:per_attribute_iv_and_salt` and `:single_iv_and_salt` modes are deprecated and will be removed in the next major release.__


### The `:algorithm` option

The default `Encryptor` class uses the standard ruby OpenSSL library. Its default algorithm is `aes-256-gcm`. You can modify this by passing the `:algorithm` option to the `attr_encrypted` call like so:

```ruby
  class User
    attr_encrypted :email, key: 'This is a key that is 256 bits!!', algorithm: 'aes-256-cbc'
  end
```

To view a list of all cipher algorithms that are supported on your platform, run the following code in your favorite Ruby REPL:

```ruby
  require 'openssl'
  puts OpenSSL::Cipher.ciphers
```
See [Encryptor](https://github.com/attr-encrypted/encryptor#algorithms) for more information.


### The `:encode`, `:encode_iv`, `:encode_salt`, and `:default_encoding` options

You're probably going to be storing your encrypted attributes somehow (e.g. filesystem, database, etc). You can simply pass the `:encode` option to automatically encode/decode when encrypting/decrypting. The default behavior assumes that you're using a string column type and will base64 encode your cipher text. If you choose to use the binary column type then encoding is not required, but be sure to pass in `false` with the `:encode` option.

```ruby
  class User
    attr_encrypted :email, key: 'some secret key', encode: true, encode_iv: true, encode_salt: true
  end
```

The default encoding is `m` (base64). You can change this by setting `encode: 'some encoding'`. See [`Array#pack`](http://ruby-doc.org/core-2.3.0/Array.html#method-i-pack) for more encoding options.


### The `:marshal`, `:dump_method`, and `:load_method` options

You may want to encrypt objects other than strings (e.g. hashes, arrays, etc). If this is the case, simply pass the `:marshal` option to automatically marshal when encrypting/decrypting.

```ruby
  class User
    attr_encrypted :credentials, key: 'some secret key', marshal: true
  end
```

You may also optionally specify `:marshaler`, `:dump_method`, and `:load_method` if you want to use something other than the default `Marshal` object.

### The `:allow_empty_value` option

You may want to encrypt empty strings or nil so as to not reveal which records are populated and which records are not.

```ruby
  class User
    attr_encrypted :credentials, key: 'some secret key', marshal: true, allow_empty_value: true
  end
```


## ORMs

### ActiveRecord

If you're using this gem with `ActiveRecord`, you get a few extra features:

#### Default options

The `:encode` option is set to true by default.

#### Dynamic `find_by_` and `scoped_by_` methods

Let's say you'd like to encrypt your user's email addresses, but you also need a way for them to login. Simply set up your class like so:

```ruby
  class User < ActiveRecord::Base
    attr_encrypted :email, key: 'This is a key that is 256 bits!!'
    attr_encrypted :password, key: 'some other secret key'
  end
```

You can now lookup and login users like so:

```ruby
  User.find_by_email_and_password('test@example.com', 'testing')
```

The call to `find_by_email_and_password` is intercepted and modified to `find_by_encrypted_email_and_encrypted_password('ENCRYPTED EMAIL', 'ENCRYPTED PASSWORD')`. The dynamic scope methods like `scoped_by_email_and_password` work the same way.

NOTE: This only works if all records are encrypted with the same encryption key (per attribute).

__NOTE: This feature is deprecated and will be removed in the next major release.__


### DataMapper and Sequel

#### Default options

The `:encode` option is set to true by default.


## Deprecations

attr_encrypted v2.0.0 now depends on encryptor v2.0.0. As part of both major releases many insecure defaults and behaviors have been deprecated. The new default behavior is as follows:

* Default `:mode` is now `:per_attribute_iv`, the default `:mode` in attr_encrypted v1.x was `:single_iv_and_salt`.
* Default `:algorithm` is now 'aes-256-gcm', the default `:algorithm` in attr_encrypted v1.x was 'aes-256-cbc'.
* The encryption key provided must be of appropriate length respective to the algorithm used. Previously, encryptor did not verify minimum key length.
* The dynamic finders available in ActiveRecord will only work with `:single_iv_and_salt` mode. It is strongly advised that you do not use this mode. If you can search the encrypted data, it wasn't encrypted securely. This functionality will be deprecated in the next major release.
* `:per_attribute_iv_and_salt` and `:single_iv_and_salt` modes are deprecated and will be removed in the next major release.

Backwards compatibility is supported by providing a special option that is passed to encryptor, namely, `:insecure_mode`:

```ruby
  class User
    attr_encrypted :email, key: 'a secret key', algorithm: 'aes-256-cbc', mode: :single_iv_and_salt, insecure_mode: true
  end
```

The `:insecure_mode` option will allow encryptor to ignore the new security requirements. It is strongly advised that if you use this older insecure behavior that you migrate to the newer more secure behavior.


## Upgrading from attr_encrypted v1.x to v3.x

Modify your gemfile to include the new version of attr_encrypted:

```ruby
  gem attr_encrypted, "~> 3.0.0"
```

The update attr_encrypted:

```bash
  bundle update attr_encrypted
```

Then modify your models using attr\_encrypted to account for the changes in default options. Specifically, pass in the `:mode` and `:algorithm` options that you were using if you had not previously done so. If your key is insufficient length relative to the algorithm that you use, you should also pass in `insecure_mode: true`; this will prevent Encryptor from raising an exception regarding insufficient key length. Please see the Deprecations sections for more details including an example of how to specify your model with default options from attr_encrypted v1.x.

## Upgrading from attr_encrypted v2.x to v3.x

A bug was discovered in Encryptor v2.0.0 that inccorectly set the IV when using an AES-\*-GCM algorithm. Unfornately fixing this major security issue results in the inability to decrypt records encrypted using an AES-*-GCM algorithm from Encryptor v2.0.0. Please see [Upgrading to Encryptor v3.0.0](https://github.com/attr-encrypted/encryptor#upgrading-from-v200-to-v300) for more info.

It is strongly advised that you re-encrypt your data encrypted with Encryptor v2.0.0. However, you'll have to take special care to re-encrypt. To decrypt data encrypted with Encryptor v2.0.0 using an AES-\*-GCM algorithm you can use the `:v2_gcm_iv` option.

It is recommended that you implement a strategy to insure that you do not mix the encryption implementations of Encryptor. One way to do this is to re-encrypt everything while your application is offline.Another way is to add a column that keeps track of what implementation was used. The path that you choose will depend on your situtation. Below is an example of how you might go about re-encrypting your data.

```ruby
  class User
    attr_encrypted :ssn, key: :encryption_key, v2_gcm_iv: is_decrypting?(:ssn)

    def is_decrypting?(attribute)
      encrypted_attributes[attribute][:operation] == :decrypting
    end
  end

  User.all.each do |user|
    old_ssn = user.ssn
    user.ssn= old_ssn
    user.save
  end
```

## Things to consider before using attr_encrypted

#### Searching, joining, etc
While choosing to encrypt at the attribute level is the most secure solution, it is not without drawbacks. Namely, you cannot search the encrypted data, and because you can't search it, you can't index it either. You also can't use joins on the encrypted data. Data that is securely encrypted is effectively noise. So any operations that rely on the data not being noise will not work. If you need to do any of the aforementioned operations, please consider using database and file system encryption along with transport encryption as it moves through your stack.

#### Data leaks
Please also consider where your data leaks. If you're using attr_encrypted with Rails, it's highly likely that this data will enter your app as a request parameter. You'll want to be sure that you're filtering your request params from you logs or else your data is sitting in the clear in your logs. [Parameter Filtering in Rails](http://apidock.com/rails/ActionDispatch/Http/FilterParameters) Please also consider other possible leak points.

#### Storage requirements
When storing your encrypted data, please consider the length requirements of the db column that you're storing the cipher text in. Older versions of Mysql attempt to 'help' you by truncating strings that are too large for the column. When this happens, you will not be able to decrypt your data. [MySQL Strict Trans](http://www.davidpashley.com/2009/02/15/silently-truncated/)

#### Metadata regarding your crypto implementation
It is advisable to also store metadata regarding the circumstances of your encrypted data. Namely, you should store information about the key used to encrypt your data, as well as the algorithm. Having this metadata with every record will make key rotation and migrating to a new algorithm signficantly easier. It will allow you to continue to decrypt old data using the information provided in the metadata and new data can be encrypted using your new key and algorithm of choice.

#### Enforcing the IV as a nonce
On a related note, most alorithms require that your IV be unique for every record and key combination. You can enforce this using composite unique indexes on your IV and encryption key name/id column. [RFC 5084](https://tools.ietf.org/html/rfc5084#section-1.5)

#### Unique key per record
Lastly, while the `:per_attribute_iv_and_salt` mode is more secure than `:per_attribute_iv` mode because it uses a unique key per record, it uses a PBKDF function which introduces a huge performance hit (175x slower by my benchmarks). There are other ways of deriving a unique key per record that would be much faster.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, changelog, or history.
* Send me a pull request. Bonus points for topic branches.
