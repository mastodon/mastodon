# attr_encrypted #

## 3.1.0 ##
* Added: Abitilty to encrypt empty values. (@tamird)
* Added: MIT license
* Added: MRI 2.5.x support (@saghaulor)
* Fixed: No long generate IV and salt if value is empty, unless :allow_empty_value options is passed. (@saghaulor)
* Fixed: Only generate IV and salt when :if and :unless options evaluate such that encryption should be performed. (@saghaulor)
* Fixed: Private methods are correctly evaluated as options. (@saghaulor)
* Fixed: Mark virtual attributes for Rails 5.x compatibility (@grosser)
* Fixed: Only check empty on strings, allows for encrypting non-string type objects
* Fixed: Fixed how accessors for db columns are defined in the ActiveRecord adapter, preventing premature definition. (@nagachika)

## 3.0.3 ##
* Fixed: attr_was would decrypt the attribute upon every call. This is inefficient and introduces problems when the options change between decrypting an old value and encrypting a new value; for example, when rotating the encryption key. As such, the new approach caches the decrypted value of the old encrypted value such that the old options are no longer needed. (@johnny-lai) (@saghaulor)

## 3.0.2 ##
* Changed: Removed alias_method_chain for compatibility with Rails v5.x (@grosser)
* Changed: Updated Travis build matrix to include Rails 5. (@saghaulor) (@connorshea)
* Changed: Removed `.silence_stream` from tests as it has been removed from Rails 5. (@sblackstone)

## 3.0.1 ##
* Fixed: attr_was method no longer calls undefined methods. (@saghaulor)

## 3.0.0 ##
* Changed: Updated gemspec to use Encryptor v3.0.0. (@saghaulor)
* Changed: Updated README with instructions related to moving from v2.0.0 to v3.0.0. (@saghaulor)
* Fixed: ActiveModel::Dirty methods in the ActiveRecord adapter. (@saghaulor)

## 2.0.0 ##
* Added: Now using Encryptor v2.0.0 (@saghaulor)
* Added: Options are copied to the instance. (@saghaulor)
* Added: Operation option is set during encryption/decryption to allow options to be evaluated in the context of the current operation. (@saghaulor)
* Added: IV and salt can be conditionally encoded. (@saghaulor)
* Added: Changelog! (@saghaulor)
* Changed: attr_encrypted no longer extends object, to use with PORO extend your class, all supported ORMs are already extended. (@saghaulor)
* Changed: Salt is now generated with more entropy. (@saghaulor)
* Changed: The default algorithm is now `aes-256-gcm`. (@saghaulor)
* Changed: The default mode is now `:per_attribute_iv`' (@saghaulor)
* Changed: Extracted class level default options hash to a private method. (@saghaulor)
* Changed: Dynamic finders only work with `:single_iv_and_salt` mode. (@saghaulor)
* Changed: Updated documentation to include v2.0.0 changes and 'things to consider' section. (@saghaulor)
* Fixed: All options are evaluated correctly. (@saghaulor)
* Fixed: IV is generated for every encryption operation. (@saghaulor)
* Deprecated: `:single_iv_and_salt` and `:per_attribute_iv_and_salt` modes are deprecated and will be removed in the next major release. (@saghaulor)
* Deprecated: Dynamic finders via `method_missing` is deprecated and will be removed in the next major release. (@saghaulor)
* Removed: Support for Ruby < 2.x (@saghaulor)
* Removed: Support for Rails < 3.x (@saghaulor)
* Removed: Unnecessary use of `alias_method` from ActiveRecord adapter. (@saghaulor)

## 1.4.0 ##
* Added: ActiveModel::Dirty#attribute_was (@saghaulor)
* Added: ActiveModel::Dirty#attribute_changed? (@mwean)

## 1.3.5 ##
* Changed: Fixed gemspec to explicitly depend on Encryptor v1.3.0 (@saghaulor)
* Fixed: Evaluate `:mode` option as a symbol or proc. (@cheynewallace)

## 1.3.4 ##
* Added: ActiveRecord::Base.reload support. (@rcook)
* Fixed: ActiveRecord adapter no longer forces attribute hashes to be string-keyed. (@tamird)
* Fixed: Mass assignment protection in ActiveRecord 4. (@tamird)
* Changed: Now using rubygems over https. (@tamird)
* Changed: Let ActiveRecord define attribute methods. (@saghaulor)

## 1.3.3 ##
* Added: Alias attr_encryptor and attr_encrpted. (@Billy Monk)

## 1.3.2 ##
* Fixed: Bug regarding strong parameters. (@S. Brent Faulkner)
* Fixed: Bug regarding loading per instance IV and salt. (@S. Brent Faulkner)
* Fixed: Bug regarding assigning nil. (@S. Brent Faulkner)
* Added: Support for protected attributes. (@S. Brent Faulkner)
* Added: Support for ActiveRecord 4. (@S. Brent Faulkner)

## 1.3.1 ##
* Added: Support for Rails 2.3.x and 3.1.x. (@S. Brent Faulkner)

## 1.3.0 ##
* Fixed: Serialization bug. (@Billy Monk)
* Added: Support for :per_attribute_iv_and_salt mode. (@rcook)
* Fixed: Added dependencies to gemspec. (@jmazzi)

## 1.2.1 ##
* Added: Force encoding when not marshaling. (@mosaicxm)
* Fixed: Issue specifying multiple attributes on the same line. (@austintaylor)
* Added: Typecasting to String before encryption (@shuber)
* Added: `"#{attribute}?"` method. (@shuber)

## 1.2.0 ##
* Changed: General code refactoring (@shuber)

## 1.1.2 ##
* No significant changes

## 1.1.1 ##
* Changled: Updated README. (@shuber)
* Added: `before_type_cast` alias to ActiveRecord adapter. (@shuber)
